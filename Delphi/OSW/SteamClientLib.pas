unit SteamClientLib;

interface

uses
  SteamTypes,
    ISteamClient006_, ISteamClient007_, ISteamClient008_, ISteamClient009_,
    ISteamFriends001_, ISteamFriends002_, ISteamFriends003_, ISteamFriends004_, ISteamFriends005_, ISteamFriends006_, ISteamFriends007_,
    ISteamUser004_, ISteamUser005_, ISteamUser006_, ISteamUser007_, ISteamUser008_, ISteamUser009_, ISteamUser010_, ISteamUser011_, ISteamUser012_, ISteamUser013_, ISteamUser014_,
    ISteamUserItems001_, ISteamUserItems002_, ISteamUserItems003_, ISteamUserItems004_,
    ISteamApps001_, ISteamApps002_, ISteamApps003_,
    ISteamUserStats001_, ISteamUserStats002_, ISteamUserStats003_, ISteamUserStats004_, ISteamUserStats005_, ISteamUserStats006_, ISteamUserStats007_,
    ISteamUtils001_, ISteamUtils002_, ISteamUtils003_, ISteamUtils004_, ISteamUtils005_,
    ISteamGameServer002_, ISteamGameServer003_, ISteamGameServer004_, ISteamGameServer005_, ISteamGameServer006_, ISteamGameServer007_, ISteamGameServer008_, ISteamGameServer009_, ISteamGameServer010_,
    ISteamMasterServerUpdater001_,
    ISteamMatchmaking001_, ISteamMatchmaking002_, ISteamMatchmaking003_, ISteamMatchmaking004_, ISteamMatchmaking005_, ISteamMatchmaking006_, ISteamMatchmaking007_, ISteamMatchmaking008_,
    ISteamMatchmakingServers001_, ISteamMatchmakingServers002_,
    ISteamNetworking001_, ISteamNetworking002_, ISteamNetworking003_, ISteamNetworking004_,
    ISteamBilling001_, ISteamBilling002_,
    ISteamRemoteStorage001_, ISteamRemoteStorage002_,
    ISteamContentServer001_, ISteamContentServer002_,
    ISteam2Bridge001_, ISteam2Bridge002_,
    ISteamGameServerItems002_, ISteamGameServerItems003_, ISteamGameServerItems004_,
    ISteamGameCoordinator001_,
    ISteamGameServerStats001_,
    ISteamGameStats001_,
    ISteamAppTicket001_,
    IClientEngine_, IClientAppManager_, IClientApps_, IClientBilling_, IClientContentServer_, IClientDepotBuilder_, IClientFriends_,
     IClientGameCoordinator_, IClientGameServer_, IClientGameStats_, IClientMatchmaking_, IClientNetworking_, IClientRemoteStorage_,
     IClientUser_, IClientUserStats_, IClientUtils_, IClientHTTP_, IClientConfigStore_;

// Breakpad
function Breakpad_SetSteamID(ulSteamID: uint64): errno_t; cdecl; external 'steamclient.dll';
function Breakpad_SteamSetSteamID(ulSteamID: uint64): errno_t; cdecl; external 'steamclient.dll';
procedure Breakpad_SteamMiniDumpInit(a: uint32; b, c: pAnsiChar); cdecl; external 'steamclient.dll';
function Breakpad_SteamWriteMiniDumpSetComment(pchMsg: pAnsiChar): errno_t; cdecl; external 'steamclient.dll';
procedure Breakpad_SteamWriteMiniDumpUsingExceptionInfoWithBuildId(a, b: int); cdecl; external 'steamclient.dll';

// Steam user
function Steam_BConnected(hUser: HSteamUser; hSteamPipe: HSteamPipe): boolean; cdecl; external 'steamclient.dll';
function Steam_BLoggedOn(hUser: HSteamUser; hSteamPipe: HSteamPipe): boolean; cdecl; external 'steamclient.dll';
procedure Steam_LogOn(hUser: HSteamUser; hSteamPipe: HSteamPipe; ulSteamID: uint64); cdecl; external 'steamclient.dll';
procedure Steam_LogOff(hUser: HSteamUser; hSteamPipe: HSteamPipe); cdecl; external 'steamclient.dll';
function Steam_InitiateGameConnection(hUser: HSteamUser; hSteamPipe: HSteamPipe;
         pBlob: Pointer; cbMaxBlob: int;
         steamID: uint64; nGameAppID: int; unIPServer: uint32; usPortServer: uint16;
         bSecure: boolean): int; cdecl; external 'steamclient.dll';
procedure Steam_TerminateGameConnection(hUser: HSteamUser; hSteamPipe: HSteamPipe;
          unIPServer: uint32; usPortServer: uint16); cdecl; external 'steamclient.dll';

