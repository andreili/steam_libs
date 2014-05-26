unit SteamTypes;

interface

uses
  Windows, USE_Types;

type
  // Steam-specific types. Defined here so this header file can be included in other code bases.
  int    = integer;
  pint = ^int;
  puint = ^uint;
  ushort = word;
  int8   = ShortInt;
  uint8  = Byte;
  int16  = SmallInt;
  uint16 = Word;
  int32  = Integer;
  uint32 = Cardinal;
  puint8 = ^uint8;
  puint16 = ^uint16;
  puint32 = ^uint32;

  // Steam account types
  EAccountType =
    (k_EAccountTypeInvalid            = 0,
     k_EAccountTypeIndividual         = 1, // single user account
     k_EAccountTypeMultiseat          = 2, // multiseat (e.g. cybercafe) account
     k_EAccountTypeGameServer         = 3, // game server account
     k_EAccountTypeAnonGameServer     = 4, // anonymous game server account
     k_EAccountTypePending            = 5, // pending
     k_EAccountTypeContentServer      = 6, // content server
     k_EAccountTypeClan               = 7,
     k_EAccountTypeChat               = 8,
     k_EAccountTypeP2PSuperSeeder     = 9, // a fake steamid used by superpeers to seed content to users of Steam P2P stuff
     k_EAccountTypeAnonUser           = 10,

     // Max of 16 items in this field
     k_EAccountTypeMax);

  //-----------------------------------------------------------------------------
  // Purpose: Used in ChatInfo messages - fields specific to a chat member - must fit in a uint32
  //-----------------------------------------------------------------------------
  EChatMemberStateChange =
    // Specific to joining / leaving the chatroom
    (k_EChatMemberStateChangeEntered      = $001,    // This user has joined or is joining the chat room
     k_EChatMemberStateChangeLeft         = $002,    // This user has left or is leaving the chat room
     k_EChatMemberStateChangeDisconnected = $004,    // User disconnected without leaving the chat first
     k_EChatMemberStateChangeKicked       = $008,    // User kicked
     k_EChatMemberStateChangeBanned       = $010);   // User kicked and banned

  //-----------------------------------------------------------------------------
  // Purpose: Functions for match making services for clients to get to favorites
  //-----------------------------------------------------------------------------
  ELobbyType =
    (k_ELobbyTypeFriendsOnly  = 1,  // shows for friends or invitees, but not in lobby list
    k_ELobbyTypePublic        = 2,  // visible for friends and in lobby list
    k_ELobbyTypeInvisible     = 3); // returned by search, but not visible to other friends
	//    useful if you want a user in two lobbies, for example matching groups together
	//	  a user can be in only one regular lobby, and up to two invisible lobbies

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
    (k_EPSMsgNameOfSchool   = 0,  // Question: What is the name of your school?
     k_EPSMsgFavoriteTeam   = 1,  // Question: What is your favorite team?
     k_EPSMsgMothersName    = 2,  // Question: What is your mother's maiden name?
     k_EPSMsgNameOfPet      = 3,  // Question: What is the name of your pet?
     k_EPSMsgChildhoodHero  = 4,  // Question: Who was your childhood hero?
     k_EPSMsgCityBornIn     = 5,  // Question: What city were you born in?

     k_EPSMaxPersonalQuestion);

  // General result codes
  EResult =
    (k_EResultOK                    = 1,  // success
     k_EResultFail                  = 2,  // generic failure
     k_EResultNoConnection          = 3,  // no/failed network connection
     //k_EResultNoConnectionRetry   = 4,  // OBSOLETE - removed
     k_EResultInvalidPassword       = 5,  // password/ticket is invalid
     k_EResultLoggedInElsewhere     = 6,  // same user logged in elsewhere
     k_EResultInvalidProtocolVer    = 7,  // protocol version is incorrect
     k_EResultInvalidParam          = 8,  // a parameter is incorrect
     k_EResultFileNotFound          = 9,  // file was not found
     k_EResultBusy                  = 10, // called method busy - action not taken
     k_EResultInvalidState          = 11, // called object was in an invalid state
     k_EResultInvalidName           = 12, // name is invalid
     k_EResultInvalidEmail          = 13, // email is invalid
     k_EResultDuplicateName         = 14, // name is not unique
     k_EResultAccessDenied          = 15, // access is denied
     k_EResultTimeout               = 16, // operation timed out
     k_EResultBanned                = 17, // VAC2 banned
     k_EResultAccountNotFound       = 18, // account not found
     k_EResultInvalidSteamID        = 19, // steamID is invalid
     k_EResultServiceUnavailable    = 20, // The requested service is currently unavailable
     k_EResultNotLoggedOn           = 21, // The user is not logged on
     k_EResultPending               = 22, // Request is pending (may be in process, or waiting on third party)
     k_EResultEncryptionFailure     = 23, // Encryption or Decryption failed
     k_EResultInsufficientPrivilege = 24, // Insufficient privilege
     k_EResultLimitExceeded         = 25, // Too much of a good thing
     k_EResultRevoked               = 26, // Access has been revoked (used for revoked guest passes)
     k_EResultExpired               = 27, // License/Guest pass the user is trying to access is expired
     k_EResultAlreadyRedeemed       = 28, // Guest pass has already been redeemed by account, cannot be acked again
     k_EResultDuplicateRequest      = 29, // The request is a duplicate and the action has already occurred in the past, ignored this time
     k_EResultAlreadyOwned          = 30, // All the games in this guest pass redemption request are already owned by the user
     k_EResultIPNotFound            = 31, // IP address not found
     k_EResultPersistFailed         = 32, // failed to write change to the data store
     k_EResultLockingFailed         = 33, // failed to acquire access lock for this operation
     k_EResultLogonSessionReplaced  = 34,
     k_EResultConnectFailed         = 35,
     k_EResultHandshakeFailed       = 36,
     k_EResultIOFailure             = 37,
     k_EResultRemoteDisconnect      = 38,
     k_EResultShoppingCartNotFound  = 39, // failed to find the shopping cart requested
     k_EResultBlocked               = 40, // a user didn't allow it
     k_EResultIgnored               = 41, // target is ignoring sender
     k_EResultNoMatch               = 42, // nothing matching the request found
     k_EResultAccountDisabled       = 43,
     k_EResultServiceReadOnly       = 44, // this service is not accepting content changes right now
     k_EResultAccountNotFeatured    = 45, // account doesn't have value, so this feature isn't available
     k_EResultAdministratorOK       = 46, // allowed to take this action, but only because requester is admin
     k_EResultContentVersion        = 47, // A Version mismatch in content transmitted within the Steam protocol.
     k_EResultTryAnotherCM          = 48, // The current CM can't service the user making a request, user should try another.
     k_EResultPasswordRequiredToKickSession = 49, // You are already logged in elsewhere, this cached credential login has failed.
     k_EResultAlreadyLoggedInElsewhere      = 50, // You are already logged in elsewhere, you must wait
     k_EResultSuspended             = 51,
     k_EResultCancelled             = 52,
     k_EResultDataCorruption        = 53,
     k_EResultDiskFull              = 54,
     k_EResultRemoteCallFailed      = 55);

  // Steam universes.  Each universe is a self-contained Steam instance.
  EUniverse =
    (k_EUniverseInvalid     = 0,
     k_EUniversePublic    = 1,
     k_EUniverseBeta      = 2,
     k_EUniverseInternal  = 3,
     k_EUniverseDev       = 4,
     k_EUniverseRC        = 5,

     k_EUniverseMax);

  EServerMode =
    (eServerModeInvalid                 = 0,  // DO NOT USE
     eServerModeNoAuthentication        = 1,  // Don't authenticate user logins and don't list on the server list
     eServerModeAuthentication          = 2,  // Authenticate users, list on the server list, don't run VAC on clients that connect
     eServerModeAuthenticationAndSecure = 3); // Authenticate users, list on the server list and VAC protect clients

  eSteamError =
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
     eSteamNotifyAppDownloadingPaused         = 11);

  ESteamSeekMethod =
    (eSteamSeekMethodSet = 0,
     eSteamSeekMethodCur = 1,
     eSteamSeekMethodEnd = 2);

  ESteamBufferMethod =
    (eSteamBufferMethodFBF = 0,
     eSteamBufferMethodNBF = 1);

  //Filter elements returned by SteamFind{First,Next}
  ESteamFindFilter =
    (eSteamFindLocalOnly,  // limit search to local filesystem
     eSteamFindRemoteOnly, // limit search to remote repository
     eSteamFindAll);       // do not limit search (duplicates allowed)

  ESteamSubscriptionBillingInfoType =
    (ePaymentCardInfo       = 1,
     ePrepurchasedInfo      = 2,
     eAccountBillingInfo    = 3,
     eExternalBillingInfo   = 4,   // indirect billing via ISP etc (not supported yet)
     ePaymentCardReceipt    = 5,
     ePrepurchaseReceipt    = 6,
     eEmptyReceipt          = 7);

  ESteamPaymentCardType =
    (eVisa            = 1,
     eMaster          = 2,
     eAmericanExpress = 3,
     eDiscover        = 4,
     eDinnersClub     = 5,
     eJCB             = 6);

  ESteamAppUpdateStatsQueryType =
    (ePhysicalBytesReceivedThisSession  = 1,
     eAppReadyToLaunchStatus            = 2,
     eAppPreloadStatus                  = 3,
     eAppEntireDepot                    = 4,
     eCacheBytesPresent                 = 5);

  ESteamSubscriptionStatus =
    (eSteamSubscriptionOK                           = 0,
     eSteamSubscriptionPending                      = 1,
     eSteamSubscriptionPreorder                     = 2,
     eSteamSubscriptionPrepurchaseTransferred       = 3,
     eSteamSubscriptionPrepurchaseInvalid           = 4,
     eSteamSubscriptionPrepurchaseRejected          = 5,
     eSteamSubscriptionPrepurchaseRevoked           = 6,
     eSteamSubscriptionPaymentCardDeclined          = 7,
     eSteamSubscriptionCancelledByUser              = 8,
     eSteamSubscriptionCancelledByVendor            = 9,
     eSteamSubscriptionPaymentCardUseLimit          = 10,
     eSteamSubscriptionPaymentCardAlert             = 11,
     eSteamSubscriptionFailed                       = 12,
     eSteamSubscriptionPaymentCardAVSFailure        = 13,
     eSteamSubscriptionPaymentCardInsufficientFunds = 14,
     eSteamSubscriptionRestrictedCountry            = 15);

  ESteamServerType =
    (eSteamValveCDKeyValidationServer = 0,
     eSteamHalfLifeMasterServer       = 1,
     eSteamFriendsServer              = 2,
     eSteamCSERServer                 = 3,
     eSteamHalfLife2MasterServer      = 4,
     eSteamRDKFMasterServer           = 5,
     eMaxServerTypes                  = 6);


  CreateInterfaceFn = function(pName: pAnsiChar; pReturnCode: pint): Pointer;
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

  //-----------------------------------------------------------------------------
  // Constants used for query ports.
  //-----------------------------------------------------------------------------
  QUERY_PORT_NOT_INITIALIZED  = $FFFF;   // We haven't asked the GS for this query port's actual value yet.
  QUERY_PORT_ERROR            = $FFFE;   // We were unable to get the query port for this server.

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
const
  k_GIDNil: GID_t = $ffffffffffffffff;
  k_TxnIDNil: GID_t = $ffffffffffffffff;
  k_TxnIDUnknown: GID_t = 0;

