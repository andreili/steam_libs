unit ISteamMatchmaking002_;

interface

uses
  SteamTypes, MatchmakingCommon, FriendsCommon;

type
  ISteamMatchmaking002 = class (TObject)
    procedure _Destructor(); virtual; abstract;

    function GetFavoriteGameCount(): int; virtual; abstract;

    // returns the details of the game server
    // iGame is of range [0,iGame)
    function GetFavoriteGame(iGame: int; var pnAppID, pnIP: uint32; var pnConnPort, pnQueryPort: uint16; var punFlags, pRTime32LastPlayedOnServer: uint32): bool; virtual; abstract;
    // returns the new index of the game
    function AddFavoriteGame(nAppID, nIP: uint32; nConnPort, nQueryPort: uint16; unFlags, rTime32LastPlayedOnServer: uint32): int; virtual; abstract;
    // removes the game; returns true if one was removed
    function RemoveFavoriteGame(nAppID, nIP: uint32; nConnPort, nQueryPort: uint16; unFlags: uint32): bool; virtual; abstract;

    ///////
    // Game lobby functions
    // Get a list of relevant lobbies
    procedure RequestLobbyList(); virtual; abstract;
    function GetLobbyByIndex(iLobby: int): CSteamID; virtual; abstract;
    // Create a lobby - you'll get the SteamID of it on success
    procedure CreateLobby(bPrivate: bool); virtual; abstract;
    // Join a lobby
    procedure JoinLobby(steamIDLobby: CSteamID); virtual; abstract;
    // Leave a lobby
    procedure LeaveLobby(steamIDLobby: CSteamID); virtual; abstract;
    // Invite someone to the lobby
    function InviteUserToLobby(steamIDLobby, steamIDInvitee: CSteamID): bool; virtual; abstract;
    // List users in this lobby
    function GetNumLobbyMembers(steamIDLobby: CSteamID): int; virtual; abstract;
    function GetLobbyMemberByIndex(steamIDLobby: CSteamID; iMember: int): CSteamID; virtual; abstract;
    // Get data associated with this lobby
    function GetLobbyData(SteamIDLobby: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; abstract;
    // Update lobby data (Admin only)
    procedure SetLobbyData(steamIDLobby: CSteamID; pchKey, pchValue: pAnsiChar); virtual; abstract;
    // Get per-user data for someone in this lobby
    function GetLobbyMemberData(steamIDLobby, steamIDUser: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; abstract;
    // Update user data (for you only)
    procedure SetLobbyMemberData(steamIDLobby: CSteamID; pchKey, pchValue: pAnsiChar); virtual; abstract;
    // Send a chat message to the lobby(
    function SendLobbyChatMsg(steamIDLobby: CSteamID; pvMsgBody: pAnsiChar; cubMsgBody: int): bool; virtual; abstract;
    // Get a chat message entry
    function GetLobbyChatEntry(steamIDLobby: CSteamID; iChatID: int; var pSteamIDUser: CSteamID; pvData: Pointer; cubData: int; var peChatEntryType: EChatEntryType): int; virtual; abstract;

    // Refreshes metadata for a lobby you're not necessarily in right now
    // you never do this for lobbies you're a member of, only if your
    // this will send down all the metadata associated with a lobby
    // this is an asynchronous call
    // returns false if the local user is not connected to the Steam servers
    // restart are returned by a LobbyDataUpdate_t callback
    function RequestLobbyData(steamIDLobby: CSteamID): bool; virtual; abstract;

    // sets the game server associated with the lobby
    // usually at this point, the users will join the specified game server
    // either the IP/Port or the steamID of the game server has to be valid, depending on how you want the clients to be able to connect
    procedure SetLobbyGameServer(steamIDLobby: CSteamID; unGameServerIP: uint32; unGameServerPort: uint16;
     steamIDGameServer: CSteamID); virtual; abstract;
  end;

implementation

end.
