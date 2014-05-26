var
  BaseFileMethods: TStreamMethods = (
    fSeek: SeekFileStream;
    fGetSiz: GetSizeFileStream;
    fSetSiz: SetSizeFileStream;
    fRead: ReadFileStream;
    fWrite: WriteFileStream;
    fClose: CloseFileStream;
    fCustom: nil;
  );
  MemoryMethods: TStreamMethods = (
    fSeek: SeekMemStream;
    fGetSiz: GetSizeMemStream;
    fSetSiz: SetSizeMemStream;
    fRead: ReadMemStream;
    fWrite: WriteMemStream;
    fClose: CloseMemStream;
    fCustom: nil;
);

function FileCreate(const FileName: string; OpenFlags: DWord): THandle;
var
  Attr: DWORD;
begin
  Attr:=(OpenFlags shr 16) and $1FFF;
  if Attr=0 then Attr:=FILE_ATTRIBUTE_NORMAL;
  Result:=CreateFile(PChar(FileName), OpenFlags and $F0000000,
                     OpenFlags and $F, nil, (OpenFlags shr 8) and $F,
                     Attr, 0);
end;

function FileSeek(Handle: THandle; MoveTo: TStrmMove; MoveMethod: TMoveMethod): TStrmSize;
var
  HiPtr: DWORD;
begin
  HiPtr:=MoveTo shr 32;
  Result:=SetFilePointer(Handle, DWORD(MoveTo), @HiPtr, Ord(MoveMethod));
  if (DWORD(Result)=$FFFFFFFF {INVALID_SET_FILE_POINTER}) and
     (GetLastError<>NO_ERROR) then
     Result:=-1; // Int64(-1)
  if Result>=0 then
    Result:=Result or (HiPtr shl 32);
end;

function FileRead(Handle: THandle; var Buffer; Count: DWord): DWord;
begin
  if not ReadFile(Handle, Buffer, Count, Result, nil) then
    Result:=0;
end;

function FileWrite(Handle: THandle; const Buffer; Count: DWord): DWord;
begin
  if not WriteFile(Handle, Buffer, Count, Result, nil) then
    Result:=0;
end;

function FileClose(Handle: THandle): Boolean;
begin
  Result:=CloseHandle(Handle);
end;

////////////////////////////////////////////////////////////////////////////////
//                           BaseFileMethods                                  //
////////////////////////////////////////////////////////////////////////////////

function SeekFileStream(Strm: TStream; MoveTo: TStrmMove; MoveFrom: TMoveMethod): TStrmSize;
begin
  Result:=FileSeek(Strm.Data.fHandle, MoveTo, MoveFrom);
  {$IFDEF FILESTREAM_POSITION}
  Strm.Data.fPosition:=Result;
  {$ENDIF}
end;

function GetSizeFileStream(Strm: TStream): TStrmSize;
var
  SizeHigh: DWORD;
begin
  Result:=GetFileSize(Strm.Data.fHandle, @SizeHigh);
  Result:=Result or SizeHigh shl 32;
end;

procedure SetSizeFileStream(Strm: TStream; NewSize: TStrmSize);
var
  P: DWORD;
begin
  P:=Strm.Position;
  Strm.Position:=NewSize;
  SetEndOfFile(Strm.Handle);
  if P < NewSize then
    Strm.Position:=P;
end;

