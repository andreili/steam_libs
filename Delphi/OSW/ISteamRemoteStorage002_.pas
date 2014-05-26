unit ISteamRemoteStorage002_;

interface

uses
  SteamTypes, RemoteStorageCommon;

type
  ISteamRemoteStorage002 = class
    // NOTE
    //
    // Filenames are case-insensitive, and will be converted to lowercase automatically.
    // So "foo.bar" and "Foo.bar" are the same file, and if you write "Foo.bar" then
    // iterate the files, the filename returned will be "foo.bar".
    //

    // file operations
    function FileWrite(filename: pAnsiChar; data: pAnsiChar; cubData: int): boolean; virtual; abstract;
    function GetFileSize(filename: pAnsiChar): uint32; virtual; abstract;
    function FileRead(filename: pAnsiChar; buffer: Pointer; cubDataToRead: int): boolean; virtual; abstract;
    function FileExists(filename: pAnsiChar): boolean; virtual; abstract;

    // iteration
    function GetFileCount(): uint32; virtual; abstract;
    function GetFileNameAndSize(index: int; var pnFileSizeInBytes: int): pAnsiChar; virtual; abstract;

    // quota management
    function GetQuota(var pnTotalBytes, puAvailableBytes: int): boolean; virtual; abstract;
  end;

implementation

end.
