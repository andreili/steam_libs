unit OS_Lib;

interface

{$I defines.inc}

uses
  Types;

//{$IFDEF WIN}
type
  {$IFDEF UNICODE}
  pChar = pWideChar;
  char = WideChar;
  {$ENDIF}
  WCHAR = WideChar;
  LPCSTR = PAnsiChar;
  LPSTR = PAnsiChar;
  LPWSTR = PWideChar;
  LPCWSTR = PWideChar;
  bool = boolean;
  pbool = ^bool;
  FARPROC = Pointer;
  ULONG_PTR = LongWord;

  uint = cardinal;
  pushort = ^ushort;
  ushort = word;

  ulong = uint;
  pulong = ^ulong;
  DWORD = ulong;
  PDWORD = ^DWORD;
  puint32 = ^uint32;
  UInt32 = UINT;
  puint16 = ^uint16;
  UInt16 = Word;
  LCID = DWORD;

  uint32_t = UInt32;
  uint16_t = UInt16;

  HWND = THANDLE;

  I64 = record
  {* 64 bit integer record. Use it and correspondent functions below in KOL
     projects to avoid dependancy from Delphi version (earlier versions of
     Delphi had no Int64 type). }
    Lo, Hi: DWORD;
  end;

  TSysCharSet = set of AnsiChar;
  TCardinalDynArray = array of ulong;
  pCardinalDynArray = ^TCardinalDynArray;

  PPointerList = ^TPointerList;
  TPointerList = array[0..MaxInt div 4 - 1] of Pointer;

  PDayTable = ^TDayTable;
  TDayTable = array[1..12] of Word;
  TDateFormat = ( dfShortDate, dfLongDate );
  {* Date formats available to use in formatting date/time to string. }
  TTimeFormatFlag = ( tffNoMinutes, tffNoSeconds, tffNoMarker, tffForce24 );
  {* Additional flags, used for formatting time. }
  TTimeFormatFlags = Set of TTimeFormatFlag;
  {* Set of flags, used for formatting time. }

const
  MonthDays: array [Boolean] of TDayTable =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
     (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));
  {* The MonthDays array can be used to quickly find the number of
    days in a month:  MonthDays[IsLeapYear(Y), M].      }

  SecsPerDay = 24 * 60 * 60;
  {* Seconds per day. }
  MSecsPerDay = SecsPerDay * 1000;
  {* Milliseconds per day. }

  VCLDate0 = 693594;
  {* Value to convert VCL "date 0" to KOL "date 0" and back.
     This value corresponds to 30-Dec-1899, 0:00:00. So,
     to convert VCL date to KOL date, just subtract this
     value from VCL date. And to convert back from KOL date
     to VCL date, add this value to KOL date.}


const
  EXCEPTION_NONCONTINUABLE     = 1;    { Noncontinuable exception }
  {$EXTERNALSYM EXCEPTION_NONCONTINUABLE}
  EXCEPTION_MAXIMUM_PARAMETERS = 15;   { maximum number of exception parameters }
  {$EXTERNALSYM EXCEPTION_MAXIMUM_PARAMETERS}

{line 1280}
  SIZE_OF_80387_REGISTERS = 80;
  {$EXTERNALSYM SIZE_OF_80387_REGISTERS}

  { The following flags control the contents of the CONTEXT structure. }

  CONTEXT_i386 = $10000;     { this assumes that i386 and }
  {$EXTERNALSYM CONTEXT_i386}
  CONTEXT_i486 = $10000;     { i486 have identical context records }
  {$EXTERNALSYM CONTEXT_i486}

  CONTEXT_CONTROL         = (CONTEXT_i386 or $00000001); { SS:SP, CS:IP, FLAGS, BP }
  {$EXTERNALSYM CONTEXT_CONTROL}
  CONTEXT_INTEGER         = (CONTEXT_i386 or $00000002); { AX, BX, CX, DX, SI, DI }
  {$EXTERNALSYM CONTEXT_INTEGER}
  CONTEXT_SEGMENTS        = (CONTEXT_i386 or $00000004); { DS, ES, FS, GS }
  {$EXTERNALSYM CONTEXT_SEGMENTS}
  CONTEXT_FLOATING_POINT  = (CONTEXT_i386 or $00000008); { 387 state }
  {$EXTERNALSYM CONTEXT_FLOATING_POINT}
  CONTEXT_DEBUG_REGISTERS = (CONTEXT_i386 or $00000010); { DB 0-3,6,7 }
  {$EXTERNALSYM CONTEXT_DEBUG_REGISTERS}
  CONTEXT_FULL = (CONTEXT_CONTROL or CONTEXT_INTEGER or CONTEXT_SEGMENTS);
  {$EXTERNALSYM CONTEXT_FULL}

type


  { System time is represented with the following structure: }
  PSystemTime = ^TSystemTime;
  _SYSTEMTIME = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  {$EXTERNALSYM _SYSTEMTIME}
  TSystemTime = _SYSTEMTIME;
  SYSTEMTIME = _SYSTEMTIME;
  {$EXTERNALSYM SYSTEMTIME}

  PFloatingSaveArea = ^TFloatingSaveArea;
  _FLOATING_SAVE_AREA = record
    ControlWord: DWORD;
    StatusWord: DWORD;
    TagWord: DWORD;
    ErrorOffset: DWORD;
    ErrorSelector: DWORD;
    DataOffset: DWORD;
    DataSelector: DWORD;
    RegisterArea: array[0..SIZE_OF_80387_REGISTERS - 1] of Byte;
    Cr0NpxState: DWORD;
  end;
  {$EXTERNALSYM _FLOATING_SAVE_AREA}
  TFloatingSaveArea = _FLOATING_SAVE_AREA;
  FLOATING_SAVE_AREA = _FLOATING_SAVE_AREA;
  {$EXTERNALSYM FLOATING_SAVE_AREA}

  { This frame has a several purposes: 1) it is used as an argument to
  NtContinue, 2) is is used to constuct a call frame for APC delivery,
  and 3) it is used in the user level thread creation routines.
  The layout of the record conforms to a standard call frame. }

  PContext = ^TContext;
  _CONTEXT = record
  {$EXTERNALSYM _CONTEXT}

  { The flags values within this flag control the contents of
    a CONTEXT record.

    If the context record is used as an input parameter, then
    for each portion of the context record controlled by a flag
    whose value is set, it is assumed that that portion of the
    context record contains valid context. If the context record
    is being used to modify a threads context, then only that
    portion of the threads context will be modified.

    If the context record is used as an IN OUT parameter to capture
    the context of a thread, then only those portions of the thread's
    context corresponding to set flags will be returned.

    The context record is never used as an OUT only parameter. }

    ContextFlags: DWORD;

  { This section is specified/returned if CONTEXT_DEBUG_REGISTERS is
    set in ContextFlags.  Note that CONTEXT_DEBUG_REGISTERS is NOT
    included in CONTEXT_FULL. }

    Dr0: DWORD;
    Dr1: DWORD;
    Dr2: DWORD;
    Dr3: DWORD;
    Dr6: DWORD;
    Dr7: DWORD;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_FLOATING_POINT. }

    FloatSave: TFloatingSaveArea;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_SEGMENTS. }

    SegGs: DWORD;
    SegFs: DWORD;
    SegEs: DWORD;
    SegDs: DWORD;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_INTEGER. }

    Edi: DWORD;
    Esi: DWORD;
    Ebx: DWORD;
    Edx: DWORD;
    Ecx: DWORD;
    Eax: DWORD;

  { This section is specified/returned if the
    ContextFlags word contians the flag CONTEXT_CONTROL. }

    Ebp: DWORD;
    Eip: DWORD;
    SegCs: DWORD;
    EFlags: DWORD;
    Esp: DWORD;
    SegSs: DWORD;
  end;
  TContext = _CONTEXT;
  CONTEXT = _CONTEXT;
  {$EXTERNALSYM CONTEXT}

  PExceptionRecord = ^TExceptionRecord;
  _EXCEPTION_RECORD = record
    ExceptionCode: DWORD;
    ExceptionFlags: DWORD;
    ExceptionRecord: PExceptionRecord;
    ExceptionAddress: Pointer;
    NumberParameters: DWORD;
    ExceptionInformation: array[0..EXCEPTION_MAXIMUM_PARAMETERS - 1] of DWORD;
  end;
  {$EXTERNALSYM _EXCEPTION_RECORD}
  TExceptionRecord = _EXCEPTION_RECORD;
  EXCEPTION_RECORD = _EXCEPTION_RECORD;
  {$EXTERNALSYM EXCEPTION_RECORD}


{ Typedef for pointer returned by exception_info() }

  _EXCEPTION_POINTERS = record
    ExceptionRecord : PExceptionRecord;
    ContextRecord : PContext;
  end;
  {$EXTERNALSYM _EXCEPTION_POINTERS}
  TExceptionPointers = _EXCEPTION_POINTERS;
  EXCEPTION_POINTERS = _EXCEPTION_POINTERS;
  {$EXTERNALSYM EXCEPTION_POINTERS}

const
{ Date Flags for GetDateFormatW. }

  {$EXTERNALSYM DATE_SHORTDATE}
  DATE_SHORTDATE = 1; { use short date picture }
  {$EXTERNALSYM DATE_LONGDATE}
  DATE_LONGDATE = 2; { use long date picture }
  {$EXTERNALSYM DATE_USE_ALT_CALENDAR}
  DATE_USE_ALT_CALENDAR = 4;   { use alternate calendar (if any) }

{ Time Flags for GetTimeFormatW. }

  {$EXTERNALSYM TIME_NOMINUTESORSECONDS}
  TIME_NOMINUTESORSECONDS = 1; { do not use minutes or seconds }
  {$EXTERNALSYM TIME_NOSECONDS}
  TIME_NOSECONDS = 2; { do not use seconds }
  {$EXTERNALSYM TIME_NOTIMEMARKER}
  TIME_NOTIMEMARKER = 4; { do not use time marker }
  {$EXTERNALSYM TIME_FORCE24HOURFORMAT}
  TIME_FORCE24HOURFORMAT = 8; { always use 24 hour format }

  DRIVE_UNKNOWN = 0;
  {$EXTERNALSYM DRIVE_UNKNOWN}
  DRIVE_NO_ROOT_DIR = 1;
  {$EXTERNALSYM DRIVE_NO_ROOT_DIR}
  DRIVE_REMOVABLE = 2;
  {$EXTERNALSYM DRIVE_REMOVABLE}
  DRIVE_FIXED = 3;
  {$EXTERNALSYM DRIVE_FIXED}
  DRIVE_REMOTE = 4;
  {$EXTERNALSYM DRIVE_REMOTE}
  DRIVE_CDROM = 5;
  {$EXTERNALSYM DRIVE_CDROM}
  DRIVE_RAMDISK = 6;
  {$EXTERNALSYM DRIVE_RAMDISK}

