unit ISteamContentServer001_;

interface

uses
  SteamTypes, ContentServerCommon;

type
  ISteamContentServer001 = class
    procedure LogOn(uContentServerID: uint32); virtual; abstract;
    procedure LogOff(); virtual; abstract;

    function LoggedOn(): boolean; virtual; abstract;

    procedure SendClientContentAuthRequest(steamID: CSteamID; unContentID: uint32); virtual; abstract;
  end;

implementation

end.
