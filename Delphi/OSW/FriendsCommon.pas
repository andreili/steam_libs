unit FriendsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  CLIENTFRIENDS_INTERFACE_VERSION = 'CLIENTFRIENDS_INTERFACE_VERSION001';
  STEAMFRIENDS_INTERFACE_VERSION_001 = 'SteamFriends001';
  STEAMFRIENDS_INTERFACE_VERSION_002 = 'SteamFriends002';
  STEAMFRIENDS_INTERFACE_VERSION_003 = 'SteamFriends003';
  STEAMFRIENDS_INTERFACE_VERSION_004 = 'SteamFriends004';
  STEAMFRIENDS_INTERFACE_VERSION_005 = 'SteamFriends005';
  STEAMFRIENDS_INTERFACE_VERSION_006 = 'SteamFriends006';
  STEAMFRIENDS_INTERFACE_VERSION_007 = 'SteamFriends007';

type
  //-----------------------------------------------------------------------------
  // Purpose: avatar sizes, used in ISteamFriends::GetFriendAvatar()
  //-----------------------------------------------------------------------------
  EAvatarSize =
    (k_EAvatarSize32x32 = 0,
     k_EAvatarSize64x64 = 1);

  ECallState =
    (k_ECallStateUnknown = 0,
     k_ECallStateWaiting = 1,
     k_ECallStateDialing = 2,
     k_ECallStateRinging = 3,
     k_ECallStateInCall = 4);

  //-----------------------------------------------------------------------------
  // Purpose: Chat Entry Types (previously was only friend-to-friend message types)
  //-----------------------------------------------------------------------------
  EChatEntryType =
    (k_EChatEntryTypeInvalid = 0,
     k_EChatEntryTypeChatMsg = 1,           // Normal text message from another user
     k_EChatEntryTypeTyping = 2,            // Another user is typing (not used in multi-user chat)
     k_EChatEntryTypeInviteGame = 3,        // Invite from other user into that users current game
     k_EChatEntryTypeEmote = 4,             // text emote message
     k_EChatEntryTypeLobbyGameStart = 5,    // lobby game is starting
     k_EChatEntryTypeLeftConversation = 6); // user has left the conversation ( closed chat window )

  // Type of system IM.  The client can use this to do special UI handling in specific circumstances
  ESystemIMType =
    (k_ESystemIMRawText = 0,
     k_ESystemIMInvalidCard = 1,
     k_ESystemIMRecurringPurchaseFailed = 2,
     k_ESystemIMCardWillExpire = 3,
     k_ESystemIMSubscriptionExpired = 4,

     k_ESystemIMGuestPassReceived = 5,
     k_ESystemIMGuestPassGranted = 6,
     k_ESystemIMGiftRevoked = 7,

     k_ESystemIMTypeMax);

  //-----------------------------------------------------------------------------
  // Purpose: set of relationships to other users
  //-----------------------------------------------------------------------------
  EFriendRelationship =
    (k_EFriendRelationshipNone = 0,
     k_EFriendRelationshipBlocked = 1,
     k_EFriendRelationshipRequestRecipient = 2,
     k_EFriendRelationshipFriend = 3,
     k_EFriendRelationshipRequestInitiator = 4,
     k_EFriendRelationshipIgnored = 5,
     k_EFriendRelationshipIgnoredFriend = 6);

  EChatRoomType =
    (k_EChatRoomTypeFriend = 1,
     k_EChatRoomTypeMUC = 2,
     k_EChatRoomTypeLobby = 3);

  EChatRoomVoiceStatus =
    (eChatRoomVoiceStatusBad = 0,
     eChatRoomVoiceStatusUnknownRoom = 1,
     eChatRoomVoiceStatusUnknownUser = 2,
     eChatRoomVoiceStatusNotSpeaking = 3,
     eChatRoomVoiceStatusConnectedSpeaking = 4,
     eChatRoomVoiceStatusConnectedSpeakingData = 5,
     eChatRoomVoiceStatusNotConnectedSpeaking = 6,
     eChatRoomVoiceStatusConnecting = 7,
     eChatRoomVoiceStatusUnreachable = 8,
     eChatRoomVoiceStatusDisconnected = 9,
     eChatRoomVoiceStatusCount = 10);

  EClanRank =
    (k_EClanRankNone = 0,
     k_EClanRankOwner = 1,
     k_EClanRankOfficer = 2,
     k_EClanRankMember = 3);

  EClanRelationship =
    (eClanRelationshipNone = 0,
     eClanRelationshipBlocked = 1,
     eClanRelationshipInvited = 2,
     eClanRelationshipMember = 3,
     eClanRelationshipKicked = 4);

  // for enumerating friends list
  EFriendFlags =
    (k_EFriendFlagNone = $00,
     k_EFriendFlagBlocked = $01,
     k_EFriendFlagFriendshipRequested = $02,
     k_EFriendFlagImmediate = $04,
     k_EFriendFlagClanMember = $08,
     k_EFriendFlagOnGameServer = $10,
     //k_EFriendFlagHasPlayedWith = $20,
     //k_EFriendFlagFriendOfFriend = $40,
     k_EFriendFlagRequestingFriendship = $80,
     k_EFriendFlagRequestingInfo = $100,
     k_EFriendFlagIgnored = $200,
     k_EFriendFlagIgnoredFriend = $400,
     k_EFriendFlagAll = $ffff);

  k_EFriendFlags = EFriendFlags;

  //-----------------------------------------------------------------------------
  // Purpose: friend-to-friend message types
  //-----------------------------------------------------------------------------
  EFriendMsgType =
    (k_EFriendMsgTypeChat = 1,       // chat test message
     k_EFriendMsgTypeTyping = 2,     // lets the friend know the other user has starting typing a chat message
     k_EFriendMsgTypeInvite = 3,     // invites the friend into the users current game
     k_EFriendMsgTypeChatSent = 4);  // chat that the user has sent to a friend

  //-----------------------------------------------------------------------------
  // Purpose: list of states a friend can be in
  //-----------------------------------------------------------------------------
  EPersonaState =
    (k_EPersonaStateOffline = 0,  // friend is not currently logged on
     k_EPersonaStateOnline = 1,   // friend is logged on
     k_EPersonaStateBusy = 2,     // user is on, but busy
     k_EPersonaStateAway = 3,     // auto-away feature
     k_EPersonaStateSnooze = 4,   // auto-away for a long time
     k_EPersonaStateMax);

  // used in PersonaStateChange_t::m_nChangeFlags to describe what's changed about a user
  // these flags describe what the client has learned has changed recently, so on startup you'll see a name, avatar & relationship change for every friend
  EPersonaChange =
    (k_EPersonaChangeName = $001,
     k_EPersonaChangeStatus = $002,
     k_EPersonaChangeComeOnline = $004,
     k_EPersonaChangeGoneOffline = $008,
     k_EPersonaChangeGamePlayed = $010,
     k_EPersonaChangeGameServer = $020,
     k_EPersonaChangeAvatar = $040,
     k_EPersonaChangeJoinedSource = $080,
     k_EPersonaChangeLeftSource = $100,
     k_EPersonaChangeRelationshipChanged = $200,
     k_EPersonaChangeNameFirstSet = $400);

  EChatPermission =
    (k_EChatPermissionClose = 1,
     k_EChatPermissionInvite = 2,
     k_EChatPermissionTalk = 8,
     k_EChatPermissionKick = 16,
     k_EChatPermissionMute = 32,
     k_EChatPermissionSetMetadata = 64,
     k_EChatPermissionChangePermissions = 128,
     k_EChatPermissionBan = 256,
     k_EChatPermissionChangeAccess = 512,
     k_EChatPermissionEveryoneNotInClanDefault = 8,
     k_EChatPermissionEveryoneDefault = 10,
     k_EChatPermissionMemberDefault = 282,
     k_EChatPermissionOfficerDefault = 282,
     k_EChatPermissionOwnerDefault = 891,
     k_EChatPermissionMask = 1019);

  //-----------------------------------------------------------------------------
  // Purpose: Chat Room Enter Responses
  //-----------------------------------------------------------------------------
  EChatRoomEnterResponse =
    (k_EChatRoomEnterResponseSuccess = 1,         // Success
     k_EChatRoomEnterResponseDoesntExist = 2,     // Chat doesn't exist (probably closed)
     k_EChatRoomEnterResponseNotAllowed = 3,      // General Denied - You don't have the permissions needed to join the chat
     k_EChatRoomEnterResponseFull = 4,            // Chat room has reached its maximum size
     k_EChatRoomEnterResponseError = 5,           // Unexpected Error
     k_EChatRoomEnterResponseBanned = 6);         // You are banned from this chat room and may not join);

  EChatAction =
    (k_EChatActionInviteChat = 1,
     k_EChatActionKick = 2,
     k_EChatActionBan = 3,
     k_EChatActionUnBan = 4,
     k_EChatActionStartVoiceSpeak = 5,
     k_EChatActionEndVoiceSpeak = 6,
     k_EChatActionLockChat = 7,
     k_EChatActionUnlockChat = 8,
     k_EChatActionCloseChat = 9,
     k_EChatActionSetJoinable = 10,
     k_EChatActionSetUnjoinable = 11,
     k_EChatActionSetOwner = 12,
     k_EChatActionSetInvisibleToFriends = 13,
     k_EChatActionSetVisibleToFriends = 14,
     k_EChatActionSetModerated = 15,
     k_EChatActionSetUnmoderated = 16);

  EChatActionResult =
    (k_EChatActionResultSuccess = 1,
     k_EChatActionResultError = 2,
     k_EChatActionResultNotPermitted = 3,
     k_EChatActionResultNotAllowedOnClanMember = 4,
     k_EChatActionResultNotAllowedOnBannedUser = 5,
     k_EChatActionResultNotAllowedOnChatOwner = 6,
     k_EChatActionResultNotAllowedOnSelf = 7,
     k_EChatActionResultChatDoesntExist = 8,
     k_EChatActionResultChatFull = 9,
     k_EChatActionResultVoiceSlotsFull = 10);

  //-----------------------------------------------------------------------------
  // Purpose: called after a friend has been successfully added
  //-----------------------------------------------------------------------------
  FriendAdded_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 1
    {$ENDIF}
    m_eResult: EResult;
    m_ulSteamID: CSteamID;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a user is requesting friendship
  //			the persona details of this user are guaranteed to be available locally
  //			at the point this callback occurs
  //-----------------------------------------------------------------------------
  UserRequestingFriendship_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 2
    {$ENDIF}
    m_ulSteamID: CSteamID;
   end;

   //-----------------------------------------------------------------------------
  // Purpose: called when a friends' status changes, seems to not be used anymore
  //-----------------------------------------------------------------------------
  PersonaStateChangeOld_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 3
    {$ENDIF}
    m_ulSteamID: CSteamID;
    m_ePersonaStatePrevious,
    m_nGameIDPrevious: int32;
    m_unGameServerIPPrevious: uint32;
    m_usGameServerPortPrevious: uint16;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a friends' status changes
  //-----------------------------------------------------------------------------
  PersonaStateChange_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 4
    {$ENDIF}
    m_ulSteamID: CSteamID;
    m_nChangeFlags: EPersonaChange;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: used to send a system IM from the service to a user
  //-----------------------------------------------------------------------------
  SystemIM_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 5
    {$ENDIF}
    m_ESystemIMType: ESystemIMType;                              // type of system IM
    m_rgchMsgBody: array[0..4096-1] of AnsiChar; // text associated with message (if any)   //k_cchSystemIMTextMax
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when this client has received a chat/invite/etc. message from a friend
  //-----------------------------------------------------------------------------
  FriendChatMsg_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 6
    {$ENDIF}
    m_ulReceiver,
    m_ulSender: CSteamID;
    m_eChatEntryType: uint16;
    m_bLimitedAccount: uint8;
    m_iChatID: uint32;
  end;

  FriendInvited_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 7
    {$ENDIF}
    m_eResult: EResult;
  end;

  ChatRoomInvite_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 8
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDPatron,
    m_ulSteamIDFriendChat: CSteamID;
    m_EChatRoomType: EChatRoomType;
    m_rgchChatRoomName: array[0..127] of AnsiChar;
  end;

  ChatRoomEnter_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 9
    {$ENDIF}
    m_ulSteamIDChat: CSteamID;
    m_EChatRoomType: EChatRoomType;
    m_ulSteamIDOwner,
    m_ulSteamIDClan,
    m_ulSteamIDFriendChat: CSteamID;
    m_bLocked: boolean;
    m_rgfChatPermissions: uint8;
    m_EChatRoomEnterResponse: EChatRoomEnterResponse;
    m_rgchChatRoomName: array[0..127] of AnsiChar;
  end;

  // 82 FF 0A 00 00 00 88 01 | 0A D7 44 01 01 00 10 01 | 02 00 00 00 | 82 FF 0A 00 | 0A D7 44 01 01 00 10 01 // leaving
  // 82 FF 0A 00 00 00 88 01 | 0A D7 44 01 01 00 10 01 | 01 00 00 00 | 40 DD B4 05 | 0A D7 44 01 01 00 10 01 // joining
  // 82 FF 0A 00 00 00 88 01 | 0A D7 44 01 01 00 10 01 | 08 00 00 00 | 82 FF 0A 00 | 22 23 E2 03 01 00 10 01 // kicking
  ChatMemberStateChange_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 10
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDUserChanged: CSteamID;
    m_rgfChatMemberStateChange: EChatMemberStateChange;
    m_ulSteamIDMakingChange: CSteamID;
  end;

  // 05 F4 25 33 EA 03 80 01 | AC 15 89 00 01 00 10 01 | 01 E2 EB 06 | 04 00 00 00
  // 05 F4 25 33 EA 03 80 01 | AC 15 89 00 01 00 10 01 | 01 E2 EB 06 | 20 00 00 00
  // 05 F4 25 33 EA 03 80 01 | 4F 70 A4 01 01 00 10 01 | 01 00 00 00 | 21 00 00 00
  ChatRoomMsg_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 11
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDUser: CSteamID;
    m_eChatEntryType: uint8;
    m_iChatID: uint32;
  end;

  ChatRoomDlgClose_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 12
    {$ENDIF}
    m_SteamID: CSteamID;
  end;

  ChatRoomClosing_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 13
    {$ENDIF}
    m_ulSteamIDChat: CSteamID;
  end;

  ChatRoomKicking_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 14
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDAdmin: CSteamID;
  end;

  ChatRoomBanning_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 15
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDAdmin: CSteamID;
  end;

  ChatRoomCreate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 16
    {$ENDIF}
    m_eResult: EResult;
    m_ulSteamIDChat,
    m_ulSteamIDFriendChat: CSteamID;
  end;

  ChatRoomMetadataUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 17
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDMember: CSteamID;
  end;

  OpenChatDialog_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 18
    {$ENDIF}
    m_ulSteamID: CSteamID;
  end;

  ChatRoomActionResult_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 19
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDUserActedOn: CSteamID;
    m_EChatAction: EChatAction;
    m_EChatActionResult: EChatActionResult;
  end;

  ChatRoomDlgSerialized_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 20
    {$ENDIF}
    m_ulSteamID: CSteamID;
  end;

  // 321 - 16 bytes
  // -------------------------------
  // 7d 74 08 00 00 00 70 01 | 00 01 00 00 e0 c6 74 04
  // 76 18 00 00 00 00 70 01 | 00 00 00 00 00 00 00 00
  // 1B BB 17 00 00 00 70 01 | 00 00 00 00 00 00 00 00
  // 82 FF 0A 00 00 00 70 01 | 00 00 00 00 00 00 00 00
  ClanInfoChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 21
    {$ENDIF}
    m_GroupID: CSteamID;
    m_bNameChanged,
    m_bAvatarChanged,
    m_bAccountInfoChanged: boolean;
  end;

  ChatMemberInfoChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 22
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDUser: CSteamID;
    m_rgfChatMemberPermissions: uint32;
  end;

  ChatRoomInfoChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 23
    {$ENDIF}
    m_ulSteamIDChat: CSteamID;
    m_rgfChatRoomDetails: uint32;
    m_ulSteamIDMakingChange: CSTeamID;
  end;

  ChatRoomSpeakChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 25
    {$ENDIF}
    m_ulSteamIDChat,
    m_ulSteamIDUser: CSteamID;
    m_bSpeaking: boolean;
  end;

  NotifyIncomingCall_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 26
    {$ENDIF}
    m_Handle: HVoiceCall;
    m_ulSteamID,
    m_ulSteamIDChat: CSteamID;
    m_bIncoming: boolean;
  end;

  NotifyHangup_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 27
    {$ENDIF}
    m_Handle: HVoiceCall;
  end;

  NotifyRequestResume_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 28
    {$ENDIF}
    m_Handle: HVoiceCall;
  end;

  // 329 - 16 bytes
  // -------------------------------
  // 82 FF 0A 00 00 00 88 01 | 0A D7 44 01 01 00 10 01
  NotifyChatRoomVoiceStateChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 29
    {$ENDIF}
    m_steamChatRoom,
    m_steamUser: CSteamID;
  end;

  ChatRoomDlgUIChange_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 30
    {$ENDIF}
    m_SteamIDChat: CSteamID;
    m_bShowAvatars,
    m_bBeepOnNewMsg,
    m_bShowSteamIDs,
    m_bShowTimestampOnNewMsg: boolean;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: posted when game overlay activates or deactivates
  //			the game can use this to be pause or resume single player games
  //-----------------------------------------------------------------------------
  GameOverlayActivated_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 31
    {$ENDIF}
    GameOverlayActivated_t: uint8;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the user tries to join a different game server from their friends list
  //			game client should attempt to connect to specified server when this is received
  //-----------------------------------------------------------------------------
  GameServerChangeRequested_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 32
    {$ENDIF}
    m_rgchServer,                               // server address ("127.0.0.1:27015", "tf2.valvesoftware.com")
    m_rgchPassword: array[0..63] of AnsiChar;   // server password, if any
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the user tries to join a lobby from their friends list
  //			game client should attempt to connect to specified lobby when this is received
  //-----------------------------------------------------------------------------
  GameLobbyJoinRequested_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 33
    {$ENDIF}
    m_steamIDLobby,
    m_steamIDFriend: CSteamID;
  end;

  FriendIgnored_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamFriendsCallbacks + 34
    {$ENDIF}
    m_eResult: EResult;
    m_ulSteamID,
    m_ulSteamFriendID: CSteamID;
    m_bIgnored: boolean;
  end;

implementation

end.
