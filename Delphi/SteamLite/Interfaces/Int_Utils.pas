unit Int_Utils;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils, ShellAPI;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): IUtils; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TUtils = class (CBaseClass, IUtils)
  {$ELSE}
  TUtils = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function GetFileList(dir, mask: pChar): pChar; virtual; stdcall;

    function GetDPNE(DPNEComplette: pChar; DPNEDif: pChar): pChar; virtual; stdcall;
    function AddExt(FileName, Ext: pChar): pChar; virtual; stdcall;
    function GetDrives(): pChar; virtual; stdcall;
    function GetTypeDrives(CharDrives: char): TTypeDrives; virtual; stdcall;
    function GetDrivesEx(TypeDrives: TTypeDrives): pChar; virtual; stdcall;
    function GetSizeTitle(Size: int64): pChar; virtual; stdcall;
    function RoundMax(Num: real; Max: integer): real; virtual; stdcall;
    //function uncompress(dest: Pointer; destLen: ulong; source: pAnsiChar; sourceLen: ulong): ulong; virtual; stdcall;
    function GetFileDate(FileName: pChar): TDateTime; virtual; stdcall;
    function GetIconByExt(Ext: string; var SmallIcon: HICON; var Descr: string): HICON; virtual; stdcall;
    function GetDiskFreeSpace(Drive: pChar): int64; virtual; stdcall;
  end;

implementation

{$IFDEF SL_ONE}
function LoadInterface(): IUtils;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TUtils.Create();
end;

function TUtils.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TUtils.GetType(): EInterfaceType;
begin
  result:=INTERFACE_UTILS;
end;

function TUtils.Init(): boolean;
begin
  result:=true;
end;

procedure TUtils.DeInit();
begin
end;

function TUtils.GetFileList(dir, mask: pChar): pChar;
var
  FindData: TWin32FindData;
  FindHandle: THandle;
  find: boolean;
  w_dir, w_mask, s: String;
