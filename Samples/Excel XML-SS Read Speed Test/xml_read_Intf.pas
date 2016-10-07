unit xml_read_Intf;

interface
uses Vcl.Grids, SysUtils, Classes;

type
  TxReaderClass = class of TxReader;
  TxReader = class
  protected
    FileName: string;
    FDataGrid: TStringGrid;
    FTicks  : cardinal;
    FFillGrid: boolean;
    FSheetList: TStrings;

    type rRowCellInfo = record
            cur_Col, max_Col: cardinal;
            cur_Row, max_Row: cardinal;
         end;

  protected
    procedure DoParseSheets; virtual; abstract;
    procedure DoParseCells(const SheetName: string; Const Data: Pointer); virtual; abstract;
  public
    constructor Create(const XMLFileName: string; const Grid: TStringGrid); virtual;
    destructor Destroy; override;

    property ElapsedTime: cardinal read FTicks;
    property FillGrid: boolean read FFillGrid write FFillGrid;
    property Sheets: TStrings read FSheetList;

    procedure ParseForSheets;
    procedure ParseForCells(Const SheetName: string; Const Data: Pointer);
  end;

implementation
uses Windows;

{ TxReader }

destructor TxReader.Destroy;
begin
  FSheetList.Free;
  inherited;
end;

constructor TxReader.Create(const XMLFileName: string; const Grid: TStringGrid);
begin
  with TFileStream.Create(XMLFileName, fmShareDenyWrite or fmOpenRead) do
    Free;

  inherited Create;
  Self.FileName := XMLFileName;
  FSheetList := TStringList.Create;
  FDataGrid := Grid;
end;

procedure TxReader.ParseForSheets;
var LTicks: cardinal;
begin
  FTicks := 0;
  if FDataGrid = nil then
     FFillGrid := false;

  LTicks := GetTickCount();
  try
    FSheetList.Clear;
    DoParseSheets;
  finally
    FTicks := GetTickCount() - LTicks;
  end;
end;

procedure TxReader.ParseForCells(const SheetName: string; Const Data: Pointer);
var LTicks: cardinal;
begin
  FTicks := 0;
  if FDataGrid = nil then
     FFillGrid := false;

  LTicks := GetTickCount();
  try
    if FDataGrid <> nil then
       FDataGrid.Cols[0].BeginUpdate;
    DoParseCells(SheetName,Data);
  finally
    if FDataGrid <> nil then
       FDataGrid.Cols[0].EndUpdate;
    FTicks := GetTickCount() - LTicks;
  end;
end;

end.
