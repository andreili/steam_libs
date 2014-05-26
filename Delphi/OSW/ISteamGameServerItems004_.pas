unit ISteamGameServerItems004_;

interface

uses
  SteamTypes, GameServerItemsCommon, UserItemsCommon;

type
  ISteamGameServerItems004 = class
    function LoadItems(steamid: CSteamID): SteamAPICall_t; virtual; abstract;
    function GetItemCount(steamid: CSteamID): SteamAPICall_t; virtual; abstract;

    function GetItemIterative(steamid: CSteamID; i: uint32; var UniqueID: ItemID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity, NbOfAttribute: uint32): boolean; virtual; abstract;
    function GetItemByID(itemid: ItemID; var steamid: CSteamID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity, NbOfAttribute: uint32): boolean; virtual; abstract;

    function GetItemAttribute(itemid: ItemID; a2: uint32; var a3: uint32; var a4: float): boolean; virtual; abstract;

    function CreateNewItemRequest(steamid: CSteamID): HNewItemRequest; virtual; abstract;

    function AddNewItemLevel(ireq: HNewItemRequest; level: uint32): boolean; virtual; abstract;
    function AddNewItemQuality(ireq: HNewItemRequest; quality: EItemQuality): boolean; virtual; abstract;

    function SetNewItemInitialInventoryPos(ireq: HNewItemRequest; pos: uint32): boolean; virtual; abstract;
    function SetNewItemInitialQuantity(ireq: HNewItemRequest; quantity: uint32): boolean; virtual; abstract;

    function AddNewItemCriteria(ireq: HNewItemRequest; a2: pAnsiChar; a3: EItemCriteriaOperator;
     a4: pAnsiChar; a5: boolean): boolean; virtual; abstract;
    function AddNewItemCriteria1(ireq: HNewItemRequest; a2: pAnsiChar; a3: float;
     a4: pAnsiChar; a5: boolean): boolean; virtual; abstract;

    function SendNewItemRequest(ireq: HNewItemRequest): SteamAPICall_t; virtual; abstract;

    function GrantItemToUser(item: ItemID; steamid: CSteamID): SteamAPICall_t; virtual; abstract;

    function DeleteTemporaryItem(item: ItemID): SteamAPICall_t; virtual; abstract;
    function DeleteAllTemporaryItems(): SteamAPICall_t; virtual; abstract;

    function UpdateQuantity(item: ItemID; quantity: uint32): SteamAPICall_t; virtual; abstract;

    function GetItemBlob(item: ItemID): SteamAPICall_t; virtual; abstract;
    function SetItemBlob(item: ItemID; blob: pAnsiChar; size: uint32): SteamAPICall_t; virtual; abstract;
  end;

implementation

end.
