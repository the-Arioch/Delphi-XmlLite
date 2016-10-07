unit fxsParser;

interface

uses SysUtils;

type
  TfxsField = record
    type Attrs = set of (faValue, faType, faName);
  public
    Name: string;
    FieldType, Value: integer;
    ReadAttrs: Attrs;
  end;

  TfxsFields = TArray<TfxsField>;

  TfxsTable = record
    type Attrs = set of (taValue, taFrom, taWhere);
  public
    From, Where: string;
    Value: integer;
    ReadAttrs: Attrs;
  public
    Fields: TfxsFields;
  end;

  TfxsTables = TArray<TfxsTable>;

procedure WriteXML(const Data: TfxsTables; const ToFile: string);
function  ReadXML (const FromFile: string): TfxsTables;

implementation

uses XmlLite, System.Generics.Collections;


Type
  TTableList = TList< TfxsTable >;
  TFieldList = TList< TfxsField >;


// 1: xml tags and attrs are case-sensitive !!!
// 2: xml always consists of s SINGLE root tag
Const
  Tag_DocRoot = 'config';

  Tag_Table = 'table';
  Tag_Table_From  = 'from';
  Tag_Table_Where = 'where';
  Tag_Table_Value = 'value';

  Tag_Field = 'field';
  Tag_Field_Name  = 'name';
  Tag_Field_Type  = 'type';
  Tag_Field_Value = 'value';

procedure WriteXML(const Data: TfxsTables; const ToFile: string);
var
  wx: IXMLWriter;
  t: TfxsTable; f: TfxsField;

