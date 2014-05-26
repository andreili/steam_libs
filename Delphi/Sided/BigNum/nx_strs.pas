////////////////////////////////////////////////////////////////////////////////
// Common String Stuff
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
unit nx_strs;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
uses nx_types;
////////////////////////////////////////////////////////////////////////////////

//
// Since v0.24.0, NX follows the Ada specifications regarding numerical
// expressions (for the bases 2, 4, 8, 10 and 16).
// For instance
//   2#1010.001#E+25 is a number expressed to the base 2,
//   4#3200# is a number expressed to the base 4,
//   8#7600# is a number expressed to the base 8,
//  10#9876# is a number expressed to the base 10,
//  16#FFFF# is a number expressed to the base 16.
// For the base 10, the 10#...# stuff is optional.
// The base (if any) is always expressed to the base 10.
// The exponent (if any) is always expressed to the base 10.
// The exponent flag is 'E' or 'e'.
// Positive signs are optional.
// A negative number is denoted, for instance, -16#1000#.
//
// See the Ada Reference Manual (Ada 2005), ISO/IEC 8652:1995(E) with Technical
// Corrigendum 1 and Amendment 1 (Draft 16), 2.4, 2.4.1, 2.4.2 , A.10.8 (8) and
// A.10.9 (13,14,15,16,17,18).
//

const
  gcBaseDelimiter  = AnsiChar('#');
  gcDecimalPoint   = AnsiChar('.');
  gcDigitSeparator = AnsiChar('_');

type
  TBigNumberData = record
    Significand: AnsiString;
    SignFlag: SInt32;
    Exponent: SInt32;
    Base: UInt32;
  end;

  TStrFormatOptions = (
    sfoLeftPadded,
    sfoNoSign,
    sfoNoTrailingZeros);

  TStrFormatOptionSet = set of TStrFormatOptions;

  TStrBaseDelimiters = (
    sbdDefault, // <Base>#...# in all strings except when Base = 10
    sbdAlways,  // <Base>#...# in all strings
    sbdNever);  // no <Base>#...# in strings


function NXGetBigNumberData(
           out   Data : TBigNumberData;
           const S    : AnsiString): SInt32;

function NXInsertSeparatorsFromRight(
           const S           : AnsiString;
                 BlockLength : SInt32;
                 LeftPadded  : Boolean): AnsiString;

function RawToBase2Str(P: PUInt32Frame; Count: SInt32): AnsiString;
function RawToBase4Str(P: PUInt32Frame; Count: SInt32): AnsiString;
function RawToBase8Str(P: PUInt32Frame; Count: SInt32): AnsiString;
function RawToBase10Str(P: PUInt32Frame; Count: SInt32): AnsiString;
function RawToBase16Str(P: PUInt32Frame; Count: SInt32): AnsiString;


////////////////////////////////////////////////////////////////////////////////
implementation
uses
  USE_Utils,
  nx_common,
  nx_kernel;
////////////////////////////////////////////////////////////////////////////////

{$IFDEF FREE_PASCAL}
  {$ASMMODE INTEL}
{$ENDIF}

//-- the two following directives should not be modified
{$Q-}
{$R-}

//==============================================================================
// Result := Binary size of A
// Same as nx_z.UI32BitSize but re-implemented here to avoid a circular
// reference
//==============================================================================
function BitSize(A: UInt32): SInt32;
assembler; register; {$IFDEF FREE_PASCAL} nostackframe; {$ENDIF}
asm
      bsr   eax, eax
      jz    @@01
      inc   eax
      ret

@@01: xor   eax, eax
end;

