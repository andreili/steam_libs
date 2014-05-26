unit ISteamAppTicket001_;

interface

uses
  SteamTypes;

type
  ISteamAppTicket001 = class
    function GetAppOwnershipTicketExtendedData(nAppID: AppId_t; pvBuffer: Pointer; cbBufferLength: uint32;
     var a1, a2: int; var ticket_lengthticket_length, signature_length: uint32): uint32; virtual; abstract;
  end;

implementation

end.
