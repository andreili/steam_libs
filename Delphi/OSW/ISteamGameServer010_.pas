unit ISteamGameServer010_;

interface

uses
  SteamTypes, GameServerCommon, UserCommon;

type
  ISteamGameServer010 = class
    // connection functions
    procedure LogOn(); virtual; stdcall;
    procedure LogOff(); virtual; stdcall;

    // status functions
    function LoggedOn(): boolean; virtual; stdcall;
    function Secure(): boolean; virtual; stdcall;
    function GetSteamID(): CSteamID; virtual; stdcall;

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
     var pSteamIDUser: CSteamID): boolean; virtual; stdcall;

    // Creates a fake user (ie, a bot) which will be listed as playing on the server, but skips validation.
    //
    // Return Value: Returns a SteamID for the user to be tracked with, you should call HandleUserDisconnect()
    // when this user leaves the server just like you would for a real user.
    function CreateUnauthenticatedUser(var pSteamID: CSteamID): boolean; virtual; stdcall;

    // Should be called whenever a user leaves our game server, this lets Steam internally
    // track which users are currently on which servers for the purposes of preventing a single
    // account being logged into multiple servers, showing who is currently on a server, etc.
    procedure SendUserDisconnect(steamID: CSteamID; unUserID: uint32); virtual; stdcall;

    // Update the data to be displayed in the server browser and matchmaking interfaces for a user
    // currently connected to the server.  For regular users you must call this after you receive a
    // GSUserValidationSuccess callback.
    //
    // Return Value: true if successful, false if failure (ie, steamIDUser wasn't for an active player)
    function UpdateUserData(steamIDUser: CSteamID; pchPlayerName: pAnsiChar; uScore: uint32): boolean; virtual; stdcall;

    // user authentication functions
    procedure SetSpawnCount(ucSpawn: uint32); virtual; stdcall;

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
     unSpectatorPort, usQueryPort: uint16; pchGameDir, pchVersion: pAnsiChar; bLanMode: boolean): boolean; virtual; stdcall;

    // Updates server status values which shows up in the server browser and matchmaking APIs
    procedure UpdateServerStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName,
     pchMapName: pAnsiChar); virtual; stdcall;

    // This can be called if spectator goes away or comes back (passing 0 means there is no spectator server now).
    procedure UpdateSpectatorPort(unSpectatorPort: uint16); virtual; stdcall;

    // Sets a string defining the "gametags" for this server, this is optional, but if it is set
    // it allows users to filter in the matchmaking/server-browser interfaces based on the value
    procedure SetGameTags(pchGameTags: pAnsiChar); virtual; stdcall;

    // Ask for the gameplay stats for the server. Results returned in a callback
    procedure GetGameplayStats(); virtual; stdcall;

    // Gets the reputation score for the game server. This API also checks if the server or some
    // other server on the same IP is banned from the Steam master servers.
    function GetServerReputation(): SteamAPICall_t; virtual; stdcall;

    // Ask if a user in in the specified group, results returns async by GSUserGroupStatus_t
    // returns false if we're not connected to the steam servers and thus cannot ask
    function RequestUserGroupStatus(steamIDUser, steamIDGroup: CSteamID): boolean; virtual; stdcall;

    // Returns the public IP of the server according to Steam, useful when the server is
    // behind NAT and you want to advertise its IP in a lobby for other clients to directly
    // connect to
    function GetPublicIP(): uint32; virtual; stdcall;

    // Sets a string defining the "gamedata" for this server, this is optional, but if it is set
    // it allows users to filter in the matchmaking/server-browser interfaces based on the value
    // don't set this unless it actually changes, its only uploaded to the master once (when
    // acknowledged)
    procedure SetGameData(pchGameData: pAnsiChar); virtual; stdcall;

    // After receiving a user's authentication data, and passing it to SendUserConnectAndAuthenticate, use this function
    // to determine if the user owns downloadable content specified by the provided AppID.
    function UserHasLicenseForApp(steamID: CSteamID; appID: AppId_t): EUserHasLicenseForAppResult; virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverGameServer010CppToI(Cpp: Pointer): ISteamGameServer010;

implementation

function ConverGameServer010CppToI(Cpp: Pointer): ISteamGameServer010;
begin
  result:=ISteamGameServer010.Create();
  result.fCpp:=Cpp;
end;

procedure ISteamGameServer010.LogOn();
{begin
  ISteamGameServer010(fCpp).LogOn();
end;   }
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  mov ecx, fCpp
  call [EAX+000]
end;

procedure ISteamGameServer010.LogOff();
begin
end;

function ISteamGameServer010.LoggedOn(): boolean;
begin
end;

function ISteamGameServer010.Secure(): boolean;
begin
end;

function ISteamGameServer010.GetSteamID(): CSteamID;
begin
end;

function ISteamGameServer010.SendUserConnectAndAuthenticate(unIPClient: uint32; pvAuthBlob: Pointer; cubAuthBlobSize: uint32;
     var pSteamIDUser: CSteamID): boolean;
begin
end;

function ISteamGameServer010.CreateUnauthenticatedUser(var pSteamID: CSteamID): boolean;
begin
end;

procedure ISteamGameServer010.SendUserDisconnect(steamID: CSteamID; unUserID: uint32);
begin
end;

function ISteamGameServer010.UpdateUserData(steamIDUser: CSteamID; pchPlayerName: pAnsiChar; uScore: uint32): boolean;
begin
end;

procedure ISteamGameServer010.SetSpawnCount(ucSpawn: uint32);
begin
end;

function ISteamGameServer010.SetServerType(unServerFlags, unGameIP, unGamePort: uint32;
     unSpectatorPort, usQueryPort: uint16; pchGameDir, pchVersion: pAnsiChar; bLanMode: boolean): boolean;
begin
end;

procedure ISteamGameServer010.UpdateServerStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName,
     pchMapName: pAnsiChar);
begin
end;

procedure ISteamGameServer010.UpdateSpectatorPort(unSpectatorPort: uint16);
begin
end;

procedure ISteamGameServer010.SetGameTags(pchGameTags: pAnsiChar);
begin
end;

procedure ISteamGameServer010.GetGameplayStats();
begin
end;

function ISteamGameServer010.GetServerReputation(): SteamAPICall_t;
begin
end;

function ISteamGameServer010.RequestUserGroupStatus(steamIDUser, steamIDGroup: CSteamID): boolean;
begin
end;

function ISteamGameServer010.GetPublicIP(): uint32;
begin
end;

procedure ISteamGameServer010.SetGameData(pchGameData: pAnsiChar);
begin
end;

function ISteamGameServer010.UserHasLicenseForApp(steamID: CSteamID; appID: AppId_t): EUserHasLicenseForAppResult;
begin
end;

end.
