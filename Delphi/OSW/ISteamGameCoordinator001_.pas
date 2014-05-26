unit ISteamGameCoordinator001_;

interface

uses
  SteamTypes, GameCoordinatorCommon;

type
  ISteamGameCoordinator001 = class
    // sends a message to the Game Coordinator
    function SendMessage(unMsgType: uint32; pubData: Pointer; cubData: uint32): EGCResults; virtual; abstract;

    // returns true if there is a message waiting from the game coordinator
    function IsMessageAvailable(var pcubMsgSize: uint32): boolean; virtual; abstract;

    // fills the provided buffer with the first message in the queue and returns k_EGCResultOK or
    // returns k_EGCResultNoMessage if there is no message waiting. pcubMsgSize is filled with the message size.
    // If the provided buffer is not large enough to fit the entire message, k_EGCResultBufferTooSmall is returned
    // and the message remains at the head of the queue.
    function RetrieveMessage(var punMsgType: uint32; pubDest: Pointer; cubDest: uint32; var pcubMsgSize: uint32): EGCResults; virtual; abstract;
  end;

implementation

end.
