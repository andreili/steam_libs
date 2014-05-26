unit ISteam2Bridge002_;

interface

uses
  SteamTypes, BridgeCommon, BillingCommon;

type
  ISteam2Bridge002 = class
    function SetSteam2Ticket(pubTicket: puint8; cubTicket: int): unknown_ret; virtual; abstract;

    function SetAccountName(szName: pAnsiChar): boolean; virtual; abstract;
    function SetPassword(szPassword: pAnsiChar): boolean; virtual; abstract;
    function SetAccountCreationTime(creationTime: RTime32): boolean; virtual; abstract;

    function CreateProcess(lpVACBlob: Pointer; cbVACBlob: uint32; a1, a2: pAnsiChar;
     a3: uint32; a4: Pointer; a5: pAnsiChar; a6: uint32): unknown_ret; virtual; abstract;

    function GetConnectedUniverse(): EUniverse; virtual; abstract;
    function GetIPCountry(): pAnsiChar; virtual; abstract;

    function GetNumLicenses(): uint32; virtual; abstract;

    function GetLicensePackageID(licenseId: uint32): uint32; virtual; abstract;
    function GetLicenseTimeCreated(licenseId: uint32): RTime32; virtual; abstract;
    function GetLicenseTimeNextProcess(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetLicenseMinuteLimit(licenseId: uint32): uint32; virtual; abstract;
    function GetLicenseMinutesUsed(licenseId: uint32): uint32; virtual; abstract;
    function GetLicensePaymentMethod(licenseId: uint32): EPaymentMethod; virtual; abstract;
    function GetLicenseFlags(licenseId: uint32): ELicenseFlags; virtual; abstract;
    function GetLicensePurchaseCountryCode(licenseId: uint32): pAnsiChar; virtual; abstract;

    function SetOfflineMode(offlineMode: boolean): boolean; virtual; abstract;

    function SetCellID(cellId: CellID_t): unknown_ret; virtual; abstract;

    function SetSteam2FullASTicket(pubTicket: puint8; cubTicket: int): unknown_ret; virtual; abstract;

    function UpdateAppOwnershipTicket(appId: AppId_t; a1: boolean): boolean; virtual; abstract;

    function GetAppOwnershipTicketLength(appId: AppId_t): uint32; virtual; abstract;
    function GetAppOwnershipTicketData(appId: AppId_t; lpTicketData: Pointer; cubTicketData: uint32): uint32; virtual; abstract;

    function GetAppDecryptionKey(appId: AppId_t; lpDecryptionKey: Pointer; cubDecryptionKey: uint32): unknown_ret; virtual; abstract;
  end;

implementation

end.

