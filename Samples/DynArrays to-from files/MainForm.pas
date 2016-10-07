unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmMain = class(TForm)
    btnSave: TButton;
    btnRead: TButton;
    mmoData: TMemo;
    pnl1: TPanel;
    procedure btnSaveClick(Sender: TObject);
    procedure btnReadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation
uses fxsParser, Deltics.HourGlass;

{$R *.dfm}

procedure TfmMain.btnSaveClick(Sender: TObject);
var data: TfxsTables;
    s: string;
begin
  s := 'Sample.SQLINFO.xml';
  if PromptForFileName(s, '*.SQLINFO.xml|*.SQLINFO.xml', 'SQLINFO.xml', '', '', True ) then
  begin
    HourglassOn();

    SetLength(data,2);

    data[0].From := 'ns1.TableName t, ns1.ViewName v';
    data[1].From := 'ns2.TableName t, ns2.ViewName v';

    data[0].Where := '';
    data[1].Where := 't.Field1 = v.Field2 and'#13#10'  v.ID < 0';

    data[0].Value := +10;
    data[1].Value := -10;

    SetLength( data[0].Fields, 3);
    with data[0].Fields[0] do begin
      Value := 2;
      Name  := 'ColumnA';
      FieldType := 5;
    end;
    with data[0].Fields[1] do begin
      Value := 1;
      Name  := 'ColumnB';
      FieldType := 6;
    end;
    with data[0].Fields[2] do begin
      Value := 0;
      Name  := 'ColumnC';
      FieldType := 7;
    end;

    SetLength( data[1].Fields, 2);
    with data[1].Fields[0] do begin
      Value := 100;
      Name  := 't.ID';
      FieldType := 105;
    end;
    with data[1].Fields[1] do begin
      Value := 101;
      Name  := 'v.ID';
      FieldType := 106;
    end;

    WriteXML( data, s );
  end;
end;

procedure TfmMain.btnReadClick(Sender: TObject);
var data: TfxsTables;
    s, pfx: string;
    ixt, ixf: integer;
    t: TfxsTable; f: TfxsField;
const indent = 6;
begin
  s := 'Sample.SQLINFO.xml';
  if PromptForFileName(s, '*.SQLINFO.xml|*.SQLINFO.xml', 'SQLINFO.xml', '', '', False ) then
  begin
    HourglassOn();
    mmoData.Clear;

    try

      data := ReadXML(s);

      mmoData.Lines.Text :=  '    >>>> XML File: ' + s + ' <<<<';
      mmoData.Lines.Add('');

      for ixt := Low( data ) to High( data ) do begin
        s := 'ÒÀÁËÈÖÀ:   ';
        t := data[ ixt ];

        if taFrom in t.ReadAttrs then
           s := s + ' (from)';
        if taWhere in t.ReadAttrs then
           s := s + ' (where)';
        if taValue in t.ReadAttrs then
           s := s + ' (value)';

        mmoData.Lines.Add( Format( '%2d: %s', [ixt, s]) );

        pfx := StringOfChar( ' ', 2*indent );
        if taFrom in t.ReadAttrs then
           mmoData.Lines.Add( pfx + 'from = "' + t.From + '"' );
        if taWhere in t.ReadAttrs then
           mmoData.Lines.Add( pfx + 'where = "' + t.Where + '"' );
        if taValue in t.ReadAttrs then
           mmoData.Lines.Add( pfx + 'value = ' + IntToStr(t.Value));

        ixf := Low( t.Fields );
        for f in t.Fields do begin
          s := 'ÏÎËÅ:   ';

          if faName in f.ReadAttrs then
             s := s + ' (name)';
          if faType in f.ReadAttrs then
             s := s + ' (type)';
          if faValue in f.ReadAttrs then
             s := s + ' (value)';

          mmoData.Lines.Add( StringOfChar( ' ', indent ) + Format( '%2d: %s', [ixf, s]) );

          pfx := StringOfChar( ' ', 2*indent );
          if faName in f.ReadAttrs then
             mmoData.Lines.Add( pfx + 'name = "' + f.Name + '"' );
          if faType in f.ReadAttrs then
             mmoData.Lines.Add( pfx + 'type = ' + IntToStr(f.FieldType));
          if faValue in f.ReadAttrs then
             mmoData.Lines.Add( pfx + 'value = ' + IntToStr(f.Value));

          Inc( ixf );
        end;
      end;

    except
      on E: Exception do
      begin
        mmoData.Lines.Add('');
        mmoData.Lines.Add('!!!! ERROR !!!!');
        mmoData.Lines.Add('');
        mmoData.Lines.Add(E.ToString);
        raise;
      end;
    end;

    mmoData.Lines.Add('');
    mmoData.Lines.Add('    >>>> File was read, parsed, dumped. <<<<' );
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  mmoData.Clear;
end;

end.
