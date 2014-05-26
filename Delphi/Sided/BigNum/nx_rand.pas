////////////////////////////////////////////////////////////////////////////////
// Random Number Generator
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
unit nx_rand;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
uses nx_types;
////////////////////////////////////////////////////////////////////////////////


function  NXRndBool: Boolean;
function  NXRndReal: Real;
procedure NXRndSeed(const Seed; Count: SInt32); overload;
procedure NXRndSeed(const Seed: array of UInt32); overload;
procedure NXRndSeed(Seed: UInt32); overload;
procedure NXRndSeedTime;
function  NXRndSI32: SInt32; {$IFDEF NX_HAS_INLINE} inline; {$ENDIF}
function  NXRndSI64: SInt64; {$IFDEF NX_HAS_INLINE} inline; {$ENDIF}
function  NXRndUI32: UInt32;
procedure NXRndUI32s(out X; Count: SInt32);
function  NXRndUI64: UInt64; {$IFDEF NX_HAS_INLINE} inline; {$ENDIF}


////////////////////////////////////////////////////////////////////////////////
implementation
uses
{$IFDEF NX_THREAD_SAFE}
{$IFDEF NX_DEBUG}
{$IFDEF DELPHI}
  Windows,
{$ENDIF}
{$ENDIF}
{$ENDIF}
  USE_Types,
  USE_Utils,
  nx_errors,
  nx_common;
////////////////////////////////////////////////////////////////////////////////

//-- the two following directives should not be modified
{$Q-}
{$R-}

// REFERENCE -------------------------------------------------------------------
// M. Matsumoto and T. Nishimura,
// "Mersenne Twister: A 623-Dimensionally Equidistributed Uniform
// Pseudo-Random Number Generator",
// ACM Transactions on Modeling and Computer Simulation,
// Vol. 8, No. 1, January 1998, pp 3-30.
//------------------------------------------------------------------------------
// To check the generator :
//
//    NXRndSeed([$123,$234,$345,$456]);
//    for i := 1 to 1000 do Write(NXRndDWord,', ');
//
// This should produce
// 1067595299, 1437477411, 477289528, 4107218783, 4228976476,
// ...,
// 2643151863, 3896204135, 2416995901, 1397735321, 3460025646
//------------------------------------------------------------------------------

// The period of the generator is 2**19937 - 1
// The generator is not cryptographically secure
//
// Each thread has its own generator that should be initialized within
// the thread (the generator of the main thread is initialized in the
// initialization part of this unit).

type
  TRndData = array [0..623] of SInt32;
  TRndContext = packed record
    Data  : TRndData;
    Index : SInt32;
    Bits  : UInt32;
    Mask  : UInt32;
{$IFDEF NX_THREAD_SAFE}
{$IFDEF NX_DEBUG}
    TTID  : TThreadID; // thread identifier
{$ENDIF}
{$ENDIF}
  end;
{$IFDEF NX_THREAD_SAFE}
  PRndContext = ^TRndContext;
{$ENDIF}

//-- unit variable
{$IFDEF NX_THREAD_SAFE}
threadvar
{$ELSE}
var
{$ENDIF}
  uvRndContext: TRndContext;


//----------------------------------------------------------------------------
// Update Data[] and set Index to 0
//----------------------------------------------------------------------------
procedure UpdateData(var Data: TRndData; var Index: SInt32);
  const
    Z : array [0..1] of SInt32 = (0,SInt32($9908b0df));
    C1 = SInt32($80000000);
    C2 = SInt32($7fffffff);
  var i, t : SInt32;
begin
  for i := 0 to 226 do
  begin
    t := (Data[i] and C1) or (Data[i+1] and C2);
    Data[i] := Data[i+397] xor (t shr 1) xor Z[t and 1];
  end;
  for i := 227 to 622 do
  begin
    t := (Data[i] and C1) or (Data[i+1] and C2);
    Data[i] := Data[i-227] xor (t shr 1) xor Z[t and 1];
  end;
  t := (Data[623] and C1) or (Data[0] and C2);
  Data[623] := Data[396] xor (t shr 1) xor Z[t and 1];
  Index := 0;
