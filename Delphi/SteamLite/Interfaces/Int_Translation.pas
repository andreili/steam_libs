unit Int_Translation;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): ITranslation; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  pLanguageRec = ^TLanguageRec;
  TLanguageRec = record
    Name,
    Value: string;
  end;

  {$IFDEF SL_ONE}
  TTranslation = class (CBaseClass, ITranslation)
  {$ELSE}
  TTranslation = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function SetLanguage(Name: pChar): boolean; virtual; stdcall;
    function GetTitle(Name: pChar): pChar; virtual; stdcall;
    function GetLanguagesList(): pChar; virtual; stdcall;
  private
    fLangName: pChar;
    fLang: TList;
    procedure ClearList();
  end;

implementation

{$IFDEF SL_ONE}
function LoadInterface(): ITranslation;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TTranslation.Create();
end;

function TTranslation.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TTranslation.GetType(): EInterfaceType;
begin
  result:=INTERFACE_TRANSLATION;
end;

function TTranslation.Init(): boolean;
begin
  fLang:=TList.Create();
  SetLanguage(Core.Settings.GetStringValue(VALUE_LANGUAGE));
  result:=true;
end;

procedure TTranslation.DeInit();
begin
  ClearList();
  fLang.Free;
  fLangName:='';
end;

function TTranslation.SetLanguage(Name: pChar): boolean; stdcall;
var
  rec: pLanguageRec;
  str: TStream;
  s: string;
begin
  result:=false;
  fLang.Clear;
  str:=TStream.CreateReadFileStream('.\Files\Languages\'+Name+'.lng');
  if str.Handle=INVALID_HANDLE_VALUE then
  begin
    str.Free;
    Exit;
  end;
  while (str.Position<str.Size) do
  begin
    s:=str.ReadStrWide();
    if (IndexOfChar(s, '=')=-1) then
    begin
      if (s='') or (s[1]=';') then continue
        else break;
    end;
    New(rec);
    rec.Name:=Parse(s, '=');
    rec.Value:=s;
    s:='';
    fLang.Add(rec);
  end;
  str.Free;
  fLangName:=Name;
  result:=(fLang.Count>0);
end;

function TTranslation.GetTitle(Name: pChar): pChar; stdcall;
var
  i, l: integer;
begin
  result:='';
  l:=fLang.Count;
  for i:=0 to l-1 do
    if (CompareStr_NoCase(Name, pLanguageRec(fLang[i]).Name)=0) then
    begin
      result:=pChar(pLanguageRec(fLang[i]).Value);
      break;
    end;
  if (result='') then
  begin
    result:=Name;
    //writeln(Name);
  end;
end;

function TTranslation.GetLanguagesList(): pChar;
var
  s, s1: string;
begin
  s:=GetStartDir()+'Files\Languages\';
  s1:=Core.Utils.GetFileList(pChar(s), '*.lng');
  while StrReplace(s1, s, '') do;
  while StrReplace(s1, '.lng', '') do;
  s:='';
  result:=pChar(s1);
end;

procedure TTranslation.ClearList();
var
  i, l: integer;
begin
  l:=fLang.Count;
  for i:=0 to l-1 do
  begin
    pLanguageRec(fLang[i]).Name:='';
    pLanguageRec(fLang[i]).Value:='';
  end;
  fLang.Clear();
end;


end.
