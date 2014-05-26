unit GameCoordinatorCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  CLIENTGAMECOORDINATOR_INTERFACE_VERSION = 'CLIENTGAMECOORDINATOR_INTERFACE_VERSION';
  STEAMGAMECOORDINATOR_INTERFACE_VERSION_001 = 'SteamGameCoordinator001';

type
  EGCMsgResponse =
    (k_EGCMsgResponseOK,
     k_EGCMsgResponseDenied,
     k_EGCMsgResponseServerError,
     k_EGCMsgResponseTimeout,
     k_EGCMsgResponseInvalid,
     k_EGCMsgResponseNoMatch,
     k_EGCMsgResponseUnknownError,
     k_EGCMsgResponseNotLoggedOn);

  // list of possible return values from the ISteamGameCoordinator API
  EGCResults =
    (k_EGCResultOK = 0,
     k_EGCResultNoMessage = 1,          // There is no message in the queue
     k_EGCResultBufferTooSmall = 2,     // The buffer is too small for the requested message
     k_EGCResultNotLoggedOn = 3,        // The client is not logged onto Steam
     k_EGCResultInvalidMessage = 4);    // Something was wrong with the message being sent with SendMessage

  EGCMessages =
    (k_EGCMsgGenericReply = 10,

     k_ESOMsg_Create = 21,
     k_ESOMsg_Update,
     k_ESOMsg_Destroy,
     k_ESOMsg_CacheSubscribed,
     k_ESOMsg_CacheUnsubscribed,

     k_EGCMsgAchievementAwarded = 51,
     k_EGCMsgConCommand,
     k_EGCMsgStartPlaying,
     k_EGCMsgStopPlaying,
     k_EGCMsgStartGameserver,
     k_EGCMsgStopGameserver,
     k_EGCMsgWGRequest,
     k_EGCMsgWGResponse,
     k_EGCMsgGetUserGameStatsSchema,
     k_EGCMsgGetUserGameStatsSchemaResponse,
     k_EGCMsgGetUserStats,
     k_EGCMsgGetUserStatsResponse,
     k_EGCMsgAppInfoUpdated,
     k_EGCMsgValidateSession,
     k_EGCMsgValidateSessionResponse,
     k_EGCMsgLookupAccountFromInput,
     k_EGCMsgSendHTTPRequest,
     k_EGCMsgSendHTTPRequestResponse,
     k_EGCMsgPreTestSetup,
     k_EGCMsgRecordSupportAction,
     k_EGCMsgGetAccountDetails,
     k_EGCMsgSendInterAppMessage,
     k_EGCMsgReceiveInterAppMessage,
     k_EGCMsgFindAccounts,

     k_EGCMsgWebAPIRegisterInterfaces = 101,
     k_EGCMsgWebAPIJobRequest,
     k_EGCMsgWebAPIRegistrationRequested,

     k_EMsgGCSetItemPosition = 1001,
     k_EMsgGCCraft,
     k_EMsgGCCraftResponse,
     k_EMsgGCDelete,
     k_EMsgGCVerifyCacheSubscription,
     k_EMsgGCNameItem,
     k_EMsgGCDecodeItem,
     k_EMsgGCDecodeItemResponse,
     k_EMsgGCPaintItem,
     k_EMsgGCPaintItemResponse,
     k_EMsgGCGoldenWrenchBroadcast,
     k_EMsgGCMOTDRequest,
     k_EMsgGCMOTDRequestResponse,
     k_EMsgGCAddItemToSocket,
     k_EMsgGCAddItemToSocketResponse,
     k_EMsgGCAddSocketToBaseItem,
     k_EMsgGCAddSocketToItem,
     k_EMsgGCAddSocketToItemResponse,
     k_EMsgGCNameBaseItem,
     k_EMsgGCNameBaseItemResponse,
     k_EMsgGCRemoveSocketItem,
     k_EMsgGCRemoveSocketItemResponse,
     k_EMsgGCCustomizeItemTexture,
     k_EMsgGCCustomizeItemTextureResponse,
     k_EMsgGCUseItemRequest,
     k_EMsgGCUseItemResponse,
     k_EMsgGCGiftedItems,
     k_EMsgGCSpawnItem,
     k_EMsgGCRespawnPostLoadoutChange,

     k_EMsgGCTrading_InitiateTradeRequest = 1501,
     k_EMsgGCTrading_InitiateTradeResponse,
     k_EMsgGCTrading_StartSession,
     k_EMsgGCTrading_SetItem,
     k_EMsgGCTrading_RemoveItem,
     k_EMsgGCTrading_UpdateTradeInfo,
     k_EMsgGCTrading_SetReadiness,
     k_EMsgGCTrading_ReadinessResponse,
     k_EMsgGCTrading_SessionClosed,
     k_EMsgGCTrading_CancelSession,
     k_EMsgGCTrading_TradeChatMsg,
     k_EMsgGCTrading_ConfirmOffer,

     k_EMsgGCServerBrowser_FavoriteServer = 1601,
     k_EMsgGCServerBrowser_BlacklistServer,

     k_EMsgGCDev_NewItemRequest = 2001,
     k_EMsgGCDev_NewItemRequestResponse);

  // callback notification - A new message is available for reading from the message queue
  GCMessageAvailable_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameCoordinatorCallbacks +1
    {$ENDIF}
    m_nMessageSize: uint32;
  end;

  // callback notification - A message failed to make it to the GC. It may be down temporarily
  GCMessageFailed_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameCoordinatorCallbacks +2
    {$ENDIF}
  end;

  SOMsgCacheSubscribed_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_ESOMsg_CacheSubscribed
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    steamid: CSteamID;
    unknown: uint32;
    padding,
    itemcount: uint16;
    // Variable length data:
    // [SOMsgCacheSubscribed_Item_t] * itemcount
  end;

  SOMsgCacheSubscribed_Item_t = record
    itemid: uint64;
    accountid: uint32;
    itemdefindex: uint16;
    itemlevel,
    itemquality: uint8;
    position,
    itemcount: uint32;
    namelength: uint16;
    // Variable length data:
    // char customname[namelength];
    // uint16 attribcount;
    // [SOMsgCacheSubscribed_Item_Attrib_t] * attribcount
  end;

  SOMsgCacheSubscribed_Item_Attrib_t = record
    attribindex: uint16;
    value: real;
  end;

  SOMsgCacheUnsubscribed_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_ESOMsg_CacheUnsubscribed
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    steamid: CSteamID;
  end;

  SOMsgCreate_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_ESOMsg_Create
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    steamid: CSteamID;
    unknown: uint32;
    item: SOMsgCacheSubscribed_Item_t;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 76f0da0200000000 0105 0f000080
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 21ccd90200000000 0105 10000080
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 d069ea0200000000 0105 20000080
  *)
  SOMsgUpdate_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_ESOMsg_Update
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    steamid: CSteamID;
    unk1: uint32;
    itemID: uint64;
    unk2: uint16;
    position: uint32;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 7f7e1b0200000000
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 5a77020200000000
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 bdbc1c0200000000
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 8885210200000000
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001 01000000 e582e30100000000
  *)
  SOMsgDeleted_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_ESOMsg_Destroy
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    steamid: CSteamID;
    unk1: uint32;
    itemID: uint64;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 76f0da0200000000 0f000080 00000000
  0100 ffffffffffffffffffffffffffffffff 21ccd90200000000 10000080 00000000
  0100 ffffffffffffffffffffffffffffffff cff9ea0200000000 42000080 00000000
  0100 ffffffffffffffffffffffffffffffff d069ea0200000000 20000080 00000000
  *)
  GCSetItemPosition_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCSetItemPosition
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    itemID: CSteamID;
    position,
    unk1: uint64;
  end;

  (*
  This one is 4 natasha
  0100 ffffffffffffffffffffffffffffffff 0700 0400 5a77020200000000 bdbc1c0200000000 8885210200000000 e582e30100000000
  *)
  GCCraft_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCCraft
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    blueprint,                      //0xffff = unknown blueprint
    itemcount: uint16;
    // Variable length data:
    // [uint64 itemid] * itemcount
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 0700 0000000000000100 d069ea0200000000
  *)

  GCCraftResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCCraftResponse
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    blueprint: uint16;               //0xffff = failed
    unk1,
    itemID: uint64;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 7f7e1b0200000000
  *)
  GCDelete_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCDelete
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    itemID: uint64;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 86cf4e0001001001
  *)
  GCVerifyCacheSubscription_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCVerifyCacheSubscription
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    steamid: CSteamID;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 28000000 4d61783637202846522900
  0100 ffffffffffffffffffffffffffffffff 29000000 54726962697400
  0100 ffffffffffffffffffffffffffffffff 2a000000 776973686d617374657200
  0100 ffffffffffffffffffffffffffffffff 2b000000 416d616e6f6f00
  0100 ffffffffffffffffffffffffffffffff 2c000000 7c4b47437c2047617920526f62696e00
  0100 ffffffffffffffffffffffffffffffff 2d000000 416e6164757200
  0100 ffffffffffffffffffffffffffffffff 2e000000 54686520436f726e62616c6c657200
  0100 ffffffffffffffffffffffffffffffff 2f000000 69736c6100
  *)
  GCGoldenWrenchBroadcast_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCGoldenWrenchBroadcast
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    WrenchNumber,
    State: uint16;// 0 = Found, 1 = Destroyed
    // Variable length data:
    // char OwnerName[];
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 00000000 02000000
  0100 ffffffffffffffffffffffffffffffff 329d2d4c 02000000
  0100 ffffffffffffffffffffffffffffffff e6c74e4c 02000000
  *)
  GCMOTDRequest_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCMOTDRequest
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    timestamp,
    unk1: uint32;
  end;

  (*
  0100 ffffffffffffffffffffffffffffffff 0000
  0100 ffffffffffffffffffffffffffffffff 0200 3100 30930e4c 436865636b6564206f75742074686520626c6f673f00 496620796f7520686176656e2774207265616420746865206f6666696369616c2054463220626c6f672c20697427732066756c6c206f6620696e73696768747320696e746f206f757220646576656c6f706d656e742070726f636573732c206c696e6b7320746f206e6f7461626c6520636f6d6d756e6974792070726f64756374696f6e732c20616e642072616e646f6d2073746f726965732061626f7574206f7572206c6f7665206f6620686174732e204869742074686520627574746f6e2062656c6f7720746f2074616b652061206c6f6f6b2100 687474703a5c5c7777772e7465616d666f7274726573732e636f6d5c00 3200 b0e52c4c 4f6666696369616c2057696b69206f70656e732100 576527766520726563656e746c79206f70656e65642074686520646f6f7273206f6e20746865204f6666696369616c205446322077696b692e20546865726520796f752063616e2066696e64206f75742065766572797468696e67205446322072656c617465642c2066726f6d20746865206e756d65726963616c206e75747320616e6420626f6c7473206f6620657665727920776561706f6e20746f2074686520656173746572206567677320696e7369646520746865204d65657420746865205465616d206d6f766965732e205468657927726520616c77617973206c6f6f6b696e6720666f72206d6f726520636f6e7472696275746f72732c20736f20776879206e6f742068656164206f76657220616e642068656c70207468656d3f00 687474703a5c5c77696b692e7465616d666f7274726573732e636f6d5c00
  *)
  GCMOTDRequestResponse_t = record
    {$IFDEF ICALLBACKS}
    k_iMessage: integer;//= k_EMsgGCMOTDRequestResponse
    {$ENDIF}
    id: uint16;
    garbage: array[0..15] of AnsiChar;
    NumberOfNews: uint16;
  end;

implementation

end.
