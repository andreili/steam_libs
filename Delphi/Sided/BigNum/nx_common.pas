////////////////////////////////////////////////////////////////////////////////
// Common Stuff
// This file is part of the NX - Numerics library.
// Copyright (c) 2009, Marcel Martin. All rights reserved.
//------------------------------------------------------------------------------
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option) any
// later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see http://www.gnu.org/licenses/
//------------------------------------------------------------------------------
// NX v0.32.2 (alpha)
// The latest release of NX can be found at http://www.ellipsa.eu/
////////////////////////////////////////////////////////////////////////////////
unit nx_common;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
uses
{$IFDEF DELPHI}
  Windows,
{$ENDIF}
  USE_Types,
  USE_Utils,
  nx_types;
////////////////////////////////////////////////////////////////////////////////

const
  //-- End Of Line
{$IFDEF FREE_PASCAL}
  gcEOL = LineEnding;
{$ENDIF}
{$IFDEF DELPHI}
  gcEOL = #13#10;
{$ENDIF}

  //-- list constants
  gcMaxListCount = $ffff;
  // gcMinListInc is the minimal capacity increment of a NX list, it should
  // be a power of 2
  gcMinListInc = SInt32(16);

  //-- gcMask32[i] = 2**(i+1) - 1
  gcMask32: array [0..31] of UInt32 = (
  $00000001, $00000003, $00000007, $0000000f, $0000001f, $0000003f, $0000007f,
  $000000ff, $000001ff, $000003ff, $000007ff, $00000fff, $00001fff, $00003fff,
  $00007fff, $0000ffff, $0001ffff, $0003ffff, $0007ffff, $000fffff, $001fffff,
  $003fffff, $007fffff, $00ffffff, $01ffffff, $03ffffff, $07ffffff, $0fffffff,
  $1fffffff, $3fffffff, $7fffffff, $ffffffff);

  //-- gcPowOf2[i] = 2**i
  gcPowOf2: array [0..31] of UInt32 = (
  $00000001, $00000002, $00000004, $00000008, $00000010, $00000020, $00000040,
  $00000080, $00000100, $00000200, $00000400, $00000800, $00001000, $00002000,
  $00004000, $00008000, $00010000, $00020000, $00040000, $00080000, $00100000,
  $00200000, $00400000, $00800000, $01000000, $02000000, $04000000, $08000000,
  $10000000, $20000000, $40000000, $80000000);

  //-- nibble values
  gcUI4BitCount: array [0..15] of SInt32 = (0,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4);
  gcUI4Parity: array [0..15] of UInt8 = (0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0);
  gcUI4Valuation: array [0..15] of SInt32 = (4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0);

  //-- threshold constants in 32-bit words (might depend on the processor used)
  gcKarSqrThreshold = SInt32(24); // Karatsuba square threshold
  gcTm3SqrThreshold = SInt32(256); // Toom-3 square threshold
  gcKarMulThreshold = SInt32(24); // Karatsuba multiplication threshold
  gcTm3MulThreshold = SInt32(196); // Toom-3 multiplication threshold
  gcPowModBEvenRecThreshold = SInt32(168); // PowMod recip. threshold (B even)
  gcPowModMonThreshold = SInt32(2); // PowMod Montgomery threshold
  gcPowModRecThreshold = SInt32(576); // PowMod reciprocal threshold

  //-- miscellaneous
  gcHexaFigures : array [0..15] of AnsiChar = '0123456789ABCDEF';
  gcWindowMaxSize = 128; // see, below, NXGetWindowSize

  //-- to swap basis types (for Galois fields)
  gcSwapBasisType : array [TGFBasisType] of TGFBasisType = (
    btNormal,btPolynomial);


function  NXEstimateDecimalSize(BitSize: SInt32): SInt32;
function  NXFmtStr(const S: AnsiString; const P: array of const): AnsiString;
function  NXGetRealData(out Data: TRealData; const X: Real): Boolean;
procedure NXGetWindowIndices(out i,j: SInt32; e: SInt32);
function  NXGetWindowSize(BitCount,Weight: SInt32): SInt32;

{$IFDEF NX_THREAD_SAFE}
//
// TNXStackBook instances are used by (the implementation parts of) the units
// - nx_z
// - nx_q
// - nx_r
// - nx_c
// - nx_gf2
// - nx_gf3
// only when the NX_THREAD_SAFE symbol is defined.
//
type
{$IFDEF HAS_SEALED_CLASS}
  TNXStackBook = class sealed (TNXClass)
{$ELSE}
  TNXStackBook = class (TNXClass)
{$ENDIF}
  private
    FLocker: TRTLCriticalSection;
    FCount: SInt32;
    FTID: array of TThreadID;

  public
    constructor Create;
    destructor  Destroy; override;

    function RegisterStack(ThreadID: TThreadID): Boolean;
    function UnregisterStack(ThreadID: TThreadID): Boolean;

    property Count: SInt32 read FCount;
  end;

