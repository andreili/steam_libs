unit Steam_Interface_2;

interface    

{$I defines.inc}

uses
  Windows, SteamTypes,
    Steam_Account, Steam_MiniDump, Steam_Misc, utils, Steam_Interface_1;

type
  CSteamInterface004 = class (CSteamInterface003)
      function Win32SetMiniDumpComment(cszComment: pChar): int; virtual; cdecl;
      function Dummy2(a1: pint): int; virtual; stdcall;
	    procedure Dummy3; virtual; stdcall;
	    function Dummy4(a1, a2, a3, a4, a5: pint): int; virtual; stdcall;
	    function GetCurrentAppId(a1, a2: pint): int; virtual; stdcall;
      {procedure Win32SetMiniDumpSourceControlId(uSourceControlId: uint); virtual; cdecl;
      procedure Win32SetMiniDumpEnableFullMemory; virtual; cdecl;
      procedure Win32WriteMiniDump(arg1, arg2, arg3, arg4: pChar; arg5: uint); virtual; cdecl;
      function GetCurrentAppId(puAppId: puint; pError: PSteamError): int; virtual; cdecl;      }
      function GetAppPurchaseCountry(appID: uint; szCountryCode: pChar; uBufferLength: uint;
                                     puRecievedLength: puint; pError: PSteamError): int; virtual; cdecl;
    end;

implementation

function CSteamInterface004.Win32SetMiniDumpComment(cszComment: pChar): int;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamWriteMiniDumpSetComment
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface004.Dummy2(a1: pint): int;
begin
end;

procedure CSteamInterface004.Dummy3;
begin
end;

function CSteamInterface004.Dummy4(a1, a2, a3, a4, a5: pint): int;
begin
  result:=0;
end;

function CSteamInterface004.GetCurrentAppId(a1, a2: pint): int;
begin
  asm sub ebp, 4 end;
  a1^:=4000;
  result:=1;
  asm add ebp, 4; pop ebp; ret 8 end;
end;

{procedure CSteamInterface004.Win32SetMiniDumpSourceControlId(uSourceControlId: uint);
begin
end;

procedure CSteamInterface004.Win32SetMiniDumpEnableFullMemory;
begin
end;

procedure CSteamInterface004.Win32WriteMiniDump(arg1, arg2, arg3, arg4: pChar; arg5: uint);
begin
end;

function CSteamInterface004.GetCurrentAppId(puAppId: puint; pError: PSteamError): int;
begin
  result:=0;
end;   }

function CSteamInterface004.GetAppPurchaseCountry(appID: uint; szCountryCode: pChar; uBufferLength: uint;
                                     puRecievedLength: puint; pError: PSteamError): int; cdecl;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppPurchaseCountry
	add esp, 20
	pop ebp
	ret 20
end; 

end.
