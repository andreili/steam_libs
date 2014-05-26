unit SteamTypes;

interface

uses
  Windows, Winsock,
    SysUtils;

type
  bool = boolean;
  float = real;
  ushort = word;
  int = integer;
  uint8 = byte;
  int8 = ShortInt;
  int16 = SmallInt;
  uint16 = word;
  int32 = integer;
  uint32 = uint;
  //int64 = int64;
  //uint64 = uint64;
  TAppID = uint32;
  errno_t = int;

  pint = ^int;
  puint8 = ^uint8;
  puint16 = ^uint16;
  puint32 = ^uint32;

  // Steam account types
  EAccountType =
    (k_EAccountTypeInvalid = 0,
     k_EAccountTypeIndividual = 1,      // single user account
     k_EAccountTypeMultiseat = 2,       // multiseat (e.g. cybercafe) account
     k_EAccountTypeGameServer = 3,      // game server account
     k_EAccountTypeAnonGameServer = 4,  // anonymous game server account
     k_EAccountTypePending = 5,         // pending
     k_EAccountTypeContentServer = 6,   // content server
     k_EAccountTypeClan = 7,
     k_EAccountTypeChat = 8,
     k_EAccountTypeP2PSuperSeeder = 9,  // a fake steamid used by superpeers to seed content to users of Steam P2P stuff
     k_EAccountTypeAnonUser = 10,

     // Max of 16 items in this field
     k_EAccountTypeMax);

  //-----------------------------------------------------------------------------
  // Purpose: Used in ChatInfo messages - fields specific to a chat member - must fit in a uint32
  //-----------------------------------------------------------------------------
  // Specific to joining / leaving the chatroom
  EChatMemberStateChange =
    (k_EChatMemberStateChangeEntered      = $0001,   // This user has joined or is joining the chat room
    k_EChatMemberStateChangeLeft          = $0002,   // This user has left or is leaving the chat room
    k_EChatMemberStateChangeDisconnected  = $0004,   // User disconnected without leaving the chat first
    k_EChatMemberStateChangeKicked        = $0008,   // User kicked
    k_EChatMemberStateChangeBanned        = $0010);  // User kicked and banned

  //-----------------------------------------------------------------------------
  // Purpose: Functions for match making services for clients to get to favorites
  //-----------------------------------------------------------------------------
  ELobbyType =
    (k_ELobbyTypeFriendsOnly = 1,   // shows for friends or invitees, but not in lobby list
     k_ELobbyTypePublic = 2,        // visible for friends and in lobby list
     k_ELobbyTypeInvisible = 3      // returned by search, but not visible to other friends
      //    useful if you want a user in two lobbies, for example matching groups together
      //    a user can be in only one regular lobby, and up to two invisible lobbies
     );

  //-----------------------------------------------------------------------------
  // Purpose: Possible positions to tell the overlay to show notifications in
  //-----------------------------------------------------------------------------
  ENotificationPosition =
    (k_EPositionTopLeft = 0,
    k_EPositionTopRight = 1,
    k_EPositionBottomLeft = 2,
    k_EPositionBottomRight = 3);

  EPersonalQuestion =
    // Never ever change these after initial release.
    (k_EPSMsgNameOfSchool = 0,     // Question: What is the name of your school?
     k_EPSMsgFavoriteTeam = 1,     // Question: What is your favorite team?
     k_EPSMsgMothersName = 2,      // Question: What is your mother's maiden name?
     k_EPSMsgNameOfPet = 3,        // Question: What is the name of your pet?
     k_EPSMsgChildhoodHero = 4,    // Question: Who was your childhood hero?
     k_EPSMsgCityBornIn = 5,       // Question: What city were you born in?

     k_EPSMaxPersonalQuestion);

  // General result codes
  EResult =
    (k_EResultOK	= 1,                         // success
     k_EResultFail = 2,                        // generic failure
     k_EResultNoConnection = 3,                // no/failed network connection
     //k_EResultNoConnectionRetry = 4,           // OBSOLETE - removed
     k_EResultInvalidPassword = 5,             // password/ticket is invalid
     k_EResultLoggedInElsewhere = 6,           // same user logged in elsewhere
     k_EResultInvalidProtocolVer = 7,          // protocol version is incorrect
     k_EResultInvalidParam = 8,                // a parameter is incorrect
     k_EResultFileNotFound = 9,                // file was not found
     k_EResultBusy = 10,                       // called method busy - action not taken
     k_EResultInvalidState = 11,               // called object was in an invalid state
     k_EResultInvalidName = 12,                // name is invalid
     k_EResultInvalidEmail = 13,               // email is invalid
     k_EResultDuplicateName = 14,              // name is not unique
     k_EResultAccessDenied = 15,               // access is denied
     k_EResultTimeout = 16,                    // operation timed out
     k_EResultBanned = 17,                     // VAC2 banned
     k_EResultAccountNotFound = 18,            // account not found
     k_EResultInvalidSteamID = 19,             // steamID is invalid
     k_EResultServiceUnavailable = 20,         // The requested service is currently unavailable
     k_EResultNotLoggedOn = 21,                // The user is not logged on
     k_EResultPending = 22,                    // Request is pending (may be in process, or waiting on third party)
     k_EResultEncryptionFailure = 23,          // Encryption or Decryption failed
     k_EResultInsufficientPrivilege = 24,      // Insufficient privilege
     k_EResultLimitExceeded = 25,              // Too much of a good thing
     k_EResultRevoked = 26,                    // Access has been revoked (used for revoked guest passes)
     k_EResultExpired = 27,                    // License/Guest pass the user is trying to access is expired
     k_EResultAlreadyRedeemed = 28,            // Guest pass has already been redeemed by account, cannot be acked again
     k_EResultDuplicateRequest = 29,           // The request is a duplicate and the action has already occurred in the past, ignored this time
     k_EResultAlreadyOwned = 30,               // All the games in this guest pass redemption request are already owned by the user
     k_EResultIPNotFound = 31,                 // IP address not found
     k_EResultPersistFailed = 32,              // failed to write change to the data store
     k_EResultLockingFailed = 33,              // failed to acquire access lock for this operation
     k_EResultLogonSessionReplaced = 34,
     k_EResultConnectFailed = 35,
     k_EResultHandshakeFailed = 36,
     k_EResultIOFailure = 37,
     k_EResultRemoteDisconnect = 38,
     k_EResultShoppingCartNotFound = 39,       // failed to find the shopping cart requested
     k_EResultBlocked = 40,                    // a user didn't allow it
     k_EResultIgnored = 41,                    // target is ignoring sender
     k_EResultNoMatch = 42,                    // nothing matching the request found
     k_EResultAccountDisabled = 43,
     k_EResultServiceReadOnly = 44,            // this service is not accepting content changes right now
     k_EResultAccountNotFeatured = 45,         // account doesn't have value, so this feature isn't available
     k_EResultAdministratorOK = 46,            // allowed to take this action, but only because requester is admin
     k_EResultContentVersion = 47,             // A Version mismatch in content transmitted within the Steam protocol.
     k_EResultTryAnotherCM = 48,               // The current CM can't service the user making a request, user should try another.
     k_EResultPasswordRequiredToKickSession = 49,  // You are already logged in elsewhere, this cached credential login has failed.
     k_EResultAlreadyLoggedInElsewhere = 50,   // You are already logged in elsewhere, you must wait
     k_EResultSuspended = 51,
     k_EResultCancelled = 52,
     k_EResultDataCorruption = 53,
     k_EResultDiskFull = 54,
     k_EResultRemoteCallFailed = 55);

  // Steam universes.  Each universe is a self-contained Steam instance.
  EUniverse =
    (k_EUniverseInvalid = 0,
     k_EUniversePublic = 1,
     k_EUniverseBeta = 2,
     k_EUniverseInternal = 3,
     k_EUniverseDev = 4,
     k_EUniverseRC = 5,
     k_EUniverseMax);

  EServerMode =
    (eServerModeInvalid = 0,                 // DO NOT USE
     eServerModeNoAuthentication = 1,        // Don't authenticate user logins and don't list on the server list
     eServerModeAuthentication = 2,          // Authenticate users, list on the server list, don't run VAC on clients that connect
     eServerModeAuthenticationAndSecure = 3  // Authenticate users, list on the server list and VAC protect clients
    );

  ESteamError =
   (eSteamErrorNone                         = 0,
    eSteamErrorUnknown                      = 1,
    eSteamErrorLibraryNotInitialized        = 2,
    eSteamErrorLibraryAlreadyInitialized    = 3,
    eSteamErrorConfig                       = 4,
    eSteamErrorContentServerConnect         = 5,
    eSteamErrorBadHandle                    = 6,
    eSteamErrorHandlesExhausted             = 7,
    eSteamErrorBadArg                       = 8,
    eSteamErrorNotFound                     = 9,
    eSteamErrorRead                         = 10,
    eSteamErrorEOF                          = 11,
    eSteamErrorSeek                         = 12,
    eSteamErrorCannotWriteNonUserConfigFile = 13,
    eSteamErrorCacheOpen                    = 14,
    eSteamErrorCacheRead                    = 15,
    eSteamErrorCacheCorrupted               = 16,
    eSteamErrorCacheWrite                   = 17,
    eSteamErrorCacheSession                 = 18,
    eSteamErrorCacheInternal                = 19,
    eSteamErrorCacheBadApp                  = 20,
    eSteamErrorCacheVersion                 = 21,
    eSteamErrorCacheBadFingerPrint          = 22,
    eSteamErrorNotFinishedProcessing        = 23,
    eSteamErrorNothingToDo                  = 24,
    eSteamErrorCorruptEncryptedUserIDTicket = 25,
    eSteamErrorSocketLibraryNotInitialized  = 26,
    eSteamErrorFailedToConnectToUserIDTicketValidationServer  = 27,
    eSteamErrorBadProtocolVersion           = 28,
    eSteamErrorReplayedUserIDTicketFromClient = 29,
    eSteamErrorReceiveResultBufferTooSmall  = 30,
    eSteamErrorSendFailed                   = 31,
    eSteamErrorReceiveFailed                = 32,
    eSteamErrorReplayedReplyFromUserIDTicketValidationServer  = 33,
    eSteamErrorBadSignatureFromUserIDTicketValidationServer   = 34,
    eSteamErrorValidationStalledSoAborted   = 35,
    eSteamErrorInvalidUserIDTicket          = 36,
    eSteamErrorClientLoginRateTooHigh       = 37,
    eSteamErrorClientWasNeverValidated      = 38,
    eSteamErrorInternalSendBufferTooSmall   = 39,
    eSteamErrorInternalReceiveBufferTooSmall = 40,
    eSteamErrorUserTicketExpired            = 41,
    eSteamErrorCDKeyAlreadyInUseOnAnotherClient = 42,
    eSteamErrorNotLoggedIn                  = 101,
    eSteamErrorAlreadyExists                = 102,
    eSteamErrorAlreadySubscribed            = 103,
    eSteamErrorNotSubscribed                = 104,
    eSteamErrorAccessDenied                 = 105,
    eSteamErrorFailedToCreateCacheFile      = 106,
    eSteamErrorCallStalledSoAborted         = 107,
    eSteamErrorEngineNotRunning             = 108,
    eSteamErrorEngineConnectionLost         = 109,
    eSteamErrorLoginFailed                  = 110,
    eSteamErrorAccountPending               = 111,
    eSteamErrorCacheWasMissingRetry         = 112,
    eSteamErrorLocalTimeIncorrect           = 113,
    eSteamErrorCacheNeedsDecryption         = 114,
    eSteamErrorAccountDisabled              = 115,
    eSteamErrorCacheNeedsRepair             = 116,
    eSteamErrorRebootRequired               = 117,
    eSteamErrorNetwork                      = 200,
    eSteamErrorOffline                      = 201);

  ESteamNotify =
    (eSteamNotifyTicketsWillExpire            = 0,
     eSteamNotifyAccountInfoChanged           = 1,
     eSteamNotifyContentDescriptionChanged    = 2,
     eSteamNotifyPleaseShutdown               = 3,
     eSteamNotifyNewContentServer             = 4,
     eSteamNotifySubscriptionStatusChanged    = 5,
     eSteamNotifyContentServerConnectionLost  = 6,
     eSteamNotifyCacheLoadingCompleted        = 7,
     eSteamNotifyCacheNeedsDecryption         = 8,
     eSteamNotifyCacheNeedsRepair             = 9,
     eSteamNotifyAppDownloading               = 10,
     eSteamNotifyAppDownloadingPaused         = 11
     );

 ESteamSeekMethod =
    (eSteamSeekMethodSet = 0,
     eSteamSeekMethodCur = 1,
     eSteamSeekMethodEnd = 2);

  ESteamBufferMethod =
    (eSteamBufferMethodFBF = 0,
     eSteamBufferMethodNBF = 1);

  ESteamFindFilter =          //Filter elements returned by SteamFind{First,Next}
    (eSteamFindLocalOnly,     //limit search to local filesystem
     eSteamFindRemoteOnly,    //limit search to remote repository
     eSteamFindAll);          //do not limit search (duplicates allowed)

  ESteamSubscriptionBillingInfoType =
    (ePaymentCardInfo     = 1,
     ePrepurchasedInfo    = 2,
     eAccountBillingInfo  = 3,
     eExternalBillingInfo = 4,      // indirect billing via ISP etc (not supported yet)
     ePaymentCardReceipt  = 5,
     ePrepurchaseReceipt  = 6,
     eEmptyReceipt        = 7);

  ESteamPaymentCardType =
    (eVisa            = 1,
     eMaster          = 2,
     eAmericanExpress = 3,
     eDiscover        = 4,
     eDinnersClub     = 5,
     eJCB = 6);

  ESteamAppUpdateStatsQueryType =
    (ePhysicalBytesReceivedThisSession = 1,
     eAppReadyToLaunchStatus = 2,
     eAppPreloadStatus = 3,
     eAppEntireDepot = 4,
     eCacheBytesPresent = 5);

  ESteamSubscriptionStatus =
    (eSteamSubscriptionOK = 0,
     eSteamSubscriptionPending = 1,
     eSteamSubscriptionPreorder = 2,
     eSteamSubscriptionPrepurchaseTransferred = 3,
     eSteamSubscriptionPrepurchaseInvalid = 4,
     eSteamSubscriptionPrepurchaseRejected = 5,
     eSteamSubscriptionPrepurchaseRevoked = 6,
     eSteamSubscriptionPaymentCardDeclined = 7,
     eSteamSubscriptionCancelledByUser = 8,
     eSteamSubscriptionCancelledByVendor = 9,
     eSteamSubscriptionPaymentCardUseLimit = 10,
     eSteamSubscriptionPaymentCardAlert = 11,
     eSteamSubscriptionFailed = 12,
     eSteamSubscriptionPaymentCardAVSFailure = 13,
     eSteamSubscriptionPaymentCardInsufficientFunds = 14,
     eSteamSubscriptionRestrictedCountry = 15);

  ESteamServerType =
    (eSteamValveCDKeyValidationServer = 0,
     eSteamHalfLifeMasterServer = 1,
     eSteamFriendsServer = 2,
     eSteamCSERServer = 3,
     eSteamHalfLife2MasterServer = 4,
     eSteamRDKFMasterServer = 5,
     eMaxServerTypes = 6);

  CreateInterfaceFn = function(pName: pAnsiChar; pReturnCode: puint): Pointer;
  FactoryFn = function(pName: pAnsiChar): Pointer;
  InstantiateInterfaceFn = function(): Pointer;

  SteamAPIWarningMessageHook_t = procedure(hpipe: int; msg: pAnsiChar);
  KeyValueIteratorCallback_t = procedure(key, value: pAnsiChar; kv: Pointer);

  SteamNotificationCallback_t = procedure(eEvent: ESteamNotify; nData: uint);

  SteamBGetCallbackFn = function(hpipe: int; pCallbackMsg: Pointer): boolean;
  SteamFreeLastCallbackFn = procedure(hpipe: int);
  SteamGetAPICallResultFn = function(hpipe: int; hSteamAPICall: uint64; pCallback: Pointer; cubCallback, iCallbackExpected: int; pbFailed: pboolean): boolean;

