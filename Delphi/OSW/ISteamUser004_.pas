unit ISteamUser004_;

interface

uses
  SteamTypes, UserCommon;

type
  ISteamUser004 = class
    // returns the HSteamUser this interface represents
    // this is only used internally by the API, and by a few select interfaces that support multi-user
    function GetHSteamUser(): HSteamUser; virtual; stdcall;

    // steam account management functions
    procedure LogOn(steamID: CSteamID); virtual; stdcall;
    procedure LogOff(); virtual; stdcall;
    // returns true if the Steam client current has a live connection to the Steam servers.
    // If false, it means there is no active connection due to either a networking issue on the local machine, or the Steam server is down/busy.
    // The Steam client will automatically be trying to recreate the connection as often as possible.
    function LoggedOn(): boolean; virtual; stdcall;
    function GetLogonState(): ELogonState; virtual; stdcall;
    function Connected(): boolean; virtual; stdcall;

    // returns the CSteamID of the account currently logged into the Steam client
    // a CSteamID is a unique identifier for an account, and used to differentiate users in all parts of the Steamworks API
    function GetSteamID(): CSteamID; virtual; stdcall;

    // account state

    // returns true if this account is VAC banned from the specified ban set// returns true if this account is VAC banned from the specified ban set
    function IsVACBanned(nGameID: AppId_t): boolean; virtual; stdcall;
    // returns true if the user needs to see the newly-banned message from the specified ban set
    function RequireShowVACBannedMessage(nAppID: AppId_t): boolean; virtual; stdcall;
    // tells the server that the user has seen the 'you have been banned' dialog
    procedure AcknowledgeVACBanning(nAppID: AppId_t); virtual; stdcall;

   { // registering/unregistration game launches functions
    // unclear as to where these should live
    // These are dead.
    function NClientGameIDAdd(nGameID: int): int; virtual; stdcall;
    procedure RemoveClientGame(nClientGameID: int); virtual; stdcall;
    procedure SetClientGameServer(nClientGameID: int; unIPServer: uint32; usPortServer: uint16); virtual; stdcall;

    // steam2 stuff
    procedure SetSteam2Ticket(pubTicket: puint8; cubTicket: int); virtual; stdcall;
    procedure AddServerNetAddress(unIP: uint32; unPort: uint16); virtual; stdcall;

    // email address setting
    function SetEmail(pchEmail: pAnsiChar): boolean; virtual; stdcall;

    // logon cookie - this is obsolete
    function Obsolete_GetSteamGameConnectToken(pBlob: Pointer; cbMaxBlob: int): int; virtual; stdcall;

    // persist per user data
    function SetRegistryString(eRegistrySubTree: ERegistrySubTree; pchKey, pchValue: pAnsiChar): boolean; virtual; stdcall;
    function GetRegistryString(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; var pchValue: pAnsiChar; cbValue: int): boolean; virtual; stdcall;
    function SetRegistryInt(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; iValue: int): boolean; virtual; stdcall;
    function GetRegistryInt(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; var pValue: int): boolean; virtual; stdcall;

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
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean; virtual; stdcall;

    // notify of disconnect
    // needs to occur when the game client leaves the specified game server, needs to match with the InitiateGameConnection() call
    procedure TerminateGameConnection(unIPServer: uint32; usPortServer: uint16); virtual; stdcall;

    // controls where chat messages go to - puts the caller on top of the stack of chat destinations
    procedure SetSelfAsPrimaryChatDestination(); virtual; stdcall;
    // returns true if the current caller is the one that should open new chat dialogs
    function IsPrimaryChatDestination(): boolean;  virtual; stdcall;

    procedure RequestLegacyCDKey(iAppID: AppId_t); virtual; stdcall;      }
  private
    fCpp: Pointer;
  end;

function ConverUser004CppToI(Cpp: Pointer): ISteamUser004;

implementation

function ConverUser004CppToI(Cpp: Pointer): ISteamUser004;
begin
  result:=ISteamUser004.Create();
  result.fCpp:=Cpp;
end;

function ISteamUser004.GetHSteamUser(): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+00]
  mov ESP, EBP
end;

procedure ISteamUser004.LogOn(steamID: CSteamID);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push integer(steamID)
  call [EAX+04]
  mov ESP, EBP
end;

procedure ISteamUser004.LogOff();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+08]
  mov ESP, EBP
end;

function ISteamUser004.LoggedOn(): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov ECX, EAX
  mov EAX, [EAX]
  push ECX
  call [EAX+12]
  mov ESP, EBP
end;

function ISteamUser004.GetLogonState(): ELogonState;
asm
  mov EAX, [EBX+$04]
  mov ECX, [EBX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push ECX
  call [EAX+16]
  mov ESP, EBP
end;

function ISteamUser004.Connected(): boolean;
asm
  mov EAX, [EBX+$04]
  mov ECX, [EBX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push ECX
  call [EAX+20]
  mov ESP, EBP
end;

function ISteamUser004.GetSteamID(): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+24]
  mov ESP, EBP
end;

function ISteamUser004.IsVACBanned(nGameID: AppId_t): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push nGameID
  call [EAX+28]
end;
function ISteamUser004.RequireShowVACBannedMessage(nAppID: AppId_t): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push nAppID
  call [EAX+32]
end;
procedure ISteamUser004.AcknowledgeVACBanning(nAppID: AppId_t);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push nAppID
  call [EAX+36]
end;
 {
procedure ISteamUser004.TerminateGameConnection(unIPServer: uint32; usPortServer: uint16);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push usPortServer
  push unIPServer
  call [EAX+16]
end;     }

end.
