////////////////////////////////////////////////////////////////////////////////
// Error Management
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
unit nx_errors;

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$H+}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
interface
{$I nx_symbols.inc}
uses
  err,
  nx_types;
////////////////////////////////////////////////////////////////////////////////


type
  ENXError = class(Exception);
  ENXAbort = class(ENXError);
  ENXCompError = class(ENXError);
  ENXDivByZero = class(ENXError);
  ENXDuplicatePtr = class(ENXError);
  ENXFileError = class(ENXError);
  ENXIntOverflow = class(ENXError);
  ENXInvalidArg = class(ENXError);
  ENXInvalidCall = class(ENXError);
  ENXOverflow = class(ENXError);
  ENXRangeError = class(ENXError);
  ENXSizeError = class(ENXError);
  ENXStreamError = class(ENXError);
  ENXUnderflow = class(ENXError);

procedure NXAbort;
procedure NXError(const Msg: string);
procedure NXRaiseCompError(const Caller,Why: ShortString); overload;
procedure NXRaiseCompError(const ClassName,Caller,Why: ShortString); overload;
procedure NXRaiseDivByZero(const Caller: ShortString); overload;
procedure NXRaiseDivByZero(const ClassName,Caller:  ShortString); overload;
procedure NXRaiseDuplicatePtr(const Caller,PtrNames: ShortString); overload;
procedure NXRaiseDuplicatePtr(
            const ClassName,Caller,PtrNames: ShortString); overload;
procedure NXRaiseFileError(
            const Caller: ShortString;
            const FileName: string); overload;
procedure NXRaiseFileError(
            const ClassName,Caller: ShortString;
            const FileName: string); overload;
procedure NXRaiseIntOverflow(const Caller: ShortString); overload;
procedure NXRaiseIntOverflow(const ClassName,Caller: ShortString); overload;
procedure NXRaiseInvalidArg(const Caller,Why: ShortString); overload;
procedure NXRaiseInvalidArg(const ClassName,Caller,Why: ShortString); overload;
procedure NXRaiseInvalidCall(const Caller,Why: ShortString); overload;
procedure NXRaiseInvalidCall(const ClassName,Caller,Why: ShortString); overload;
procedure NXRaiseOverflow(const Caller: ShortString); overload;
procedure NXRaiseOverflow(const ClassName,Caller: ShortString); overload;
procedure NXRaiseRangeError(const Caller: ShortString); overload;
procedure NXRaiseRangeError(const ClassName,Caller: ShortString); overload;
procedure NXRaiseSizeError(const Caller: ShortString); overload;
procedure NXRaiseSizeError(const ClassName,Caller: ShortString); overload;
procedure NXRaiseStreamError(const Caller: ShortString); overload;
procedure NXRaiseStreamError(const ClassName,Caller: ShortString); overload;
procedure NXRaiseUnderflow(const Caller: ShortString); overload;
procedure NXRaiseUnderflow(const ClassName,Caller: ShortString); overload;

//-- ancestor of all NX classes requiring exceptions (shouldn't be instanciated)
type
{$IFDEF HAS_ABSTRACT_CLASS}
  TNXClassWithExceptions = class abstract (TNXClass)
{$ELSE}
  TNXClassWithExceptions = class (TNXClass)
{$ENDIF}
  protected
    procedure RaiseCompError(const Caller,Why: ShortString);
    procedure RaiseDivByZero(const Caller: ShortString);
    procedure RaiseFileError(const Caller: ShortString; const FileName: string);
    procedure RaiseInvalidArg(const Caller,Why: ShortString);
    procedure RaiseInvalidCall(const Caller,Why: ShortString);
    procedure RaiseRangeError(const Caller: ShortString);
    procedure RaiseSizeError(const Caller: ShortString);
    procedure RaiseStreamError(const Caller: ShortString);
  end;

