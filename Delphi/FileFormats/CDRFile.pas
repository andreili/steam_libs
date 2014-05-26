unit CDRFile;

interface

uses
  Windows, USE_Types, USE_Utils, BLOBFile;

const
  Langs: array[0..12] of string = ('French', 'Italian', 'German', 'Spanish',
   'Korean', 'sChinese', 'Koreana', 'tChinese', 'Japanese', 'Russian', 'Thai', 'Portuguese', 'English');

type
  {$I TypLib_CDR.inc}
  TCDR = class
    private
      VersionNumber: ushort;
      //LastChangedExistingAppOrSubscriptionTime,
      //IndexAppIdToSubscriptionIdsRecord: uint32;
      fBLOB: TBLOBFile;

      Subscriptions: array of TSubscriptionRecord;
      PublicKeys: array of TPublicKey;

      function GetAppRecordById(AppId: uint32): pAppRecord;
      procedure LoadFromStream(Stream: TStream);
      // CDR
      procedure EnumerateAppRecords(Node: pBLOBNode);
      procedure EnumerateSubscription(Node: pBLOBNode);
      procedure EnumerateAllAppsPublicKeysRecord(Node: pBLOBNode);
      //procedure EnumerateAllAppsEncryptedPrivateKeysRecord(Node: pBLOBNode);
    public
      AppRecords: array of TAppRecord;

      constructor Create(FileName: string); overload;
      constructor Create(Stream: TStream); overload;
      destructor Destroy; override;

      property AppRecord[AppId: uint32]: pAppRecord read GetAppRecordById;
  end;

implementation

const
  NodeMagicNum = $5001;
  NodeMagicNumComp = $4301;
  //ESteamBlobNodeType
  Key    = 1;
  Value  = 2;
  //ESteamBlobNodeType
  eCRDVersionNumber = 0;
  eCRDApplicationsRecord = 1;
  eCRDSubscriptionsRecord = 2;
  eCRDLastChangedExistingAppOrSubscriptionTime = 3;
  eCRDIndexAppIdToSubscriptionIdsRecord = 4;
  eCRDAllAppsPublicKeysRecord = 5;
  eCRDAllAppsEncryptedPrivateKeysRecord = 6;
  //EFileSystemFields
  eFSRAppId = 1;
  eFSRMountName = 2;
  eFSRIsOptional = 3;
  //ELaunchOptionRecordFields
  eLODescription = 1;
  eLOCommandLine = 2;
  eLOIconIndex = 3;
  eLONoDesktopShortcut = 4;
  eLONoStartMenuShortcut = 5;
  eLOLongRunningUnattended = 6;
  //EVersionRecordFields
  eVRDescription = 1;
  eVRVersionId = 2;
  eVRIsNotAvailable = 3;
  eVRLaunchOptionIdsRecord = 4;
  eVRDepotEncryptionKey = 5;
  eVRIsEncryptionKeyAvailable = 6;
  eVRIsRebased = 7;
  eVRIsLongVersionRoll = 8;
  //EApplicationFields
  eAppAppId = 1;
  eAppName = 2;
  eAppInstallDirName = 3;
  eAppMinCacheFileSizeMB = 4;
  eAppMaxCacheFileSizeMB = 5;
  eAppLaunchOptionsRecord = 6;
  eAppAppIconsRecord = 7;
  eAppOnFirstLaunch = 8;
  eAppIsBandwidthGreedy = 9;
  eAppVersionsRecord = 10;
  eAppCurrentVersionId = 11;
  eAppFilesystemRecords = 12;
  eAppTrickleVersionId = 13;
  eAppUserDefinedRecords = 14;
  eAppBetaVersionPassword = 15;
  eAppBetaVersionId = 16;
  eAppLegacyInstallDirName = 17;
  eAppSkipMFPOverwrite = 18;
  eAppUseFilesystemDvr = 19;
  eAppManifestOnlyApp = 20;
  eAppAppOfManifestOnlyCache = 21;
  //ESubscriptionFields
	eSubSubscriptionId = 1;
	eSubName = 2;
	eSubBillingType = 3;
	eSubCostInCents = 4;
	eSubPeriodInMinutes = 5;
	eSubAppIds = 6;
	eSubRunAppId = 7;
	eSubOnSubscribeRunLaunchOptionIndex = 8;
	eSubRateLimitRecord = 9;
	eSubDiscounts = 10;
	eSubIsPreorder = 11;
	eSubRequiresShippingAddress = 12;
	eSubDomesticCostInCents = 13;
	eSubInternationalCostInCents = 14;
	eSubRequiredKeyType = 15;
	eSubIsCyberCafe = 16;
	eSubGameCode = 17;
	eSubGameCodeDescription = 18;
	eSubIsDisabled = 19;
	eSubRequiresCD = 20;
	eSubTerritoryCode = 21;
	eSubIsSteam3Subscription = 22;
	eSubExtendedInfoRecords = 23;

