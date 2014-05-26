unit ISteamClient008_;

interface

uses
  SteamTypes, ClientCommon;

type
  ISteamClient008 = class
    // Creates a communication pipe to the Steam client
    function CreateSteamPipe(): HSteamPipe; virtual; stdcall;
    // Releases a previously created communications pipe
    function ReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean; virtual; stdcall;

    // connects to an existing global user, failing if none exists
    // used by the game to coordinate with the steamUI
    function ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser; virtual; stdcall;
    // used by game servers, create a steam user that won't be shared with anyone else
    function CreateLocalUser(var phSteamPipe: HSteamPipe): HSteamUser; virtual; stdcall;
    // removes an allocated user
    function ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser): boolean; virtual; stdcall;

    // retrieves the ISteamUser interface associated with the handle
    function GetISteamUser(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUser; virtual; stdcall;

    // retrieves the ISteamGameServer interface associated with the handle
    function GetISteamGameServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamGameServer; virtual; stdcall;

    // set the local IP and Port to bind to
    // this must be set before CreateLocalUser()
    procedure SetLocalIPBinding(unIP: uint32; usPort: uint16); virtual; stdcall;

    // returns the ISteamFriends interface
    function GetISteamFriends(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamFriends; virtual; stdcall;

    // returns the ISteamUtils interface
    function GetISteamUtils(hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUtils; virtual; stdcall;

    // returns the ISteamMatchmaking interface
    function GetISteamMatchmaking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmaking; virtual; stdcall;

    // returns the ISteamMasterServerUpdater interface
    function GetISteamMasterServerUpdater(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMasterServerUpdater; virtual; stdcall;

    // returns the ISteamMatchmakingServers interface
    function GetISteamMatchmakingServers(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmakingServers; virtual; stdcall;

    // returns a generic interface
    function GetISteamGenericInterface(SteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): Pointer; virtual; stdcall;

    // returns the ISteamUserStats interface
    function GetISteamUserStats(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUserStats; virtual; stdcall;

    // returns apps interface
    function GetISteamApps(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamApps; virtual; stdcall;

    // networking
    function GetISteamNetworking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamNetworking; virtual; stdcall;

    // remote storage
    function GetISteamRemoteStorage(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamRemoteStorage; virtual; stdcall;

    // this needs to be called every frame to process matchmaking results
    // redundant if you're already calling SteamAPI_RunCallbacks()
    procedure RunFrame(); virtual; stdcall;

    // returns the number of IPC calls made since the last time this function was called
    // Used for perf debugging so you can understand how many IPC calls your game makes per frame
    // Every IPC call is at minimum a thread context switch if not a process one so you want to rate
    // control how often you do them.
    function GetIPCCallCount(): uint32; virtual; stdcall;

    // API warning handling
    // 'int' is the severity; 0 for msg, 1 for warning
    // 'const char *' is the text of the message
    // callbacks will occur directly after the API function is called that generated the warning or message
    procedure SetWarningMessageHook(pFunction: SteamAPIWarningMessageHook_t); virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverClient008CppToI(Cpp: Pointer): ISteamClient008;

implementation

uses
  FriendsCommon, ISteamFriends001_, ISteamFriends002_, ISteamFriends003_, ISteamFriends004_, ISteamFriends005_, ISteamFriends006_, ISteamFriends007_,
  GameServerCommon, ISteamGameServer010_;

function ConverClient008CppToI(Cpp: Pointer): ISteamClient008;
begin
  result:=ISteamClient008.Create();
  result.fCpp:=Cpp;
end;

function ISteamClient008.CreateSteamPipe(): HSteamPipe;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX]
end;

function ISteamClient008.ReleaseSteamPipe(hSteamPipe: HSteamPipe): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push hSteamPipe
  call [EAX+004]
end;

function ISteamClient008.ConnectToGlobalUser(hSteamPipe: HSteamPipe): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push hSteamPipe
  call [EAX+008]
end;

function ISteamClient008.CreateLocalUser(var phSteamPipe: HSteamPipe): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push hSteamPipe
  call [EAX+012]
end;

function ISteamClient008.ReleaseUser(hSteamPipe: HSteamPipe; hUser: HSteamUser): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push hUser
  push hSteamPipe
  call [EAX+016]
end;

function ISteamClient008.GetISteamUser(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+020]
end;

function ISteamClient008.GetISteamGameServer(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamGameServer;
begin
  asm
    mov EAX, [EBP+$08]
    mov EAX, [EAX+$04]
    mov EAX, [EAX]
    push pchVersion
    push hSteamPipe
    push hSteamUser
    call [EAX+024]
  end;
  if StrComp_NoCase(pchVersion, STEAMGAMESERVER_INTERFACE_VERSION_010)=0 then result:=ISteamGameServer(ConverGameServer010CppToI(result))
end;

procedure ISteamClient008.SetLocalIPBinding(unIP: uint32; usPort: uint16);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push usPort
  push unIP
  call [EAX+028]
end;

function ISteamClient008.GetISteamFriends(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamFriends;
begin
  asm
    mov EAX, [EBP+$08]
    mov EAX, [EAX+$04]
    mov EAX, [EAX]
    push pchVersion
    push hSteamPipe
    push hSteamUser
    call [EAX+032]
  end;
  if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_001)=0 then result:=ISteamFriends(ConverFreiend001CppToI(result))
    else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_002)=0 then result:=ISteamFriends(ConverFreiend002CppToI(result))
      else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_003)=0 then result:=ISteamFriends(ConverFreiend003CppToI(result))
        else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_004)=0 then result:=ISteamFriends(ConverFreiend004CppToI(result))
          else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_005)=0 then result:=ISteamFriends(ConverFreiend005CppToI(result))
            else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_006)=0 then result:=ISteamFriends(ConverFreiend006CppToI(result))
              else if StrComp_NoCase(pchVersion, STEAMFRIENDS_INTERFACE_VERSION_007)=0 then result:=ISteamFriends(ConverFreiend007CppToI(result));
end;

function ISteamClient008.GetISteamUtils(hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUtils;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  call [EAX+036]
end;

function ISteamClient008.GetISteamMatchmaking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmaking;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+050]
end;

function ISteamClient008.GetISteamMasterServerUpdater(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMasterServerUpdater;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+044]
end;

function ISteamClient008.GetISteamMatchmakingServers(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamMatchmakingServers;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+048]
end;

function ISteamClient008.GetISteamGenericInterface(SteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): Pointer;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+052]
end;

function ISteamClient008.GetISteamUserStats(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamUserStats;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+056]
end;

function ISteamClient008.GetISteamApps(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamApps;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+060]
end;

function ISteamClient008.GetISteamNetworking(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamNetworking;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+064]
end;

function ISteamClient008.GetISteamRemoteStorage(hSteamUser: HSteamUser; hSteamPipe: HSteamPipe; pchVersion: pAnsiChar): ISteamRemoteStorage;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pchVersion
  push hSteamPipe
  push hSteamUser
  call [EAX+068]
end;

procedure ISteamClient008.RunFrame();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+072]
end;

function ISteamClient008.GetIPCCallCount(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  call [EAX+076]
end;

procedure ISteamClient008.SetWarningMessageHook(pFunction: SteamAPIWarningMessageHook_t);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov EAX, [EAX]
  push pFunction
  call [EAX+080]
end;

end.
