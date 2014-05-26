unit ISteamUser006_;

interface

uses
  SteamTypes, UserCommon;

type
  ISteamUser006 = class
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

    // returns the CSteamID of the account currently logged into the Steam client
    // a CSteamID is a unique identifier for an account, and used to differentiate users in all parts of the Steamworks API
    function GetSteamID(): CSteamID; virtual; abstract;

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
    function InitiateGameConnection(pOutputBlob: Pointer; cbBlobMax: int; steamID: CSteamID; gameID: CGameID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean; virtual; abstract;

    // notify of disconnect
    // needs to occur when the game client leaves the specified game server, needs to match with the InitiateGameConnection() call
    procedure TerminateGameConnection(unIPServer: uint32; usPortServer: uint16); virtual; abstract;
  end;

implementation

end.
