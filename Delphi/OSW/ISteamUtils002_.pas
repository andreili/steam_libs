unit ISteamUtils002_;

interface

uses
  SteamTypes, UtilsCommon;

type
  ISteamUtils002 = class
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
  private
    fCpp: Pointer;
  end;

function ConverUtils002CppToI(Cpp: Pointer): ISteamUtils002;

implementation

function ConverUtils002CppToI(Cpp: Pointer): ISteamUtils002;
begin
  result:=ISteamUtils002.Create();
  result.fCpp:=Cpp;
end;

function ISteamUtils002.GetSecondsSinceAppActive(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+0]
  mov ESP, EBP
end;

function ISteamUtils002.GetSecondsSinceComputerActive(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+04]
  mov ESP, EBP
end;

function ISteamUtils002.GetConnectedUniverse(): EUniverse;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+08]
  mov ESP, EBP
end;

function ISteamUtils002.GetServerRealTime(): RTime32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+12]
  mov ESP, EBP
end;

function ISteamUtils002.GetIPCountry(): pAnsiChar;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+16]
  mov ESP, EBP
end;

function ISteamUtils002.GetImageSize(iImage: int; var pnWidth, pnHeight: uint32): boolean;
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

function ISteamUtils002.GetImageRGBA(iImage: int; pubDest: puint8; nDestBufferSize: int): boolean;
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

function ISteamUtils002.GetCSERIPPort(var unIP: uint32; var usPort: uint16): boolean;
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

function ISteamUtils002.GetCurrentBatteryPower(): uint8;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+32]
  mov ESP, EBP
end;

end.
