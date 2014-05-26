unit RemoteStorageCommon;

interface

uses
  SteamTypes;

const
  STEAMREMOTESTORAGE_INTERFACE_VERSION_001 = 'STEAMREMOTESTORAGE_INTERFACE_VERSION001';
  STEAMREMOTESTORAGE_INTERFACE_VERSION_002 = 'STEAMREMOTESTORAGE_INTERFACE_VERSION002';
  CLIENTREMOTESTORAGE_INTERFACE_VERSION = 'CLIENTREMOTESTORAGE_INTERFACE_VERSION001';

type
  ERemoteStorageFileRoot =
    (k_ERemoteStorageFileRootInvalid = 0,
     k_ERemoteStorageFileRootDefault,
     k_ERemoteStorageFileRootMax);

  ERemoteStorageSyncState =
    (k_ERemoteSyncStateUnknown = 0,
     k_ERemoteSyncStateSynchronized = 1,
     k_ERemoteSyncStateSyncInProgress = 2,
     k_ERemoteSyncStatePendingChangesInCloud = 3,
     k_ERemoteSyncStatePendingChangesLocally = 4,
     k_ERemoteSyncStatePendingChangesInCloudAndLocally = 5);

implementation

end.
