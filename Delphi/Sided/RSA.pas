unit RSA;

interface

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils, SHA, nx_z, nx_strs;

type
  TRSAKey = packed record
    n,
    e,
    d: PBigInt;
  end;

var
  MainKeySign,
  NetWorkKey,
  NetWorkKeySign: TRSAKey;

procedure SetNetworkKey(Key: pByte);

// returned (FFSize+38) bytes
function RSASign(Key: TRSAKey; Mess: pByte; Size: uint32; SignSize: uint32): pByte;
// 128 bytes
function RSASignMessage(Key: TRSAKey; Mess: pByte; Size: uint32): pByte; inline;
// 256 bytes
function RSASignMessage1024(Key: TRSAKey; Mess: pByte; Size: uint32): pByte; inline;
function RSASignFile(Key: TRSAKey; FileName: string; AddExt: string = '_rsa_signature'): pByte;
// !!!!
function RSACheckSign(Key: TRSAKey; Sign: pByte; Mess: pByte; Size: uint32; SignSize: uint32 = 128): boolean;

function RSAEncrypt(Key: TRSAKey; Data: pByte; Size: uint32; IsAlignment: boolean = false): pByte;
function RSADecrypt(Key: TRSAKey; Data: pByte; Size: uint32; IsAlignment: boolean = false): pByte;

function GetNetWorkKey(): pByte;

implementation

procedure SetNetworkKey(Key: pByte);
var
  i: integer;
  s: AnsiString;
begin
  IFree(NetWorkKey.n);
  INew(NetWorkKey.n);
  s:='16#';
  for i:=1 to 128 do
    s:=s+Wide2Ansi(Int2Hex(Key[i-1], 2));
  ISetStr(NetWorkKey.n, AnsiString(s+'#'));
  s:='';
end;

// RSA
{$REGION}
function RSASign(Key: TRSAKey; Mess: pByte; Size: uint32; SignSize: uint32): pByte;
var
  SHA: TSHA1;
  RSA_SIGN_DATA: array of byte;