constructor TAppRecord.Create();
begin
  inherited Create();
  IsBandwidthGreedy:=false;
  SkipMFPOverwrite:=false;
  UseFilesystemDvr:=false;
  ManifestOnlyApp:=false;
  AppId:=0;
  Name:='';
  InstallDirName:='';
  MinCacheFileSizeMB:=0;
  MaxCacheFileSizeMB:=0;
  LaunchOptionRecords:=nil;
  IconRecordCount:=0;
  IconsRecord:=nil;
  OnFirstLaunch:=0;
  VersionsRecord:=nil;
  CurrentVersionId:=0;
  FilesystemsRecords:=nil;
  TrickleVersionId:=0;
  UserDefinedRecordCount:=0;
  UserDefinedRecords:=nil;
  LanguagesCount:=0;
  Languages:=nil;
  BetaVersionPassword:='';
  BetaVersionId:=0;
  LegacyInstallDirName:='';
  AppOfManifestOnlyCache:=0;
end;

destructor TAppRecord.Destroy();
var
  i: integer;
begin
  if Length(VersionsRecord)>0 then
    for i:=0 to Length(VersionsRecord)-1 do
      SetLength(VersionsRecord[i].LaunchOptionIdsRecord, 0);
  SetLength(IconsRecord, 0);
  SetLength(LaunchOptionRecords, 0);
  SetLength(VersionsRecord, 0);
  SetLength(FilesystemsRecords, 0);
  SetLength(UserDefinedRecords, 0);
  SetLength(Languages, 0);
  inherited Destroy();
end;

function TAppRecord.GetUDR(Name: AnsiString): AnsiString;
var
  i: integer;
begin
  result:='';
  if UserDefinedRecordCount>0 then
    for i:=0 to UserDefinedRecordCount-1 do
      if (CompareStr_NoCase(Ansi2Wide(UserDefinedRecords[i].Name), Ansi2Wide(Name))=0) then
      begin
        result:=UserDefinedRecords[i].Value;
        Exit;
      end;
end;

function TAppRecord.GetCMD(): AnsiString;
begin
  result:=LaunchOptionRecords[Length(LaunchOptionRecords)-1].CommandLine;
end;

function TAppRecord.DecryptKey(VersionID: uint32): AnsiString;
begin
  result:='';
  if Length(VersionsRecord)>integer(VersionID) then
    Exit;
  result:=VersionsRecord[VersionID].DepotEncryptionKey;
end;

function TAppRecord.IsCache(): boolean;
var
  i: integer;
