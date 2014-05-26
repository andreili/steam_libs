unit USE_Types;

interface

{$I defines.inc}

uses
  Windows, Types;

type
  TPackageType =
    (PACKAGE_NONE = 0,
     PACKAGE_GCF = 1,
     PACKAGE_NCF = 2,
     PACKAGE_PAK = 3,
     PACKAGE_VPK = 4,
     PACKAGE_ANOTHER = 11);

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


  TOnError = procedure(ItemName: string; ErrorCode: integer; Data: Pointer); stdcall;
  TOnErrorObj = procedure(ItemName: string; ErrorCode: integer; Data: Pointer) of object; stdcall;
  TOnProgress = procedure(Text: string; CurPos, MaxPos: int64; Data: Pointer); stdcall;
  TOnProgressObj = procedure(Text: string; CurPos, MaxPos: int64; Data: Pointer) of object; stdcall;
  TLoadingProgressProc = procedure(CaptionMain, CaptionProgress: string; CurrentProg, TotalProg: integer) of object;
  TAddTreeItemProc = function(Root: Pointer; Caption: string; ItemIdx: integer): Pointer of object;
  TAddFileItemProc = procedure(Caption: string; ItemIdx: integer; ItemSize: uint64) of object;

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

  TIntArray = array of integer;

  PWordArray = ^TWordArray;
  TWordArray = array[0..16383] of Word;

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

  I64 = record
  {* 64 bit integer record. Use it and correspondent functions below in KOL
     projects to avoid dependancy from Delphi version (earlier versions of
     Delphi had no Int64 type). }
    Lo, Hi: DWORD;
  end;

  TSysCharSet = set of AnsiChar;
  TCardinalDynArray = array of ulong;
  pCardinalDynArray = ^TCardinalDynArray;

