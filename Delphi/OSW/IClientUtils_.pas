unit IClientUtils_;

interface

uses
  SteamTypes, UtilsCommon;

type
  IClientUtils = class
    function GetInstallPath(): pAnsiChar; virtual; abstract;
    function GetManagedContentRoot(): pAnsiChar; virtual; abstract;

    // return the number of seconds since the user
    function GetSecondsSinceAppActive(): uint32; virtual; abstract;
    function GetSecondsSinceComputerActive(): uint32; virtual; abstract;

    // the universe this client is connecting to
    function GetConnectedUniverse(): EUniverse; virtual; abstract;

    // server time - in PST, number of seconds since January 1, 1970 (i.e unix time)
    function GetServerRealTime(): uint32; virtual; abstract;

    // returns the 2 digit ISO 3166-1-alpha-2 format country code this client is running in (as looked up via an IP-to-location database)
    // e.g "US" or "UK".
    function GetIPCountry(): pAnsiChar; virtual; abstract;

    //virtual unknown_ret LoadFileFromCDN( const char*, bool *, int, uint64 ) = 0;
    //virtual unknown_ret WriteCDNFileToDisk( int, const char* ) = 0;

    // returns true if the image exists, and valid sizes were filled out
    function GetImageSize(iImage: int; var pnWidth, pnHeight: uint32): boolean; virtual; abstract;

    // returns true if the image exists, and the buffer was successfully filled out
    // results are returned in RGBA format
    // the destination buffer size should be 4 * height * width * sizeof(char)
    function GetImageRGBA(iImage: int; pubDest: puint8; nDestBufferSize: int): boolean; virtual; abstract;

    // returns the IP of the reporting server for valve - currently only used in Source engine games
    function GetCSERIPPort(var unIP: uint32; var usPort: uint16): boolean; virtual; abstract;

    function GetNumRunningApps(): uint32; virtual; abstract;

    // return the amount of battery power left in the current system in % [0..100], 255 for being on AC power
    function GetCurrentBatteryPower(): uint8; virtual; abstract;

    procedure SetOfflineMode(bOffline: boolean); virtual; abstract;
    function GetOfflineMode(): boolean; virtual; abstract;

    function SetAppIDForCurrentPipe(appId: AppId_t): AppId_t; virtual; abstract;
    function GetAppID(): AppId_t; virtual; abstract;

    procedure SetAPIDebuggingActive(bActive, bVerbose: boolean); virtual; abstract;

    // API asynchronous call results
    // can be used directly, but more commonly used via the callback dispatch API (see steam_api.h)
    function IsAPICallCompleted(hSteamAPICall: SteamAPICall_t; var pbFailed: boolean): boolean; virtual; abstract;
    function GetAPICallFailureReason(hSteamAPICall: SteamAPICallCompleted_t): ESteamAPICallFailure; virtual; abstract;
    function GetAPICallResult(hSteamAPICall: SteamAPICall_t; pCallback: Pointer; cubCallback,
     iCallbackExpected: int; var pbFailed: boolean): boolean; virtual; abstract;

    function SignalAppsToShutDown(): boolean; virtual; abstract;

    function GetCellID(): CellID_t; virtual; abstract;

    function IsGlobalInstance(): boolean; virtual; abstract;
  end;

implementation

end.