//-- error messages
const
  esA_eq_0 = 'A = 0';
  esA_cannot_be_monic = 'A cannot be monic';
  esA_is_even = 'A is even';
  esA_is_not_a_cube = 'A is not a cube';
  esA_is_not_a_qr_modulo_P = 'A is not a quadratic residue modulo P';
  esA_is_not_a_square = 'A is not a square';
  esA_is_not_irreducible = 'A is not irreducible';
  esA_is_not_monic = 'A is not monic';
  esA_le_0 = 'A <= 0';
  esA_le_B = 'A <= B';
  esA_lt_0 = 'A < 0';
  esA_lt_1 = 'A < 1';
  esA_lt_2 = 'A < 2';
  esA_ne_1_mod_8 = 'A <> 1 (mod 8)';
  esA4_and_A6_cannot_be_both_nil = 'A4 and A6 cannot be both nil';
  esA4_and_A6_cannot_be_both_false = 'A4 and A6 cannot be both false';
  esAbse_is_not_in_0_gcMaxBigRealExponent =
    '|e| is not in 0..gcMaxBigRealExponent';

  esB_is_even = 'B is even';
  esB_lt_0 = 'B < 0';
  esB_lt_1 = 'B < 1';
  esB_lt_2 = 'B < 2';
  esB_lt_3 = 'B < 3';
  esB_is_not_irreducible = 'B is not irreducible';
  esB_is_not_monic = 'B is not monic';
  esBase_is_not_in_2_4_8_10_16 = 'Base is not in [2,4,8,10,16]';
  esBase_is_not_in_2_16 = 'Base is not in [2,16]';
  esBase_is_not_in_3_9 = 'Base is not in [3,9]';
  esBase_lt_2 = 'Base < 2';
  esBitCount_is_not_in_0_gcMaxBigIntBitSize =
    'BitCount is not in 0..gcMaxBigIntBitSize';
  esBitCount_is_not_in_BitSizeA_gcMaxBigIntBitSize =
    'BitCount is not in BitSize(A)..gcMaxBigIntBitSize';
  esBitCount_lt_1 = 'BitCount < 1';
  esBound_lt_2 = 'Bound < 2';

  esCannot_finalize_a_non_running_object =
    'Cannot finalize a non running object';
  esCannot_initialize_a_running_object =
    'Cannot initialize a running object';
  esCannot_update_a_non_running_object =
    'Cannot update a non running object';
  esConstant_term_ne_1 = 'Constant term different from 1';
  esCount_is_not_in_0_203280221 = 'Count is not in 0..203280221';
  esCount_is_not_in_0_32 = 'Count is not in 0..32';
  esCount_is_not_in_0_Degree_A = 'Count is not in 0..Degree(A)';
  esCount_lt_1 = 'Count < 1';
  esCurve_without_coefficients = 'Curve without coefficients';
  esCurve_without_field = 'Curve without field';

  esD_eq_0 = 'D = 0';
  esD_le_0 = 'D <= 0';
  esDegreeA_ge_field_degree = 'Degree(A) >= field degree';
  esDegreeA_ne_3 = 'Degree(A) <> 3';
  esDegreeB_ge_field_degree = 'Degree(B) >= field degree';
  esDegreeB_le_0 = 'Degree(B) <= 0';
  esDegreeP_gt_gcMaxGF2NFieldDegree = 'Degree(P) > gcMaxGF2NFieldDegree';
  esDegreeP_gt_gcMaxGF3NFieldDegree = 'Degree(P) > gcMaxGF3NFieldDegree';
  esDegreeP_lt_2 = 'Degree(P) < 2';
  esDegreeP_should_divide_the_field_degree =
    'Degree(P) should divide the field degree';
  esDegreeR_ge_field_degree = 'Degree(R) >= field degree';
  esDisc_is_not_in_m11_m7_m3_m2_m1_2_3_5_13 =
    'Disc is not in [-11,-7,-3,-2,-1,2,3,5,13]';
  esDisc_is_not_squarefree = 'Disc is not squarefree';
  esDummyBits_lt_0 = 'DummyBits < 0';

  esE_lt_0 = 'E < 0';
  ese_lt_1 = 'e < 1';
  esEmpty_list = 'Empty list';
  esEmpty_matrix = 'Empty matrix';
  esExponent_lt_0 = 'Exponent < 0';

  esFailed_inversion = 'Failed inversion';
  esField_BasisType_ne_btPolynomial = 'Field.BasisType <> btPolynomial';
  esField_degrees_not_eq = 'Field degrees not equal';
  esField_not_created_with_a_normal_basis =
    'Field not created with a normal basis';
  esField_polynomial_degree_not_odd = 'Field polynomial degree not odd';
  esField_polynomial_should_be_monic = 'Field polynomial should be monic';
  esFirst_le_0 = 'First <= 0';

  esGCD_Residue_Modulus_ne_1 = 'GCD(Residue,Modulus) <> 1';

  esIndex_lt_0 = 'Index < 0';
  esInexact_division = 'Inexact division';
  esInvalid_A2_coefficient = 'Invalid A2 coefficient';
  esInvalid_A6_coefficient = 'Invalid A6 coefficient';
  esInvalid_AX_coefficient = 'Invalid AX coefficient';
  esInvalid_array_size = 'Invalid array size';
  esInvalid_Basis_value = 'Invalid Basis value';
  esInvalid_coefficients = 'Invalid coefficients';
  esInvalid_Count_value = 'Invalid Count value';
  esInvalid_decimal_part = 'Invalid decimal part';
  esInvalid_degrees = 'Invalid degrees';
  esInvalid_discriminant = 'Invalid discriminant';
  esInvalid_DivType_value = 'Invalid DivType value';
  esInvalid_modulus = 'Invalid modulus';
  esInvalid_parameter = 'Invalid parameter';
  esInvalid_p_value = 'Invalid p value';
  esInvalid_polynomial = 'Invalid polynomial';
  esInvalid_polynomial_array = 'Invalid polynomial array';
  esInvalid_rational = 'Invalid rational';
  esInvalid_resulting_polynomial = 'Invalid resulting polynomial';
  esInvalid_resulting_value = 'Invalid resulting value';
  esInvalid_root_R = 'Invalid root R';
  esInvalid_root_type_value = 'Invalid resulting RootType value';
  esInvalid_RoundingMode_value = 'Invalid RoundingMode value';
  esInvalid_Separator_value = 'Invalid Separator value';
  esInvalid_Shift_value = 'Invalid Shift value';

  esk_eq_0 = 'k = 0';
  esk_is_not_in_0_gcMaxBigIntBitSize = 'k is not in 0..gcMaxBigIntBitSize';
  esk_is_not_in_0_gcMaxBigRealExponent = 'k is not in 0..gcMaxBigRealExponent';
  esk_is_not_in_3_gcMaxBigIntBitSize = 'k is not in 3..gcMaxBigIntBitSize';
  esk_is_not_in_m65536_65536 = 'k is not in -65536..65536';
  esk_lt_0 = 'k < 0';

  esM_lt_0 = 'M < 0';
  esMatrix_sizes_do_not_match = 'Matrix sizes do not match';
  esMi_lt_2 = 'M[%d] < 2';
  esMin_gt_Max = 'Min > Max';
  esModuli_are_not_coprime = 'Moduli are not coprime';

  esN_lt_3 = 'N < 3';
  esN_lt_K = 'N < K';
  esNo_nqr_lt_2pow32 = 'No non quadratic residue less than 2**32';
  esNon_integer_result = 'Non integer result';
  esNon_irreducible_field_polynomial = 'Non irreducible field polynomial (!?)';
  esNon_square_matrix = 'Non square matrix';

  esP_eq_0 = 'P = 0';
  esP_is_a_square = 'P is a square';
  esP_is_composite = 'P is composite';
  esP_is_not_an_odd_prime = 'P is not an odd prime';
  esP_is_not_irreducible = 'P is not irreducible';
  esP_is_not_normal = 'P is not normal';
  esP_is_not_prime = 'P is not prime';
  esP_is_presumably_composite = 'P is presumably composite';
  esP_lt_0 = 'P < 0';
  esP_lt_2 = 'P < 2';
  esPolynomial_degree_ge_matrix_size = 'Polynomial degree >= matrix size';

  esQ_eq_0 = 'Q = 0';

  esR_is_empty = 'R is empty';
  esRep_lt_0 = 'Rep < 0';
  esResidue_ge_Modulus = 'Residue >= Modulus';

  esSelf_Count_ne_L_Count = 'Self.Count <> L.Count';
  esSelf_has_not_been_created_with_a_normal_basis =
    'Self has not been created with a normal basis';
  esShift_is_not_in_0_gcMaxBigIntBitSize =
    'Shift is not in 0..gcMaxBigIntBitSize';
  esSize_R_ne_Size_M = 'Size(R) <> Size(M)';
  esSyntax_error = 'Syntax error';
  esSyntax_error_pos = 'Syntax error (position=%d)';

  esValue_eq_0_mod_3 = 'Value = 0 (mod 3)';
  esValue_out_of_range = 'Value out of range';
  esVector_sizes_do_not_match = 'Vector sizes do not match';

  esX_and_Mi = 'X and M[%d]';
  esX_and_Ri = 'X and R[%d]';
  esX_eq_1 = 'X = 1';
  esX_is_not_in_cm1_1c = 'X is not in [-1, 1]';
  esX_is_not_in_om1_1o = 'X is not in ]-1, 1[';
  esX_le_0 = 'X <= 0';
  esX_lt_0 = 'X < 0';
  esX_lt_1 = 'X < 1';

  esY_is_NaN_or_INF = 'Y is NaN or INF';
  esY_lt_0 = 'Y < 0';

