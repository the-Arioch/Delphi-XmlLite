{ #----------------------------------------------------------------------------
  Header translation for Microsoft XmlLite
  @author Carl Mönnig

  * XmlLite is a native C++ implementation of .NET XmlReader+Writer for stream-based, forward-only XML parsing and creation.
  * XmlLite.dll is required.  It is included with all new versions of Windows, and service packs for old versions.
  * XmlReader's pull-based interface is cleaner to use than SAX's event-based interface.
  * More info: http://msdn.microsoft.com/en-us/library/ms752838%28v=VS.85%29.aspx

  Note: This is a minimal translation, some parts were not implemented and most are untested.
  ----------------------------------------------------------------------------- }
unit XmlLite;

interface

uses
  ActiveX,
  SysUtils;

// TODO: check Win64 target - maybe there them should 64-bit enums ???
{$MINENUMSIZE 4}
type
  XmlNodeType = (
    XmlNodeType_None = 0,
    XmlNodeType_Element = 1,
    XmlNodeType_Attribute = 2,
    XmlNodeType_Text = 3,
    XmlNodeType_CDATA = 4,
    XmlNodeType_ProcessingInstruction = 7,
    XmlNodeType_Comment = 8,
    XmlNodeType_DocumentType = 10,
    XmlNodeType_Whitespace = 13,
    XmlNodeType_EndElement = 15,
    XmlNodeType_XmlDeclaration = 17
    );

  XmlStandAlone = (
    XmlStandalone_Omit = 0,
    XmlStandalone_Yes = 1,
    XmlStandalone_No = 2
    );

  DtdProcessing = (
    XmlDtdProcessing_Prohibit = 0,
    XmlDtdProcessing_Parse = 1
    );

  XmlWriterProperty = (
    XmlWriterProperty_MultiLanguage = 0,
    XmlWriterProperty_Indent = 1,
    XmlWriterProperty_ByteOrderMark = 2,
    XmlWriterProperty_OmitXmlDeclaration = 3,
    xmlWriterProperty_ConformanceLevel = 4
    );

  XmlReaderProperty = (
    XmlReaderProperty_MultiLanguage = 0,
    XmlReaderProperty_ConformanceLevel = 1,
    XmlReaderProperty_RandomAccess = 2,
    XmlReaderProperty_XmlResolver = 3,
    XmlReaderProperty_DtdProcessing = 4,
    XmlReaderProperty_ReadState = 5,
    XmlReaderProperty_MaxElementDepth = 6,
    XmlReaderProperty_MaxEntityExpansion = 7
    );
{$MINENUMSIZE 1}

