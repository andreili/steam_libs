unit Steam_Interface_4;

interface 

{$I defines.inc}                  

uses
  Windows, SteamTypes,
    Steam_Misc, Steam_FileSystem, Steam_Interface_3, utils;

type
   CSteamInterface006 = class (CSteamInterface005)
    public
      function OpenFileEx(const szFileName, szMode: pAnsiChar; a1, size, a2: puint; pError: pSteamError): SteamHandle_t; override;
      function FindServersNumServers(arg1: uint): int; virtual; cdecl;
      function FindServersIterateServer(arg1, arg2: int; szServerAddress: pAnsiChar; uServerAddressChars: uint): int; virtual; cdecl;
      function FindServersGetErrorString: int; virtual; cdecl;
    end;

implementation

function CSteamInterface006.OpenFileEx(const szFileName, szMode: pAnsiChar; a1, size, a2: puint; pError: pSteamError): SteamHandle_t;
begin
  asm sub ebp, 4 end;
  result:=SteamOpenFileEx(szFileName, szMode, size, pError);
  asm pop ebp; ret 24 end
end;

function CSteamInterface006.FindServersNumServers(arg1: uint): int;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamFindServersNumServers
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface006.FindServersIterateServer(arg1, arg2: int; szServerAddress: pAnsiChar; uServerAddressChars: uint): int;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamFindServersIterateServer
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface006.FindServersGetErrorString: int;
begin
  result:=SteamFindServersGetErrorString;;
end;


end.