type
  // this is baked into client messages and interfaces as an int,
  // make sure we never break this.
  PackageId_t = uint32;
const
  k_uPackageIdFreeSub: PackageId_t = $0000;
  k_uPackageIdInvalid: PackageId_t = $FFFFFFFF;
  k_uPackageIdWallet: PackageId_t = ulong(-2);
  k_uPackageIdMicroTxn: PackageId_t = ulong(-3);

type
  // this is baked into client messages and interfaces as an int,
  // make sure we never break this.
  AppId_t = uint32;
const
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

type
  ShareType_t =
    (SHARE_STOPIMMEDIATELY  = 0,
     SHARE_RATIO            = 1,
     SHARE_MANUAL           = 2);

  // this is baked into client messages and interfaces as an int,
  // make sure we never break this.  AppIds and DepotIDs also presently
  // share the same namespace, but since we'd like to change that in the future
  // I've defined it seperately here.
  DepotId_t = uint32;
const
  k_uDepotIdInvalid: DepotId_t = 0;

type
  HVoiceCall = int;
  // RTime32
  // We use this 32 bit time representing real world time.
  // It offers 1 second resolution beginning on January 1, 1970 (Unix time)
  RTime32 = uint32;

const
  k_RTime32Nil: RTime32 = 0;
  k_RTime32MinValid: RTime32 = 10;
  k_RTime32Infinite: RTime32 = 2147483647;

