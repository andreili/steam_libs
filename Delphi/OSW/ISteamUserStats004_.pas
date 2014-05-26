unit ISteamUserStats004_;

interface

uses
  SteamTypes, UserStatsCommon;

type
  ISteamUserStats004 = class
    // Ask the server to send down this user's data and achievements for nGameID
    function RequestCurrentStats(nGameID: CGameID): boolean; virtual; abstract;

    // Data accessors
    function GetStat(pchName: pAnsiChar; var pData: int): boolean; overload; virtual; abstract;
    function GetStat(pchName: pAnsiChar; var pData: float): boolean; overload; virtual; abstract;

    // Set / update data
    function SetStat(pchName: pAnsiChar; var pData: int): boolean; overload; virtual; abstract;
    function SetStat(pchName: pAnsiChar; var pData: float): boolean; overload; virtual; abstract;
    function UpdateAvgRateStat(pchName: pAnsiChar; flCountThisSession: float; dSessionLength: double): boolean; virtual; abstract;

    // Achievement flag accessors
    function GetAchievement(pchName: pAnsiChar; varpbAchieved: boolean; var a1: uint32): boolean; virtual; abstract;

    function SetAchievement(pchName: pAnsiChar): boolean; virtual; abstract;
    function ClearAchievement(pchName: pAnsiChar): boolean; virtual; abstract;

    // Store the current data on the server, will get a callback when set
    // And one callback for every new achievement
    function StoreStats(nGameID: CGameID): boolean; virtual; abstract;

    // Gets the icon of the achievement, which is a handle to be used in IClientUtils::GetImageRGBA( ), or 0 if none set
    function GetAchievementIcon(pchName: pAnsiChar): int; virtual; abstract;
    // Get general attributes ( display name / text, etc) for an Achievement
    function GetAchievementDisplayAttribute(pchName, pchKey: pAnsiChar): pAnsiChar; virtual; abstract;

    // Achievement progress - triggers an AchievementProgress callback, that is all.
    // Calling this w/ N out of N progress will NOT set the achievement, the game must still do that.
    function IndicateAchievementProgress(pchName: pAnsiChar; nCurProgress, nMaxProgress: uint32): boolean; virtual; abstract;

    // Friends stats & achievements

    // downloads stats for the user
    // returns a UserStatsReceived_t received when completed
    // if the other user has no stats, UserStatsReceived_t.m_eResult will be set to k_EResultFail
    // these stats won't be auto-updated; you'll need to call RequestUserStats() again to refresh any data
    function RequestUserStats(steamIDUser: CSteamID): SteamAPICall_t; virtual; abstract;

    // requests stat information for a user, usable after a successful call to RequestUserStats()
    function GetUserStat(steamIDUser: CSteamID; nGameID: CGameID; pchName: pAnsiChar;
     var pData: int): boolean; overload; virtual; abstract;
    function GetUserStat(steamIDUser: CSteamID; nGameID: CGameID; pchName: pAnsiChar;
     var pData: float): boolean; overload; virtual; abstract;
    function GetUserAchievement(steamIDUser: CSteamID; nGameID: CGameID; pchName: pAnsiChar;
     var pbAchieved: boolean): boolean; virtual; abstract;

    // Reset stats
    function ResetAllStats(nGameID: CGameID; bAchievementsToo: boolean): boolean; virtual; abstract;
  end;

implementation

end.
