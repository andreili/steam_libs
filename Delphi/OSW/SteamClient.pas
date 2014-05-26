unit SteamClient;

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

function Breakpad_SetSteamID(ulSteamID: uint64): errno_t; cdecl; external 'steamclient.dll';
function Breakpad_SteamSetSteamID(ulSteamID: uint64): errno_t;
procedure Breakpad_SteamMiniDumpInit(a: uint32; b, c: pAnsiChar);
function Breakpad_SteamWriteMiniDumpSetComment(pchMsg: pAnsiChar): errno_t;


implementation

end.
