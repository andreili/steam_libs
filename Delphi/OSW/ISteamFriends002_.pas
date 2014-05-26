unit ISteamFriends002_;

interface

uses
  SteamTypes, FriendsCommon;

type
  ISteamFriends002 = class (TObject)
    // returns the local players name - guaranteed to not be NULL.
    function GetPersonaName(): pAnsiChar; virtual; stdcall;
    // sets the player name, stores it on the server and publishes the changes to all friends who are online
    procedure SetPersonaName(pchPersonaName: pAnsiChar); virtual; stdcall;

    // gets the friend status of the current user
    function GetPersonaState(): EPersonaState; virtual; stdcall;
    // sets the status, communicates to server, tells all friends
    procedure SetPersonaState(ePersonaState: EPersonaState); virtual; stdcall;

    // gets the relationship to a user
    function GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship; virtual; stdcall;
    // returns true if the specified user is considered a friend (can see our online status)
    function GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState; virtual; stdcall;

    // returns the name of a friend - guaranteed to not be NULL.
    function GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar; virtual; stdcall;

    // steam registry, accessed by friend
    procedure SetFriendRegValue(steamIDFriend: CSteamID; pchKey, pchValue: pAnsiChar); virtual; stdcall;
    function GetFriendRegValue(steamIDFriend: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; stdcall;

    // returns true if the friend is actually in a game
    function GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean; virtual; stdcall;

    // accesses old friends names - returns an empty string when their are no more items in the history
    function GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar; virtual; stdcall;

    // adds a friend to the users list.  Friend will be notified that they have been added, and have the option of accept/decline
    function AddFriend(steamIDFriend: CSteamID): boolean; virtual; stdcall;
    // removes the friend from the list, and blocks them from contacting the user again
    function RemoveFriend(steamIDFriend: CSteamID): boolean; virtual; stdcall;
    // returns true if the specified user is considered a friend (can see our online status)
    function HasFriend(steamIDFriend: CSteamID; eFriendFlags: EFriendFlags): boolean; virtual; stdcall;

    // adds a friend by email address or account name - value returned in callback
    function AddFriendByName(pchEmailOrAccountName: pAnsiChar): HSteamCall; virtual; stdcall;

    function InviteFriendByEmail(emailAddr: pAnsiChar): unknown_ret; virtual; stdcall;


    // chat message iteration
    // returns the number of bytes in the message, filling pvData with as many of those bytes as possible
    // returns 0 if the steamID or iChatID are invalid
    function GetChatMessage(steamIDFriend: CSteamID; iChatID: integer; pvData: Pointer; cubData: integer; var peFriendMsgType: EFriendMsgType): integer; virtual; stdcall;

    // generic friend->friend message sending, takes a sized buffer
    function SendMsgToFriend2(steamIDFriend: CSteamID; eFriendMsgType: EFriendMsgType; pvMsgBody: Pointer; cubMsgBody: integer): boolean; virtual; stdcall;

    // returns the chatID that a chat should be resumed from when switching chat contexts
    function GetChatIDOfChatHistoryStart(steamIDFriend: CSteamID): integer; virtual; stdcall;
    // sets where a chat with a user should resume
    procedure SetChatHistoryStart(steamIDFriend: CSteamID; iChatID: integer); virtual; stdcall;
    // clears the chat history - should be called when a chat dialog closes
    // the chat history can still be recovered by another context using SetChatHistoryStart() to reset the ChatIDOfChatHistoryStart
    procedure ClearChatHistory(steamIDFriend: CSteamID); virtual; stdcall;

    // clan functions
    function GetClanCount(): int; virtual; stdcall;
    function GetClanByIndex(iClan: int): CSteamID; virtual; stdcall;
    function GetClanName(steamIDClan: CSteamID): pAnsiChar; virtual; stdcall;

    function InviteFriendToClan(steamIDfriend, steamIDclan: CSteamID): unknown_ret; virtual; stdcall;
    function AcknowledgeInviteToClan(steamID: CSteamID; a1: boolean): unknown_ret; virtual; stdcall;

    function GetFriendCountFromSource(steamIDSource: CSteamID): int; virtual; stdcall;
    function GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID; virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverFreiend002CppToI(Cpp: Pointer): ISteamFriends002;

implementation

function ConverFreiend002CppToI(Cpp: Pointer): ISteamFriends002;
begin
  result:=ISteamFriends002.Create();
  result.fCpp:=Cpp;
end;

function ISteamFriends002.GetPersonaName(): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+00]
end;

