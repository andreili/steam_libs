unit ISteamGameServerStats001_;

interface

uses
  SteamTypes, GameServerStatsCommon;

type
  ISteamGameServerStats001 = class
    // downloads stats for the user
    // returns a GSStatsReceived_t callback when completed
    // if the user has no stats, GSStatsReceived_t.m_eResult will be set to k_EResultFail
    // these stats will only be auto-updated for clients playing on the server. For other
    // users you'll need to call RequestUserStats() again to refresh any data
    function RequestUserStats(steamIDUser: CSteamID): SteamAPICall_t; virtual; abstract;

    // requests stat information for a user, usable after a successful call to RequestUserStats()
    function GetUserStat(steamIDUser: CSteamID; pchName: pAnsiChar; var pData: int32): boolean; virtual; abstract;
    function GetUserStat1(steamIDUser: CSteamID; pchName: pAnsiChar; var pData: float): boolean; virtual; abstract;
    function GetUserAchievement(steamIDUser: CSteamID; pchName: pAnsiChar; var pbAchieved: boolean): boolean; virtual; abstract;

    // Set / update stats and achievements.
    // Note: These updates will work only on stats game servers are allowed to edit and only for
    // game servers that have been declared as officially controlled by the game creators.
    // Set the IP range of your official servers on the Steamworks page
    function SetUserStat(steamIDUser: CSteamID; pchName: pAnsiChar; nData: int32): boolean; virtual; abstract;
    function SetUserStat1(steamIDUser: CSteamID; pchName: pAnsiChar; fData: float): boolean; virtual; abstract;
    function UpdateUserAvgRateStat(steamIDUser: CSteamID; pchName: pAnsiChar;
     flCountThisSession: float; dSessionLength: double): boolean; virtual; abstract;

    function SetUserAchievement(steamIDUser: CSteamID; pchName: pAnsiChar): boolean; virtual; abstract;
    function ClearUserAchievement(steamIDUser: CSteamID; pchName: pAnsiChar): boolean; virtual; abstract;

    // Store the current data on the server, will get a GSStatsStored_t callback when set.
    //
    // If the callback has a result of k_EResultInvalidParam, one or more stats
    // uploaded has been rejected, either because they broke constraints
    // or were out of date. In this case the server sends back updated values.
    // The stats should be re-iterated to keep in sync.
    function StoreUserStats(steamIDUser: CSteamID): SteamAPICall_t; virtual; abstract;
  end;

implementation

end.
