unit ISteamFriends004_;

interface

uses
  SteamTypes, FriendsCommon;

type
  ISteamFriends004 = class (TObject)
    // returns the local players name - guaranteed to not be NULL.
    // this is the same name as on the users community profile page
    // this is stored in UTF-8 format
    // like all the other interface functions that return a char *, it's important that this pointer is not saved
    // off; it will eventually be free'd or re-allocated
    function GetPersonaName(): pAnsiChar; virtual; stdcall;
    // sets the player name, stores it on the server and publishes the changes to all friends who are online
    procedure SetPersonaName(pchPersonaName: pAnsiChar); virtual; stdcall;

    // gets the status of the current user
    function GetPersonaState(): EPersonaState; virtual; stdcall;

    // friend iteration
    // takes a set of k_EFriendFlags, and returns the number of users the client knows about who meet that criteria
    // then GetFriendByIndex() can then be used to return the id's of each of those users
    function GetFriendCount(iFriendFlags: int): int; virtual; stdcall;
    // returns the steamID of a user
    // iFriend is a index of range [0, GetFriendCount())
    // iFriendsFlags must be the same value as used in GetFriendCount()
    // the returned CSteamID can then be used by all the functions below to access details about the user
    function GetFriendByIndex(iFriend, iFriendFlags: int): CSteamID; virtual; stdcall;

    // gets the relationship to a user
    function GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship; virtual; stdcall;
    // returns the current status of the specified user
    // this will only be known by the local user if steamIDFriend is in their friends list; on the same game server; in a chat room or lobby; or in a small group with the local user
    function GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState; virtual; stdcall;

    // returns the name another user - guaranteed to not be NULL.
    // same rules as GetFriendPersonaState() apply as to whether or not the user knowns the name of the other user
    // note that on first joining a lobby, chat room or game server the local user will not known the name of the other users automatically; that information will arrive asyncronously
    function GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar; virtual; stdcall;

    // gets the avatar of the current user, which is a handle to be used in IClientUtils::GetImageRGBA(), or 0 if none set
    function GetFriendAvatar(steamIDFriend: CSteamID; eAvatarSize: int): int; virtual; stdcall;

    // returns true if the friend is actually in a game
    function GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean; virtual; stdcall;

    // accesses old friends names - returns an empty string when their are no more items in the history
    function GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar; virtual; stdcall;

    // returns true if the specified user meets any of the criteria specified in iFriendFlags
    // iFriendFlags can be the union (binary or, |) of one or more k_EFriendFlags values
    function HasFriend(steamIDFriend: CSteamID; eFriendFlags: EFriendFlags): boolean; virtual; stdcall;

    // clan (group) iteration and access functions
    function GetClanCount(): int; virtual; stdcall;
    function GetClanByIndex(iClan: int): CSteamID; virtual; stdcall;
    function GetClanName(steamIDClan: CSteamID): pAnsiChar; virtual; stdcall;

    // iterators for getting users in a chat room, lobby, game server or clan
    // note that large clans that cannot be iterated by the local user
    // steamIDSource can be the steamID of a group, game server, lobby or chat room
    function GetFriendCountFromSource(steamIDSource: CSteamID): int; virtual; stdcall;
    function GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID; virtual; stdcall;
    // returns true if the local user can see that steamIDUser is a member or in steamIDSource
    function IsUserInSource(steamIDUser, steamIDSource: CSteamID): boolean; virtual; stdcall;

    // User is in a game pressing the talk button (will suppress the microphone for all voice comms from the Steam friends UI)
    procedure SetInGameVoiceSpeaking(steamIDUser: CSteamID; bSpeaking: boolean); virtual; stdcall;

    // activates the game overlay, with an optional dialog to open
    // valid options are "Friends", "Community", "Players", "Settings", "LobbyInvite", "OfficialGameGroup"
    procedure ActivateGameOverlay(pchDialog: pAnsiChar); virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverFreiend004CppToI(Cpp: Pointer): ISteamFriends004;

implementation

function ConverFreiend004CppToI(Cpp: Pointer): ISteamFriends004;
begin
  result:=ISteamFriends004.Create();
  result.fCpp:=Cpp;
end;

function ISteamFriends004.GetPersonaName(): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+00]
end;

procedure ISteamFriends004.SetPersonaName(pchPersonaName: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchPersonaName
  call [EAX+04]
end;

function ISteamFriends004.GetPersonaState(): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+08]
end;

function ISteamFriends004.GetFriendCount(iFriendFlags: int): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriendFlags
  call [EAX+12]
end;

function ISteamFriends004.GetFriendByIndex(iFriend, iFriendFlags: integer): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriendFlags
  push iFriend
  call [EAX+16]
end;

function ISteamFriends004.HasFriend(steamIDFriend: CSteamID; eFriendFlags: EFriendFlags): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(eFriendFlags)
  push integer(steamIDFriend)
  call [EAX+20]
end;

function ISteamFriends004.GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+24]
end;

function ISteamFriends004.GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+28]
end;

function ISteamFriends004.GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+32]
end;

function ISteamFriends004.GetFriendAvatar(steamIDFriend: CSteamID; eAvatarSize: int): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push eAvatarSize
  push integer(steamIDFriend)
  call [EAX+36]
end;

function ISteamFriends004.GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iPersonaName
  push integer(steamIDFriend)
  call [EAX+40]
end;

function ISteamFriends004.GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pusGamePort
  push punGameIP
  push pnGameID
  push integer(steamIDFriend)
  call [EAX+44]
end;

function ISteamFriends004.GetClanCount(): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+48]
end;

function ISteamFriends004.GetClanByIndex(iClan: int): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iClan
  call [EAX+52]
end;

function ISteamFriends004.GetClanName(steamIDClan: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDClan)
  call [EAX+56]
end;

function ISteamFriends004.GetFriendCountFromSource(steamIDSource: CSteamID): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDSource)
  call [EAX+60]
end;

function ISteamFriends004.GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriend
  push integer(steamIDSource)
  call [EAX+64]
end;

function ISteamFriends004.IsUserInSource(steamIDUser, steamIDSource: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDSource)
  push integer(steamIDUser)
  call [EAX+68]
end;

procedure ISteamFriends004.SetInGameVoiceSpeaking(steamIDUser: CSteamID; bSpeaking: boolean);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(bSpeaking)
  push integer(steamIDUser)
  call [EAX+72]
end;

procedure ISteamFriends004.ActivateGameOverlay(pchDialog: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchDialog
  call [EAX+76]
end;

end.