procedure ISteamFriends002.SetPersonaName(pchPersonaName: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchPersonaName
  call [EAX+04]
end;

function ISteamFriends002.GetPersonaState(): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+08]
end;

procedure ISteamFriends002.SetPersonaState(ePersonaState: EPersonaState);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(ePersonaState)
  call [EAX+12]
end;

function ISteamFriends002.AddFriend(steamIDFriend: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push ePersonaState
  call [EAX+16]
end;

function ISteamFriends002.RemoveFriend(steamIDFriend: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+20]
end;

function ISteamFriends002.HasFriend(steamIDFriend: CSteamID; eFriendFlags: EFriendFlags): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(eFriendFlags)
  push integer(steamIDFriend)
  call [EAX+24]
end;

function ISteamFriends002.GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+28]
end;

function ISteamFriends002.GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+32]
end;

function ISteamFriends002.GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+36]
end;

function ISteamFriends002.AddFriendByName(pchEmailOrAccountName: pAnsiChar): HSteamCall;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchEmailOrAccountName
  call [EAX+40]
end;

procedure ISteamFriends002.SetFriendRegValue(steamIDFriend: CSteamID; pchKey, pchValue: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchValue
  push pchKey
  push integer(steamIDFriend)
  call [EAX+44]
end;

function ISteamFriends002.GetFriendRegValue(steamIDFriend: CSteamID; pchKey: pAnsiChar): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchKey
  push integer(steamIDFriend)
  call [EAX+48]
end;

function ISteamFriends002.GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iPersonaName
  push integer(steamIDFriend)
  call [EAX+52]
end;

function ISteamFriends002.GetChatMessage(steamIDFriend: CSteamID; iChatID: integer; pvData: Pointer; cubData: integer; var peFriendMsgType: EFriendMsgType): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push peFriendMsgType
  push cubData
  push pvData
  push iChatID
  push integer(steamIDFriend)
  call [EAX+56]
end;

function ISteamFriends002.SendMsgToFriend2(steamIDFriend: CSteamID; eFriendMsgType: EFriendMsgType; pvMsgBody: Pointer; cubMsgBody: integer): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push cubMsgBody
  push pvMsgBody
  push integer(eFriendMsgType)
  push integer(steamIDFriend)
  call [EAX+60]
end;

function ISteamFriends002.GetChatIDOfChatHistoryStart(steamIDFriend: CSteamID): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+64]
end;

procedure ISteamFriends002.SetChatHistoryStart(steamIDFriend: CSteamID; iChatID: integer);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iChatID
  push integer(steamIDFriend)
  call [EAX+68]
end;

procedure ISteamFriends002.ClearChatHistory(steamIDFriend: CSteamID);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+72]
end;

function ISteamFriends002.InviteFriendByEmail(emailAddr: pAnsiChar): unknown_ret;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push emailAddr
  call [EAX+76]
end;

function ISteamFriends002.GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pusGamePort
  push punGameIP
  push pnGameID
  push integer(steamIDFriend)
  call [EAX+80]
end;

function ISteamFriends002.GetClanCount(): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+84]
end;

function ISteamFriends002.GetClanByIndex(iClan: int): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iClan
  call [EAX+88]
end;

function ISteamFriends002.GetClanName(steamIDClan: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDClan)
  call [EAX+92]
end;

function ISteamFriends002.InviteFriendToClan(steamIDfriend, steamIDclan: CSteamID): unknown_ret;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDclan)
  push integer(steamIDfriend)
  call [EAX+96]
end;

function ISteamFriends002.AcknowledgeInviteToClan(steamID: CSteamID; a1: boolean): unknown_ret;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(a1)
  push integer(steamID)
  call [EAX+100]
end;

function ISteamFriends002.GetFriendCountFromSource(steamIDSource: CSteamID): int;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDSource)
  call [EAX+104]
end;

function ISteamFriends002.GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iFriend
  push integer(steamIDSource)
  call [EAX+108]
end;


end.
