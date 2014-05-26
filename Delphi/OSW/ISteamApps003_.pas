unit ISteamApps003_;

interface

uses
  SteamTypes;

type
  ISteamApps003 = class
    function IsSubscribed(): boolean; virtual; abstract;
    function IsLowViolence(): boolean; virtual; abstract;
    function IsCybercafe(): boolean; virtual; abstract;
    function IsVACBanned(): boolean; virtual; abstract;

    function GetCurrentGameLanguage(): pAnsiChar; virtual; abstract;
    function GetAvailableGameLanguages(): pAnsiChar; virtual; abstract;

    // only use this member if you need to check ownership of another game related to yours, a demo for example
    function IsSubscribedApp(appID: AppId_t): boolean; virtual; abstract;

    // Takes AppID of DLC and checks if the user owns the DLC & if the DLC is installed
    function IsDlcInstalled(appID: AppId_t): boolean; virtual; abstract;
  end;

implementation

end.