type
  IXMLReader = interface
    ['{7279FC81-709D-4095-B63D-69FE4B0D9030}']
    function SetInput(const _IXMLStream: IUnknown): HRESULT; stdcall;
    function GetProperty(const nProperty: XmlReaderProperty; out ppValue: LongWord): HRESULT; stdcall;
    function SetProperty(const nProperty: XmlReaderProperty; const pValue: LongWord): HRESULT; stdcall;
    function Read(out XmlNodeType: XmlNodeType): HRESULT; stdcall;
    function GetNodeType(out XmlNodeType: XmlNodeType): HRESULT; stdcall;
    function MoveToFirstAttribute: HRESULT; stdcall;
    function MoveToNextAttribute: HRESULT; stdcall;
    function MoveToAttributeByName(const pwszLocalName, pwszNamespaceUri: WideString): HRESULT; stdcall;
    function MoveToElement: HRESULT; stdcall;
    function GetQualifiedName(out ppwszQualifiedName: PWideChar; out pcwchQualifiedName: LongWord): HRESULT; stdcall;
    function GetNamespaceUri(out ppwszNamespaceUri: PWideChar; out pcwchNamespaceUri: LongWord): HRESULT; stdcall;
    function GetLocalName(out ppwszLocalName: PWideChar; out pcwchLocalName: LongWord): HRESULT; stdcall;
    function GetPrefix(out ppwszPrefix: PWideChar; out pcwchPrefix: LongWord): HRESULT; stdcall;
    function GetValue(out ppwszValue: PWideChar; out pcwchValue: LongWord): HRESULT; stdcall;
    function ReadValueChunk( { __out_ecount_part(cwchChunkSize, *pcwchRead) WCHAR *pwchBuffer, LongWord cwchChunkSize, __inout  LongWord *pcwchRead } )
      : HRESULT; stdcall;
    function GetBaseUri(out ppwszBaseUri: PWideChar; out pcwchBaseUri: LongWord): HRESULT; stdcall;
    function IsDefault: LongBool; stdcall;
    function IsEmptyElement: LongBool; stdcall;
    function GetLineNumber(out pnLineNumber: LongWord): HRESULT; stdcall;
    function GetLinePosition(out pnLinePosition: LongWord): HRESULT; stdcall;
    function GetAttributeCount(out pnAttributeCount: LongWord): HRESULT; stdcall;
    function GetDepth(out pnDepth: LongWord): HRESULT; stdcall;
    function IsEOF: LongBool; stdcall;
  end;

  IXmlReaderInput = Interface(IUnknown)
  end;

  IXMLWriter = interface
    ['{7279FC88-709D-4095-B63D-69FE4B0D9030}']
    function SetOutput(const _IXMLStream: IUnknown): HRESULT; stdcall;
    function GetProperty(const nProperty: XmlWriterProperty; out ppValue: Longint): HRESULT; stdcall;
    function SetProperty(const nProperty: XmlWriterProperty; const pValue: Longint): HRESULT; stdcall;
    function WriteAttributes(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
    function WriteAttributeString(const pwszPrefix, pwszLocalName, pwszNamespaceUri, pwszValue: WideString): HRESULT; stdcall;
    function WriteCData(const pwszText: WideString): HRESULT; stdcall;
    function WriteCharEntity(const wch: WideChar): HRESULT; stdcall;
    function WriteChars( { __in_ecount_opt(cwch)  const WCHAR *pwch, LongWord cwch } ): HRESULT; stdcall;
    function WriteComment(const pwszComment: WideString): HRESULT; stdcall;
    function WriteDocType(const pwszName, pwszPublicId, pwszSystemId, pwszSubset: WideString): HRESULT; stdcall;
    function WriteElementString(const pwszPrefix, pwszLocalName, pwszNamespaceUri, pwszValue: WideString): HRESULT; stdcall;
    function WriteEndDocument: HRESULT; stdcall;
    function WriteEndElement: HRESULT; stdcall;
    function WriteEntityRef(const pwszName: WideString): HRESULT; stdcall;
    function WriteFullEndElement: HRESULT; stdcall;
    function WriteName(const pwszName: WideString): HRESULT; stdcall;
    function WriteNmToken(const pwszNmToken: WideString): HRESULT; stdcall;
    function WriteNode(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
    function WriteNodeShallow(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
    function WriteProcessingInstruction(const pwszName, pwszText: WideString): HRESULT; stdcall;
    function WriteQualifiedName(const pwszLocalName, pwszNamespaceUri: WideString): HRESULT; stdcall;
    function WriteRaw(const pwszData: WideString): HRESULT; stdcall;
    function WriteRawChars( { _in_ecount_opt(cwch)  const WCHAR *pwch, LongWord cwch } ): HRESULT; stdcall;
    function WriteStartDocument(const standalone: XmlStandAlone): HRESULT; stdcall;
    function WriteStartElement(const pwszPrefix, pwszLocalName, pwszNamespaceUri: PWideChar): HRESULT; stdcall;
    function WriteString(const pwszText: WideString): HRESULT; stdcall;
    function WriteSurrogateCharEntity(const wchLow, wchHigh: WideChar): HRESULT; stdcall;
    function WriteWhitespace(const pwszWhitespace: WideString): HRESULT; stdcall;
    function Flush: HRESULT; stdcall;
  end;

  IXmlWriterOutput = interface(IUnknown)
  end;

function CreateXmlFileReader(const FileName: string = ''): IXMLReader;

function CreateXmlFileReaderWithEnc(const FileName: string; Encoding: TEncoding): IXmlReader;

function CreateXmlFileWriter(const FileName: string = ''): IXMLWriter;

function CreateXmlFileWriterWithEnc(const FileName: string; Encoding: TEncoding): IXmlWriter;

function OpenXmlFileStreamReader(const FileName: string): IStream;

function OpenXmlFileStreamWriter(const FileName: string): IStream;

function CheckHR(const HR: HRESULT): HResult;
function IsXMLLiteResultOK(const HR: HRESULT): Boolean; inline;

implementation

uses
  Classes;

const
  XMLReaderGuid: TGUID = '{7279FC81-709D-4095-B63D-69FE4B0D9030}';
  XMLWriterGuid: TGUID = '{7279FC88-709D-4095-B63D-69FE4B0D9030}';

function CreateXmlReader(
  const refiid: TGUID;
  out _IXMLReader: IXMLReader;
  const pMalloc: Pointer): HRESULT; stdcall; external 'XmlLite.dll';

function CreateXmlReaderInputWithEncodingCodePage(
  const pInputStream: IStream;
  const pMalloc: IMalloc;
  const nEncodingCodePage: Cardinal; // TEncoding.XXX.CodePage
  const fEncodingHint: LongBool;
  const pwszBaseUri: PWideChar;
  out ppInput: IXmlReaderInput): HRESULT; stdcall; external 'XmlLite.dll';

function CreateXmlReaderInputWithEncodingName(
  const pInputStream: IStream;
  const pMalloc: IMalloc;
  const pwszEncodingName: PWideChar; // TEncoding.XXX.EncodingName
  const fEncodingHint: LongBool;
  const pwszBaseUri: PWideChar;
  out ppInput: IXmlReaderInput): HRESULT; stdcall; external 'XmlLite.dll';

function CreateXmlWriter(
  const refiid: TGUID;
  out _IXMLWriter: IXMLWriter;
  const pMalloc: Pointer): HRESULT; stdcall; external 'XmlLite.dll';

function CreateXmlWriterOutputWithEncodingCodePage(
  const pOutputStream: IStream;
  const pMalloc: IMalloc;
  const nEncodingCodePage: Cardinal; // TEncoding.XXX.CodePage
  out ppOutput: IXmlWriterOutput): HRESULT; stdcall; external 'XmlLite.dll';

function CreateXmlWriterOutputWithEncodingName(
  const pOutputStream: IStream;
  const pMalloc: IMalloc;
  const pwszEncodingName: PWideChar; // TEncoding.XXX.EncodingName
  out ppOutput: IXmlWriterOutput): HRESULT; stdcall; external 'XmlLite.dll';




function CreateXmlFileReader(const FileName: string): IXMLReader;
begin
  CheckHR(CreateXmlReader(XMLReaderGuid, Result, nil));
  if (Result <> nil) and (FileName <> '') then
  begin
    CheckHR(Result.SetProperty(XmlReaderProperty_DtdProcessing, LongWord(XmlDtdProcessing_Parse)));
    CheckHR(Result.SetInput(OpenXmlFileStreamReader(FileName)));
  end;
end;

function CreateXmlFileReaderWithEnc(const FileName: string; Encoding: TEncoding): IXmlReader;
var
  input: IXmlReaderInput;
  stream: IStream;
begin
  CheckHR(CreateXmlReader(XMLReaderGuid, Result, nil));
  CheckHR(Result.SetProperty(XmlReaderProperty_DtdProcessing, LongWord(XmlDtdProcessing_Parse)));
  stream := OpenXmlFileStreamReader(FileName);
  CheckHR(CreateXmlReaderInputWithEncodingCodePage(stream, nil, Encoding.CodePage, true, nil, input));
  CheckHR(Result.SetInput(input));
end;

function CreateXmlFileWriter(const FileName: string): IXMLWriter;
begin
  CheckHR(CreateXmlWriter(XMLWriterGuid, Result, nil));
  if (Result <> nil) and (FileName <> '') then
    CheckHR(Result.SetOutput(OpenXmlFileStreamWriter(FileName)));
end;

function CreateXmlFileWriterWithEnc(const FileName: string; Encoding: TEncoding): IXmlWriter;
var
  output: IXmlWriterOutput;
  stream: IStream;
begin
  CheckHR(CreateXmlWriter(XMLWriterGuid, Result, nil));
  stream := OpenXmlFileStreamWriter(FileName);
  CheckHR(CreateXmlWriterOutputWithEncodingCodePage(stream, nil, Encoding.CodePage, output));
  CheckHR(Result.SetOutput(output));
end;


function OpenXmlFileStreamReader(const FileName: string): IStream;
begin
  Assert(FileExists(FileName), 'XML file should exist');
  Result := TStreamAdapter.Create(TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite), soOwned);
end;

function OpenXmlFileStreamWriter(const FileName: string): IStream;
begin
  Result := TStreamAdapter.Create(TFileStream.Create(FileName, fmCreate), soOwned);
end;

// Use example: repeat ... until until S_OK <> CheckHR( rd.MoveToNextAttribute() );
function CheckHR(const HR: HRESULT): HResult;
begin
  if (HR < 0) then
    raise Exception.CreateFmt('XmlLite exception! Code: %d = 0x%x', [HR, HR]);
  Result := HR;
end;

function IsXMLLiteResultOK(const HR: HRESULT): Boolean;
begin
  Result := S_OK = CheckHR(HR);
end;

end.