//==============================================================================
// -> S, Ada expression representing an integer or a real
//    S should contain a valid numerical expression without space or special
//    characters like <tab>, <cr>, <lf>, etc.
// <- Data, S splitted (and checked)
// <- Result
//    Result =  0 -> all is right
//           >  0 -> error  (Result is the position of the syntax error in S)
//           = -1 -> error  (S is empty)
//==============================================================================
function NXGetBigNumberData(
           out   Data : TBigNumberData;
           const S    : AnsiString): SInt32;
  const
    ccInvalid        = UInt8(0);
    ccSign           = UInt8(1);
    ccDigit          = UInt8(2);
    ccDigitSeparator = UInt8(3);
    ccBaseDelimiter  = UInt8(4);
    ccDecimalPoint   = UInt8(5);
    ccExponentFlag   = UInt8(6);
    ccEndOfString    = UInt8(7);
  type
    TCodeChar = ccInvalid..ccEndOfString;
  const
    //
    // NewState := TransitionTable[CodeChar,OldState]
    //
    TransitionTable : array [TCodeChar, 1..20] of UInt8 = (
    //-- old state --------------------------------------------------------
    // 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
    //---------------------------------------------------------------------
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 0 i
    (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,18, 0, 0, 0),  // 1 s
    (3, 3, 3, 3,10, 8, 8, 8, 8,10,10,14,14,14,14, 0,19,19,19, 0),  // 2 d
    (0, 0, 4, 0, 0, 0, 0, 9, 0,11, 0, 0, 0,15, 0, 0, 0, 0,20, 0),  // 3 ds
    (0, 0, 5, 0, 0, 0, 0, 0, 0,16, 0,16, 0,16, 0, 0, 0, 0, 0, 0),  // 4 bd
    (7, 7, 6, 0,13, 0, 0, 0, 0,12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 5 dp
    (0, 0,17, 0, 0,17, 0,17, 0, 0, 0, 0, 0, 0, 0,17, 0, 0, 0, 0),  // 6 ef
    (0, 0,21, 0, 0,21, 0,21, 0, 0, 0, 0, 0, 0, 0,21, 0, 0,21,21)); // 7 eos
    //---------------------------------------------------------------------

    //
    // Action := ActionTable[OldState,NewState]
    //
    //   0: exit (syntax error)
    //   1: set significand sign
    //   2: initialize Index and Count for digit sequence
    //   3: increase Count
    //   4: set BPart (base)
    //   5: set IPart (integer part)
    //   6: set FPart (fractional part)
    //   7: reset Base to 10
    //   8: set EPart (exponent)
    //   9: do 5 & 7
    //  10: do 6 & 7
    //  11: break (all is right)
    //  12: do 5 & 11
    //  13: do 6 & 11
    //  14: do 8 & 11
    //  15: do nothing
    //
    ActionTable : array [1..20, 0..21] of UInt8 = (
    //-- new state -----------------------------------------------------------
    // 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21
    //------------------------------------------------------------------------
    (0, 0, 1, 2, 0, 0, 0,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 1
    (0, 0, 0, 2, 0, 0, 0,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 2
    (0, 0, 0, 3, 3, 4, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0,12),  // 3
    (0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 4
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0,15, 0, 0, 0, 0, 0, 0, 0, 0),  // 5
    (0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0,15, 0, 0, 0,11),  // 6
    (0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 7
    (0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0,13),  // 8
    (0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 9
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 5, 0, 0, 0, 9, 0, 0, 0, 0, 0),  // 10
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),  // 11
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 9, 0, 0, 0, 0, 0),  // 12
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0),  // 13
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3,10, 0, 0, 0, 0, 0),  // 14
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0),  // 15
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,15, 0, 0, 0,11),  // 16
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0),  // 17
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0),  // 18
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3,14),  // 19
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0)); // 20
    //------------------------------------------------------------------------

  var
    T                   : PAnsiChar;
    IPart, FPart, EPart : AnsiString;
    i, Index, Count, e  : SInt32;
    Base                : UInt32;
    OldState, NewState  : UInt8;
    esign               : Boolean;

  //--------------------------------------------------------------------------
  function GetCodeChar(c: AnsiChar): TCodeChar;
  begin
    case c of
      '+','-':
      Result := ccSign;

      #0:
      Result := ccEndOfString;

      '0','1':
      Result := ccDigit;

      '2'..'9':
      if Base > UInt32(Ord(c)-Ord('0')) then Result := ccDigit
      else Result := ccInvalid;

      'A'..'D','F'..'Z':
      if Base > UInt32(Ord(c)-Ord('A')+10) then Result := ccDigit
      else Result := ccInvalid;

      'a'..'d','f'..'z':
      if Base > UInt32(Ord(c)-Ord('a')+10) then Result := ccDigit
      else Result := ccInvalid;

      'E','e':
      if Base > 14 then Result := ccDigit
      else
      if Base = 10 then Result := ccExponentFlag
      else Result := ccInvalid;

      gcBaseDelimiter:
      Result := ccBaseDelimiter;

      gcDecimalPoint:
      Result := ccDecimalPoint;

      gcDigitSeparator:
      Result := ccDigitSeparator;

      else
      Result := ccInvalid;
    end;
  end;
  //--------------------------------------------------------------------------
  procedure SetBase;
    var
      S    : AnsiString;
      i, j : SInt32;
      c    : AnsiChar;
      P    : PAnsiChar;
  begin
    //-- don't take in account the leading 0's (if any)
    c := (T+Index)^;
    while (Count > 0) and ((c = '0') or (c = gcDigitSeparator)) do
    begin
      Inc(Index);
      Dec(Count);
      c := (T+Index)^;
    end;
    if Count = 0 then Exit;

    SetLength(S,Count); // oversize
    P := PAnsiChar(S); // alias
    j := 0;
    for i := Index to Index+Count-1 do
    begin
      c := (T+i)^;
      if c <> gcDigitSeparator then
      begin
        (P+j)^ := c;
        Inc(j);
      end;
    end;

    if (j < 1) or (j > 2) then Exit; // the base should have 1 or 2 digits

    if j > 0 then
    begin
      if j < Count then SetLength(S,j); // adjust size
      Base := UInt32(Str2Int(Ansi2Wide(S))); // may raise an exception
      if (Base < 2) or (Base > 36) then Exit;
    end;
  end;
  //--------------------------------------------------------------------------
  procedure SetIPart;
    var
      i, j : SInt32;
      c    : AnsiChar;
      P    : PAnsiChar;
  begin
    //-- don't take in account the leading 0's (if any)
    c := (T+Index)^;
    while (Count > 0) and ((c = '0') or (c = gcDigitSeparator)) do
    begin
      Inc(Index);
      Dec(Count);
      c := (T+Index)^;
    end;
    if Count = 0 then Exit;

    SetLength(IPart,Count); // oversize
    P := PAnsiChar(IPart); // alias
    j := 0;
    for i := Index to Index+Count-1 do
    begin
      c := (T+i)^;
      if c <> gcDigitSeparator then
      begin
        (P+j)^ := c;
        Inc(j);
      end;
    end;
    if j < Count then SetLength(IPart,j); // adjust size
  end;
  //--------------------------------------------------------------------------
  procedure SetFPart;
    var
      i, j : SInt32;
      c    : AnsiChar;
      P    : PAnsiChar;
  begin
    //-- don't take in account the trailing 0's (if any)
    j := Index + Count - 1;
    c := (T+j)^;
    while (Count > 0) and ((c = '0') or (c = gcDigitSeparator)) do
    begin
      Dec(Count);
      Dec(j);
      c := (T+j)^;
    end;
    if Count = 0 then Exit;

    SetLength(FPart,Count); // oversize
    P := PAnsiChar(FPart); // alias
    j := 0;
    for i := Index to Index+Count-1 do
    begin
      c := (T+i)^;
      if c <> gcDigitSeparator then
      begin
        (P+j)^ := c;
        Inc(j);
      end;
    end;
    if j < Count then SetLength(FPart,j); // adjust size
  end;
  //--------------------------------------------------------------------------
  procedure SetEPart;
  begin
    EPart := Copy(S,Index+1,Count);
  end;
  //--------------------------------------------------------------------------

