unit ISteamUserItems004_;

interface

uses
  SteamTypes, UserItemsCommon;

type
  ISteamUserItems004 = class
    function LoadItems(): SteamAPICall_t; virtual; abstract;

    function GetItemCount(): SteamAPICall_t; virtual; abstract;

    function GetItemIterative(i: uint32; var UniqueID: ItemID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity, NbOfAttribute: uint32): boolean; virtual; abstract;
    function GetItemByID(UniqueID: ItemID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity, NbOfAttribute: uint32): boolean; virtual; abstract;
    procedure GetItemAttribute(uniqueID: ItemID; b: uint32; var c: uint32; var d: float); virtual; abstract;

    procedure UpdateInventoryPos(uniqueID: ItemID; b: uint32); virtual; abstract;

    function DeleteItem(itemId: ItemID): unknown_ret; virtual; abstract;

    function GetItemBlob(itemId: ItemID): SteamAPICall_t; virtual; abstract;
    function SetItemBlob(itemId: ItemID; blob: Pointer; size: uint32): SteamAPICall_t; virtual; abstract;

    procedure DropItem(itemId: ItemID); virtual; abstract;
  end;

implementation

end.
