unit ContentServerCommon;

interface

const
  CLIENTCONTENTSERVER_INTERFACE_VERSION = 'CLIENTCONTENTSERVER_INTERFACE_VERSION001';
  STEAMCONTENTSERVER_INTERFACE_VERSION_001 = 'SteamContentServer001';
  STEAMCONTENTSERVER_INTERFACE_VERSION_002 = 'SteamContentServer002';

type
  EConnectionPriority =
    (k_EConnectionPriorityLow = 0,
     k_EConnectionPriorityMedium = 1,
     k_EConnectionPriorityHigh = 2);

implementation

end.
