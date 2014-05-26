unit ISteamBilling002_;

interface

uses
  SteamTypes, BillingCommon;

type
  ISteamBilling002 = class
    function InitCreditCardPurchase(a1: int; a2: uint32; a3: boolean): unknown_ret; virtual; abstract;
    function InitPayPalPurchase(a1: int): unknown_ret; virtual; abstract;

    function GetActivationCodeInfo(a1: pAnsiChar): unknown_ret; virtual; abstract;
    function PurchaseWithActivationCode(a1: pAnsiChar): unknown_ret; virtual; abstract;

    function GetFinalPrice(): unknown_ret; virtual; abstract;

    function CancelPurchase(): unknown_ret; virtual; abstract;
    function CompletePurchase(): unknown_ret; virtual; abstract;

    function UpdateCardInfo(a1: uint32): unknown_ret; virtual; abstract;
    function DeleteCard(a1: uint32): unknown_ret; virtual; abstract;

    function GetCardList(): unknown_ret; virtual; abstract;

    function Obsolete_GetLicenses(): unknown_ret; virtual; abstract;

    function CancelLicense(a1, a2: int): unknown_ret; virtual; abstract;

    function GetPurchaseReceipts(a1: boolean): unknown_ret; virtual; abstract;

    function AcknowledgePurchaseReceipt(a1: uint32): unknown_ret; virtual; abstract;

    // Sets the billing address in the ISteamBilling object for use by other ISteamBilling functions (not stored on server)
    function SetBillingAddress(a1: uint32; pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;
    // Gets any previous set billing address in the ISteamBilling object (not stored on server)
    function GetBillingAddress(a1: uint32; pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;
    // Sets the billing address in the ISteamBilling object for use by other ISteamBilling functions (not stored on server)
    function SetShippingAddress(pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone, a1: pAnsiChar): boolean; virtual; abstract;
    // Gets any previous set billing address in the ISteamBilling object (not stored on server)
    function GetShippingAddress(pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;

    // Sets the credit card info in the ISteamBilling object for use by other ISteamBilling functions  (may eventually also be stored on server)
    function SetCardInfo(a1: uint32; eCreditCardType: ECreditCardType; pchCardNumber, pchCardHolderName,
     pchCardExpYear, pchCardExpMonth, pchCardCVV2, a2: pAnsiChar): boolean; virtual; abstract;
    // Gets any credit card info in the ISteamBilling object (not stored on server)
    function GetCardInfo(a1: uint32; eCreditCardType: ECreditCardType; pchCardNumber, pchCardHolderName,
     pchCardExpYear, pchCardExpMonth, pchCardCVV2, a2: pAnsiChar): boolean; virtual; abstract;

    function GetLicensePackageID(licenseId: uint32): uint32; virtual; abstract;
    function GetLicenseTimeCreated(licenseId: uint32): RTime32; virtual; abstract;
    function GetLicenseTimeNextProcess(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetLicenseMinuteLimit(licenseId: uint32): uint32; virtual; abstract;
    function GetLicenseMinutesUsed(licenseId: uint32): uint32; virtual; abstract;
    function GetLicensePaymentMethod(licenseId: uint32): EPaymentMethod; virtual; abstract;
    function GetLicenseFlags(licenseId: uint32): ELicenseFlags; virtual; abstract;
    function GetLicensePurchaseCountryCode(licenseId: uint32): pAnsiChar; virtual; abstract;

    function GetReceiptPackageID(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptStatus(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptResultDetail(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptTransTime(licenseId: uint32): RTime32; virtual; abstract;
    function GetReceiptTransID(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptAcknowledged(licenseId: uint32): boolean; virtual; abstract;
    function GetReceiptPaymentMethod(licenseId: uint32): EPaymentMethod; virtual; abstract;
    function GetReceiptBaseCost(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptTotalDiscount(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptTax(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptShipping(licenseId: uint32): unknown_ret; virtual; abstract;
    function GetReceiptCountryCode(licenseId: uint32): pAnsiChar; virtual; abstract;

    function GetNumLicenses(): uint32; virtual; abstract;
    function GetNumReceipts(): uint32; virtual; abstract;

    function PurchaseWithMachineID(a1: int; a2: pAnsiChar): unknown_ret; virtual; abstract;

    function InitClickAndBuyPurchase(a1: int; a2: int64; a3, a4: pAnsiChar): unknown_ret; virtual; abstract;

    function GetPreviousClickAndBuyAccount(var a1: int64; var a2, a3: pAnsiChar): unknown_ret; virtual; abstract;
  end;

implementation

end.
