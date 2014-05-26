////////////////////////////////////////////////////////////////////////////////
// Basic Types
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
unit nx_types;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
////////////////////////////////////////////////////////////////////////////////


type
  //-- basic integer types
  SInt8  = Shortint; //  8-bit signed
  SInt16 = Smallint; // 16-bit signed
  SInt32 = Longint;  // 32-bit signed
  SInt64 = Int64;    // 64-bit signed
  UInt8  = Byte;     //  8-bit unsigned
  UInt16 = Word;     // 16-bit unsigned
  UInt32 = Longword; // 32-bit unsigned
  //
  // FREE PASCAL 2.2.0+ and DELPHI 7+ have the System.UInt64 type
  //
{$IFNDEF HAS_UINT64_TYPE}
{$IFDEF HAS_QWORD_TYPE}
  UInt64 = QWord; // unsigned 64-bit integer
{$ELSE}
  //-- for DELPHI 5 or 6
  //   !!! NX regards UInt64 instances as unsigned but DELPHI does not !!!
  UInt64 = type Int64;
  {$DEFINE HAS_FAKE_UINT64_TYPE}
{$ENDIF} // HAS_QWORD_TYPE
{$ENDIF} // HAS_UINT64_TYPE

  //-- frames
  //
  //   !!! Do not modify. So that pointer arithmetic is possible, the size of a
  //   frame should be equal to the size of the base type.
  //
  TSInt32Frame = array [0..0] of SInt32;
  TUInt8Frame  = array [0..0] of UInt8;
  TUInt16Frame = array [0..0] of UInt16;
  TUInt32Frame = array [0..0] of UInt32;
  TUInt64Frame = array [0..0] of UInt64;

  //-- pointers
  PSInt8  = ^SInt8;
  PSInt16 = ^SInt16;
  PSInt32 = ^SInt32;
  PSInt64 = ^SInt64;
  PUInt8  = ^UInt8;
  PUInt16 = ^UInt16;
  PUInt32 = ^UInt32;
  PUInt64 = ^UInt64;

  PSInt32Frame = ^TSInt32Frame;
  PUInt8Frame  = ^TUInt8Frame;
  PUInt16Frame = ^TUInt16Frame;
  PUInt32Frame = ^TUInt32Frame;
  PUInt64Frame = ^TUInt64Frame;

{$IFDEF DELPHI}
  TThreadID = Cardinal;
{$ENDIF}

  //-- to cast integer types
  SInt32x2 = packed record Lo,Hi: SInt32; end;
  UInt32x2 = packed record Lo,Hi: UInt32; end;

  PSInt32x2 = ^SInt32x2;
  PUInt32x2 = ^UInt32x2;

  UInt32Union = packed record
    case Byte of
      0: (Whole: UInt32);
      1: (W0,W1: UInt16);
      2: (B0,B1,B2,B3: UInt8);
  end;
  UInt64Union = packed record
    case Byte of
      0: (Whole: UInt64);
      1: (Lo,Hi: UInt32);
      2: (W0,W1,W2,W3: UInt16);
      3: (B0,B1,B2,B3,B4,B5,B6,B7: UInt8);
  end;

  //-- to cast the Real type (which one is Single or Double)
  TRealData = packed record
    Significand : UInt64;
    Exponent    : SInt32;
    SignFlag    : UInt32;
  end;

  //-- dynamic arrays
  TSInt32DynArray = array of SInt32;
  TSInt64DynArray = array of SInt64;
  TUInt32DynArray = array of UInt32;
  TUInt64DynArray = array of UInt64;

  //-- miscellaneous
  TAnsiCharSet = set of AnsiChar;

  //-- abstract ancestor of all NX classes (shouldn't be instanciated)
  TNXClass = class {$IFDEF HAS_ABSTRACT_CLASS} abstract {$ENDIF} end;

  //-- polynomial types
  TPolynomialType = (
    ptNull,        // null polynomial
    ptMonomial,    // 1 non null coefficient
    ptBinomial,    // 2 non null coefficients
    ptTrinomial,   // 3 non null coefficients
    ptTetranomial, // 4 non null coefficients
    ptPentanomial, // 5 non null coefficients
    ptOrdinary);   // more than 5 non null coefficients

  //-- basis types (for Galois fields)
  TGFBasisType = (
    btPolynomial,
    btNormal);

  //-- elliptic curve (over GF(p^n)) status
  TGFPNECStatus = (
    csEmpty,
    csHasField,
    csHasCoefficients);


////////////////////////////////////////////////////////////////////////////////
implementation
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
{$IFDEF NX_CHECKS}
initialization
  //-- frames and base types should have the same sizes
  if SizeOf(TSInt32Frame) <> SizeOf(SInt32) then RunError(255);
  if SizeOf(TUInt8Frame)  <> SizeOf(UInt8)  then RunError(255);
  if SizeOf(TUInt16Frame) <> SizeOf(UInt16) then RunError(255);
  if SizeOf(TUInt32Frame) <> SizeOf(UInt32) then RunError(255);
  if SizeOf(TUInt64Frame) <> SizeOf(UInt64) then RunError(255);
{$ENDIF}
end.
////////////////////////////////////////////////////////////////////////////////

