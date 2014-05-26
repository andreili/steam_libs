unit MatchmakingCommon;

interface

{$I Defines.inc}

uses
  SteamTypes, FriendsCommon;

const
  CLIENTMATCHMAKING_INTERFACE_VERSION = 'CLIENTMATCHMAKING_INTERFACE_VERSION001';
  STEAMMATCHMAKING_INTERFACE_VERSION_001 = 'SteamMatchMaking001';
  STEAMMATCHMAKING_INTERFACE_VERSION_002 = 'SteamMatchMaking002';
  STEAMMATCHMAKING_INTERFACE_VERSION_003 = 'SteamMatchMaking003';
  STEAMMATCHMAKING_INTERFACE_VERSION_004 = 'SteamMatchMaking004';
  STEAMMATCHMAKING_INTERFACE_VERSION_005 = 'SteamMatchMaking005';
  STEAMMATCHMAKING_INTERFACE_VERSION_006 = 'SteamMatchMaking006';
  STEAMMATCHMAKING_INTERFACE_VERSION_007 = 'SteamMatchMaking007';
  STEAMMATCHMAKING_INTERFACE_VERSION_008 = 'SteamMatchMaking008';

type
  ELobbyComparison =
    (k_ELobbyComparisonEqualToOrLessThan = -2,
     k_ELobbyComparisonLessThan = -1,
     k_ELobbyComparisonEqual = 0,
     k_ELobbyComparisonGreaterThan = 1,
     k_ELobbyComparisonEqualToOrGreaterThan = 2,
     k_ELobbyComparisonNotEqual = 3);

  ELobbyDistanceFilter =
    (k_ELobbyDistanceFilterClose = 0,
     k_ELobbyDistanceFilterDefault = 1,
     k_ELobbyDistanceFilterFar = 2,
     k_ELobbyDistanceFilterWorldwide = 3);

  //-----------------------------------------------------------------------------
  // Purpose: a server was added/removed from the favorites list, you should refresh now
  //-----------------------------------------------------------------------------
  FavoritesListChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +2
    {$ENDIF}
    m_nIP,               // an IP of 0 means reload the whole list, any other value means just one server
    m_nQueryPort,
    m_nConnPort: uint32;
    m_nAppID: AppId_t;
    m_nFlags: uint32;
    m_bAdd: boolean;     // true if this is adding the entry, otherwise it is a remove
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Someone has invited you to join a Lobby
  //			normally you don't need to do anything with this, since
  //			the Steam UI will also display a '<user> has invited you to the lobby, join?' dialog
  //
  //			if the user outside a game chooses to join, your game will be launched with the parameter "+connect_lobby <64-bit lobby id>",
  //			or with the callback GameLobbyJoinRequested_t if they're already in-game
  //-----------------------------------------------------------------------------
  LobbyInvite_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +3
    {$ENDIF}
    m_ulSteamIDUser,              // Steam ID of the person making the invite
    m_ulSteamIDLobby: CSteamID;   // Steam ID of the Lobby
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Sent on entering a lobby, or on failing to enter
  //			m_EChatRoomEnterResponse will be set to k_EChatRoomEnterResponseSuccess on success,
  //			or a higher value on failure (see enum EChatRoomEnterResponse)
  //-----------------------------------------------------------------------------
  LobbyEnter_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +4
    {$ENDIF}
    m_ulSteamIDLobby: CSteamID;                         // SteamID of the Lobby you have entered
    m_rgfChatPermissions: EChatPermission;              // Permissions of the current user
    m_bLocked: boolean;                                 // If true, then only invited users may join
    m_EChatRoomEnterResponse: EChatRoomEnterResponse;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: The lobby metadata has changed
  //			if m_ulSteamIDMember is the steamID of a lobby member, use GetLobbyMemberData() to access per-user details
  //			if m_ulSteamIDMember == m_ulSteamIDLobby, use GetLobbyData() to access lobby metadata
  //-----------------------------------------------------------------------------
  LobbyDataUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +5
    {$ENDIF}
    m_ulSteamIDLobby,             // steamID of the Lobby
    m_ulSteamIDMember: CSteamID;  // steamID of the member whose data changed, or the room itself
  end;

  //-----------------------------------------------------------------------------
  // Purpose: The lobby chat room state has changed
  //			this is usually sent when a user has joined or left the lobby
  //-----------------------------------------------------------------------------
  LobbyChatUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +6
    {$ENDIF}
    m_ulSteamIDLobby,                   // Lobby ID
    m_ulSteamIDUserChanged,             // user who's status in the lobby just changed - can be recipient
    m_ulSteamIDMakingChange: CSteamID;  // Chat member who made the change (different from SteamIDUserChange if kicking, muting, etc.)
                                        // for example, if one user kicks another from the lobby, this will be set to the id of the user who initiated the kick
    m_rgfChatMemberStateChange: EChatMemberStateChange; // bitfield of EChatMemberStateChange values
  end;

  //-----------------------------------------------------------------------------
  // Purpose: A chat message for this lobby has been sent
  //			use GetLobbyChatEntry( m_iChatID ) to retrieve the contents of this message
  //-----------------------------------------------------------------------------
  LobbyChatMsg_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +7
    {$ENDIF}
    m_ulSteamIDLobby,         // the lobby id this is in
    m_ulSteamIDUser: uint64;  // steamID of the user who has sent this message
    m_eChatEntryType: uint8;  // type of message
    m_iChatID: uint32;        // index of the chat entry to lookup
  end;

  //-----------------------------------------------------------------------------
  // Purpose: There's a change of Admin in this Lobby
  //-----------------------------------------------------------------------------
  LobbyAdminChange_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +8
    {$ENDIF}
    m_ulSteamIDLobby,
    m_ulSteamIDNewAdmin: CSteamID;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: A game created a game for all the members of the lobby to join,
  //			as triggered by a SetLobbyGameServer()
  //			it's up to the individual clients to take action on this; the usual
  //			game behavior is to leave the lobby and connect to the specified game server
  //-----------------------------------------------------------------------------
  LobbyGameCreated_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +9
    {$ENDIF}
    m_ulSteamIDLobby,                 // the lobby we were in
    m_ulSteamIDGameServer: CSteamID;  // the new game server that has been created or found for the lobby members
    m_unIP: uint32;                   // IP & Port of the game server (if any)
    m_usPort: uint16;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Number of matching lobbies found
  //			iterate the returned lobbies with GetLobbyByIndex(), from values 0 to m_nLobbiesMatching-1
  //-----------------------------------------------------------------------------
  LobbyMatchList_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +10
    {$ENDIF}
    m_nLobbiesMatching: uint32;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Called when the lobby is being forcefully closed
  //			lobby details functions will no longer be updated
  //-----------------------------------------------------------------------------
  LobbyClosing_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +11
    {$ENDIF}
    m_ulSteamIDLobby: CSteamID;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: posted if a user is forcefully removed from a lobby
  //			can occur if a user loses connection to Steam
  //-----------------------------------------------------------------------------
  LobbyKicked_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +12
    {$ENDIF}
    m_ulSteamIDLobby,                // Lobby
    m_ulSteamIDAdmin: uint64;        // User who kicked you - possibly the ID of the lobby itself
    m_bKickedDueToDisconnect: uint8; // true if you were kicked from the lobby due to the user losing connection to Steam (currently always true)
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Result of our request to create a Lobby
  //			m_eResult == k_EResultOK on success
  //			at this point, the local user may not have finishing joining this lobby;
  //			game code should wait until the subsequent LobbyEnter_t callback is received
  //-----------------------------------------------------------------------------
  LobbyCreated_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamMatchmakingCallbacks +13
    {$ENDIF}
    m_eResult: EResult;           // k_EResultOK - the lobby was successfully created
                                  // k_EResultNoConnection - your Steam client doesn't have a connection to the back-end
                                  // k_EResultTimeout - you the message to the Steam servers, but it didn't respond
                                  // k_EResultFail - the server responded, but with an unknown internal error
                                  // k_EResultAccessDenied - your game isn't set to allow lobbies, or your client does haven't rights to play the game
                                  // k_EResultLimitExceeded - your game client has created too many lobbies
    m_ulSteamIDLobby: CSteamID;  // chat room, zero if failed
  end;

implementation

end.
