unit GameStatsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  STEAMGAMESTATS_INTERFACE_VERSION_001 = 'SteamGameStats001';
  CLIENTGAMESTATS_INTERFACE_VERSION = 'CLIENTGAMESTATS_INTERFACE_VERSION001';

type
  //-----------------------------------------------------------------------------
  // Purpose: nAccountType for GetNewSession
  //-----------------------------------------------------------------------------
  EGameStatsAccountType =
    (k_EGameStatsAccountType_Steam = 1,             // ullAccountID is a 64-bit SteamID for a player
     k_EGameStatsAccountType_Xbox = 2,              // ullAccountID is a 64-bit XUID
     k_EGameStatsAccountType_SteamGameServer = 3);  // ullAccountID is a 64-bit SteamID for a game server

  //-----------------------------------------------------------------------------
  // Purpose: callback for GetNewSession() method
  //-----------------------------------------------------------------------------
  GameStatsSessionIssued_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameStatsCallbacks +1
    {$ENDIF}
    m_ulSessionID: uint64;
    m_eResult: EResult;
    m_bCollectingAny,
    m_bCollectingDetails: boolean;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: callback for EndSession() method
  //-----------------------------------------------------------------------------
  GameStatsSessionClosed_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameStatsCallbacks +2
    {$ENDIF}
    m_ulSessionID: uint64;
    m_eResult: EResult;
  end;

implementation

end.
