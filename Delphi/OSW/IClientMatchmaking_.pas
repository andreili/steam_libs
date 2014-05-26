unit IClientMatchmaking_;

interface

uses
  SteamTypes, MatchmakingCommon, UserCommon, FriendsCommon;

type
  IClientMatchmaking = class
    function GetFavoriteGameCount(): int; virtual; abstract;
    function GetFavoriteGame(iGame: int; var pnAppID: AppId_t; var pnIP: uint32;
     var pnConnPort, pnQueryPort: uint16;
     var punFlags, pRTime32LastPlayedOnServer: uint32): boolean; virtual; abstract;
    function AddFavoriteGame(nAppID: AppId_t; nIP: uint32; nConnPort, nQueryPort: uint16;
     unFlags, rTime32LastPlayedOnServer: uint32): int; virtual; abstract;
    function RemoveFavoriteGame(nAppID: AppId_t; nIP: uint32; nConnPort, nQueryPort: uint16;
     unFlags: uint32): boolean;  virtual; abstract;

    function RequestLobbyList(): SteamAPICall_t; virtual; abstract;

    procedure AddRequestLobbyListStringFilter(pchKeyToMatch, pchValueToMatch: pAnsiChar;
     eComparisonType: ELobbyComparison); virtual; abstract;
    procedure AddRequestLobbyListNumericalFilter(pchKeyToMatch: pAnsiChar; nValueToMatch: int;
     eComparisonType: ELobbyComparison); virtual; abstract;
    procedure AddRequestLobbyListNearValueFilter(pchKeyToMatch: pAnsiChar; nValueToBeCloseTo: int); virtual; abstract;
    procedure ValueToBeCloseTo(nSlotsAvailable: int); virtual; abstract;
    procedure AddRequestLobbyListDistanceFilter(filter: ELobbyDistanceFilter); virtual; abstract;
    procedure AddRequestLobbyListResultCountFilter(cMaxResults: int); virtual; abstract;

    function GetLobbyByIndex(iLobby: int): CSteamID; virtual; abstract;

    function CreateLobby(eLobbyType: ELobbyType; cMaxMembers: int): SteamAPICall_t; virtual; abstract;
    function JoinLobby(steamIDLobby: CSteamID): SteamAPICall_t; virtual; abstract;
    procedure LeaveLobby(steamIDLobby: CSteamID); virtual; abstract;
    function InviteUserToLobby(steamIDLobby, steamIDInvitee: CSteamID): boolean; virtual; abstract;

    function GetNumLobbyMembers(steamIDLobby: CSteamID): int; virtual; abstract;
    function GetLobbyMemberByIndex(steamIDLobby: CSteamID; iMember: int): CSteamID; virtual; abstract;

    function GetLobbyData(steamIDLobby: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; abstract;
    function SetLobbyData(steamIDLobby: CSteamID; pchKey, pchValue: pAnsiChar): boolean; virtual; abstract;

    function GetLobbyDataCount(steamIDLobby: CSteamID): int; virtual; abstract;
    function GetLobbyDataByIndex(steamIDLobby: CSteamID; iLobbyData: int; pchKey: pAnsiChar;
     cchKeyBufferSize: int; pchValue: pAnsiChar; cchValueBufferSize: int): boolean; virtual; abstract;
    function DeleteLobbyData(steamIDLobby: CSteamID; pchKey: pAnsiChar): boolean; virtual; abstract;

    function GetLobbyMemberData(steamIDLobby, steamIDUser: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; abstract;
    function SetLobbyMemberData(steamIDLobby: CSteamID; pchKey, pchValue: pAnsiChar): boolean; virtual; abstract;

    function SendLobbyChatMsg(steamIDLobby: CSteamID; pvMsgBody: Pointer; cubMsgBody: int): boolean; virtual; abstract;
    function GetLobbyChatEntry(steamIDLobby: CSteamID; iChatID: int; var pSteamIDUser: CSteamID;
     pvData: Pointer; cubData: int; var peChatEntryType: EChatEntryType): int; virtual; abstract;

    function RequestLobbyData(steamIDLobby: CSteamID): boolean; virtual; abstract;

    procedure SetLobbyGameServer(steamIDLobby: CSteamID; unGameServerIP: uint32; unGameServerPort: uint16;
     steamIDGameServer: CSteamID); virtual; abstract;
    function GetLobbyGameServer(steamIDLobby: CSteamID; var unGameServerIP: uint32; var unGameServerPort: uint16;
     var steamIDGameServer: CSteamID): boolean; virtual; abstract;

    function SetLobbyMemberLimit(steamIDLobby: CSteamID; cMaxMembers: int): boolean; virtual; abstract;
    function GetLobbyMemberLimit(steamIDLobby: CSteamID): int; virtual; abstract;

    procedure SetLobbyVoiceEnabled(steamIDLobby: CSteamID; bVoiceEnabled: boolean); virtual; abstract;
    function RequestFriendsLobbies(): boolean; virtual; abstract;

    function SetLobbyType(steamIDLobby: CSteamID; eLobbyType: ELobbyType): boolean; virtual; abstract;
    function SetLobbyJoinable(steamIDLobby: CSteamID; bLobbyJoinable: boolean): boolean; virtual; abstract;
    function GetLobbyOwner(steamIDLobby: CSteamID): CSteamID; virtual; abstract;
    function SetLobbyOwner(steamIDLobby, steamIDNewOwner: CSteamID): boolean; virtual; abstract;

    function GetGMSServerCount(): int; virtual; abstract;
    function GetGMSServerAddress(iServer: int; var unServerIP: uint32; var usServerPort: uint16): boolean; virtual; abstract;
  end;

implementation

end.
