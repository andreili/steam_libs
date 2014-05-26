#include "stdafx.h"
#include "BLOBFile.h"
#include "../Stream.h"
#include "CDRFile.h"

#define NodeMagicNum		0x5001
#define NodeMagicNumComp	0x4301

enum ESteamBlobNodeType
{
	eCRDVersionNumber = 0,
	eCRDApplicationsRecord = 1,
	eCRDSubscriptionsRecord = 2,
	eCRDLastChangedExistingAppOrSubscriptionTime = 3,
	eCRDIndexAppIdToSubscriptionIdsRecord = 4,
	eCRDAllAppsPublicKeysRecord = 5,
	eCRDAllAppsEncryptedPrivateKeysRecord = 6
};

enum EApplicationFields
{
	eAppAppId = 1,
	eAppName = 2,
	eAppInstallDirName = 3,
	eAppMinCacheFileSizeMB = 4,
	eAppMaxCacheFileSizeMB = 5,
	eAppLaunchOptionsRecord = 6,
	eAppAppIconsRecord = 7,
	eAppOnFirstLaunch = 8,
	eAppIsBandwidthGreedy = 9,
	eAppVersionsRecord = 10,
	eAppCurrentVersionId = 11,
	eAppFilesystemRecords = 12,
	eAppTrickleVersionId = 13,
	eAppUserDefinedRecords = 14,
	eAppBetaVersionPassword = 15,
	eAppBetaVersionId = 16,
	eAppLegacyInstallDirName = 17,
	eAppSkipMFPOverwrite = 18,
	eAppUseFilesystemDvr = 19,
	eAppManifestOnlyApp = 20,
	eAppAppOfManifestOnlyCache = 21
};

enum EVersionRecordFields
{
	eVRDescription = 1,
	eVRVersionId = 2,
	eVRIsNotAvailable = 3,
	eVRLaunchOptionIdsRecord = 4,
	eVRDepotEncryptionKey = 5,
	eVRIsEncryptionKeyAvailable = 6,
	eVRIsRebased = 7,
	eVRIsLongVersionRoll = 8
};

enum ELaunchOptionRecordFields
{
	eLODescription = 1,
	eLOCommandLine = 2,
	eLOIconIndex = 3,
	eLONoDesktopShortcut = 4,
	eLONoStartMenuShortcut = 5,
	eLOLongRunningUnattended = 6,
	eLOPlatform = 7
};

enum EFileSystemFields
{
	eFSRAppId = 1,
	eFSRMountName = 2,
	eFSRIsOptional = 3,
	eFSRPlatform = 4
};

enum ESubscriptionFields
{
	eSubSubscriptionId = 1,
	eSubName = 2,
	eSubBillingType = 3,
	eSubCostInCents = 4,
	eSubPeriodInMinutes = 5,
	eSubAppIds = 6,
	eSubRunAppId = 7,
	eSubOnSubscribeRunLaunchOptionIndex = 8,
	eSubRateLimitRecord = 9,
	eSubDiscounts = 10,
	eSubIsPreorder = 11,
	eSubRequiresShippingAddress = 12,
	eSubDomesticCostInCents = 13,
	eSubInternationalCostInCents = 14,
	eSubRequiredKeyType = 15,
	eSubIsCyberCafe = 16,
	eSubGameCode = 17,
	eSubGameCodeDescription = 18,
	eSubIsDisabled = 19,
	eSubRequiresCD = 20,
	eSubTerritoryCode = 21,
	eSubIsSteam3Subscription = 22,
	eSubExtendedInfoRecords = 23
};

CAppRecord::CAppRecord()
{
	IsBandwidthGreedy = SkipMFPOverwrite = UseFilesystemDvr = ManifestOnlyApp = false;
	AppId = MinCacheFileSizeMB = MaxCacheFileSizeMB = LaunchOptionRecordsCount = 0;
	OnFirstLaunch = VersionRecordsCount = CurrentVersionId = FilesystemsRecordsCount = 0;
	TrickleVersionId = UserDefinedRecordCount = LanguagesCount = BetaVersionId = AppOfManifestOnlyCache = 0;
	Name = InstallDirName = BetaVersionPassword = LegacyInstallDirName = NULL;
	LaunchOptionRecords = NULL;
	VersionRecords = NULL;
	FilesystemsRecords = NULL;
	UserDefinedRecords = NULL;
}

