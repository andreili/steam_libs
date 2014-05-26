unit USE_Utils;

interface

{$I defines.inc}

uses
  USE_Types, Windows;


function jenkinsLookupHash2(Data: pByte; Length: integer; InitVal: uint32): uint32;
function adler32(adler: uint32; buf: pByte; len: integer): uint32;
function CRC32(lpBuffer: pByte; uiBufferSize: uint32): uint32;
function Checksum(lpBuffer: pByte; uiBufferSize: uint32): uint32; inline;
function uncompress(dest: Pointer; var destLen: uint32; source: Pointer; sourceLen: uint32): uint32;
function compress(dest: Pointer; var destLen: uint32; source: Pointer; sourceLen: uint32): uint32;
function memcmp(const buf1, buf2: Pointer; len: Integer): Integer;
function MakeWord(a, b: Byte): Word; inline;
function Ansi2Wide(str: AnsiString): WideString;
function Wide2Ansi(str: WideString): AnsiString;
function Ansi2OEM(str: AnsiString): AnsiString;
function Wide2OEM(str: WideString): WideString;
function FileExists(const FileName: string): Boolean; inline;
function CreateDir(const Dir: string): Boolean; inline;
function ForceDirectories(Dir: string): Boolean;
function FixSlashes(str: string): string;
function DirectoryExists(const Name: string): Boolean;
function CompareStr_NoCase(const S1, S2: string): Integer;
function CompareStr(const S1, S2: string): Integer;
function StrSatisfy(const S, Mask: string): Boolean;
function LowerCase(const S: string): string; overload;
function UpperCase(const S: string): string;
function LowerCaseAnsi(const S: Ansistring): Ansistring; overload;
function __DelimiterLast(Str, Delimiters: PChar): PChar;
function ExtractFileName(const Path: string): string;
function ExtractFilePath(const Path: string): string;
function ExtractFileExt( const Path : string ) : string;
function FileSize(const Path: string): Int64;
function IncludeTrailingChar(const S: string; C: char): string; inline;
function IncludeTrailingPathDelimiter(const S: string): string; inline;
function ExcludeTrailingChar(const S: string; C: char): string; inline;
function ExcludeTrailingPathDelimiter(const S: string): string; inline;
function Str2Int(const Value : string) : Integer;
function Str2Int64(const Value : string) : int64;
function Hex2Int( const Value : string) : int64;
function Int2StrEx(Value: int64; MinLength: integer): string;
function Int2Str(Value: int64): string;
function Int2Hex( Value : DWord; Digits : Integer ) : string;
function Int64_2Str( X: I64 ): string;
function IntPower(Base: Extended; Exponent: Integer): Extended;
function Str2Double( const S: string ): Double;
function Extended2Str( E: Extended ): string;
function Double2Str( D: Double ): String;
function CopyEnd(const S: string; Idx: Integer ): string;
function StrReplace( var S: string; const From, ReplTo: string ): Boolean;
function IndexOfStr(const S, Sub: string; startpos: integer = 1): Integer;
function IndexOfChar(const S: string; Chr: char): Integer;
function IndexOfCharsMin(const S, Chars: string): Integer;
function Parse(var S: string; const Separators: string): string;
function Format( const fmt: string; params: Array of const ): string;
procedure DivMod(Dividend: Integer; Divisor: Word; var Result, Remainder: Word);
function Min(const A, B: Integer): Integer; inline;
function GetStartDir : String;
function StrLen(const Str: PAnsiChar): Cardinal; overload;
function StrLen(const Str: PWideChar): Cardinal; overload;
function StrPos(const Str1, Str2: PAnsiChar): PAnsiChar; assembler;
function StrCopy(Dest: PChar; const Source: PChar): PChar;

function IsLeapYear(Year: Integer): Boolean; inline;
function DayOfWeek(Date: TDateTime): Integer; inline;
function DateTime2SystemTime(const DateTime : TDateTime; var SystemTime : TSystemTime ) : Boolean;
function SystemDate2Str( const SystemTime : TSystemTime; const LocaleID : DWORD;
                         const DfltDateFormat : TDateFormat;
                         const DateFormat : pChar ) : string;
function SystemTime2Str( const SystemTime : TSystemTime; const LocaleID : DWORD;
                         const Flags : TTimeFormatFlags;
                         const TimeFormat : pChar ) : string;
function Date2StrFmt( const Fmt: string; D: TDateTime ): string;
function Time2StrFmt( const Fmt: string; D: TDateTime ): string;
function Str2DateTimeFmt( const sFmtStr, sS: string ): TDateTime;
function Str2DateTimeShort( const S: string ): TDateTime;
function SystemTime2DateTime(const SystemTime : TSystemTime; var DateTime : TDateTime ) : Boolean;
function FileTime2DateTime( const ft: TFileTime; var DT: TDateTime ): Boolean;
function DateTime2StrShort( D: TDateTime ): String;
function Now : TDateTime;

function Neg64( const X: I64 ): I64;
function Mul64EDX( const X: I64; M: Integer ): I64;
function Mul64i( const X: I64; Mul: Integer ): I64;
function Div64EDX( const X: I64; D: Integer ): I64;
function Div64i( const X: I64; D: Integer ): I64;
function Mod64i( const X: I64; D: Integer ): Integer;
function Sgn64( const X: I64 ): Integer;
function Cmp64( const X, Y: I64 ): Integer;
procedure IncInt64( var I64: I64; Delta: Integer );
procedure DecInt64( var I64: I64; Delta: Integer );
function Add64( const X, Y: I64 ): I64;
function Sub64( const X, Y: I64 ): I64;

{$IFDEF LOG}
procedure Log(Mess: string);
{$ENDIF}

implementation

uses
  KOLZLib;

{$IFDEF LOG}
procedure Log(Mess: string);
var
  str: TStream;
  dt: TDateTime;
  st: TSystemTime;
