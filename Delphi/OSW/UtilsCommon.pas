unit UtilsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  CLIENTUTILS_INTERFACE_VERSION = 'CLIENTUTILS_INTERFACE_VERSION001';
  STEAMUTILS_INTERFACE_VERSION_001 = 'SteamUtils001';
  STEAMUTILS_INTERFACE_VERSION_002 = 'SteamUtils002';
  STEAMUTILS_INTERFACE_VERSION_003 = 'SteamUtils003';
  STEAMUTILS_INTERFACE_VERSION_004 = 'SteamUtils004';
  STEAMUTILS_INTERFACE_VERSION_005 = 'SteamUtils005';

type
  ESteamAPICallFailure =
    (k_ESteamAPICallFailureNone = -1,                // no failure
     k_ESteamAPICallFailureSteamGone = 0,            // the local Steam process has gone away
     k_ESteamAPICallFailureNetworkFailure = 1,       // the network connection to Steam has been broken, or was already broken
     k_ESteamAPICallFailureInvalidHandle = 2,        // the SteamAPICall_t handle passed in no longer exists
     k_ESteamAPICallFailureMismatchedCallback = 3);  // GetAPICallResult() was called with the wrong callback type for this API call

  EConfigStore =
    (k_EConfigStoreInvalid = 0,
     k_EConfigStoreInstall = 1,
     k_EConfigStoreUserRoaming = 2,
     k_EConfigStoreUserLocal = 3,
     k_EConfigStoreMax = 4);

  //-----------------------------------------------------------------------------
  // Purpose: The country of the user changed
  //-----------------------------------------------------------------------------
  IPCountry_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUtilsCallbacks +1
    {$ENDIF}
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Fired when running on a laptop and less than 10 minutes of battery is left, fires then every minute
  //-----------------------------------------------------------------------------
  LowBatteryPower_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUtilsCallbacks + 2
    {$ENDIF}
    m_nMinutesBatteryLeft: uint8;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: called when a SteamAsyncCall_t has completed (or failed)
  //-----------------------------------------------------------------------------
  SteamAPICallCompleted_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUtilsCallbacks +3
    {$ENDIF}
    m_hAsyncCall: SteamAPICall_t;
  end;

  //-----------------------------------------------------------------------------
  // called when Steam wants to shutdown
  //-----------------------------------------------------------------------------
  SteamShutdown_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUtilsCallbacks +4
    {$ENDIF}
  end;

  SteamConfigStoreChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUtilsCallbacks +5
    {$ENDIF}
    m_eConfigStore: EConfigStore;
    m_szRootOfChanges: array[0..254] of AnsiChar;
  end;

implementation

end.