type
  CellID_t = uint32;
const
  k_uCellIDInvalid: CellID_t = $FFFFFFFF;

type
  // handle to a Steam API call
  SteamAPICall_t = uint64;
const
  k_uAPICallInvalid: SteamAPICall_t = 0;

type
  // handle to a communication pipe to the Steam client
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

const
  k_HAuthTicketInvalid: HAuthTicket = 0;

type
  HNewItemRequest = int;
  ItemID = int64;

  HTTPRequestHandle = uint32;

  unknown_ret = int;

  HServerQuery = int;

const
  HSERVERQUERY_INVALID: uint = $ffffffff;

  // game server flags
  k_unFavoriteFlagNone: uint32 = $00;
  k_unFavoriteFlagFavorite: uint32 = $01;  // this game favorite entry is for the favorites list
  k_unFavoriteFlagHistory: uint32 = $02;   // this game favorite entry is for the history list

type
  // handle to a socket
  SNetSocket_t = uint32;
  SNetListenSocket_t = uint32;

const
  // 32KB max size on chat messages
  k_cchFriendChatMsgMax: uint32 = 32 * 1024;

  // maximum number of characters in a user's name. Two flavors; one for UTF-8 and one for UTF-16.
  // The UTF-8 version has to be very generous to accomodate characters that get large when encoded
  // in UTF-8.
  k_cchPersonaNameMax  = 128;
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
  k_unSteamAccountIDMask = $FFFFFFFF;
  k_unSteamAccountInstanceMask = $000FFFFF;