{$IFDEF NX_THREAD_SAFE}
{$IFDEF NX_DEBUG}
  esStack_not_initialized = 'Stack not initialized';
  esRandom_generator_not_initialized = 'Random generator not initialized';
{$ENDIF}
{$ENDIF}


////////////////////////////////////////////////////////////////////////////////
implementation
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// LOCAL
////////////////////////////////////////////////////////////////////////////////

const
  //-- End Of Line
{$IFDEF FREE_PASCAL}
  ucEOL = LineEnding;
{$ENDIF}
{$IFDEF DELPHI}
  ucEOL = #13#10;
{$ENDIF}

const
  esAbort        = 'Computation aborted';
  esCompError    = '%s' + ucEOL + 'Computation error' + ucEOL + '%s';
  esDivByZero    = '%s' + ucEOL + 'Division by 0';
  esDuplicatePtr = '%s' + ucEOL + '%s must point to distinct objects';
  esFileError    = '%s' + ucEOL + 'Invalid "%s" file';
  esInvalidArg   = '%s' + ucEOL + 'Invalid parameter' + ucEOL + '%s';
  esInvalidCall  = '%s' + ucEOL + 'Invalid call' + ucEOL + '%s';
  esOverflow     = '%s' + ucEOL + 'Overflow';
  esRangeError   = '%s' + ucEOL + 'Range check error';
  esSizeError    = '%s' + ucEOL + 'Invalid size specification';
  esStreamError  = '%s' + ucEOL + 'Invalid stream';
  esUnderflow    = '%s' + ucEOL + 'Underflow';

