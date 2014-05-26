unit utils;

interface

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils;

{$IFDEF LOGING}
procedure Log(Mes: string);
{$ENDIF}

function GetSteamFileName(var FileName: string): boolean;
function ConvertDate(FileTime: TFileTime): integer;
function strrchr(const str: pAnsiChar; c: pAnsiChar): pAnsiChar;
function memcpy(dst: Pointer; const src: Pointer; len: integer): Pointer;
function strcpy(dst: PAnsiChar; const src: PAnsiChar): PAnsiChar;

var
  ProgDir: string;
  Extracted: boolean = true;
  //ini: pIniFile;
{$IFDEF LOGING}
  //переменные, отвечающие за ведение логов...
  LOGING_ACCOUNT: boolean = true;
  LOGING_CALLING: boolean = true;
  LOGING_INIT: boolean = true;
  LOGING_LOGING: boolean = true;
  LOGIN_MINIDUMP: boolean = true;
  LOGING_MISK: boolean = true;
  LOGING_USERID: boolean = true;
  LOGING_FILESYSTEM: boolean = true;
  LOGING_FILESYSTEM_ALL: boolean = true;
{$ENDIF}

implementation

const                                                       //1217958702 = $4898932E
  FileTimeDelta = VclDate0+25569;

function ConvertDate(FileTime: TFileTime): integer;
var
  t: integer;
begin
  t:=int64(FileTime)-116444736000000000;
  result:=trunc(t/10000000)-FileTimeDelta;

  //FileTime2DateTime(FileTime, d);
  //result:=Trunc(d)+FileTimeDelta;
  //result:=DateTimeToFileDate(d);
  //result:=DateTimeToFileDate(d-FileTimeDelta);
end;

function strrchr(const str: pAnsiChar; c: pAnsiChar): pAnsiChar;
var
  len: Integer;
begin
  len:=Length(str);
  Result:=str+len;
  while len<>0 do
  begin
    if Result[0]=c then
      Exit;
    Dec(Result);
    Dec(len);
  end;
  Result:=nil;
end;

function memcpy(dst: Pointer; const src: Pointer; len: integer): Pointer;
begin
  Move(src^, dst^, len);
  Result := dst;
end;

function strcpy(dst: PAnsiChar; const src: PAnsiChar): PAnsiChar;
begin
  Result := memcpy(dst, src, Length(src) + 1);
end;

{$IFDEF LOGING}
procedure Log(Mes: string);
var
  s: string;
  l: TStream;
  i, len: integer;
begin
  //if l=nil then
  begin
    l:=TStream.CreateFileStream(ProgDir+'log.txt', ofOpenReadWrite);
    l.Seek(l.Size, spBegin);
  end;
  s:=Parse(Mes, ':');
  if Mes<>'' then
  begin
    len:=Length(s);
    SetLength(s, 40+2+Length(Mes));
    for i:=len+1 to 42 do
      s[i]:=' ';
    s[41]:=':';
    s[42]:=#9;
    Move(Mes[1], s[43], Length(Mes)*2);
  end;
    //s:=Format('%40s :'+#9+'%s', [s, Mes]);
  l.WriteWideStr(s);
  l.Free;
end;
{$ENDIF}

function GetSteamFileName(var FileName: string): boolean;
begin
  result:=true;
  {if FileExists(FileName) then FileName:=FileName
    else }if FileExists(ProgDir+FileName) then FileName:=ProgDir+FileName
      else if FileExists(ProgDir+'bin\'+FileName) then FileName:=ProgDir+'bin\'+FileName
        else result:=false;
end;

procedure InitiateLibrary;
var
 // _tmp: array[0..254] of char;
  //s: string;
{$IFDEF LOGING}
  l: TStream;
{$ENDIF}
begin
  {GetModuleFileName(0, _tmp, 255);
  ProgDir:=IncludeTrailingPathDelimiter(ExtractFilePath(_tmp));  }

  (*s:='Emu.ini';
  if GetSteamFileName(s) then
  begin
    Ini:=OpenIniFile(s);
{$IFDEF LOGING}
    ini.Section:='Loging';
    LOGING_FILESYSTEM:=ini.ValueBoolean('FileSystem', false);
    LOGING_ACCOUNT:=ini.ValueBoolean('Account', false);
    if not LOGING_FILESYSTEM then
      LOGING_FILESYSTEM_ALL:=false
        else LOGING_FILESYSTEM_ALL:=true;
{$ENDIF}
    Ini.Section:='Emulator';
    Extracted:=ini.ValueBoolean('Extracted', true);
  end;   *)

{$IFDEF LOGING}
  l:=TStream.CreateFileStream(ProgDir+'log.txt', ofOpenReadWrite);
  l.Seek(l.Size, spBegin);
  if l.Size<>0 then
    l.WriteWideStr(#13#10#13#10#13#10);
  l.WriteWideStr(Date2StrFmt('yyyy.MM.dd: ', Now)+Time2StrFmt('hh.mm.ss', Now)+
   ' - andreil© Alpha-Emulator (work in pogress...)'+#13#10);
  l.Free;
{$ENDIF}

{$IFDEF RESOURCER}
  ResourcesList:=NewStrList;
{$ENDIF}
end;

procedure DeinitializeLibrary;
{$IFDEF RESOURCER}
{var
  i, n: integer;
  s: string; }
{$ENDIF}
begin
  //ini.Free;
{$IFDEF RESOURCER}
  {i:=0;
  repeat
    s:=ResourcesList.Items[i];
    ResourcesList.Items[i]:='';
    repeat
      n:=ResourcesList.IndexOf(s);
      ResourcesList.Delete(n);
    until n=-1;
    ResourcesList.Items[i]:=s;
    inc(i);
  until i>=ResourcesList.Count-1;   }
  ResourcesList.SaveToFile(ProgDir+'ResourcesList.txt');
  ResourcesList.Free;
{$ENDIF}
end;


initialization
  InitiateLibrary;

finalization
  DeinitializeLibrary;


end.
