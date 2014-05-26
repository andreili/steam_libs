unit FileSystem;

interface

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils,
    utils, SteamTypes, Steam_Misc;

type
  TFileInCache = record
      GcfID,
      FileHandle: integer;
      Size,
      Position: ulong;
    end;

  TFS = class
    public
      fFile: TStream;

      {GcfCount: ulong;
      Gcfs: array of TGCFFile; }

      function OpenFileEx(FileName, Mode: string; Size: puint; pError: pSteamError): SteamHandle_t;
      function FlushFile(hFile: SteamHandle_t; pError: PSteamError): int;
      function CloseFile(hFile: SteamHandle_t; pError: PSteamError): int;
      //function Getc(hFile: SteamHandle_t; pError: PSteamError): int;
      //function Putc(cChar: int; hFile: SteamHandle_t; pError: PSteamError): int;
      function ReadFile(pBuf: PByte; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint;
      function WriteFile(pBuf: Pointer; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint;
      function SeekFile(hFile: SteamHandle_t; lOffset: ulong; esMethod: ESteamSeekMethod; pError: PSteamError): int;
      function SizeFile(hFile: SteamHandle_t; pError: PSteamError): int;
      function TellFile(hFile: SteamHandle_t; pError: PSteamError): uint32;
      //procedure FillInfo(Gcf: TGCFFile; Handle: ulong; pInfo: pSteamElemInfo);
      function Stat(FileName: string; pInfo: PSteamElemInfo; pError: PSteamError): int;
      function GetLocalFileCopy(FileName: string; pError: PSteamError): int;

      function FindFirst(Pattern: string; eFilter: ESteamFindFilter; pFindInfo: PSteamElemInfo; pError: PSteamError): SteamHandle_t;
      function FindNext(hFind: SteamHandle_t; pFindInfo: PSteamElemInfo; pError: PSteamError): int;
      function FindClose(hFind: SteamHandle_t; pError: PSteamError): int;

      function GetCacheDefaultDirectory(Path: string; pError: PSteamError): int;
      function SetCacheDefaultDirectory(Path: string; pError: PSteamError): int;

      function MountGcf(FileName, Path: string): boolean;
      function GetItemFromPath(FileName: string): TFileInCache;
      procedure ExtractFile(FileName: string);

      procedure UnMountAll;
    end;

var
  FS: TFS;

implementation


function TFS.OpenFileEx(FileName, Mode: string; Size: puint; pError: pSteamError): SteamHandle_t;
var
  FileMode, Creation: ulong;
begin
  result:=0;
    
  FileName:=FixSlashes(LowerCase(FileName));
  if IndexOfStr(FileName, '|all_source_engine_paths|')<>-1 then
    StrReplace(FileName, '|all_source_engine_paths|', '');
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamOpenFileEx: FileName = '+FileName+#13#10);
{$ENDIF}
  if FileName[2]<>':' then
    FileName:=ProgDir+FileName;
  if FileExists(FileName) then
    Creation:=ofOpenExisting
      else Creation:=ofCreateAlways;
  if (Mode='r') or (Mode='rb') or (Mode='rt') then FileMode:=ofOpenRead or ofShareDenyWrite or ofOpenExisting
    else if (Mode='b') or (Mode='wb') or (Mode='wt') then FileMode:=ofOpenWrite or ofCreateAlways or ofShareDenyWrite
      else if (Mode='a') or (Mode='ab') then FileMode:=ofOpenReadWrite or Creation or ofShareDenyWrite
        else if (Mode='r+') or (Mode='rb+') or (Mode='r+') or (Mode='rt+') or (Mode='r+t') then FileMode:=ofOpenReadWrite or Creation or ofShareDenyWrite
          else if (Mode='w+') or (Mode='wb+') or (Mode='w+b') then FileMode:=ofOpenWrite or ofCreateAlways or ofShareDenyWrite
            else if (Mode='a+') or (Mode='ab+') or (Mode='a+b') then FileMode:=ofOpenReadWrite or Creation or ofShareDenyWrite
              else FileMode:=ofOpenRead or ofShareDenyWrite or ofOpenExisting;
  fFile:=TStream.CreateFileStream(FileName, FileMode);
  if (fFile<>nil) then
    if fFile.Handle<>INVALID_HANDLE_VALUE then
    begin
{$IFDEF RESOURCER}
      ResourcesList.Add(FileName);
{$ENDIF}
      result:=ulong(fFile);
    end;
  if result<>0 then
  begin
    //size^:=fFile.Stream.Size;
    if Size<>nil then
    begin
      Size^:=SizeFile(ulong(fFile), pError);
      if IndexOfChar(Mode, 'a')<>-1 then
        Self.SeekFile(ulong(fFile), Size^, eSteamSeekMethodSet, pError);
    end;
    SteamClearError(pError);
  end;
end;

function TFS.FlushFile(hFile: SteamHandle_t; pError: PSteamError): int;  
begin
  result:=1;
end;

function TFS.CloseFile(hFile: SteamHandle_t; pError: PSteamError): int;  
begin
  fFile:=TStream(hFile);
  fFile.Free;
  result:=1;
end;

{function TFS.Getc(hFile: SteamHandle_t; pError: PSteamError): int;
begin
end;

function TFS.Putc(cChar: int; hFile: SteamHandle_t; pError: PSteamError): int;
begin
end; }

function TFS.ReadFile(pBuf: PByte; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint;
begin
  result:=TStream(hFile).Read(pBuf^, uSize*uCount)//result:=FileRead(fFile.Handle, pBuf^, uSize*uCount)
end;

function TFS.WriteFile(pBuf: Pointer; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint;  
begin
  result:=TStream(hFile).Write(pBuf^, uSize*uCount)//result:=FileWrite(fFile.Handle, pBuf, uSize*uCount)
end;

function TFS.SeekFile(hFile: SteamHandle_t; lOffset: ulong; esMethod: ESteamSeekMethod; pError: PSteamError): int;
begin
  result:=TStream(hFile).Seek(lOffset, TMoveMethod(esMethod))//result:=SetFilePointer(fFile.Handle, lOffset, nil, ulong(esMethod))//FileSeek(fFile.Handle, lOffset, TMoveMethod(esMethod))
end;

function TFS.SizeFile(hFile: SteamHandle_t; pError: PSteamError): int; 
begin
  result:=TStream(hFile).Size//result:=GetFileSize(fFile.Handle, nil)
end;

function TFS.TellFile(hFile: SteamHandle_t; pError: PSteamError): uint32;
begin 
  result:=TStream(hFile).Position//result:=FileSeek(fFile.Handle, 0, spCurrent)
end;

{procedure TFS.FillInfo(Gcf: TGCFFile; Handle: ulong; pInfo: pSteamElemInfo);
var
  Item: TCache_ManifestNode;
  str: AnsiString;
begin
  Item:=Gcf.ManifestEntry[Handle];
  if (Item.Attributes and HL_GCF_FLAG_FILE)<>0 then
  begin
    pInfo.bIsDir:=0;
    pInfo.uSizeOrCount:=Item.CountOrSize;
  end
    else
  begin  
    pInfo.bIsDir:=1;
    pInfo.uSizeOrCount:=0;
  end;  
  pInfo.bIsLocal:=0;
  str:=Gcf.ItemPath[Handle];
  strcpy(pInfo^.cszName, pAnsiChar(str));
  pInfo.lLastAccessTime:=$FECC;
  pInfo.lLastModificationTime:=$FECC;
  pInfo^.lCreationTime:=$FECC;
end;   }

function TFS.Stat(FileName: string; pInfo: PSteamElemInfo; pError: PSteamError): int;
var
  FindHandle: ulong;
  Find: TWin32FindData;  
  cszPeriod: pAnsiChar;
begin
  if IndexOfStr(FileName, '|all_source_engine_paths|')<>-1 then
    StrReplace(FileName, '|all_source_engine_paths|', '');
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamStat: '+FileName+#13#10);
{$ENDIF}
  FindHandle:=FindFirstFile(pChar(FileName), Find);
  if FindHandle<>INVALID_HANDLE_VALUE then
  begin
{$IFDEF RESOURCER}
    ResourcesList.Add(cszFileName);
{$ENDIF}
    if Find.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY=FILE_ATTRIBUTE_DIRECTORY then
        pInfo.IsDir:=1
          else pInfo.IsDir:=0;
    pInfo.IsLocal:=1;
    pInfo.CreationTime:=ConvertDate(Find.ftCreationTime);
    pInfo.LastAccessTime:=ConvertDate(Find.ftLastAccessTime);
    pInfo.LastModificationTime:=ConvertDate(Find.ftLastWriteTime);
    pInfo.SizeOrCount:=Find.nFileSizeLow;

    cszPeriod:=strrchr(pAnsiChar(Wide2Ansi(FileName)), '\');
    if cszPeriod<>nil then strcpy(pInfo.Name, cszPeriod+1)
      else strcpy(pInfo.Name, pAnsiChar(Wide2Ansi(FileName)));
    //strcpy(pInfo^.cszName, Find.cFileName);
    SteamClearError(pError);
    result:=0;
    Windows.FindClose(FindHandle);
  end
    else result:=-1;
end;

function TFS.GetLocalFileCopy(FileName: string; pError: PSteamError): int;
begin    
  result:=0;
  if IndexOfStr(FileName, '|all_source_engine_paths|')<>-1 then
    StrReplace(FileName, '|all_source_engine_paths|', '');
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamGetLocalFileCopy: FileName = '+FileName+#13#10);
{$ENDIF}
  FS.ExtractFile(FileName);
  if FileName[2]<>':' then
  begin
    FileName:=ProgDir+FileName;
{$IFDEF RESOURCER}
    ResourcesList.Add(FileName);
{$ENDIF}
    if FileExists(FileName) then
      result:=1;
  end
    else if FileExists(FileName) then result:=1;
end;

function TFS.FindFirst(Pattern: string; eFilter: ESteamFindFilter; pFindInfo: PSteamElemInfo; pError: PSteamError): SteamHandle_t;
var
  FindHandle: ulong;
  FindData: TWin32FindData; 
  pFind: PFindRecord;
begin  
  result:=STEAM_INVALID_HANDLE;
  if IndexOfStr(Pattern, '|all_source_engine_paths|')<>-1 then
    StrReplace(Pattern, '|all_source_engine_paths|', '');
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamFindFirst: '+Pattern+#13#10);
{$ENDIF}
  FindHandle:=FindFirstFile(pChar(Pattern), FindData);
  if FindHandle<>INVALID_HANDLE_VALUE then
  begin
    pFindInfo.CreationTime:=ConvertDate(FindData.ftCreationTime);
    pFindInfo.LastAccessTime:=ConvertDate(FindData.ftLastAccessTime);
    pFindInfo.LastModificationTime:=ConvertDate(FindData.ftLastWriteTime);
    pFindInfo.SizeOrCount:=FindData.nFileSizeLow;

    if FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY=FILE_ATTRIBUTE_DIRECTORY then pFindInfo.IsDir:=1
      else pFindInfo.IsDir:=0;
    pFindInfo.IsLocal:=1;

    strcpy(@pFindInfo.Name[0], pAnsiChar(Wide2Ansi(FindData.cFileName)));

    New(pFind);
    pFind^.IsLocalSearch:=true;
    pFind.FindHandle:=FindHandle;
    strcpy(pFind.Mask, pAnsiChar(Wide2Ansi(Pattern)));
    SteamClearError(pError);
    result:=SteamHandle_t(pFind);
  end
end;

function TFS.FindNext(hFind: SteamHandle_t; pFindInfo: PSteamElemInfo; pError: PSteamError): int;
var
  pFind: PFindRecord;
  FindData: TWin32FindData;  
begin                      
  result:=-1;
  pFind:=PFindRecord(hFind);
  if pFind.IsLocalSearch then
  begin
    if FindNextFile(pFind.FindHandle, FindData) then
    begin  
      pFindInfo.CreationTime:=ConvertDate(FindData.ftCreationTime);
      pFindInfo.LastAccessTime:=ConvertDate(FindData.ftLastAccessTime);
      pFindInfo.LastModificationTime:=ConvertDate(FindData.ftLastWriteTime);
      pFindInfo.SizeOrCount:=FindData.nFileSizeLow;

      if FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY=FILE_ATTRIBUTE_DIRECTORY then pFindInfo.IsDir:=1
        else pFindInfo.IsDir:=0;
      pFindInfo.IsLocal:=1;

      strcpy(pFindInfo.Name, pAnsiChar(Wide2Ansi(FindData.cFileName)));

      result:=0;
    end;
  end
end;

function TFS.FindClose(hFind: SteamHandle_t; pError: PSteamError): int;   
begin    
  result:=0;
  if PFindRecord(hFind).IsLocalSearch then
  begin
    SteamClearError(pError);
    if Windows.FindClose(pFindRecord(hFind).FindHandle) then
      result:=1;
  end
end;

function TFS.GetCacheDefaultDirectory(Path: string; pError: PSteamError): int;
begin   
  result:=1;
end;

function TFS.SetCacheDefaultDirectory(Path: string; pError: PSteamError): int;
begin   
  SteamClearError(pError);
  result:=1;
end;  

function TFS.MountGcf(FileName, Path: string): boolean;
{var
  i: ulong;
  bad: boolean; }
begin
{$IFDEF LOGING}
  Log('Mount GCF-Cache: '+ExtractFileName(FileName)+#13#10);
{$ENDIF}
 { result:=false;
  if Path<>'' then
    FileName:=IncludetrailingPathDelimiter(Path)+FileName;
  bad:=false;
  if GcfCount>0 then
    for i:=0 to GcfCount-1 do
      if StrComp_NoCase(pAnsiChar(Gcfs[i].FileName), pAnsiChar(FileName))=0 then
        bad:=true;
  if not bad then
  begin
    inc(GcfCount);
    SetLength(Gcfs, GcfCount);
    Gcfs[GcfCount-1]:=TGCFFile.Create();
    Gcfs[GcfCount-1].LoadFromFile(FileName);
    if Gcfs[GcfCount-1].FileVersion<>6 then
    begin
      MessageBox(0, pAnsiChar('Не могу смонтировать GCF-файл'+#13#10+FileName),
       pAnsiChar('Ошибка:'), MB_ICONERROR or MB_APPLMODAL);
      dec(GcfCount);
      SetLength(Gcfs, GcfCount);
    end;
    result:=true;
  end; }
  result:=false;
end;

function TFS.GetItemFromPath(FileName: string): TFileInCache;
{var
  i: ulong; }
begin
  {result.GcfID:=-1;
  result.FileHandle:=-1;
  StrReplace(FileName, ProgDir, '');
  StrReplace(FileName, LowerCase(ProgDir), '');
  if GcfCount>0 then
    for i:=0 to GcfCount-1 do
    begin
      result.FileHandle:=Gcfs[i].ItemByPath[FileName];
      if result.FileHandle<>-1 then
      begin
        result.Size:=Gcfs[I].ManifestEntry[result.FileHandle].CountOrSize;
        result.GcfID:=i;
        result.Position:=0;
        Exit;
      end;
    end; }
end;

procedure TFS.ExtractFile(FileName: string);
{var
  Handle: TFileInCache;     }
begin
{  Handle:=GetItemFromPath(FileName);
  if Handle.GcfID>-1 then
    Gcfs[Handle.GcfID].ExtractFile(Handle.FileHandle, FileName);    }
end;

procedure TFS.UnMountAll;
{var
  i: ulong; }
begin
{  if GcfCount>0 then
    for i:=0 to GcfCount-1 do
    begin
      Gcfs[i].Free;
      Free_And_Nil(Gcfs[i]);
    end;
  GcfCount:=0;  }
end;    

initialization
  FS:=TFS.Create();
  //FS.GcfCount:=0;

finalization
  FS.UnMountAll;
  FS.Free;

end.
