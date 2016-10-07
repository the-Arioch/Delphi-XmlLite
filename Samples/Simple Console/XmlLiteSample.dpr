program XmlLiteSample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  XmlLite in '..\..\XmlLite.pas';

procedure ReadXml(Reader: IXMLReader);
var
  nodeType: XmlNodeType;
  pName: PWideChar;
  lenName: Cardinal;
  pValue: PWideChar;
  lenValue: Cardinal;
begin
  while not Reader.IsEOF do
  begin
    Reader.Read(nodeType);
    //Read every node
    //If it is an XML element node, get the name
    if nodeType = XmlNodeType.Element then
      Reader.GetLocalName(pName, lenName)
    else //If it is XML text and the current element is ARTIST, write the value
    if (pName = 'ARTIST') and (nodeType = XmlNodeType.Text) then
    begin
      Reader.GetValue(pValue, lenValue);
      Writeln(pValue);
    end;
  end;
end;

procedure RunSample;
var
  _Reader: IXMLReader;
begin
  _Reader := CreateXmlFileReader('cd_catalog.xml');
  ReadXml(_Reader);
  _Reader := nil;

  Writeln;

  _Reader := CreateXmlFileReader('cd_catalog.xml', TEncoding.Unicode);
  ReadXml(_Reader);

end;

begin
  try
    RunSample;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Writeln;
  Writeln('Hit return to close.');
  Readln;
end.
