unit ISteamGameServer002_;

interface

uses
  SteamTypes, GameServerCommon;

type
  ISteamGameServer002 = class
    // connection functions
    procedure LogOn(); virtual; abstract;
    procedure LogOff(); virtual; abstract;
    function LoggedOn(): boolean; virtual; abstract;

    // user authentication functions
    procedure SetSpawnCount(ucSpawn: uint32); virtual; abstract;

    function GetSteam2GetEncryptionKeyToSendToNewClient(pvEncryptionKey: Pointer; var pcbEncryptionKey: uint32;
     cbMaxEncryptionKey: uint32): boolean; virtual; abstract;

    // the IP address and port should be in host order, i.e 127.0.0.1 == 0x7f000001
    // Both Steam2 and Steam3 authentication
    function SendSteam2UserConnect(unUserID: uint32; pvRawKey: Pointer; unKeyLen, unIPPublic: uint32; usPort: uint16;
     pvCookie: Pointer; cubCookie: uint32): boolean; virtual; abstract;

    // the IP address should be in host order, i.e 127.0.0.1 == 0x7f000001
    // Steam3 only user auth
    function SendSteam3UserConnect(steamID: CSteamID; unIPPublic: uint32; pvCookie: Pointer; cubCookie: uint32): boolean; virtual; abstract;

    function RemoveUserConnect(unUserID: uint32): boolean; virtual; abstract;

    // Should be called whenever a user leaves our game server, this lets Steam internally
    // track which users are currently on which servers for the purposes of preventing a single
    // account being logged into multiple servers, showing who is currently on a server, etc.
    function SendUserDisconnect(steamID: CSteamID; unUserID: uint32): boolean; virtual; abstract;

    function SendUserStatusResponse(steamID: CSteamID; nSecondsConnected, nSecondsSinceLast: int): boolean; virtual; abstract;

    // obsolete, use UpdateStatus below
    function Obsolete_GSSetStatus(nAppIdServed: int32; unServerFlags: uint32; cPlayers, cPlayersMax, cBotPlayers,
     unGamePort: int; pchServerName, pchGameDir, pchMapName, pchVersion: pAnsiChar): boolean; virtual; abstract;

    // Updates server status values which shows up in the server browser and matchmaking APIs
    function UpdateStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pchMapName: pAnsiChar): boolean; virtual; abstract;

    function Secure(): boolean; virtual; abstract;
    function GetSteamID(): CSteamID; virtual; abstract;

    // You shouldn't need to call this as it is called internally by SteamGameServer_Init() and can only be called once.
    //
    // To update the data in this call which may change during the servers lifetime see UpdateServerStatus() below.
    //
    // Input:	nGameAppID - The Steam assigned AppID for the game
    //			unServerFlags - Any applicable combination of flags (see k_unServerFlag____ constants below)
    //			unGameIP - The IP Address the server is listening for client connections on (might be INADDR_ANY), note that this is in host order
    //			unGamePort - The port which the server is listening for client connections on
    //			pchGameDir - A unique string identifier for your game
    //			pchVersion - The current version of the server as a string like 1.0.0.0
    //
    // bugbug jmccaskey - figure out how to remove this from the API and only expose via SteamGameServer_Init... or make this actually used,
    // and stop calling it in SteamGameServer_Init()?
    function SetServerType(nGameAppId: int32; unServerFlags, unGameIP, unGamePort: uint32; pchGameDir,
     pchVersion: pAnsiChar): boolean; virtual; abstract;

    // voided: these functions seem to have been added sometime after this interface was created, probably to keep it viable against the newer interfaces
    //

    // You shouldn't need to call this as it is called internally by SteamGameServer_Init() and can only be called once.
    //
    // To update the data in this call which may change during the servers lifetime see UpdateServerStatus() below.
    //
    // Input:	nGameAppID - The Steam assigned AppID for the game
    //			unServerFlags - Any applicable combination of flags (see k_unServerFlag____ constants below)
    //			unGameIP - The IP Address the server is listening for client connections on (might be INADDR_ANY)
    //			unGamePort - The port which the server is listening for client connections on
    //			unSpectatorPort - the port on which spectators can join to observe the server, 0 if spectating is not supported
    //			usQueryPort - The port which the ISteamMasterServerUpdater API should use in order to listen for matchmaking requests
    //			pchGameDir - A unique string identifier for your game
    //			pchVersion - The current version of the server as a string like 1.0.0.0
    //			bLanMode - Is this a LAN only server?
    //
    // bugbug jmccaskey - figure out how to remove this from the API and only expose via SteamGameServer_Init... or make this actually used,
    // and stop calling it in SteamGameServer_Init()?
    function SetServerType2(nGameAppId: int32; unServerFlags, unGameIP, unGamePort: uint32;
     usSpectatorPort, usQueryPort: uint16; pchGameDir, pchVersion: pAnsiChar; bLANMode: boolean): boolean; virtual; abstract;

    // Updates server status values which shows up in the server browser and matchmaking APIs
    function UpdateStatus2(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName,
     pchMapName: pAnsiChar): boolean; virtual; abstract;

    // Creates a fake user (ie, a bot) which will be listed as playing on the server, but skips validation.
    //
    // Return Value: Returns a SteamID for the user to be tracked with, you should call HandleUserDisconnect()
    // when this user leaves the server just like you would for a real user.
    function CreateUnauthenticatedUser(var pSteamID: CSteamID): boolean; virtual; abstract;

    // Update the data to be displayed in the server browser and matchmaking interfaces for a user
    // currently connected to the server.  For regular users you must call this after you receive a
    // GSUserValidationSuccess callback.
    //
    // Return Value: true if successful, false if failure (ie, steamIDUser wasn't for an active player)
    function SetUserData(steamIDUser: CSteamID; pchPlayerName: pAnsiChar; uScore: uint32): boolean; virtual; abstract;

    // This can be called if spectator goes away or comes back (passing 0 means there is no spectator server now).
    procedure UpdateSpectatorPort(unSpectatorPort: uint16); virtual; abstract;

    // Sets a string defining the "gametype" for this server, this is optional, but if it is set
    // it allows users to filter in the matchmaking/server-browser interfaces based on the value
    procedure SetGameType(pchGameType: pAnsiChar); virtual; abstract;
  end;

implementation

end.
