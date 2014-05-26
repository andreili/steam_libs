unit Steam_Interface;

interface

uses
  Windows, USE_Types, USE_Utils,
    utils, SteamTypes, Steam_Misc,
      Steam_Interface_003, Steam_Interface_004, Steam_Interface_005, Steam_Interface_006;

{$I defines.inc}

function CreateInterface(cszSteamDLLAppsystemInterfaceVersion: pAnsiChar;
                         pError: PSteamError): int; export; cdecl;
function _f(cszSteamInterfaceVersion: pAnsiChar): uint; export; cdecl;

var
  SteamInterface003: CSteamInterface003;
  SteamInterface004: CSteamInterface004;
  SteamInterface005: CSteamInterface005;
  SteamInterface006: CSteamInterface006;
  
implementation

function CreateInterface(cszSteamDLLAppsystemInterfaceVersion: pAnsiChar;
                         pError: PSteamError): int; export; cdecl;
begin                         
{$IFDEF LOGING}
  Log('CreateInterface SteamDLLAppsystem version:' +cszSteamDLLAppsystemInterfaceVersion+#13#10);
{$ENDIF}
  result:=0;
end;

function _f(cszSteamInterfaceVersion: pAnsiChar): uint; export; cdecl;
var
  s: string;
begin                                                              
{$IFDEF LOGING}
  Log('_f SteamInterface version: '+cszSteamInterfaceVersion+#13#10);
{$ENDIF}

  //result:=__f(cszSteamInterfaceVersion);
  result:=0;
  if cszSteamInterfaceVersion<>nil then
  begin
    s:=Ansi2Wide(cszSteamInterfaceVersion);
    if IndexOfStr(s, 'Steam003')=1 then
    begin
      result:=uint(SteamInterface003);
    end
        else if IndexOfStr(s, 'Steam004')=1 then
          result:=uint(SteamInterface004)
            else if IndexOfStr(s, 'Steam005')=1 then
              result:=uint(SteamInterface005)
                else if IndexOfStr(s, 'Steam006')=1 then
                  result:=uint(SteamInterface006);
  end;   
end;

initialization

  //SteamDLLAppsystem:=CSteamDLLAppsystem001.Create;
  SteamInterface003:=CSteamInterface003.Create;
  SteamInterface004:=CSteamInterface004.Create;
  SteamInterface005:=CSteamInterface005.Create;
  SteamInterface006:=CSteamInterface006.Create;

finalization

  //SteamDLLAppsystem.Free;
  SteamInterface003.Free;
  SteamInterface004.Free;
  SteamInterface005.Free;
  SteamInterface006.Free;

end.

