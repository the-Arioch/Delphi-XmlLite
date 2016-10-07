unit read_xmlLite;

interface

uses XMLLite, xml_read_Intf, vcl.Grids;

type
  TxLiteReader = class(TxReader)
  private
    type rRowCellInfo = TxReader.rRowCellInfo;
    type rSheetInfo = record
                        name: string;
                        max_row, max_col: cardinal;
                        start_line, start_col, tag_depth: cardinal;
                     end;

    var SheetsMaxes: TArray<rSheetInfo>;
    const SheetNameSizeGap = 3;

    function GetNodeValue(const rd: IXMLReader; out Value: string): boolean;
    function GetNodeLocalName(const rd: IXMLReader; out Name: string): boolean;
    function IsNodeLocalName(const rd: IXMLReader; const Name: string): boolean;
    function GetNamedAttr(const rd: IXMLReader; const Name: string; out Value: string): boolean;

    type tCellHandler = procedure (const rd: IXMLReader;
                const info: rRowCellInfo) of object;

    procedure ScanSheet( const rd: IXMLReader;
                       var info: rRowCellInfo;
                       const ForCell: tCellHandler = nil);
    procedure FillGridCell(const rd: IXMLReader;
                const info: rRowCellInfo);

  protected
    procedure DoParseSheets; override;
    procedure DoParseCells(const SheetName: string; Const Data: Pointer); override;
  end;

implementation

uses SysUtils, System.Generics.Collections;

{ TxLiteReader }

function TxLiteReader.GetNodeValue(const rd: IXMLReader;
  out Value: string): boolean;
var
  pName: PWideChar;
  lenName: Cardinal;
begin
  Result := False;
  if EXmlLite.IsOK( rd.GetValue(pName, lenName) ) then
  begin
    SetString( Value, pName, lenName );
    // UniqueString( Value );  DocuWiki: SetString then copies Length characters from Buffer into the string;
    Result := True;
  end;
end;

function TxLiteReader.GetNodeLocalName(const rd: IXMLReader;
  out Name: string): boolean;
var
  pName: PWideChar;
  lenName: Cardinal;
begin
  Result := False;
  if EXmlLite.IsOK( rd.GetLocalName(pName, lenName) ) then
  begin
    SetString( Name, pName, lenName );
    Result := True;
  end;
end;

function TxLiteReader.IsNodeLocalName(const rd: IXMLReader;
  const Name: string): boolean;
var
  pName: string;
begin
  Result := False;
  if GetNodeLocalName(rd, pName) then
    Result := SameText( pName, Name );
  // честно говоря, надо бы SameStr - XML должен быть case-sensitive
end;

function TxLiteReader.GetNamedAttr(const rd: IXMLReader; const Name: string;
  out Value: string): boolean;
begin
  Result := False;
  try
    if EXmlLite.IsOK(rd.MoveToFirstAttribute()) then
    repeat
      if IsNodeLocalName(rd, Name) then begin
         Result := GetNodeValue( rd, Value );
         break;
      end;
    until not EXmlLite.IsOK( rd.MoveToNextAttribute() );
  finally
    CheckHR( rd.MoveToElement );
  end;
end;

procedure TxLiteReader.DoParseSheets;
var
  rd: IXMLReader;
  nodeType: XmlNodeType;

  maxes: TList<rSheetInfo>;
  sheet: rSheetInfo;
  info: rRowCellInfo;
begin
  rd := CreateXmlFileReader(FileName);

  maxes := TList<rSheetInfo>.Create;
  try
    maxes.Capacity := 8;

    while not rd.IsEOF do
    begin
      if not EXmlLite.IsOK(rd.Read(nodeType)) then break;

      (*   DEBUG
      if not EXmlLite.IsOK(rd.GetLineNumber(sheet.start_line)) then
         sheet.start_line := 0;
      if not EXmlLite.IsOK(rd.GetLinePosition(sheet.start_col)) then
         sheet.start_col := 0;
      if not EXmlLite.IsOK( rd.GetDepth( sheet.tag_depth ) ) then
         sheet.tag_depth := 0;

         Resume:
          1) Depth is ZERO-based ( is zero for <?xml ... >)
          2) LineNum is ONE-based ( is one for first file line )
          3) LinePos is ONE-based and points to the tag's letter
               ( is two for <root ...> and is three for <?xml ...>)
      *)

      if nodeType <> XmlNodeType.Element then continue;

//      rd.GetLocalName(pName, lenName);
//      if not SameText( string(pName), 'Worksheet') then continue;
      if not IsNodeLocalName( rd, 'Worksheet' ) then continue;

      if not EXmlLite.IsOK( rd.GetDepth( sheet.tag_depth ) ) then
         sheet.tag_depth := 0;
      if not EXmlLite.IsOK(rd.GetLineNumber(sheet.start_line)) then
         sheet.start_line := 0;
      if not EXmlLite.IsOK(rd.GetLinePosition(sheet.start_col)) then
         sheet.start_col := 0;

      sheet.name := '  - БЕЗ ИМЕНИ !!! -';
      GetNamedAttr( rd, 'Name', sheet.name);

      ScanSheet( rd, info );

      sheet.max_row := info.max_Row;
      sheet.max_col := info.max_Col;

      sheet.name := sheet.name + StringOfChar(' ', SheetNameSizeGap) +
          '[' + IntToStr(info.max_Col) +'x' + IntToStr(info.max_Row) + ']';

      FSheetList.AddObject( sheet.name, pointer( maxes.Add( sheet ) ) );
    end;

    SheetsMaxes := maxes.ToArray();
  finally
    maxes.Destroy;
  end;
