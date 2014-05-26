unit UserCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  CLIENTUSER_INTERFACE_VERSION = 'CLIENTUSER_INTERFACE_VERSION001';
  CLIENTGAMESERVER_INTERFACE_VERSION = 'CLIENTGAMESERVER_INTERFACE_VERSION001';
  STEAMUSER_INTERFACE_VERSION_004 = 'SteamUser004';
  STEAMUSER_INTERFACE_VERSION_005 = 'SteamUser005';
  STEAMUSER_INTERFACE_VERSION_006 = 'SteamUser006';
  STEAMUSER_INTERFACE_VERSION_007 = 'SteamUser007';
  STEAMUSER_INTERFACE_VERSION_008 = 'SteamUser008';
  STEAMUSER_INTERFACE_VERSION_009 = 'SteamUser009';
  STEAMUSER_INTERFACE_VERSION_010 = 'SteamUser010';
  STEAMUSER_INTERFACE_VERSION_011 = 'SteamUser011';
  STEAMUSER_INTERFACE_VERSION_012 = 'SteamUser012';
  STEAMUSER_INTERFACE_VERSION_013 = 'SteamUser013';
  STEAMUSER_INTERFACE_VERSION_014 = 'SteamUser014';

type
  // Callback values for callback ValidateAuthTicketResponse_t which is a response to BeginAuthSession
  EAuthSessionResponse =
    (k_EAuthSessionResponseOK = 0,                            // Steam has verified the user is online, the ticket is valid and ticket has not been reused.
     k_EAuthSessionResponseUserNotConnectedToSteam = 1,       // The user in question is not connected to steam
     k_EAuthSessionResponseNoLicenseOrExpired = 2,            // The license has expired.
     k_EAuthSessionResponseVACBanned = 3,                     // The user is VAC banned for this game.
     k_EAuthSessionResponseLoggedInElseWhere = 4,             // The user account has logged in elsewhere and the session containing the game instance has been disconnected.
     k_EAuthSessionResponseVACCheckTimedOut = 5,              // VAC has been unable to perform anti-cheat checks on this user
     k_EAuthSessionResponseAuthTicketCanceled = 6,            // The ticket has been canceled by the issuer
     k_EAuthSessionResponseAuthTicketInvalidAlreadyUsed = 7,  // This ticket has already been used, it is not valid.
     k_EAuthSessionResponseAuthTicketInvalid = 8);            // This ticket is not from a user instance currently connected to steam.

  // results from BeginAuthSession
  EBeginAuthSessionResult =
    (k_EBeginAuthSessionResultOK = 0,               // Ticket is valid for this game and this steamID.
     k_EBeginAuthSessionResultInvalidTicket = 1,    // Ticket is not valid.
     k_EBeginAuthSessionResultDuplicateRequest = 2, // A ticket has already been submitted for this steamID
     k_EBeginAuthSessionResultInvalidVersion = 3,   // Ticket is from an incompatible interface version
     k_EBeginAuthSessionResultGameMismatch = 4,     // Ticket is not for this game
     k_EBeginAuthSessionResultExpiredTicket = 5);   // Ticket has expired

  EAppUsageEvent =
    (k_EAppUsageEventGameLaunch = 1,
     k_EAppUsageEventGameLaunchTrial = 2,
     k_EAppUsageEventMedia = 3,
     k_EAppUsageEventPreloadStart = 4,
     k_EAppUsageEventPreloadFinish = 5,
     k_EAppUsageEventMarketingMessageView = 6,	// deprecated, do not use
     k_EAppUsageEventInGameAdViewed = 7,
     k_EAppUsageEventGameLaunchFreeWeekend = 8);

  ERegistrySubTree =
    (k_ERegistrySubTreeNews = 0,
     k_ERegistrySubTreeApps = 1,
     k_ERegistrySubTreeSubscriptions = 2,
     k_ERegistrySubTreeGameServers = 3,
     k_ERegistrySubTreeFriends = 4,
     k_ERegistrySubTreeSystem = 5,
     k_ERegistrySubTreeAppOwnershipTickets = 6,
     k_ERegistrySubTreeLegacyCDKeys = 7);

  ELogonState =
    (k_ELogonStateNotLoggedOn = 0,
     k_ELogonStateLoggingOn = 1,
     k_ELogonStateLoggingOff = 2,
     k_ELogonStateLoggedOn = 3);

  // Error codes for use with the voice functions
  EVoiceResult =
    (k_EVoiceResultOK = 0,
     k_EVoiceResultNotInitialized = 1,
     k_EVoiceResultNotRecording = 2,
     k_EVoiceResultNoData = 3,
     k_EVoiceResultBufferTooSmall = 4,
     k_EVoiceResultDataCorrupted = 5);

  //-----------------------------------------------------------------------------
  // Purpose: types of VAC bans
  //-----------------------------------------------------------------------------
  EVACBan =
    (k_EVACBanGoldsrc,
     k_EVACBanSource,
     k_EVACBanDayOfDefeatSource);

  EUserHasLicenseForAppResult =
    (k_EUserHasLicenseResultHasLicense = 0,         // User has a license for specified app
     k_EUserHasLicenseResultDoesNotHaveLicense = 1, // User does not have a license for the specified app
     k_EUserHasLicenseResultNoAuth = 2);            // User has not been authenticated

  // Enum for the types of news push items you can get
  ENewsUpdateType =
    (k_EAppNews = 0,        // news about a particular app
     k_ESteamAds = 1,       // Marketing messages
     k_ESteamNews = 2,      // EJ's corner and the like
     k_ECDDBUpdate = 3,     // backend has a new CDDB for you to load
     k_EClientUpdate = 4);  // new version of the steam client is available

  ESteamUsageEvent =
    (k_ESteamUsageEventMarketingMessageView = 1,
     k_ESteamUsageEventHardwareSurvey = 2,
     k_ESteamUsageEventDownloadStarted = 3,
     k_ESteamUsageEventLocalizedAudioChange = 4);

  EClientStat =
    (k_EClientStatP2PConnectionsUDP = 0,
     k_EClientStatP2PConnectionsRelay = 1,
     k_EClientStatP2PGameConnections = 2,
     k_EClientStatP2PVoiceConnections = 3,
     k_EClientStatBytesDownloaded = 4,
     k_EClientStatMax = 5);

  ENatType =
    (eNatTypeUntested = 0,
     eNatTypeTestFailed = 1,
     eNatTypeNoUDP = 2,
     eNatTypeOpenInternet = 3,
     eNatTypeFullCone = 4,
     eNatTypeRestrictedCone = 5,
     eNatTypePortRestrictedCone = 6,
     eNatTypeUnspecified = 7,
     eNatTypeSymmetric = 8,
     eNatTypeSymmetricFirewall = 9,
     eNatTypeCount = 10);

  //-----------------------------------------------------------------------------
  // Purpose: Marketing message flags that change how a client should handle them
  //-----------------------------------------------------------------------------
  EMarketingMessageFlags =
    (k_EMarketingMessageFlagsNone = 0,
     k_EMarketingMessageFlagsHighPriority = 1 shl 0,
     k_EMarketingMessageFlagsPlatformWindows = 1 shl 1,
     k_EMarketingMessageFlagsPlatformMac = 1 shl 2,
     	//aggregate flags
     k_EMarketingMessageFlagsPlatformRestrictions =
     k_EMarketingMessageFlagsPlatformWindows or k_EMarketingMessageFlagsPlatformMac);

  CNatTraversalStat = class
    m_eResult: EResult;
    m_eLocalNatType,
    m_eRemoteNatType: ENatType;
    m_bMultiUserChat,
    m_bRelay: boolean;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a logon attempt has succeeded
  //-----------------------------------------------------------------------------
  LogonSuccess_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +1
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a connections to the Steam back-end has been established
  //			this means the Steam client now has a working connection to the Steam servers
  //			usually this will have occurred before the game has launched, and should
  //			only be seen if the user has dropped connection due to a networking issue
  //			or a Steam server update
  //-----------------------------------------------------------------------------
  SteamServersConnected_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +1
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a logon attempt has failed
  //-----------------------------------------------------------------------------
  LogonFailure_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +2
    {$ENDIF}
    m_eResult: EResult;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a connection attempt has failed
  //			this will occur periodically if the Steam client is not connected,
  //			and has failed in it's retry to establish a connection
  //-----------------------------------------------------------------------------
  SteamServerConnectFailure_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +2
    {$ENDIF}
    m_eResult: EResult;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the user logs off
  //-----------------------------------------------------------------------------
  LoggedOff_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +3
    {$ENDIF}
    m_eResult: EResult;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called if the client has lost connection to the Steam servers
  //			real-time services will be disabled until a matching SteamServersConnected_t has been posted
  //-----------------------------------------------------------------------------
  SteamServersDisconnected_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +3
    {$ENDIF}
    m_eResult: EResult;
  end;

  ClientPrimaryChatDestinationSet_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +3
    {$ENDIF}
    m_bIsPrimary,
    m_bWasPrimary: uint8;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the client is trying to retry logon after being unintentionally logged off
  //-----------------------------------------------------------------------------
  BeginLogonRetry_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +4
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the steam2 ticket has been set
  //-----------------------------------------------------------------------------
  Steam2TicketChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +6
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when app news update is recieved
  //-----------------------------------------------------------------------------
  ClientAppNewsItemUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +10
    {$ENDIF}
    m_eNewsUpdateType: ENewsUpdateType;  // one of ENewsUpdateType
    m_uNewsID,                           // unique news post ID
    m_uAppID: uint32;                    // app ID this update applies to if it is of type k_EAppNews
  end;

  //-----------------------------------------------------------------------------
  // Purpose: steam news update
  //-----------------------------------------------------------------------------
  ClientSteamNewsItemUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +12
    {$ENDIF}
    m_eNewsUpdateType: ENewsUpdateType;
    m_uNewsID,                 // unique news post ID
    m_uHaveSubID,              // conditions to control if we display this update for type k_ESteamNews
    m_uNotHaveSubID,
    m_uHaveAppID,
    m_uNotHaveAppID,
    m_uHaveAppIDInstalled,
    m_uHavePlayedAppID: uint32;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Sent by the Steam server to the client telling it to disconnect from the specified game server,
  //			which it may be in the process of or already connected to.
  //			The game client should immediately disconnect upon receiving this message.
  //			This can usually occur if the user doesn't have rights to play on the game server.
  //-----------------------------------------------------------------------------
  ClientGameServerDeny_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +13
    {$ENDIF}
    m_uAppID: AppId_t;
    m_unGameServerIP: uint32;
    m_usGameServerPort,
    m_bSecure: uint16;
    m_uReason: uint32;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: notifies the user that they are now the primary access point for chat messages
  //-----------------------------------------------------------------------------
  PrimaryChatDestinationSet_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +14
    {$ENDIF}
    m_bIsPrimary: uint8;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: connect to game server denied
  //-----------------------------------------------------------------------------
  UserPolicyResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +15
    {$ENDIF}
    m_bSecure: uint8;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: steam cddb/bootstrapper update
  //-----------------------------------------------------------------------------
  ClientSteamNewsClientUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +16
    {$ENDIF}
    m_eNewsUpdateType,                 // one of ENewsUpdateType
    m_bReloadCDDB: uint8;              // if true there is a new CDDB available
    m_unCurrentBootstrapperVersion,
    m_unCurrentClientVersion: uint32;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the callback system for this client is in an error state (and has flushed pending callbacks)
  //			When getting this message the client should disconnect from Steam, reset any stored Steam state and reconnect
  //-----------------------------------------------------------------------------
  CallbackPipeFailure_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +17
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when the callback system for this client is in an error state (and has flushed pending callbacks)
  //			When getting this message the client should disconnect from Steam, reset any stored Steam state and reconnect.
  //			This usually occurs in the rare event the Steam client has some kind of fatal error.
  //-----------------------------------------------------------------------------
  EFailureType =
    (k_EFailureFlushedCallbackQueue,
     k_EFailurePipeFail);
  IPCFailure_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +17
    {$ENDIF}
    m_eFailureType: EFailureType;
  end;

  LegacyCDKeyRegistered_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +18
    {$ENDIF}
    m_eResult: EResult;
    m_iAppID: AppId_t;
    m_rgchCDKey: array[0..63] of AnsiChar;
  end;

  AccountInformationUpdated_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +19
    {$ENDIF}
  end;

  GuestPassSent_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +20
    {$ENDIF}
    m_eResult: EResult;
  end;

  GuestPassAcked_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +21
    {$ENDIF}
    m_eResult: EResult;
    m_unPackageID: PackageId_t;
    m_gidGuestPassID: GID_t;
    m_ulGuestPassKey: uint64;
  end;

  GuestPassRedeemed_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +22
    {$ENDIF}
    m_eResult: EResult;
    m_unPackageID: uint32;
  end;

  UpdateGuestPasses_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +23
    {$ENDIF}
    m_eResult: EResult;
    m_cGuestPassesToGive,
    m_cGuestPassesToRedeem: uint32;
  end;

  LogOnCredentialsChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +24
    {$ENDIF}
  end;

  LicensesUpdated_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +25
    {$ENDIF}
  end;

  CheckPasswordResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +26
    {$ENDIF}
    m_EResult: EResult;
  end;

  ResetPasswordResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +27
    {$ENDIF}
    m_EResult: EResult;
  end;

  AppLifetimeNotice_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +30
    {$ENDIF}
    m_nAppID: AppId_t;
    m_nInstanceID: int;
    m_bExiting: boolean;
  end;

  AppOwnershipTicketReceived_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +31
    {$ENDIF}
    m_nAppID: AppId_t;
  end;

  PasswordChangeResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +32
    {$ENDIF}
    m_EResult: EResult;
  end;

  EmailChangeResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +33
    {$ENDIF}
    m_EResult: EResult;
  end;

  SecretQAChangeResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +34
    {$ENDIF}
    m_EResult: EResult;
  end;

  CreateAccountResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +35
    {$ENDIF}
    m_EResult: EResult;
  end;

  SendForgottonPasswordEmailResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +37
    {$ENDIF}
    m_EResult: EResult;
  end;

  ResetForgottonPasswordResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +38
    {$ENDIF}
    m_EResult: EResult;
  end;

  DownloadFromDFSResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +40
    {$ENDIF}
    m_EResult: EResult;
    m_rgchURL: array[0..127] of AnsiChar;
  end;

  DRMSDKFileTransferResult_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +41
    {$ENDIF}
    m_EResult: EResult;
  end;

  ClientMarketingMessageUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +42
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // callback for BeginAuthSession
  //-----------------------------------------------------------------------------
  ValidateAuthTicketResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +43
    {$ENDIF}
    m_SteamID: CSteamID;
    m_eAuthSessionResponse: EAuthSessionResponse;
  end;

  MsgWebAuthToken_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +48
    {$ENDIF}
    m_bValid: boolean;
    m_Token: array[0..511] of AnsiChar;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a user has responded to a microtransaction authorization request
  //-----------------------------------------------------------------------------
  MicroTxnAuthorizationResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserCallbacks +52
    {$ENDIF}
    m_unAppID: uint32;      // AppID for this microtransaction
    m_ulOrderID: uint64;    // OrderID provided for the microtransaction
    m_bAuthorized: uint8;   // if user authorized transaction
  end;


implementation

end.