const
  ERROR_STOP = 1;
  ERROR_CHECKSUM = 2;
  ERROR_INCOMPLETE = 3;

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

  ofOpenRead          = {$IFDEF LIN} O_RDONLY {$ELSE} $80000000 {$ENDIF};
  {* Use this flag (in combination with others) to open file for "read" only. }
  ofOpenWrite         = {$IFDEF LIN} O_WRONLY {$ELSE} $40000000 {$ENDIF};
  {* Use this flag (in combination with others) to open file for "write" only. }
  ofOpenReadWrite     = {$IFDEF LIN} O_RDWR {$ELSE} $C0000000 {$ENDIF};
  {* Use this flag (in combination with others) to open file for "read" and "write". }

  ofShareExclusive    = {$IFDEF LIN} $10 {$ELSE} $00 {$ENDIF};
  {* Use this flag (in combination with others) to open file for exclusive use. }
  ofShareDenyWrite    = {$IFDEF LIN} $20 {$ELSE} $01 {$ENDIF};
  {* Use this flag (in combination with others) to open file in share mode, when
     only attempts to open it in other process for "write" will be impossible.
     I.e., other processes could open this file simultaneously for read only
     access. }
  ofShareDenyRead     = {$IFDEF LIN} 0 {not supported} {$ELSE} $02 {$ENDIF};
  {* Use this flag (in combination with others) to open file in share mode, when
     only attempts to open it for "read" in other processes will be disabled.
     I.e., other processes could open it for "write" only access. }
  ofShareDenyNone     = {$IFDEF LIN} $30 {$ELSE} $03 {$ENDIF};
  {* Use this flag (in combination with others) to open file in full sharing mode.
     I.e. any process will be able open this file using the same share flag. }
  ofCreateNew         = {$IFDEF LIN} O_CREAT or O_TRUNC {$ELSE} $100 {$ENDIF};
  {* Default creation disposition. Use this flag for creating new file (usually
     for write access. }
  ofCreateAlways      = {$IFDEF LIN} O_CREAT {$ELSE} $200 {$ENDIF};
  {* Use this flag (in combination with others) to open existing or creating new
     file. If existing file is opened, it is truncated to size 0. }
  ofOpenExisting      = {$IFDEF LIN} 0 {$ELSE} $300 {$ENDIF};
  {* Use this flag (in combination with others) to open existing file only. }
  ofOpenAlways        = {$IFDEF LIN} O_CREAT {$ELSE} $400 {$ENDIF};
  {* Use this flag (in combination with others) to open existing or create new
     (if such file is not yet exists). }
  ofTruncateExisting  = {$IFDEF LIN} O_TRUNC {$ELSE} $500 {$ENDIF};
  {* Use this flag (in combination with others) to open existing file and truncate
     it to size 0. }

const
  SEEK_BEGIN    = 0;
  SEEK_CURRENT  = 1;
  SEEK_END      = 2;

  ACCES_READ = 1;
  ACCES_WRITE = 2;
  ACCES_READWRITE = 3;

type
  TItemSize = record
      Size,
      CSize: int64;
      Folders,
      Files,
      CFiles,
      Sectors: ulong;
    end;

  pFindRecord = ^TFindRecord;
  TFindRecord = record
      IsLocalSearch: boolean;
      FindHandle: ulong;
      Mask,
      PathToFile: pChar;
      ItemRoot,
      ItemCurrent: record
          Package: Pointer;
          ItemIdx: integer;
        end;
    end;

// TStream
{$REGION}
  TStrmSize = int64;
  TStrmMove = int64;
  TMoveMethod = (spBegin, spCurrent, spEnd);

  TStream = class;

  pStreamMethods = ^TStreamMethods;
  TStreamMethods = packed record
    fSeek: function(Strm: TStream; MoveTo: TStrmMove; MoveMethod: TMoveMethod): TStrmSize;
    fGetSiz: function(Strm: TStream): TStrmSize;
    fSetSiz: procedure(Strm: TStream; Value: TStrmSize);
    fRead: function(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize;
    fWrite: function(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize;
    fClose: procedure(Strm: TStream);
    fCustom: Pointer;
    fWait: procedure(Strm: TStream);
  end;

  pStreamData = ^TStreamData;
  TStreamData = packed record
    IsChange: boolean;
    IsExMem: boolean;
    fHandle: THandle;
    fCapacity, fSize, fPosition: TStrmSize;

    Package: TObject;
    FileStream: TStream;
    SectorsTable: TCardinalDynArray;
  end;

  TStream = class(TObject)
  protected
    fPMethods: pStreamMethods;
    fMethods: TStreamMethods;
    fMemory: Pointer;
    //fData: TStreamData;
    function GetCapacity: TStrmSize; inline;
    procedure SetCapacity(const Value: TStrmSize); inline;
  protected
    function GetFileStreamHandle: THandle; inline;
    procedure SetPosition(const Value: TStrmSize); inline;
    function GetPosition: TStrmSize; inline;
    function GetSize: TStrmSize; inline;
    procedure SetSize(const NewSize: TStrmSize); inline;
  public
    Data: TStreamData;
    destructor Destroy; override;
    constructor Create(Methods: TStreamMethods);
    constructor CreateFileStream(const FileName: string; Mode: ulong);
    constructor CreateReadFileStream(const FileName: string); overload;
    constructor CreateWriteFileStream(const FileName: string); overload;
    constructor CreateReadWriteFileStream(const FileName: string); overload;
    {constructor CreateReadFileStream(const FileName: AnsiString); overload;
    constructor CreateWriteFileStream(const FileName: AnsiString); overload;
    constructor CreateReadWriteFileStream(const FileName: AnsiString); overload; }
    constructor CreateMemoryStream();
    constructor CreateMemoryStreamEx(AData: Pointer; PointerSize: TStrmSize);
    constructor CreateStreamOnStream(Procs: pStreamMethods);

    function Read(var Buffer; const Count: TStrmSize): TStrmSize; //inline;
    function ReadStrZ(): AnsiString;
    function ReadStrLen(Len: Integer): string;
    function ReadStrLenAnsi(Len: Integer): AnsiString;
    function ReadStr: AnsiString;
    function ReadStrWide: WideString;
    function Seek(MoveTo: TStrmMove; MoveMethod: TMoveMethod): TStrmSize;inline;
    function Write(const Buffer; Count: TStrmSize): TStrmSize;
    function WriteAnsiStr(Str: AnsiString): TStrmSize;inline;
    function WriteWideStr(Str: WideString): TStrmSize;inline;
    property Size: TStrmSize read GetSize write SetSize;
    property Position: TStrmSize read GetPosition write SetPosition;
    property Memory: Pointer read fMemory;
    {* Only for memory stream. }
    property Handle: THandle read GetFileStreamHandle;
    {* Only for file stream. It is possible to check that Handle <>
       INVALID_HANDLE_VALUE to ensure that file stream is created OK. }

    property Methods: PStreamMethods read fPMethods;
    //property Data: TStreamData read fData write fData;

    property Capacity: TStrmSize read GetCapacity write SetCapacity;
  end;
{$ENDREGION}

// TList
{$REGION}
  TList = class(TObject)
  {* Simple list of pointers. It is used in KOL instead of standard VCL
     TList to store any kind data (or pointers to these ones). Can be created
     calling function NewList. }
  {= Простой список указателей. }
  protected
    fItems: PPointerList;
    fCount: Integer;
    fCapacity: Integer;
    fAddBy: Integer;
    procedure SetCount(const Value: Integer);
    procedure SetAddBy(Value: Integer);

    procedure SetCapacity( Value: Integer );
    function Get( Idx: Integer ): Pointer;
    procedure Put( Idx: Integer; Value: Pointer );
  protected
    {$IFDEF TLIST_FAST}
    fBlockList: PList;
    fLastKnownBlockIdx: Integer;
    fLastKnownCountBefore: Integer;
    fUseBlocks: Boolean;
    {$ENDIF}
  public
    constructor Create();
    destructor Destroy; override;

    procedure Clear;
    {* Makes Count equal to 0. Not responsible for freeing (or destroying)
       data, referenced by released pointers. }
    procedure Add( Value: Pointer );
    {* Adds pointer to the end of list, increasing Count by one. }
    procedure Insert( Idx: Integer; Value: Pointer );
    {* Inserts pointer before given item. Returns Idx, i.e. index of
       inserted item in the list. Indeces of items, located after insertion
       point, are increasing. To add item to the end of list, pass Count
       as index parameter. To insert item before first item, pass 0 there. }
    function IndexOf( Value: Pointer ): Integer;
    {* Searches first (from start) item pointer with given value and returns
       its index (zero-based) if found. If not found, returns -1. }
    procedure Delete( Idx: Integer );
    {* Deletes given (by index) pointer item from the list, shifting all
       follow item indeces up by one. }
    procedure DeleteRange( Idx, Len: Integer );
    {* Deletes Len items starting from Idx. }
    procedure Remove( Value: Pointer );
    {* Removes first entry of a Value in the list. }
    property Count: Integer read fCount write SetCount;
    {* Returns count of items in the list. It is possible to delete a number
       of items at the end of the list, keeping only first Count items alive,
       assigning new value to Count property (less then Count it is). }
    property Capacity: Integer read fCapacity write SetCapacity;
    {* Returns number of pointers which could be stored in the list
       without reallocating of memory. It is possible change this value
       for optimize usage of the list (for minimize number of reallocating
       memory operations). }
    property Items[ Idx: Integer ]: Pointer read Get write Put; default;
    {* Provides access (read and write) to items of the list. Please note,
       that TList is not responsible for freeing memory, referenced by stored
       pointers. }
    function Last: Pointer;
    {* Returns the last item (or nil, if the list is empty). }
    procedure Swap( Idx1, Idx2: Integer );
    {* Swaps two items in list directly (fast, but without testing of
       index bounds). }
    procedure MoveItem( OldIdx, NewIdx: Integer );
    {* Moves item to new position. Pass NewIdx >= Count to move item
       after the last one. }
    procedure Release;
    {* Especially for lists of pointers to dynamically allocated memory.
       Releases all pointed memory blocks and destroys object itself. }
    procedure ReleaseObjects;
    {* Especially for a list of objects derived from TObj.
       Calls Free for every of the object in the list, and then calls
       Free for the object itself. }
    property AddBy: Integer read fAddBy write SetAddBy;
    {* Value to increment capacity when new items are added or inserted
       and capacity need to be increased. }
    property DataMemory: PPointerList read fItems;
    {* Raw data memory. Can be used for direct access to items of a list.
       Do not use it for TLIST_FAST ! }
    procedure Assign( SrcList: TList );
    {* Copies all source list items. }
    {$IFDEF _D4orHigher}
    procedure AddItems( const AItems: array of Pointer );
    {* Adds a list of items given by a dynamic array. }
    {$ENDIF}
    function ItemAddress( Idx: Integer ): Pointer;
    {* Returns an address of memory occupying by the item with index Idx.
       (If the item is a pointer, returned value is a pointer to a pointer).
       Item with index requested must exist. }
  {$IFDEF TLIST_FAST}
    property UseBlocks: Boolean read fUseBlocks write fUseBlocks;
  {$ENDIF}
  end;
{$ENDREGION}

// TIniFile
{$REGION}
  TIniFileMode = ( ifmRead, ifmWrite );
  {* ifmRead is default mode (means "read" data from ini-file.
     Set mode to ifmWrite to write data to ini-file, correspondent to
     TIniFile. }

  TIniFile = class (TObject)
  {* Ini file incapsulation. The main feature is what the same block of
     read-write operations could be defined (difference must be only in
     Mode value).
     |*Ini file sample.
     This sample shows how the same Pascal operators can be used both
     for read and write for the same variables, when working with TIniFile:
     !    procedure ReadWriteIni( Write: Boolean );
     !    var Ini: PIniFile;
     !    begin
     !      Ini := OpenIniFile( 'MyIniFile.ini' );
     !      Ini.Section := 'Main';
     !      if Write then            // if Write, the same operators will save
     !         Ini.Mode := ifmWrite; // data rather then load.
     !      MyForm.Left := Ini.ValueInteger( 'Left', MyForm.Left );
     !      MyForm.Top  := Ini.ValueInteger( 'Top',  MyForm.Top );
     !      Ini.Free;
     !    end;
     !
     |*  }
  protected
    fMode: TIniFileMode;
    fFileName: String;
    fSection: String;
  protected
  public
    constructor Create(const FileName: String);
    destructor Destroy; {-}override;{+}{++}(*override;*){--}
    {* destructor }
    property Mode: TIniFileMode read fMode write fMode;
    {* ifmWrite, if write data to ini-file rather than read it. }
    property FileName: String read fFileName;
    {* Ini file name. }
    property Section: String read fSection write fSection;
    {* Current ini section. }
    function ValueInteger( const Key: String; Value: Integer ): Integer;
    {* Reads or writes integer data value. }
    function ValueString( const Key: String; const Value: String ): String;
    {* Reads or writes Double data value. }
    function ValueBoolean( const Key: String; Value: Boolean ): Boolean;
    {* Reads or writes Boolean data value. }
    function ValueData( const Key: String; Value: Pointer; Count: Integer ): Boolean;
    {* Reads or writes data from/to buffer. Returns True, if success. }
    procedure ClearAll;
    {* Clears all sections of ini-file. }
    procedure ClearSection;
    {* Clears current Section of ini-file. }
    procedure ClearKey( const Key: String );
    {* Clears given key in current section. }
         (*
    /////////////// + by Vyacheslav A. Gavrik:
    procedure GetSectionNames(Names:PKOLStrList);
    {* Retrieves section names, storing it in string list passed as a parameter.
       String list does not cleared before processing. Section names are added
       to the end of the string list. }
    procedure SectionData(Names:PKOLStrList);
    {* Read/write current section content to/from string list. (Depending on
       current Mode value). }
    ///////////////           *)

  end;
{$ENDREGION}

  TThread = class;
  TThreadProc = function(Sender: TThread): integer of object;
  TThread = class (TObject)
    private
      fHandle: THANDLE;
      fThreadID: DWORD;
    public
      Data: Pointer;
      OnExecute: TThreadProc;
      AutoFree: boolean;
      procedure Resume(); inline;
      constructor Create();
      constructor CreateAutoFree(Proc: TThreadProc);
      destructor Destroy(); override;
  end;

function FileCreate(const FileName: string; OpenFlags: DWord): THandle; inline;
function FileSeek(Handle: THandle; MoveTo: TStrmMove; MoveMethod: TMoveMethod): TStrmSize; inline;
function FileRead(Handle: THandle; var Buffer; Count: DWord): DWord; inline;
function FileWrite(Handle: THandle; const Buffer; Count: DWord): DWord; inline;
function FileClose(Handle: THandle): Boolean; inline;

function SeekFileStream(Strm: TStream; MoveTo: TStrmMove; MoveFrom: TMoveMethod): TStrmSize; inline;
function GetSizeFileStream(Strm: TStream): TStrmSize; inline;
procedure SetSizeFileStream(Strm: TStream; NewSize: TStrmSize); inline;
function ReadFileStream(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize; inline;
function WriteFileStream(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
var ReadFileStreamProc: function(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize = ReadFileStream;
procedure CloseFileStream(Strm: TStream); inline;

function SeekMemStream(Strm: TStream; MoveTo: TStrmMove; MoveFrom: TMoveMethod): TStrmSize; inline;
function GetSizeMemStream(Strm: TStream): TStrmSize; inline; inline;
procedure SetSizeMemStream(Strm: TStream; NewSize: TStrmSize); inline;
function ReadMemStream(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize; inline;
function WriteMemStream(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
procedure CloseMemStream(Strm: TStream); inline;

implementation

uses
  USE_Utils;

{$I USE_Types_SteamProcs.inc}
{$I USE_Types_Win.inc}
{$I USE_Types_List.inc}

function ThreadFunc(Thread: TThread): integer; stdcall;
begin
  result:=1;
  if Assigned(Thread.OnExecute) then
    Result := Thread.OnExecute(Thread);
  if Thread.AutoFree then
    Thread.Free;
end;

procedure TThread.Resume();
begin
  ResumeThread(fHandle);
end;

constructor TThread.Create();
begin
  inherited;
  fHandle:=CreateThread( nil, // no security
                                  0,   // the same stack size
                                  @ThreadFunc, // thread entry point
                                  self,      // parameter to pass to ThreadFunc
                                  $00000004,   // always SUSPENDED
                                  FThreadID ); // receive thread ID
end;

constructor TThread.CreateAutoFree(Proc: TThreadProc);
begin
  inherited;
  OnExecute:=Proc;
  fHandle:=CreateThread( nil, // no security
                                  0,   // the same stack size
                                  @ThreadFunc, // thread entry point
                                  self,      // parameter to pass to ThreadFunc
                                  0,
                                  FThreadID ); // receive thread ID
  AutoFree:=true;
  //Resume();
end;

destructor TThread.Destroy();
begin
  inherited Destroy();
  OnExecute:=nil;
  CloseHandle(fHandle);
end;


end.
