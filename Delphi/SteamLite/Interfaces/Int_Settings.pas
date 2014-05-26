unit Int_Settings;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): ISettings; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TSettings = class (CBaseClass, ISettings)
  {$ELSE}
  TSettings = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function GetStringValue(ValueID: uint32): pChar; virtual; stdcall;
    procedure SetStringValue(ValueID: uint32; Value: pChar); virtual; stdcall;
    function GetBooleanValue(ValueID: uint32): boolean; virtual; stdcall;
    procedure SetBooleanValue(ValueID: uint32; Value: boolean); virtual; stdcall;

    function Get_Log_All_Levels(): uint32; virtual; stdcall;
  private
    fSettingsIni: TIniFile;
  end;

implementation

{$IFDEF SL_ONE}
function LoadInterface(): ISettings;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TSettings.Create();
end;

function TSettings.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TSettings.GetType(): EInterfaceType;
begin
  result:=INTERFACE_SETTINGS;
end;

function TSettings.Init(): boolean;
begin
  fSettingsIni:=TIniFile.Create('.\Files\Settings.ini');
  result:=true;
end;

procedure TSettings.DeInit();
begin
  fSettingsIni.Free;
end;

function TSettings.GetStringValue(ValueID: uint32): pChar; stdcall;
begin
  if (ValueID and SECTION_GENERAL=SECTION_GENERAL) then fSettingsIni.Section:='General';
  if (ValueID and SECTION_NETWORK=SECTION_NETWORK) then fSettingsIni.Section:='Network';
  if (ValueID and SECTION_LOG=SECTION_LOG) then fSettingsIni.Section:='Log';

  case (ValueID) of
    VALUE_CACHE_PATH: result:=pChar(IncludeTrailingPathDelimiter(fSettingsIni.ValueString('CachePath', '')));
    VALUE_USER_PATH: result:=pChar(IncludeTrailingPathDelimiter(fSettingsIni.ValueString('UserPath', '')));
    VALUE_LOG_LEVEL: result:=pChar(fSettingsIni.ValueString('Level', Int2Str(LOG_LEVEL_SHOW_INFOS or LOG_LEVEL_SHOW_ERRORS)));
    VALUE_LANGUAGE: result:=pChar(fSettingsIni.ValueString('Language', 'Russian'));
    VALUE_SERVER_ADDR: result:=pChar(fSettingsIni.ValueString('ServerAddr', 'gds1.steampowered.com:27030'));
    VALUE_MAXWORKS:
      begin
        result:=pChar(fSettingsIni.ValueString('MaxWorksCount', '2'));
        if (Core.WorksList<>nil) then
          Core.WorksList.SetMaxWorks(Str2Int(result));
      end;
    else result:='';
  end;
end;

procedure TSettings.SetStringValue(ValueID: uint32; Value: pChar); stdcall;
begin
  fSettingsIni.Mode:=ifmWrite;
  if (ValueID and SECTION_GENERAL=SECTION_GENERAL) then fSettingsIni.Section:='General';
  if (ValueID and SECTION_NETWORK=SECTION_NETWORK) then fSettingsIni.Section:='Network';
  if (ValueID and SECTION_LOG=SECTION_LOG) then fSettingsIni.Section:='Log';

  case (ValueID) of
    VALUE_CACHE_PATH: fSettingsIni.ValueString('CachePath', Value);
    VALUE_USER_PATH: fSettingsIni.ValueString('UserPath', Value);
    VALUE_LANGUAGE: fSettingsIni.ValueString('Language', Value);
    VALUE_SERVER_ADDR:  fSettingsIni.ValueString('ServerAddr', Value);
    VALUE_LOG_LEVEL: fSettingsIni.ValueString('Level', Value);
    VALUE_MAXWORKS: fSettingsIni.ValueString('MaxWorksCount', Value);
  end;
  fSettingsIni.Mode:=ifmRead;
end;

function TSettings.GetBooleanValue(ValueID: uint32): boolean; stdcall;
begin
 if (ValueID and SECTION_GENERAL=SECTION_GENERAL) then fSettingsIni.Section:='General';
  if (ValueID and SECTION_NETWORK=SECTION_NETWORK) then fSettingsIni.Section:='Network';
  if (ValueID and SECTION_LOG=SECTION_LOG) then fSettingsIni.Section:='Log';

  case (ValueID) of
    VALUE_UPDATE_CDR: result:=fSettingsIni.ValueBoolean('UpdateCDR', true);
    VALUE_LOG_CDR: result:=fSettingsIni.ValueBoolean('CDR', false);
    VALUE_LOG_CACHES: result:=fSettingsIni.ValueBoolean('LoadingCaches', true);
    VALUE_LOG_GAMES: result:=fSettingsIni.ValueBoolean('LoadingGames', true);
    VALUE_SHOWDEMO: result:=fSettingsIni.ValueBoolean('ShowDemoApps', true);
    VALUE_SHOWTEST: result:=fSettingsIni.ValueBoolean('ShowTestApps', true);
    else result:=true;
  end;
end;

procedure TSettings.SetBooleanValue(ValueID: uint32; Value: boolean);
begin
  fSettingsIni.Mode:=ifmWrite;
  if (ValueID and SECTION_GENERAL=SECTION_GENERAL) then fSettingsIni.Section:='General';
  if (ValueID and SECTION_NETWORK=SECTION_NETWORK) then fSettingsIni.Section:='Network';
  if (ValueID and SECTION_LOG=SECTION_LOG) then fSettingsIni.Section:='Log';

  case (ValueID) of
    VALUE_UPDATE_CDR: fSettingsIni.ValueBoolean('UpdateCDR', Value);
    VALUE_LOG_CDR: fSettingsIni.ValueBoolean('CDR', Value);
    VALUE_LOG_CACHES: fSettingsIni.ValueBoolean('LoadingCaches', Value);
    VALUE_LOG_GAMES: fSettingsIni.ValueBoolean('LoadingGames', Value);
    VALUE_SHOWDEMO: fSettingsIni.ValueBoolean('ShowDemoApps', Value);
    VALUE_SHOWTEST: fSettingsIni.ValueBoolean('ShowTestApps', Value);
  end;
  fSettingsIni.Mode:=ifmRead;
end;

function TSettings.Get_Log_All_Levels(): uint32;
begin
  result:=Str2Int(GetStringValue(VALUE_LOG_LEVEL));
end;



end.