const
  k_cubDigestSize = 20;     // CryptoPP::SHA::DIGESTSIZE
  k_cubSaltSize = 8;

  k_cchGameExtraInfoMax = 64;

  // Max number of credit cards stored for one account
  k_nMaxNumCardsPerAccount = 1;

  // game server flags
  k_unServerFlagNone: uint32        = $00;
  k_unServerFlagActive: uint32      = $01;   // server has users playing
  k_unServerFlagSecure: uint32      = $02;   // server wants to be secure
  k_unServerFlagDedicated: uint32   = $04;   // server is dedicated
  k_unServerFlagLinux: uint32       = $08;   // linux build
  k_unServerFlagPassworded: uint32  = $10;   // password protected
  k_unServerFlagPrivate: uint32     = $20;   // server shouldn't list on master server and
                                             // won't enforce authentication of users that connect to the server.
                                             // Useful when you run a server where the clients may not
                                             // be connected to the internet but you want them to play (i.e LANs)

type
  SHADigest_t = array[0..k_cubDigestSize-1] of uint8;
  Salt_t = array[0..k_cubSaltSize-1] of uint8;

  //-----------------------------------------------------------------------------
  // GID (GlobalID) stuff
  // This is a globally unique identifier.  It's guaranteed to be unique across all
  // racks and servers for as long as a given universe persists.
  //-----------------------------------------------------------------------------
  // NOTE: for GID parsing/rendering and other utils, see gid.h
  GID_t = uint64;

  // For convenience, we define a number of types that are just new names for GIDs
  JobID_t = GID_t;    // Each Job has a unique ID
  TxnID_t = GID_t;    // Each financial transaction has a unique ID

  // this is baked into client messages and interfaces as an int,
  // make sure we never break this.
  PackageId_t = uint32;

  // this is baked into client messages and interfaces as an int,
  // make sure we never break this.
  AppId_s = ^AppId_t;
  AppId_t = uint32;

  ShareType_t =
    (SHARE_STOPIMMEDIATELY = 0,
     SHARE_RATIO = 1,
     SHARE_MANUAL = 2);

  // this is baked into client messages and interfaces as an int,
  // make sure we never break this.  AppIds and DepotIDs also presently
  // share the same namespace, but since we'd like to change that in the future
  // I've defined it seperately here.
  DepotId_t = uint32;

  HVoiceCall = int;

  // RTime32
  // We use this 32 bit time representing real world time.
  // It offers 1 second resolution beginning on January 1, 1970 (Unix time)
  RTime32 = uint32;

  CellID_t = uint32;

  // handle to a Steam API call
  SteamAPICall_t = uint64;

  // handle to a communication pipe to the Steam client
  pHSteamPipe = ^HSteamPipe;
  HSteamPipe = int32;
  // handle to single instance of a steam user
  HSteamUser = int32;
  // reference to a steam call, to filter results by
  HSteamCall = int32;

  //-----------------------------------------------------------------------------
  // Typedef for handle type you will receive when requesting server list.
  //-----------------------------------------------------------------------------
  HServerListRequest = Pointer;

  // return type of GetAuthSessionTicket
  HAuthTicket = uint32;

  HNewItemRequest = int;
  ItemID = int64;

  HTTPRequestHandle = uint32;
  HServerQuery = int;

  unknown_ret = int;

  // handle to a socket
  SNetSocket_t = uint32;
  SNetListenSocket_t = uint32;

