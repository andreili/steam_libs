unit ISteamBilling001_;

interface

uses
  SteamTypes, BillingCommon;

type
  ISteamBilling001 = class
    // Sets the billing address in the ISteamBilling object for use by other ISteamBilling functions (not stored on server)
    function SetBillingAddress(pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;
    // Gets any previous set billing address in the ISteamBilling object (not stored on server)
    function GetBillingAddress(pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;
    // Sets the billing address in the ISteamBilling object for use by other ISteamBilling functions (not stored on server)
    function SetShippingAddress(pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone, a1: pAnsiChar): boolean; virtual; abstract;
    // Gets any previous set billing address in the ISteamBilling object (not stored on server)
    function GetShippingAddress(pchName, pchAddress1, pchAddress2, pchCity, pchPostcode,
     pchState, pchCountry, pchPhone: pAnsiChar): boolean; virtual; abstract;

    // Sets the credit card info in the ISteamBilling object for use by other ISteamBilling functions  (may eventually also be stored on server)
    function SetCardInfo(eCreditCardType: ECreditCardType; pchCardNumber, pchCardHolderName,
     pchCardExpYear, pchCardExpMonth, pchCardCVV2, a2: pAnsiChar): boolean; virtual; abstract;
    // Gets any credit card info in the ISteamBilling object (not stored on server)
    function GetCardInfo(eCreditCardType: ECreditCardType; pchCardNumber, pchCardHolderName,
     pchCardExpYear, pchCardExpMonth, pchCardCVV2, a2: pAnsiChar): boolean; virtual; abstract;

    // Ask the server to purchase a package: requires that ISteamBilling cardinfo, billing & shipping address are set
    // gidCardID - if non-NIL, use a server stored card
    // bStoreCardInfo - Should this cardinfo also be stored on the server
    function Purchase(nPackageID: uint32; nExpectedCostCents: int32; gidCardID: uint64; bStoreCardInfo: boolean): boolean; virtual; abstract;
  end;

implementation

end.
