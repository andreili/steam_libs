unit GameServerStatsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  STEAMGAMESERVERSTATS_INTERFACE_VERSION_001 = 'SteamGameServerStats001';

type
  //-----------------------------------------------------------------------------
  // Purpose: called when the latests stats and achievements have been received
  //			from the server
  //-----------------------------------------------------------------------------
  GSStatsReceived_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerStatsCallbacks +0
    {$ENDIF}
    m_eResult: EResult;       // Success / error fetching the stats
    m_steamIDUser: CSteamID;  // The user for whom the stats are retrieved for
  end;

  //-----------------------------------------------------------------------------
  // Purpose: result of a request to store the user stats for a game
  //-----------------------------------------------------------------------------
  GSStatsStored_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerStatsCallbacks +1
    {$ENDIF}
    m_eResult: EResult;
    m_steamIDUser: CSteamID;    // The user for whom the stats were stored
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Callback indicating that a user's stats have been unloaded.
  //  Call RequestUserStats again to access stats for this user
  //-----------------------------------------------------------------------------
  GSStatsUnloaded_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerStatsCallbacks +8
    {$ENDIF}
    m_steamIDUser: CSteamID;    // User whose stats have been unloaded
  end;

implementation

end.
