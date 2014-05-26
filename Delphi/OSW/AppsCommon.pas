unit AppsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  CLIENTAPPS_INTERFACE_VERSION = 'CLIENTAPPS_INTERFACE_VERSION001';
  CLIENTAPPMANAGER_INTERFACE_VERSION = 'CLIENTAPPMANAGER_INTERFACE_VERSION001';
  STEAMAPPS_INTERFACE_VERSION_001 = 'STEAMAPPS_INTERFACE_VERSION001';
  STEAMAPPS_INTERFACE_VERSION_002 = 'STEAMAPPS_INTERFACE_VERSION002';
  STEAMAPPS_INTERFACE_VERSION_003 = 'STEAMAPPS_INTERFACE_VERSION003';

type
  EAppState =
    (k_EAppStateInvalid = 0,
     k_EAppStateUninstalled = 1,
     k_EAppStateUpdateRequired = 2,
     k_EAppStateFullyInstalled = 4,
     k_EAppStateDataEncrypted = 8,
     k_EAppStateDataLocked = 16,
     k_EAppStateDataCorrupt = 32,
     k_EAppStateAppRunning = 64,
     k_EAppStateUpdateRunning = 256,
     k_EAppStateUpdatePaused = 512,
     k_EAppStateUpdateSuspended = 1024,
     k_EAppStateUninstalling = 2048,
     k_EAppStateReconfiguring = 4096,
     k_EAppStateDownloading = 8192,
     k_EAppStateStaging = 16384,
     k_EAppStateCommitting = 32768);

  EAppEvent =
    (k_EAppEventDownloadComplete = 2);

  //-----------------------------------------------------------------------------
  // Purpose: called when new information about an app has arrived
  //-----------------------------------------------------------------------------
  AppDataChanged_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: integer;//= k_iSteamAppsCallbacks + 1
    {$ENDIF}
    m_nAppID: uint32;
    m_bBySteamUI,
    m_bCDDBUpdate: boolean;
  end;

  RequestAppCallbacksComplete_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: integer; //= k_iSteamAppsCallbacks + 2
    {$ENDIF}
  end;

  AppInfoUpdateComplete_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: integer;//= k_iSteamAppsCallbacks + 3
    {$ENDIF}
    m_EResult: EResult;
    m_cAppsUpdated: uint32;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: posted after the user gains ownership of DLC & that DLC is installed
  //-----------------------------------------------------------------------------
  DlcInstalled_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: integer;//= k_iSteamAppsCallbacks + 5
    {$ENDIF}
    m_nAppID: uint32;         // AppID of the DLC
  end;

implementation

end.
