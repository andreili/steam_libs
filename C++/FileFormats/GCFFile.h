
#define CACHE_FLAG_FILE						0x00004000	// The item is a file.
#define CACHE_FLAG_ENCRYPTED				0x00000100	// The item is encrypted.
#define CACHE_FLAG_BACKUP_LOCAL				0x00000040	// Backup the item before overwriting it.
#define CACHE_FLAG_COPY_LOCAL				0x0000000a	// The item is to be copied to the disk.
#define CACHE_FLAG_COPY_LOCAL_NO_OVERWRITE 	0x00000001	// Don't overwrite the item if copying it to the disk and the item already exists.

#define CACHE_CHECKSUM_LENGTH					0x00008000	// The maximum data allowed in a 32 bit checksum.
#define CACHE_BLOCK_SIZE						0x00002000

#define CACHE_TYPE_GCF						0x00000001
#define CACHE_TYPE_NCF						0x00000002
#define CACHE_INVALID_ITEM					0xffffffff

#define CACHE_OPEN_READ						0x00000001
#define CACHE_OPEN_WRITE					0x00000002
#define CACHE_OPEN_READWRITE				0x00000003

#define USE_NCF_DIR							0x00
#define USE_NCF_FILE_NOT_LOAD				0x01
#define USE_NCF_FILE_INCOMPLETE				0x02
#define USE_NCF_FILE						0x03

#define HEADER_FILE_HEADER			0
#define HEADER_BAT_HEADER			1
#define HEADER_BAT					2
#define HEADER_FAT_HEADER			3
#define HEADER_FAT					4
#define HEADER_MANIFEST_HEADER		5
#define HEADER_MANIFEST_NODES		6
#define HEADER_NAMES				7
#define HEADER_HASH_KEYS			8
#define HEADER_HASH_INDICIES		9
#define HEADER_MFE					10
#define HEADER_USER_CONFIG			11
#define HEADER_MANIFEST_MAP_HEADER	12
#define HEADER_MANIFEST_MAP			13
#define HEADER_CHECKSUM_CONTAINER	14
#define HEADER_FILEID_HEADER		15
#define HEADER_FILEID				16
#define HEADER_CHECKSUMS			17
#define HEADER_CHECKSUM_SIGNATURE	18
#define HEADER_LAV					19
#define HEADER_LENGTH	20

struct FileHeader
{
	UINT32 HeaderVersion;
	UINT32 CacheType;
	UINT32 FormatVersion;
	UINT32 ApplicationID;
	UINT32 ApplicationVersion;
	UINT32 IsMounted;
	UINT32 Dummy0;
	UINT32 FileSize;
	UINT32 ClusterSize;
	UINT32 ClusterCount;
	UINT32 Checksum;
};

struct BlockAllocationTableHeader
{
	UINT32 BlockCount;
	UINT32 BlocksUsed;
	UINT32 LastUsedBlock;
	UINT32 Dummy0;
	UINT32 Dummy1;
	UINT32 Dummy2;
	UINT32 Dummy3;
	UINT32 Checksum;
};

struct BlockAllocationTableEntry
{
	UINT16 Flags;
	UINT16 Dummy0;
	UINT32 FileDataOffset;
	UINT32 FileDataSize;
	UINT32 FirstClusterIndex;
	UINT32 NextBlockIndex;
	UINT32 PreviousBlockIndex;
	UINT32 ManifestIndex;
};

struct FileAllocationTableHeader
{
	UINT32 ClusterCount;
	UINT32 FirstUnusedEntry;
	UINT32 IsLongTerminator;
	UINT32 Checksum;
};

//typedef UINT32 FileAllocationTableEntry;

struct ManifestHeader
{
	UINT32 HeaderVersion;
	UINT32 ApplicationID;
	UINT32 ApplicationVersion;
	UINT32 NodeCount;
	UINT32 FileCount;
	UINT32 CompressionBlockSize;
	UINT32 BinarySize;
	UINT32 NameSize;
	UINT32 HashTableKeyCount;
	UINT32 NumOfMinimumFootprintFiles;
	UINT32 NumOfUserConfigFiles;
	UINT32 Bitmask;
	UINT32 Fingerprint;
	UINT32 Checksum;
};