begin
  SetLength(RSA_SIGN_DATA, SignSize);
  RSA_SIGN_DATA[0]:=$00;
  RSA_SIGN_DATA[1]:=$01;
  FillChar(RSA_SIGN_DATA[2], SignSize-38, $ff);
  Move(AnsiString(#$00#$30#$21#$30#$09#$06#$05#$2b#$0e#$03#$02#$1a#$05#$00#$04#$14), RSA_SIGN_DATA[SignSize-36], $10);

  SHA:=TSHA1.Create();
  SHA.AddBytes(Mess, Size);
  Move(SHA.GetDigest()^, RSA_SIGN_DATA[SignSize-20], $14);
  SHA.Free;

  result:=RSAEncrypt(Key, @RSA_SIGN_DATA[0], SignSize);
  SetLength(RSA_SIGN_DATA, 0);
end;

function RSASignMessage(Key: TRSAKey; Mess: pByte; Size: uint32): pByte;
begin
  result:=RSASign(Key, Mess, Size, 128);
end;

function RSASignMessage1024(Key: TRSAKey; Mess: pByte; Size: uint32): pByte;
begin
  result:=RSASign(Key, Mess, Size, 256);
end;

function RSASignFile(Key: TRSAKey; FileName: string; AddExt: string = '_rsa_signature'): pByte;
var
  str: TStream;
  sz: uint32;
  data: pByte;
begin
  result:=nil;
  str:=TStream.CreateReadFileStream(FileName);
  if str.Handle=INVALID_HANDLE_VALUE then
    Exit;
  sz:=str.Size;
  GetMem(data, sz);
  str.Read(data^, sz);
  str.Free;
  result:=RSASignMessage(Key, data, sz);
  FreeMem(data, sz);

  str:=TStream.CreateWriteFileStream(FileName+AddExt);
  str.Write(result^, 128);
  str.Free;
end;

function RSACheckSign(Key: TRSAKey; Sign: pByte; Mess: pByte; Size: uint32; SignSize: uint32 = 128): boolean;
var
  sgn: pByte;
  SHA: TSHA1;
  RSA_SIGN_DATA: array of byte;
begin
  {result:=true;
  sgn:=RSASignMessage1024(Key, Mess, Size);
  if memcmp(sign, sgn, SignSize)<>0 then
    result:=false;
  FreeMem(sgn, Size);  }

  result:=false;
  sgn:=RSADecrypt(Key, Sign, SignSize, true);
  if (sgn[0]<>0) and (sgn[1]<>1) then
    Exit;

  SetLength(RSA_SIGN_DATA, SignSize);
  RSA_SIGN_DATA[0]:=$00;
  RSA_SIGN_DATA[1]:=$01;
  FillChar(RSA_SIGN_DATA[2], SignSize-38, $ff);
  Move(AnsiString(#$00#$30#$21#$30#$09#$06#$05#$2b#$0e#$03#$02#$1a#$05#$00#$04#$14), RSA_SIGN_DATA[SignSize-36], $10);
  SHA:=TSHA1.Create();
  SHA.AddBytes(Mess, Size);
  Move(SHA.GetDigest()^, RSA_SIGN_DATA[SignSize-20], $14);
  SHA.Free;

  result:=(memcmp(@RSA_SIGN_DATA[0], sgn, SignSize)=0);

  FreeMem(sgn, SignSize);
end;

function RSAEncrypt(Key: TRSAKey; Data: pByte; Size: uint32; IsAlignment: boolean = false): pByte;
var
  res: PBigInt;
  i: integer;
  s: AnsiString;
begin
  res:=nil;
  INew(res);
  // convert to HEX-string
  s:='16#';
  SetLength(s, Size*2+4);
  for i:=1 to Size do
    Move(Wide2Ansi(Int2Hex(Data[i-1], 2))[1], s[i*2+2], 2);
  s[Size*2+4]:='#';
  ISetStr(res, s);
  IPowMod(res, Key.e, Key.n, dtMontgomery);
  s:=IStr(res, 16, 0, [sfoNoSign]);

  Delete(s, 1, 3);
  Delete(s, Length(s), 1);
  if IsAlignment then
    while (Length(s)<integer(Size*2)) do
      s:='0'+s;

  Size:=Length(s) div 2;
  GetMem(result, Size);
  for i:=0 to Size-1 do
    result[i]:=Hex2Int(Ansi2Wide(s[i*2+1]+s[i*2+2]));
  SetLength(s, 0);
  IFree(res);
end;

function RSADecrypt(Key: TRSAKey; Data: pByte; Size: uint32; IsAlignment: boolean = false): pByte;
var
  res: PBigInt;
  i: integer;
  s: AnsiString;
begin
  res:=nil;
  INew(res);
  // convert to HEX-string
  s:='16#';
  for i:=1 to Size do
    s:=s+Wide2Ansi(Int2Hex(Data[i-1], 2));
  ISetStr(res, AnsiString(s+'#'));
  IPowMod(res, Key.d, Key.n, dtMontgomery);
  s:=IStr(res, 16, 0, [sfoNoSign, sfoLeftPadded]);

  Delete(s, 1, 3);
  Delete(s, Length(s), 1);
  if IsAlignment then
    while (Length(s)<integer(Size*2)) do
      s:='0'+s;

  Size:=Length(s) div 2;
  GetMem(result, Size);
  for i:=0 to Size-1 do
    result[i]:=Hex2Int(Ansi2Wide(s[i*2+1]+s[i*2+2]));
  SetLength(s, 0);
  IFree(res);
end;
{$ENDREGION}

function GetNetWorkKey(): pByte;
var
  Size, i: integer;
  s: AnsiString;
begin
  s:=IStr(NetWorkKey.n, 16, 0, [sfoNoSign]);

  Delete(s, 1, 3);
  Delete(s, Length(s), 1);

  Size:=Length(s) div 2;
  GetMem(result, Size);
  for i:=0 to Size-1 do
    result[i]:=Hex2Int(Ansi2Wide(s[i*2+1]+s[i*2+2]));
  SetLength(s, 0);
end;



initialization
  INew(MainKeySign.n);
  INew(MainKeySign.e);
  INew(MainKeySign.d);
  ISetStr(MainKeySign.n, AnsiString({$I RSA_MK_n.inc}));
  ISetStr(MainKeySign.e, AnsiString({$I RSA_MK_e.inc}));
  ISetStr(MainKeySign.d, AnsiString('16#11#'));
  INew(NetWorkKey.n);
  INew(NetWorkKey.e);
  INew(NetWorkKey.d);
  ISetStr(NetWorkKey.n, AnsiString({$I RSA_NK_n.inc}));
  ISetStr(NetWorkKey.e, AnsiString('16#11#'));
  ISetStr(NetWorkKey.d, AnsiString({$I RSA_NK_d.inc}));
  INew(NetWorkKeySign.n);
  INew(NetWorkKeySign.e);
  INew(NetWorkKeySign.d);
  ISetStr(NetWorkKeySign.n, AnsiString({$I RSA_NK_n.inc}));
  ISetStr(NetWorkKeySign.e, AnsiString({$I RSA_NK_d.inc}));
  ISetStr(NetWorkKeySign.d, AnsiString('16#11#'));
  //Writeln('RSA key''s initialized.');

finalization
  IFree(MainKeySign.n);
  IFree(MainKeySign.e);
  IFree(MainKeySign.d);
  IFree(NetWorkKey.n);
  IFree(NetWorkKey.e);
  IFree(NetWorkKey.d);
  IFree(NetWorkKeySign.n);
  IFree(NetWorkKeySign.e);
  IFree(NetWorkKeySign.d);

end.