const
  k_GIDNil: GID_t = $ffffffffffffffff;
  k_TxnIDNil: GID_t = $ffffffffffffffff;
  k_TxnIDUnknown: GID_t = 0;

  k_uPackageIdFreeSub: PackageId_t = $0000;
  k_uPackageIdInvalid: PackageId_t = $FFFFFFFF;
  k_uPackageIdWallet: PackageId_t = ulong(-2);
  k_uPackageIdMicroTxn: PackageId_t = ulong(-3);

  k_uAppIdInvalid: AppId_t = 0;
  k_nGameIDNotepad: AppId_t = 65535;
  k_nGameIDCSSTestApp: AppId_t = 65534;
  k_nGameIDDRMTestApp_Static: AppId_t = 6710;
  k_nGameIDDRMTestApp_Blob: AppId_t = 6711;
  k_nGameIDDRMTestApp_Secrets: AppId_t = 6712;
  k_nGameIDDRMTestApp_SDK: AppId_t = 6713;
  k_nGameIDWinUI: AppId_t = 7;
  k_nGameIDWinUI2: AppId_t = 8;
  k_nGameIDCS: AppId_t = 10;
  k_nGameIDTFC: AppId_t = 20;
  k_nGameIDDOD: AppId_t = 30;
  k_nGameIDDMC: AppId_t = 40;
  k_nGameIDOpFor: AppId_t = 50;
  k_nGameIDRicochet: AppId_t = 60;
  k_nGameIDHL1: AppId_t = 70;
  k_nGameIDCZero: AppId_t = 80;
  k_nGameIDCSBeta: AppId_t = 150;
  k_nGameIDBaseSourceSDK: AppId_t = 215;
  k_nGameIDHL2: AppId_t = 220;
  k_nGameIDCSS: AppId_t = 240;
  k_nDepotHL2Buka: AppId_t = 235;
  k_nGameHL1SRC: AppId_t = 280;
  k_nGameDRMTest: AppId_t = 199;
  k_nGameIDDODSRC: AppId_t = 300;
  k_nGameIDHL2DM: AppId_t = 320;
  k_nGameIDPortal: AppId_t = 400;
  k_nGameIDHL2EP2: AppId_t = 420;
  k_nGameIDTF2: AppId_t = 440;
  k_nGameIDL4D: AppId_t = 500;
  k_nGameIDL4DDemo: AppId_t = 530;
  k_nGameIDL4D2: AppId_t = 550;
  k_nGameIDRedOrchestra: AppId_t = 1200;
  k_nGameIDRedOrchestraBeta: AppId_t = 1210;
  k_nGameIDKillingFloor: AppId_t = 1250;
  k_nGameIDSin1: AppId_t = 1309;
  k_nGameIDEarth2160: AppId_t = 1900;
  k_nGameIDTheShip: AppId_t = 2400;
  k_nGameIDTheShipBeta: AppId_t = 2410;
  k_nGameIDDarkMessiahSP: AppId_t = 2100;
  k_nGameIDDarkMessiahMPBeta: AppId_t = 2110;
  k_nGameIDDarkMessiahMP: AppId_t = 2115;
  k_nGameIDDarkMessiahSPDemo: AppId_t = 2120;
  k_nGameIDDarkMessiahFix: AppId_t = 2130;
  k_nGameRaceWTCC: AppId_t = 4230;
  k_nGameIDLostPlanetOld: AppId_t = 6500;
  k_nGameIDLostPlanet: AppId_t = 6510;
  k_nGameIDNBA2K9: AppId_t = 7740;
  k_nGameIDCallofDuty4: AppId_t = 7940;
  k_nMLBFrontOfficeManager: AppId_t = 7780;
  k_nGameIDEmpireTotalWar: AppId_t = 10500;
  k_nGameCSSOnline: AppId_t = 11600;
  k_nGameIDFirstSource: AppId_t = 200;
  k_nGameIDLastSource: AppId_t = 999;
  k_nGameIDFirstGoldSource: AppId_t = 10;
  k_nGameIDLastGoldSource: AppId_t = 199;
  k_nGameIDFirstNonSource: AppId_t = 1000;
  k_nGameIDMax: AppId_t = 2147483647;
  k_nGameIDStress: AppId_t = 30020;
  k_nGameIDGCTest: AppId_t = 30100;

  k_uDepotIdInvalid: DepotId_t = 0;

  k_RTime32Nil: RTime32 = 0;
  k_RTime32MinValid: RTime32 = 10;
  k_RTime32Infinite: RTime32 = 2147483647;

  k_uCellIDInvalid: CellID_t = $FFFFFFFF;

  k_uAPICallInvalid: SteamAPICall_t = 0;

  k_HAuthTicketInvalid: HAuthTicket = 0;

  HSERVERQUERY_INVALID: int = $ffffffff;

  // game server flags
  k_unFavoriteFlagNone: uint32 = $00;
  k_unFavoriteFlagFavorite: uint32 = $01;  // this game favorite entry is for the favorites list
  k_unFavoriteFlagHistory: uint32 = $02;   // this game favorite entry is for the history list

  // 32KB max size on chat messages
  k_cchFriendChatMsgMax: uint32 = 32 * 1024;

  // maximum number of characters in a user's name. Two flavors; one for UTF-8 and one for UTF-16.
  // The UTF-8 version has to be very generous to accomodate characters that get large when encoded
  // in UTF-8.
  k_cchPersonaNameMax = 128;
  k_cwchPersonaNameMax = 32;

  // size limit on chat room or member metadata
  k_cubChatMetadataMax: uint32 = 8192;
  // upper bound of length of system IM text
  k_cchSystemIMTextMax: int = 4096;
  // size limit on stat or achievement name (UTF-8 encoded)
  k_cchStatNameMax: int = 128;
  // maximum number of bytes for a leaderboard name (UTF-8 encoded)
  k_cchLeaderboardNameMax: int = 128;
  // maximum number of details int32's storable for a single leaderboard entry
  k_cLeaderboardDetailsMax: int = 64;

