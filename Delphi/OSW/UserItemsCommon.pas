unit UserItemsCommon;

interface

uses
  SteamTypes;

const
  STEAMUSERITEMS_INTERFACE_VERSION_001 = 'STEAMUSERITEMS_INTERFACE_VERSION001';
  STEAMUSERITEMS_INTERFACE_VERSION_002 = 'STEAMUSERITEMS_INTERFACE_VERSION002';
  STEAMUSERITEMS_INTERFACE_VERSION_003 = 'STEAMUSERITEMS_INTERFACE_VERSION003';

type
  EItemCriteriaOperator =
    (k_EOperator_String_EQ,
     k_EOperator_Not,
     k_EOperator_String_Not_EQ = 1,
     k_EOperator_Float_EQ,
     k_EOperator_Float_Not_EQ,
     k_EOperator_Float_LT,
     k_EOperator_Float_Not_LT,
     k_EOperator_Float_LTE,
     k_EOperator_Float_Not_LTE,
     k_EOperator_Float_GT,
     k_EOperator_Float_Not_GT,
     k_EOperator_Float_GTE,
     k_EOperator_Float_Not_GTE,
     k_EOperator_Subkey_Contains,
     k_EOperator_Subkey_Not_Contains,
     k_EItemCriteriaOperator_Count);

  EItemQuality =
    (k_EItemQuality_Normal,
     k_EItemQuality_Common,
     k_EItemQuality_Rare,
     k_EItemQuality_Unique,
     k_EItemQuality_Count,
     k_EItemQuality_Unk5,
     k_EItemQuality_Unk6,
     k_EItemQuality_Community,
     k_EItemQuality_Valve,
     k_EItemQuality_SelfMade,

     k_EItemQuality_Max = $FF);

  EItemRequestResult =
    (k_EItemRequestResultOK = 0,
     k_EItemRequestResultDenied,
     k_EItemRequestResultServerError,
     k_EItemRequestResultTimeout,
     k_EItemRequestResultInvalid,
     k_EItemRequestResultNoMatch,
     k_EItemRequestResultUnknownError,
     k_EItemRequestResultNotLoggedOn);

  UserItemCount_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserItemsCallbacks +0
    {$ENDIF}
    m_gameID: CGameID;
    m_eResult: EItemRequestResult;
    m_unCount: uint32;
  end;

  //         Item ID         |    Unknown  |   Unknown
  // c5 31 b4 00 00 00 00 00 | 00 00 00 00 | 00 00 00 00
  // ce b7 15 02 00 00 00 00 | 00 00 00 00 | 00 00 00 00
  UserItemMoved_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserItemsCallbacks +1
    {$ENDIF}
    m_itemID: ItemID;
    Unk0,
    Unk1: uint32;
  end;

  //        Item ID          |    Unknown  |   Unknown
  // c8 a0 15 02 00 00 00 00 | 00 00 00 00 | 00 00 00 00
  UserItemDeleted_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserItemsCallbacks +2
    {$ENDIF}
    m_itemID: ItemID;
    Unk0,
    Unk1: uint32;
  end;

  //         Item ID         |    CGameID (440) ?
  // 86 e7 43 02 00 00 00 00 | b8 01 00 00 00 00 00 00
  // 37 da 43 02 00 00 00 00 | b8 01 00 00 00 00 00 00
  // 4c cb 43 02 00 00 00 00 | b8 01 00 00 00 00 00 00
  // 1f bf 43 02 00 0000 00  | b8 01 00 00 00 00 00 00
  // thanks to Didrole for the sample data
  UserItemGranted_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserItemsCallbacks +3
    {$ENDIF}
    m_itemID: ItemID;
    m_gameID: CGameID;
  end;

  UserItemGetBlob_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserItemsCallbacks +4
    {$ENDIF}
    m_itemID: ItemID;
    m_eResult: EItemRequestResult;
    itemBlob: array[0..1023] of uint8;
  end;

  UserItemSetBlob_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamUserItemsCallbacks +5
    {$ENDIF}
    m_itemID: ItemID;
    m_eResult: EItemRequestResult;
    Unk: uint32;
  end;


implementation

end.
