unit XML_Read_Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  xml_read_Intf,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  JvExMask, JvToolEdit, Vcl.Grids;

type
  TForm17 = class(TForm)
    edtOpen: TJvFilenameEdit;
    rgMethod: TRadioGroup;
    rgSheet: TRadioGroup;
    chkGridVisible: TCheckBox;
    btnShowSheet: TButton;
    gridSheet: TStringGrid;
    lblElapsed: TLabel;
    procedure chkGridVisibleClick(Sender: TObject);
    procedure edtOpenAfterDialog(Sender: TObject; var AName: string;
      var AAction: Boolean);
    procedure edtOpenDropFiles(Sender: TObject);
    procedure rgMethodClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnShowSheetClick(Sender: TObject);
    procedure rgSheetClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure ReselectedFile(const AName: string);
    { Private declarations }

  public
    Reader: TxReader;
    XMLName: string;
    { Public declarations }
  end;

var
  Form17: TForm17;

implementation

uses Deltics.Hourglass,
     read_txmldoc, read_xmlLite, read_OmniXML;

{$R *.dfm}

procedure TForm17.chkGridVisibleClick(Sender: TObject);
begin
  gridSheet.Visible := chkGridVisible.Checked;
  if Reader <> nil then
     Reader.FillGrid := chkGridVisible.Checked;
end;

procedure TForm17.ReselectedFile( const AName: string );
begin
  if not FileExists(AName) then exit;

  btnShowSheet.Enabled := False;
  rgMethod.ItemIndex := -1;
  rgSheet.ItemIndex  := -1;
  rgSheet.Caption    := ' Лист ';
  rgSheet.Items.Clear;
  lblElapsed.Caption := '';

  XMLName := AName;
end;

procedure TForm17.edtOpenAfterDialog(Sender: TObject; var AName: string;
  var AAction: Boolean);
begin
  AAction := AAction or FileExists(AName);
  if AAction then
     ReselectedFile( AName );
end;

procedure TForm17.edtOpenDropFiles(Sender: TObject);
begin
  ReselectedFile( edtOpen.FileName );
end;

procedure TForm17.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Reader);
end;

procedure TForm17.rgMethodClick(Sender: TObject);
var rc: TxReaderClass;
begin
  lblElapsed.Caption := '';
  Self.Repaint;

  case rgMethod.ItemIndex of
    0: rc := TxLiteReader;
    1: rc := TxDocReader;
    2: rc := TxOmniXMLReader;
    else rc := nil;
  end;

  HourglassOn();

  FreeAndNil(Reader);

  Reader := rc.Create( XMLName, gridSheet );
  Reader.FillGrid := chkGridVisible.Checked;

  Reader.ParseForSheets;

  rgSheet.Caption    := ' Листы (список получен за ' + IntToStr(Reader.ElapsedTime) + ' мс)';

  rgSheet.Items.Clear;
  rgSheet.Items.AddStrings( Reader.Sheets );
end;

procedure TForm17.btnShowSheetClick(Sender: TObject);
var n: string; i: integer; p: pointer; s: string;
begin
  lblElapsed.Caption := '';
  Self.Repaint;

  i := rgSheet.ItemIndex;
  if i < 0 then begin
     ShowMessage('Сначала выберите лист!');
     exit;
  end;

  n := rgSheet.Items[ i ];
  p := rgSheet.Items.Objects[ i ];

  Reader.FillGrid := chkGridVisible.Checked;
  HourglassOn();
  Reader.ParseForCells( n, p );

  s := IntToStr(Reader.ElapsedTime) + ' мс';

  if chkGridVisible.Checked and gridSheet.Visible then
    s := s + #13#10 + 'Размер ' + IntToStr( gridSheet.ColCount ) +
                            'x' + IntToStr( gridSheet.RowCount );

  lblElapsed.Caption := s;
end;

procedure TForm17.rgSheetClick(Sender: TObject);
begin
  btnShowSheet.Enabled :=
    ( Reader <> nil ) and
    ( rgMethod.ItemIndex >= 0 ) and
    ( rgSheet.ItemIndex >= 0 );
end;

procedure TForm17.FormCreate(Sender: TObject);
begin
  edtOpenDropFiles( nil );
end;

end.
