unit ISteamGameServerItems002_;

interface

uses
  SteamTypes, GameServerItemsCommon, UserItemsCommon;

type
  ISteamGameServerItems002 = class
    function LoadItems(steamid: CSteamID): SteamAPICall_t; virtual; abstract;
    function GetItemCount(steamid: CSteamID): SteamAPICall_t; virtual; abstract;

    function GetItemIterative(steamid: CSteamID; i: uint32; var UniqueID: ItemID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity: uint32): boolean; virtual; abstract;
    function GetItemByID(itemid: ItemID; var steamid: CSteamID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity: uint32): boolean; virtual; abstract;

    function GetItemAttribute(itemid: ItemID; a2: uint32; var a3: uint32; var a4: float): boolean; virtual; abstract;

    function CreateNewItemRequest(steamid: CSteamID; a2: uint32; quality: EItemQuality): HNewItemRequest; virtual; abstract;

    function AddNewItemCriteria(ireq: HNewItemRequest; a2: pAnsiChar; a3: EItemCriteriaOperator;
     a4: pAnsiChar; a5: boolean): boolean; virtual; abstract;
    function AddNewItemCriteria1(ireq: HNewItemRequest; a2: pAnsiChar; a3: float;
     a4: pAnsiChar; a5: boolean): boolean; virtual; abstract;

    function SendNewItemRequest(ireq: HNewItemRequest): SteamAPICall_t; virtual; abstract;

    function GrantItemToUser(item: ItemID; steamid: CSteamID): SteamAPICall_t; virtual; abstract;

    function DeleteTemporaryItem(item: ItemID): SteamAPICall_t; virtual; abstract;
    function DeleteAllTemporaryItems(): SteamAPICall_t; virtual; abstract;
  end;

implementation

end.
