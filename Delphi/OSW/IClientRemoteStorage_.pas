unit IClientRemoteStorage_;

interface

uses
  SteamTypes, RemoteStorageCommon;

type
  IClientRemoteStorage = class
    function FileWrite(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     pchFile: pAnsiChar; pvData: Pointer; cubData: int): boolean; virtual; abstract;
    function GetFileSize(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     pchFile: pAnsiChar): int32; virtual; abstract;

    function FileRead(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     pchFile: pAnsiChar; pvData: Pointer; cubDataToRead: int): int; virtual; abstract;
    function FileExists(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     pchFile: pAnsiChar): int32; virtual; abstract;

    function GetFileCount(nAppId: AppId_t; bUnk1: boolean): int32; virtual; abstract;
    function GetFileNameAndSize(nAppId: AppId_t; iFile: int; var pnFileSizeInBytes: int;
     iUnk2: int; bUnk1: boolean): pAnsiChar; virtual; abstract;

    function GetQuota(nAppId: AppId_t; var pnTotalBytes, pnAvailableBytes: int32): boolean; virtual; abstract;

    function IsCloudEnabledForAccount(): boolean; virtual; abstract;
    function IsCloudEnabledForApp(nAppId: AppId_t): boolean; virtual; abstract;
    function SetCloudEnabledForApp(nAppId: AppId_t; bEnable: boolean): boolean; virtual; abstract;

    function FilePersist(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     pchFile: pAnsiChar): unknown_ret; virtual; abstract;
    function FileForget(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     pchFile: pAnsiChar): unknown_ret; virtual; abstract;

    function ResolvePath(nAppId: AppId_t; eRemoteStorageFileRoot: ERemoteStorageFileRoot;
     a1, a2: pAnsiChar; a3: uint32): unknown_ret; virtual; abstract;

    function SetCloudEnabledForAccount(bEnable: boolean): boolean; virtual; abstract;

    function LoadLocalFileInfoCache(nAppId: AppId_t): boolean; virtual; abstract;

    function EvaluateRemoteStorageSyncState(nAppId: AppId_t): unknown_ret; virtual; abstract;
    function GetRemoteStorageSyncState(nAppId: AppId_t): ERemoteStorageSyncState; virtual; abstract;

    function HaveLatestFilesLocally(nAppId: AppId_t): boolean; virtual; abstract;

    function GetConflictingFileTimestamps(nAppId: AppId_t; var a1, a2: uint32): unknown_ret; virtual; abstract;
    function ResolveSyncConflict(nAppId: AppId_t; a1: boolean): unknown_ret; virtual; abstract;

    procedure SynchronizeApp(nAppId: AppId_t; bSyncClient, v: boolean); virtual; abstract;
    function IsAppSyncInProgress(nAppId: AppId_t): boolean; virtual; abstract;

    function ERemoteStorageFileRootFromName(a1: pAnsiChar): ERemoteStorageFileRoot; virtual; abstract;
    function PchNameFromERemoteStorageFileRoot(eRemoteStorageFileRoot: ERemoteStorageFileRoot): pAnsiChar; virtual; abstract;
  end;

implementation

end.
