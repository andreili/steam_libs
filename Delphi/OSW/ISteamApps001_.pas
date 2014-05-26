unit ISteamApps001_;

interface

uses
  SteamTypes;

type
  ISteamApps001 = class (TObject)
    procedure _Destructor(); virtual; abstract;
    // returns 0 if the key does not exist
    // this may be true on first call, since the app data may not be cached locally yet
    // If you expect it to exists wait for the AppDataChanged_t after the first failure and ask again
    function GetAppData(nAppID: TAppID; pchKey, pchValue: pAnsiChar; cchValueMax: int): int; virtual; abstract;
  end;

implementation


end.
