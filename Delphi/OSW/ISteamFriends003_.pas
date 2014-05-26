unit ISteamFriends003_;

interface

uses
  SteamTypes, FriendsCommon;

type
  ISteamFriends003 = class (TObject)
    // returns the local players name - guaranteed to not be NULL.
    function GetPersonaName(): pAnsiChar; virtual; stdcall;
    // sets the player name, stores it on the server and publishes the changes to all friends who are online
    procedure SetPersonaName(pchPersonaName: pAnsiChar); virtual; stdcall;

    // gets the friend status of the current user
    function GetPersonaState(): EPersonaState; virtual; stdcall;

    // friend iteration
    function GetFriendCount(iFriendFlags: int): int; virtual; stdcall;
    function GetFriendByIndex(iFriend, iFriendFlags: int): CSteamID; virtual; stdcall;

    // gets the relationship to a user
    function GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship; virtual; stdcall;
    // returns true if the specified user is considered a friend (can see our online status)
    function GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState; virtual; stdcall;

    // returns the name of a friend - guaranteed to not be NULL.
    function GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar; virtual; stdcall;

    // gets the avatar of the current user, which is a handle to be used in IClientUtils::GetImageRGBA(), or 0 if none set
    function GetFriendAvatar(steamIDFriend: CSteamID): int; virtual; stdcall;

    // returns true if the friend is actually in a game
    function GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean; virtual; stdcall;

    // accesses old friends names - returns an empty string when their are no more items in the history
    function GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar; virtual; stdcall;

    // returns true if the specified user is considered a friend (can see our online status)
    function HasFriend(steamIDFriend: CSteamID; eFriendFlags: EFriendFlags): boolean; virtual; stdcall;

    // clan functions
    function GetClanCount(): int; virtual; stdcall;
    function GetClanByIndex(iClan: int): CSteamID; virtual; stdcall;
    function GetClanName(steamIDClan: CSteamID): pAnsiChar; virtual; stdcall;

    // iterators for any source
    function GetFriendCountFromSource(steamIDSource: CSteamID): int; virtual; stdcall;
    function GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID; virtual; stdcall;
    function IsUserInSource(steamIDUser, steamIDSource: CSteamID): boolean; virtual; stdcall;

    // User is in a game pressing the talk button (will suppress the microphone for all voice comms from the Steam friends UI)
    procedure SetInGameVoiceSpeaking(steamIDUser: CSteamID; bSpeaking: boolean); virtual; stdcall;

    // activates the game overlay, with an optional dialog to open ("Friends", "Community", "Players", "Settings")
    procedure ActivateGameOverlay(pchDialog: pAnsiChar); virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverFreiend003CppToI(Cpp: Pointer): ISteamFriends003;

implementation

function ConverFreiend003CppToI(Cpp: Pointer): ISteamFriends003;
begin
  result:=ISteamFriends003.Create();
  result.fCpp:=Cpp;
end;

function ISteamFriends003.GetPersonaName(): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+00]
end;

procedure ISteamFriends003.SetPersonaName(pchPersonaName: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchPersonaName
  call [EAX+04]
end;

function ISteamFriends003.GetPersonaState(): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+08]
end;

function ISteamFriends003.GetFriendCount(iFriendFlags: int): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriendFlags
  call [EAX+12]
end;

function ISteamFriends003.GetFriendByIndex(iFriend, iFriendFlags: integer): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriendFlags
  push iFriend
  call [EAX+16]
end;

function ISteamFriends003.HasFriend(steamIDFriend: CSteamID; eFriendFlags: EFriendFlags): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(eFriendFlags)
  push integer(steamIDFriend)
  call [EAX+20]
end;

function ISteamFriends003.GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+24]
end;

function ISteamFriends003.GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+28]
end;

function ISteamFriends003.GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+32]
end;

function ISteamFriends003.GetFriendAvatar(steamIDFriend: CSteamID): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+36]
end;

function ISteamFriends003.GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iPersonaName
  push integer(steamIDFriend)
  call [EAX+40]
end;

function ISteamFriends003.GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean;
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

function ISteamFriends003.GetClanCount(): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+48]
end;

function ISteamFriends003.GetClanByIndex(iClan: int): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iClan
  call [EAX+52]
end;

function ISteamFriends003.GetClanName(steamIDClan: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDClan)
  call [EAX+56]
end;

function ISteamFriends003.GetFriendCountFromSource(steamIDSource: CSteamID): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDSource)
  call [EAX+60]
end;

function ISteamFriends003.GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriend
  push integer(steamIDSource)
  call [EAX+64]
end;

function ISteamFriends003.IsUserInSource(steamIDUser, steamIDSource: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDSource)
  push integer(steamIDUser)
  call [EAX+68]
end;

procedure ISteamFriends003.SetInGameVoiceSpeaking(steamIDUser: CSteamID; bSpeaking: boolean);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(bSpeaking)
  push integer(steamIDUser)
  call [EAX+72]
end;

procedure ISteamFriends003.ActivateGameOverlay(pchDialog: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchDialog
  call [EAX+76]
end;


end.
