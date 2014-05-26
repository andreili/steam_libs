unit ISteamFriends001_;

interface

uses
  SteamTypes, FriendsCommon;

type
  ISteamFriends001 = class
    // returns the local players name - guaranteed to not be NULL.
    function GetPersonaName(): pAnsiChar; virtual; stdcall;
    // sets the player name, stores it on the server and publishes the changes to all friends who are online
    procedure SetPersonaName(pchPersonaName: pAnsiChar); virtual;  stdcall;

    // gets the friend status of the current user
    function GetPersonaState(): EPersonaState; virtual;  stdcall;
    // sets the status, communicates to server, tells all friends
    procedure SetPersonaState(ePersonaState: EPersonaState); virtual;  stdcall;

    // adds a friend to the users list.  Friend will be notified that they have been added, and have the option of accept/decline
    function AddFriend(steamIDFriend: CSteamID): boolean; virtual;  stdcall;
    // removes the friend from the list, and blocks them from contacting the user again
    function RemoveFriend(steamIDFriend: CSteamID): boolean; virtual;  stdcall;
    // returns true if the specified user is considered a friend (can see our online status)
    function HasFriend(steamIDFriend: CSteamID): boolean; virtual;  stdcall;

    // gets the relationship to a user
    function GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship; virtual;  stdcall;
    // returns true if the specified user is considered a friend (can see our online status)
    function GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState; virtual;  stdcall;

    // retrieves details about the game the friend is currently playing - returns false if the friend is not playing any games
    // this is deprecated, please use the GetFriendGamePlayed# functions below
    function Deprecated_GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean; virtual;  stdcall;

    // returns the name of a friend - guaranteed to not be NULL.
    function GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar; virtual;  stdcall;

    // adds a friend by email address or account name - value returned in callback
    function AddFriendByName(pchEmailOrAccountName: pAnsiChar): HSteamCall; virtual;  stdcall;

    // friend iteration
    function GetFriendCount(): integer; virtual;  stdcall;
    function GetFriendByIndex(iFriend: integer): CSteamID; virtual;  stdcall;

    // generic friend->friend message sending
    // DEPRECATED, use the sized-buffer version instead (has much higher max buffer size)
    procedure SendMsgToFriend1(steamIDFriend: CSteamID; eFriendMsgType: EFriendMsgType; pchMsgBody: pAnsiChar); virtual;  stdcall;

    // steam registry, accessed by friend
    procedure SetFriendRegValue(steamIDFriend: CSteamID; pchKey, pchValue: pAnsiChar); virtual;  stdcall;
    function GetFriendRegValue(steamIDFriend: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual;  stdcall;

    // accesses old friends names - returns an empty string when their are no more items in the history
    function GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar; virtual;  stdcall;

    // chat message iteration
    // returns the number of bytes in the message, filling pvData with as many of those bytes as possible
    // returns 0 if the steamID or iChatID are invalid
    function GetChatMessage(steamIDFriend: CSteamID; iChatID: integer; pvData: Pointer; cubData: integer; var peFriendMsgType: EFriendMsgType): integer; virtual;  stdcall;

    // generic friend->friend message sending, takes a sized buffer
    function SendMsgToFriend2(steamIDFriend: CSteamID; eFriendMsgType: EFriendMsgType; pvMsgBody: Pointer; cubMsgBody: integer): boolean; virtual;  stdcall;

    // returns the chatID that a chat should be resumed from when switching chat contexts
    function GetChatIDOfChatHistoryStart(steamIDFriend: CSteamID): integer; virtual;  stdcall;
    // sets where a chat with a user should resume
    procedure SetChatHistoryStart(steamIDFriend: CSteamID; iChatID: integer); virtual;  stdcall;
    // clears the chat history - should be called when a chat dialog closes
    // the chat history can still be recovered by another context using SetChatHistoryStart() to reset the ChatIDOfChatHistoryStart
    procedure ClearChatHistory(steamIDFriend: CSteamID); virtual;  stdcall;

    function InviteFriendByEmail(pchEmailOrAccountName: pAnsiChar): HSteamCall; virtual;  stdcall;
    function GetBlockedFriendCount(): uint32; virtual;  stdcall;
    function GetFriendGamePlayed(steamIDFriend: CSteamID; var pulGameID: uint64; var punGameIP: uint32; var pusGamePort: uint16): boolean; virtual;  stdcall;
    function GetFriendGamePlayed2(steamIDFriend: CSteamID; var pulGameID: uint64; var punGameIP: uint32; var pusQueryPort: uint16): boolean; virtual;  stdcall;
  private
    fCpp: Pointer;
  end;

function ConverFreiend001CppToI(Cpp: Pointer): ISteamFriends001;

implementation

function ConverFreiend001CppToI(Cpp: Pointer): ISteamFriends001;
begin
  result:=ISteamFriends001.Create();
  result.fCpp:=Cpp;
end;

function ISteamFriends001.GetPersonaName(): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+00]
end;

