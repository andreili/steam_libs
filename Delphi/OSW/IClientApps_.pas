unit IClientApps_;

interface

uses
  SteamTypes, AppsCommon;

type
  IClientApps = class
    // returns 0 if the key does not exist
    // this may be true on first call, since the app data may not be cached locally yet
    // If you expect it to exists wait for the AppDataChanged_t after the first failure and ask again
    function GetAppData(unAppID: AppId_t; pchKey, pchValue: pAnsiChar; cchValueMax: int): int; virtual; abstract;

    function GetInternalAppIDFromGameID(gameID: CGameID): AppId_t; virtual; abstract;

    procedure RequestAppCallbacks(bOnlyMultiplayerApps: boolean); virtual; abstract;
    procedure SendUserSpecificAppData(unAppID: AppId_t; pvData: Pointer; cbData: int); virtual; abstract;

    function GetAppDataSection(unAppID: AppId_t; eSection: int; pchBuffer: puint8; cbBufferMax: int): int; virtual; abstract;
    function RequestAppInfoUpdate(var pAppIDs: AppId_t; nNumAppIDs: int; bForceUpdate: boolean): boolean; virtual; abstract;

    procedure NotifyAppEventTriggered(unAppID: AppId_t; eAppEvent: EAppEvent); virtual; abstract;
    procedure NotifyDlcInstalled(unAppID: AppId_t); virtual; abstract;
  end;

implementation

end.
