unit Steam_Interface_005;

interface 

{$I defines.inc}

uses
  Windows, USE_Types, SteamTypes,
    Steam_AsyncCallHandling, Steam_Init, Steam_Logging,
    Steam_MiniDump, Steam_Misc, Steam_Filesystem, Steam_Account, Steam_STEAMUserID, utils;

type
  CSteamInterface005 = class (TObject)
      procedure _Destructor(); virtual; stdcall;
      function ChangePassword(const cszCurrentPassphrase, cszNewPassphrase: pAnsiChar; pbChanged: pInteger; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetCurrentEmailAddress(szEmailaddress: pAnsiChar; uBufSize: LongWord; puEmailaddressChars: puint32; pError: pSteamError): int; virtual; cdecl;
      function ChangePersonalQA(const cszCurrentPassphrase, cszNewPersonalQuestion, cszNewAnswerToQuestion: pAnsiChar; pbChanged: pInteger; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function ChangeEmailAddress(const cszNewEmailAddress: pAnsiChar; pbChanged: pInteger; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function VerifyEmailAddress(cszNewEmailAddress: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function RequestEmailAddressVerificationEmail(pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function ChangeAccountName(cszCurrentAccountName: pAnsiChar; cszNewAccountName: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function MountAppFilesystem(pError: PSteamError): int; virtual; cdecl;
      function UnmountAppFilesystem(pError: PSteamError): int; virtual; cdecl;
      function MountFilesystem(uAppId: uint32; const szMountPath: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function UnmountFilesystem(uAppId: uint32; pError: pSteamError): int; virtual; cdecl;
      function Stat(const cszName: pAnsiChar; pInfo: pSteamElemInfo; pError: pSteamError): int; virtual; cdecl;
      function SetvBuf(hFile: SteamHandle_t; pBuf: Pointer; eMethod: ESteamBufferMethod; uBytes: uint; pError: PSteamError): int; virtual; cdecl;
      function FlushFile(hFile: SteamHandle_t; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function OpenFile(const cszName, cszMode: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function OpenFileEx(const szFileName, szMode: pAnsiChar; size: puint; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function OpenTmpFile(pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      procedure ClearError(pError: PSteamError); virtual; cdecl;
      function GetVersion(szVersion: pAnsiChar; uVersionBufSize: uint): int; virtual; cdecl;
      function GetOfflineStatus(pSteamOfflineStatus: pSteamOfflineStatus; pError: pSteamError): Integer; virtual; cdecl;
      function ChangeOfflineStatus(pSteamOfflineStatus: pSteamOfflineStatus; pError: pSteamError): int; virtual; cdecl;
      function ProcessCall(handle: SteamCallHandle_t; pProgress: pSteamProgress; pError: pSteamError): int; virtual; cdecl;
      function AbortCall(handle: SteamCallHandle_t; pError: PSteamError): int; virtual; cdecl;
      function BlockingCall(handle: SteamCallHandle_t; uiProcessTickMS: uint; pError: PSteamError): int; virtual; cdecl;
      function SetMaxStallCount(uNumStalls: uint; pError: PSteamError): int; virtual; cdecl;
      function CloseFile(hFile: SteamHandle_t; pError: PSteamError): int; virtual; cdecl;
      function ReadFile(pBuf: Pointer; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint; virtual; cdecl;
      function WriteFile(const pBuf: Pointer; uSize, uCount: LongWord; hFile: SteamHandle_t; pError: pSteamError): uint; virtual; cdecl;
      function Getc(hFile: SteamHandle_t; pError: PSteamError): int; virtual; cdecl;
      function Putc(cChar: Integer; hFile: SteamHandle_t; pError: pSteamError): int; virtual; cdecl;
      function SeekFile(hFile: SteamHandle_t; lOffset: ulong; sm: ESteamSeekMethod; pError: PSteamError): int; virtual; cdecl;
      function TellFile(hFile: SteamHandle_t; pError: pSteamError): LongWord; virtual; cdecl;
      function SizeFile(hFile: SteamHandle_t; pError: PSteamError): int; virtual; cdecl;
      function FindFirst(const szFileName: pAnsiChar; eFilter: ESteamFindFilter; element: pSteamElemInfo; pError: pSteamError): SteamHandle_t; virtual; cdecl;
      function FindNext(hFind: SteamHandle_t; element: pSteamElemInfo; pError: pSteamError): int; virtual; cdecl;
      function FindClose(hFind: SteamHandle_t; pError: PSteamError): int; virtual; cdecl;
      function GetLocalFileCopy(const szFileName: pAnsiChar; pError: pSteamError): Integer; virtual; cdecl;
      function IsFileImmediatelyAvailable(const cszName: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function HintResourceNeed(const cszMasterList: pAnsiChar; bForgetEverything: integer; pError: pSteamError): int; virtual; cdecl;
      function ForgetAllHints(const cszMountPath: pAnsiChar; pError: pSteamError): Integer; virtual; cdecl;
      function PauseCachePreloading(const cszMountPath: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function ResumeCachePreloading(const cszMountPath: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function WaitForResources(const cszMasterList: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function StartEngine(pError: PSteamError): int; virtual; cdecl;
      function ShutdownEngine(pError: PSteamError): int; virtual; cdecl;
      function Startup(uUsingMask: uint; pError: PSteamError): int; virtual; cdecl;
      function Cleanup(pError: PSteamError): int; virtual; cdecl;
      function NumAppsRunning(pError: pSteamError): int; virtual; cdecl;
      function CreateAccount(const cszUser, cszPassphrase, cszCreationKey, cszPersonalQuestion, cszAnswerToQuestion, cszArg6: pAnsiChar; pbCreated: pInteger; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GenerateSuggestedAccountNames(cszArg1, cszArg2, cszArg3: pAnsiChar; uArg4: uint32; puArg5: puint32; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function IsLoggedIn(pbIsLoggedIn: pInteger; pError: pSteamError): int; virtual; cdecl;
      function Logout(pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function IsSecureComputer(pbIsSecure: pInteger; pError: pSteamError): int; virtual; cdecl;
      function CreateLogContext(const cszName: pAnsiChar): SteamHandle_t; virtual; cdecl;
      function Log(hContext: SteamHandle_t; const cszMsg: pAnsiChar): int; virtual; cdecl;
      procedure LogResourceLoadStarted(const cszMsg: pAnsiChar); virtual; cdecl;
      procedure LogResourceLoadFinished(const cszMsg: pAnsiChar); virtual; cdecl;
      function RefreshLogin(const cszPassphrase: pAnsiChar; bIsSecureComputer: integer; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function VerifyPassword(const cszPassword: pAnsiChar; pbIsValid: pInteger; pError: pSteamError): int; virtual; cdecl;
      function GetUserType(puArg1: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function GetAppStats(pAppStats: PSteamAppStats; pError: PSteamError): int; virtual; cdecl;
      function IsAccountNameInUse(cszArg1: pAnsiChar; piArg2: puint32; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetAppIds(puIds: pLongWord; uMaxIds: LongWord; pError: pSteamError): int; virtual; cdecl;
      function GetSubscriptionStats(pSubscriptionStats: PSteamSubscriptionStats; pError: PSteamError): int; virtual; cdecl;
      function RefreshAccountInfo(arg1: int; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function Subscribe(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function Unsubscribe(uSubscriptionId: uint; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetSubscriptionReceipt(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetAccountStatus(puArg1: puint32; pError: pSteamError): int; virtual; cdecl;
      function SetUser(const cszUser: pAnsiChar; pbUserSet: pInteger; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetUser(szUser: pAnsiChar; uBufSize: LongWord; puUserChars: pLongWord; bIsSecureComputer: integer; pError: pSteamError): int; virtual; cdecl;
      function Login(const cszUser, cszPassphrase: pAnsiChar; bIsSecureComputer: integer; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function AckSubscriptionReceipt(uArg1: uint32; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function IsAppSubscribed(uAppId: LongWord; pbIsAppSubscribed, pReserved: pInteger; pError: pSteamError): int; virtual; cdecl;
      function GetSubscriptionIds(puIds: pLongWord; uMaxIds: LongWord; pError: pSteamError): int; virtual; cdecl;
      function EnumerateSubscription(uId: uint; pSubscription: PSteamSubscription; pError: PSteamError): int; virtual; cdecl;
      function EnumerateSubscriptionDiscount(uSubscriptionId, uDiscountIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): int; virtual; cdecl;
      function EnumerateSubscriptionDiscountQualifier(uSubscriptionId, uDiscountIdx, uQualifierIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): int; virtual; cdecl;
      function EnumerateApp(uId: uint; pApp: PSteamApp; pError: PSteamError): int; virtual; cdecl;
      function EnumerateAppLaunchOption(uAppId, uLaunchOptionIndex: uint; pLaunchOption: PSteamAppLaunchOption;
                                        pError: PSteamError): int; virtual; cdecl;
      function DeleteAccount(pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function EnumerateAppIcon(uAppId: LongWord; uIconIndex: Integer; pIconData: pByte; uIconDataBufSize: LongWord; puSizeOfIconData: pLongWord; pError: pSteamError): int; virtual; cdecl;
      function LaunchApp(uAppId, uLaunchOption: LongWord; const cszArgs: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetCacheFilePath(uCacheId: LongWord; pBuff: pAnsiChar; uBuffLen: LongWord; puResLen: pLongWord; pError: pSteamError): int; virtual; cdecl;
      function EnumerateAppVersion(uAppId, uVersionIndex: uint; pAppVersion: PSteamAppVersion;
                                   pError: PSteamError): int; virtual; cdecl;
      function EnumerateAppDependency(AppId, uDependency: uint; pDependencyInfo: PSteamAppDependencyInfo;
                                      pError: PSteamError): int; virtual; cdecl;
      function StartLoadingCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function InsertAppDependency(uAppId, uFileSystemIndex: uint32; pDependencyInfo: pSteamAppDependencyInfo; pError: pSteamError): int; virtual; cdecl;
      function RemoveAppDependency(uAppId, uDependency: LongWord; pError: pSteamError): int; virtual; cdecl;
      function FindApp(cszArg1: pAnsiChar; puArg2: puint32; pError: pSteamError): int; virtual; cdecl;
      function GetAppDependencies(uAppId: uint32; puDependecies: puint32; uBufferLength: uint32; pError: pSteamError): int; virtual; cdecl;
      function IsSubscribed(uSubscriptionId: LongWord; pbIsSubscribed, pReserved: pInteger; pError: pSteamError): int; virtual; cdecl;
      function GetAppUserDefinedInfo(uAppId: LongWord; const cszPropertyName, szPropertyValue: pAnsiChar; uBufSize: LongWord; puPropertyValueLength: pLongWord; pError: pSteamError): int; virtual; cdecl;
      function WaitForAppReadyToLaunch(uAppId: uint; pError: PSteamError): int; virtual; cdecl;
      function IsCacheLoadingEnabled(uAppId: LongWord; pbIsLoading: pInteger; pError: pSteamError): int; virtual; cdecl;
      function StopLoadingCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetEncryptedUserIDTicket(const pEncryptionKeyReceivedFromAppServer: Pointer; uEncryptionKeyLength: LongWord; pOutputBuffer: Pointer; uSizeOfOutputBuffer: LongWord; pReceiveSizeOfEncryptedTicket: pLongWord; pError: pSteamError): eSteamError; virtual; cdecl;
      function FlushCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function RepairOrDecryptCaches(uAppId: uint32; iArg2: int; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function LoadCacheFromDir(uAppId: LongWord; const cszPath: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetCacheDefaultDirectory(szPath: pAnsiChar; pError: PSteamError): int; virtual; cdecl;
      function SetCacheDefaultDirectory(const cszPath: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function GetAppDir(uAppId: LongWord; szDirectory: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function MoveApp(uAppId: LongWord; const szPath: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function GetAppCacheSize(uAppId: LongWord; puCacheSizeInMb: pLongWord; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function SetAppCacheSize(uAppId, uCacheSizeInMb: uint; pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function SetAppVersion(uAppId, uAppVersionId: LongWord; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function Uninstall(pError: PSteamError): SteamCallHandle_t; virtual; cdecl;
      function SetNotificationCallback(pCallbackFunction: SteamNotificationCallback_t; pError: PSteamError): int; virtual; cdecl;
      function ChangeForgottenPassword(cszArg1, cszArg2, cszArg3, cszArg4: pAnsiChar; piArg5: pint; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function RequestForgottenPasswordEmail(cszArg1, cszArg2: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function RequestAccountsByEmailAddressEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function RequestAccountsByCdKeyEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function GetNumAccountsWithEmailAddress(cszEmail: pAnsiChar; puNums: puint32; pError: pSteamError): SteamCallHandle_t; virtual; cdecl;
      function UpdateAccountBillingInfo(const pPaymentCardInfo: pSteamPaymentCardInfo; pbChanged: pInteger; pError: pSteamError): int; virtual; cdecl;
      function UpdateSubscriptionBillingInfo(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pbChanged: pInteger; pError: pSteamError): int; virtual; cdecl;
      function GetSponsorUrl(uAppId: LongWord; szUrl: pAnsiChar; uBufSize: LongWord; pUrlChars: pLongWord; pError: pSteamError): Integer; virtual; cdecl;
      function GetContentServerInfo(uArg1: uint32; puArg2, puArg3: puint32; pError: pSteamError): int; virtual; cdecl;
      function GetAppUpdateStats(uAppId, uStatType: uint; pUpdateStats: PSteamUpdateStats;
                             pError: PSteamError): int; virtual; cdecl;
      function GetTotalUpdateStats(pUpdateStats: PSteamUpdateStats; pError: PSteamError): int; virtual; cdecl;
      function CreateCachePreloaders(pError: PSteamError): SteamCallHandle_t; virtual; cdecl;

      // ISteam004
      function Win32SetMiniDumpComment(cszComment: pAnsiChar): int; virtual; cdecl;
      procedure Win32SetMiniDumpSourceControlId(uSourceControlId: uint); virtual; stdcall;
	    procedure Win32SetMiniDumpEnableFullMemory(); virtual; stdcall;
	    procedure Win32WriteMiniDump(a1, a2, a3, a4: pAnsiChar; a5: uint32); virtual; stdcall;
	    function GetCurrentAppId(puAppId: puint32; pError: PSteamError): int; virtual; stdcall;
      function GetAppPurchaseCountry(appID: uint; szCountryCode: pAnsiChar; uBufferLength: uint;
                                     puRecievedLength: puint; pError: PSteamError): int; virtual; cdecl;

      // ISteam005
      function GetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int; virtual; cdecl;
      function IsFileNeededByCache(a1: ulong; cszFileName: pAnsiChar; uArg3: uint; pError: pSteamError): int; virtual; cdecl;
      function LoadFileToCache(a1: uint; a2: pAnsiChar; a3: Pointer; a4, a5: uint; pError: pSteamError): int; virtual; cdecl;
      function GetCacheDecryptionKey(uAppId: uint; szCacheDecryptionKey: pAnsiChar; uBufferLength: uint; puRecievedLength: puint32; pError: pSteamError): int; virtual; cdecl;
      function GetSubscriptionExtendedInfo(uSubscritptionId: uint; cszKeyName, szKeyValue: pAnsiChar; uBufferLength: uint; puRecievedLength: puint; pError: pSteamError): int; virtual; cdecl;
      function GetSubscriptionPurchaseCountry(uSubscritptionId: uint; szCountry: pAnsiChar; uBufferLength: uint; piRecievedLength: pAnsiChar; pError: pSteamError): int; virtual; cdecl;
      function GetAppUserDefinedRecord(uAppId: uint; AddEntryToKeyValueFunc: KeyValueIteratorCallback_t; pvCKeyValue: pPointer; pError: PSteamError): int; virtual; cdecl;
    end;

implementation

procedure CSteamInterface005._Destructor;
begin
{$IFDEF LOGING}
  utils.Log('_Destructor'+#13#10);
{$ENDIF}
end;

function CSteamInterface005.AbortCall(handle: SteamCallHandle_t; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
  push [ebp+12]
  push [ebp+ 8]
  call AbortCall
  add esp, 8
  pop ebp
  ret 8
end;

function CSteamInterface005.AckSubscriptionReceipt(uArg1: uint32; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamAckSubscriptionReceipt
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.BlockingCall(handle: SteamCallHandle_t; uiProcessTickMS: LongWord; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamBlockingCall
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.ChangeAccountName(cszCurrentAccountName: pAnsiChar; cszNewAccountName: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamChangeAccountName
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.ChangeEmailAddress(const cszNewEmailAddress: pAnsiChar; pbChanged: pInteger; pError: pSteamError): SteamCallHandle_t;
asm
  push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamChangeEmailAddress
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.ChangeForgottenPassword(cszArg1, cszArg2, cszArg3, cszArg4: pAnsiChar; piArg5: pint; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+28]
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamChangeForgottenPassword
	add esp, 24
	pop ebp
	ret 24
end;
function CSteamInterface005.ChangeOfflineStatus(pSteamOfflineStatus: pSteamOfflineStatus; pError: pSteamError): Integer;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamChangeOfflineStatus
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.ChangePassword(const cszCurrentPassphrase, cszNewPassphrase: pAnsiChar; pbChanged: pInteger; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamChangePassword
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.ChangePersonalQA(const cszCurrentPassphrase, cszNewPersonalQuestion, cszNewAnswerToQuestion: pAnsiChar; pbChanged: pInteger; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamChangePersonalQA
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.Cleanup(pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamCleanup
	add esp, 4
	pop ebp
	ret 4
end;

procedure CSteamInterface005.ClearError(pError: pSteamError);
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamClearError
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.CloseFile(hFile: SteamHandle_t; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamCloseFile
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.CreateAccount(const cszUser, cszPassphrase, cszCreationKey, cszPersonalQuestion, cszAnswerToQuestion, cszArg6: pAnsiChar; pbCreated: pInteger; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+36]
	push [ebp+32]
	push [ebp+28]
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamCreateAccount
	add esp, 32
	pop ebp
	ret 32
end;

function CSteamInterface005.CreateCachePreloaders(pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamCreateCachePreloaders
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.CreateLogContext(const cszName: pAnsiChar): SteamHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamCreateLogContext
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.DeleteAccount(pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamDeleteAccount
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.EnumerateApp(uId: LongWord; pApp: pSteamApp; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateApp
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.EnumerateAppDependency(AppId, uDependency: LongWord; pDependencyInfo: pSteamAppDependencyInfo; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateAppDependency
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.EnumerateAppIcon(uAppId: LongWord; uIconIndex: Integer; pIconData: pByte; uIconDataBufSize: LongWord; puSizeOfIconData: pLongWord; pError: pSteamError): Integer;
asm
	push [ebp+28]
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateAppIcon
	add esp, 24
	pop ebp
	ret 24
end;

function CSteamInterface005.EnumerateAppLaunchOption(uAppId, uLaunchOptionIndex: LongWord; pLaunchOption: pSteamAppLaunchOption; pError: pSteamError): int;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateAppLaunchOption
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.EnumerateAppVersion(uAppId, uVersionIndex: LongWord; pAppVersion: pSteamAppVersion; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateAppVersion
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.EnumerateSubscription(uId: LongWord; pSubscription: pSteamSubscription; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateSubscription
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.EnumerateSubscriptionDiscount(uSubscriptionId, uDiscountIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateSubscriptionDiscount
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.EnumerateSubscriptionDiscountQualifier(uSubscriptionId, uDiscountIdx, uQualifierIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): Integer;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamEnumerateSubscriptionDiscountQualifier
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.FindApp(cszArg1: pAnsiChar; puArg2: puint32; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamFindApp
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.FindClose(hFind: SteamHandle_t; pError: PSteamError): int;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamFindClose
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.FindFirst(const szFileName: pAnsiChar; eFilter: ESteamFindFilter; element: pSteamElemInfo; pError: pSteamError): SteamHandle_t;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamFindFirst
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.FindNext(hFind: SteamHandle_t; element: pSteamElemInfo; pError: pSteamError): int;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamFindNext
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.FlushCache(uAppId: LongWord; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamFlushCache
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.FlushFile(hFile: SteamHandle_t; pError: PSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamFlushFile
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.ForgetAllHints(const cszMountPath: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamForgetAllHints
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GenerateSuggestedAccountNames(cszArg1, cszArg2, cszArg3: pAnsiChar; uArg4: uint32; puArg5: puint32; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+28]
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGenerateSuggestedAccountNames
	add esp, 24
	pop ebp
	ret 24
end;

function CSteamInterface005.GetAccountStatus(puArg1: puint32; pError: pSteamError): int;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamGetAccountStatus
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetAppCacheSize(uAppId: LongWord; puCacheSizeInMb: pLongWord; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppCacheSize
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.GetAppDependencies(uAppId: uint32; puDependecies: puint32; uBufferLength: uint32; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppDependencies
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.GetAppDir(uAppId: LongWord; szDirectory: pAnsiChar; pError: pSteamError): int;
begin
asm sub ebp, 4 end;

  Result := GetAppDir(uAppId, szDirectory, pError);

asm pop ebp; ret 12 end
end;

function CSteamInterface005.GetAppIds(puIds: pLongWord; uMaxIds: LongWord; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppIds
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.GetAppStats(pAppStats: pSteamAppStats; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppStats
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetAppUpdateStats(uAppId, uStatType: LongWord; pUpdateStats: pSteamUpdateStats; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppUpdateStats
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.GetAppUserDefinedInfo(uAppId: LongWord; const cszPropertyName, szPropertyValue: pAnsiChar; uBufSize: LongWord; puPropertyValueLength: pLongWord; pError: pSteamError): Integer;
asm
	push [ebp+28]
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppUserDefinedInfo
	add esp, 24
	pop ebp
	ret 24
end;

function CSteamInterface005.Getc(hFile: SteamHandle_t; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetc
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetCacheDefaultDirectory(szPath: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetCacheDefaultDirectory
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetCacheFilePath(uCacheId: LongWord; pBuff: pAnsiChar; uBuffLen: LongWord; puResLen: pLongWord; pError: pSteamError): Integer;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetCacheFilePath
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.GetContentServerInfo(uArg1: uint32; puArg2, puArg3: puint32; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetContentServerInfo
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.GetCurrentEmailAddress(szEmailaddress: pAnsiChar; uBufSize: LongWord; puEmailaddressChars: puint32; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetCurrentEmailAddress
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.GetEncryptedUserIDTicket(const pEncryptionKeyReceivedFromAppServer: Pointer; uEncryptionKeyLength: LongWord; pOutputBuffer: Pointer; uSizeOfOutputBuffer: LongWord; pReceiveSizeOfEncryptedTicket: pLongWord; pError: pSteamError): eSteamError;
asm
	push [ebp+28]
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetEncryptedUserIDTicket
	add esp, 24
	pop ebp
	ret 24
end;

function CSteamInterface005.GetLocalFileCopy(const szFileName: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetLocalFileCopy
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetNumAccountsWithEmailAddress(cszEmail: pAnsiChar; puNums: puint32; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetNumAccountsWithEmailAddress
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.GetOfflineStatus(pSteamOfflineStatus: pSteamOfflineStatus; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetOfflineStatus
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetSponsorUrl(uAppId: LongWord; szUrl: pAnsiChar; uBufSize: LongWord; pUrlChars: pLongWord; pError: pSteamError): Integer;
asm
	push [ebp+24]
  push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetSponsorUrl
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.GetSubscriptionIds(puIds: pLongWord; uMaxIds: LongWord; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetSubscriptionIds
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.GetSubscriptionReceipt(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetSubscriptionReceipt
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.GetSubscriptionStats( pSubscriptionStats: pSteamSubscriptionStats; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetSubscriptionStats
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetTotalUpdateStats(pUpdateStats: pSteamUpdateStats; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetTotalUpdateStats
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.GetUser(szUser: pAnsiChar; uBufSize: LongWord; puUserChars: pLongWord; bIsSecureComputer: integer; pError: pSteamError): Integer;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetUser
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.GetUserType(puArg1: pAnsiChar; pError: pSteamError): Integer;
asm
	push [ebp+8]
	call SteamGetUserType
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.GetVersion(szVersion: pAnsiChar; uVersionBufSize: LongWord): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamGetVersion
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.HintResourceNeed(const cszMasterList: pAnsiChar; bForgetEverything: integer; pError: pSteamError): Integer;
asm
  push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamHintResourceNeed
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.InsertAppDependency(uAppId, uFileSystemIndex: uint32; pDependencyInfo: pSteamAppDependencyInfo; pError: pSteamError): Integer;
asm
  push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamInsertAppDependency
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.IsAccountNameInUse(cszArg1: pAnsiChar; piArg2: puint32; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamIsAccountNameInUse
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.IsAppSubscribed(uAppId: LongWord; pbIsAppSubscribed, pReserved: pInteger; pError: pSteamError): Integer;
asm
  push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamIsAppSubscribed
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.IsCacheLoadingEnabled(uAppId: LongWord; pbIsLoading: pInteger; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamIsCacheLoadingEnabled
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.IsFileImmediatelyAvailable(const cszName: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamIsFileImmediatelyAvailable
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.IsLoggedIn(pbIsLoggedIn: pInteger; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamIsLoggedIn
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.IsSecureComputer(pbIsSecure: pInteger; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamIsSecureComputer
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.IsSubscribed(uSubscriptionId: LongWord; pbIsSubscribed, pReserved: pInteger; pError: pSteamError): Integer;
asm
  push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamIsSubscribed
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.LaunchApp(uAppId, uLaunchOption: LongWord; const cszArgs: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamLaunchApp
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.LoadCacheFromDir(uAppId: LongWord; const cszPath: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamLoadCacheFromDir
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.Log(hContext: SteamHandle_t; const cszMsg: pAnsiChar): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamLog
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.Login(const cszUser, cszPassphrase: pAnsiChar; bIsSecureComputer: integer; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamLogin
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.Logout(pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamLogout
	add esp, 4
	pop ebp
	ret 4
end;

procedure CSteamInterface005.LogResourceLoadFinished(const cszMsg: pAnsiChar);
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamLogResourceLoadFinished
	add esp, 4
	pop ebp
	ret 4
end;

procedure CSteamInterface005.LogResourceLoadStarted(const cszMsg: pAnsiChar);
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamLogResourceLoadStarted
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.MountAppFilesystem(pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamMountAppFilesystem
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.MountFilesystem(uAppId: LongWord; const szMountPath: pAnsiChar; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamMountFilesystem
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.MoveApp(uAppId: LongWord; const szPath: pAnsiChar; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamMoveApp
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.NumAppsRunning(pError: pSteamError): Integer;
asm
	push [ebp+8]
	call SteamNumAppsRunning
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.OpenFile(const cszName, cszMode: pAnsiChar; pError: pSteamError): SteamHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamOpenFile
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.OpenFileEx(const szFileName, szMode: pAnsiChar; size: puint; pError: pSteamError): SteamHandle_t;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]

	call SteamOpenFileEx
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.OpenTmpFile(pError: pSteamError): SteamHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamOpenTmpFile
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.PauseCachePreloading(const cszMountPath: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamPauseCachePreloading
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.ProcessCall(handle: SteamCallHandle_t; pProgress: pSteamProgress; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamProcessCall
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.Putc(cChar: Integer; hFile: SteamHandle_t; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamPutc
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.ReadFile(pBuf: Pointer; uSize, uCount: LongWord; hFile: SteamHandle_t; pError: pSteamError): LongWord;
asm
  push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamReadFile
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.RefreshAccountInfo(arg1: int; pError: PSteamError): SteamCallHandle_t;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamRefreshAccountInfo
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.RefreshLogin(const cszPassphrase: pAnsiChar; bIsSecureComputer: integer; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamRefreshLogin
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.RemoveAppDependency(uAppId, uDependency: LongWord; pError: pSteamError): Integer;
begin
asm sub ebp, 4 end;

  Result := RemoveAppDependency(uAppId, uDependency, pError);

asm pop ebp; ret 3*sizeof(integer) end
end;

function CSteamInterface005.RepairOrDecryptCaches(uAppId: uint32; iArg2: int; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamRepairOrDecryptCaches
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.RequestAccountsByCdKeyEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamRequestAccountsByCdKeyEmail
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.RequestAccountsByEmailAddressEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamRepairOrDecryptCaches
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.RequestEmailAddressVerificationEmail(pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+8]
	call SteamRequestEmailAddressVerificationEmail
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.RequestForgottenPasswordEmail(cszArg1, cszArg2: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
  push [ebp+12]
  push [ebp+8]
	call SteamRequestForgottenPasswordEmail
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.ResumeCachePreloading(const cszMountPath: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamResumeCachePreloading
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.SeekFile(hFile: SteamHandle_t; lOffset: LongWord; sm: ESteamSeekMethod; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
  push [ebp+12]
  push [ebp+8]
	call SteamSeekFile
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.SetAppCacheSize(uAppId, uCacheSizeInMb: LongWord; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamSetAppCacheSize
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.SetAppVersion(uAppId, uAppVersionId: LongWord; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamSetAppVersion
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.SetCacheDefaultDirectory(const cszPath: pAnsiChar; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamSetCacheDefaultDirectory
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.SetMaxStallCount(uNumStalls: LongWord; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamSetMaxStallCount
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.SetNotificationCallback( pCallbackFunction: SteamNotificationCallback_t; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamSetNotificationCallback
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.SetUser(const cszUser: pAnsiChar; pbUserSet: pInteger; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamSetUser
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.SetvBuf(hFile: SteamHandle_t; pBuf: Pointer; eMethod: ESteamBufferMethod; uBytes: LongWord; pError: pSteamError): Integer;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamSetvBuf
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.ShutdownEngine(pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamShutdownEngine
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.SizeFile(hFile: SteamHandle_t; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamSizeFile
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.StartEngine(pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamStartEngine
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.StartLoadingCache(uAppId: LongWord;
  pError: pSteamError): SteamHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamStartLoadingCache
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.Startup(uUsingMask: LongWord; pError: pSteamError): Integer;
begin asm sub ebp, 4 end;

  Result := SteamStartup(uUsingMask, pError);

asm 	add ebp, 4; pop ebp; ret 8; end; end;

function CSteamInterface005.Stat(const cszName: pAnsiChar; pInfo: pSteamElemInfo; pError: pSteamError): Integer;
asm
  push [ebp+16]
  push [ebp+12]
  push [ebp+8]
  call SteamStat;
  add esp, 12
  pop ebp
  ret 12
end;

function CSteamInterface005.StopLoadingCache(uAppId: LongWord; pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamStopLoadingCache
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.Subscribe(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamSubscribe
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.TellFile(hFile: SteamHandle_t; pError: pSteamError): LongWord;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamTellFile
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.Uninstall(pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamUninstall
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.UnmountAppFilesystem(pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamUnmountAppFilesystem
	add esp, 4
	pop ebp
	ret 4
end;

function CSteamInterface005.UnmountFilesystem(uAppId: uint32; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamUnmountFilesystem
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.Unsubscribe(uSubscriptionId: LongWord; pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamUnsubscribe
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.UpdateAccountBillingInfo(const pPaymentCardInfo: pSteamPaymentCardInfo; pbChanged: pInteger; pError: pSteamError): Integer;
asm
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamUpdateAccountBillingInfo
	add esp, 12
	pop ebp
	ret 12
end;

function CSteamInterface005.UpdateSubscriptionBillingInfo(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pbChanged: pInteger; pError: pSteamError): Integer;
asm
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamUpdateSubscriptionBillingInfo
	add esp, 16
	pop ebp
	ret 16
end;

function CSteamInterface005.VerifyEmailAddress(cszNewEmailAddress: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
	push [ebp+12]
	push [ebp+8]
	call SteamVerifyEmailAddress
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.VerifyPassword(const cszPassword: pAnsiChar; pbIsValid: pInteger; pError: pSteamError): Integer;
begin
asm sub ebp, 4 end;

  Result := SteamVerifyPassword(cszPassword, pbIsValid, pError);

asm pop ebp; ret 12 end
end;

function CSteamInterface005.WaitForAppReadyToLaunch(uAppId: LongWord; pError: pSteamError): Integer;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamWaitForAppReadyToLaunch
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.WaitForResources(const cszMasterList: pAnsiChar; pError: pSteamError): SteamCallHandle_t;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+12]
	push [ebp+8]
	call SteamWaitForResources
	add esp, 8
	pop ebp
	ret 8
end;

function CSteamInterface005.WriteFile(const pBuf: Pointer; uSize, uCount: LongWord; hFile: SteamHandle_t; pError: pSteamError): LongWord;
asm
  push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamWriteFile
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.Win32SetMiniDumpComment(cszComment: pAnsiChar): int;
asm
  //push ebp
  //mov ebp, esp
	push [ebp+8]
	call SteamWriteMiniDumpSetComment
	add esp, 4
	pop ebp
	ret 4
end;

procedure CSteamInterface005.Win32SetMiniDumpSourceControlId(uSourceControlId: uint);
begin
{$IFDEF LOGING}
  utils.Log('Win32SetMiniDumpSourceControlId'+#13#10);
{$ENDIF}
end;

procedure CSteamInterface005.Win32SetMiniDumpEnableFullMemory;
begin
{$IFDEF LOGING}
  utils.Log('Win32SetMiniDumpEnableFullMemory'+#13#10);
{$ENDIF}
end;

procedure CSteamInterface005.Win32WriteMiniDump(a1, a2, a3, a4: pAnsiChar; a5: uint32);
begin
{$IFDEF LOGING}
  utils.Log('Win32WriteMiniDump'+#13#10);
{$ENDIF}
end;

function CSteamInterface005.GetCurrentAppId(puAppId: puint32; pError: PSteamError): int;
begin
{$IFDEF LOGING}
  utils.Log('GetCurrentAppId'+#13#10);
{$ENDIF}
  {asm sub ebp, 4 end;
  a1^:=4000;
  result:=1;
  asm add ebp, 4; pop ebp; ret 8 end;}
end;

function CSteamInterface005.GetAppPurchaseCountry(appID: uint; szCountryCode: pAnsiChar; uBufferLength: uint;
                                     puRecievedLength: puint; pError: PSteamError): int; cdecl;
asm
	push [ebp+24]
	push [ebp+20]
	push [ebp+16]
	push [ebp+12]
	push [ebp+8]
	call SteamGetAppPurchaseCountry
	add esp, 20
	pop ebp
	ret 20
end;

function CSteamInterface005.GetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int;
asm
  push [ebp+16]
  push [ebp+12]
  push [ebp+8]
  call SteamGetLocalClientVersion
  add esp, 12
  pop ebp
  ret 12
end;

function CSteamInterface005.IsFileNeededByCache(a1: ulong; cszFileName: pAnsiChar; uArg3: uint; pError: pSteamError): int;
begin
  result:=SteamIsFileNeededByCache(a1, cszFileName, uArg3, pError);
end;    

function CSteamInterface005.LoadFileToCache(a1: uint; a2: pAnsiChar; a3: Pointer; a4, a5: uint; pError: pSteamError): int;
begin
  result:=SteamLoadFileToCache(a1, a2, a3, a4, a5, pError);
end;

function CSteamInterface005.GetCacheDecryptionKey(uAppId: uint; szCacheDecryptionKey: pAnsiChar; uBufferLength: uint; puRecievedLength: puint32; pError: pSteamError): int;
begin
  result:=SteamGetCacheDecryptionKey(uAppId, szCacheDecryptionKey, uBufferLength, puRecievedLength, pError);
end;

function CSteamInterface005.GetSubscriptionExtendedInfo(uSubscritptionId: uint; cszKeyName, szKeyValue: pAnsiChar; uBufferLength: uint; puRecievedLength: puint; pError: pSteamError): int;
begin
  result:=SteamGetSubscriptionExtendedInfo;
end;

function CSteamInterface005.GetSubscriptionPurchaseCountry(uSubscritptionId: uint; szCountry: pAnsiChar; uBufferLength: uint; piRecievedLength: pAnsiChar; pError: pSteamError): int;
begin
  asm sub ebp, 4 end;
  result:=SteamGetSubscriptionPurchaseCountry(uSubscritptionId, szCountry, uBufferLength, piRecievedLength, pError);
  asm pop ebp; ret 20 end
end;

function CSteamInterface005.GetAppUserDefinedRecord(uAppId: uint; AddEntryToKeyValueFunc: KeyValueIteratorCallback_t; pvCKeyValue: pPointer; pError: PSteamError): int;
asm
  //push ebp
  //mov ebp, esp
  push [ebp+20]
  push [ebp+16]
  push [ebp+12]
	push [ebp+8]
	call SteamGetAppUserDefinedRecord
	add esp, 16
	pop ebp
	ret 16
end;


end.
