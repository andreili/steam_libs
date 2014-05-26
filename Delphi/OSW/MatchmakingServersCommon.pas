unit MatchmakingServersCommon;

interface

uses
  SteamTypes;

const
  STEAMMATCHMAKINGSERVERS_INTERFACE_VERSION_001 = 'SteamMatchMakingServers001';
  STEAMMATCHMAKINGSERVERS_INTERFACE_VERSION_002 = 'SteamMatchMakingServers002';

type
  EMatchMakingServerResponse =
    (eServerResponded = 0,
     eServerFailedToRespond,
     eNoServersListedOnMasterServer); // for the Internet query type, returned in response callback if no servers of this type match

  EMatchMakingType =
    (eInternetServer = 0,
     eLANServer,
     eFriendsServer,
     eFavoritesServer,
     eHistoryServer,
     eSpectatorServer,
     eInvalidServer );

  //-----------------------------------------------------------------------------
  // Callback interfaces for server list functions (see ISteamMatchmakingServers below)
  //
  // The idea here is that your game code implements objects that implement these
  // interfaces to receive callback notifications after calling asynchronous functions
  // inside the ISteamMatchmakingServers() interface below.
  //
  // This is different than normal Steam callback handling due to the potentially
  // large size of server lists.
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Purpose: Callback interface for receiving responses after a server list refresh
  // or an individual server update.
  //
  // Since you get these callbacks after requesting full list refreshes you will
  // usually implement this interface inside an object like CServerBrowser.  If that
  // object is getting destructed you should use ISteamMatchMakingServers()->CancelQuery()
  // to cancel any in-progress queries so you don't get a callback into the destructed
  // object and crash.
  //-----------------------------------------------------------------------------
  ISteamMatchmakingServerListResponse001 = class
    public
      // Server has responded ok with updated data
      procedure ServerResponded(iServer: int); virtual; abstract;
      // Server has failed to respond
      procedure ServerFailedToRespond(iServer: int); virtual; abstract;
      // A list refresh you had initiated is now 100% completed
      procedure RefreshComplete(hRequest: HServerListRequest; response: EMatchMakingServerResponse); virtual; abstract;
  end;

  ISteamMatchmakingServerListResponse002 = class
    public
      // Server has responded ok with updated data
      procedure ServerResponded(hRequest: HServerListRequest; iServer: int); virtual; abstract;
      // Server has failed to respond// Server has failed to respond
      procedure ServerFailedToRespond(hRequest: HServerListRequest; iServer: int); virtual; abstract;
      // A list refresh you had initiated is now 100% completed
      procedure RefreshComplete(hRequest: HServerListRequest; response: EMatchMakingServerResponse); virtual; abstract;
  end;

  //Typedef to the lastest version of the interface
  ISteamMatchmakingServerListResponse = ISteamMatchmakingServerListResponse002;

  //-----------------------------------------------------------------------------
  // Purpose: Callback interface for receiving responses after pinging an individual server
  //
  // These callbacks all occur in response to querying an individual server
  // via the ISteamMatchmakingServers()->PingServer() call below.  If you are
  // destructing an object that implements this interface then you should call
  // ISteamMatchmakingServers()->CancelServerQuery() passing in the handle to the query
  // which is in progress.  Failure to cancel in progress queries when destructing
  // a callback handler may result in a crash when a callback later occurs.
  //-----------------------------------------------------------------------------
  ISteamMatchmakingPingResponse = class
    public
      // Server has responded successfully and has updated data
      procedure ServerResponded(server: gameserveritem_t); virtual; abstract;
      // Server failed to respond to the ping request
      procedure ServerFailedToRespond(); virtual; abstract;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Callback interface for receiving responses after requesting details on
  // who is playing on a particular server.
  //
  // These callbacks all occur in response to querying an individual server
  // via the ISteamMatchmakingServers()->PlayerDetails() call below.  If you are
  // destructing an object that implements this interface then you should call
  // ISteamMatchmakingServers()->CancelServerQuery() passing in the handle to the query
  // which is in progress.  Failure to cancel in progress queries when destructing
  // a callback handler may result in a crash when a callback later occurs.
  //-----------------------------------------------------------------------------
  ISteamMatchmakingPlayersResponse = class
    public
      // Got data on a new player on the server -- you'll get this callback once per player
      // on the server which you have requested player data on.
      procedure AddPlayerToList(pchName: pAnsiChar; nScore: int; flTimePlayed: real); virtual; abstract;
      // The server failed to respond to the request for player details
      procedure PlayersFailedToRespond(); virtual; abstract;
      // The server has finished responding to the player details request
      // (ie, you won't get anymore AddPlayerToList callbacks)
      procedure PlayersRefreshComplete(); virtual; abstract;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Callback interface for receiving responses after requesting rules
  // details on a particular server.
  //
  // These callbacks all occur in response to querying an individual server
  // via the ISteamMatchmakingServers()->ServerRules() call below.  If you are
  // destructing an object that implements this interface then you should call
  // ISteamMatchmakingServers()->CancelServerQuery() passing in the handle to the query
  // which is in progress.  Failure to cancel in progress queries when destructing
  // a callback handler may result in a crash when a callback later occurs.
  //-----------------------------------------------------------------------------
  ISteamMatchmakingRulesResponse = class
    public
      // Got data on a rule on the server -- you'll get one of these per rule defined on
      // the server you are querying
      procedure RulesResponded(pchRule, pchValue: pAnsiChar); virtual; abstract;
      // The server failed to respond to the request for rule details
      procedure RulesFailedToRespond(); virtual; abstract;
      // The server has finished responding to the rule details request
      // (ie, you won't get anymore RulesResponded callbacks)
      procedure RulesRefreshComplete(); virtual; abstract;
  end;

implementation

end.