begin
  str:=TStream.CreateReadWriteFileStream('.\log.txt');
  str.Position:=str.Size;
  dt:=Now();
  DateTime2SystemTime(dt, st);
  str.WriteWideStr(DateTime2StrShort(dt)+'.'+Int2Str(st.wMilliseconds)+': ');
  str.WriteWideStr(Mess+#10#13);
  str.Free;
end;
{$ENDIF}

procedure mix(var a, b, c: uint32); inline;
begin
  dec(a, b);  dec(a, c);  a:=a xor (c shr 13);
  dec(b, c);  dec(b, a);  b:=b xor (a shl 8);
  dec(c, a);  dec(c, b);  c:=c xor (b shr 13);
  dec(a, b);  dec(a, c);  a:=a xor (c shr 12);
  dec(b, c);  dec(b, a);  b:=b xor (a shl 16);
  dec(c, a);  dec(c, b);  c:=c xor (b shr 5);
  dec(a, b);  dec(a, c);  a:=a xor (c shr 3);
  dec(b, c);  dec(b, a);  b:=b xor (a shl 10);
  dec(c, a);  dec(c, b);  c:=c xor (b shr 15);
end;

function jenkinsLookupHash2(Data: pByte; Length: integer; InitVal: uint32): uint32;
var
  a, b, c, len: uint32;
begin
  len:=Length;
  a:=$9e3779b9;
  b:=a;
  c:=InitVal;

  while (len>=12) do
  begin
    inc(a, Data[0] + (Data[1] shl 8) + (Data[2]  shl 16) + (Data[3]  shl 24));
    inc(b, Data[4] + (Data[5] shl 8) + (Data[6]  shl 16) + (Data[7]  shl 24));
    inc(c, Data[8] + (Data[9] shl 8) + (Data[10] shl 16) + (Data[11] shl 24));
    mix(a, b, c);
    Data:=pByte(@Data[12]);
    dec(len, 12);
  end;

  inc(c, length);
  if len>=11 then
    inc(c, Data[10] shl 24);
  if len>=10 then
    inc(c, Data[9] shl 16);
  if len>=9 then
    inc(c, Data[8] shl  8);
  if len>=8 then
    inc(b, Data[7] shl 24);
  if len>=7 then
    inc(b, Data[6] shl 16);
  if len>=6 then
    inc(b, Data[5] shl  8);
  if len>=5 then
    inc(b, Data[4]);
  if len>=4 then
    inc(a, Data[3] shl 24);
  if len>=3 then
    inc(a, Data[2] shl 16);
  if len>=2 then
    inc(a, Data[1] shl  8);
  if len>=1 then
    inc(a, Data[0]);

  mix(a, b, c);
  result:=c;
end;

const
  NMAX = 5552;
  BASE: uint32 =  65521;

function adler32(adler: uint32; buf: pByte; len: integer): uint32;
var
  sum2: uint32;
  n: uint32;
  procedure DO1(buf_: pbyte; i: integer);
  begin
    inc(adler, buf_[i]);
    inc(sum2, adler);
  end;
  procedure DO2(buf_: pbyte; i: integer);
  begin
    DO1(buf_, i);
    DO1(buf_, i+1);
  end;
  procedure DO4(buf_: pbyte; i: integer);
  begin
    DO2(buf_, i);
    DO2(buf_, i+2);
  end;
  procedure DO8(buf_: pbyte; i: integer);
  begin
    DO4(buf_, i);
    DO4(buf_, i+4);
  end;
  procedure DO16(buf_: pbyte);
  begin
    DO8(buf_, 0);
    DO8(buf_, 8);
  end;
begin
  sum2:=(adler shr 16) and $ffff;
  adler:=adler and $ffff;

  if (len=1) then
  begin
    inc(adler, buf[0]);
    if (adler>=BASE) then
      dec(adler, BASE);
    inc(sum2, adler);
    if (sum2>BASE) then
      dec(sum2, BASE);
    result:=adler or (sum2 shl 16);
    Exit;
  end;

  if (buf=nil) then
  begin
    result:=$00000001;
    Exit;
  end;

  if (len<16) then
  begin
    while len>0 do
    begin
      dec(len);
      inc(adler, buf^);
      inc(buf);
      inc(sum2, adler);
    end;
    sum2:=sum2 mod BASE;
    result:=adler or (sum2 shl 16);
    Exit;
  end;

  while (len>=NMAX) do
  begin
    dec(len, NMAX);
    n:=NMAX div 16;
    repeat
      DO16(buf);
      inc(buf, 16);
      dec(n);
    until n=0;
    adler:=adler mod BASE;
    sum2:=sum2 mod BASE;
  end;
  if (len>0) then
  begin
    while (len>=16) do
    begin
      dec(len, 16);
      DO16(buf);
      inc(buf, 16);
    end;
    while (len>0) do
    begin
      dec(len);
      inc(adler, buf^);
      inc(buf);
      inc(sum2, adler);
    end;
    adler:=adler mod BASE;
    sum2:=sum2 mod BASE;
  end;
  result:=adler or (sum2 shl 16);
end;

// CRC 32
{$REGION}
var
  CRC32Table : array[0..255] of uint32 = (
      $00000000, $77073096, $ee0e612c, $990951ba, $076dc419,
      $706af48f, $e963a535, $9e6495a3, $0edb8832, $79dcb8a4,
      $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07,
      $90bf1d91, $1db71064, $6ab020f2, $f3b97148, $84be41de,
      $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7, $136c9856,
      $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9,
      $fa0f3d63, $8d080df5, $3b6e20c8, $4c69105e, $d56041e4,
      $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
      $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3,
      $45df5c75, $dcd60dcf, $abd13d59, $26d930ac, $51de003a,
      $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599,
      $b8bda50f, $2802b89e, $5f058808, $c60cd9b2, $b10be924,
      $2f6f7c87, $58684c11, $c1611dab, $b6662d3d, $76dc4190,
      $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f,
      $9fbfe4a5, $e8b8d433, $7807c9a2, $0f00f934, $9609a88e,
      $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
      $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed,
      $1b01a57b, $8208f4c1, $f50fc457, $65b0d9c6, $12b7e950,
      $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3,
      $fbd44c65, $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2,
      $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb, $4369e96a,
      $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5,
      $aa0a4c5f, $dd0d7cc9, $5005713c, $270241aa, $be0b1010,
      $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
      $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17,
      $2eb40d81, $b7bd5c3b, $c0ba6cad, $edb88320, $9abfb3b6,
      $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615,
      $73dc1683, $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8,
      $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1, $f00f9344,
      $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb,
      $196c3671, $6e6b06e7, $fed41b76, $89d32be0, $10da7a5a,
      $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
      $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1,
      $a6bc5767, $3fb506dd, $48b2364b, $d80d2bda, $af0a1b4c,
      $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef,
      $4669be79, $cb61b38c, $bc66831a, $256fd2a0, $5268e236,
      $cc0c7795, $bb0b4703, $220216b9, $5505262f, $c5ba3bbe,
      $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31,
      $2cd99e8b, $5bdeae1d, $9b64c2b0, $ec63f226, $756aa39c,
      $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
      $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b,
      $e5d5be0d, $7cdcefb7, $0bdbdf21, $86d3d2d4, $f1d4e242,
      $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1,
      $18b74777, $88085ae6, $ff0f6a70, $66063bca, $11010b5c,
      $8f659eff, $f862ae69, $616bffd3, $166ccf45, $a00ae278,
      $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7,
      $4969474d, $3e6e77db, $aed16a4a, $d9d65adc, $40df0b66,
      $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
      $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605,
      $cdd70693, $54de5729, $23d967bf, $b3667a2e, $c4614ab8,
      $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b,
      $2d02ef8d);

function CRC32(lpBuffer: pByte; uiBufferSize: uint32): uint32;
var
  i: Integer;
begin
  Result := $FFFFFFFF;
  for i := 0 to uiBufferSize-1 do
  begin
    Result := ((Result shr 8) and $00FFFFFF) xor CRC32Table[(Result xor lpBuffer^) and $FF];
    inc(lpBuffer);
  end;
  Result := Result xor $FFFFFFFF;
end;
{$ENDREGION}

function Checksum(lpBuffer: pByte; uiBufferSize: uint32): uint32;
begin
  result:=Adler32(0, lpBuffer, uiBufferSize) xor CRC32(lpBuffer, uiBufferSize);
end;

function uncompress(dest: Pointer; var destLen: uint32; source: Pointer; sourceLen: uint32): uint32;
var
  stream: TZStreamRec;
  err: integer;
begin
  stream.next_in:=source;
  stream.avail_in:=sourceLen;

  stream.next_out:=dest;
  stream.avail_out:=destLen;

  stream.zalloc:=zcalloc;
  stream.zfree:=zcfree;

  err:=inflateInit_(stream, zlib_version, sizeof(stream));
  if err<>Z_OK then
  begin
    result:=err;
    Exit;
  end;
  err:=inflate(stream, Z_FINISH);
  if err<>Z_STREAM_END then
  begin
    inflateEnd(stream);
    if (err=Z_NEED_DICT) or ((err=Z_BUF_ERROR) and (stream.avail_in=0)) then
    begin
      result:=uint32(Z_DATA_ERROR);
      Exit;
    end;
    result:=err;
    Exit;
  end;
  err:=inflateEnd(stream);
  destLen:=stream.total_out;
  result:=err;
end;

function compress(dest: Pointer; var destLen: uint32; source: Pointer; sourceLen: uint32): uint32;
var
  stream: TZStreamRec;
  err: integer;
begin
  stream.next_in:=source;
  stream.avail_in:=sourceLen;

  stream.next_out:=dest;
  stream.avail_out:=destLen;

  stream.zalloc:=zcalloc;
  stream.zfree:=zcfree;

  err:=deflateInit_(stream, 3, zlib_version, sizeof(stream));
  if err<>Z_OK then
  begin
    result:=err;
    Exit;
  end;
  err:=deflate(stream, Z_FINISH);
  if err<>Z_STREAM_END then
  begin
    deflateEnd(stream);
    if (err=Z_NEED_DICT) or ((err=Z_BUF_ERROR) and (stream.avail_in=0)) then
    begin
      result:=ulong(Z_DATA_ERROR);
      Exit;
    end;
    result:=err;
    Exit;
  end;
  err:=deflateEnd(stream);
  destLen:=stream.total_out;
  result:=err;
end;


function memcmp(const buf1, buf2: Pointer; len: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  i := 0;
  while (i < len) and (Result = 0) do
  begin
    if PAnsiChar(buf1)[i] < PAnsiChar(buf2)[i] then
      Result := -1
    else if PAnsiChar(buf1)[i] > PAnsiChar(buf2)[i] then
      Result := 1;
    Inc(i);
  end;
end;

function MakeWord(A, B: Byte): Word;
begin
  Result := A or B shl 8;
end;

function Ansi2Wide(str: AnsiString): WideString;
var
  l: integer;
begin
{$IFDEF WIN}
  if str='' then Result:=''
    else
  begin
    l:=MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PAnsiChar(str), -1, nil, 0);
    SetLength(Result, l - 1);
    if l>1 then
      MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PAnsiChar(str), -1, PWideChar(Result), l-1);
  end;
{$ENDIF}
end;