const
  INVALID_HANDLE_VALUE = cardinal(-1);
  MAX_PATH = 260;

{$IFDEF MSWINDOWS}
  advapi32  = 'advapi32.dll';
  kernel32  = 'kernel32.dll';
  mpr       = 'mpr.dll';
  {$EXTERNALSYM version}
  version   = 'version.dll';
  comctl32  = 'comctl32.dll';
  gdi32     = 'gdi32.dll';
  opengl32  = 'opengl32.dll';
  user32    = 'user32.dll';
  wintrust  = 'wintrust.dll';
  msimg32   = 'msimg32.dll';
{$ENDIF}
{$IFDEF LINUX}
  advapi32  = 'libwine.borland.so';
  kernel32  = 'libwine.borland.so';
  mpr       = 'libmpr.borland.so';
  version   = 'libversion.borland.so';
  {$EXTERNALSYM version}
  comctl32  = 'libcomctl32.borland.so';
  gdi32     = 'libwine.borland.so';
  opengl32  = 'libopengl32.borland.so';
  user32    = 'libwine.borland.so';
  wintrust  = 'libwintrust.borland.so';
  msimg32   = 'libmsimg32.borland.so';
{$ENDIF}

{ Primary language IDs. }

  LANG_NEUTRAL                         = $00;
  {$EXTERNALSYM LANG_NEUTRAL}
  LANG_INVARIANT                       = $7f;
  {$EXTERNALSYM LANG_INVARIANT}

  LANG_AFRIKAANS                       = $36;
  {$EXTERNALSYM LANG_AFRIKAANS}
  LANG_ALBANIAN                        = $1c;
  {$EXTERNALSYM LANG_ALBANIAN}
  LANG_ARABIC                          = $01;
  {$EXTERNALSYM LANG_ARABIC}
  LANG_BASQUE                          = $2d;
  {$EXTERNALSYM LANG_BASQUE}
  LANG_BELARUSIAN                      = $23;
  {$EXTERNALSYM LANG_BELARUSIAN}
  LANG_BULGARIAN                       = $02;
  {$EXTERNALSYM LANG_BULGARIAN}
  LANG_CATALAN                         = $03;
  {$EXTERNALSYM LANG_CATALAN}
  LANG_CHINESE                         = $04;
  {$EXTERNALSYM LANG_CHINESE}
  LANG_CROATIAN                        = $1a;
  {$EXTERNALSYM LANG_CROATIAN}
  LANG_CZECH                           = $05;
  {$EXTERNALSYM LANG_CZECH}
  LANG_DANISH                          = $06;
  {$EXTERNALSYM LANG_DANISH}
  LANG_DUTCH                           = $13;
  {$EXTERNALSYM LANG_DUTCH}
  LANG_ENGLISH                         = $09;
  {$EXTERNALSYM LANG_ENGLISH}
  LANG_ESTONIAN                        = $25;
  {$EXTERNALSYM LANG_ESTONIAN}
  LANG_FAEROESE                        = $38;
  {$EXTERNALSYM LANG_FAEROESE}
  LANG_FARSI                           = $29;
  {$EXTERNALSYM LANG_FARSI}
  LANG_FINNISH                         = $0b;
  {$EXTERNALSYM LANG_FINNISH}
  LANG_FRENCH                          = $0c;
  {$EXTERNALSYM LANG_FRENCH}
  LANG_GERMAN                          = $07;
  {$EXTERNALSYM LANG_GERMAN}
  LANG_GREEK                           = $08;
  {$EXTERNALSYM LANG_GREEK}
  LANG_HEBREW                          = $0d;
  {$EXTERNALSYM LANG_HEBREW}
  LANG_HUNGARIAN                       = $0e;
  {$EXTERNALSYM LANG_HUNGARIAN}
  LANG_ICELANDIC                       = $0f;
  {$EXTERNALSYM LANG_ICELANDIC}
  LANG_INDONESIAN                      = $21;
  {$EXTERNALSYM LANG_INDONESIAN}
  LANG_ITALIAN                         = $10;
  {$EXTERNALSYM LANG_ITALIAN}
  LANG_JAPANESE                        = $11;
  {$EXTERNALSYM LANG_JAPANESE}
  LANG_KOREAN                          = $12;
  {$EXTERNALSYM LANG_KOREAN}
  LANG_LATVIAN                         = $26;
  {$EXTERNALSYM LANG_LATVIAN}
  LANG_LITHUANIAN                      = $27;
  {$EXTERNALSYM LANG_LITHUANIAN}
  LANG_NORWEGIAN                       = $14;
  {$EXTERNALSYM LANG_NORWEGIAN}
  LANG_POLISH                          = $15;
  {$EXTERNALSYM LANG_POLISH}
  LANG_PORTUGUESE                      = $16;
  {$EXTERNALSYM LANG_PORTUGUESE}
  LANG_ROMANIAN                        = $18;
  {$EXTERNALSYM LANG_ROMANIAN}
  LANG_RUSSIAN                         = $19;
  {$EXTERNALSYM LANG_RUSSIAN}
  LANG_SERBIAN                         = $1a;
  {$EXTERNALSYM LANG_SERBIAN}
  LANG_SLOVAK                          = $1b;
  {$EXTERNALSYM LANG_SLOVAK}
  LANG_SLOVENIAN                       = $24;
  {$EXTERNALSYM LANG_SLOVENIAN}
  LANG_SPANISH                         = $0a;
  {$EXTERNALSYM LANG_SPANISH}
  LANG_SWEDISH                         = $1d;
  {$EXTERNALSYM LANG_SWEDISH}
  LANG_THAI                            = $1e;
  {$EXTERNALSYM LANG_THAI}
  LANG_TURKISH                         = $1f;
  {$EXTERNALSYM LANG_TURKISH}
  LANG_UKRAINIAN                       = $22;
  {$EXTERNALSYM LANG_UKRAINIAN}
  LANG_VIETNAMESE                      = $2a;
  {$EXTERNALSYM LANG_VIETNAMESE}

