unit UserStatsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  STEAMUSERSTATS_INTERFACE_VERSION_001 = 'STEAMUSERSTATS_INTERFACE_VERSION001';
  STEAMUSERSTATS_INTERFACE_VERSION_002 = 'STEAMUSERSTATS_INTERFACE_VERSION002';
  STEAMUSERSTATS_INTERFACE_VERSION_003 = 'STEAMUSERSTATS_INTERFACE_VERSION003';
  STEAMUSERSTATS_INTERFACE_VERSION_004 = 'STEAMUSERSTATS_INTERFACE_VERSION004';
  STEAMUSERSTATS_INTERFACE_VERSION_005 = 'STEAMUSERSTATS_INTERFACE_VERSION005';
  STEAMUSERSTATS_INTERFACE_VERSION_006 = 'STEAMUSERSTATS_INTERFACE_VERSION006';
  STEAMUSERSTATS_INTERFACE_VERSION_007 = 'STEAMUSERSTATS_INTERFACE_VERSION007';
  CLIENTUSERSTATS_INTERFACE_VERSION = 'CLIENTUSERSTATS_INTERFACE_VERSION002';

type
  //-----------------------------------------------------------------------------
  // types of user game stats fields
  // WARNING: DO NOT RENUMBER EXISTING VALUES - STORED IN DATABASE
  //-----------------------------------------------------------------------------
  ESteamUserStatType =
    (k_ESteamUserStatTypeINVALID = 0,
     k_ESteamUserStatTypeINT = 1,
     k_ESteamUserStatTypeFLOAT = 2,
     // Read as FLOAT, set with count / session length
     k_ESteamUserStatTypeAVGRATE = 3,
     k_ESteamUserStatTypeACHIEVEMENTS = 4,
     k_ESteamUserStatTypeGROUPACHIEVEMENTS = 5);

  // type of data request, when downloading leaderboard entries
  ELeaderboardDataRequest =
    (k_ELeaderboardDataRequestGlobal = 0,
     k_ELeaderboardDataRequestGlobalAroundUser = 1,
     k_ELeaderboardDataRequestFriends = 2);

  // the display type (used by the Steam Community web site) for a leaderboard
  ELeaderboardDisplayType =
    (k_ELeaderboardDisplayTypeNone = 0,
     k_ELeaderboardDisplayTypeNumeric = 1,            // simple numerical score
     k_ELeaderboardDisplayTypeTimeSeconds = 2,        // the score represents a time, in seconds
     k_ELeaderboardDisplayTypeTimeMilliSeconds = 3);  // the score represents a time, in milliseconds

  ELeaderboardUploadScoreMethod =
    (k_ELeaderboardUploadScoreMethodNone = 0,
     k_ELeaderboardUploadScoreMethodKeepBest = 1,       // Leaderboard will keep user's best score
     k_ELeaderboardUploadScoreMethodForceUpdate = 2);   // Leaderboard will always replace score with specified

  // the sort order of a leaderboard
  ELeaderboardSortMethod =
    (k_ELeaderboardSortMethodNone = 0,
     k_ELeaderboardSortMethodAscending = 1,      // top-score is lowest number
     k_ELeaderboardSortMethodDescending = 2);    // top-score is highest number

  // a single entry in a leaderboard, as returned by GetDownloadedLeaderboardEntry()
  LeaderboardEntry_t = record
    m_steamIDUser: CSteamID;  // user with the entry - use SteamFriends()->GetFriendPersonaName() & SteamFriends()->GetFriendAvatar() to get more info
    m_nGlobalRank,            // [1..N], where N is the number of users with an entry in the leaderboard
    m_nScore,                 // score as set in the leaderboard
    m_cDetails: int32;        // number of int32 details available for this entry
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the latests stats and achievements have been received
  //			from the server
  //-----------------------------------------------------------------------------
  UserStatsReceived_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks + 1
    {$ENDIF}
    m_nGameID: uint64;        // Game these stats are for
    m_eResult: EResult;       // Success / error fetching the stats// Success / error fetching the stats
    m_steamIDUser: CSteamID;  // The user for whom the stats are retrieved for
  end;

  //-----------------------------------------------------------------------------
  // Purpose: result of a request to store the user stats for a game
  //-----------------------------------------------------------------------------
  UserStatsStored_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks + 2
    {$ENDIF}
    m_nGameID: uint64;   // Game these stats are for
    m_eResult: EResult;  // success / error
  end;

  //-----------------------------------------------------------------------------
  // Purpose: result of a request to store the achievements for a game, or an
  //			"indicate progress" call. If both m_nCurProgress and m_nMaxProgress
  //			are zero, that means the achievement has been fully unlocked.
  //-----------------------------------------------------------------------------
  UserAchievementStored_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks + 3
    {$ENDIF}
    m_nGameID: uint64;            // Game this is for
    m_bGroupAchievement: boolean; // if this is a "group" achievement
    m_rgchAchievementName: array[0..127] of AnsiChar;
    m_nCurProgress,               // current progress towards the achievement
    m_nMaxProgress: uint32;       // "out of" this many
  end;

  //-----------------------------------------------------------------------------
  // Purpose: call result for finding a leaderboard, returned as a result of FindOrCreateLeaderboard() or FindLeaderboard()
  //			use CCallResult<> to map this async result to a member function
  //-----------------------------------------------------------------------------
  LeaderboardFindResult_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks +4
    {$ENDIF}
    m_hSteamLeaderboard: SteamLeaderboard_t;  // handle to the leaderboard serarched for, 0 if no leaderboard found
    m_bLeaderboardFound: uint8;               // 0 if no leaderboard found
  end;

  //-----------------------------------------------------------------------------
  // Purpose: call result indicating scores for a leaderboard have been downloaded and are ready to be retrieved, returned as a result of DownloadLeaderboardEntries()
  //			use CCallResult<> to map this async result to a member function
  //-----------------------------------------------------------------------------
  LeaderboardScoresDownloaded_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks +5
    {$ENDIF}
    m_hSteamLeaderboard: SteamLeaderboard_t;
    m_hSteamLeaderboardEntries: SteamLeaderboardEntries_t;  // the handle to pass into GetDownloadedLeaderboardEntries()
    m_cEntryCount: int;                                     // the number of entries downloaded
  end;

  //-----------------------------------------------------------------------------
  // Purpose: call result indicating scores has been uploaded, returned as a result of UploadLeaderboardScore()
  //			use CCallResult<> to map this async result to a member function
  //-----------------------------------------------------------------------------
  LeaderboardScoreUploaded_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks +6
    {$ENDIF}
    m_bSuccess: uint8;                        // 1 if the call was successful
    m_hSteamLeaderboard: SteamLeaderboard_t;  // the leaderboard handle that was
    m_nScore: int32;                          // the score that was attempted to set
    m_bScoreChanged: uint8;                   // true if the score in the leaderboard change, false if the existing score was better
    m_nGlobalRankNew,                         // the new global rank of the user in this leaderboard
    m_nGlobalRankPrevious: int;               // the previous global rank of the user in this leaderboard; 0 if the user had no existing entry in the leaderboard
  end;

  NumberOfCurrentPlayers_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks +7
    {$ENDIF}
    m_bSuccess: uint8;   // 1 if the call was successful
    m_cPlayers: int32;   // Number of players currently playing
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Callback indicating that a user's stats have been unloaded.
  //  Call RequestUserStats again to access stats for this user
  //-----------------------------------------------------------------------------
  UserStatsUnloaded_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks +8
    {$ENDIF}
    m_steamIDUser: CSteamID;    // User whose stats have been unloaded;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Callback indicating that an achievement icon has been fetched
  //-----------------------------------------------------------------------------
  UserAchievementIconFetched_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserStatsCallbacks +9
    {$ENDIF}
    m_nGameID: CGameID;       // Game this is for
    m_rgchAchievementName: array[0..127] of AnsiChar; // name of the achievement
    m_bAchieved: boolean;     // Is the icon for the achieved or not achieved version?
    m_nIconHandle: integer;   // Handle to the image, which can be used in ClientUtils()->GetImageRGBA(), 0 means no image is set for the achievement
  end;

implementation

end.
