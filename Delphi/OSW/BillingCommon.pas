unit BillingCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  CLIENTBILLING_INTERFACE_VERSION = 'CLIENTBILLING_INTERFACE_VERSION001';
  STEAMBILLING_INTERFACE_VERSION_001 = 'SteamBilling001';
  STEAMBILLING_INTERFACE_VERSION_002 = 'SteamBilling002';

type
  ECurrencyCode =
    (k_ECurrencyCodeInvalid = 0,
     k_ECurrencyCodeUSD = 1,
     k_ECurrencyCodeGBP = 2,
     k_ECurrencyCodeEUR = 3,
     k_ECurrencyCodeMax = 4);

  // Flags for licenses - BITS
  ELicenseFlags =
    (k_ELicenseFlagRenew = $01,              // Renew this license next period
     k_ELicenseFlagRenewalFailed = $02,      // Auto-renew failed
     k_ELicenseFlagPending = $04,            // Purchase or renewal is pending
     k_ELicenseFlagExpired = $08,            // Regular expiration (no renewal attempted)
     k_ELicenseFlagCancelledByUser = $10,    // Cancelled by the user
     k_ELicenseFlagCancelledByAdmin = $20);  // Cancelled by customer support

  // Payment methods for purchases - BIT FLAGS so can be used to indicate
  // acceptable payment methods for packages
  EPaymentMethod =
    (k_EPaymentMethodNone = $00,
     k_EPaymentMethodCDKey = $01,
     k_EPaymentMethodCreditCard = $02,
     k_EPaymentMethodPayPal = $04,
     k_EPaymentMethodManual = $08,		// Purchase was added by Steam support
     k_EPaymentMethodGuestPass = 8,
     k_EPaymentMethodHardwarePromo = 16,
     k_EPaymentMethodClickAndBuy = 32,
     k_EPaymentMethodAutoGrant = 64,
     k_EPaymentMethodWallet = 128,
     k_EPaymentMethodOEMTicket = 256,
     k_EPaymentMethodSplit = 512);

  EPurchaseResultDetail =
    (k_EPurchaseResultNoDetail = 0,
     k_EPurchaseResultAVSFailure = 1,
     k_EPurchaseResultInsufficientFunds = 2,
     k_EPurchaseResultContactSupport = 3,
     k_EPurchaseResultTimeout = 4,
     // these are mainly used for testing
     k_EPurchaseResultInvalidPackage = 5,
     k_EPurchaseResultInvalidPaymentMethod = 6,
     k_EPurchaseResultInvalidData = 7,
     k_EPurchaseResultOthersInProgress = 8,
     k_EPurchaseResultAlreadyPurchased = 9,
     k_EPurchaseResultWrongPrice = 10,
     k_EPurchaseResultFraudCheckFailed = 11,
     k_EPurchaseResultCancelledByUser = 12,
     k_EPurchaseResultRestrictedCountry = 13,
     k_EPurchaseResultBadActivationCode = 14,
     k_EPurchaseResultDuplicateActivationCode = 15,
     k_EPurchaseResultUseOtherPaymentMethod = 16,
     k_EPurchaseResultUseOtherFundingSource = 17,
     k_EPurchaseResultInvalidShippingAddress = 18,
     k_EPurchaseResultRegionNotSupported = 19,
     k_EPurchaseResultAcctIsBlocked = 20,
     k_EPurchaseResultAcctNotVerified = 21,
     k_EPurchaseResultInvalidAccount = 22,
     k_EPurchaseResultStoreBillingCountryMismatch = 23,
     k_EPurchaseResultDoesNotOwnRequiredApp = 24,
     k_EPurchaseResultCanceledByNewTransaction = 25,
     k_EPurchaseResultForceCanceledPending = 26,
     k_EPurchaseResultFailCurrencyTransProvider = 27,
     k_EPurchaseResultFailedCyberCafe = 28,
     k_EPurchaseResultNeedsPreApproval = 29,
     k_EPurchaseResultPreApprovalDenied = 30);

  EPurchaseStatus =
    (k_EPurchasePending = 0,
     k_EPurchaseSucceeded = 1,
     k_EPurchaseFailed = 2,
     k_EPurchaseRefunded = 3,
     k_EPurchaseInit = 4,
     k_EPurchaseChargedback = 5,
     k_EPurchaseRevoked = 6,
     k_EPurchaseInDispute = 7);

  ECreditCardType =
    (k_ECreditCardTypeUnknown = 0,
     k_ECreditCardTypeVisa = 1,
     k_ECreditCardTypeMaster = 2,
     k_ECreditCardTypeAmericanExpress = 3,
     k_ECreditCardTypeDiscover = 4,
     k_ECreditCardTypeDinersClub = 5,
     k_ECreditCardTypeJCB = 6);

  //-----------------------------------------------------------------------------
  // Purpose: called when this client has received a finalprice message from a Billing
  //-----------------------------------------------------------------------------
  FinalPriceMsg_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamBillingCallbacks + 1
    {$ENDIF}
    m_bSuccess,
    m_nBaseCost,
    m_nTotalDiscount,
    m_nTax,
    m_nShippingCost: uint32;
  end;

  PurchaseMsg_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamBillingCallbacks + 2
    {$ENDIF}
    m_bSuccess: uint32;
    m_EPurchaseResultDetail: int32;   // Detailed result information
  end;

implementation

end.
