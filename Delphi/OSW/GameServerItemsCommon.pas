unit GameServerItemsCommon;

interface

{$I Defines.inc}

uses
  SteamTypes, UserItemsCommon;

const
  STEAMGAMESERVERITEMS_INTERFACE_VERSION_002 = 'STEAMGAMESERVERITEMS_INTERFACE_VERSION002';
  STEAMGAMESERVERITEMS_INTERFACE_VERSION_003 = 'STEAMGAMESERVERITEMS_INTERFACE_VERSION003';
  STEAMGAMESERVERITEMS_INTERFACE_VERSION_004 = 'STEAMGAMESERVERITEMS_INTERFACE_VERSION004';

type
  GSItemCount_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerItemsCallbacks +0
    {$ENDIF}
    m_steamID: CSteamID;
    m_eResult: EItemRequestResult;
    m_unCount: uint32;
  end;

  GSItemRequest_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerItemsCallbacks +1
    {$ENDIF}
    m_steamID: CSteamID;
    m_eResult: EItemRequestResult;
    m_itemID: ItemID;
  end;

  GSItemGranted_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerItemsCallbacks +7
    {$ENDIF}
    m_steamID: CSteamID;
    m_itemID: ItemID;
  end;

  GSItemGetBlob_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerItemsCallbacks +8
    {$ENDIF}
    m_itemID: ItemID;
    m_eResult: EItemRequestResult;
    m_itemBlob: array[0..1023] of uint8;
  end;

  GSItemSetBlob_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamGameServerItemsCallbacks +9
    {$ENDIF}
    m_itemID: ItemID;
    m_eResult: EItemRequestResult;
    Unk: uint32;
  end;

implementation

end.
