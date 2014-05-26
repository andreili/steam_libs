unit ISteamClient006_;

interface

uses
  SteamTypes, ClientCommon;

type
  ISteamClient006 = class
    // Creates a communication pipe to the Steam client
    function CreateSteamPipe(): HSteamPipe; virtual; stdcall;
    // Releases a previously created communications pipe
    function ReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean; virtual; stdcall;

    // creates a global instance of a steam user, so that other processes can share it
    // used by the steam UI, to share it's account info/connection with any games it launches
    // fails (returns NULL) if an existing instance already exists
    function CreateGlobalUser(phSteamPipe: pHSteamPipe): HSteamUser; virtual; stdcall;
    // connects to an existing global user, failing if none exists
    // used by the game to coordinate with the steamUI
    function ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser; virtual; stdcall;
    // used by game servers, create a steam user that won't be shared with anyone else
    function CreateLocalUser(phSteamPipe: pHSteamPipe): HSteamUser; virtual; stdcall;
    // removes an allocated user
    function ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser): boolean; virtual; stdcall;

    // retrieves the ISteamUser interface associated with the handle
    function GetISteamUser(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUser; virtual; stdcall;

    // retrieves the IVac interface associated with the handle
    // there is normally only one instance of VAC running, but using this connects it to the right user/account
    function GetIVAC(hSteamUser: HSteamUser): IVAC; virtual; stdcall;

    // retrieves the ISteamGameServer interface associated with the handle
    function GetISteamGameServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamGameServer; virtual; stdcall;

    // set the local IP and Port to bind to
    // this must be set before CreateLocalUser()
    procedure SetLocalIPBinding(unIP: uint32; usPort: uint16); virtual; stdcall;

    // returns the name of a universe
    function GetUniverseName(eUniverse: EUniverse): pAnsiChar; virtual; stdcall;

    // returns the ISteamFriends interface
    function GetISteamFriends(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamFriends; virtual; stdcall;

    // returns the ISteamUtils interface
    function GetISteamUtils(hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUtils; virtual; stdcall;

    // returns the ISteamBilling interface
    function GetISteamBilling(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamBilling; virtual; stdcall;

    // returns the ISteamMatchmaking interface
    function GetISteamMatchmaking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmaking; virtual; stdcall;

    // returns the ISteamContentServer interface
    function GetISteamContentServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamContentServer; virtual; stdcall;

    // returns apps interface
    function GetISteamApps(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamApps; virtual; stdcall;

    // returns the ISteamMasterServerUpdater interface
    function GetISteamMasterServerUpdater(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMasterServerUpdater; virtual; stdcall;

    // returns the ISteamMatchmakingServers interface
    function GetISteamMatchmakingServers(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmakingServers; virtual; stdcall;

    // this needs to be called every frame to process matchmaking results
    // redundant if you're already calling SteamAPI_RunCallbacks()
    procedure RunFrame(); virtual; stdcall;

    // returns the number of IPC calls made since the last time this function was called
    // Used for perf debugging so you can understand how many IPC calls your game makes per frame
    // Every IPC call is at minimum a thread context switch if not a process one so you want to rate
    // control how often you do them.
    function GetIPCCallCount(): uint32; virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverClient006CppToI(Cpp: Pointer): ISteamClient006;

implementation

uses
  FriendsCommon, ISteamFriends001_, ISteamFriends002_, ISteamFriends003_, ISteamFriends004_, ISteamFriends005_, ISteamFriends006_, ISteamFriends007_,
  UserCommon, ISteamUser004_, ISteamUser014_,
  GameServerCommon, ISteamGameServer010_,
  UtilsCommon, ISteamUtils001_, ISteamUtils002_, ISteamUtils003_, ISteamUtils004_, ISteamUtils005_;

function ConverClient006CppToI(Cpp: Pointer): ISteamClient006;
begin
  result:=ISteamClient006.Create();
  result.fCpp:=Cpp;
end;

function ISteamClient006.CreateSteamPipe(): HSteamPipe;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  mov ECX, [ECX+$04]
  call [EAX]
  mov ESP, EBP
end;

function ISteamClient006.ReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  mov ECX, [ECX+$04]
  push hSteamPipe
  call [EAX+04]
  mov ESP, EBP
end;

function ISteamClient006.CreateGlobalUser(phSteamPipe: pHSteamPipe): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  mov ECX, [ECX+$04]
  push phSteamPipe
  call [EAX+008]
  mov ESP, EBP
end;

function ISteamClient006.ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  mov ECX, [ECX+$04]
  push hSteamPipe
  call [EAX+12]
  mov ESP, EBP
end;

function ISteamClient006.CreateLocalUser(phSteamPipe: pHSteamPipe): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push phSteamPipe
  call [EAX+16]
  mov ESP, EBP
end;

function ISteamClient006.ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push hUser
  push hSteamPipe
  call [EAX+20]
  mov ESP, EBP
end;

function ISteamClient006.GetISteamUser(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUser;
begin
  asm
    mov EAX, [EBP+$08]
    mov EAX, [EAX+$04]
    mov ECX, EAX
    mov EAX, [EAX]
    push pchVersion
    push hSteamPipe
    push hSteamUser
    call [EAX+24]
    mov EBX, EAX
  end;
  if StrComp_NoCase(pchVersion, STEAMUSER_INTERFACE_VERSION_004)=0 then result:=ISteamUser(ConverUser004CppToI(result))
        else if StrComp_NoCase(pchVersion, STEAMUSER_INTERFACE_VERSION_014)=0 then result:=ISteamUser(ConverUser014CppToI(result));
end;

function ISteamClient006.GetIVAC(hSteamUser: HSteamUser): IVAC;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  mov ECX, [ECX+$04]
  push hSteamUser
  call [EAX+28]
  mov EBX, EAX
end;

function ISteamClient006.GetISteamGameServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamGameServer;
begin
  asm
    mov EAX, [EBP+$08]
    mov EAX, [EAX+$04]
    mov EAX, [EAX]
    mov ECX, [ECX+$04]
    push pchVersion
    push hSteamPipe
    push hSteamUser
    call [EAX+024]
    mov EBX, EAX
  end;
  if StrComp_NoCase(pchVersion, STEAMGAMESERVER_INTERFACE_VERSION_010)=0 then result:=ISteamGameServer(ConverGameServer010CppToI(result));
end;

procedure ISteamClient006.SetLocalIPBinding(unIP: uint32; usPort: uint16);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push usPort
  push unIP
  call [EAX+36]
end;

function ISteamClient006.GetUniverseName(eUniverse: EUniverse): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push integer(eUniverse)
  call [EAX+40]
end;

function ISteamClient006.GetISteamFriends(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamFriends;
begin
  asm
    mov EAX, [EBP+$08]
    mov EAX, [EAX+$04]
    mov ECX, EAX
    mov EAX, [EAX]
    push pchVersion
    push hSteamPipe
    push hSteamUser
    call [EAX+44]
    mov EBX, EAX
  end;
  if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_001)=0 then result:=ISteamFriends(ConverFreiend001CppToI(result))
    else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_002)=0 then result:=ISteamFriends(ConverFreiend002CppToI(result))
      else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_003)=0 then result:=ISteamFriends(ConverFreiend003CppToI(result))
        else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_004)=0 then result:=ISteamFriends(ConverFreiend004CppToI(result))
          else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_005)=0 then result:=ISteamFriends(ConverFreiend005CppToI(result))
            else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_006)=0 then result:=ISteamFriends(ConverFreiend006CppToI(result))
              else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_007)=0 then result:=ISteamFriends(ConverFreiend007CppToI(result));
end;

function ISteamClient006.GetISteamUtils(hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUtils;
begin
  asm
    mov EAX, [EBP+$08]
    mov EAX, [EAX+$04]
    mov ECX, EAX
    mov EAX, [EAX]
    push pchVersion
    push hSteamPipe
    call [EAX+48]
    mov EBX, EAX
  end;
  if StrComp_NoCase(pchVersion, STEAMUTILS_INTERFACE_VERSION_001)=0 then result:=ISteamUtils(ConverUtils001CppToI(result))
    else if StrComp_NoCase(pchVersion, STEAMUTILS_INTERFACE_VERSION_002)=0 then result:=ISteamUtils(ConverUtils002CppToI(result))
      else if StrComp_NoCase(pchVersion, STEAMUTILS_INTERFACE_VERSION_003)=0 then result:=ISteamUtils(ConverUtils003CppToI(result))
        else if StrComp_NoCase(pchVersion, STEAMUTILS_INTERFACE_VERSION_004)=0 then result:=ISteamUtils(ConverUtils004CppToI(result))
          else if StrComp_NoCase(pchVersion, STEAMUTILS_INTERFACE_VERSION_005)=0 then result:=ISteamUtils(ConverUtils005CppToI(result));
end;

function ISteamClient006.GetISteamBilling(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamBilling;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+52]
    mov EBX, EAX
end;

function ISteamClient006.GetISteamMatchmaking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmaking;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+56]
    mov EBX, EAX
end;

function ISteamClient006.GetISteamContentServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamContentServer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+60]
    mov EBX, EAX
end;

function ISteamClient006.GetISteamMasterServerUpdater(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMasterServerUpdater;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+64]
    mov EBX, EAX
end;

function ISteamClient006.GetISteamMatchmakingServers(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmakingServers;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+68]
    mov EBX, EAX
end;

function ISteamClient006.GetISteamApps(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamApps;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+72]
    mov EBX, EAX
end;

procedure ISteamClient006.RunFrame();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+76]
end;

function ISteamClient006.GetIPCCallCount(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  mov ECX, [ECX+$04]
  call [EAX+80]
  mov ESP, EBP
end;

end.