function ReadFileStream(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize;
begin
  Result:=FileRead(Strm.Data.fHandle, Buffer, Count);
  {$IFDEF FILESTREAM_POSITION}
  inc(Strm.fData.fPosition, Result);
  {$ENDIF}
end;

function WriteFileStream(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize;
begin
  Result:=FileWrite(Strm.Data.fHandle, Buffer, Count);
  {$IFDEF FILESTREAM_POSITION}
  inc(Strm.fData.fPosition, Result);
  {$ENDIF}
end;

procedure CloseFileStream(Strm: TStream);
begin
  if Strm.Data.fHandle<>INVALID_HANDLE_VALUE then
    FileClose(Strm.Data.fHandle);
  Strm.Data.fHandle:=INVALID_HANDLE_VALUE;
end;

////////////////////////////////////////////////////////////////////////////////
//                            MemoryMethods                                   //
////////////////////////////////////////////////////////////////////////////////

function SeekMemStream(Strm: TStream; MoveTo: TStrmMove; MoveFrom: TMoveMethod): TStrmSize;
var
  NewPos: DWORD;
begin
  case MoveFrom of
  spBegin: NewPos:=MoveTo;
  spCurrent: NewPos:=Strm.Data.fPosition+DWORD(MoveTo);
  else //spEnd:
    NewPos:=Strm.Data.fSize+DWORD(MoveTo);
  end;
  if NewPos>Strm.Data.fSize then
    Strm.SetSize(NewPos);
  Strm.Data.fPosition:=NewPos;
  Result:=NewPos;
end;

function GetSizeMemStream(Strm: TStream): TStrmSize;
begin
  Result:=Strm.Data.fSize;
end;

procedure SetSizeMemStream(Strm: TStream; NewSize: TStrmSize);
var
  S: TStream;
  NewCapacity: DWORD;
begin
  S:=Strm;
  if S.Data.fCapacity<NewSize then
  begin
    {$IFDEF OLD_MEMSTREAMS_SETSIZE}
    NewCapacity:=(NewSize or CapacityMask)+1;
    {$ELSE}
    NewCapacity:=NewSize;
    {$ENDIF}
    if S.fMemory=nil then
    begin
      if NewSize<>0 then
        GetMem(S.fMemory, NewCapacity);
    end
      else ReallocMem(S.fMemory, NewCapacity);
    S.Data.fCapacity:=NewCapacity;
  end
    else
  if (NewSize=0) and (S.Size>0) then
    if S.fMemory<>nil then
    begin
      FreeMem(S.fMemory);
      S.fMemory:=nil;
      S.Data.fCapacity:=0;
    end;
  S.Data.fSize:=NewSize;
  if S.Data.fPosition>S.Data.fSize then
    S.Data.fPosition:=S.Data.fSize;
end;

function ReadMemStream(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize;
var
  S: TStream;
  C: TStrmSize;
begin
  S:=Strm;
  C:=Count;
  if C + S.Data.fPosition>S.Data.fSize then
    C:=S.Data.fSize-S.Data.fPosition;
  Result:=C;
  Move(Pointer(DWORD(S.fMemory)+S.Data.fPosition)^, Buffer, Result);
  Inc(S.Data.fPosition, Result);
end;

function WriteMemStream(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize;
var
  S: TStream;
begin
  S:=Strm;
  if Count+S.Data.fPosition>S.Data.fSize then
    S.SetSize(S.Data.fPosition+Count);
  Result:=Count;
  Move(Buffer, Pointer(DWORD(S.fMemory)+S.Data.fPosition)^, Result);
  Inc(S.Data.fPosition, Result);
end;

procedure CloseMemStream(Strm: TStream);
var
  S: TStream;
begin
  S:=Strm;
  if (S.fMemory<>nil) and (not Strm.Data.IsExMem) then
  begin
    FreeMem(S.fMemory);
    S.fMemory:=nil;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//                                TStream                                     //
////////////////////////////////////////////////////////////////////////////////

constructor TStream.Create(Methods: TStreamMethods);
begin
  inherited Create();
  Move(Methods.fSeek, fMethods.fSeek, Sizeof(TStreamMethods));
  Data.IsExMem:=false;
end;

constructor TStream.CreateFileStream(const FileName: string; Mode: ulong);
begin
  inherited Create();

  if Mode and ofOpenReadWrite=ofOpenReadWrite then
  begin
    if FileExists(FileName) then
      Mode:=Mode or ofOpenExisting
        else Mode:=Mode or ofCreateAlways;
  Data.IsExMem:=false;
  end;

  Move(BaseFileMethods, fMethods, Sizeof(TStreamMethods));
  fPMethods:=@fMethods;

  Data.fHandle:=FileCreate(FileName, Mode);
  Data.IsChange:=false;
  Data.IsExMem:=false;
end;

constructor TStream.CreateReadFileStream(const FileName: string);
begin
  CreateFileStream(FileName, ofOpenRead or ofShareDenyWrite or ofOpenExisting);
  Data.IsExMem:=false;
end;

constructor TStream.CreateWriteFileStream(const FileName: string);
begin
  CreateFileStream(FileName, ofOpenWrite or ofCreateAlways or ofShareDenyWrite);
  Data.IsExMem:=false;
end;

constructor TStream.CreateReadWriteFileStream(const FileName: string);
begin
  CreateFileStream(FileName, ofOpenReadWrite or ofShareDenyWrite or ofCreateAlways);
  Data.IsExMem:=false;
end;
                                           {
constructor TStream.CreateReadFileStream(const FileName: AnsiString);
begin
  CreateFileStream(ansi2Wide(FileName), ofOpenRead or ofShareDenyWrite or ofOpenExisting);
end;

constructor TStream.CreateWriteFileStream(const FileName: AnsiString);
begin
  CreateFileStream(ansi2Wide(FileName), ofOpenWrite or ofCreateAlways or ofShareDenyWrite);
end;

constructor TStream.CreateReadWriteFileStream(const FileName: AnsiString);
begin
  CreateFileStream(ansi2Wide(FileName), ofOpenReadWrite or ofShareDenyWrite);
end;                                    }

constructor TStream.CreateMemoryStream();
begin
  inherited Create();
  Move(MemoryMethods.fSeek, fMethods.fSeek, Sizeof(TStreamMethods));
  fPMethods:=@fMethods;
  Data.IsChange:=false;
  Data.IsExMem:=false;
end;

constructor TStream.CreateMemoryStreamEx(AData: Pointer; PointerSize: TStrmSize);
begin
  inherited Create();
  Move(MemoryMethods.fSeek, fMethods.fSeek, Sizeof(TStreamMethods));
  fPMethods:=@fMethods;
  Data.IsChange:=false;
  fMemory:=AData;
  Data.fSize:=PointerSize;
  Data.IsExMem:=true;
end;

constructor TStream.CreateStreamOnStream(Procs: pStreamMethods);
begin
  inherited Create();
  Move(Procs^.fSeek, fMethods.fSeek, Sizeof(TStreamMethods));
  fPMethods:=@fMethods;
  Data.IsChange:=false;
  Data.IsExMem:=false;
end;

function TStream.GetPosition: TStrmSize;
begin
  Result:=Seek(0, spCurrent);
end;

procedure TStream.SetPosition(const Value: TStrmSize);
begin
  Seek(Value, spBegin);
end;

function TStream.GetSize: TStrmSize;
begin
  Result:=fMethods.fGetSiz(Self);
end;

procedure TStream.SetSize(const NewSize: TStrmSize);
begin
  fMethods.fSetSiz(Self, NewSize);
end;

function TStream.GetFileStreamHandle: THandle;
begin
  Result:=Data.fHandle;
end;

function TStream.Read(var Buffer; const Count: TStrmSize): TStrmSize;
begin
  Result:=Methods.fRead(Self, Buffer, Count);
end;

function TStream.ReadStrZ(): AnsiString;
var
  c: Ansichar;
begin
  result:='';
  repeat
    c:=#0;
    Read(c, 1);
    if c<>#0 then
      result:=result+c;
  until c=#0;
end;

function TStream.ReadStrLen(Len: Integer): string;
var
  i: Integer;
begin
  SetLength( Result, Len);
  i:=Read(Result[1], Len*sizeof(result[1]));
  SetLength(Result, i);
end;

function TStream.ReadStrLenAnsi(Len: Integer): AnsiString;
var
  i: Integer;
begin
  SetLength( Result, Len);
  i:=Read(Result[1], Len);
  SetLength(Result, i);
end;

function TStream.ReadStr: AnsiString;
var
  C: AnsiChar;
begin
  Result := '';
  REPEAT
    C := #0;
    Read( C, 1 );
    if C <> #0 then
    begin
      if C = #13 then
      begin
        C := #0;
        Read( C, 1 );
        if C <> #10 then Position := Position - 1;
        C := #13;
      end
        else
      if C = #10 then
        C := #13;
      if C <> #13 then
        Result := Result + C;
    end;
  UNTIL C in [ #13, #0 ];
end;

function TStream.ReadStrWide: WideString;
var
  C: WideChar;
begin
  Result := '';
  REPEAT
    C := #0;
    Read( C, 2 );
    if C <> #0 then
    begin
      if C = #13 then
      begin
        C := #0;
        Read( C, 2 );
        if C <> #10 then Position := Position - 1;
        C := #13;
      end
        else
      if C = #10 then
        C := #13;
      if C <> #13 then
        Result := Result + C;
    end;
  UNTIL C in [ #13, #0 ];
end;

function TStream.GetCapacity: TStrmSize;
begin
  Result:=Data.fCapacity;
end;

procedure TStream.SetCapacity(const Value: TStrmSize);
var OldSize: DWORD;
    V: TStrmSize;
begin
  V:=Value;
  {$IFDEF OLD_STREAM_CAPACITY}
  if fData.fCapacity>=Value then
    Exit;
  OldSize:=Size;
  Size:=V;
  Size:=OldSize;
  {$ELSE}
  if Value<Data.fSize then
    V:=Data.fSize;
  if Value>Data.fCapacity then
  begin
    OldSize:=Size;
    Size:=V;
    Size:=OldSize;
  end
    else
  if fMemory<>nil then
  begin
    {$IFDEF _D4orHigher}
    fMemory:=ReallocMemory(fMemory, V);
    {$ELSE}
    ReallocMem(fMemory, V);
    {$ENDIF}
    Data.fCapacity:=V;
  end;
  {$ENDIF}
end;

function TStream.Write(const Buffer; Count: TStrmSize): TStrmSize;
begin
  Result:=fMethods.fWrite(Self, Buffer, Count);
end;

function TStream.WriteAnsiStr(Str: AnsiString): TStrmSize;
begin
  result:=Write(Str[1], Length(Str)*sizeof(Str[1]));
end;

function TStream.WriteWideStr(Str: WideString): TStrmSize;
begin
  result:=Write(Str[1], Length(Str)*sizeof(Str[1]));
end;

function TStream.Seek(MoveTo: TStrmMove; MoveMethod: TMoveMethod): TStrmSize;
begin
  Result:=fMethods.fSeek(Self, MoveTo, MoveMethod);
end;

destructor TStream.Destroy;
begin
  Seek(0, spBegin);
  fMethods.fClose(Self);
  //fData.fThread.Free;
  inherited Destroy();
end;