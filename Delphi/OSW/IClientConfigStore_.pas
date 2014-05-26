unit IClientConfigStore_;

interface

uses
  SteamTypes, UtilsCommon;

const
  CLIENTCONFIGSTORE_INTERFACE_VERSION = 'CLIENTCONFIGSTORE_INTERFACE_VERSION001';

type
  IClientConfigStore = class
    function IsSet(eConfigStore: EConfigStore; keyName: pAnsiChar): bool; virtual; abstract;

    function GetBool(eConfigStore: EConfigStore; keyName: pAnsiChar): bool; virtual; abstract;
    function GetInt(eConfigStore: EConfigStore; keyName: pAnsiChar): int; virtual; abstract;
    function GetUint64(eConfigStore: EConfigStore; keyName: pAnsiChar): uint64; virtual; abstract;
    function GetFloat(eConfigStore: EConfigStore; keyName: pAnsiChar): float; virtual; abstract;
    function GetString(eConfigStore: EConfigStore; keyName: pAnsiChar): pAnsiChar; virtual; abstract;
    function GetBinary(eConfigStore: EConfigStore; keyName: pAnsiChar; pBuffer: puint8; uSize: uint32): bool; virtual; abstract;
    function GetBinaryWatermarked(eConfigStore: EConfigStore; keyName: pAnsiChar; pBuffer: puint8; uSize: uint32): bool; virtual; abstract;

    procedure SetBool(eConfigStore: EConfigStore; keyName: pAnsiChar; Value: bool); virtual; abstract;
    procedure SetInt(eConfigStore: EConfigStore; keyName: pAnsiChar; Value: int); virtual; abstract;
    procedure SetUint64(eConfigStore: EConfigStore; keyName: pAnsiChar; Value: uint64); virtual; abstract;
    procedure SetFloat(eConfigStore: EConfigStore; keyName: pAnsiChar; Value: float); virtual; abstract;
    procedure SetString(eConfigStore: EConfigStore; keyName: pAnsiChar; Value: pAnsiChar); virtual; abstract;
    procedure SetBinary(eConfigStore: EConfigStore; keyName: pAnsiChar; pBuffer: puint8; uSize: uint32); virtual; abstract;
    procedure SetBinaryWatermarked(eConfigStore: EConfigStore; keyName: pAnsiChar; pBuffer: puint8; uSize: uint32); virtual; abstract;

    procedure RemoveKey(eConfigStore: EConfigStore; keyName: pAnsiChar); virtual; abstract;
    function GetKeySerialized(eConfigStore: EConfigStore; keyName: pAnsiChar; pBuffer: puint8; uSize: uint32): bool; virtual; abstract;
  end;

implementation

end.
