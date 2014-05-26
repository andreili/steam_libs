///////////////////////////////////////////////////////////////////////////////
// Kernel
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
unit nx_kernel;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
uses nx_types;
////////////////////////////////////////////////////////////////////////////////


{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Add Mul3 func
  // * Add a FFT multiplication (for very big numbers)
  //

function  RawAdd(P,Q: PUInt32Frame; Count: SInt32): UInt32;
function  RawAddMulUI32(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
function  RawAddTo(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
function  RawAddUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
procedure RawAnd(P,Q: PUInt32Frame; Count: SInt32);
function  RawBitCount(P: PUInt32Frame; Count: SInt32): SInt32;
function  RawBitScanForward(P: PUInt32Frame; Count: SInt32): SInt32;
function  RawByteCount(P: PUInt32Frame; Count: SInt32): SInt32;
procedure RawByteSwap(P: PUInt32Frame; Count: SInt32);
function  RawCmp(P,Q: PUInt32Frame; Count: SInt32): SInt32;
function  RawCRC(P: PUInt32Frame; Count: SInt32; CRC: UInt32): UInt32;
function  RawDivUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
procedure RawDivUI32Exact(P: PUInt32Frame; Count: SInt32; D,I: UInt32);
function  RawMod3(P: PUInt32Frame; Count: SInt32): UInt32;
function  RawModUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
function  RawModUI32I(P: PUInt32Frame; Count: SInt32; D,I: UInt32): UInt32;
procedure RawMulStdTo(P,Q,R: PUInt32Frame; QCount,RCount: SInt32);
procedure RawMulTo(P,Q,R: PUInt32Frame; Count: SInt32);
function  RawMulUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
function  RawMulUI32To(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
procedure RawNot(P: PUInt32Frame; Count: SInt32);
procedure RawOr(P,Q: PUInt32Frame; Count: SInt32);
function  RawParityOdd(P: PUInt32Frame; Count: SInt32): Boolean;
function  RawShl(P: PUInt32Frame; Count,Shift: SInt32): UInt32;
function  RawShr(P: PUInt32Frame; Count, Shift: SInt32): Boolean;
function  RawShr1(P: PUInt32Frame; Count: SInt32): Boolean;
procedure RawSqrTo(P,Q: PUInt32Frame; Count: SInt32);
function  RawSub(P,Q: PUInt32Frame; Count: SInt32): UInt32;
function  RawSubr(P,Q: PUInt32Frame; Count: SInt32): UInt32;
function  RawSubTo(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
function  RawSubUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
function  RawWeight(P: PUInt32Frame; Count: SInt32): SInt32;
procedure RawXor(P,Q: PUInt32Frame; Count: SInt32);

//
// deprecated (will be removed from v0.33.0)
//
function  RawAddd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawAddMuld(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawDivd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
procedure RawDivde(P: PUInt32Frame; Count: SInt32; D,I: UInt32); {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawModd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawModdi(P: PUInt32Frame; Count: SInt32; D,I: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawMuld(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawMuldTo(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}
function  RawSubd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32; {$IFDEF HAS_DEPRECATED} deprecated; {$ENDIF}


////////////////////////////////////////////////////////////////////////////////
implementation
uses nx_common;
////////////////////////////////////////////////////////////////////////////////

{$DEFINE USE_STACK_AS_HEAP} // see RawMulTo and RawSqrTo

{$IFDEF FREE_PASCAL}
  {$ASMMODE INTEL}
{$ENDIF}

//-- the two following directives should not be modified
{$Q-}
{$R-}

//==============================================================================
// P[] := P[] + Q[] (on Count 32-bit words)
// Result := last carry (0 or 1)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawAddDebug(P,Q: PUInt32Frame; Count: SInt32): UInt32;
{$ELSE}
function RawAdd(P,Q: PUInt32Frame; Count: SInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      shr   ecx, 2
      clc
      jz    @@02
      push  esi
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   esi, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      adc   esi, [eax+ebx*1]
      adc   edi, [eax+ebx*1+4]
      mov   [eax+ebx*1], esi
      mov   [eax+ebx*1+4], edi
      mov   esi, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      adc   esi, [eax+ebx*1+8]
      adc   edi, [eax+ebx*1+12]
      mov   [eax+ebx*1+8], esi
      mov   [eax+ebx*1+12], edi
      dec   ecx
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   esi
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      adc   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R2: mov   edi, [edx+ebx*1]
      adc   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R1: mov   edi, [edx+ebx*1]
      adc   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: sbb   eax, eax
      pop   ebx
      neg   eax
      pop   edi
end;

{$IFDEF NX_DEBUG}
function RawAdd(P,Q: PUInt32Frame; Count: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE0000000) = 0); // Count in 0..2**25-1?

  Result := RawAddDebug(P,Q,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] + Q[] * D (on Count 32-bit words)
// Result := last carry
//==============================================================================
{$IFDEF NX_DEBUG}
function RawAddMulUI32Debug(
           P,Q   : PUInt32Frame;
           Count : SInt32;
           D     : UInt32): UInt32;
{$ELSE}
function RawAddMulUI32(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI : UInt32;
asm
      cmp   D, 2
      je    @@10          // jmp if D=2
      jb    @@20          // jmp if D=0 or 1

      mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi
      push  ebp
      mov   edi, ecx
      mov   ebp, D
      and   edi, 3
      xor   ebx, ebx
      push  edi
      mov   esi, eax
      shr   ecx, 2
      mov   edi, edx
      jz    @@02

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      mov   eax, [edi+4]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi+4]
      adc   edx, 0
      mov   [esi+4], eax
      mov   ebx, edx
      mov   eax, [edi+8]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi+8]
      adc   edx, 0
      mov   [esi+8], eax
      mov   ebx, edx
      mov   eax, [edi+12]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi+12]
      adc   edx, 0
      mov   [esi+12], eax
      add   edi, 16
      add   esi, 16
      dec   ecx
      mov   ebx, edx
      jnz   @@01

@@02: pop   ecx
      jmp   dword ptr @@RX[ecx*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      add   edi, 4
      add   esi, 4
      mov   ebx, edx
@@R2: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      add   edi, 4
      add   esi, 4
      mov   ebx, edx
@@R1: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
@@R0: pop   ebp
      mov   eax, ebx      // Result := carry
      mov   esi, SESI
      mov   edi, SEDI
      mov   ebx, SEBX
      mov   esp, ebp
      pop   ebp
      ret   4

      //-- D = 2
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@10: mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      mov   esi, eax
      push  edi
      shr   ecx, 2
      mov   edi, edx
      jz    @@12

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@11: mov   eax, [edi]
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      mov   eax, [edi+4]
      xor   ebx, ebx
      add   eax, eax
      adc   ebx, ebx
      add   eax, edx
      adc   ebx, 0
      add   eax, [esi+4]
      adc   ebx, 0
      mov   [esi+4], eax
      mov   eax, [edi+8]
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi+8]
      adc   edx, 0
      mov   [esi+8], eax
      mov   eax, [edi+12]
      xor   ebx, ebx
      add   eax, eax
      adc   ebx, ebx
      add   eax, edx
      adc   ebx, 0
      add   eax, [esi+12]
      adc   ebx, 0
      mov   [esi+12], eax
      dec   ecx
      lea   edi, [edi+16]
      lea   esi, [esi+16]
      jnz   @@11

@@12: pop   ecx
      jmp   dword ptr @@SX[ecx*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@SX: dd    @@S0,@@S1,@@S2,@@S3
@@S3: mov   eax, [edi]
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      add   edi, 4
      add   esi, 4
      mov   ebx, edx
@@S2: mov   eax, [edi]
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      add   edi, 4
      add   esi, 4
      mov   ebx, edx
@@S1: mov   eax, [edi]
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, ebx
      adc   edx, 0
      add   eax, [esi]
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
@@S0: mov   esi, SESI
      mov   eax, ebx      // Result := carry
      mov   edi, SEDI
      mov   ebx, SEBX
      mov   esp, ebp
      pop   ebp
      ret   4

      //-- D = 0 or 1
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@20: cmp   D, 0
      je    @@30
      call  RawAdd        // D = 1, Result := RawAdd(P,Q,Count)
      mov   esp, ebp
      pop   ebp
      ret   4

@@30: xor   eax, eax      // D = 0, exit with Result = 0
end;

{$IFDEF NX_DEBUG}
function RawAddMulUI32(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE0000000) = 0); // Count in 0..2**25-1?

  Result := RawAddMulUI32Debug(P,Q,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawAddMuld(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawAddMulUI32(P,Q,Count,D);
end;

//==============================================================================
// P[] := Q[] + R[] (on Count 32-bit words)
// Result := last borrow (0 or 1)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawAddToDebug(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
{$ELSE}
function RawAddTo(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI : UInt32;
asm
      mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi
      mov   edi, Count
      xor   ebx, ebx
      mov   esi, edi
      and   edi, 3
      shr   esi, 2
      clc
      jz    @@02
      push  ebp
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   ebp, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      adc   ebp, [ecx+ebx*1]
      adc   edi, [ecx+ebx*1+4]
      mov   [eax+ebx*1], ebp
      mov   [eax+ebx*1+4], edi
      mov   ebp, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      adc   ebp, [ecx+ebx*1+8]
      adc   edi, [ecx+ebx*1+12]
      mov   [eax+ebx*1+8], ebp
      mov   [eax+ebx*1+12], edi
      dec   esi
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   ebp
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      adc   edi, [ecx+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R2: mov   edi, [edx+ebx*1]
      adc   edi, [ecx+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R1: mov   edi, [edx+ebx*1]
      adc   edi, [ecx+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: mov   esi, SESI
      sbb   eax, eax
      mov   edi, SEDI
      mov   ebx, SEBX
      neg   eax
end;

{$IFDEF NX_DEBUG}
function RawAddTo(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawAddToDebug(P,Q,R,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] + D (on Count 32-bit words)
// Return carry: 0 or 1 (or D if Count = 0)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawAddUI32Debug(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ELSE}
function RawAddUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      dec   edx             // Count := Count - 1
      js    @@02            // jmp if Count < 0

      add   [eax], ecx      // P[0] := P[0] + D
      mov   ecx, 0          // do not modify CF
      jnc   @@02            // jmp if no carry
      inc   ecx             // Result = 1

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: dec   edx             // Count := Count - 1
      lea   eax, [eax+4]    // i := i + 1
      js    @@02            // jmp if Count < 0 (Result = 1)
      inc   dword ptr [eax] // P[i] := P[i] + 1
      jz    @@01            // jmp if carry

      dec   ecx             // Result = 0
@@02: mov   eax, ecx        // Result := 0, 1 or D
end;

{$IFDEF NX_DEBUG}
function RawAddUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE0000000) = 0); // Count in 0..2**25-1?

  Result := RawAddUI32Debug(P,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawAddd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawAddUI32(P,Count,D);
end;

//==============================================================================
// P[] := P[] and Q[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
procedure RawAndDebug(P,Q: PUInt32Frame; Count: SInt32);
{$ELSE}
procedure RawAnd(P,Q: PUInt32Frame; Count: SInt32);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      shr   ecx, 2
      jz    @@02
      push  esi
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   esi, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      and   esi, [eax+ebx*1]
      and   edi, [eax+ebx*1+4]
      mov   [eax+ebx*1], esi
      mov   [eax+ebx*1+4], edi
      mov   esi, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      and   esi, [eax+ebx*1+8]
      and   edi, [eax+ebx*1+12]
      mov   [eax+ebx*1+8], esi
      mov   [eax+ebx*1+12], edi
      dec   ecx
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   esi
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      and   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      add   ebx, 4
@@R2: mov   edi, [edx+ebx*1]
      and   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      add   ebx, 4
@@R1: mov   edi, [edx+ebx*1]
      and   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: pop   ebx
      pop   edi
end;

{$IFDEF NX_DEBUG}
procedure RawAnd(P,Q: PUInt32Frame; Count: SInt32);
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  RawAndDebug(P,Q,Count);
end;
{$ENDIF}

//==============================================================================
// Result := Bit count of P^[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawBitCountDebug(P: PUInt32Frame; Count: SInt32): SInt32;
{$ELSE}
function RawBitCount(P: PUInt32Frame; Count: SInt32): SInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      dec   edx
      jl    @@01
      bsr   ecx, [eax+edx*4]
      shl   edx, 5
      add   edx, ecx
@@01: inc   edx
      mov   eax, edx
end;

{$IFDEF NX_DEBUG}
function RawBitCount(P: PUInt32Frame; Count: SInt32): SInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawBitCountDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// Bit Scan Forward
// Return the indice of the first trailing bit of P[] that is not null (scan on
// Count 32-bit words)
// Return -1 if Count = 0 or if P[] contains only 0s
//==============================================================================
{$IFDEF NX_DEBUG}
function RawBitScanForwardDebug(P: PUInt32Frame; Count: SInt32): SInt32;
{$ELSE}
function RawBitScanForward(P: PUInt32Frame; Count: SInt32): SInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      mov   edi, eax
      test  edx, edx
      mov   eax, -1
      jz    @@01             // exit if Count = 0 (with Result = -1)
      mov   ecx, edx         // ecx := Count
      cld                    // presumably useless but better sure than sorry
      xor   eax, eax
      mov   edx, edi         // save value
      repe  scasd
      sub   edi, 4
      mov   eax, -1
      bsf   ecx, [edi]
      jz    @@01             // P[] contains only 0s (exit with Result = -1)
      sub   edi, edx
      lea   eax, [ecx+edi*8]
@@01: pop   edi
end;

{$IFDEF NX_DEBUG}
function RawBitScanForward(P: PUInt32Frame; Count: SInt32): SInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawBitScanForwardDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// Result := Byte count of P[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawByteCountDebug(P: PUInt32Frame; Count: SInt32): SInt32;
{$ELSE}
function RawByteCount(P: PUInt32Frame; Count: SInt32): SInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      test  edx, edx
      jz    @@01
      dec   edx
      mov   eax, [eax+edx*4]
      lea   edx, [edx*4+1]
      shr   eax, 8
      jz    @@01
      inc   edx
      shr   eax, 8
      jz    @@01
      inc   edx
      shr   eax, 8
      jz    @@01
      inc   edx
@@01: mov   eax, edx
end;

{$IFDEF NX_DEBUG}
function RawByteCount(P: PUInt32Frame; Count: SInt32): SInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawByteCountDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// Swap the four UInt8s of the Count UInt32s of P[]
//==============================================================================
{$IFDEF NX_DEBUG}
procedure RawByteSwapDebug(P: PUInt32Frame; Count: SInt32);
{$ELSE}
procedure RawByteSwap(P: PUInt32Frame; Count: SInt32);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      test  edx, 1
      jz    @@01
      dec   edx
      mov   ecx, [eax+edx*4]
  {$IFDEF NX_BSWAP_SUPPORTED}
      bswap ecx
  {$ELSE}
      rol   cx, 8
      rol   ecx, 16
      rol   cx, 8
  {$ENDIF}
      mov   [eax+edx*4], ecx
@@01: test  edx, edx
      jz    @@FF
      push  ebx

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: sub   edx, 2
      mov   ebx, [eax+edx*4]
      mov   ecx, [eax+edx*4+4]
  {$IFDEF NX_BSWAP_SUPPORTED}
      bswap ebx
      bswap ecx
  {$ELSE}
      rol   bx, 8
      rol   cx, 8
      rol   ebx, 16
      rol   ecx, 16
      rol   bx, 8
      rol   cx, 8
  {$ENDIF}
      mov   [eax+edx*4], ebx
      mov   [eax+edx*4+4], ecx
      jnz   @@02

      pop   ebx
@@FF:
end;

{$IFDEF NX_DEBUG}
procedure RawByteSwap(P: PUInt32Frame; Count: SInt32);
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  RawByteSwapDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// Compare P[] and Q[] (on Count 32-bit words)
// Return
//   -1 if P[] < Q[]
//    0 if P[] = Q[]
//    1 if P[] > Q[]
//==============================================================================
{$IFDEF NX_DEBUG}
function RawCmpDebug(P,Q: PUInt32Frame; Count: SInt32): SInt32;
{$ELSE}
function RawCmp(P,Q: PUInt32Frame; Count: SInt32): SInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      //
      // Checking whether Count=0 would be a waste of time on average,
      // the code works in all cases and proba(Count=0) is dim.
      //
      push  esi
      push  edi
      lea   esi, [eax+ecx*4-4] // esi points to P[Count-1]
      lea   edi, [edx+ecx*4-4] // edi points to Q[Count-1]
      std                      // DF := 1 (to decrease esi and edi)
      xor   eax, eax           // eax := 0, CF := 0 and ZF := 1
      repe  cmpsd              // loop while (ecx > 0) and (P[i] = Q[i])
      seta  al                 // eax := Ord(P[i] > Q[i])
      cld                      // reset DF to 0
      sbb   eax, 0             // eax := eax - Ord(P[i] < Q[i])
      pop   edi
      pop   esi
end;

{$IFDEF NX_DEBUG}
function RawCmp(P,Q: PUInt32Frame; Count: SInt32): SInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawCmpDebug(P,Q,Count);
end;
{$ENDIF} // NX_DEBUG

//------------------------------------------------------------------------------
// Unit Constant (used by RawCRC)
// ! DO NOT MODIFY ucGF, it might be used for validity tests
//------------------------------------------------------------------------------
const
  //
  // Table generated using the following primitive polynomial over GF(2):
  // (32,31,28,27,26,24,23,21,20,16,12,9,4,1,0)
  //
  ucGF : array [UInt8] of UInt32 = (
  $00000000, $6c533947, $d8a6728e, $b4f54bc9, $21ddfe6f, $4d8ec728,
  $f97b8ce1, $9528b5a6, $43bbfcde, $2fe8c599, $9b1d8e50, $f74eb717,
  $626602b1, $0e353bf6, $bac0703f, $d6934978, $8777f9bc, $eb24c0fb,
  $5fd18b32, $3382b275, $a6aa07d3, $caf93e94, $7e0c755d, $125f4c1a,
  $c4cc0562, $a89f3c25, $1c6a77ec, $70394eab, $e511fb0d, $8942c24a,
  $3db78983, $51e4b0c4, $9e7ee80b, $f22dd14c, $46d89a85, $2a8ba3c2,
  $bfa31664, $d3f02f23, $670564ea, $0b565dad, $ddc514d5, $b1962d92,
  $0563665b, $69305f1c, $fc18eaba, $904bd3fd, $24be9834, $48eda173,
  $190911b7, $755a28f0, $c1af6339, $adfc5a7e, $38d4efd8, $5487d69f,
  $e0729d56, $8c21a411, $5ab2ed69, $36e1d42e, $82149fe7, $ee47a6a0,
  $7b6f1306, $173c2a41, $a3c96188, $cf9a58cf, $ac6ccb65, $c03ff222,
  $74cab9eb, $189980ac, $8db1350a, $e1e20c4d, $55174784, $39447ec3,
  $efd737bb, $83840efc, $37714535, $5b227c72, $ce0ac9d4, $a259f093,
  $16acbb5a, $7aff821d, $2b1b32d9, $47480b9e, $f3bd4057, $9fee7910,
  $0ac6ccb6, $6695f5f1, $d260be38, $be33877f, $68a0ce07, $04f3f740,
  $b006bc89, $dc5585ce, $497d3068, $252e092f, $91db42e6, $fd887ba1,
  $3212236e, $5e411a29, $eab451e0, $86e768a7, $13cfdd01, $7f9ce446,
  $cb69af8f, $a73a96c8, $71a9dfb0, $1dfae6f7, $a90fad3e, $c55c9479,
  $507421df, $3c271898, $88d25351, $e4816a16, $b565dad2, $d936e395,
  $6dc3a85c, $0190911b, $94b824bd, $f8eb1dfa, $4c1e5633, $204d6f74,
  $f6de260c, $9a8d1f4b, $2e785482, $422b6dc5, $d703d863, $bb50e124,
  $0fa5aaed, $63f693aa, $c8488db9, $a41bb4fe, $10eeff37, $7cbdc670,
  $e99573d6, $85c64a91, $31330158, $5d60381f, $8bf37167, $e7a04820,
  $535503e9, $3f063aae, $aa2e8f08, $c67db64f, $7288fd86, $1edbc4c1,
  $4f3f7405, $236c4d42, $9799068b, $fbca3fcc, $6ee28a6a, $02b1b32d,
  $b644f8e4, $da17c1a3, $0c8488db, $60d7b19c, $d422fa55, $b871c312,
  $2d5976b4, $410a4ff3, $f5ff043a, $99ac3d7d, $563665b2, $3a655cf5,
  $8e90173c, $e2c32e7b, $77eb9bdd, $1bb8a29a, $af4de953, $c31ed014,
  $158d996c, $79dea02b, $cd2bebe2, $a178d2a5, $34506703, $58035e44,
  $ecf6158d, $80a52cca, $d1419c0e, $bd12a549, $09e7ee80, $65b4d7c7,
  $f09c6261, $9ccf5b26, $283a10ef, $446929a8, $92fa60d0, $fea95997,
  $4a5c125e, $260f2b19, $b3279ebf, $df74a7f8, $6b81ec31, $07d2d576,
  $642446dc, $08777f9b, $bc823452, $d0d10d15, $45f9b8b3, $29aa81f4,
  $9d5fca3d, $f10cf37a, $279fba02, $4bcc8345, $ff39c88c, $936af1cb,
  $0642446d, $6a117d2a, $dee436e3, $b2b70fa4, $e353bf60, $8f008627,
  $3bf5cdee, $57a6f4a9, $c28e410f, $aedd7848, $1a283381, $767b0ac6,
  $a0e843be, $ccbb7af9, $784e3130, $141d0877, $8135bdd1, $ed668496,
  $5993cf5f, $35c0f618, $fa5aaed7, $96099790, $22fcdc59, $4eafe51e,
  $db8750b8, $b7d469ff, $03212236, $6f721b71, $b9e15209, $d5b26b4e,
  $61472087, $0d1419c0, $983cac66, $f46f9521, $409adee8, $2cc9e7af,
  $7d2d576b, $117e6e2c, $a58b25e5, $c9d81ca2, $5cf0a904, $30a39043,
  $8456db8a, $e805e2cd, $3e96abb5, $52c592f2, $e630d93b, $8a63e07c,
  $1f4b55da, $73186c9d, $c7ed2754, $abbe1e13);

//==============================================================================
// Result := Checksum of P[] (on Count 32-bit words)
// -> CRC, current CRC or 0 (useful to chain calls to RawCRC)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawCRCDebug(P: PUInt32Frame; Count: SInt32; CRC: UInt32): UInt32;
{$ELSE}
function RawCRC(P: PUInt32Frame; Count: SInt32; CRC: UInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      test  edx, edx
      jz    @@02             // if Count = 0, exit with Result = CRC
      push  ebx
      push  edi
      push  esi
      not   ecx              // CRC := CRC xor $ffffffff
      lea   edi, [eax+edx*4] // [edi] points to P[Count]
      xor   ebx, ebx
      neg   edx              // to increase edx up to 0
      lea   esi, [ucGF]      // [esi] points to ucGF[0]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [edi+edx*4] // eax := P[i]
      mov   bl,  al
      xor   bl,  cl          // k := UInt8(P[i])[0] xor (CRC and $ff)
      shr   ecx, 8           // CRC := CRC shr 8
      xor   ecx, [esi+ebx*4] // CRC := CRC xor ucGF[k]
      mov   bl,  ah
      xor   bl,  cl
      shr   ecx, 8
      shr   eax, 16          // now, use the 2 high bytes of eax
      xor   ecx, [esi+ebx*4]
      mov   bl,  al
      xor   bl,  cl
      shr   ecx, 8
      xor   ecx, [esi+ebx*4]
      mov   bl,  ah
      xor   bl,  cl
      shr   ecx, 8
      xor   ecx, [esi+ebx*4]
      inc   edx
      jnz   @@01

      not   ecx              // CRC := CRC xor $ffffffff
      pop   esi
      pop   edi
      pop   ebx
@@02: mov   eax, ecx
end;

{$IFDEF NX_DEBUG}
function RawCRC(P: PUInt32Frame; Count: SInt32; CRC: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawCRCDebug(P,Count,CRC);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] div D (on Count 32-bit words)
// Return the remainder of the division
//==============================================================================
{$IFDEF NX_DEBUG}
function RawDivUI32Debug(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ELSE}
function RawDivUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      push  edi
      push  esi
      mov   ebx, edx            // ebx := Count
      mov   esi, edx
      lea   edi, [eax+edx*4-4]  // edi points to P[Count-1]
      and   esi, 3
      xor   edx, edx            // init remainder to 0
      shr   ebx, 2
      jz    @@03

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: mov   eax, [edi]
      div   ecx
      mov   [edi], eax
      mov   eax, [edi-4]
      div   ecx
      mov   [edi-4], eax
      mov   eax, [edi-8]
      div   ecx
      mov   [edi-8], eax
      mov   eax, [edi-12]
      div   ecx
      mov   [edi-12], eax
      dec   ebx
      lea   edi, [edi-16]
      jnz   @@02

@@03: jmp   dword ptr @@RX[esi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   eax, [edi]
      div   ecx
      mov   [edi], eax
      sub   edi, 4
@@R2: mov   eax, [edi]
      div   ecx
      mov   [edi], eax
      sub   edi, 4
@@R1: mov   eax, [edi]
      div   ecx
      mov   [edi], eax
@@R0: pop   esi
      pop   edi
      pop   ebx
      mov   eax, edx
end;

{$IFDEF NX_DEBUG}
function RawDivUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(D > 0);

  Result := RawDivUI32Debug(P,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawDivd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawDivUI32(P,Count,D);
end;

//==============================================================================
// P[] := P[] div D (on Count 32-bit words)
// !!! It is assumed that P[] is divisible by D
// Based on a GMP routine
//==============================================================================
{$IFDEF NX_DEBUG}
procedure RawDivUI32ExactDebug(P: PUInt32Frame; Count: SInt32; D,I: UInt32);
{$ELSE}
procedure RawDivUI32Exact(P: PUInt32Frame; Count: SInt32; D,I: UInt32);
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI : UInt32;
asm
      mov   SESI, esi
      mov   SEDI, edi
      mov   SEBX, ebx
      push  ebp
      mov   edi, I
      mov   esi, eax            // esi := P
      mov   ebp, ecx            // ebp := D
      lea   esi, [esi+edx*4-4]
      mov   ecx, edx            // ecx := Size
      xor   ebx, ebx
      neg   ecx
      xor   edx, edx
      mov   eax, [esi+ecx*4+4]  // eax := P[0]
      inc   ecx
      jz    @@03
      jmp   @@02

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [esi+ecx*4]
      sub   edx, ebx
      sub   eax, edx
      sbb   ebx, ebx
@@02: imul  eax, edi
      mov   [esi+ecx*4], eax
      mul   ebp
      inc   ecx
      jnz   @@01

      mov   eax, [esi]
@@03: add   eax, ebx
      sub   eax, edx
      pop   ebp
      imul  eax, edi
      mov   ebx, SEBX
      mov   [esi], eax
      mov   edi, SEDI
      mov   esi, SESI
end;

{$IFDEF NX_DEBUG}
procedure RawDivUI32Exact(P: PUInt32Frame; Count: SInt32; D,I: UInt32);
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(Count > 0);
  ASSERT((D and 1) <> 0);
  ASSERT((D*I) = 1);

  RawDivUI32ExactDebug(P,Count,D,I);
end;
{$ENDIF}

//-- deprecated
procedure RawDivde(P: PUInt32Frame; Count: SInt32; D,I: UInt32);
begin
  RawDivUI32Exact(P,Count,D,I);
end;

//==============================================================================
// Result := P[] mod 3 (on Count 32-bit words)
// P[] is not modified
// Since 2**32 = 1 mod 3, X mod 3 is equal to the sum of its digits (mod 3)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawMod3Debug(P: PUInt32Frame; Count: SInt32): UInt32;
{$ELSE}
function RawMod3(P: PUInt32Frame; Count: SInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      test  edx, edx          // Count = 0?
      jz    @@02
      lea   ecx, [eax-4]      // ecx points to P[-1]
      xor   eax, eax          // eax := 0 and CF := 0

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: adc   eax, [ecx+edx*4]  // eax := eax + P[i] + carry
      dec   edx               // i := i-1 (do not modify CF)
      jnz   @@01

      mov   ecx, 3            // set divisor (do not modify CF)
      adc   eax, edx          // add last carry, here edx = 0
      div   ecx               // edx := [0:eax] mod 3
@@02: mov   eax, edx          // Result := edx
end;

{$IFDEF NX_DEBUG}
function RawMod3(P: PUInt32Frame; Count: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawMod3Debug(P,Count);
end;
{$ENDIF}

//==============================================================================
// Result := P[] mod D (on Count 32-bit words)
// P[] is not modified
//------------------------------------------------------------------------------
// Based on a GMP routine
//==============================================================================
{$IFDEF NX_DEBUG}
function RawModUI32Debug(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ELSE}
function RawModUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register;
  const THRESHOLD = 4;
  var SEBX, SEDI, SESI, P2, D2, E, I : UInt32;
asm
      mov   SEBX, ebx
      mov   SEDI, edi

      cmp   edx, THRESHOLD
      jae   @@00

      //-- use standard div if Count < 4
      and   edx, edx  // Count = 0?
      jz    @@S1

      mov   ebx, ecx  // ebx = Divisor
      mov   edi, eax  // edi = @P
      mov   ecx, edx  // ecx = Count
      xor   edx, edx

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@S0: mov   eax, [edi+ecx*4-4]
      div   ebx
      dec   ecx
      jnz   @@S0

@@S1: mov   eax, edx
      jmp   @@09

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@00: mov   SESI, esi
      mov   P2, eax            // Save P
      mov   D2, ecx            // Save D
      mov   esi, [eax+edx*4-4] // esi := most significant digit of P^
      mov   edi, ecx           // edi = D
      and   ecx, ecx
      js    @@01
      bsr   eax, ecx           // ok, D > 0
      mov   ecx, 31
      sub   ecx, eax
      //-- E = D shl (32 - BitSize(D))
      shl   edi, cl
@@01: mov   E, edi
      //-- save Size
      mov   ecx, edx // ecx = Size
      //-- I := $-1 or [-x:0] div x
      cmp   edi, $80000000
      jne   @@02
      mov   eax, $ffffffff
      jmp   @@03
@@02: mov   edx, edi
      neg   edx
      xor   eax, eax
      div   edi
@@03: mov   I, eax
      sub   esi, edi
      mov   edi, edx
      dec   ecx
      jz    @@06

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@04: sbb   edi, edx
      and   edi, E

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@05: mov   eax, P2
      add   edi, esi
      mov   ebx, [eax+ecx*4-4]
      mov   esi, ebx
      mov   eax, edi
      sar   ebx, 31
      mov   edx, I
      sub   eax, ebx
      mul   edx
      and   ebx, E
      add   ebx, esi
      add   eax, ebx
      lea   ebx, [edi+1]
      adc   edx, ebx
      jz    @@07

      mov   eax, E
      mul   edx
      sub   esi, eax
      dec   ecx
      jnz   @@04

@@06: sbb   edi, edx
      and   edi, E
      jmp   @@08

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@07: mov   edi, E
      dec   ecx
      jnz   @@05

@@08: lea   eax, [esi+edi]
      xor   edx, edx
      mov   ecx, D2
      div   ecx
      mov   eax, edx
      mov   esi, SESI

@@09: mov   edi, SEDI
      mov   ebx, SEBX
end;

{$IFDEF NX_DEBUG}
function RawModUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(D > 0);

  Result := RawModUI32Debug(P,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawModd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawModUI32(P,Count,D);
end;

//==============================================================================
// P[] = Q[] * D - Result * 2**(32*k) always holds (so if Result = 0, P[] is
// congruent to 0 modulo D)
//------------------------------------------------------------------------------
// Based on a GMP routine
//==============================================================================
{$IFDEF NX_DEBUG}
function RawModUI32IDebug(P: PUInt32Frame; Count: SInt32; D,I: UInt32): UInt32;
{$ELSE}
function RawModUI32I(P: PUInt32Frame; Count: SInt32; D,I: UInt32): UInt32;
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI : UInt32;
asm
      mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi
      push  ebp
      lea   ebx, [eax+edx*4] // ebx points to P[Count]
      mov   edi, I
      mov   esi, ecx         // esi := D
      mov   ebp, edx         // ebp := Count
      xor   ecx, ecx
      neg   ebp              // to increase ebp up to 0
      xor   edx, edx

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [ebx+ebp*4]
      sub   eax, ecx
      sbb   ecx, ecx
      sub   eax, edx
      sbb   ecx, 0
      imul  eax, edi
      neg   ecx
      mul   esi
      inc   ebp
      jnz   @@01

      pop   ebp
      lea   eax, [ecx+edx*1]
      mov   esi, SESI
      mov   edi, SEDI
      mov   ebx, SEBX
end;

{$IFDEF NX_DEBUG}
function RawModUI32I(P: PUInt32Frame; Count: SInt32; D,I: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(Count > 0);
  ASSERT((D and 1) <> 0);
  ASSERT((D*I) = 1);

  Result := RawModUI32IDebug(P,Count,D,I);
end;
{$ENDIF}

//-- deprecated
function RawModdi(P: PUInt32Frame; Count: SInt32; D,I: UInt32): UInt32;
begin
  Result := RawModUI32I(P,Count,D,I);
end;

//==============================================================================
// P[] := P[] * D (on Count 32-bit words)
// Result := last carry
//==============================================================================
{$IFDEF NX_DEBUG}
function RawMulUI32Debug(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ELSE}
function RawMulUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      cmp   ecx, 2
      je    @@10         // jmp if D = 2
      jb    @@20         // jmp if D < 2 (thus D = 1)
      push  ebx
      push  edi
      push  esi
      mov   edi, ecx     // edi := D
      mov   esi, eax     // esi := P
      xor   ebx, ebx
      mov   eax, edx
      mov   ecx, edx
      and   eax, 3
      shr   ecx, 2
      jz    @@02
      push  eax

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [esi]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      mov   eax, [esi+4]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi+4], eax
      mov   ebx, edx
      mov   eax, [esi+8]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi+8], eax
      mov   ebx, edx
      mov   eax, [esi+12]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi+12], eax
      mov   ebx, edx
      dec   ecx
      lea   esi, [esi+16]
      jnz   @@01

      pop   eax
@@02: jmp   dword ptr @@RX[eax*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   eax, [esi]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      add   esi, 4
@@R2: mov   eax, [esi]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      add   esi, 4
@@R1: mov   eax, [esi]
      mul   edi
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
@@R0: pop   esi
      mov   eax, ebx
      pop   edi
      pop   ebx
      ret

@@10: mov   ecx, edx
      mov   edx, eax
      call  RawAdd       // D = 2, Result := RawAdd(P,P,Count)
      ret

@@20: xor   eax, eax     // D = 1, Result := 0
end;

{$IFDEF NX_DEBUG}
function RawMulUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(D > 0);

  Result := RawMulUI32Debug(P,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawMuld(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawMulUI32(P,Count,D);
end;

//==============================================================================
// P[] := Q[] * D (on Count 32-bit words)
// Result := last carry
//==============================================================================
{$IFDEF NX_DEBUG}
function RawMulUI32ToDebug(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ELSE}
function RawMulUI32To(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI : UInt32;
asm
      cmp   D, 2
      je    @@10          // jmp if D = 2
      mov   SEDI, edi
      mov   SESI, esi
      jb    @@20          // jmp if D < 2
      mov   SEBX, ebx
      mov   esi, eax      // esi := P
      push  ebp
      mov   edi, edx      // edi := Q
      push  ecx           // save Count
      mov   ebp, D
      xor   ebx, ebx
      shr   ecx, 2
      jz    @@02

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      mov   eax, [edi+4]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi+4], eax
      mov   ebx, edx
      mov   eax, [edi+8]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi+8], eax
      mov   ebx, edx
      mov   eax, [edi+12]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi+12], eax
      mov   ebx, edx
      add   edi, 16
      dec   ecx
      lea   esi, [esi+16]
      jnz   @@01

@@02: pop   ecx
      and   ecx, 3
      jmp   dword ptr @@RX[ecx*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      add   edi, 4
      add   esi, 4
@@R2: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
      add   edi, 4
      add   esi, 4
@@R1: mov   eax, [edi]
      mul   ebp
      add   eax, ebx
      adc   edx, 0
      mov   [esi], eax
      mov   ebx, edx
@@R0: pop   ebp
      mov   eax, ebx
      mov   ebx, SEBX
      jmp   @@40

      //-- D = 2
@@10: push  ecx           // push Count
      mov   ecx, edx
      call  RawAddTo      // RawAddTo(P,Q,Q,Count)
      jmp   @@FF

      //-- D = 0 or 1
@@20: cld
      cmp   D, 0
      mov   edi, eax      // edi := P
      je    @@30          // jmp if D = 0

      //-- D = 1
      mov   esi, edx      // esi := Q
      rep   movsd         // P[] := Q[]
      xor   eax, eax      // Result := 0
      jmp   @@40

      //-- D = 0
@@30: xor   eax, eax      // eax := 0
      rep   stosd         // fill P[] with 0s

@@40: mov   esi, SESI
      mov   edi, SEDI
@@FF:
end;

{$IFDEF NX_DEBUG}
function RawMulUI32To(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawMulUI32ToDebug(P,Q,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawMuldTo(P,Q: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawMulUI32To(P,Q,Count,D);
end;

//------------------------------------------------------------------------------
// Toom-3 Evaluate
//   H := 4A + 2B +  C
//   M :=  A +  B +  C
//   L :=  A + 2B + 4C
// where
//   H, M, L, A and B have length MaxCount
//   C has length MinCount such that MaxCount-MinCount = 0, 1 or 2
// Return carries in hc, mc and lc respectively.
//------------------------------------------------------------------------------
procedure RawEvalTm3(    H,M,L,A,B,C       : PUInt32Frame;
                         MinCount,MaxCount : SInt32;
                     out hc,mc,lc          : UInt32);
assembler; register;
  var a0, b0, c0, hcarry, mcarry, lcarry : UInt32;
asm
      push  ebx
      push  esi
      push  edi

      mov   ebx, MinCount
      mov   esi, eax      // esi := H
      mov   edi, edx      // edi := M
      mov   hcarry, 0
      mov   mcarry, 0
      mov   lcarry, 0
      test  ebx, ebx
      jle   @@02          // jmp if MinCount = 0 (never occurs)

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, A
      mov   edx, B
      mov   eax, [eax]
      mov   edx, [edx]
      mov   a0, eax       // a0 := A^[0]
      mov   b0, edx       // b0 := B^[0]
      mov   eax, C
      add   A, 4
      mov   edx, [eax]
      add   B, 4
      mov   c0, edx       // c0 := C^[0]
      add   C, 4
      //-- h := 4a + 2b + c + hcarry
      mov   eax, a0
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, b0
      adc   edx, 0
      add   eax, eax
      adc   edx, edx
      add   eax, c0
      adc   edx, 0
      add   eax, hcarry
      adc   edx, 0
      mov   [esi], eax    // H^[0]
      mov   hcarry, edx
      //-- m := a + b + c + mcarry
      mov   eax, a0
      xor   edx, edx
      add   eax, b0
      adc   edx, edx
      add   eax, c0
      adc   edx, 0
      add   eax, mcarry
      adc   edx, 0
      mov   [edi], eax    // M^[0]
      mov   mcarry, edx
      //-- l := a + 2b + 4c + lcarry
      mov   eax, c0
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, b0
      adc   edx, 0
      add   eax, eax
      adc   edx, edx
      add   eax, a0
      adc   edx, 0
      add   eax, lcarry
      adc   edx, 0
      mov   [ecx], eax    // L^[0]
      mov   lcarry, edx
      lea   esi, [esi+4]
      lea   edi, [edi+4]
      dec   ebx
      lea   ecx, [ecx+4]
      jnz   @@01          // loop while ebx > 0

@@02: mov   ebx, MaxCount
      sub   ebx, MinCount
      cmp   ebx, 1        // ebx = 0, 1 or 2
      je    @@03          // jmp if ebx = 1
      jl    @@04          // jmp if ebx = 0

      mov   eax, A
      mov   edx, B
      mov   eax, [eax]
      mov   edx, [edx]
      mov   a0, eax       // a0 := A^[0]
      mov   b0, edx       // b0 := B^[0]
      add   A, 4
      add   B, 4
      //-- h := 4a + 2b + hcarry
      mov   eax, a0
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, b0
      adc   edx, 0
      add   eax, eax
      adc   edx, edx
      add   eax, hcarry
      adc   edx, 0
      mov   [esi], eax
      mov   hcarry, edx
      //-- m := a + b + mcarry
      mov   eax, a0
      xor   edx, edx
      add   eax, b0
      adc   edx, edx
      add   eax, mcarry
      adc   edx, 0
      mov   [edi], eax
      mov   mcarry, edx
      //-- l := a + 2b + lcarry
      mov   eax, b0
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, a0
      adc   edx, 0
      add   eax, lcarry
      adc   edx, 0
      mov   [ecx], eax
      mov   lcarry, edx
      add   esi, 4
      add   edi, 4
      add   ecx, 4

@@03: mov   eax, A
      mov   edx, B
      mov   eax, [eax]
      mov   edx, [edx]
      mov   a0, eax
      mov   b0, edx
      //-- h := 4a + 2b + hcarry
      mov   eax, a0
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, b0
      adc   edx, 0
      add   eax, eax
      adc   edx, edx
      add   eax, hcarry
      adc   edx, 0
      mov   [esi], eax
      mov   hcarry, edx
      //-- m := a + b + mcarry
      mov   eax, a0
      xor   edx, edx
      add   eax, b0
      adc   edx, edx
      add   eax, mcarry
      adc   edx, 0
      mov   [edi], eax
      mov   mcarry, edx
      //-- l := a + 2b + lcarry
      mov   eax, b0
      xor   edx, edx
      add   eax, eax
      adc   edx, edx
      add   eax, a0
      adc   edx, 0
      add   eax, lcarry
      adc   edx, 0
      mov   [ecx], eax
      mov   lcarry, edx

@@04: mov   edi, hc
      mov   esi, mc
      mov   ebx, lc
      mov   eax, hcarry
      mov   edx, mcarry
      mov   ecx, lcarry
      //-- set carries
      mov   [edi], eax
      mov   [esi], edx
      mov   [ebx], ecx

      pop   edi
      pop   esi
      pop   ebx
end;

//------------------------------------------------------------------------------
// Toom-3 Interpolate
// A^, B^, C^ and D^ all have length n
// E^ has length MinCount with MaxCount-MinCount = 0, 2 or 4
// Take previous overflows from b3, c3 and d3, and return new ones there
// Adapted from a GMP routine
//------------------------------------------------------------------------------
procedure RawInterpolTm3(    A,B,C,D,E         : PUInt32Frame;
                             MinCount,MaxCount : SInt32;
                         var b3,c3,d3          : UInt32);
  type
    TCD = array [0..1] of UInt32; // to access PUInt32Frame(Pointer)^[1]
    PCD = ^TCD;
  var
    qa, qb, qc, qd, qe, qt                : UInt64;
    t, b0, c0, d0, sb, sc, sd, ob, oc, od : UInt32;
    i                                     : SInt32;
begin
  sb := 0;
  sc := 0;
  sd := 0;

  // Let x, y, z be the values to interpolate, we have
  // b = 16 a + 8 x + 4 y + 2 z +    e
  // c =    a +   x +   y +   z +    e
  // d =    a + 2 x + 4 y + 8 z + 16 e

  qa := A^[0];
  qb := B^[0];
  qc := C^[0];
  qd := D^[0];
  qe := E^[0];
  //-- b := b - 16 a - e = 8 x + 4 y + 2 z
  qb := qb - (qa shl 4) - qe;
  //-- c := c - a - e  = x + y + z
  qc := qc - qa - qe;
  //-- d := d - a - 16 e = 2 x + 4 y + 8 z
  qd := qd - qa - (qe shl 4);
  //-- (b,d) := (b+d, b-d)
  qt := qd;
  qd := qb - qt;
  qb := qb + qt;
  //-- b := b - 8 c
  qb := qb - (qc shl 3);
  //-- c := 2 c - b
  qc := qc + qc - qb;

  //-- d := d/3
  asm
      //
      // qd.Lo := qd.Lo * (1/3 mod 2**32)
      // qd.Hi := (qd.Hi - ((qd.Lo * 3) div 2**32)) * (1/3 mod 2**32)
      //
      mov   eax, dword ptr qd[0]
      imul  eax, $aaaaaaab
      mov   dword ptr qd[0], eax
      mov   ecx, eax
      mov   edx, dword ptr qd[4]
      add   eax, eax              // d0+d0 -> CF
      sbb   edx, 0
      add   eax, ecx              // d0+d0+d0 -> CF
      sbb   edx, 0
      imul  edx, $aaaaaaab
      mov   dword ptr qd[4], edx
  end {$IFDEF FREE_PASCAL} ['EAX','ECX','EDX'] {$ENDIF};

  //-- (b,d) := (b+d,b-d)
  qt := qd;
  qd := qb - qt;
  qb := qb + qt;
  //-- b = 4*x, sb has period 2
  qb := qb + sb;
  sb := ((sb and $ffff0000) or (sb shr 16)) + UInt32x2(qb).Hi;
  //-- c = 2*y, sc has period 1
  qc := qc + sc;

  //-- the casts compel FPC 2.2.0 and higher to produce efficient code
  sc := UInt32(SInt32x2(qc).Hi - SInt32(sc shr 31));

  //-- d = 4*z, sd has period 2
  qd := qd + sd;
  sd := ((sd and $ffff0000) or (sd shr 16)) + UInt32x2(qd).Hi;

  ob := UInt32x2(qb).Lo shr 2;
  oc := UInt32x2(qc).Lo shr 1;
  od := UInt32x2(qd).Lo shr 2;

  for i := 1 to MinCount-1 do
  begin
    qa := PCD(A)^[1];
    qb := PCD(B)^[1];
    qc := PCD(C)^[1];
    qd := PCD(D)^[1];
    qe := PCD(E)^[1];

    //-- b := b - 16 a - e = 8 x + 4 y + 2 z
    qb := qb - (qa shl 4) - qe;
    //-- c := c - a - e  = x + y + z
    qc := qc - qa - qe;
    //-- d := d - a - 16 e = 2 x + 4 y + 8 z
    qd := qd - qa - (qe shl 4);
    //-- (b,d) := (b+d, b-d)
    qt := qd;
    qd := qb - qt;
    qb := qb + qt;
    //-- b := b - 8 c
    qb := qb - (qc shl 3);
    //-- c := 2 c - b
    qc := qc + qc - qb;

    //-- d := d/3
    asm
        mov   eax, dword ptr qd[0]
        imul  eax, $aaaaaaab
        mov   dword ptr qd[0], eax
        mov   ecx, eax
        mov   edx, dword ptr qd[4]
        add   eax, eax
        sbb   edx, 0
        add   eax, ecx
        sbb   edx, 0
        imul  edx, $aaaaaaab
        mov   dword ptr qd[4], edx
    end {$IFDEF FREE_PASCAL} ['EAX','ECX','EDX'] {$ENDIF};

    //-- (b,d) := (b+d,b-d)
    qt := qd;
    qd := qb - qt;
    qb := qb + qt;
    //-- b = 4*x, sb has period 2
    qb := qb + sb;
    sb := ((sb and $ffff0000) or (sb shr 16)) + UInt32x2(qb).Hi;
    //-- c = 2*y, sc has period 1
    qc := qc + sc;

    //-- the casts compel FPC 2.2.0 and higher to produce efficient code
    sc := UInt32(SInt32x2(qc).Hi - SInt32(sc shr 31));

    //-- d = 4*z, sd has period 2
    qd := qd + sd;
    sd := ((sd and $ffff0000) or (sd shr 16)) + UInt32x2(qd).Hi;

    B^[0] := ob or (UInt32x2(qb).Lo shl 30);
    C^[0] := oc or (UInt32x2(qc).Lo shl 31);
    D^[0] := od or (UInt32x2(qd).Lo shl 30);
    Inc(A);
    Inc(B);
    Inc(C);
    Inc(D);
    Inc(E);
    ob := UInt32x2(qb).Lo shr 2;
    oc := UInt32x2(qc).Lo shr 1;
    od := UInt32x2(qd).Lo shr 2;
  end;

  for i := MinCount to MaxCount-1 do
  begin
    qa := PCD(A)^[1];
    qb := PCD(B)^[1];
    qc := PCD(C)^[1];
    qd := PCD(D)^[1];

    //-- b := b - 16 a = 8 x + 4 y + 2 z
    qb := qb - (qa shl 4);
    //-- c := c - a = x + y + z
    qc := qc - qa;
    //-- d := d - a = 2 x + 4 y + 8 z
    qd := qd - qa;
    //-- (b,d) := (b+d,b-d)
    qt := qd;
    qd := qb - qt;
    qb := qb + qt;
    //-- b := b - 8 c
    qb := qb - (qc shl 3);
    //-- c := 2 c - b
    qc := qc + qc - qb;

    //-- d := d/3
    asm
        mov   eax, dword ptr qd[0]
        imul  eax, $aaaaaaab
        mov   dword ptr qd[0], eax
        mov   ecx, eax
        mov   edx, dword ptr qd[4]
        add   eax, eax
        sbb   edx, 0
        add   eax, ecx
        sbb   edx, 0
        imul  edx, $aaaaaaab
        mov   dword ptr qd[4], edx
    end {$IFDEF FREE_PASCAL} ['EAX','ECX','EDX'] {$ENDIF};

    //-- (b,d) := (b+d, b-d)
    qt := qd;
    qd := qb - qt;
    qb := qb + qt;
    //-- b = 4*x, sb has period 2
    qb := qb + sb;
    sb := ((sb and $ffff0000) or (sb shr 16)) + UInt32x2(qb).Hi;
    //-- c = 2*y, sc has period 1
    qc := qc + sc;

    //-- the casts compel FPC 2.2.0 and higher to produce efficient code
    sc := UInt32(SInt32x2(qc).Hi - SInt32(sc shr 31));

    //-- d = 4*z, sd has period 2
    qd := qd + sd;
    sd := ((sd and $ffff0000) or (sd shr 16)) + UInt32x2(qd).Hi;

    B^[0] := ob or (UInt32x2(qb).Lo shl 30);
    C^[0] := oc or (UInt32x2(qc).Lo shl 31);
    D^[0] := od or (UInt32x2(qd).Lo shl 30);
    Inc(A);
    Inc(B);
    Inc(C);
    Inc(D);
    ob := UInt32x2(qb).Lo shr 2;
    oc := UInt32x2(qc).Lo shr 1;
    od := UInt32x2(qd).Lo shr 2;
  end;

  //-- handle most significant values
  b0 := b3;
  d0 := d3;
  c0 := c3;
  t  := b0 + d0;

  //-- the casts compel FPC 2.2.0 and higher to produce efficient code
  d0 := UInt32(SInt32(b0) - SInt32(d0));      // d0 := b0 - d0
  b0 := UInt32(SInt32(t) - SInt32(c0 shl 3)); // b0 := t  - (c0 shl 3)

  Inc(c0,c0);
  Dec(c0,b0);
  d0 := d0 * UInt32($aaaaaaab);
  t  := b0 + d0;

  //-- the casts compel FPC 2.2.0 and higher to produce efficient code
  d0 := UInt32(SInt32(b0) - SInt32(d0)); // d0 := b0 - d0

  b0 := t;
  Inc(c0,sc);
  Inc(b0,sb);
  Inc(d0,sd);
  B^[0] := ob or (b0 shl 30);
  C^[0] := oc or (c0 shl 31);
  D^[0] := od or (d0 shl 30);
  b3 := b0 shr 2;
  c3 := c0 shr 1;
  d3 := d0 shr 2;
end;

//------------------------------------------------------------------------------
// Multiplication
// P[0..2] := Q[0..1] * R[0]
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
procedure RawMul21ToDebug(P,Q,R: PUInt32Frame);
{$ELSE}
procedure RawMul21To(P,Q,R: PUInt32Frame);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      push  edi
      push  esi
      mov   ebx, eax      // P
      mov   edi, edx      // Q
      mov   esi, [ecx]    // R[0]
      mov   eax, [edi]
      mul   esi           // Q0 * R0
      mov   [ebx], eax    // P0
      mov   ecx, edx
      mov   eax, [edi+4]
      mul   esi           // Q1 * R0
      add   eax, ecx
      adc   edx, 0
      mov   [ebx+4], eax  // P1
      mov   [ebx+8], edx  // P2
      pop   esi
      pop   edi
      pop   ebx
end;

{$IFDEF NX_DEBUG}
procedure RawMul21To(P,Q,R: PUInt32Frame);
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT(P <> R);

  RawMul21ToDebug(P,Q,R);
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Multiplication
// P[0..3] := Q[0..1] * R[0..1]
//------------------------------------------------------------------------------
{$IFDEF NX_LOCATE_TODO_NOTES}
  {$MESSAGE 'Do not forget me'}
{$ENDIF}
  //
  // * Check whether a Karatsuba scheme (3 "mul" instead of 4) is better
  //
{$IFDEF NX_DEBUG}
procedure RawMul22ToDebug(P,Q,R: PUInt32Frame);
{$ELSE}
procedure RawMul22To(P,Q,R: PUInt32Frame);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      push  edi
      push  esi
      mov   ebx, eax      // P
      mov   edi, edx      // Q
      mov   esi, ecx      // R
      mov   edx, [esi]
      mov   eax, [edi]
      xor   ecx, ecx      // 0
      mul   edx           // Q0 * R0
      mov   [ebx], eax    // P0
      mov   [ebx+4], edx  // P1
      mov   edx, [esi]
      mov   eax, [edi+4]
      mul   edx           // Q1 * R0
      add   eax, [ebx+4]  // P1
      adc   ecx, edx      // cannot generate a carry
      mov   [ebx+4], eax  // P1
      mov   [ebx+8], ecx  // P2
      mov   eax, [edi]
      mov   edx, [esi+4]
      xor   ecx, ecx
      mul   edx           // Q0 * R1
      add   eax, [ebx+4]  // P1
      adc   edx, [ebx+8]  // P2
      mov   [ebx+4], eax  // P1
      mov   [ebx+8], edx  // P2
      adc   ecx, ecx
      mov   edx, [esi+4]
      mov   eax, [edi+4]
      mul   edx           // Q1 * R1
      add   eax, [ebx+8]  // P2
      adc   ecx, edx
      mov   [ebx+8], eax  // P2
      mov   [ebx+12], ecx // P3
      pop   esi
      pop   edi
      pop   ebx
end;

{$IFDEF NX_DEBUG}
procedure RawMul22To(P,Q,R: PUInt32Frame);
begin
  //-- require
  ASSERT(Pointer(P) <>Pointer( Q));
  ASSERT(Pointer(P) <> Pointer(R));

  RawMul22ToDebug(P,Q,R);
end;
{$ENDIF}

//==============================================================================
// P[] := Q[] * R[]
// ! Size(P[]) must have been set to QCount + RCount
//==============================================================================
procedure RawMulStdTo(P,Q,R: PUInt32Frame; QCount,RCount: SInt32);
  var S : PUInt32Frame;
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT(P <> R);
  ASSERT(Q <> R);
  ASSERT(((QCount+RCount) and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(QCount >= RCount);
  ASSERT(RCount > 0);

  if QCount > 2 then
  begin
    S := P;
    Inc(S,QCount);
    S^[0] := RawMulUI32To(P,Q,QCount,R^[0]); // P := Q * R[0]
    Dec(RCount);
    while RCount > 0 do
    begin
      Inc(P);
      Inc(R);
      Inc(S);
      S^[0] := RawAddMulUI32(P,Q,QCount,R^[0]); // P := P + Q * R[i]
      Dec(RCount);
    end;
  end
  else
  if QCount = 2 then
    if RCount = 2 then
      RawMul22To(P,Q,R)
    else
      RawMul21To(P,Q,R) // RCount = 1
  else // QCount = 1
  PUInt64Frame(P)^[0] := UInt64(Q^[0]) * R^[0];
end;

//------------------------------------------------------------------------------
// Karatsuba multiplication
// P[] := Q[] * R[]
// The size of P[] must be >= 2*Count, the sizes of Q[] and R[] must be >= Count
// W[] is a buffer of which the size must be >= (Count+32)*2
// Adapted from a GMP routine
//------------------------------------------------------------------------------
procedure RawMulKarTo(P,Q,R,W: PUInt32Frame; Count: SInt32);
  var
    Pk, Qk, Rk, T : PUInt32Frame;
    sign, x       : UInt32;
    c1, m, n      : SInt32;
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT(P <> R);
  ASSERT(Q <> R);
  ASSERT(Count >= gcKarMulThreshold);

  sign := 0;
  m := Count shr 1;
  if (Count and 1) = 0 then
  begin
    Pk := @P^[m];
    Qk := @Q^[m];
    Rk := @R^[m];

    if RawCmp(Q,Qk,m) >= 0 then RawSubTo(P,Q,Qk,m)
    else
    begin
      RawSubTo(P,Qk,Q,m);
      sign := 1;
    end;

    if RawCmp(R,Rk,m) >= 0 then RawSubTo(Pk,R,Rk,m)
    else
    begin
      RawSubTo(Pk,Rk,R,m);
      sign := sign xor 1;
    end;

    if m < gcKarMulThreshold then
    begin
      RawMulStdTo(W,P,Pk,m,m);
      RawMulStdTo(P,Q,R,m,m);
      RawMulStdTo(@P^[Count],Qk,Rk,m,m);
    end
    else
    begin
      T := @W^[Count];
      RawMulKarTo(W,P,Pk,T,m);
      RawMulKarTo(P,Q,R,T,m);
      RawMulKarTo(@P^[Count],Qk,Rk,T,m);
    end;

    if sign > 0 then x := RawAdd(W,P,Count) else x := RawSubr(W,P,Count);
    Inc(x,RawAdd(W,@P^[Count],Count));
    Inc(x,RawAdd(Pk,W,Count));
    if x > 0 then RawAddUI32(@Pk^[Count],m,x);
  end
  else // Count is odd
  begin
    n := m + 1; // m + n = Count
    Pk := @P^[n];
    Qk := @Q^[n];
    Rk := @R^[n];

    x := Q^[m];
    if x > 0 then Inc(x,RawSubTo(P,Q,Qk,m))
    else
    if RawCmp(Q,Qk,m) >= 0 then RawSubTo(P,Q,Qk,m)
    else
    begin
      RawSubTo(P,Qk,Q,m);
      sign := 1;
    end;
    P^[m] := x;

    x := R^[m];
    if x > 0 then Inc(x,RawSubTo(Pk,R,Rk,m))
    else
    if RawCmp(R,Rk,m) >= 0 then RawSubTo(Pk,R,Rk,m)
    else
    begin
      RawSubTo(Pk,Rk,R,m);
      sign := sign xor 1;
    end;
    P^[Count] := x;

    c1 := Count + 1;
    if m < gcKarMulThreshold then
    begin
      if n < gcKarMulThreshold then
      begin
        RawMulStdTo(W,P,Pk,n,n);
        RawMulStdTo(P,Q,R,n,n);
      end
      else
      begin
        T := @W^[c1];
        RawMulKarTo(W,P,Pk,T,n);
        RawMulKarTo(P,Q,R,T,n);
      end;
      RawMulStdTo(@P^[c1],Qk,Rk,m,m);
    end
    else
    begin
      T := @W^[c1];
      RawMulKarTo(W,P,Pk,T,n);
      RawMulKarTo(P,Q,R,T,n);
      RawMulKarTo(@P^[c1],Qk,Rk,T,m);
    end;
    if sign > 0 then RawAdd(W,P,c1) else RawSubr(W,P,c1);

    if RawAdd(W,@P^[c1],Count-1) > 0 then
    begin
      T := @W^[Count-1];
      Inc(T^[0]);
      if T^[0] = 0 then
      begin
        Inc(T);
        Inc(T^[0]);
      end;
    end;

    if RawAdd(Pk,W,c1) > 0 then
    begin
      T := @Pk^[Count];
      repeat
        Inc(T);
        Inc(T^[0]);
      until T^[0] > 0;
    end;
  end;
end;

//------------------------------------------------------------------------------
// Toom-3 multiplication
// P0[0..2*Count-1] := Q0[0..Count-1] * R0[0..Count-1]
// W is workspace
// Adapted from a GMP routine
//------------------------------------------------------------------------------
procedure RawMulTm3To(P0,Q0,R0,W0: PUInt32Frame; Count: SInt32);
  var
    P1, P2, P3, P4, Q2, R2, W1, W2, W3, W4 : PUInt32Frame;
    c2, c3, c4, d2, d3, d4, t2, t3, t4     : UInt32;
    k, s1, s2, sx                          : SInt32;
begin
  //-- require
  ASSERT(P0 <> Q0);
  ASSERT(P0 <> R0);
  ASSERT(Q0 <> R0);
  ASSERT(P0 <> W0);
  ASSERT(Q0 <> W0);
  ASSERT(R0 <> W0);
  ASSERT(Count >= gcTm3MulThreshold);

  // break Count into 3 parts: s1, s1 and sx
  //   Count = 3*k   -> s1 = k,   sx = k
  //   Count = 3*k+1 -> s1 = k+1, sx = k-1
  //   Count = 3*k+2 -> s1 = k+1, sx = k

  k := Count div 3;
  case UInt32(Count - (k+k+k)) of
    0: begin
         s1 := k;
         sx := k;
       end;
    1: begin
         s1 := k + 1;
         sx := k - 1;
       end;
    else
    s1 := k + 1;
    sx := k;
  end;
  s2 := s1 + s1;

  //-- set pointers

  P1 := @P0^[s1];
  P2 := @P1^[s1];
  P3 := @P2^[s1];
  P4 := @P3^[s1];
  Q2 := @Q0^[s2];
  R2 := @R0^[s2];
  W1 := @W0^[s1];
  W2 := @W1^[s1];
  W3 := @W2^[s1];
  W4 := @W3^[s1];

  //-- first stage (evaluation at points 0, 1/2, 1, 2, oo)

  RawEvalTm3(P0,W0,P2,Q0,@Q0^[s1],Q2,sx,s1,c2,c3,c4);
  RawEvalTm3(P1,W1,P3,R0,@R0^[s1],R2,sx,s1,d2,d3,d4);

  //-- second stage

  if s1 < gcKarMulThreshold then
    RawMulStdTo(W2,P2,P3,s1,s1)
  else
  if s1 < gcTm3MulThreshold then
    RawMulKarTo(W2,P2,P3,W4,s1)
  else
    RawMulTm3To(W2,P2,P3,W4,s1);

  t4 := c4 * d4;
  if c4 > 0 then Inc(t4,RawAddMulUI32(W3,P3,s1,c4));
  if d4 > 0 then Inc(t4,RawAddMulUI32(W3,P2,s1,d4));

  if s1 < gcKarMulThreshold then
    RawMulStdTo(P2,W0,W1,s1,s1)
  else
  if s1 < gcTm3MulThreshold then
    RawMulKarTo(P2,W0,W1,W4,s1)
  else
    RawMulTm3To(P2,W0,W1,W4,s1);

  t3 := c3 * d3;
  if c3 > 0 then Inc(t3,RawAddMulUI32(P3,W1,s1,c3));
  if d3 > 0 then Inc(t3,RawAddMulUI32(P3,W0,s1,d3));

  if s1 < gcKarMulThreshold then
    RawMulStdTo(W0,P0,P1,s1,s1)
  else
  if s1 < gcTm3MulThreshold then
    RawMulKarTo(W0,P0,P1,W4,s1)
  else
    RawMulTm3To(W0,P0,P1,W4,s1);

  t2 := c2 * d2;
  if c2 > 0 then Inc(t2,RawAddMulUI32(W1,P1,s1,c2));
  if d2 > 0 then Inc(t2,RawAddMulUI32(W1,P0,s1,d2));

  if s1 < gcKarMulThreshold then
    RawMulStdTo(P0,Q0,R0,s1,s1)
  else
  if s1 < gcTm3MulThreshold then
    RawMulKarTo(P0,Q0,R0,W4,s1)
  else
    RawMulTm3To(P0,Q0,R0,W4,s1);

  if sx < gcKarMulThreshold then
    RawMulStdTo(P4,Q2,R2,sx,sx)
  else
  if sx < gcTm3MulThreshold then
    RawMulKarTo(P4,Q2,R2,W4,sx)
  else
    RawMulTm3To(P4,Q2,R2,W4,sx);

  //-- third stage (interpolation)

  RawInterpolTm3(P0,W0,P2,W2,P4,sx+sx,s2,t2,t3,t4);

  //-- final stage

  Inc(t2,RawAdd(P1,W0,s2));
  Inc(t4,RawAdd(P3,W2,s2));
  if t2 > 0 then
  begin
    t2 := RawAddUI32(P3,sx+sx+s1,t2);
    ASSERT(t2 = 0);
  end;
  if t3 > 0 then
  begin
    t3 := RawAddUI32(P4,sx+sx,t3);
    ASSERT(t3 = 0);
  end;
  if t4 > 0 then
  begin
    t4 := RawAddUI32(@P4^[s1],sx+sx-s1,t4);
    ASSERT(t4 = 0);
  end;
end;

//==============================================================================
// P[] := Q[] * R[]
// Size(P[]) should be at least Count*2
//==============================================================================
procedure RawMulTo(P,Q,R: PUInt32Frame; Count: SInt32);
  var
{$IFDEF USE_STACK_AS_HEAP}
    V : array [0..(gcTm3MulThreshold+32)*2-1] of UInt32;
{$ENDIF}
    W : PUInt32Frame;
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT(P <> R);
  ASSERT(Q <> R);
  ASSERT((Count and $FF000000) = 0); // Count in 0..2**24-1?
  ASSERT(Count > 0);

  //-- standard multiplication
  if Count < gcKarMulThreshold then RawMulStdTo(P,Q,R,Count,Count)
  else
  //-- Karatsuba multiplication
  if Count < gcTm3MulThreshold then
  begin
  {$IFDEF USE_STACK_AS_HEAP}
    RawMulKarTo(P,Q,R,@V,Count);
  {$ELSE}
  {$IFDEF FREE_PASCAL}
    W := nil;
  {$ENDIF}
    GetMem(W,(Count+32) shl 3);
    try
      RawMulKarTo(P,Q,R,W,Count);
    finally
      FreeMem(W);
    end;
  {$ENDIF} // USE_STACK_AS_HEAP
  end
  else
  //-- Toom-3 multiplication
  begin
  {$IFDEF FREE_PASCAL}
    W := nil;
  {$ENDIF}
    GetMem(W,(Count+48) shl 3);
    try
      RawMulTm3To(P,Q,R,W,Count);
    finally
      FreeMem(W);
    end;
  end;
end;

//==============================================================================
// P[] := not P[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
procedure RawNotDebug(P: PUInt32Frame; Count: SInt32);
{$ELSE}
procedure RawNot(P: PUInt32Frame; Count: SInt32);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      mov   ecx, edx
      xor   ebx, ebx
      and   ecx, 3
      shr   edx, 2
      jz    @@02

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: not   dword ptr [eax+ebx*1]
      not   dword ptr [eax+ebx*1+4]
      not   dword ptr [eax+ebx*1+8]
      not   dword ptr [eax+ebx*1+12]
      dec   edx
      lea   ebx, [ebx+16]
      jnz   @@01

@@02: jmp   dword ptr @@RX[ecx*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: not   dword ptr [eax+ebx*1]
      add   ebx, 4
@@R2: not   dword ptr [eax+ebx*1]
      add   ebx, 4
@@R1: not   dword ptr [eax+ebx*1]
@@R0: pop   ebx
end;

{$IFDEF NX_DEBUG}
procedure RawNot(P: PUInt32Frame; Count: SInt32);
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  RawNotDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] or Q[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
procedure RawOrDebug(P,Q: PUInt32Frame; Count: SInt32);
{$ELSE}
procedure RawOr(P,Q: PUInt32Frame; Count: SInt32);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      shr   ecx, 2
      jz    @@02
      push  esi
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   esi, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      or    esi, [eax+ebx*1]
      or    edi, [eax+ebx*1+4]
      mov   [eax+ebx*1], esi
      mov   [eax+ebx*1+4], edi
      mov   esi, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      or    esi, [eax+ebx*1+8]
      or    edi, [eax+ebx*1+12]
      mov   [eax+ebx*1+8], esi
      mov   [eax+ebx*1+12], edi
      dec   ecx
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   esi
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      or    edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      add   ebx, 4
@@R2: mov   edi, [edx+ebx*1]
      or    edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      add   ebx, 4
@@R1: mov   edi, [edx+ebx*1]
      or    edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: pop   ebx
      pop   edi
end;

{$IFDEF NX_DEBUG}
procedure RawOr(P,Q: PUInt32Frame; Count: SInt32);
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  RawOrDebug(P,Q,Count);
end;
{$ENDIF}

//==============================================================================
// Parity Odd
// Result := parity of P[] (on Count 32-bit words)
// The returned value is equal to "(RawWeight(P,Count) and 1) = 1"
//==============================================================================
{$IFDEF NX_DEBUG}
function RawParityOddDebug(P: PUInt32Frame; Count: SInt32): Boolean;
{$ELSE}
function RawParityOdd(P: PUInt32Frame; Count: SInt32): Boolean;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      push  edi
      mov   ebx, edx
      xor   ecx, ecx
      and   ebx, 3
      shr   edx, 2
      jz    @@02
      xor   edi, edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: xor   ecx, [eax]
      xor   edi, [eax+4]
      xor   ecx, [eax+8]
      xor   edi, [eax+12]
      dec   edx
      lea   eax, [eax+16]
      jnz   @@01

      xor   ecx, edi
@@02: jmp   dword ptr @@RX[ebx*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: xor   ecx, [eax]
      add   eax, 4
@@R2: xor   ecx, [eax]
      add   eax, 4
@@R1: xor   ecx, [eax]
@@R0: pop   edi
      mov   eax, ecx
      pop   ebx
      shr   eax, 16
      xor   eax, ecx
      xor   al, ah
      setpo al
end;

{$IFDEF NX_DEBUG}
function RawParityOdd(P: PUInt32Frame; Count: SInt32): Boolean;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawParityOddDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] << Shift (on Count 32-bit words)
// Result := last dropped bit(s) = (P[Count-1] >> (32-Shift))
//==============================================================================
{$IFDEF NX_DEBUG}
function RawShlDebug(P: PUInt32Frame; Count,Shift: SInt32): UInt32;
{$ELSE}
function RawShl(P: PUInt32Frame; Count,Shift: SInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      push  edi

      mov   edi, eax
      mov   ebx, [edi+edx*4-4] // read most significant digit of A
      xor   eax, eax
      shld  eax, ebx, cl       // compute result
      dec   edx
      jz    @@FE

      push  eax                // push result
      test  edx, 1             // edx is odd?
      jnz   @@01               // if so enter loop in the middle

      mov   eax, ebx

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@00: mov   ebx, [edi+edx*4-4]
      shld  eax, ebx, cl
      mov   [edi+edx*4], eax
      dec   edx
@@01: mov   eax, [edi+edx*4-4]
      shld  ebx, eax, cl
      mov   [edi+edx*4], ebx
      dec   edx
      jnz   @@00

      shl   eax, cl            // compute least significant digit
      mov   [edi], eax
      pop   eax                // pop result
      pop   edi
      pop   ebx
      ret

@@FE: shl   ebx, cl            //compute least significant digit
      mov   [edi], ebx         //store it
      pop   edi
      pop   ebx
end;

{$IFDEF NX_DEBUG}
function RawShl(P: PUInt32Frame; Count,Shift: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(Count > 0);
  ASSERT(Shift > 0);
  ASSERT(Shift < 32);

  Result := RawShlDebug(P,Count,Shift);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] >> Shift (on Count 32-bit words)
// Return TRUE if the higher word is set to 0, return FALSE otherwise
//==============================================================================
{$IFDEF NX_DEBUG}
function RawShrDebug(P: PUInt32Frame; Count, Shift: SInt32): Boolean;
{$ELSE}
function RawShr(P: PUInt32Frame; Count, Shift: SInt32): Boolean;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  esi
      mov   edi, [eax]
      lea   eax, [eax+edx*4-4]
      neg   edx
      inc   edx
      jz    @@03
      test  edx, 1
      jnz   @@02
      mov   esi, edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   edi, [eax+edx*4+4]
      shrd  esi, edi, cl
      mov   [eax+edx*4], esi
      inc   edx
@@02: mov   esi, [eax+edx*4+4]
      shrd  edi, esi, cl
      mov   [eax+edx*4], edi
      inc   edx
      jnz   @@01

@@03: shr   dword ptr [eax], cl
      pop   esi
      pop   edi
      setz  al           // result TRUE iff (P^[Count-1] := 0)
end;

{$IFDEF NX_DEBUG}
function RawShr(P: PUInt32Frame; Count, Shift: SInt32): Boolean;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(Count > 0);
  ASSERT(Shift > 0);
  ASSERT(Shift < 32);

  Result := RawShrDebug(P,Count,Shift);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] >> 1 (on Count 32-bit words)
// Return TRUE if the higher word is set to 0, return FALSE otherwise
//==============================================================================
{$IFDEF NX_DEBUG}
function RawShr1Debug(P: PUInt32Frame; Count: SInt32): Boolean;
{$ELSE}
function RawShr1(P: PUInt32Frame; Count: SInt32): Boolean;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  ebx
      mov   ecx, edx              // ecx := Count
      lea   ebx, [eax+edx*4-4]    // ebx points to P[Count-1]
      and   ecx, 3
      cmp   dword ptr [ebx], 1
      sete  al                    // Result := Hi(Digit) = 1
      shr   edx, 2
      clc                         // clear CF
      jz    @@02

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: rcr   dword ptr [ebx], 1
      rcr   dword ptr [ebx-4], 1
      rcr   dword ptr [ebx-8], 1
      rcr   dword ptr [ebx-12], 1
      dec   edx
      lea   ebx, [ebx-16]
      jnz   @@01

@@02: jmp   dword ptr @@RX[ecx*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: rcr   dword ptr [ebx], 1
      lea   ebx, [ebx-4]
@@R2: rcr   dword ptr [ebx], 1
      lea   ebx, [ebx-4]
@@R1: rcr   dword ptr [ebx], 1
@@R0: pop   ebx
end;

{$IFDEF NX_DEBUG}
function RawShr1(P: PUInt32Frame; Count: SInt32): Boolean;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?
  ASSERT(Count > 0);

  Result := RawShr1Debug(P,Count);
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Standard square
// P[0..2*Count-1] := (Q[0..Count-1])**2
// The size of P[] should be >= 2*Count, the size of Q[] should be >= Count
//------------------------------------------------------------------------------
{$IFDEF NX_DEBUG}
procedure RawSqrStdToDebug(P,Q: PUInt32Frame; Count: SInt32);
{$ELSE}
procedure RawSqrStdTo(P,Q: PUInt32Frame; Count: SInt32);
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI, PP, QQ, C0, C1 : UInt32;
asm
      cmp   ecx, 3
      je    @@10
      jl    @@20

      //-- Count > 3

      mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi
      mov   PP, eax
      mov   QQ, edx
      mov   C0, ecx

      //-- products

      mov   edi, eax            // [edi] points P[0]
      xor   eax, eax
      dec   ecx                 // ecx := Count - 1
      mov   [edi], eax          // P[0] := 0
      mov   esi, QQ             // [esi] points Q[0]
      add   edi, 4
      mov   ebx, [esi]          // ebx := Q[0]
      push  ebp
      add   esi, 4              // [esi] points Q[1]
      xor   ebp, ebp            // carry := 0;

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   eax, [esi]          // eax := Q[i]
      mul   ebx                 // edx:eax := Q[i] * Q[0]
      add   eax, ebp            // add carry
      adc   edx, 0              // propagate carry
      mov   [edi], eax          // P[i] := eax
      mov   ebp, edx            // update carry
      add   esi, 4
      dec   ecx
      lea   edi, [edi+4]
      jnz   @@01

      pop   ebp
      mov   [edi], edx          // P[Count-1] := carry
      mov   ecx, C0
      sub   ecx, 2
      mov   esi, 8              // i = 2
      mov   C1, ecx

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: push  esi
      mov   edi, PP
      mov   eax, QQ             // [eax] points to Q[0]
      lea   edi, [edi+esi*2-4]  // edi := k = i + i - 1
      lea   esi, [eax+esi*1]    // esi := j = i
      push  ebp
      mov   ebx, [esi-4]        // ebx := Q[i-1], here esi = i
      xor   ecx, ecx
      mov   ebp, C1

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@03: mov   eax, [esi]          // eax := Q[j]
      mul   ebx                 // multiplier is Q[i-1]
      add   esi, 4
      add   eax, ecx            // eax + carry
      adc   edx, 0
      add   eax, [edi]          // P[i+j-1] := P[i+j-1] + Lo(Q[j] * Q[i-1])
      adc   edx, 0              // carry := Lo(Q[j] * Q[i-1]) + CF
      mov   [edi], eax          // P[i+j-1]
      mov   ecx, edx
      add   edi, 4
      dec   ebp
      jnz   @@03

      pop   ebp
      pop   esi                 // esi := i
      mov   [edi], edx          // P[i+j] := edx
      dec   C1
      lea   esi, [esi+4]
      jnz   @@02                // loop (outer loop)

      xor   eax, eax
      mov   [edi+4], eax        // P[Count+Count-1] := 0

      //-- shift left by 1 (P = P*2)

      mov   ecx, C0
      mov   edi, PP

      //-- here, CF = 0
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@04: mov   eax, [edi]
      mov   edx, [edi+4]
      adc   eax, eax
      adc   edx, edx
      mov   [edi], eax
      mov   [edi+4], edx
      dec   ecx
      lea   edi, [edi+8]
      jnz   @@04

      //-- add squares

@@05: mov   esi, QQ             // [esi] points to Q[0]
      mov   edi, PP             // i = 0
      mov   ebx, C0             // ebx := Count
      mov   eax, [esi]          // eax := Q[i]
      mul   eax
      add   esi, 4
      add   eax, [edi]          // P[0] := P[0] + eax + CF
      adc   edx, 0              // edx := edx + CF
      mov   [edi], eax          // P[0]
      dec   ebx
      add   edi, 4

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@06: mov   eax, [esi]          // eax := Q[i]
      mov   ecx, edx
      mul   eax
      add   esi, 4
      add   ecx, [edi]          // P[2*i+1] := P[2*i+1] + ecx
      adc   eax, [edi+4]        // P[2*i+2] := P[2*i+2] + eax + CF
      adc   edx, 0              // edx := Hi(mul) + CF
      mov   [edi], ecx          // P[2*i+1]
      mov   [edi+4], eax        // P[2*i+2]
      dec   ebx
      lea   edi, [edi+8]
      jnz   @@06

      add   edx, [edi]
      mov   [edi], edx
      mov   esi, SESI
      mov   edi, SEDI
      mov   ebx, SEBX
      mov   esp, ebp
      pop   ebp
      ret

      //-- Count = 3
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@10: mov   SEBX, ebx
      mov   SEDI, edi
      mov   ebx, eax
      mov   edi, edx
      xor   ecx, ecx
      mov   eax, [edi]
      mul   eax                 // Q0 * Q0
      mov   [ebx], eax          // P0
      mov   [ebx+4], edx        // P1
      mov   eax, [edi+4]
      mov   edx, [edi]
      mov   [ebx+8], ecx        // P2 := 0
      mul   edx                 // Q1 * Q0
      add   eax, eax
      adc   edx, edx
      adc   ecx, ecx
      add   eax, [ebx+4]        // P1
      adc   edx, [ebx+8]        // P2
      adc   ecx, 0
      mov   [ebx+4], eax        // P1
      mov   [ebx+8], edx        // P2
      mov   eax, [edi+4]
      mov   [ebx+12], ecx       // P3
      mul   eax                 // Q1 * Q1
      xor   ecx, ecx
      add   eax, [ebx+8]        // P2
      adc   edx, [ebx+12]       // P3
      mov   [ebx+8], eax        // P2
      mov   [ebx+12], edx       // P3
      adc   ecx, ecx
      mov   edx, [edi]
      mov   eax, [edi+8]
      mul   edx                 // Q2 * Q0
      add   eax, eax
      adc   edx, edx
      adc   ecx, 0
      add   eax, [ebx+8]        // P2
      adc   edx, [ebx+12]       // P3
      mov   [ebx+8], eax        // P2
      mov   [ebx+12], edx       // P3
      adc   ecx, 0
      mov   edx, [edi+4]
      mov   [ebx+16], ecx       // P4
      mov   eax, [edi+8]
      mul   edx                 // Q2 * Q1
      xor   ecx, ecx
      add   eax, eax
      adc   edx, edx
      adc   ecx, ecx
      add   eax, [ebx+12]       // P3
      adc   edx, [ebx+16]       // P4
      mov   [ebx+12], eax       // P3
      mov   [ebx+16], edx       // P4
      mov   eax, [edi+8]
      adc   ecx, 0
      mul   eax                 // Q2 * Q2
      add   eax, [ebx+16]       // P4
      adc   ecx, edx
      mov   [ebx+16], eax       // P4
      mov   [ebx+20], ecx       // P5
      mov   edi, SEDI
      mov   ebx, SEBX
      mov   esp, ebp
      pop   ebp
      ret

      //-- Count = 0, 1 or 2
  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@20: cmp   ecx, 1
      jb    @@FF
      je    @@30

      //-- Count = 2
      mov   SEBX, ebx
      mov   ecx, eax
      mov   ebx, edx
      mov   eax, [edx]
      mul   eax
      mov   [ecx], eax          // P0
      mov   [ecx+4], edx        // P1
      mov   eax, [ebx+4]
      mul   eax
      mov   [ecx+8], eax        // P2
      mov   [ecx+12], edx       // P3
      mov   eax, [ebx]
      mov   edx, [ebx+4]
      mul   edx
      xor   ebx, ebx
      add   eax, eax
      adc   edx, edx
      adc   ebx, ebx
      add   eax, [ecx+4]        // P1
      adc   edx, [ecx+8]        // P2
      adc   ebx, [ecx+12]       // P3
      mov   [ecx+4], eax        // P1
      mov   [ecx+8], edx        // P2
      mov   [ecx+12], ebx       // P3
      mov   ebx, SEBX
      mov   esp, ebp
      pop   ebp
      ret

      //-- Count = 1
@@30: mov   ecx, eax
      mov   eax, [edx]
      mul   eax
      mov   [ecx], eax
      mov   [ecx+4], edx
@@FF:
end;

{$IFDEF NX_DEBUG}
procedure RawSqrStdTo(P,Q: PUInt32Frame; Count: SInt32);
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT((Count and $FF000000) = 0); // Count in 0..2**24-1?

  RawSqrStdToDebug(P,Q,Count);
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Karatsuba square
// P[0..2*Count-1] := (Q[0..Count-1])**2
// The size of P[] must be >= 2*Count, the size of Q[] must be >= Count
// W[] is a buffer of which the size must be >= (Count+32)*2
// Adapted from a GMP routine
//------------------------------------------------------------------------------
procedure RawSqrKarTo(P,Q,W: PUInt32Frame; Count: SInt32);
  var
    T, Pk, Qk : PUInt32Frame;
    x         : UInt32;
    c1, m, n  : SInt32;
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT(P <> W);
  ASSERT(Q <> W);
  ASSERT(Count >= gcKarSqrThreshold);

  m := Count shr 1;
  if (Count and 1) = 0 then
  begin
    Qk := @Q^[m];
    if RawCmp(Q,Qk,m) >= 0 then RawSubTo(P,Q,Qk,m)
    else RawSubTo(P,Qk,Q,m);

    Pk := @P^[Count];
    if m < gcKarSqrThreshold then
    begin
      RawSqrStdTo(W,P,m);
      RawSqrStdTo(P,Q,m);
      RawSqrStdTo(Pk,Qk,m);
    end
    else
    begin
      T := @W^[Count];
      RawSqrKarTo(W,P,T,m);
      RawSqrKarTo(P,Q,T,m);
      RawSqrKarTo(Pk,Qk,T,m);
    end;

    x := RawSubr(W,P,Count);
    Inc(x,RawAdd(W,Pk,Count));
    Inc(x,RawAdd(@P^[m],W,Count));
    if x > 0 then RawAddUI32(@Pk^[m],m,x);
  end
  else // Count is odd
  begin
    n := m + 1; // m + n = Count
    Qk := @Q^[n];

    x := Q^[m];
    if x > 0 then Inc(x,RawSubTo(P,Q,Qk,m))
    else
    if RawCmp(Q,Qk,m) >= 0 then RawSubTo(P,Q,Qk,m)
    else RawSubTo(P,Qk,Q,m);
    P^[m] := x;

    c1 := Count + 1;
    Pk := @P^[c1];
    if m < gcKarSqrThreshold then
    begin
      if n < gcKarSqrThreshold then
      begin
        RawSqrStdTo(W,P,n);
        RawSqrStdTo(P,Q,n);
      end
      else
      begin
        T := @W^[c1];
        RawSqrKarTo(W,P,T,n);
        RawSqrKarTo(P,Q,T,n);
      end;
      RawSqrStdTo(Pk,Qk,m);
    end
    else
    begin
      T := @W^[c1];
      RawSqrKarTo(W,P,T,n);
      RawSqrKarTo(P,Q,T,n);
      RawSqrKarTo(Pk,Qk,T,m);
    end;
    RawSubr(W,P,c1);

    if RawAdd(W,Pk,Count-1) > 0 then
    begin
      T := @W^[Count-1];
      Inc(T^[0]);
      if T^[0] = 0 then
      begin
        Inc(T);
        Inc(T^[0]);
      end;
    end;

    if RawAdd(@P^[n],W,c1) > 0 then
    begin
      T := @Pk^[m];
      repeat
        Inc(T);
        Inc(T^[0]);
      until T^[0] > 0;
    end;
  end;
end;

//------------------------------------------------------------------------------
// Toom-3 square
// P[0..2*Count-1] := (Q[0..Count-1])**2
// W[] is workspace
// Adapted from a GMP routine
//------------------------------------------------------------------------------
procedure RawSqrTm3To(P0,Q0,W0: PUInt32Frame; Count: SInt32);
  var
    P2, P3, P4, Q2, W2, W4 : PUInt32Frame;
    c2, c3, c4, t2, t3, t4 : UInt32;
    k, s1, s2, sx          : SInt32;
begin
  //-- require
  ASSERT(P0 <> Q0);
  ASSERT(P0 <> W0);
  ASSERT(Q0 <> W0);
  ASSERT(Count >= gcTm3SqrThreshold);

  // split Count into 3 parts such that Count = s1 + s1 + sx
  //   Count = 3*k   => s1 = k,   sx = k
  //   Count = 3*k+1 => s1 = k+1, sx = k-1
  //   Count = 3*k+2 => s1 = k+1, sx = k
  k := Count div 3;
  case UInt32(Count - (k+k+k)) of
    0: begin
         s1 := k;
         sx := k;
       end;
    1: begin
         s1 := k+1;
         sx := k-1;
       end;
    else
    s1 := k+1;
    sx := k;
  end;
  s2 := s1 + s1; // s1 * 2

  //-- pointers
  P2 := @P0^[s2];
  P3 := @P2^[s1];
  P4 := @P3^[s1];
  Q2 := @Q0^[s2];
  W2 := @W0^[s2];
  W4 := @W2^[s2];

  //-- first stage (evaluation at points 0, 1/2, 1, 2, oo)

  RawEvalTm3(P0,W0,P2,Q0,@Q0^[s1],Q2,sx,s1,c2,c3,c4);

  //-- second stage

  if s1 < gcKarSqrThreshold then
    RawSqrStdTo(W2,P2,s1)
  else
  if s1 < gcTm3SqrThreshold then
    RawSqrKarTo(W2,P2,W4,s1)
  else
    RawSqrTm3To(W2,P2,W4,s1);

  if c4 > 0 then
    t4 := c4 * c4 + RawAddMulUI32(@W2^[s1],P2,s1,c4+c4)
  else
    t4 := 0;

  if s1 < gcKarSqrThreshold then
    RawSqrStdTo(P2,W0,s1)
  else
  if s1 < gcTm3SqrThreshold then
    RawSqrKarTo(P2,W0,W4,s1)
  else
    RawSqrTm3To(P2,W0,W4,s1);

  if c3 > 0 then
    t3 := c3 * c3 + RawAddMulUI32(P3,W0,s1,c3+c3)
  else
    t3 := 0;

  if s1 < gcKarSqrThreshold then
    RawSqrStdTo(W0,P0,s1)
  else
  if s1 < gcTm3SqrThreshold then
    RawSqrKarTo(W0,P0,W4,s1)
  else
    RawSqrTm3To(W0,P0,W4,s1);

  if c2 > 0 then
    t2 := c2 * c2 + RawAddMulUI32(@W0^[s1],P0,s1,c2+c2)
  else
    t2 := 0;

  if s1 < gcKarSqrThreshold then
    RawSqrStdTo(P0,Q0,s1)
  else
  if s1 < gcTm3SqrThreshold then
    RawSqrKarTo(P0,Q0,W4,s1)
  else
    RawSqrTm3To(P0,Q0,W4,s1);

  if sx < gcKarSqrThreshold then
    RawSqrStdTo(P4,Q2,sx)
  else
  if sx < gcTm3SqrThreshold then
    RawSqrKarTo(P4,Q2,W4,sx)
  else
    RawSqrTm3To(P4,Q2,W4,sx);

  //-- third stage (interpolation)

  RawInterpolTm3(P0,W0,P2,W2,P4,sx+sx,s2,t2,t3,t4);

  //-- final stage

  Inc(t2,RawAdd(@P0^[s1],W0,s2));
  Inc(t4,RawAdd(P3,W2,s2));
  if t2 > 0 then
  begin
    t2 := RawAddUI32(P3,sx+sx+s1,t2);
    ASSERT(t2 = 0);
  end;
  if t3 > 0 then
  begin
    t3 := RawAddUI32(P4,sx+sx,t3);
    ASSERT(t3 = 0);
  end;
  if t4 > 0 then
  begin
    t4 := RawAddUI32(@P4^[s1],sx+sx-s1,t4);
    ASSERT(t4 = 0);
  end;
end;

//==============================================================================
// P[] := (Q[])**2
// Size(P[]) should be at least 2*Count
// Size(Q[]) should be at least Count
//==============================================================================
procedure RawSqrTo(P,Q: PUInt32Frame; Count: SInt32);
  var
{$IFDEF USE_STACK_AS_HEAP}
    V : array [0..(gcTm3SqrThreshold+32)*2-1] of UInt32;
{$ENDIF}
    W : PUInt32Frame;
begin
  //-- require
  ASSERT(P <> Q);
  ASSERT((Count and $FF000000) = 0); // Count in 0..2**24-1?

  if Count < gcKarSqrThreshold then RawSqrStdTo(P,Q,Count)
  else
{$IFDEF USE_STACK_AS_HEAP}
  if Count < gcTm3SqrThreshold then RawSqrKarTo(P,Q,@V,Count)
{$ELSE}
  if Count < gcTm3SqrThreshold then
  begin
  {$IFDEF FREE_PASCAL}
    W := nil;
  {$ENDIF}
    GetMem(W,(Count+32) shl 3);
    try
      RawSqrKarTo(P,Q,W,Count);
    finally
      FreeMem(W);
    end;
  end
{$ENDIF} // USE_STACK_AS_HEAP
  else
  begin
  {$IFDEF FREE_PASCAL}
    W := nil;
  {$ENDIF}
    GetMem(W,(Count+48) shl 3);
    try
      RawSqrTm3To(P,Q,W,Count);
    finally
      FreeMem(W);
    end;
  end;
end;

//==============================================================================
// P[] := P[] - Q[] (on Count 32-bit words)
// Result := last borrow (0 or $ffffffff)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawSubDebug(P,Q: PUInt32Frame; Count: SInt32): UInt32;
{$ELSE}
function RawSub(P,Q: PUInt32Frame; Count: SInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      shr   ecx, 2
      clc
      jz    @@02
      push  esi
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   esi, [eax+ebx*1]
      mov   edi, [eax+ebx*1+4]
      sbb   esi, [edx+ebx*1]
      sbb   edi, [edx+ebx*1+4]
      mov   [eax+ebx*1], esi
      mov   [eax+ebx*1+4], edi
      mov   esi, [eax+ebx*1+8]
      mov   edi, [eax+ebx*1+12]
      sbb   esi, [edx+ebx*1+8]
      sbb   edi, [edx+ebx*1+12]
      mov   [eax+ebx*1+8], esi
      mov   [eax+ebx*1+12], edi
      dec   ecx
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   esi
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   ecx, [eax+ebx*1]
      sbb   ecx, [edx+ebx*1]
      mov   [eax+ebx*1], ecx
      lea   ebx, [ebx+4]
@@R2: mov   ecx, [eax+ebx*1]
      sbb   ecx, [edx+ebx*1]
      mov   [eax+ebx*1], ecx
      lea   ebx, [ebx+4]
@@R1: mov   ecx, [eax+ebx*1]
      sbb   ecx, [edx+ebx*1]
      mov   [eax+ebx*1], ecx
@@R0: pop   ebx
      pop   edi
      sbb   eax, eax
end;

{$IFDEF NX_DEBUG}
function RawSub(P,Q: PUInt32Frame; Count: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawSubDebug(P,Q,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := Q[] - P[] (on Count 32-bit words)
// Result := last borrow (0 or $ffffffff)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawSubrDebug(P,Q: PUInt32Frame; Count: SInt32): UInt32;
{$ELSE}
function RawSubr(P,Q: PUInt32Frame; Count: SInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      shr   ecx, 2
      clc
      jz    @@02
      push  esi
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   esi, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      sbb   esi, [eax+ebx*1]
      sbb   edi, [eax+ebx*1+4]
      mov   [eax+ebx*1], esi
      mov   [eax+ebx*1+4], edi
      mov   esi, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      sbb   esi, [eax+ebx*1+8]
      sbb   edi, [eax+ebx*1+12]
      mov   [eax+ebx*1+8], esi
      mov   [eax+ebx*1+12], edi
      dec   ecx
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   esi
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      sbb   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R2: mov   edi, [edx+ebx*1]
      sbb   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R1: mov   edi, [edx+ebx*1]
      sbb   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: sbb   eax, eax
      pop   ebx
      pop   edi
end;

{$IFDEF NX_DEBUG}
function RawSubr(P,Q: PUInt32Frame; Count: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawSubrDebug(P,Q,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := Q[] - R[] (on Count 32-bit words)
// Result := last borrow (0 or $ffffffff)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawSubToDebug(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
{$ELSE}
function RawSubTo(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
{$ENDIF}
assembler; register;
  var SEBX, SEDI, SESI : UInt32;
asm
      mov   SEBX, ebx
      mov   SEDI, edi
      mov   SESI, esi
      mov   edi, Count
      xor   ebx, ebx
      mov   esi, edi
      and   edi, 3
      shr   esi, 2
      clc
      jz    @@02
      push  ebp
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   ebp, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      sbb   ebp, [ecx+ebx*1]
      sbb   edi, [ecx+ebx*1+4]
      mov   [eax+ebx*1], ebp
      mov   [eax+ebx*1+4], edi
      mov   ebp, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      sbb   ebp, [ecx+ebx*1+8]
      sbb   edi, [ecx+ebx*1+12]
      mov   [eax+ebx*1+8], ebp
      mov   [eax+ebx*1+12], edi
      dec   esi
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   ebp
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      sbb   edi, [ecx+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R2: mov   edi, [edx+ebx*1]
      sbb   edi, [ecx+ebx*1]
      mov   [eax+ebx*1], edi
      lea   ebx, [ebx+4]
@@R1: mov   edi, [edx+ebx*1]
      sbb   edi, [ecx+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: mov   esi, SESI
      mov   edi, SEDI
      mov   ebx, SEBX
      sbb   eax, eax
end;

{$IFDEF NX_DEBUG}
function RawSubTo(P,Q,R: PUInt32Frame; Count: SInt32): UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawSubToDebug(P,Q,R,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] - D (on Count 32-bit words)
// Return borrow (0 or $ffffffff) or return UInt32(-D) if Count = 0
//==============================================================================
{$IFDEF NX_DEBUG}
function RawSubUI32Debug(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ELSE}
function RawSubUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      dec   edx             // Count := Count - 1
      js    @@01            // jmp if Count < 0

      sub   [eax], ecx      // P[0] := P[0] - D
      mov   ecx, 0          // do not modify CF
      jc    @@02            // jmp if borrow

@@01: neg   ecx             // Result := 0 or -D
      mov   eax, ecx
      ret

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@02: dec   edx             // Count := Count - 1
      lea   eax, [eax+4]    // i := i + 1
      js    @@03            // jmp if Count < 0 (CF = 1)
      sbb   [eax], ecx      // P[i] := P[i] - 1
      jc    @@02            // jmp if borrow

@@03: sbb   eax, eax        // Result := 0 or -1
end;

{$IFDEF NX_DEBUG}
function RawSubUI32(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  //-- require
  ASSERT(( Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawSubUI32Debug(P,Count,D);
end;
{$ENDIF}

//-- deprecated
function RawSubd(P: PUInt32Frame; Count: SInt32; D: UInt32): UInt32;
begin
  Result := RawSubUI32(P,Count,D);
end;

//==============================================================================
// Result := Hamming weight of P[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
function RawWeightDebug(P: PUInt32Frame; Count: SInt32): SInt32;
{$ELSE}
function RawWeight(P: PUInt32Frame; Count: SInt32): SInt32;
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      lea   edi, [eax-4]     // [edi] points to P[-1]
      xor   eax, eax         // Result := 0
      test  edx, edx
      jz    @@02

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   ecx, [edi+edx*4]
      mov   ebx, ecx
      shr   ebx, 1
      and   ebx, $55555555
      sub   ecx, ebx
      mov   ebx, ecx
      shr   ecx, 2
      and   ebx, $33333333
      and   ecx, $33333333
      add   ecx, ebx
      mov   ebx, ecx
      shr   ecx, 4
      add   ecx, ebx
      and   ecx, $0f0f0f0f
      mov   ebx, ecx
      shr   ecx, 8
      add   ecx, ebx
      mov   ebx, ecx
      shr   ecx, 16
      add   ecx, ebx
      and   ecx, $000000ff
      add   eax, ecx
      dec   edx
      jnz   @@01

@@02: pop   ebx
      pop   edi
end;

{$IFDEF NX_DEBUG}
function RawWeight(P: PUInt32Frame; Count: SInt32): SInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  Result := RawWeightDebug(P,Count);
end;
{$ENDIF}

//==============================================================================
// P[] := P[] xor Q[] (on Count 32-bit words)
//==============================================================================
{$IFDEF NX_DEBUG}
procedure RawXorDebug(P,Q: PUInt32Frame; Count: SInt32);
{$ELSE}
procedure RawXor(P,Q: PUInt32Frame; Count: SInt32);
{$ENDIF}
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      push  edi
      push  ebx
      mov   edi, ecx
      xor   ebx, ebx
      and   edi, 3
      shr   ecx, 2
      jz    @@02
      push  esi
      push  edi

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@01: mov   esi, [edx+ebx*1]
      mov   edi, [edx+ebx*1+4]
      xor   esi, [eax+ebx*1]
      xor   edi, [eax+ebx*1+4]
      mov   [eax+ebx*1], esi
      mov   [eax+ebx*1+4], edi
      mov   esi, [edx+ebx*1+8]
      mov   edi, [edx+ebx*1+12]
      xor   esi, [eax+ebx*1+8]
      xor   edi, [eax+ebx*1+12]
      mov   [eax+ebx*1+8], esi
      mov   [eax+ebx*1+12], edi
      dec   ecx
      lea   ebx, [ebx+16]
      jnz   @@01

      pop   edi
      pop   esi
@@02: jmp   dword ptr @@RX[edi*4]

  {$IFDEF FREE_PASCAL}
      align 4
  {$ENDIF}
@@RX: dd    @@R0,@@R1,@@R2,@@R3
@@R3: mov   edi, [edx+ebx*1]
      xor   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      add   ebx, 4
@@R2: mov   edi, [edx+ebx*1]
      xor   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
      add   ebx, 4
@@R1: mov   edi, [edx+ebx*1]
      xor   edi, [eax+ebx*1]
      mov   [eax+ebx*1], edi
@@R0: pop   ebx
      pop   edi
end;

{$IFDEF NX_DEBUG}
procedure RawXor(P,Q: PUInt32Frame; Count: SInt32);
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  RawXorDebug(P,Q,Count);
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
end.
////////////////////////////////////////////////////////////////////////////////