CAppRecord::~CAppRecord()
{
	if (VersionRecordsCount > 0)
		for (int i=0 ; i<VersionRecordsCount ; i++)
			delete VersionRecords[i].LaunchOptionIdsRecord;
	//delete IconsRecord;
	delete LaunchOptionRecords;
	delete VersionRecords;
	delete FilesystemsRecords;
	delete UserDefinedRecords;
	//delete Languages;
}

char *CAppRecord::GetUserDefinedRecord(char *name)
{
	if (UserDefinedRecordCount > 0)
		for (int i=0 ; i<UserDefinedRecordCount ; i++)
			if (strcmp(UserDefinedRecords[i].name, name) == 0)
				return UserDefinedRecords[i].value;
	return "";
}

char *CAppRecord::GetCMD()
{
	int idx = VersionRecords[CurrentVersionId].LaunchOptionIdsRecord[0];
	return LaunchOptionRecords[idx].CommandLine;
}

char *CAppRecord::DecryptKey(int VersionID)
{
	if (VersionRecordsCount > VersionID)
		return NULL;
	return VersionRecords[VersionID].DepotEncryptionKey;
}

bool CAppRecord::IsCache()
{
	if (AppId == 312) 
		return false;
	if (strcmp(Name, LegacyInstallDirName) == 0)
		return true;
	if (FilesystemsRecordsCount > 0)
		for (int i=0 ; i<FilesystemsRecordsCount ; i++)
			if (FilesystemsRecords[i].AppId == AppId)
				return true;
	if ((FilesystemsRecordsCount == 0) || (strcmp(GetUserDefinedRecord("ismediafile"), "1") == 0))
		return true;
	return false;
}

void CAppRecord::ReadLaunchOptionsRecords(CBLOBNode *Node)
{
	if (Node == NULL)
		return;
	LaunchOptionRecordsCount = Node->ChildrensCount();
	if (LaunchOptionRecordsCount == 0)
		return;
	LaunchOptionRecords = new TAppLaunchOptionRecord[LaunchOptionRecordsCount];
	for (int i=0 ; i<LaunchOptionRecordsCount ; i++)
	{
		CBLOBNode *Children = Node->Childrens(i);
		LaunchOptionRecords[i].Description = Children->ReadString(eLODescription);
		LaunchOptionRecords[i].CommandLine = Children->ReadString(eLOCommandLine);
		LaunchOptionRecords[i].IconIndex = Children->ReadUINT32(eLOIconIndex);
		LaunchOptionRecords[i].NoDesktopShortcut = Children->ReadBool(eLONoDesktopShortcut);
		LaunchOptionRecords[i].NoStartMenuShortcut = Children->ReadBool(eLONoStartMenuShortcut);
		LaunchOptionRecords[i].LongRunningUnattended = Children->ReadBool(eLOLongRunningUnattended);
		LaunchOptionRecords[i].Platform = Children->ReadString(eLOPlatform);
	}
}

