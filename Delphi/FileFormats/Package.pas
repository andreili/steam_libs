unit Package;

interface

uses
  USE_Types, Windows;

type
  TPackage = class (TObject)
    public
      PackageType: TPackageType;
      Stop: boolean;
      OnError: TOnError;
      OnErrorObj: TOnErrorObj;
      OnProgress: TOnProgress;
      OnProgressObj: TOnProgressObj;
      FileName: string;
      Stream: TStream;
      StreamMethods: TStreamMethods;

      class function IsFormat(FileName: string): boolean; overload; virtual; abstract;
      class function IsFormat(Stream: TStream): boolean; overload; virtual; abstract;

      constructor Create(); overload; virtual; abstract;
      destructor Destroy; override; abstract;

      function GetItemSize(Item: integer): TItemSize; virtual; abstract;
      function GetItemPath(Item: integer): string; virtual; abstract;
      function GetItemByPath(Path: string): integer; virtual; abstract;

      function _LoadFromFile(FileName: string): boolean; virtual; abstract;
      function LoadFromStream(Stream: TStream): boolean; virtual; abstract;

      property ItemSize[Item: integer]: TItemSize read GetItemSize;
      property ItemPath[Item: integer]: string read GetItemPath;
      property ItemByPath[Item: string]: integer read GetItemByPath;

      function OpenFile(FileName: string; Access: byte): TStream; overload; virtual; abstract;
      function OpenFile(Item: integer; Access: byte): TStream; overload; virtual; abstract;

    {private
      function Read(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize; virtual; abstract;
      function Write(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize; virtual; abstract;
      procedure SetFileSize(Strm: TStream; Size: TStrmSize); virtual; abstract;
      procedure CloseFile(Strm: TStream; Flag: ulong = 0); virtual; abstract;}

    public
      class function LoadFromFile(FileName, Common: string): TPackage; virtual;
  end;

implementation

uses
  GCFFile, PAKFile, VPKFile;

class function TPackage.LoadFromFile(FileName, Common: string): TPackage;
begin
  if (TGCFFile.IsGCF(FileName)) then result:=TPackage(TGCFFile.Create(Common))
  else if (TPAKFile.IsPAK(FileName)) then result:=TPackage(TPAKFile.Create())
  else if (TVPKFile.IsVPK(FileName)) then result:=TPackage(TVPKFile.Create())
  else result:=nil;
  if (result<>nil) then
    result._LoadFromFile(FileName);
end;

end.
