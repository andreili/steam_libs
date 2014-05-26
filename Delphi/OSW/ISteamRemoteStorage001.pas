unit ISteamRemoteStorage001;

interface

uses
  Windows, SteamClient_Types;

type
  TSteamRemoteStorage001 = class (TObject)
    procedure _Destructor(); virtual; stdcall;

    function FileWrite(filename: pAnsiChar; data: Pointer; size: int): bool; virtual; cdecl;
    function GetFileSize(filename: pAnsiChar): uint32; virtual; cdecl;
    function FileRead(filename: pAnsiChar; buffer: Pointer; Size: int): bool; virtual; cdecl;

    function FileExists(filename: pAnsiChar): bool; virtual; cdecl;
    function FileDelete(filename: pAnsiChar): bool; virtual; cdecl;

    function GetFileCount(): uint32; virtual; cdecl;

    function GetFileNameAndSize(index: int; size: pint): pAnsiChar; virtual; cdecl;

    function GetQuota(current, maximum: pint): bool; virtual; cdecl;
  end;

implementation

uses
  Steam_RemoteStorage;

procedure TSteamRemoteStorage001._Destructor();
begin
end;

function TSteamRemoteStorage001.FileWrite(filename: pAnsiChar; data: Pointer; size: int): bool;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call RemoteStorage_FileWrite
	add esp, 12
	pop ebp
	ret 12
end;

function TSteamRemoteStorage001.GetFileSize(filename: pAnsiChar): uint32;
asm
	push [ebp+8]
	call RemoteStorage_GetFileSize
	add esp, 4
	pop ebp
	ret 4
end;

function TSteamRemoteStorage001.FileRead(filename: pAnsiChar; buffer: Pointer; Size: int): bool;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call RemoteStorage_FileRead
	add esp, 12
	pop ebp
	ret 12
end;

function TSteamRemoteStorage001.FileExists(filename: pAnsiChar): bool;
asm
	push [ebp+8]
	call RemoteStorage_FileExists
	add esp, 4
	pop ebp
	ret 4
end;

function TSteamRemoteStorage001.FileDelete(filename: pAnsiChar): bool;
asm
	push [ebp+8]
	call RemoteStorage_FileDelete
	add esp, 4
	pop ebp
	ret 4
end;

function TSteamRemoteStorage001.GetFileCount(): uint32;
asm
	call RemoteStorage_GetFileCount
	add esp, 0
	pop ebp
	ret 0
end;

function TSteamRemoteStorage001.GetFileNameAndSize(index: int; size: pint): pAnsiChar;
asm
	push [ebp+12]
	push [ebp+8]
	call RemoteStorage_GetFileNameAndSize
	add esp, 8
	pop ebp
	ret 8
end;

function TSteamRemoteStorage001.GetQuota(current, maximum: pint): bool;
asm
	push [ebp+12]
	push [ebp+8]
	call RemoteStorage_GetQuota
	add esp, 8
	pop ebp
	ret 8
end;

end.
