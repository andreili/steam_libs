unit SL_Interfaces;

interface

uses
  ShareMem, Windows, USE_Types, Sockets;

{$I defines.inc}

const
  CORE_VERSION: uint32 = 1;

  // коды операций между сервером и клиентом
  MESS_GET_SETTINGS_VALUE: uint32 = $1001;
  MESS_GET_APPS_LIST: uint32 = $1002;
  MESS_GET_IS_APP_BUSY: uint32 = $1003;
  MESS_GET_APP_PROPERTIES: uint32 = $1004;
  MESS_GET_CACHE_PROPERTIES: uint32 = $1005;

  MESS_WORK_GET_STATE: uint32 = $2001;
  MESS_WORK_ADD: uint32 = $2002;
  MESS_WORK_PAUSE: uint32 = $2003;
  MESS_WORK_STOP: uint32 = $2004;
  MESS_WORK_RESUME: uint32 = $2005;

  MESS_SHUTDOWN: uint32 = $ffff;

  // флаги типов списков пользовательского интерфейса
  LIST_INSTALLED_GAMES      = $0001;
  LIST_INSTALLED_MEDIA      = $0002;
  LIST_INSTALLED_TOOLS      = $0004;
  LIST_INSTALLED_CACHES     = $0008;
  LIST_INSTALL_APPLICATIONS = $0010;
  LIST_INSTALL_CACHES       = $0020;

  // секции файла настроек
  SECTION_GENERAL = $1000;
   VALUE_CACHE_PATH = $1001;
   VALUE_USER_PATH = $1002;
   VALUE_LANGUAGE = $1003;
   VALUE_MAXWORKS = $1004;
   VALUE_SHOWDEMO = $1005;
   VALUE_SHOWTEST = $1006;
  SECTION_NETWORK = $2000;
   VALUE_SERVER_ADDR = $2001;
   VALUE_UPDATE_CDR  = $2002;
  SECTION_LOG = $3000;
   VALUE_LOG_CDR = $3001;
   VALUE_LOG_CACHES = $3002;
   VALUE_LOG_GAMES = $3003;
   VALUE_LOG_LEVEL = $3004;

  VALUE_LANGUAGES_FILES_LIST = $f001;

  LOG_LEVEL_SHOW_INFOS = $0001;
  LOG_LEVEL_SHOW_ERRORS = $0002;

  KBYTE = 1024;
  MBYTE = KBYTE*KBYTE;
  GBYTE = KBYTE*KBYTE*KBYTE;

  ITEM_ROOT: uint32 = 0;

type
  TTypeDrives = (tdHDD, tdCD, tdFlopy, tdRemote, tdRamDisk, tdNone);