type
  // Special flags for Chat accounts - they go in the top 8 bits
  // of the steam ID's "instance", leaving 12 for the actual instances
  EChatSteamIDInstanceFlags =
    (k_EChatAccountInstanceMask = $00000FFF,
      k_EChatInstanceFlagClan     = (k_unSteamAccountInstanceMask+1) shr 1,  // top bit
      k_EChatInstanceFlagLobby    = (k_unSteamAccountInstanceMask+1) shr 2,  // next one down, etc
      k_EChatInstanceFlagMMSLobby = (k_unSteamAccountInstanceMask+1) shr 3   // next one down, etc
      // Max of 8 flags
      );

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

const
  STEAM_INVALID_HANDLE: SteamHandle_t           = 0;
  STEAM_INVALID_CALL_HANDLE: SteamCallHandle_t  = 0;
  STEAM_INACTIVE_USERIDTICKET_VALIDATION_HANDLE: SteamUserIDTicketValidationHandle_t = nil;
  STEAM_USE_LATEST_VERSION: uint                = $FFFFFFFF;

type
  // Each Steam instance (licensed Steam Service Provider) has a unique SteamInstanceID_t.
  //
  // Each Steam instance as its own DB of users.
  // Each user in the DB has a unique SteamLocalUserID_t (a serial number, with possible
  // rare gaps in the sequence).
  SteamInstanceID_t = ushort;
  SteamLocalUserID_t = uint64;

  SteamPersonalQuestion_t = array[0..STEAM_QUESTION_MAXLEN] of AnsiChar;

  //-----------------------------------------------------------------------------
  // Purpose: Base values for callback identifiers, each callback must
  //			have a unique ID.
  //-----------------------------------------------------------------------------
  ECallbackType =
    (k_iSteamUserCallbacks            = 100,
     k_iSteamGameServerCallbacks      = 200,
     k_iSteamFriendsCallbacks         = 300,
     k_iSteamBillingCallbacks         = 400,
     k_iSteamMatchmakingCallbacks     = 500,
     k_iSteamContentServerCallbacks   = 600,
     k_iSteamUtilsCallbacks           = 700,
     k_iClientFriendsCallbacks        = 800,
     k_iClientUserCallbacks           = 900,
     k_iSteamAppsCallbacks            = 1000,
     k_iSteamUserStatsCallbacks       = 1100,
     k_iSteamNetworkingCallbacks      = 1200,
     k_iClientRemoteStorageCallbacks  = 1300,
     k_iSteamUserItemsCallbacks       = 1400,
     k_iSteamGameServerItemsCallbacks = 1500,
     k_iClientUtilsCallbacks          = 1600,
     k_iSteamGameCoordinatorCallbacks = 1700,
     k_iSteamGameServerStatsCallbacks = 1800,
     k_iSteam2AsyncCallbacks          = 1900,
     k_iSteamGameStatsCallbacks       = 2000,
     k_iClientHTTPCallbacks           = 2100);

  PSteamElemInfo = ^TSteamElemInfo;
  TSteamElemInfo = record
      IsDir: integer;          //If non-zero, element is a directory; if zero, element is a file
      SizeOrCount: uint;       //If element is a file, this contains size of file in bytes
      IsLocal: integer;        //If non-zero, reported item is a standalone element on local filesystem
      Name: array[0..(STEAM_MAX_PATH-1)] of AnsiChar; //Base element name (no path)
      LastAccessTime,          //since 1/1/1970 (like time_t) when element was last accessed
      LastModificationTime,    //Seconds since 1/1/1970 (like time_t) when element was last modified
      CreationTime: LongInt;   //Seconds since 1/1/1970 (like time_t) when element was created
    end;

  EDetailedPlatformErrorType =
    (eNoDetailedErrorAvailable,
     eStandardCerrno,
     eWin32LastError,
     eWinSockLastError,
     eDetailedPlatformErrorCount);

  pSteamError = ^TSteamError;
  TSteamError = record
      SteamError: eSteamError;
      DetailedErrorType: eDetailedPlatformErrorType;
      DetailedErrorCode: integer;
      ErrDescription: pAnsiChar;
      Desc: array[0..(STEAM_MAX_PATH-1)] of AnsiChar;
    end;

  PSteamProgress = ^TSteamProgress;
  TSteamProgress = record
      Valid: integer;
      Percent: integer;
      Progress: array[0..(STEAM_MAX_PATH-1)] of AnsiChar;
    end;

  PSteamAppStats = ^TSteamAppStats;
  TSteamAppStats  = record
      NumApps,
      MaxNameChars,
      MaxInstallDirNameChars,
      MaxVersionLabelChars,
      MaxLaunchOptions,
      MaxLaunchOptionDescChars,
      MaxLaunchOptionCmdLineChars,
      MaxNumIcons,
      MaxIconSize,
      MaxDependencies: uint;
    end;

  PSteamUpdateStats = ^TSteamUpdateStats;
  TSteamUpdateStats = record
      BytesTotal,
      BytesPresent: SteamUnsigned64_t;
    end;

  PSteamPaymentCardInfo = ^TSteamPaymentCardInfo;
  TSteamPaymentCardInfo = record
      CardNumber:      array[0..STEAM_CARD_NUMBER_SIZE] of AnsiChar;
      CardHolderName:  array[0..STEAM_CARD_HOLDERNAME_SIZE] of AnsiChar;
      CardExpYear:     array[0..STEAM_CARD_EXPYEAR_SIZE] of AnsiChar;
      CardExpMonth:    array[0..STEAM_CARD_EXPMONTH_SIZE] of AnsiChar;
      CardCVV2:        array[0..STEAM_CARD_CVV2_SIZE] of AnsiChar;
      BillingAddress1: array[0..STEAM_BILLING_ADDRESS1_SIZE] of AnsiChar;
      BillingAddress2: array[0..STEAM_BILLING_ADDRESS2_SIZE] of AnsiChar;
      BillingCity:     array[0..STEAM_BILLING_CITY_SIZE] of AnsiChar;
      BillingZip:      array[0..STEAM_BILLING_ZIP_SIZE] of AnsiChar;
      BillingState:    array[0..STEAM_BILLING_STATE_SIZE] of AnsiChar;
      BillingCountry:  array[0..STEAM_BILLING_COUNTRY_SIZE] of AnsiChar;
      BillingPhone:    array[0..STEAM_BILLING_PHONE_SIZE] of AnsiChar;
      BillingEmailAddress: array[0..STEAM_BILLING_EMAIL_SIZE] of AnsiChar;
      ExpectedCostInCents,
      ExpectedTaxInCents: int;
      ShippingName: array[0..STEAM_CARD_HOLDERNAME_SIZE] of AnsiChar;
      ShippingAddress1: array[0..STEAM_BILLING_ADDRESS1_SIZE] of AnsiChar;
      ShippingAddress2: array[0..STEAM_BILLING_ADDRESS2_SIZE] of AnsiChar;
      ShippingCity:     array[0..STEAM_BILLING_CITY_SIZE] of AnsiChar;
      ShippingZip:      array[0..STEAM_BILLING_ZIP_SIZE] of AnsiChar;
      ShippingState:    array[0..STEAM_BILLING_STATE_SIZE] of AnsiChar;
      ShippingCountry:  array[0..STEAM_BILLING_COUNTRY_SIZE] of AnsiChar;
      ShippingPhone:    array[0..STEAM_BILLING_PHONE_SIZE] of AnsiChar;
      ExpectedShippingCostInCents: uint;
    end;

  TSteamPrepurchaseInfo = record
      TypeOfProofOfPurchase: array[0..STEAM_TYPE_OF_PROOF_OF_PURCHASE_SIZE] of AnsiChar;
        //A ProofOfPurchase token is not necessarily a nul-terminated string; it may be binary data
        // (perhaps encrypted). Hence we need a length and an array of bytes.
      LengthOfBinaryProofOfPurchaseToken: uint;
      BinaryProofOfPurchaseToken: array[0..STEAM_PROOF_OF_PURCHASE_TOKEN_SIZE] of AnsiChar;
    end;

  TSteamExternalBillingInfo = record
      AccountName: array[0..STEAM_EXTERNAL_ACCOUNTNAME_SIZE] of AnsiChar;
      Password: array[0..STEAM_EXTERNAL_ACCOUNTPASSWORD_SIZE] of AnsiChar;
    end;

  PSteamSubscriptionBillingInfo = ^TSteamSubscriptionBillingInfo;
  TSteamSubscriptionBillingInfo = record
      BillingInfoType: eSteamSubscriptionBillingInfoType;
      case integer of
        0: (PaymentCardInfo: TSteamPaymentCardInfo);
        1: (PrepurchaseInfo: TSteamPrepurchaseInfo);
        2: (ExternalBillingInfo: TSteamExternalBillingInfo);
        3: (UseAccountBillingInfo: AnsiChar);
    end;

  PSteamSubscriptionStats = ^TSteamSubscriptionStats;
  TSteamSubscriptionStats = record
      NumSubscriptions,
      MaxNameChars,
      MaxApps: uint;
    end;

  EBillingType =
    (eNoCost                  = 0,
     eBillOnceOnly            = 1,
     eBillMonthly             = 2,
     eProofOfPrepurchaseOnly  = 3,
     eGuestPass               = 4,
     eHardwarePromo           = 5,
     eGift                    = 6,
     eAutoGrant               = 7,
     eNumBillingTypes         = 8);

  PSteamSubscription = ^TSteamSubscription;
  TSteamSubscription = record
      Name: pAnsiChar;
      MaxNameChars: uint;
      puAppIds: array of ulong;
      MaxAppIDs,
      ID,
      NumApps: uint;
      BillingType: EBillingType;
      CostInCents,
      NumDiscounts: uint;
      IsPreorder,
      RequiresShippingAddress: int;
      DomesticShippingCostInCents,
      InternationalShippingCostInCents: uint;
      IsCyberCafeSubscription: bool;
      GameCode: uint;
      GameCodeDesc: array[0..STEAM_MAX_PATH-1] of AnsiChar;
      IsDisabled,
      RequiresCD: bool;
      TerritoryCode: uint;
      IsSteam3Subscription: bool;
    end;

  PSteamApp = ^TSteamApp;
  TSteamApp = record
      Name: pAnsiChar;
      MaxNameChars: uint;
      LatestVersionLabel: pAnsiChar;
      MaxLatestVersionLabelChars: uint;
      CurrentVersionLabel: pAnsiChar;
      MaxCurrentVersionLabelChars: uint;
      CacheFile: pAnsiChar;
      MaxCacheFileChars: uint;
      ID ,
      LatestVersionId,
      CurrentVersionId,
      MinCacheFileSizeMB,
      MaxCacheFileSizeMB,
      NumLaunchOptions,
      NumIcons,
      NumVersions,
      NumDependencies: uint;
      UnkString: pAnsiChar;
    end;

  PSteamAppLaunchOption = ^TSteamAppLaunchOption;
  TSteamAppLaunchOption  = record
      Description: pAnsiChar;
      MaxDescChars: uint;
      CmdLine: pAnsiChar;
      MaxCmdLineChars,
      Index,
      IconIndex,
      NoDesktopShortcut,
      NoStartMenuShortcut,
      IsLongRunningUnattended: uint;
    end;

  PSteamAppVersion = ^TSteamAppVersion;
  TSteamAppVersion = record
      Label_: pAnsiChar;
      MaxLabelChars,
      VersionId: uint;
      IsNotAvailable: integer;
    end;

  TSteamSplitLocalUserID = record
      Low32bits: uint;
      High32bits: uint;
    end;

  PSteamGlobalUserID = ^TSteamGlobalUserID;
  TSteamGlobalUserID = record
      SteamInstanceID: SteamInstanceID_t;
      SteamLocalUserID: record
        case byte of
          0: (As64bits: SteamLocalUserID_t);
          1: (Split: TSteamSplitLocalUserID);
      end;
    end;

  PSteamAppDependencyInfo = ^TSteamAppDependencyInfo;
  TSteamAppDependencyInfo = record
      AppId,
      IsRequired: uint;
      MountName: array[0..(STEAM_MAX_PATH-1)] of AnsiChar;
    end;

  pSteamOfflineStatus = ^TSteamOfflineStatus;
  TSteamOfflineStatus = record
    OfflineNow,
    OfflineNextSession: int;
  end;

  TSteamPaymentCardReceiptInfo = record
      CardType: ESteamPaymentCardType;
      CardLastFourDigits: array[0..STEAM_CARD_LASTFOURDIGITS_SIZE] of AnsiChar;
      CardHolderName:  array[0..STEAM_CARD_HOLDERNAME_SIZE] of AnsiChar;
      BillingAddress1: array[0..STEAM_BILLING_ADDRESS1_SIZE] of AnsiChar;
      BillingAddress2: array[0..STEAM_BILLING_ADDRESS2_SIZE] of AnsiChar;
      BillingCity:     array[0..STEAM_BILLING_CITY_SIZE] of AnsiChar;
      BillingZip:      array[0..STEAM_BILLING_ZIP_SIZE] of AnsiChar;
      BillingState:    array[0..STEAM_BILLING_STATE_SIZE] of AnsiChar;
      BillingCountry:  array[0..STEAM_BILLING_COUNTRY_SIZE] of AnsiChar;
      CardApprovalCode:    array[0..STEAM_CARD_APPROVAL_CODE_SIZE] of AnsiChar;
      TransDate: array[0..STEAM_DATE_SIZE] of AnsiChar;
      TransTime: array[0..STEAM_DATE_SIZE] of AnsiChar;
      PriceWithoutTax,
      TaxAmount,
      ShippingCost: uint;
  end;

  TSteamPrepurchaseReceiptInfo = record
    TypeOfProofOfPurchase: array[0..STEAM_TYPE_OF_PROOF_OF_PURCHASE_SIZE] of AnsiChar;
  end;

  TSteamSubscriptionReceipt = record
    Status,
    PreviousStatus: ESteamSubscriptionStatus;
    ReceiptInfoType: ESteamSubscriptionBillingInfoType;
    ConfirmationCode: array[0..STEAM_CONFIRMATION_CODE_SIZE] of AnsiChar;
    case byte of
      0: (PaymentCardReceiptInfo: TSteamPaymentCardReceiptInfo);
      1: (PrepurchaseReceiptInfo: TSteamPrepurchaseReceiptInfo);
  end;

  TSteamSubscriptionDiscount = record
    Name: array[0..STEAM_MAX_PATH-1] of AnsiChar;
    DiscountInCents,
    NumQualifiers: uint;
  end;

  pSteamDiscountQualifier = ^TSteamDiscountQualifier;
  TSteamDiscountQualifier = record
    Name: array[0..STEAM_MAX_PATH-1] of AnsiChar;
    RequiredSubscription: uint;
    IsDisqualifier: int;
  end;

  SteamSalt = record
    uchSalt: array[0..STEAM_SALT_SIZE-1] of byte;
  end;

  SteamID_t = record
    case integer of
      0: (m_comp: record
            m_unAccountID: uint32;
            m_unAccountInstanceAndType: array[0..2] of uint8;
            m_EUniverse: EUniverse;
          end);
      1: (m_unAll64Bits: uint64);
  end;

  CSteamID = class
    //-----------------------------------------------------------------------------
    // Purpose: Constructor
    //-----------------------------------------------------------------------------
    constructor Create(); overload; virtual;
    //-----------------------------------------------------------------------------
    // Purpose: Constructor
    // Input  : AccountID   - 32-bit account ID
    //          Universe    - Universe this account belongs to
    //          AccountType - Type of account
    //-----------------------------------------------------------------------------
    constructor Create(AccountID: uint32; Universe: EUniverse; AccountType: EAccountType); overload; virtual;
    //-----------------------------------------------------------------------------
    // Purpose: Constructor
    // Input  : AccountID       - 32-bit account ID
    //          AccountInstance - instance
    //          Universe        - Universe this account belongs to
    //          AccountType     - Type of account
    //-----------------------------------------------------------------------------
    constructor Create(AccountID: uint32; AccountInstance: uint; Universe: EUniverse; AccountType: EAccountType); overload; virtual;
    //-----------------------------------------------------------------------------
    // Purpose: Constructor
    // Input  : SteamID - 64-bit representation of a Steam ID
    // Note:  Will not accept a uint32 or int32 as input, as that is a probable mistake.
    //        See the stubbed out overloads in the private: section for more info.
    //-----------------------------------------------------------------------------
    constructor Create(SteamID: uint64); overload; virtual;
    procedure Set_(AccountID: uint32; Universe: EUniverse; AccountType: EAccountType); virtual; stdcall;
    procedure InstancedSet(AccountID, Instance: uint32; Universe: EUniverse; AccountType: EAccountType); virtual; stdcall;
    procedure FullSet(Identifier: uint64; Universe: EUniverse; AccountType: EAccountType); virtual; stdcall;
    procedure SetFromUint64(SteamID: uint64); virtual; stdcall;
    ////////
    ///

  private
    m_steamid: SteamID_t;
  end;

  GameID_t = record
    case integer of
      0: (m_ulGameID: uint64);
      1: (m_gameID: record
            m_nAppID: array[0..2] of uint8;
            m_nType: uint8;
            m_nModID: uint32;
          end;);
  end;
  CGameID = uint64;{class
  private
    GameID: GameID_t;
  end;       }

  MatchMakingKeyValuePair_t = record
    m_szKey,
    m_szValue: array[0..255] of AnsiChar;
  end;

  // servernetadr_t is all the addressing info the serverbrowser needs to know about a game server,
  // namely: its IP, its connection port, and its query port.
  servernetadr_t = class
  private
    {m_usConnectionPort: uint16; // (in HOST byte order)
    m_usQueryPort: uint16;
    m_unIP: uint32;}
  end;

  gameserveritem_t = class
  public
    m_NetAdr: servernetadr_t;                       // IP/Query Port/Connection Port for this server
    m_nPing: int;                                   // current ping time in milliseconds
    m_bHadSuccessfulResponse,                       // server has responded successfully in the past
    m_bDoNotRefresh: bool;                          // server is marked as not responding and should no longer be refreshed
    m_szGameDir,                                    // current game directory
    m_szMap: array[0..31] of AnsiChar;              // current ma
    m_szGameDescription: array[0..63] of AnsiChar;  // game description
    m_nAppID: uint32;                               // Steam App ID of this server
    m_nPlayers,                                     // current number of players on the server
    m_nMaxPlayers,                                  // Maximum players that can join this server
    m_nBotPlayers: int;                             // Number of bots (i.e simulated players) on this server
    m_bPassword,                                    // true if this server needs a password to join
    m_bSecure: bool;                                // Is this server protected by VAC
    m_ulTimeLastPlayed: uint32;                     // time (in unix time) when this server was last played on (for favorite/history servers)
    m_nServerVersion: int;                          // server version as reported to Steam
  private
    //m_szServerName: array[0..63] of AnsiChar;       //  Game server name
  // For data added after SteamMatchMaking001 add it here
  public
    m_szGameTags: array[0..127] of AnsiChar;        // the tags this server exposes
    m_steamID: CSteamID;                            // steamID of the game server - invalid if it's doesn't have one (old server, or not connected to Steam)
  end;

  // friend game played informatio
  FriendGameInfo_t = record
    m_gameID: CGameID;
    m_unGameIP: uint32;
    m_usGamePort,
    m_usQueryPort: uint16;
    m_steamIDLobby: CSteamID;
  end;

  // structure that contains client callback data
  CallbackMsg_t = record
    m_hSteamUser: HSteamUser;
    m_iCallback: int;
    m_pubParam: ^uint8;
    m_cubParam: int;
  end;