begin
  result:=false;
  if (AppId=ulong(-1)) then
    Exit;
  //result:= (App^.MinCacheFileSizeMB=App^.MaxCacheFileSizeMB);
  result:= (Length(FilesystemsRecords)=0) or (IsMedia());
  if Length(FilesystemsRecords)>0 then
    for i:=0 to Length(FilesystemsRecords)-1 do
      if FilesystemsRecords[i].AppId=AppId then
        result:=true;
  if not result then
    result:=(Name=LegacyInstallDirName);
  {if not result then
    result:=MinCacheFileSizeMB>0;
  {if AppId=312 then
    result:=false;
 { result:= (App^.FilesystemsRecords.Count=0) or (CDR.GetUserRecord(App, 'ismediafile')='1');
  if (App^.AppId=0) or (App^.AppId=3) or (App^.AppId=7) then
    result:=true;    }
end;

function TAppRecord.IsApp(): boolean;
var
  i: integer;
begin
  result:=false;
  if (AppId=ulong(-1)) then
    Exit;
  //result:= (App^.MinCacheFileSizeMB=App^.MaxCacheFileSizeMB);
  result:= (Length(FilesystemsRecords)>0) or (IsMedia());
  if (Length(FilesystemsRecords)=1) and (FilesystemsRecords[0].AppId=AppId) then
    result:=false;
 { result:= (App^.FilesystemsRecords.Count=0) or (CDR.GetUserRecord(App, 'ismediafile')='1');
  if (App^.AppId=0) or (App^.AppId=3) or (App^.AppId=7) then
    result:=true;    }
end;

function TAppRecord.IsMedia(): boolean;
begin
  result:=(GetUDR('ismediafile')='1');
end;

function TAppRecord.IsTool(): boolean;
begin
  result:=(GetUDR('state')='eStateTool');
end;

constructor TCDR.Create(FileName: string);
var
  Stream: TStream;
  i: integer;
begin
  Stream:=TStream.CreateReadFileStream(FileName);
  if Stream.Handle=INVALID_HANDLE_VALUE then
    Exit;
  LoadFromStream(Stream);
  Stream.Free;
  for i:=0 to length(PublicKeys)-1 do
  //  if PublicKeys[i].ID=561 then
    begin
      Stream:=TStream.CreateWriteFileStream('.\keys\'+Int2Str(PublicKeys[i].ID)+'.bin');
      Stream.Write(PublicKeys[i].Key[0], 160);
      Stream.Free;
    end;
end;

constructor TCDR.Create(Stream: TStream);
begin
  inherited Create();
  LoadFromStream(Stream);
end;

destructor TCDR.Destroy;
var
  i: integer;
begin
  if Length(AppRecords)>0 then
    for i:=0 to Length(AppRecords)-1 do
      AppRecords[i].Free;
  SetLength(AppRecords, 0);
  SetLength(Subscriptions, 0);
  SetLength(PublicKeys, 0);
  inherited Destroy();
end;

procedure TCDR.LoadFromStream(Stream: TStream);
begin
  fBLOB:=TBLOBFile.Create(Stream);
  VersionNumber:=pword(fBLOB.RootNode[eCRDVersionNumber].Data)^;
  EnumerateAppRecords(fBLOB.RootNode[eCRDApplicationsRecord]);
  EnumerateSubscription(fBLOB.RootNode[eCRDSubscriptionsRecord]);
  //LastChangedExistingAppOrSubscriptionTime:=UINT32FromData(fBLOB.RootNode[eCRDLastChangedExistingAppOrSubscriptionTime]);
  //IndexAppIdToSubscriptionIdsRecord:=UINT32FromData(fBLOB.RootNode[eCRDIndexAppIdToSubscriptionIdsRecord]);
  EnumerateAllAppsPublicKeysRecord(fBLOB.RootNode[eCRDAllAppsPublicKeysRecord]);
  //EnumerateAllAppsEncryptedPrivateKeysRecord(fBLOB.RootNode[eCRDAllAppsEncryptedPrivateKeysRecord]);
  fBLOB.Free;
end;

procedure TCDR.EnumerateAppRecords(Node: pBLOBNode);
var
  i, len: integer;
  AppNode: pBLOBNode;

  procedure ReadLaunchOptionsRecords(Rec: pAppRecord; Node: pBLOBNode);
  var
    i1, len: integer;
  begin
    if Node=nil then
      Exit;
    len:=Node^.Childrens;
    if len=0 then
      Exit;
    SetLength(Rec^.LaunchOptionRecords, len);
    for i1:=0 to len-1 do
      with Rec^.LaunchOptionRecords[i1] do
      begin
        Description:=StringFromData(Node^.Children[i1]^[eLODescription]);
        CommandLine:=StringFromData(Node^.Children[i1]^[eLOCommandLine]);
        IconIndex:=UINT32FromData(Node^.Children[i1]^[eLOIconIndex]);
        NoDesktopShortcut:=BoolFromData(Node^.Children[i1]^[eLONoDesktopShortcut]);
        NoStartMenuShortcut:=BoolFromData(Node^.Children[i1]^[eLONoStartMenuShortcut]);
        LongRunningUnattended:=BoolFromData(Node^.Children[i1]^[eLOLongRunningUnattended]);
      end;
  end;
  {procedure ReadIconRecords(Rec: pAppRecord; Node: pBLOBNode);
  var
    i1, len: integer;
  begin
    if Node=nil then
      Exit;
    len:=Node^.Childrens;
    if len=0 then
      Exit;
    Rec^.IconRecordCount:=len;
    SetLength(Rec^.IconsRecord, len);
    for i1:=0 to len-1 do
      with Rec^.IconsRecord[i1] do
      begin
      end;
  end;   }
  procedure ReadVersionRecords(Rec: pAppRecord; Node: pBLOBNode);
    procedure ReadLOIDs(VR: pAppVersionRecord; Node: pBLOBNode);
    var
      i1, len: integer;
    begin
      len:=Node^.Childrens;
      if len=0 then
        Exit;
      VR^.LaunchOptionIdsRecordCount:=len;
      SetLength(VR^.LaunchOptionIdsRecord, len);
      for i1:=0 to len-1 do
        VR^.LaunchOptionIdsRecord[i1]:=UINT32FromData(Node^.Children[i1]^[0]);
    end;
  var
    i1, len: integer;
  begin
    if Node=nil then
      Exit;
    len:=Node^.Childrens;
    if len=0 then
      Exit;
    SetLength(Rec^.VersionsRecord, len);
    for i1:=0 to len-1 do
      with Rec^.VersionsRecord[i1] do
      begin
        Description:=StringFromData(Node^.Children[i1]^[eVRDescription]);
        VersionId:=UINT32FromData(Node^.Children[i1]^[eVRVersionId]);
        IsNotAvailable:=BoolFromData(Node^.Children[i1]^[eVRIsNotAvailable]);
        ReadLOIDs(@Rec^.VersionsRecord[i1], Node^.Children[i1]^[eVRLaunchOptionIdsRecord]);
        DepotEncryptionKey:=StringFromData(Node^.Children[i1]^[eVRDepotEncryptionKey]);
        IsEncryptionKeyAvailable:=BoolFromData(Node^.Children[i1]^[eVRIsEncryptionKeyAvailable]);
        IsRebased:=BoolFromData(Node^.Children[i1]^[eVRIsRebased]);
        IsLongVersionRoll:=BoolFromData(Node^.Children[i1]^[eVRIsLongVersionRoll]);
      end;
  end;
  procedure ReadFileSystemRecords(Rec: pAppRecord; Node: pBLOBNode);
  var
    i1, len: integer;
  begin
    if Node=nil then
      Exit;
    len:=Node^.Childrens;
    if len=0 then
      Exit;
    SetLength(Rec^.FilesystemsRecords, len);
    for i1:=0 to len-1 do
      with Rec^.FilesystemsRecords[i1] do
      begin
        AppId:=UINT32FromData(Node^.Children[i1]^[eFSRAppId]);
        MountName:=StringFromData(Node^.Children[i1]^[eFSRMountName]);
        IsOptional:=BoolFromData(Node^.Children[i1]^[eFSRIsOptional]);
      end;
  end;
  procedure ReadUserDefinedRecords(Rec: pAppRecord; Node: pBLOBNode);
  var
    i1, len: integer;
  begin
    if Node=nil then
      Exit;
    len:=Node^.Childrens;
    if len=0 then
      Exit;
    Rec^.UserDefinedRecordCount:=len;
    SetLength(Rec^.UserDefinedRecords, len);
    for i1:=0 to len-1 do
      with Rec^.UserDefinedRecords[i1] do
      begin
        Name:=Copy(Node^.Children[i1].Name, 1, Length(Node^.Children[i1].Name));
        Value:=StringFromData(Node^.Children[i1])
      end;
  end;

begin
  len:=Node^.Childrens;
  SetLength(AppRecords, len);
  for i:=0 to len-1 do
  begin
    AppNode:=Node^.Children[i];
    AppRecords[i]:=TAppRecord.Create();
    with AppRecords[i] do
    begin
      //Writeln(i);
      AppId:=UINT32FromData(AppNode^[eAppAppId]);
      Name:=StringFromData(AppNode^[eAppName]);
      InstallDirName:=StringFromData(AppNode^[eAppInstallDirName]);
      MinCacheFileSizeMB:=UINT32FromData(AppNode^[eAppMinCacheFileSizeMB]);
      MaxCacheFileSizeMB:=UINT32FromData(AppNode^[eAppMaxCacheFileSizeMB]);
      ReadLaunchOptionsRecords(@AppRecords[i], AppNode^[eAppLaunchOptionsRecord]);
      //ReadIconRecords(@AppRecords[i], AppNode^[eAppAppIconsRecord]);
      OnFirstLaunch:=UINT32FromData(AppNode^[eAppOnFirstLaunch]);
      IsBandwidthGreedy:=BoolFromData(AppNode^[eAppIsBandwidthGreedy]);
      ReadVersionRecords(@AppRecords[i], AppNode^[eAppVersionsRecord]);
      CurrentVersionId:=UINT32FromData(AppNode^[eAppCurrentVersionId]);
      ReadFileSystemRecords(@AppRecords[i], AppNode^[eAppFilesystemRecords]);
      TrickleVersionId:=UINT32FromData(AppNode^[eAppTrickleVersionId]);
      ReadUserDefinedRecords(@AppRecords[i], AppNode^[eAppUserDefinedRecords]);
      BetaVersionPassword:=StringFromData(AppNode^[eAppBetaVersionPassword]);
      BetaVersionId:=UINT32FromData(AppNode^[eAppBetaVersionId]);
      LegacyInstallDirName:=StringFromData(AppNode^[eAppLegacyInstallDirName]);
      SkipMFPOverwrite:=BoolFromData(AppNode^[eAppSkipMFPOverwrite]);
      UseFilesystemDvr:=BoolFromData(AppNode^[eAppSkipMFPOverwrite]);
      ManifestOnlyApp:=BoolFromData(AppNode^[eAppManifestOnlyApp]);
      AppOfManifestOnlyCache:=UINT32FromData(AppNode^[eAppAppOfManifestOnlyCache]);
    end;
  end;
end;

procedure TCDR.EnumerateSubscription(Node: pBLOBNode);
  procedure ReeadAppIDs(Rec: pSubscriptionRecord; SubNode: pBLOBNode);
  var
    i, len: integer;
  begin
    if SubNode=nil then
      Exit;
    len:=SubNode.Childrens;
    if len=0 then
      Exit;
    SetLength(Rec^.AppIds, len);
    for i:=0 to len-1 do
      Rec^.AppIds[i]:=puint32(Pointer(SubNode^.Children[i]^.Name))^;
  end;
  procedure ReadExtendedInfo(Rec: pSubscriptionRecord; SubNode: pBLOBNode);
  var
    i, len: integer;
  begin
    if SubNode=nil then
      Exit;
    len:=SubNode.Childrens;
    if len=0 then
      Exit;
    Rec^.ExtendedInfoRecordCount:=len;
    SetLength(Rec^.ExtendedInfoRecords, len);
    for i:=0 to len-1 do
    begin
      Rec^.ExtendedInfoRecords[i].Name:=Copy(SubNode^.Children[i]^.Name, 1, length(SubNode^.Children[i]^.Name));
      Rec^.ExtendedInfoRecords[i].Value:=StringFromData(SubNode^.Children[i]);
    end;
  end;

var
  i, len: integer;
  AppNode: pBLOBNode;
begin
  len:=Node^.Childrens;
  SetLength(Subscriptions, len);
  for i:=0 to len-1 do
  begin
    AppNode:=Node^.Children[i];
    //Subscriptions[i]:=TAppRecord.Create();
    with Subscriptions[i] do
    begin
      SubscriptionId:=UINT32FromData(AppNode^[eSubSubscriptionId]);
      Name:=StringFromData(AppNode^[eSubName]);
      BillingType:=EnSubBillingType(UINT32FromData(AppNode^[eSubBillingType]));
      CostInCents:=UINT32FromData(AppNode^[eSubCostInCents]);
      PeriodInMinutes:=UINT32FromData(AppNode^[eSubPeriodInMinutes]);
      ReeadAppIDs(@Subscriptions[i], AppNode^[eSubAppIds]);
      RunAppId:=UINT32FromData(AppNode^[eSubRunAppId]);
      OnSubscribeRunLaunchOptionIndex:=UINT32FromData(AppNode^[eSubOnSubscribeRunLaunchOptionIndex]);
      //ReadRateLimitRecord(@Subscriptions[i], AppNode^[eSubRateLimitRecord]);
      //ReadSubDiscounts(@Subscriptions[i], AppNode^[eSubDiscounts]);
      IsPreorder:=BoolFromData(AppNode^[eSubIsPreorder]);
      RequiresShippingAddress:=BoolFromData(AppNode^[eSubRequiresShippingAddress]);
      DomesticCostInCents:=UINT32FromData(AppNode^[eSubDomesticCostInCents]);
      InternationalCostInCents:=UINT32FromData(AppNode^[eSubInternationalCostInCents]);
      RequiredKeyType:=UINT32FromData(AppNode^[eSubRequiredKeyType]);
      IsCyberCafe:=BoolFromData(AppNode^[eSubIsCyberCafe]);
      GameCode:=UINT32FromData(AppNode^[eSubGameCode]);
      GameCodeDescription:=StringFromData(AppNode^[eSubGameCodeDescription]);
      IsDisabled:=BoolFromData(AppNode^[eSubIsDisabled]);
      RequiresCD:=BoolFromData(AppNode^[eSubRequiresCD]);
      TerritoryCode:=UINT32FromData(AppNode^[eSubTerritoryCode]);
      IsSteam3Subscription:=BoolFromData(AppNode^[eSubIsSteam3Subscription]);
      ReadExtendedInfo(@Subscriptions[i], AppNode^[eSubExtendedInfoRecords]);
    end;
  end;
end;


procedure TCDR.EnumerateAllAppsPublicKeysRecord(Node: pBLOBNode);
var
  i, len: integer;
begin
  if Node=nil then
    Exit;
  len:=Node.Childrens;
  if len=0 then
    Exit;
  SetLength(PublicKeys, len);
  for i:=0 to len-1 do
    with Node^.Children[i]^ do
    begin
      Move(Name[1], PublicKeys[i].ID, 4);
      Move(Data^, PublicKeys[i].Key[0], DataSize);
    end;
end;

{procedure TCDR.EnumerateAllAppsEncryptedPrivateKeysRecord(Node: pBLOBNode);
begin
end; }

function TCDR.GetAppRecordById(AppId: uint32): pAppRecord;
var
  i, len: integer;
begin
  result:=nil;
  len:=Length(AppRecords);
  for i:=0 to len-1 do
    if (AppRecords[i].AppId=AppId) then
    begin
      result:=@AppRecords[i];
      Exit;
    end;
end;

end.