function Wide2Ansi(str: WideString): AnsiString;
var
  l: integer;
begin
{$IFDEF WIN}
  if str='' then Result:=''
    else
  begin
    l:=WideCharToMultiByte(CP_NONE,
     WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
     PWideChar(str), -1, nil, 0, nil, nil);
    SetLength(Result, l-1);
    if l>1 then
      WideCharToMultiByte(CP_NONE,
       WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
       PWideChar(str), -1, PAnsiChar(Result), l-1, nil, nil);
  end;
{$ENDIF}
end;

function Ansi2OEM(str: AnsiString): AnsiString;
var
  res: array[0..1024] of AnsiChar;
begin
  AnsiToOem(@str[1], res);
  result:=Copy(res, 0, strlen(res));
end;

function Wide2OEM(str: WideString): WideString;
begin
  result:=Ansi2Wide(Ansi2OEM(str));
end;

function FileExists(const FileName: string): Boolean;
var Code: Integer;
begin
  Code:=GetFileAttributes(pChar(FileName));
  Result:=(Code<>-1) and (FILE_ATTRIBUTE_DIRECTORY and Code=0);
end;

function CreateDir(const Dir: string): Boolean;
begin
   Result:=CreateDirectory(pChar(Dir), nil);
end;

function ExtractFilePath(const Path: string): string;
var
  P, P0: pChar;
begin
  P0:=pChar(Path);
  P:=__DelimiterLast(P0, ':\/');
  if P^=#0 then Result:=''
    else Result:=Copy(Path, 1, P-P0+1);
end;

function ExtractFileExt( const Path : string ) : string;
var P: pChar;
begin
  P := __DelimiterLast( PChar( Path ), '.' );
  Result := P;
end;

function ForceDirectories(Dir: string): Boolean;
begin
 Result := Length(Dir) > 0; {Centronix}
 If not Result then Exit;
 Dir := ExcludeTrailingPathDelimiter(Dir);
 If (Length(Dir) < 3) or DirectoryExists(Dir) or
   (ExtractFilePath(Dir) = Dir) then Exit; // avoid 'xyz:\' problem.
 Result := ForceDirectories(ExtractFilePath(Dir)) and CreateDir(Dir);
end;

function FixSlashes(str: string): string;
var
  i: ulong;
  tmp: string;