var
  m_key: array[0..159] of AnsiChar =
    (#$30, #$81, #$9D, #$30, #$0D, #$06, #$09, #$2A, #$86, #$48, #$86,
     #$F7, #$0D, #$01, #$01, #$01, #$05, #$00, #$03, #$81, #$8B, #$00,
     #$30, #$81, #$87, #$02, #$81, #$81, #$00, #$C1, #$7E, #$E4, #$CC,
     #$16, #$61, #$B4, #$19, #$1F, #$6A, #$88, #$DA, #$8D, #$C9, #$5F,
     #$68, #$32, #$53, #$00, #$7F, #$F9, #$46, #$5B, #$89, #$10, #$C6,
     #$CB, #$30, #$BD, #$7B, #$95, #$D6, #$B4, #$BA, #$52, #$F1, #$77,
     #$1F, #$41, #$2E, #$10, #$13, #$F2, #$12, #$6E, #$88, #$45, #$4D,
     #$97, #$57, #$5C, #$78, #$76, #$44, #$BE, #$D2, #$EB, #$4A, #$F2,
     #$D9, #$04, #$76, #$72, #$7D, #$A2, #$12, #$B2, #$AF, #$B3, #$3E,
     #$60, #$E4, #$E1, #$17, #$13, #$78, #$CA, #$9F, #$06, #$08, #$19,
     #$76, #$EF, #$89, #$98, #$5A, #$DA, #$B3, #$03, #$E8, #$51, #$33,
     #$B2, #$34, #$28, #$A0, #$96, #$1F, #$66, #$E4, #$99, #$A2, #$86,
     #$97, #$E6, #$EF, #$E1, #$5E, #$81, #$AF, #$E8, #$38, #$02, #$CE,
     #$61, #$54, #$7A, #$C5, #$95, #$4B, #$87, #$6D, #$A2, #$46, #$DF,
     #$19, #$57, #$E9, #$02, #$01, #$11);


function IS_STEAM_ERROR(e: TSteamError): boolean;

implementation

function IS_STEAM_ERROR(e: TSteamError): boolean;
begin
  result:=(e.SteamError<>eSteamErrorNone);
end;

constructor CSteamID.Create();
begin
  inherited;
  FillChar(m_steamid, sizeof(uint64), 0);
end;

constructor CSteamID.Create(AccountID: uint32; Universe: EUniverse; AccountType: EAccountType);
begin
  inherited Create();
  Set_(AccountID, Universe, AccountType);
end;

constructor CSteamID.Create(AccountID: uint32; AccountInstance: uint; Universe: EUniverse; AccountType: EAccountType);
begin
  inherited Create();
{$IFDEF _SERVER and Assert}
  // enforce that for individual accounts, instance is always 1
  Assert(not ((AccountType=k_EAccountTypeIndividual) and (AccountInstance<>1)));
{$ENDIF}
  InstancedSet(AccountID, AccountInstance, Universe, AccountType);
end;

constructor CSteamID.Create(SteamID: uint64);
begin
  inherited Create();
  //SetFromUint64(SteamID);
end;

procedure CSteamID.Set_(AccountID: uint32; Universe: EUniverse; AccountType: EAccountType);
begin
  FillChar(m_steamid, sizeof(uint64), 0);
  m_steamid.m_comp.m_unAccountID:=AccountID;
  m_steamid.m_comp.m_EUniverse:=Universe;
  m_steamid.m_comp.m_unAccountInstanceAndType[2]:=uint8(AccountType);
  if (AccountType=k_EAccountTypeClan) then m_steamid.m_comp.m_unAccountInstanceAndType[0]:=0
    else m_steamid.m_comp.m_unAccountInstanceAndType[0]:=1;
end;

procedure CSteamID.InstancedSet(AccountID, Instance: uint32; Universe: EUniverse; AccountType: EAccountType);
begin
  FillChar(m_steamid, sizeof(uint64), 0);
  m_steamid.m_comp.m_unAccountID:=AccountID;
  Move(Instance, m_steamid.m_comp.m_unAccountInstanceAndType[0], sizeof(uint32));
  m_steamid.m_comp.m_EUniverse:=Universe;
  m_steamid.m_comp.m_unAccountInstanceAndType[2]:=(m_steamid.m_comp.m_unAccountInstanceAndType[2] and $f0) +
   uint8(AccountType);
end;

procedure CSteamID.FullSet(Identifier: uint64; Universe: EUniverse; AccountType: EAccountType);
begin
  InstancedSet(Identifier and $FFFFFFFF, (Identifier shr 32) and $FFFFFFFF, Universe, AccountType);
end;

procedure CSteamID.SetFromUint64(SteamID: uint64);
begin
  m_steamid.m_unAll64Bits:=SteamID;
end;

end.
