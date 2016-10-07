program SML_Sample;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {fmMain},
  fxsParser in 'fxsParser.pas',
  Deltics.Hourglass in 'Deltics.Hourglass.pas',
  XmlLite in '..\..\XmlLite.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
