  TLang = packed record
      Name: AnsiString;
      FileIDCount: ulong;
      FileID: array of ulong;
    end;
  TUserDefinedRecord = packed record
      Name: AnsiString;
      Value: AnsiString;
    end;
  TPublicKey = packed record
    ID: uint32;
    Key: array[0..159] of byte;
  end;
  pESteamBlobValueType = ^ESteamBlobValueType;
  ESteamBlobValueType =
    (str,
     dword,
     RawBinaryData);
  EnSubBillingType =
    (eSBTNoCost,
     eSBTBillOnceOnly,
     eSBTBillMonthly,
     eSBTProofOfPrepurchaseOnly,
     eSBTGuestPass,
     eSBTHardwarePromo);

  pAppIconRecord = ^TAppIconRecord;
  TAppIconRecord = class
    end; 


  pAppLaunchOptionRecord = ^TAppLaunchOptionRecord;
  TAppLaunchOptionRecord = packed record  
      NoDesktopShortcut,
      NoStartMenuShortcut,
      LongRunningUnattended: boolean;
      Description: AnsiString;
      CommandLine: AnsiString;
      IconIndex: integer;
    end;

  pAppFilesystemRecord = ^TAppFilesystemRecord;
  TAppFilesystemRecord = packed record
      IsOptional: boolean;
      AppId: uint;
      MountName: AnsiString;
    end;
  pAppVersionRecord = ^TAppVersionRecord;
  TAppVersionRecord = packed record
      IsNotAvailable,   
      IsEncryptionKeyAvailable,
      IsRebased,
      IsLongVersionRoll: boolean;
      Description: AnsiString;
      VersionId: uint;
      LaunchOptionIdsRecordCount: integer;
      LaunchOptionIdsRecord: array of uint;
      DepotEncryptionKey: AnsiString;
    end;
  pSubscriptionDiscountQualifier = ^TSubscriptionDiscountQualifier;
  TSubscriptionDiscountQualifier = packed record
      QualifierId,
      SubscriptionId: uint;
      Name: AnsiString;
    end;
  pSubscriptionDiscountRecord = ^TSubscriptionDiscountRecord;
  TSubscriptionDiscountRecord = packed record
      DiscountId: uint;
      DiscountInCents: AnsiString;
      DiscountQualifierCount: integer;
      DiscountQualifiers: array of TSubscriptionDiscountQualifier;
    end;
  pSubscriptionRecord = ^TSubscriptionRecord;
  TSubscriptionRecord = packed record  
      IsPreorder,
      RequiresShippingAddress,
      IsCyberCafe,
      IsDisabled,
      RequiresCD,
      IsSteam3Subscription: boolean;
      DomesticCostInCents,
      InternationalCostInCents,
      RequiredKeyType,
      SubscriptionId,   
      CostInCents,
      TerritoryCode: uint;
      PeriodInMinutes,
      GameCode,
      RunAppId: integer;
      Name,
      GameCodeDescription: AnsiString;
      BillingType: EnSubBillingType;
      OnSubscribeRunLaunchOptionIndex: integer;
      
      AppIdCount: integer;
      AppIds: array of uint;
      DiscountCount: integer;
      Discounts: array of TSubscriptionDiscountRecord;
      ExtendedInfoRecordCount: integer;
      ExtendedInfoRecords: array of packed record
          Name,
          Value: AnsiString;
        end;
    end;
  pAppRecord = ^TAppRecord;
  TAppRecord = class
    private
      function GetUDR(Name: AnsiString): AnsiString;
    public
      IsBandwidthGreedy,
      SkipMFPOverwrite,
      UseFilesystemDvr,
      ManifestOnlyApp: boolean;
      AppId: uint;
      Name: AnsiString;
      InstallDirName: AnsiString;
      MinCacheFileSizeMB,
      MaxCacheFileSizeMB: uint32;
      LaunchOptionRecords: array of TAppLaunchOptionRecord;
      IconRecordCount: uint32;
      IconsRecord: array of TAppIconRecord;
      OnFirstLaunch: integer;
      VersionsRecord: array of TAppVersionRecord;
      CurrentVersionId: integer;
      FilesystemsRecords: array of TAppFilesystemRecord;
      TrickleVersionId: integer;
      UserDefinedRecordCount: integer;
      UserDefinedRecords: array of TUserDefinedRecord;
      LanguagesCount: ulong;
      Languages: array of TLang;
      BetaVersionPassword: AnsiString;
      BetaVersionId: integer;
      LegacyInstallDirName: AnsiString;
      AppOfManifestOnlyCache: uint;

      constructor Create(); overload;
      destructor Destroy(); override;
      property UserRecord[Name: AnsiString]: AnsiString read GetUDR;
      function GetCMD(): AnsiString;
      function DecryptKey(VersionID: uint32): AnsiString;
      function IsCache(): boolean;
      function IsApp(): boolean;
      function IsMedia(): boolean;
      function IsTool(): boolean;
    end;
