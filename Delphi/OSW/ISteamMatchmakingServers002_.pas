unit ISteamMatchmakingServers002_;

interface

uses
  SteamTypes, MatchmakingServersCommon;

type
  ISteamMatchmakingServers001 = class
    // Request a new list of servers of a particular type.  These calls each correspond to one of the EMatchMakingType values.
    // Each call allocates a new asynchronous request object.
    // Request object must be released by calling ReleaseRequest( hServerListRequest )
    function RequestInternetServerList(iApp: AppId_t; var ppchFilters: MatchMakingKeyValuePair_s;
     nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse): HServerListRequest; virtual; abstract;
    function RequestLANServerList(iApp: AppId_t; var ppchFilters: MatchMakingKeyValuePair_s;
     var pRequestServersResponse: ISteamMatchmakingServerListResponse): HServerListRequest; virtual; abstract;
    function RequestFriendsServerList(iApp: AppId_t; var ppchFilters: MatchMakingKeyValuePair_s;
     nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse): HServerListRequest; virtual; abstract;
    function RequestFavoritesServerList(iApp: AppId_t; var ppchFilters: MatchMakingKeyValuePair_s;
     nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse): HServerListRequest; virtual; abstract;
    function RequestHistoryServerList(iApp: AppId_t; var ppchFilters: MatchMakingKeyValuePair_s;
     nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse): HServerListRequest; virtual; abstract;
    function RequestSpectatorServerList(iApp: AppId_t; var ppchFilters: MatchMakingKeyValuePair_s;
     nFilters: uint32; var pRequestServersResponse: ISteamMatchmakingServerListResponse): HServerListRequest; virtual; abstract;

    // Releases the asynchronous request object and cancels any pending query on it if there's a pending query in progress.
    // RefreshComplete callback is not posted when request is released.
    procedure ReleaseRequest(hServerListRequest: HServerListRequest);virtual; abstract;

    (*
    the filters that are available in the ppchFilters params are:
      "map"		- map the server is running, as set in the dedicated server api
      "dedicated" - reports bDedicated from the API
      "secure"	- VAC-enabled
      "full"		- not full
      "empty"		- not empty
      "noplayers" - is empty
      "proxy"		- a relay server
    *)

    // Get details on a given server in the list, you can get the valid range of index
    // values by calling GetServerCount().  You will also receive index values in
    // ISteamMatchmakingServerListResponse::ServerResponded() callbacks
    function GetServerDetails(hRequest: HServerListRequest; iServer: int): gameserveritem_s;virtual; abstract;

    // Cancel an request which is operation on the given list type.  You should call this to cancel
    // any in-progress requests before destructing a callback object that may have been passed
    // to one of the above list request calls.  Not doing so may result in a crash when a callback
    // occurs on the destructed object.
    // Canceling a query does not release the allocated request handle.
    // The request handle must be released using ReleaseRequest( hRequest )
    procedure CancelQuery(hRequest: HServerListRequest);virtual; abstract;

    // Ping every server in your list again but don't update the list of servers
    // Query callback installed when the server list was requested will be used
    // again to post notifications and RefreshComplete, so the callback must remain
    // valid until another RefreshComplete is called on it or the request
    // is released with ReleaseRequest( hRequest )
    procedure RefreshQuery(hRequest: HServerListRequest);virtual; abstract;

    // Returns true if the list is currently refreshing its server list
    procedure IsRefreshing(hRequest: HServerListRequest);virtual; abstract;

    // How many servers in the given list, GetServerDetails above takes 0... GetServerCount() - 1
    procedure GetServerCount(hRequest: HServerListRequest); virtual; abstract;

    // Refresh a single server inside of a query (rather than all the servers )
    procedure RefreshServer(hRequest: HServerListRequest; iServer: int); virtual; abstract;

    //-----------------------------------------------------------------------------
    // Queries to individual servers directly via IP/Port
    //-----------------------------------------------------------------------------

    // Request updated ping time and other details from a single server
    function PingServer(unIP: uint32; usPort: uint16;
     var pRequestServersResponse: ISteamMatchmakingPingResponse): HServerQuery;virtual; abstract;

    // Request the list of players currently playing on a serve
    function PlayerDetails(unIP: uint32; usPort: uint16;
     var pRequestServersResponse: ISteamMatchmakingPlayersResponse): HServerQuery;virtual; abstract;

    // Request the list of rules that the server is running (See ISteamMasterServerUpdater->SetKeyValue() to set the rules server side)
    function ServerRules(unIP: uint32; usPort: uint16;
     var pRequestServersResponse: ISteamMatchmakingRulesResponse): HServerQuery;virtual; abstract;

    // Cancel an outstanding Ping/Players/Rules query from above.  You should call this to cancel
    // any in-progress requests before destructing a callback object that may have been passed
    // to one of the above calls to avoid crashing when callbacks occur.
    procedure CancelServerQuery(hServerQuery: HServerQuery);virtual; abstract;
  end;

implementation

end.
