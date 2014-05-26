unit IClientUser_;

interface

uses
  SteamTypes, UserCommon, ContentServerCommon;

type
  IClientUser = class
    function GetHSteamUser(): HSteamUser; virtual; abstract;

    procedure LogOn(unk1: uint8; steamID: CSteamID); virtual; abstract;
    procedure LogOnWithPassword(pchLogin, pchPassword: pAnsiChar); virtual; abstract;
    procedure LogOnAndCreateNewSteamAccountIfNeeded(unk: uint8); virtual; abstract;
    procedure LogOff(); virtual; abstract;
    function LoggedOn(): boolean; virtual; abstract;
    function GetLogonState(): ELogonState; virtual; abstract;
    function Connected(): boolean; virtual; abstract;
    function GetSteamID(): CSteamID; virtual; abstract;

    function IsVACBanned(nGameID: AppId_t): boolean; virtual; abstract;
    function RequireShowVACBannedMessage(nAppID: AppId_t): boolean; virtual; abstract;
    procedure AcknowledgeVACBanning(nAppID: AppId_t); virtual; abstract;

    procedure SetSteam2Ticket(pubTicket: puint8; cubTicket: int); virtual; abstract;

    function SetEmail(pchEmail: pAnsiChar): boolean; virtual; abstract;

    function SetConfigString(eRegistrySubTree: ERegistrySubTree; pchKey, pchValue: pAnsiChar): boolean; virtual; abstract;
    function GetConfigString(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; var pchValue: pAnsiChar; cbValue: int): boolean; virtual; abstract;
    function SetConfigInt(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; iValue: int): boolean; virtual; abstract;
    function GetConfigInt(eRegistrySubTree: ERegistrySubTree; pchKey: pAnsiChar; var pValue: int): boolean; virtual; abstract;

    function GetConfigStoreKeyName(eRegistrySubTree: ERegistrySubTree; pchKey, pchStoreName: pAnsiChar; cbStoreName: int): boolean; virtual; abstract;

    function InitiateGameConnection(pOutputBlob: Pointer; cbBlobMax: int; steamIDGS: CSteamID; gameID: CGameID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean; virtual; abstract;
    function InitiateGameConnectionOld(pOutputBlob: Pointer; cbBlobMax: int; steamIDGS: CSteamID; gameID: CGameID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean; pvSteam2GetEncryptionKey: Pointer; cbSteam2GetEncryptionKey: int): boolean; virtual; abstract;

    procedure TerminateGameConnection(unIPServer: uint32; usPortServer: uint16); virtual; abstract;

    procedure SetSelfAsPrimaryChatDestination(); virtual; abstract;
    function IsPrimaryChatDestination(): boolean;  virtual; abstract;

    procedure RequestLegacyCDKey(iAppID: AppId_t); virtual; abstract;

    function SendGuestPassByEmail(pchEmailAccount: pAnsiChar; gidGuestPassID: GID_t; bResending: boolean): boolean; virtual; abstract;
    function SendGuestPassByAccountID(uAccountID: uint32; gidGuestPassID: GID_t; bResending: boolean): boolean; virtual; abstract;

    function AckGuestPass(pchGuestPassCode: pAnsiChar): boolean; virtual; abstract;
    function RedeemGuestPass(pchGuestPassCode: pAnsiChar): boolean; virtual; abstract;

    function GetGuestPassToGiveCount(): uint32; virtual; abstract;
    function GetGuestPassToRedeemCount(): uint32; virtual; abstract;
    function GetGuestPassLastUpdateTime(): uint32; virtual; abstract;

    function GetGuestPassToGiveInfo(nPassIndex: uint32; var pgidGuestPassID: GID_t; var pnPackageID: PackageId_t;
     var pRTime32Created, pRTime32Expiration, pRTime32Sent, pRTime32Redeemed: RTime32; pchRecipientAddress: pAnsiChar;
     cRecipientAddressSize: int): boolean; virtual; abstract;
    function GetGuestPassToRedeemInfo(nPassIndex: uint32; var pgidGuestPassID: GID_t; var pnPackageID: PackageId_t;
     var pRTime32Created, pRTime32Expiration, pRTime32Sent, pRTime32Redeemed: RTime32): boolean; virtual; abstract;
    function GetGuestPassToRedeemSenderAddress(nPassIndex: uint32; pchSenderAddress: pAnsiChar; cSenderAddressSize: int): boolean; virtual; abstract;
    function GetGuestPassToRedeemSenderName(nPassIndex: uint32; pchSenderName: pAnsiChar; cSenderNameSize: int): boolean; virtual; abstract;

    function RequestGuestPassTargetList(gidGuestPassID: GID_t): boolean; virtual; abstract;

    function RequestGiftTargetList(nPackageID: PackageId_t): boolean; virtual; abstract;

    procedure AcknowledgeMessageByGID(pchMessageGID: pAnsiChar); virtual; abstract;

    function SetLanguage(pchLanguage: pAnsiChar): boolean; virtual; abstract;

    procedure TrackAppUsageEvent(gameID: CGameID; eAppUsageEvent: int; pchExtraInfo: pAnsiChar); virtual; abstract;

    function RaiseConnectionPriority(eConnectionPriority: EConnectionPriority): int; virtual; abstract;
    procedure ResetConnectionPriority(hRaiseConnectionPriorityPrev: int); virtual; abstract;

    procedure SetAccountNameFromSteam2(pchAccountName: pAnsiChar); virtual; abstract;
    procedure SetPasswordFromSteam2(pchPassword: pAnsiChar); virtual; abstract;

    procedure SetAccountNameForCachedCredentialLogin(pchAccountName: pAnsiChar; bRememberPassword: boolean); virtual; abstract;
    procedure SetLoginInformation(pchAccountName, pchPassword: pAnsiChar; bRememberPassword: boolean); virtual; abstract;

    procedure SetAccountCreationTime(rtime32Time: RTime32); virtual; abstract;
    function DoesTextContainUserPassword(pchText: pAnsiChar): boolean; virtual; abstract;

    function obselete_GetCMIPAddress(): uint32; virtual; abstract;
    function obselete_GetP2PRelayIPAddress(): uint32; virtual; abstract;

    function RequestWebAuthToken(): SteamAPICall_t; virtual; abstract;
    function GetLanguage(pchLanguage: pAnsiChar; cbLanguage: int): boolean; virtual; abstract;
    procedure SetCyberCafe(bCyberCafe: boolean); virtual; abstract;

    procedure CreateAccount(pchAccountName, pchNewPassword, pchNewEmail: pAnsiChar;
     iQuestion: int; pchNewQuestion, pchNewAnswer: pAnsiChar); virtual; abstract;

    procedure CheckPassword(pchAccountName, pchPassword: pAnsiChar; bAttemptRecovery: boolean); virtual; abstract;
    procedure ResetPassword(pchAccountName, pchOldPassword, pchNewPassword, pchValidationCode, pchAnswer: pAnsiChar); virtual; abstract;

    procedure TrackNatTraversalStat(var pNatStat: CNatTraversalStat); virtual; abstract;

    procedure RefreshSteam2Login(); virtual; abstract;
    procedure RefreshSteam2LoginWithSecureOption(bIsSecure: boolean); virtual; abstract;
    function Steam2IsSecureComputer(): boolean; virtual; abstract;

    function GetPackageIDForGuestPassToRedeemByGID(gid: GID_t): PackageId_t; virtual; abstract;

    procedure TrackSteamUsageEvent(eSteamUsageEvent: ESteamUsageEvent; pubKV: puint8; cubKV: uint32); virtual; abstract;
    procedure TrackSteamGUIUsage(a1: pAnsiChar); virtual; abstract;

    procedure SetComputerInUse(); virtual; abstract;

    function IsGameRunning(gameID: CGameID): boolean; virtual; abstract;

    function GetCurrentSessionToken(): uint64; virtual; abstract;

    function UpdateAppOwnershipTicket(nAppID: AppId_t; bOnlyUpdateIfStale, unk: boolean): boolean; virtual; abstract;

    function RequestCustomBinary(pszAbsolutePath: pAnsiChar; nAppID: AppId_t;
     bForceUpdate, bAppLaunchRequest: boolean): boolean; virtual; abstract;
    function GetCustomBinariesState(unAppID: AppId_t; var punProgress: uint32): boolean; virtual; abstract;

    procedure SetCellID(cellID: CellID_t); virtual; abstract;

    function GetUserBaseFolder(): pAnsiChar; virtual; abstract;

    function GetUserDataFolder(gameID: CGameID; pchBuffer: pAnsiChar; cubBuffer: int): boolean; virtual; abstract;
    function GetUserConfigFolder(pchBuffer: pAnsiChar; cubBuffer: int): boolean; virtual; abstract;

    function GetAccountName(pchAccountName: pAnsiChar; cb: uint32): boolean; virtual; abstract;

    procedure RequiresLegacyCDKey(a1: uint32); virtual; abstract;
    function GetLegacyCDKey(nAppID: AppId_t; pchKeyData: pAnsiChar; cbKeyData: int): boolean; virtual; abstract;
    function HasLegacyCDKey(nAppID: AppId_t): boolean; virtual; abstract;
    procedure RemoveLegacyCDKey(nAppID: AppId_t); virtual; abstract;

    procedure StartVoiceRecording(); virtual; abstract;
    procedure StopVoiceRecording(); virtual; abstract;
    procedure ResetVoiceRecording(); virtual; abstract;

    function GetAvailableVoice(var pcbCompressed, pcbRaw: uint32): EVoiceResult; virtual; abstract;
    function GetVoice(bWantCompressed: boolean; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32; bWantRaw: boolean; pRawDestBuffer: Pointer;
     cbRawDestBufferSize: uint32; var nRawBytesWritten: uint32): EVoiceResult; virtual; abstract;

    function GetCompressedVoice(pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32): EVoiceResult; virtual; abstract;
    function DecompressVoice(pCompressed: Pointer; cbCompressed: uint32; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32): EVoiceResult; virtual; abstract;

    function IsAnyGameRunning(): boolean; virtual; abstract;

    procedure ChangePassword(pchOldPassword, pchNewPassword: pAnsiChar); virtual; abstract;
    procedure ChangeEmail(pchOldEmail, pchNewEmail: pAnsiChar); virtual; abstract;
    procedure ChangeSecretQuestionAndAnswer(a1: pAnsiChar; iQuestion: int; pchNewQuestion,
     pchNewAnswer: pAnsiChar); virtual; abstract;

    procedure SetSteam2FullASTicket(pubTicket: puint8; cubTicket: int); virtual; abstract;

    function GetEmail(pchEmail: pAnsiChar; cchEmail: int): boolean; virtual; abstract;

    procedure RequestForgottenPasswordEmail(pchAccountName, pchTriedPassword: pAnsiChar); virtual; abstract;

    procedure Test_FakeConnectionTimeout(); virtual; abstract;

    function RunInstallScript(pAppIDs: AppId_s; cAppIDs: int; pchInstallPath, pchLanguage: pAnsiChar;
     bUninstall: boolean): boolean; virtual; abstract;

    function IsInstallScriptRunning(): AppId_t; virtual; abstract;

    function GetInstallScriptString(nAppID: AppId_t; pchInstallPath, pchLanguage, pchKeyname,
     pchKeyvalue, pchValue: pAnsiChar; cchValue: int): boolean; virtual; abstract;
    function GetInstallScriptState(pchDescription: pAnsiChar; cchDescription: uint32;
     var punNumSteps, punCurrStep: uint32): boolean; virtual; abstract;

    function SpawnProcess(lpVACBlob: Pointer; cbBlobSize: uint32; lpApplicationName, lpCommandLine: pAnsiChar;
     dwCreationFlags: uint32; lpCurrentDirectory: pAnsiChar; nAppID: AppId_t; pchGameName: pAnsiChar;
     bAlwaysUseShellExec: boolean): boolean; virtual; abstract;

    function GetAppOwnershipTicketLength(nAppID: uint32): uint32; virtual; abstract;
    function GetAppOwnershipTicketData(nAppID: uint32; pvBuffer: Pointer; cbBufferLength: uint32): uint32; virtual; abstract;

    function GetAppOwnershipTicketExtendedData(nAppID: uint32; pvBuffer: Pointer; cbBufferLength: uint32;
     var a1,a2, a3, a4: unknown_ret): uint32; virtual; abstract;

    function GetAppDecryptionKey(nAppID: uint32; pvBuffer: Pointer; cbBufferLength: uint32): boolean; virtual; abstract;

    function GetMarketingMessageCount(): int; virtual; abstract;
    function GetMarketingMessage(cMarketingMessage: int; var gidMarketingMessageID: GID_t;
     pubMsgUrl: pAnsiChar; cubMessageUrl: int; var eMarketingMssageFlags: EMarketingMessageFlags): boolean; virtual; abstract;

    function GetAuthSessionTicket(pMyAuthTicket: Pointer; cbMaxMyAuthTicket: int;
     var pcbAuthTicket: uint32): HAuthTicket; virtual; abstract;

    function BeginAuthSession(pTheirAuthTicket: Pointer; cbTicket: int;
     steamID: CSteamID): EBeginAuthSessionResult; virtual; abstract;
    procedure EndAuthSession(steamID: CSteamID); virtual; abstract;

    procedure CancelAuthTicket(hAuthTicket: HAuthTicket); virtual; abstract;

    function IsUserSubscribedAppInTicket(steamID: CSteamID; appID: AppId_t): int; virtual; abstract;

    function AdvertiseGame(gameID: CGameID; steamIDGameServer: CSteamID;
     unIPServer: uint32; usPortServer: uint16): boolean; virtual; abstract;

    function RequestEncryptedAppTicket(): unknown_ret; virtual; abstract;
    function GetEncryptedAppTicket(): unknown_ret; virtual; abstract;

    procedure SetAccountLimited(bAccountLimited: boolean); virtual; abstract;
    function IsAccountLimited(): boolean; virtual; abstract;

    procedure SendValidationEmail(); virtual; abstract;
    function GameConnectTokensAvailable(): boolean; virtual; abstract;

    function NumGamesRunning(): int; virtual; abstract;
    function GetRunningGameID(iGame: int): CGameID; virtual; abstract;

    function GetAccountSecurityPolicyFlags(): uint32; virtual; abstract;

    procedure RequestChangeEmail(pchPassword: pAnsiChar; eRequestType: int); virtual; abstract;
    procedure ChangePasswordWithCode(pchOldPassword, pchCode, pchNewPassword: pAnsiChar); virtual; abstract;
    procedure ChangeEmailWithCode(pchPassword, pchCode, pchEmail: pAnsiChar); virtual; abstract;
    procedure ChangeSecretQuestionAndAnswerWithCode(pchPassword, pchCode,
     pchNewQuestion, pchNewAnswer: pAnsiChar); virtual; abstract;

    procedure SetClientStat(eStat: EClientStat; llValue: int64; nAppID: AppId_t;
     nDepotID: DepotId_t; nCellID: CellID_t); virtual; abstract;

    procedure VerifyPassword(pchPassword: pAnsiChar); virtual; abstract;

    function SupportUser(): boolean; virtual; abstract;

    function IsAppOverlayEnabled(a1: uint32): boolean; virtual; abstract;

    function IsBehindNAT(): boolean; virtual; abstract;

    function GetMicroTxnAppID(a1: uint64): AppId_t; virtual; abstract;
    function GetMicroTxnOrderID(a1: uint64): unknown_ret; virtual; abstract;

    //virtual bool BGetMicroTxnPrice( uint64, CAmount *, CAmount *, bool * ) = 0;
    function BGetMicroTxnPrice(a1: uint64; var a2, a3: int; var a4: boolean): boolean; virtual; abstract;

    function GetMicroTxnLineItemCount(a1: uint64): unknown_ret; virtual; abstract;

    //virtual bool BGetMicroTxnLineItem( uint64, uint32, CAmount *, uint32 *, char *, uint32 ) = 0;
    function BGetMicroTxnLineItem(a1: uint64; a2: uint32; var a3: int; var a4: uint32;
     a5: pAnsiChar; a6: uint32): boolean;  virtual; abstract;

    //virtual unknown_ret AuthorizeMicroTxn( uint64, EMicroTxnAuthResponse ) = 0;
    function AuthorizeMicroTxn(a1: uint64; a2: int): unknown_ret; virtual; abstract;

    function NotifyAppMicroTxnAuthResponse(a1: uint32; a2: uint64; a3: boolean): unknown_ret; virtual; abstract;

    //virtual bool BGetWalletBalance( bool *, CAmount * ) = 0;
    function BGetWalletBalance(var a1: boolean; var a2: int): boolean; virtual; abstract;

    function RequestMicroTxnInfo(a1: uint64): unknown_ret; virtual; abstract;

    function BGetAppMinutesPlayed(a1: uint32; var a2, a3: int): boolean; virtual; abstract;

    function BGetGuideURL(a1: uint32; a2: pAnsiChar; a3: uint32): boolean; virtual; abstract;

    function GetClientAppListResponse_AddApp(): unknown_ret; virtual; abstract;
    function GetClientAppListResponse_AddDLC(): unknown_ret; virtual; abstract;
    function GetClientAppListResponse_Done(): unknown_ret; virtual; abstract;
    function PostUIResultToClientJob(): unknown_ret; virtual; abstract;
    function BWriteScreenshotForGame(): unknown_ret; virtual; abstract;
    function BRecreateThumbnailForScreenshot(): unknown_ret; virtual; abstract;
  end;

implementation

end.
