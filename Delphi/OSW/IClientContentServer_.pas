unit IClientContentServer_;

interface

uses
  SteamTypes, ContentServerCommon, UserCommon;

type
  IClientContentServer = class
    function GetHSteamUser(): HSteamUser; virtual; abstract;

    function GetSteamID(): CSteamID; virtual; abstract;

    procedure LogOn(uContentServerID: uint32); virtual; abstract;
    procedure LogOff(); virtual; abstract;

    function LoggedOn(): boolean; virtual; abstract;
    function GetLogonState(): ELogonState; virtual; abstract;
    function Connected(): boolean; virtual; abstract;

    function RaiseConnectionPriority(eConnectionPriority: EConnectionPriority): int; virtual; abstract;
    procedure ResetConnectionPriority(hRaiseConnectionPriorityPrev: int); virtual; abstract;

    procedure SetCellID(cellID: CellID_t); virtual; abstract;

    function SendClientContentAuthRequest(steamID: CSteamID; unContentID: uint32; bUseToken: boolean; ulSessionToken: uint64; bTokenPresent: boolean): boolean; virtual; abstract;
    function CheckTicket(steamID: CSteamID; uContentID: uint32; pvTicketData: Pointer; cubTicketLength: uint32): boolean; virtual; abstract;
  end;

implementation

end.