begin
  wx := CreateXmlFileWriter(ToFile);
  if wx = nil then raise Exception.Create(ToFile + #13#10 + 'Can not write to the given file.');

  EXmlLite.Check( wx.SetProperty(XmlWriterProperty.Indent, LongInt(True)) ); 
  // EXmlLite.Check( wx.SetProperty(XmlWriterProperty_OmitXmlDeclaration, LongInt(True)) ); 

  EXmlLite.Check( wx.WriteStartDocument( XmlStandalone.Omit ) );
  EXmlLite.Check( wx.WriteComment( '  Delphi XML-Lite Demo Sample File, can be deleted  ' ) );
  EXmlLite.Check( wx.Flush );

  EXmlLite.Check( wx.WriteStartElement( nil, Tag_DocRoot, nil) );
  for t in Data do begin
    EXmlLite.Check( wx.WriteStartElement( nil, Tag_Table, nil) );

//  Here we consider when saving ALL the record fields are necessarily filled. If not - add the checks then
//  if xxx in t.ReadAttrs then  

    EXmlLite.Check( wx.WriteAttributeString( '', Tag_Table_Value, '', PChar(IntToStr(t.Value)) ) );
    EXmlLite.Check( wx.WriteAttributeString( '', Tag_Table_From,  '', PChar(t.From)) );
    EXmlLite.Check( wx.WriteAttributeString( '', Tag_Table_Where, '', PChar(t.Where)) );

    for f in t.Fields do begin
       EXmlLite.Check( wx.WriteStartElement( nil, Tag_Field, nil) );

//  Here we consider when saving ALL the record fields are necessarily filled. If not - add the checks then
//  if xxx in f.ReadAttrs then 

       EXmlLite.Check( wx.WriteAttributeString( '', Tag_Field_Name,  '', PChar(f.Name)) );
       EXmlLite.Check( wx.WriteAttributeString( '', Tag_Field_Type,  '', PChar(IntToStr(f.FieldType)) ) );
       EXmlLite.Check( wx.WriteAttributeString( '', Tag_Field_Value, '', PChar(IntToStr(f.Value)) ) );

       EXmlLite.Check( wx.WriteEndElement );
    end;

    EXmlLite.Check( wx.WriteEndElement );
    EXmlLite.Check( wx.Flush );
  end;
  EXmlLite.Check( wx.WriteEndElement );
  EXmlLite.Check( wx.WriteEndDocument );
end;

function  ReadXML (const FromFile: string): TfxsTables;
var rx: IXMLReader;
    t: TfxsTable;   f:  TfxsField;
    ts: TTableList; fs: TFieldList;

    nodeType: XmlNodeType;
    HR: HResult;
    pName: PWideChar;
    lenName: Cardinal;

    CurrTableLevel, CurrLevel: Cardinal;
begin
  Result := nil;
  rx := CreateXmlFileReader( FromFile );
  if rx = nil then raise Exception.Create( FromFile + #13#10 + 'Can not read from the given file.');

  ts := nil; fs := nil;
  try
    ts := TTableList.Create;  ts.Capacity := 8;
    fs := TFieldList.Create;  fs.Capacity := 8;

    CurrTableLevel := 0;

    while not rx.IsEOF do
    begin
      HR := EXmlLite.Check( rx.Read(nodeType) );
      if HR = S_FALSE then break; // File is EOFed

      if nodeType <> XmlNodeType.Element then continue;

      EXmlLite.Check( rx.GetLocalName(pName, lenName) );
      if SameText( string(pName), Tag_Table) then
      begin
        t.ReadAttrs := [];
        t.Value     := 0;
        t.Fields    := nil;
        t.From      := '';
        t.Where     := '';

        fs.Clear;

        EXmlLite.Check( rx.GetDepth( CurrTableLevel ) ); // table tag level of nesting

        HR := rx.MoveToFirstAttribute();
        if HR <> S_FALSE then EXmlLite.Check( HR );
        if S_OK = HR then
        repeat
          EXmlLite.Check( rx.GetLocalName(pName, lenName) );

          if SameText(string(pName), Tag_Table_Value) then begin
             Assert( not( taValue in t.ReadAttrs ) );
             if EXmlLite.IsOK( rx.GetValue(pName, lenName) ) then begin
                t.Value := StrToInt( Trim( pName ) );
                Include( t.ReadAttrs, taValue );
             end;
          end else
          if SameText(string(pName), Tag_Table_From) then begin
             Assert( not( taFrom in t.ReadAttrs ) );
             if EXmlLite.IsOK( rx.GetValue(pName, lenName) ) then begin
                t.From := pName;
                Include( t.ReadAttrs, taFrom );
             end;
          end else
          if SameText(string(pName), Tag_Table_Where) then begin
             Assert( not( taWhere in t.ReadAttrs ) );
             if EXmlLite.IsOK( rx.GetValue(pName, lenName) ) then begin
                t.Where := pName;
                Include( t.ReadAttrs, taWhere );
             end;
          end;

        until not EXmlLite.IsOK( rx.MoveToNextAttribute() ) ;

        // After reading table-tag attributes now we are ready for reading nested field-tags

        // Whether the tag is self-closing <xxx .... /> then
        //    1: there would be no nested field-tags
        //    2: there would be no closing element-end typed tag
		
        EXmlLite.Check( rx.MoveToElement() ); // from attrs back to the table-tag itself
        if not rx.IsEmptyElement() then begin
          while not rx.IsEOF do
          begin
            HR := EXmlLite.Check( rx.Read(nodeType) );
            if HR = S_FALSE then break; // file got EOFed

            if nodeType = XmlNodeType.EndElement then
            begin
              EXmlLite.Check( rx.GetDepth( CurrLevel ) );
              if CurrLevel <= 1 + CurrTableLevel then
                 // Quitting the table-tag. Waiting no more for field-tags until a next table-tag started
                 break;
            end;

            if nodeType <> XmlNodeType.Element then continue;

            EXmlLite.Check( rx.GetLocalName(pName, lenName) );
            if SameText( string(pName), Tag_Field) then
            begin
              f.ReadAttrs := [];
              f.FieldType := 0;
              f.Value     := 0;
              f.Name      := '';

              HR := rx.MoveToFirstAttribute();
              if HR <> S_FALSE then EXmlLite.Check( HR );
              if S_OK = HR then
              repeat
                EXmlLite.Check( rx.GetLocalName(pName, lenName) );

                if SameText(string(pName), Tag_Field_Value) then begin
                   Assert( not( faValue in f.ReadAttrs ) );
                   if EXmlLite.IsOK( rx.GetValue(pName, lenName) ) then begin
                      f.Value := StrToInt( Trim( pName ) );
                      Include( f.ReadAttrs, faValue );
                   end;
                end else
                if SameText(string(pName), Tag_Field_Name) then begin
                   Assert( not( faName in f.ReadAttrs ) );
                   if EXmlLite.IsOK( rx.GetValue(pName, lenName) ) then begin
                      f.Name := pName;
                      Include( f.ReadAttrs, faName );
                   end;
                end else
                if SameText(string(pName), Tag_Field_Type) then begin
                   Assert( not( faType in f.ReadAttrs ) );
                   if EXmlLite.IsOK( rx.GetValue(pName, lenName) ) then begin
                      f.FieldType := StrToInt( Trim( pName ) );
                      Include( f.ReadAttrs, faType );
                   end;
                end;

              until not EXmlLite.IsOK( rx.MoveToNextAttribute() ) ;

              fs.Add( f );
            end;
          end;
        end;

        t.Fields := fs.ToArray();
        fs.Clear;

        ts.Add( t );
      end;

    end;

    Result := ts.ToArray();
  finally
    ts.Free; fs.Free;
  end;
end;

end.
