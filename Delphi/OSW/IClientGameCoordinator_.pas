unit IClientGameCoordinator_;

interface

uses
  SteamTypes, GameCoordinatorCommon;

type
  IClientGameCoordinator = class
    function SendMessage(v: AppId_t; unMsgType: uint32; pubData: Pointer; cubData: uint32): EGCResults; virtual; abstract;

    function IsMessageAvailable(unAppID: AppId_t; pcubMsgSize: puint32): boolean; virtual; abstract;

    function RetrieveMessage(unAppID: AppId_t; punMsgType: puint32; pubDest: Pointer; cubDest: uint32; pcubMsgSize: puint32): EGCResults; virtual; abstract;
  end;

implementation

end.