struct ManifestNode
{
	UINT32 NameOffset;
	UINT32 CountOrSize;
	UINT32 FileId;
	UINT32 Attributes;
	UINT32 ParentIndex;
	UINT32 NextIndex;
	UINT32 ChildIndex;
};

struct ManifestMapHeader
{
	UINT32 HeaderVersion;
	UINT32 Dummy0;
};

struct ChecksumDataContainer
{
	UINT32 HeaderVersion;
	UINT32 ChecksumSize;
};

struct FileIdChecksumTableHeader
{
	UINT32 FormatCode;
	UINT32 Dummy0;
	UINT32 FileIdCount;
	UINT32 ChecksumCount;
};

struct FileIdChecksumTableEntry
{
	UINT32 ChecksumCount;
	UINT32 FirstChecksumIndex;
};

/*struct ChecksumSignature
{
	UINT8 Signature[0x80];
};*/

struct DataHeader
{
	UINT32 ClusterCount;
	UINT32 ClusterSize;
	UINT32 FirstClusterOffset;
	UINT32 ClustersUsed;
	UINT32 Checksum;
};

struct TItemSize
{
	UINT64 Size;
	UINT64 CompletedSize;
	UINT32 Folders;
	UINT32 Files;
	UINT32 CompletedFiles;
	UINT32 Sectors;
};

struct TItemTree
{
	UINT32 Handle;
	TItemTree *FirstChild;
	TItemTree *Next;
};

class CGCFFile
{
private:
	//#pragma pack(1)
	FileHeader *pHeader;
	BlockAllocationTableHeader *pBATHeader;
	BlockAllocationTableEntry *lpBAT;
	FileAllocationTableHeader *pFATHeader;
	UINT32 *lpFAT;
	ManifestHeader *pManifestHeader;
	ManifestNode *lpManifest;
	char *lpNames;
	UINT32 *lpHashTableKeys;
	UINT32 *lpHashTableIndices;
	UINT32 *lpMinimumFootprint;
	UINT32 *lpUserConfig;
	ManifestMapHeader *pManifestMapHeader;
	UINT32 *lpManifestMap;
	ChecksumDataContainer *pChecksumDataContainer;
	FileIdChecksumTableHeader *pFileIDChecksumHeader;
	FileIdChecksumTableEntry *lpFileIDChecksum;
	UINT32 *lpChecksum;
	UINT8 *pChecksumSignature;
	UINT32 pLatestApplicationVersion;
	DataHeader *pDataHeader;
	UINT32 fDataBlockTerminator;
	int BitMapLen;
	UINT8 *lpBitMap;
	bool IsNCF;
	char *CommonPath;
	char *fileName;
	bool fIsChangeHeader[HEADER_LENGTH];
	CStream *stream;
public:
	CGCFFile(char *Common = "");
	~CGCFFile();
	bool ParanoiaSave;
	bool Stop;

	virtual bool __cdecl LoadFromFile(char *FileName);
	virtual bool __cdecl LoadFromStream(CStream *Stream);
	virtual void __cdecl LoadFromMem(char *Manifest, char *Checksums, UINT32 MS, UINT32 CS, bool AsGCF);

	virtual bool __cdecl SaveToFile(char *FileName);
	virtual bool __cdecl SaveToStream(CStream *Stream);
	//virtual void __cdecl SaveChanges();
	// сохраняет заголовки кэша как INFO-файл для последующего создание обновления
	virtual bool __cdecl SaveToFileAsInfo(char *FileName);
	virtual bool __cdecl SaveToStreamAsInfo(CStream *Stream);