end;

procedure TxLiteReader.DoParseCells(const SheetName: string; Const Data: Pointer);
var
  rd: IXMLReader;
  nodeType: XmlNodeType;
  pName: PWideChar;
  lenName: Cardinal;

  i: integer; u: Cardinal;
  s: string;
  ShowCell: tCellHandler;

  SheetStarted, SameSheet: boolean;
  SheetCursorFound: boolean;
  sheet: rSheetInfo;

  info: rRowCellInfo;
begin
  rd := CreateXmlFileReader(FileName);

  SheetStarted := false;
  SheetCursorFound := false;

  i := integer(Data);
  if i <= High(SheetsMaxes) then
     if i >= Low(SheetsMaxes) then
     begin
       sheet := SheetsMaxes[i];
       SheetCursorFound := sheet.name = SheetName;
     end;
  if not SheetCursorFound then
     for sheet in SheetsMaxes do
         if sheet.name = SheetName then
         begin
           SheetCursorFound := true;
           break;
         end;
  SheetCursorFound := SheetCursorFound
     and (sheet.tag_depth > 0)
     and (sheet.start_col > 0)
     and (sheet.start_line > 0);

  if not SheetCursorFound then begin
     // нужно искать по имени - а значит восстановить имя
     Sheet.Name := SheetName;
     i := Length( Sheet.Name );
     while i >= 1 + SheetNameSizeGap do begin
       if Sheet.Name[i] = '[' then begin
          SetLength( Sheet.Name, i - SheetNameSizeGap - 1 );
          break;
       end;
       Dec(i);
     end;
  end;

  {$Region 'в оглавлении не нашли - перечитать файл!'}
  if not SheetCursorFound then
  with info do
  begin
    // лишний прогон файла - ищём размеры листа
    // вообще не должно никогда вызывaться, старый код

    max_Row := 0;
    cur_Row := 0;
    max_Col := 0;
    cur_Col := 0;

    while not rd.IsEOF do
    begin
      if S_OK <> rd.Read(nodeType) then break;
      if nodeType <> XmlNodeType.Element then continue;

      rd.GetLocalName(pName, lenName);

      if SameText( string(pName), 'Worksheet') then begin
        SameSheet := False;
        if S_OK = rd.MoveToFirstAttribute() then
        repeat
          rd.GetLocalName(pName, lenName);
          if SameText(string(pName), 'Name') then begin
             if S_OK = rd.GetValue(pName, lenName) then begin
                SameSheet := SameText( pName, SheetName );
                break;
             end;
          end;
        until (S_OK  <> rd.MoveToNextAttribute() );

        if not SameSheet then begin
           if SheetStarted then break;        // начался следующий лист - хватит
           if not SheetStarted then Continue; // ищем следующий лист
        end;
        SheetStarted := True;
      end else
      if not SheetStarted then begin
         continue       // наш лист ещё не начался
      end else
      if SameText( string(pName), 'Row') then begin

        Inc(cur_Row);
        if S_OK = rd.MoveToFirstAttribute() then
        repeat
          rd.GetLocalName(pName, lenName);
          if SameText(string(pName), 'Index') then begin
             if S_OK = rd.GetValue(pName, lenName) then begin
                if TryStrToInt(Trim(pName), i) then
                   cur_Row := i;
                break;
             end;
          end;
        until (S_OK  <> rd.MoveToNextAttribute() );

        cur_Col := 0;
        if cur_Row > max_Row then
           max_Row := cur_Row;
      end else
      if SameText( string(pName), 'Cell') then begin

        Inc(cur_Col);
        if S_OK = rd.MoveToFirstAttribute() then
        repeat
          rd.GetLocalName(pName, lenName);
          if SameText(string(pName), 'Index') then begin
             if S_OK = rd.GetValue(pName, lenName) then begin
                if TryStrToInt(Trim(pName), i) then
                   cur_Col := i;
                break;
             end;
          end;
        until (S_OK  <> rd.MoveToNextAttribute() );

        if cur_Col > max_Col then
           max_Col := cur_Col;
      end else
      ;
    end;

    sheet.max_row := max_Row;
    sheet.max_col := max_Col;

    rd := CreateXmlFileReader(FileName); // начинаем с начала
  end;
  {$EndRegion}

  if FFillGrid then
  begin
    FDataGrid.RowCount := 0;
    FDataGrid.ColCount := sheet.max_Col;
    FDataGrid.RowCount := sheet.max_Row;
  end;

  if FFillGrid
     then ShowCell := FillGridCell
     else ShowCell := nil;

  while not rd.IsEOF do
  begin
    if not EXmlLite.IsOK(rd.Read(nodeType)) then
       break;

    if nodeType <> XmlNodeType.Element then
       continue;

    if SheetCursorFound then begin
       // ищем по положению курсора
      if not EXmlLite.IsOK(rd.GetLineNumber(u)) then
         Continue;
      if u < sheet.start_line then
         Continue;
      if u > sheet.start_line then
         Break; // пролетели мимо

      if not EXmlLite.IsOK(rd.GetLinePosition(u)) then
         Continue;
      if u <> sheet.start_col then
         Continue;

      // глубину вложенности проверять быть может не обязательно
      // Хотя если WhiteList-элемент может быть нулевой длины?..
      if not EXmlLite.IsOK(rd.GetDepth(u)) then
         Continue;
      if u <> sheet.tag_depth then
         Continue;
    end else begin
       // ищем по имени
      if not IsNodeLocalName( rd, 'Worksheet' ) then
         continue;
      if not GetNamedAttr( rd, 'Name', s) then
         continue;
      if not SameText( s, Sheet.Name ) then
         continue;
    end;

    {$IfOpt D+}
      GetNodeLocalName(rd, s);
      GetNodeValue(rd, s);
      GetNamedAttr( rd, 'Name', s);
    {$EndIf}
    ScanSheet( rd, info, ShowCell );
    break;
  end;