{ Sublanguage IDs. }

  { The name immediately following SUBLANG_ dictates which primary
    language ID that sublanguage ID can be combined with to form a
    valid language ID. }

  SUBLANG_NEUTRAL                      = $00;    { language neutral }
  {$EXTERNALSYM SUBLANG_NEUTRAL}
  SUBLANG_DEFAULT                      = $01;    { user default }
  {$EXTERNALSYM SUBLANG_DEFAULT}
  SUBLANG_SYS_DEFAULT                  = $02;    { system default }
  {$EXTERNALSYM SUBLANG_SYS_DEFAULT}
  SUBLANG_CUSTOM_DEFAULT               = $03;    { default custom language/locale }
  {$EXTERNALSYM SUBLANG_CUSTOM_DEFAULT}
  SUBLANG_CUSTOM_UNSPECIFIED           = $04;    { custom language/locale }
  {$EXTERNALSYM SUBLANG_CUSTOM_UNSPECIFIED}
  SUBLANG_UI_CUSTOM_DEFAULT            = $05;    { Default custom MUI language/locale }
  {$EXTERNALSYM SUBLANG_UI_CUSTOM_DEFAULT}

  SUBLANG_ARABIC_SAUDI_ARABIA          = $01;    { Arabic (Saudi Arabia) }
  {$EXTERNALSYM SUBLANG_ARABIC_SAUDI_ARABIA}
  SUBLANG_ARABIC_IRAQ                  = $02;    { Arabic (Iraq) }
  {$EXTERNALSYM SUBLANG_ARABIC_IRAQ}
  SUBLANG_ARABIC_EGYPT                 = $03;    { Arabic (Egypt) }
  {$EXTERNALSYM SUBLANG_ARABIC_EGYPT}
  SUBLANG_ARABIC_LIBYA                 = $04;    { Arabic (Libya) }
  {$EXTERNALSYM SUBLANG_ARABIC_LIBYA}
  SUBLANG_ARABIC_ALGERIA               = $05;    { Arabic (Algeria) }
  {$EXTERNALSYM SUBLANG_ARABIC_ALGERIA}
  SUBLANG_ARABIC_MOROCCO               = $06;    { Arabic (Morocco) }
  {$EXTERNALSYM SUBLANG_ARABIC_MOROCCO}
  SUBLANG_ARABIC_TUNISIA               = $07;    { Arabic (Tunisia) }
  {$EXTERNALSYM SUBLANG_ARABIC_TUNISIA}
  SUBLANG_ARABIC_OMAN                  = $08;    { Arabic (Oman) }
  {$EXTERNALSYM SUBLANG_ARABIC_OMAN}
  SUBLANG_ARABIC_YEMEN                 = $09;    { Arabic (Yemen) }
  {$EXTERNALSYM SUBLANG_ARABIC_YEMEN}
  SUBLANG_ARABIC_SYRIA                 = $0a;    { Arabic (Syria) }
  {$EXTERNALSYM SUBLANG_ARABIC_SYRIA}
  SUBLANG_ARABIC_JORDAN                = $0b;    { Arabic (Jordan) }
  {$EXTERNALSYM SUBLANG_ARABIC_JORDAN}
  SUBLANG_ARABIC_LEBANON               = $0c;    { Arabic (Lebanon) }
  {$EXTERNALSYM SUBLANG_ARABIC_LEBANON}
  SUBLANG_ARABIC_KUWAIT                = $0d;    { Arabic (Kuwait) }
  {$EXTERNALSYM SUBLANG_ARABIC_KUWAIT}
  SUBLANG_ARABIC_UAE                   = $0e;    { Arabic (U.A.E) }
  {$EXTERNALSYM SUBLANG_ARABIC_UAE}
  SUBLANG_ARABIC_BAHRAIN               = $0f;    { Arabic (Bahrain) }
  {$EXTERNALSYM SUBLANG_ARABIC_BAHRAIN}
  SUBLANG_ARABIC_QATAR                 = $10;    { Arabic (Qatar) }
  {$EXTERNALSYM SUBLANG_ARABIC_QATAR}
  SUBLANG_CHINESE_TRADITIONAL          = $01;    { Chinese (Taiwan) }
  {$EXTERNALSYM SUBLANG_CHINESE_TRADITIONAL}
  SUBLANG_CHINESE_SIMPLIFIED           = $02;    { Chinese (PR China) }
  {$EXTERNALSYM SUBLANG_CHINESE_SIMPLIFIED}
  SUBLANG_CHINESE_HONGKONG             = $03;    { Chinese (Hong Kong) }
  {$EXTERNALSYM SUBLANG_CHINESE_HONGKONG}
  SUBLANG_CHINESE_SINGAPORE            = $04;    { Chinese (Singapore) }
  {$EXTERNALSYM SUBLANG_CHINESE_SINGAPORE}
  SUBLANG_DUTCH                        = $01;    { Dutch }
  {$EXTERNALSYM SUBLANG_DUTCH}
  SUBLANG_DUTCH_BELGIAN                = $02;    { Dutch (Belgian) }
  {$EXTERNALSYM SUBLANG_DUTCH_BELGIAN}
  SUBLANG_ENGLISH_US                   = $01;    { English (USA) }
  {$EXTERNALSYM SUBLANG_ENGLISH_US}
  SUBLANG_ENGLISH_UK                   = $02;    { English (UK) }
  {$EXTERNALSYM SUBLANG_ENGLISH_UK}
  SUBLANG_ENGLISH_AUS                  = $03;    { English (Australian) }
  {$EXTERNALSYM SUBLANG_ENGLISH_AUS}
  SUBLANG_ENGLISH_CAN                  = $04;    { English (Canadian) }
  {$EXTERNALSYM SUBLANG_ENGLISH_CAN}
  SUBLANG_ENGLISH_NZ                   = $05;    { English (New Zealand) }
  {$EXTERNALSYM SUBLANG_ENGLISH_NZ}
  SUBLANG_ENGLISH_EIRE                 = $06;    { English (Irish) }
  {$EXTERNALSYM SUBLANG_ENGLISH_EIRE}
  SUBLANG_ENGLISH_SOUTH_AFRICA         = $07;    { English (South Africa) }
  {$EXTERNALSYM SUBLANG_ENGLISH_SOUTH_AFRICA}
  SUBLANG_ENGLISH_JAMAICA              = $08;    { English (Jamaica) }
  {$EXTERNALSYM SUBLANG_ENGLISH_JAMAICA}
  SUBLANG_ENGLISH_CARIBBEAN            = $09;    { English (Caribbean) }
  {$EXTERNALSYM SUBLANG_ENGLISH_CARIBBEAN}
  SUBLANG_ENGLISH_BELIZE               = $0a;    { English (Belize) }
  {$EXTERNALSYM SUBLANG_ENGLISH_BELIZE}
  SUBLANG_ENGLISH_TRINIDAD             = $0b;    { English (Trinidad) }
  {$EXTERNALSYM SUBLANG_ENGLISH_TRINIDAD}
  SUBLANG_FRENCH                       = $01;    { French }
  {$EXTERNALSYM SUBLANG_FRENCH}
  SUBLANG_FRENCH_BELGIAN               = $02;    { French (Belgian) }
  {$EXTERNALSYM SUBLANG_FRENCH_BELGIAN}
  SUBLANG_FRENCH_CANADIAN              = $03;    { French (Canadian) }
  {$EXTERNALSYM SUBLANG_FRENCH_CANADIAN}
  SUBLANG_FRENCH_SWISS                 = $04;    { French (Swiss) }
  {$EXTERNALSYM SUBLANG_FRENCH_SWISS}
  SUBLANG_FRENCH_LUXEMBOURG            = $05;    { French (Luxembourg) }
  {$EXTERNALSYM SUBLANG_FRENCH_LUXEMBOURG}
  SUBLANG_GERMAN                       = $01;    { German }
  {$EXTERNALSYM SUBLANG_GERMAN}
  SUBLANG_GERMAN_SWISS                 = $02;    { German (Swiss) }
  {$EXTERNALSYM SUBLANG_GERMAN_SWISS}
  SUBLANG_GERMAN_AUSTRIAN              = $03;    { German (Austrian) }
  {$EXTERNALSYM SUBLANG_GERMAN_AUSTRIAN}
  SUBLANG_GERMAN_LUXEMBOURG            = $04;    { German (Luxembourg) }
  {$EXTERNALSYM SUBLANG_GERMAN_LUXEMBOURG}
  SUBLANG_GERMAN_LIECHTENSTEIN         = $05;    { German (Liechtenstein) }
  {$EXTERNALSYM SUBLANG_GERMAN_LIECHTENSTEIN}
  SUBLANG_ITALIAN                      = $01;    { Italian }
  {$EXTERNALSYM SUBLANG_ITALIAN}
  SUBLANG_ITALIAN_SWISS                = $02;    { Italian (Swiss) }
  {$EXTERNALSYM SUBLANG_ITALIAN_SWISS}
  SUBLANG_KOREAN                       = $01;    { Korean (Extended Wansung) }
  {$EXTERNALSYM SUBLANG_KOREAN}
  SUBLANG_KOREAN_JOHAB                 = $02;    { Korean (Johab) }
  {$EXTERNALSYM SUBLANG_KOREAN_JOHAB}
  SUBLANG_NORWEGIAN_BOKMAL             = $01;    { Norwegian (Bokmal) }
  {$EXTERNALSYM SUBLANG_NORWEGIAN_BOKMAL}
  SUBLANG_NORWEGIAN_NYNORSK            = $02;    { Norwegian (Nynorsk) }
  {$EXTERNALSYM SUBLANG_NORWEGIAN_NYNORSK}
  SUBLANG_PORTUGUESE                   = $02;    { Portuguese }
  {$EXTERNALSYM SUBLANG_PORTUGUESE}
  SUBLANG_PORTUGUESE_BRAZILIAN         = $01;    { Portuguese (Brazilian) }
  {$EXTERNALSYM SUBLANG_PORTUGUESE_BRAZILIAN}
  SUBLANG_SERBIAN_LATIN                = $02;    { Serbian (Latin) }
  {$EXTERNALSYM SUBLANG_SERBIAN_LATIN}
  SUBLANG_SERBIAN_CYRILLIC             = $03;    { Serbian (Cyrillic) }
  {$EXTERNALSYM SUBLANG_SERBIAN_CYRILLIC}
  SUBLANG_SPANISH                      = $01;    { Spanish (Castilian) }
  {$EXTERNALSYM SUBLANG_SPANISH}
  SUBLANG_SPANISH_MEXICAN              = $02;    { Spanish (Mexican) }
  {$EXTERNALSYM SUBLANG_SPANISH_MEXICAN}
  SUBLANG_SPANISH_MODERN               = $03;    { Spanish (Modern) }
  {$EXTERNALSYM SUBLANG_SPANISH_MODERN}
  SUBLANG_SPANISH_GUATEMALA            = $04;    { Spanish (Guatemala) }
  {$EXTERNALSYM SUBLANG_SPANISH_GUATEMALA}
  SUBLANG_SPANISH_COSTA_RICA           = $05;    { Spanish (Costa Rica) }
  {$EXTERNALSYM SUBLANG_SPANISH_COSTA_RICA}
  SUBLANG_SPANISH_PANAMA               = $06;    { Spanish (Panama) }
  {$EXTERNALSYM SUBLANG_SPANISH_PANAMA}
  SUBLANG_SPANISH_DOMINICAN_REPUBLIC     = $07;  { Spanish (Dominican Republic) }
  {$EXTERNALSYM SUBLANG_SPANISH_DOMINICAN_REPUBLIC}
  SUBLANG_SPANISH_VENEZUELA            = $08;    { Spanish (Venezuela) }
  {$EXTERNALSYM SUBLANG_SPANISH_VENEZUELA}
  SUBLANG_SPANISH_COLOMBIA             = $09;    { Spanish (Colombia) }
  {$EXTERNALSYM SUBLANG_SPANISH_COLOMBIA}
  SUBLANG_SPANISH_PERU                 = $0a;    { Spanish (Peru) }
  {$EXTERNALSYM SUBLANG_SPANISH_PERU}
  SUBLANG_SPANISH_ARGENTINA            = $0b;    { Spanish (Argentina) }
  {$EXTERNALSYM SUBLANG_SPANISH_ARGENTINA}
  SUBLANG_SPANISH_ECUADOR              = $0c;    { Spanish (Ecuador) }
  {$EXTERNALSYM SUBLANG_SPANISH_ECUADOR}
  SUBLANG_SPANISH_CHILE                = $0d;    { Spanish (Chile) }
  {$EXTERNALSYM SUBLANG_SPANISH_CHILE}
  SUBLANG_SPANISH_URUGUAY              = $0e;    { Spanish (Uruguay) }
  {$EXTERNALSYM SUBLANG_SPANISH_URUGUAY}
  SUBLANG_SPANISH_PARAGUAY             = $0f;    { Spanish (Paraguay) }
  {$EXTERNALSYM SUBLANG_SPANISH_PARAGUAY}
  SUBLANG_SPANISH_BOLIVIA              = $10;    { Spanish (Bolivia) }
  {$EXTERNALSYM SUBLANG_SPANISH_BOLIVIA}
  SUBLANG_SPANISH_EL_SALVADOR          = $11;    { Spanish (El Salvador) }
  {$EXTERNALSYM SUBLANG_SPANISH_EL_SALVADOR}
  SUBLANG_SPANISH_HONDURAS             = $12;    { Spanish (Honduras) }
  {$EXTERNALSYM SUBLANG_SPANISH_HONDURAS}
  SUBLANG_SPANISH_NICARAGUA            = $13;    { Spanish (Nicaragua) }
  {$EXTERNALSYM SUBLANG_SPANISH_NICARAGUA}
  SUBLANG_SPANISH_PUERTO_RICO          = $14;    { Spanish (Puerto Rico) }
  {$EXTERNALSYM SUBLANG_SPANISH_PUERTO_RICO}
  SUBLANG_SWEDISH                      = $01;    { Swedish }
  {$EXTERNALSYM SUBLANG_SWEDISH}
  SUBLANG_SWEDISH_FINLAND              = $02;    { Swedish (Finland) }
  {$EXTERNALSYM SUBLANG_SWEDISH_FINLAND}

{ Sorting IDs. }

  SORT_DEFAULT                         = $0;     { sorting default }
  {$EXTERNALSYM SORT_DEFAULT}

  SORT_JAPANESE_XJIS                   = $0;     { Japanese XJIS order }
  {$EXTERNALSYM SORT_JAPANESE_XJIS}
  SORT_JAPANESE_UNICODE                = $1;     { Japanese Unicode order }
  {$EXTERNALSYM SORT_JAPANESE_UNICODE}

  SORT_CHINESE_BIG5                    = $0;     { Chinese BIG5 order }
  {$EXTERNALSYM SORT_CHINESE_BIG5}
  SORT_CHINESE_PRCP                    = $0;     { PRC Chinese Phonetic order }
  {$EXTERNALSYM SORT_CHINESE_PRCP}
  SORT_CHINESE_UNICODE                 = $1;     { Chinese Unicode order }
  {$EXTERNALSYM SORT_CHINESE_UNICODE}
  SORT_CHINESE_PRC                     = $2;     { PRC Chinese Stroke Count order }
  {$EXTERNALSYM SORT_CHINESE_PRC}

  SORT_KOREAN_KSC                      = $0;     { Korean KSC order }
  {$EXTERNALSYM SORT_KOREAN_KSC}
  SORT_KOREAN_UNICODE                  = $1;     { Korean Unicode order }
  {$EXTERNALSYM SORT_KOREAN_UNICODE}

  SORT_GERMAN_PHONE_BOOK               = $1;     { German Phone Book order }
  {$EXTERNALSYM SORT_GERMAN_PHONE_BOOK}