procedure ISteamFriends001.SetPersonaName(pchPersonaName: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchPersonaName
  call [EAX+04]
end;

function ISteamFriends001.GetPersonaState(): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+08]
end;

procedure ISteamFriends001.SetPersonaState(ePersonaState: EPersonaState);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(ePersonaState)
  call [EAX+12]
end;

function ISteamFriends001.AddFriend(steamIDFriend: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push ePersonaState
  call [EAX+16]
end;

function ISteamFriends001.RemoveFriend(steamIDFriend: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+20]
end;

function ISteamFriends001.HasFriend(steamIDFriend: CSteamID): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+24]
end;

function ISteamFriends001.GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+28]
end;

function ISteamFriends001.GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+32]
end;

function ISteamFriends001.Deprecated_GetFriendGamePlayed(steamIDFriend: CSteamID; var pnGameID: int32; var punGameIP: uint32; var pusGamePort: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pusGamePort
  push punGameIP
  push pnGameID
  push integer(steamIDFriend)
  call [EAX+36]
end;

function ISteamFriends001.GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+40]
end;

function ISteamFriends001.AddFriendByName(pchEmailOrAccountName: pAnsiChar): HSteamCall;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchEmailOrAccountName
  call [EAX+44]
end;

function ISteamFriends001.GetFriendCount(): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+48]
end;

function ISteamFriends001.GetFriendByIndex(iFriend: integer): CSteamID;
asm
  mov EAX, [EBX+$04]
  mov ECX, [EBX+$04]
  mov EAX, [EAX]
  push iFriend
  call [EAX+52]
end;

procedure ISteamFriends001.SendMsgToFriend1(steamIDFriend: CSteamID; eFriendMsgType: EFriendMsgType; pchMsgBody: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchMsgBody
  push integer(eFriendMsgType)
  push integer(steamIDFriend)
  call [EAX+56]
end;

procedure ISteamFriends001.SetFriendRegValue(steamIDFriend: CSteamID; pchKey, pchValue: pAnsiChar);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchValue
  push pchKey
  push integer(steamIDFriend)
  call [EAX+60]
end;

function ISteamFriends001.GetFriendRegValue(steamIDFriend: CSteamID; pchKey: pAnsiChar): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchKey
  push integer(steamIDFriend)
  call [EAX+64]
end;

function ISteamFriends001.GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: integer): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iPersonaName
  push integer(steamIDFriend)
  call [EAX+68]
end;

function ISteamFriends001.GetChatMessage(steamIDFriend: CSteamID; iChatID: integer; pvData: Pointer; cubData: integer; var peFriendMsgType: EFriendMsgType): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push peFriendMsgType
  push cubData
  push pvData
  push iChatID
  push integer(steamIDFriend)
  call [EAX+72]
end;

function ISteamFriends001.SendMsgToFriend2(steamIDFriend: CSteamID; eFriendMsgType: EFriendMsgType; pvMsgBody: Pointer; cubMsgBody: integer): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push cubMsgBody
  push pvMsgBody
  push integer(eFriendMsgType)
  push integer(steamIDFriend)
  call [EAX+76]
end;

function ISteamFriends001.GetChatIDOfChatHistoryStart(steamIDFriend: CSteamID): integer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+80]
end;

procedure ISteamFriends001.SetChatHistoryStart(steamIDFriend: CSteamID; iChatID: integer);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push iChatID
  push integer(steamIDFriend)
  call [EAX+84]
end;

procedure ISteamFriends001.ClearChatHistory(steamIDFriend: CSteamID);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(steamIDFriend)
  call [EAX+88]
end;

function ISteamFriends001.InviteFriendByEmail(pchEmailOrAccountName: pAnsiChar): HSteamCall;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchEmailOrAccountName
  call [EAX+92]
end;

function ISteamFriends001.GetBlockedFriendCount(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+96]
end;

function ISteamFriends001.GetFriendGamePlayed(steamIDFriend: CSteamID; var pulGameID: uint64; var punGameIP: uint32; var pusGamePort: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pusGamePort
  push punGameIP
  push pulGameID
  push integer(steamIDFriend)
  call [EAX+100]
end;

function ISteamFriends001.GetFriendGamePlayed2(steamIDFriend: CSteamID; var pulGameID: uint64; var punGameIP: uint32; var pusQueryPort: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pusQueryPort
  push punGameIP
  push pulGameID
  push integer(steamIDFriend)
  call [EAX+104]
end;

end.
