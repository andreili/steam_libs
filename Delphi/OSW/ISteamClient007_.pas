unit ISteamClient007_;

interface

uses
  SteamTypes, ClientCommon;

type
  ISteamClient007 = class
    // Creates a communication pipe to the Steam client
    function CreateSteamPipe(): HSteamPipe; virtual; abstract;
    // Releases a previously created communications pipe
    function ReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean; virtual; abstract;

    // connects to an existing global user, failing if none exists
    // used by the game to coordinate with the steamUI
    function ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser; virtual; abstract;
    // used by game servers, create a steam user that won't be shared with anyone else
    function CreateLocalUser(var phSteamPipe: HSteamPipe): HSteamUser; virtual; abstract;
    // removes an allocated user
    function ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser): boolean; virtual; abstract;

    // retrieves the ISteamUser interface associated with the handle
    function GetISteamUser(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUser; virtual; abstract;

    // retrieves the ISteamGameServer interface associated with the handle
    function GetISteamGameServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamGameServer; virtual; abstract;

    // set the local IP and Port to bind to
    // this must be set before CreateLocalUser()
    procedure SetLocalIPBinding(unIP: uint32; usPort: uint16); virtual; abstract;

    // returns the ISteamFriends interface
    function GetISteamFriends(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamFriends; virtual; abstract;

    // returns the ISteamUtils interface
    function GetISteamUtils(hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUtils; virtual; abstract;

    // returns the ISteamMatchmaking interface
    function GetISteamMatchmaking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmaking; virtual; abstract;

    // returns the ISteamContentServer interface
    function GetISteamContentServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamContentServer; virtual; abstract;

    // returns the ISteamMasterServerUpdater interface
    function GetISteamMasterServerUpdater(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMasterServerUpdater; virtual; abstract;

    // returns the ISteamMatchmakingServers interface
    function GetISteamMatchmakingServers(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmakingServers; virtual; abstract;

    // returns a generic interface
    function GetISteamGenericInterface(SteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): Pointer; virtual; abstract;

    // this needs to be called every frame to process matchmaking results
    // redundant if you're already calling SteamAPI_RunCallbacks()
    procedure RunFrame(); virtual; abstract;

    // returns the number of IPC calls made since the last time this function was called
    // Used for perf debugging so you can understand how many IPC calls your game makes per frame
    // Every IPC call is at minimum a thread context switch if not a process one so you want to rate
    // control how often you do them.
    function GetIPCCallCount(): uint32; virtual; abstract;

    // returns the ISteamUserStats interface
    function GetISteamUserStats(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUserStats; virtual; abstract;

    // returns apps interface
    function GetISteamApps(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamApps; virtual; abstract;

    // networking
    function GetISteamNetworking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamNetworking; virtual; abstract;

    // API warning handling
    // 'int' is the severity; 0 for msg, 1 for warning
    // 'const char *' is the text of the message
    // callbacks will occur directly after the API function is called that generated the warning or message
    procedure SetWarningMessageHook(pFunction: SteamAPIWarningMessageHook_t); virtual; abstract;

    // remote storage
    function GetISteamRemoteStorage(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamRemoteStorage; virtual; abstract;
  end;

implementation

end.