	virtual bool __cdecl GetIsNCF();
	virtual UINT32 __cdecl GetCacheID();
	virtual UINT32 __cdecl GetFileVersion();
	virtual UINT32 __cdecl GetCacheVersion();
	virtual ManifestNode* __cdecl GetManifestEntry(UINT32 Item);
	virtual char* __cdecl GetFileName();

	virtual TItemTree* __cdecl GetItemTree(UINT32 Item);
	virtual UINT32 __cdecl GetItemsCount();
	virtual TItemSize __cdecl GetItemSize(UINT32 Item);
	virtual TItemSize __cdecl GetItemSizeFromGame(UINT32 Item);
	virtual bool __cdecl IsFile(UINT32 Item);
	virtual UINT32 __cdecl CheckIdx(UINT32 Item);
	virtual UINT32 __cdecl GetItem(char *Item);
	virtual char* __cdecl GetItemName(UINT32 Item);
	virtual char* __cdecl GetItemPath(UINT32 Item);

	virtual bool __cdecl ExtractItem(UINT32 Item, char *Dest);
	virtual UINT64 __cdecl ExtractFile(UINT32 Item, char *Dest, bool IsValidation = false);
	virtual UINT64 __cdecl DecryptFile(UINT32 Item, char *key);

	virtual bool __cdecl ExtractForGame(char *Dest);
	virtual bool __cdecl ValidateItem(UINT32 Item);
	virtual bool __cdecl CorrectItem(UINT32 Item);
	virtual bool __cdecl DecryptItem(UINT32 Item, char *key);

	virtual UINT64 __cdecl GetCompletedSize(UINT32 Item);
	virtual double __cdecl GetCompletion(UINT32 Item);
	virtual CStream* __cdecl OpenFile(char* FileName, UINT8 Mode);
	virtual CStream* __cdecl OpenFile(UINT32 Item, UINT8 Mode);
	virtual bool __cdecl FindFirst(FindRecord *pFindRecord);
	virtual bool __cdecl FindNext(FindRecord *pFindRecord);
	virtual char* __cdecl CreateInfo();
	virtual char* __cdecl CreatePatch(char *InfoFile);
	//ApplyPatch
	//CreateMiniGCF
private:		
	virtual void __cdecl BuildBitMap();
	virtual void __cdecl BuildClustersTable(UINT32 Item, std::vector<UINT32> *ItemTable);
	virtual void __cdecl RebuildClustersTable(UINT32 Item, std::vector<UINT32> *ItemTable);
	virtual bool __cdecl IsClusterFree(UINT32 ClusterIdx);
	virtual INT32 __cdecl AllocateCluster();
	virtual void __cdecl DeleteBlock(UINT32 BlockIdx);
	virtual void _cdecl FillClusters();
	virtual bool __cdecl CompareFile(UINT32 Item1, CGCFFile *GCF2, UINT32 Item2);
	virtual void __cdecl CopyHeaders(CGCFFile *GCF);
	virtual void __cdecl FreeBlocks();
	virtual void __cdecl SetSectorsCount(UINT32 NewCount);
	virtual void __cdecl CalculateChecksumsForHeaders();
	virtual UINT64 __cdecl ExtractItem_Recurse(UINT32 Item, char *Dest);
	virtual UINT64 __cdecl DecryptItem_Recurse(UINT32 Item, char *key);
	virtual UINT64 __cdecl GetFileSize(UINT32 Item);
public:
	// don't use is't methods !!!!!!!!!!!!!!!!!!
	virtual void __cdecl StreamClose(StreamData *Data);
	virtual UINT64 __cdecl StreamRead(StreamData *Data, void *lpData, UINT64 uiSize);
	virtual UINT64 __cdecl StreamWrite(StreamData *Data, void *lpData, UINT64 uiSize);
	virtual UINT64 __cdecl StreamSeek(StreamData *Data, INT64 uiPos, ESeekMode eSeekMode);
	virtual UINT64 __cdecl StreamGetSize(StreamData *Data);
	virtual void __cdecl StreamSetSize(StreamData *Data, UINT64 uiSize);
};