void CAppRecord::ReadVersionRecords(CBLOBNode *Node)
{
	if (Node == NULL)
		return;
	VersionRecordsCount = Node->ChildrensCount();
	if (VersionRecordsCount == 0)
		return;
	VersionRecords = new TAppVersionRecord[VersionRecordsCount];
	for (int i=0 ; i<VersionRecordsCount ; i++)
	{
		CBLOBNode *Children = Node->Childrens(i);
		VersionRecords[i].Description = Children->ReadString(eVRDescription);
		VersionRecords[i].VersionId = Children->ReadUINT32(eVRVersionId);
		VersionRecords[i].IsNotAvailable = Children->ReadBool(eVRIsNotAvailable);
		VersionRecords[i].DepotEncryptionKey = Children->ReadString(eVRDepotEncryptionKey);
		VersionRecords[i].IsEncryptionKeyAvailable = Children->ReadBool(eVRIsEncryptionKeyAvailable);
		VersionRecords[i].IsRebased = Children->ReadBool(eVRIsRebased);
		VersionRecords[i].IsLongVersionRoll = Children->ReadBool(eVRIsLongVersionRoll);

		// ReadLOIDs
		CBLOBNode *LOIDs = Children->GetNodeByIdx(eVRLaunchOptionIdsRecord);
		VersionRecords[i].LaunchOptionIdsRecordCount = LOIDs->ChildrensCount();
		VersionRecords[i].LaunchOptionIdsRecord = new UINT32[VersionRecords[i].LaunchOptionIdsRecordCount];
		for (int j=0 ; j<VersionRecords[i].LaunchOptionIdsRecordCount ; j++)
			VersionRecords[i].LaunchOptionIdsRecord[j] = *(UINT32*)LOIDs->Childrens(j)->Data();
	}
}

void CAppRecord::ReadFileSystemRecords(CBLOBNode *Node)
{
	if (Node == NULL)
		return;
	FilesystemsRecordsCount = Node->ChildrensCount();
	if (FilesystemsRecordsCount == 0)
		return;
	FilesystemsRecords = new TAppFilesystemRecord[FilesystemsRecordsCount];
	for (int i=0 ; i<FilesystemsRecordsCount ; i++)
	{
		CBLOBNode *Children = Node->Childrens(i);
		FilesystemsRecords[i].AppId = Children->ReadUINT32(eFSRAppId);
		FilesystemsRecords[i].MountName = Children->ReadString(eFSRMountName);
		FilesystemsRecords[i].IsOptional = Children->ReadBool(eFSRIsOptional);
		FilesystemsRecords[i].Platform = Children->ReadString(eFSRPlatform);
	}
}