type
  // handle to a single leaderboard
  SteamLeaderboard_t = uint64;
  // handle to a set of downloaded entries in a leaderboard
  SteamLeaderboardEntries_t = uint64;

  PFNLegacyKeyRegistration = procedure(pchCDKey, pchInstallPath: pAnsiChar);
  PFNLegacyKeyInstalled = function(): boolean;

const
  k_unSteamAccountIDMask: int = $FFFFFFFF;
  k_unSteamAccountInstanceMask: int = $000FFFFF;

type
  // Special flags for Chat accounts - they go in the top 8 bits
  // of the steam ID's "instance", leaving 12 for the actual instances
  EChatSteamIDInstanceFlags =
    (k_EChatAccountInstanceMask = $00000FFF,                                 // top 8 bits are flags
     k_EChatInstanceFlagClan = ($000FFFFF+1) shr 1,       // top bit
     k_EChatInstanceFlagLobby = ($000FFFFF+1) shr 2,      // next one down, etc
     k_EChatInstanceFlagMMSLobby = ($000FFFFF+1) shr 3);  // next one down, etc
     // Max of 8 flags

const
  STEAM_USING_FILESYSTEM                =$00000001;
  STEAM_USING_LOGGING                   =$00000002;
  STEAM_USING_USERID                    =$00000004;
  STEAM_USING_ACCOUNT                   =$00000008;
  STEAM_USING_ALL                       =$0000000f;
  STEAM_MAX_PATH                        =255;
  STEAM_QUESTION_MAXLEN                 =255;
  STEAM_SALT_SIZE                       =8;

  STEAM_DATE_SIZE                       =9;
  STEAM_TIME_SIZE                       =9;
  STEAM_CARD_NUMBER_SIZE                =17;
  STEAM_CONFIRMATION_CODE_SIZE          =22;
  STEAM_CARD_HOLDERNAME_SIZE            =100;
  STEAM_CARD_APPROVAL_CODE_SIZE         =100;
  STEAM_CARD_EXPYEAR_SIZE               =4;
  STEAM_CARD_LASTFOURDIGITS_SIZE        =4;
  STEAM_CARD_EXPMONTH_SIZE              =2;
  STEAM_CARD_CVV2_SIZE                  =5;
  STEAM_BILLING_ADDRESS1_SIZE           =128;
  STEAM_BILLING_ADDRESS2_SIZE           =128;
  STEAM_BILLING_CITY_SIZE               =50;
  STEAM_BILLING_ZIP_SIZE                =16;
  STEAM_BILLING_STATE_SIZE              =32;
  STEAM_BILLING_COUNTRY_SIZE            =32;
  STEAM_BILLING_PHONE_SIZE              =20;
  STEAM_BILLING_EMAIL_SIZE              =100;
  STEAM_TYPE_OF_PROOF_OF_PURCHASE_SIZE  =20;
  STEAM_PROOF_OF_PURCHASE_TOKEN_SIZE    =200;
  STEAM_EXTERNAL_ACCOUNTNAME_SIZE       =100;
  STEAM_EXTERNAL_ACCOUNTPASSWORD_SIZE   =80;

