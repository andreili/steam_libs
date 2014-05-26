unit ISteamUser012_;

interface

uses
  SteamTypes, UserCommon;

type
  ISteamUser012 = class
    // returns the HSteamUser this interface represents
    // this is only used internally by the API, and by a few select interfaces that support multi-user
    function GetHSteamUser(): HSteamUser; virtual; abstract;

    // returns true if the Steam client current has a live connection to the Steam servers.
    // If false, it means there is no active connection due to either a networking issue on the local machine, or the Steam server is down/busy.
    // The Steam client will automatically be trying to recreate the connection as often as possible.
    function LoggedOn(): boolean; virtual; abstract;

    // returns the CSteamID of the account currently logged into the Steam client
    // a CSteamID is a unique identifier for an account, and used to differentiate users in all parts of the Steamworks API
    function GetSteamID(): CSteamID; virtual; abstract;

    // Multiplayer Authentication functions

    // InitiateGameConnection() starts the state machine for authenticating the game client with the game server
    // It is the client portion of a three-way handshake between the client, the game server, and the steam servers
    //
    // Parameters:
    // void *pAuthBlob - a pointer to empty memory that will be filled in with the authentication token.
    // int cbMaxAuthBlob - the number of bytes of allocated memory in pBlob. Should be at least 2048 bytes.
    // CSteamID steamIDGameServer - the steamID of the game server, received from the game server by the client
    // CGameID gameID - the ID of the current game. For games without mods, this is just CGameID( <appID> )
    // uint32 unIPServer, uint16 usPortServer - the IP address of the game server
    // bool bSecure - whether or not the client thinks that the game server is reporting itself as secure (i.e. VAC is running)
    // void pvSteam2GetEncryptionKey - unknown
    // int cbSteam2GetEncryptionKey - unknown
    //
    // return value - returns the number of bytes written to pBlob. If the return is 0, then the buffer passed in was too small, and the call has failed
    // The contents of pBlob should then be sent to the game server, for it to use to complete the authentication process.
    function InitiateGameConnection(pAuthBlob: Pointer; cbMaxAuthBlob: int; steamIDGameServer: CSteamID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean; virtual; abstract;

    // notify of disconnect
    // needs to occur when the game client leaves the specified game server, needs to match with the InitiateGameConnection() call
    procedure TerminateGameConnection(unIPServer: uint32; usPortServer: uint16); virtual; abstract;

    // Legacy functions

    // legacy authentication support - need to be called if the game server rejects the user with a 'bad ticket' error
    procedure RefreshSteam2Login(); virtual; abstract;

    // get the local storage folder for current Steam account to write application data, e.g. save games, configs etc.
    // this will usually be something like "C:\Progam Files\Steam\userdata\<SteamID>\<AppID>\local"
    function GetUserDataFolder(gameID: CGameID; pchBuffer: pAnsiChar; cubBuffer: int): boolean; virtual; abstract;

    // Starts voice recording. Once started, use GetCompressedVoice() to get the data
    procedure StartVoiceRecording(); virtual; abstract;

    // Stops voice recording. Because people often release push-to-talk keys early, the system will keep recording for
    // a little bit after this function is called. GetCompressedVoice() should continue to be called until it returns
    // k_eVoiceResultNotRecording
    procedure StopVoiceRecording(); virtual; abstract;

    // Gets the latest voice data. It should be called as often as possible once recording has started.
    // nBytesWritten is set to the number of bytes written to pDestBuffer.
    function GetCompressedVoice(pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32): EVoiceResult; virtual; abstract;

    // Decompresses a chunk of data produced by GetCompressedVoice(). nBytesWritten is set to the
    // number of bytes written to pDestBuffer. The output format of the data is 16-bit signed at
    // 11025 samples per second.
    function DecompressVoice(pCompressed: Pointer; cbCompressed: uint32; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32): EVoiceResult; virtual; abstract;

    // Retrieve ticket to be sent to the entity who wishes to authenticate you.
    // pcbTicket retrieves the length of the actual ticket.
    function GetAuthSessionTicket(pMyAuthTicket: Pointer; cbMaxMyAuthTicket: int;
     var pcbAuthTicket: uint32): HAuthTicket; virtual; abstract;

    // Authenticate ticket from entity steamID to be sure it is valid and isnt reused
    // Registers for callbacks if the entity goes offline or cancels the ticket ( see ValidateAuthTicketResponse_t callback and EAuthSessionResponse )
    function BeginAuthSession(pTheirAuthTicket: Pointer; cbTicket: int;
     steamID: CSteamID): EBeginAuthSessionResult; virtual; abstract;

    // Stop tracking started by BeginAuthSession - called when no longer playing game with this entity
    procedure EndAuthSession(steamID: CSteamID); virtual; abstract;

    // Cancel auth ticket from GetAuthSessionTicket, called when no longer playing game with the entity you gave the ticket to
    procedure CancelAuthTicket(hAuthTicket: HAuthTicket); virtual; abstract;

    // After receiving a user's authentication data, and passing it to BeginAuthSession, use this function
    // to determine if the user owns downloadable content specified by the provided AppID.
    //virtual EUserHasLicenseForAppResult UserHasLicenseForApp( CSteamID steamID, AppId_t appID ) = 0;
    function UserHasLicenseForApp(steamID: CSteamID; appID: AppId_t): uint32; virtual; abstract;
  end;

implementation

end.
