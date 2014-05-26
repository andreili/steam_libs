////////////////////////////////////////////////////////////////////////////////
// CONDITIONAL SYMBOLS AND COMPILER DIRECTIVES FOR THE NX LIBRARY
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
{$IFNDEF NX_HAS_SYMBOLS}
{$DEFINE NX_HAS_SYMBOLS}
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// THE FOLLOWING SYMBOLS MAY BE [UN]DEFINED
//
////////////////////////////////////////////////////////////////////////////////

{$DEFINE NX_DEBUG}
{.$DEFINE NX_CHECKS}

{.$DEFINE NX_THREAD_SAFE}
{$DEFINE NX_USE_INLINE}
{.$DEFINE NX_USE_HEAPTRACE} // for FREE PASCAL only

//
// In case a very old processor is used, undefine the following symbol
//
{$DEFINE NX_BSWAP_SUPPORTED} // use the asm BSWAP instruction

////////////////////////////////////////////////////////////////////////////////
//
// THE FOLLOWING SYMBOLS AND DIRECTIVES SHOULDN'T BE MODIFIED (EXCEPT THE ONE
// ENABLING FPC VERSIONS HIGHER THAN 2.0.4)
//
////////////////////////////////////////////////////////////////////////////////

{$DEFINE NX_VERSION_0_32_3}

{$IFDEF FPC}
  {$DEFINE FREE_PASCAL}
{$ELSE}
  {$DEFINE DELPHI}
{$ENDIF}

{$IFDEF FREE_PASCAL} ///////////////////////////////////////////////////////////

  {$IFNDEF CPUI386}
    {$MESSAGE FATAL 'NX requires i386 processors'}
  {$ENDIF}

  //
  // Do not try FPC versions below 2.0.4, the crash is (almost) guaranteed.
  //

  {$IFDEF VER2_0_4}
    {$DEFINE HAS_QWORD_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}

  {$IFDEF VER2_0_5}
    {$DEFINE HAS_QWORD_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}

  {$IFDEF VER2_1_4}
    {$DEFINE HAS_QWORD_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}

  {$IFDEF VER2_2_0}
    {$DEFINE HAS_UINT64_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}

  {$IFDEF VER2_2_2}
    {$DEFINE HAS_UINT64_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}

  {$IFDEF VER2_2_4}
    {$DEFINE HAS_UINT64_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}

  //
  // Add here FPC versions higher than 2.2.0 (unchecked but they should work)
  //
  (*
  {$IFDEF VER2_?_?}
    {$DEFINE HAS_UINT64_TYPE}
    {$DEFINE FPC_VERSION_OK}
  {$ENDIF}
  *)

  {$IFNDEF FPC_VERSION_OK}
    {$MESSAGE FATAL 'NX cannot run with this Free Pascal version'}
  {$ENDIF}

  {$DEFINE HAS_DEPRECATED}
  {$DEFINE HAS_INLINE}

{$ENDIF} // FREE_PASCAL ////////////////////////////////////////////////////////

{$IFDEF DELPHI} ////////////////////////////////////////////////////////////////

  {$IFNDEF WIN32}
    {$MESSAGE FATAL 'NX requires DELPHI for Win32'}
  {$ENDIF}

  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion >= 18.0} // D10 aka D2006 (VER180) and higher
      {$DEFINE HAS_ABSTRACT_CLASS}
      {$DEFINE HAS_DEPRECATED}
      {$DEFINE HAS_INLINE}
      {$DEFINE HAS_RECORD_WITH_PRIVATE_FIELDS}
      {$DEFINE HAS_SEALED_CLASS}
      {$DEFINE HAS_UINT64_TYPE}
      {$DEFINE HAS_UNSAFE}
      {$DEFINE DELPHI_VERSION_OK}

    //
    // Delphi versions other than 5 and 10:
    // I have no compilers in order to check them, so if you get problems
    // when running NX with these Delphi versions, thanks to let me know.
    // See http://www.ellipsa.eu/public/misc/contact.html to get the current
    // email address.
    //

    {$ELSEIF CompilerVersion >= 17.0} // D9 aka D2005 (VER170)
      {$DEFINE HAS_ABSTRACT_CLASS}
      {$DEFINE HAS_DEPRECATED}
      {$DEFINE HAS_INLINE}
      {$DEFINE HAS_RECORD_WITH_PRIVATE_FIELDS}
      {$DEFINE HAS_SEALED_CLASS}
      {$DEFINE HAS_UINT64_TYPE}
      {$DEFINE HAS_UNSAFE}
      {$DEFINE DELPHI_VERSION_OK}

    {$ELSEIF CompilerVersion >= 16.0} // D8 (VER160)
      // Delphi 8 is for .NET only

    {$ELSEIF CompilerVersion >= 15.0} // D7 (VER150)
      {$DEFINE HAS_DEPRECATED}
      {$DEFINE HAS_UINT64_TYPE}
      {$DEFINE HAS_UNSAFE}
      {$DEFINE DELPHI_VERSION_OK}

    {$ELSEIF CompilerVersion >= 14.0} // D6 (VER140)
      {$DEFINE HAS_DEPRECATED}
      {$DEFINE DELPHI_VERSION_OK}

    {$IFEND}
  {$ENDIF} // CONDITIONALEXPRESSIONS

  {$IFDEF VER130} // D5
    {$DEFINE DELPHI_VERSION_OK}
    {$DEFINE DELPHI_5}
  {$ENDIF}

  {$IFNDEF DELPHI_VERSION_OK}
    {$MESSAGE FATAL 'NX cannot run with this Delphi version'}
  {$ENDIF}

  {$IFDEF HAS_UNSAFE}
    {$WARN UNSAFE_TYPE OFF}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_CAST OFF}
  {$ENDIF}

  {$A+}                    // align record fields on 4 or 8-byte boundaries
  {$H+}                    // long strings
  {$O+}                    // optimizations on
  {$REALCOMPATIBILITY OFF} // "Real" should be "Double"
  {$X+}                    // extended syntax

{$ENDIF} // DELPHI /////////////////////////////////////////////////////////////

{$IFDEF HAS_INLINE}
  {$IFDEF NX_USE_INLINE}
    {$INLINE ON}
  {$ELSE}
    {$UNDEF HAS_INLINE}
  {$ENDIF}
{$ENDIF}

{$IFDEF NX_DEBUG}
  {$C+} // assertions
  {$D+} // debug infos
  {$Q+} // overflow checks
  {$R+} // range checks
  {$S+} // check stack overflow
  {$W+} // stackframes
{$IFDEF DELPHI}
  {$L+} // local symbols
  {$Y+} // definition infos
{$ENDIF}
{$ELSE} // NX_DEBUG
  {$C-}
  {$D-}
  {$Q-}
  {$R-}
  {$S-}
  {$W-}
{$IFDEF DELPHI}
  {$L-}
  {$Y-}
{$ENDIF}
{$ENDIF} // NX_DEBUG

{$B-} // partial boolean evaluation (useless with FREE_PASCAL defined)
{$I-} // I/O checks

//
//
// For my own use ;-)
// Won't work with low Delphi versions
//
{.$DEFINE NX_LOCATE_TODO_NOTES}

////////////////////////////////////////////////////////////////////////////////
{$ENDIF} // NX_HAS_SYMBOLS
////////////////////////////////////////////////////////////////////////////////

