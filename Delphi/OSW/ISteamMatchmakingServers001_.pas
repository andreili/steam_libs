unit ISteamMatchmakingServers001_;

interface

uses
  SteamTypes, MatchmakingServersCommon;

type
  ISteamMatchmakingServers001 = class (TObject)
    procedure _Destructor(); virtual; abstract;
    // Request a new list of servers of a particular type.  These calls each correspond to one of the EMatchMakingType values.
    procedure RequestInternetServerList(iApp: TAppID; var ppchFilters: MatchMakingKeyValuePair_s; nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse); virtual; abstract;
    procedure RequestLANServerList(iApp: TAppID; var pRequestServersResponse: ISteamMatchmakingServerListResponse); virtual; abstract;
    procedure RequestFriendsServerList(iApp: TAppID; var ppchFilters: MatchMakingKeyValuePair_s; nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse); virtual; abstract;
    procedure RequestFavoritesServerList(iApp: TAppID; var ppchFilters: MatchMakingKeyValuePair_s; nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse); virtual; abstract;
    procedure RequestHistoryServerList(iApp: TAppID; var ppchFilters: MatchMakingKeyValuePair_s; nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse); virtual; abstract;
    procedure RequestSpectatorServerList(iApp: TAppID; var ppchFilters: MatchMakingKeyValuePair_s; nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse); virtual; abstract;

    {the filters that are available in the ppchFilters params are:

    "map"		- map the server is running, as set in the dedicated server api
    "dedicated" - reports bDedicated from the API
    "secure"	- VAC-enabled
    "full"		- not full
    "empty"		- not empty
    "noplayers" - is empty
    "proxy"		- a relay server }
    // Get details on a given server in the list, you can get the valid range of index
    // values by calling GetServerCount().  You will also receive index values in
    // ISteamMatchmakingServerListResponse::ServerResponded() callbacks
    function GetServerDetails(eType: EMatchMakingType; iServer: int): gameserveritem_s; virtual; abstract;
    // Cancel an request which is operation on the given list type.  You should call this to cancel
    // any in-progress requests before destructing a callback object that may have been passed
    // to one of the above list request calls.  Not doing so may result in a crash when a callback
    // occurs on the destructed object.
    procedure CancelQuery(eType: EMatchMakingType); virtual; abstract;
    // Ping every server in your list again but don't update the list of servers
    procedure RefreshQuery(eType: EMatchMakingType); virtual; abstract;
    // Returns true if the list is currently refreshing its server list
    procedure IsRefreshing(eType: EMatchMakingType); virtual; abstract;
    // How many servers in the given list, GetServerDetails above takes 0... GetServerCount() - 1
    procedure GetServerCount(eType: EMatchMakingType); virtual; abstract;
    // Refresh a single server inside of a query (rather than all the servers )
    procedure RefreshServer(eType: EMatchMakingType; iServer: int); virtual; abstract;

    //-----------------------------------------------------------------------------
    // Queries to individual servers directly via IP/Port
    //-----------------------------------------------------------------------------
    // Request updated ping time and other details from a single server
    function PingServer(unIP: uint32; usPort: uint16; var pRequestServersResponse: ISteamMatchmakingPingResponse): HServerQuery; virtual; abstract;
    // Request the list of players currently playing on a server
    function PlayerDetails(unIP: uint32; usPort: uint16; var pRequestServersResponse: ISteamMatchmakingPlayersResponse): HServerQuery; virtual; abstract;
    // Request the list of rules that the server is running (See ISteamMasterServerUpdater->SetKeyValue() to set the rules server side)
    function ServerRules(unIP: uint32; usPort: uint16; var pRequestServersResponse: ISteamMatchmakingRulesResponse): HServerQuery; virtual; abstract;

    // Cancel an outstanding Ping/Players/Rules query from above.  You should call this to cancel
    // any in-progress requests before destructing a callback object that may have been passed
    // to one of the above calls to avoid crashing when callbacks occur.
    procedure CancelServerQuery(hServerQuery: HServerQuery); virtual; abstract;
  end;

implementation

end.
