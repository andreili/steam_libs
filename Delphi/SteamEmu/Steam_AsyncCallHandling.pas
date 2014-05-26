unit Steam_AsyncCallHandling;

interface  

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils,
    utils, SteamTypes;

function SteamProcessCall(handle: SteamCallHandle_t; pProgress: PSteamProgress; pError: PSteamError): int; export; cdecl;
function SteamAbortCall(handle: SteamCallHandle_t; pError: PSteamError): int; export; cdecl;
function SteamBlockingCall(handle: SteamCallHandle_t; uiProcessTickMS: uint; pError: PSteamError): int; export; cdecl;
function SteamSetMaxStallCount(uNumStalls: uint; pError: PSteamError): int; export; cdecl;

implementation

function SteamProcessCall(handle: SteamCallHandle_t; pProgress: PSteamProgress;
                          pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_CALLING then
    Log('SteamProcessCall: Handle: '+Int2Str(handle)+#13#10); 
{$ENDIF}
  result:=0;
end;

function SteamAbortCall(handle: SteamCallHandle_t; pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_CALLING then
    Log('SteamAbortCall: Handle: '+Int2Str(handle)+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamBlockingCall(handle: SteamCallHandle_t; uiProcessTickMS: uint;
                          pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_CALLING then
    Log('SteamBlockingCall: Handle: '+Int2Str(handle)+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamSetMaxStallCount(uNumStalls: uint; pError: PSteamError): int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_CALLING then
    Log('SteamSetMaxStallCount'+#13#10); 
{$ENDIF}
  result:=1;
end;

end.
