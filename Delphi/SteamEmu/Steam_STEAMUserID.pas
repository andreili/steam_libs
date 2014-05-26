unit Steam_STEAMUserID;

interface 

{$I defines.inc}

uses
  Windows, USE_Types, Winsock,
    SteamTypes, utils, Steam_Misc;

function SteamInitializeUserIDTicketValidator(pszOptionalPublicEncryptionKeyFilename, pszOptionalPrivateDecryptionKeyFilename: pAnsiChar; ClientClockSkewToleranceInSeconds, ServerClockSkewToleranceInSeconds, MaxNumLoginsWithinClientClockSkewTolerancePerClient, HintPeakSimultaneousValidations, AbortValidationAfterStallingForNProcessSteps: uint): ESteamError; export; cdecl;
function SteamShutdownUserIDTicketValidator: ESteamError; export; cdecl;
function SteamGetEncryptedUserIDTicket(pEncryptionKeyReceivedFromAppServer: Pointer; uEncryptionKeyLength: uint; pOutputBuffer: puint; uSizeOfOutputBuffer: uint; pReceiveSizeOfEncryptedTicket: puint; pError: PSteamError): ESteamError; export; cdecl;
function SteamStartValidatingNewValveCDKey(pEncryptedNewValveCDKeyFromClient: Pointer; uSizeOfEncryptedNewValveCDKeyFromClient, ObservedClientIPAddr: uint; pPrimaryValidateNewCDKeyServerSockAddr, pSecondaryValidateNewCDKeyServerSockAddr: Psockaddr; var ReceiveHandle: SteamUserIDTicketValidationHandle_t): ESteamError; export; cdecl;
function SteamGetEncryptionKeyToSendToNewClient(pReceiveSizeOfEncryptionKey: puint): pAnsiChar; export; cdecl;
function SteamStartValidatingUserIDTicket(pEncryptedUserIDTicketFromClient: Pointer; uSizeOfEncryptedUserIDTicketFromClient, ObservedClientIPAddr: uint; var ReceiveHandle: SteamUserIDTicketValidationHandle_t): ulong; export; cdecl;
function SteamProcessOngoingUserIDTicketValidation(Handle: SteamUserIDTicketValidationHandle_t; pReceiveValidSteamGlobalUserID: PSteamGlobalUserID; pReceiveClientLocalIPAddr: puint; pOptionalReceiveProofOfAuthenticationToken: pAnsiChar; SizeOfOptionalAreaToReceiveProofOfAuthenticationToken: int; pOptionalReceiveSizeOfProofOfAuthenticationToken: pint): ESteamError; export; cdecl;
procedure SteamAbortOngoingUserIDTicketValidation(Handle: SteamUserIDTicketValidationHandle_t); export; cdecl;
function SteamOptionalCleanUpAfterClientHasDisconnected(ObservedClientIPAddr, ClientLocalIPAddr: uint): ESteamError; export; cdecl;

implementation

function SteamInitializeUserIDTicketValidator(pszOptionalPublicEncryptionKeyFilename, pszOptionalPrivateDecryptionKeyFilename: pAnsiChar; ClientClockSkewToleranceInSeconds, ServerClockSkewToleranceInSeconds, MaxNumLoginsWithinClientClockSkewTolerancePerClient, HintPeakSimultaneousValidations, AbortValidationAfterStallingForNProcessSteps: uint): ESteamError; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamInitializeUserIDTicketValidator'+#13#10);  
{$ENDIF}
  result:=eSteamErrorNone;
end;

function SteamShutdownUserIDTicketValidator: ESteamError; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamShutdownUserIDTicketValidator'+#13#10);  
{$ENDIF}
  result:=eSteamErrorNone;
end;

function SteamGetEncryptedUserIDTicket(pEncryptionKeyReceivedFromAppServer: Pointer; uEncryptionKeyLength: uint; pOutputBuffer: puint; uSizeOfOutputBuffer: uint; pReceiveSizeOfEncryptedTicket: puint; pError: PSteamError): ESteamError; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamGetEncryptedUserIDTicket'+#13#10);    
{$ENDIF}
  pReceiveSizeOfEncryptedTicket^:=32;
  pOutputBuffer^:=800;
  Move(m_key[0], pEncryptionKeyReceivedFromAppServer^, 160);
  SteamClearError(pError);
  result:=eSteamErrorNone;
end;

function SteamGetEncryptionKeyToSendToNewClient(pReceiveSizeOfEncryptionKey: puint): pAnsiChar; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamGetEncryptionKeyToSendToNewClient'+#13#10);  
{$ENDIF}
  pReceiveSizeOfEncryptionKey^:=length(m_key);
  result:=m_key;
end;

function SteamStartValidatingUserIDTicket(pEncryptedUserIDTicketFromClient: Pointer; uSizeOfEncryptedUserIDTicketFromClient, ObservedClientIPAddr: uint; var ReceiveHandle: SteamUserIDTicketValidationHandle_t): ulong; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamStartValidatingUserIDTicket'+#13#10);  
{$ENDIF}
  result:=$17;
end;  

function SteamStartValidatingNewValveCDKey(pEncryptedNewValveCDKeyFromClient: Pointer; uSizeOfEncryptedNewValveCDKeyFromClient, ObservedClientIPAddr: uint; pPrimaryValidateNewCDKeyServerSockAddr, pSecondaryValidateNewCDKeyServerSockAddr: Psockaddr; var ReceiveHandle: SteamUserIDTicketValidationHandle_t): ESteamError; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamStartValidatingNewValveCDKey'+#13#10);
{$ENDIF}
  result:=eSteamErrorNone;
end;

function SteamProcessOngoingUserIDTicketValidation(Handle: SteamUserIDTicketValidationHandle_t; pReceiveValidSteamGlobalUserID: PSteamGlobalUserID; pReceiveClientLocalIPAddr: puint; pOptionalReceiveProofOfAuthenticationToken: pAnsiChar; SizeOfOptionalAreaToReceiveProofOfAuthenticationToken: int; pOptionalReceiveSizeOfProofOfAuthenticationToken: pint): ESteamError; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamProcessOngoingUserIDTicketValidation'+#13#10);   
{$ENDIF}
  result:=eSteamErrorNone;
end;

procedure SteamAbortOngoingUserIDTicketValidation(Handle: SteamUserIDTicketValidationHandle_t); export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamAbortOngoingUserIDTicketValidation'+#13#10);  
{$ENDIF}
end;

function SteamOptionalCleanUpAfterClientHasDisconnected(ObservedClientIPAddr, ClientLocalIPAddr: uint): ESteamError; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_USERID then
    log('SteamOptionalCleanUpAfterClientHasDisconnected'+#13#10);      
{$ENDIF}
  result:=eSteamErrorNone;
end;

end.
