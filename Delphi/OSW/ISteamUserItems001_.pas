unit ISteamUserItems001_;

interface

uses
  SteamTypes, UserItemsCommon;

type
  ISteamUserItems001 = class
    function LoadItems(): SteamAPICall_t; virtual; abstract;

    function GetItemCount(): SteamAPICall_t; virtual; abstract;

    function GetItemIterative(index: uint32; var UniqueID: ItemID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity, NbOfAttribute: uint32): boolean; virtual; abstract;
    function GetItemByID(UniqueID: ItemID; var ItemType, ItemLevel: uint32;
     var Quality: EItemQuality; var Flags, Quantity, NbOfAttribute: uint32): boolean; virtual; abstract;
    procedure GetItemAttribute(uniqueID: ItemID; index: uint32; var attribId: uint32; var value: float); virtual; abstract;

    procedure UpdateInventoryPos(uniqueID: ItemID; pos: uint32); virtual; abstract;

    procedure DropItem(itemId: ItemID); virtual; abstract;
  end;

implementation

end.