end;

procedure TxLiteReader.ScanSheet(const rd: IXMLReader;
  var info: rRowCellInfo;
  const ForCell: tCellHandler);
var CurrDepth, SheetDepth: Cardinal;
    nodeType: XmlNodeType;
    tag: string;

  procedure IncIndex(const rd: IXMLReader; var Index, Max: cardinal);
  var
    k: integer;
    s: string;
  begin
    Inc( Index );

    if GetNamedAttr( rd, 'Index', s ) then
    begin
      s := Trim( s );
      if TryStrToInt( s, k ) then
         Index := k;
    end;

    if Max < Index then
       Max := Index;
  end;

begin
  info.max_Col := 0;
  info.cur_Row := 0;
  info.max_Row := 0;

  if rd.IsEmptyElement then
     exit;

  CheckHR(rd.GetDepth( SheetDepth ));
  Inc(SheetDepth);

  while EXmlLite.IsOK(rd.Read(nodeType)) do begin
    CheckHR(rd.GetDepth( CurrDepth ));
    if CurrDepth < SheetDepth then
       break;
//
//    if (nodeType = XmlNodeType_EndElement) and
//       (CurrDepth = SheetDepth) then
//       break;

    if nodeType <> XmlNodeType.Element then
       continue;

    if not GetNodeLocalName( rd, tag ) then
       continue;

//    if IsNodeLocalName( rd, 'Row' ) then begin
    if SameText( tag, 'Row' ) then begin

      IncIndex(rd, info.cur_Row, info.max_Row);

      info.cur_Col := 0;
    end else
//    if IsNodeLocalName( rd,  'Cell' ) then begin
    if SameText( tag,  'Cell' ) then begin

      IncIndex(rd, info.cur_Col, info.max_Col);

      if FFillGrid and Assigned( ForCell ) then
         ForCell( rd, info );
    end;
  end;
end;

// на входе yстановлены на ss:Cell
procedure TxLiteReader.FillGridCell(const rd: IXMLReader;
  const info: rRowCellInfo);
var
  s, part: string;
  CellDepth, DataDepth, CurrDepth: Cardinal;
  nodeType: XmlNodeType;
begin
  s := '';
  DataDepth := 0;
  try
    if rd.IsEmptyElement then exit; // Cell with no ss:Data tag
    CheckHR(rd.GetDepth( CellDepth ));
    Inc(CellDepth);

    while EXmlLite.IsOK(rd.Read(nodeType)) do begin
      CheckHR(rd.GetDepth( CurrDepth ));
      if CurrDepth < CellDepth then exit;
//    if (nodeType = XmlNodeType_EndElement) and
//       (CurrDepth = CellDepth) then
//       break;

      if nodeType <> XmlNodeType.Element then
         Continue;

      if IsNodeLocalName( rd, 'Data') then begin
         if not rd.IsEmptyElement then begin
            CheckHR(rd.GetDepth( DataDepth ));
            Inc(DataDepth);

            while EXmlLite.IsOK( rd.Read(nodeType) ) do begin
              CheckHR(rd.GetDepth( CurrDepth ));
              if CurrDepth < DataDepth then
                 break;
//              if (nodeType = XmlNodeType_EndElement) and
//                 (CurrDepth = DataDepth) then
//                 break;

              if (nodeType = XmlNodeType.Text) or
                 (nodeType = XmlNodeType.Whitespace) then
                if GetNodeValue(rd, part) then
                  s := s + part;
           end;
         end;
      end;

      // if DataDepth > 0 then exit;
    end;

  finally
    FDataGrid.Cells[info.cur_Col-1, info.cur_Row-1] := s;
  end;
end;

end.