{line 2250}
  FILE_SHARE_READ                     = $00000001;
  {$EXTERNALSYM FILE_SHARE_READ}
  FILE_SHARE_WRITE                    = $00000002;
  {$EXTERNALSYM FILE_SHARE_WRITE}
  FILE_SHARE_DELETE                   = $00000004;
  {$EXTERNALSYM FILE_SHARE_DELETE}
  FILE_ATTRIBUTE_READONLY             = $00000001;
  {$EXTERNALSYM FILE_ATTRIBUTE_READONLY}
  FILE_ATTRIBUTE_HIDDEN               = $00000002;
  {$EXTERNALSYM FILE_ATTRIBUTE_HIDDEN}
  FILE_ATTRIBUTE_SYSTEM               = $00000004;
  {$EXTERNALSYM FILE_ATTRIBUTE_SYSTEM}
  FILE_ATTRIBUTE_DIRECTORY            = $00000010;
  {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
  FILE_ATTRIBUTE_ARCHIVE              = $00000020;
  {$EXTERNALSYM FILE_ATTRIBUTE_ARCHIVE}
  FILE_ATTRIBUTE_DEVICE               = $00000040;
  {$EXTERNALSYM FILE_ATTRIBUTE_DEVICE}
  FILE_ATTRIBUTE_NORMAL               = $00000080;
  {$EXTERNALSYM FILE_ATTRIBUTE_NORMAL}
  FILE_ATTRIBUTE_TEMPORARY            = $00000100;
  {$EXTERNALSYM FILE_ATTRIBUTE_TEMPORARY}
  FILE_ATTRIBUTE_SPARSE_FILE          = $00000200;
  {$EXTERNALSYM FILE_ATTRIBUTE_SPARSE_FILE}
  FILE_ATTRIBUTE_REPARSE_POINT        = $00000400;
  {$EXTERNALSYM FILE_ATTRIBUTE_REPARSE_POINT}
  FILE_ATTRIBUTE_COMPRESSED           = $00000800;
  {$EXTERNALSYM FILE_ATTRIBUTE_COMPRESSED}
  FILE_ATTRIBUTE_OFFLINE              = $00001000;
  {$EXTERNALSYM FILE_ATTRIBUTE_OFFLINE}
  FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  = $00002000;
  {$EXTERNALSYM FILE_ATTRIBUTE_NOT_CONTENT_INDEXED}
  FILE_ATTRIBUTE_ENCRYPTED            = $00004000;
  {$EXTERNALSYM INVALID_FILE_ATTRIBUTES}
  INVALID_FILE_ATTRIBUTES             = DWORD($FFFFFFFF);
  {$EXTERNALSYM FILE_ATTRIBUTE_ENCRYPTED}
  FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_FILE_NAME}
  FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_DIR_NAME}
  FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_ATTRIBUTES}
  FILE_NOTIFY_CHANGE_SIZE             = $00000008;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_SIZE}
  FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_LAST_WRITE}
  FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_LAST_ACCESS}
  FILE_NOTIFY_CHANGE_CREATION         = $00000040;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_CREATION}
  FILE_NOTIFY_CHANGE_SECURITY         = $00000100;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_SECURITY}
  FILE_ACTION_ADDED                   = $00000001;
  {$EXTERNALSYM FILE_ACTION_ADDED}
  FILE_ACTION_REMOVED                 = $00000002;
  {$EXTERNALSYM FILE_ACTION_REMOVED}
  FILE_ACTION_MODIFIED                = $00000003;
  {$EXTERNALSYM FILE_ACTION_MODIFIED}
  FILE_ACTION_RENAMED_OLD_NAME        = $00000004;
  {$EXTERNALSYM FILE_ACTION_RENAMED_OLD_NAME}
  FILE_ACTION_RENAMED_NEW_NAME        = $00000005;
  {$EXTERNALSYM FILE_ACTION_RENAMED_NEW_NAME}
  MAILSLOT_NO_MESSAGE                 = LongWord(-1);
  {$EXTERNALSYM MAILSLOT_NO_MESSAGE}
  MAILSLOT_WAIT_FOREVER               = LongWord(-1);
  {$EXTERNALSYM MAILSLOT_WAIT_FOREVER}
  FILE_CASE_SENSITIVE_SEARCH          = $00000001;
  {$EXTERNALSYM FILE_CASE_SENSITIVE_SEARCH}
  FILE_CASE_PRESERVED_NAMES           = $00000002;
  {$EXTERNALSYM FILE_CASE_PRESERVED_NAMES}
  FILE_UNICODE_ON_DISK                = $00000004;
  {$EXTERNALSYM FILE_UNICODE_ON_DISK}
  FILE_PERSISTENT_ACLS                = $00000008;
  {$EXTERNALSYM FILE_PERSISTENT_ACLS}
  FILE_FILE_COMPRESSION               = $00000010;
  {$EXTERNALSYM FILE_FILE_COMPRESSION}
  FILE_VOLUME_IS_COMPRESSED           = $00008000;
  {$EXTERNALSYM FILE_VOLUME_IS_COMPRESSED}

  { Define the severity codes }

  { The operation completed successfully. }
  ERROR_SUCCESS = 0;
  {$EXTERNALSYM ERROR_SUCCESS}
  NO_ERROR = 0;   { dderror }
  {$EXTERNALSYM NO_ERROR}

  { Code Page Default Values. }

  {$EXTERNALSYM CP_ACP}
  CP_ACP                   = 0;             { default to ANSI code page }
  {$EXTERNALSYM CP_OEMCP}
  CP_OEMCP                 = 1;             { default to OEM  code page }
  {$EXTERNALSYM CP_MACCP}
  CP_MACCP                 = 2;             { default to MAC  code page }
  {$EXTERNALSYM CP_THREAD_ACP}
  CP_THREAD_ACP            = 3;             { current thread's ANSI code page }
  {$EXTERNALSYM CP_SYMBOL}
  CP_SYMBOL                = 42;            { SYMBOL translations }

  {$EXTERNALSYM CP_UTF7}
  CP_UTF7                  = 65000;         { UTF-7 translation }
  {$EXTERNALSYM CP_UTF8}
  CP_UTF8                  = 65001;         { UTF-8 translation }

  { Clipping Capabilities }

  {$EXTERNALSYM CP_NONE}
  CP_NONE      = 0;     { No clipping of output             }
  {$EXTERNALSYM CP_RECTANGLE}
  CP_RECTANGLE = 1;     { Output clipped to rects           }
  {$EXTERNALSYM CP_REGION}
  CP_REGION    = 2;     { obsolete                          }

  { MBCS and Unicode Translation Flags. }

  {$EXTERNALSYM MB_PRECOMPOSED}
  MB_PRECOMPOSED = 1; { use precomposed chars }
  {$EXTERNALSYM MB_COMPOSITE}
  MB_COMPOSITE = 2; { use composite chars }
  {$EXTERNALSYM MB_USEGLYPHCHARS}
  MB_USEGLYPHCHARS = 4; { use glyph chars, not ctrl chars }

  {$EXTERNALSYM WC_DEFAULTCHECK}
  WC_DEFAULTCHECK = $100; { check for default char }
  {$EXTERNALSYM WC_COMPOSITECHECK}
  WC_COMPOSITECHECK = $200; { convert composite to precomposed }
  {$EXTERNALSYM WC_DISCARDNS}
  WC_DISCARDNS = $10; { discard non-spacing chars }
  {$EXTERNALSYM WC_SEPCHARS}
  WC_SEPCHARS = $20; { generate separate chars }
  {$EXTERNALSYM WC_DEFAULTCHAR}
  WC_DEFAULTCHAR = $40; { replace w default char }

type
{ File structures }

  PSecurityAttributes = ^TSecurityAttributes;
  _SECURITY_ATTRIBUTES = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;
  TSecurityAttributes = _SECURITY_ATTRIBUTES;
  SECURITY_ATTRIBUTES = _SECURITY_ATTRIBUTES;

  POverlapped = ^TOverlapped;
  _OVERLAPPED = record
    Internal: DWORD;
    InternalHigh: DWORD;
    Offset: DWORD;
    OffsetHigh: DWORD;
    hEvent: THandle;
  end;
  TOverlapped = _OVERLAPPED;
  OVERLAPPED = _OVERLAPPED;

{$IFDEF MSWINDOWS}
  { File System time stamps are represented with the following structure: }
  PFileTime = ^TFileTime;
  _FILETIME = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;
  TFileTime = _FILETIME;
  FILETIME = _FILETIME;
  {$EXTERNALSYM FILETIME}
{$ENDIF}
{$IFDEF LINUX}
  _FILETIME = Types._FILETIME;
  PFileTime = Types.PFileTime;
  TFileTime = Types.TFileTime;
  FILETIME = Types.FILETIME;
{$ENDIF}

  PWin32FindDataA = ^TWin32FindDataA;
  PWin32FindDataW = ^TWin32FindDataW;
  PWin32FindData = PWin32FindDataW;
  _WIN32_FIND_DATAA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of AnsiChar;
    cAlternateFileName: array[0..13] of AnsiChar;
  end;
  _WIN32_FIND_DATAW = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of Char;
    cAlternateFileName: array[0..13] of Char;
  end;
  _WIN32_FIND_DATA = _WIN32_FIND_DATAW;
  TWin32FindDataA = _WIN32_FIND_DATAA;
  TWin32FindDataW = _WIN32_FIND_DATAW;
  TWin32FindData = {$IFDEF UNICODE} TWin32FindDataW {$ELSE} TWin32FindDataA {$ENDIF};
  WIN32_FIND_DATAA = _WIN32_FIND_DATAA;
  WIN32_FIND_DATAW = _WIN32_FIND_DATAW;
  WIN32_FIND_DATA = {$IFDEF UNICODE} WIN32_FIND_DATAW {$ELSE} WIN32_FIND_DATAA {$ENDIF};

  TFarProc = Pointer;
  TFNThreadStartRoutine = TFarProc;

{ Translated from WINNT.H (only things needed for API calls) }
{line 190}
type
  LONGLONG = Int64;
  {$EXTERNALSYM LONGLONG}
  PSID = Pointer;
  {$EXTERNALSYM PSID}
  PLargeInteger = ^TLargeInteger;
  _LARGE_INTEGER = record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: Longint);
    1: (
      QuadPart: LONGLONG);
  end;
  {$EXTERNALSYM _LARGE_INTEGER}
  {$NODEFINE TLargeInteger}
  TLargeInteger = Int64;
  LARGE_INTEGER = _LARGE_INTEGER;
  {$EXTERNALSYM LARGE_INTEGER}

  DWORDLONG = UInt64;
  {$EXTERNALSYM DWORDLONG}
  ULONGLONG = UInt64;
  {$EXTERNALSYM ULONGLONG}
  ULARGE_INTEGER = record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: DWORD);
    1: (
      QuadPart: ULONGLONG);
  end;
  {$EXTERNALSYM ULARGE_INTEGER}
  PULargeInteger = ^TULargeInteger;
  TULargeInteger = ULARGE_INTEGER;