type
  SteamHandle_t = uint;
  SteamUserIDTicketValidationHandle_t = Pointer;
  SteamCallHandle_t = uint;
  SteamUnsigned64_t = uint64;

  SteamInstanceID_t = ushort;
  SteamLocalUserID_t = uint64;

  SteamPersonalQuestion_t = array[0..STEAM_QUESTION_MAXLEN] of AnsiChar;

const
  STEAM_INVALID_HANDLE: SteamHandle_t  = 0;
  STEAM_INVALID_CALL_HANDLE: SteamCallHandle_t = 0;
  STEAM_INACTIVE_USERIDTICKET_VALIDATION_HANDLE: SteamUserIDTicketValidationHandle_t = nil;
  STEAM_USE_LATEST_VERSION: uint = $FFFFFFFF;

type
  //-----------------------------------------------------------------------------
  // Purpose: Base values for callback identifiers, each callback must
  //			have a unique ID.
  //-----------------------------------------------------------------------------
  ECallbackType =
    (k_iSteamUserCallbacks = 100,
     k_iSteamGameServerCallbacks = 200,
     k_iSteamFriendsCallbacks = 300,
     k_iSteamBillingCallbacks = 400,
     k_iSteamMatchmakingCallbacks = 500,
     k_iSteamContentServerCallbacks = 600,
     k_iSteamUtilsCallbacks = 700,
     k_iClientFriendsCallbacks = 800,
     k_iClientUserCallbacks = 900,
     k_iSteamAppsCallbacks = 1000,
     k_iSteamUserStatsCallbacks = 1100,
     k_iSteamNetworkingCallbacks = 1200,
     k_iClientRemoteStorageCallbacks = 1300,
     k_iSteamUserItemsCallbacks = 1400,
     k_iSteamGameServerItemsCallbacks = 1500,
     k_iClientUtilsCallbacks = 1600,
     k_iSteamGameCoordinatorCallbacks = 1700,
     k_iSteamGameServerStatsCallbacks = 1800,
     k_iSteam2AsyncCallbacks = 1900,
     k_iSteamGameStatsCallbacks = 2000,
     k_iClientHTTPCallbacks = 2100);

  TSteamElemInfo = record
      bIsDir: integer;          //If non-zero, element is a directory; if zero, element is a file
      uSizeOrCount: uint;       //If element is a file, this contains size of file in bytes
      bIsLocal: integer;        //If non-zero, reported item is a standalone element on local filesystem
      cszName: array[0..(STEAM_MAX_PATH-1)] of AnsiChar; //Base element name (no path)
      lLastAccessTime,          //since 1/1/1970 (like time_t) when element was last accessed
      lLastModificationTime,    //Seconds since 1/1/1970 (like time_t) when element was last modified
      lCreationTime: LongInt;   //Seconds since 1/1/1970 (like time_t) when element was created
    end;

  EDetailedPlatformErrorType =
    (eNoDetailedErrorAvailable,
     eStandardCerrno,
     eWin32LastError,
     eWinSockLastError,
     eDetailedPlatformErrorCount);

  TSteamError = record
      eSteamError: eSteamError;
      eDetailedErrorType: eDetailedPlatformErrorType;
      nDetailedErrorCode: integer;
      ErrDescription: pAnsiChar;
      szDesc: array[0..(STEAM_MAX_PATH-1)] of AnsiChar;
    end;

  TSteamProgress = record
      Valid: integer;
      Percent: integer;
      Progress: array[0..(STEAM_MAX_PATH-1)] of AnsiChar;
    end;

  TSteamAppStats  = record
      NumApps,
      MaxNameChars,
      uMaxInstallDirNameChars,
      MaxVersionLabelChars,
      MaxLaunchOptions,
      MaxLaunchOptionDescChars,
      MaxLaunchOptionCmdLineChars,
      MaxNumIcons,
      MaxIconSize,
      uMaxDependencies: uint;
    end;

  TSteamUpdateStats = record
      uBytesTotal,
      uBytesPresent: SteamUnsigned64_t;
    end;

  TSteamPaymentCardInfo = record
      szCardNumber:      array[0..STEAM_CARD_NUMBER_SIZE] of AnsiChar;
      szCardHolderName:  array[0..STEAM_CARD_HOLDERNAME_SIZE] of AnsiChar;
      szCardExpYear:     array[0..STEAM_CARD_EXPYEAR_SIZE] of AnsiChar;
      szCardExpMonth:    array[0..STEAM_CARD_EXPMONTH_SIZE] of AnsiChar;
      szCardCVV2:        array[0..STEAM_CARD_CVV2_SIZE] of AnsiChar;
      szBillingAddress1: array[0..STEAM_BILLING_ADDRESS1_SIZE] of AnsiChar;
      szBillingAddress2: array[0..STEAM_BILLING_ADDRESS2_SIZE] of AnsiChar;
      szBillingCity:     array[0..STEAM_BILLING_CITY_SIZE] of AnsiChar;
      szBillingZip:      array[0..STEAM_BILLING_ZIP_SIZE] of AnsiChar;
      szBillingState:    array[0..STEAM_BILLING_STATE_SIZE] of AnsiChar;
      szBillingCountry:  array[0..STEAM_BILLING_COUNTRY_SIZE] of AnsiChar;
      szBillingPhone:    array[0..STEAM_BILLING_PHONE_SIZE] of AnsiChar;
      szBillingEmailAddress: array[0..STEAM_BILLING_EMAIL_SIZE] of AnsiChar;
      uExpectedCostInCents,
      uExpectedTaxInCents: int;
      szShippingName: array[0..STEAM_CARD_HOLDERNAME_SIZE] of AnsiChar;
      szShippingAddress1: array[0..STEAM_BILLING_ADDRESS1_SIZE] of AnsiChar;
      szShippingAddress2: array[0..STEAM_BILLING_ADDRESS2_SIZE] of AnsiChar;
      szShippingCity:     array[0..STEAM_BILLING_CITY_SIZE] of AnsiChar;
      szShippingZip:      array[0..STEAM_BILLING_ZIP_SIZE] of AnsiChar;
      szShippingState:    array[0..STEAM_BILLING_STATE_SIZE] of AnsiChar;
      szShippingCountry:  array[0..STEAM_BILLING_COUNTRY_SIZE] of AnsiChar;
      szShippingPhone:    array[0..STEAM_BILLING_PHONE_SIZE] of AnsiChar;
      uExpectedShippingCostInCents: uint;
    end;

  TSteamPrepurchaseInfo = record
      szTypeOfProofOfPurchase: array[0..STEAM_TYPE_OF_PROOF_OF_PURCHASE_SIZE] of AnsiChar;
        //A ProofOfPurchase token is not necessarily a nul-terminated string; it may be binary data
        // (perhaps encrypted). Hence we need a length and an array of bytes.
      uLengthOfBinaryProofOfPurchaseToken: uint;
      cBinaryProofOfPurchaseToken: array[0..STEAM_PROOF_OF_PURCHASE_TOKEN_SIZE] of AnsiChar;
    end;

  TSteamExternalBillingInfo = record
      szAccountName: array[0..STEAM_EXTERNAL_ACCOUNTNAME_SIZE] of AnsiChar;
      szPassword: array[0..STEAM_EXTERNAL_ACCOUNTPASSWORD_SIZE] of AnsiChar;
    end;

  TSteamSubscriptionBillingInfo = record
      eBillingInfoType: eSteamSubscriptionBillingInfoType;
      case integer of
        0: (PaymentCardInfo: TSteamPaymentCardInfo);
        1: (PrepurchaseInfo: TSteamPrepurchaseInfo);
        2: (ExternalBillingInfo: TSteamExternalBillingInfo);
        3: (bUseAccountBillingInfo: AnsiChar);
    end;

  TSteamSubscriptionStats = record
      NumSubscriptions,
      MaxNameChars,
      MaxApps: uint;
    end;

  EBillingType =
    (eNoCost = 0,
     eBillOnceOnly = 1,
     eBillMonthly =2,
     eProofOfPrepurchaseOnly = 3,
     eGuestPass = 4,
     eHardwarePromo = 5,
     eGift = 6,
     eAutoGrant = 7,
     eNumBillingTypes = 8);

  TSteamSubscription = record
      Name: pAnsiChar;
      MaxNameChars: uint;
      puAppIds: array of ulong;
      MaxAppIDs,
      ID,
      NumApps: uint;
      eBillingType: EBillingType;
      CostInCents,
      uNumDiscounts: uint;
      bIsPreorder,
      bRequiresShippingAddress: int;
      uDomesticShippingCostInCents,
      uInternationalShippingCostInCents: uint;
      bIsCyberCafeSubscription: bool;
      uGameCode: uint;
      szGameCodeDesc: array[0..STEAM_MAX_PATH-1] of AnsiChar;
      bIsDisabled,
      bRequiresCD: bool;
      uTerritoryCode: uint;
      bIsSteam3Subscription: bool;
    end;

  TSteamApp = record
      Name: pAnsiChar;
      maxNameChars: uint;
      latestVersionLabel: pAnsiChar;
      maxLatestVersionLabelChars: uint;
      currentVersionLabel: pAnsiChar;
      maxCurrentVersionLabelChars: uint;
      cacheFile: pAnsiChar;
      maxCacheFileChars: uint;
      id,
      latestVersionId,
      currentVersionId,
      minCacheFileSizeMB,
      maxCacheFileSizeMB,
      numLaunchOptions,
      numIcons,
      numVersions,
      numDependencies: uint;
      szUnkString: pAnsiChar;
    end;

  TSteamAppLaunchOption  = record
      description: pAnsiChar;
      maxDescChars: uint;
      cmdLine: pAnsiChar;
      maxCmdLineChars,
      index,
      iconIndex,
      noDesktopShortcut,
      noStartMenuShortcut,
      isLongRunningUnattended: uint;
    end;

  TSteamAppVersion = record
      szLabel: pAnsiChar;
      uMaxLabelChars,
      uVersionId: uint;
      bIsNotAvailable: integer;
    end;

  TSteamSplitLocalUserID = record
      Low32bits: uint;
      High32bits: uint;
    end;

  TSteamGlobalUserID = record
      m_SteamInstanceID: SteamInstanceID_t;
      m_SteamLocalUserID: record
        case byte of
          0: (As64bits: SteamLocalUserID_t);
          1: (Split: TSteamSplitLocalUserID);
      end;
    end;

  TSteamAppDependencyInfo = record
      AppId,
      IsRequired: uint;
      szMountName: array[0..(STEAM_MAX_PATH-1)] of AnsiChar;
    end;

  TSteamOfflineStatus = record
    eOfflineNow,
    eOfflineNextSession: int;
  end;

  TSteamPaymentCardReceiptInfo = record
      eCardType: ESteamPaymentCardType;
      szCardLastFourDigits: array[0..STEAM_CARD_LASTFOURDIGITS_SIZE] of AnsiChar;
      szCardHolderName:  array[0..STEAM_CARD_HOLDERNAME_SIZE] of AnsiChar;
      szBillingAddress1: array[0..STEAM_BILLING_ADDRESS1_SIZE] of AnsiChar;
      szBillingAddress2: array[0..STEAM_BILLING_ADDRESS2_SIZE] of AnsiChar;
      szBillingCity:     array[0..STEAM_BILLING_CITY_SIZE] of AnsiChar;
      szBillingZip:      array[0..STEAM_BILLING_ZIP_SIZE] of AnsiChar;
      szBillingState:    array[0..STEAM_BILLING_STATE_SIZE] of AnsiChar;
      szBillingCountry:  array[0..STEAM_BILLING_COUNTRY_SIZE] of AnsiChar;
      szCardApprovalCode:    array[0..STEAM_CARD_APPROVAL_CODE_SIZE] of AnsiChar;
      szTransDate: array[0..STEAM_DATE_SIZE] of AnsiChar;
      szTransTime: array[0..STEAM_DATE_SIZE] of AnsiChar;
      uPriceWithoutTax,
      uTaxAmount,
      uShippingCost: uint;
  end;

  TSteamPrepurchaseReceiptInfo = record
    szTypeOfProofOfPurchase: array[0..STEAM_TYPE_OF_PROOF_OF_PURCHASE_SIZE] of AnsiChar;
  end;

  TSteamSubscriptionReceipt = record
    eStatus,
    ePreviousStatus: ESteamSubscriptionStatus;
    eReceiptInfoType: ESteamSubscriptionBillingInfoType;
    szConfirmationCode: array[0..STEAM_CONFIRMATION_CODE_SIZE] of AnsiChar;
    case byte of
      0: (PaymentCardReceiptInfo: TSteamPaymentCardReceiptInfo);
      1: (PrepurchaseReceiptInfo: TSteamPrepurchaseReceiptInfo);
  end;

  TSteamSubscriptionDiscount = record
    szName: array[0..STEAM_MAX_PATH-1] of AnsiChar;
    uDiscountInCents,
    uNumQualifiers: uint;
  end;

  TSteamDiscountQualifier = record
    szName: array[0..STEAM_MAX_PATH-1] of AnsiChar;
    uRequiredSubscription: uint;
    bIsDisqualifier: int;
  end;

  SteamSalt = record
    uchSalt: array[0..STEAM_SALT_SIZE-1] of byte;
  end;

  CSteamID = record
    case integer of
      0: (m_unAccountID: uint32;   // unique account identifier
         m_d: array[0..2] of byte;
         m_EUniverse: EUniverse;
         //m_unAccountInstance: array[0..2] of byte; //20:m_unAccountInstance + 4:m_EAccountType
         // m_unAccountInstance: word;   // dynamic instance ID (used for multiseat type accounts only)
         // m_EAccountType: word; // type of account - can't show as EAccountType, due to signed / unsigned difference
         );
      1: (m_unAll64Bits: uint64);
  end;

  GameID_t = record
    m_nAppID: array[0..2] of byte;
    m_nType: byte;
    m_nModID: uint32;
  end;

  EGameIDType =
    (k_EGameIDTypeApp = 0,
     k_EGameIDTypeGameMod = 1,
     k_EGameIDTypeShortcut = 2,
     k_EGameIDTypeP2P = 3);

  CGameID = record
    m_ulGameID: uint64;
    m_gameID: GameID_t;
  end;

  MatchMakingKeyValuePair_s = ^MatchMakingKeyValuePair_t;
  MatchMakingKeyValuePair_t = record
    m_szKey,
    m_szValue: array[0..255] of AnsiChar;
  end;

  netadr_t = sockaddr_in;

  servernetadr_t = class
    public
      procedure Init(ip: uint; usQueryPort, usConnectionPort: uint16); overload;
      procedure Init(ipAndQueryPort: netadr_t; usQueryPort, usConnectionPort: uint16); overload;
      function GetIPAndQueryPort(): netadr_t;

      function GetQueryPort(): uint16;
      procedure SetQueryPort(usPort: uint16);

      function GetConnectionPort(): uint16;
      procedure SetConnectionPort(usPort: uint16);

      function GetIP(): uint32;
      procedure SetIP(IP: uint32);

      function GetConnectionAddressString(): pAnsiChar;
      function GetQueryAddressString(): pAnsiChar;

      function Men(netadr: servernetadr_t): boolean;
      procedure Ravno(netadr: servernetadr_t);
    private
      function ToString(unIP: uint32; usPort: uint16): pAnsiChar;
    private
      m_usConnectionPort,
      m_usQueryPort: uint16;
      m_unIP: uint32;
  end;

  gameserveritem_s = ^gameserveritem_t;
  gameserveritem_t = class
    public
      constructor Create();
      function GetName(): pAnsiChar;
      procedure SetName(Name: pAnsiChar);
    public
      m_NetAdr: servernetadr_t;                       // IP/Query Port/Connection Port for this server
      m_nPing: int;                                   // current ping time in milliseconds
      m_bHadSuccessfulResponse,                       // server has responded successfully in the past
      m_bDoNotRefresh: boolean;                       // server is marked as not responding and should no longer be refreshed
      m_szGameDir,                                    // current game directory
      m_szMap: array[0..31] of AnsiChar;              // current map
      m_szGameDescription: array[0..63] of AnsiChar;  // game description
      m_nAppID: uint32;                               // Steam App ID of this server
      m_nPlayers,                                     // current number of players on the server
      m_nMaxPlayers,                                  // Maximum players that can join this server
      m_nBotPlayers: int;                             // Number of bots (i.e simulated players) on this server
      m_bPassword,                                    // true if this server needs a password to join
      m_bSecure: boolean;                             // Is this server protected by VAC
      m_ulTimeLastPlayed: uint32;                     // time (in unix time) when this server was last played on (for favorite/history servers)
      m_nServerVersion: int;                          // server version as reported to Steam
    private
      m_szServerName: array[0..63] of AnsiChar;       //  Game server name
    public
      m_szGameTags: array[0..127] of AnsiChar;        // the tags this server exposes
      m_steamID: CSteamID;                            // steamID of the game server - invalid if it's doesn't have one (old server, or not connected to Steam)
  end;

  FriendGameInfo_t = record
    m_gameID: CGameID;
    m_unGameIP: uint32;
    m_usGamePort,
    m_usQueryPort: uint16;
    m_steamIDLobby: CSteamID;
  end;

  CallbackMsg_t = record
    m_hSteamUser: HSteamUser;
    m_iCallback: int;
    m_pubParam: puint8;
    m_cubParam: int;
  end;

  EConnectionPriority =
    (k_EConnectionPriorityLow = 0,
     k_EConnectionPriorityMedium = 1,
     k_EConnectionPriorityHigh = 2);

