unit ISteam2Bridge001_;

interface

uses
  SteamTypes, BridgeCommon, BillingCommon;

type
  ISteam2Bridge001 = class
    function SetSteam2Ticket(pubTicket: puint8; cubTicket: int): unknown_ret; virtual; abstract;

    function SetAccountName(szName: pAnsiChar): boolean; virtual; abstract;
    function SetPassword(szPassword: pAnsiChar): boolean; virtual; abstract;
    function SetAccountCreationTime(creationTime: RTime32): boolean; virtual; abstract;

    function CreateProcess(lpVACBlob: Pointer; cbBlobSize: uint32; a1, a2: pAnsiChar;
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
  end;

implementation

end.
