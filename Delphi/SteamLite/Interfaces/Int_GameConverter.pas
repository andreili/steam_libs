unit Int_GameConverter;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): IGameConverter; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TGameConverter = class (CBaseClass, IGameConverter)
  {$ELSE}
  TGameConverter = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;

    procedure PrepareApplication(Application: IApplication); virtual; stdcall;
    function ExtractApplication(Application: IApplication; DstFolder: pChar; IsStandAlone: boolean): EConvertResult; virtual; stdcall;
    function Convert(Application: IApplication; Emulator: EEmulator; IsExtracted: boolean): EConvertResult; virtual; stdcall;
    function Launch(Application: IApplication; AppId: uint32): EConvertResult; virtual; stdcall;
  private
  end;

implementation

{$IFDEF SL_ONE}
function LoadInterface(): IGameConverter;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TGameConverter.Create();
end;

function TGameConverter.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TGameConverter.GetType(): EInterfaceType;
begin
  result:=INTERFACE_GAME_CONVERTER;
end;

function TGameConverter.Init(): boolean;
begin
  result:=true;
end;

procedure TGameConverter.DeInit();
begin
end;

procedure TGameConverter.PrepareApplication(Application: IApplication);
begin
end;

function TGameConverter.ExtractApplication(Application: IApplication; DstFolder: pChar; IsStandAlone: boolean): EConvertResult;
begin
end;

function TGameConverter.Convert(Application: IApplication; Emulator: EEmulator; IsExtracted: boolean): EConvertResult;
begin
end;

function TGameConverter.Launch(Application: IApplication; AppId: uint32): EConvertResult;
begin
end;


end.
