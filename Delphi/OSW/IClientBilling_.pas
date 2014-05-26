unit IClientBilling_;

interface

uses
  SteamTypes, BillingCommon;

type
  IClientBilling = class
    function GetActivationCodeInfo(pchActivationCode: pAnsiChar): boolean; virtual; abstract;
    function PurchaseWithActivationCode(pchActivationCode: pAnsiChar): boolean; virtual; abstract;

    function CancelLicense(packageID: PackageId_t; nCancelReason: int32): boolean; virtual; abstract;

    function GetPurchaseReceipts(bUnacknowledgedOnly: boolean): boolean; virtual; abstract;
    function AcknowledgePurchaseReceipt(nReceiptIndex: uint32): boolean; virtual; abstract;

    function GetLicensePackageID(nLicenseIndex: uint32): PackageId_t; virtual; abstract;
    function GetLicenseTimeCreated(nLicenseIndex: uint32): RTime32; virtual; abstract;
    function GetLicenseTimeNextProcess(nLicenseIndex: uint32): RTime32; virtual; abstract;
    function GetLicenseMinuteLimit(nLicenseIndex: uint32): int; virtual; abstract;
    function GetLicenseMinutesUsed(nLicenseIndex: uint32): int; virtual; abstract;
    function GetLicensePaymentMethod(nLicenseIndex: uint32): EPaymentMethod; virtual; abstract;
    function GetLicenseFlags(nLicenseIndex: uint32): uint32; virtual; abstract;
    function GetLicensePurchaseCountryCode(nLicenseIndex: uint32): pAnsiChar; virtual; abstract;
    function GetLicenseTerritoryCode(nLicenseIndex: uint32): int; virtual; abstract;
    function GetLicenseInfo(nLicenseIndex: uint32; a2, a3: puint32; a4, a5: pint; a6: EPaymentMethod;
     a7: puint32; a8: pint; a9: pAnsiChar): unknown_ret; virtual; abstract;

    function GetReceiptPackageID(nReceiptIndex: uint32): PackageId_t; virtual; abstract;
    function GetReceiptStatus(nReceiptIndex: uint32): EPurchaseStatus; virtual; abstract;
    function GetReceiptResultDetail(nReceiptIndex: uint32): EPurchaseResultDetail; virtual; abstract;
    function GetReceiptTransTime(nReceiptIndex: uint32): RTime32; virtual; abstract;
    function GetReceiptTransID(nReceiptIndex: uint32): uint64; virtual; abstract;
    function GetReceiptAcknowledged(nReceiptIndex: uint32): boolean; virtual; abstract;
    function GetReceiptPaymentMethod(nReceiptIndex: uint32): EPaymentMethod; virtual; abstract;
    function GetReceiptBaseCost(nReceiptIndex: uint32): uint32; virtual; abstract;
    function GetReceiptTotalDiscount(nReceiptIndex: uint32): uint32; virtual; abstract;
    function GetReceiptTax(nReceiptIndex: uint32): uint32; virtual; abstract;
    function GetReceiptShipping(nReceiptIndex: uint32): uint32; virtual; abstract;
    function GetReceiptCurrencyCode(nReceiptIndex: uint32): ECurrencyCode; virtual; abstract;
    function GetReceiptCountryCode(nReceiptIndex: uint32): pAnsiChar; virtual; abstract;

    function GetNumLicenses(): uint32; virtual; abstract;
    function GetNumReceipts(): uint32; virtual; abstract;

    function PurchaseWithMachineID(packageId: PackageId_t; pchCustomData: pAnsiChar): boolean; virtual; abstract;

    function GetReceiptCardInfo(nReceiptIndex: uint32; var eCreditCardType: ECreditCardType; pchCardLast4Digits, pchCardHolderFirstName,
     pchCardHolderLastName, pchCardExpYear, pchCardExpMonth: pAnsiChar): boolean; virtual; abstract;

    function GetReceiptBillingAddress(nReceiptIndex: uint32; pchFirstName, pchLastName,
     pchAddress1, pchAddress2, pchCity, pchPostcode, pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;

    function GetReceiptLineItemCount(nReceiptIndex: uint32): uint32; virtual; abstract;
    function GetReceiptLineItemInfo(nReceiptIndex, nLineItemIndex: uint32; var nPackageID: PackageId_t;
     nBaseCost, nDiscount, nTax, nShipping: puint32; var eCurrencyCode: ECurrencyCode): boolean; virtual; abstract;

    procedure EnableTestLicense(unPackageID: PackageId_t); virtual; abstract;
    procedure DisableTestLicense(unPackageID: PackageId_t); virtual; abstract;

    function ActivateOEMTicket(pchOEMLicenseFile: pAnsiChar): boolean; virtual; abstract;
  end;

implementation

end.
