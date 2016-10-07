program XL_XML_Read;

uses
  Vcl.Forms,
  XML_Read_Form in 'XML_Read_Form.pas' {Form17},
  xml_read_Intf in 'xml_read_Intf.pas',
  Deltics.Hourglass in '..\..\Libs\Deltics.Hourglass.pas',
  read_xmlLite in 'read_xmlLite.pas',
  XmlLite in '..\..\Libs\Delphi-XmlLite\XmlLite.pas',
  read_TXMLDoc in 'read_TXMLDoc.pas',
  read_OmniXML in 'read_OmniXML.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm17, Form17);
  Application.Run;
end.
