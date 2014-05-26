////////////////////////////////////////////////////////////////////////////////
// Big Integers (Z)
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
// NX v0.32.3 (alpha)
// The latest release of NX can be found at http://www.ellipsa.eu/
////////////////////////////////////////////////////////////////////////////////
unit nx_z;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
uses
  USE_Types,
  USE_Utils,
  nx_types,
  nx_strs;
////////////////////////////////////////////////////////////////////////////////

{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Add Burnikel & Ziegler division
  // * Add recursive GCD
  //

const
  //-- bigint size bound
  gcMaxBigIntSize = SInt32($1000000); // 2**24 (max size to the base 2**32)
  gcMaxBigIntBitSize = gcMaxBigIntSize shl 5; // 2**29

type
  //
  // Big integer
  //
  // A TBigInt instance is said to be normalized when the two following
  // properties hold:
  // 1) (Size > 0) -> (Digits^[Size-1] <> 0)
  // 2) (Size = 0) -> (SignFlag = 0)
  //
  // ! Except with INormalize, IIsNormalized, ISet0* and ISet0Packed*, it is
  // assumed that routines are called with normalized operands. If they are
  // not anything can occur: access violations, infinite loops, etc.
  //
  // ! Programs should assume nothing concerning the content of the cells
  // Digits^[Size..Capacity-1]. Their values might be any.
  //
{$IFDEF FREE_PASCAL}
  TBigInt = packed object // used as a record
  private
{$ENDIF}
{$IFDEF DELPHI}
  TBigInt = packed record
{$IFDEF HAS_RECORD_WITH_PRIVATE_FIELDS}
  private
{$ENDIF}
{$ENDIF}
    Digits: PUInt32Frame; // pointer to a frame of UInt32's
    Capacity: SInt32;     // memory size (in UInt32's) allocated to Digits^
    Size: SInt32;         // number of digits currently used in Digits^
    SignFlag: SInt32;     // 0 if positive or null, 1 if negative
  end;
  PBigInt = ^TBigInt;
  PPBigInt = ^PBigInt;
  TPBigIntFrame = array [0..0] of PBigInt;
  PPBigIntFrame = ^TPBigIntFrame;

  //
  // Division type (used by IPowMod)
  //
  TDivType = (dtUndefined, dtStandard, dtMontgomery, dtReciprocal);

  //
  // Random generator options (used by IRnd)
  //
  TRndOptions = (roExactSize, roSigned);
  TRndOptionSet = set of TRndOptions;

  //
  // Procedural types
  //
  TBigIntBinaryOp = procedure(A,B: PBigInt);
  TBigIntBinaryOpSI32 = procedure(A: PBigInt; B: SInt32);
  TBigIntBinaryOpSI64 = procedure(A: PBigInt; B: SInt64);
  TBigIntBinaryOpUI32 = procedure(A: PBigInt; B: UInt32);
  TBigIntBinaryOpUI64 = procedure(A: PBigInt; B: UInt64);
  TBigIntCompare = function(A,B: PBigInt): SInt32;
  TBigIntTest = function(A: PBigInt): Boolean;
  TBigIntUnaryOp = procedure(A: PBigInt);


//
// Miscellaneous (small integers)
//
function UI32Bit(A: UInt32; Index: SInt32): Boolean;
function UI64Bit(A: UInt64; Index: SInt32): Boolean;
function UI32BitParityOdd(A: UInt32): Boolean;
function UI64BitParityOdd(A: UInt64): Boolean;
function UI32BitScanForward(A: UInt32): SInt32;
function UI64BitScanForward(A: UInt64): SInt32;
function UI32BitSize(A: UInt32): SInt32;
function UI64BitSize(A: UInt64): SInt32;
function UI32BitWeight(A: UInt32): SInt32;
function UI64BitWeight(A: UInt64): SInt32;
function UI32ByteSwap(A: UInt32): UInt32;
function UI32Cmp(A,B: UInt32): SInt32;
function UI64Cmp(A,B: UInt64): SInt32;
function UI32CRC(A: UInt32; InitCRC: UInt32 = 0): UInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function UI64CRC(A: UInt64; InitCRC: UInt32 = 0): UInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function UI32ExtractBits(A: UInt32; Index,Count: SInt32): UInt32;
function UI64ExtractBits(A: UInt64; Index,Count: SInt32): UInt32;
function UI32GCD(A,B: UInt32): UInt32;
function UI64GCD(A,B: UInt64): UInt64;
function UI32InvMod(A,B: UInt32): UInt32;
function UI32InvMod2Pow32(A: UInt32): UInt32;
function UI32IsSquare(A: UInt32): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function UI64IsSquare(A: UInt64): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function UI32SqrtTest(var A: UInt32): Boolean;
function UI64SqrtTest(var A: UInt64): Boolean;
function UI32Sqrt(A: UInt32): UInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function UI64Sqrt(A: UInt64): UInt64; {$IFDEF HAS_INLINE} inline; {$ENDIF}

//
// Creation/Destruction/Memory management
//
function  ICapacity(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IDigitsPtr(A: PBigInt): PUInt32Frame; {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure IFree(var A: PBigInt);
procedure IFreeMany(var A,B: PBigInt); overload;
procedure IFreeMany(var A,B,C: PBigInt); overload;
procedure IFreeMany(const A: array of PPBigInt); overload;
procedure IFreeMany(const A: PPBigIntFrame; Count: SInt32); overload;
procedure IIncCapacity(A: PBigInt);
procedure IIncCapacityUpTo(A: PBigInt; NewCapacity: SInt32);
procedure INew(var A: PBigInt);
procedure INewMany(var A,B: PBigInt); overload;
procedure INewMany(var A,B,C: PBigInt); overload;
procedure INewMany(const A: array of PPBigInt); overload;
procedure INewMany(const A: PPBigIntFrame; Count: SInt32); overload;
procedure IPack(A: PBigInt);
procedure IPackMany(const A: array of PBigInt); overload;
procedure IPackMany(const A: PPBigIntFrame; Count: SInt32); overload;
procedure ISetSize(A: PBigInt; NewSize: SInt32);
function  ISize(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}

//
// Normalization
//
function  IIsNormalized(A: PBigInt): Boolean;
procedure INormalize(A: PBigInt);

//
// Streams/Files
//
procedure ILoadFromFile(A: PBigInt; const FileName: string);
procedure ILoadFromStream(A: PBigInt; Stream: TStream);
procedure ISaveToFile(A: PBigInt; const FileName: string);
procedure ISaveToStream(A: PBigInt; Stream: TStream);

//
// Miscellaneous
//
procedure IAbs(A: PBigInt); {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure IAdd(A,B: PBigInt);
procedure IAddAbs(A,B: PBigInt);
procedure IAddMul(A,B,C: PBigInt);
procedure IAddMulSI32(A,B: PBigInt; C: SInt32);
procedure IAddMulSI64(A,B: PBigInt; const C: SInt64);
procedure IAddMulUI32(A,B: PBigInt; C: UInt32);
procedure IAddMulUI64(A,B: PBigInt; const C: UInt64);
procedure IAddSI32(A: PBigInt; B: SInt32);
procedure IAddSI64(A: PBigInt; B: SInt64);
procedure IAddTo(R,A,B: PBigInt);
procedure IAddUI32(A: PBigInt; B: UInt32);
procedure IAddUI64(A: PBigInt; B: UInt64);
procedure IAnd(A,B: PBigInt);
function  IAsSI32(A: PBigInt; CheckRange: Boolean = true): SInt32;
function  IAsSI64(A: PBigInt; CheckRange: Boolean = true): SInt64;
function  IAsUI8(A: PBigInt; CheckRange: Boolean = true): UInt8;
function  IAsUI32(A: PBigInt; CheckRange: Boolean = true): UInt32;
function  IAsUI64(A: PBigInt; CheckRange: Boolean = true): UInt64;
function  IBit(A: PBigInt; Index: SInt32): Boolean;
function  IBitParityOdd(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IBitScanForward(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure IBitSet(A: PBigInt; Index: SInt32; Value: Boolean);
function  IBitSize(A: PBigInt): SInt32;
function  IBitWeight(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IByteSize(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure ICbrt(A: PBigInt);
function  ICmp(A,B: PBigInt): SInt32;
function  ICmpAbs(A,B: PBigInt): SInt32;
function  ICmpAbsSI32(A: PBigInt; B: SInt32): SInt32;
function  ICmpAbsSI64(A: PBigInt; B: SInt64): SInt32;
function  ICmpAbsUI32(A: PBigInt; B: UInt32): SInt32;
function  ICmpAbsUI64(A: PBigInt; B: UInt64): SInt32;
function  ICmpSI32(A: PBigInt; B: SInt32): SInt32;
function  ICmpSI64(A: PBigInt; B: SInt64): SInt32;
function  ICmpSize(A,B: PBigInt): SInt32;
function  ICmpUI32(A: PBigInt; B: UInt32): SInt32;
function  ICmpUI64(A: PBigInt; B: UInt64): SInt32;
function  ICRC(A: PBigInt; InitCRC: UInt32 = 0): UInt32;
procedure ICut(A: PBigInt; BitCount: SInt32);
procedure IDec(A: PBigInt);
function  IDecimalSize(A: PBigInt; EstimateOnly: Boolean = false): SInt32;
function  IDigit(A: PBigInt; Index: SInt32): UInt32;
function  IDigitScanForward(A: PBigInt): SInt32;
procedure IDigitSet(A: PBigInt; Index: SInt32; Value: UInt32);
function  IDiv(A,B: PBigInt): Boolean;
procedure IDivExactUI32(A: PBigInt; B: UInt32);
function  IDivisible(A: PBigInt; B: UInt32): Boolean;
procedure IDivMod(Q,R,A,B: PBigInt);
procedure IDivRem(Q,R,A,B: PBigInt);
function  IDivSI32(A: PBigInt; B: SInt32): SInt32;
function  IDivSI64(A: PBigInt; B: SInt64): SInt64;
function  IDivUI32(A: PBigInt; B: UInt32): Boolean;
function  IDivUI64(A: PBigInt; B: UInt64): Boolean;
function  IEqu(A,B: PBigInt): Boolean;
function  IEqu0(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IEqu1(A: PBigInt): Boolean;
function  IEquAbs(A,B: PBigInt): Boolean;
function  IEquAbs1(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IEquAbsSI32(A: PBigInt; B: SInt32): Boolean;
function  IEquAbsSI64(A: PBigInt; B: SInt64): Boolean;
function  IEquAbsUI32(A: PBigInt; B: UInt32): Boolean;
function  IEquAbsUI64(A: PBigInt; B: UInt64): Boolean;
function  IEquMinus1(A: PBigInt): Boolean;
function  IEquSI32(A: PBigInt; B: SInt32): Boolean;
function  IEquSI64(A: PBigInt; B: SInt64): Boolean;
function  IEquUI32(A: PBigInt; B: UInt32): Boolean;
function  IEquUI64(A: PBigInt; B: UInt64): Boolean;
function  IExtractBits(A: PBigInt; Index,Count: SInt32): UInt32;
procedure IFillBits(A: PBigInt; BitCount: SInt32);
procedure IFillDigits(A: PBigInt; Count: SInt32; Value: UInt32);
function  IGCD(A,B: PBigInt): Boolean;
function  IGCDEqu1(A,B: PBigInt): Boolean;
function  IGCDUI32(A: PBigInt; B: UInt32): UInt32;
function  IGCDUI64(A: PBigInt; B: UInt64): UInt64;
procedure IInc(A: PBigInt);
function  IInvMod(A,B: PBigInt): Boolean;
function  IInvModMany(const A: array of PBigInt; B: PBigInt): Boolean;
function  IIsEven(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IIsNegative(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IIsNegativeOrNull(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IIsOdd(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IIsPositive(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IIsPositiveOrNull(A: PBigInt): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  IIsPowOf2(A: PBigInt): Boolean;
function  IIsSI32(A: PBigInt): Boolean;
function  IIsSI64(A: PBigInt): Boolean;
function  IIsSquare(A: PBigInt): Boolean;
function  IIsUI8(A: PBigInt): Boolean;
function  IIsUI32(A: PBigInt): Boolean;
function  IIsUI64(A: PBigInt): Boolean;
procedure ILCM(A,B: PBigInt);
procedure ILoadFromBuf(A: PBigInt; const Buf; ByteCount: SInt32);
function  ILSD(A: PBigInt): UInt32;
function  ILSDNZ(A: PBigInt): UInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure IMod(A,B: PBigInt);
function  IMod3(A: PBigInt): UInt32;
function  IModSI32(A: PBigInt; B: SInt32): SInt32;
function  IModSI64(A: PBigInt; B: SInt64): SInt64;
function  IModUI32(A: PBigInt; B: UInt32): UInt32;
function  IModUI64(A: PBigInt; B: UInt64): UInt64;
procedure IMontgomery(A,B: PBigInt);
procedure IMontgomeryReduce(A,B: PBigInt; U: UInt32);
function  IMontgomerySetup(A: PBigInt): UInt32;
function  IMSD(A: PBigInt): UInt32;
function  IMSDNZ(A: PBigInt): UInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure IMul(A,B: PBigInt);
procedure IMulSI32(A: PBigInt; B: SInt32);
procedure IMulSI64(A: PBigInt; B: SInt64);
procedure IMulTo(R,A,B: PBigInt);
procedure IMulUI32(A: PBigInt; B: UInt32);
procedure IMulUI64(A: PBigInt; B: UInt64);
procedure INegate(A: PBigInt); {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure INot(A: PBigInt; BitCount: SInt32);
procedure IOr(A,B: PBigInt);
procedure IPowMod(A,E,B: PBigInt; DivType: TDivType = dtUndefined);
procedure IPowUI32(A: PBigInt; E: UInt32);
procedure IPowUI64Mod(
                  A       : PBigInt;
            const E       : UInt64;
                  B       : PBigInt;
                  DivType : TDivType = dtUndefined);
procedure IReciprocalMod(A,B,R: PBigInt);
procedure IReciprocalSetup(A,B: PBigInt);
procedure IReduce(A,B: PBigInt);
procedure IRem(A,B: PBigInt);
function  IRemoveTrailingZeroes(A: PBigInt): SInt32;
function  IRemSI32(A: PBigInt; B: SInt32): SInt32;
function  IRemSI64(A: PBigInt; B: SInt64): SInt64;
procedure IRnd(
            A        : PBigInt;
            BitCount : SInt32;
            Options  : TRndOptionSet = []); overload;
procedure IRnd(A,Min,Max: PBigInt); overload;
procedure IRol(A: PBigInt; BitCount,Shift: SInt32);
procedure IRol1(A: PBigInt; BitCount: SInt32);
procedure IRoot(A: PBigInt; k: UInt32);
procedure IRor(A: PBigInt; BitCount,Shift: SInt32);
procedure IRor1(A: PBigInt; BitCount: SInt32);
procedure ISet(A,B: PBigInt);
procedure ISet0(A: PBigInt); {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure ISet0Many(const A: array of PBigInt); overload;
procedure ISet0Many(const A: PPBigIntFrame; Count: SInt32); overload;
procedure ISet0Packed(A: PBigInt);
procedure ISet0PackedMany(const A: array of PBigInt); overload;
procedure ISet0PackedMany(const A: PPBigIntFrame; Count: SInt32); overload;
procedure ISet1(A: PBigInt);
procedure ISetAbs(A,B: PBigInt);
procedure ISetEven(A: PBigInt);
procedure ISetHiPart(A,B: PBigInt; Count: SInt32);
procedure ISetLoPart(A,B: PBigInt; Count: SInt32);
procedure ISetMinus1(A: PBigInt);
procedure ISetNegative(A: PBigInt; Value: Boolean); {$IFDEF HAS_INLINE} inline; {$ENDIF}
procedure ISetOdd(A: PBigInt);
procedure ISetSI32(A: PBigInt; B: SInt32);
procedure ISetSI64(A: PBigInt; B: SInt64);
procedure ISetSign(A: PBigInt; Sign: SInt32);
procedure ISetUI32(A: PBigInt; B: UInt32);
procedure ISetUI64(A: PBigInt; B: UInt64);
procedure IShl(A: PBigInt; Shift: SInt32);
procedure IShl1(A: PBigInt);
procedure IShr(A: PBigInt; Shift: SInt32);
function  IShr1(A: PBigInt): Boolean;
function  IShrUntilOdd(A: PBigInt): SInt32;
function  ISign(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF}
function  ISignProduct(A,B: PBigInt): SInt32;
procedure ISqr(A: PBigInt);
function  ISqrt(A: PBigInt): Boolean;
function  ISqrtRem(S,R,A: PBigInt): Boolean;
procedure ISqrTo(R,A: PBigInt);
procedure ISub(A,B: PBigInt);
procedure ISubr(A,B: PBigInt);
procedure ISubSI32(A: PBigInt; B: SInt32);
procedure ISubSI64(A: PBigInt; B: SInt64);
procedure ISubTo(R,A,B: PBigInt);
procedure ISubUI32(A: PBigInt; B: UInt32);
procedure ISubUI64(A: PBigInt; B: UInt64);
procedure ISwp(A,B: PBigInt);
function  IXGCD(D,U,V,A,B: PBigInt): Boolean;
procedure IXor(A,B: PBigInt);

//
// Strings
//
procedure ISetStr(A: PBigInt; const S: AnsiString);
function  IStr(
            A              : PBigInt;
            Base           : UInt32 = 10;
            BlockLength    : SInt32 = 0;
            Options        : TStrFormatOptionSet = [];
            BaseDelimiters : TStrBaseDelimiters = sbdDefault): AnsiString;

//
// The following routine would be "local" if not required by nx_r, so do
// not use it in programs, it could still be modified or even suppressed
// from the interface.
//
procedure RawStrToBigInt(N: PBigInt; const S: AnsiString; sf,Base: UInt32);

//
// Stack
//
// Programs should make use of the stack instead of creating/destroying
// TBigInt instances. It minimizes memory manager calls and thus speeds up
// computations.
// Each thread has its own stack that should be initialized with IContextInit
// and finalized with IContextDone (from the concerned thread).
//
function  IStackCapacity: SInt32;
function  IStackGet(out A: PBigInt): SInt32;
function  IStackGetMany(out A,B: PBigInt): SInt32; overload;
function  IStackGetMany(out A,B,C: PBigInt): SInt32; overload;
function  IStackGetMany(const A: array of PPBigInt): SInt32; overload;
function  IStackGetMany(
            const A     : PPBigIntFrame;
                  Count : SInt32): SInt32; overload;
procedure IStackGrowUpTo(NewCapacity: SInt32);
function  IStackIndex: SInt32;
procedure IStackPack(DoPackAll: Boolean = false);
procedure IStackRestore(PreviousIndex: SInt32);

//
// Initialization/finalization for threads (other than the main thread)
//
// There is no need to call IContextInit or IContextDone from the main thread
// but for any other thread
// 1) IContextInit has to be called once before starting to use the routines of
//    nx_z in this thread;
// 2) IContextDone has to be called once before destroying this thread.
//
{$IFDEF NX_THREAD_SAFE}
procedure IContextDone;
procedure IContextInit;
{$ENDIF}

//
// deprecated (will be removed from v0.33.0)
//
procedure ISetSignFlag(A: PBigInt; NewSignFlag: SInt32); {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  ISignFlag(A: PBigInt): SInt32; {$IFDEF HAS_INLINE} inline; {$ENDIF} {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}

////////////////////////////////////////////////////////////////////////////////
implementation
uses
{$IFDEF DELPHI}
{$IFDEF NX_THREAD_SAFE}
  Windows,
{$ENDIF}
{$ENDIF}
  nx_errors,
  nx_common,
  nx_rand,
  nx_kernel;
////////////////////////////////////////////////////////////////////////////////

{$IFDEF FREE_PASCAL}
  {$ASMMODE INTEL}
{$ENDIF}

//-- the two following directives should not be modified
{$Q-}
{$R-}

const
  //-- ucMinBigIntInc = Minimal capacity increment (in UInt32's) of a bigint
  //   !!! Should be a power of 2 not less than 2
  ucMinBigIntInc = SInt32(8);

type
  SInt32x4 = packed record
    i0,i1,i2,i3: SInt32;
  end;
  TBigIntFileHeader = array [0..15] of AnsiChar;

const
  ucBigIntFileHeader: TBigIntFileHeader = 'NX.TBigInt......';

////////////////////////////////////////////////////////////////////////////////
// Debugging
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
// Result := (all the pointers A[i] are distinct)
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
function DistinctPointers1(const A: array of PBigInt): Boolean;
  var i, j : SInt32;
begin
  for i := 0 to High(A)-1 do
    for j := i+1 to High(A) do
      if Pointer(A[i]) = Pointer(A[j]) then
      begin
        Result := false;
        Exit;
      end;
  Result := true;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Result := (all the pointers A[i] are distinct)
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
function DistinctPointers2(const A: array of PPBigInt): Boolean;
  var i, j : SInt32;
begin
  for i := 0 to High(A)-1 do
    for j := i+1 to High(A) do
      if Pointer(A[i]) = Pointer(A[j]) then
      begin
        Result := false;
        Exit;
      end;
  Result := true;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Result := (all the pointers A[i]^ are nil)
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
function NilPointers2(const A: array of PPBigInt): Boolean;
  var i : SInt32;
begin
  for i := 0 to High(A) do
    if Assigned(A[i]^) then
    begin
      Result := false;
      Exit;
    end;
  Result := true;
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Result := (all the pointers A^[i] are nil)
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
function NilPointers3(const A: PPBigIntFrame; Count: SInt32): Boolean;
  var i : SInt32;
begin
  for i := 0 to Count-1 do
    if Assigned(A^[i]) then
    begin
      Result := false;
      Exit;
    end;
  Result := true;
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
// Miscellaneous (small integers)
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Result := bit #Index of A if Index in 0..31 (FALSE = 0, TRUE = 1),
//        := FALSE if Index is not in 0..31
// Bits are 0-based
//==============================================================================
function UI32Bit(A: UInt32; Index: SInt32): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      //-- Result := (UInt32(Index) < 32) and ((A and gcPowOf2[Index]) <> 0)
      cmp   edx, 32
      jnb   @@01
      mov   edx, dword [gcPowOf2+edx*4]
      and   eax, edx
      setnz al
      ret

@@01: mov   al, 0  // return FALSE
end;

//==============================================================================
// Result := bit #Index of A if Index in 0..63 (FALSE = 0, TRUE = 1),
//        := FALSE if Index is not in 0..63
// Bits are 0-based
//==============================================================================
function UI64Bit(A: UInt64; Index: SInt32): Boolean;
begin
  if UInt32(Index) > 63 then Result := false
  else
  with UInt32x2(A) do
  if UInt32(Index) > 31 then Result := (Hi and gcPowOf2[Index-32]) <> 0
  else Result := (Lo and gcPowOf2[Index]) <> 0;
end;

//==============================================================================
// Result := 'Parity odd' of A
// The returned value is equal to "(UI32BitWeight(A) and 1) = 1"
//==============================================================================
function UI32BitParityOdd(A: UInt32): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   edx, eax
      shr   eax, 16
      xor   eax, edx
      xor   al, ah
      setpo al
end;

//==============================================================================
// Result := 'Parity odd' of A
// The returned value is equal to "(UI64BitWeight(A) and 1) = 1"
//==============================================================================
function UI64BitParityOdd(A: UInt64): Boolean;
begin
  with UInt32x2(A) do Result := UI32BitParityOdd(Lo xor Hi);
end;

//==============================================================================
// Result := Indice of the first trailing bit of A that is not null
//        := -1 if A = 0
// Bits are 0-based
//==============================================================================
function UI32BitScanForward(A: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      bsf   eax, eax
      jz    @@01
      ret

@@01: mov   eax, -1
end;

//==============================================================================
// Result := Indice of the first trailing bit that is not null (or -1 if A = 0)
// Bits are 0-based
//==============================================================================
function UI64BitScanForward(A: UInt64): SInt32;
begin
  with UInt32x2(A) do
  if Lo > 0 then Result := UI32BitScanForward(Lo)
  else
  if Hi > 0 then Result := UI32BitScanForward(Hi) + 32
  else Result := -1;
end;

//==============================================================================
// Result := Binary size of A
//==============================================================================
function UI32BitSize(A: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      bsr   eax, eax
      jz    @@01
      inc   eax
      ret

@@01: xor   eax, eax
end;

//==============================================================================
// Result := Binary size of A
//==============================================================================
function UI64BitSize(A: UInt64): SInt32;
begin
  with UInt32x2(A) do
  begin
    Result := UI32BitSize(Hi);
    if Result = 0 then Result := UI32BitSize(Lo) else Inc(Result,32);
  end;
end;

//==============================================================================
// Result := Hamming weight of A (number of bits equal to 1)
//==============================================================================
function UI32BitWeight(A: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   edx, eax
      shr   edx, 1
      and   edx, $55555555
      sub   eax, edx
      mov   edx, eax
      shr   eax, 2
      and   edx, $33333333
      and   eax, $33333333
      add   eax, edx
      mov   edx, eax
      shr   eax, 4
      add   eax, edx
      and   eax, $0f0f0f0f
      mov   edx, eax
      shr   eax, 8
      add   eax, edx
      mov   edx, eax
      shr   eax, 16
      add   eax, edx
      and   eax, $ff
end;

//==============================================================================
// Return the weight of A (number of bits equal to 1)
//==============================================================================
function UI64BitWeight(A: UInt64): SInt32;
begin
  with UInt32x2(A) do Result := UI32BitWeight(Hi) + UI32BitWeight(Lo);
end;

//==============================================================================
// Swap the four bytes of A
//==============================================================================
function UI32ByteSwap(A: UInt32): UInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
{$IFDEF NX_BSWAP_SUPPORTED}
      bswap eax
{$ELSE}
      rol   ax, 8
      rol   eax, 16
      rol   ax, 8
{$ENDIF}
end;

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function UI32Cmp(A,B: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      //-- Result := Ord(A > B) - Ord(A < B);
      cmp   eax, edx
      seta  al
      setb  dl
      and   eax, $ff
      and   edx, $ff
      sub   eax, edx
end;

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function UI64Cmp(A,B: UInt64): SInt32;
begin
  with UInt32x2(A) do
  begin
    Result := Ord(Hi > UInt32x2(B).Hi) - Ord(Hi < UInt32x2(B).Hi);
    if Result = 0 then
      Result := Ord(Lo > UInt32x2(B).Lo) - Ord(Lo < UInt32x2(B).Lo);
  end;
end;

//==============================================================================
// Result := CRC(A)
// InitCRC allows to chain calls to UI32CRC
//==============================================================================
function UI32CRC(A: UInt32; InitCRC: UInt32 = 0): UInt32;
begin
  Result := RawCRC(@A,1,InitCRC);
end;

//==============================================================================
// Result := CRC(A)
// InitCRC allows to chain calls to UI64CRC
//==============================================================================
function UI64CRC(A: UInt64; InitCRC: UInt32 = 0): UInt32;
begin
  Result := RawCRC(@A,2,InitCRC);
end;

//==============================================================================
// Result := Bits [Index...Index+Count-1] of A
// -> Index, index of the least significant bit to extract
// -> Count, 0 <= Count <= 32, number of bits to extract
// Bits are 0-based
//==============================================================================
function UI32ExtractBits(A: UInt32; Index,Count: SInt32): UInt32;
begin
  if Index < 0 then NXRaiseInvalidArg('UI32ExtractBits',esIndex_lt_0);

  case UInt32(Count) of
    0:     Result := 0;
    1..32: Result := (A shr Index) and gcMask32[Count-1];
    else
    NXRaiseInvalidArg('UI32ExtractBits',esCount_is_not_in_0_32);

  {$IFDEF DELPHI}
    Result := 0; // to avoid DELPHI warning
  {$ENDIF}
  end;
end;

//==============================================================================
// Result := Bits [Index...Index+Count-1] of A
// -> Index, index of the least significant bit to extract
// -> Count, 0 <= Count <= 32, number of bits to extract
// Bits are 0-based
//==============================================================================
function UI64ExtractBits(A: UInt64; Index,Count: SInt32): UInt32;
begin
  if Index < 0 then NXRaiseInvalidArg('UI64ExtractBits',esIndex_lt_0);

  case UInt32(Count) of
    0:     Result := 0;
    1..32: Result := UInt32(A shr Index) and gcMask32[Count-1];
    else
    NXRaiseInvalidArg('UI64ExtractBits',esCount_is_not_in_0_32);

  {$IFDEF DELPHI}
    Result := 0; // to avoid DELPHI warning
  {$ENDIF}
  end;
end;

//==============================================================================
// -> A, any
// -> B, any
// <- Result := GCD(A,B) if A and B are not both null
//           := 0 (invalid GCD value) whenever A = B = 0
// GCD ~ Greatest Common Divisor
//==============================================================================
function UI32GCD(A,B: UInt32): UInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      test  edx, edx
      je    @@FF       // exit with Result = A if B = 0

      mov   ecx, eax   // ecx := A
      mov   eax, edx   // eax := B
      test  ecx, ecx
      je    @@FF       // exit with Result = B if A = 0

      mov   edx, ecx   // edx := A
      push  ebx
      bsf   ecx, eax
      shr   eax, cl    // make B odd
      mov   ebx, ecx   // save i
      bsf   ecx, edx
      shr   edx, cl    // make A odd
      cmp   ebx, ecx
      jbe   @@01       // jmp if i <= j
      mov   ebx, ecx   // ebx := min(i,j)

@@01: cmp   eax, edx
      jb    @@03       // jmp if B < A
      je    @@04       // jmp if B = A (exit)

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: sub   eax, edx   // B := B - A
      bsf   ecx, eax
      shr   eax, cl    // make B odd
      cmp   eax, edx
      ja    @@02       // jmp if B > A
      je    @@04       // jmp if B = A (exit)

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@03: sub   edx, eax   // A := A - B
      bsf   ecx, edx
      shr   edx, cl    // make A odd
      cmp   eax, edx
      ja    @@02       // jmp if B > A
      jb    @@03       // jmp if B < A

@@04: mov   ecx, ebx
      shl   eax, cl    // Result := A shl i
      pop   ebx
@@FF:
end;

//==============================================================================
// -> A, any
// -> B, any
// <- Result := GCD(A,B) if A and B are not both null
//           := 0 (invalid GCD value) whenever A = B = 0
// GCD ~ Greatest Common Divisor
//==============================================================================
function UI64GCD(A,B: UInt64): UInt64;
assembler; register;
  var SEBX, SEDI, SESI: UInt32;
asm
      mov   SEDI, edi
      mov   SESI, esi
      mov   edx, dword ptr A[4] // edx := Hi(A)
      mov   eax, dword ptr A[0] // eax := Lo(A)
      mov   edi, dword ptr B[4] // edi := Hi(B)
      mov   esi, dword ptr B[0] // esi := Lo(B)
      mov   ecx, edi
      or    ecx, esi
      jz    @@15                // B = 0, exit with Result := A
      mov   ecx, edx
      or    ecx, eax
      jnz   @@01
      mov   edx, edi
      mov   eax, esi
      jmp   @@15                // A = 0, exit with Result = B

      // it is possible to avoid using ebx by using cl,ch instead
      // of ecx,ebx

@@01: mov   SEBX, ebx
      xor   ecx, ecx            // i := 0
      test  eax, 1
      jnz   @@03

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: shrd  eax, edx, 1         // A := A shr 1
      shr   edx, 1
      inc   ecx                 // Inc(i)
      test  eax, 1
      jz    @@02                // loop while not Odd(A)

@@03: xor   ebx, ebx            // j := 0
      test  esi, 1
      jnz   @@05

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@04: shrd  esi, edi, 1         // B := B shr 1
      shr   edi, 1
      inc   ebx                 // inc(j)
      test  esi, 1
      jz    @@04                // loop while not odd(B)

@@05: cmp   ecx, ebx
      jbe   @@09       // jmp if i <= j
      mov   ecx, ebx   // ecx := Min(i,j)
      jmp   @@09

      //-- A > B
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@07: sub   eax, esi            // A := A - B
      sbb   edx, edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@08: shrd  eax, edx, 1         // A : A shr 1
      shr   edx, 1
      test  eax, 1
      jz    @@08                // loop while not Odd(A)
@@09: cmp   edx, edi
      jb    @@10                // if A < B
      ja    @@07                // if A > B
      cmp   eax, esi
      ja    @@07                // if A > B
      je    @@12                // A = B, exit with Result := A shl i

      //-- A < B
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@10: sub   esi, eax            // B := B - A
      sbb   edi, edx

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@11: shrd  esi, edi, 1         // B := B shr 1;
      shr   edi, 1
      test  esi, 1
      jz    @@11                // loop while not Odd(B)

      cmp   edx, edi
      ja    @@07                // if A > B
      jb    @@10                // if A < B
      cmp   eax, esi
      ja    @@07                // if A > B
      jb    @@10                // if A < B

@@12: cmp   ecx, 32
      jb    @@13
      mov   edx, eax
      and   ecx, 31             // useless?
      xor   eax, eax
      shl   edx, cl
      jmp   @@14
@@13: shld  edx, eax, cl
      shl   eax, cl
@@14: mov   ebx, SEBX
@@15: mov   esi, SESI
      mov   edi, SEDI
end;

//------------------------------------------------------------------------------
// Local (for UI32InvMod only)
//------------------------------------------------------------------------------
procedure UI32InvModError;
begin
  NXRaiseDivByZero('UI32InvMod');
end;

//==============================================================================
// Result := A**(-1) mod B
//        := 0 if GCD(A,B) <> 1
//==============================================================================
function UI32InvMod(A,B: UInt32): UInt32;
assembler; register;
  var SEBX, SEDI, SESI, SB, F : UInt32;
asm
      mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi

      cmp   edx, 1
      jb    @@XX       // jmp if B = 0
      je    @@05       // jmp if B = 1
      test  eax, eax
      je    @@05       // jmp if A = 0

      mov   ebx, eax   // A
      mov   ecx, edx   // B
      mov   edi, 1     // U
      cmp   ebx, ecx
      mov   esi, 0     // V (set to 0 without modifying flags)
      je    @@05       // jmp if A = B
      mov   SB, ecx    // save initial value
      mov   F, esi     // F := 0 ("F odd" means "negate the result")
      ja    @@01       // jmp if A > B
      mov   eax, ecx   // B
      xor   edx, edx
      div   ebx        // Q := [0:B] div A, R := [0:B] mod A
      mov   esi, eax   // V := Q
      test  edx, edx
      mov   ecx, edx   // B := R
      je    @@02       // jmp if B = 0

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, ebx   // eax := A
      xor   edx, edx   // edx := 0
      div   ecx        // Q := [0:A] div B, R := [0:A] mod B
      mov   ebx, ecx   // A := B
      imul  eax, esi   // T := V * Q (product < 2**32)
      mov   ecx, edx   // B := R
      add   eax, edi   // T := T + U
      inc   F
      mov   edi, esi   // U := V
      test  ecx, ecx   // B = 0 ?
      mov   esi, eax   // V := T
      jne   @@01

@@02: cmp   ebx, 1     // A = 1 ?
      jne   @@05
      and   ebx, F     // F odd ? (here, ebx = 1)
      jne   @@03
      mov   eax, edi   // Result := U
      jmp   @@06
@@03: mov   eax, SB
      sub   eax, edi   // Result := B - U
      jmp   @@06

@@XX: call  UI32InvModError
@@05: xor   eax, eax   // Result := 0
@@06: mov   esi, SESI
      mov   edi, SEDI
      mov   ebx, SEBX
end;

//------------------------------------------------------------------------------
// Unit Constant (used by UI32InvMod2Pow32)
//------------------------------------------------------------------------------
const
  // ucIT[i] = (2*i+1)**(-1) mod 256
  ucIT: array [0..127] of UInt8 = (
  $01,$ab,$cd,$b7,$39,$a3,$c5,$ef,$f1,$1b,$3d,$a7,$29,$13,$35,$df,
  $e1,$8b,$ad,$97,$19,$83,$a5,$cf,$d1,$fb,$1d,$87,$09,$f3,$15,$bf,
  $c1,$6b,$8d,$77,$f9,$63,$85,$af,$b1,$db,$fd,$67,$e9,$d3,$f5,$9f,
  $a1,$4b,$6d,$57,$d9,$43,$65,$8f,$91,$bb,$dd,$47,$c9,$b3,$d5,$7f,
  $81,$2b,$4d,$37,$b9,$23,$45,$6f,$71,$9b,$bd,$27,$a9,$93,$b5,$5f,
  $61,$0b,$2d,$17,$99,$03,$25,$4f,$51,$7b,$9d,$07,$89,$73,$95,$3f,
  $41,$eb,$0d,$f7,$79,$e3,$05,$2f,$31,$5b,$7d,$e7,$69,$53,$75,$1f,
  $21,$cb,$ed,$d7,$59,$c3,$e5,$0f,$11,$3b,$5d,$c7,$49,$33,$55,$ff);

//==============================================================================
// Inverse of A modulo 2**32
// -> A odd
// <- Result such that Result*A = 1 mod 2**32 (or 0 if A is even)
//==============================================================================
function UI32InvMod2Pow32(A: UInt32): UInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, eax
      xor   edx, edx
      shr   eax, 1
      jnc   @@01                     // exit with Result=0 if A is even
      and   eax, $7f
      mov   dl,  byte ptr [ucIT+eax] // t := ucIT[(A shr 1) mod 128]
      lea   eax, [edx+edx*1]         // 2*t
      imul  edx, edx                 // t*t
      imul  edx, ecx                 // t*t*A
      sub   eax, edx                 // t := 2*t - t*t*A
      lea   edx, [eax+eax*1]         // 2*t
      imul  eax, eax                 // t*t
      imul  eax, ecx                 // t*t*A
      sub   edx, eax                 // t := 2*t - t*t*A
@@01: mov   eax, edx
end;

//==============================================================================
// Result := A is a square
//==============================================================================
function UI32IsSquare(A: UInt32): Boolean;
begin
  Result := UI32SqrtTest(A);
end;

//==============================================================================
// Result := A is a square
//==============================================================================
function UI64IsSquare(A: UInt64): Boolean;
begin
  Result := UI64SqrtTest(A);
end;

//==============================================================================
// Result := Square root of A
//==============================================================================
function UI32Sqrt(A: UInt32): UInt32;
begin
  Result := A;
  UI32SqrtTest(Result);
end;

//==============================================================================
// Result := Square root of A
//==============================================================================
function UI64Sqrt(A: UInt64): UInt64;
begin
  Result := A;
  UI64SqrtTest(Result);
end;

//==============================================================================
// A := A**(1/2)
// Result := TRUE iff A (input) is a square
//==============================================================================
function UI32SqrtTest(var A: UInt32): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   edx, [eax]
      cmp   edx, $ffff
      ja    @@WW           // jmp if A > 65535
      cmp   edx, $ff
      mov   ecx, $4000
      ja    @@HW           // jmp if A > 255
      mov   ecx, $40
      jmp   @@QW

@@WW: mov   ecx, $40000000 // entry point when A > 65535
      cmp   edx, ecx
      jb    @@01
      sub   edx, ecx
      or    ecx, $c0000000
@@01: shr   ecx, 1
      xor   ecx, $30000000
      cmp   edx, ecx
      jb    @@02
      sub   edx, ecx
      or    ecx, $30000000
@@02: shr   ecx, 1
      xor   ecx, $c000000
      cmp   edx, ecx
      jb    @@03
      sub   edx, ecx
      or    ecx, $c000000
@@03: shr   ecx, 1
      xor   ecx, $3000000
      cmp   edx, ecx
      jb    @@04
      sub   edx, ecx
      or    ecx, $3000000
@@04: shr   ecx, 1
      xor   ecx, $c00000
      cmp   edx, ecx
      jb    @@05
      sub   edx, ecx
      or    ecx, $c00000
@@05: shr   ecx, 1
      xor   ecx, $300000
      cmp   edx, ecx
      jb    @@06
      sub   edx, ecx
      or    ecx, $300000
@@06: shr   ecx, 1
      xor   ecx, $c0000
      cmp   edx, ecx
      jb    @@07
      sub   edx, ecx
      or    ecx, $c0000
@@07: shr   ecx, 1
      xor   ecx, $30000
      cmp   edx, ecx
      jb    @@08
      sub   edx, ecx
      or    ecx, $30000
@@08: shr   ecx, 1
      xor   ecx, $c000
@@HW: cmp   edx, ecx       // entry point when (A < 65536) and (A > 255)
      jb    @@09
      sub   edx, ecx
      or    ecx, $c000
@@09: shr   ecx, 1
      xor   ecx, $3000
      cmp   edx, ecx
      jb    @@10
      sub   edx, ecx
      or    ecx, $3000
@@10: shr   ecx, 1
      xor   ecx, $c00
      cmp   edx, ecx
      jb    @@11
      sub   edx, ecx
      or    ecx, $c00
@@11: shr   ecx, 1
      xor   ecx, $300
      cmp   edx, ecx
      jb    @@12
      sub   edx, ecx
      or    ecx, $300
@@12: shr   ecx, 1
      xor   ecx, $c0
@@QW: cmp   edx, ecx       // entry point when A < 256
      jb    @@13
      sub   edx, ecx
      or    ecx, $c0
@@13: shr   ecx, 1
      xor   ecx, $30
      cmp   edx, ecx
      jb    @@14
      sub   edx, ecx
      or    ecx, $30
@@14: shr   ecx, 1
      xor   ecx, $c
      cmp   edx, ecx
      jb    @@15
      sub   edx, ecx
      or    ecx, $c
@@15: shr   ecx, 1
      xor   ecx, $3
      cmp   edx, ecx
      jb    @@16
      sub   edx, ecx
      or    ecx, $2
@@16: shr   ecx, 1
      test  edx, edx       // if 0 then perfect square
      mov   [eax], ecx     // A := A**(1/2)
      setz  al             // Result := TRUE iff A was a perfect square
end;

//==============================================================================
// A := A**(1/2)
// Hi := 0
// Result := TRUE iff A (input) is a square
//==============================================================================
function UI64SqrtTest(var A: UInt64): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      xor   ecx, ecx        // ecx := 0
      mov   edi, [eax+4]    // edi := Hi(A)
      mov   [eax+4], ecx    // Hi(A) := 0

      cmp   edi, $ffff
      mov   edx, $80000000
      mov   ecx, $c0000000
      ja    @@01            // jmp if Hi(A) > 65535
      cmp   edi, $ff
      mov   edx, $8000
      mov   ecx, $c000
      ja    @@01            // jmp if Hi(A) > 255
      test  edi, edi
      mov   edx, $80
      mov   ecx, $c0
      jnz   @@01            // jmp if Hi(A) > 0

      call  UI32SqrtTest    // ok, eax = @A and Hi(A) = 0
      pop   edi
      ret

@@01: push  esi
      push  eax             // save @A
      mov   esi, [eax]      // esi := Lo(A)

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: xor   edx, ecx
      cmp   edi, edx
      jb    @@03
      sub   edi, edx
      or    edx, ecx
@@03: shr   edx, 1
      shr   ecx, 2
      jnz   @@02

      mov   eax, $80000000
      mov   ecx, $c0000000

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@04: xor   eax, ecx
      cmp   edi, edx
      ja    @@05
      jb    @@06
      cmp   esi, eax
      jb    @@06
@@05: sub   esi, eax
      sbb   edi, edx
      or    eax, ecx
@@06: shr   edx, 1
      rcr   eax, 1
      shr   ecx, 2
      jnz   @@04

      pop   edx             // edx := @A
      or    esi, edi        // set ZF (both null <-> A is a perfect square)
      mov   [edx], eax      // Lo(A) := root
      pop   esi
      setz  al              // Result := ZF
      pop   edi
end;

////////////////////////////////////////////////////////////////////////////////
// Creation/Destruction/Memory management
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Result := Capacity of A
//==============================================================================
function ICapacity(A: PBigInt): SInt32;
begin
  Result := A^.Capacity;
end;

//==============================================================================
// Result := A^.Digits
// Do not use this function... unless you know what you are doing
//==============================================================================
function IDigitsPtr(A: PBigInt): PUInt32Frame;
begin
  Result := A^.Digits;
end;

//==============================================================================
// Free and set A to nil (do nothing if A = nil)
//==============================================================================
procedure IFree(var A: PBigInt);
begin
  if Assigned(A) then
  begin
    ReAllocMem(A^.Digits,0);
    FreeMem(A);
    A := nil;
  end;
end;

//==============================================================================
// Overloaded
// Free and set A and B to nil
//==============================================================================
procedure IFreeMany(var A,B: PBigInt);
begin
  if Assigned(A) then
  begin
    ReAllocMem(A^.Digits,0);
    FreeMem(A);
    A := nil;
  end;
  if Assigned(B) then
  begin
    ReAllocMem(B^.Digits,0);
    FreeMem(B);
    B := nil;
  end;
end;

//==============================================================================
// Overloaded
// Free and set A, B and C to nil
//==============================================================================
procedure IFreeMany(var A,B,C: PBigInt);
begin
  if Assigned(A) then
  begin
    ReAllocMem(A^.Digits,0);
    FreeMem(A);
    A := nil;
  end;
  if Assigned(B) then
  begin
    ReAllocMem(B^.Digits,0);
    FreeMem(B);
    B := nil;
  end;
  if Assigned(C) then
  begin
    ReAllocMem(C^.Digits,0);
    FreeMem(C);
    C := nil;
  end;
end;

//==============================================================================
// Overloaded
// Free and set to nil all the A[i]^'s
//------------------------------------------------------------------------------
// Should be called this way "IFreeMany([@A0,@A1,...])" where the Ai's are
// PBigInt pointers.
//==============================================================================
procedure IFreeMany(const A: array of PPBigInt);
  var
    P : PBigInt;
    i : SInt32;
begin
  for i := High(A) downto 0 do
  begin
    Pointer(P) := Pointer(A[i]^);
    if Assigned(P) then
    begin
      ReAllocMem(P^.Digits,0);
      FreeMem(P);
      A[i]^ := nil;
    end;
  end;
end;

//==============================================================================
// Overloaded
// Free and set to nil all the A^[i]'s
// -> Count, number of big integers to free (A should be sufficiently sized)
//==============================================================================
procedure IFreeMany(const A: PPBigIntFrame; Count: SInt32);
  var P : PBigInt;
begin
  while Count > 0 do
  begin
    Dec(Count);
    Pointer(P) := Pointer(A^[Count]);
    if Assigned(P) then
    begin
      ReAllocMem(P^.Digits,0);
      FreeMem(P);
      A^[Count] := nil;
    end;
  end;
end;

//==============================================================================
// Increase A capacity by ucMinBigIntInc
//------------------------------------------------------------------------------
// The capacity of a bigint doesn't automatically decrease, use IPack to get
// some memory back
//==============================================================================
procedure IIncCapacity(A: PBigInt);
  var NewCapacity : SInt32;
begin
  with A^ do
  begin
    NewCapacity := Capacity + ucMinBigIntInc;

    if UInt32(NewCapacity) > UInt32(gcMaxBigIntSize) then
      NXRaiseSizeError('IIncCapacity');

    ReAllocMem(Digits,NewCapacity*SizeOf(UInt32));
    Capacity := NewCapacity;
  end;
end;

//==============================================================================
// Set A capacity greater than or equal to NewCapacity
// Do nothing if NewCapacity is less than or equal to the current capacity
//------------------------------------------------------------------------------
// The capacity of a BigInt doesn't automatically decrease, use IPack to get
// some memory back
//==============================================================================
procedure IIncCapacityUpTo(A: PBigInt; NewCapacity: SInt32);
begin
  //-- require
  ASSERT(NewCapacity >= 0);

  //-- round the new value upwards modulo ucMinBigIntInc
  NewCapacity := (NewCapacity + (ucMinBigIntInc-1)) and (-ucMinBigIntInc);

  with A^ do
  begin
    if NewCapacity > Capacity then
    begin
      if UInt32(NewCapacity) > UInt32(gcMaxBigIntSize) then
        NXRaiseSizeError('IIncCapacityUpTo');

      ReAllocMem(Digits,NewCapacity*SizeOf(UInt32));
      Capacity := NewCapacity;
    end;
  end;
end;

//==============================================================================
// Create A equal to 0
//==============================================================================
procedure INew(var A: PBigInt);
begin
  //-- require
  ASSERT(not Assigned(A));

  GetMem(A,SizeOf(TBigInt));
  with A^ do
  begin
    Digits := nil;
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Overloaded
// Create A and B equal to 0
//==============================================================================
procedure INewMany(var A,B: PBigInt);
begin
  //-- require
  ASSERT(not Assigned(A));
  ASSERT(not Assigned(B));

  GetMem(A,SizeOf(TBigInt));
  with A^ do
  begin
    Digits := nil;
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
  GetMem(B,SizeOf(TBigInt));
  with B^ do
  begin
    Digits := nil;
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Overloaded
// Create A, B and C equal to 0
//==============================================================================
procedure INewMany(var A,B,C: PBigInt);
begin
  //-- require
  ASSERT(not Assigned(A));
  ASSERT(not Assigned(B));
  ASSERT(not Assigned(C));

  GetMem(A,SizeOf(TBigInt));
  with A^ do
  begin
    Digits := nil;
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
  GetMem(B,SizeOf(TBigInt));
  with B^ do
  begin
    Digits := nil;
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
  GetMem(C,SizeOf(TBigInt));
  with C^ do
  begin
    Digits := nil;
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Overloaded
// Create all the A[i]^'s (equal to 0)
//------------------------------------------------------------------------------
// Should be called this way "INewMany([@A1,@A2,...])" where the Ai's are
// PBigInt pointers set to nil
//==============================================================================
procedure INewMany(const A: array of PPBigInt);
  var
    P : PBigInt;
    i : SInt32;
begin
  //-- require
{$IFDEF NX_DEBUG}
  ASSERT(DistinctPointers2(A)); // all of the A[i] pointers should be distinct
  ASSERT(NilPointers2(A));      // all of the A[i]^ pointers should be nil
{$ENDIF}

{$IFDEF FREE_PASCAL}
  P := nil;
{$ENDIF}
  for i := High(A) downto 0 do
  begin
    GetMem(P,SizeOf(TBigInt));
    with P^ do
    begin
      Digits := nil;
      Capacity := 0;
      Size := 0;
      SignFlag := 0;
    end;
    Pointer(A[i]^) := Pointer(P);
  end;
end;

//==============================================================================
// Overloaded
// Create all the A^[i]'s (equal to 0)
// -> Count, number of BigInts to create (A should be sufficiently sized)
//==============================================================================
procedure INewMany(const A: PPBigIntFrame; Count: SInt32);
  var P : PBigInt;
begin
  //-- require
{$IFDEF NX_DEBUG}
  ASSERT(NilPointers3(A,Count)); // all of the A^[i] pointers should be nil
{$ENDIF}

{$IFDEF FREE_PASCAL}
  P := nil;
{$ENDIF}
  while Count > 0 do
  begin
    GetMem(P,SizeOf(TBigInt));
    with P^ do
    begin
      Digits := nil;
      Capacity := 0;
      Size := 0;
      SignFlag := 0;
    end;
    Dec(Count);
    Pointer(A^[Count]) := Pointer(P);
  end;
end;

//==============================================================================
// Get memory back (if possible)
//==============================================================================
procedure IPack(A: PBigInt);
  var NewCapacity : SInt32;
begin
  with A^ do
  begin
    NewCapacity := (Size + (ucMinBigIntInc-1)) and (-ucMinBigIntInc);
    if Capacity > NewCapacity then
    begin
      ReAllocMem(Digits,NewCapacity*SizeOf(UInt32));
      Capacity := NewCapacity;
    end;
  end;
end;

//==============================================================================
// Overloaded
// Get memory back (if possible)
//==============================================================================
procedure IPackMany(const A: array of PBigInt);
  var i, NewCapacity : SInt32;
begin
  for i := High(A) downto 0 do
  with A[i]^ do
  begin
    NewCapacity := (Size + (ucMinBigIntInc-1)) and (-ucMinBigIntInc);
    if Capacity > NewCapacity then
    begin
      ReAllocMem(Digits,NewCapacity*SizeOf(UInt32));
      Capacity := NewCapacity;
    end;
  end;
end;

//==============================================================================
// Overloaded
// Get memory back (if possible)
//==============================================================================
procedure IPackMany(const A: PPBigIntFrame; Count: SInt32);
  var NewCapacity : SInt32;
begin
  while Count > 0 do
  begin
    Dec(Count);
    with A^[Count]^ do
    begin
      NewCapacity := (Size + (ucMinBigIntInc-1)) and (-ucMinBigIntInc);
      if Capacity > NewCapacity then
      begin
        ReAllocMem(Digits,NewCapacity*SizeOf(UInt32));
        Capacity := NewCapacity;
      end;
    end;
  end;
end;

//-- deprecated
procedure ISetSignFlag(A: PBigInt; NewSignFlag: SInt32);
begin
  with A^ do SignFlag := NewSignFlag and Ord(Size > 0);
end;

//==============================================================================
// Set A^.Size equal to NewSize
// If NewSize > A^.Size then A^.Digits[A^.Size..NewSize-1] is filled with 0s
//------------------------------------------------------------------------------
// After a call to this procedure, A is generally no more normalized. It is up
// to the caller to manage the normalization.
//==============================================================================
procedure ISetSize(A: PBigInt; NewSize: SInt32);
begin
  if UInt32(NewSize) > UInt32(gcMaxBigIntSize) then
    NXRaiseSizeError('ISetSize');

  with A^ do
  begin
    if NewSize > Size then
    begin
      if NewSize > Capacity then IIncCapacityUpTo(A,NewSize);
      FillChar(Digits^[Size],(NewSize-Size)*SizeOf(UInt32),0);
    end;
    Size := NewSize;
  end;
end;

//-- deprecated
function ISignFlag(A: PBigInt): SInt32;
begin
  Result := A^.SignFlag;
end;

//==============================================================================
// Result := Size of A
//==============================================================================
function ISize(A: PBigInt): SInt32;
begin
  Result := A^.Size;
end;

////////////////////////////////////////////////////////////////////////////////
// Normalization
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Result := (A is normalized)
//==============================================================================
function IIsNormalized(A: PBigInt): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      and   ecx, ecx
      jz    @@01

      mov   edx, [eax+TBigInt.Digits]
      lea   edx, [edx+ecx*4-4]
      mov   eax, [edx]
      test  eax, eax
      setne al
      ret

@@01: cmp   ecx, [eax+TBigInt.SignFlag]
      sete  al
end;

//==============================================================================
// Normalize A, i.e., set A such that
// 1) (Size > 0) -> (Digits[Size-1] <> 0)
// 2) (Size = 0) -> (SignFlag = 0)
//==============================================================================
{$IFDEF NX_DEBUG}
procedure INormalizeDebug(A: PBigInt);
{$ELSE}
procedure INormalize(A: PBigInt);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      mov   edx, [eax+TBigInt.Digits]
      test  ecx, ecx
      lea   edx, [edx-4]
      jz    @@02                        // jmp if Size=0

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: cmp   dword ptr [edx+ecx*4], 0    // Digits^[Size-1] > 0?
      jne   @@03                        // if so, jump
      dec   ecx
      jnz   @@01

@@02: mov   [eax+TBigInt.SignFlag], ecx // set to 0 whenever Size=0
@@03: mov   [eax+TBigInt.Size], ecx     // update Size
end;

{$IFDEF NX_DEBUG}
procedure INormalize(A: PBigInt);
begin
  //-- require
  ASSERT(A^.Size >= 0);

  INormalizeDebug(A);
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
// Stream/Files
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Load A from a file
//==============================================================================
procedure ILoadFromFile(A: PBigInt; const FileName: string);
  var
    F : TStream;
    H : TBigIntFileHeader;
begin
  F := TStream.CreateReadFileStream(FileName);
  try
    H := '';
    if F.Read(H,SizeOf(H)) <> SizeOf(H) then Exit;
    if H <> ucBigIntFileHeader then Exit;
    ILoadFromStream(A,F);
    F.Free;
  except
    F.Free;
    NXRaiseFileError('ILoadFromFile',FileName);
  end;
end;

//==============================================================================
// Load A from a stream
// !!! A is not necessarily normalized
//==============================================================================
procedure ILoadFromStream(A: PBigInt; Stream: TStream);
  var
    p : SInt64;
    s : SInt32;
begin
  p := Stream.Position;
  with A^ do
  try
    //-- read Size
    Size := -1;
    if Stream.Read(Size,SizeOf(Size)) <> SizeOf(Size) then Exit;
    if (Size < 0) or (Size > gcMaxBigIntSize) then Exit;

    //-- read SignFlag
    SignFlag := 2; // !!! invalid value
    if Stream.Read(SignFlag,SizeOf(SignFlag)) <> SizeOf(SignFlag) then Exit;
    if UInt32(SignFlag) > 1 then Exit;

    //-- read Digits^
    if Size > Capacity then IIncCapacityUpTo(A,Size); // a monstruosity ;-)
    s := Size * SizeOf(UInt32);
    if Stream.Read(Digits^,s) <> s then Exit;
  except
    ISet0Packed(A); // to return a valid integer in any case
    Stream.Position := p;
    NXRaiseStreamError('ILoadFromStream');
  end;
end;

//==============================================================================
// Save A to a file
//==============================================================================
procedure ISaveToFile(A: PBigInt; const FileName: string);
  var F : TStream;
begin
  F := TStream.CreateWriteFileStream(FileName);
  try
    if F.Write(ucBigIntFileHeader,SizeOf(ucBigIntFileHeader)) <>
                                         SizeOf(ucBigIntFileHeader) then Exit;
    ISaveToStream(A,F);
    F.Free;
  except
    F.Free;
    NXRaiseFileError('ISaveToFile',FileName);
  end;
end;

//==============================================================================
// Save A to a stream
//==============================================================================
procedure ISaveToStream(A: PBigInt; Stream: TStream);
  var
    p : SInt64;
    s : SInt32;
begin
  p := Stream.Position;
  with A^ do
  try
    if Stream.Write(Size,SizeOf(Size)) <> SizeOf(Size) then Exit;
    if Stream.Write(SignFlag,SizeOf(SignFlag)) <> SizeOf(SignFlag) then Exit;
    s := Size * SizeOf(UInt32);
    if Stream.Write(Digits^,s) <> s then Exit;
  except
    Stream.Position := p;
    NXRaiseStreamError('ISaveToStream');
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Miscellaneous (local)
////////////////////////////////////////////////////////////////////////////////

//-- add/sub

//------------------------------------------------------------------------------
// A := A + B (ignoring signs)
//------------------------------------------------------------------------------
procedure AddAbs(A,B: PBigInt);
  var s : SInt32;
begin
  s := B^.Size;
  with A^ do
  begin
    if Size < s then
    begin
      if Capacity < s then IIncCapacityUpTo(A,s+1); // +1 for possible carry
      s := Size;
      Size := B^.Size;
      Move(B^.Digits^[s],Digits^[s],(Size-s)*SizeOf(UInt32));
    end;

    if RawAdd(Digits,B^.Digits,s) = 0 then Exit;

    //-- handle carry
    if Size > s then
      if RawAddUI32(@Digits^[s],Size-s,1) = 0 then Exit;
    if Size = Capacity then IIncCapacity(A);
    Digits^[Size] := 1;
    Inc(Size);
  end;
end;

//------------------------------------------------------------------------------
// A := A - B (ignoring signs)
//------------------------------------------------------------------------------
procedure SubAbs(A,B: PBigInt);
  var i : SInt32;
begin
  //-- require
  ASSERT(ICmpAbs(A,B) > 0);

  with A^ do
  begin
    if RawSub(Digits,B^.Digits,B^.Size) > 0 then
      //-- propagate borrow
      for i := B^.Size to Size-1 do
        if Digits^[i] = 0 then Digits^[i] := $ffffffff
        else
        begin
          Dec(Digits^[i]);
          Break; 
        end;

    //-- normalize
    while Digits^[Size-1] = 0 do Dec(Size); // Size cannot be set to 0
  end;
end;

//------------------------------------------------------------------------------
// A := B - A (ignoring signs)
//------------------------------------------------------------------------------
procedure SubAbsReverse(A,B: PBigInt);
  var i : SInt32;
begin
  //-- require
  ASSERT(ICmpAbs(A,B) < 0);

  with A^ do
  begin
    if Size < B^.Size then
    begin
      if Capacity < B^.Size then IIncCapacityUpTo(A,B^.Size);
      Move(B^.Digits^[Size],Digits^[Size],(B^.Size-Size)*SizeOf(UInt32));

      if RawSubr(Digits,B^.Digits,Size) > 0 then
        //-- propagate borrow
        for i := Size to B^.Size-1 do
          if Digits^[i] = 0 then Digits^[i] := $ffffffff
          else
          begin
            Dec(Digits^[i]);
            Break;
          end;

      Size := B^.Size;
    end
    //-- A^.Size = B^.Size
    else RawSubr(Digits,B^.Digits,Size); // no possible borrow

    //-- normalize
    while Digits^[Size-1] = 0 do Dec(Size); // Size cannot be set to 0
  end;
end;

//-- div/rem

//------------------------------------------------------------------------------
// -> Q, any
// -> R, dividend
// -> D, divisor
// <- Q := R div D
// <- R := R rem D
//------------------------------------------------------------------------------
procedure DivRemStd(Q,R,D: PBigInt);
  var
    D0, R0, Q0, X, Y : PUInt32Frame;
    R4               : PUInt32Frame absolute X; // alias
    Q4               : PUInt32Frame absolute Y; // alias
    sd, sr, sq, i    : SInt32;
    hd, ld           : UInt32;
begin
  //-- require
  ASSERT(Pointer(Q) <> Pointer(R));
  ASSERT(Pointer(Q) <> Pointer(D));
  ASSERT(Pointer(R) <> Pointer(D));
  ASSERT(ICmpAbs(R,D) > 0);
  ASSERT(D^.Size > 1);
  ASSERT((D^.Digits^[D^.Size-1] and $80000000) <> 0);

  //-- get the two most significant digits of the divisor
  sd := D^.Size;
  D0 := D^.Digits;
  hd := D0^[sd-1];
  ld := D0^[sd-2];

  //-- add a leading 0 to R (if needed)
  sr := R^.Size;
  R0 := R^.Digits;
  if hd <= R0^[sr-1] then
  begin
    if R^.Capacity = sr then
    begin
      IIncCapacity(R);
      R0 := R^.Digits; // might have changed
    end;
    R0^[sr] := 0;
    Inc(sr);
  end;

  sq := sr - sd;
  if Q^.Capacity < sq then IIncCapacityUpTo(Q,sq);
  Q0 := Q^.Digits;

  asm
    {$IFDEF DELPHI}
        push  ebx
        push  edi
        push  esi
    {$ENDIF}
        mov   eax, R0
        mov   edx, Q0
        sub   eax, 4
        sub   edx, 4
        mov   R4, eax
        mov   Q4, edx
        mov   eax, sq
        shl   eax, 2

        //-- quotient estimate (QE)
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@02: mov   I, eax           // save I
        mov   edi, sr          // edi := sr
        mov   eax, R4
        mov   esi, hd
        lea   edi, [eax+edi*4]
        mov   edx, [edi]       // edx := R[sr-1]
        cmp   edx, esi         // R[sr-1] = hd?
        je    @@03

        //-- if R[sr-1] < hd then QE := (R[sr-1] << 32 + R[sr-2]) div hd
        mov   eax, [edi-4]
        div   esi              // div hd
        mov   ebx, eax         // ebx (QE) <- eax
        mov   esi, edx         // esi (RE) <- edx (RE is Remainder Estimate)
        mov   eax, ld
        mul   ebx              // edx:eax := ld * QE
        jmp   @@04

        //-- if R[sr-1] = hd then QE := 2**32-1
  @@03: mov   ebx, $ffffffff    // ebx (QE) := 2**32-1
        add   esi, [edi-4]      // esi (RE) := hd + R[sr-2]
        jc    @@07              // if CF=1 then QE ok
        mov   eax, ld
        mov   edx, ld
        neg   eax
        sbb   edx, 0            // edx:eax := ld * QE

        //-- adjust the estimate
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@04: cmp   esi, edx         // RE = hi(QE * ld)?
        ja    @@06             // if > then QE ok
        jb    @@05             // if <
        cmp   eax, [edi-8]     // if =, lo(QE * d1) = R[sr-3]?
        jbe   @@06             //       if <= then QE ok
  @@05: dec   ebx              // QE := QE - 1
        add   esi, hd          // RE := RE + hd
        jc    @@06             // if CF=1 then QE ok
        sub   eax, ld          // eax := lo(QE * ld)
        sbb   edx, 0           // edx := hi(QE * ld)
        jmp   @@04
  @@06: test  ebx, ebx         // QE = 0?
        jz    @@0A             // if so, jmp to End-Main-Loop

        //-- R := (R - D * QE) mod ((sr+1) << 32k)
  @@07: mov   edi, R4
        mov   esi, D0
        add   edi, I           // edi points to R[i-1]
        mov   ecx, sd
        xor   edx, edx         // carry := 0
        push  ebp

    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@08: mov   eax, [esi]       // eax := D[j]
        mov   ebp, edx         // save carry
        mul   ebx              // mul QE
        add   eax, ebp
        adc   edx, 0
        mov   ebp, [edi]
        add   esi, 4
        sub   ebp, eax
        adc   edx, 0
        mov   [edi], ebp
        dec   ecx
        lea   edi, [edi+4]
        jnz   @@08

        cmp   edx, [edi]       // (edx > [edi]) -> (qe is too big by 1)
        pop   ebp
        jbe   @@0A

        //
        // Code part (from here to @@0A) almost never used: proba ~ 2**(-31)
        // Hexa numbers that activate the code
        // -> R = 80000000000000000000000000000000000000000000000000000000
        // -> D = 8000000100000002ffffffff
        // <- R = 7fffffe500000068ffffffe3
        // <- Q = fffffffdfffffffe00000011ffffffe3
        //

        dec   ebx               // QE := QE - 1
        mov   edi, R4
        mov   esi, D0           // esi points to D[0]
        add   edi, I            // edi points to R[i-1]
        xor   edx, edx          // edx := 0 AND CF := 0
        mov   ecx, sd

    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@09: mov   eax, [esi+edx*1]  // eax := D[j]
        adc   [edi+edx*1], eax  // R[j+i-1] := R[j+i-1] + D[j] + CF
        dec   ecx
        lea   edx, [edx+4]
        jnz   @@09

    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@0A: mov   esi, Q4
        mov   eax, I
        mov   [esi+eax*1], ebx  // Q[i-1] := QE
        dec   sr                // decrease the size of R
        sub   eax, 4            // decrease i
        jnz   @@02              // loop while i > 0

    {$IFDEF DELPHI}
        pop   esi
        pop   edi
        pop   ebx
    {$ENDIF}
  end {$IFDEF FREE_PASCAL} ['EAX','EBX','ECX','EDX','EDI','ESI'] {$ENDIF};

  //-- normalize Q (cannot be set to 0)
  while Q0^[sq-1] = 0 do Dec(sq);
  Q^.Size := sq;

  //-- normalize R
  while (sr > 0) and (R0^[sr-1] = 0) do Dec(sr);
  R^.Size := sr;
  if sr = 0 then R^.SignFlag := 0;
end;

//------------------------------------------------------------------------------
// -> R, dividend
// -> D, divisor
// <- R := R rem D
//------------------------------------------------------------------------------
procedure RemStd(R,D: PBigInt);
  var
    D0, R0, X : PUInt32Frame;
    R4        : PUInt32Frame absolute X; // alias
    hd, ld    : UInt32;
    sd, sr, i : SInt32;
begin
  //-- require
  ASSERT(Pointer(R) <> Pointer(D));
  ASSERT(ICmpAbs(R,D) > 0);
  ASSERT(D^.Size > 1);
  ASSERT((D^.Digits^[D^.Size-1] and $80000000) <> 0);

  //-- get the two most significant digits of the divisor
  sd := D^.Size;
  D0 := D^.Digits;
  hd := D0^[sd-1];
  ld := D0^[sd-2];

  //-- add a leading 0 to R (if needed)
  sr := R^.Size;
  R0 := R^.Digits;
  if hd <= R0^[sr-1] then
  begin
    if R^.Capacity = sr then
    begin
      IIncCapacity(R);
      R0 := R^.Digits; // might have changed
    end;
    R0^[sr] := 0;
    Inc(sr);
  end;

  asm
    {$IFDEF DELPHI}
        push  ebx
        push  edi
        push  esi
    {$ENDIF}
        mov   eax, sr
        mov   edx, R0
        sub   eax, sd
        sub   edx, 4
        shl   eax, 2
        mov   R4, edx
        mov   I, eax

        //-- quotient estimate (QE)
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@02: mov   edi, sr           // edi := sr
        mov   eax, R4
        mov   esi, hd
        lea   edi, [eax+edi*4]
        mov   edx, [edi]        // edx := R[sr-1]
        cmp   edx, esi          // R[sr-1] = hd?
        je    @@03

        //-- if R[sr-1] < hd then QE := (R[sr-1] << 32 + R[sr-2]) div hd
        mov   eax, [edi-4]
        div   esi               // div hd
        mov   ebx, eax          // ebx (QE) <- eax
        mov   esi, edx          // esi (RE) <- edx (RE is Remainder Estimate)
        mov   eax, ld
        mul   ebx               // edx:eax := ld * QE
        jmp   @@04

        //-- if R[sr-1] = hd then QE := 2**32-1
  @@03: mov   ebx, $ffffffff    // ebx (QE) := 2**32-1
        add   esi, [edi-4]      // esi (RE) := hd + R[sr-2]
        jc    @@07              // if CF=1 then QE ok
        mov   eax, ld
        mov   edx, ld
        neg   eax
        sbb   edx, 0            // edx:eax := ld * QE

        //-- adjust the quotient estimate
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@04: cmp   esi, edx          // RE = hi(QE * ld)?
        ja    @@06              // if > then QE ok
        jb    @@05              // if <
        cmp   eax, [edi-8]      // if =, lo(QE * ld) = R[sr-3]?
        jbe   @@06              //       if <= then QE ok
  @@05: dec   ebx               // QE := QE - 1
        add   esi, hd           // RE := RE + hd
        jc    @@06              // if CF=1 then QE ok
        sub   eax, ld           // eax := lo(QE * ld)
        sbb   edx, 0            // edx := hi(QE * ld)
        jmp   @@04
  @@06: test  ebx, ebx
        jz    @@0A

        //-- R := (R - D*QE) mod ((sr+1) << 32k)
  @@07: mov   edi, R4
        mov   esi, D0
        add   edi, I            // edi points to R[i-1]
        mov   ecx, sd
        xor   edx, edx          // carry := 0
        push  ebp

    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@08: mov   eax, [esi]        // eax := D[j]
        mov   ebp, edx          // save carry
        mul   ebx               // mul QE
        add   eax, ebp
        adc   edx, 0
        mov   ebp, [edi]
        add   esi, 4
        sub   ebp, eax
        adc   edx, 0
        mov   [edi], ebp
        dec   ecx
        lea   edi, [edi+4]
        jnz   @@08

        cmp   edx, [edi]        // (edx > [edi]) -> (qe is too big by 1)
        pop   ebp
        jbe   @@0A

        //
        // Code part (from here to @@0A) almost never used: proba ~ 2**(-31)
        // Hexa numbers that activate the code
        // -> R = 80000000000000000000000000000000000000000000000000000000
        // -> D = 8000000100000002ffffffff
        // <- R = 7fffffe500000068ffffffe3
        //

        mov   edi, R4
        mov   esi, D0           // esi points to D[0]
        add   edi, I            // edi points to R[i-1]
        xor   edx, edx          // edx := 0 and CF := 0
        mov   ecx, sd

    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@09: mov   eax, [esi+edx*1]  // eax := D[j]
        adc   [edi+edx*1], eax  // R[j+i-1] := R[j+i-1] + D[j] + CF
        dec   ecx
        lea   edx, [edx+4]
        jnz   @@09

    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@0A: dec   sr                // decrease the size of R
        sub   I, 4              // decrease i
        jnz   @@02              // loop while i > 0

    {$IFDEF DELPHI}
        pop   esi
        pop   edi
        pop   ebx
    {$ENDIF}
  end {$IFDEF FREE_PASCAL} ['EAX','EBX','ECX','EDX','EDI','ESI'] {$ENDIF};

  //-- normalize R
  while (sr > 0) and (R0^[sr-1] = 0) do Dec(sr);
  R^.Size := sr;
  if sr = 0 then R^.SignFlag := 0;
end;

//-- gcd

//------------------------------------------------------------------------------
// Result := 63 leading bits of A
//------------------------------------------------------------------------------
function Get63LeadingBits(A: PBigInt): SInt64;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      push  ebx
      cmp   ecx, 2
      mov   ebx, [eax+TBigInt.Digits]
      jg    @@03                      // jmp if Size > 2
      je    @@02                      // jmp if Size = 2
      xor   edx, edx
      test  ecx, ecx
      je    @@01                      // jmp if Size = 0
      mov   eax, [ebx]                // eax := Digits[0]
      pop   ebx
      ret

@@01: mov   eax, edx                  // Result := 0
      pop   ebx
      ret

@@02: mov   eax, [ebx]                // eax := Digits[0]
      mov   edx, [ebx+4]              // edx := Digits[1]
      xor   ebx, ebx
      jmp   @@05

@@03: mov   eax, [ebx+ecx*4-12]       // eax := Digits[Size-3]
      mov   edx, [ebx+ecx*4-8]        // edx := Digits[Size-2]
      mov   ebx, [ebx+ecx*4-4]        // ebx := Digits[Size-1]
      test  ebx, ebx
      je    @@05                      // jmp if ebx = 0
      bsr   ecx, ebx                  // ok, ebx <> 0
      cmp   ecx, 31
      je    @@04                      // jmp if binary size of ebx = 32
      inc   ecx
      shrd  eax, edx, cl              // shift [ebx:edx:eax] -> [0:edx:eax]
      shrd  edx, ebx, cl
      jmp   @@05
@@04: mov   eax, edx                  // mov [ebx:edx:eax] -> [0:edx:eax]
      mov   edx, ebx
@@05: test  edx, edx                  // 32-th bit of edx = 1 ?
      jns   @@06                      // if not, exit
      shr   edx, 1                    // if so, shift [edx:eax] by 1 bit
      rcr   eax, 1
@@06: pop   ebx
end;

//------------------------------------------------------------------------------
// Partial Euclid (Lehmer-Collins method).
//------------------------------------------------------------------------------
// See PhD thesis by Reynald Lercier (in French): "Algorithmique des Courbes
// Elliptiques dans les Corps Finis", pages 143-172.
// ftp://lix.polytechnique.fr/pub/lercier/papers/these.ps.Z
//------------------------------------------------------------------------------
function LCPartial(out m: SInt32x4; A,B: PBigInt): Boolean;
  var
    aa, bb, a0, b0, a1, b1, a2, b2 : SInt64;
    sa, sb, s                      : SInt32;
begin
  //-- require
  ASSERT(ICmp(A,B) > 0);
  ASSERT(IIsPositiveOrNull(B));

  if B^.Size = 0 then
  begin
    Result := false;
    Exit;
  end;

  //-- Initializations
  //    k := Max[BitSize(A)-63, 0]
  //   aa := A shr k
  //   bb := B shr k
  sa := IBitSize(A);
  sb := IBitSize(B);
  if sa > 63 then
  begin
    s := sa - sb;
    if s < 63 then
    begin
      if sb < 63 then s := sa - 63;
      aa := Get63LeadingBits(A);
      bb := Get63LeadingBits(B) shr s;
    end
    else
    begin
      Result := false;
      Exit;
    end;
  end
  else
  begin
    with UInt32x2(aa) do
    begin
      Lo := A^.Digits^[0];
      if sa > 32 then Hi := PUInt32x2(A^.Digits)^.Hi else Hi := 0;
    end;
    with UInt32x2(bb) do
    begin
      Lo := B^.Digits^[0];
      if sb > 32 then Hi := PUInt32x2(B^.Digits)^.Hi else Hi := 0;
    end;
  end;

  a0 := 1;
  a1 := 0;
  b0 := 0;
  b1 := 1;

  asm
    {$IFDEF DELPHI}
        push  edi
        push  esi
        push  ebx
    {$ENDIF}
        mov   esi, dword ptr bb[4]
        mov   edi, dword ptr bb[0]
        mov   ecx, esi
        or    ecx, edi
        jz    @@0B                  // exit asm block if bb = 0

        //-- here, aa > bb > 0 (thus r and q non-negative)
        //   r := aa mod bb
        //   q := aa div bb (q is not computed)

        //-- MAIN LOOP
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@00: mov   edx, dword ptr aa[4]  // t := aa/2
        mov   eax, dword ptr aa[0]
        shr   edx, 1
        rcr   eax, 1
        xor   ecx, ecx              // ecx is a counter for the division loops
        jmp   @@02

        //-- 1ST DIVISION LOOP
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@01: add   edi, edi
        adc   esi, esi              // bb := bb*2 (bit #63 of b never set to 1)
        inc   ecx
  @@02: cmp   esi, edx
        jb    @@01                  // jmp if Hi(bb) < Hi(t)  ( -> bb <= t)
        ja    @@03                  // jmp if Hi(bb) > Hi(t)
        cmp   edi, eax
        jbe   @@01                  // jmp if Lo(bb) <= Lo(t) ( -> bb <= t)
        //-- END 1ST DIVISION LOOP

  @@03: mov   s, ecx
        mov   ebx, dword ptr aa[0]
        mov   ecx, dword ptr aa[4]
        sub   ebx, edi
        sbb   ecx, esi              // [ebx:ecx] is r := aa-bb (r >= 0)
        xor   eax, eax
        xor   edx, edx
        sub   eax, dword ptr a1[0]
        sbb   edx, dword ptr a1[4]
        mov   dword ptr a2[0], eax
        mov   dword ptr a2[4], edx  // a2 := -a1
        xor   eax, eax
        xor   edx, edx
        sub   eax, dword ptr b1[0]
        sbb   edx, dword ptr b1[4]
        mov   dword ptr b2[0], eax
        mov   dword ptr b2[4], edx  // b2 := -b1
        cmp   s, 0
        je    @@07

        //-- 2ND DIVISION LOOP
    {$IFDEF FREE_PASCAL}
        align 4
    {$ENDIF}
  @@04: shr   esi, 1
        rcr   edi, 1                // bb := bb / 2

        mov   eax, dword ptr a2[0]
        mov   edx, dword ptr a2[4]
        add   eax, eax
        adc   edx, edx
        mov   dword ptr a2[0], eax
        mov   dword ptr a2[4], edx  // a2 := a2 * 2
        mov   eax, dword ptr b2[0]
        mov   edx, dword ptr b2[4]
        add   eax, eax
        adc   edx, edx
        mov   dword ptr b2[0], eax
        mov   dword ptr b2[4], edx  // b2 := b2 * 2
        cmp   esi, ecx
        ja    @@06                  // jmp if Hi(bb) > Hi(r)  ( -> bb > r)
        jb    @@05                  // jmp if Hi(bb) < Hi(r)
        cmp   edi, ebx
        ja    @@06                  // jmp if Lo(bb) > Lo(r)  ( -> bb > r)
  @@05: mov   eax, dword ptr a2[0]
        mov   edx, dword ptr a2[4]
        sub   eax, dword ptr a1[0]
        sbb   edx, dword ptr a1[4]
        mov   dword ptr a2[0], eax
        mov   dword ptr a2[4], edx  // a2 := a2 - a1
        mov   eax, dword ptr b2[0]
        mov   edx, dword ptr b2[4]
        sub   eax, dword ptr b1[0]
        sbb   edx, dword ptr b1[4]
        mov   dword ptr b2[0], eax
        mov   dword ptr b2[4], edx  // b2 := b2 - b1
        sub   ebx, edi
        sbb   ecx, esi              // r := r - bb
  @@06: dec   s
        jnz   @@04
        //-- END 2ND DIVISION LOOP

  @@07: mov   eax, dword ptr a0[0]
        mov   edx, dword ptr a0[4]
        add   eax, dword ptr a2[0]
        adc   edx, dword ptr a2[4]
        mov   dword ptr a2[0], eax
        mov   dword ptr a2[4], edx  // a2 := a2 + a0
        mov   eax, dword ptr b0[0]
        mov   edx, dword ptr b0[4]
        add   eax, dword ptr b2[0]
        adc   edx, dword ptr b2[4]
        mov   dword ptr b2[0], eax
        mov   dword ptr b2[4], edx  // b2 := b2 + b0
        js    @@08
        neg   eax
        adc   edx, 0
        neg   edx                   // [eax:edx] := -|b2|
  @@08: add   eax, ebx
        adc   edx, ecx
        js    @@0B                  // exit asm block if r-|b2| < 0
  @@09: mov   eax, dword ptr b1[0]
        mov   edx, dword ptr b1[4]
        sub   eax, dword ptr b2[0]
        sbb   edx, dword ptr b2[4]
        js    @@0A
        neg   eax
        adc   edx, 0
        neg   edx                   // [eax:edx] := -|b1-b2|
  @@0A: add   eax, edi
        adc   edx, esi
        sub   eax, ebx
        sbb   edx, ecx
        js    @@0B                  // exit asm block if (bb - r - |b1-b2|) < 0

        mov   dword ptr aa[0], edi
        mov   dword ptr aa[4], esi  // aa := bb
        mov   eax, dword ptr a1[0]
        mov   edx, dword ptr a1[4]
        mov   dword ptr a0[0], eax
        mov   dword ptr a0[4], edx  // a0 := a1
        mov   eax, dword ptr a2[0]
        mov   edx, dword ptr a2[4]
        mov   dword ptr a1[0], eax
        mov   dword ptr a1[4], edx  // a1 := a2
        mov   edi, ebx
        mov   esi, ecx              // bb := r
        mov   eax, dword ptr b1[0]
        mov   edx, dword ptr b1[4]
        mov   dword ptr b0[0], eax
        mov   dword ptr b0[4], edx  // b0 := b1
        mov   eax, dword ptr b2[0]
        mov   edx, dword ptr b2[4]
        mov   dword ptr b1[0], eax
        mov   dword ptr b1[4], edx  // b1 := b2
        or    ecx, ebx
        jnz   @@00                  // loop while bb <> 0

        //-- END MAIN LOOP
  @@0B:
    {$IFDEF DELPHI}
        pop   ebx
        pop   esi
        pop   edi
    {$ENDIF}
  end {$IFDEF FREE_PASCAL} ['EAX','EBX','ECX','EDX','EDI','ESI'] {$ENDIF};

  if (UInt32x2(b0).Hi or UInt32x2(b0).Lo) <> 0 then
  begin
    m.i0 := SInt32(a0);
    m.i1 := SInt32(a1);
    m.i2 := SInt32(b0);
    m.i3 := SInt32(b1);

    //-- check whether the change of type didn't modify the values
    ASSERT(SInt64(m.i0) = a0);
    ASSERT(SInt64(m.i1) = a1);
    ASSERT(SInt64(m.i2) = b0);
    ASSERT(SInt64(m.i3) = b1);

    Result := true;
  end
  else Result := false;
end;

//------------------------------------------------------------------------------
// -> X, integer to inverse
// -> N, modulus
// <- X such that X = 1/X mod N or X = 0 if gcd(X,N) <> 1
// <- Result, TRUE if X is invertible modulo N, FALSE otherwise
//------------------------------------------------------------------------------
function LCInvMod(X,N: PBigInt): Boolean;
  var
    D, E, Y, S, T : PBigInt;
    m             : SInt32x4;
    z             : SInt32;
    a, b          : UInt32;
begin
  //-- require
  ASSERT(Pointer(X) <> Pointer(N));
  ASSERT(IIsPositive(X));
  ASSERT(ICmp(X,N) < 0);

  if X^.Size = 1 then
  begin
    case X^.Digits^[0] of
      1: Result := true;

      2: if (N^.Size > 0) and ((N^.Digits^[0] and 1) > 0) then // N odd?
         begin
           ISet(X,N);
           IShr1(X);
           IInc(X); // N = 2k+1 -> 2**(-1) = k+1
           Result := true;
         end
         else
         begin
           X^.Size := 0;
           Result := false;
         end;

      3: begin
           a := IMod3(N);
           if a > 0 then
           begin
             //-- if a = 1 then 3**(-1) mod N = (2N+1)/3
             //   if a = 2 then 3**(-1) mod N =  (N+1)/3
             ISet(X,N);
             if a = 1 then IShl1(X);
             IInc(X);
             IDivExactUI32(X,3);
             Result := true;
           end
           else
           begin
             X^.Size := 0;
             Result := false;
           end;
         end;

      else // here, (X > 3) and (X < 2**32)
      //-- X**(-1) mod N = (((-N)**(-1) mod X)*N + 1)/X
      a := X^.Digits^[0];
      //-- the casts compel FPC 2.2.0 and higher to produce efficient code
      b := UI32InvMod(UInt32(SInt32(a) - SInt32(IModUI32(N,a))),a);
      if b > 0 then
      begin
        ISet(X,N);
        IMulUI32(X,b);
        IInc(X);
        IDivExactUI32(X,a);
        Result := true;
      end
      else
      begin
        X^.Size := 0;
        Result := false;
      end;
    end; // "case of"

    Exit;
  end;

  //-- Lehmer-Collins modular inversion
  z := IStackGetMany([@D,@E,@Y,@S,@T]);
  try
    ISet(D,N);
    ISwp(E,X);
    ISet1(Y);

    repeat
      if LCPartial(m,D,E) then // ok, 0 < E < D
      begin
        //-- D' := m0 D + m2 E
        //   E' := m1 D + m3 E
        ISet(S,D);
        ISet(T,E);
        IMulSI32(D,m.i0);
        IMulSI32(S,m.i1);
        IMulSI32(T,m.i2);
        IMulSI32(E,m.i3);
        IAdd(D,T);
        IAdd(E,S);
        //-- X' := m0 X + m2 Y
        //   Y' := m1 X + m3 Y
        ISet(S,X);
        ISet(T,Y);
        IMulSI32(X,m.i0);
        IMulSI32(S,m.i1);
        IMulSI32(T,m.i2);
        IMulSI32(Y,m.i3);
        IAdd(X,T);
        IAdd(Y,S);
      end
      else
      begin // here, m0 = 0, m1 = 1, m2 = 1, m3 = -(D div E)
        //-- D' := E
        //   E' := D - (D div E)*E
        IDivRem(S,T,D,E); // S := D div E, T := D rem E
        ISwp(T,D);
        ISwp(D,E);
        //-- X' := Y
        //   Y' := X - (D div E)*Y
        ISwp(X,Y);
        IMul(S,X);
        ISub(Y,S);
      end;
    until E^.Size = 0;

    //-- finalization
    if (D^.Size = 1) and (D^.Digits^[0] = 1) then // if GCD(X,N) = 1
    begin
      if X^.SignFlag <> 0 then IAdd(X,N); // so that X is positive
      Result := true;
    end
    else
    begin
      with X^ do
      begin
        Size := 0;
        SignFlag := 0;
      end;
      Result := false;
    end;
  finally
    IStackRestore(z);
  end;
end;

//------------------------------------------------------------------------------
// Lehmer-Collins extended GCD
// -> A,B
// <- D = GCD(A,B) (D is always positive)
// <- X,Y, such that D = AX + BY
//------------------------------------------------------------------------------
procedure LCXGCD(D,X,Y,A,B: PBigInt);
  var
    E, S, T : PBigInt;
    m       : SInt32x4;
    z       : SInt32;
begin
  //-- require
  ASSERT(Pointer(D) <> Pointer(X));
  ASSERT(Pointer(D) <> Pointer(Y));
  ASSERT(Pointer(D) <> Pointer(A));
  ASSERT(Pointer(D) <> Pointer(B));
  ASSERT(Pointer(X) <> Pointer(Y));
  ASSERT(Pointer(X) <> Pointer(A));
  ASSERT(Pointer(X) <> Pointer(B));
  ASSERT(Pointer(Y) <> Pointer(A));
  ASSERT(Pointer(Y) <> Pointer(B));
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(IIsPositive(A));
  ASSERT(ICmp(A,B) < 0);

  z := IStackGetMany(E,S,T);
  try
    ISet(E,A);
    ISet(D,B);
    with X^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    ISet1(Y);

    repeat
      if LCPartial(m,D,E) then // ok, 0 < E < D
      begin
        //-- D' := m0 D + m2 E
        //   E' := m1 D + m3 E
        ISet(S,D);
        ISet(T,E);
        IMulSI32(D,m.i0);
        IMulSI32(S,m.i1);
        IMulSI32(T,m.i2);
        IMulSI32(E,m.i3);
        IAdd(D,T);
        IAdd(E,S);
        //-- X' := m0 X + m2 Y
        //   Y' := m1 X + m3 Y
        ISet(S,X);
        ISet(T,Y);
        IMulSI32(X,m.i0);
        IMulSI32(S,m.i1);
        IMulSI32(T,m.i2);
        IMulSI32(Y,m.i3);
        IAdd(X,T);
        IAdd(Y,S);
      end
      else
      begin // here, m0 = 0, m1 = 1, m2 = 1, m3 = -(D div E)
        //-- D' := E
        //   E' := D - (D div E)*E
        IDivRem(S,T,D,E); // S := D div E, T := D rem E
        ISwp(T,D);
        ISwp(D,E);
        //-- X' := Y
        //   Y' := X - (D div E)*Y
        ISwp(X,Y);
        IMul(S,X);
        ISub(Y,S);
      end;
    until E^.Size = 0;
  finally
    IStackRestore(z);
  end;

  //-- Y := (D - AX)/B
  IMulTo(Y,A,X);
  ISubr(Y,D);
  IDiv(Y,B);
end;

//-- mul

//------------------------------------------------------------------------------
// -> A
// -> B
// <- R = A*B
//------------------------------------------------------------------------------
procedure MultiplyTo(R,A,B: PBigInt);
   var
     dx, dy, dr, dw, d : PUInt32Frame;
     sx, sy, sr, s, t  : SInt32;
     Carry             : UInt32;
begin
  //-- require
  ASSERT(Pointer(R) <> Pointer(A));
  ASSERT(Pointer(R) <> Pointer(B));
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(A^.Size >= gcKarMulThreshold);
  ASSERT(B^.Size >= gcKarMulThreshold);

  //-- X := Max(A,B), Y := Min(A,B) (Max and Min according to the size)
  if A^.Size < B^.Size then
  begin
    sx := B^.Size;
    dx := B^.Digits;
    sy := A^.Size;
    dy := A^.Digits;
  end
  else
  begin
    sx := A^.Size;
    dx := A^.Digits;
    sy := B^.Size;
    dy := B^.Digits;
  end;

  // here, sx >= sy

  sr := sx + sy;
  if R^.Capacity < sr then IIncCapacityUpTo(R,sr);
  RawMulTo(R^.Digits,dx,dy,sy);

  if sx > sy then // if equal, the work is done
  begin
    dr := @R^.Digits^[sy];
    Inc(dx,sy);
    Dec(sx,sy);
    s := sy;
    if sx < sy then
    begin
      t := sx; sx := sy; sy := t;
      d := dx; dx := dy; dy := d;
    end;

  {$IFDEF FREE_PASCAL}
    dw := nil;
  {$ENDIF}
    if sy >= gcKarMulThreshold then
      GetMem(dw,sy shl 3)
    else
      GetMem(dw,(sx+sy) shl 2);
    try
      Carry := 0;
      while sy >= gcKarMulThreshold do
      begin
        RawMulTo(dw,dx,dy,sy);
        t := sy shl 1;
        if s > t then
          Inc(Carry,RawAddUI32(@dr^[t],s-t,RawAdd(dr,dw,t)))
        else
        begin
          Inc(Carry,RawAdd(dr,dw,s));
          if s < t then
          begin
            Move(dw^[s],dr^[s],(t-s) shl 2);
            Carry := RawAddUI32(@dr^[s],t-s,Carry);
            s := t;
          end;
        end;

        Inc(dr,sy);
        Inc(dx,sy);
        Dec(sx,sy);
        Dec(s,sy);
        if sx < sy then
        begin
          t := sx; sx := sy; sy := t;
          d := dx; dx := dy; dy := d;
        end;
      end;

      if sy > 0 then
      begin
        RawMulStdTo(dw,dx,dy,sx,sy);
        t := sx + sy;
        if s > t then
          RawAddUI32(@dr^[t],s-t,RawAdd(dr,dw,t))
        else
        begin
          Inc(Carry,RawAdd(dr,dw,s));
          if s < t then
          begin
            Move(dw^[s],dr^[s],(t-s) shl 2);
            RawAddUI32(@dr^[s],t-s,Carry);
          end;
        end;
      end;
    finally
      FreeMem(dw);
    end;
  end;

  with R^ do
  begin
    Dec(sr,Ord(Digits^[sr-1] = 0));
    Size := sr;
    SignFlag := A^.SignFlag xor B^.SignFlag; // ok, sr > 0
  end;
end;

//-- powmod

//------------------------------------------------------------------------------
// <- A := A**E mod B
//------------------------------------------------------------------------------
procedure PowMod(A,E,B: PBigInt; DivType: TDivType);
  var
    T                            : array [0..gcWindowMaxSize-1] of PBigInt;
    D, L                         : PBigInt;
    z, i, es, ws, ts, f, g, h, s : SInt32;
    m, u                         : UInt32;
  //--------------------------------------------------------------------------
  function GetBestDivType: TDivType;
  begin
    with B^ do
    //-- no Montgomery if B is even (here, B > 0)
    if (Digits^[0] and 1) = 0 then
      if Size < gcPowModBEvenRecThreshold then
        Result := dtStandard
      else
        Result := dtReciprocal
    else
    //-- can use Montgomery
    if Size < gcPowModMonThreshold then
      Result := dtStandard
    else
    if Size < gcPowModRecThreshold then
      Result := dtMontgomery
    else
      Result := dtReciprocal;
  end;
  //--------------------------------------------------------------------------
  procedure Reduce(X: PBigInt);
  begin
    case DivType of
      dtMontgomery: IMontgomeryReduce(X,B,u);
      dtReciprocal: IReciprocalMod(X,B,D);
      else
      //-- standard division
      case ICmpAbs(X,D) of
        //-- X = D
        0: X^.Size := 0; // ok, SignFlag = 0
        //-- X > D
        1: if D^.Size > 1 then
             RemStd(X,D)
           else
           with X^ do
           begin
             Digits^[0] := RawModUI32(Digits,Size,D^.Digits^[0]);
             Size := Ord(Digits^[0] > 0); // ok, SignFlag = 0
           end;
        //-- X < D
        else; // nothing
      end;
    end;
  end;
  //--------------------------------------------------------------------------
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(E));
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(Pointer(E) <> Pointer(B));
  ASSERT(ICmpUI32(A,2) >= 0);
  ASSERT(ICmpAbsUI32(E,2) >= 0); // do not take the sign in account
  ASSERT(ICmp(A,B) < 0); // imply B >= 3
  ASSERT((DivType <> dtMontgomery) or IIsOdd(B));

  //-- select the division type (if not defined)
  if DivType = dtUndefined then DivType := GetBestDivType;

  //-- select the window size in 1..8
  es := IBitSize(E);
  with E^ do ws := NXGetWindowSize(es,RawWeight(Digits,Size));

  z := IStackIndex;
  try
    //-- setup
    case DivType of
      dtStandard:
      begin
        //-- adjust the modulus for standard division
        with B^ do s := 32 - UI32BitSize(Digits^[Size-1]);
        if s > 0 then
        begin
          IStackGet(D);
          ISet(D,B);
          IShl(D,s);
        end
        else Pointer(D) := Pointer(B); // alias
      end;

      dtMontgomery:
      begin
        //-- Montgomery setup
        u := -UI32InvMod2pow32(B^.Digits^[0]);
        IShl(A,B^.Size shl 5);
        IMod(A,B);

      {$IFDEF DELPHI}
        s := 0; // to avoid DELPHI warning
      {$ENDIF}
      end;

      dtReciprocal:
      begin
        //-- generalized reciprocal stuff
        IStackGet(D);
        IReciprocalSetup(D,B);

      {$IFDEF DELPHI}
        s := 0; // to avoid DELPHI warning
      {$ENDIF}
      end;

      else
      NXRaiseInvalidArg('PowMod',esInvalid_DivType_value);

    {$IFDEF DELPHI}
      s := 0; // to avoid DELPHI warning
    {$ENDIF}
    end;

    //-- main stuff
    if ws > 1 then // use windows
    begin
      //-- round exponent binary size upwards modulo ws
      i := es mod ws;
      if i > 0 then Inc(es,ws-i);

      //-- init T
      ts := 1 shl (ws - 1);
      IStackGetMany(@T[0],ts);

      //-- T := [A, A**3, ..., A**(2**ws-1)]
      ISwp(A,T[0]);
      ISqrTo(A,T[0]);
      Reduce(A);
      for i := 1 to ts-1 do
      begin
        IMulTo(T[i],T[i-1],A);
        Reduce(T[i]);
      end;

      //-- 1st exponent part
      Dec(es,ws);
      f := IExtractBits(E,es,ws);
      NXGetWindowIndices(g,h,f); // split f as 2**g * (2h + 1)
      ISet(A,T[h]);
      for i := 1 to g do
      begin
        ISqr(A);
        Reduce(A);
      end;

      //-- next exponent parts
      while es > 0 do
      begin
        Dec(es,ws);
        f := IExtractBits(E,es,ws);
        if f = 0 then g := ws
        else
        begin
          NXGetWindowIndices(g,h,f);
          for i := 1 to ws-g do
          begin
            ISqr(A);
            Reduce(A);
          end;
          IMul(A,T[h]);
          Reduce(A);
        end;
        for i := 1 to g do
        begin
          ISqr(A);
          Reduce(A);
        end;
      end;
    end
    else // ws <= 1 (don't use window method)
    if A^.Size > 1 then
    begin
      IStackGet(L);
      ISet(L,A);
      for i := es-2 downto 0 do
      begin
        ISqr(A);
        Reduce(A);
        if IBit(E,i) then
        begin
          IMul(A,L);
          Reduce(A);
        end;
      end;
    end
    else // A^.Size = 1
    begin
      m := A^.Digits^[0];

  {$IFDEF NX_LOCATE_TODO_NOTES}
    {$MESSAGE 'Do not forget me'}
  {$ENDIF}
      //
      // * Should check whether m is a power of 2?
      //

      for i := es-2 downto 0 do
      begin
        ISqr(A);
        Reduce(A);
        if IBit(E,i) then
        begin
          IMulUI32(A,m);
          Reduce(A);
        end;
      end;
    end;

    //-- finalize the resulting value
    if DivType = dtMontgomery then
    begin
      IMontgomeryReduce(A,B,u);
      if ICmpAbs(A,B) >= 0 then ISub(A,B);
    end
    else
    if (DivType = dtStandard) and (s > 0) then
    begin
      IShl(A,s);
      IMod(A,D);
      IShr(A,s);
    end;
  finally
    IStackRestore(z);
  end;
end;

//-- rotation

//------------------------------------------------------------------------------
// Rotation to the left by Shift bits on BitCount bits.
// N is regarded as a BitCount-bit sized integer (i.e., leading zeroes are
// possibly taken in account).
//------------------------------------------------------------------------------
procedure RotateLeft(N: PBigInt; BitCount,Shift: SInt32);
  var
    X : PBigInt;
    z : SInt32;
begin
  //-- require
  ASSERT(BitCount > Shift);

{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Rotate without using a temporary bigint (if possible)
  //

  z := IStackGet(X);
  try
    ISet(X,N);
    Dec(BitCount,Shift);
    ICut(N,BitCount);
    IShr(X,BitCount);
    IShl(N,Shift);
    IOr(N,X);
  finally
    IStackRestore(z);
  end;
end;

//-- square rooting

//------------------------------------------------------------------------------
// Compute recursively
//   S := A**(1/2)
//   R := A - S**2
// Written by Wolfgang Ehrhardt
// http://home.netsurf.de/wolfgang.ehrhardt/
//------------------------------------------------------------------------------
// Based on a P. Zimmermann's paper : Karatsuba Square Root, INRIA Research
// Report RR-3805, http://www.inria.fr/rrrt/rr-3805.html
//------------------------------------------------------------------------------
procedure SqrtRem(S,R,A: PBigInt);
  var
    Q, U : PBigInt;
    z, t : SInt32;
begin
  //-- require
  ASSERT(Pointer(S) <> Pointer(R));
  ASSERT(Pointer(S) <> Pointer(A));
  ASSERT(Pointer(R) <> Pointer(A));
  ASSERT(A^.SignFlag = 0);

  //-- use ISqrt for sizes below 16
  if A^.Size < 16 then
  begin
    ISet(S,A);
    if ISqrt(S) then
      R^.Size := 0 // A is perfect square, set R := 0
    else
    begin
      //-- R := A - S**2
      ISqrTo(R,S);
      ISubr(R,A);
    end;
    Exit;
  end;

  //
  // no need to set a try..finally block, the stack index was saved by ISqrtRem
  //

  z := IStackGetMany(Q,U);

  //-- use b = 2**t, t = bitsize(A) div 4
  t := IBitSize(A) shr 2;

  //-- a_3*b + a_2 = Q = A div b**2 = A shr 2t
  ISet(Q,A);
  IShr(Q,t+t);

  //-- (S,R) = SqrtRem(a_3*b + a_2)
  SqrtRem(S,R,Q);

  //-- Q = a_1 = (A shr t) mod 2**t
  ISet(Q,A);
  IShr(Q,t);
  ICut(Q,t);

  //-- R*b + a_1
  IShl(R,t);
  IAdd(R,Q);
  IShl1(S); // shift left 1 here to avoid another temp. var for IDivRem

  //-- (Q,U) = DivRem(R*b + a_1, 2S)
  IDivRem(Q,U,R,S);

  //-- S = S*b + Q
  IShl(S,Pred(t)); // Pred() to compensate for IShl1(S)
  IAdd(S,Q);

  //-- R = U*b - Q**2 + a_0,  a_0 = A mod 2**t
  ISet(R,U);
  IShl(R,t);
  ISqr(Q);
  ISub(R,Q);
  ISet(Q,A);
  ICut(Q,t);
  IAdd(R,Q);

  if R^.SignFlag <> 0 then // R < 0
  begin
    //-- R = R + 2S - 1
    IAdd(R,S);
    IAdd(R,S);
    IDec(R);
    //-- S = S - 1
    IDec(S);
  end;

  IStackRestore(z);
end;

////////////////////////////////////////////////////////////////////////////////
// Miscellaneous (public)
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// A := |A|
//==============================================================================
procedure IAbs(A: PBigInt);
begin
  A^.SignFlag := 0;
end;

//==============================================================================
// A := A + B
//==============================================================================
procedure IAdd(A,B: PBigInt);
begin
  with A^ do
  if SignFlag = B^.SignFlag then AddAbs(A,B)
  else
  case ICmpAbs(A,B) of
    0: begin
         Size := 0;
         SignFlag := 0;
       end;
    1: SubAbs(A,B); // A := Sign(A) * (|A| - |B|)
    else
    //-- A := Sign(B) * (|B| - |A|)
    SubAbsReverse(A,B);
    SignFlag := B^.SignFlag; // ok, A^.Size > 0
  end;
end;

//==============================================================================
// A := A + |B|
//==============================================================================
procedure IAddAbs(A,B: PBigInt);
begin
  with A^ do
  if SignFlag = 0 then AddAbs(A,B)
  else
  case ICmpAbs(A,B) of
    0: begin
         Size := 0;
         SignFlag := 0;
       end;
    1: SubAbs(A,B); // A := -(|A| - |B|)
    else
    //-- A := +(|B| - |A|)
    SubAbsReverse(A,B);
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := A + B*C
//==============================================================================
procedure IAddMul(A,B,C: PBigInt);
  var
    T : PBigInt;
    z : SInt32;
begin
  z := IStackGet(T);
  try
    IMulTo(T,B,C);
    IAdd(A,T);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A + B*C
//==============================================================================
procedure IAddMulSI32(A,B: PBigInt; C: SInt32);
  var
    T : PBigInt;
    z : SInt32;
begin
{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Rewrite without temp. bigint
  //

  z := IStackGet(T);
  try
    ISet(T,B);
    IMulSI32(T,C);
    IAdd(A,T);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A + B*C
//==============================================================================
procedure IAddMulSI64(A,B: PBigInt; const C: SInt64);
  var
    T : PBigInt;
    z : SInt32;
begin
  z := IStackGet(T);
  try
    ISet(T,B);
    IMulSI64(T,C);
    IAdd(A,T);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A + B*C
//==============================================================================
procedure IAddMulUI32(A,B: PBigInt; C: UInt32);
  var
    T : PBigInt;
    z : SInt32;
begin
{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Rewrite without temp. bigint
  //

  z := IStackGet(T);
  try
    ISet(T,B);
    IMulUI32(T,C);
    IAdd(A,T);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A + B*C
//==============================================================================
procedure IAddMulUI64(A,B: PBigInt; const C: UInt64);
  var
    T : PBigInt;
    z : SInt32;
begin
  z := IStackGet(T);
  try
    ISet(T,B);
    IMulUI64(T,C);
    IAdd(A,T);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A + B
//==============================================================================
procedure IAddSI32(A: PBigInt; B: SInt32);
begin
  if B < 0 then ISubUI32(A,-B) else IAddUI32(A,B);
end;

//==============================================================================
// A := A + B
//==============================================================================
procedure IAddSI64(A: PBigInt; B: SInt64);
begin
  if SInt32x2(B).Hi < 0 then ISubUI64(A,-B) else IAddUI64(A,B);
end;

//==============================================================================
// R := A + B
//==============================================================================
procedure IAddTo(R,A,B: PBigInt);
begin
  if Pointer(R) = Pointer(A) then
  begin
    IAdd(R,B);
    Exit;
  end;

  if Pointer(R) = Pointer(B) then
  begin
    IAdd(R,A);
    Exit;
  end;

  if A^.Size >= B^.Size then
  begin
    ISet(R,A);
    IAdd(R,B);
  end
  else
  begin
    ISet(R,B);
    IAdd(R,A);
  end;
end;

//==============================================================================
// A := A + B
//==============================================================================
procedure IAddUI32(A: PBigInt; B: UInt32);
begin
  with A^ do
  if SignFlag = 0 then // A >= 0
  begin
    B := RawAddUI32(Digits,Size,B);
    if B <> 0 then
    begin
      if Size = Capacity then IIncCapacity(A);
      Digits^[Size] := B;
      Inc(Size);
    end;
  end
  else // A < 0
  begin
    if RawSubUI32(Digits,Size,B) <> 0 then // (borrow <> 0) -> (Size = 1)
    begin
      Digits^[0] := -Digits^[0];
      SignFlag := 0; // negate
    end
    else
    if Digits^[Size-1] = 0 then
    begin
      Dec(Size);
      SignFlag := Ord(Size > 0); // negate if Size = 0
    end;
  end;
end;

//==============================================================================
// A := A + B
//==============================================================================
procedure IAddUI64(A: PBigInt; B: UInt64);
  var
    T : PBigInt;
    z : SInt32;
begin
  with UInt32x2(B) do
  if Hi > 0 then
  begin
    z := IStackGet(T);
    try
      ISetUI64(T,B);
      IAdd(A,T);
    finally
      IStackRestore(z);
    end;
  end
  else
  if Lo > 0 then IAddUI32(A,Lo);
end;

//==============================================================================
// A := A and B
// A^.SignFlag := A^.SignFlag and B^.SignFlag, or 0 if A is set to 0
//==============================================================================
procedure IAnd(A,B: PBigInt);
begin
  with A^ do
  begin
    if Size > B^.Size then Size := B^.Size;
    RawAnd(Digits,B^.Digits,Size);
    SignFlag := SignFlag and B^.SignFlag;
  end;
  INormalize(A);
end;

//==============================================================================
// Result := A if possible (see IIsSI32)
//==============================================================================
function IAsSI32(A: PBigInt; CheckRange: Boolean = true): SInt32;
begin
  with A^ do
  if Size > 0 then
  begin
    if CheckRange and (not IIsSI32(A)) then NXRaiseRangeError('IAsSI32');

    Result := SInt32(Digits^[0]);
    if SignFlag <> 0 then Result := -Result;
  end
  else Result := 0;
end;

//==============================================================================
// Result := A if possible (see IIsSI64)
//==============================================================================
function IAsSI64(A: PBigInt; CheckRange: Boolean = true): SInt64;
begin
  with A^ do
  if Size > 0 then
  begin
    if CheckRange and (not IIsSI64(A)) then NXRaiseRangeError('IAsSI64');

    with UInt32x2(Result) do
    begin
      if Size > 1 then Hi := PUInt32x2(Digits)^.Hi else Hi := 0;
      Lo := Digits^[0];
    end;
    if SignFlag <> 0 then Result := -Result;
  end
  else Result := 0;
end;

//==============================================================================
// Result := A if possible (see IIsUI8)
//==============================================================================
function IAsUI8(A: PBigInt; CheckRange: Boolean = true): UInt8;
begin
  with A^ do
  if Size > 0 then
  begin
    if CheckRange and (not IIsUI8(A)) then NXRaiseRangeError('IAsSUI8');

    Result := PUInt8(Digits)^;
  end
  else Result := 0;
end;

//==============================================================================
// Result := A if possible (see IIsUI32)
//==============================================================================
function IAsUI32(A: PBigInt; CheckRange: Boolean = true): UInt32;
begin
  with A^ do
  if Size > 0 then
  begin
    if CheckRange and ((SignFlag <> 0) or (Size > 1)) then
      NXRaiseRangeError('IAsUI32');

    Result := Digits^[0];
  end
  else Result := 0;
end;

//==============================================================================
// Result := A if possible (see IIsUI64)
//==============================================================================
function IAsUI64(A: PBigInt; CheckRange: Boolean = true): UInt64;
begin
  with A^ do
  if Size > 0 then
  begin
    if CheckRange and ((SignFlag <> 0) or (Size > 2)) then
      NXRaiseRangeError('IAsUI64');

    with UInt32x2(Result) do
    begin
      if Size > 1 then Hi := PUInt32x2(Digits)^.Hi else Hi := 0;
      Lo := Digits^[0];
    end;
  end
  else Result := 0;
end;

//==============================================================================
// Result := Bit #Index of A
// Bits are 0-based
// ! There is no error if (Index < 0) or (Index >= BitSize(A)), the function
// returns FALSE (0)
//==============================================================================
function IBit(A: PBigInt; Index: SInt32): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      shl   ecx, 5
      cmp   edx, ecx
      jae   @@01  // jmp if |Index| >= |Size*32| (with CF = 0)
      mov   eax, [eax+TBigInt.Digits]
      bt    [eax], edx
@@01: setc  al
end;

//==============================================================================
// Result := 'parity odd' of A
// The returned value is equal to "(IBitWeight(A) and 1) = 1"
//==============================================================================
function IBitParityOdd(A: PBigInt): Boolean;
begin
  with A^ do Result := RawParityOdd(Digits,Size);
end;

//==============================================================================
// Result := Indice of the first trailing bit different from 0 (or -1 if A = 0)
// Bits are 0-based
//==============================================================================
function IBitScanForward(A: PBigInt): SInt32;
begin
  with A^ do Result := RawBitScanForward(Digits,Size);
end;

//==============================================================================
// Set the bit #Index of A equal to Value
// -> Value, FALSE = 0, TRUE = 1
// Bits are 0-based
//==============================================================================
procedure IBitSet(A: PBigInt; Index: SInt32; Value: Boolean);
  var
    s : SInt32;
    t : UInt32;
begin
  if UInt32(Index) >= UInt32(gcMaxBigIntBitSize) then
    NXRaiseRangeError('IBitSet');

  s := Index shr 5 + 1;
  with A^ do
  if Value then
  begin
    if s > Size then
    begin
      if s > Capacity then IIncCapacityUpTo(A,s);
      FillChar(Digits^[Size],(s-Size)*SizeOf(UInt32),0);
      Size := s;
    end;
    Dec(s);
    Digits^[s] := Digits^[s] or gcPowOf2[Index and 31];
  end
  else
  if s < Size then
  begin
    Dec(s);
    Digits^[s] := Digits^[s] and (not gcPowOf2[Index and 31]);
  end
  else
  if s = Size then
  begin
    Dec(s);
    t := Digits^[s] and (not gcPowOf2[Index and 31]);
    Digits^[s] := t;
    if t = 0 then INormalize(A);
  end;
end;

//==============================================================================
// Result := Binary size of A
//==============================================================================
function IBitSize(A: PBigInt): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   edx, [eax+TBigInt.Digits]
      mov   eax, [eax+TBigInt.Size]
      dec   eax
      jl    @@01
      bsr   ecx, [edx+eax*4]
      shl   eax, 5
      add   eax, ecx
@@01: inc   eax
end;

//==============================================================================
// Return the Hamming weight of A (number of bits equal to 1)
//==============================================================================
function IBitWeight(A: PBigInt): SInt32;
begin
  with A^ do Result := RawWeight(Digits,Size);
end;

//==============================================================================
// Result := Size of A to the base 2**8
//==============================================================================
function IByteSize(A: PBigInt): SInt32;
begin
  with A^ do Result := RawByteCount(Digits,Size);
end;

//==============================================================================
// Compute the cubic root of A
//==============================================================================
procedure ICbrt(A: PBigInt);
  var
    W, X, Y : PBigInt;
    z, sf   : SInt32;
begin
  with A^ do
  begin
    //-- -2 < A < 2, there is nothing to do
    if (Size = 0) or ((Size = 1) and (Digits^[0] = 1)) then Exit;

    sf := SignFlag;
    if sf <> 0 then SignFlag := 0;
  end;

  z := IStackGetMany(W,X,Y);
  try
    //-- initialization, X := 2**u
    IBitSet(X,(UInt32(IBitSize(A)-1) div 3) + 1,true);
    repeat
      //-- save the value
      ISet(Y,X);
      //-- X := (2 X**3 + A) / (3 X**2)
      ISqr(X);
      ISet(W,X);
      IMulUI32(W,3);
      IShl1(X);
      IMul(X,Y);
      IAdd(X,A);
      IDiv(X,W);
    until ICmpAbs(X,Y) >= 0;
    ISwp(A,Y);
    A^.SignFlag := sf;
  finally
    IStackRestore(z);
  end;
end;   

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function ICmp(A,B: PBigInt): SInt32;
  const
    S : array [0..1] of SInt32 = (1,-1);
    T : array [0..1,-1..1] of SInt32 = ((-1,0,1),(1,0,-1));
begin
  with A^ do
  if SignFlag <> B^.SignFlag then
    Result := S[SignFlag]
  else
  if Size <> B^.Size then
    Result := T[SignFlag,(Ord(Size > B^.Size) shl 1) - 1]
  else
    Result := T[SignFlag,RawCmp(Digits,B^.Digits,Size)];
end;

//==============================================================================
// Compare |A| and |B|
// Result := -1 if |A| < |B|, 0 if |A| = |B|, 1 if |A| > |B|
//==============================================================================
function ICmpAbs(A,B: PBigInt): SInt32;
begin
  with A^ do
  if Size = B^.Size then
    Result := RawCmp(Digits,B^.Digits,Size)
  else
    Result := Ord(Size > B^.Size) shl 1 - 1;
end;

//==============================================================================
// Compare |A| and |B|
// Result := -1 if |A| < |B|, 0 if |A| = |B|, 1 if |A| > |B|
//==============================================================================
function ICmpAbsSI32(A: PBigInt; B: SInt32): SInt32;
begin
  with A^ do
  if Size > 1 then Result := 1
  else
  if Size > 0 then
  begin
    if B < 0 then B := -B;
    Result := Ord(Digits^[0] > UInt32(B)) - Ord(Digits^[0] < UInt32(B))
  end
  else Result := -Ord(B <> 0);
end;

//==============================================================================
// Compare |A| and |B|
// Result := -1 if |A| < |B|, 0 if |A| = |B|, 1 if |A| > |B|
//==============================================================================
function ICmpAbsSI64(A: PBigInt; B: SInt64): SInt32;
begin
  if SInt32x2(B).Hi < 0 then B := -B;
  Result := ICmpAbsUI64(A,B);
end;

//==============================================================================
// Compare A and B
// Result := -1 if |A| < B, 0 if |A| = B, 1 if |A| > B
//==============================================================================
function ICmpAbsUI32(A: PBigInt; B: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      cmp   dword ptr [eax+TBigInt.Size], 1
      jl    @@01
      je    @@02
      mov   eax, 1
      ret

@@01: xor   eax, eax
      test  edx, edx
      setne al
      neg   eax
      ret

@@02: mov   ecx, [eax+TBigInt.Digits]
      xor   eax, eax
      cmp   [ecx], edx
      seta  al
      sbb   eax, 0
end;

//==============================================================================
// Compare |A| and B
// Result := -1 if |A| < B, 0 if |A| = B, 1 if |A| > B
//==============================================================================
function ICmpAbsUI64(A: PBigInt; B: UInt64): SInt32;
begin
  with A^ do
  if Size > 2 then
    Result := 1
  else
  if Size > 1 then
    Result := UI64Cmp(PUInt64(Digits)^,B)
  else
  with UInt32x2(B) do
  if Size > 0 then
    if Hi > 0 then
      Result := -1
    else
      Result := Ord(Digits^[0] > Lo) - Ord(Digits^[0] < Lo)
  else
    Result := -Ord((Hi or Lo) <> 0)
end;

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function ICmpSI32(A: PBigInt; B: SInt32): SInt32;
begin
  with A^ do
  if Size > 1 then
    Result := (-SignFlag) or 1
  else
  if Size > 0 then
    if SignFlag = Ord(B < 0) then // same sign?
    begin
      if SignFlag <> 0 then B := -B;
      Result := Ord(Digits^[0] > UInt32(B)) - Ord(Digits^[0] < UInt32(B));
    end
    else
      Result := (-SignFlag) or 1
  else
    Result := Ord(B < 0) - Ord(B > 0);
end;

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function ICmpSI64(A: PBigInt; B: SInt64): SInt32;
  var F, S : SInt32;
begin
  with A^, UInt32x2(B) do
  begin
    //-- F := Ord(B < 0)
    F := SInt32(Hi shr 31);

    if F <> SignFlag then
      Result := (F-1) or 1
    else
    begin
      if F <> 0 then B := -B; // -2**63 stays unchanged, no problem

      if Hi > 0 then
        S := 2
      else
      if Lo > 0 then
        S := 1
      else
        S := 0;

      if Size <> S then
        Result := Ord(Size > S) shl 1 - 1
      else
      if S > 1 then
        Result := UI64Cmp(PUInt64(Digits)^,B)
      else
      if S > 0 then
        Result := Ord(Digits^[0] > Lo) - Ord(Digits^[0] < Lo)
      else
        Result := 0; // A = B = 0

      if SignFlag <> 0 then Result := -Result;
    end;
  end;
end;

//==============================================================================
// Compare A^.Size and B^.Size
// Result := -1 if A.S < B.S, 0 if A.S = B.S, 1 if A.S > B.S
//==============================================================================
function ICmpSize(A,B: PBigInt): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      //-- Result := Ord(A^.Size > B^.Size) - Ord(A^.Size < B^.Size);
      mov   eax, [eax+TBigInt.Size]
      cmp   eax, [edx+TBigInt.Size]
      setg  al
      setb  dl
      and   eax, $ff
      and   edx, $ff
      sub   eax, edx
end;

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function ICmpUI32(A: PBigInt; B: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      cmp   dword ptr [eax+TBigInt.SignFlag], 0
      je    @@01
      mov   eax, -1
      ret

@@01: cmp   dword ptr [eax+TBigInt.Size], 1
      jl    @@02
      je    @@03
      mov   eax, 1
      ret

@@02: xor   eax, eax
      test  edx, edx
      setne al
      neg   eax
      ret

@@03: mov   eax, [eax+TBigInt.Digits]
      cmp   [eax], edx
      mov   eax, 0
      seta  al
      sbb   eax, 0
end;

//==============================================================================
// Compare A and B
// Result := -1 if A < B, 0 if A = B, 1 if A > B
//==============================================================================
function ICmpUI64(A: PBigInt; B: UInt64): SInt32;
begin
  if A^.SignFlag = 0 then
    Result := ICmpAbsUI64(A,B)
  else
    Result := -1;
end;

//==============================================================================
// Result := CRC(A)
// InitCRC allows to chain calls to ICRC
//==============================================================================
function ICRC(A: PBigInt; InitCRC: UInt32=0): UInt32;
begin
  with A^ do Result := RawCRC(@SignFlag,1,RawCRC(Digits,Size,InitCRC));
end;

//==============================================================================
// Keep only the BitCount trailing bits of A (i.e., A := A mod 2**BitCount)
//==============================================================================
procedure ICut(A: PBigInt; BitCount: SInt32);
  var
    i : SInt32;
    t : UInt32;
begin
  if UInt32(BitCount) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseInvalidArg('ICut',esBitCount_is_not_in_0_gcMaxBigIntBitSize);

  with A^ do
  if BitCount > 0 then
  begin
    i := (BitCount+31) shr 5 - 1;
    if i < Size then // otherwise the work is already done
    begin
      t := Digits^[i] and gcMask32[(BitCount-1) and 31];
      Digits^[i] := t;
      Size := i+1;
      if t = 0 then INormalize(A);
    end;
  end
  else
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := A - 1
//==============================================================================
procedure IDec(A: PBigInt);
  var i : SInt32;
begin
  with A^ do
  if SignFlag <> 0 then // A < 0
  begin
    if RawAddUI32(Digits,Size,1) > 0 then
    begin
      if Size = Capacity then IIncCapacity(A);
      Digits^[Size] := 1;
      Inc(Size);
    end;
  end
  else
  if Size > 0 then // A > 0
  begin
    for i := 0 to Size-1 do
      if Digits^[i] = 0 then
        Digits^[i] := $ffffffff
      else
      begin
        Dec(Digits^[i]);
        Break;
      end;

    if Digits^[Size-1] = 0 then Dec(Size); // ok, SignFlag = 0
  end
  else // A = 0
  begin
    if Capacity = 0 then IIncCapacity(A);
    Digits^[0] := 1;
    Size := 1;
    SignFlag := 1; // negate
  end;
end;

//==============================================================================
// Result := decimal size of A
// If EstimateOnly = TRUE, the function returns an estimate of the decimal
// size. The estimate is never less than the true decimal size.
//==============================================================================
function IDecimalSize(A: PBigInt; EstimateOnly: Boolean = false): SInt32;
  var
    D : PBigInt;
    z : SInt32;
begin
  Result := NXEstimateDecimalSize(IBitSize(A));
  if EstimateOnly then Exit;

  if Result > 1 then
  begin
    z := IStackGet(D);
    try
      ISetUI32(D,5);
      //-- adjust the estimate (which one is either right or greater by 1)
      Dec(Result);
      IPowUI32(D,Result);
      IShl(D,Result);
      //-- compare 10**(Result-1) with A
      if ICmpAbs(D,A) <= 0 then Inc(Result);
    finally
      IStackRestore(z);
    end;
  end;
end;

//==============================================================================
// Result := Digit #Index of A
// Digits are 0-based
// ! There is no error if (Index < 0) or (Index >= A^.Size), the function
// returns 0
//==============================================================================
function IDigit(A: PBigInt; Index: SInt32): UInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      cmp   edx, [eax+TBigInt.Size]
      jae   @@01
      mov   eax, [eax+TBigInt.Digits]
      mov   eax, [eax+edx*4]
      ret

@@01: xor   eax, eax
end;

//==============================================================================
// Result := indice of the first trailing digit different from 0 (or -1 if
// A = 0)
// Digits are 0-based
//==============================================================================
function IDigitScanForward(A: PBigInt): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      mov   edx, [eax+TBigInt.Digits]
      test  ecx, ecx
      mov   eax, -1
      jz    @@FF             // exit if Size = 0 (with Result = -1)
      cld                    // presumably useless but better sure than sorry
      push  edi
      xor   eax, eax         // eax := 0
      mov   edi, edx
      repe  scasd
      sub   edi, edx
      shr   edi, 2
      lea   eax, [edi-1]
      pop   edi
@@FF:
end;

//==============================================================================
// Set the digit #Index of A equal to Value
// Digits are 0-based
//==============================================================================
procedure IDigitSet(A: PBigInt; Index: SInt32; Value: UInt32);
  var s : SInt32;
begin
  if UInt32(Index) >= UInt32(gcMaxBigIntSize) then
    NXRaiseRangeError('IDigitSet');

  s := Index + 1;
  with A^ do
  if Value > 0 then
  begin
    if Size < s then
    begin
      if Capacity < s then IIncCapacityUpTo(A,s);
      FillChar(Digits^[Size],(s-Size)*SizeOf(UInt32),0);
      Size := s;
    end;
    Digits^[Index] := Value;
  end
  else
  if Size > s then Digits^[Index] := 0
  else
  if Size = s then
  begin
    Digits^[Index] := 0;
    //-- normalize
    repeat
      Dec(Index);
    until (Index < 0) or (Digits^[Index] > 0);
    if Index < 0 then SignFlag := 0;
    Size := Index + 1;
  end;
end;

//==============================================================================
// A <- A div B (B is not modified)
// Result := TRUE iff A mod B = 0
// The obtained quotient is the same as the one obtained with IDivRem (so,
// it may be different from the one obtained with IDivMod)
//==============================================================================
function IDiv(A,B: PBigInt): Boolean;
  var
    R, D      : PBigInt;
    z, s, qsf : SInt32;
begin
  if B^.Size = 0 then NXRaiseDivByZero('IDiv');

  with A^ do
  case ICmpAbs(A,B) of
    //-- |A| = |B|
    0: begin
         qsf := SignFlag xor B^.SignFlag; // quotient sign flag
         ISet1(A);
         SignFlag := qsf;
         Result := true;
       end;

    //-- |A| > |B|
    1: begin
         qsf := SignFlag xor B^.SignFlag;
         if B^.Size > 1 then
         begin
           s := 32 - UI32BitSize(B^.Digits^[B^.Size-1]);
           z := IStackIndex;
           try
             if s > 0 then
             begin
               IStackGetMany(R,D);
               ISwp(A,R); // R := A, A := 0
               ISet(D,B);
               IShl(R,s); // normalize for division
               IShl(D,s);
             end
             else
             begin
               IStackGet(R);
               ISwp(A,R); // R := A, A := 0
               Pointer(D) := Pointer(B); // alias
             end;
             DivRemStd(A,R,D);
             Result := R^.Size = 0;
           finally
             IStackRestore(z);
           end;
         end
         else // B^.Size = 1
         begin
           Result := RawDivUI32(Digits,Size,B^.Digits^[0]) = 0;
           if Digits^[Size-1] = 0 then Dec(Size); // normalize
         end;
         SignFlag := qsf;
       end;

    //-- 0 <= |A| < |B|
    else
    if Size = 0 then Result := true
    else
    begin
      Size := 0;
      SignFlag := 0;
      Result := false; // remainder would be different from 0
    end;
  end;
end;

//==============================================================================
// A := A div B
//==============================================================================
procedure IDivExactUI32(A: PBigInt; B: UInt32);
  var t : UInt32;
begin
  if B = 0 then NXRaiseDivByZero('IDivExactUI32');

  //-- require
  ASSERT(IDivisible(A,B));

  with A^ do
  if (Size > 0) and (B > 1) then
  begin
    if (B and 1) = 0 then
    begin
      //-- set B odd
      t := 0;
      repeat
        Inc(t);
        B := B shr 1;
      until (B and 1) <> 0;
      IShr(A,t);
      if B = 1 then Exit;
    end;

    RawDivUI32Exact(Digits,Size,B,UI32InvMod2pow32(B));
    if Digits^[Size-1] = 0 then Dec(Size); // normalize, A cannot be set to 0
  end;
end;

//==============================================================================
// Result := TRUE iff (A mod B) = 0
//==============================================================================
function IDivisible(A: PBigInt; B: UInt32): Boolean;
  var e, f, a0 : UInt32;
begin
  if B = 0 then NXRaiseDivByZero('IDivisible');

  with A^ do
  begin
    if (Size = 0) or (B = 1) then
    begin
      Result := true;
      Exit;
    end;

    if (B and 1) <> 0 then
    begin
      Result := RawModUI32I(Digits,Size,B,UI32InvMod2pow32(B)) = 0;
      Exit;
    end;

    a0 := Digits^[0];
    if (a0 and 1) <> 0 then
    begin
      Result := false; // A is odd and B is even
      Exit;
    end;

    if a0 > 0 then // A is divisible by 2**k with k < 32
    begin
      e := 0;
      repeat
        Inc(e);
        a0 := a0 shr 1;
      until (a0 and 1) <> 0;
    end
    else e := 32; // A is divisible by 2**32

    f := 0;
    repeat
      Inc(f);
      B := B shr 1;
    until (B and 1) <> 0; // loop until B odd

    Result :=
      (e >= f)
      and
      ((B = 1) or (RawModUI32I(Digits,Size,B,UI32InvMod2pow32(B)) = 0));
  end;
end;

//==============================================================================
// Q <- A div B
// R <- A mod B  (if R <> 0 then R sign = B sign)
//==============================================================================
procedure IDivMod(Q,R,A,B: PBigInt);
  var
    D    : PBigInt;
    m    : UInt32;
    z, s : SInt32;
begin
  //-- require
  ASSERT(Pointer(Q) <> Pointer(R));
  ASSERT(Pointer(Q) <> Pointer(A));
  ASSERT(Pointer(Q) <> Pointer(B));
  ASSERT(Pointer(R) <> Pointer(A));
  ASSERT(Pointer(R) <> Pointer(B));
//ASSERT(Pointer(A) <> Pointer(B)); // not necessary

  if B^.Size = 0 then NXRaiseDivByZero('IDivMod');

  case ICmpAbs(A,B) of
    //-- |A| = |B|
    0: begin
         if A^.SignFlag = B^.SignFlag then ISet1(Q) else ISetMinus1(Q);
         with R^ do
         begin
           Size := 0;
           SignFlag := 0;
         end;
       end;

    //-- |A| > |B|
    1: if B^.Size > 1 then
       begin
         ISet(R,A);
         s := 32 - UI32BitSize(B^.Digits^[B^.Size-1]);
         if s > 0 then
         begin
           z := IStackGet(D);
           try
             ISet(D,B);
             IShl(R,s); // normalize for division
             IShl(D,s);
             DivRemStd(Q,R,D);
           finally
             IStackRestore(z);
           end;
           IShr(R,s);
         end
         else
           DivRemStd(Q,R,B);

         Q^.SignFlag := A^.SignFlag xor B^.SignFlag; // Q cannot equal 0
         if (R^.Size > 0) and (Q^.SignFlag <> 0) then
         begin
           IDec(Q);
           IAdd(R,B);
         end;
       end
       else
       begin
         ISet(Q,A);
         with Q^ do
         begin
           m := RawDivUI32(Digits,Size,B^.Digits^[0]);
           if Digits^[Size-1] = 0 then Dec(Size); // normalize Q
           SignFlag := A^.SignFlag xor B^.SignFlag; // Q cannot equal 0
         end;

         if m > 0 then
           if Q^.SignFlag = 0 then
           begin
             ISetUI32(R,m);
             R^.SignFlag := A^.SignFlag;
           end
           else
           begin
             IDec(Q);
             ISet(R,B);
             if A^.SignFlag = 0 then IAddUI32(R,m) else ISubUI32(R,m);
           end
         else // m = 0
         with R^ do
         begin
           Size := 0;
           SignFlag := 0;
         end;
       end;

    //-- 0 <= |A| < |B|
    else
    if A^.Size > 0 then
    begin
      ISet(R,A);
      if R^.SignFlag = B^.SignFlag then
      with Q^ do
      begin
        Size := 0;
        SignFlag := 0;
      end
      else
      begin
        ISetMinus1(Q);
        IAdd(R,B);
      end;
    end
    else // A = 0
    begin
      //-- 0 div B -> (Q := 0, R := 0)
      with Q^ do
      begin
        Size := 0;
        SignFlag := 0;
      end;
      with R^ do
      begin
        Size := 0;
        SignFlag := 0;
      end;
    end;
  end;
end;

//==============================================================================
// Q <- A div B
// R <- A rem B  (if R <> 0 then R sign = A sign)
//==============================================================================
procedure IDivRem(Q,R,A,B: PBigInt);
  var
    D    : PBigInt;
    m    : UInt32;
    z, s : SInt32;
begin
  //-- require
  ASSERT(Pointer(Q) <> Pointer(R));
  ASSERT(Pointer(Q) <> Pointer(A));
  ASSERT(Pointer(Q) <> Pointer(B));
  ASSERT(Pointer(R) <> Pointer(A));
  ASSERT(Pointer(R) <> Pointer(B));
//ASSERT(Pointer(A) <> Pointer(B)); // not necessary

  if B^.Size = 0 then NXRaiseDivByZero('IDivRem');

  case ICmpAbs(A,B) of
    //-- |A| = |B|
    0: begin
         if A^.SignFlag = B^.SignFlag then ISet1(Q) else ISetMinus1(Q);
         with R^ do
         begin
           Size := 0;
           SignFlag := 0;
         end;
       end;

    //-- |A| > |B|
    1: if B^.Size > 1 then
       begin
         ISet(R,A);
         s := 32 - UI32BitSize(B^.Digits^[B^.Size-1]);
         if s > 0 then
         begin
           z := IStackGet(D);
           try
             ISet(D,B);
             IShl(R,s); // normalize for division
             IShl(D,s);
             DivRemStd(Q,R,D);
           finally
             IStackRestore(z);
           end;
           IShr(R,s);
         end
         else
           DivRemStd(Q,R,B);

         Q^.SignFlag := A^.SignFlag xor B^.SignFlag; // Q cannot equal 0
       end
       else  // B^.Size = 1
       begin
         ISet(Q,A);
         with Q^ do
         begin
           m := RawDivUI32(Digits,Size,B^.Digits^[0]);
           if Digits^[Size-1] = 0 then Dec(Size); // normalize Q
           SignFlag := A^.SignFlag xor B^.SignFlag; // Q cannot equal 0
         end;

         if m > 0 then
         begin
           ISetUI32(R,m);
           R^.SignFlag := A^.SignFlag;
         end
         else
         with R^ do
         begin
           Size := 0;
           SignFlag := 0;
         end;
       end;

    //-- 0 <= |A| < |B|
    else
    with Q^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    ISet(R,A);
  end;
end;

//==============================================================================
// A := A div B
// Result := A rem B (Result sign = A (input) sign)
//==============================================================================
function IDivSI32(A: PBigInt; B: SInt32): SInt32;
begin
  if B = 0 then NXRaiseDivByZero('IDivSI32');

  with A^ do
  if Size > 0 then
  begin
    //-- A := A div |B|, Result := A mod |B|
    if B < 0 then Result := RawDivUI32(Digits,Size,-B)
             else Result := RawDivUI32(Digits,Size,B);
    //-- set Result sign
    if SignFlag <> 0 then Result := -Result;
    //-- normalize quotient
    if Digits^[Size-1] = 0 then
    begin
      Dec(Size);
      if Size = 0 then
      begin
        SignFlag := 0;
        Exit;
      end;
    end;
    //-- set quotient sign
    if B < 0 then SignFlag := SignFlag xor 1; // ok, A^.Size > 0
  end
  else Result := 0; // A = 0
end;

//==============================================================================
// A <- A div B
// Result <- A rem B (if Result <> 0 then Result sign = A (input) sign)
//==============================================================================
function IDivSI64(A: PBigInt; B: SInt64): SInt64;
  var
    Q, R, D : PBigInt;
    z       : SInt32;
begin
  with UInt32x2(B) do if (Hi or Lo) = 0 then NXRaiseDivByZero('IDivSI64');

{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Check whether |B| is a 32-bit integer
  //

  z := IStackGetMany(Q,R,D);
  try
    ISetSI64(D,B);
    IDivRem(Q,R,A,D);
    ISwp(A,Q);
    Result := IAsSI64(R);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A div B
// Result := (A rem B) = 0
//==============================================================================
function IDivUI32(A: PBigInt; B: UInt32): Boolean;
begin
  if B = 0 then NXRaiseDivByZero('IDivUI32');

  with A^ do
  if Size > 0 then
  begin
    Result := RawDivUI32(Digits,Size,B) = 0;
    if Digits^[Size-1] = 0 then
    begin
      Dec(Size);
      if Size = 0 then SignFlag := 0;
    end;
  end
  else Result := true; // A = 0
end;

//==============================================================================
// A <- A div B
// Result <- TRUE iff (A rem B) = 0
//==============================================================================
function IDivUI64(A: PBigInt; B: UInt64): Boolean;
  var
    Q, R, D : PBigInt;
    z       : SInt32;
begin
  with UInt32x2(B) do
  if Hi > 0 then
  begin
    z := IStackGetMany(Q,R,D);
    try
      ISetUI64(D,B);
      IDivRem(Q,R,A,D);
      ISwp(A,Q);
      Result := R^.Size = 0;
    finally
      IStackRestore(z);
    end;
  end
  else
  if Lo > 0 then Result := IDivUI32(A,Lo)
  else // B = 0
  begin
    NXRaiseDivByZero('IDivUI64');

  {$IFDEF DELPHI}
    Result := false; // to avoid DELPHI warning
  {$ENDIF}
  end;
end;

//==============================================================================
// Result := A = B
//==============================================================================
function IEqu(A,B: PBigInt): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.SignFlag]
      cmp   ecx, [edx+TBigInt.SignFlag]
      jne   @@01
      mov   ecx, [eax+TBigInt.Size]
      cmp   ecx, [edx+TBigInt.Size]
      jne   @@01
      push  esi
      push  edi
      cld
      mov   esi, [eax+TBigInt.Digits]
      mov   edi, [edx+TBigInt.Digits]
      repe  cmpsd
      pop   edi
      pop   esi
@@01: sete  al
end;

//==============================================================================
// Result := (A = 0)
//==============================================================================
function IEqu0(A: PBigInt): Boolean;
begin
  Result := A^.Size = 0;
end;

//==============================================================================
// Result := (A = 1)
//==============================================================================
function IEqu1(A: PBigInt): Boolean;
begin
  with A^ do Result := (Size = 1) and (Digits^[0] = 1) and (SignFlag = 0);
end;

//==============================================================================
// Result := |A| = |B|
//==============================================================================
function IEquAbs(A,B: PBigInt): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      cmp   ecx, [edx+TBigInt.Size]
      jne   @@01
      push  esi
      push  edi
      cld
      mov   esi, [eax+TBigInt.Digits]
      mov   edi, [edx+TBigInt.Digits]
      repe  cmpsd
      pop   edi
      pop   esi
@@01: sete  al
end;

//==============================================================================
// Result := (|A| = 1)
//==============================================================================
function IEquAbs1(A: PBigInt): Boolean;
begin
  with A^ do Result := (Size = 1) and (Digits^[0] = 1);
end;

//==============================================================================
// Result := |A| = |B|
//==============================================================================
function IEquAbsSI32(A: PBigInt; B: SInt32): Boolean;
begin
  with A^ do
  if Size > 1 then Result := false
  else
  if Size > 0 then
  begin
    if B < 0 then B := -B;
    Result := Digits^[0] = UInt32(B);
  end
  else Result := B = 0;
end;

//==============================================================================
// Result := |A| = |B|
//==============================================================================
function IEquAbsSI64(A: PBigInt; B: SInt64): Boolean;
begin
  with A^ do
  if Size > 2 then Result := false
  else
  with UInt32x2(B) do
  if Size > 1 then
  begin
    if SInt32x2(B).Hi < 0 then B := -B;
    Result := Boolean(Ord(PUInt32x2(Digits)^.Hi = Hi) and Ord(Digits^[0] = Lo));
  end
  else
  if Size > 0 then
  begin
    if SInt32x2(B).Hi < 0 then B := -B;
    Result := Boolean(Ord(0 = Hi) and Ord(Digits^[0] = Lo));
  end
  else Result := (Hi or Lo) = 0; // A = 0
end;

//==============================================================================
// Result := |A| = B
//==============================================================================
function IEquAbsUI32(A: PBigInt; B: UInt32): Boolean;
begin
  with A^ do
  if Size > 1 then Result := false
  else
  if Size > 0 then Result := Digits^[0] = B
  else Result := B = 0;
end;

//==============================================================================
// Result := |A| = B
//==============================================================================
function IEquAbsUI64(A: PBigInt; B: UInt64): Boolean;
begin
  with A^ do
  if Size > 2 then Result := false
  else
  with UInt32x2(B) do
  if Size > 1 then
    Result := Boolean(Ord(PUInt32x2(Digits)^.Hi = Hi) and Ord(Digits^[0] = Lo))
  else
  if Size > 0 then Result := Boolean(Ord(0 = Hi) and Ord(Digits^[0] = Lo))
  else Result := (Hi or Lo) = 0; // A = 0
end;

//==============================================================================
// Result := (A = -1)
//==============================================================================
function IEquMinus1(A: PBigInt): Boolean;
begin
  //
  // when Size = 1, Digit^[0] cannot be 0, so it is sufficient to check
  // whether Digit^[0] = SignFlag (instead of checking whether they are both
  // equal to 1)
  //
  with A^ do Result := (Size = 1) and (SInt32(Digits^[0]) = SignFlag);
end;

//==============================================================================
// Result := A = B
//==============================================================================
function IEquSI32(A: PBigInt; B: SInt32): Boolean;
begin
  with A^ do
  if (Size > 1) or (SignFlag <> Ord(B < 0)) then Result := false
  else
  if Size > 0 then
  begin
    if B < 0 then B := -B;
    Result := Digits^[0] = UInt32(B); // no problem with -2**31
  end
  else Result := B = 0; // A = 0
end;

//==============================================================================
// Result := A = B
//==============================================================================
function IEquSI64(A: PBigInt; B: SInt64): Boolean;
  var sf : UInt32;
begin
  with A^ do
  if Size > 2 then Result := false
  else
  with UInt32x2(B) do
  begin
    sf := Hi shr 31; // sf := Ord(B < 0)

    if SINt32(sf) <> SignFlag then Result := false
    else
    if Size = 2 then
    begin
      if sf > 0 then B := -B;
      Result :=
        Boolean(Ord(PUInt32x2(Digits)^.Hi = Hi) and Ord(Digits^[0] = Lo));
    end
    else
    if Size = 1 then
    begin
      if sf > 0 then B := -B;
      Result := Boolean(Ord(0 = Hi) and Ord(Digits^[0] = Lo));
    end
    else
    Result := (Hi or Lo) = 0; // A = 0
  end;
end;

//==============================================================================
// Result := A = B
//==============================================================================
function IEquUI32(A: PBigInt; B: UInt32): Boolean;
begin
  with A^ do
  if Size > 1 then Result := false
  else
  if Size > 0 then Result := Boolean(Ord(SignFlag = 0) and Ord(Digits^[0] = B))
  else Result := B = 0;
end;

//==============================================================================
// Result := A = B
//==============================================================================
function IEquUI64(A: PBigInt; B: UInt64): Boolean;
begin
  with A^ do
  if (Size > 2) or (SignFlag <> 0) then Result := false
  else
  with UInt32x2(B) do
  if Size > 1 then
    Result := Boolean(Ord(PUInt32x2(Digits)^.Hi = Hi) and Ord(Digits^[0] = Lo))
  else
  if Size > 0 then Result := Boolean(Ord(0 = Hi) and Ord(Digits^[0] = Lo))
  else Result := (Hi or Lo) = 0; // A = 0
end;

//==============================================================================
// Result := Bits [Index...Index+Count-1] of A
// -> Index, index of the least significant bit to extract
// -> Count, 0 <= Count <= 32, number of bits to extract
// Bits are 0-based
// Used by exponentiation routines to get exponent parts
//==============================================================================
function IExtractBits(A: PBigInt; Index,Count: SInt32): UInt32;
  var i, j : SInt32;
begin
  if Index < 0 then NXRaiseInvalidArg('IExtractBits',esIndex_lt_0);

  case UInt32(Count) of
    0: Result := 0;

    1: begin
         i := Index shr 5;
         with A^ do
         if i < Size then
           Result := Ord((Digits^[i] and gcPowOf2[Index and 31]) <> 0)
         else Result := 0;
       end;

    2..32:
    begin
      i := Index shr 5; // digit #i contains the bit #Index
      j := Index and 31;
      Dec(Count);
      with A^ do
      if ((Index+Count) and 31) > j then // need only one digit
        if i < Size then Result := (Digits^[i] shr j) and gcMask32[Count]
        else Result := 0
      else // need two digits
      if (i+1) < Size then Result :=
        ((Digits^[i] shr j) or (Digits^[i+1] shl (32-j))) and gcMask32[Count]
      else
      if (i+1) = Size then Result := (Digits^[i] shr j) and gcMask32[Count]
      else Result := 0;
    end;

    else
    NXRaiseInvalidArg('IExtractBits',esCount_is_not_in_0_32);

  {$IFDEF DELPHI}
    Result := 0; // to avoid DELPHI warning
  {$ENDIF}
  end;
end;

//==============================================================================
// A := 2**BitCount - 1 (A is constituted of BitCount bits set to 1)
// The returned A is always non-negative
//==============================================================================
procedure IFillBits(A: PBigInt; BitCount: SInt32);
  var s : SInt32;
begin
  if UInt32(BitCount) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseSizeError('IFillBits');

  with A^ do
  begin
    if BitCount > 0 then
    begin
      s := (BitCount+31) shr 5;
      if Capacity < s then IIncCapacityUpTo(A,s);
      FillChar(Digits^[0],(s-1)*SizeOf(UInt32),$ff);
      Digits^[s-1] := gcMask32[(BitCount-1) and 31];
      Size := s;
    end
    else Size := 0;

    SignFlag := 0;
  end;
end;

//==============================================================================
// Fill A with Count digits equal to Value
//==============================================================================
procedure IFillDigits(A: PBigInt; Count: SInt32; Value: UInt32);
  var i : SInt32;
begin
  if UInt32(Count) > UInt32(gcMaxBigIntSize) then
    NXRaiseSizeError('IFillDigits');

  with A^ do
  begin
    if (Count > 0) and (Value > 0) then
    begin
      if Capacity < Count then IIncCapacityUpTo(A,Count);
      for i := Count-1 downto 0 do Digits^[i] := Value;
      Size := Count;
    end
    else Size := 0;

    SignFlag := 0;
  end;
end;

//==============================================================================
// -> A, any
// -> B, any
// <- A := GCD(A,B) if A and B are not both null
//      := 0 (invalid GCD value) whenever A = B = 0
// <- Result := TRUE iff GCD(A,B) = 1
//------------------------------------------------------------------------------
// GCD ~ Greatest Common Divisor
//==============================================================================
function IGCD(A,B: PBigInt): Boolean;
  var
    X, S, T : PBigInt;
    z, cmp  : SInt32;
    m       : SInt32x4;
begin
  with A^ do
  begin
    //-- (A = 0) -> (GCD(A,B) = |B|)
    if Size = 0 then
    begin
      ISetAbs(A,B); // A := |B|
      Result := IEquAbs1(A);
      Exit;
    end;

    SignFlag := 0; // A := |A|

    //-- (B = 0) -> (GCD(A,B) = |A|)
    if B^.Size = 0 then
    begin
      Result := IEquAbs1(A);
      Exit;
    end;

    //-- (|A| = |B|) -> (GCD(A,B) = |A|)
    cmp := ICmpAbs(A,B);
    if cmp = 0 then
    begin
      Result := IEquAbs1(A);
      Exit; // A is the GCD
    end;

    //-- compute GCD
    z := IStackGetMany(X,S,T);
    try
      ISetAbs(X,B); // X := |B|
      if cmp < 0 then ISwp(A,X); // so that A > X

      repeat
        //
        // here, (0 < X < A) always holds
        //
        if Size < 3 then
        begin
          //-- if 32 < BitSize(A) <= 64, use UI64GCD
          if Size = 2 then
          begin
            if X^.Size = 2 then
            begin
              PUInt64(Digits)^ := UI64GCD(PUInt64(Digits)^,PUInt64(X^.Digits)^);
              //-- normalization, Size = 1 or 2 (cannot be 0)
              if PUInt32x2(Digits)^.Hi = 0 then Size := 1;
            end
            else // X^.Size = 1
            begin
              Digits^[0] := UI32GCD(UInt32(PUInt64(Digits)^ mod X^.Digits^[0]),
                            X^.Digits^[0]);
              Size := 1;
            end;
          end
          //-- BitSize(A) <= 32, use UI32GCD
          else Digits^[0] := UI32GCD(Digits^[0],X^.Digits^[0]);

          Break;
        end;

        if LCPartial(m,A,X) then // ok, A > X > 0
        begin
          //-- A := m0 A + m2 X
          //   X := m1 A + m3 X
          ISet(S,A);
          ISet(T,X);
          IMulSI32(A,m.i0);
          IMulSI32(S,m.i1);
          IMulSI32(T,m.i2);
          IMulSI32(X,m.i3);
          IAdd(A,T);
          IAdd(X,S);
        end
        else
        begin
          //-- m0 = 0, m1 = 1, m2 = 1, m3 = -q (with q = A div X)
          //   A := X
          //   X := A - q X
          IMod(A,X);
          ISwp(A,X);
        end;
      until X^.Size = 0;
    finally
      IStackRestore(z);
    end;

    Result := IEquAbs1(A);
  end;
end;

//==============================================================================
// -> A, any
// -> B, any
// <- Result := TRUE iff GCD(A,B) = 1
//------------------------------------------------------------------------------
// GCD ~ Greatest Common Divisor
// A and B are not modified
//==============================================================================
function IGCDEqu1(A,B: PBigInt): Boolean;
  var
    T : PBigInt;
    z : SInt32;
begin
  if A^.Size = 0 then
  begin
    Result := IEquAbs1(B);
    Exit;
  end;

  if B^.Size = 0 then
  begin
    Result := IEquAbs1(A);
    Exit;
  end;

  //-- both even?
  if ((A^.Digits^[0] or B^.Digits^[0]) and 1) = 0 then
  begin
    Result := false;
    Exit;
  end;

  z := IStackGet(T);
  try
    ISet(T,A);
    Result := IGCD(T,B);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// -> A, any
// -> B, any
//    if B = 0 then the resulting GCD is |A| which one, most of the time, will
//    overflow the UInt64 type.
// <- Result := GCD(A,B) if A and B are not both null
//           := 0 (invalid GCD value) whenever A = B = 0
//------------------------------------------------------------------------------
// GCD ~ Greatest Common Divisor
//==============================================================================
function IGCDUI32(A: PBigInt; B: UInt32): UInt32;
begin
  if B = 0 then
  with A^ do
  begin
    if Size > 1 then // the GCD is |A| and is too big for Result
      NXRaiseRangeError('IGCDUI32');

    //-- Result := |A|
    if Size > 0 then Result := Digits^[0] else Result := 0;
    Exit;
  end;

  Result := UI32GCD(IModUI32(A,B),B);
end;

//==============================================================================
// -> A, any
// -> B, any
//    if B = 0 then the resulting GCD is |A| which one, most of the time, will
//    overflow the UInt64 type.
// <- Result := GCD(A,B) if A and B are not both null
//           := 0 (invalid GCD value) whenever A = B = 0
//------------------------------------------------------------------------------
// GCD ~ Greatest Common Divisor
//==============================================================================
function IGCDUI64(A: PBigInt; B: UInt64): UInt64;
begin
  //-- B = 0?
  if (UInt32x2(B).Hi or UInt32x2(B).Lo) = 0 then
  with A^ do
  begin
    if Size > 2 then // the GCD is |A| and is too big for Result
      NXRaiseRangeError('IGCDUI64');

    //-- Result := |A|
    if Size > 1 then Result := PUInt64(Digits)^
    else
    with UInt32x2(Result) do
    begin
      Hi := 0;
      if Size > 0 then Lo := Digits^[0] else Lo := 0;
    end;
    Exit;
  end;

  Result := UI64GCD(IModUI64(A,B),B);
end;

//==============================================================================
// A := A + 1
//==============================================================================
procedure IInc(A: PBigInt);
  var i : SInt32;
begin
  with A^ do
  if SignFlag = 0 then
  begin
    if RawAddUI32(Digits,Size,1) > 0 then
    begin
      if Size = Capacity then IIncCapacity(A);
      Digits^[Size] := 1;
      Inc(Size);
    end;
  end
  else
  begin
    //-- (A < 0) -> ((A + 1) = -(|A| - 1))
    for i := 0 to Size-1 do
      if Digits^[i] = 0 then Digits^[i] := $ffffffff
      else
      begin
        Dec(Digits^[i]);
        Break;
      end;

    if Digits^[Size-1] = 0 then
    begin
      Dec(Size);
      if Size = 0 then SignFlag := 0;
    end;
  end;
end;

//==============================================================================
// -> A, any
// -> B >= 2
// <- A := A**(-1) mod B
// <- Result := TRUE if A is invertible modulo B, FALSE otherwise
//==============================================================================
function IInvMod(A,B: PBigInt): Boolean;
begin
  if ICmpUI32(B,2) < 0 then NXRaiseInvalidArg('IInvMod',esB_lt_2);

  IMod(A,B); // reduce and set A non-negative
  Result := (A^.Size > 0) and LCInvMod(A,B);
end;

//==============================================================================
// -> A[i], any
// -> B >= 2
// <- A[i] := A[i]**(-1) mod B
// Result := TRUE iff (Length(A) > 0) and (all A[i] are invertible modulo B)
// Make use of the Montgomery method
//==============================================================================
function IInvModMany(const A: array of PBigInt; B: PBigInt): Boolean;
  var
    W       : PPBigIntFrame;
    U       : PBigInt;
    z, L, i : SInt32;
begin
  //-- require
{$IFDEF NX_DEBUG}
  ASSERT(DistinctPointers1(A));
  for i := 0 to High(A) do ASSERT(Pointer(A[i]) <> Pointer(B));
{$ENDIF}

  if ICmpUI32(B,2) < 0 then NXRaiseInvalidArg('IInvModMany',esB_lt_2);

  L := High(A) + 1;
  if L = 0 then
  begin
    Result := false;
    Exit;
  end;

  z := IStackIndex;
  W := nil;
  try
    GetMem(W,L*SizeOf(PBigInt));
    IStackGetMany(W,L);
    ISet(W^[0],A[0]);
    for i := 1 to L-1 do
    begin
      IMulTo(W^[i],W^[i-1],A[i]);
      IMod(W^[i],B);
    end;

    Pointer(U) := Pointer(W^[L-1]); // alias
    if not ((U^.Size > 0) and LCInvMod(U,B)) then
    begin
      Result := false;
      Exit;
    end;
    for i := L-2 downto 0 do
    begin
      IMul(W^[i],U);
      IMod(W^[i],B);
      IMul(U,A[i+1]);
      IMod(U,B);
      ISwp(A[i+1],W^[i]);
    end;
    ISwp(A[0],U);
    Result := true;
  finally
    IStackRestore(z);
    if Assigned(W) then FreeMem(W);
  end;
end;

//==============================================================================
// Result := (A is even)
//==============================================================================
function IIsEven(A: PBigInt): Boolean;
begin
  with A^ do Result := (Size = 0) or ((Digits^[0] and 1) = 0);
end;

//==============================================================================
// Result := (A < 0)
//==============================================================================
function IIsNegative(A: PBigInt): Boolean;
begin
  Result := A^.SignFlag <> 0;
end;

//==============================================================================
// Result := (A <= 0)
//==============================================================================
function IIsNegativeOrNull(A: PBigInt): Boolean;
begin
  with A^ do Result := Boolean(Ord(Size = 0) or SignFlag);
end;

//==============================================================================
// Result := (A is odd)
//==============================================================================
function IIsOdd(A: PBigInt): Boolean;
begin
  with A^ do Result := (Size > 0) and ((Digits^[0] and 1) <> 0);
end;

//==============================================================================
// Result := (A > 0)
//==============================================================================
function IIsPositive(A: PBigInt): Boolean;
begin
  with A^ do Result := Boolean(Ord(Size > 0) and (1 - SignFlag));
end;

//==============================================================================
// Result := (A >= 0)
//==============================================================================
function IIsPositiveOrNull(A: PBigInt): Boolean;
begin
  Result := A^.SignFlag = 0;
end;

//==============================================================================
// Result := |A| is a power of 2
//==============================================================================
function IIsPowOf2(A: PBigInt): Boolean;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      mov   ecx, [eax+TBigInt.Size]
      and   ecx, ecx
      jle   @@03
      mov   eax, [eax+TBigInt.Digits]

{$IFDEF FREE_PASCAL}
      align 4
{$ENDIF}
@@01: mov   edx, [eax]
      and   edx, edx
      jne   @@02          // jmp if D <> 0
      dec   ecx           // Size := Size - 1
      lea   eax, [eax+4]
      je    @@03          // useless (assuming A is normalized)
      jmp   @@01

@@02: dec   ecx
      jne   @@03          // if D is not the last digit of A, exit(FALSE)
      lea   ecx, [edx-1]  // ecx := D-1
      and   edx, ecx
      sete  al            // Result := (D and (D-1)) = 0
      ret

@@03: xor   eax, eax      // Result := FALSE
end;

//==============================================================================
// Result := TRUE if A is a SInt32, FALSE otherwise
//==============================================================================
function IIsSI32(A: PBigInt): Boolean;
begin
  with A^ do
  if Size > 1 then Result := false
  else
  if Size > 0 then Result :=
    ((Digits^[0] and $80000000) = 0)
    or
    Boolean(Ord(Digits^[0] = $80000000) and Ord(SignFlag <> 0)) // A = -2**31
  else Result := true; // Size = 0
end;

//==============================================================================
// Result := TRUE if A is an SInt64, FALSE otherwise
//==============================================================================
function IIsSI64(A: PBigInt): Boolean;
begin
  with A^ do
  if Size > 2 then Result := false
  else
  if Size = 2 then
    with PUInt32x2(Digits)^ do
      Result :=
        ((Hi and $80000000) = 0)
        or
        //-- A = -2**63
        Boolean(Ord(Hi = $80000000) and Ord(Lo = 0) and Ord(SignFlag <> 0))
  else Result := true; // Size = 0 or 1
end;

//==============================================================================
// Result := (A is a square)
//==============================================================================
function IIsSquare(A: PBigInt): Boolean;
  var
    X : PBigInt;
    r : UInt32;
    z : SInt32;
begin
  with A^ do
  begin
    //-- handle A <= 0
    Result := Size = 0;
    if Result or (SignFlag <> 0) then Exit;

    // the numbers in hexa are (packed) bit arrays

    //-- check whether A is a square modulo 32
    if (($2030213 shr (Digits^[0] and 31)) and 1) = 0 then Exit;

    //-- check whether A is a square modulo p (p small odd prime)
    //   3234846615 = 3*5*7*11*13*17*19*23*29
    r := RawModUI32(Digits,Size,UInt32(3234846615));
    if ((($13D122F3 shr (r mod 29)) and 1) = 0) or
       (((   $5335F shr (r mod 23)) and 1) = 0) or
       (((   $30AF3 shr (r mod 19)) and 1) = 0) or
       (((   $1A317 shr (r mod 17)) and 1) = 0) or
       (((    $161B shr (r mod 13)) and 1) = 0) or
       (((     $23B shr (r mod 11)) and 1) = 0) or
       (((      $17 shr (r mod  7)) and 1) = 0) or
       (((      $13 shr (r mod  5)) and 1) = 0) or
       (((       $3 shr (r mod  3)) and 1) = 0) then Exit;
  end;

  z := IStackGet(X);
  try
    ISet(X,A);
    Result := ISqrt(X);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// Result := TRUE if A is a UInt8, FALSE otherwise
//==============================================================================
function IIsUI8(A: PBigInt): Boolean;
begin
  with A^ do
  if Size > 1 then Result := false
  else
  if Size > 0 then
    Result := Boolean(Ord(SignFlag = 0) and Ord((Digits^[0] and $ffffff00) = 0))
  else Result := true; // Size = 0
end;

//==============================================================================
// Result := TRUE if A is a UInt32, FALSE otherwise
//==============================================================================
function IIsUI32(A: PBigInt): Boolean;
begin
  //-- casts to avoid jumps in assembler code
  with A^ do Result := Boolean(Byte(Ord(SignFlag = 0) and Ord(Size < 2)));
end;

//==============================================================================
// Result := TRUE if A is a UInt64, FALSE otherwise
//==============================================================================
function IIsUI64(A: PBigInt): Boolean;
begin
  //-- casts to avoid jumps in assembler code
  with A^ do Result := Boolean(Byte(Ord(SignFlag = 0) and Ord(Size < 3)));
end;

//==============================================================================
// -> A, any
// -> B, any
// <- A := LCM(A,B) if A*B <> 0
//      := 0 whenever A*B = 0
//------------------------------------------------------------------------------
// LCM ~ Least Common Multiple
//==============================================================================
procedure ILCM(A,B: PBigInt);
  var
    D : PBigInt;
    z : SInt32;
begin
  with A^ do
  begin
    if Pointer(A) = Pointer(B) then
    begin
      SignFlag := 0; // lcm(A,A) = |A|
      Exit;
    end;

    if Size > 0 then
      if B^.Size > 0 then
      begin
        z := IStackGet(D);
        try
          ISet(D,A);
          if not IGCD(D,B) then
            //-- with random values, proba(D < 2**32) is high
            if D^.Size = 1 then IDivExactUI32(A,D^.Digits^[0]) else IDiv(A,D);
          IMul(A,B);
        finally
          SignFlag := 0; // the LCM should always be non-negative
          IStackRestore(z);
        end;
      end
      else
      begin
        Size := 0;
        SignFlag := 0;
      end;
  end;
end;

//==============================================================================
// Set A^.Digits^[] with the ByteCount UInt8's of Buf
// A^.SignFlag is always set to 0
//==============================================================================
procedure ILoadFromBuf(A: PBigInt; const Buf; ByteCount: SInt32);
  var s : SInt32;
begin
  if UInt32(ByteCount) > UInt32(gcMaxBigIntBitSize shr 3) then
    NXRaiseSizeError('ILoadFromBuf');

  with A^ do
  begin
    if ByteCount > 0 then
    begin
      s := (ByteCount+3) shr 2;
      if s > Capacity then IIncCapacityUpTo(A,s);
      Digits^[s-1] := 0; // (Count mod 4) might be <> 0
      Move(Buf,Digits^[0],ByteCount);
      while (s > 0) and (Digits^[s-1] = 0) do Dec(s); // normalize
      Size := s;
    end
    else Size := 0;

    SignFlag := 0;
  end;
end;

//==============================================================================
// Result := Least Significant Digit of A (0 if A = 0)
//==============================================================================
function ILSD(A: PBigInt): UInt32;
begin
  with A^ do if Size > 0 then Result := Digits^[0] else Result := 0;
end;

//==============================================================================
// Result := Least Significant Digit of A
//==============================================================================
function ILSDNZ(A: PBigInt): UInt32;
begin
  //-- require
  ASSERT(A^.Size > 0);

  Result := A^.Digits^[0];
end;

//==============================================================================
// A := A mod B
// if A (out) <> 0 then A (out) sign = B sign
//==============================================================================
procedure IMod(A,B: PBigInt);
  var
    D    : PBigInt;
    r    : UInt32;
    z, s : SInt32;
begin
  if B^.Size = 0 then NXRaiseDivByZero('IMod');

  with A^ do
  case ICmpAbs(A,B) of
    //-- |A| = |B|
    0: begin
         Size := 0;
         SignFlag := 0;
       end;

    //-- |A| > |B|
    1: if B^.Size > 1 then
       begin
         s := 32 - UI32BitSize(B^.Digits^[B^.Size-1]);
         if s > 0 then
         begin
           z := IStackGet(D);
           try
             ISet(D,B);
             IShl(A,s); // "normalize" for division
             IShl(D,s);
             RemStd(A,D);
           finally
             IStackRestore(z);
           end;
           IShr(A,s);
         end
         else RemStd(A,B);

         if (Size > 0) and (SignFlag <> B^.SignFlag) then IAdd(A,B);
       end
       else // B^.Size = 1
       begin
         r := RawModUI32(Digits,Size,B^.Digits^[0]);
         if r > 0 then
         begin
           Digits^[0] := r;
           Size := 1;
           if SignFlag <> B^.SignFlag then IAdd(A,B);
         end
         else
         begin
           Size := 0;
           SignFlag := 0;
         end;
       end;

    //-- 0 <= |A| < |B|
    else
    if (Size > 0) and (SignFlag <> B^.SignFlag) then IAdd(A,B);
  end;
end;

//==============================================================================
// Result := A mod 3 (positive remainder)
//==============================================================================
function IMod3(A: PBigInt): UInt32;
begin
  with A^ do
  begin
    Result := RawMod3(Digits,Size);
    if (Result > 0) and (SignFlag <> 0) then
      //-- the casts compel FPC 2.2.0 and higher to produce efficient code
      Result := UInt32(3 - SInt32(Result));
  end;
end;

//==============================================================================
// Result := A mod B (A is not modified)
// If Result <> 0 then Result sign = B sign
//==============================================================================
function IModSI32(A: PBigInt; B: SInt32): SInt32;
begin
  if B = 0 then NXRaiseDivByZero('IModSI32');

  with A^ do
  if Size > 0 then
  begin
    if B < 0 then
      Result := RawModUI32(Digits,Size,-B)
    else
      Result := RawModUI32(Digits,Size,B);

    if Result <> 0 then
      if SignFlag <> 0 then
        if B < 0 then
          Result := -Result
        else
          Result := B - Result
      else
        if B < 0 then
          Result := B + Result;
  end
  else
    Result := 0;
end;

//==============================================================================
// Result := A mod B (A is not modified)
// If Result <> 0 then Result sign = B sign
//==============================================================================
function IModSI64(A: PBigInt; B: SInt64): SInt64;
  var
    R, D : PBigInt;
    z    : SInt32;
begin
  with UInt32x2(B) do if (Hi or Lo) = 0 then NXRaiseDivByZero('IModSI64');

{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Check whether |B| is a 32-bit integer
  //

  z := IStackGetMany(R,D);
  try
    ISet(R,A);
    ISetSI64(D,B);
    IMod(R,D);
    Result := IAsSI64(R);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// Result := A mod B
// Positive remainder
//==============================================================================
function IModUI32(A: PBigInt; B: UInt32): UInt32;
begin
  if B = 0 then NXRaiseDivByZero('IModUI32');

  with A^ do
  if Size > 0 then
  begin
    Result := RawModUI32(Digits,Size,B);
    if (SignFlag <> 0) and (Result > 0) then
      //-- the casts compel FPC 2.2.0 and higher to produce efficient code
      Result := UInt32(SInt32(B) - SInt32(Result));
  end
  else Result := 0;
end;

//==============================================================================
// Result := A mod B (A is not modified)
// If Result <> 0 then Result sign = B sign, i.e., positive
//==============================================================================
function IModUI64(A: PBigInt; B: UInt64): UInt64;
  var
    R, D : PBigInt;
    z    : SInt32;
begin
  with UInt32x2(B) do
  if Hi > 0 then
  begin
    z := IStackGetMany(R,D);
    try
      ISet(R,A);
      ISetUI64(D,B);
      IMod(R,D);
      Result := IAsUI64(R);
    finally
      IStackRestore(z);
    end;
  end
  else
  if Lo > 0 then
  begin
    UInt32x2(Result).Hi := 0;
    UInt32x2(Result).Lo := IModUI32(A,Lo);
  end
  else NXRaiseDivByZero('IModUI64');
end;

//==============================================================================
// -> A, any
// -> B, odd modulus
// <- A, image of A (input) in Montgomery domain
// The resulting A is such that 0 <= A < B
//==============================================================================
procedure IMontgomery(A,B: PBigInt);
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(IIsPositiveOrNull(A));
  ASSERT(IIsPositive(B));
  ASSERT(IIsOdd(B));

  IShl(A,B^.Size shl 5);
  IMod(A,B);
end;

//==============================================================================
// Montgomery reduction
// The resulting A is such that 0 <= A < 2B and A^.Size <= B^.Size
//------------------------------------------------------------------------------
// From HAC 14.32 algorithm, without the final subtraction
//==============================================================================
procedure IMontgomeryReduce(A,B: PBigInt; U: UInt32);
  var
    P, Q, T : PUInt32Frame;
    d       : UInt32;
    s, i    : SInt32;
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(IIsPositiveOrNull(A));
  ASSERT(IIsPositive(B));
  ASSERT(IIsOdd(B));
  ASSERT((ILSD(B)*UInt32(-U)) = 1);

  s := B^.Size;
  i := s + s;

  ASSERT(A^.Size <= i);

  with A^ do
  begin
    //-- fill up A[Size..s+s] with 0s
    if Capacity <= i then IIncCapacityUpTo(A,i+1);
    P := Digits; // alias (shouldn't be set before the previous instruction)
    if i > Size then FillChar(P^[Size],(i-Size+1)*SizeOf(UInt32),0)
    else P^[i] := 0;

    //-- update A
    Q := B^.Digits; // alias
    for i := s-1 downto 0 do
    begin
      //-- P := P + Q * ((P0*U) mod 2**32)
      d := RawAddMulUI32(P,Q,s,P^[0]*U);
      //-- propagate carry (if any)
      if d > 0 then
      begin
        Inc(P^[s],d);
        if P^[s] < d then // new carry?
        begin
          T := @P^[s];
          repeat
            Inc(T); // we always have @T^[0] <= @P^[s+s]
            Inc(T^[0]);
          until T^[0] > 0;
        end;
      end;
      Inc(P)
    end;
    if P^[s] > 0 then RawSubTo(Digits,P,Q,s)
    else Move(P^[0],Digits^[0],s*SizeOf(UInt32));

    //-- normalize A
    P := Digits;
    repeat
      if P^[s-1] > 0 then Break;
      Dec(s);
    until s = 0;
    Size := s;
  end;
end;

//==============================================================================
// Result := Parameter for Montgomery reduction
//==============================================================================
function IMontgomerySetup(A: PBigInt): UInt32;
begin
  with A^ do
  begin
    if SignFlag <> 0 then NXRaiseInvalidArg('IMontgomerySetup',esA_lt_0);

    if (Size = 0) or ((Digits^[0] and 1) = 0) then
      NXRaiseInvalidArg('IMontgomerySetup',esA_is_even);

    Result := -UI32InvMod2pow32(Digits^[0]);
  end;
end;

//==============================================================================
// Result := Most Significant Digit of A (or 0 if A = 0)
//==============================================================================
function IMSD(A: PBigInt): UInt32;
begin
  with A^ do if Size > 0 then Result := Digits^[Size-1] else Result := 0;
end;

//==============================================================================
// Result := Most Significant Digit of A
//==============================================================================
function IMSDNZ(A: PBigInt): UInt32;
begin
  //-- require
  ASSERT(A^.Size > 0);

  with A^ do Result := Digits^[Size-1];
end;

//==============================================================================
// A := A * B
//==============================================================================
procedure IMul(A,B: PBigInt);
  var
    R                : PBigInt;
    Carry            : UInt32;
    z, sa, sb, sf, s : SInt32;
begin
  if Pointer(A) = Pointer(B) then
  begin
    ISqr(A);
    Exit;
  end;

  sa := A^.Size;
  sb := B^.Size;

  if (sa < gcKarMulThreshold) or (sb < gcKarMulThreshold) then
  begin
    if sa = 0 then Exit;

    with A^ do
    begin
      if sb = 0 then
      begin
        Size := 0;
        SignFlag := 0;
        Exit;
      end;

      sf := SignFlag xor B^.SignFlag;

      if sb = 1 then
      begin
        Carry := RawMulUI32(Digits,sa,B^.Digits^[0]);
        if Carry > 0 then
        begin
          if Capacity = sa then IIncCapacity(A);
          Digits^[sa] := Carry;
          Inc(Size);
        end;
        SignFlag := sf;
        Exit;
      end;

      if sa = 1 then
      begin
        if Capacity <= sb then IIncCapacityUpTo(A,sb+1);
        Carry := RawMulUI32To(Digits,B^.Digits,sb,Digits^[0]);
        Digits^[sb] := Carry;
        Size := sb + Ord(Carry > 0);
        SignFlag := sf;
        Exit;
      end;
    end;

    z := IStackGet(R);
    try
      s := sa + sb;
      with R^ do
      begin
        if Capacity < s then IIncCapacityUpTo(R,s);
        if sa >= sb then RawMulStdTo(Digits,A^.Digits,B^.Digits,sa,sb)
                    else RawMulStdTo(Digits,B^.Digits,A^.Digits,sb,sa);
        if Digits^[s-1] = 0 then Dec(s);
        Size := s;
        SignFlag := sf;
      end;
      ISwp(A,R);
    finally
      IStackRestore(z);
    end;
    Exit;
  end;

  //-- both sizes are greater than or equal to the Karatsuba mul threshold
  z := IStackGet(R);
  try
    MultiplyTo(R,A,B);
    ISwp(A,R);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A * B
//==============================================================================
procedure IMulSI32(A: PBigInt; B: SInt32);
  var c : UInt32;
begin
  with A^ do
  if Size > 0 then
    if B <> 0 then
    begin
      if B < 0 then
      begin
        B := -B; // if B = -2**31 then B = -B, no problem
        SignFlag := SignFlag xor 1;
      end;
      if B <> 1 then // and not "B > 1", B (input) might be equal to -2**31
      begin
        c := RawMulUI32(Digits,Size,B);
        if c > 0 then
        begin
          if Size = Capacity then IIncCapacity(A);
          Digits^[Size] := c;
          Inc(Size);
        end;
      end;
    end
    else // B = 0
    begin
      Size := 0;
      SignFlag := 0;
    end;
end;

//==============================================================================
// A := A * B
//==============================================================================
procedure IMulSI64(A: PBigInt; B: SInt64);
  var
    T     : PBigInt;
    z, sf : SInt32;
    c     : UInt32;
begin
  if A^.Size = 0 then Exit;

  if SInt32x2(B).Hi >= 0 then sf := 0
  else
  begin
    B := -B;
    sf := 1;
  end;

  with A^, UInt32x2(B) do
  if Hi > 0 then
  begin
    z := IStackGet(T);
    try
      if (Size+2) > T^.Capacity then IIncCapacityUpTo(T,Size+2);
      //-- T := A * B[0]
      T^.Digits^[Size] := RawMulUI32To(T^.Digits,Digits,Size,Lo);
      //-- T := T + A * B[1]
      c := 1;
      c := RawAddMulUI32(@T^.Digits^[c],Digits,Size,Hi);
      if c > 0 then
      begin
        T^.Digits^[Size+1] := c;
        T^.Size := Size + 2;
      end
      else T^.Size := Size + 1;
      T^.SignFlag := SignFlag xor sf;
      ISwp(A,T);
    finally
      IStackRestore(z);
    end;
  end
  else
  if Lo > 1 then
  begin
    c := RawMulUI32To(Digits,Digits,Size,Lo);
    if c > 0 then
    begin
      if Size = Capacity then IIncCapacity(A);
      Digits^[Size] := c;
      Inc(Size);
    end;
    SignFlag := SignFlag xor sf;
  end
  else
  if Lo = 0 then // B = 0
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// R := A * B
//==============================================================================
procedure IMulTo(R,A,B: PBigInt);
  var
    Carry     : UInt32;
    sa, sb, s : SInt32;
begin
  if Pointer(A) = Pointer(B) then
  begin
    ISqrTo(R,A);
    Exit;
  end;

  if Pointer(R) = Pointer(A) then
  begin
    IMul(R,B);
    Exit;
  end;

  if Pointer(R) = Pointer(B) then
  begin
    IMul(R,A);
    Exit;
  end;

  sa := A^.Size;
  sb := B^.Size;

  with R^ do
  if (sa < gcKarMulThreshold) or (sb < gcKarMulThreshold) then
  begin
    if (sa = 0) or (sb = 0) then
    begin
      Size := 0;
      SignFlag := 0;
      Exit;
    end;

    if sb = 1 then
    begin
      if Capacity <= sa  then IIncCapacityUpTo(R,sa+1);
      Carry := RawMulUI32To(Digits,A^.Digits,sa,B^.Digits^[0]);
      Digits^[sa] := Carry;
      s := sa + Ord(Carry > 0);
    end
    else
    if sa = 1 then
    begin
      if Capacity <= sb then IIncCapacityUpTo(R,sb+1);
      Carry := RawMulUI32To(Digits,B^.Digits,sb,A^.Digits^[0]);
      Digits^[sb] := Carry;
      s := sb + Ord(Carry > 0);
    end
    else
    begin
      s := sa + sb;
      if Capacity < s then IIncCapacityUpTo(R,s);
      if sa >= sb then RawMulStdTo(Digits,A^.Digits,B^.Digits,sa,sb)
                  else RawMulStdTo(Digits,B^.Digits,A^.Digits,sb,sa);
      Dec(s,Ord(Digits^[s-1] = 0));
    end;
    Size := s;
    SignFlag := A^.SignFlag xor B^.SignFlag;
    Exit;
  end;

  //-- both sizes are greater than or equal to the Karatsuba mul threshold
  MultiplyTo(R,A,B);
end;

//==============================================================================
// A := A * B
//==============================================================================
procedure IMulUI32(A: PBigInt; B: UInt32);
  var c : UInt32;
begin
  with A^ do
  if Size > 0 then
    if B > 1 then
    begin
      c := RawMulUI32(Digits,Size,B);
      if c > 0 then
      begin
        if Size = Capacity then IIncCapacity(A);
        Digits^[Size] := c;
        Inc(Size);
      end;
    end
    else
    if B = 0 then
    begin
      Size := 0;
      SignFlag := 0;
    end;
end;

//==============================================================================
// A := A * B
//==============================================================================
procedure IMulUI64(A: PBigInt; B: UInt64);
  var
    T : PBigInt;
    c : UInt32;
    z : SInt32;
begin
  with A^ do
  begin
    if Size = 0 then Exit;

    with UInt32x2(B) do
    if Hi > 0 then
    begin
      z := IStackGet(T);
      try
        if (Size+2) > T^.Capacity then IIncCapacityUpTo(T,Size+2);
        //-- T := A * B[0]
        T^.Digits^[Size] := RawMulUI32To(T^.Digits,Digits,Size,Lo);
        //-- T := T + A * B[1]
        c := 1;
        c := RawAddMulUI32(@T^.Digits^[c],Digits,Size,Hi);
        T^.Digits^[Size+1] := c;
        T^.Size := Size + 1 + Ord(c > 0);
        T^.SignFlag := SignFlag;
        ISwp(A,T);
      finally
        IStackRestore(z);
      end;
    end
    else
    if Lo > 1 then
    begin
      c := RawMulUI32To(Digits,Digits,Size,Lo);
      if c > 0 then
      begin
        if Size = Capacity then IIncCapacity(A);
        Digits^[Size] := c;
        Inc(Size);
      end;
    end
    else
    if Lo = 0 then // B = 0
    begin
      Size := 0;
      SignFlag := 0;
    end;
  end;
end;

//==============================================================================
// A := -A
//==============================================================================
procedure INegate(A: PBigInt);
begin
  with A^ do SignFlag := SignFlag xor Ord(Size > 0);
end;

//==============================================================================
// A := not A (on BitCount bits)
// A^.SignFlag := 1 - A^.SignFlag (or 0 if A is set to 0)
// BitCount must be greater than or equal to BitSize(A)
//==============================================================================
procedure INot(A: PBigInt; BitCount: SInt32);
  var
    s : SInt32;
    t : UInt32;
begin
  if (BitCount < IBitSize(A)) or
     (UInt32(BitCount) > UInt32(gcMaxBigIntBitSize)) then
    NXRaiseInvalidArg('INot',esBitCount_is_not_in_BitSizeA_gcMaxBigIntBitSize);

  if BitCount > 0 then
  begin
    s := (BitCount+31) shr 5; // here, s >= Size and s > 0
    with A^ do
    begin
      if s > Size then
      begin
        if Capacity < s then IIncCapacityUpTo(A,s);
        FillChar(Digits^[Size],(s-Size)*SizeOf(UInt32),0);
        Size := s;
      end;
      if s > 1 then RawNot(Digits,s-1);
      t := Digits^[s-1] xor gcMask32[(BitCount-1) and 31];
      Digits^[s-1] := t;
      SignFlag := SignFlag xor 1;
    end;
    if t = 0 then INormalize(A); // set A^.SignFlag to 0 (if needed)
  end;
end;

//==============================================================================
// A := A or B
// A^.SignFlag := A^.SignFlag or B^.SignFlag
//==============================================================================
procedure IOr(A,B: PBigInt);
begin
  with A^ do
  begin
    if Size >= B^.Size then RawOr(Digits,B^.Digits,B^.Size)
    else
    begin
      RawOr(Digits,B^.Digits,Size);
      if Capacity < B^.Size then IIncCapacityUpTo(A,B^.Size);
      Move(B^.Digits^[Size],Digits^[Size],(B^.Size-Size)*SizeOf(UInt32));
      Size := B^.Size;
    end;
    SignFlag := SignFlag or B^.SignFlag;
  end;
end;

//==============================================================================
// A := A**E mod B
//==============================================================================
procedure IPowMod(A,E,B: PBigInt; DivType: TDivType = dtUndefined);
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(E));
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(Pointer(E) <> Pointer(B));

  if E^.SignFlag <> 0 then NXRaiseInvalidArg('IPowMod',esE_lt_0);

  with B^ do
  begin
    if (SignFlag <> 0) or (Size = 0) then NXRaiseInvalidArg('IPowMod',esB_lt_1);

    //-- B = 1? (B cannot be negative)
    if (Size = 1) and (Digits^[0] = 1) then
    begin
      A^.Size := 0;
      A^.SignFlag := 0;
      Exit;
    end;
  end;

  //-- E = 0?
  if E^.Size = 0 then
  begin
    ISet1(A); // A**0 = 1 for any A (i.e., 0**0 = 1)
    Exit;
  end;

  //-- reduce A modulo B
  with A^ do if (SignFlag <> 0) or (Size >= B^.Size) then IMod(A,B);

  //-- E = 1? (E cannot be negative)
  with E^ do if (Size = 1) and (Digits^[0] = 1) then Exit;

  //-- A = 0 or 1? (A cannot be negative)
  with A^ do if (Size = 0) or ((Size = 1) and (Digits^[0] = 1)) then Exit;

  //
  // here, A > 1, E > 1 and B > 2
  //

  PowMod(A,E,B,DivType);
end;

//==============================================================================
// A := A**E
//------------------------------------------------------------------------------
// A**0 = 1 for any A
// 0**E = 0 for E <> 0
//==============================================================================
procedure IPowUI32(A: PBigInt; E: UInt32);
  var
    T           : PBigInt;
    m           : UInt64Union;
    b           : UInt32;
    z, sf, s, i : SInt32;
begin
  if E = 0 then
  begin
    ISet1(A); // A**0 = 1 for any A (i.e., 0**0 = 1)
    Exit;
  end;

  with A^ do
  if Size > 0 then
  begin
    SignFlag := SignFlag and SInt32(E); // A := |A| whenever E is even
    s := IShrUntilOdd(A);

    if Size > 1 then
    begin
      z := IStackGet(T);
      try
        ISet(T,A);
        for i := UI32BitSize(E)-2 downto 0 do
        begin
          ISqr(A);
          if (E and gcPowOf2[i]) <> 0 then IMul(A,T);
        end;
      finally
        IStackRestore(z);
      end;
    end
    else // Size = 1
    begin
      b := Digits^[0];
      if b > 1 then
      begin
        sf := SignFlag;
        for i := UI32BitSize(E)-2 downto 0 do
        begin
          ISqr(A);
          if (E and gcPowOf2[i]) <> 0 then IMulUI32(A,b);
        end;
        SignFlag := sf;
      end;
    end;

    //-- shift
    if s > 0 then // A**E = (A shr s)**E shl (s*E)
    begin
      m.Whole := UInt64(UInt32(s)) * E;

      if m.Hi > 0 then NXRaiseIntOverflow('IPowUI32');

      IShl(A,m.Lo);
    end;
  end;
end;

//==============================================================================
// A := A**E mod B
//==============================================================================
procedure IPowUI64Mod(
                  A       : PBigInt;
            const E       : UInt64;
                  B       : PBigInt;
                  DivType : TDivType = dtUndefined);
  var
    F : PBigInt;
    z : SInt32;
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(B));

  with B^ do
  begin
    if (SignFlag <> 0) or (Size = 0) then // B < 1
      NXRaiseInvalidArg('IPowUI32Mod',esB_lt_1);

    //-- B = 1? (B cannot be negative)
    if (Size = 1) and (Digits^[0] = 1) then
    begin
      A^.Size := 0;
      A^.SignFlag := 0;
      Exit;
    end;
  end;

  //-- E = 0?
  with UInt32x2(E) do
  if (Hi or Lo) = 0 then
  begin
    ISet1(A); // A**0 = 1 for any A (i.e., 0**0 = 1)
    Exit;
  end;

  //-- reduce A modulo B
  with A^ do if (SignFlag <> 0) or (Size >= B^.Size) then IMod(A,B);

  //-- E = 1?
  //
  //   "Boolean(Ord(Hi = 0) and Ord(Lo = 1))" is better than
  //   "(Hi = 0) and (Lo = 1)".
  //
  with UInt32x2(E) do if Boolean(Ord(Hi = 0) and Ord(Lo = 1)) then Exit;

  //-- A = 0 or 1? (A cannot be negative)
  with A^ do if (Size = 0) or ((Size = 1) and (Digits^[0] = 1)) then Exit;

  //
  // here, A > 1, E > 1 and B > 2
  //

  z := IStackGet(F);
  try
    ISetUI64(F,E);
    PowMod(A,F,B,DivType);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// Generalized reciprocal "division"
// A := A mod B, whith R reciprocal of B (the remainder is always positive)
//==============================================================================
procedure IReciprocalMod(A,B,R: PBigInt);
  var
    T        : PBigInt;
    z, s, sf : SInt32;
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(B));
  ASSERT(Pointer(A) <> Pointer(R));
  ASSERT(Pointer(B) <> Pointer(R));
  ASSERT(ICmpUI32(B,2) > 0);

  with A^ do
  case ICmpAbs(A,B) of
    //-- |A| = |B|
    0: begin
         Size := 0;
         SignFlag := 0;
       end;

    //-- |A| > |B|
    1: begin
         s := IBitSize(R) - 1;
         z := IStackGet(T);
         try
           sf := SignFlag;
           SignFlag := 0;

           //-- loop, to allow inputs |A| greater than (B**2 - 1)
           //   note that when Size(A) > 2*Size(B), Burnikel div is faster
           repeat
             ISet(T,A);
             IShr(T,s-1);
             IMul(T,R);
             IShr(T,s+1);
             IMul(T,B);
             ISub(A,T);

             if ICmp(A,B) < 0 then Break;
             ISub(A,B);
             if ICmp(A,B) < 0 then Break;
             ISub(A,B);
           until ICmp(A,B) < 0;

           if Boolean(Ord(sf > 0) and Ord(Size > 0)) then ISubr(A,B);
         finally
           IStackRestore(z);
         end;
       end;

    //-- |A| < |B|
    else
    if SignFlag <> 0 then IAdd(A,B);
  end;
end;

//==============================================================================
// Generalized reciprocal
// <- A := (4**(BitSize(B-1)))/B
// -> B, greater than 2
//==============================================================================
procedure IReciprocalSetup(A,B: PBigInt);
  var s : SInt32;
begin
  if ICmpUI32(B,3) < 0 then NXRaiseInvalidArg('IReciprocalSetup',esB_lt_3);

  //-- s := BitSize(B-1)
  s := IBitSize(B) - Ord(IIsPowOf2(B));
  with A^ do
  begin
    Size := 0;
    SignFlag := 0;
  end;
  IBitSet(A,s+s,true);
  IDiv(A,B);
end;

//==============================================================================
// Reduce the fraction A/B
// The returned B is always positive
// If A = 0 then B is set to 1
//==============================================================================
procedure IReduce(A,B: PBigInt);
  var
    D  : PBigInt;
    z  : SInt32;
    d0 : UInt32;
begin
  //-- require
  ASSERT(Pointer(A) <> Pointer(B));

  if B^.Size = 0 then NXRaiseDivByZero('IReduce');

  if A^.Size = 0 then
  begin
    ISet1(B); // the fraction 0 is normalized as 0/1
    Exit;
  end;

  //-- handle sign
  if B^.SignFlag <> 0 then
  begin
    with A^ do SignFlag := SignFlag xor Ord(Size > 0); // A := -A
    B^.SignFlag := 0; // B := |B|
  end;

  z := IStackGet(D);
  try
    ISet(D,A);
    if not IGCD(D,B) then
      //-- with random inputs proba(D < 2**32) is high
      if D^.Size = 1 then
      begin
        d0 := D^.Digits^[0];
        IDivExactUI32(A,d0);
        IDivExactUI32(B,d0);
      end
      else
      begin
        IDiv(A,D);
        IDiv(B,D);
      end;
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := A rem B
// If A (out) <> 0 then A (out) sign = A (in) sign
//==============================================================================
procedure IRem(A,B: PBigInt);
  var
    D    : PBigInt;
    r    : UInt32;
    z, s : SInt32;
begin
  if B^.Size = 0 then NXRaiseDivByZero('IRem');

  with A^ do
  case ICmpAbs(A,B) of
    //-- |A| = |B|
    0: begin
         Size := 0;
         SignFlag := 0;
       end;

    //-- |A| > |B|
    1: if B^.Size > 1 then
       begin
         s := 32 - UI32BitSize(B^.Digits^[B^.Size-1]);
         if s > 0 then
         begin
           z := IStackGet(D);
           try
             ISet(D,B);
             IShl(A,s); // normalize for division
             IShl(D,s);
             RemStd(A,D);
           finally
             IStackRestore(z);
           end;
           IShr(A,s);
         end
         else RemStd(A,B);
       end
       else // B^.Size = 1
       begin
         r := RawModUI32(Digits,Size,B^.Digits^[0]);
         if r > 0 then
         begin
           Digits^[0] := r;
           Size := 1;
         end
         else
         begin
           Size := 0;
           SignFlag := 0;
         end;
       end;

    //-- |A| < |B|
    else; // nothing
  end;
end;

//==============================================================================
// Suppress the trailing zeroes of A (if A <> 0)
// Result := number of suppressed digit(s)
//==============================================================================
function IRemoveTrailingZeroes(A: PBigInt): SInt32;
begin
  Result := IDigitScanForward(A);
  if Result > 0 then
  with A^ do
  begin
    Dec(Size,Result);
    Move(Digits^[Result],Digits^[0],Size*SizeOf(UInt32));
  end;
end;

//==============================================================================
// Result := A rem B
// A is not modified
// If Result <> 0 then Result sign = A sign
//==============================================================================
function IRemSI32(A: PBigInt; B: SInt32): SInt32;
begin
  if B = 0 then NXRaiseDivByZero('IRemSI32');

  with A^ do
  if Size > 0 then
  begin
    if B < 0 then B := -B; // B might equal -2**31, no problem
    Result := RawModUI32(Digits,Size,UInt32(B));
    if SignFlag <> 0 then Result := -Result;
  end
  else Result := 0;
end;

//==============================================================================
// Result := A rem B (A is not modified)
// If Result <> 0 then Result sign = A sign
// Comment: Not at all efficient
//==============================================================================
function IRemSI64(A: PBigInt; B: SInt64): SInt64;
  var
    R, D : PBigInt;
    z    : SInt32;
begin
  if (UInt32x2(B).Hi or UInt32x2(B).Lo) = 0 then NXRaiseDivByZero('IRemSI64');

{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Check whether |B| is a 32-bit integer
  //

  z := IStackGetMany(R,D);
  try
    ISet(R,A);
    ISetSI64(D,B);
    IRem(R,D);
    Result := IAsSI64(R);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// Overloaded
// A := BitCount-bit random integer
// If roExactSize is in Options then A has exactly BitCount bits (otherwise it
// has at most BitCount bits)
// If roSigned is in Options then A^.SignFlag is random (otherwise it is set
// to 0)
//==============================================================================
procedure IRnd(A: PBigInt; BitCount: SInt32; Options: TRndOptionSet = []);
  var
    s, i : SInt32;
    t    : UInt32;
begin
  if UInt32(BitCount) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseInvalidArg('IRnd',esBitCount_is_not_in_0_gcMaxBigIntBitSize);

  with A^ do
  if BitCount > 0 then
  begin
    s := (BitCount+31) shr 5;
    if Capacity < s then IIncCapacityUpTo(A,s);
    //-- fill the digits
    NXRndUI32s(Digits^[0],s);
    Size := s;
    //-- set the sign
    SignFlag := Ord((roSigned in Options) and NXRndBool);
    //-- most significant digit
    i := (BitCount-1) and 31;
    t := Digits^[s-1] and gcMask32[i];
    if roExactSize in Options then Digits^[s-1] := t or gcPowOf2[i]
    else
    begin
      Digits^[s-1] := t;
      if t = 0 then // normalize
      begin
        repeat Dec(Size); until (Size = 0) or (Digits^[Size-1] > 0);
        if Size = 0 then SignFlag := 0;
      end;
    end;
  end
  else // (BitCount = 0) -> (A := 0)
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Overloaded
// A := random integer such that Min <= A <= Max
//==============================================================================
procedure IRnd(A,Min,Max: PBigInt);
  var
    T : PBigInt;
    z : SInt32;
begin
  if ICmp(Min,Max) > 0 then NXRaiseInvalidArg('IRnd',esMin_gt_Max);

  z := IStackGet(T);
  try
    ISubTo(T,Max,Min);
    if T^.SignFlag = 0 then IInc(T) else IDec(T);
    IRnd(A,IBitSize(T)+1,[roExactSize]);
    IMod(A,T); // A takes the sign of T
  finally
    IStackRestore(z);
  end;
  IAdd(A,Min);
end;

//==============================================================================
// A := RotateLeft(A,Shift) (The rotation is done on BitCount bits)
//==============================================================================
procedure IRol(A: PBigInt; BitCount,Shift: SInt32);
begin
  if (BitCount < IBitSize(A)) or
     (UInt32(BitCount) > UInt32(gcMaxBigIntBitSize)) then
    NXRaiseInvalidArg('IRol',esBitCount_is_not_in_BitSizeA_gcMaxBigIntBitSize);

  if UInt32(Shift) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseInvalidArg('IRol',esShift_is_not_in_0_gcMaxBigIntBitSize);

  if BitCount > 1 then // if BitCount = 0 or 1, there is nothing to do
  begin
    //-- 0 <= Shift < BitCount
    Shift := Shift mod BitCount;
    //-- rotation
    if Shift > 1 then RotateLeft(A,BitCount,Shift)
    else
    if Shift > 0 then
    begin
      IShl1(A);
      if IBit(A,BitCount) then
      begin
        ISetOdd(A);
        IBitSet(A,BitCount,false);
      end;
    end;
  end;
end;

//==============================================================================
// A := RotateLeft(A,1) (The rotation is done on BitCount bits)
//==============================================================================
procedure IRol1(A: PBigInt; BitCount: SInt32);
begin
  if (BitCount < IBitSize(A)) or
     (UInt32(BitCount) > UInt32(gcMaxBigIntBitSize)) then
    NXRaiseInvalidArg('IRol1',esBitCount_is_not_in_BitSizeA_gcMaxBigIntBitSize);

  if BitCount > 1 then // if BitCount = 0 or 1, there is nothing to do
  begin
    IShl1(A);
    if IBit(A,BitCount) then
    begin
      ISetOdd(A);
      IBitSet(A,BitCount,false);
    end;
  end;
end;

//==============================================================================
// Compute the k-th root of a number
// -> A >= 0
// -> K > 0
// <- A, k-th root of A
//==============================================================================
procedure IRoot(A: PBigInt; k: UInt32);
  var
    W, X, Y : PBigInt;
    z       : SInt32;
begin
  with A^ do
  begin
    if SignFlag <> 0 then NXRaiseInvalidArg('IRoot',esA_lt_0);

    if k = 0 then NXRaiseInvalidArg('IRoot',esk_eq_0);

    //-- if k = 1 or if 0 <= A < 2, there is nothing to do
    if (k = 1) or (Size = 0) or ((Size = 1) and (Digits^[0] = 1)) then Exit;
  end;

  z := IStackGetMany(W,X,Y);
  try
    //-- initialization, X := 2**u
    IBitSet(X,(UInt32(IBitSize(A)-1) div k) + 1,true);
    repeat
      //-- save the value
      ISet(Y,X);
      //-- X := ((k-1) * X**k + A) / (k * X**(k-1))
      IPowUI32(X,Pred(k)); // ! not "k-1" to avoid the 64-bit code of FPC 2.2.x
      ISet(W,X);
      IMulUI32(W,k);
      IMul(X,Y);
      IMulUI32(X,Pred(k)); // ! and not "k-1" to avoid etc. etc.
      IAdd(X,A);
      IDiv(X,W);
    until ICmpAbs(X,Y) >= 0;
    ISwp(A,Y);
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// A := RotateRight(A,Shift) (The rotation is done on BitCount bits)
//==============================================================================
procedure IRor(A: PBigInt; BitCount, Shift: SInt32);
  var sf : SInt32;
begin
  if (BitCount < IBitSize(A)) or
     (UInt32(BitCount) > UInt32(gcMaxBigIntBitSize)) then
    NXRaiseInvalidArg('IRor',esBitCount_is_not_in_BitSizeA_gcMaxBigIntBitSize);

  if UInt32(Shift) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseInvalidArg('IRor',esShift_is_not_in_0_gcMaxBigIntBitSize);

  if BitCount > 1 then // if BitCount = 0 or 1, there is nothing to do
  begin
    //-- 0 <= Shift < BitCount
    Shift := Shift mod BitCount;
    //-- rotation
    if Shift > 1 then RotateLeft(A,BitCount,BitCount-Shift)
    else
    if Shift > 0 then
    begin
      sf := A^.SignFlag; // useful only when A = -1
      if IShr1(A) then IBitSet(A,BitCount,true);
      A^.SignFlag :=  sf;
    end;
  end;
end;

//==============================================================================
// A := RotateRight(A,1) (The rotation is done on BitCount bits)
//==============================================================================
procedure IRor1(A: PBigInt; BitCount: SInt32);
  var sf : SInt32;
begin
  if (BitCount < IBitSize(A)) or
     (UInt32(BitCount) > UInt32(gcMaxBigIntBitSize)) then
    NXRaiseInvalidArg('IRor1',esBitCount_is_not_in_BitSizeA_gcMaxBigIntBitSize);

  if BitCount > 1 then // if BitCount = 0 or 1, there is nothing to do
  begin
    sf := A^.SignFlag; // useful only when A = -1
    if IShr1(A) then IBitSet(A,BitCount,true);
    A^.SignFlag :=  sf;
  end;
end;

//==============================================================================
// A := B
//==============================================================================
procedure ISet(A,B: PBigInt);
begin
  with B^ do
  begin
    if Size > A^.Capacity then IIncCapacityUpTo(A,Size);
    Move(Digits^[0],A^.Digits^[0],Size*SizeOf(UInt32));
    A^.Size := Size;
    A^.SignFlag := SignFlag;
  end;
end;

//==============================================================================
// A := 0
//==============================================================================
procedure ISet0(A: PBigInt);
begin
  with A^ do
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Overloaded
// A[i] := 0
//==============================================================================
procedure ISet0Many(const A: array of PBigInt);
  var i : SInt32;
begin
  for i := High(A) downto 0 do
    with A[i]^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
end;

//==============================================================================
// Overloaded
// A^[i] := 0
// It is assumed that Length(A) >= Count
//==============================================================================
procedure ISet0Many(const A: PPBigIntFrame; Count: SInt32);
begin
  while Count > 0 do
  begin
    Dec(Count);
    with A^[Count]^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
  end;
end;

//==============================================================================
// A := 0 (Digits is freed)
//==============================================================================
procedure ISet0Packed(A: PBigInt);
begin
  with A^ do
  begin
    ReAllocMem(Digits,0);
    Capacity := 0;
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Overloaded
// A[i] := 0 (Digits is freed)
//==============================================================================
procedure ISet0PackedMany(const A: array of PBigInt);
  var i : SInt32;
begin
  for i := High(A) downto 0 do
    with A[i]^ do
    begin
      ReAllocMem(Digits,0);
      Capacity := 0;
      Size := 0;
      SignFlag := 0;
    end;
end;

//==============================================================================
// Overloaded
// A^[i] := 0 (Digits is freed)
// It is assumed that Length(A) >= Count
//==============================================================================
procedure ISet0PackedMany(const A: PPBigIntFrame; Count: SInt32);
begin
  while Count > 0 do
  begin
    Dec(Count);
    with A^[Count]^ do
    begin
      ReAllocMem(Digits,0);
      Capacity := 0;
      Size := 0;
      SignFlag := 0;
    end;
  end;
end;

//==============================================================================
// A := 1
//==============================================================================
procedure ISet1(A: PBigInt);
begin
  with A^ do
  begin
    if Capacity = 0 then IIncCapacity(A);
    Digits^[0] := 1;
    Size := 1;
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := |B|
//==============================================================================
procedure ISetAbs(A,B: PBigInt);
begin
  with B^ do
  begin
    if Size > A^.Capacity then IIncCapacityUpTo(A,Size);
    Move(Digits^[0],A^.Digits^[0],Size*SizeOf(UInt32));
    A^.Size := Size;
    A^.SignFlag := 0;
  end;
end;

//==============================================================================
// Set A even
//==============================================================================
procedure ISetEven(A: PBigInt);
begin
  with A^ do
  if Size > 1 then Digits^[0] := Digits^[0] and $fffffffe
  else
  if Size = 1 then
    if Digits^[0] > 1 then Digits^[0] := Digits^[0] and $fffffffe
    //-- A = +/-1
    else
    begin
      Size := 0;
      SignFlag := 0;
    end;
end;

//==============================================================================
// A := Count most significant digits of B
// A takes the sign of B (if not set to 0)
// Equivalent to A := 0 if Count = 0
// Equivalent to A := B if Count >= B^.Size
//==============================================================================
procedure ISetHiPart(A,B: PBigInt; Count: SInt32);
begin
  //-- require
  ASSERT(Count >= 0);

  with B^ do if Count > Size then Count := Size;

  with A^ do
  if Count > 0 then
  begin
    if Capacity < Count then IIncCapacityUpTo(A,Count);
    Move(B^.Digits^[B^.Size-Count],Digits^[0],Count*SizeOf(UInt32));
    Size := Count;
    SignFlag := B^.SignFlag;
  end
  else
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := Count least significant digits of B
// A takes the sign of B (if not set to 0)
// Equivalent to A := 0 if Count = 0
// Equivalent to A := B if Count >= B^.Size
//==============================================================================
procedure ISetLoPart(A,B: PBigInt; Count: SInt32);
begin
  //-- require
  ASSERT(Count >= 0);

  with B^ do if Count > Size then Count := Size;

  with A^ do
  if Count > 0 then
  begin
    if Capacity < Count then IIncCapacityUpTo(A,Count);
    Move(B^.Digits^[0],Digits^[0],Count*SizeOf(UInt32));
    Size := Count;
    SignFlag := B^.SignFlag;
    if Digits^[Count-1] = 0 then INormalize(A);
  end
  else
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := -1
//==============================================================================
procedure ISetMinus1(A: PBigInt);
begin
  with A^ do
  begin
    if Capacity = 0 then IIncCapacity(A);
    Digits^[0] := 1;
    Size := 1;
    SignFlag := 1;
  end;
end;

//==============================================================================
// If Value then A := -|A| else A := |A|
//==============================================================================
procedure ISetNegative(A: PBigInt; Value: Boolean);
begin
  with A^ do SignFlag := Ord(Size > 0) and Ord(Value);
end;

//==============================================================================
// Set A odd (i.e., A := A or 1)
//==============================================================================
procedure ISetOdd(A: PBigInt);
begin
  with A^ do
  if Size > 0 then Digits^[0] := Digits^[0] or 1
  else
  begin
    if Capacity = 0 then IIncCapacity(A);
    Digits^[0] := 1;
    Size := 1;
  end;
end;

//==============================================================================
// A := B
//==============================================================================
procedure ISetSI32(A: PBigInt; B: SInt32);
begin
  with A^ do
  if B <> 0 then
  begin
    if Capacity = 0 then IIncCapacity(A);
    Size := 1;
    if B < 0 then
    begin
      Digits^[0] := -B; // if B = -2**31 then B = -B, no problem
      SignFlag := 1;
    end
    else
    begin
      Digits^[0] := B;
      SignFlag := 0;
    end;
  end
  else
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := B
//==============================================================================
procedure ISetSI64(A: PBigInt; B: SInt64);
begin
  with A^, UInt32x2(B) do
  if (Hi or Lo) <> 0 then // B <> 0
  begin
    if Capacity = 0 then IIncCapacity(A);

    if SInt32x2(B).Hi >= 0 then SignFlag := 0
    else
    begin
      B := -B; // if B is -2**63 then B = -B, no problem
      SignFlag := 1;
    end;

    PUInt64(Digits)^ := B;
    Size := Succ(Ord(Hi <> 0)); // 1 or 2
  end
  else // B = 0
  begin
    Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// Set A sign
// If Sign < 0 then A := -|A|
// If Sign = 0 then A := 0
// If Sign > 0 then A := |A|
//==============================================================================
procedure ISetSign(A: PBigInt; Sign: SInt32);
begin
  with A^ do
  if Sign < 0 then SignFlag := Ord(Size > 0)
  else
  begin
    if Sign = 0 then Size := 0;
    SignFlag := 0;
  end;
end;

//==============================================================================
// A := B
//==============================================================================
procedure ISetUI32(A: PBigInt; B: UInt32);
begin
  with A^ do
  begin
    if B <> 0 then
    begin
      if Capacity = 0 then IIncCapacity(A);
      Digits^[0] := B;
      Size := 1;
    end
    else Size := 0;

    SignFlag := 0;
  end;
end;

//==============================================================================
// A := B
//==============================================================================
procedure ISetUI64(A: PBigInt; B: UInt64);
begin
  with A^ do
  begin
    with UInt32x2(B) do
    if (Hi or Lo) <> 0 then // B <> 0
    begin
      if Capacity = 0 then IIncCapacity(A);
      PUInt64(Digits)^ := B;
      Size := Succ(Ord(Hi <> 0));
    end
    else Size := 0;

    SignFlag := 0;
  end;
end;

//==============================================================================
// A := A * 2**Shift
//==============================================================================
procedure IShl(A: PBigInt; Shift: SInt32);
  var
    s, t  : SInt32;
    Carry : UInt32;
begin
  if UInt32(Shift) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseInvalidArg('IShl',esShift_is_not_in_0_gcMaxBigIntBitSize);

  with A^ do
  if Size > 0 then
  begin
    s := Shift and 31;
    t := Shift shr 5;

    if s > 1 then Carry := RawShl(Digits,Size,s)
    else
    if s > 0 then Carry := RawAdd(Digits,Digits,Size)
    else Carry := 0;

    s := Size + t + Ord(Carry <> 0);
    if Capacity < s then IIncCapacityUpTo(A,s);
    if t > 0 then
    begin
      Move(Digits^[0],Digits^[t],Size*SizeOf(UInt32));
      FillChar(Digits^[0],t*SizeOf(UInt32),0);
    end;
    if Carry > 0 then Digits^[s-1] := Carry;
    Size := s;
  end;
end;

//==============================================================================
// A := A * 2
//==============================================================================
procedure IShl1(A: PBigInt);
begin
  with A^ do
  if Size > 0 then
    if RawAdd(Digits,Digits,Size) > 0 then
    begin
      if Size = Capacity then IIncCapacity(A);
      Digits^[Size] := 1;
      Inc(Size);
    end;
end;

//==============================================================================
// A := A div 2**Shift
//==============================================================================
procedure IShr(A: PBigInt; Shift: SInt32);
  var t : SInt32;
begin
  if UInt32(Shift) > UInt32(gcMaxBigIntBitSize) then
    NXRaiseInvalidArg('IShr',esShift_is_not_in_0_gcMaxBigIntBitSize);

  with A^ do
  if Size > 0 then
  begin
    t := Shift shr 5;
    if t > 0 then
    begin
      if Size > t then
      begin
        Dec(Size,t);
        Move(Digits^[t],Digits^[0],Size*SizeOf(UInt32));
      end
      else
      begin
        Size := 0;
        SignFlag := 0;
        Exit;
      end;
    end;

    t := Shift and 31;
    if t > 0 then
      if RawShr(Digits,Size,t) then
      begin
        Dec(Size);
        if Size = 0 then SignFlag := 0;
      end;
  end;
end;

//==============================================================================
// A := A div 2
// Result := TRUE iff the dropped bit is 1
//==============================================================================
function IShr1(A: PBigInt): Boolean;
begin
  with A^ do
  if Size > 0 then
  begin
    Result := (Digits^[0] and 1) <> 0;
    if RawShr1(Digits,Size) then
    begin
      Dec(Size);
      if Size = 0 then SignFlag := 0;
    end;
  end
  else Result := false;
end;

//==============================================================================
// Result := position of the first trailing bit <> 0 or -1 if A = 0
// A := A div 2**Result (A is not modified if Result = -1 or 0)
//==============================================================================
function IShrUntilOdd(A: PBigInt): SInt32;
begin
  Result := IBitScanForward(A);
  if Result > 0 then IShr(A,Result);
end;

//==============================================================================
// Result := sign of A (-1, 0 or 1)
//==============================================================================
function ISign(A: PBigInt): SInt32;
begin
  with A^ do Result := Ord(Size > 0) - (SignFlag shl 1);
end;

//==============================================================================
// Result := ((sign of A) * (sign of B)) (-1, 0 or 1)
//==============================================================================
function ISignProduct(A,B: PBigInt): SInt32;
  const SP : array [-1..1,-1..1] of SInt32 = ((1,0,-1),(0,0,0),(-1,0,1));
begin
  Result := SP[Ord(A^.Size > 0) - (A^.SignFlag shl 1),
               Ord(B^.Size > 0) - (B^.SignFlag shl 1)];
end;

//==============================================================================
// A := A**2
//==============================================================================
procedure ISqr(A: PBigInt);
  var
    R    : PBigInt;
    z, s : SInt32;
    m    : UInt32;
begin
  with A^ do
  if Size > 1 then
  begin
    s := Size shl 1;
    z := IStackGet(R);
    try
      ISwp(A,R); // R := A, A := 0
      if Capacity < s then IIncCapacityUpTo(A,s);
      Digits^[s-1] := 0;
      RawSqrTo(Digits,R^.Digits,R^.Size);
      Dec(s,Ord(Digits^[s-1] = 0));
      Size := s;
    finally
      IStackRestore(z);
    end;
  end
  else
  if Size > 0 then
  begin
    m := Digits^[0];
    if (m and $ffff0000) <> 0 then
    begin
      PUInt64(Digits)^ := UInt64(m) * m;
      Size := 2;
    end
    else
    begin
      Digits^[0] := m * m;
      Size := 1;
    end;
    SignFlag := 0;
  end;
  // if A = 0, nothing
end;

//==============================================================================
// A := A**(1/2)
// Result := A (input) is a perfect square
//==============================================================================
function ISqrt(A: PBigInt): Boolean;
  const
    XSHIFT = 16; // ! Must be even and such that 2 <= XSHIFT <= 32
    XMASK = UInt32((1 shl (XSHIFT div 2))-1);
  var
    X, Y                               : PBigInt;
    da, dx                             : PUInt32Frame;
    z, cmp, sa, sx, sy, i, j, s, Shift : SInt32;
    Len                                : array [0..31] of SInt32;
begin
  with A^ do
  begin
    if SignFlag <> 0 then NXRaiseInvalidArg('ISqrt',esA_lt_0);

    if Size > 2 then
    begin
      z := IStackGetMany(X,Y);
      try
        //-- shift A an even number of bits to the left so that
        //   1) BitSize(A) = 2**k or 2**k - 1
        //   2) A^.Size is even
        //   3) A^.Digits^[0] mod 2**XSHIFT = 0
        s := Size;
        i := UI32BitSize(Digits^[s-1]);
        Inc(s,Ord(i > (32 - XSHIFT)));
        Shift := XSHIFT + (32 - ((i + XSHIFT) and 31)) and 31;
        if (s and 1) <> 0 then
        begin
          Inc(Shift,32);
          Inc(s);
        end;
        if (Shift and 1) <> 0 then Dec(Shift);
        IShl(A,Shift);
        da := Digits;
        sa := Size;

        //-- initial value
        if X^.Capacity = 0 then IIncCapacity(X);
        dx := X^.Digits;
        dx^[0]            := da^[sa-2];
        PUInt32x2(dx)^.Hi := da^[sa-1];
        UI64SqrtTest(PUInt64(dx)^);
        X^.Size := 1; // dx^[1] has been set to 0 by UI64SqrtTest

        //-- set a size table for adjusting precision within Newton loop
        s := s shr 1;
        i := 0;
        repeat
          Len[i] := s;
          s := (s + 1) shr 1;
          Inc(Len[i],s);
          Inc(i);
        until s = 1;

        //-- Newton loop (non-constant precision)
        for j := i-1 downto 0 do
        begin
          ISwp(X,Y);
          s := Len[j]; // new dividend size
          //-- set X equal to A shr (sa-s)*32
          if s > X^.Capacity then IIncCapacityUpTo(X,s);
          X^.Size := s;
          Move(da^[sa-s],X^.Digits^[0],s*SizeOf(UInt32));
          IDiv(X,Y);
          sy := Y^.Size;
          Dec(s,sy);
          //-- add only the Y^.Size most significant digits
          //   X[s-1, ..., s-Y^.Size] + Y[Y^.Size-1, ..., 0]
          dx := X^.Digits;
          sx := X^.Size;
          if (RawAdd(@dx^[s-sy],Y^.Digits,sy) <> 0) and (sx > s) then
          begin
            //-- X := s*32 bits equal to 1
            FillChar(dx^[0],s*SizeOf(UInt32),$ff);
            dx^[s] := 0;
          end
          else
          begin
            RawShr1(dx,sx);
            dx^[s-1] := dx^[s-1] or $80000000;
          end;
          X^.Size := s;
        end;

        //-- if Result = FALSE then A is not a square
        //   Proba(Result is TRUE) when A is not square is about 1/2**(XSHIFT/2)
        Result := (X^.Digits^[0] and XMASK) = 0;

        //-- adjust result
        IShr(X,Shift div 2);

        if Result then
        begin
          //-- check whether A is really a perfect square and whether X = Root+1
          IShr(A,Shift); // need to correct
          ISqrTo(Y,X);
          cmp := ICmpAbs(Y,A);
          if cmp <> 0 then
          begin
            Result := false;
            if cmp > 0 then IDec(X);
          end;
        end;

        //-- set the resulting root
        ISwp(A,X);
      finally
        IStackRestore(z);
      end;
    end
    else
    if Size = 2 then
    begin
      Result := UI64SqrtTest(PUInt64(Digits)^);
      Dec(Size);
    end
    else
    if Size > 0 then // Size = 1
      Result := UI32SqrtTest(Digits^[0]) // A^.Size doesn't change
    else Result := true; // Size = 0
  end;
end;

//==============================================================================
// S := A**(1/2)
// R := A - S**2 (R := 0 whenever A is a perfect square)
// Result := TRUE iff A is a perfect square
//==============================================================================
function ISqrtRem(S,R,A: PBigInt): Boolean;
  var z : SInt32;
begin
  //-- require
  ASSERT(Pointer(S) <> Pointer(R));
  ASSERT(Pointer(S) <> Pointer(A));
  ASSERT(Pointer(R) <> Pointer(A));

  if A^.SignFlag <> 0 then NXRaiseInvalidArg('ISqrtRem',esA_lt_0);

  z := IStackIndex;
  try
    SqrtRem(S,R,A);
    Result := R^.Size = 0;
  finally
    IStackRestore(z);
  end;
end;

//==============================================================================
// R := A**2
//==============================================================================
procedure ISqrTo(R,A: PBigInt);
  var
    s : SInt32;
    m : UInt32;
begin
  if Pointer(R) = Pointer(A) then
  begin
    ISqr(R);
    Exit;
  end;

  with R^ do
  begin
    if A^.Size > 1 then
    begin
      s := A^.Size shl 1;
      if s > Capacity then IIncCapacityUpTo(R,s);
      Digits^[s-1] := 0;
      RawSqrTo(Digits,A^.Digits,A^.Size);
      Dec(s,Ord(Digits^[s-1] = 0)); // decrease s (if need be)
      Size := s;
    end
    else
    if A^.Size > 0 then
    begin
      if Capacity = 0 then IIncCapacity(R);
      m := A^.Digits^[0];
      if (m and $ffff0000) <> 0 then
      begin
        PUInt64(Digits)^ := UInt64(m) * m;
        Size := 2;
      end
      else
      begin
        Digits^[0] := m * m;
        Size := 1;
      end;
    end
    else Size := 0; // A = 0 -> R := 0

    SignFlag := 0;
  end;
end;

//==============================================================================
// A := A - B
//==============================================================================
procedure ISub(A,B: PBigInt);
begin
  with A^ do
  if SignFlag <> B^.SignFlag then AddAbs(A,B)
  else
  case ICmpAbs(A,B) of
    0: begin
         Size := 0;
         SignFlag := 0;
       end;
    1: SubAbs(A,B);
    else
    SubAbsReverse(A,B);
    SignFlag := SignFlag xor 1; // ok, A^.Size > 0
  end;
end;

//==============================================================================
// A := B - A (Subtract reverse)
//==============================================================================
procedure ISubr(A,B: PBigInt);
begin
  with A^ do
  if SignFlag <> B^.SignFlag then
  begin
    AddAbs(A,B);
    SignFlag := SignFlag xor 1; // ok, A^.Size > 0
  end
  else
  case ICmpAbs(A,B) of
    0: begin
         Size := 0;
         SignFlag := 0;
       end;
    1: begin
         SubAbs(A,B);
         SignFlag := SignFlag xor 1; // ok, A^.Size > 0
       end;
    else
    SubAbsReverse(A,B);
  end;
end;

//==============================================================================
// A := A - B
//==============================================================================
procedure ISubSI32(A: PBigInt; B: SInt32);
begin
  if B < 0 then IAddUI32(A,-B) else ISubUI32(A,B);
end;

//==============================================================================
// A := A - B
//==============================================================================
procedure ISubSI64(A: PBigInt; B: SInt64);
begin
  if SInt32x2(B).Hi < 0 then IAddUI64(A,-B) else ISubUI64(A,B);
end;

//==============================================================================
// R := A - B
//==============================================================================
procedure ISubTo(R,A,B: PBigInt);
begin
  if Pointer(R) = Pointer(A) then
  begin
    ISub(R,B);
    Exit;
  end;

  if Pointer(R) = Pointer(B) then
  begin
    ISubr(R,A);
    Exit;
  end;

  if A^.Size >= B^.Size then
  begin
    ISet(R,A);
    ISub(R,B);
  end
  else
  begin
    ISet(R,B);
    ISubr(R,A);
  end;
end;

//==============================================================================
// A := A - B
//==============================================================================
procedure ISubUI32(A: PBigInt; B: UInt32);
begin
  with A^ do
  if SignFlag <> 0 then
  begin
    if RawAddUI32(Digits,Size,B) > 0 then
    begin
      if Size = Capacity then IIncCapacity(A);
      Digits^[Size] := 1;
      Inc(Size);
    end;
  end
  else
  if Size > 0 then // A > 0
  begin
    if RawSubUI32(Digits,Size,B) > 0 then // (borrow <> 0) -> (Size = 1)
    begin
      Digits^[0] := -Digits^[0];
      SignFlag := 1;
    end
    else
    if Digits^[Size-1] = 0 then Dec(Size); // ok, SignFlag = 0
  end
  else // A = 0
  if B > 0 then
  begin
    if Capacity = 0 then IIncCapacity(A);
    Digits^[0] := B;
    Size := 1;
    SignFlag := 1;
  end;
end;

//==============================================================================
// A := A - B
//==============================================================================
procedure ISubUI64(A: PBigInt; B: UInt64);
  var
    T : PBigInt;
    z : SInt32;
begin
  with UInt32x2(B) do
  if Hi > 0 then
  begin
    z := IStackGet(T);
    try
      ISetUI64(T,B);
      ISub(A,T);
    finally
      IStackRestore(z);
    end;
  end
  else
  if Lo > 0 then ISubUI32(A,Lo);
end;

//==============================================================================
// A <-> B
//==============================================================================
procedure ISwp(A,B: PBigInt);
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      mov   ecx, [eax+TBigInt.Digits]
      mov   ebx, [edx+TBigInt.Digits]
      mov   [eax+TBigInt.Digits], ebx
      mov   [edx+TBigInt.Digits], ecx
      mov   ecx, [eax+TBigInt.Capacity]
      mov   ebx, [edx+TBigInt.Capacity]
      mov   [eax+TBigInt.Capacity], ebx
      mov   [edx+TBigInt.Capacity], ecx
      mov   ecx, [eax+TBigInt.Size]
      mov   ebx, [edx+TBigInt.Size]
      mov   [eax+TBigInt.Size], ebx
      mov   [edx+TBigInt.Size], ecx
      mov   ecx, [eax+TBigInt.SignFlag]
      mov   ebx, [edx+TBigInt.SignFlag]
      mov   [eax+TBigInt.SignFlag], ebx
      mov   [edx+TBigInt.SignFlag], ecx
      pop   ebx
end;

//==============================================================================
// eXtended GCD (Bezout coefficients)
// -> A,B
// <- D := GCD(|A|,|B|)
// <- U,V, such that AU + BV = D
// <- Result, TRUE if D = 1, FALSE otherwise
//==============================================================================
function IXGCD(D,U,V,A,B: PBigInt): Boolean;
  var sfa, sfb : SInt32;
begin
  //-- require
  ASSERT(Pointer(D) <> Pointer(U));
  ASSERT(Pointer(D) <> Pointer(V));
  ASSERT(Pointer(D) <> Pointer(A));
  ASSERT(Pointer(D) <> Pointer(B));
  ASSERT(Pointer(U) <> Pointer(V));
  ASSERT(Pointer(U) <> Pointer(A));
  ASSERT(Pointer(U) <> Pointer(B));
  ASSERT(Pointer(V) <> Pointer(A));
  ASSERT(Pointer(V) <> Pointer(B));
  ASSERT(Pointer(A) <> Pointer(B));

  //-- U := 0
  U^.Size := 0;
  U^.SignFlag := 0;
  ISet1(V);
  sfa := A^.SignFlag;
  sfb := B^.SignFlag;
  try
    A^.SignFlag := 0; // A := |A|
    B^.SignFlag := 0; // B := |B|
    if A^.Size > 0 then
      if B^.Size > 0 then
        case ICmpAbs(A,B) of
          0: ISet(D,A); // U and V are ok
          1: LCXGCD(D,V,U,B,A);
          else
          LCXGCD(D,U,V,A,B);
        end
      else // B = 0
      begin
        ISet(D,A);
        ISwp(U,V);
      end
    else // A = 0
    if B^.Size > 0 then ISet(D,B)
    else
    begin
      //-- V := 0
      V^.Size := 0;
      V^.SignFlag := 0;
      //-- D := 0
      D^.Size := 0;
      D^.SignFlag := 0;
    end;
  finally
    if sfa <> 0 then
    begin
      A^.SignFlag := 1;
      INegate(U);
    end;
    if sfb <> 0 then
    begin
      B^.SignFlag := 1;
      INegate(V);
    end;
  end;
  Result := IEquAbs1(D);
end;

//==============================================================================
// A := A xor B
// A^.SignFlag := (A^.SignFlag xor B^.SignFlag) and ((|A| xor |B|)^.Size > 0)
//==============================================================================
procedure IXor(A,B: PBigInt);
begin
  with A^ do
  if Size < B^.Size then
  begin
    if Capacity < B^.Size then IIncCapacityUpTo(A,B^.Size);
    RawXor(Digits,B^.Digits,Size);
    Move(B^.Digits^[Size],Digits^[Size],(B^.Size-Size)*SizeOf(UInt32));
    Size := B^.Size;
    SignFlag := SignFlag xor B^.SignFlag; // ok, A^.Size > 0
  end
  else
  if Size > 0 then
  begin
    RawXor(Digits,B^.Digits,B^.Size);
    SignFlag := SignFlag xor B^.SignFlag;
    if (Size = B^.Size) and (Digits^[Size-1] = 0) then INormalize(A);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Strings
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
// Big integer to decimal string
//------------------------------------------------------------------------------
function BigIntToBase10Str(N: PBigInt): AnsiString;
  var
    D, M, Q, R : PBigInt;
    z, e, t    : SInt32;
    S          : AnsiString;
begin
  if N^.Size = 0 then
  begin
    Result := '0';
    Exit;
  end;

  //-- the estimate is always right or greater by 1
  t := NXEstimateDecimalSize(IBitSize(N));

{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Refine the tuning of e
  //
  e := SInt32(Trunc(Sqrt(t) * 4.5));
  while (e mod 9) <> 0 do Inc(e);
  if e > 9999 then e := 9999;

  if (t < 650) or (t <= e) then
  begin
    z := IStackGet(M);
    try
      ISetAbs(M,N);
      Result := RawToBase10Str(M^.Digits,M^.Size);
      // here, M is no more normalized, don't mind
    finally
      IStackRestore(z);
    end;
  end
  else
  begin
    Result := '';
    z := IStackGetMany([@M,@D,@Q,@R]);
    try
      ISetAbs(M,N);

      //-- D := 10**e
      ISetUI32(D,5);
      IPowUI32(D,e);
      IShl(D,e);

      //-- concat parts of length e (the last one is of length <= e)
      repeat
        IDivMod(Q,R,M,D);
        if R^.Size > 0 then
        begin
          //-- update result
          S := RawToBase10Str(R^.Digits,R^.Size);
          Result := S + Result;

          //-- if quotient = 0 then exit loop (and procedure)
          if Q^.Size = 0 then Break;

          //-- normalize R
          ISet0(R);

          //-- the remainder length might be smaller than e
          t := e - Length(S);
          if t > 0 then Result := StringOfChar('0',t) + Result;
        end
        else
          Result := StringOfChar('0',e) + Result;

        ISwp(M,Q);
      until false;
    finally
      IStackRestore(z);
    end;
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
function CheckBaseAndDigits(const S: AnsiString; Base: UInt32): Boolean;
  var i : SInt32;
begin
  Result := false;
  case Base of
     2: for i := 1 to Length(S) do if not (S[i] in ['0'..'1']) then Exit;
     4: for i := 1 to Length(S) do if not (S[i] in ['0'..'3']) then Exit;
     8: for i := 1 to Length(S) do if not (S[i] in ['0'..'7']) then Exit;
    10: for i := 1 to Length(S) do if not (S[i] in ['0'..'9']) then Exit;
    16: for i := 1 to Length(S) do
          if not (S[i] in ['0'..'9','A'..'F','a'..'f']) then Exit;
    else
    Exit;
  end;
  Result := true;
end;
{$ENDIF} // NX_DEBUG

//------------------------------------------------------------------------------
// String to big integer
//------------------------------------------------------------------------------
procedure RawStrToBigInt(N: PBigInt; const S: AnsiString; sf,Base: UInt32);
  var
    P       : PAnsiChar;
    D       : UInt32;
    Last, i : SInt32;
begin
  //-- require
{$IFDEF NX_DEBUG}
  ASSERT(sf < 2);
  ASSERT(CheckBaseAndDigits(S,Base));
{$ENDIF}

  Last := Length(S) - 1;

  if Last < 0 then // Length(S) = 0
  begin
    ISet0(N);
    Exit;
  end;

  P := PAnsiChar(S); // alias
  D := 0;

  case Base of
    2:
    with N^ do
    begin
      i := (Last shr 5) + 1;
      if Capacity < i then IIncCapacityUpTo(N,i);
      Size := i;
      for i := 0 to Last do
      begin
        if P^ = '1' then Inc(D);
        Inc(P);
        if ((Last-i) and 31) <> 0 then Inc(D,D)
        else
        begin
          Digits^[(Last-i) shr 5] := D;
          D := 0;
        end;
      end;
      INormalize(N);
    end;

    4:
    with N^ do
    begin
      i := (Last shr 4) + 1;
      if Capacity < i then IIncCapacityUpTo(N,i);
      Size := i;
      for i := 0 to Last do
      begin
        Inc(D,UInt32(Ord(P^) - Ord('0')));
        Inc(P);
        if ((Last-i) and 15) <> 0 then D := D shl 2
        else
        begin
          Digits^[(Last-i) shr 4] := D;
          D := 0;
        end;
      end;
      INormalize(N);
    end;

    8:
    begin
    {$IFDEF NX_LOCATE_TODO_NOTES}
      {$MESSAGE 'Do not forget me'}
    {$ENDIF}
      //
      // * (Over)estimate and set N^.Capacity before setting the digits
      //

      //-- first, k digits
      for i := 1 to ((Last + 1) mod 10) do
      begin
        D := D shl 3 + UInt32(Ord(P^) - Ord('0'));
        Inc(P);
      end;
      ISetUI32(N,D);
      //-- next, 10-digit blocks
      while P^ <> #0 do
      begin
        D := UInt32(Ord(P^) - Ord('0'));
        Inc(P);
        for i := 1 to 9 do
        begin
          D := D shl 3 + UInt32(Ord(P^) - Ord('0'));
          Inc(P);
        end;
        IShl(N,30); // N := N * 2**30
        IAddUI32(N,D);
      end;
    end;

    16:
    with N^ do
    begin
      i := (Last shr 3) + 1;
      if Capacity < i then IIncCapacityUpTo(N,i);
      Size := i;
      for i := 0 to Last do
      begin
        case P^ of
          '0'..'9': Inc(D,UInt32(Ord(P^) - Ord('0')));
          'A'..'F': Inc(D,UInt32(Ord(P^) - Ord('A') + 10));
          else // 'a'..'f'
          Inc(D,UInt32(Ord(P^) - Ord('a') + 10));
        end;
        Inc(P);
        if ((Last-i) and 7) <> 0 then D := D shl 4
        else
        begin
          Digits^[(Last-i) shr 3] := D;
          D := 0;
        end;
      end;
      INormalize(N);
    end;

    else // Base = 10
  {$IFDEF NX_LOCATE_TODO_NOTES}
    {$MESSAGE 'Do not forget me'}
  {$ENDIF}
    //
    // * (Over)estimate and set N^.Capacity before setting the digits
    //

    //-- first, k digits
    for i := 1 to (Last + 1) mod 9 do
    begin
      D := D * 10 + UInt32(Ord(P^) - Ord('0'));
      Inc(P);
    end;
    ISetUI32(N,D);
    //-- then, 9-digit blocks
    while P^ <> #0 do
    begin
      D := UInt32(Ord(P^) - Ord('0'));
      Inc(P);
      for i := 1 to 8 do
      begin
        D := D * 10 + UInt32(Ord(P^) - Ord('0'));
        Inc(P);
      end;
      IMulUI32(N,1000000000); // N := N * 10**9
      IAddUI32(N,D);
    end;
  end; // "case Base of"

  if N^.Size > 0 then N^.SignFlag := SInt32(sf);
end;

//==============================================================================
// A := S
//  '11' or '11E+0' are regarded as base 10 expressions;
//  '2#11#' or '2#11#E+0' are regarded as a base 2 expressions;
//  '4#11#' or '4#11#E+0' are regarded as a base 4 expressions;
//  '8#11#' or '8#11#E+0' are regarded as a base 8 expressions;
//  '10#11#' or '10#11#E+0' are regarded as a base 10 expressions;
//  '16#11#' or '16#11#E+0' are regarded as a base 16 expressions.
// Note that, '12.205E+3' being an integer, the call "ISetStr(A,'12.205E+3')"
// is ok.
//==============================================================================
procedure ISetStr(A: PBigInt; const S: AnsiString);
  var
    Data : TBigNumberData;
    T    : PBigInt;
    z    : SInt32;
begin
  //-- check syntax and setup Data
  z := NXGetBigNumberData(Data,S);

  if z <> 0 then NXRaiseInvalidArg('ISetStr',NXFmtStr(esSyntax_error_pos,[z]));

  with Data do
  begin
    if Exponent < 0 then NXRaiseInvalidArg('ISetStr',esNon_integer_result);

    if not (Base in [2,4,8,10,16]) then
      NXRaiseInvalidArg('ISetStr',esBase_is_not_in_2_4_8_10_16);

    RawStrToBigInt(A,Significand,SignFlag,Base);
    if Exponent > 0 then
      case Base of
         2: IShl(A,Exponent);   // A := A *  2**e
         4: IShl(A,Exponent*2); // A := A *  4**e = A * 2**(2e)
         8: IShl(A,Exponent*3); // A := A *  8**e = A * 2**(3e)
        16: IShl(A,Exponent*4); // A := A * 16**e = A * 2**(4e)
        else // Base = 10
        z := IStackGet(T);
        try
          ISetUI32(T,5);
          IPowUI32(T,Exponent);
          IMul(A,T);
          IShl(A,Exponent);       // A := A * 5**e * 2**e
        finally
          IStackRestore(z);
        end;
      end;
  end;

  ASSERT(IIsNormalized(A));
end;

//==============================================================================
// Return a string containing A expressed to the base Base
// A -> Bigint to convert to a string
// Base -> 2, 4, 8, 10 or 16
//   if Base =  2, Result := '[+|-]2#<int>#';
//   if Base =  4, Result := '[+|-]4#<int>#';
//   if Base =  8, Result := '[+|-]8#<int>#';
//   if Base = 10, Result := '[+|-]<int>';
//   if Base = 16, Result := '[+|-]16#<int>#'.
//   <int> is an expression depending on Base.
// BlockLength ->
//   If BlockLength > 0 then a separator is inserted every BlockLength digits
//   (if possible).
// Options ->
//   if sfoLeftPadded is in Options then Result is left padded with 0's (when
//   BlockLength > 0);
//   if sfoNoSign is in Options then Result is unsigned;
//   if sfoNoTrailingZeros is in Options then Result is, for instance, of the
//   form '1E+8' instead of '100000000'.
//==============================================================================
function IStr(
           A              : PBigInt;
           Base           : UInt32 = 10;
           BlockLength    : SInt32 = 0;
           Options        : TStrFormatOptionSet = [];
           BaseDelimiters : TStrBaseDelimiters = sbdDefault): AnsiString;
  var i, e : SInt32;
begin
  with A^ do
  case Base of
     2: Result := RawToBase2Str(Digits,Size);
     4: Result := RawToBase4Str(Digits,Size);
     8: Result := RawToBase8Str(Digits,Size);
    10: Result := BigIntToBase10Str(A);
    16: Result := RawToBase16Str(Digits,Size);
    else
    NXRaiseInvalidArg('IStr',esBase_is_not_in_2_4_8_10_16);
  end;

  e := 0;
  if sfoNoTrailingZeros in Options then
  begin
    i := Length(Result);
    while i > 1 do
    begin
      if Result[i] = '0' then Inc(e) else Break;
      Dec(i);
    end;
    if e > 0 then SetLength(Result,Length(Result)-e);
  end;

  //-- add separators
  if BlockLength > 0 then
    Result := NXInsertSeparatorsFromRight(Result,
                                          BlockLength,
                                          sfoLeftPadded in Options);

  //-- add base
  if ((Base <> 10) and (BaseDelimiters = sbdDefault)) or
     (BaseDelimiters = sbdAlways) then
    Result := Int2Str(Base) + '#' + Result + '#';

  //-- add exponent
  if e > 0 then Result := Result + 'E+' + Int2Str(e);

  //-- add sign
  if not (sfoNoSign in Options) then
    Result := PAnsiChar('+-')[A^.SignFlag] + Result;
end;

////////////////////////////////////////////////////////////////////////////////
// Stack
////////////////////////////////////////////////////////////////////////////////

const
  ucMaxStackSize = $ffff;
  ucMinStackInc = 16; // !!! should be a power of 2

type
  TIStack = packed record
    Base: PPBigIntFrame;
    Capacity: SInt32;    // big integers created (total)
    Index: SInt32;       // current stack index
{$IFDEF NX_THREAD_SAFE}
    ThreadID: TThreadID; // thread identifier
{$ENDIF}
  end;
{$IFDEF NX_THREAD_SAFE}
  PIStack = ^TIStack;
{$ENDIF}

{$IFDEF NX_THREAD_SAFE}
threadvar  // each thread has its own stack
{$ELSE}
var
{$ENDIF}
  uvIStack: TIStack;

{$IFDEF NX_THREAD_SAFE}
var
  uvIStackBook: TNXStackBook; // to [un]register the created stacks
{$ENDIF}

//------------------------------------------------------------------------------
// Free the stack of the current thread.
// Called by IContextDone.
// Do nothing if the stack is already destroyed.
//------------------------------------------------------------------------------
procedure IStackDone;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
  if uvIStackBook.UnregisterStack(ThreadID) then
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
    if Assigned(Base) then
    begin
      IFreeMany(Base,Capacity);
      ReAllocMem(Base,0);
    end;
    Capacity := 0;
    Index := 0;
  {$IFDEF NX_THREAD_SAFE}
    ThreadID := 0;
  {$ENDIF}
  end;
end;

//------------------------------------------------------------------------------
// Initialize the stack of the current thread.
// Called by IContextInit if NX_THREAD_SAFE is defined.
// Do nothing if the stack is already initialized.
//------------------------------------------------------------------------------
{$IFDEF NX_THREAD_SAFE}
procedure IStackInit;
  var ID: TThreadID;
begin
  ID := GetCurrentThreadID;
  if uvIStackBook.RegisterStack(ID) then
    with PIStack(@uvIStack)^ do
    begin
      Base := nil;
      Capacity := 0;
      Index := 0;
      ThreadID := ID;
    end;
end;
{$ENDIF} // NX_THREAD_SAFE

//==============================================================================
// Return uvIStack.Capacity (number of created big integers)
//==============================================================================
function IStackCapacity: SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if ThreadID <> GetCurrentThreadID then
      NXRaiseInvalidCall('IStackCapacity',esStack_not_initialized);
  {$ENDIF}
  {$ENDIF}

    Result := Capacity;
  end;
end;

//==============================================================================
// Get an integer (equal to 0) from the stack
// Result := stack index BEFORE allocating the integer
//==============================================================================
function IStackGet(out A: PBigInt): SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
    if Index = Capacity then IStackGrowUpTo(Capacity+1);
    Pointer(A) := Pointer(Base^[Index]);
    with A^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    Result := Index;
    Inc(Index);
  end;
end;

//==============================================================================
// Overloaded
// Get 2 integers (equal to 0) from the stack
// Result := stack index BEFORE allocating the integers
//==============================================================================
function IStackGetMany(out A,B: PBigInt): SInt32;
  var NewIndex: SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
    NewIndex := Index + 2;
    if NewIndex > Capacity then IStackGrowUpTo(NewIndex);
    Pointer(A) := Pointer(Base^[Index]);
    with A^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    Pointer(B) := Pointer(Base^[Index+1]);
    with B^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    Result := Index;
    Index := NewIndex;
  end;
end;

//==============================================================================
// Overloaded
// Get 3 integers (equal to 0) from the stack
// Result := stack index BEFORE allocating the integers
//==============================================================================
function IStackGetMany(out A,B,C: PBigInt): SInt32;
  var NewIndex: SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
    NewIndex := Index + 3;
    if NewIndex > Capacity then IStackGrowUpTo(NewIndex);
    Pointer(A) := Pointer(Base^[Index]);
    with A^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    Pointer(B) := Pointer(Base^[Index+1]);
    with B^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    Pointer(C) := Pointer(Base^[Index+2]);
    with C^ do
    begin
      Size := 0;
      SignFlag := 0;
    end;
    Result := Index;
    Index := NewIndex;
  end;
end;

//==============================================================================
// Overloaded
// Get A[i]^ from the stack (equal to 0 for all i)
// Result := stack index BEFORE allocating the integers
//------------------------------------------------------------------------------
// Should be called this way "IStackGetMany([@A0,@A1,...])" where the Ai's
// are PBigInt pointers.
//==============================================================================
function IStackGetMany(const A: array of PPBigInt): SInt32;
  var
    SB          : PPBigIntFrame;
    NewIndex, i : SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
    NewIndex := Index + Length(A);
    if NewIndex > Capacity then IStackGrowUpTo(NewIndex);
    SB := @Base^[Index]; // alias
    for i := High(A) downto 0 do
    begin
      with SB^[i]^ do
      begin
        Size := 0;
        SignFlag := 0;
      end;
      Pointer(A[i]^) := Pointer(SB^[i]);
    end;
    Result := Index;
    Index := NewIndex;
  end;
end;

//==============================================================================
// Overloaded
// Get A^[i] from the stack (equal to 0 for all i)
// -> Count, number of BigInts to get (A should be sufficiently sized)
// Result := stack index BEFORE allocating the integers
//==============================================================================
function IStackGetMany(const A: PPBigIntFrame; Count: SInt32): SInt32;
  var
    SB          : PPBigIntFrame;
    NewIndex, i : SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
    NewIndex := Index + Count;
    if NewIndex > Capacity then IStackGrowUpTo(NewIndex);
    SB := @Base^[Index]; // alias
    for i := Count-1 downto 0 do
    begin
      with SB^[i]^ do
      begin
        Size := 0;
        SignFlag := 0;
      end;
      Pointer(A^[i]) := Pointer(SB^[i]);
    end;
    Result := Index;
    Index := NewIndex;
  end;
end;

//==============================================================================
// Increase uvIStack upto NewCapacity (rounded upwards modulo ucMinStackInc)
// Do nothing whenever NewCapacity <= FStackCapacity
//==============================================================================
procedure IStackGrowUpTo(NewCapacity: SInt32);
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if ThreadID <> GetCurrentThreadID then
      NXRaiseInvalidCall('IStackGrowUpTo',esStack_not_initialized);
  {$ENDIF}
  {$ENDIF}

    if NewCapacity > Capacity then
    begin
      if UInt32(NewCapacity) > UInt32(ucMaxStackSize) then
        NXRaiseSizeError('IStackGrowUpTo');

      NewCapacity := (NewCapacity + (ucMinStackInc-1)) and (-ucMinStackInc);
      ReAllocMem(Base,NewCapacity*SizeOf(PBigInt));
      FillChar(Base^[Capacity],(NewCapacity-Capacity)*SizeOf(PBigInt),0);
      while Capacity < NewCapacity do
      begin
        INew(Base^[Capacity]);
        Inc(Capacity);
      end;
    end;
  end;
end;

//==============================================================================
// Result := current stack index
//==============================================================================
function IStackIndex: SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if ThreadID <> GetCurrentThreadID then
      NXRaiseInvalidCall('IStackIndex',esStack_not_initialized);
  {$ENDIF}
  {$ENDIF}

    Result := Index;
  end;
end;

//==============================================================================
// Pack all integers of the stack
// Also pack uvIStack.Base if DoPackAll is TRUE
//==============================================================================
procedure IStackPack(DoPackAll: Boolean = false);
  var NewCapacity: SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if ThreadID <> GetCurrentThreadID then
      NXRaiseInvalidCall('IStackPack',esStack_not_initialized);
  {$ENDIF}
  {$ENDIF}

    //-- pack the base?
    if DoPackAll then
    begin
      NewCapacity := (Index + (ucMinStackInc-1)) and (-ucMinStackInc);
      if NewCapacity < Capacity then
      begin
        IFreeMany(@Base^[NewCapacity],Capacity-NewCapacity);
        Capacity := NewCapacity;
        ReAllocMem(Base,NewCapacity*SizeOf(PBigInt));
      end;
    end;

    //-- pack the integers in Base[0..Index-1]
    IPackMany(Base,Index);

    //-- pack the integers in Base[Index..Capacity-1]
    ISet0PackedMany(@Base^[Index],Capacity-Index);
  end;
end;

//==============================================================================
// Set uvIStack.Index equal to PreviousIndex
//==============================================================================
procedure IStackRestore(PreviousIndex: SInt32);
begin
{$IFDEF NX_THREAD_SAFE}
  with PIStack(@uvIStack)^ do
{$ELSE}
  with uvIStack do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if ThreadID <> GetCurrentThreadID then
      NXRaiseInvalidCall('IStackRestore',esStack_not_initialized);
  {$ENDIF}
  {$ENDIF}
    ASSERT(PreviousIndex <= Index);

    Index := PreviousIndex;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Initialization/Finalization
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Finalize the unit variables
// ! Should be called once in each thread using nx_z before destroying this
// thread.
// ! Is called once in the finalization part of this unit, so no need to call
// it from the main thread.
//==============================================================================
procedure IContextDone;
begin
  IStackDone;
end;

//==============================================================================
// Initialize the unit variables
// ! Should be called once in each thread using nx_z routines (before using
// them).
// ! Is called once in the initialization part of this unit, so no need to call
// it from the main thread.
//==============================================================================
{$IFDEF NX_THREAD_SAFE}
procedure IContextInit;
begin
  IStackInit;
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
initialization
{$IFDEF NX_CHECKS}
  //-- ucMinBigIntInc should be a power of 2 greater than or equal to 2
  if ((ucMinBigIntInc and Pred(ucMinBigIntInc)) <> 0) or
     (ucMinBigIntInc < 2) then
    RunError(255);

  //-- ucMinStackInc should be a power of 2
  if ((ucMinStackInc and Pred(ucMinStackInc)) <> 0) or (ucMinStackInc = 0) then
    RunError(255);

  //-- SizeOf(TBigInt) should be a multiple of 4
  if (SizeOf(TBigInt) and 3) <> 0 then RunError(255);

  //-- both types should have the same size
  if SizeOf(TPBigIntFrame) <> SizeOf(PBigInt) then RunError(255);
{$ENDIF}

{$IFDEF NX_THREAD_SAFE}
  uvIStackBook := TNXStackBook.Create;
  IContextInit;
{$ENDIF}

finalization
  IContextDone;

{$IFDEF NX_THREAD_SAFE}
  uvIStackBook.Free;
{$ENDIF}
end.
////////////////////////////////////////////////////////////////////////////////

//
//  Sometimes TURBO DELPHI EXPLORER stops compiling with the message
//
//    "[Pascal Fatal Error] nx_z.pas: F2084 Internal Error: URW821".
//
//  When this is the case just make a build with <Shift-F9>, this is sufficient
//  to make DELPHI happy.
//

