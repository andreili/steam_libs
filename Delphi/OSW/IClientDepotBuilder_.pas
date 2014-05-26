unit IClientDepotBuilder_;

interface

uses
  SteamTypes;

const
  CLIENTDEPOTBUILDER_INTERFACE_VERSION = 'CLIENTDEPOTBUILDER_INTERFACE_VERSION001';

type
  EDepotBuildStatus =
    (k_EDepotBuildStatusInvalid = -1,
     k_EDepotBuildStatusFailed = 0,
     k_EDepotBuildStatusProcessingConfig = 1,
     k_EDepotBuildStatusProcessingData = 2,
     k_EDepotBuildStatusUploadingData = 3,
     k_EDepotBuildStatusCompleted = 4);

  //-----------------------------------------------------------------------------
  // Purpose: Status of a given depot version, these are stored in the DB, don't renumber
  //-----------------------------------------------------------------------------
  EStatusDepotVersion =
    (k_EStatusDepotVersionInvalid = 0,
     k_EStatusDepotVersionCompleteDisabled = 1,
     k_EStatusDepotVersionCompleteEnabledBeta = 2,
     k_EStatusDepotVersionCompleteEnabledPublic = 3);

  HDEPOTBUILD = uint32;

  IClientDepotBuilder = class
    function InitializeDepotBuildForConfigFile(pchConfigFile: pAnsiChar; bMakePublic: boolean): HDEPOTBUILD; virtual; abstract;
    function GetDepotBuildStatus(hDepotBuild: HDEPOTBUILD; var pStatusOut: EDepotBuildStatus; pPercentDone: puint32): boolean; virtual; abstract;
    function CloseDepotBuildHandle(hDepotBuild: HDEPOTBUILD): boolean; virtual; abstract;

    function ReconstructDepotFromManifestAndChunks(pchLocalManifestPath, pchLocalChunkPath, pchRestorePath: pAnsiChar): HDEPOTBUILD; virtual; abstract;

    function GetChunkCounts(hDepotBuild: HDEPOTBUILD; unTotalChunksInNewBuild, unChunksAlsoInOldBuild: puint32): boolean; virtual; abstract;
  end;

implementation

end.