void CAppRecord::ReadUserDefinedRecords(CBLOBNode *Node)
{
	if (Node == NULL)
		return;
	UserDefinedRecordCount = Node->ChildrensCount();
	if (UserDefinedRecordCount == 0)
		return;
	UserDefinedRecords = new TUserDefinedRecord[UserDefinedRecordCount];
	for (int i=0 ; i<UserDefinedRecordCount ; i++)
	{
		CBLOBNode *Children = Node->Childrens(i);
		UserDefinedRecords[i].name = CopyStr(Children->Name());
		if ((Node->Childrens(i) == NULL) || (Children->Data() == NULL))
			UserDefinedRecords[i].value = "";
		else
			UserDefinedRecords[i].value = CopyStr(Children->Data(), Children->DataSize());
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//                                             CCDR                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////

CCDR::CCDR(char *filename)
{
	CStream *str = new CStream(filename, false);
	if (str->GetHandle() == INVALID_HANDLE_VALUE)
	{
		this->~CCDR();
		return;
	}
	LoadFromStream(str);
	delete str;
}

CCDR::CCDR(CStream *Stream)
{
	LoadFromStream(Stream);
}

CCDR::~CCDR()
{
	if (AppRecordsCount > 0)
		for (int i=0 ; i<AppRecordsCount ; i++)
			delete AppRecords[i];
	delete AppRecords;
	delete Subscriptions;
	delete PublicKeys;
}

CAppRecord *CCDR::GetAppRecordById(UINT32 AppId)
{
	if (AppRecordsCount > 0)
		for (int i=0 ; i<AppRecordsCount ; i++)
			if (AppRecords[i]->AppId == AppId)
				return AppRecords[i];
	return NULL;
}

void CCDR::LoadFromStream(CStream *Stream)
{
	fBLOB = new CBLOBFile(Stream);
	CBLOBNode *root = fBLOB->RootNode();
	VersionNumber = root->ReadUINT16(eCRDVersionNumber);
	EnumerateAppRecords(root->GetNodeByIdx(eCRDApplicationsRecord));
	EnumerateSubscription(root->GetNodeByIdx(eCRDSubscriptionsRecord));
	LastChangedExistingAppOrSubscriptionTime = root->ReadUINT32(eCRDLastChangedExistingAppOrSubscriptionTime);
	//IndexAppIdToSubscriptionIdsRecord(root->GetNodeByIdx(eCRDIndexAppIdToSubscriptionIdsRecord));
	EnumerateAllAppsPublicKeysRecord(root->GetNodeByIdx(eCRDAllAppsPublicKeysRecord));
	//EnumerateAllAppsEncryptedPrivateKeysRecord(root->GetNodeByIdx(eCRDAllAppsEncryptedPrivateKeysRecord));
	delete fBLOB;
}

void CCDR::EnumerateAppRecords(CBLOBNode *Node)
{
	AppRecordsCount = Node->ChildrensCount();
	AppRecords = new CAppRecord*[AppRecordsCount];
	for (int i=0 ; i<AppRecordsCount ; i++)
	{
		CBLOBNode *AppNode = Node->Childrens(i);
		CAppRecord *App = new CAppRecord();
		AppRecords[i] = App;

		App->AppId = AppNode->ReadUINT32(eAppAppId);
		App->Name = AppNode->ReadString(eAppName);
		App->InstallDirName = AppNode->ReadString(eAppInstallDirName);
		App->MinCacheFileSizeMB = AppNode->ReadUINT32(eAppMinCacheFileSizeMB);
		App->MaxCacheFileSizeMB = AppNode->ReadUINT32(eAppMaxCacheFileSizeMB);
		App->ReadLaunchOptionsRecords(AppNode->GetNodeByIdx(eAppLaunchOptionsRecord));
		//ReadIconRecords(App, AppNode->GetNodeByIdx(eAppAppIconsRecord));
		App->OnFirstLaunch = AppNode->ReadUINT32(eAppOnFirstLaunch);
		App->IsBandwidthGreedy = AppNode->ReadBool(eAppIsBandwidthGreedy);
		App->ReadVersionRecords(AppNode->GetNodeByIdx(eAppVersionsRecord));
		App->CurrentVersionId = AppNode->ReadUINT32(eAppCurrentVersionId);
		App->ReadFileSystemRecords(AppNode->GetNodeByIdx(eAppFilesystemRecords));
		App->TrickleVersionId = AppNode->ReadUINT32(eAppTrickleVersionId);
		App->ReadUserDefinedRecords(AppNode->GetNodeByIdx(eAppUserDefinedRecords));
		App->BetaVersionPassword = AppNode->ReadString(eAppBetaVersionPassword);
		App->BetaVersionId = AppNode->ReadUINT32(eAppBetaVersionId);
		App->LegacyInstallDirName = AppNode->ReadString(eAppLegacyInstallDirName);
		App->SkipMFPOverwrite = AppNode->ReadBool(eAppSkipMFPOverwrite);
		App->UseFilesystemDvr = AppNode->ReadBool(eAppSkipMFPOverwrite);
		App->ManifestOnlyApp = AppNode->ReadBool(eAppManifestOnlyApp);
		App->AppOfManifestOnlyCache = AppNode->ReadUINT32(eAppAppOfManifestOnlyCache);
	}
}

void CCDR::EnumerateSubscription(CBLOBNode *Node)
{
	SubscriptionsCount = Node->ChildrensCount();
	Subscriptions = new TSubscriptionRecord[SubscriptionsCount];
	for (int i=0 ; i<SubscriptionsCount ; i++)
	{
		CBLOBNode *SubNode = Node->Childrens(i);

		Subscriptions[i].SubscriptionId = SubNode->ReadUINT32(eSubSubscriptionId);
		Subscriptions[i].Name = SubNode->ReadString(eSubName);
		Subscriptions[i].BillingType = (EnSubBillingType)SubNode->ReadUINT32(eSubBillingType);
		Subscriptions[i].CostInCents = SubNode->ReadUINT32(eSubCostInCents);
		Subscriptions[i].PeriodInMinutes = SubNode->ReadUINT32(eSubPeriodInMinutes);
		Subscriptions[i].RunAppId = SubNode->ReadUINT32(eSubRunAppId);
		Subscriptions[i].OnSubscribeRunLaunchOptionIndex = SubNode->ReadUINT32(eSubOnSubscribeRunLaunchOptionIndex);
		Subscriptions[i].IsPreorder = SubNode->ReadBool(eSubIsPreorder);
		Subscriptions[i].RequiresShippingAddress = SubNode->ReadBool(eSubRequiresShippingAddress);
		Subscriptions[i].DomesticCostInCents = SubNode->ReadUINT32(eSubDomesticCostInCents);
		Subscriptions[i].InternationalCostInCents = SubNode->ReadUINT32(eSubInternationalCostInCents);
		Subscriptions[i].RequiredKeyType = SubNode->ReadUINT32(eSubRequiresShippingAddress);
		Subscriptions[i].IsCyberCafe = SubNode->ReadBool(eSubIsCyberCafe);
		Subscriptions[i].GameCode = SubNode->ReadUINT32(eSubGameCode);
		Subscriptions[i].GameCodeDescription = SubNode->ReadString(eSubGameCodeDescription);
		Subscriptions[i].IsDisabled = SubNode->ReadBool(eSubIsDisabled);
		Subscriptions[i].RequiresCD = SubNode->ReadBool(eSubIsPreorder);
		Subscriptions[i].TerritoryCode = SubNode->ReadUINT32(eSubTerritoryCode);
		Subscriptions[i].IsSteam3Subscription = SubNode->ReadBool(eSubIsSteam3Subscription);

		// ReadAppIDs
		CBLOBNode *AppIDs = SubNode->GetNodeByIdx(eSubAppIds);
		if (AppIDs != NULL)
		{
			Subscriptions[i].AppIdCount = AppIDs->ChildrensCount();
			if (Subscriptions[i].AppIdCount > 0)
			{
				Subscriptions[i].AppIds = new UINT32[Subscriptions[i].AppIdCount];
				for (int j=0 ; j<Subscriptions[i].AppIdCount ; i++)
					if ((AppIDs->Childrens(j) != NULL) && (AppIDs->Childrens(j)->Data() != NULL))
						Subscriptions[i].AppIds[j] = *(UINT32*)AppIDs->Childrens(j)->Data();
			}
		}
		//ReadExtendedInfo
		CBLOBNode *ExInfo = SubNode->GetNodeByIdx(eSubAppIds);
		if (ExInfo != NULL)
		{
			Subscriptions[i].ExtendedInfoRecordCount = ExInfo->ChildrensCount();
			if (Subscriptions[i].ExtendedInfoRecordCount > 0)
			{
				Subscriptions[i].ExtendedInfoRecords = new TExtendedInfoRecords[Subscriptions[i].ExtendedInfoRecordCount];
				for (int j=0 ; j<Subscriptions[i].ExtendedInfoRecordCount ; i++)
				{
					CBLOBNode *Children = ExInfo->Childrens(j);
					Subscriptions[i].ExtendedInfoRecords[j].name = CopyStr(Children->Name());
					if ((ExInfo->Childrens(j) == NULL) || (Children->Data() == NULL))
						Subscriptions[i].ExtendedInfoRecords[j].value = "";
					else
						Subscriptions[i].ExtendedInfoRecords[j].value = CopyStr(Children->Data(), Children->DataSize());
				}
			}
		}
	}
}

void CCDR::EnumerateAllAppsPublicKeysRecord(CBLOBNode *Node)
{
	if (Node == NULL)
		return;
	PublicKeysCount = Node->ChildrensCount();
	if (PublicKeysCount == 0)
		return;
	PublicKeys = new TPublicKey[PublicKeysCount];
	for (int i=0 ; i<PublicKeysCount ; i++)
	{
		CBLOBNode *Children = Node->Childrens(i);
		if (Children->DataSize() <160)
			continue;
		PublicKeys[i].ID = *(UINT32*)Children->Name();
		memcpy(PublicKeys[i].Key, Children->Data(), 160);
	}
}

//void CCDR::EnumerateAllAppsEncryptedPrivateKeysRecord(CBLOBNode *Node)
