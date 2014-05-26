unit ISteamUser005_;

interface

uses
  SteamTypes, UserCommon;

type
  ISteamUser005 = class
    // returns the HSteamUser this interface represents
    // this is only used internally by the API, and by a few select interfaces that support multi-user
    function GetHSteamUser(): HSteamUser; virtual; abstract;

    // steam account management functions
    procedure LogOn(steamID: CSteamID); virtual; abstract;
    procedure LogOff(); virtual; abstract;
    // returns true if the Steam client current has a live connection to the Steam servers.
    // If false, it means there is no active connection due to either a networking issue on the local machine, or the Steam server is down/busy.
    // The Steam client will automatically be trying to recreate the connection as often as possible.
    function LoggedOn(): boolean; virtual; abstract;
    function GetLogonState(): ELogonState; virtual; abstract;
    function Connected(): boolean; virtual; abstract;

    // returns the CSteamID of the account currently logged into the Steam client
    // a CSteamID is a unique identifier for an account, and used to differentiate users in all parts of the Steamworks API
    function GetSteamID(): CSteamID; virtual; abstract;

    // returns true if this account is VAC banned from the specified ban set// returns true if this account is VAC banned from the specified ban set
    function IsVACBanned(nGameID: AppId_t): boolean; virtual; abstract;
    // returns true if the user needs to see the newly-banned message from the specified ban set
    function RequireShowVACBannedMessage(nAppID: AppId_t): boolean; virtual; abstract;
    // tells the server that the user has seen the 'you have been banned' dialog
    procedure AcknowledgeVACBanning(nAppID: AppId_t); virtual; abstract;

    // steam2 stuff
    procedure SetSteam2Ticket(pubTicket: puint8; cubTicket: int); virtual; abstract;
    procedure AddServerNetAddress(unIP: uint32; unPort: uint16); virtual; abstract;

    // email address setting
    function SetEmail(pchEmail: pAnsiChar): boolean; virtual; abstract;

    // persist per user data
    function SetRegistryString(eRegistrySubTree: ERegistrySubTree; pchKey, pchValue: pAnsiChar): boolean; virtual; abstract;
    function GetRegistryString(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; var pchValue: pAnsiChar; cbValue: int): boolean; virtual; abstract;
    function SetRegistryInt(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; iValue: int): boolean; virtual; abstract;
    function GetRegistryInt(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; var pValue: int): boolean; virtual; abstract;

    // InitiateGameConnection() starts the state machine for authenticating the game client with the game server
    // It is the client portion of a three-way handshake between the client, the game server, and the steam servers
    //
    // Parameters:
    // void *pAuthBlob - a pointer to empty memory that will be filled in with the authentication token.
    // int cbMaxAuthBlob - the number of bytes of allocated memory in pBlob. Should be at least 2048 bytes.
    // CSteamID steamIDGameServer - the steamID of the game server, received from the game server by the client
    // int nGameID - the ID of the current game.
    // uint32 unIPServer, uint16 usPortServer - the IP address of the game server
    // bool bSecure - whether or not the client thinks that the game server is reporting itself as secure (i.e. VAC is running)
    //
    // return value - returns the number of bytes written to pBlob. If the return is 0, then the buffer passed in was too small, and the call has failed
    // The contents of pBlob should then be sent to the game server, for it to use to complete the authentication process.
    function InitiateGameConnection(pOutputBlob: Pointer; cbBlobMax: int; steamIDGS: CSteamID; gameID: CGameID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean; virtual; abstract;

    // notify of disconnect
    // needs to occur when the game client leaves the specified game server, needs to match with the InitiateGameConnection() call
    procedure TerminateGameConnection(unIPServer: uint32; usPortServer: uint16); virtual; abstract;

    // controls where chat messages go to - puts the caller on top of the stack of chat destinations
    procedure SetSelfAsPrimaryChatDestination(); virtual; abstract;
    // returns true if the current caller is the one that should open new chat dialogs
    function IsPrimaryChatDestination(): boolean;  virtual; abstract;

    procedure RequestLegacyCDKey(iAppID: AppId_t); virtual; abstract;

    function SendGuestPassByEmail(pchEmailAccount: pAnsiChar; gidGuestPassID: GID_t; bResending: boolean): boolean; virtual; abstract;
    function SendGuestPassByAccountID(uAccountID: uint32; gidGuestPassID: GID_t; bResending: boolean): boolean; virtual; abstract;

    function AckGuestPass(pchGuestPassCode: pAnsiChar): boolean; virtual; abstract;
    function RedeemGuestPass(pchGuestPassCode: pAnsiChar): boolean; virtual; abstract;

    function GetGuestPassToGiveCount(): uint32; virtual; abstract;
    function GetGuestPassToRedeemCount(): uint32; virtual; abstract;
    function GetGuestPassLastUpdateTime(): uint32; virtual; abstract;

    function GetGuestPassToGiveInfo(nPassIndex: uint32; var pgidGuestPassID: GID_t; var pnPackageID: PackageId_t;
     var pRTime32Created, pRTime32Expiration, pRTime32Sent, pRTime32Redeemed: RTime32; pchRecipientAddress: pAnsiChar;
     cRecipientAddressSize: int): boolean; virtual; abstract;
    function GetGuestPassToRedeemInfo(nPassIndex: uint32; var pgidGuestPassID: GID_t; var pnPackageID: PackageId_t;
     var pRTime32Created, pRTime32Expiration, pRTime32Sent, pRTime32Redeemed: RTime32): boolean; virtual; abstract;
    function GetGuestPassToRedeemSenderAddress(nPassIndex: uint32; pchSenderAddress: pAnsiChar; cSenderAddressSize: int): boolean; virtual; abstract;
    function GetGuestPassToRedeemSenderName(nPassIndex: uint32; pchSenderName: pAnsiChar; cSenderNameSize: int): boolean; virtual; abstract;

    function RequestGuestPassTargetList(gidGuestPassID: GID_t): boolean; virtual; abstract;

    function RequestGiftTargetList(nPackageID: PackageId_t): boolean; virtual; abstract;

    procedure AcknowledgeMessageByGID(pchMessageGID: pAnsiChar); virtual; abstract;

    function SetLanguage(pchLanguage: pAnsiChar): boolean; virtual; abstract;

    procedure TrackAppUsageEvent(gameID: CGameID; eAppUsageEvent: int; pchExtraInfo: pAnsiChar); virtual; abstract;

    function SetAccountName(pchName: pAnsiChar): unknown_ret; virtual; abstract;
    function SetPassword(pchPassword: pAnsiChar): unknown_ret; virtual; abstract;

    function SetAccountCreationTime(uTime: RTime32): unknown_ret; virtual; abstract;
  end;

implementation

end.