function StrComp_NoCase(const Str1, Str2: PAnsiChar): Integer;
function CSteamID2String(ID: CSteamID): string;

implementation

function CSteamID2String(ID: CSteamID): string;
var
  AccountType: EAccountType;
  res: string;
begin
  AccountType:=EAccountType((ID.m_d[2] and $f0) shr 4);
  case AccountType of
    k_EAccountTypeInvalid, k_EAccountTypeIndividual:
      res:='STEAM_0:'+IntToStr(int((ID.m_unAccountID mod 2)<>0))+':'+IntToStr(ID.m_unAccountID div 2);
    else res:=IntToStr(ID.m_unAll64Bits);
  end;
  result:=res;
end;

procedure servernetadr_t.Init(ip: uint; usQueryPort, usConnectionPort: uint16);
begin
  m_unIP:=ip;
  m_usQueryPort:=usQueryPort;
  m_usConnectionPort:=usConnectionPort;
end;

procedure servernetadr_t.Init(ipAndQueryPort: netadr_t; usQueryPort, usConnectionPort: uint16);
begin
  //Init(ipAndQueryPort.GetIP(), ipAndQueryPort.GetPort(), usConnectionPort);
end;

function servernetadr_t.GetIPAndQueryPort(): netadr_t;
var
  netAdr: netadr_t;
