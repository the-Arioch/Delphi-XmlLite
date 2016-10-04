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
  Windows, // LONG_PTR type in Win32/Win64 with different Delphi versions
  SysUtils;

// TODO: The underscored superlong enum values are crazy.
//       Better to use Scoped Enumerations
//       They are supported starting with Delphi 2009 (missing in 2007 and prior)
//       They are supported starting with FPC 2.6.0
//       Would anyone really care about prior versions? Hardly so.
// http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/devcommon/compdirsscopedenums_xml.html
// http://docs.embarcadero.com/products/rad_studio/radstudio2007/RS2007_helpupdates/HUpdate4/EN/html/devcommon/delphicompdirectivespart_xml.html
// http://wiki.freepascal.org/FPC_New_Features_2.6.0

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
    xmlWriterProperty_ConformanceLevel = 4,
    XmlWriterProperty_CompactEmptyElement = 5
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

  XmlReadState = (
    XmlReadState_Initial	= 0,
    XmlReadState_Interactive	= 1,
    XmlReadState_Error	= 2,
    XmlReadState_EndOfFile	= 3,
    XmlReadState_Closed	= 4
    );

  XmlConformanceLevel = (
    XmlConformanceLevel_Auto	= 0,
    XmlConformanceLevel_Fragment	= 1,
    XmlConformanceLevel_Document	= 2
    );

{$MINENUMSIZE 1}

(**  Win32/Win64 properties compatibility

 https://msdn.microsoft.com/en-us/library/ms752842.aspx
 HRESULT GetProperty ([in] UINT nProperty, [out] LONG_PTR ** ppValue);

 The first  parameter in UINT is always 32 bits
 The second parameter in LONG_PTR (pointer-sized signed integer) is 32 or 64 bits

 Here it means - enums are 4-bytes SizeOf.
 Later it means in interface declarations xxxProperty can not have LongWord type
       for their 2nd parameters

 See datatypes declarations at
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751.aspx

 Additionally - LPCWSTR stands for "const PWideChar" and
    WideString stands for BSTR ( OLE/COM "Basic String")
 They are not the same, though kind of worked due to BSTR "implementation details".
 However that incurred redundant datatype casting UnicodeString -> WideString
    if nothing else. Could be a nice hack for pre-Unicode Delphi though.

 Differences example:
   a) PWideChar string can not contain #0 inside.
   b) PWideChar can tell states of "no string" aka nil aka NULL and
            one of empty aka 0-length string. But one can not pass
            nil instead of UnicodeString/WideString into, say, WriteElementString
 **)