begin
  //-- default value (0)
  with Data do
  begin
    Significand := '';
    SignFlag := 0;
    Exponent := 0;
    Base := 10;
  end;

  if Length(S) = 0 then
  begin
    Result := -1; // S is empty, there is no error position
    Exit;
  end;

  Base := 10; // default value
  IPart := '';
  FPart := '';
  EPart := '';

  Result := 0; // let's suppose that all is right
  T := PAnsiChar(S); // alias

  NewState := 1;
  i := -1;
  repeat
    Inc(i);
    OldState := NewState;
    NewState := TransitionTable[GetCodeChar((T+i)^),OldState];
    case ActionTable[OldState,NewState] of
      0: begin
           Result := i + 1;  // error, exit with error position (in S)
           Exit;
         end;
      1: Data.SignFlag := Ord((T+i)^ = '-');
      2: begin
           Index := i;
           Count := 1;
         end;
      3: Inc(Count);
      4: try
           SetBase;
           Data.Base := Base;
         except
           Result := i + 1;  // error
           Exit;
         end;
      5: SetIPart;
      6: SetFPart;
      7: Base := 10;
      8: SetEPart;
      9: begin
           SetIPart;
           Base := 10;
         end;
     10: begin
           SetFPart;
           Base := 10;
         end;
     11: Break;
     12: begin
           SetIPart;
           Break;
         end;
     13: begin
           SetFPart;
           Break;
         end;
     14: begin
           SetEPart;
           Break;
         end;
    end;
  until false;

  Data.Significand := IPart + FPart;

  //-- possible because all non significant 0's were suppressed
  if Length(Data.Significand) = 0 then
  begin
    Data.Significand := '0';
    Data.SignFlag := 0; // would be ok without this instruction but...
    Exit;
  end;

  //-- suppress possible leading 0's when IPart is empty
  //   !!! SHOULD NOT MODIFY FPart (Data.Exponent may have to be modified)
  if Length(IPart) = 0 then
  begin
    T := PAnsiChar(FPart); // alias
    i := 0;
    while T^ = '0' do
    begin
      Inc(i);
      Inc(T);
    end;
    if i > 0 then
      with Data do Significand := Copy(Significand,i+1,Length(Significand)-i);
  end;

  //-- compute exponent (error if e is not a 32-bit signed integer)
  e := 0;
  try
    if Length(EPart) > 0 then
    begin
      T := PAnsiChar(EPart); // alias
      case T^ of
        '+': esign := false;
        '-': esign := true;
        else
        esign := false;
        e := Ord(T^) - Ord('0');
      end;
      for i := 1 to Length(EPart)-1 do
      begin
        Inc(T);
        {$Q+}
        e := e * 10 + Ord(T^) - Ord('0');
        {$Q-}
      end;
      {$Q+}
      if esign then e := -e;
      {$Q-}
    end;
    {$Q+}
    e := e - Length(FPart);
    {$Q-}
  except
    Result := Length(S); // error
    Exit;
  end;
  Data.Exponent := e;