end;

//==============================================================================
// Result := 'random' boolean
//==============================================================================
function NXRndBool: Boolean;
begin
{$IFDEF NX_THREAD_SAFE}
  with PRndContext(@uvRndContext)^ do
{$ELSE}
  with uvRndContext do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if TTID <> GetCurrentThreadID then
      NXRaiseInvalidCall('NXRndBool',esRandom_generator_not_initialized);
  {$ENDIF}
  {$ENDIF}

    Inc(Mask,Mask);
    if Mask = 0 then
    begin
      Mask := 1;
      if Index > 623 then UpdateData(Data,Index);
      Bits := UInt32(Data[Index]);
      Inc(Index);
      Bits := Bits xor (Bits shr 11);
      Bits := Bits xor ((Bits shl 7) and $9d2c5680);
      Bits := Bits xor ((Bits shl 15) and $efc60000);
      Bits := Bits xor (Bits shr 18);
    end;
    Result := (Bits and Mask) <> 0;
  end;
end;

//==============================================================================
// Result := 'random' real in [0.0, 1.0)
//==============================================================================
function NXRndReal: Real;
{$IFDEF DELPHI}
  const ONE : Real = 1.0;
{$ENDIF}
begin
{$IFDEF FREE_PASCAL}
{$IFDEF FPC_HAS_TYPE_DOUBLE}
  NXRndUI32s(Result,2);
  with UInt32x2(Result) do Hi := (Hi and $000fffff) or $3ff00000;
{$ELSE}
{$IFDEF FPC_HAS_TYPE_SINGLE}
  UInt32(Result) := (NXRndUI32 and $007fffff) or $3f800000;
{$ELSE}
  {$FATAL Type Real should be defined as Double or as Single}
{$ENDIF} // FPC_HAS_TYPE_SINGLE
{$ENDIF} // FPC_HAS_TYPE_DOUBLE
  Result := Result - Real(1.0);
{$ENDIF} // FREE_PASCAL

{$IFDEF DELPHI}
  //-- Real = Double
  NXRndUI32s(Result,2);
  with UInt32x2(Result) do Hi := (Hi and $000fffff) or $3ff00000;
  Result := Result - ONE;
{$ENDIF} // DELPHI
end;

//==============================================================================
// Overloaded
// Initialize the random generator with Seed (regarded as an array of Count
// 32-bit words)
// -> Count > 0
//==============================================================================
procedure NXRndSeed(const Seed; Count: SInt32);
  const
    M0 = SInt32(1812433253);
    M1 = SInt32(1664525);
    M2 = SInt32(1566083941);
  var
    S             : TSInt32Frame absolute Seed;
    i, j, k, kmax : SInt32;
begin
  if Count <= 0 then NXRaiseInvalidArg('NXRndSeed',esCount_lt_1);

{$IFDEF NX_THREAD_SAFE}
  with PRndContext(@uvRndContext)^ do
{$ELSE}
  with uvRndContext do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    TTID := GetCurrentThreadID;
  {$ENDIF}
  {$ENDIF}

    //-- 1st pass
    Data[0] := 19650218;
    for i := 1 to 623 do
      Data[i] := ((Data[i-1] xor (Data[i-1] shr 30))*M0) + i;

    //-- 2nd pass
    i := 1;
    j := 0;
    if Count < 624 then kmax := 623 else kmax := Pred(Count);
    for k := kmax downto 0 do
    begin
      Data[i] :=
        (Data[i] xor ((Data[i-1] xor (Data[i-1] shr 30))*M1)) + S[j] + j;
      Inc(i);
      if i > 623 then
      begin
        Data[0] := Data[623];
        i := 1;
      end;
      Inc(j);
      if j >= Count then j := 0;
    end;

    //-- 3rd pass
    for k := 623 downto 0 do
    begin
      Data[i] := (Data[i] xor ((Data[i-1] xor (Data[i-1] shr 30))*M2)) - i;
      Inc(i);
      if i > 623 then
      begin
        Data[0] := Data[623];
        i := 1;
      end;
    end;
    Data[0] := SInt32($80000000);

    //-- Index > 623 means uvRndContext has to be updated before being used
    Index := 624;
    Mask := 0;
  end;
