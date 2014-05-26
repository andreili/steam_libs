unit ISteamRemoteStorage001_;

interface

uses
  SteamTypes, RemoteStorageCommon;

type
  ISteamRemoteStorage001 = class
    function FileWrite(filename: pAnsiChar; data: pAnsiChar; iSize: int): boolean; virtual; abstract;

    function GetFileSize(filename: pAnsiChar): uint32; virtual; abstract;

    function FileRead(filename: pAnsiChar; buffer: Pointer; size: int): boolean; virtual; abstract;

    function FileExists(filename: pAnsiChar): boolean; virtual; abstract;
    function FileDelete(filename: pAnsiChar): boolean; virtual; abstract;

    function GetFileCount(): uint32; virtual; abstract;

    function GetFileNameAndSize(index: int; var size: int): pAnsiChar; virtual; abstract;

    function GetQuota(var current, maximum: int): boolean; virtual; abstract;
  end;

implementation

end.
