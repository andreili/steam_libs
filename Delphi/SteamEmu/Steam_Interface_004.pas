unit Steam_Interface_004;

interface    

{$I defines.inc}

uses
  Windows, USE_Types, SteamTypes,
    Steam_Account, Steam_MiniDump, Steam_Misc, utils, Steam_Interface_003;

type
  CSteamInterface004 = class (CSteamInterface003)
      function Win32SetMiniDumpComment(cszComment: pAnsiChar): int; virtual; cdecl;
      procedure Win32SetMiniDumpSourceControlId(uSourceControlId: uint); virtual; stdcall;
	    procedure Win32SetMiniDumpEnableFullMemory(); virtual; stdcall;
	    procedure Win32WriteMiniDump(a1, a2, a3, a4: pAnsiChar; a5: uint32); virtual; stdcall;
	    function GetCurrentAppId(puAppId: puint32; pError: PSteamError): int; virtual; stdcall;
      function GetAppPurchaseCountry(appID: uint; szCountryCode: pAnsiChar; uBufferLength: uint;
                                     puRecievedLength: puint; pError: PSteamError): int; virtual; cdecl;
    end;

implementation

function CSteamInterface004.Win32SetMiniDumpComment(cszComment: pAnsiChar): int;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamWriteMiniDumpSetComment
	add esp, 4
	pop ebp
	ret 4
end;

procedure CSteamInterface004.Win32SetMiniDumpSourceControlId(uSourceControlId: uint);
begin
{$IFDEF LOGING}
  utils.Log('Win32SetMiniDumpSourceControlId'+#13#10);
{$ENDIF}
end;

procedure CSteamInterface004.Win32SetMiniDumpEnableFullMemory;
begin
{$IFDEF LOGING}
  utils.Log('Win32SetMiniDumpEnableFullMemory'+#13#10);
{$ENDIF}
end;

procedure CSteamInterface004.Win32WriteMiniDump(a1, a2, a3, a4: pAnsiChar; a5: uint32);
begin
{$IFDEF LOGING}
  utils.Log('Win32WriteMiniDump'+#13#10);
{$ENDIF}
end;

function CSteamInterface004.GetCurrentAppId(puAppId: puint32; pError: PSteamError): int;
begin
{$IFDEF LOGING}
  utils.Log('GetCurrentAppId'+#13#10);
{$ENDIF}
  {asm sub ebp, 4 end;
  a1^:=4000;
  result:=1;
  asm add ebp, 4; pop ebp; ret 8 end;}
end;

function CSteamInterface004.GetAppPurchaseCountry(appID: uint; szCountryCode: pAnsiChar; uBufferLength: uint;
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