{$ENDIF} // NX_THREAD_SAFE


////////////////////////////////////////////////////////////////////////////////
implementation
uses nx_errors;
////////////////////////////////////////////////////////////////////////////////

//-- the two following directives should not be modified
{$Q-}
{$R-}

////////////////////////////////////////////////////////////////////////////////
// PUBLIC
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Return an estimate of the decimal size of a Bitsize-bit number.
// If d is the decimal size, the estimate e is either e = d or e = d+1
//==============================================================================
function NXEstimateDecimalSize(BitSize: SInt32): SInt32;
begin
  if BitSize > 0 then Result := SInt32(Round(0.5 + ((Ln(2)/Ln(10)) * BitSize)))
  else
  if BitSize = 0 then Result := 0
  else Result := -1;
end;

//==============================================================================
// Same as SysUtils.FmtStr but function instead of procedure and AnsiString
// instead of string
//==============================================================================
function NXFmtStr(const S: AnsiString; const P: array of const): AnsiString;
begin
  Result := ''; // to avoid compiler warnings
  result:=Wide2Ansi(Format(Ansi2Wide(S), P));
end;

//==============================================================================
// Split X and set the values of Data (when Result = TRUE)
// Return TRUE iff X is neither a NaN or +/-Infinite
//==============================================================================
function NXGetRealData(out Data: TRealData; const X: Real): Boolean;
begin
  with Data, UInt32x2(Significand) do
  begin
{$IFDEF FREE_PASCAL}
{$IFDEF FPC_HAS_TYPE_DOUBLE}
    Exponent := SInt32((UInt32x2(X).Hi shr 20) and $7ff);
    if Exponent = $7ff then Result := false // NaN or +/-INF
    else
    begin
      Hi := UInt32x2(X).Hi and $fffff;
      Lo := UInt32x2(X).Lo;
      if Exponent = 0 then
        if Significand = 0 then SignFlag := 0 // zero
        else SignFlag := UInt32x2(X).Hi shr 31 // subnormal
      else
      begin
        Hi := Hi or $100000; // add implicit leading 1
        Dec(Exponent,1023+52); // exponent bias + significand bit size
        SignFlag := UInt32x2(X).Hi shr 31;
      end;
      Result := true;
    end;
{$ELSE} // FPC_HAS_TYPE_DOUBLE
{$IFDEF FPC_HAS_TYPE_SINGLE}
    Exponent := SInt32((UInt32(X) shr 23) and $ff);
    if Exponent = $ff then Result := false // NaN or +/-INF
    else
    begin
      Hi := 0;
      Lo := UInt32(X) and $7fffff;
      if Exponent = 0 then
        if Lo = 0 then SignFlag := 0 // zero
        else SignFlag := UInt32(X) shr 31 // subnormal
      else
      begin
        Lo := Lo or $800000; // add implicit leading 1
        Dec(Exponent,127+23); // exponent bias + significand bit size
        SignFlag := UInt32(X) shr 31;
      end;
      Result := true;
    end;
{$ELSE}
  {$MESSAGE FATAL Type Real should be defined as Single or as Double}
{$ENDIF} // FPC_HAS_TYPE_SINGLE
{$ENDIF} // FPC_HAS_TYPE_DOUBLE
{$ENDIF} // FREE_PASCAL

{$IFDEF DELPHI} // Real = Double
    Exponent := SInt32((UInt32x2(X).Hi shr 20) and $7ff);
    if Exponent = $7ff then Result := false // NaN or +/-INF
    else
    begin
      Hi := UInt32x2(X).Hi and $fffff;
      Lo := UInt32x2(X).Lo;
      if Exponent = 0 then
        if Significand = 0 then SignFlag := 0 // zero
        else SignFlag := UInt32x2(X).Hi shr 31 // subnormal
      else
      begin
        Hi := Hi or $100000; // add implicit leading 1
        Dec(Exponent,1023+52); // exponent bias + significand bit size
        SignFlag := UInt32x2(X).Hi shr 31;
      end;
      Result := true;
    end;
{$ENDIF} // DELPHI
  end;
end;

//==============================================================================
// Window parameters for exponentiations
// -> e, exponent part
// <- (i,j) such that e = 2**i * (2*j + 1)
//==============================================================================
procedure NXGetWindowIndices(out i,j: SInt32; e: SInt32);
begin
  if e <= 0 then NXRaiseInvalidArg('NXGetWindowIndices',ese_lt_1);

  i := 0;
  while (e and 1) = 0 do // ok, e > 0
  begin
    e := e shr 1;
    Inc(i);
  end;
  j := (e-1) shr 1;