{line 450}
  PListEntry = ^TListEntry;
  _LIST_ENTRY = record
    Flink: PListEntry;
    Blink: PListEntry;
  end;
  {$EXTERNALSYM _LIST_ENTRY}
  TListEntry = _LIST_ENTRY;
  LIST_ENTRY = _LIST_ENTRY;
  {$EXTERNALSYM LIST_ENTRY}

{line 2100}
const
  THREAD_BASE_PRIORITY_LOWRT = 15;  { value that gets a thread to LowRealtime-1 }
  {$EXTERNALSYM THREAD_BASE_PRIORITY_LOWRT}
  THREAD_BASE_PRIORITY_MAX = 2;     { maximum thread base priority boost }
  {$EXTERNALSYM THREAD_BASE_PRIORITY_MAX}
  THREAD_BASE_PRIORITY_MIN = -2;    { minimum thread base priority boost }
  {$EXTERNALSYM THREAD_BASE_PRIORITY_MIN}
  THREAD_BASE_PRIORITY_IDLE = -15;  { value that gets a thread to idle }
  {$EXTERNALSYM THREAD_BASE_PRIORITY_IDLE}

  SYNCHRONIZE = $00100000;
  {$EXTERNALSYM SYNCHRONIZE}
  STANDARD_RIGHTS_REQUIRED = $000F0000;
  {$EXTERNALSYM STANDARD_RIGHTS_REQUIRED}
  EVENT_MODIFY_STATE = $0002;
  {$EXTERNALSYM EVENT_MODIFY_STATE}
  EVENT_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $3);
  {$EXTERNALSYM EVENT_ALL_ACCESS}
  MUTANT_QUERY_STATE = $0001;
  {$EXTERNALSYM MUTANT_QUERY_STATE}
  MUTANT_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or MUTANT_QUERY_STATE);
  {$EXTERNALSYM MUTANT_ALL_ACCESS}

  SEMAPHORE_MODIFY_STATE  = $0002;
  {$EXTERNALSYM SEMAPHORE_MODIFY_STATE}
  SEMAPHORE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $3);
  {$EXTERNALSYM SEMAPHORE_ALL_ACCESS}

  PROCESS_TERMINATE         = $0001;
  {$EXTERNALSYM PROCESS_TERMINATE}
  PROCESS_CREATE_THREAD     = $0002;
  {$EXTERNALSYM PROCESS_CREATE_THREAD}
  PROCESS_VM_OPERATION      = $0008;
  {$EXTERNALSYM PROCESS_VM_OPERATION}
  PROCESS_VM_READ           = $0010;
  {$EXTERNALSYM PROCESS_VM_READ}
  PROCESS_VM_WRITE          = $0020;
  {$EXTERNALSYM PROCESS_VM_WRITE}
  PROCESS_DUP_HANDLE        = $0040;
  {$EXTERNALSYM PROCESS_DUP_HANDLE}
  PROCESS_CREATE_PROCESS    = $0080;
  {$EXTERNALSYM PROCESS_CREATE_PROCESS}
  PROCESS_SET_QUOTA         = $0100;
  {$EXTERNALSYM PROCESS_SET_QUOTA}
  PROCESS_SET_INFORMATION   = $0200;
  {$EXTERNALSYM PROCESS_SET_INFORMATION}
  PROCESS_QUERY_INFORMATION = $0400;
  {$EXTERNALSYM PROCESS_QUERY_INFORMATION}
  PROCESS_ALL_ACCESS        = (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $FFF);
  {$EXTERNALSYM PROCESS_ALL_ACCESS}

{line 2150}
type
  PMemoryBasicInformation = ^TMemoryBasicInformation;
  _MEMORY_BASIC_INFORMATION = record
    BaseAddress : Pointer;
    AllocationBase : Pointer;
    AllocationProtect : DWORD;
    RegionSize : DWORD;
    State : DWORD;
    Protect : DWORD;
    Type_9 : DWORD;
  end;
  {$EXTERNALSYM _MEMORY_BASIC_INFORMATION}
  TMemoryBasicInformation = _MEMORY_BASIC_INFORMATION;
  MEMORY_BASIC_INFORMATION = _MEMORY_BASIC_INFORMATION;
  {$EXTERNALSYM MEMORY_BASIC_INFORMATION}

const
  SECTION_QUERY = 1;
  {$EXTERNALSYM SECTION_QUERY}
  SECTION_MAP_WRITE = 2;
  {$EXTERNALSYM SECTION_MAP_WRITE}
  SECTION_MAP_READ = 4;
  {$EXTERNALSYM SECTION_MAP_READ}
  SECTION_MAP_EXECUTE = 8;
  {$EXTERNALSYM SECTION_MAP_EXECUTE}
  SECTION_EXTEND_SIZE = $10;
  {$EXTERNALSYM SECTION_EXTEND_SIZE}
  SECTION_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED or SECTION_QUERY or
    SECTION_MAP_WRITE or SECTION_MAP_READ or SECTION_MAP_EXECUTE or SECTION_EXTEND_SIZE);
  {$EXTERNALSYM SECTION_ALL_ACCESS}

  PAGE_NOACCESS = 1;
  {$EXTERNALSYM PAGE_NOACCESS}
  PAGE_READONLY = 2;
  {$EXTERNALSYM PAGE_READONLY}
  PAGE_READWRITE = 4;
  {$EXTERNALSYM PAGE_READWRITE}
  PAGE_WRITECOPY = 8;
  {$EXTERNALSYM PAGE_WRITECOPY}
  PAGE_EXECUTE = $10;
  {$EXTERNALSYM PAGE_EXECUTE}
  PAGE_EXECUTE_READ = $20;
  {$EXTERNALSYM PAGE_EXECUTE_READ}
  PAGE_EXECUTE_READWRITE = $40;
  {$EXTERNALSYM PAGE_EXECUTE_READWRITE}
  PAGE_EXECUTE_WRITECOPY = $80;
  {$EXTERNALSYM PAGE_EXECUTE_WRITECOPY}
  PAGE_GUARD = $100;
  {$EXTERNALSYM PAGE_GUARD}
  PAGE_NOCACHE = $200;
  {$EXTERNALSYM PAGE_NOCACHE}
  MEM_COMMIT = $1000;
  {$EXTERNALSYM MEM_COMMIT}
  MEM_RESERVE = $2000;
  {$EXTERNALSYM MEM_RESERVE}
  MEM_DECOMMIT = $4000;
  {$EXTERNALSYM MEM_DECOMMIT}
  MEM_RELEASE = $8000;
  {$EXTERNALSYM MEM_RELEASE}
  MEM_FREE = $10000;
  {$EXTERNALSYM MEM_FREE}
  MEM_PRIVATE = $20000;
  {$EXTERNALSYM MEM_PRIVATE}
  MEM_MAPPED = $40000;
  {$EXTERNALSYM MEM_MAPPED}
  MEM_RESET = $80000;
  {$EXTERNALSYM MEM_RESET}
  MEM_TOP_DOWN = $100000;
  {$EXTERNALSYM MEM_TOP_DOWN}
  SEC_FILE = $800000;
  {$EXTERNALSYM SEC_FILE}
  SEC_IMAGE = $1000000;
  {$EXTERNALSYM SEC_IMAGE}
  SEC_RESERVE = $4000000;
  {$EXTERNALSYM SEC_RESERVE}
  SEC_COMMIT = $8000000;
  {$EXTERNALSYM SEC_COMMIT}
  SEC_NOCACHE = $10000000;
  {$EXTERNALSYM SEC_NOCACHE}
  MEM_IMAGE = SEC_IMAGE;
  {$EXTERNALSYM MEM_IMAGE}

{line 490}
const
  MINCHAR = $80;
  {$EXTERNALSYM MINCHAR}
  MAXCHAR = 127;
  {$EXTERNALSYM MAXCHAR}
  MINSHORT = $8000;
  {$EXTERNALSYM MINSHORT}
  MAXSHORT = 32767;
  {$EXTERNALSYM MAXSHORT}
  MINLONG = DWORD($80000000);
  {$EXTERNALSYM MINLONG}
  MAXLONG = $7FFFFFFF;
  {$EXTERNALSYM MAXLONG}
  MAXBYTE = 255;
  {$EXTERNALSYM MAXBYTE}
  MAXWORD = 65535;
  {$EXTERNALSYM MAXWORD}
  MAXDWORD = DWORD($FFFFFFFF);
  {$EXTERNALSYM MAXDWORD}

const
 { String Flags. }

  {$EXTERNALSYM NORM_IGNORECASE}
  NORM_IGNORECASE = 1; { ignore case }
  {$EXTERNALSYM NORM_IGNORENONSPACE}
  NORM_IGNORENONSPACE = 2; { ignore nonspacing chars }
  {$EXTERNALSYM NORM_IGNORESYMBOLS}
  NORM_IGNORESYMBOLS = 4; { ignore symbols }
  {$EXTERNALSYM NORM_IGNOREKANATYPE}
  NORM_IGNOREKANATYPE = $10000;
  {$EXTERNALSYM NORM_IGNOREWIDTH}
  NORM_IGNOREWIDTH = $20000;