// Steam callbacks
function Steam_BGetCallback(hSteamPipe: HSteamPipe; var pCallbackMsg: CallbackMsg_t;
         var phSteamCall: HSteamCall): boolean; cdecl; external 'steamclient.dll';
procedure Steam_FreeLastCallback(hSteamPipe: HSteamPipe); cdecl; external 'steamclient.dll';
function Steam_GetAPICallResult(hSteamPipe: HSteamPipe; hSteamAPICall: SteamAPICall_t; pCallback: Pointer;
         cubCallback, iCallbackExpected: integer; pbFailed: PBoolean): boolean; cdecl; external 'steamclient.dll';

// Steam client
function Steam_CreateSteamPipe: HSteamPipe; cdecl; external 'steamclient.dll';
function Steam_BReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean; cdecl; external 'steamclient.dll';
function Steam_CreateLocalUser(var phSteamPipe: HSteamPipe): HSteamUser; cdecl; external 'steamclient.dll';
function Steam_CreateGlobalUser(var phSteamPipe: HSteamPipe): HSteamUser; cdecl; external 'steamclient.dll';
function Steam_ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser; cdecl; external 'steamclient.dll';
procedure Steam_ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser); cdecl; external 'steamclient.dll';
procedure Steam_SetLocalIPBinding(unIP: uint32; usPort: uint16); cdecl; external 'steamclient.dll';

// Steam game server
function Steam_GSGetSteamGameConnectToken(hUser: HSteamUser; hSteamPipe: HSteamPipe; pBlob: Pointer; cbBlobMax: int): int; cdecl;  external 'steamclient.dll';
function Steam_GetGSHandle(hUser: HSteamUser; hSteamPipe: HSteamPipe): Pointer; cdecl;  external 'steamclient.dll';
function Steam_GSSendSteam2UserConnect(phSteamHandle: Pointer; unUserID: uint32;
         pvRawKey: pAnsiChar; unKeyLen, unIPPublic: uint32; usPort: uint16;
         pvCookie: pAnsiChar; cubCookie: uint32): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSSendSteam3UserConnect(phSteamHandle: Pointer; ulSteamID: uint64;
         unIPPublic: uint32; pvCookie: pAnsiChar; cubCookie: uint32): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSSendUserDisconnect(phSteamHandle: Pointer; ulSteamID: uint64;
         unUserID: uint32): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSSendUserStatusResponse(phSteamHandle: Pointer; ulSteamID: uint64;
         nSecondsConnected, nSecondsSinceLast: int): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSUpdateStatus(phSteamHandle: Pointer; cPlayers, cPlayersMax,
         cBotPlayers: int; pchServerName, pchMapName: pAnsiChar): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSRemoveUserConnect(phSteamHandle: Pointer; unUserID: uint32): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSSetSpawnCount(phSteamHandle: Pointer; ucSpawn: uint32): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSGetSteam2GetEncryptionKeyToSendToNewClient(phSteamHandle: Pointer;
         pvEncryptionKey: pointer; pcbEncryptionKey: puint32; cbMaxEncryptionKey: uint32): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSLogOn(phSteamHandle: Pointer): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSLogOff(phSteamHandle: Pointer): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSBLoggedOn(phSteamHandle: Pointer): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSSetServerType(phSteamHandle: Pointer; nAppIdServed: int32; unServerFlags,
         unGameIP, unGamePort: uint32; pchGameDir, pchVersion: pAnsiChar): boolean; cdecl;  external 'steamclient.dll';
function Steam_GSBSecure(phSteamHandle: Pointer): boolean; cdecl;  external 'steamclient.dll';

//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//  Steam API setup & shutdown
//
//  These functions manage loading, initializing and shutdown of the steamclient.dll
//
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
  {
// S_API void STEAM_CALL SteamAPI_Init(); (see below
procedure SteamAPI_Shutdown();

// checks if a local Steam client is running
function SteamAPI_IsSteamRunning(): boolean;

// Detects if your executable was launched through the Steam client, and restarts your game through
// the client if necessary. The Steam client will be started if it is not running.
//
// Returns: true if your executable was NOT launched through the Steam client. This function will
//          then start your application through the client. Your current process should exit.
//
//          false if your executable was started through the Steam client or a steam_appid.txt file
//          is present in your game's directory (for development). Your current process should continue.
//
// NOTE: This function should be used only if you are using CEG or not using Steam's DRM. Once applied
//       to your executable, Steam's DRM will handle restarting through Steam if necessary.
function SteamAPI_RestartAppIfNecessary(unOwnAppID: uint32): boolean;

// crash dump recording functions
}


implementation

end.
