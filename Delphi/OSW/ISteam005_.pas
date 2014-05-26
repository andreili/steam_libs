unit ISteam005_;

interface

{$I defines.inc}

uses
  SteamTypes;

type
  CSteamInterface005 = class (TObject)
      procedure _Destructor(); virtual; abstract;
      function ChangePassword(const cszCurrentPassphrase, cszNewPassphrase: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetCurrentEmailAddress(szEmailaddress: pAnsiChar; uBufSize: uint32; var puEmailaddressChars: uint32; var pError: TSteamError): int; virtual; abstract;
      function ChangePersonalQA(const cszCurrentPassphrase, cszNewPersonalQuestion, cszNewAnswerToQuestion: pAnsiChar; pbChanged: pInteger; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function ChangeEmailAddress(const cszNewEmailAddress: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function VerifyEmailAddress(cszEmailAddress: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function RequestEmailAddressVerificationEmail(var pError: TSteamError): int; virtual; abstract;
      function ChangeAccountName(cszCurrentAccountName, cszNewAccountName: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function MountAppFilesystem(var pError: TSteamError): int; virtual; abstract;
      function UnmountAppFilesystem(var pError: TSteamError): int; virtual; abstract;
      function MountFilesystem(uAppId: LongWord; const szMountPath: pAnsiChar; var pError: TSteamError): int; virtual; abstract;
      function UnmountFilesystem(uAppId: uint32; var pError: TSteamError): int; virtual; abstract;
      function Stat(const cszName: pAnsiChar; var pInfo: TSteamElemInfo; var pError: TSteamError): int; virtual; abstract;
      function SetvBuf(hFile: SteamHandle_t; pBuf: Pointer; eMethod: ESteamBufferMethod; uBytes: uint32; var pError: TSteamError): int; virtual; abstract;
      function FlushFile(hFile: SteamHandle_t; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function OpenFile(const cszName, cszMode: pAnsiChar; var pError: TSteamError): SteamHandle_t; virtual; abstract;
      function OpenFileEx(const szFileName, szMode: pAnsiChar; var puSize: uint32; var pError: TSteamError): SteamHandle_t; virtual; abstract;
      function OpenTmpFile(var pError: TSteamError): SteamHandle_t; virtual; abstract;
      procedure ClearError(var pError: TSteamError); virtual; abstract;
      function GetVersion(szVersion: pAnsiChar; uVersionBufSize: uint32): int; virtual; abstract;
      function GetOfflineStatus(var pSteamOfflineStatus: TSteamOfflineStatus; var pError: TSteamError): Integer; virtual; abstract;
      function ChangeOfflineStatus(var pSteamOfflineStatus: TSteamOfflineStatus; var pError: TSteamError): int; virtual; abstract;
      function ProcessCall(handle: SteamCallHandle_t; var pProgress: TSteamProgress; var pError: TSteamError): int; virtual; abstract;
      function AbortCall(handle: SteamCallHandle_t; var pError: TSteamError): int; virtual; abstract;
      function BlockingCall(handle: SteamCallHandle_t; uiProcessTickMS: uint32; var pError: TSteamError): int; virtual; abstract;
      function SetMaxStallCount(uNumStalls: uint32; var pError: TSteamError): int; virtual; abstract;
      function CloseFile(hFile: SteamHandle_t; var pError: TSteamError): int; virtual; abstract;
      function ReadFile(pBuf: Pointer; uSize, uCount: uint32; hFile: SteamHandle_t; var pError: TSteamError): uint32; virtual; abstract;
      function WriteFile(const pBuf: Pointer; uSize, uCount: LongWord; hFile: SteamHandle_t; var pError: TSteamError): uint32; virtual; abstract;
      function Getc(hFile: SteamHandle_t; var pError: TSteamError): int; virtual; abstract;
      function Putc(cChar: Integer; hFile: SteamHandle_t; var pError: TSteamError): int; virtual; abstract;
      function SeekFile(hFile: SteamHandle_t; lOffset: uint32; sm: ESteamSeekMethod; var pError: TSteamError): int; virtual; abstract;
      function TellFile(hFile: SteamHandle_t; var pError: TSteamError): LongWord; virtual; abstract;
      function SizeFile(hFile: SteamHandle_t; var pError: TSteamError): int; virtual; abstract;
      function FindFirst(const szFileName: pAnsiChar; eFilter: ESteamFindFilter; var element: TSteamElemInfo; var pError: TSteamError): SteamHandle_t; virtual; abstract;
      function FindNext(hFind: SteamHandle_t; var element: TSteamElemInfo; var pError: TSteamError): int; virtual; abstract;
      function FindClose(hFind: SteamHandle_t; var pError: TSteamError): int; virtual; abstract;
      function GetLocalFileCopy(const szFileName: pAnsiChar; var pError: TSteamError): Integer; virtual; abstract;
      function IsFileImmediatelyAvailable(const cszName: pAnsiChar; var pError: TSteamError): int; virtual; abstract;
      function HintResourceNeed(const cszMasterList: pAnsiChar; bForgetEverything: integer; var pError: TSteamError): int; virtual; abstract;
      function ForgetAllHints(var pError: TSteamError): Integer; virtual; abstract;
      function PauseCachePreloading(var pError: TSteamError): int; virtual; abstract;
      function ResumeCachePreloading(var pError: TSteamError): int; virtual; abstract;
      function WaitForResources(const cszMasterList: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function StartEngine(var pError: TSteamError): int; virtual; abstract;
      function ShutdownEngine(var pError: TSteamError): int; virtual; abstract;
      function Startup(uUsingMask: uint32; var pError: TSteamError): int; virtual; abstract;
      function Cleanup(var pError: TSteamError): int; virtual; abstract;
      function NumAppsRunning(var pError: TSteamError): int; virtual; abstract;
      function CreateAccount(const cszUser, cszPassphrase, cszCreationKey, cszPersonalQuestion, cszAnswerToQuestion, cszArg6: pAnsiChar; var pbCreated: Integer; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GenerateSuggestedAccountNames(const cszArg1, cszArg2, cszArg3: pAnsiChar; uArg4: uint32; var puArg5: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function IsLoggedIn(var pbIsLoggedIn: int; var pError: TSteamError): int; virtual; abstract;
      function Logout(var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function IsSecureComputer(var pbIsSecure: int; var pError: TSteamError): int; virtual; abstract;
      function CreateLogContext(const cszName: pAnsiChar): SteamHandle_t; virtual; abstract;
      function Log(hContext: SteamHandle_t; const cszMsg: pAnsiChar): int; virtual; abstract;
      procedure LogResourceLoadStarted(const cszMsg: pAnsiChar); virtual; abstract;
      procedure LogResourceLoadFinished(const cszMsg: pAnsiChar); virtual; abstract;
      function RefreshLogin(const cszPassphrase: pAnsiChar; bIsSecureComputer: integer; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function VerifyPassword(const cszPassword: pAnsiChar; var pbIsValid: int; var pError: TSteamError): int; virtual; abstract;
      function GetUserType(var puArg1: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetAppStats(var pAppStats: TSteamAppStats; var pError: TSteamError): int; virtual; abstract;
      function IsAccountNameInUse(cszArg1: pAnsiChar; var piArg2: int; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetAppIds(var puIds: uint32; uMaxIds: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetSubscriptionStats(var pSubscriptionStats: TSteamSubscriptionStats; var pError: TSteamError): int; virtual; abstract;
      function RefreshAccountInfo(var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function Subscribe(uSubscriptionId: uint32; var pSubscriptionBillingInfo: TSteamSubscriptionBillingInfo; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function Unsubscribe(uSubscriptionId: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetSubscriptionReceipt(uSubscriptionId: uint32; var pSteamSubscriptionReceipt: TSteamSubscriptionReceipt; var pError: TSteamError): uint32; virtual; abstract;
      function GetAccountStatus(var puArg1: uint32; var pError: TSteamError): int; virtual; abstract;
      function SetUser(const cszUser: pAnsiChar;var pbUserSet: int; var pError: TSteamError): int; virtual; abstract;
      function GetUser(szUser: pAnsiChar; uBufSize: LongWord; var puUserChars: uint32; var pSteamGlobalUserID: TSteamGlobalUserID; var pError: TSteamError): int; virtual; abstract;
      function Login(const cszUser, cszPassphrase: pAnsiChar; bIsSecureComputer: integer; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function AckSubscriptionReceipt(uArg1: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function IsAppSubscribed(uAppId: uint32; var pbIsAppSubscribed, pReserved: int; var pError: TSteamError): int; virtual; abstract;
      function GetSubscriptionIds(puIds: puint32; uMaxIds: LongWord; var pError: TSteamError): int; virtual; abstract;
      function EnumerateSubscription(uId: uint32; var pSubscription: TSteamSubscription; var pError: TSteamError): int; virtual; abstract;
      function EnumerateSubscriptionDiscount(uSubscriptionId, uDiscountIdx: uint32; var pSteamSubscriptionDiscount: TSteamSubscriptionDiscount; var pError: TSteamError): int; virtual; abstract;
      function EnumerateSubscriptionDiscountQualifier(uSubscriptionId, uDiscountIdx, uQualifierIdx: uint32; pSteamSubscriptionDiscount: TSteamSubscriptionDiscount; var pError: TSteamError): int; virtual; abstract;
      function EnumerateApp(uId: uint32; var pApp: TSteamApp; var pError: TSteamError): int; virtual; abstract;
      function EnumerateAppLaunchOption(uAppId, uLaunchOptionIndex: uint32; var pLaunchOption: TSteamAppLaunchOption; var pError: TSteamError): int; virtual; abstract;
      function DeleteAccount(var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function EnumerateAppIcon(uAppId: uint32; uIconIndex: Integer; pIconData: pByte; uIconDataBufSize: LongWord; var puSizeOfIconData: uint32; var pError: TSteamError): int; virtual; abstract;
      function LaunchApp(uAppId, uLaunchOption: uint32; const cszArgs: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetCacheFilePath(uCacheId: uint32; pBuff: pAnsiChar; uBuffLen: uint32; var puResLen: uint32; var pError: TSteamError): int; virtual; abstract;
      function EnumerateAppVersion(uAppId, uVersionIndex: uint32; var pAppVersion: TSteamAppVersion; var pError: TSteamError): int; virtual; abstract;
      function EnumerateAppDependency(AppId, uDependency: uint32; var pDependencyInfo: TSteamAppDependencyInfo; var pError: TSteamError): int; virtual; abstract;
      function StartLoadingCache(uAppId: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function InsertAppDependency(uAppId, uFileSystemIndex: uint32; var pDependencyInfo: TSteamAppDependencyInfo; var pError: TSteamError): int; virtual; abstract;
      function RemoveAppDependency(uAppId, uDependency: uint32; var pError: TSteamError): int; virtual; abstract;
      function FindApp(cszArg1: pAnsiChar; var puArg2: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetAppDependencies(uAppId: uint32; var puDependecies: uint32; uBufferLength: uint32; var pError: TSteamError): int; virtual; abstract;
      function IsSubscribed(uSubscriptionId: LongWord; var pbIsSubscribed, pReserved: int; var pError: TSteamError): int; virtual; abstract;
      function GetAppUserDefinedInfo(uAppId: uint32; const cszPropertyName, szPropertyValue: pAnsiChar; uBufSize: uint32; var puPropertyValueLength: uint32; var pError: TSteamError): int; virtual; abstract;
      function WaitForAppReadyToLaunch(uAppId: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function IsCacheLoadingEnabled(uAppId: LongWord; var pbIsLoading: int; var pError: TSteamError): int; virtual; abstract;
      function StopLoadingCache(uAppId: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetEncryptedUserIDTicket(const pEncryptionKeyReceivedFromAppServer: Pointer; uEncryptionKeyLength: uint32; pOutputBuffer: Pointer; uSizeOfOutputBuffer: uint32; var pReceiveSizeOfEncryptedTicket: uint32; var pError: TSteamError): eSteamError; virtual; abstract;
      function FlushCache(uAppId: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function RepairOrDecryptCaches(uAppId: uint32; iArg2: int; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function LoadCacheFromDir(uAppId: uint32; const cszPath: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetCacheDefaultDirectory(szPath: pAnsiChar; var pError: TSteamError): int; virtual; abstract;
      function SetCacheDefaultDirectory(const cszPath: pAnsiChar; var pError: TSteamError): int; virtual; abstract;
      function GetAppDir(uAppId: uint32; szDirectory: pAnsiChar; var pError: TSteamError): int; virtual; abstract;
      function MoveApp(uAppId: uint32; const szPath: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetAppCacheSize(uAppId: uint32; var puCacheSizeInMb: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function SetAppCacheSize(uAppId, uCacheSizeInMb: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function SetAppVersion(uAppId, uAppVersionId: uint32; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function Uninstall(var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function SetNotificationCallback(pCallbackFunction: SteamNotificationCallback_t; var pError: TSteamError): int; virtual; abstract;
      function ChangeForgottenPassword(cszArg1, cszArg2, cszArg3, cszArg4: pAnsiChar; var piArg5: int; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function RequestForgottenPasswordEmail(cszArg1, cszArg2: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function RequestAccountsByEmailAddressEmail(cszArg1: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function RequestAccountsByCdKeyEmail(cszArg1: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function GetNumAccountsWithEmailAddress(cszArg1, cszArg2: pAnsiChar; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function UpdateAccountBillingInfo(var pPaymentCardInfo: TSteamPaymentCardInfo; var pError: TSteamError): SteamCallHandle_t; virtual; abstract;
      function UpdateSubscriptionBillingInfo(uSubscriptionId: uint32; var pSubscriptionBillingInfo: TSteamSubscriptionBillingInfo; var pError: TSteamError): int; virtual; abstract;
      function GetSponsorUrl(uAppId: uint32; szUrl: pAnsiChar; uBufSize: uint32; var pUrlChars: uint32; var pError: TSteamError): Integer; virtual; abstract;
      function GetContentServerInfo(uArg1: uint32; var puArg2, puArg3: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetAppUpdateStats(uAppId: uint32;  eSteamAppUpdateStatsQueryType: ESteamAppUpdateStatsQueryType; var pUpdateStats: TSteamUpdateStats; var pError: TSteamError): int; virtual; abstract;
      function GetTotalUpdateStats(var pUpdateStats: TSteamUpdateStats; var pError: TSteamError): int; virtual; abstract;
      function CreateCachePreloaders(var pError: TSteamError): SteamCallHandle_t; virtual; abstract;

      // ISteam004
      procedure Win32SetMiniDumpComment(cszComment: pAnsiChar); virtual; abstract;
      procedure Win32SetMiniDumpSourceControlId(uSourceControlId: uint32); virtual; abstract;
      procedure Win32SetMiniDumpEnableFullMemory(); virtual; abstract;
      procedure Win32WriteMiniDump(a1, a2, a3, a4: pAnsiChar; a5: uint32); virtual; abstract;
      function GetCurrentAppId(var puAppId: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetAppPurchaseCountry(uAppId: uint32; szCountryCode: pAnsiChar;
       uBufferLength: uint32; var puRecievedLength: uint32; var pError: TSteamError): int; virtual; abstract;

      // ISteam005
      function GetLocalClientVersion(var a1, uSourceControlId: uint32; var pError: TSteamError): int; virtual; abstract;
      function IsFileNeededByCache(uArg1: uint32; cszFileName: pAnsiChar; uArg3: uint32; var pError: TSteamError): int; virtual; abstract;
      function LoadFileToCache(uArg1: uint32; cszArg2: pAnsiChar; pcvArg3: Pointer; uArg4, uArg5: uint32;
       var pError: TSteamError): int; virtual; abstract;
      function GetCacheDecryptionKey(uAppId: uint32; szCacheDecryptionKey: pAnsiChar; uBufferLength: uint32;
       var puRecievedLength: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetSubscriptionExtendedInfo(uSubscritptionId: uint32; cszKeyName, szKeyValue: pAnsiChar; uBufferLength: uint32;
       var puRecievedLength: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetSubscriptionPurchaseCountry(uSubscritptionId: uint32; szCountry: pAnsiChar; uBufferLength: uint32;
       var piRecievedLength: uint32; var pError: TSteamError): int; virtual; abstract;
      function GetAppUserDefinedRecord(uAppId: uint32; AddEntryToKeyValueFunc: KeyValueIteratorCallback_t;
       pvCKeyValue: Pointer; var ppError: TSteamError): int; virtual; abstract;
  end;

implementation

end.
