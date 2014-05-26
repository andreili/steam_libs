

#pragma pack (push, 1)
struct TLang
{
	char *name;
	UINT32 FileIDCount;
	UINT32 *FileIDs;
};

struct TUserDefinedRecord
{
	char *name;
	char *value;
};

struct TPublicKey
{
	UINT32 ID;
	char Key[160];
	/*char Header[29];
	char Key[128];
	char Dummy[3];*/
};

enum ESteamBlobValueType
{
	str,
	dword,
	RawBinaryData
};

enum EnSubBillingType
{
	eSBTNoCost,
	eSBTBillOnceOnly,
	eSBTBillMonthly,
	eSBTProofOfPrepurchaseOnly,
	eSBTGuestPass,
	eSBTHardwarePromo
};

struct TAppLaunchOptionRecord
{
	bool NoDesktopShortcut;
	bool NoStartMenuShortcut;
	bool LongRunningUnattended;
	char *Description;
	char *CommandLine;
	int IconIndex;
	char *Platform;
};

struct TAppFilesystemRecord
{
	bool IsOptional;
	UINT32 AppId;
	char *MountName;
	char *Platform;
};

struct TAppVersionRecord
{
	bool IsNotAvailable;
	bool IsEncryptionKeyAvailable;
	bool IsRebased;
	bool IsLongVersionRoll;
	char *Description;
	UINT32 VersionId;
	int LaunchOptionIdsRecordCount;
	UINT32 *LaunchOptionIdsRecord;
	char *DepotEncryptionKey;
};

struct TSubscriptionDiscountQualifier
{
	UINT32 QualifierId;
	UINT32 SubscriptionId;
	char *AnsiString;
};

struct TSubscriptionDiscountRecord
{
	UINT32 DiscountId;
	char *DiscountInCents;
	int DiscountQualifierCount;
	TSubscriptionDiscountQualifier *DiscountQualifiers;
};

struct TExtendedInfoRecords
{
	char *name;
	char *value;
};

struct TSubscriptionRecord
{
	bool IsPreorder;
	bool RequiresShippingAddress;
	bool IsCyberCafe;
	bool IsDisabled;
	bool RequiresCD;
	bool IsSteam3Subscription;
	UINT32 DomesticCostInCents;
	UINT32 InternationalCostInCents;
	UINT32 RequiredKeyType;
	UINT32 SubscriptionId;
	UINT32 CostInCents;
	UINT32 TerritoryCode;
	int PeriodInMinutes;
	int GameCode;
	int RunAppId;
	char *Name;
	char *GameCodeDescription;
	EnSubBillingType BillingType;
	int OnSubscribeRunLaunchOptionIndex;

	int AppIdCount;
	UINT32 *AppIds;
	int DiscountCount;
	TSubscriptionDiscountRecord *Discounts;
	int ExtendedInfoRecordCount;
	TExtendedInfoRecords *ExtendedInfoRecords;
};

class CAppRecord
{
public:
	bool IsBandwidthGreedy;
	bool SkipMFPOverwrite;
	bool UseFilesystemDvr;
	bool ManifestOnlyApp;
	UINT32 AppId;
	char *Name;
	char *InstallDirName;
	UINT32 MinCacheFileSizeMB;
	UINT32 MaxCacheFileSizeMB;
	int LaunchOptionRecordsCount;
	TAppLaunchOptionRecord *LaunchOptionRecords;
	//int IconRecordCount;
	//TAppIconRecord *IconsRecord;
	int OnFirstLaunch;
	int VersionRecordsCount;
	TAppVersionRecord *VersionRecords;
	int CurrentVersionId;
	int FilesystemsRecordsCount;
	TAppFilesystemRecord *FilesystemsRecords;
	int TrickleVersionId;
	int UserDefinedRecordCount;
	TUserDefinedRecord *UserDefinedRecords;
	UINT32 LanguagesCount;
	//TLang *Languages;
	char *BetaVersionPassword;
	int BetaVersionId;
	char *LegacyInstallDirName;
	UINT32 AppOfManifestOnlyCache;

	CAppRecord();
	~CAppRecord();

	char *GetUserDefinedRecord(char *name);
	char *GetCMD();
	char *DecryptKey(int VersionID);
	bool IsCache();
	
	void ReadLaunchOptionsRecords(CBLOBNode *Node);
	void ReadVersionRecords(CBLOBNode *Node);
	void ReadFileSystemRecords(CBLOBNode *Node);
	void ReadUserDefinedRecords(CBLOBNode *Node);
};

class CCDR
{
private:
	UINT16 VersionNumber;
	UINT32 LastChangedExistingAppOrSubscriptionTime;
	UINT32 IndexAppIdToSubscriptionIdsRecord;
	CBLOBFile *fBLOB;
	int SubscriptionsCount;
	TSubscriptionRecord *Subscriptions;
	int PublicKeysCount;
	TPublicKey *PublicKeys;

	void LoadFromStream(CStream *Stream);
	void EnumerateAppRecords(CBLOBNode *Node);
	void EnumerateSubscription(CBLOBNode *Node);
	void EnumerateAllAppsPublicKeysRecord(CBLOBNode *Node);
	//void EnumerateAllAppsEncryptedPrivateKeysRecord(CBLOBNode *Node);
public:
	CCDR(char *filename);
	CCDR(CStream *Stream);
	~CCDR();

	int AppRecordsCount;
	CAppRecord **AppRecords;

	CAppRecord *GetAppRecordById(UINT32 AppId);
};

#pragma pack (pop)