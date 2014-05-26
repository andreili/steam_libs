unit Steam_Account;

interface   

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils,
    SteamTypes, Steam_Misc, utils;

    

function SteamCreateAccount(cszUser, cszPassphrase, cszCreationKey, cszPersonalQuestion, cszAnswerToQuestion: pAnsiChar;
                            pbCreated: pint; uUnknown: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamDeleteAccount(pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamChangeAccountName(cszCurrentAccountName, cszNewAccountName: pAnsiChar; pError: pSteamError): int; export; cdecl;
function SteamChangeEmailAddress(cszNewEmailAddress: pAnsiChar; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamChangeForgottenPassword(cszArg1, cszArg2, cszArg3, cszArg4: pAnsiChar; piArg5: pint; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamChangePassword(cszCurrentPassphrase, cszNewPassphrase: pAnsiChar; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamChangePersonalQA(cszCurrentPassphrase, cszNewPersonalQuestion, cszNewAnswerToQuestion: pAnsiChar; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamEnumerateApp(AppId: uint; pApp: PSteamApp; pError: PSteamError): int; export; cdecl;
function SteamEnumerateAppDependency(AppId, uDependency: uint; pDependencyInfo: PSteamAppDependencyInfo; pError: PSteamError): int; export; cdecl;
function SteamEnumerateAppIcon(uAppId, uIconIndex: uint; pIconData: pAnsiChar; uIconDataBufSize: uint; puSizeOfIconData: puint; pError: PSteamError): int; export; cdecl;
function SteamEnumerateAppLaunchOption(uAppId, uLaunchOptionIndex: uint; pLaunchOption: PSteamAppLaunchOption; pError: PSteamError): int; export; cdecl;
function SteamEnumerateAppVersion(uAppId, uVersionIndex: uint; pAppVersion: PSteamAppVersion; pError: PSteamError): int; export; cdecl;
function SteamEnumerateSubscription(uSubId: uint; pSubscription: PSteamSubscription; pError: PSteamError): int; export; cdecl;
function SteamEnumerateSubscriptionDiscount(uSubscriptionId, uDiscountIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): int; export; cdecl;
function SteamEnumerateSubscriptionDiscountQualifier(uSubscriptionId, uDiscountIdx, uQualifierIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): int; export; cdecl;
function SteamGenerateSuggestedAccountNames(cszArg1, cszArg2, cszArg3: pAnsiChar; uArg4: uint32; puArg5: puint32; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamGetAccountStatus(puArg1: puint32; pError: pSteamError): int; export; cdecl;
function SteamGetAppCacheSize(uAppId: uint; pCacheSizeInMb: puint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamGetAppDependencies(uAppId: uint32; puDependecies: puint32; uBufferLength: uint32; pError: pSteamError): int; export; cdecl;
function SteamGetAppDir: int; export; cdecl;
function SteamGetAppIds(puAppIds: puint; uMaxIds: uint; pError: PSteamError): int; export; cdecl;
function SteamGetAppPurchaseCountry(appID: uint; szCountryCode: pAnsiChar; uBufferLength: uint; puRecievedLength: puint; pError: PSteamError): int; export; cdecl;
function SteamGetAppStats(pAppStats: PSteamAppStats; pError: PSteamError): int; export; cdecl;
function SteamGetAppUpdateStats(uAppId, uStatType: uint; pUpdateStats: PSteamUpdateStats; pError: PSteamError): int; export; cdecl;
function SteamGetAppUserDefinedInfo(uAppId: uint; cszPropertyName, szPropertyValue: pAnsiChar; uBufSize: uint; puPropertyValueLength: puint; pError: PSteamError): int; export; cdecl;
function SteamGetAppUserDefinedRecord(uAppId, arg2, arg3: uint; pError: PSteamError): int; export; cdecl;
function SteamGetCurrentEmailAddress(szEmailaddress: pAnsiChar; uBufSize: uint; puEmailaddressChars: puint; pError: PSteamError): int; export; cdecl;
function SteamGetNumAccountsWithEmailAddress(cszEmail: pAnsiChar; puNums: puint; pError: pSteamError): int; export; cdecl;
function SteamGetSponsorUrl(uAppId: uint; szUrl: pAnsiChar; uBufSize: uint; pUrlChars: puint; pError: PSteamError): int; export; cdecl;
function SteamGetSubscriptionExtendedInfo: int; export; cdecl;
function SteamGetSubscriptionIds(puSubIds: puint; uMaxIds: uint; pError: PSteamError): int; export; cdecl;
function SteamGetSubscriptionPurchaseCountry(a1: uint; a2: pAnsiChar; a3: uint; a4: pAnsiChar; a5: pSteamError): int; export; cdecl;
function SteamGetSubscriptionReceipt(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamGetSubscriptionStats(pSubscriptionStats: PSteamSubscriptionStats; pError: PSteamError): int; export; cdecl;
function SteamGetTotalUpdateStats(pSubscriptionStats: PSteamUpdateStats; pError: PSteamError): int; export; cdecl;
function SteamGetUser(szUser: pAnsiChar; uBufSize: uint; puUserChars: puint; bIsSecureComputer: int; pError: PSteamError): int; export; cdecl;
function SteamGetUserType(arg1: puint; pError: pSteamError): int; export; cdecl;
function SteamIsAccountNameInUse(cszUser: pAnsiChar; pbIsInUse: puint; pError: pSteamError): int; export; cdecl;
function SteamIsAppSubscribed(uAppId: uint; pbIsAppSubscribed, pbIsReady: pint; pError: PSteamError): int; export; cdecl;
function SteamIsLoggedIn(pbIsLoggedIn: pint; pError: PSteamError): int; export; cdecl;
function SteamIsSecureComputer(pbIsSecure: pint; pError: PSteamError): int; export; cdecl;
function SteamIsSubscribed(uSubscriptionId: uint; pbIsSubscribed, pbIsReady: pint; pError: PSteamError): int; export; cdecl;
function SteamLaunchApp(uAppId, uLaunchOption: uint; cszArgs: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamLogin(cszUser, cszPassphrase: pAnsiChar; bIsSecureComputer: int; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamLogout(pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamMoveApp(uAppId: uint; szPath: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamRefreshAccountInfo(arg1: int32; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamRefreshAccountInfo2: int; export; cdecl;
function SteamRefreshAccountInfoEx: int; export; cdecl;
function SteamRefreshLogin(cszPassphrase: pAnsiChar; bIsSecureComputer: int; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamRequestAccountsByCdKeyEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamRequestAccountsByEmailAddressEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamRequestEmailAddressVerificationEmail(pError: pSteamError): int; export; cdecl;
function SteamRequestForgottenPasswordEmail(cszArg1, cszArg2: pAnsiChar; pError: pSteamError): SteamCallHandle_t; export; cdecl;
function SteamSetUser(cszUser: pAnsiChar; pbUserSet: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamSetUser2(cszUser: pAnsiChar; pbUserSet: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamSubscribe(uSubscriptionId: uint; pSubscriptionBillingInfo: PSteamSubscriptionBillingInfo; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamUnsubscribe(uSubscriptionId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamUpdateAccountBillingInfo(pPaymentCardInfo: PSteamPaymentCardInfo; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamUpdateSubscriptionBillingInfo(uSubscriptionId: uint; pSubscriptionBillingInfo: PSteamSubscriptionBillingInfo; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamVerifyEmailAddress(cszEmailAddress: pAnsiChar; pError: pSteamError): int; export; cdecl;
function SteamVerifyPassword(const cszPassword: pAnsiChar; pbIsValid: pInteger; pError: pSteamError): int; export; cdecl;
function SteamWaitForAppReadyToLaunch(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamAckSubscriptionReceipt(uArg1: uint32; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamRemoveAppDependency: int; export; cdecl;
function SteamSetAppCacheSize(uAppId, nCacheSizeInMb: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamSetAppVersion(uAppId, uAppVersionId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamInsertAppDependency(uAppId, uFileSystemIndex: uint32; pDependencyInfo: pSteamAppDependencyInfo; pError: pSteamError): int; export; cdecl;
function SteamNumAppsRunning: int; export; cdecl;
function SteamFindApp(cszArg1: pAnsiChar; puArg2: puint32; pError: pSteamError): int; export; cdecl;

implementation

function SteamCreateAccount(cszUser, cszPassphrase, cszCreationKey, cszPersonalQuestion, cszAnswerToQuestion: pAnsiChar;
                            pbCreated: pint; uUnknown: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamCreateAccount'+#13#10); 
{$ENDIF}
  pbCreated^:=1;  
  SteamClearError(pError);
  result:=1;
end;

function SteamDeleteAccount(pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamDeleteAccount'+#13#10);  
{$ENDIF}     
  SteamClearError(pError);
  result:=1;
end;

function SteamChangeAccountName(cszCurrentAccountName, cszNewAccountName: pAnsiChar; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamChangeAccountName'+#13#10);   
{$ENDIF}
  result:=1;
end;

function SteamChangeEmailAddress(cszNewEmailAddress: pAnsiChar; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamChangeEmailAddress: '+cszNewEmailAddress+#13#10);  
{$ENDIF}     
  SteamClearError(pError);
  pbChanged^:=1;
  result:=1;
end;

function SteamChangeForgottenPassword(cszArg1, cszArg2, cszArg3, cszArg4: pAnsiChar; piArg5: pint; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamChangeForgottenPassword'+#13#10);   
{$ENDIF}
  result:=1;
end;

function SteamChangePassword(cszCurrentPassphrase, cszNewPassphrase: pAnsiChar; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamChangePassword: '+Ansi2Wide(cszCurrentPassphrase)+' , '+Ansi2Wide(cszNewPassphrase)+#13#10);
{$ENDIF}   
  SteamClearError(pError);
  pbChanged^:=1;
  result:=1;
end;

function SteamChangePersonalQA(cszCurrentPassphrase, cszNewPersonalQuestion, cszNewAnswerToQuestion: pAnsiChar; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamChangePersonalQA: '+Ansi2Wide(cszCurrentPassphrase)+' , '+Ansi2Wide(cszNewPersonalQuestion)+' , '+Ansi2Wide(cszNewAnswerToQuestion)+#13#10);
{$ENDIF}  
  SteamClearError(pError);
  pbChanged^:=1;
  result:=1;
end;

function SteamEnumerateApp(AppId: uint; pApp: PSteamApp; pError: PSteamError): int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateApp: AppID: '+Int2Str(AppId)+#13#10);  
{$ENDIF}   
  SteamClearError(pError);
  result:=1;
end;

function SteamEnumerateAppDependency(AppId, uDependency: uint; pDependencyInfo: PSteamAppDependencyInfo; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateAppDependency: AppID: '+Int2Str(AppId)+#13#10);  
{$ENDIF}  
  SteamClearError(pError);
  result:=1;
end;

function SteamEnumerateAppIcon(uAppId, uIconIndex: uint; pIconData: pAnsiChar; uIconDataBufSize: uint; puSizeOfIconData: puint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateAppIcon: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}   
  SteamClearError(pError);
  result:=1;
end;

function SteamEnumerateAppLaunchOption(uAppId, uLaunchOptionIndex: uint; pLaunchOption: PSteamAppLaunchOption; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateAppLaunchOption: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamEnumerateAppVersion(uAppId, uVersionIndex: uint; pAppVersion: PSteamAppVersion; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    Log('SteamEnumerateAppVersion: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamEnumerateSubscription(uSubId: uint; pSubscription: PSteamSubscription; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateSubscription: SubId: '+Int2Str(uSubId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamEnumerateSubscriptionDiscount(uSubscriptionId, uDiscountIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateSubscriptionDiscount'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamEnumerateSubscriptionDiscountQualifier(uSubscriptionId, uDiscountIdx, uQualifierIdx: uint32; pSteamDiscountQualifier: pSteamDiscountQualifier; pError: pSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamEnumerateSubscriptionDiscountQualifier'+#13#10);    
{$ENDIF}
  result:=1;
end;

function SteamGenerateSuggestedAccountNames(cszArg1, cszArg2, cszArg3: pAnsiChar; uArg4: uint32; puArg5: puint32; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGenerateSuggestedAccountNames'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamGetAccountStatus(puArg1: puint32; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAccountStatus'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamGetAppCacheSize(uAppId: uint; pCacheSizeInMb: puint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppCacheSize: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetAppDependencies(uAppId: uint32; puDependecies: puint32; uBufferLength: uint32; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppDependencies'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamGetAppDir: int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppDir'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamGetAppIds(puAppIds: puint; uMaxIds: uint; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppIds: AppIDs: '+Int2Str(puAppIds^)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetAppPurchaseCountry(appID: uint; szCountryCode: pAnsiChar; uBufferLength: uint; puRecievedLength: puint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppPurchaseCountry: AppID: '+Int2Str(AppId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetAppStats(pAppStats: PSteamAppStats; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppStats'+#13#10);    
{$ENDIF}
  result:=1;
end;

function SteamGetAppUpdateStats(uAppId, uStatType: uint; pUpdateStats: PSteamUpdateStats; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppUpdateStats: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=0;
end;

function SteamGetAppUserDefinedInfo(uAppId: uint; cszPropertyName, szPropertyValue: pAnsiChar; uBufSize: uint; puPropertyValueLength: puint; pError: PSteamError): int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppUserDefinedInfo: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetAppUserDefinedRecord(uAppId, arg2, arg3: uint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetAppUserDefinedRecord: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=0;
end;

function SteamGetCurrentEmailAddress(szEmailaddress: pAnsiChar; uBufSize: uint; puEmailaddressChars: puint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetCurrentEmailAddress: '+szEmailaddress+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamGetNumAccountsWithEmailAddress(cszEmail: pAnsiChar; puNums: puint; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetNumAccountsWithEmailAddress'+#13#10);   
{$ENDIF}
  puNums^:=0;  
  result:=1;
end;

function SteamGetSponsorUrl(uAppId: uint; szUrl: pAnsiChar; uBufSize: uint; pUrlChars: puint; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetSponsorUrl: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetSubscriptionExtendedInfo: int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetSubscriptionExtendedInfo'+#13#10);   
{$ENDIF}
  result:=1;
end;

function SteamGetSubscriptionIds(puSubIds: puint; uMaxIds: uint; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetSubscriptionIds'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamGetSubscriptionPurchaseCountry(a1: uint; a2: pAnsiChar; a3: uint; a4: pAnsiChar; a5: pSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetSubscriptionPurchaseCountry'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamGetSubscriptionReceipt(uSubscriptionId: LongWord; const pSubscriptionBillingInfo: pSteamSubscriptionBillingInfo; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetSubscriptionPurchaseCountry'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetSubscriptionStats(pSubscriptionStats: PSteamSubscriptionStats; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetSubscriptionStats'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamGetTotalUpdateStats(pSubscriptionStats: PSteamUpdateStats; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetTotalUpdateStats'+#13#10);
{$ENDIF}
  SteamClearError(pError);
  result:=1;
end;

function SteamGetUser(szUser: pAnsiChar; uBufSize: uint; puUserChars: puint; bIsSecureComputer: int; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetUser'+#13#10);
{$ENDIF}
  SteamClearError(pError);
  result:=1;
end;

function SteamGetUserType(arg1: puint; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetUserType'+#13#10); 
{$ENDIF}
  arg1^:=1;
  SteamClearError(pError);
  result:=1;
end;

function SteamIsAccountNameInUse(cszUser: pAnsiChar; pbIsInUse: puint; pError: pSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamGetUserType'+#13#10); 
{$ENDIF}
  pbIsInUse^:=0;
  SteamClearError(pError);
  result:=1;
end;

function SteamIsAppSubscribed(uAppId: uint; pbIsAppSubscribed, pbIsReady: pint; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    Log('SteamIsAppSubscribed: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}
  result:=1;
  if pbIsAppSubscribed<>nil then pbIsAppSubscribed^:=1;
  if pbIsReady<>nil then pbIsReady^:=1;
  if pError<>nil then SteamClearError(pError);
end;

function SteamIsLoggedIn(pbIsLoggedIn: pint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    Log('SteamIsLoggedIn'+#13#10);   
{$ENDIF}
  result:=0;
  if (pbIsLoggedIn<>nil) and (pError<>nil) then
  begin
    pbIsLoggedIn^:=1;
    SteamClearError(pError);
    result:=1;
  end;
end;

function SteamIsSecureComputer(pbIsSecure: pint; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamIsSecureComputer'+#13#10);   
{$ENDIF}  
  SteamClearError(pError);
  pbIsSecure^:=1;
  result:=1;
end;

function SteamIsSubscribed(uSubscriptionId: uint; pbIsSubscribed, pbIsReady: pint; pError: PSteamError): int; export; cdecl;
begin     
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    Log('SteamIsSubscribed'+#13#10);     
{$ENDIF}
  case uSubscriptionId of
    4:  pbIsSubscribed^:=0;
    64: pbIsSubscribed^:=0;
    else pbIsSubscribed^:=1;
  end;
  pbIsReady^:=1;
  {pbIsSubscribed^:=1;
  pbIsReady^:=0;      }
  SteamClearError(pError);
  result:=1;
end;

function SteamLaunchApp(uAppId, uLaunchOption: uint; cszArgs: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamLaunchApp: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}    
  SteamClearError(pError);
  result:=0;
end;

function SteamLogin(cszUser, cszPassphrase: pAnsiChar; bIsSecureComputer: int; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamLogin: login: '+Ansi2Wide(cszUser)+' , password: '+Ansi2Wide(cszPassphrase)+#13#10);
{$ENDIF}     
  SteamClearError(pError);
  result:=1;
end;

function SteamLogout(pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamLogout'+#13#10);    
{$ENDIF} 
  SteamClearError(pError);
  result:=1;
end;

function SteamMoveApp(uAppId: uint; szPath: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamMoveApp: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}  
  SteamClearError(pError);
  result:=1;
end;

function SteamRefreshAccountInfo(arg1: int32; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRefreshAccountInfo'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamRefreshAccountInfo2: int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRefreshAccountInfo2'+#13#10);    
{$ENDIF}
  result:=1;
end;

function SteamRefreshAccountInfoEx: int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRefreshAccountInfoEx'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamRefreshLogin(cszPassphrase: pAnsiChar; bIsSecureComputer: int; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRefreshLogin'+#13#10);  
{$ENDIF}   
  SteamClearError(pError);
  result:=1;
end;

function SteamRequestAccountsByCdKeyEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRequestAccountsByCdKeyEmail'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamRequestAccountsByEmailAddressEmail(cszArg1: pAnsiChar; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRequestAccountsByEmailAddressEmail'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamRequestEmailAddressVerificationEmail(pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRequestEmailAddressVerificationEmail'+#13#10);    
{$ENDIF}
  result:=1;
end;

function SteamRequestForgottenPasswordEmail(cszArg1, cszArg2: pAnsiChar; pError: pSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRequestForgottenPasswordEmail'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamSetUser(cszUser: pAnsiChar; pbUserSet: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamSetUser: '+cszUser+#13#10);
{$ENDIF}
  SteamClearError(pError);
  result:=0;
end;

function SteamSetUser2(cszUser: pAnsiChar; pbUserSet: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamSetUser2: '+cszUser+#13#10);
{$ENDIF}
  SteamClearError(pError);
  result:=0;
end;

function SteamSubscribe(uSubscriptionId: uint; pSubscriptionBillingInfo: PSteamSubscriptionBillingInfo; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamSubscribe'+#13#10);   
{$ENDIF} 
  SteamClearError(pError);
  result:=1;
end;

function SteamUnsubscribe(uSubscriptionId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamUnsubscribe'+#13#10);  
{$ENDIF}  
  SteamClearError(pError);
  result:=1;
end;

function SteamUpdateAccountBillingInfo(pPaymentCardInfo: PSteamPaymentCardInfo; pbChanged: pint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin     
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamUpdateAccountBillingInfo'+#13#10);   
{$ENDIF}   
  SteamClearError(pError);
  result:=1;
end;

function SteamUpdateSubscriptionBillingInfo(uSubscriptionId: uint; pSubscriptionBillingInfo: PSteamSubscriptionBillingInfo; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamUpdateSubscriptionBillingInfo'+#13#10);    
{$ENDIF}  
  SteamClearError(pError);
  result:=1;
end;

function SteamVerifyEmailAddress(cszEmailAddress: pAnsiChar; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamVerifyEmailAddress'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamVerifyPassword(const cszPassword: pAnsiChar; pbIsValid: pInteger; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamVerifyPassword'+#13#10); 
{$ENDIF}  
  SteamClearError(pError);
  result:=1;
end;

function SteamWaitForAppReadyToLaunch(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamWaitForAppReadyToLaunch: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}  
  SteamClearError(pError);
  result:=1;
end;

function SteamAckSubscriptionReceipt(uArg1: uint32; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamAckSubscriptionReceipt'+#13#10);    
{$ENDIF}  
  result:=1;
end;

function SteamRemoveAppDependency: int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamRemoveAppDependency'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamSetAppCacheSize(uAppId, nCacheSizeInMb: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamSetAppCacheSize: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}    
  SteamClearError(pError);
  result:=1;
end;

function SteamSetAppVersion(uAppId, uAppVersionId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamSetAppVersion: AppID: '+Int2Str(uAppId)+#13#10);
{$ENDIF}    
  SteamClearError(pError);
  result:=1;
end;

function SteamInsertAppDependency(uAppId, uFileSystemIndex: uint32; pDependencyInfo: pSteamAppDependencyInfo; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamInsertAppDependency'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamNumAppsRunning: int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamNumAppsRunning'+#13#10);   
{$ENDIF}
  result:=1;
end;

function SteamFindApp(cszArg1: pAnsiChar; puArg2: puint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_ACCOUNT then
    log('SteamFindApp'+#13#10);  
{$ENDIF}
  result:=1;
end;

end.
