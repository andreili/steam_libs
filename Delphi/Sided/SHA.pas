unit SHA;

interface

uses
  Windows, WinSock,
    USE_Types;

type
  TSHA1 = class
    private
      H0, H1, H2, H3, H4: ulong;
      bytes: array[0..63] of byte;
      unprocessedBytes: integer;
      size: ulong;
      digest: array[0..4] of uint32;
      procedure Process;
    public
      constructor Create();
      destructor Destroy; override;

      procedure AddBytes(data: pByte; num: integer);
      function HashFile(FileName: string): pByte;
      function GetDigest: pByte;
    end;

implementation

constructor TSHA1.Create();
begin
  inherited Create();
  H0:=$67452301;
  H1:=$efcdab89;
  H2:=$98badcfe;
  H3:=$10325476;
  H4:=$c3d2e1f0;
  unprocessedBytes:=0;
  size:=0;
end;

function memcpy(dst: Pointer; const src: Pointer; len: integer): Pointer; inline;
begin
  Move(src^, dst^, len);
  Result := dst;
end;

function LRot(X: dword; c: integer): dword; inline;
begin
  result:=(X shl c) or (x shr (32-c));
end;
{asm
  mov ecx, edx
  rol eax, cl
end;   }

procedure storeBigEndianUint32(b: pByte; num: uint32);
begin
  b[0]:=byte(num shr 24);
  b[1]:=byte(num shr 16);
  b[2]:=byte(num shr 8);
  b[3]:=byte(num);
end;

procedure TSHA1.process;
var
  t, temp: integer;
  a, b, c, d, e, K, f: ulong;
  W: array[0..79] of ulong;
begin
  a:=H0;
  b:=H1;
  c:=H2;
  d:=H3;
  e:=H4;
  for t:=0 to 15 do
    W[t]:=(bytes[t*4] shl 24)+(bytes[t*4 + 1] shl 16)+(bytes[t*4 + 2] shl 8)+ bytes[t*4 + 3];
  t:=15;
  for t:=t to 79 do
    W[t]:=lrot(W[t-3] xor W[t-8] xor W[t-14] xor W[t-16], 1);
  for t:=0 to 79 do
  begin
    if t<20 then
    begin
      k:=$5a827999;
      f:=(b and c) or ((b xor $FFFFFFFF) and d);
    end
      else if t<40 then
    begin
      k:=$6ed9eba1;
      f:=b xor c xor d;
    end
      else if t<60 then
    begin
      k:=$8f1bbcdc;
      f:=(b and c) or (b and d) or (c and d);
    end
      else
    begin
      k:=$ca62c1d6;
      f:=b xor c xor d;
    end;
    temp:=lrot(a, 5) + f + e + W[t] + K;
    e:=d;
    d:=c;
    c:=lrot(b, 30);
    b:=a;
    a:=temp;
  end;
  inc(H0, a);
  inc(H1, b);
  inc(H2, c);
  inc(H3, d);
  inc(H4, e);
  unprocessedBytes:=0;
end;

function TSHA1.HashFile(FileName: string): pByte;
var
  Stream: TStream;
  Data: pByte;
begin
  result:=nil;
  Stream:=TStream.CreateReadFileStream(FileName);
  if Stream.Handle=INVALID_HANDLE_VALUE then
    Exit;
  GetMem(Data, Stream.Size);
  Stream.Read(Data^, Stream.Size);
  Self.AddBytes(Data, Stream.Size);
  Stream.Free;
  FreeMem(Data);  
  result:=Self.GetDigest;
end;

procedure TSHA1.AddBytes(Data: pByte; Num: integer);
var
  needed, toCopy: integer;
begin
  inc(size, num);
  while num>0 do
  begin
    needed:=64-unprocessedBytes;
    if Num<Needed then toCopy:=Num
      else toCopy:=Needed;
    memcpy(@bytes[unprocessedBytes], data, toCopy);
    dec(Num, toCopy);
    inc(Data, toCopy);
    inc(unprocessedBytes, toCopy);
    if unprocessedBytes=64 then
      process;
  end;
end;

var
  footer: array[0..63] of byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

function TSHA1.GetDigest: pByte;
var
  totalBitsL, totalBitsH: ulong;
  neededZeros: integer;
  b: byte;
begin
  FillChar(footer[0], length(footer), 0);
  // save the message size
  totalBitsL:=size shl 3;
  totalBitsH:=size shr 29;
  // add 0x80 to the message
  b:=$80;
  addBytes(@b, 1);
  // block has no room for 8-byte filesize, so finish it
  if unprocessedBytes>56 then
    addBytes(@footer[0], 64-unprocessedBytes);
  // how many zeros do we need
  neededZeros:=56-unprocessedBytes;
  // store file size (in bits) in big-endian format
  storeBigEndianUint32(@footer[neededZeros], totalBitsH);
  storeBigEndianUint32(@footer[neededZeros+4], totalBitsL);
  // finish the final block
  addBytes(@footer[0], neededZeros+8);
  // allocate memory for the digest bytes
  // copy the digest bytes
  storeBigEndianUint32(@digest[0], H0);
  storeBigEndianUint32(@digest[1], H1);
  storeBigEndianUint32(@digest[2], H2);
  storeBigEndianUint32(@digest[3], H3);
  storeBigEndianUint32(@digest[4], H4);
  result:=@digest[0];
end;

destructor TSHA1.Destroy;
begin
  inherited Destroy();
end;


end.
