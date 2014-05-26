unit Int_File;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}
        (*
{$IFDEF SL_ONE}
function LoadInterface(): IFile; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TFile = class (CBaseClass, IFile)
  {$ELSE}
  TFile = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function LoadFromFile(FileName: pChar): boolean; virtual; stdcall;
    function LoadFromStream(Stream: TStream): boolean; virtual; stdcall;
    function GetMainStream(): TStream; virtual; stdcall;
    function GetFileType(): EFileType; virtual; stdcall;
    function OpenFile(FileName: pChar; Mode: byte): TStream; virtual; stdcall;
  end;
          *)
implementation
          (*
{$IFDEF SL_ONE}
function LoadInterface(): IFile;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TFile.Create();
end;

function TFile.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TFile.GetType(): EInterfaceType;
begin
  result:=INTERFACE_FILE_FORMATS;
end;

function TFile.Init(): boolean;
begin
  result:=true;
end;

procedure TFile.DeInit();
begin
end;

function TFile.LoadFromFile(FileName: pChar): boolean;
begin
  result:=false;
end;

function TFile.LoadFromStream(Stream: TStream): boolean;
begin
  result:=false;
end;

function TFile.GetMainStream(): TStream;
begin
  result:=nil;
end;

function TFile.GetFileType(): EFileType;
begin
end;

function TFile.OpenFile(FileName: pChar; Mode: byte): TStream;
begin
end;          *)

end.