end;

//==============================================================================
// Insert digit separators counting from the right (the end) of the string
// -> S, string without separators
// -> BlockLength > 0, to insert a separator every BlockLength character(s)
//    If BlockLength <= 0, the function returns S as it is
// -> LeftPadded, to pad the most left block with non significant 0s
// <- Result, equal to S + separators (possibly leftpadded with 0s)
//==============================================================================
function NXInsertSeparatorsFromRight(
           const S           : AnsiString;
                 BlockLength : SInt32;
                 LeftPadded  : Boolean): AnsiString;
  var
    P, Q                : PAnsiChar;
    Len, NewLen, Pad, i : SInt32;
begin
  if BlockLength <= 0 then
  begin
    Result := S;
    Exit;
  end;

  Len := Length(S);
  if Len = 0 then
  begin
    Result := '';
    Exit;
  end;

  Q := PAnsiChar(S);
  Inc(Q,Len);

  ASSERT(Q^ = #0);

  if LeftPadded then
  begin
    Pad := BlockLength - (Len mod BlockLength);
    if Pad = BlockLength then Pad := 0;
  end
  else Pad := 0;
  NewLen := Pad + Len + (Len-1) div BlockLength;
  SetLength(Result,NewLen);
  P := PAnsiChar(Result) + NewLen;

  ASSERT(P^ = #0);

  //-- move the characters, one by one
  i := BlockLength;
  Dec(BlockLength);
  while Len > 0 do
  begin
    if i > 0 then Dec(i)
    else
    begin
      Dec(P);
      P^ := gcDigitSeparator; // insert a separator
      i := BlockLength;
    end;
    Dec(Q);
    Dec(P);
    P^ := Q^; // copy a character
    Dec(Len);
  end;

  //-- fill up with 0's (if need be)
  while Pad > 0 do
  begin
    Dec(P);
    P^ := '0';
    Dec(Pad);
  end;

  ASSERT((P+NewLen)^ = #0);
end;

//==============================================================================
// Return a "base-2" (binary) string representing P^[]
// The size of P^[] should be Count 32-bit words (at least)
//==============================================================================
function RawToBase2Str(P: PUInt32Frame; Count: SInt32): AnsiString;
  var
    T    : PAnsiChar;
    i, j : SInt32;
    D    : UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  if Count = 0 then
  begin
    Result := '0';
    Exit;
  end;

  ASSERT(P^[Count-1] <> 0);

  //-- length of the resulting string
  i := (Count-1) shl 5 + BitSize(P^[Count-1]);
  SetLength(Result,i);
  T := PAnsiChar(Result) + i; // alias, T points to the end of Result

  //-- all 32-bit words except the leading one
  for i := 0 to Count-2 do
  begin
    D := P^[i];
    for j := 3 downto 0 do
    begin
      //-- set 8 base-2 digits
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
      Dec(T); T^ := gcHexaFigures[D and 1]; D := D shr 1;
    end;
  end;

  //-- leading 32-bit word
  D := P^[Count-1];
  repeat
    Dec(T);
    T^ := gcHexaFigures[D and 1];
    D := D shr 1;
  until D = 0;
end;

//==============================================================================
// Return a "base-4" string representing P^[]
// The size of P^[] should be Count 32-bit words (at least)
//==============================================================================
function RawToBase4Str(P: PUInt32Frame; Count: SInt32): AnsiString;
  var
    T    : PAnsiChar;
    i, j : SInt32;
    D    : UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  if Count = 0 then
  begin
    Result := '0';
    Exit;
  end;

  ASSERT(P^[Count-1] <> 0);

  //-- length of the resulting string
  i := (Count-1) shl 4 + (BitSize(P^[Count-1]) + 1) shr 1;
  SetLength(Result,i);
  T := PAnsiChar(Result) + i; // alias, T points to the end of Result

  //-- all 32-bit words except the leading one
  for i := 0 to Count-2 do
  begin
    D := P^[i];
    for j := 1 downto 0 do
    begin
      //-- set 8 base-4 digits
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
      Dec(T); T^ := gcHexaFigures[D and 3]; D := D shr 2;
    end;
  end;

  //-- leading 32-bit word
  D := P^[Count-1];
  repeat
    Dec(T);
    T^ := gcHexaFigures[D and 3];
    D := D shr 2;
  until D = 0;
end;

//==============================================================================
// Return a "base-8" (octal) string representing P^[]
// The size of P^[] should be Count 32-bit words (at least)
//==============================================================================
function RawToBase8Str(P: PUInt32Frame; Count: SInt32): AnsiString;
  var
    T               : PAnsiChar;
    Len, i, j, k, m : SInt32;
    D               : UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  if Count = 0 then
  begin
    Result := '0';
    Exit;
  end;

  ASSERT(P^[Count-1] <> 0);

  //-- length of the resulting string
  Len := ((Count-1) shl 5 + BitSize(P^[Count-1]) + 2) div 3;
  SetLength(Result,Len);
  T := PAnsiChar(Result) + Len; // alias, T points to the end of Result

  //-- all 32-bit words
  m := 0;
  for i := 0 to Len - 1 do
  begin
    //-- extract 3 bits
    j := m shr 5; // the word #j contains the bit #m
    k := m and 31;
    if ((m+3) and 31) > k then // need only one 32-bit word
      if j < Count then D := (P^[j] shr k) and 7
      else D := 0
    else // need two 32-bit words
    if (j+1) < Count then D := ((P^[j] shr k) or (P^[j+1] shl (32-k))) and 7
    else
    if (j+1) = Count then D := (P^[j] shr k) and 7
    else D := 0;

    Dec(T);
    T^ := gcHexaFigures[D];
    Inc(m,3);
  end;
end;

//==============================================================================
// Return a "base-10" string representing P^[]
// The size of P^[] should be Count 32-bit words (at least)
// !!! P^[] is modified (filled up with Count 0's)
//==============================================================================
function RawToBase10Str(P: PUInt32Frame; Count: SInt32): AnsiString;
  const MARK = AnsiChar('?');
  var
    T    : PAnsiChar;
    D, R : UInt32;
    s, i : SInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  if Count = 0 then
  begin
    Result := '0';
    Exit;
  end;

  ASSERT(P^[Count-1] <> 0);

  s := NXEstimateDecimalSize(RawBitCount(P,Count));
  SetLength(Result,s);
  T := PAnsiChar(Result); // alias
  T^ := MARK; // to check whether the estimated size is ok or too big by 1
  Inc(T,s);

  repeat
    //-- D := A mod 10**9 and A := A div 10**9
    D := RawDivUI32(P,Count,1000000000);

    if P^[Count-1] = 0 then
    begin
      //-- normalize A
      Dec(Count);
      if Count = 0 then
      begin
        //-- last remainder
        repeat
          asm
              //-- R := D mod 10, D := D div 10
              mov   ecx, 10
              xor   edx, edx
              mov   eax, D
              div   ecx
              mov   R, edx
              mov   D, eax
          end {$IFDEF FREE_PASCAL} ['EAX','ECX','EDX'] {$ENDIF};
          Dec(T);
          T^ := gcHexaFigures[R];
        until D = 0;

        Break; // exit main repeat..until loop
      end;
    end;

    //-- set 9 base-10 digits
    for i := 7 downto 0 do
    begin
      asm
          //-- R := D mod 10, D := D div 10
          mov   ecx, 10
          xor   edx, edx
          mov   eax, D
          div   ecx
          mov   R, edx
          mov   D, eax
      end {$IFDEF FREE_PASCAL} ['EAX','ECX','EDX'] {$ENDIF};
      Dec(T);
      T^ := gcHexaFigures[R];
    end;
    ASSERT(D < 10);
    Dec(T);
    T^ := gcHexaFigures[D];
  until false;

  //-- suppress the mark (if need be)
  if Result[1] = MARK then Delete(Result,1,1);
end;

//==============================================================================
// Return a "base-16" (hexadecimal) string representing P^[]
// The size of P^[] should be Count 32-bit words (at least)
//==============================================================================
function RawToBase16Str(P: PUInt32Frame; Count: SInt32): AnsiString;
  var
    T : PAnsiChar;
    i : SInt32;
    D : UInt32;
begin
  //-- require
  ASSERT((Count and $FE000000) = 0); // Count in 0..2**25-1?

  if Count = 0 then
  begin
    Result := '0';
    Exit;
  end;

  ASSERT(P^[Count-1] <> 0);

  //-- length of the resulting string
  i := (Count-1) shl 3 + (BitSize(P^[Count-1]) + 3) shr 2;
  SetLength(Result,i);
  T := PAnsiChar(Result) + i; // alias, T points to the end of Result

  //-- all 32-bit words except the leading one
  for i := 0 to Count-2 do
  begin
    D := P^[i];
    //-- set 8 base-16 digits
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D and 15]; D := D shr 4;
    Dec(T); T^ := gcHexaFigures[D];
  end;

  //-- leading 32-bit word
  D := P^[Count-1];
  repeat
    Dec(T);
    T^ := gcHexaFigures[D and 15];
    D := D shr 4;
  until D = 0;
end;

////////////////////////////////////////////////////////////////////////////////
end.
////////////////////////////////////////////////////////////////////////////////

