unit Int_FileFormats;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): IFileFormats; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TFileFormats = class (CBaseClass, IFileFormats)
  {$ELSE}
  TFileFormats = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function GetFileFormat(FileName: pChar): IFileFormat; virtual; stdcall;
    function GetStreamFormat(Stream: TStream): IFileFormat; virtual; stdcall;
    function LoadFromFile(FileName: pChar): IFile; virtual; stdcall;
    function LoadFromStream(Stream: TStream): IFile; virtual; stdcall;
  private
    fFormats: array of IFileFormat;
  end;

implementation

uses
  Int_FileFormat_GCF{$IFDEF SL_ONE} {$ENDIF};

{$IFDEF SL_ONE}
function LoadInterface(): IFileFormats;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TFileFormats.Create();
end;

function TFileFormats.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TFileFormats.GetType(): EInterfaceType;
begin
  result:=INTERFACE_FILE_FORMATS;
end;

function TFileFormats.Init(): boolean;
var
  FF: IFileFormat;

  procedure Add();
  var
    l: integer;
  begin
    l:=Length(fFormats);
    SetLength(fFormats, l+1);
    fFormats[l]:=FF;
  end;
begin
  SetLength(fFormats, 0);
  // загрузка всех форматов файлов
  {$IFDEF SL_ONE}
    FF:=Int_FileFormat_GCF.LoadInterface();
    FF.Init;
    Add();
  {$ELSE}
  {$ENDIF}
  result:=true;
end;

procedure TFileFormats.DeInit();
var
  i, l: integer;
begin
  l:=Length(fFormats);
  for i:=0 to l-1 do
    fFormats[i].DeInit;
  SetLength(fFormats, 0);
end;

function TFileFormats.GetFileFormat(FileName: pChar): IFileFormat;
var
  i, l: integer;
begin
  result:=nil;
  l:=Length(fFormats);
  for i:=0 to l-1 do
    if (fFormats[i].TestFile(FileName)) then
    begin
      result:=IFileFormat(fFormats[i]);
      break;
    end;
end;

function TFileFormats.GetStreamFormat(Stream: TStream): IFileFormat;
var
  i, l: integer;
begin
  result:=nil;
  l:=Length(fFormats);
  for i:=0 to l-1 do
    if (fFormats[i].TestStream(Stream)) then
    begin
      result:=IFileFormat(fFormats[i]);
      break;
    end;
end;

function TFileFormats.LoadFromFile(FileName: pChar): IFile;
var
  format: IFileFormat;
begin
  format:=GetFileFormat(FileName);
  if (format<>nil) then result:=format.LoadFromFile(FileName)
    else result:=nil;
end;

function TFileFormats.LoadFromStream(Stream: TStream): IFile;
begin
  result:=GetStreamFormat(Stream).LoadFromStream(Stream);
end;


end.
