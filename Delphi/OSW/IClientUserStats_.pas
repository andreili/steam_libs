unit IClientUserStats_;

interface

uses
  SteamTypes, UserStatsCommon;

type
  IClientUserStats = class
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
    function IndicateAchievementProgress(nGameID: CGameID; pchName: pAnsiChar;
     nCurProgress, nMaxProgress: uint32): boolean; virtual; abstract;

    function SetMaxStatsLoaded(uMax: uint32): unknown_ret; virtual; abstract;

    // downloads stats for the user
    // returns a UserStatsReceived_t received when completed
    // if the other user has no stats, UserStatsReceived_t.m_eResult will be set to k_EResultFail
    // these stats won't be auto-updated; you'll need to call RequestUserStats( ) again to refresh any data
    function RequestUserStats(steamIDUser: CSteamID; nGameID: CGameID): SteamAPICall_t; virtual; abstract;

    // requests stat information for a user, usable after a successful call to RequestUserStats( )
    function GetUserStat(steamIDUser: CSteamID; nGameID: CGameID; pchName: pAnsiChar;
     var pData: int): boolean; overload; virtual; abstract;
    function GetUserStat(steamIDUser: CSteamID; nGameID: CGameID; pchName: pAnsiChar;
     var pData: float): boolean; overload; virtual; abstract;
    function GetUserAchievement(steamIDUser: CSteamID; nGameID: CGameID; pchName: pAnsiChar;
     var pbAchieved: boolean; var a1: uint32): boolean; virtual; abstract;

    // Reset stats
    function ResetAllStats(nGameID: CGameID; bAchievementsToo: boolean): boolean; virtual; abstract;

    // asks the Steam back-end for a leaderboard by name, and will create it if it's not yet
    // This call is asynchronous, with the result returned in LeaderboardFindResult_t
    function FindOrCreateLeaderboard(pchLeaderboardName: pAnsiChar; eLeaderboardSortMethod: ELeaderboardSortMethod;
     eLeaderboardDisplayType: ELeaderboardDisplayType): SteamAPICall_t; virtual; abstract;

    // as above, but won't create the leaderboard if it's not found
    // This call is asynchronous, with the result returned in LeaderboardFindResult_t
    function FindLeaderboard(pchLeaderboardName: pAnsiChar): SteamAPICall_t; virtual; abstract;

    // returns the name of a leaderboard
    function GetLeaderboardName(hSteamLeaderboard: SteamLeaderboard_t): pAnsiChar; virtual; abstract;

    // returns the total number of entries in a leaderboard, as of the last request
    function GetLeaderboardEntryCount(GetLeaderboardEntryCount: SteamLeaderboard_t): int; virtual; abstract;

    // returns the sort method of the leaderboard
    function GetLeaderboardSortMethod(hSteamLeaderboard: SteamLeaderboard_t): ELeaderboardSortMethod; virtual; abstract;

    // returns the display type of the leaderboard
    function GetLeaderboardDisplayType(hSteamLeaderboard: SteamLeaderboard_t): ELeaderboardDisplayType; virtual; abstract;

    // Asks the Steam back-end for a set of rows in the leaderboard.
    // This call is asynchronous, with the result returned in LeaderboardScoresDownloaded_t
    // LeaderboardScoresDownloaded_t will contain a handle to pull the results from GetDownloadedLeaderboardEntries( ) ( below)
    // You can ask for more entries than exist, and it will return as many as do exist.
    // k_ELeaderboardDataRequestGlobal requests rows in the leaderboard from the full table, with nRangeStart & nRangeEnd in the range [1, TotalEntries]
    // k_ELeaderboardDataRequestGlobalAroundUser requests rows around the current user, nRangeStart being negate
    //   e.g. DownloadLeaderboardEntries( hLeaderboard, k_ELeaderboardDataRequestGlobalAroundUser, -3, 3 ) will return 7 rows, 3 before the user, 3 after
    // k_ELeaderboardDataRequestFriends requests all the rows for friends of the current user
    function DownloadLeaderboardEntries(hSteamLeaderboard: SteamLeaderboard_t; eLeaderboardDataRequest: ELeaderboardDataRequest;
     nRangeStart, nRangeEnd: int): SteamAPICall_t; virtual; abstract;

    // Returns data about a single leaderboard entry
    // use a for loop from 0 to LeaderboardScoresDownloaded_t::m_cEntryCount to get all the downloaded entries
    // e.g.
    //		void OnLeaderboardScoresDownloaded( LeaderboardScoresDownloaded_t *pLeaderboardScoresDownloaded )
    //		{
    //			for ( int index = 0; index < pLeaderboardScoresDownloaded->m_cEntryCount; index++ )
    //			{
    //				LeaderboardEntry_t leaderboardEntry;
    //				int32 details[3];		// we know this is how many we've stored previously
    //				GetDownloadedLeaderboardEntry( pLeaderboardScoresDownloaded->m_hSteamLeaderboardEntries, index, &leaderboardEntry, details, 3 );
    //				assert( leaderboardEntry.m_cDetails == 3 );
    //				...
    //			}
    // once you've accessed all the entries, the data will be free'd, and the SteamLeaderboardEntries_t handle will become invalid
    function GetDownloadedLeaderboardEntry(hSteamLeaderboardEntries: SteamLeaderboardEntries_t; index: int;
     var pLeaderboardEntry: LeaderboardEntry_t; var pDetails: int; cDetailsMax: int): boolean; virtual; abstract;

    // Uploads a user score to the Steam back-end.
    // This call is asynchronous, with the result returned in LeaderboardScoreUploaded_t
    // If the score passed in is no better than the existing score this user has in the leaderboard, then the leaderboard will not be updated.
    // Details are extra game-defined information regarding how the user got that score
    // pScoreDetails points to an array of int32's, cScoreDetailsCount is the number of int32's in the list
    function UploadLeaderboardScore(hSteamLeaderboard: SteamLeaderboard_t; eLeaderboardUploadScoreMethod: ELeaderboardUploadScoreMethod;
     nScore: int; pScoreDetails: pint; cScoreDetailsCount: int): SteamAPICall_t; virtual; abstract;

    // Retrieves the number of players currently playing your game ( online + offline)
    // This call is asynchronous, with the result returned in NumberOfCurrentPlayers_t
    function GetNumberOfCurrentPlayers(): SteamAPICall_t; virtual; abstract;

    function GetNumAchievedAchievements(nGameID: CGameID): unknown_ret; virtual; abstract;
    function GetLastAchievementUnlocked(nGameID: CGameID): unknown_ret; virtual; abstract;
    function RequestGlobalAchievementPercentages(nGameID: CGameID): unknown_ret; virtual; abstract;
    function GetMostAchievedAchievementInfo(nGameID: CGameID; a: pAnsiChar; b: uint32;
     var c: float; var d: boolean): unknown_ret; virtual; abstract;
    function GetNextMostAchievedAchievementInfo(nGameID: CGameID; a: int; b: pAnsiChar; c: uint32;
     var d: float; var f: boolean): unknown_ret; virtual; abstract;
  end;

implementation

end.