type
  EEncoding =
    (ENCODING_UNICODE,
     ENCODING_ANSI);

  EInterfaceType =
    (INTERFACE_CORE,              // список остальных интерфейсов
     INTERFACE_LOG,               //+
     INTERFACE_UTILS,             //+интерфейс с различными вспомогательными функциями
     INTERFACE_SETTINGS,          //+доступ к настройкам
     INTERFACE_TRANSLATION,       //+реализация многоязыковой поддержки
     INTERFACE_APPLICATION_LIST,  // реализация работы со списком приложений (игры, инструменты, медиа, файлы кэша)
     INTERFACE_WORK_LIST,         // реализация работы с заданиями (добавление, удаление, приостановка и т.п.)
     INTERFACE_WORK,
     INTERFACE_UI,                // реализация пользовательского интерфейса
     INTERFACE_WINDOW,
     INTERFACE_NETWORK,           // реализация сетевых протоколов
     INTERFACE_P2P,               // реализация p2p сети
     INTERFACE_GAME_CONVERTER,    // конвертирование игр
     INTERFACE_FILE_FORMATS,      //+универсальный класс для работы с файлами
     INTERFACE_FILE_FORMAT,       // реализация работы с конкретным форматом файлов (могут различаться дополнительными функциями после основных)
     INTERFACE_FILE,              // реализация работы с конкретным файлом (могут различаться дополнительными функциями после основных)
     INTERFACE_APPLICATION,       // общий класс для работы с приложениями
     INTERFACE_APP,               // промежуточный клас (набор методов), общий для приложений (не для файлов кэша!)
     INTERFACE_CACHE,             // работа с отдельным файлом кэша        \
     INTERFACE_GAME,              // работа с отдельной игрой               -- в {INTERFACE_APPLICATION_LIST} хранится массив этих интерфейсов,
     INTERFACE_MEDIA,             // работа с отдельным медиа-приложением   --   приведенных к типу INTERFACE_APP
     INTERFACE_TOOLS,             // работа с отдельным инструментом       /
     INTERFACE_NONE = 255);

  EFileType =
    (FILE_CACHE = 0,              // GCF/NCF
     FILE_ARCHIVE,
     FILE_IMAGE,
     FILE_TEXT,
     FILE_HTML,                   // при открытии на просмотр распаковываются так же и другие требуемые файлы
     FILE_NONE = 255);

  EEmulator =
    (EMULATOR_HCUPA = 0,
     EMULATOR_REV,
     EMULATOR_OTHER = 255);

  EConvertResult =
    (CONVERT_OK = 0,
     CONVERT_PATH_NOT_EXISTS,
     CONVERT_PATCH_APPLY_FAILED,
     CONVERT_FAILED = 255);

  ELoadListResult =
    (LOAD_LIST_OK = 0,
     LOAD_LIST_FAILED = 255);

  EApplicationType =
    (APPLICATION_CACHE = 0,
     APPLICATION_GAME,
     APPLICATION_MEDIA,
     APPLICATION_TOOLS);

  EUpdateCDR =
    (UPDATE_CDR_OK = 0,
     UPDATE_CDR_LOST_CONNECT,
     UPDATE_CDR_FAILED = 255);

  ECacheType =
    (CACHE_GCF = 0,
     CACHE_NCF,
     CACHE_OTHER = 255);

  EWorkType =
    (WORK_LOAD_CORE = 0,
     WORK_OPEN,
     WORK_VALIDATE,
     WORK_CORRECT,
     WORK_CREATE_MINI_GCF,
     WORK_DOWNLOAD,
     WORK_CREATE_ARCHIVE,
     WORK_CREATE_UPDATE,
     WORK_APPLY_UDATE,
     WORK_LAUNCH,
     WORK_CREATE_STAND_ALONE_APPLICATION,
     WORK_CREATE_GCF_APPLICATION);

  EWorkState =
    (WORK_STATE_OK = 0,
     WORK_STATE_IDLE,
     WORK_STATE_RUN,
     WORK_STATE_STOP,
     WORK_STATE_PAUSED,
     WORK_STATE_ERROR = 255);

  EWorkError =
    (WORK_ERROR_STOP = 0,
     WORK_ERROR_CHECKSUM,
     WORK_ERROR_INCOMPLETE,
     WORK_ERROR_OTHER = 255);

  EValidateResult =
    (VALIDATE_OK = 0,
     VALIDATE_CHECKSUM_ERROR,
     VALIDATE_INCOMPLETE);

 { EOpenMode =
    (OPEN_READ,
     OPEN_WRITE,
     OPEN_READWRITE);  }

  pClientAppRecord = ^TClientAppRecord;
  TClientAppRecord = packed record
    IsLoaded: boolean;
    AppType: EApplicationType;
    Name: array[0..254] of char;
    Developer: array[0..254] of char;
    CommonPath: array[0..254] of char;
    AppID: uint32;
    AppVersion: uint32;
    AppSize: uint64;
    Complention: single;
  end;

  pDetailedAppInfo = ^TDetailedAppInfo;
  TDetailedAppInfo = packed record
    BaseInfo: TClientAppRecord;
    HomePage: array[0..254] of char;
    CachesCount: integer;
    Caches: array[0..1023] of TClientAppRecord;
    UDRCount: integer;
    UDR: array[0..1023] of record
        Name,
        Value: array[0..254] of char;
      end;
  end;

  TWorkState = record
    Max,
    Current: int64;
    Caption: array[0..254] of char;
  end;

