unit GameServerCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  STEAMGAMESERVER_INTERFACE_VERSION_002 = 'SteamGameServer002';
  STEAMGAMESERVER_INTERFACE_VERSION_003 = 'SteamGameServer002';
  STEAMGAMESERVER_INTERFACE_VERSION_004 = 'SteamGameServer003';
  STEAMGAMESERVER_INTERFACE_VERSION_005 = 'SteamGameServer004';
  STEAMGAMESERVER_INTERFACE_VERSION_006 = 'SteamGameServer005';
  STEAMGAMESERVER_INTERFACE_VERSION_007 = 'SteamGameServer006';
  STEAMGAMESERVER_INTERFACE_VERSION_008 = 'SteamGameServer007';
  STEAMGAMESERVER_INTERFACE_VERSION_009 = 'SteamGameServer009';
  STEAMGAMESERVER_INTERFACE_VERSION_010 = 'SteamGameServer010';

type
  // Result codes to GSHandleClientDeny/Kick
  EDenyReason =
    (k_EDenyInvalidVersion = 1,
     k_EDenyGeneric = 2,
     k_EDenyNotLoggedOn = 3,
     k_EDenyNoLicense = 4,
     k_EDenyCheater = 5,
     k_EDenyLoggedInElseWhere = 6,
     k_EDenyUnknownText = 7,
     k_EDenyIncompatibleAnticheat = 8,
     k_EDenyMemoryCorruption = 9,
     k_EDenyIncompatibleSoftware = 10,
     k_EDenySteamConnectionLost = 11,
     k_EDenySteamConnectionError = 12,
     k_EDenySteamResponseTimedOut = 13,
     k_EDenySteamValidationStalled = 14,
     k_EDenySteamOwnerLeftGuestUser = 15);

  // client has been approved to connect to this game server
  GSClientApprove_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +1
    {$ENDIF}
    m_SteamID: CSteamID;
  end;

  // client has been denied to connection to this game server
  GSClientDeny_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +2
    {$ENDIF}
    m_SteamID: CSteamID;
    m_eDenyReason: EDenyReason;
    m_pchOptionalText: array[0..127] of AnsiChar;
  end;

  // request the game server should kick the user
  GSClientKick_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +3
    {$ENDIF}
    m_SteamID: CSteamID;
    m_eDenyReason: EDenyReason;
  end;

  // NOTE: callback values 4 and 5 are skipped because they are used for old deprecated callbacks,
  // do not reuse them here.

  // client has been denied to connect to this game server because of a Steam2 auth failure
  GSClientSteam2Deny_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +4
    {$ENDIF}
    m_UserID: uint32;
    m_eSteamError: ESteamError;
  end;

  // client has been accepted by Steam2 to connect to this game server
  GSClientSteam2Accept_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +5
    {$ENDIF}
    m_UserID: uint32;
    m_SteamID: CSteamID;
  end;

  // client achievement info
  GSClientAchievementStatus_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +6
    {$ENDIF}
    m_SteamID: CSteamID;
    m_pchAchievement: array[0..127] of AnsiChar;
    m_bUnlocked: boolean;
  end;

  // GS gameplay stats info
  GSGameplayStats_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +7
    {$ENDIF}
    m_eResult: EResult;
    m_nRank: int32;                  // Overall rank of the server (0-based)
    m_unTotalConnects,               // Total number of clients who have ever connected to the server
    m_unTotalMinutesPlayed: uint32;  // Total number of minutes ever played on the server
  end;

  // send as a reply to RequestUserGroupStatus()
  GSClientGroupStatus_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +8
    {$ENDIF}
    m_SteamIDUser,
    m_SteamIDGroup: CSteamID;
    m_bMember,
    m_bOfficer: boolean;
  end;

  // Sent as a reply to GetServerReputation()
  GSReputation_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +9
    {$ENDIF}
    m_eResult: EResult;                    // Result of the call;
    m_unReputationScore: uint32;           // The reputation score for the game server
    m_bBanned: boolean;                    // True if the server is banned from the Steam
      // The following members are only filled out if m_bBanned is true. They will all
      // be set to zero otherwise. Master server bans are by IP so it is possible to be
      // banned even when the score is good high if there is a bad server on another port.
      // This information can be used to determine which server is bad.
    m_unBannedIP: uint32;                  // The IP of the banned server
    m_usBannedPort: uint16;                // The port of the banned server
    m_ulBannedGameID: uint64;              // The game ID the banned server is serving
    m_unBanExpires: uint32;                // Time the ban expires, expressed in the Unix epoch (seconds since 1/1/1970)
  end;

  // received when the game server requests to be displayed as secure (VAC protected)
  // m_bSecure is true if the game server should display itself as secure to users, false otherwise
  GSPolicyResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerCallbacks +15
    {$ENDIF}
    m_bSecure: uint8;
  end;

implementation

end.
