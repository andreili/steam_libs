unit ISteamUtils003_;

interface

uses
  SteamTypes, UtilsCommon;

type
  ISteamUtils003 = class
    // return the number of seconds since the user
    function GetSecondsSinceAppActive(): uint32; virtual; stdcall;
    function GetSecondsSinceComputerActive(): uint32; virtual; stdcall;

    // the universe this client is connecting to
    function GetConnectedUniverse(): EUniverse; virtual; stdcall;

    // Steam server time - in PST, number of seconds since January 1, 1970 (i.e unix time)
    function GetServerRealTime(): uint32; virtual; stdcall;

    // returns the 2 digit ISO 3166-1-alpha-2 format country code this client is running in (as looked up via an IP-to-location database)
    // e.g "US" or "UK".
    function GetIPCountry(): pAnsiChar; virtual; stdcall;

    //virtual unknown_ret LoadFileFromCDN( const char*, bool *, int, uint64 ) = 0;
    //virtual unknown_ret WriteCDNFileToDisk( int, const char* ) = 0;

    // returns true if the image exists, and valid sizes were filled out
    function GetImageSize(iImage: int; var pnWidth, pnHeight: uint32): boolean; virtual; stdcall;

    // returns true if the image exists, and the buffer was successfully filled out
    // results are returned in RGBA format
    // the destination buffer size should be 4 * height * width * sizeof(char)
    function GetImageRGBA(iImage: int; pubDest: puint8; nDestBufferSize: int): boolean; virtual; stdcall;

    // returns the IP of the reporting server for valve - currently only used in Source engine games
    function GetCSERIPPort(var unIP: uint32; var usPort: uint16): boolean; virtual; stdcall;

    // return the amount of battery power left in the current system in % [0..100], 255 for being on AC power
    function GetCurrentBatteryPower(): uint8; virtual; stdcall;

    // returns the appID of the current process
    function GetAppID(): AppId_t; virtual; stdcall;

    // Sets the position where the overlay instance for the currently calling game should show notifications.
    // This position is per-game and if this function is called from outside of a game context it will do nothing.
    procedure SetOverlayNotificationPosition(eNotificationPosition: ENotificationPosition); virtual; stdcall;

    // API asynchronous call results
    // can be used directly, but more commonly used via the callback dispatch API (see steam_api.h)
    function IsAPICallCompleted(hSteamAPICall: SteamAPICall_t; var pbFailed: boolean): boolean; virtual; stdcall;
    function GetAPICallFailureReason(hSteamAPICall: SteamAPICallCompleted_t): ESteamAPICallFailure; virtual; stdcall;
    function GetAPICallResult(hSteamAPICall: SteamAPICall_t; pCallback: Pointer; cubCallback,
     iCallbackExpected: int; var pbFailed: boolean): boolean; virtual; stdcall;

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
    // callbacks will occur directly after the API function is called that generated the warning or messag
    procedure SetWarningMessageHook(pFunction: SteamAPIWarningMessageHook_t); virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverUtils003CppToI(Cpp: Pointer): ISteamUtils003;

implementation

function ConverUtils003CppToI(Cpp: Pointer): ISteamUtils003;
begin
  result:=ISteamUtils003.Create();
  result.fCpp:=Cpp;
end;

function ISteamUtils003.GetSecondsSinceAppActive(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+0]
  mov ESP, EBP
end;

function ISteamUtils003.GetSecondsSinceComputerActive(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+04]
  mov ESP, EBP
end;

function ISteamUtils003.GetConnectedUniverse(): EUniverse;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+08]
  mov ESP, EBP
end;

function ISteamUtils003.GetServerRealTime(): RTime32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+12]
  mov ESP, EBP
end;

function ISteamUtils003.GetIPCountry(): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+16]
  mov ESP, EBP
end;

function ISteamUtils003.GetImageSize(iImage: int; var pnWidth, pnHeight: uint32): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push pnHeight
  push pnWidth
  push iImage
  call [EAX+20]
  mov ESP, EBP
end;

function ISteamUtils003.GetImageRGBA(iImage: int; pubDest: puint8; nDestBufferSize: int): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push nDestBufferSize
  push pubDest
  push iImage
  call [EAX+24]
  mov ESP, EBP
end;

function ISteamUtils003.GetCSERIPPort(var unIP: uint32; var usPort: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push usPort
  push unIP
  call [EAX+28]
  mov ESP, EBP
end;

function ISteamUtils003.GetCurrentBatteryPower(): uint8;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+32]
  mov ESP, EBP
end;

function ISteamUtils003.GetAppID(): AppId_t;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+36]
  mov ESP, EBP
end;

procedure ISteamUtils003.SetOverlayNotificationPosition(eNotificationPosition: ENotificationPosition);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push int(eNotificationPosition)
  call [EAX+40]
  mov ESP, EBP
end;

function ISteamUtils003.IsAPICallCompleted(hSteamAPICall: SteamAPICall_t; var pbFailed: boolean): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push int(pbFailed)
  push int(hSteamAPICall)
  call [EAX+44]
  mov ESP, EBP
end;

function ISteamUtils003.GetAPICallFailureReason(hSteamAPICall: SteamAPICallCompleted_t): ESteamAPICallFailure;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push int(hSteamAPICall)
  call [EAX+48]
  mov ESP, EBP
end;

function ISteamUtils003.GetAPICallResult(hSteamAPICall: SteamAPICall_t; pCallback: Pointer; cubCallback,
 iCallbackExpected: int; var pbFailed: boolean): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push int(pbFailed)
  push iCallbackExpected
  push cubCallback
  push int(SteamAPICall_t)
  push int(hSteamAPICall)
  call [EAX+52]
  mov ESP, EBP
end;

procedure ISteamUtils003.RunFrame();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+56]
  mov ESP, EBP
end;

function ISteamUtils003.GetIPCCallCount(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+60]
  mov ESP, EBP
end;

procedure ISteamUtils003.SetWarningMessageHook(pFunction: SteamAPIWarningMessageHook_t);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push integer(pFunction)
  call [EAX+64]
  mov ESP, EBP
end;

end.
