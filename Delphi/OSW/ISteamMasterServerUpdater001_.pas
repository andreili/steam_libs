unit ISteamMasterServerUpdater001_;

interface

uses
  SteamTypes, MasterServerUpdaterCommon;

type
  ISteamMasterServerUpdater001 = class
    // Call this as often as you like to tell the master server updater whether or not
    // you want it to be active (default: off).
    procedure SetActive(bActive: boolean); virtual; abstract;

    // You usually don't need to modify this.
    // Pass -1 to use the default value for iHeartbeatInterval.
    // Some mods change this.
    procedure SetHeartbeatInterval(iHeartbeatInterval: int); virtual; abstract;

    // These are in GameSocketShare mode, where instead of ISteamMasterServerUpdater creating its own
    // socket to talk to the master server on, it lets the game use its socket to forward messages
    // back and forth. This prevents us from requiring server ops to open up yet another port
    // in their firewalls.
    //
    // the IP address and port should be in host order, i.e 127.0.0.1 == 0x7f000001

    // These are used when you've elected to multiplex the game server's UDP socket
    // rather than having the master server updater use its own sockets.
    //
    // Source games use this to simplify the job of the server admins, so they
    // don't have to open up more ports on their firewalls.

    // Call this when a packet that starts with 0xFFFFFFFF comes in. That means
    // it's for us.
    function HandleIncomingPacket(pData: Pointer; cbData: int; srcIP: uint32; srcPort: uint16): boolean; virtual; abstract;

    // AFTER calling HandleIncomingPacket for any packets that came in that frame, call this.
    // This gets a packet that the master server updater needs to send out on UDP.
    // It returns the length of the packet it wants to send, or 0 if there are no more packets to send.
    // Call this each frame until it returns 0.
    function GetNextOutgoingPacket(pOut: Pointer; cbMaxOut: int; var pNetAdr: uint32; var pPort: uint16): int; virtual; abstract;

    // Functions to set various fields that are used to respond to queries.

    // Call this to set basic data that is passed to the server browser.
    procedure SetBasicServerData(nProtocolVersion: ushort; bDedicatedServer: boolean; pRegionName,
     pProductName: pAnsiChar; nMaxReportedClients: ushort; bPasswordProtected: boolean;
     pGameDescription: pAnsiChar); virtual; abstract;

    // Call this to clear the whole list of key/values that are sent in rules queries.
    procedure ClearAllKeyValues(); virtual; abstract;

    // Call this to add/update a key/value pair.
    procedure SetKeyValue(pKey, pValue: pAnsiChar); virtual; abstract;

    // You can call this upon shutdown to clear out data stored for this game server and
    // to tell the master servers that this server is going away.
    procedure NotifyShutdown(); virtual; abstract;

    // Returns true if the master server has requested a restart.
    // Only returns true once per request.
    function WasRestartRequested(): boolean; virtual; abstract;

    // Force it to request a heartbeat from the master servers.
    procedure ForceHeartbeat(); virtual; abstract;

    // Manually edit and query the master server list.
    // It will provide name resolution and use the default master server port if none is provided
    function AddMasterServer(pServerAddress: pAnsiChar): boolean; virtual; abstract;
    function RemoveMasterServer(pServerAddress: pAnsiChar): boolean; virtual; abstract;

    function GetNumMasterServers(): int; virtual; abstract;

    // Returns the # of bytes written to pOut.
    function GetMasterServerAddress(iServer: int; pOut: pAnsiChar; outBufferSize: int): int; virtual; abstract;
  end;

implementation

end.
