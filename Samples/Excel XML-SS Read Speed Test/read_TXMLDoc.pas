unit read_TXMLDoc;

interface

uses xml_read_Intf, vcl.Grids, xmlIntf, XMLDOM;

type

  TxDocReader = class(TxReader)
  private
    const SS_NS = 'urn:schemas-microsoft-com:office:spreadsheet';
    type rRowCellInfo = TxReader.rRowCellInfo;
    type tCellHandler = procedure (const row, cell: IDOMNode;
                const info: rRowCellInfo) of object;

    procedure ScanRow( const row: IDOMNode;
                       var info: rRowCellInfo;
                       const ForCell: tCellHandler = nil);
    procedure FillGridCell(const row, cell: IDOMNode;
                const info: rRowCellInfo);
  protected
    rd: IXMLDocument;
    function  GetMSXPath: IDOMNodeSelect;

    procedure DoParseSheets; override;
    procedure DoParseCells(const SheetName: string; Const Data: Pointer); override;
  end;

implementation

uses XMLDoc, Xml.Win.msxmldom, WinAPI.msxml, SysUtils;

{ TxDocReader }

function TxDocReader.GetMSXPath: IDOMNodeSelect;
var
  ms:  IXMLDOMDocument2;
  ms1: IXMLDOMDocument;
  sel: IDOMNodeSelect;
begin
  Result := nil;

  // http://stackoverflow.com/a/1352556/976391

  if Supports(rd.DocumentElement.DOMNode,
     IDOMNodeSelect, sel) then
  begin
    ms1 := (rd.DOMDocument as TMSDOMDocument).MSDocument;
    if Supports( ms1, IXMLDOMDocument2, ms) then begin

        // http://stackoverflow.com/a/39708963/976391  !!!
       ms.setProperty('SelectionNamespaces',
            'xmlns:excel="' + SS_NS + '" ');
//            'xmlns:excel="urn:schemas-microsoft-com:office:spreadsheet" ');
       ms.setProperty('SelectionLanguage', 'XPath');
    end;

    Result := sel;
  end;
end;

procedure TxDocReader.DoParseSheets;
var
  i: integer;
  s: string;
  ns:  IDOMNodeList;
  n:   IDOMNode;
  sel: IDOMNodeSelect;
begin
  if nil = rd then
     rd := TXMLDocument.Create(nil);

  rd.LoadFromFile( FileName );

  sel := GetMSXPath;

  if nil <> sel then
  begin
    ns := sel.selectNodes('/excel:Workbook/excel:Worksheet/@excel:Name');

    for i := 0 to ns.length - 1 do
    begin
      n := ns.item[i];
      s := n.nodeValue;
      FSheetList.Add( s );
    end;
  end;
end;

procedure TxDocReader.DoParseCells(const SheetName: string; Const Data: Pointer);
var
  info: rRowCellInfo;
  i: integer;
  s: string; q: char;
  ns : IDOMNodeList;
  n  : IDOMNode;
  sel: IDOMNodeSelect;
begin
  if nil = rd then begin
     rd := TXMLDocument.Create(nil);
     rd.LoadFromFile( FileName );
  end;

  sel := GetMSXPath;

  q := '"';
  if Pos(q,SheetName) > 0 then q := '''';
  if Pos(q,SheetName) > 0 then
     raise ENotSupportedException.Create(
           'Название листа не поддерживается в XML XPath'#13#10 + SheetName );

  s := '/excel:Workbook/excel:Worksheet[@excel:Name = '
          +   AnsiQuotedStr( SheetName, q ) +
       ']/excel:Table/excel:Row';

  ns := sel.selectNodes( s );

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

{.$Define ByIndex}

procedure TxDocReader.ScanRow(const row: IDOMNode; var info: rRowCellInfo;
  const ForCell: tCellHandler);
var
  cell: IDomNode;
{$IfDef ByIndex}
  ns: IDOMNodeList;
  i: integer;
{$EndIf}

  procedure IncIndex(var Index, Max: cardinal; const RowCell: IDOMNode);
  var
    an: IDOMNode;
    attrs: IDOMNamedNodeMap;
    k: integer;
    s: string;
  begin
    Inc( Index );

    attrs := RowCell.attributes;
    if attrs <> nil then begin
//         if attrs.length > 0 then begin
//            an := attrs.item[ 0 ];  // debug
//            s := an.nodeName;
//            s := an.localName;
//         end;
       an := attrs.getNamedItemNS( SS_NS, 'Index');
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
    if row.hasChildNodes then begin
      ns := row.childNodes;
      for i := 0 to ns.length - 1 do begin
        cell := ns[i];
{$Else}
      cell := row.firstChild; // should be 'ss:Cell'
      while cell <> nil do try
{$EndIf}
        if not SameText(cell.localName, 'Cell') then
           Continue;

        IncIndex( cur_Col, max_Col, cell );

        if Assigned(ForCell) then
           ForCell( row, cell, info);

{$IfNDef ByIndex}
      finally
        cell := cell.nextSibling;
{$EndIf}
      end;
{$IfDef ByIndex}
    end;
{$EndIf}
  end;
end;

procedure TxDocReader.FillGridCell(const row, cell: IDOMNode;
  const info: rRowCellInfo);
var
  s: string;
  an: IDOMNode;
begin
  s := '';

  if cell.hasChildNodes then begin
     an := cell.firstChild;
     while an <> nil do begin
       if SameText(an.localName, 'Data') then
       begin
          an := an.firstChild;
          while an <> nil do begin
            if an.nodeType = TEXT_NODE then begin
               s := an.nodeValue;
               break;
            end;
            an := an.nextSibling;
          end;
          break;
       end;
       an := an.nextSibling;
     end;
  end;

  FDataGrid.Cells[info.cur_Col-1, info.cur_Row-1] := s;
end;

end.
