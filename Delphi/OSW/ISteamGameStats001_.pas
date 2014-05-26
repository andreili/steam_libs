unit ISteamGameStats001_;

interface

uses
  SteamTypes, GameStatsCommon;

type
  ISteamGameStats001 = class
    function GetNewSession(nAccountType: int8; ullAccountID: uint64; nAppID: AppId_t; rtTimeStarted: RTime32): SteamAPICall_t; virtual; abstract;
    function EndSession(ulSessionID: uint64; rtTimeEnded: RTime32; nReasonCode: int16): SteamAPICall_t; virtual; abstract;

    function AddSessionAttributeInt(ulSessionID: uint64; pstrName: pAnsiChar; nData: int): EResult; virtual; abstract;
    function AddSessionAttributeString(ulSessionID: uint64; pstrName: pAnsiChar; pstrData: pAnsiChar): EResult; virtual; abstract;
    function AddSessionAttributeFloat(ulSessionID: uint64; pstrName: pAnsiChar; fData: float): EResult; virtual; abstract;

    function AddNewRow(var pulRowID: uint64; ulSessionID: uint64; pstrTableName: pAnsiChar): EResult; virtual; abstract;

    function CommitRow(ulRowID: uint64): EResult; virtual; abstract;
    function CommitOutstandingRows(ulSessionID: uint64): EResult; virtual; abstract;

    function AddRowAttributeInt(ulRowID: uint64; pstrName: pAnsiChar; iData: int): EResult; virtual; abstract;
    function AddRowAtributeString(ulRowID: uint64; pstrName: pAnsiChar; pstrData: pAnsiChar): EResult; virtual; abstract;
    function AddRowAttributeFloat(ulRowID: uint64; pstrName: pAnsiChar; fData: float): EResult; virtual; abstract;

    function AddSessionAttributeInt64(ulSessionID: uint64; pstrName: pAnsiChar; llData: int64): EResult; virtual; abstract;
    function AddRowAttributeInt64(ulRowID: uint64; pstrName: pAnsiChar; llData: int64): EResult; virtual; abstract;
  end;

implementation

end.