begin
  result:='';
  if Length(str)=0 then
    Exit;
  tmp:=str;
  for i:=0 to length(tmp) do
    if tmp[i]='/' then tmp[i]:='\';
  for i:=1 to Length(tmp) do
    if (tmp[i]='\') and (tmp[i+1]='\') then
      Delete(tmp, i, 1);
  result:=tmp;
end;

function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
  e: DWORD;
begin
  e:=SetErrorMode(SEM_NOOPENFILEERRORBOX or SEM_FAILCRITICALERRORS);
  Code:=GetFileAttributes(PChar(Name));
  Result:=(Code<>-1) and (FILE_ATTRIBUTE_DIRECTORY and Code<>0);
  SetErrorMode(e);
end;

function CompareStr_NoCase(const S1, S2: string): Integer;
begin
  result:=CompareStr(LowerCase(S1), LowerCase(S2));
end;

function CompareStr(const S1, S2: string): Integer;
{$IFNDEF UNICODE}
asm
  {On entry:
     eax = @S1[1]
     edx = @S2[1]
   On exit:
     Result in eax:
       0 if S1 = S2,
       > 0 if S1 > S2,
       < 0 if S1 < S2
   Code size:
     101 bytes}
  cmp eax, edx
  je @SameString
  {Is either of the strings perhaps nil?}
  test eax, edx
  jz @PossibleNilString
  {Compare the first four characters (there has to be a trailing #0). In random
   string compares this can save a lot of CPU time.}
@BothNonNil:
  push 0
  push 0
  cmp word ptr [eax-10],1
  jz @leftIsAnsi

  push edx
  mov edx,eax
  mov eax,esp
  call System.@LStrFromUStr
  pop edx
  mov eax,[esp]

@leftIsAnsi:
  cmp word ptr [edx-10],1
  jz @rightIsAnsi

  push eax
  lea eax,[esp + 4]
  call System.@LStrFromUStr
  pop eax
  mov edx,[esp + 4]

@rightIsAnsi:
  {Compare the first character}
  movzx ecx, byte ptr [edx]
  cmp cl, [eax]
  je @FirstCharacterSame
  {First character differs}
  movzx eax, byte ptr [eax]
  sub eax, ecx
  jmp @Done
@FirstCharacterSame:
  {Save ebx}
  push ebx
  {Set ebx = length(S1)}
  mov ebx, [eax - 4]
  xor ecx, ecx
  {Set ebx = length(S1) - length(S2)}
  sub ebx, [edx - 4]
  {Save the length difference on the stack}
  push ebx
  {Set ecx = 0 if length(S1) < length(S2), $ffffffff otherwise}
  adc ecx, -1
  {Set ecx = - min(length(S1), length(S2))}
  and ecx, ebx
  sub ecx, [eax - 4]
  {Adjust the pointers to be negative based}
  sub eax, ecx
  sub edx, ecx
@CompareLoop:
  mov ebx, [eax + ecx]
  xor ebx, [edx + ecx]
  jnz @Mismatch
  add ecx, 4
  js @CompareLoop
  {All characters match - return the difference in length}
@MatchUpToLength:
  pop eax
  pop ebx
@Done:
  mov ecx,esp
  mov edx,[ecx]
  or edx,[ecx + 4]
  jz @NoClear
  push eax
  mov eax,ecx
  mov edx,2
  call System.@LStrArrayClr
  pop eax
@NoClear:
  pop edx
  pop edx
  ret
@Mismatch:
  bsf ebx, ebx
  shr ebx, 3
  add ecx, ebx
  jns @MatchUpToLength
  movzx eax, byte ptr [eax + ecx]
  movzx edx, byte ptr [edx + ecx]
  sub eax, edx
  pop ebx
  pop ebx
  jmp @Done
  {It is the same string}
@SameString:
  xor eax, eax
  ret
  {Good possibility that at least one of the strings are nil}
@PossibleNilString:
  test eax, eax
  jz @FirstStringNil
  test edx, edx
  jnz @BothNonNil
  {Return first string length: second string is nil}
  mov eax, [eax - 4]
  ret
@FirstStringNil:
  {Return 0 - length(S2): first string is nil}
  sub eax, [edx - 4]
end;
{$ELSE}
asm
  cmp eax, edx
  je @SameString
  {Is either of the strings perhaps nil?}
  test eax, edx
  jz @PossibleNilString
  {Compare the first four characters (there has to be a trailing #0). In random
   string compares this can save a lot of CPU time.}
@BothNonNil:
  push 0
  push 0
  cmp word ptr [eax-10],2
  jz @leftIsUnicode

  push edx
  mov edx,eax
  mov eax,esp
  call System.@UStrFromLStr
  pop edx
  mov eax,[esp]

@leftIsUnicode:
  cmp word ptr [edx-10],2
  jz @rightIsUnicode

  push eax
  lea eax,[esp + 8]
  call System.@UStrFromLStr
  pop eax
  mov edx,[esp + 4]

@rightIsUnicode:
  {Compare the first character}
  movzx ecx, word ptr [edx]
  cmp cx, [eax]
  je @FirstCharacterSame
  {First character differs}
  movzx eax, word ptr [eax]
  sub eax, ecx
  jmp @Done
@FirstCharacterSame:
  {Save ebx}
  push ebx
  {Set ebx = length(S1)}
  mov ebx, [eax - 4]
  xor ecx, ecx
  {Set ebx = length(S1) - length(S2)}
  sub ebx, [edx - 4]
  {Save the length difference on the stack}
  push ebx
  {Set ecx = 0 if length(S1) < length(S2), $ffffffff otherwise}
  adc ecx, -1
  {Set ecx = - min(length(S1), length(S2))}
  and ecx, ebx
  sub ecx, [eax - 4]
  sal ecx, 1
  {Adjust the pointers to be negative based}
  sub eax, ecx
  sub edx, ecx
@CompareLoop:
  mov ebx, [eax + ecx]
  xor ebx, [edx + ecx]
  jnz @Mismatch
  add ecx, 4
  js @CompareLoop
  {All characters match - return the difference in length}
@MatchUpToLength:
  pop eax
  pop ebx
@Done:
  mov ecx,esp
  mov edx,[ecx]
  or edx,[ecx + 4]
  jz @NoClear
  push eax
  mov eax,ecx
  mov edx,2
  call System.@LStrArrayClr
  pop eax
@NoClear:
  pop edx
  pop edx
  ret
@Mismatch:
  bsf ebx, ebx
  shr ebx, 4
  add ebx, ebx
  add ecx, ebx
  jns @MatchUpToLength
  movzx eax, word ptr [eax + ecx]
  movzx edx, word ptr [edx + ecx]
  sub eax, edx
  pop ebx
  pop ebx
  jmp @Done
  {It is the same string}
@SameString:
  xor eax, eax
  ret
  {Good possibility that at least one of the strings are nil}
@PossibleNilString:
  test eax, eax
  jz @FirstStringNil
  test edx, edx
  jnz @BothNonNil
  {Return first string length: second string is nil}
  mov eax, [eax - 4]
  ret
@FirstStringNil:
  {Return 0 - length(S2): first string is nil}
  sub eax, [edx - 4]
end;
{$ENDIF}

function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean; overload; inline;
begin
  Result := C in CharSet;
end;

function CharInSet(C: WideChar; const CharSet: TSysCharSet): Boolean; overload; inline;
begin
  Result := (C < #$0100) and (AnsiChar(C) in CharSet);
end;

function LowerCase(const S: string): string;
var
  I: Integer;
begin
  Result:=S;
  for I:=1 to Length(S) do
    if CharInSet(Result[I], ['A'..'Z']) or CharInSet(Result[I], ['À'..'ß']) then
       Inc(Result[I], 32);
end;

function UpperCase(const S: string): string;
var I : Integer;
begin
  Result := S;
  for I := 1 to Length( S ) do
    if CharInSet(result[I], [ 'a'..'z' ]) then
       Dec( Result[ I ], 32 );
end;

function LowerCaseAnsi(const S: Ansistring): Ansistring;
var
  I: Integer;
begin
  Result:=S;
  for I:=1 to Length(S) do
    if CharInSet(Result[I], ['A'..'Z']) or CharInSet(Result[I], ['À'..'ß']) then
    //if CharInSet(Result[I], ['A'..'Z']) then
       Inc(Result[I], 32);
end;

function WStrRScan(const Str: PChar; Chr: Char): PChar;
begin
  Result := Str;
  while Result^ <> #0 do inc( Result );
  while (DWORD( Result ) >= DWORD( Str )) and
        (Result^ <> Chr) do dec( Result );
  if (DWORD( Result ) < DWORD( Str )) then
    Result := nil;
end;

function _StrSatisfy(S, Mask: pChar ) : Boolean;
label next_char;
begin
next_char:
  Result := True;
  if (S^=#0) and (Mask^=#0) then
    exit;
  if (Mask^= '*') and (Mask[1]= #0) then
    exit;
  if S^=#0 then
  begin
    while Mask^='*' do
      Inc(Mask);
    Result:=Mask^=#0;
    exit;
  end;
  Result:=False;
  if Mask^=#0 then
    exit;
  if Mask^='?' then
  begin
    Inc(S);
    Inc(Mask);
    goto next_char;
  end;
  if Mask^='*' then
  begin
    Inc(Mask);
    while S^<>#0 do
    begin
      Result:=_StrSatisfy(S, Mask);
      if Result then
        exit;
      Inc(S);
    end;
    exit; // (Result = False)
  end;
  Result:=S^=Mask^;
  Inc(S);
  Inc(Mask);
  if Result then
    goto next_char;
end;

function StrSatisfy(const S, Mask: string): Boolean;
begin
  Result:=_StrSatisfy(pChar(LowerCase(S)), pChar(LowerCase(Mask)));
end;

function WStrLen( W: PChar ): Integer;
asm
         XCHG     EDI, EAX
         XCHG     EDX, EAX
         OR       ECX, -1
         XOR      EAX, EAX
         CMP      EAX, EDI
         JE       @@exit0
{$IFDEF UNICODE}
         REPNE    SCASW
{$ELSE}
         REPNE    SCASB
{$ENDIF}
         DEC      EAX
         DEC      EAX
         SUB      EAX, ECX
@@exit0:
         MOV      EDI, EDX
end;

function __DelimiterLast(Str, Delimiters: PChar): PChar;
var
  P, F: PChar;
begin
  P:=Str;
  Result:=P+WStrLen(Str);
  while Delimiters^<>#0 do
  begin
    F:=WStrRScan(P, Delimiters^);
    if F <> nil then
    if (Result^=#0) or (Integer(F)>Integer(Result)) then
      Result:=F;
    Inc(Delimiters);
  end;
end;

function ExtractFileName(const Path: string): string;
var
  P: pChar;
begin
  P:=__DelimiterLast(PChar(Path), ':\/');
  if P^=#0 then Result:=Path
    else Result:=P+1;
end;

function FileSize(const Path: string): Int64;
var
  FD: TWin32FindData;
  Handle: THandle;
begin
  Result:=0;
  Handle:=FindFirstFile(pChar(Path), FD);
  if Handle=INVALID_HANDLE_VALUE then
    Exit;
  I64(Result).Lo:=FD.nFileSizeLow;
  I64(Result).Hi:=FD.nFileSizeHigh;
  FindClose(Handle);
end;

function IncludeTrailingChar(const S: string; C: char): string;
begin
  Result:=S;
  if (Result='') or (Result[Length(Result)]<>C) then
    Result:=Result+C;
end;

function IncludeTrailingPathDelimiter(const S: string): string;
begin
   Result:=IncludeTrailingChar(S, {$IFDEF UNIX}'/'{$ELSE}'\'{$ENDIF});
end;

function ExcludeTrailingChar(const S: string; C: char ): string;
begin
  Result:=S;
  if Result<>'' then
  if Result[Length(Result)] = C then
    Delete(Result, Length(Result), 1);
end;

function ExcludeTrailingPathDelimiter(const S: string): string;
begin
   Result:=ExcludeTrailingChar(S, {$IFDEF UNIX}'/'{$ELSE}'\'{$ENDIF});
end;

function S2Int( S: PChar ): Integer;
var M : Integer;
begin
   Result := 0;
   if S = '' then Exit;
   M := 1;
   if S^ = '-' then
   begin
      M := -1;
      Inc( S );
   end
     else
   if S^ = '+' then
     Inc( S );
   while CharInSet(S^, [ '0'..'9' ]) do
   begin
      Result := Result * 10 + Integer( S^ ) - Integer( '0' );
      Inc( S );
   end;
   if M < 0 then
      Result := -Result;
end;

function Str2Int(const Value : string) : Integer;
begin
  Result := S2Int( PChar( Value ) );
end;

function Str2Int64(const Value : string) : int64;
var
  M : int64;
  S: pChar;
begin
   Result := 0;
   S:=pChar(Value);
   if S = '' then Exit;
   M := 1;
   if S^ = '-' then
   begin
      M := -1;
      Inc( S );
   end
     else
   if S^ = '+' then
     Inc( S );
   while CharInSet(S^, [ '0'..'9' ]) do
   begin
      Result := Result * 10 + Integer( S^ ) - Integer( '0' );
      Inc( S );
   end;
   if M < 0 then
      Result := -Result;
end;

function Hex2Int( const Value : string) : int64;
var I : Integer;
begin
  Result := 0;
  I := 1;
  if Value = '' then Exit;
  if Value[ 1 ] = '$' then Inc( I );                    // Delphi
  if (Value[1]='0') and (Value[2]='x')  then inc(I, 2); // C/C++/C#
  while I <= Length( Value ) do
  begin
    if CharInSet(Value[ I ], [ '0'..'9' ]) then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('0'))
    else
    if CharInSet(Value[ I ], [ 'A'..'F' ]) then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('A') + 10)
    else
    if CharInSet(Value[ I ], [ 'a'..'f' ]) then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('a') + 10)
    else
      break;
    Inc( I );
  end;
end;

function Int2Str(Value: int64): string;
var
  Buf: Array[0..15] of char;
  Dst: PChar;
  Minus: Boolean;
  D: DWORD;
begin
  Dst:=@Buf[ 15 ];
  Dst^:=#0;
  Minus:=False;
  if Value<0 then
  begin
    Value:=-Value;
    Minus:=True;
  end;
  D:=Value;
  repeat
    Dec(Dst);
    Dst^:=char((D mod 10) + Byte('0'));
    D:=D div 10;
  until D=0;
  if Minus then
  begin
    Dec(Dst);
    Dst^:='-';
  end;
  Result:=Dst;
end;

function Int2StrEx(Value: int64; MinLength: integer): string;
var
  res: string;
begin
  res:=Int2Str(Value);
  while (Length(res)<MinLength) do
    res:='0'+res;
  result:=res;
end;

function Int2Hex( Value : DWord; Digits : Integer ) : string;
var Buf: array[ 0..8 ] of char;
    Dest : PChar;

    function HexDigit( B : Byte ) : char;
    const
      HexDigitChr: array[ 0..15 ] of char = ( '0','1','2','3','4','5','6','7',
                                                  '8','9','A','B','C','D','E','F' ); // TODO: FP may havn't UnicodeString
    begin
      Result := HexDigitChr[ B and $F ];
    end;
begin
  Dest := @Buf[ 8 ];
  Dest^ := #0;
  repeat
    Dec( Dest );
    Dest^ := '0';
    if Value <> 0 then
    begin
      Dest^ := HexDigit( Value and $F );
      Value := Value shr 4;
    end;
    Dec( Digits );
  until (Value = 0) and (Digits <= 0);
  Result := Dest;
end;

procedure IncInt64( var I64: I64; Delta: Integer );
asm
  ADD  [EAX], EDX
  ADC  dword ptr [EAX+4], 0
end;

procedure DecInt64( var I64: I64; Delta: Integer );
asm
  SUB  [EAX], EDX
  SBB  dword ptr [EDX], 0
end;

function Add64( const X, Y: I64 ): I64;
asm
  PUSH  ESI
  XCHG  ESI, EAX
  LODSD
  ADD   EAX, [EDX]
  MOV   [ECX], EAX
  LODSD
  ADC   EAX, [EDX+4]
  MOV   [ECX+4], EAX
  POP   ESI
end;

function Sub64( const X, Y: I64 ): I64;
asm
  PUSH  ESI
  XCHG  ESI, EAX
  LODSD
  SUB   EAX, [EDX]
  MOV   [ECX], EAX
  LODSD
  SBB   EAX, [EDX+4]
  MOV   [ECX+4], EAX
  POP   ESI
end;

function Neg64( const X: I64 ): I64;
asm
  MOV  ECX, [EAX]
  NEG  ECX
  MOV  [EDX], ECX
  MOV  ECX, 0
  SBB  ECX, [EAX+4]
  MOV  [EDX+4], ECX
end;

//[function Mul64EDX]
function Mul64EDX( const X: I64; M: Integer ): I64;
asm
  PUSH  ESI
  PUSH  EDI
  XCHG  ESI, EAX
  MOV   EDI, ECX
  MOV   ECX, EDX
  LODSD
  MUL   ECX
  STOSD
  XCHG  EDX, ECX
  LODSD
  MUL  EDX
  ADD   EAX, ECX
  STOSD
  POP   EDI
  POP   ESI
end;

function Mul64i( const X: I64; Mul: Integer ): I64;
var Minus: Boolean;
begin
  Minus := FALSE;
  if Mul < 0 then
  begin
    Minus := TRUE;
    Mul := -Mul;
  end;
  Result := Mul64EDX( X, Mul );
  if Minus then
    Result := Neg64( Result );
end;

function Div64EDX( const X: I64; D: Integer ): I64;
asm
  PUSH  ESI
  PUSH  EDI
  XCHG  ESI, EAX
  MOV   EDI, ECX
  MOV   ECX, EDX
  MOV   EAX, [ESI+4]
  CDQ
  DIV  ECX
  MOV   [EDI+4], EAX
  LODSD
  DIV  ECX
  STOSD
  POP   EDI
  POP   ESI
end;

function Div64i( const X: I64; D: Integer ): I64;
var Minus: Boolean;
begin
  Minus := FALSE;
  if D < 0 then
  begin
    D := -D;
    Minus := TRUE;
  end;
  Result := X;
  if Sgn64( Result ) < 0 then
  begin
    Result := Neg64( Result );
    Minus := not Minus;
  end;
  Result := Div64EDX( Result, D );
  if Minus then
    Result := Neg64( Result );
end;

//[function Mod64i]
function Mod64i( const X: I64; D: Integer ): Integer;
begin
  Result := Sub64( X, Mul64i( Div64i( X, D ), D ) ).Lo;
end;

//[function Sgn64]
function Sgn64( const X: I64 ): Integer;
asm
  XOR  EDX, EDX
  CMP  [EAX+4], EDX
  XCHG EAX, EDX
  JG   @@ret_1
  JL   @@ret_neg
  CMP  [EDX], EAX
  JZ   @@exit
@@ret_1:
  INC  EAX
  RET
@@ret_neg:
  DEC  EAX
@@exit:
end;

//[function Cmp64]
function Cmp64( const X, Y: I64 ): Integer;
begin
  Result := Sgn64( Sub64( X, Y ) );
end;

function Int64_2Str( X: I64 ): string;
var M: Boolean;
    Y: Integer;
    Buf: array[ 0..31 ] of char;
    I: Integer;
begin
  M := FALSE;
  case Sgn64( X ) of
  -1: begin M := TRUE; X := Neg64( X ); end;
  0:  begin Result := '0'; Exit; end;
  end;
  I := 31;
  Buf[ 31 ] := #0;
  while Sgn64( X ) > 0 do
  begin
    Dec( I );
    Y := Mod64i( X, 10 );
    Buf[ I ] := char( Y + Integer( '0' ) );
    X := Div64i( X, 10 );
  end;
  if M then
  begin
    Dec( I );
    Buf[ I ] := '-';
  end;
  Result := PChar( @Buf[ I ] );
end;

function IntPower(Base: Extended; Exponent: Integer): Extended;
// This version of code by Galkov:
// Changes in comparison to Delphi standard:
// no Overflow exception if Exponent is very big negative value
// (just 0 in result in such case).
asm
        fld1             { Result := 1 }
        test    eax,eax  // check Exponent for 0, return 0 ** 0 = 1
        jz      @@3      // (though Mathematics says that this is not so...)
        fld     Base
        jg      @@2
        fdivr   ST,ST(1) { Base := 1 / Base }
        neg     eax
        jmp     @@2
@@1:    fmul    ST,ST    { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST { Result := Result * X }
        jnz     @@1
        fstp    st       { pop X from FPU stack }
@@3:    fwait
end;

function Str2Double( const S: string ): Double;
var I: Integer;
    M, Pt: Boolean;
    D: Double;
    Ex: Integer;
begin
  Result := 0.0;
  if S = '' then Exit;
  M := FALSE;
  I := 1;
  if S[ 1 ] = '-' then
  begin
    M := TRUE;
    Inc( I );
  end;
  Pt := FALSE;
  D := 1.0;
  while I <= Length( S ) do
  begin
    case S[ I ] of
    '.': if not Pt then Pt := TRUE else break;
    '0'..'9': if not Pt then
                 Result := Result * 10.0 + Integer( S[ I ] ) - Integer( '0' )
              else
              begin
                D := D * 0.1;
                Result := Result + (Integer( S[ I ] ) - Integer( '0' )) * D;
              end;
    'e', 'E': begin
                Ex := Str2Int( CopyEnd( S, I + 1 ) );
                Result := Result * IntPower( 10.0, Ex );
                break;
              end;
    else break;
    end;
    Inc( I );
  end;
  if M then
    Result := -Result;
end;


function Extended2Str( E: Extended ): string;
    function UnpackFromBuf( const Buf: array of Byte; N: Integer ): string;
    var I, J, K, L: Integer;
    begin
      SetLength( Result, 16 );
      J := 1;
      for I := 7 downto 0 do
      begin
        K := Buf[ I ] shr 4;
        Result[ J ] := char( Ord('0') + K );
        Inc( J );
        K := Buf[ I ] and $F;
        Result[ J ] := char( Ord('0') + K );
        Inc( J );
      end;

      Assert( Result[ 1 ] = '0', 'error!' );
      Delete( Result, 1, 1 );

      if N <= 0 then
      begin
        while N < 0 do
        begin
          Result := '0' + Result;
          Inc( N );
        end;
        Result := '0.' + Result;
      end
        else
      if N < Length( Result ) then
      begin
        Result := Copy( Result, 1, N ) + '.' + CopyEnd( Result, N + 1 );
      end
        else
      begin
        while N > Length( Result ) do
        begin
          Result := Result + '0';
        end;
        Exit;
      end;

      L := Length( Result );
      while L > 1 do
      begin
        if not (CharInSet(Result[ L ], ['0','.'])) then break;
        Dec( L );
        if Result[ L + 1 ] = '.' then break;
      end;
      if L < Length( Result ) then Delete( Result, L + 1, MaxInt );

    end;

var
  S: Boolean;
var F: Extended;
    N: Integer;
    Buf1: array[ 0..9 ] of Byte;
    I10: Integer;
begin
  Result := '0';
  if E = 0 then Exit;
  S := E < 0;
  if S then E := -E;

  N := 15;
  F := 5E12;
  I10 := 10;
  while E < F do
  begin
    Dec( N );
    E := E * I10;
  end;
  if N = 15 then
  while E >= 1E13 do
  begin
    Inc( N );
    E := E / I10;
  end;

  while TRUE do
  begin
    asm
      FLD    [E]
      FBSTP  [Buf1]
    end;
    if Buf1[ 7 ] <> 0 then break;
    E := E * I10;
    Dec( N );
  end;

  Result := UnpackFromBuf( Buf1, N );

  if S then Result := '-' + Result;
end;

function Double2Str( D: Double ): String;
begin
  Result := Extended2Str( D );
end;

function CopyEnd(const S: string; Idx: Integer ): string;
begin
  Result:=Copy(S, Idx, MaxInt);
end;

function StrReplace( var S: string; const From, ReplTo: string ): Boolean;
var I: Integer;
begin
  I := pos( From, S );
  if I > 0 then
  begin
    S := Copy( S, 1, I - 1 ) + ReplTo + CopyEnd( S, I + Length( From ) );
    Result := TRUE;
  end
  else Result := FALSE;
end;

function IndexOfStr(const S, Sub: string; startpos: integer = 1): Integer;
var
  I: Integer;
begin
  Result:=Length(S);
  if Sub='' then
    Exit;
  Result:=0;
  if S='' then
    Exit;
  if Length(Sub)>Length(S) then
    Exit;
  Result:=startpos;
  while (Result+Length(Sub)-1<=Length(S)) do
  begin
    I:=IndexOfChar(CopyEnd(S, Result), Sub[1]);
    if I<=0 then
      break;
    Result:=Result+I-1;
    if Result<=0 then
      Exit;
    if Copy(S, Result, Length(Sub))=Sub then
      Exit;
    Inc(Result);
  end;
  Result:=-1;
end;

function IndexOfChar(const S: string; Chr: char ): Integer;
var
  i, l: integer;
begin
  Result:=-1;
  if S='' then
    Exit;
  l:=Length(S);
  for I:=1 to l do
  begin
      if S[I]=Chr then
      begin
        Result:=I;
        break;
      end;
  end;
end;

function IndexOfCharsMin(const S, Chars: string): Integer;
var
  I, J: Integer;
begin
  Result:=-1;
  for I:=1 to Length(Chars) do
  begin
    J:=IndexOfChar(S, Chars[I]);
    if J>0 then
    begin
      if (Result<=0) or (J<Result) then
        Result:=J;
    end;
  end;
end;

function Parse(var S: string; const Separators: string): string;
var
  Pos: Integer;
begin
  Pos:=IndexOfStr( S, Separators );
  if Pos<=0 then
     Pos:=Length(S)+1;
  Result:=Copy(S, 1, Pos-1);
  Delete(S, 1, Pos+Length(Separators)-1);
end;

function Format( const fmt: string; params: Array of const ): string;
var Buffer: array[ 0..1023 ] of char;
    ElsArray, El: PDWORD;
    I : Integer;
    P : PDWORD;
begin
  ElsArray := nil;
  if High( params ) >= 0 then
    GetMem( ElsArray, (High( params ) + 1) * sizeof( Pointer ) );
  El := ElsArray;
  for I := 0 to High( params ) do
  begin
    P := @params[ I ];
    P := Pointer( P^ );
    El^ := DWORD( P );
    Inc( El );
  end;
  wvsprintf( pChar(@Buffer[0]), pChar( fmt ), Pointer( ElsArray ) );
  Result := Buffer;
  if ElsArray <> nil then
     FreeMem( ElsArray );
end;

procedure DivMod(Dividend: Integer; Divisor: Word; var Result, Remainder: Word);
asm
        PUSH    EBX
        MOV     EBX,EDX
        MOV     EDX,EAX
        SHR     EDX,16
        DIV     BX
        MOV     EBX,Remainder
        MOV     [ECX],AX
        MOV     [EBX],DX
        POP     EBX
end;

function Min(const A, B: Integer ): Integer;
begin
  if A<B then result:=A
    else result:=B;
end;

function GetStartDir : string;
var Buffer:array[0..MAX_PATH] of char;
    I : Integer;
begin
    I := GetModuleFileName( 0, Buffer, MAX_PATH );
    for I := I downto 0 do
      if Buffer[ I ] = {$IFDEF LIN} '/' {$ELSE} '\' {$ENDIF} then
      begin
        Buffer[ I + 1 ] := #0;
        break;
      end;
    Result := Buffer;
end;

function StrLen(const Str: PAnsiChar): Cardinal; assembler;
asm
  {$IFDEF F_P}
        MOV     EAX, [Str]
  {$ENDIF F_P}
        XCHG    EAX, EDI
        XCHG    EDX, EAX
        OR      ECX, -1
        XOR     EAX, EAX
        CMP     EAX, EDI
        JE      @@exit0
        REPNE   SCASB
        DEC     EAX
        DEC     EAX
        SUB     EAX,ECX
@@exit0:
        MOV     EDI,EDX
end {$IFDEF F_P} [ 'EAX', 'EDX', 'ECX' ] {$ENDIF};

function StrPos(const Str1, Str2: PAnsiChar): PAnsiChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        OR      EAX,EAX
        JE      @@2
        OR      EDX,EDX
        JE      @@2
        MOV     EBX,EAX
        MOV     EDI,EDX
        XOR     AL,AL
        MOV     ECX,0FFFFFFFFH
        REPNE   SCASB
        NOT     ECX
        DEC     ECX
        JE      @@2
        MOV     ESI,ECX
        MOV     EDI,EBX
        MOV     ECX,0FFFFFFFFH
        REPNE   SCASB
        NOT     ECX
        SUB     ECX,ESI
        JBE     @@2
        MOV     EDI,EBX
        LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
        LODSB
        REPNE   SCASB
        JNE     @@2
        MOV     EAX,ECX
        PUSH    EDI
        MOV     ECX,EBX
        REPE    CMPSB
        POP     EDI
        MOV     ECX,EAX
        JNE     @@1
        LEA     EAX,[EDI-1]
        JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
        POP     ESI
        POP     EDI
end;

function StrLen(const Str: PWideChar): Cardinal;
asm
  {Check the first byte}
  cmp word ptr [eax], 0
  je @ZeroLength
  {Get the negative of the string start in edx}
  mov edx, eax
  neg edx
@ScanLoop:
  mov cx, [eax]
  add eax, 2
  test cx, cx
  jnz @ScanLoop
  lea eax, [eax + edx - 2]
  shr eax, 1
  ret
@ZeroLength:
  xor eax, eax
end;

function StrCopy(Dest: PChar; const Source: PChar): PChar;
begin
  Move(Source^, Dest^, (StrLen(Source) + 1) * SizeOf(Char));
  Result := Dest;
end;

function IsLeapYear(Year: Integer): Boolean;
begin
  Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));
end;

function DayOfWeek(Date: TDateTime): Integer;
begin
  Result := (Trunc( Date ) + 6) mod 7 + 1;
end;

function DateTime2SystemTime(const DateTime : TDateTime; var SystemTime : TSystemTime ) : Boolean;
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;
var Days : Integer;
    Y, M, D, I: Word;
    MSec : Integer;
    DayTable: PDayTable;
    MinCount, MSecCount: Word;
begin
  FillChar(SystemTime, sizeof(TSystemTime), 0);
  Days := Trunc( DateTime );
  MSec := Round((DateTime - Days) * MSecsPerDay);
  Result := False;
  with SystemTime do
  if Days > 0 then
  begin
    Dec(Days);
    Y := 1;
    while Days >= D400 do
    begin
      Dec(Days, D400);
      Inc(Y, 400);
    end;
    DivMod(Days, D100, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D100);
    end;
    Inc(Y, I * 100);
    DivMod(D, D4, I, D);
    Inc(Y, I * 4);
    DivMod(D, D1, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D1);
    end;
    Inc(Y, I);
    DayTable := @MonthDays[IsLeapYear(Y)];
    M := 1;
    while True do
    begin
      I := DayTable^[M];
      if D < I then Break;
      Dec(D, I);
      Inc(M);
    end;
    wYear := Y;
    wMonth := M;
    wDay := D + 1;
    wDayOfWeek := DayOfWeek( DateTime );
    Result := True;
  end;
  with SystemTime do
  if (MSec>0) then
  begin
    DivMod(MSec, 60000, MinCount, MSecCount);
    DivMod(MinCount, 60, wHour, wMinute);
    DivMod(MSecCount, 1000, wSecond, wMilliSeconds);
    Result := True;
  end;
end;

function SystemDate2Str( const SystemTime : TSystemTime; const LocaleID : DWORD;
                         const DfltDateFormat : TDateFormat;
                         const DateFormat : pChar ) : string;
var Buf : pChar;
    Sz : Integer;
    Flags : DWORD;
begin
   Sz := 100;
   Buf := nil;
   Result := '';
   Flags := 0;
   if DateFormat = nil then
   if DfltDateFormat = dfShortDate then
      Flags := DATE_SHORTDATE
   else
      Flags := DATE_LONGDATE;
   while True do
   begin
      if Buf <> nil then
         FreeMem( Buf );
      GetMem( Buf, Sz * Sizeof( Char ) );
      if Buf = nil then Exit;
      if GetDateFormat( LocaleID, Flags, @SystemTime, DateFormat, Buf, Sz )
         = 0 then
      begin
         if GetLastError = 122 then
            Sz := Sz * 2
         else
            break;
      end
         else
      begin
         Result := Buf;
         break;
      end;
   end;
   if Buf <> nil then
      FreeMem( Buf );
end;

//*
//[function SystemTime2Str]
function SystemTime2Str( const SystemTime : TSystemTime; const LocaleID : DWORD;
                         const Flags : TTimeFormatFlags;
                         const TimeFormat : pChar ) : string;
var Buf : pChar;
    Sz : Integer;
    Flg : DWORD;
begin
   Sz := 100;
   Buf := nil;
   Result := '';
   Flg := 0;
   if tffNoMinutes in Flags then
      Flg := TIME_NOMINUTESORSECONDS
   else
   if tffNoSeconds in Flags then
      Flg := TIME_NOSECONDS;
   if tffNoMarker in Flags then
      Flg := Flg or TIME_NOTIMEMARKER;
   if tffForce24 in Flags then
      Flg := Flg or TIME_FORCE24HOURFORMAT;
   while True do
   begin
      if Buf <> nil then
         FreeMem( Buf );
      GetMem( Buf, Sz * Sizeof( Char ) );
      if Buf = nil then Exit;
      if GetTimeFormat( LocaleID, Flg, @SystemTime, TimeFormat, Buf, Sz )
         = 0 then
      begin
         if GetLastError = 122 then
            Sz := Sz * 2
         else
            break;
      end
         else
      begin
         Result := Buf;
         break;
      end;
   end;
   if Buf <> nil then
      FreeMem( Buf );
end;



function Date2StrFmt( const Fmt: string; D: TDateTime ): string;
var ST: TSystemTime;
    lpFmt: pChar;
begin
  DateTime2SystemTime( D, ST );
  lpFmt := nil;
  if Fmt <> '' then lpFmt := pChar( Fmt );
  Result := SystemDate2Str( ST, LOCALE_USER_DEFAULT, dfShortDate, lpFmt );
end;

function Time2StrFmt( const Fmt: string; D: TDateTime ): string;
var ST: TSystemTime;
    lpFmt: pChar;
begin
  if D < 1 then D := D + 1;
  DateTime2SystemTime( D, ST );
  lpFmt := nil;
  if Fmt <> '' then lpFmt := pChar( Fmt );
  Result := SystemTime2Str( ST, LOCALE_USER_DEFAULT, [], lpFmt );
end;

function StrIsStartingFrom( Str, Pattern: PChar ): Boolean;
asm
        XOR     ECX, ECX
      @@1:
        MOV     CL, [EDX]   // pattern[ i ]
        INC     EDX
        MOV     CH, [EAX]   // str[ i ]
        INC     EAX
        JECXZ   @@2         // str = pattern; CL = #0, CH = #0
        CMP     CL, CH
        JE      @@1
      @@2:
        TEST    CL, CL
        SETZ    AL
end;

function Str2DateTimeFmt( const sFmtStr, sS: string ): TDateTime;
var h12, hAM: Boolean;
    FmtStr, S: PChar;

  function GetNum( var S: PChar; NChars: Integer ): Integer;
  begin
    Result := 0;
    while (S^ <> #0) and (NChars <> 0) do
    begin
      Dec( NChars );
      {$IFDEF UNICODE_CTRLS}
      if (S^ >= '0') and (S^ <= '9') then
      {$ELSE}
      if CharInSet(S^, ['0'..'9']) then
      {$ENDIF}
      begin
        Result := Result * 10 + Ord(S^) - Ord('0');
        Inc( S );
      end
      else
        break;
    end;
  end;

  function GetYear( var S: PChar; NChars: Integer ): Integer;
  var STNow: TSystemTime;
      OldDate: Boolean;
  begin
    Result := GetNum( S, NChars );
    GetSystemTime( STNow );
    OldDate := Result < 50;
    Result := Result + STNow.wYear - STNow.wYear mod 100;
    if OldDate then Dec( Result, 100 );
  end;

  function GetMonth( const fmt: String; var S: PChar ): Integer;
  var SD: TSystemTime;
      M: Integer;
      C, MonthStr: String;
  begin
    GetSystemTime( SD );
    for M := 1 to 12 do
    begin
      SD.wMonth := M;
      C := SystemDate2Str( SD, LOCALE_USER_DEFAULT, dfLongDate, PChar( fmt + '/dd/yyyy/' ) );
      MonthStr := Parse( C, '/' );
      if CompareStr_NoCase( MonthStr, Copy( S, 1, Length( MonthStr ) ) ) = 0 then
      begin
        Result := M;
        Inc( S, Length( MonthStr ) );
        Exit;
      end;
    end;
    Result := 1;
  end;

  procedure SkipDayOfWeek( const fmt: String; var S: pChar );
  var SD: TSystemTime;
      Dt: TDateTime;
      D: Integer;
      C, DayWeekStr: String;
  begin
    GetSystemTime( SD );
    SystemTime2DateTime( SD, Dt );
    Dt := Dt - SD.wDayOfWeek;
    for D := 0 to 6 do
    begin
      DateTime2SystemTime( Dt, SD );
      C := SystemDate2Str( SD, LOCALE_USER_DEFAULT, dfLongDate, PChar( fmt + '/MM/yyyy/' ) );
      DayWeekStr := Parse( C, '/' );
      if CompareStr_NoCase( DayWeekStr, Copy( S, 1, Length( DayWeekStr ) ) ) = 0 then
      begin
        Inc( S, Length( DayWeekStr ) );
        Exit;
      end;
      Dt := Dt + 1.0;
    end;
  end;

  procedure GetTimeMark( const fmt: String; var S: PChar );
  var SD: TSystemTime;
      AM: Boolean;
      C, TimeMarkStr: String;
  begin
    GetSystemTime( SD );
    SD.wHour := 0;
    for AM := FALSE to TRUE do
    begin
      C := SystemDate2Str( SD, LOCALE_USER_DEFAULT, dfLongDate, PChar( fmt + '/HH/mm' ) );
      TimeMarkStr := Parse( C, '/' );
      if CompareStr_NoCase( TimeMarkStr, Copy( S, 1, Length( TimeMarkStr ) ) ) = 0 then
      begin
        Inc( S, Length( TimeMarkStr ) );
        hAM := AM;
        Exit;
      end;
      SD.wHour := 13;
    end;
    Result := 1;
  end;

  function FmtIs1( S: PChar ): Boolean;
  begin
    if StrIsStartingFrom( FmtStr, S ) then
    begin
      Inc( FmtStr, StrLen ( S ) );
      Result := TRUE;
    end
      else
      Result := FALSE;
  end;

  function FmtIs( S1, S2: PChar ): Boolean;
  begin
    Result := FmtIs1( S1 ) or FmtIs1( S2 );
  end;

var ST: TSystemTime;
begin
  FmtStr := PChar( sFmtStr);
  S := PChar( sS );
  FillChar( ST, Sizeof( ST ), #0 );
  h12 := FALSE;
  hAM := FALSE;
  while (FmtStr^ <> #0) and (S^ <> #0) do
  begin
    {$IFDEF UNICODE_CTRLS}
    if ((FmtStr^ >= 'a') and (FmtStr^ <= 'z') or
       (FmtStr^ >= 'A') and (FmtStr^ <= 'Z')) and
       (S^ >= '0') and (S^ <= '9') then
    {$ELSE}
    if CharInSet(FmtStr^, ['a'..'z','A'..'Z']) and CharInSet(S^, ['0'..'9']) then
    {$ENDIF}
    begin
      if      FmtIs1( 'yyyy'   ) then ST.wYear := GetNum( S, 4 )
      else if FmtIs1( 'yy' )     then ST.wYear := GetYear( S, 2 )
      else if FmtIs1( 'y' )      then ST.wYear := GetYear( S, -1 )
      else if FmtIs( 'dd', 'd' ) then ST.wDay := GetNum( S, 2 )
      else if FmtIs( 'MM', 'M' ) then ST.wMonth := GetNum( S, 2 )
      else if FmtIs( 'HH', 'H' ) then ST.wHour := GetNum( S, 2 )
      else if FmtIs( 'hh', 'h' ) then begin ST.wHour := GetNum( S, 2 ); h12 := TRUE end
      else if FmtIs( 'mm', 'm' ) then ST.wMinute := GetNum( S, 2 )
      else if FmtIs( 'ss', 's' ) then ST.wSecond := GetNum( S, 2 )
      else break; // + ECM
    end
      else
    {$IFDEF UNICODE_CTRLS}
    if (FmtStr^ = 'M') or (FmtStr^ = 'd') or (FmtStr^ = 'g') then
    {$ELSE}
    if CharInSet(FmtStr^, [ 'M', 'd', 'g' ]) then
    {$ENDIF}
    begin
      if      FmtIs1( 'MMMM' ) then ST.wMonth := GetMonth( 'MMMM', S )
      else if FmtIs1( 'MMM'  ) then ST.wMonth := GetMonth( 'MMM', S )
      else if FmtIs1( 'dddd' ) then SkipDayOfWeek( 'dddd', S )
      else if FmtIs1( 'ddd'  ) then SkipDayOfWeek( 'ddd', S )
      else if FmtIs1( 'tt'   ) then GetTimeMark( 'tt', S )
      else if FmtIs1( 't'    ) then GetTimeMark( 't', S )
      else break; // + ECM
    end
      else
    begin
      if FmtStr^ = S^ then
        Inc( FmtStr );
      Inc( S );
    end;
  end;

  if h12 then
  if hAM then
    Inc( ST.wHour, 12 );

  SystemTime2DateTime( ST, Result );
end;


var FmtBuf: PChar;
    DateSeparator : Char = #0; // + ECM

function Str2DateTimeShort( const S: string ): TDateTime;
var FmtStr, FmtStr2: string;

  function EnumDateFmt( lpstrFmt: PChar ): Boolean; stdcall;
  begin
    GetMem(FmtBuf, (StrLen(lpstrFmt)+1) * Sizeof(Char));
    StrCopy(FmtBuf, lpstrFmt);
    Result := FALSE;
  end;

begin
  FmtStr := 'dd.MM.yyyy';
  FmtBuf := nil;
  EnumDateFormats( @ EnumDateFmt, LOCALE_USER_DEFAULT, DATE_SHORTDATE );
  if FmtBuf <> nil then
  begin
    FmtStr := FmtBuf;
    FreeMem( FmtBuf );
  end;

  FmtStr2 := 'H:mm:ss';
  FmtBuf := nil;
  EnumTimeFormats( @ EnumDateFmt, LOCALE_USER_DEFAULT, 0 );
  if FmtBuf <> nil then
  begin
    FmtStr2 := FmtBuf;
    FreeMem( FmtBuf );
  end;

  Result := Str2DateTimeFmt( FmtStr + ' ' + FmtStr2, S );
end;

function SystemTime2DateTime(const SystemTime : TSystemTime; var DateTime : TDateTime ) : Boolean;
var I : Integer;
    _Day : Integer;
    DayTable: PDayTable;
begin
  Result := False;
  DateTime := 0.0;
  DayTable := @MonthDays[IsLeapYear(SystemTime.wYear)];
  with SystemTime do
  if {(wYear >= 0) !always true! and} (wYear <= 9999) and
    {(wMonth >= 1) and !otherwise can not convert time only!}
    (wMonth <= 12) and
    {(wDay >= 1) and !otherwise can not convert time only!}
    (wDay <= DayTable^[wMonth]) and                                      //
    (wHour < 24) and (wMinute < 60) and (wSecond < 60) and (wMilliSeconds < 1000) then   //
  begin
    _Day := wDay;
    for I := 1 to wMonth - 1 do
        Inc(_Day, DayTable^[I]);
    I := wYear - 1;
    //--------------- by Vadim Petrov ------++
    if I<0 then i := 0;                     //
    //--------------------------------------++
    DateTime := I * 365 + I div 4 - I div 100 + I div 400 + _Day
             + (wHour * 3600000 + wMinute * 60000 + wSecond * 1000 + wMilliSeconds) / MSecsPerDay;
    Result := True;
  end;
end;

function FileTime2DateTime( const ft: TFileTime; var DT: TDateTime ): Boolean;
var ft1: TFileTime;
    st: TSystemTime;
begin
  Result := FileTimeToLocalFileTime( ft, ft1 ) and
            FileTimeToSystemTime( ft1, st ) and
            SystemTime2DateTime( st, dt );
end;

function DateTime2StrShort( D: TDateTime ): String;
var ST: TSystemTime;
begin
  //--------- by Vadim Petrov --------++
  if D < 1 then D := D + 1;           //
  //----------------------------------++
  DateTime2SystemTime( D, ST );
  Result := SystemDate2Str( ST, LOCALE_USER_DEFAULT {GetUserDefaultLCID}, dfShortDate, nil ) + ' ' +
            SystemTime2Str( ST, LOCALE_USER_DEFAULT {GetUserDefaultLCID}, [], nil );
end;

procedure GetLocalTime(var lpSystemTime: TSystemTime); stdcall; external kernel32 name 'GetLocalTime';

function Now : TDateTime;
var SystemTime : TSystemTime;
begin
   GetLocalTime( SystemTime );
   SystemTime2DateTime( SystemTime, Result );
end;

end.
