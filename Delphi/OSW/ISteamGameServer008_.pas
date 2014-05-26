unit ISteamGameServer008_;

interface

uses
  SteamTypes, GameServerCommon;

type
  ISteamGameServer008 = class
    // connection functions
    procedure LogOn(); virtual; abstract;
    procedure LogOff(); virtual; abstract;

    // status functions
    function LoggedOn(): boolean; virtual; abstract;
    function Secure(): boolean; virtual; abstract;
    function GetSteamID(): CSteamID; virtual; abstract;

    // Handles receiving a new connection from a Steam user.  This call will ask the Steam
    // servers to validate the users identity, app ownership, and VAC status.  If the Steam servers
    // are off-line, then it will validate the cached ticket itself which will validate app ownership
    // and identity.  The AuthBlob here should be acquired on the game client using SteamUser()->InitiateGameConnection()
    // and must then be sent up to the game server for authentication.
    //
    // Return Value: returns true if the users ticket passes basic checks. pSteamIDUser will contain the Steam ID of this user. pSteamIDUser must NOT be NULL
    // If the call succeeds then you should expect a GSClientApprove_t or GSClientDeny_t callback which will tell you whether authentication
    // for the user has succeeded or failed (the steamid in the callback will match the one returned by this call)
    function SendUserConnectAndAuthenticate(unIPClient: uint32; pvAuthBlob: Pointer; cubAuthBlobSize: uint32;
     var pSteamIDUser: CSteamID): boolean; virtual; abstract;

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
    function SetServerType(unServerFlags, unGameIP, unGamePort: uint32;
     unSpectatorPort, usQueryPort: uint16; pchGameDir, pchVersion: pAnsiChar; bLanMode: boolean): boolean; virtual; abstract;

    // Updates server status values which shows up in the server browser and matchmaking APIs
    procedure UpdateServerStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName,
     pchMapName: pAnsiChar); virtual; abstract;

    // This can be called if spectator goes away or comes back (passing 0 means there is no spectator server now).
    procedure UpdateSpectatorPort(unSpectatorPort: uint16); virtual; abstract;

    // Sets a string defining the "gametype" for this server, this is optional, but if it is set
    // it allows users to filter in the matchmaking/server-browser interfaces based on the value
    procedure SetGameType(pchGameType: pAnsiChar); virtual; abstract;

    // Ask if a user has a specific achievement for this game, will get a callback on reply
    function GetUserAchievementStatus(steamID: CSteamID; pchAchievementName: pAnsiChar): boolean; virtual; abstract;

    // Ask for the gameplay stats for the server. Results returned in a callback
    procedure GetGameplayStats(); virtual; abstract;

    // Ask if a user in in the specified group, results returns async by GSUserGroupStatus_t
    // returns false if we're not connected to the steam servers and thus cannot ask
    function RequestUserGroupStatus(steamIDUser, steamIDGroup: CSteamID): boolean; virtual; abstract;

    // Returns the public IP of the server according to Steam, useful when the server is
    // behind NAT and you want to advertise its IP in a lobby for other clients to directly
    // connect to
    function GetPublicIP(): uint32; virtual; abstract;
  end;

implementation

end.
