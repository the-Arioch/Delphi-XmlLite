Delphi-XmlLite
==============

Header translation for Microsoft XmlLite

* XmlLite is a native C++ implementation of .NET XmlReader+Writer for stream-based, forward-only XML parsing and creation.
* XmlLite.dll is required.  It is included with all new versions of Windows, and service packs for old versions.
* XmlReader's pull-based interface is cleaner to use than SAX's event-based interface.
* More info: http://msdn.microsoft.com/en-us/library/ms752838%28v=VS.85%29.aspx
* StackOverflow discussion: http://stackoverflow.com/a/6969959/243144
                                                                                        
**Note**: This is a minimal translation, some parts were not implemented and most are untested.

**Note**: i only used it in Win32 projects, but Delphi/Win64 was independently tested at 
* https://github.com/EtheaDev/SVGIconImageList/pull/97
* https://github.com/EtheaDev/SVGIconImageList/issues/96

Sample code taken from production.  We use this to generate very large (>1GB) Xml files from an array of temporary files.

    procedure AppendFile(const FileName: string; _IXMLWriter: IXMLWriter);
    var
      _IXMLReader: IXMLReader;
      NodeType: Integer;
      LocalName: PWideChar;
      LocalNameLen: LongWord;
    begin
      _IXMLReader := CreateXmlFileReader(FileName);
      while not _IXMLReader.IsEOF do
      begin
        _IXMLReader.GetLocalName(LocalName, LocalNameLen);
        if (LocalName = 'SecondLevelNodeName') then
          _IXMLWriter.WriteNode(_IXMLReader, True)
        else
          _IXMLReader.Read(NodeType);
      end;
    end;
  
    procedure CombineXmlFiles(const FileName: string; TempXmlFileArray: StringArray);
    var
      _IXMLWriter : IXMLWriter;
      iCounter: Integer;
    begin
      _IXMLWriter := CreateXmlFileWriter(FileName);

      _IXMLWriter.SetProperty(XmlWriterProperty_Indent, LongInt(True));

      _IXMLWriter.WriteStartDocument(XmlStandalone_Omit);
      _IXMLWriter.WriteStartElement(nil, PWideChar('RootNodeName'), nil);

      for iCounter := 0 to High(TempXmlFileArray) do
        AppendFile(TempXmlFileArray[iCounter], _IXMLWriter);

      _IXMLWriter.WriteEndElement;
      _IXMLWriter.WriteEndDocument;
      _IXMLWriter.Flush;
    end;
