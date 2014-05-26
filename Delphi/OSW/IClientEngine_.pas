unit IClientEngine_;

interface

uses
  SteamTypes;

type
  IClientApps = class end;
  IClientBilling = class end;
  IClientContentServer = class end;
  IClientFriends = class end;
  IClientGameCoordinator = class end;
  IClientGameServer = class end;
  IClientGameServerItems = class end;
  IClientGameStats = class end;
  IClientMasterServerUpdater = class end;
  IClientMatchmaking = class end;
  IClientMatchmakingServers = class end;
  IClientNetworking = class end;
  IClientRemoteStorage = class end;
  IClientUser = class end;
  IClientUserItems = class end;
  IClientUserStats = class end;
  IClientUtils = class end;
  IP2PController = class end;
  IClientAppManager = class end;
  IClientDepotBuilder = class end;
  IConCommandBaseAccessor = class end;
  IClientHTTP = class end;
  IClientGameServerStats = class end;
  IClientConfigStore = class end;

  IClientEngine = class
    function CreateSteamPipe(): HSteamPipe; virtual; abstract;
    function ReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean; virtual; abstract;

    function CreateGlobalUser(var hSteamPipe: HSteamPipe): HSteamUser; virtual; abstract;
    function ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser; virtual; abstract;

    function CreateLocalUser(var phSteamPipe: HSteamPipe; eAccountType: EAccountType): HSteamUser; virtual; abstract;

    procedure ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser); virtual; abstract;

    function IsValidHSteamUserPipe(hSteamPipe: HSteamPipe; hUser: HSteamUser): boolean; virtual; abstract;

    function GetIClientUser(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientUser; virtual; abstract;
    function GetIClientGameServer(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientGameServer; virtual; abstract;

    procedure SetLocalIPBinding(unIP: uint32; usPort: uint16); virtual; abstract;
    function GetUniverseName(eUniverse: EUniverse): pAnsiChar; virtual; abstract;

    function GetIClientFriends(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientFriends; virtual; abstract;
    function GetIClientUtils(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientUtils; virtual; abstract;
    function GetIClientBilling(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientBilling; virtual; abstract;
    function GetIClientMatchmaking(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientMatchmaking; virtual; abstract;
    function GetIClientApps(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientApps; virtual; abstract;
    function GetIClientContentServer(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientContentServer; virtual; abstract;
    function GetIClientMasterServerUpdater(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientMasterServerUpdater; virtual; abstract;
    function GetIClientMatchmakingServers(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientMatchmakingServers; virtual; abstract;

    procedure RunFrame(); virtual; abstract;
    function GetIPCCallCount(): uint32; virtual; abstract;

    function GetIClientUserStats(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientUserStats; virtual; abstract;
    function GetIClientGameServerStats(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientGameServerStats; virtual; abstract;

    function GetIClientNetworking(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientNetworking; virtual; abstract;
    function GetIClientRemoteStorage(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientRemoteStorage; virtual; abstract;

    procedure SetWarningMessageHook(pFunction: SteamAPIWarningMessageHook_t); virtual; abstract;

    function GetIClientGameCoordinator(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientGameCoordinator; virtual; abstract;

    procedure SetOverlayNotificationPosition(eNotificationPosition: ENotificationPosition); virtual; abstract;

    function IsOverlayEnabled(): boolean; virtual; abstract;
    function GetAPICallResult(hSteamPipe: HSteamPipe; hSteamAPICall: SteamAPICall_t; pCallback: Pointer;
     cubCallback, iCallbackExpected: int; pbFailed: pboolean): boolean; virtual; abstract;

    function GetIClientDepotBuilder(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientDepotBuilder; virtual; abstract;

    procedure ConCommandInit(pAccessor: IConCommandBaseAccessor); virtual; abstract;

    function GetIClientAppManager(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientAppManager; virtual; abstract;
    function GetIClientConfigStore(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientConfigStore; virtual; abstract;

    function OverlayNeedsPresent(): boolean; virtual; abstract;

    function GetIClientGameStats(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientGameStats; virtual; abstract;
    function GetIClientHTTP(HSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): IClientHTTP; virtual; abstract;

    function GetIPCServerMap(): Pointer; virtual; abstract;
    function OnDebugTextArrived(pchDebugText: pAnsiChar): unknown_ret; virtual; abstract;
  end;

implementation

end.
