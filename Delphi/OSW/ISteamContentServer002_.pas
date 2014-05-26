unit ISteamContentServer002_;

interface

uses
  SteamTypes, ContentServerCommon;

type
  ISteamContentServer002 = class
    procedure LogOn(uContentServerID: uint32); virtual; abstract;
    procedure LogOff(); virtual; abstract;

    function LoggedOn(): boolean; virtual; abstract;

    procedure SendClientContentAuthRequest(steamID: CSteamID; unContentID: uint32); virtual; abstract;

    function CheckTicket(steamId: CSteamID; a: uint32; b: Pointer; c: uint32): boolean; virtual; abstract;
  end;

implementation

end.