begin
  //netAdr.SetIP(m_unIP);
  //netAdr.SetPort(m_usQueryPort);
  result:=netAdr;
end;

function servernetadr_t.GetQueryPort(): uint16;
begin
  result:=m_usQueryPort;
end;

procedure servernetadr_t.SetQueryPort(usPort: uint16);
begin
  m_usQueryPort:=usPort;
end;

function servernetadr_t.GetConnectionPort(): uint16;
begin
  result:=m_usConnectionPort;
end;

procedure servernetadr_t.SetConnectionPort(usPort: uint16);
begin
  m_usConnectionPort:=usPort;
end;

function servernetadr_t.GetIP(): uint32;
begin
  result:=m_unIP;
end;

procedure servernetadr_t.SetIP(IP: uint32);
begin
  m_unIP:=IP;
end;

function servernetadr_t.GetConnectionAddressString(): pAnsiChar;
begin
  result:=ToString(m_unIP, m_usConnectionPort);
end;

function servernetadr_t.GetQueryAddressString(): pAnsiChar;
begin
  result:=ToString(m_unIP, m_usQueryPort);
end;

function servernetadr_t.Men(netadr: servernetadr_t): boolean;
begin
  result:=(m_unIP<netadr.m_unIP) or ((m_unIP=netadr.m_unIP) and (m_usQueryPort<netadr.m_usQueryPort));