end;

//==============================================================================
// Overloaded
// Initialize the random generator with the Seed array
// -> Seed, any
//==============================================================================
procedure NXRndSeed(const Seed: array of UInt32);
begin
  NXRndSeed(Seed,Length(Seed));
end;

//==============================================================================
// Overloaded
// Initialize the random generator with Seed
//------------------------------------------------------------------------------
// Notice that NXRndSeed(x) is not equivalent to NXRndSeed([x]). This is not
// very coherent but this is the way the generator was designed.
//==============================================================================
procedure NXRndSeed(Seed: UInt32);
  const M = SInt32(1812433253);
  var i : SInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PRndContext(@uvRndContext)^ do
{$ELSE}
  with uvRndContext do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    TTID := GetCurrentThreadID;
  {$ENDIF}
  {$ENDIF}

    Data[0] := SInt32(Seed);
    for i := 1 to 623 do Data[i] := ((Data[i-1] xor (Data[i-1] shr 30))*M) + i;
    Index := 624;
    Mask := 0;
  end;
end;

//==============================================================================
// Result := 'random' SInt32
//==============================================================================
function NXRndSI32: SInt32;
begin
  Result := SInt32(NXRndUI32);
end;

//==============================================================================
// Result := 'random' SInt64
//==============================================================================
function NXRndSI64: SInt64;
begin
  NXRndUI32s(Result,2);
end;

//==============================================================================
// Initialize the random generator with the SysUtils.Now function
//==============================================================================
procedure NXRndSeedTime;
  var T : TDateTime; // 64-bit type (equiv. to type Double)
begin
  T := Now;
  NXRndSeed(T,SizeOf(T) shr 2);
end;

//==============================================================================
// Result := 'random' UInt32
//==============================================================================
function NXRndUI32: UInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PRndContext(@uvRndContext)^ do
{$ELSE}
  with uvRndContext do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if TTID <> GetCurrentThreadID then
      NXRaiseInvalidCall('NXRndUI32',esRandom_generator_not_initialized);
  {$ENDIF}
  {$ENDIF}

    if Index > 623 then UpdateData(Data,Index);
    Result := UInt32(Data[Index]);
    Inc(Index);
    Result := Result xor (Result shr 11);
    Result := Result xor ((Result shl 7) and $9d2c5680);
    Result := Result xor ((Result shl 15) and $efc60000);
    Result := Result xor (Result shr 18);
  end;
end;

//==============================================================================
// Fill X with Count 'random' UInt32's
//==============================================================================
procedure NXRndUI32s(out X; Count: SInt32);
  var
    R : TUInt32Frame absolute X;
    t : UInt32;
begin
{$IFDEF NX_THREAD_SAFE}
  with PRndContext(@uvRndContext)^ do
{$ELSE}
  with uvRndContext do
{$ENDIF}
  begin
  {$IFDEF NX_THREAD_SAFE}
  {$IFDEF NX_DEBUG}
    if TTID <> GetCurrentThreadID then
      NXRaiseInvalidCall('NXRndUI32s',esRandom_generator_not_initialized);
  {$ENDIF}
  {$ENDIF}

    while Count > 0 do
    begin
      Dec(Count);
      if Index > 623 then UpdateData(Data,Index);
      t := UInt32(Data[Index]);
      Inc(Index);
      t := t xor (t shr 11);
      t := t xor ((t shl 7) and $9d2c5680);
      t := t xor ((t shl 15) and $efc60000);
      R[Count] := t xor (t shr 18);
    end;
  end;
end;

//==============================================================================
// Result := 'random' UInt64
//==============================================================================
function NXRndUI64: UInt64;
begin
  NXRndUI32s(Result,2);
end;

////////////////////////////////////////////////////////////////////////////////
initialization
  NXRndSeedTime; // initialize the main thread generator
end.
////////////////////////////////////////////////////////////////////////////////

