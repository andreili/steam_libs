unit ISteamUtils001_;

interface

uses
  SteamTypes, UtilsCommon;

type
  ISteamUtils001 = class
    // return the number of seconds since the user
    function GetSecondsSinceAppActive(): uint32; virtual; stdcall;
    function GetSecondsSinceComputerActive(): uint32; virtual; stdcall;

    // the universe this client is connecting to
    function GetConnectedUniverse(): EUniverse; virtual; stdcall;

    // server time - in PST, number of seconds since January 1, 1970 (i.e unix time)
    function GetServerRealTime(): uint32; virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverUtils001CppToI(Cpp: Pointer): ISteamUtils001;

implementation

function ConverUtils001CppToI(Cpp: Pointer): ISteamUtils001;
begin
  result:=ISteamUtils001.Create();
  result.fCpp:=Cpp;
end;

function ISteamUtils001.GetSecondsSinceAppActive(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+0]
  mov ESP, EBP
end;

function ISteamUtils001.GetSecondsSinceComputerActive(): uint32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+04]
  mov ESP, EBP
end;

function ISteamUtils001.GetConnectedUniverse(): EUniverse;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+08]
  mov ESP, EBP
end;

function ISteamUtils001.GetServerRealTime(): RTime32;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+12]
  mov ESP, EBP
end;

end.
