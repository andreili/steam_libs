unit Steam_Interface_3;

interface 

{$I defines.inc}

uses
  Windows, SteamTypes,
    Steam_Account, Steam_Misc, utils, Steam_Interface_2;

type
  CSteamInterface005 = class (CSteamInterface004)
      function GetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int; virtual; cdecl;
      function IsFileNeededByCache: int; virtual; cdecl;
      function LoadFileToCache: int; virtual; cdecl;
      function GetCacheDecryptionKey: int; virtual; cdecl;
      function GetSubscriptionExtendedInfo: int; virtual; cdecl;
      function GetSubscriptionPurchaseCountry(a1: uint; a2: pAnsiChar; a3: uint; a4: pAnsiChar; a5: pSteamError): int; virtual; cdecl;
      function GetAppUserDefinedRecord(appID: int; arg2: uint; arg3: uint; pError: PSteamError): int; virtual; cdecl;
    end;

implementation

uses
  Steam_FileSystem;

function CSteamInterface005.GetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int;
asm
  push [ebp+16]
  push [ebp+12]
  push [ebp+8]

  call SteamGetLocalClientVersion

  add esp, 12
  pop ebp
  ret 12
end;

function CSteamInterface005.IsFileNeededByCache: int;   
begin
  result:=SteamIsFileNeededByCache;
end;    

function CSteamInterface005.LoadFileToCache: int;
begin
  result:=SteamLoadFileToCache;
end;

function CSteamInterface005.GetCacheDecryptionKey: int;   
begin
  result:=SteamGetCacheDecryptionKey;
end;

function CSteamInterface005.GetSubscriptionExtendedInfo: int;
begin
  result:=SteamGetSubscriptionExtendedInfo;
end;

function CSteamInterface005.GetSubscriptionPurchaseCountry(a1: uint; a2: pAnsiChar; a3: uint; a4: pAnsiChar; a5: pSteamError): int;
begin
  asm sub ebp, 4 end;
  result:=SteamGetSubscriptionPurchaseCountry(a1, a2, a3, a4, a5);
  asm pop ebp; ret 20 end
end;

function CSteamInterface005.GetAppUserDefinedRecord(appID: int; arg2: uint; arg3: uint; pError: PSteamError): int;  
asm
  //push ebp
  //mov ebp, esp
  push [ebp+20]
  push [ebp+16]
  push [ebp+12]
	push [ebp+8]
	call SteamGetAppUserDefinedRecord
	add esp, 16
	pop ebp
	ret 16
end;


end.