type
  IXMLReader = interface
    ['{7279FC81-709D-4095-B63D-69FE4B0D9030}']
    function SetInput(const _IXMLStream: IUnknown): HRESULT; stdcall;
    function GetProperty(const nProperty: XmlReaderProperty; out ppValue: LONG_PTR): HRESULT; stdcall;
    function SetProperty(const nProperty: XmlReaderProperty; const pValue: LONG_PTR): HRESULT; stdcall;
    function Read(out XmlNodeType: XmlNodeType): HRESULT; stdcall;
    function GetNodeType(out XmlNodeType: XmlNodeType): HRESULT; stdcall;
    function MoveToFirstAttribute: HRESULT; stdcall;
    function MoveToNextAttribute: HRESULT; stdcall;
    function MoveToAttributeByName(const pwszLocalName, pwszNamespaceUri: PWideChar): HRESULT; stdcall;
    function MoveToElement: HRESULT; stdcall;
    function GetQualifiedName(out ppwszQualifiedName: PWideChar; out pcwchQualifiedName: LongWord): HRESULT; stdcall;
    function GetNamespaceUri(out ppwszNamespaceUri: PWideChar; out pcwchNamespaceUri: LongWord): HRESULT; stdcall;
    function GetLocalName(out ppwszLocalName: PWideChar; out pcwchLocalName: LongWord): HRESULT; stdcall;
    function GetPrefix(out ppwszPrefix: PWideChar; out pcwchPrefix: LongWord): HRESULT; stdcall;
    function GetValue(out ppwszValue: PWideChar; out pcwchValue: LongWord): HRESULT; stdcall;
    function ReadValueChunk( const Buffer: PWideChar; const BufferSizeInChars: Cardinal; out ResultLengthInChars: Cardinal )
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
    function WriteAttributeString(const pwszPrefix, pwszLocalName, pwszNamespaceUri, pwszValue: PWideChar): HRESULT; stdcall;
    function WriteCData(const pwszText: PWideChar): HRESULT; stdcall;
    function WriteCharEntity(const wch: WideChar): HRESULT; stdcall;
    function WriteChars( const Chars: PWideChar; const Count: Cardinal ): HRESULT; stdcall;
    function WriteComment(const pwszComment: PWideChar): HRESULT; stdcall;
    function WriteDocType(const pwszName, pwszPublicId, pwszSystemId, pwszSubset: PWideChar): HRESULT; stdcall;
    function WriteElementString(const pwszPrefix, pwszLocalName, pwszNamespaceUri, ContentOrNil: PWideChar): HRESULT; stdcall;
    function WriteEndDocument: HRESULT; stdcall;
    function WriteEndElement: HRESULT; stdcall;
    function WriteEntityRef(const pwszName: PWideChar): HRESULT; stdcall;
    function WriteFullEndElement: HRESULT; stdcall;
    function WriteName(const pwszName: PWideChar): HRESULT; stdcall;
    function WriteNmToken(const pwszNmToken: PWideChar): HRESULT; stdcall;
    function WriteNode(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
    function WriteNodeShallow(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
    function WriteProcessingInstruction(const pwszName, pwszText: PWideChar): HRESULT; stdcall;
    function WriteQualifiedName(const pwszLocalName, pwszNamespaceUri: PWideChar): HRESULT; stdcall;
    function WriteRaw(const pwszData: PWideChar): HRESULT; stdcall;
    function WriteRawChars( const RawChars: PWideChar; const Count: Cardinal ): HRESULT; stdcall;
    function WriteStartDocument(const standalone: XmlStandAlone): HRESULT; stdcall;
    function WriteStartElement(const pwszPrefix, pwszLocalName, pwszNamespaceUri: PWideChar): HRESULT; stdcall;
    function WriteString(const pwszText: PWideChar): HRESULT; stdcall;
    function WriteSurrogateCharEntity(const wchLow, wchHigh: WideChar): HRESULT; stdcall;
    function WriteWhitespace(const pwszWhitespace: PWideChar): HRESULT; stdcall;
    function Flush: HRESULT; stdcall;
  end;

  IXmlWriterOutput = interface(IUnknown)
  end;

(** MSDN: IXmlWriterLite

This class is a programming interface for writing XML quickly, introduced in Windows 10.
It implements an interface with most of the same methods as IXmlWriter, except for WriteQualifiedName.
Some method signatures are slightly different between IXmlWriter and IXmlWriterLite.
IXmlWriterLite is faster than IXmlWriter because it skips validation of namespaces and attributes, and
  does not maintain information that is required to automatically close tags.
Use IXmlWriterLite when you can maintain complete XML document correctness in your code, and
  output speed is of highest importance. Otherwise, we recommend that you use IXmlWriter. **)

    IXmlWriterLite = interface
      ['{862494C6-1310-4AAD-B3CD-2DBEEBF670D3}']
        function SetOutput(const _IXMLStream: IUnknown): HRESULT; stdcall;

        function GetProperty(const nProperty: XmlWriterProperty; out ppValue: LONG_PTR): HRESULT; stdcall;
        function SetProperty(const nProperty: XmlWriterProperty; const pValue: LONG_PTR): HRESULT; stdcall;

        function WriteAttributes(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
        function WriteAttributeString(const QualifiedName: PWideChar; const QualNameLength: Cardinal;
                                      const Value: PWideChar; const ValueLength: Cardinal ): HRESULT; stdcall;

        function WriteCData(const pwszText: PWideChar): HRESULT; stdcall;
        function WriteCharEntity(const wch: WideChar): HRESULT; stdcall;
        function WriteChars(const Chars: PWideChar; const Count: Cardinal): HRESULT; stdcall;

        function WriteComment(const pwszComment: PWideChar): HRESULT; stdcall;
        function WriteDocType(const pwszName, pwszPublicId, pwszSystemId, pwszSubset: PWideChar): HRESULT; stdcall;
        function WriteElementString(const QualifiedName: PWideChar; const QNameLengthInChars: Cardinal; const ContentOrNil: PWideChar): HRESULT; stdcall;
        function WriteEndDocument: HRESULT; stdcall;
        function WriteEndElement(const QualifiedName: PWideChar; const QNameLengthInChars: Cardinal): HRESULT; stdcall;
        function WriteEntityRef(const pwszName: PWideChar): HRESULT; stdcall;
        function WriteFullEndElement(const QualifiedName: PWideChar; const QNameLengthInChars: Cardinal): HRESULT; stdcall;
        function WriteName(const pwszName: PWideChar): HRESULT; stdcall;
        function WriteNmToken(const pwszNmToken: PWideChar): HRESULT; stdcall;
        function WriteNode(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
        function WriteNodeShallow(const pReader: IXMLReader; const fWriteDefaultAttributes: LongBool): HRESULT; stdcall;
        function WriteProcessingInstruction(const pwszName, pwszText: PWideChar): HRESULT; stdcall;
        function WriteRaw(const pwszData: PWideChar): HRESULT; stdcall;
        function WriteRawChars( const RawChars: PWideChar; const Count: Cardinal ): HRESULT; stdcall;
        function WriteStartDocument(const standalone: XmlStandAlone): HRESULT; stdcall;
        function WriteStartElement(const QualifiedName: PWideChar; const QNameLengthInChars: Cardinal): HRESULT; stdcall;
        function WriteString(const pwszText: PWideChar): HRESULT; stdcall;
        function WriteSurrogateCharEntity(const wchLow, wchHigh: WideChar): HRESULT; stdcall;
        function WriteWhitespace(const pwszWhitespace: PWideChar): HRESULT; stdcall;
        function Flush: HRESULT; stdcall;
      end platform experimental {'Requires Windows 10'};


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
  XMLReaderGuid:     TGUID = '{7279FC81-709D-4095-B63D-69FE4B0D9030}';
  XMLWriterGuid:     TGUID = '{7279FC88-709D-4095-B63D-69FE4B0D9030}';
  XMLWriterLiteGUID: TGUID = '{862494C6-1310-4AAD-B3CD-2DBEEBF670D3}';

// To sleep with: do not load DLL and funciton until we really call them, if ever
// Implemented starting with Delphi 2010 - http://www.tindex.net/Language/delayed.html

function CreateXmlReader(
  const refiid: TGUID;
  out _IXMLReader: IXMLReader; // actually iUnknown - future versions might have ore reading interfaces
  const pMalloc: IMalloc): HRESULT; stdcall; external 'XmlLite.dll' {delayed};

function CreateXmlReaderInputWithEncodingCodePage(
  const pInputStream: IStream;
  const pMalloc: IMalloc;
  const nEncodingCodePage: Cardinal; // TEncoding.XXX.CodePage
  const fEncodingHint: LongBool;
  const pwszBaseUri: PWideChar;
  out ppInput: IXmlReaderInput): HRESULT; stdcall; external 'XmlLite.dll' {delayed};

function CreateXmlReaderInputWithEncodingName(
  const pInputStream: IStream;
  const pMalloc: IMalloc;
  const pwszEncodingName: PWideChar; // TEncoding.XXX.EncodingName
  const fEncodingHint: LongBool;
  const pwszBaseUri: PWideChar;
  out ppInput: IXmlReaderInput): HRESULT; stdcall; external 'XmlLite.dll' {delayed};

function CreateXmlWriter(
  const refiid: TGUID;
  out _IXMLWriter: IUnknown; // can be IXmlWriter or IXmlWriterLite or any future intf
  const pMalloc: IMalloc): HRESULT; stdcall; external 'XmlLite.dll' {delayed};

function CreateXmlWriterOutputWithEncodingCodePage(
  const pOutputStream: IStream;
  const pMalloc: IMalloc;
  const nEncodingCodePage: Cardinal; // TEncoding.XXX.CodePage
  out ppOutput: IXmlWriterOutput): HRESULT; stdcall; external 'XmlLite.dll' {delayed};

function CreateXmlWriterOutputWithEncodingName(
  const pOutputStream: IStream;
  const pMalloc: IMalloc;
  const pwszEncodingName: PWideChar; // TEncoding.XXX.EncodingName
  out ppOutput: IXmlWriterOutput): HRESULT; stdcall; external 'XmlLite.dll' {delayed};




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
  CheckHR(CreateXmlWriter(XMLWriterGuid, iUnknown(Result), nil));
  if (Result <> nil) and (FileName <> '') then
    CheckHR(Result.SetOutput(OpenXmlFileStreamWriter(FileName)));
end;

function CreateXmlFileWriterWithEnc(const FileName: string; Encoding: TEncoding): IXmlWriter;
var
  output: IXmlWriterOutput;
  stream: IStream;
begin
  CheckHR(CreateXmlWriter(XMLWriterGuid, iUnknown(Result), nil));
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