{ Default System and User IDs for language and locale. }

  LANG_SYSTEM_DEFAULT   = (SUBLANG_SYS_DEFAULT shl 10) or LANG_NEUTRAL;
  {$EXTERNALSYM LANG_SYSTEM_DEFAULT}
  LANG_USER_DEFAULT     = (SUBLANG_DEFAULT shl 10) or LANG_NEUTRAL;
  {$EXTERNALSYM LANG_USER_DEFAULT}

  LOCALE_SYSTEM_DEFAULT = (SORT_DEFAULT shl 16) or LANG_SYSTEM_DEFAULT;
  {$EXTERNALSYM LOCALE_SYSTEM_DEFAULT}
  LOCALE_USER_DEFAULT   = (SORT_DEFAULT shl 16) or LANG_USER_DEFAULT;
  {$EXTERNALSYM LOCALE_USER_DEFAULT}
  LOCALE_CUSTOM_DEFAULT = (SORT_DEFAULT shl 16) or ((SUBLANG_CUSTOM_DEFAULT shl 10) or LANG_NEUTRAL);
  {$EXTERNALSYM LOCALE_CUSTOM_DEFAULT}
  LOCALE_CUSTOM_UNSPECIFIED = (SORT_DEFAULT shl 16) or ((SUBLANG_CUSTOM_UNSPECIFIED shl 10) or LANG_NEUTRAL);
  {$EXTERNALSYM LOCALE_CUSTOM_UNSPECIFIED}
  LOCALE_CUSTOM_UI_DEFAULT = (SORT_DEFAULT shl 16) or ((SUBLANG_UI_CUSTOM_DEFAULT shl 10) or LANG_NEUTRAL);
  {$EXTERNALSYM LOCALE_CUSTOM_UI_DEFAULT}
  LOCALE_NEUTRAL = (SORT_DEFAULT shl 16) or ((SUBLANG_NEUTRAL shl 10) or LANG_NEUTRAL);
  {$EXTERNALSYM LOCALE_NEUTRAL}
  LOCALE_INVARIANT = (SORT_DEFAULT shl 16) or ((SUBLANG_NEUTRAL shl 10) or LANG_INVARIANT);
  {$EXTERNALSYM LOCALE_INVARIANT}

  FORMAT_MESSAGE_ALLOCATE_BUFFER = $100;
  {$EXTERNALSYM FORMAT_MESSAGE_ALLOCATE_BUFFER}
  FORMAT_MESSAGE_IGNORE_INSERTS = $200;
  {$EXTERNALSYM FORMAT_MESSAGE_IGNORE_INSERTS}
  FORMAT_MESSAGE_FROM_STRING = $400;
  {$EXTERNALSYM FORMAT_MESSAGE_FROM_STRING}
  FORMAT_MESSAGE_FROM_HMODULE = $800;
  {$EXTERNALSYM FORMAT_MESSAGE_FROM_HMODULE}
  FORMAT_MESSAGE_FROM_SYSTEM = $1000;
  {$EXTERNALSYM FORMAT_MESSAGE_FROM_SYSTEM}
  FORMAT_MESSAGE_ARGUMENT_ARRAY = $2000;
  {$EXTERNALSYM FORMAT_MESSAGE_ARGUMENT_ARRAY}
  FORMAT_MESSAGE_MAX_WIDTH_MASK = 255;
  {$EXTERNALSYM FORMAT_MESSAGE_MAX_WIDTH_MASK}

const
  { MessageBox() Flags }
  {$EXTERNALSYM MB_OK}
  MB_OK = $00000000;
  {$EXTERNALSYM MB_OKCANCEL}
  MB_OKCANCEL = $00000001;
  {$EXTERNALSYM MB_ABORTRETRYIGNORE}
  MB_ABORTRETRYIGNORE = $00000002;
  {$EXTERNALSYM MB_YESNOCANCEL}
  MB_YESNOCANCEL = $00000003;
  {$EXTERNALSYM MB_YESNO}
  MB_YESNO = $00000004;
  {$EXTERNALSYM MB_RETRYCANCEL}
  MB_RETRYCANCEL = $00000005;

  {$EXTERNALSYM MB_ICONHAND}
  MB_ICONHAND = $00000010;
  {$EXTERNALSYM MB_ICONQUESTION}
  MB_ICONQUESTION = $00000020;
  {$EXTERNALSYM MB_ICONEXCLAMATION}
  MB_ICONEXCLAMATION = $00000030;
  {$EXTERNALSYM MB_ICONASTERISK}
  MB_ICONASTERISK = $00000040;
  {$EXTERNALSYM MB_USERICON}
  MB_USERICON = $00000080;
  {$EXTERNALSYM MB_ICONWARNING}
  MB_ICONWARNING                 = MB_ICONEXCLAMATION;
  {$EXTERNALSYM MB_ICONERROR}
  MB_ICONERROR                   = MB_ICONHAND;
  {$EXTERNALSYM MB_ICONINFORMATION}
  MB_ICONINFORMATION             = MB_ICONASTERISK;
  {$EXTERNALSYM MB_ICONSTOP}
  MB_ICONSTOP                    = MB_ICONHAND;

  {$EXTERNALSYM MB_DEFBUTTON1}
  MB_DEFBUTTON1 = $00000000;
  {$EXTERNALSYM MB_DEFBUTTON2}
  MB_DEFBUTTON2 = $00000100;
  {$EXTERNALSYM MB_DEFBUTTON3}
  MB_DEFBUTTON3 = $00000200;
  {$EXTERNALSYM MB_DEFBUTTON4}
  MB_DEFBUTTON4 = $00000300;

  {$EXTERNALSYM MB_APPLMODAL}
  MB_APPLMODAL = $00000000;
  {$EXTERNALSYM MB_SYSTEMMODAL}
  MB_SYSTEMMODAL = $00001000;
  {$EXTERNALSYM MB_TASKMODAL}
  MB_TASKMODAL = $00002000;
  {$EXTERNALSYM MB_HELP}
  MB_HELP = $00004000;                          { Help Button }

  {$EXTERNALSYM MB_NOFOCUS}
  MB_NOFOCUS = $00008000;
  {$EXTERNALSYM MB_SETFOREGROUND}
  MB_SETFOREGROUND = $00010000;
  {$EXTERNALSYM MB_DEFAULT_DESKTOP_ONLY}
  MB_DEFAULT_DESKTOP_ONLY = $00020000;

  {$EXTERNALSYM MB_TOPMOST}
  MB_TOPMOST = $00040000;
  {$EXTERNALSYM MB_RIGHT}
  MB_RIGHT = $00080000;
  {$EXTERNALSYM MB_RTLREADING}
  MB_RTLREADING = $00100000;

  {$EXTERNALSYM MB_SERVICE_NOTIFICATION}
  MB_SERVICE_NOTIFICATION = $00200000;
  {$EXTERNALSYM MB_SERVICE_NOTIFICATION_NT3X}
  MB_SERVICE_NOTIFICATION_NT3X = $00040000;

  {$EXTERNALSYM MB_TYPEMASK}
  MB_TYPEMASK = $0000000F;
  {$EXTERNALSYM MB_ICONMASK}
  MB_ICONMASK = $000000F0;
  {$EXTERNALSYM MB_DEFMASK}
  MB_DEFMASK = $00000F00;
  {$EXTERNALSYM MB_MODEMASK}
  MB_MODEMASK = $00003000;
  {$EXTERNALSYM MB_MISCMASK}
  MB_MISCMASK = $0000C000;

type







  TFNPropEnumProc = TFarProc;
  TFNPropEnumProcEx = TFarProc;
  TFNEditWordBreakProc = TFarProc;
  TFNNameEnumProc = TFarProc;

  TFNWinStaEnumProc = TFNNameEnumProc;
  TFNDeskTopEnumProc = TFNNameEnumProc;

  MakeIntResourceA = PAnsiChar;
  MakeIntResourceW = PWideChar;
  MakeIntResource = MakeIntResourceW;

  PTimeZoneInformation = ^TTimeZoneInformation;
  _TIME_ZONE_INFORMATION = record
    Bias: Longint;
    StandardName: array[0..31] of WCHAR;
    StandardDate: TSystemTime;
    StandardBias: Longint;
    DaylightName: array[0..31] of WCHAR;
    DaylightDate: TSystemTime;
    DaylightBias: Longint;
  end;
  {$EXTERNALSYM _TIME_ZONE_INFORMATION}
  TTimeZoneInformation = _TIME_ZONE_INFORMATION;
  TIME_ZONE_INFORMATION = _TIME_ZONE_INFORMATION;
  {$EXTERNALSYM TIME_ZONE_INFORMATION}

const
  { Predefined Resource Types }
  {$EXTERNALSYM RT_CURSOR}
  RT_CURSOR       = MakeIntResource(1);
  {$EXTERNALSYM RT_BITMAP}
  RT_BITMAP       = MakeIntResource(2);
  {$EXTERNALSYM RT_ICON}
  RT_ICON         = MakeIntResource(3);
  {$EXTERNALSYM RT_MENU}
  RT_MENU         = MakeIntResource(4);
  {$EXTERNALSYM RT_DIALOG}
  RT_DIALOG       = MakeIntResource(5);
  {$EXTERNALSYM RT_STRING}
  RT_STRING       = MakeIntResource(6);
  {$EXTERNALSYM RT_FONTDIR}
  RT_FONTDIR      = MakeIntResource(7);
  {$EXTERNALSYM RT_FONT}
  RT_FONT         = MakeIntResource(8);
  {$EXTERNALSYM RT_ACCELERATOR}
  RT_ACCELERATOR  = MakeIntResource(9);
  {$EXTERNALSYM RT_RCDATA}
  RT_RCDATA       = Types.RT_RCDATA; //MakeIntResource(10);
  {$EXTERNALSYM RT_MESSAGETABLE}
  RT_MESSAGETABLE = MakeIntResource(11);

  DIFFERENCE = 11;
  {$EXTERNALSYM DIFFERENCE}

  RT_GROUP_CURSOR = MakeIntResource(DWORD(RT_CURSOR) + DIFFERENCE);
  {$EXTERNALSYM RT_GROUP_CURSOR}
  RT_GROUP_ICON   = MakeIntResource(DWORD(RT_ICON) + DIFFERENCE);
  {$EXTERNALSYM RT_GROUP_ICON}
  RT_VERSION      = MakeIntResource(16);
  {$EXTERNALSYM RT_VERSION}
  RT_DLGINCLUDE   = MakeIntResource(17);
  {$EXTERNALSYM RT_DLGINCLUDE}
  RT_PLUGPLAY     = MakeIntResource(19);
  {$EXTERNALSYM RT_PLUGPLAY}
  RT_VXD          = MakeIntResource(20);
  {$EXTERNALSYM RT_VXD}
  RT_ANICURSOR    = MakeIntResource(21);
  {$EXTERNALSYM RT_ANICURSOR}
  RT_ANIICON      = MakeIntResource(22);
  {$EXTERNALSYM RT_ANIICON}
  RT_HTML         = MakeIntResource(23);
  {$EXTERNALSYM RT_HTML}
  RT_MANIFEST     = MakeIntResource(24);
  {$EXTERNALSYM RT_MANIFEST}
  CREATEPROCESS_MANIFEST_RESOURCE_ID                 = MakeIntResource(1);
  {$EXTERNALSYM CREATEPROCESS_MANIFEST_RESOURCE_ID}
  ISOLATIONAWARE_MANIFEST_RESOURCE_ID                = MakeIntResource(2);
  {$EXTERNALSYM ISOLATIONAWARE_MANIFEST_RESOURCE_ID}
  ISOLATIONAWARE_NOSTATICIMPORT_MANIFEST_RESOURCE_ID = MakeIntResource(3);
  {$EXTERNALSYM ISOLATIONAWARE_NOSTATICIMPORT_MANIFEST_RESOURCE_ID}
  MINIMUM_RESERVED_MANIFEST_RESOURCE_ID              = MakeIntResource(1);  // inclusive
  {$EXTERNALSYM MINIMUM_RESERVED_MANIFEST_RESOURCE_ID}
  MAXIMUM_RESERVED_MANIFEST_RESOURCE_ID              = MakeIntResource(16); // inclusive
  {$EXTERNALSYM MAXIMUM_RESERVED_MANIFEST_RESOURCE_ID}

  SEM_FAILCRITICALERRORS = 1;
  {$EXTERNALSYM SEM_FAILCRITICALERRORS}
  SEM_NOGPFAULTERRORBOX = 2;
  {$EXTERNALSYM SEM_NOGPFAULTERRORBOX}
  SEM_NOALIGNMENTFAULTEXCEPT = 4;
  {$EXTERNALSYM SEM_NOALIGNMENTFAULTEXCEPT}
  SEM_NOOPENFILEERRORBOX = $8000;
  {$EXTERNALSYM SEM_NOOPENFILEERRORBOX}