begin
  result:='';
  w_mask:=mask ;
  if w_mask='' then
    w_mask:='*.*';
  w_dir:=IncludeTrailingPathDelimiter(dir);
  FindData.dwFileAttributes:=FILE_ATTRIBUTE_NORMAL;
  FindHandle:=FindFirstFile(PChar(w_dir+w_mask), FindData);
  if FindHandle<>INVALID_HANDLE_VALUE then
  begin
    find:=true;
    while find do
    begin
      s:=FindData.cFileName;
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY<>FILE_ATTRIBUTE_DIRECTORY) then
        result:=pChar(result+w_dir+s+#13);
      find:=FindNextFile(FindHandle, FindData);
    end;
  end;
end;

function TUtils.GetDPNE(DPNEComplette: pChar; DPNEDif: pChar): pChar;
var
  dl, n: LongInt;
  Mas: array [0..3] of string;
   // 1-Path; 2-Name; 3-Ext
  uk, First: Byte;
  SExt: string;
  dif: string;
begin
  result:='';
  try
    dl:=Length(DPNEComplette);
    for uk:=0 to 3 do mas[uk]:='';
    if (DPNEComplette[1]='"')and(DPNEComplette[dl]='"') then
    begin
      First:=1;
      dec(dl);
    end
      else First:=0;
    uk:=3;
    for n:=dl downto First do
    begin
      if uk=0 then
        mas[0]:=DPNEComplette[n]+mas[0];
      if uk=1 then
      begin
        if DPNEComplette[n]<>':' then mas[1]:=DPNEComplette[n]+mas[1]
          else dec(Uk);
      end;
      if uk=2 then
      begin
        if DPNEComplette[n]<>'\' then Mas[2]:=DPNEComplette[n]+mas[2]
          else dec(uk);
      end;
      if uk=3 then
      begin
        if DPNEComplette[n]=':' then
        begin
          mas[1]:=mas[3];
          mas[3]:='';
          dec(uk);
          Dec(uk);
          Dec(Uk);
        end
          else if DPNEComplette[n]='\' then
        begin
          mas[2]:=mas[3];
          mas[3]:='';
          dec(uk);
          dec(uk);
        end
          else if DPNEComplette[n]<>'.' then Mas[3]:=DPNEComplette[n]+mas[3]
           else dec(uk);
      end;
    end;
    if mas[3]='' then SExt:=''
      else SExt:='.'+mas[3];
    dif:=LowerCase(DPNEDif);
    if (dif='d')or(Dif='disk') then Result:=pChar(mas[0])
    else if (dif='p')or(Dif='path') then Result:=pChar(mas[1])
    else if (dif='dp')or(Dif='disk_path') then Result:=pChar(mas[0]+':'+mas[1])
    else if (dif='n')or(Dif='name') then Result:=pChar(mas[2])
    else if (dif='e')or(Dif='ext') then Result:=pChar(mas[3])
    else if (dif='pn')or(Dif='path_name') then Result:=pChar(mas[1]+'\'+mas[2])
    else if (dif='dpn')or(Dif='disk_path_name') then Result:=pChar(mas[0]+':'+mas[1]+'\'+mas[2])
    else if (dif='ne')or(Dif='name_ext') then Result:=pChar(mas[2]+SExt)
    else if (dif='pne')or(Dif='path_name_ext') then Result:=pChar(mas[1]+'\'+mas[2]+SExt)
    else if (dif='dpne')or(Dif='disk_path_name_ext') then Result:=pChar(mas[0]+':'+mas[1]+'\'+mas[2]+SExt);
  except
    Result:='';
  end;
end;

function TUtils.AddExt(FileName, Ext: pChar): pChar;
var
  exts: array [1..255] of string;
  n, kol: integer;
  f: boolean;
  s: string;
begin
  try
    kol:=1;
    exts[1]:='';
    for n:=1 to Length(ext) do
    begin
      if ext[n]<>'/' then exts[kol]:=exts[kol]+ext[n]
        else
      begin
        inc(kol);
        exts[kol]:='';
      end;
    end;
    if exts[1]='' then
      exts[1]:=ext;
    f:=False;
    for n:=1 to kol do
    begin
      if GetDPNE(FileName,'Ext')=Exts[n] then
        f:=True;
    end;
    if not F then s:=GetDPNE(FileName,'Disk_Path_Name')+'.'+Exts[1]
      else s:=FileName;
  except
    s:=FileName;
  end;
  result:=pChar(s);
end;

function TUtils.GetDrives(): pChar;
var
  DriveBits: set of 0..25;
  DriveNum: integer;
  DriveChar: char;
  s: string;
begin
  s:='';
  Integer(DriveBits):=GetLogicalDrives();
  for DriveNum:=0 to 25 do
    if DriveNum in DriveBits then
    begin
      DriveChar := Chr(DriveNum + Ord('a'));
      s:=s+DriveChar;
    end;
  result:=pChar(s);
end;

function TUtils.GetTypeDrives(CharDrives: char): TTypeDrives;
var
  k: integer;
  str: string;
begin
  str:=CharDrives+ ':\';
  k:=GetDriveType(PChar(str));
  case k of
    DRIVE_CDROM : result:=tdCD;
    DRIVE_REMOVABLE: result:=tdFlopy;
    DRIVE_FIXED: result:=tdHDD;
    DRIVE_REMOTE: result:=tdRemote;
    DRIVE_RAMDISK: result:=tdRamDisk;
    else result:=tdNone;
  end;
end;

function TUtils.GetDrivesEx(TypeDrives: TTypeDrives): pChar;
var
  TempList: pChar;
  i: integer;
  ch: Char;
  s: string;
begin
  s:='';
  TempList:=GetDrives();
  for i:=0 to (length(TempList) div 2)-1 do
  begin
    ch:=TempList[i];
    if GetTypeDrives(ch)=TypeDrives then
      s:=s+ch;
  end;
  result:=pChar(s);
end;

function TUtils.GetSizeTitle(Size: int64): pChar;
begin
  if Size>=GBYTE then result:=pChar(Double2Str(RoundMax(Size/GBYTE, 100))+' '+Core.Translation.GetTitle('#GBytes'))
    else if Size>=MBYTE then result:=pChar(Double2Str(RoundMax(Size/MBYTE, 100))+' '+Core.Translation.GetTitle('#MBytes'))
      else if Size>=KBYTE then result:=pChar(Double2Str(RoundMax(Size/KBYTE, 100))+' '+Core.Translation.GetTitle('#KBytes'))
        else result:=pChar(Int64_2Str(i64(Size))+' '+Core.Translation.GetTitle('#Bytes'));
end;

function TUtils.RoundMax(Num: real; Max: integer): real;
begin
  result:=Round(num*Max + 0.5)/Max;
end;

function TUtils.GetFileDate(FileName: pChar): TDateTime;
var
  Find: TWin32FindData;
  FindHandle: THandle;
begin
  FindHandle:=FindFirstFile(pChar(FileName), Find);
  if FindHandle<>INVALID_HANDLE_VALUE then
  begin
    FileTime2DateTime(Find.ftLastWriteTime, result);
  end
    else result:=0;
end;

function ReadReg(root: HKEY; key: string): string;
var
  resKey: HKEY;
  DataType, DataSize: integer;
begin
  result:='';
  if RegOpenKeyEx(root, pChar(key), 0, KEY_ALL_ACCESS, resKey)=ERROR_SUCCESS then
    if RegQueryValueEx(resKey, '', nil, @DataType, nil, @DataSize)=ERROR_SUCCESS then
    begin
      SetLength(result, DataSize);
      if RegQueryValueEx(resKey, '', nil, @DataType, @result[1], @DataSize)<>ERROR_SUCCESS then
        result:='';
      SetLength(Result, Length(PChar(Result)));
    end;
end;

type
  pIconRec = ^TIconRec;
  TIconRec = record
    Icon,
    SmallIcon: HICON;
    Ext,
    Descr: string;
  end;

var
  WinDir: array[0..MAX_PATH] of char;
  Icons: TList;

function FindIcon(Ext: string): pIconRec;
var
  i: integer;
begin
  for i:=0 to Icons.Count-1 do
    if CompareStr_NoCase(pIconRec(Icons[i])^.Ext, Ext)=0 then
    begin
      result:=Icons[i];
      Exit;
    end;
  result:=nil;
end;

function TUtils.GetIconByExt(Ext: string; var SmallIcon: HICON; var Descr: string): HICON;
var
  IconIdx: integer;
  FileName, s: string;
  rec: pIconRec;
begin
  rec:=FindIcon(Ext);
  if rec<>nil then
  begin
    SmallIcon:=rec^.SmallIcon;
    Descr:=rec^.Descr;
    result:=rec^.Icon;
    Exit;
  end;

  IconIdx:=1;
  Descr:='';
  FileName:='';
  Descr:=ReadReg(HKEY_CLASSES_ROOT, Ext);
  FileName:=ReadReg(HKEY_CLASSES_ROOT, Descr+'\DefaultIcon');

  if IndexOfStr(FileName, ',')>0 then
  begin
    s:=FileName;
    FileName:=Parse(s, ',');
    IconIdx:=Str2Int(s);
  end;
  if (FileName<>'') and (FileName[1]='"') then
  begin
    Delete(FileName, 1, 1);
    Delete(FileName, Length(FileName), 1);
  end;

  if not FileExists(FileName) then
    StrReplace(FileName, '%SystemRoot%', WinDir);
  if not FileExists(FileName) then
    FileName:=WinDir+'\system32\shell32.dll';
  if ExtractIconEx(pChar(FileName), IconIdx, result, SmallIcon, 1)<>1 then
  begin
    //ExtractIconEx(pChar(FileName), 0, result, SmallIcon, 1);
  end;
  new(rec);
  rec^.Icon:=result;
  rec^.SmallIcon:=SmallIcon;
  rec^.Ext:=Ext;
  rec^.Descr:=Descr;
  Icons.Add(rec);
end;

function TUtils.GetDiskFreeSpace(Drive: pChar): int64;
type
  TGetDFSEx = function(Path: pChar; CallerFreeBytes, TotalBytes, FreeBytes: Pointer): Bool; stdcall;
var
  GetDFSEx: TGetDFSEx;
  Kern32: THandle;
  V: TOSVersionInfo;
  Ex: Boolean;
  SectorsPerCluster, BytesPerSector, NumberOfFreeClusters, TNC: DWORD;
  FBA, TNB: int64;
begin
  GetDFSEx:=nil;
  V.dwOSVersionInfoSize:=Sizeof(V);
  GetVersionEx(POSVersionInfo(@V)^); // bug in Windows.pas !
  Ex:=FALSE;
  if V.dwPlatformId=VER_PLATFORM_WIN32_NT then
  begin
    Ex:=V.dwMajorVersion>=4;
  end
    else if V.dwPlatformId=VER_PLATFORM_WIN32_WINDOWS then
  begin
    Ex:=V.dwMajorVersion>4;
    if not Ex then
      if V.dwMajorVersion=4 then
      begin
        Ex:=V.dwMinorVersion>0;
        if not Ex then
          Ex:=LoWord(V.dwBuildNumber)>=$1111;
      end;
  end;
  if Ex then
  begin
    Kern32:=GetModuleHandle('kernel32');
    GetDFSEx:=GetProcAddress(Kern32, 'GetDiskFreeSpaceExW');
  end;
  if Assigned(GetDFSEx) then GetDFSEx(Drive, @FBA, @TNB, @Result)
    else
  begin
    Windows.GetDiskFreeSpace(Drive, SectorsPerCluster, BytesPerSector, NumberOfFreeClusters, TNC);
    Result:=SectorsPerCluster*BytesPerSector*NumberOfFreeClusters;
  end;
end;

var
  i: integer;
  rec: pIconRec;

initialization
  GetWindowsDirectory(WinDir, MAX_PATH);
  Icons:=TList.Create();

finalization
  for i:=0 to Icons.Count-1 do
  begin
    rec:=Icons[i];
    rec^.Ext:='';
    rec^.Descr:='';
  end;

end.