type
  ISLInterface = interface
    ['{43D77C46-9C0C-4530-8A9B-86DB949D0B10}']
    function GetEncoding(): EEncoding; stdcall;       // кодировка, с которой работает класс (ONLY UNICODE!)
    function GetType(): EInterfaceType; stdcall;      // тип интерфейса для его точной идентификации
    function Init(): boolean; stdcall;
    procedure DeInit(); stdcall;
  end;

  ILog = interface (ISLInterface)
    function AddEvent(Caption: pChar): integer; stdcall;
    procedure AddEventEx(Caption, Res: pChar); stdcall;
    procedure SetEventResult(EventIdx: integer; Res: pChar); stdcall;
    function GetEventCaption(EventIdx: integer): pChar; stdcall;
    function GetEventResult(EventIdx: integer): pChar; stdcall;
    procedure DeleteTmpEvent(EventIdx: integer); stdcall;
  end;

  ITranslation = interface (ISLInterface)
    function SetLanguage(Name: pChar): boolean; stdcall;
    function GetTitle(Name: pChar): pChar; stdcall;
    function GetLanguagesList(): pChar; stdcall;
  end;

  ISettings = interface (ISLInterface)
    function GetStringValue(ValueID: uint32): pChar; stdcall;
    procedure SetStringValue(ValueID: uint32; Value: pChar); stdcall;
    function GetBooleanValue(ValueID: uint32): boolean; stdcall;
    procedure SetBooleanValue(ValueID: uint32; Value: boolean); stdcall;

    function Get_Log_All_Levels(): uint32; stdcall;
  end;

  IUtils = interface (ISLInterface)
    function GetFileList(dir, mask: pChar): pChar; stdcall;
    function GetDPNE(DPNEComplette: pChar; DPNEDif: pChar): pChar; stdcall;
    function AddExt(FileName, Ext: pChar): pChar; stdcall;
    function GetDrives(): pChar; stdcall;
    function GetTypeDrives(CharDrives: char): TTypeDrives; stdcall;
    function GetDrivesEx(TypeDrives: TTypeDrives): pChar; stdcall;
    function GetSizeTitle(Size: int64): pChar; stdcall;
    function RoundMax(Num: real; Max: integer): real; stdcall;
    //function uncompress(dest: Pointer; destLen: ulong; source: pAnsiChar; sourceLen: ulong): ulong; stdcall;
    function GetFileDate(FileName: pChar): TDateTime; stdcall;
    function GetIconByExt(Ext: string; var SmallIcon: HICON; var Descr: string): HICON; stdcall;
    function GetDiskFreeSpace(Drive: pChar): int64; stdcall;
  end;

  IWork = interface;
  ICache = interface;
  TCachesArray = array of ICache;

  IFile = interface;
  IFileCache = interface;
  IApplication = interface (ISLInterface)
    procedure BuildCachesList(); stdcall;
    function GetAppID(): uint32; stdcall;
    function GetName(): pChar; stdcall;
    function GetFolderName(): pChar; stdcall;
    function GetLastVersion(): uint32; stdcall;
    function GetUserDefinedRecord(Name: pAnsiChar): pAnsiChar; stdcall;

    function GetWork(): IWork; stdcall;

    function GetAppType(): EApplicationType; stdcall;
    function IsLoaded(): boolean; stdcall;
    function IsIncompleted(): boolean; stdcall;

    function GetVersion(): uint32; stdcall;
    function GetCompletion(): single; stdcall;
    function GetSize(): uint64; stdcall;
    function GetCompleted(): uint64; stdcall;
    function GetCaches(): TCachesArray; stdcall;
  end;

  IApp = interface(IApplication)
    function GetDeveloperName(): pChar; stdcall;
    function GetHomepageURL(): pChar; stdcall;
    function GetCMDLine(): pChar; stdcall;            // строка для запуска приложения (включая имя EXE-файла)
    function GetIconString(): pChar; stdcall;
    function GetRecommendEmulator(): EEmulator; stdcall;
    function GetAppSize(IsStandAlone: boolean): Int64; stdcall;
  end;

  ICache = interface (IApplication)
    procedure CreateFoldersList(Root: Pointer; OnItem: TAddTreeItemProc); stdcall;
    procedure CreateFilesList(Item: uint32; OnItem: TAddFileItemProc); stdcall;
    function GetCacheType(): ECacheType; stdcall;
    function GetFilesCount(): uint32; stdcall;
    function GetFoldersCount(): uint32; stdcall;
    function Open(): IFileCache; stdcall;
    procedure Close(); stdcall;
    function GetCacheSize(IsStandAlone: boolean): Int64; stdcall;
  end;

  IApplicationsList = interface (ISLInterface)
    function ReloadList(): ELoadListResult; stdcall;                    // перезагрузка списков (с их перезагрузкой в интерфейсе, ест)
    procedure LoadApplicationsState(); stdcall;                         // загружает состояние приложений (ускоряет запуск, если изменилось не много файлов кэша)
    procedure SaveApplicationsState(); stdcall;

    function UpdateCDR(): EUpdateCDR; stdcall;
    function ReloadCDR(): ELoadListResult; stdcall;                     // перезегрузка CDR с последующей перезагрузкой списка приложений при удаче

    function GetAppsCount(): integer; stdcall;
    function GetCachesCount(): integer; stdcall;
    function GetApplicationsCount(): integer; stdcall;

    function GetApplication(AppID: uint32): IApp; stdcall;
    function GetCache(AppID: uint32): ICache; stdcall;
    function GetApplicationByIdx(Index: integer): IApplication; stdcall;
    function IsAppBusy(AppID: uint32): boolean; stdcall;
  end;

  IWorksList = interface;
  IWork = interface (ISLInterface)
    function GetSubWorksList(): IWorksList; stdcall;
    function GetState(): EWorkState; stdcall;
    function GetSize(): uint64; stdcall;
    function GetCompletedSize(): uint64; stdcall;
    function GetCaption(): pChar; stdcall;            // возвращает строку с описание текущего действия
    function GetWorkID(): uint32; stdcall;
    function IsActive(): boolean; stdcall;

    function GetApplication(): IApplication; stdcall;

    procedure Stop(); stdcall;
    procedure Pause(); stdcall;
    procedure Resume(); stdcall;
  end;

  IWorksList = interface (ISLInterface)
    function AddWork(WorkType: EWorkType; Application: IApplication): IWork; stdcall; overload;
    function AddWork(WorkType: EWorkType; Application: IApplication; Parent: IWork): IWork; stdcall; overload;

    function GetMaxWorks(): uint32; stdcall;
    procedure SetMaxWorks(Value: uint32); stdcall;
    function GetCurrentWorksCount(): uint32; stdcall;
    function GetWorkFromApplicationID(AppID: uint32): IWork; stdcall;
    function GetWorkByID(WorkID: uint32): IWork; stdcall;
    function GetWorkState(WorkID: uint32): TWorkState; stdcall;
    function GetNewWorkID(): uint32; stdcall;
    procedure WaitForWork(WorkID: uint32); stdcall;
  end;

  IUIWindow = interface (ISLInterface)
  end;

  IUserInterface = interface (ISLInterface)
    function ShowMainForm(): IUIWindow; stdcall;
    procedure WaitShowMainForm(); stdcall;
    function ShowSettingsForm(): IUIWindow; stdcall;
    function ShowCachePropertiesForm(AppID: uint32): IUIWindow; stdcall;
    function ShowAppPropertiesForm(AppID: uint32): IUIWindow; stdcall;
    procedure ReloadControlsText(Parent: TObject); stdcall;

    procedure OnWorkStart(Work: IWork; Text: pChar); stdcall;
    procedure OnWorkProc(Work: IWork; Text: pChar; CurPos, MaxPos: uint64); stdcall;
    procedure OnWorkEnd(Work: IWork); stdcall;
    procedure OnWorkError(Work: IWork; Error: EWorkError; Item: pChar); stdcall;
    procedure OnLoadingStart(); stdcall;
    procedure OnLoadingEnd(); stdcall;

    procedure UpdateApplicationStatus(Application: IApplication); stdcall;

    procedure AddApplicationToList(Application: IApplication); stdcall;
    procedure ClearApplicationsList(Lists: uint32); stdcall;
    procedure AddLogEvent(EventIdx: uint32); stdcall;
    procedure SetLogEventResult(EventIdx: uint32); stdcall;

    function GetFilenameFromDlg(Caption, Mask: pChar): pChar; stdcall;
    function GetDirectoryFromDlg(Caption: pChar): pChar; stdcall;
  end;

  INetwork = interface (ISLInterface)
  end;

  IP2P = interface (ISLInterface)
  end;

  IFile = interface (ISLInterface)
  {
    OnErrorObj: TOnErrorObj;
    OnProgressObj: TOnProgressObj;
  }
    function LoadFromFile(FileName: pChar): boolean; stdcall;
    function LoadFromStream(Stream: TStream): boolean; stdcall;
    function GetMainStream(): TStream; stdcall;
    function GetFileType(): EFileType; stdcall;
    function OpenFile(FileName: pChar; Mode: byte): TStream; stdcall;
  end;

  IFileCache = interface (IFile)
    function GetItemName(Item: uint32): pChar; stdcall;
    function GetItemByName(Name: pChar): uint32; stdcall;
    function Validate(Item: uint32): EValidateResult; stdcall;
    function Correct(Item: uint32): EValidateResult; stdcall;
    function Extract(Item: uint32; Dst: pChar): EValidateResult; stdcall;
    function GetVersion(): uint; stdcall;
    function GetItemSize(Item: uint32): TItemSize; stdcall;
    function GetItemFlags(Item: uint32): uint32; stdcall;
    function GetCompletion(Item: uint32): single; stdcall;
    function CreateArchive(): pChar; stdcall;
    function CreateUpdate(ArchiveName: pChar): boolean; stdcall;
    function ApplyUpdae(UpdateName: pChar): boolean; stdcall;
    procedure CreateFoldersList(Item: Pointer; OnItem: TAddTreeItemProc); stdcall;
    procedure CreateFilesList(Item: uint32; OnItem: TAddFileItemProc); stdcall;
  end;

  IFileFormat = interface (ISLInterface)
    function TestFile(FileName: pChar): boolean; stdcall;
    function TestStream(Stream: TStream): boolean; stdcall;
    function LoadFromFile(FileName: pChar): IFile; stdcall;
    function LoadFromStream(Stream: TStream): IFile; stdcall;
  end;

  IFileFormats = interface (ISLInterface)
    function GetFileFormat(FileName: pChar): IFileFormat; stdcall;
    function GetStreamFormat(Stream: TStream): IFileFormat; stdcall;
    function LoadFromFile(FileName: pChar): IFile; stdcall;
    function LoadFromStream(Stream: TStream): IFile; stdcall;
  end;

  IGameConverter = interface (ISLInterface)
    procedure PrepareApplication(Application: IApplication); stdcall;
    function ExtractApplication(Application: IApplication; DstFolder: pChar; IsStandAlone: boolean): EConvertResult; stdcall;
    function Convert(Application: IApplication; Emulator: EEmulator; IsExtracted: boolean): EConvertResult; stdcall;
    function Launch(Application: IApplication; AppId: uint32): EConvertResult; stdcall;
  end;

  ICore = class (TObject)
    Log: ILog;
    Utils: IUtils;
    Translation: ITranslation;
    Settings: ISettings;
    UI: IUserInterface;
    ApplicationsList: IApplicationsList;
    WorksList: IWorksList;
    Network: INetwork;
    P2P: IP2P;
    Files: IFileFormats;
    Converter: IGameConverter;
    fSock: CSocket;

    destructor Destroy(); override;
    procedure Start(); virtual; stdcall;
  end;

  CBaseClass = class (TObject)
    private
      FRefCount: Integer;
    protected
      function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
      function _AddRef: Integer; virtual; stdcall;
      function _Release: Integer; virtual; stdcall;
  end;

var
  Core: ICore = nil;

implementation

function CBaseClass.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
  if GetInterface(IID, Obj) then result:=S_OK
    else result:=E_NOINTERFACE;
end;

function CBaseClass._AddRef: Integer; stdcall;
begin
  result:=InterlockedIncrement(FRefCount);
end;

function CBaseClass._Release: Integer; stdcall;
begin
  result:=InterlockedDecrement(FRefCount);
  {if result=0 then
    Destroy;}
end;

destructor ICore.Destroy();
begin
end;

procedure ICore.Start();
begin
end;


end.