function MoveFile(lpExistingFileName, lpNewFileName: PChar): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'MoveFileW' {$ELSE} 'MoveFileA' {$ENDIF};

function LoadLibrary(lpLibFileName: PWideChar): HMODULE; stdcall; external kernel32 name {$IFDEF UNICODE} 'LoadLibraryW' {$ELSE} 'LoadLibraryA' {$ENDIF};
function GetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall; overload; external kernel32 name 'GetProcAddress';
//function GetProcAddress(hModule: HMODULE; lpProcName: LPCWSTR): FARPROC; stdcall; overload;
function FreeLibrary(hLibModule: HMODULE): BOOL; stdcall; external kernel32 name 'FreeLibrary';
function GetTimeZoneInformation(var lpTimeZoneInformation: TTimeZoneInformation): DWORD; stdcall; external kernel32 name 'GetTimeZoneInformation';
function EnumDateFormats(lpDateFmtEnumProc: TFarProc; Locale: LCID; dwFlags: DWORD): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE}'EnumDateFormatsW'{$ELSE}'EnumDateFormatsA'{$ENDIF};
function EnumTimeFormats(lpTimeFmtEnumProc: TFarProc; Locale: LCID; dwFlags: DWORD): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE}'EnumTimeFormatsW'{$ELSE}'EnumTimeFormatsA'{$ENDIF};

{ WinAPI }

function CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: DWORD; lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD; hTemplateFile: THandle): THandle; stdcall; external kernel32 name {$IFDEF UNICODE} 'CreateFileW' {$ELSE} 'CreateFileA' {$ENDIF};
function SetFilePointer(hFile: THandle; lDistanceToMove: Longint; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall; external kernel32 name 'SetFilePointer';
function WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD; var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'WriteFile';
function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'ReadFile';
function GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall; external kernel32 name 'GetFileSize';
function SetEndOfFile(hFile: THandle): BOOL; stdcall; external kernel32 name 'SetEndOfFile';
function CloseHandle(hObject: THandle): BOOL; stdcall; external kernel32 name 'CloseHandle';
function GetFileAttributes(lpFileName: PChar): DWORD; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetFileAttributesW' {$ELSE} 'GetFileAttributesA' {$ENDIF};
function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD; const lpMultiByteStr: LPCSTR; cchMultiByte: Integer; lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer; stdcall; external kernel32 name 'MultiByteToWideChar';
function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD; lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR; cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer; stdcall; external kernel32 name 'WideCharToMultiByte';
function SetErrorMode(uMode: UINT): UINT; stdcall; external kernel32 name 'SetErrorMode';
function FindFirstFile(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name {$IFDEF UNICODE} 'FindFirstFileW' {$ELSE} 'FindFirstFileA' {$ENDIF};
function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'FindNextFileW' {$ELSE} 'FindNextFileA' {$ENDIF};
function FindClose(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose';
function CopyFile(lpExistingFileName, lpNewFileName: PChar; bFailIfExists: BOOL): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'CopyFileW' {$ELSE} 'CopyFileA' {$ENDIF};
function CreateDirectory(lpPathName: PChar; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'CreateDirectoryW' {$ELSE} 'CreateDirectoryA' {$ENDIF};
function CompareString(Locale: LCID; dwCmpFlags: DWORD; lpString1: PChar; cchCount1: Integer; lpString2: PChar; cchCount2: Integer): Integer; stdcall; external kernel32 name {$IFDEF UNICODE} 'CompareStringW' {$ELSE} 'CompareStringA' {$ENDIF};
function CreateThread(lpThreadAttributes: Pointer; dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer; dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall; external kernel32 name 'CreateThread';
function ResumeThread(hThread: THandle): DWORD; stdcall; external kernel32 name 'ResumeThread';
function CreateSemaphore(lpSemaphoreAttributes: Pointer; lInitialCount, lMaximumCount: Longint; lpName: PChar): THandle; stdcall; external kernel32 name {$IFDEF UNICODE} 'CreateSemaphoreW' {$ELSE} 'CreateSemaphoreA' {$ENDIF};
function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD; stdcall; external kernel32 name 'WaitForSingleObject';
function ReleaseSemaphore(hSemaphore: THandle; lReleaseCount: Longint; lpPreviousCount: Pointer): BOOL; stdcall; external kernel32 name 'ReleaseSemaphore';
procedure Sleep(dwMilliseconds: DWORD); stdcall; external kernel32 name 'Sleep';

function GetDriveType(lpRootPathName: PChar): UINT; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetDriveTypeW' {$ELSE} 'GetDriveTypeA' {$ENDIF};
function GetLogicalDrives(): DWORD; stdcall; external kernel32 name 'GetLogicalDrives';
function WritePrivateProfileString(lpAppName, lpKeyName, lpString, lpFileName: PChar): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'WritePrivateProfileStringW' {$ELSE} 'WritePrivateProfileStringA' {$ENDIF};
function GetPrivateProfileString(lpAppName, lpKeyName, lpDefault: PChar; lpReturnedString: PChar; nSize: DWORD; lpFileName: PChar): DWORD; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetPrivateProfileStringW' {$ELSE} 'GetPrivateProfileStringA' {$ENDIF};
function GetPrivateProfileInt(lpAppName, lpKeyName: PChar; nDefault: Integer; lpFileName: PChar): UINT; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetPrivateProfileIntW' {$ELSE} 'GetPrivateProfileIntA' {$ENDIF};
function GetPrivateProfileStruct(lpszSection, lpszKey: PChar; lpStruct: Pointer; uSizeStruct: UINT; szFile: PChar): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetPrivateProfileStructW' {$ELSE} 'GetPrivateProfileStructA' {$ENDIF};
function WritePrivateProfileStruct(lpszSection, lpszKey: PChar; lpStruct: Pointer; uSizeStruct: UINT; szFile: PChar): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'WritePrivateProfileStructW' {$ELSE} 'WritePrivateProfileStructA' {$ENDIF};

function GetModuleFileName(hModule: HINST; lpFilename: PChar; nSize: DWORD): DWORD; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetModuleFileNameW' {$ELSE} 'GetModuleFileNameA' {$ENDIF};
function wvsprintf(Output, Format, arglist: pChar ): Integer; external user32 name {$IFDEF UNICODE} 'wvsprintfW' {$ELSE} 'wvsprintfA' {$ENDIF};
procedure GetSystemTime(var lpSystemTime: TSystemTime); stdcall; external kernel32 name 'GetSystemTime';
function GetDateFormat(Locale: DWORD; dwFlags: DWORD; lpDate: PSystemTime; lpFormat: pChar; lpDateStr: pChar; cchDate: Integer): Integer; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetDateFormatW' {$ELSE} 'GetDateFormatA' {$ENDIF};
function GetTimeFormat(Locale: DWORD; dwFlags: DWORD; lpTime: PSystemTime; lpFormat: pChar; lpTimeStr: pChar; cchTime: Integer): Integer; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetTimeFormatW' {$ELSE} 'GetTimeFormatA' {$ENDIF};
function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'FileTimeToLocalFileTime';
function FileTimeToSystemTime(const lpFileTime: TFileTime; var lpSystemTime: TSystemTime): BOOL; stdcall; external kernel32 name 'FileTimeToSystemTime';
procedure RaiseException(dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD; lpArguments: PDWORD); stdcall; external kernel32 name 'RaiseException';
function QueryPerformanceCounter(var lpPerformanceCount: TLargeInteger): BOOL; stdcall; external kernel32 name 'QueryPerformanceCounter';

function FormatMessage(dwFlags: DWORD; lpSource: Pointer; dwMessageId: DWORD; dwLanguageId: DWORD; lpBuffer: PWideChar; nSize: DWORD; Arguments: Pointer): DWORD; stdcall;external kernel32 name {$IFDEF UNICODE} 'FormatMessageW' {$ELSE} 'FormatMessageA' {$ENDIF};
function LoadString(hInstance: HINST; uID: UINT; lpBuffer: PWideChar; nBufferMax: Integer): Integer; stdcall; external user32 name {$IFDEF UNICODE} 'LoadStringW' {$ELSE} 'LoadStringA' {$ENDIF};
function VirtualQuery(lpAddress: Pointer; var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall; external kernel32 name 'VirtualQuery';
function MessageBox(hWnd: THandle; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;  external user32 name {$IFDEF UNICODE} 'MessageBoxW' {$ELSE} 'MessageBoxA' {$ENDIF};
function LoadResource(hModule: HINST; hResInfo: HRSRC): HGLOBAL; stdcall; external kernel32 name 'LoadResource';
function FindResource(hModule: HMODULE; lpName, lpType: PChar): HRSRC; stdcall; external kernel32 name {$IFDEF UNICODE} 'FindResourceW' {$ELSE} 'FindResourceA' {$ENDIF};
function FreeResource(hResData: HGLOBAL): BOOL; stdcall; external kernel32 name 'FreeResource';


(*function CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall; external kernel32 name {$IFDEF UNICODE} 'CreateFileW' {$ELSE} 'CreateFileA' {$ENDIF};
function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall; external kernel32 name 'SetFilePointer';
function WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;
  var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'WriteFile';
function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'ReadFile';
function GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall; external kernel32 name 'GetFileSize';
function SetEndOfFile(hFile: THandle): BOOL; stdcall; external kernel32 name 'SetEndOfFile';
function CloseHandle(hObject: THandle): BOOL; stdcall; external kernel32 name 'CloseHandle';

function GetFileAttributes(lpFileName: PChar): DWORD; stdcall; external kernel32 name {$IFDEF UNICODE} 'GetFileAttributesW' {$ELSE} 'GetFileAttributesA' {$ENDIF};

function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD;
  const lpMultiByteStr: LPCSTR; cchMultiByte: Integer;
  lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer; stdcall; external kernel32 name 'MultiByteToWideChar';
function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD;
  lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR;
  cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer; stdcall; external kernel32 name 'WideCharToMultiByte';

function SetErrorMode(uMode: UINT): UINT; stdcall;  external kernel32 name 'SetErrorMode';

function FindFirstFile(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name {$IFDEF UNICODE} 'FindFirstFileW' {$ELSE} 'FindFirstFileA' {$ENDIF};
function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall; external kernel32 name {$IFDEF UNICODE} 'FindNextFileW' {$ELSE} 'FindNextFileA' {$ENDIF};
function FindClose(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose';
     *)

 {
var
  CreateFile: function(lpFileName: PChar; dwDesiredAccess, dwShareMode: DWORD;
    lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
    hTemplateFile: THandle): THandle; stdcall;
  SetFilePointer: function(hFile: THandle; lDistanceToMove: Longint;
    lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
  WriteFile: function(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;
    var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
  ReadFile: function(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
    var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
  GetFileSize: function(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall;
  SetEndOfFile: function(hFile: THandle): BOOL; stdcall;
  CloseHandle: function(hObject: THandle): BOOL; stdcall;
  GetFileAttributes: function(lpFileName: PChar): DWORD; stdcall;
  MultiByteToWideChar: function(CodePage: UINT; dwFlags: DWORD;
    const lpMultiByteStr: LPCSTR; cchMultiByte: Integer;
    lpWideCharStr: LPWSTR; cchWideChar: Integer): Integer; stdcall;
  WideCharToMultiByte: function(CodePage: UINT; dwFlags: DWORD;
    lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR;
    cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer; stdcall;
  SetErrorMode: function(uMode: UINT): UINT; stdcall;
  FindFirstFile: function(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall;
  FindNextFile: function(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall;
  FindClose: function(hFindFile: THandle): BOOL; stdcall;
  CopyFile: function(lpExistingFileName, lpNewFileName: PChar; bFailIfExists: BOOL): BOOL; stdcall;
  CreateDirectory: function(lpPathName: PChar; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
  CompareString: function(Locale: LCID; dwCmpFlags: DWORD; lpString1: PChar; cchCount1: Integer; lpString2: PChar; cchCount2: Integer): Integer; stdcall;
  ResumeThread: function(hThread: THandle): DWORD; stdcall;
  CreateThread: function(lpThreadAttributes: Pointer; dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer; dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall;

  GetDriveType: function(lpRootPathName: PChar): UINT; stdcall;
  GetLogicalDrives: function: DWORD; stdcall;
  WritePrivateProfileString: function(lpAppName, lpKeyName, lpString, lpFileName: PChar): BOOL; stdcall;
  GetPrivateProfileString: function(lpAppName, lpKeyName, lpDefault: PChar; lpReturnedString: PChar; nSize: DWORD; lpFileName: PChar): DWORD; stdcall;
  GetPrivateProfileInt: function(lpAppName, lpKeyName: PChar; nDefault: Integer; lpFileName: PChar): UINT; stdcall;
  GetPrivateProfileStruct: function(lpszSection, lpszKey: PChar; lpStruct: Pointer; uSizeStruct: UINT; szFile: PChar): BOOL; stdcall;
  WritePrivateProfileStruct: function(lpszSection, lpszKey: PChar; lpStruct: Pointer; uSizeStruct: UINT; szFile: PChar): BOOL; stdcall;
  CreateSemaphore: function(lpSemaphoreAttributes: Pointer; lInitialCount, lMaximumCount: Longint; lpName: PChar): THandle; stdcall;
  WaitForSingleObject: function(hHandle: THandle; dwMilliseconds: DWORD): DWORD; stdcall;
  ReleaseSemaphore: function(hSemaphore: THandle; lReleaseCount: Longint; lpPreviousCount: Pointer): BOOL; stdcall;

  GetModuleFileName: function(hModule: HINST; lpFilename: PChar; nSize: DWORD): DWORD; stdcall;
  wvsprintf: function(Output, Format, arglist: pChar ): Integer;
  GetDateFormat: function(Locale: DWORD; dwFlags: DWORD; lpDate: PSystemTime; lpFormat: pChar; lpDateStr: pChar; cchDate: Integer): Integer; stdcall;
  GetTimeFormat: function(Locale: DWORD; dwFlags: DWORD; lpTime: PSystemTime; lpFormat: pChar; lpTimeStr: pChar; cchTime: Integer): Integer; stdcall;
  FileTimeToLocalFileTime: function(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall;
  FileTimeToSystemTime: function(const lpFileTime: TFileTime; var lpSystemTime: TSystemTime): BOOL; stdcall;

  RaiseException: procedure(dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD; lpArguments: PDWORD); stdcall;

           }

//{$ENDIF}

function MakeWord(a, b: Byte): Word; inline;
{$EXTERNALSYM MakeWord}
function MakeLong(a, b: Word): Longint; inline;
{$EXTERNALSYM MakeLong}

type
  LOWORD = Word;
  {$EXTERNALSYM LOWORD}

function HiWord(l: DWORD): Word; inline;
{$EXTERNALSYM HiWord}

type
  LOBYTE = Byte;
  {$EXTERNALSYM LOBYTE}

function HiByte(W: Word): Byte; inline;



implementation

{$IFDEF WIN}

function MakeWord(A, B: Byte): Word;
begin
  Result := A or B shl 8;
end;

function MakeLong(A, B: Word): Longint;
begin
  Result := A or B shl 16;
end;

function HiWord(L: DWORD): Word;
begin
  Result := L shr 16;
end;

function HiByte(W: Word): Byte;
begin
  Result := W shr 8;
end;

      {
function GetProcAddress(hModule: HMODULE; lpProcName: LPCWSTR): FARPROC;
begin
  if ULONG_PTR(lpProcName) shr 16 = 0 then // IS_INTRESOURCE
    Result := GetProcAddress(hModule, LPCSTR(lpProcName))
  else
    Result := GetProcAddress(hModule, LPCSTR(AnsiString(lpProcName)));
end;  }

 (*
var
  KernelLib,
  UserLib: THandle;

initialization
  KernelLib:=LoadLibrary(pChar(kernel32));
  if KernelLib=INVALID_HANDLE_VALUE then
    Halt(1);
  UserLib:=LoadLibrary(pChar(user32));
  if UserLib=INVALID_HANDLE_VALUE then
    Halt(1);

  CreateFile:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'CreateFileW' {$ELSE} 'CreateFileA' {$ENDIF});
  SetFilePointer:=GetProcAddress(KernelLib, 'SetFilePointer');
  WriteFile:=GetProcAddress(KernelLib, 'WriteFile');
  ReadFile:=GetProcAddress(KernelLib, 'ReadFile');
  GetFileSize:=GetProcAddress(KernelLib, 'GetFileSize');
  SetEndOfFile:=GetProcAddress(KernelLib, 'SetEndOfFile');
  CloseHandle:=GetProcAddress(KernelLib, 'CloseHandle');
  GetFileAttributes:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetFileAttributesW' {$ELSE} 'GetFileAttributesA' {$ENDIF});
  MultiByteToWideChar:=GetProcAddress(KernelLib, 'MultiByteToWideChar');
  WideCharToMultiByte:=GetProcAddress(KernelLib, 'WideCharToMultiByte');
  SetErrorMode:=GetProcAddress(KernelLib, 'SetErrorMode');
  FindFirstFile:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'FindFirstFileW' {$ELSE} 'FindFirstFileA' {$ENDIF});
  FindNextFile:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'FindNextFileW' {$ELSE} 'FindNextFileA' {$ENDIF});
  FindClose:=GetProcAddress(KernelLib, 'FindClose');
  CopyFile:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'CopyFileW' {$ELSE} 'CopyFileA' {$ENDIF});
  CreateDirectory:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'CreateDirectoryW' {$ELSE} 'CreateDirectoryA' {$ENDIF});
  CompareString:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'CompareStringW' {$ELSE} 'CompareStringA' {$ENDIF});
  CreateThread:=GetProcAddress(KernelLib, 'CreateThread');
  ResumeThread:=GetProcAddress(KernelLib, 'ResumeThread');
  CreateSemaphore:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'CreateSemaphoreW' {$ELSE} 'CreateSemaphoreA' {$ENDIF});
  WaitForSingleObject:=GetProcAddress(KernelLib, 'WaitForSingleObject');
  ReleaseSemaphore:=GetProcAddress(KernelLib, 'ReleaseSemaphore');

  GetDriveType:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetDriveTypeW' {$ELSE} 'GetDriveTypeA' {$ENDIF});
  GetLogicalDrives:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetLogicalDrivesW' {$ELSE} 'GetLogicalDrivesA' {$ENDIF});
  WritePrivateProfileString:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'WritePrivateProfileStringW' {$ELSE} 'WritePrivateProfileStringA' {$ENDIF});
  GetPrivateProfileString:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetPrivateProfileStringW' {$ELSE} 'GetPrivateProfileStringA' {$ENDIF});
  GetPrivateProfileInt:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetPrivateProfileIntW' {$ELSE} 'GetPrivateProfileIntA' {$ENDIF});
  GetPrivateProfileStruct:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetPrivateProfileStructW' {$ELSE} 'GetPrivateProfileStructA' {$ENDIF});
  WritePrivateProfileStruct:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'WritePrivateProfileStructW' {$ELSE} 'WritePrivateProfileStructA' {$ENDIF});

  GetModuleFileName:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetModuleFileNameW' {$ELSE} 'GetModuleFileNameA' {$ENDIF});
  wvsprintf:=GetProcAddress(UserLib, {$IFDEF UNICODE} 'wvsprintfW' {$ELSE} 'wvsprintfA' {$ENDIF});
  GetDateFormat:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetDateFormatW' {$ELSE} 'GetDateFormatA' {$ENDIF});
  GetTimeFormat:=GetProcAddress(KernelLib, {$IFDEF UNICODE} 'GetTimeFormatW' {$ELSE} 'GetTimeFormatA' {$ENDIF});
  FileTimeToLocalFileTime:=GetProcAddress(KernelLib, 'FileTimeToLocalFileTime');
  FileTimeToSystemTime:=GetProcAddress(KernelLib, 'FileTimeToSystemTime');
  RaiseException:=GetProcAddress(KernelLib, 'RaiseException');

finalization
  FreeLibrary(KernelLib);
  FreeLibrary(UserLib); *)

{$ENDIF}

end.
