unit IClientGameServer_;

interface

uses
  SteamTypes, GameServerCommon, UserCommon;

type
  EGameConnectSteamResponse =
    (k_EGameConnectSteamResponse_WaitingForResponse = 0,
     k_EGameConnectSteamResponse_AuthorizedToPlay = 1,
     k_EGameConnectSteamResponse_Denied = 2,
     k_EGameConnectSteamResponse_ExceededReasonableTime_StillWaiting = 3);

  ConnectedUserInfo_t = record
    m_cubConnectedUserInfo,
    m_nCountOfGuestUsers: int;
    m_SteamID: CSteamID;
    m_unIPPublic,
    m_nFrags: uint32;
    m_flConnectTime: double;
    m_eGameConnectSteamResponse: EGameConnectSteamResponse;
    m_eDenyReason: EDenyReason;
  end;

  IClientGameServer = class
    // returns the HSteamUser this interface represents
    function GetHSteamUser(): HSteamUser; virtual; abstract;
    function GetSteamID(): CSteamID; virtual; abstract;

    // steam account management functions
    procedure LogOn(); virtual; abstract;
    procedure LogOff(); virtual; abstract;
    function LoggedOn(): boolean; virtual; abstract;

    function Secure(): boolean; virtual; abstract;
    function GetLogonState(): ELogonState; virtual; abstract;
    function Connected(): boolean; virtual; abstract;

    function RaiseConnectionPriority(eConnectionPriority: EConnectionPriority): int; virtual; abstract;
    procedure ResetConnectionPriority(hRaiseConnectionPriorityPrev: int); virtual; abstract;

    procedure SetCellID(cellID: CellID_t); virtual; abstract;

    procedure TrackSteamUsageEvent(eSteamUsageEvent: ESteamUsageEvent; pubKV: puint8; cubKV: uint32); virtual; abstract;

    // Handles receiving a new connection from a Steam user.  This call will ask the Steam
    // servers to validate the users identity, app ownership, and VAC status.  If the Steam servers
    // are off-line, then it will validate the cached ticket itself which will validate app ownership
    // and identity.  The AuthBlob here should be acquired on the game client using SteamUser()->InitiateGameConnection()
    // and must then be sent up to the game server for authentication.
    //
    // Return Value: returns true if the users ticket passes basic checks. pSteamIDUser will contain the Steam ID of this user. pSteamIDUser must NOT be NULL
    // If the call succeeds then you should expect a GSClientApprove_t or GSClientDeny_t callback which will tell you whether authentication
    // for the user has succeeded or failed (the steamid in the callback will match the one returned by this call)
    function SendUserConnectAndAuthenticate(unIPClient: uint32; pvAuthBlob: Pointer; cubAuthBlobSize: uint32; var pSteamIDUser: CSteamID): boolean; virtual; abstract;

    // Creates a fake user (ie, a bot) which will be listed as playing on the server, but skips validation.
    //
    // Return Value: Returns a SteamID for the user to be tracked with, you should call HandleUserDisconnect()
    // when this user leaves the server just like you would for a real user.
    function CreateUnauthenticatedUserConnection(): CSteamID;   virtual; abstract;

    // Should be called whenever a user leaves our game server, this lets Steam internally
    // track which users are currently on which servers for the purposes of preventing a single
    // account being logged into multiple servers, showing who is currently on a server, etc.
    procedure SendUserDisconnect(stemID: CSteamID); virtual; abstract;

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
    function SetServerType(unServerFlags, unGameIP: uint32; unGamePort, unSpectatorPort, usQueryPort: uint16;
     pchGameDir, pchVersion: pAnsiChar; bLANMode: boolean): boolean; virtual; abstract;

    // Update the data to be displayed in the server browser and matchmaking interfaces for a user
    // currently connected to the server.  For regular users you must call this after you receive a
    // GSUserValidationSuccess callback.
    //
    // Return Value: true if successful, false if failure (ie, steamIDUser wasn't for an active player)
    function UpdateUserData(steamIDUser: CSteamID; pchPlayerName: pAnsiChar; uScore: uint32): boolean; virtual; abstract;

    // Updates server status values which shows up in the server browser and matchmaking APIs
    procedure UpdateStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName,
     pchMapName: pAnsiChar); virtual; abstract;

    // This can be called if spectator goes away or comes back (passing 0 means there is no spectator server now).
    procedure UpdateSpectatorPort(unSpectatorPort: uint16); virtual; abstract;

    procedure SetGameTags(pchGameTags: pAnsiChar); virtual; abstract;

    // Sets a string defining the "gamedata" for this server, this is optional, but if it is set
    // it allows users to filter in the matchmaking/server-browser interfaces based on the value
    // don't set this unless it actually changes, its only uploaded to the master once (when
    // acknowledged)
    procedure SetGameData(pchGameData: pAnsiChar); virtual; abstract;

    procedure SetCountOfSimultaneousGuestUsersPerSteamAccount(nCount: int); virtual; abstract;

    function EnumerateConnectedUsers(iterator: int; var pConnectedUserInfo: ConnectedUserInfo_t): boolean; virtual; abstract;

    // Ask for the gameplay stats for the server. Results returned in a callback
    procedure GetGameplayStats(); virtual; abstract;

    function GetServerReputation(): SteamAPICall_t; virtual; abstract;

    // Ask if a user in in the specified group, results returns async by GSUserGroupStatus_t
    // returns false if we're not connected to the steam servers and thus cannot ask
    function RequestUserGroupStatus(steamIDUser, steamIDGroup: CSteamID): boolean; virtual; abstract;

    // Returns the public IP of the server according to Steam, useful when the server is
    // behind NAT and you want to advertise its IP in a lobby for other clients to directly
    // connect to
    function GetPublicIP(): uint32; virtual; abstract;

    // Retrieve ticket to be sent to the entity who wishes to authenticate you.
    // pcbTicket retrieves the length of the actual ticket.
    function GetAuthSessionTicket(pTicket: Pointer; cbMaxTicket: int; var pcbTicket: uint32): HAuthTicket; virtual; abstract;

    // Authenticate ticket from entity steamID to be sure it is valid and isnt reused
    // Registers for callbacks if the entity goes offline or cancels the ticket ( see ValidateAuthTicketResponse_t callback and EAuthSessionResponse )
    function BeginAuthSession(pAuthTicket: Pointer; cbAuthTicket: int; steamID: CSteamID): EBeginAuthSessionResult; virtual; abstract;

    // Stop tracking started by BeginAuthSession - called when no longer playing game with this entity
    procedure EndAuthSession(steamID: CSteamID); virtual; abstract;

    // Cancel auth ticket from GetAuthSessionTicket, called when no longer playing game with the entity you gave the ticket to
    procedure CancelAuthTicket(hAuthTicket: HAuthTicket); virtual; abstract;

    // After receiving a user's authentication data, and passing it to SendUserConnectAndAuthenticate, use this function
    // to determine if the user owns downloadable content specified by the provided AppID.
    //virtual EUserHasLicenseForAppResult UserHasLicenseForApp( CSteamID steamID, AppId_t appID ) = 0;
    function IsUserSubscribedAppInTicket(steamID: CSteamID; appID: uint32): int32; virtual; abstract;

    // Ask if a user has a specific achievement for this game, will get a callback on reply
    function _GetUserAchievementStatus(steamID: CSteamID; pchAchievementName: pAnsiChar): boolean; virtual; abstract;

    procedure _GSSetSpawnCount(ucSpawn: uint32); virtual; abstract;
    function _GSGetSteam2GetEncryptionKeyToSendToNewClient(pvEncryptionKey: Pointer; var pcbEncryptionKey: uint32; cbMaxEncryptionKey: uint32): boolean; virtual; abstract;

    function _GSSendSteam2UserConnect(unUserID: uint32; pvRawKey: Pointer;  unKeyLen, unIPPublic: uint32; usPort: uint16; pvCookie: Pointer; cubCookie: uint32): boolean; virtual; abstract;
    function _GSSendSteam3UserConnect(steamID: CSteamID; unIPPublic: uint32; pvCookie: Pointer; cubCookie: uint32): boolean; virtual; abstract;

    function _GSSendUserConnect(unUserID, unIPPublic: uint32; usPort: uint16; pvCookie: Pointer; cubCookie: uint32): boolean; virtual; abstract;
    function _GSRemoveUserConnect(unUserID: uint32): boolean; virtual; abstract;
    function _GSSendUserDisconnect(steamID: CSteamID; unUserID: uint32): boolean; virtual; abstract;

    // Updates server status values which shows up in the server browser and matchmaking APIs
    function _GSUpdateStatus(cPlayers, cPlayersMax, cBotPlayers: int; pchServerName, pSpectatorServerName, pchMapName: pAnsiChar): boolean; virtual; abstract;

    function _GSCreateUnauthenticatedUser(var pSteamID: CSteamID): boolean; virtual; abstract;
  end;

implementation

end.
