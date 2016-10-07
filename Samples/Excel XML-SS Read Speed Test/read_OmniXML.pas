unit read_OmniXML;

interface

uses xml_read_Intf, vcl.Grids, OmniXML;

type
  TxOmniXMLReader = class(TxReader)
  private
    type rRowCellInfo = TxReader.rRowCellInfo;
    type tCellHandler = procedure (const row, cell: IXMLNode;
                const info: rRowCellInfo) of object;

    procedure ScanRow( const row: IXMLNode;
                       var info: rRowCellInfo;
                       const ForCell: tCellHandler = nil);
    procedure FillGridCell(const row, cell: IXMLNode;
                const info: rRowCellInfo);
  protected
    Sheets: Array of IXMLNode;
    rd: IXMLDocument;
    // function  GetMSXPath: IDOMNodeSelect;

    procedure DoParseSheets; override;
    procedure DoParseCells(const SheetName: string; Const Data: Pointer); override;
  end;

implementation

uses OmniXMLXPath, SysUtils;

procedure TxOmniXMLReader.DoParseSheets;
var
  i: integer;
  s: string;
  ns:  IXMLNodeList;
  n:   IXMLNode;
begin
  if nil = rd then
     rd := TXMLDocument.Create();

  if not rd.Load( FileName ) then
     raise EXMLException.Create('Не могу загрузить файл');


//  ns := XPathSelect( rd, '/excel:Workbook/excel:Worksheet/@excel:Name');
  ns := XPathSelect( rd, 'Workbook/Worksheet/@ss:Name');
  // нет разделения на namespace/localname !!!!!

  SetLength( Sheets, ns.length );
  for i := 0 to ns.length - 1 do
  begin
    n := ns.item[i];
    s := n.nodeValue;
    FSheetList.AddObject( s, pointer( i ) );
    Sheets[i] := n;
  end;
end;

procedure TxOmniXMLReader.DoParseCells(const SheetName: string; Const Data: Pointer);
var
  info: rRowCellInfo;
  i: integer;
//  s: string; q: char;
  ns : IXMLNodeList;
  n  : IXMLNode;
begin
  if nil = rd then
     DoParseSheets;

  Pointer(i) := Data;
  if i >= Low(Sheets) then
     if i <= High(Sheets) then
        if Sheets[i].NodeValue = SheetName then
           n := Sheets[i];
  if nil = n then begin
     i := -1;
     for n in Sheets do
        if n.NodeValue = SheetName then
        begin
          i := 1;
          break;
        end;
     if i < 0 then
        n := nil;
  end;
  if n = nil then exit;
  n := n.ParentNode;

  ns := XPathSelect( n, 'Table/Row');

  if ns = nil then exit; // not found
  if ns.length <= 0 then exit; // not found

  info.max_Row := 0;
  info.max_Col := 0;

  info.cur_Row := 0;
  for i := 0 to ns.length - 1 do begin
      n := ns.item[ i ]; // строка
      ScanRow( n, info );
  end;


  if FFillGrid then
  begin
    FDataGrid.RowCount := 0;
    FDataGrid.ColCount := info.max_Col;
    FDataGrid.RowCount := info.max_Row;
  end;

  if not FFillGrid then
     exit;

  info.cur_Row := 0;
  for i := 0 to ns.length - 1 do
  begin
    n := ns.item[ i ]; // строка
    ScanRow( n, info, FillGridCell );
  end;
end;

{$Define ByIndex}

procedure TxOmniXMLReader.ScanRow(const row: IxmlNode; var info: rRowCellInfo;
  const ForCell: tCellHandler);
var
  cell: IxmlNode;
{$IfDef ByIndex}
  cells: IXMLNodeList;
  i : integer;
{$EndIf}

  procedure IncIndex(var Index, Max: cardinal; const RowCell: IxmlNode);
  var
    an: IxmlNode;
    attrs: IxmlNamedNodeMap;
    k: integer;
    s: string;
  begin
    Inc( Index );

    attrs := RowCell.attributes;
    if attrs <> nil then begin
       an := attrs.getNamedItem( 'ss:Index');
       if an = nil then
          an := attrs.getNamedItem( 'Index');
       if an <> nil then begin
          s := an.nodeValue;
          s := Trim( s );
          if TryStrToInt( s, k ) then
             Index := k;
       end;
    end;

    if Max < Index then
       Max := Index;
  end;
begin
  with info do begin

    IncIndex( cur_Row, max_Row, row );

    cur_Col := 0;
{$IfDef ByIndex}
    cells := row.ChildNodes;
    for i := 0 to cells.Length-1 do begin
      cell := cells.Item[i];
{$Else}
    cell := row.firstChild; // should be 'ss:Cell'
    while cell <> nil do try
{$EndIf}

      if not SameText(cell.NodeName, 'Cell') then
        if not SameText(cell.NodeName, 'ss:Cell') then
          Continue;

      IncIndex( cur_Col, max_Col, cell );

      if Assigned(ForCell) then
         ForCell( row, cell, info);

{$IfNDef ByIndex}
    finally
      cell := cell.nextSibling;
{$EndIf}
    end;
  end;
end;

procedure TxOmniXMLReader.FillGridCell(const row, cell: IxmlNode;
  const info: rRowCellInfo);
var
  s: string;
  an: IxmlNode;
{$IfDef ByIndex}
  i, j: integer;
  ns: IXMLNodeList;
{$EndIF}
begin
  s := '';

  if cell.hasChildNodes then begin
{$IfDef ByIndex}
     ns := cell.ChildNodes;
     for i := 0 to ns.Length-1 do begin
       an := ns.Item[i];
{$Else}
     an := cell.firstChild;
     while an <> nil do begin
{$EndIF}
       if an.HasChildNodes then
       if SameText(an.NodeName, 'ss:Data') or
          SameText(an.NodeName, 'Data') then
       begin
{$IfDef ByIndex}
          ns := an.ChildNodes;
          for j := 0 to ns.Length-1 do begin
            an := ns.Item[j];
{$Else}
          an := an.firstChild;
          while an <> nil do begin
{$EndIF}
            if an.nodeType = TEXT_NODE then begin
               s := an.nodeValue;
               break;
            end;
{$IfNDef ByIndex}
            an := an.nextSibling;
{$EndIF}
          end;
          break;
       end;
{$IfNDef ByIndex}
       an := an.nextSibling;
{$EndIF}
     end;
  end;

  FDataGrid.Cells[info.cur_Col-1, info.cur_Row-1] := s;
end;

end.
