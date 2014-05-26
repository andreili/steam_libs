unit Int_Log;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): ILog; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  TEvent = record
    Caption,
    Result: pChar;
  end;

  {$IFDEF SL_ONE}
  TLog = class (CBaseClass, ILog)
  {$ELSE}
  TLog = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function AddEvent(Caption: pChar): integer; virtual; stdcall;
    procedure AddEventEx(Caption, Res: pChar); virtual; stdcall;
    procedure SetEventResult(EventIdx: integer; Res: pChar); virtual; stdcall;
    function GetEventCaption(EventIdx: integer): pChar; virtual; stdcall;
    function GetEventResult(EventIdx: integer): pChar; virtual; stdcall;
    procedure DeleteTmpEvent(EventIdx: integer); virtual; stdcall;
  private
    fEvents: array of TEvent;
    procedure AddLineToFile(Line: pChar); stdcall;
  end;

implementation

var
  Sem: THandle;

{$IFDEF SL_ONE}
function LoadInterface(): ILog;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TLog.Create();
end;

function TLog.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TLog.GetType(): EInterfaceType;
begin
  result:=INTERFACE_LOG;
end;

function TLog.Init(): boolean;
begin
  SetLength(fEvents, 0);
  result:=true;
end;

procedure TLog.DeInit();
var
  i, l: integer;
begin
  WaitForSingleObject(Sem, INFINITE);
  l:=Length(fEvents);
  for i:=0 to l-1 do
  begin
    fEvents[i].Caption:='';
    fEvents[i].Result:='';
  end;
  SetLength(fEvents, 0);
  ReleaseSemaphore(Sem, 1, nil);
end;

function TLog.AddEvent(Caption: pChar): integer;
var
  i, l, Idx: integer;
begin
  WaitForSingleObject(Sem, INFINITE);
  //Writeln(Wide2OEM(Caption));
  l:=Length(fEvents);
  Idx:=-1;
  for i:=0 to l-1 do
    if (fEvents[i].Caption='') then
    begin
      Idx:=i;
      break;
    end;
  if (Idx=-1) then
  begin
    SetLength(fEvents, l+1);
    fEvents[l].Caption:='';
    fEvents[l].Result:='';
    Idx:=l;
  end;

  fEvents[Idx].Caption:=Caption;
  AddLineToFile(Caption);
  result:=Idx;
  {if (Core.UI<>nil) then
    Core.UI.AddLogEvent(result); }
  ReleaseSemaphore(Sem, 1, nil);
end;

procedure TLog.AddEventEx(Caption, Res: pChar);
var
  Idx: integer;
begin
  Idx:=AddEvent(Caption);
  SetEventResult(Idx, Res);
  //Core.UI.AddLogEvent(Idx);
  DeleteTmpEvent(Idx);
end;

procedure TLog.SetEventResult(EventIdx: integer; Res: pChar);
begin
  WaitForSingleObject(Sem, INFINITE);
  if EventIdx<Length(fEvents) then
  begin
    fEvents[EventIdx].Result:=Res;
    AddLineToFile(pChar(fEvents[EventIdx].Caption+' : '+Res));
    {if (Core.UI<>nil) then
      Core.UI.SetLogEventResult(EventIdx);  }
  end;
  ReleaseSemaphore(Sem, 1, nil);
end;

function TLog.GetEventCaption(EventIdx: integer): pChar;
begin
  if EventIdx<Length(fEvents) then result:=fEvents[EventIdx].Caption
    else result:='';
end;

function TLog.GetEventResult(EventIdx: integer): pChar;
begin
  if EventIdx<Length(fEvents) then result:=fEvents[EventIdx].Result
    else result:='';
end;

procedure TLog.DeleteTmpEvent(EventIdx: integer);
begin
  if EventIdx<Length(fEvents) then
  begin
    fEvents[EventIdx].Result:='';
    fEvents[EventIdx].Caption:='';
  end;
end;

procedure TLog.AddLineToFile(Line: pChar); stdcall;
var
  n: TDateTime;
  fStream: TStream;
begin
  fStream:=TStream.CreateReadWriteFileStream('.\log.txt');
  fSTream.Position:=fSTream.Size;
  n:=Now();
  fStream.WriteWideStr(Format('%-25s: %s'#13#10, [Date2StrFmt('dd.MM.yyyy', n)+Time2StrFmt(':HH.mm.ss', n), Line]));
  fStream.Free;
end;

initialization
  Sem:=CreateSemaphore(nil, 1, 1, 'Sem_Log');

finalization
  CloseHandle(Sem);

end.