////////////////////////////////////////////////////////////////////////////////
// PUBLIC
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Raise an ENXAbort exception
//==============================================================================
procedure NXAbort;
begin
  raise ENXAbort.Create(e_Abort, esAbort);
end;

//==============================================================================
// Raise an ENX exception with the message Msg
//==============================================================================
procedure NXError(const Msg: string);
begin
  raise ENXError.Create(e_InvalidOp, Msg);
end;

//==============================================================================
// Overloaded
// Raise an ENXCompError exception
//==============================================================================
procedure NXRaiseCompError(const Caller,Why: ShortString);
begin
  raise ENXCompError.CreateFmt(e_Custom, esCompError,[Caller,Why]);
end;

//==============================================================================
// Overloaded
// Raise an ENXCompError exception
//==============================================================================
procedure NXRaiseCompError(const ClassName,Caller,Why: ShortString);
begin
  raise ENXCompError.CreateFmt(e_Custom, esCompError,[ClassName + '.' + Caller,Why]);
end;

//==============================================================================
// Overloaded
// Raise an ENXDivByZero exception
//==============================================================================
procedure NXRaiseDivByZero(const Caller: ShortString);
begin
  raise ENXDivByZero.CreateFmt(e_DivBy0, esDivByZero,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXDivByZero exception
//==============================================================================
procedure NXRaiseDivByZero(const ClassName,Caller: ShortString);
begin
  raise ENXDivByZero.CreateFmt(e_DivBy0, esDivByZero,[ClassName + '.' + Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXDuplicatePtr exception
//==============================================================================
procedure NXRaiseDuplicatePtr(const Caller,PtrNames: ShortString);
begin
  raise ENXDuplicatePtr.CreateFmt(e_Custom, esDuplicatePtr,[Caller,PtrNames]);
end;

//==============================================================================
// Overloaded
// Raise an ENXDuplicatePtr exception
//==============================================================================
procedure NXRaiseDuplicatePtr(const ClassName,Caller,PtrNames: ShortString);
begin
  raise ENXDuplicatePtr.CreateFmt(e_Custom, esDuplicatePtr,
                                  [ClassName + '.' + Caller,PtrNames]);
end;

//==============================================================================
// Overloaded
// Raise an ENXFileError exception
//==============================================================================
procedure NXRaiseFileError(const Caller: ShortString; const FileName: string);
begin
  raise ENXFileError.CreateFmt(e_Custom, esFileError,[Caller,FileName]);
end;

//==============================================================================
// Overloaded
// Raise an ENXFileError exception
//==============================================================================
procedure NXRaiseFileError(const ClassName,Caller : ShortString;
                           const FileName             : string);
begin
  raise ENXFileError.CreateFmt(e_Custom, esFileError,[ClassName + '.' + Caller,FileName]);
end;

//==============================================================================
// Overloaded
// Raise an ENXIntOverflow exception
//==============================================================================
procedure NXRaiseIntOverflow(const Caller: ShortString);
begin
  raise ENXIntOverflow.CreateFmt(e_IntOverflow, esOverflow,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXIntOverflow exception
//==============================================================================
procedure NXRaiseIntOverflow(const ClassName,Caller: ShortString);
begin
  raise ENXIntOverflow.CreateFmt(e_IntOverflow, esOverflow,[ClassName + '.' + Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXInvalidArg exception
//==============================================================================
procedure NXRaiseInvalidArg(const Caller,Why: ShortString);
begin
  raise ENXInvalidArg.CreateFmt(e_InvalidContainer, esInvalidArg,[Caller,Why]);
end;

//==============================================================================
// Overloaded
// Raise an ENXInvalidArg exception
//==============================================================================
procedure NXRaiseInvalidArg(const ClassName,Caller,Why: ShortString);
begin
  raise ENXInvalidArg.CreateFmt(e_InvalidContainer, esInvalidArg,[ClassName + '.' + Caller,Why]);
end;

//==============================================================================
// Overloaded
// Raise an ENXInvalidCall exception
//==============================================================================
procedure NXRaiseInvalidCall(const Caller,Why: ShortString);
begin
  raise ENXInvalidCall.CreateFmt(e_InvalidCast, esInvalidCall,[Caller,Why]);
end;

//==============================================================================
// Overloaded
// Raise an ENXInvalidCall exception
//==============================================================================
procedure NXRaiseInvalidCall(const ClassName,Caller,Why: ShortString);
begin
  raise ENXInvalidCall.CreateFmt(e_InvalidCast, esInvalidCall,[ClassName + '.' + Caller,Why]);
end;

//==============================================================================
// Overloaded
// Raise an ENXOverflow exception
//==============================================================================
procedure NXRaiseOverflow(const Caller: ShortString);
begin
  raise ENXOverflow.CreateFmt(e_Overflow, esOverflow,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXOverflow exception
//==============================================================================
procedure NXRaiseOverflow(const ClassName,Caller: ShortString);
begin
  raise ENXOverflow.CreateFmt(e_Overflow, esOverflow,[ClassName + '.' + Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXRangeError exception
//==============================================================================
procedure NXRaiseRangeError(const Caller: ShortString);
begin
  raise ENXRangeError.CreateFmt(e_Range, esRangeError,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXRangeError exception
//==============================================================================
procedure NXRaiseRangeError(const ClassName,Caller: ShortString);
begin
  raise ENXRangeError.CreateFmt(e_Range, esRangeError,[ClassName + '.' + Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXSizeError exception
//==============================================================================
procedure NXRaiseSizeError(const Caller: ShortString);
begin
  raise ENXSizeError.CreateFmt(e_Custom, esSizeError,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXSizeError exception
//==============================================================================
procedure NXRaiseSizeError(const ClassName,Caller: ShortString);
begin
  raise ENXSizeError.CreateFmt(e_Custom, esSizeError,[ClassName + '.' + Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXStreamError exception
//==============================================================================
procedure NXRaiseStreamError(const Caller: ShortString);
begin
  raise ENXStreamError.CreateFmt(e_Custom, esStreamError,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXStreamError exception
//==============================================================================
procedure NXRaiseStreamError(const ClassName,Caller: ShortString);
begin
  raise ENXStreamError.CreateFmt(e_Custom, esStreamError,[ClassName + '.' + Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXUnderflow exception
//==============================================================================
procedure NXRaiseUnderflow(const Caller: ShortString);
begin
  raise ENXUnderflow.CreateFmt(e_Underflow, esUnderflow,[Caller]);
end;

//==============================================================================
// Overloaded
// Raise an ENXUnderflow exception
//==============================================================================
procedure NXRaiseUnderflow(const ClassName,Caller: ShortString);
begin
  raise ENXUnderflow.CreateFmt(e_Underflow, esUnderflow,[ClassName + '.' + Caller]);
end;

////////////////////////////////////////////////////////////////////////////////
// TNXClassWithExceptions class
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
// Raise an ENXCompError exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseCompError(const Caller,Why: ShortString);
begin
  raise ENXCompError.CreateFmt(e_Custom, esCompError,[ClassName + '.' + Caller,Why]);
end;

//------------------------------------------------------------------------------
// Raise an ENXDivByZero exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseDivByZero(const Caller: ShortString);
begin
  raise ENXDivByZero.CreateFmt(e_DivBy0, esDivByZero,[ClassName + '.' + Caller]);
end;

//------------------------------------------------------------------------------
// Raise an ENXFileError exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseFileError(
            const Caller   : ShortString;
            const FileName : string);
begin
  raise ENXFileError.CreateFmt(e_Custom, esFileError,[ClassName + '.' + Caller,FileName]);
end;

//------------------------------------------------------------------------------
// Raise an ENXInvalidArg exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseInvalidArg(const Caller,Why: ShortString);
begin
  raise ENXInvalidArg.CreateFmt(e_InvalidPointer, esInvalidArg,[ClassName + '.' + Caller,Why]);
end;

//------------------------------------------------------------------------------
// Raise an ENXInvalidCall exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseInvalidCall(
            const Caller,Why: ShortString);
begin
  raise ENXInvalidCall.CreateFmt(e_InvalidCast, esInvalidCall,[ClassName + '.' + Caller,Why]);
end;

//------------------------------------------------------------------------------
// Raise an ENXRangeError exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseRangeError(const Caller: ShortString);
begin
  raise ENXRangeError.CreateFmt(e_Range, esRangeError,[ClassName + '.' + Caller]);
end;

//------------------------------------------------------------------------------
// Raise an ENXSizeError exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseSizeError(const Caller: ShortString);
begin
  raise ENXSizeError.CreateFmt(e_Custom, esSizeError,[ClassName + '.' + Caller]);
end;

//------------------------------------------------------------------------------
// Raise an ENXStreamError exception
//------------------------------------------------------------------------------
procedure TNXClassWithExceptions.RaiseStreamError(const Caller: ShortString);
begin
  raise ENXStreamError.CreateFmt(e_Custom, esStreamError,[ClassName + '.' + Caller]);
end;

////////////////////////////////////////////////////////////////////////////////
end.
////////////////////////////////////////////////////////////////////////////////

