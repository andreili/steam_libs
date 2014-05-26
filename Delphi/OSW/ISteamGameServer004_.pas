unit ISteamGameServer004_;

interface

uses
  SteamTypes, GameServerCommon;

type
  ISteamGameServer004 = class
    // connection functions
    procedure LogOn(); virtual; abstract;
    procedure LogOff(); virtual; abstract;
    function LoggedOn(): boolean; virtual; abstract;

    function Secure(): boolean; virtual; abstract;
    function GetSteamID(): CSteamID; virtual; abstract;

    function SendUserConnectAndAuthenticate(steamIDUser: CSteamID; a2: uint32; a3: Pointer; a4: uint32): boolean; virtual; abstract;

    // Creates a fake user (ie, a bot) which will be listed as playing on the server, but skips validation.
    //
    // Return Value: Returns a SteamID for the user to be tracked with, you should call HandleUserDisconnect()
    // when this user leaves the server just like you would for a real user.
    function CreateUnauthenticatedUser(var pSteamID: CSteamID): boolean; virtual; abstract;

    // Should be called whenever a user leaves our game server, this lets Steam internally
    // track which users are currently on which servers for the purposes of preventing a single
    // account being logged into multiple servers, showing who is currently on a server, etc.
    procedure SendUserDisconnect(steamID: CSteamID; unUserID: uint32); virtual; abstract;

    // Update the data to be displayed in the server browser and matchmaking interfaces for a user
    // currently connected to the server.  For regular users you must call this after you receive a
    // GSUserValidationSuccess callback.
    //
    // Return Value: true if successful, false if failure (ie, steamIDUser wasn't for an active player)
    function UpdateUserData(steamIDUser: CSteamID; pchPlayerName: pAnsiChar; uScore: uint32): boolean; virtual; abstract;

    // user authentication functions
    procedure SetSpawnCount(ucSpawn: uint32); virtual; abstract;

    // You shouldn't need to call this as it is called internally by SteamGameServer_Init() and can only be called once.
    //
    // To update the data in this call which may change during the servers lifetime see UpdateServerStatus() below.
    //
    // Input:	nGameAppID - The Steam assigned AppID for the game
    //			unServerFlags - Any applicable combination of flags (see k_unServerFlag____ constants below)
    //			unGameIP - The IP Address the server is listening for client connections on (might be INADDR_ANY), note that this is in host order
    //			unGamePort - The port which the server is listening for client connections on
    //			unSpectatorPort - the port on which spectators can join to observe the server, 0 if spectating is not supported
    //			usQueryPort - The port which the ISteamMasterServerUpdater API should use in order to listen for matchmaking requests
    //			pchGameDir - A unique string identifier for your game
    //			pchVersion - The current version of the server as a string like 1.0.0.0
    //			bLanMode - Is this a LAN only server?
    //
    // bugbug jmccaskey - figure out how to remove this from the API and only expose via SteamGameServer_Init... or make this actually used,
    // and stop calling it in SteamGameServer_Init()?
    function SetServerType(nGameAppId: int32; unServerFlags, unGameIP, unGamePort: uint32;
     usSpectatorPort, usQueryPort: uint16; pchGameDir, pchVersion: pAnsiChar; bLanMode: boolean): boolean; virtual; abstract;

    function UpdateStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName,
     pchMapName: pAnsiChar): boolean; virtual; abstract;

    // This can be called if spectator goes away or comes back (passing 0 means there is no spectator server now).
    procedure UpdateSpectatorPort(unSpectatorPort: uint16); virtual; abstract;

    // Sets a string defining the "gametype" for this server, this is optional, but if it is set
    // it allows users to filter in the matchmaking/server-browser interfaces based on the value
    procedure SetGameType(pchGameType: pAnsiChar); virtual; abstract;

    // Ask if a user has a specific achievement for this game, will get a callback on reply
    function GetUserAchievementStatus(steamID: CSteamID; pchAchievementName: pAnsiChar): boolean; virtual; abstract;
  end;

implementation

end.
