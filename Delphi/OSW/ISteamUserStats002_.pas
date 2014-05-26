unit ISteamUserStats002_;

interface

uses
  SteamTypes, UserStatsCommon;

type
  ISteamUserStats002 = class
    // The "schema" of a Game's UserData is really defined elsewhere, and
    // the game should know it before accessing this interface. These top
    // three functions are mostly provided for iteration / testing purposes.
    // Get the number of stats fields for nGameID
    function GetNumStats(nGameID: CGameID): uint32; virtual; abstract;
    // Get stat name iStat in [0, GetNumStats)
    function GetStatName(nGameID: CGameID; iStat: uint32): pAnsiChar; virtual; abstract;
    // Get type of this field
    function GetStatType(nGameID: CGameID; pchName: pAnsiChar): ESteamUserStatType; virtual; abstract;
    // Get the number of achievements for nGameID
    function GetNumAchievements(nGameID: CGameID): uint32; virtual; abstract;
    // Get achievement name iAchievement in [0, GetNumAchievements)
    function GetAchievementName(GetAchievementName: CGameID; iAchievement: uint32): pAnsiChar; virtual; abstract;

    // Ask the server to send down this user's data and achievements for nGameID
    function RequestCurrentStats(nGameID: CGameID): boolean; virtual; abstract;

    // Data accessors
    function GetStat(nGameID: CGameID; pchName: pAnsiChar; var pData: int): boolean; overload; virtual; abstract;
    function GetStat(nGameID: CGameID; pchName: pAnsiChar; var pData: float): boolean; overload; virtual; abstract;

    // Set / update data
    function SetStat(nGameID: CGameID; pchName: pAnsiChar; var pData: int): boolean; overload; virtual; abstract;
    function SetStat(nGameID: CGameID; pchName: pAnsiChar; var pData: float): boolean; overload; virtual; abstract;
    function UpdateAvgRateStat(nGameID: CGameID; pchName: pAnsiChar;
     flCountThisSession: float; dSessionLength: double): boolean; virtual; abstract;

    // Achievement flag accessors
    function GetAchievement(nGameID: CGameID; pchName: pAnsiChar; varpbAchieved: boolean; var a1: uint32): boolean; virtual; abstract;

    function SetAchievement(nGameID: CGameID; pchName: pAnsiChar): boolean; virtual; abstract;
    function ClearAchievement(nGameID: CGameID; pchName: pAnsiChar): boolean; virtual; abstract;

    // Store the current data on the server, will get a callback when set
    // And one callback for every new achievement
    function StoreStats(nGameID: CGameID): boolean; virtual; abstract;

    // Gets the icon of the achievement, which is a handle to be used in IClientUtils::GetImageRGBA( ), or 0 if none set
    function GetAchievementIcon(nGameID: CGameID; pchName: pAnsiChar): int; virtual; abstract;
    // Get general attributes ( display name / text, etc) for an Achievement
    function GetAchievementDisplayAttribute(nGameID: CGameID; pchName, pchKey: pAnsiChar): pAnsiChar; virtual; abstract;

    // Achievement progress - triggers an AchievementProgress callback, that is all.
    // Calling this w/ N out of N progress will NOT set the achievement, the game must still do that.
    function IndicateAchievementProgress(nGameID: CGameID; pchName: pAnsiChar; nCurProgress, nMaxProgress: uint32): boolean; virtual; abstract;
  end;

implementation

end.