end;

procedure servernetadr_t.Ravno(netadr: servernetadr_t);
begin
  m_usConnectionPort:=netadr.m_usConnectionPort;
  m_usQueryPort:=netadr.m_usQueryPort;
  m_unIP:=netadr.m_unIP;
end;

function servernetadr_t.ToString(unIP: uint32; usPort: uint16): pAnsiChar;
var
  ipByte: pByte;
begin
  ipByte:=@unIP;
  result:=pAnsiChar(IntToStr(ipByte[0])+'.'+IntToStr(ipByte[1])+'.'+IntToStr(ipByte[2])+'.'+
   IntToStr(ipByte[3])+':'+IntToStr(usPort));
end;

constructor gameserveritem_t.Create();
begin
  m_szGameDir[0]:=#0;
  m_szMap[0]:=#0;
  m_szGameDescription[0]:=#0;
  m_szServerName[0]:=#0;
  m_szGameTags[0]:=#0;
  m_bHadSuccessfulResponse:=false;
  m_bDoNotRefresh:=false;
  m_bPassword:=false;
  m_bSecure:=false;
  m_nPing:=0;
  m_nAppID:=0;
  m_nPlayers:=0;
  m_nMaxPlayers:=0;
  m_nBotPlayers:=0;
  m_ulTimeLastPlayed:=0;
  m_nServerVersion:=0;
end;

function gameserveritem_t.GetName(): pAnsiChar;
begin
  if m_szServerName[0]=#0 then result:=m_NetAdr.GetConnectionAddressString()
    else result:=m_szServerName;
end;

procedure gameserveritem_t.SetName(Name: pAnsiChar);
begin
  Move(Name[0], m_szServerName[0], length(Name));
  m_szServerName[length(Name)]:=#0;
end;

var Upper: array[ AnsiChar ] of AnsiChar;

function StrComp_NoCase(const Str1, Str2: PAnsiChar): Integer;
asm
        PUSH    ESI
        XCHG    ESI, EAX
  @@1:  MOVZX   EAX, BYTE PTR [EDX]
        INC     EDX
        MOV     CL,  BYTE PTR [EAX+Upper]
        LODSB
        SUB     CL,  BYTE PTR [EAX+Upper]
        JNZ     @@fin
        CMP     AL,  CL
        JNZ     @@1
  @@fin:MOVSX   EAX, CL
        POP     ESI
end;

var c: AnsiChar;

initialization
  for c:=Low(c) to High(c) do
    Upper[c]:=AnsiChar(AnsiUpperCase(c+' ')[1]);

end.
