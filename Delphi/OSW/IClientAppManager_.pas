unit IClientAppManager_;

interface

uses
  SteamTypes, AppsCommon;

type
  AppUpdateInfo_s = record
    m_timeUpdateStart: RTime32;
    m_unBytesToDownload,
    m_unBytesDownloaded,
    m_unBytesToWrite,
    m_unBytesWritten: uint64;
  end;

  IClientAppManager = class
    public
      function LaunchApp(unAppID: AppId_t; uLaunchOption: uint32; cszArgs: pAnsiChar): boolean; virtual; abstract;
      function ShutdownApp(unAppID: AppId_t; bForce: boolean): boolean; virtual; abstract;

      function GetAppState(unAppID: AppId_t): EAppState; virtual; abstract;

      function InstallApp(unAppID: AppId_t; phBuffer: pAnsiChar; cbBuffer: int): boolean; virtual; abstract;
      function GetAppDir(unAppID: AppId_t; szBuffer: pAnsiChar; cubBuffer: uint32): uint32; virtual; abstract;
      function UninstallApp(unAppID: AppId_t; bComplete: boolean): boolean; virtual; abstract;

      function GetUpdateInfo(unAppID: AppId_t; var pUpdateInfo: AppUpdateInfo_s): uint32; virtual; abstract;

      function StartDownloadingUpdates(unAppID: AppId_t): boolean; virtual; abstract;
      function StopDownloadingUpdates(unAppID: AppId_t; bLockContent: boolean): boolean; virtual; abstract;
      function ApplyUpdate(unAppID: AppId_t): boolean; virtual; abstract;

      function VerifyApp(unAppID: AppId_t): boolean; virtual; abstract;

      function GetFileInfo(a1: uint32; pchFileName: pAnsiChar; punFileSize: puint64; var puDepotId: DepotId_t): boolean; virtual; abstract;

      function SetAppConfig(a1: uint32; pchBuffer: puint8; cbBuffer: int): boolean; virtual; abstract;
  end;

implementation

end.