end;

//==============================================================================
// Window size for exponentiations
// -> BitCount, binary size of the exponent
// -> Weight, bit-weight of the exponent, i.e., number+1 of multiplications to
//    do with a binary method (should be set to 0 whenever this value is
//    unknown)
// <- Result, in [1..8] (window size in bits)
//    ! When the returned value is equal to 1, the window method shouldn't be
//    used, it is not better than the binary method.
//==============================================================================
function NXGetWindowSize(BitCount,Weight: SInt32): SInt32;
begin
  if BitCount <= 0 then NXRaiseInvalidArg('NXGetWindowSize',esBitCount_lt_1);

  case BitCount of
    1..8: Result := 1;
    9..24: Result := 2;
    25..69: Result := 3;
    70..196: Result := 4;
    197..538: Result := 5;
    539..1433: Result := 6;
    1434..3714: Result := 7;
    else
    Result := 8;
  end;

  //-- should use the window method or not?
  //   Weight-1 = number of multiplications to do without the window method.
  //   2**(Result-1)-1+(BitCount+Result-1)/Result = number of multiplications
  //   to do with the window method.
  if (Result > 1) and (Weight > 0) then
    if Weight <= ((1 shl (Result-1)) + (BitCount+Result-1) div Result) then
      Result := 1; // means 'do not use the window method'
end;

////////////////////////////////////////////////////////////////////////////////
// TNXStackBook class
////////////////////////////////////////////////////////////////////////////////

{$IFDEF NX_THREAD_SAFE}

//==============================================================================
//==============================================================================
constructor TNXStackBook.Create;
begin
  inherited;

{$IFDEF DELPHI}
  InitializeCriticalSection(FLocker);
{$ENDIF}
{$IFDEF FREE_PASCAL}
  InitCriticalSection(FLocker);
{$ENDIF}
end;

//==============================================================================
//==============================================================================
destructor TNXStackBook.Destroy;
begin
{$IFDEF DELPHI}
  DeleteCriticalSection(FLocker);
{$ENDIF}
{$IFDEF FREE_PASCAL}
  DoneCriticalSection(FLocker);
{$ENDIF}

  inherited;

{$IFDEF NX_DEBUG}
  //
  // Error whenever a stack was not freed (each thread makes use of its own
  // stacks and has to destroy them by calling [I|Q|X|C|GF2|GF3]ContextDone).
  //
  if FCount <> 0 then RunError(254);
{$ENDIF} // NX_DEBUG
end;

//==============================================================================
// Register a stack (if not already done) for a given thread
//==============================================================================
function TNXStackBook.RegisterStack(ThreadID: TThreadID): Boolean;
  const MinTIDInc = 8;
  var i, j : SInt32;
begin
  EnterCriticalSection(FLocker);
  try
    i := FCount-1;
    while (i >= 0) and (FTID[i] <> ThreadID) do Dec(i);

    if i >= 0 then Result := false // already registered
    else
    begin
      Inc(FCount);
      i := Length(FTID);
      if FCount > i then
      begin
        SetLength(FTID,i+MinTIDInc);
        for j := FCount to i+(MinTIDInc-1) do FTID[j] := 0;
      end;
      FTID[FCount-1] := ThreadID;
      Result := true;
    end;
  finally
    LeaveCriticalSection(FLocker);
  end;
end;

//==============================================================================
// Unregister a stack (if not already done) for a given thread
//==============================================================================
function TNXStackBook.UnregisterStack(ThreadID: TThreadID): Boolean;
  var i, j : SInt32;
begin
  EnterCriticalSection(FLocker);
  try
    i := FCount-1;
    while (i >= 0) and (FTID[i] <> ThreadID) do Dec(i);
    if i < 0 then Result := false // not registered
    else
    begin
      Dec(FCount);
      for j := i to FCount-1 do FTID[j] := FTID[j+1];
      FTID[FCount] := 0;
      Result := true;
    end;
  finally
    LeaveCriticalSection(FLocker);
  end;
end;

{$ENDIF} // NX_THREAD_SAFE

////////////////////////////////////////////////////////////////////////////////
initialization
{$IFDEF NX_CHECKS}
  //-- gcMinListInc should be a power of 2
  if ((gcMinListInc and Pred(gcMinListInc)) <> 0) or (gcMinListInc = 0) then
    RunError(255);
{$ENDIF}

{$IFDEF FREE_PASCAL}
  //-- FREE PASCAL should raise an exception whenever a memory allocation fails
  ReturnNilIfGrowHeapFails := false;
{$ENDIF}
end.
////////////////////////////////////////////////////////////////////////////////

