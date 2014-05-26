unit GCFFile;

interface

{$I defines.inc}

{$DEFINE DECRYPT}

uses
  Windows, USE_Types, USE_Utils, RSA, SHA {$IFDEF DECRYPT}, DECCipher, KOLZLib{$ENDIF};

{var
  GlobalGCFSemaphore: THandle;   }

const
  HL_GCF_CHECKSUM_LENGTH = $8000;
  HL_GCF_BLOCK_SIZE = $2000;

  HL_GCF_FLAG_FILE                      =$00004000;	// The item is a file.
  HL_GCF_FLAG_ENCRYPTED                 =$00000100;	// The item is encrypted.
  HL_GCF_FLAG_BACKUP_LOCAL              =$00000040;	// Backup the item before overwriting it.
  HL_GCF_FLAG_COPY_LOCAL                =$0000000a;	// The item is to be copied to the disk.
  HL_GCF_FLAG_COPY_LOCAL_NO_OVERWRITE   =$00000001;

  HL_NCF_DIR = 0;
  HL_NCF_FILE_NOT_LOAD = 1;
  HL_NCF_FILE_INCOMPLETE = 2;
  HL_NCF_FILE = 3;

type
  pCache_FileHeader = ^TCache_FileHeader;
  TCache_FileHeader = packed record
    HeaderVersion,                // always 0x00000001
    CacheType,                    // always 0x00000001 (if this is 0x00000002, then it is a NCF)
    FormatVersion,                // the file format version. The latest version number is 6 from GCF and 1 from NCF
    ApplicationID,                // the application ID of the cache
    ApplicationVersion,           // as with any software, updates need to be performed and tracked
    IsMounted,                    // set to 0x00000001 if the file is currently mounted, otherwise it will be set to 0x00000000. (Unverified)
    Dummy0,                       // always set to 0x00000000
    FileSize,                     // the total size of the cache file
    ClusterSize,                  // represents how many bytes are in each cluster in the cache
    ClusterCount,                 // represents how many total clusters are stored in the cache
    Checksum: uint32_t;           // used to validate the header
  end;

  TCache_BlockAllocationTableHeader = packed record
    BlockCount,                   // represents the number of blocks in the cache
    BlocksUsed,                   // represents the number of blocks that are used
    LastUsedBlock,                // the index of the last used block
    Dummy0,
    Dummy1,
    Dummy2,
    Dummy3,
    Checksum: uint32_t;           // used to validate the header.
                                  //Currently, this checksum is calculated by adding all of the previous fields together
  end;

  TCache_BlockAllocationTableEntry = packed record
    Flags,                        // represents the type of block. These are the currently known flags:
                                  //   $8000 - Used.
                                  //   $4000 - Local copy has priority over cache copy. (Unverified)
                                  //   $0004 - Encrypted. (Unverified)
                                  //   $0002 - Encrypted and compressed. (Unverified)
                                  //   $0001 - Raw.
    Dummy0: uint16_t;
    FileDataOffset,               // defines the offset in the extracted file where this block of data is located
    FileDataSize,                 // defines the length of the data in this block entry
    FirstClusterIndex,            // defines the index to the first cluster which contains this block’s data
    NextBlockIndex,               // defines the next block entry in the series.
                                  //  If this value is equal to BlockAllocationTableHeader.BlockCount
                                  //  then this is the last block in the series.

    PreviousBlockIndex,           // defines the previous block entry in the series
    ManifestIndex: uint32_t;      // represents which file this block is part of in the manifest
  end;

  TCache_FileAllocationTableHeader = packed record
    ClusterCount,                 // represents the number of clusters in the cache.
                                  //  This should be the same as FileHeader.ClusterCount
    FirstUnusedEntry,             // represents the index of the first unused entry
    IsLongTerminator,             // defines the end of block chain terminator.
                                  //  If the value is 0, then the terminator is 0x0000FFFF;
                                  //  if the value is 1, then the terminator is 0xFFFFFFFF
    Checksum: uint32_t;           // used to validate the header.
                                  //  Currently, this checksum is calculated by adding all of the previous fields together
  end;

  TCache_FileAllocationTableEntry = uint32_t;
    // the index of the next cluster of the file. If the value is equal to the terminator
    //   (defined by FileAllocationTableHeader.IsLongTerminator), then there are no more clusters in the file

  pCache_ManifestHeader = ^TCache_ManifestHeader;
  TCache_ManifestHeader = packed record
    HeaderVersion,                // always 0x00000004
    ApplicationID,                // the application ID of the cache. This should be the same as FileHeader.ApplicationID
    ApplicationVersion,           // the version of the application. This should be the same as FileHeader.ApplicationVersion
    NodeCount,                    // represents the number of manifest nodes there are
    FileCount,                    // represents the number of files are in the cache
    CompressionBlockSize,         // defines how many bytes are used per checksum/compressed block for each file.
                                  //   (Checksums are defined in another section.)
    BinarySize,                   // defines how many bytes are in the manifest (This field includes the size of this structure.)
    NameSize,                     // defines the number of bytes in the name table
    HashTableKeyCount,            // represents how many hash table keys there are
    NumOfMinimumFootprintFiles,   // represents how many minimum footprint files there are
    NumOfUserConfigFiles,         // represents how many user configuration files there are
    Bitmask,                      // is as the name says, a bit mask of various flags and values. These are the known masks:
                                  //   $00000001 - Build Mode (Purpose unknown)
                                  //   $00000002 - Is Purge All (Purpose unknown)
                                  //   $00000004 - Is Long Roll (Purpose unknown—this may have to do with when there are other related cache files in a “chain,” e.g. language caches.)
                                  //   $FFFFFF00 - Depot Key (Purpose unknown)
    Fingerprint,                  // most likely randomly generated every time the manifest is updated
    Checksum: uint32_t;           // an adler32 checksum of the whole manifest, excluding the following two fields: Fingerprint and Checksum
  end;

  pCache_ManifestNode = ^TCache_ManifestNode;
  TCache_ManifestNode = packed record
    NameOffset,                   // the offset in the name table where the name of the node is located
    CountOrSize,                  // the size of the node
    FileId,                       // the file ID of this node. If the node is a folder, then this value is 0xFFFFFFFF
    Attributes,                   // various flags for the node. These are the currently known flags:
                                  //   0x00004000 - The node is a file.
                                  //   0x00000800 - The node is an executable file. (Unverified)
                                  //   0x00000400 - The node is a hidden file. (Unverified)
                                  //   0x00000200 - The node is a read-only file. (Unverified)
                                  //   0x00000100 - The node is an encrypted file.
                                  //   0x00000080 - The node is a purge file. (Unverified)
                                  //   0x00000040 - Backup the node before overwriting it. (Versioned Uc File—Unverified)
                                  //   0x00000020 - The node is a no-cache file. (Unverified)
                                  //   0x00000008 - The node is a locked file. (Unverified)
                                  //   0x00000002 - The node is a launch file. (Unverified)
                                  //   0x00000001 - The node is a user configuration file. Do not overwrite the file if copying it to the local file system and the file already exists.
    ParentIndex,                  // the index to the parent node. If the node is at the root, then the value is 0xFFFFFFFF
    NextIndex,                    // the index to the next sibling node in the current hierarchy. If there are no more sibling nodes, then the value is 0x00000000
    ChildIndex: uint32_t;         // the index to the first child node for the current node. If there is no child node, then the value is 0x00000000
  end;

  TCache_ManifestMinimumFootprintEntry = uint32_t;
    // the index in the node table of the minimum footprint file.
    //   This should always be a reference to a file in the manifest
  TCache_ManifestUserConfigEntry = uint32_t;
    // the index in the node table of the user configuration file.
    //   This should always be a reference to a file in the manifest

  TCache_ManifestMapHeader = packed record
    HeaderVersion,                // always 0x00000001
    Dummy0: uint32_t;             // always 0x00000000
  end;

  TCache_ManifestMapEntry = uint32_t;
    // the index of the first block (in the block allocation table) for the file.
    //   If the value is equal to BlockAllocationTableHeader.BlockCount, then the item is a directory and/or
    //   is not stored in the cache

  TCache_ChecksumDataContainer = packed record
    HeaderVersion,                // always 0x00000001
    ChecksumSize: uint32_t;       // the number of bytes in the checksum section (excluding this structure
                                  //   and the following LatestApplicationVersion structure)
  end;

  pCache_FileIdChecksumTableHeader = ^TCache_FileIdChecksumTableHeader;
  TCache_FileIdChecksumTableHeader = packed record
    FormatCode,                   // always 0x14893721
    Dummy0,                       // always 0x00000001
    FileIdCount,                  // the number of file ID entries
    ChecksumCount: uint32_t;      // the number of checksums
  end;

  TCache_FileIdChecksumTableEntry = packed record
    ChecksumCount,                // how many ChecksumEntrys are used for the checksum section
    FirstChecksumIndex: uint32_t; // the index of the first ChecksumEntry for the checksum section
  end;

  TCache_ChecksumEntry = uint32_t;
    // is a checksum for a given segment of a file. Each block can be several clusters in the cache file.
    //   The size of the block is defined as ManifestHeader.CompressionBlockSize.
    //   If the file segment is smaller than the block size, then the checksum is
    //   only calculated on the file’s remaining size
  TCache_ChecksumSignature = array[0..$7f] of byte;
    // is an RSA signature (using SHA-1 and RSASSA-PKCS1-v1_5) of the checksum section
  TCache_LatestApplicationVersion = uint32_t;
    // the latest version of the application’s checksums

  TCache_DataHeader = packed record
    ClusterCount,                 // the number of clusters in the cache. This should be the same as FileHeader.ClusterCount
    ClusterSize,                  // how many bytes are in each cluster of a file. This should be the same as FileHeader.ClusterSi
    FirstClusterOffset,           // the offset (relative to the start of the cache file) to the first cluster
    ClustersUsed,                 // the number of clusters that actually have data
    Checksum: uint32_t;           // used to validate the header. Currently, this checksum is calculated by adding all of the previous fields together
  end;

const
  CACHE_TYPE_GCF = $00000001;
  CACHE_TYPE_NCF = $00000002;

  SIZE_HEADER_CHECK = sizeof(TCache_FileHeader)-4;
  SIZE_BAT_HEADER_CHECK = (sizeof(TCache_BlockAllocationTableHeader) div 4)-1;
  SIZE_FAT_HEADER_CHECK = (sizeof(TCache_FileAllocationTableHeader) div 4)-1;
  SIZE_MANIFEST_CHECK = sizeof(TCache_ManifestHeader)-4;

  HEADER_FILE_HEADER = 0;
  HEADER_BAT_HEADER = 1;
  HEADER_BAT = 2;
  HEADER_FAT_HEADER = 3;
  HEADER_FAT = 4;
  HEADER_MANIFEST_HEADER = 5;
  HEADER_MANIFEST_NODES = 6;
  HEADER_NAMES = 7;
  HEADER_HASH_KEYS = 8;
  HEADER_HASH_INDICIES = 9;
  HEADER_MFE = 10;
  HEADER_USER_CONFIG = 11;
  HEADER_MANIFEST_MAP_HEADER = 12;
  HEADER_MANIFEST_MAP = 13;
  HEADER_CHECKSUM_CONTAINER = 14;
  HEADER_FILEID_HEADER = 15;
  HEADER_FILEID = 16;
  HEADER_CHECKSUMS = 17;
  HEADER_CHECKSUM_SIGNATURE = 18;
  HEADER_LAV = 19;


type
  TGCFFile = class (TObject)
  {TPackage -->}
    public
      PackageType: TPackageType;
      Stop: boolean;
      OnError: TOnError;
      OnErrorObj: TOnErrorObj;
      OnProgress: TOnProgress;
      OnProgressObj: TOnProgressObj;
      fFileName: string;
      fStream: TStream;
      StreamMethods: TStreamMethods;

      class function IsGCF(FileName: string): boolean; overload; virtual;
      class function IsGCF(Stream: TStream): boolean; overload; virtual;

      constructor Create(CommonPath: string = ''); virtual;
      destructor Destroy; override;

      function GetItemSize(Item: integer): TItemSize; virtual;
      function GetItemPath(Item: integer): string; virtual;
      function GetItemByPath(Path: string): integer; virtual;

      function LoadFromFile(FileName: string): boolean; virtual;
      function LoadFromStream(Stream: TStream): boolean; virtual;

      property ItemSize[Item: integer]: TItemSize read GetItemSize;
      property ItemPath[Item: integer]: string read GetItemPath;
      property ItemByPath[Item: string]: integer read GetItemByPath;

      function OpenFile(FileName: string; Access: byte): TStream; overload; virtual;
      function OpenFile(Item: integer; Access: byte): TStream; overload; virtual;

    private
      function Read(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize; virtual;
      function Write(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize; virtual;
      procedure SetFileSize(Strm: TStream; Size: TStrmSize); virtual;
      procedure CloseFile(Strm: TStream; Flag: ulong = 0); virtual;
  {<-- TPackage}
    private
      fDataBlockTerminator: uint32_t;
      // File Header
      fFileHeader: TCache_FileHeader;
      // Block Allocation Table
      fBATHeader: TCache_BlockAllocationTableHeader;
      lpBATEntries: array of TCache_BlockAllocationTableEntry;
      // File Allocation Table
      fFATHeader: TCache_FileAllocationTableHeader;
      lpFATEntries: array of TCache_FileAllocationTableEntry;
      // Manifest
      fManifestHeader: TCache_ManifestHeader;
      lpManifestNodes: array of TCache_ManifestNode;
      fNameTable: AnsiString;
      lpHashTableKeys: array of uint32_t;
      lpHashTableIndices: array of uint32_t;
      lpMinimumFootprintEntries: array of uint32_t;
      lpUserConfigEntries: array of uint32_t;
      fManifestMapHeader: TCache_ManifestMapHeader;
      lpManifestMapEntries: array of TCache_ManifestMapEntry;
      // Checksums
      fChecksumDataContainer: TCache_ChecksumDataContainer;
      fFileIdChecksumTableHeader: TCache_FileIdChecksumTableHeader;
      lpFileIdChecksumTableEntries: array of TCache_FileIdChecksumTableEntry;
      lpChecksumEntries: array of uint32_t;

      lpChecksumSignature: array[0..$7f] of byte;
      fLatestApplicationVersion: uint32_t;
      fDataHeader: TCache_DataHeader;

      fIsNCF: boolean;
      fBitMap: array of byte;
      fIsChangeHeader: array [0..30] of boolean;
      CommonPath: string;

      function GetFileSize(FileID: integer): int64; virtual;
      function GetItemSizeFromGame(Item: integer): int64; virtual;
      function GetItemName(Item: integer): string; virtual;
      function GetManifestEntry(Idx: integer): TCache_ManifestNode; virtual;

      procedure GCF_BuildBitMap(); virtual;
      // получить номер сектора, в котором находятся данные
      //function GCF_GetClusterIdx(Item: integer; Position: int64): uint32_t; virtual;
      // построение полной таблицы секторов
      procedure GCF_BuildClustersTable(Item: integer; Table: pCardinalDynArray); virtual;
      // перенос полной таблицы секторов из массива в заголовки
      procedure GCF_RebuildClustersTable(Item: integer; Table: pCardinalDynArray); virtual;

      // определяет, свободен ли запрашиваемый кластер
      function GCF_IsClusterFree(ClusterIdx: integer): boolean; virtual;
      // возвращает первый свободный кластер
      function GCF_AllocateCluster(): integer; virtual;
      // удаляет текущий и следующие блоки вместе с цепочками кластеров
      procedure GCF_DeleteBlock(BlockIdx: ulong); virtual;
      // удаляет все цепочки блоков и кластеров
      procedure GCF_FillClusters(); virtual;

      // сравнивает два файла
      function CompareFile(Item1: integer; GCF2: TGCFFile; Item2: integer): boolean; virtual;
      // копирует заголовки из другого файла кэша
      procedure CopyHeaders(FromGCF: TGCFFile); virtual;
      // удаляет из заголовков блоки файлов и очищает таблицу секторов
      procedure FreeBlocks(); virtual;
      // изменяет количество секторов, изменяя заголовки
      procedure SetClustersCount(Count: ulong); virtual;
      procedure CalculateChecksumsForHeaders(); virtual;
      // меняет два сектора местами
      // если Idx2>ClustersCount, то Idx1 может иметь значение только 0!!!!!
      procedure SwapClusters(Idx1, Idx2: uint32);
    public
      ParanoiaSave: boolean;
      IgnoreCheckError: boolean;
      Data: Pointer;

      procedure LoadFromMem(Manifest, Checksum: pByte; MS, CS: uint32; AsGCF: boolean); virtual;
      procedure SaveToFile(FileName: string); virtual;
      procedure SaveToStream(Stream: TStream); virtual;
      procedure SaveChanges(); virtual;
        // сохраняет заголовки кэша как INFO-файл для последующего создание обновления
      procedure SaveToStreamAsInfo(Stream: TStream); virtual;
      procedure Close(); virtual;

      // информация о файле кэша
      property IsNCF: boolean read fIsNCF;
      property CacheID: ulong read fFileHeader.ApplicationID;
      property FileVersion: ulong read fFileHeader.FormatVersion;
      property CacheVersion: ulong read fFileHeader.ApplicationVersion;
      property ManifestEntry[Item: integer]: TCache_ManifestNode read GetManifestEntry;
      property ManifesCheck: uint32 read fManifestHeader.Checksum;

      // свойства получения информации о элементах
      property ItemsCount: ulong read fManifestHeader.NodeCount;
      property ItemSizeFromGame[Item: integer]: int64 read GetItemSizeFromGame;
      function IsFile(Item: uint32): boolean; virtual;
      function CheckIdx(Item: uint32): uint32;
      function GetFlags(Item: uint32): uint32;

      // свойства для работы с именами элементов
      property ItemName[Item: integer]: string read GetItemName;

      // методы обработки элементов
      function ExtractItem(Item: ulong; Dest: string): boolean; virtual;
      function ExtractFile(Item: integer; Dest: string; IsValidation: boolean = false): int64; virtual;
      {$IFDEF DECRYPT}
      function DecryptFile(Item: integer; Key: Pointer): int64; virtual;
      {$ENDIF}
        // извлечение минимально необходимых файлов
      function ExtractForGame(Dest: string): boolean; virtual;
      function ValidateItem(Item: integer): boolean; virtual;
      function CorrectItem(Item: integer): boolean; virtual;
      {$IFDEF DECRYPT}
      function DecryptItem(Item: integer; Key: string): boolean; virtual;
      {$ENDIF}
      function GetCompletedSize(Item: integer): int64; virtual;
      function GetCompletion(Item: integer): single; virtual;

      // поиск по кэшу
      function FindFirst(FindRec: pFindRecord): boolean; virtual;
      function FindNext(FindRec: pFindRecord): boolean; virtual;

      // методы обновлений
      function CreateInfo(): string; virtual;
      function CreatePatch(InfoFile: string): boolean; virtual;
      function ApplyUpdate(UpdateFile: string): boolean; virtual;

      function CreateMiniGCF(FileName: string): boolean; virtual;

      procedure CreateItemsTree(Item: integer; RootNode: Pointer; OnItem: TAddTreeItemProc); virtual;
      procedure CreateItemsList(Item: integer; OnItem: TAddFileItemProc); virtual;
  end;

implementation

uses
  nx_z, nx_strs;

function HeaderChecksum(Data: pByte; Length: integer): uint32_t;
var
  Checksum: uint32_t;
  i: integer;
begin
  Checksum:=0;
  for i:=0 to Length-1 do
  begin
    inc(Checksum, Data^);
    inc(Data);
  end;
  result:=Checksum;
end;

function HeaderChecksum2(Data: pulong; Length: integer): uint32_t;
var
  Checksum: uint32_t;
  i: integer;
begin
  Checksum:=0;
  for i:=0 to Length-1 do
  begin
    inc(Checksum, Data^);
    inc(Data);
  end;
  result:=Checksum;
end;

function ManifestChecksum(Header: pCache_ManifestHeader; entries, names, hashs, table, MFP, UCF: pByte): uint32_t;
var
  tmp1, tmp2: uint32;
begin
  tmp1:=Header.Fingerprint;
  tmp2:=Header.Checksum;
  Header.Fingerprint:=0;
  Header.Checksum:=0;
  result:=adler32(0, pAnsiChar(Header), sizeof(TCache_ManifestHeader));
  result:=adler32(result, pAnsiChar(entries), sizeof(TCache_ManifestNode)*Header^.NodeCount);
  result:=adler32(result, pAnsiChar(names), Header^.NameSize);
  result:=adler32(result, pAnsiChar(hashs), sizeof(uint32)*Header^.HashTableKeyCount);
  result:=adler32(result, pAnsiChar(table), sizeof(uint32)*Header^.NodeCount);
  if Header^.NumOfMinimumFootprintFiles>0 then
    result:=adler32(result, pAnsiChar(MFP), sizeof(uint32)*Header^.NumOfMinimumFootprintFiles);
  if Header^.NumOfUserConfigFiles>0 then
    result:=adler32(result, pAnsiChar(UCF), sizeof(uint32)*Header^.NumOfUserConfigFiles);
  Header.Fingerprint:=tmp1;
  Header.Checksum:=tmp2;
end;

procedure CheckChecksum(TableHeader: pCache_FileIdChecksumTableHeader; Header, TableEntries, CheckEntries: pByte; var _out: pByte);
var
  data: pByte;
  DataSize: uint32;
  sha: TSHA1;
begin
  DataSize:=sizeof(TCache_FileIdChecksumTableHeader)+
   sizeof(TCache_FileIdChecksumTableEntry)*TableHeader.FileIdCount+
   sizeof(ulong)*(TableHeader.ChecksumCount);
  GetMem(data, DataSize);
  Move(TableHeader, data[0], sizeof(TCache_FileIdChecksumTableHeader));
  Move(TableEntries[0], data[sizeof(TCache_FileIdChecksumTableHeader)], sizeof(TCache_FileIdChecksumTableEntry)*TableHeader.FileIdCount);
  Move(CheckEntries[0], data[sizeof(TCache_FileIdChecksumTableHeader)+sizeof(TCache_FileIdChecksumTableEntry)*TableHeader.FileIdCount],
   sizeof(ulong)*TableHeader.ChecksumCount);

  GetMem(_out, 128);
  _out[0]:=$00;
  _out[1]:=$01;
  FillChar(_out[2], 128-38, $ff);
  Move(AnsiString(#$00#$30#$21#$30#$09#$06#$05#$2b#$0e#$03#$02#$1a#$05#$00#$04#$14), _out[128-36], $10);

  SHA:=TSHA1.Create();
  SHA.AddBytes(data, DataSize);
  Move(SHA.GetDigest()^, _out[128-20], $14);
  SHA.Free;
  {GetMem(k, 160);
  str:=TStream.CreateReadFileStream('96.bin');
  str.Read(k^, 160);
  str.Free;
  SetNetworkKey(@k[29]);
  _out:=RSASignMessage(NetWorkKey, data, DataSize);}
end;

{
  fStream.Read(fChecksumDataContainer, sizeof(TCache_ChecksumDataContainer));
  fStream.Read(fFileIdChecksumTableHeader, sizeof(TCache_FileIdChecksumTableHeader));
  SetLength(lpFileIdChecksumTableEntries, fFileIdChecksumTableHeader.FileIdCount);
   fStream.Read(lpFileIdChecksumTableEntries[0], sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount);
  SetLength(lpChecksumEntries, fFileIdChecksumTableHeader.ChecksumCount);
   fStream.Read(lpChecksumEntries[0], sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount));
}


function StreamOnStream_Seek(Strm: TStream; MoveTo: TStrmMove; MoveFrom: TMoveMethod): TStrmSize; inline;
var
  NewPos: DWORD;
begin
  case MoveFrom of
    spBegin: NewPos:=MoveTo;
    spCurrent: NewPos:=Strm.Data.fPosition+MoveTo;
    else NewPos:=Strm.Data.fSize+MoveTo;
  end;
  if NewPos>Strm.Data.fSize then
    Strm.Size:=NewPos;
  if ((Strm.Data.Package as TGCFFile).IsNCF) then
    Strm.Data.FileStream.Position:=NewPos;
  Strm.Data.fPosition:=NewPos;
  Result:=NewPos;
end;

function StreamOnStream_GetSize(Strm: TStream): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TGCFFile).ItemSize[Strm.Data.fHandle].Size;
end;

procedure StreamOnStream_SetSize(Strm: TStream; NewSize: TStrmSize); inline;
begin
  (Strm.Data.Package as TGCFFile).SetFileSize(Strm, NewSize);
end;

function StreamOnStream_Read(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=TGCFFile(Strm.Data.Package).Read(Strm, @Buffer, Count);
end;

function StreamOnStream_Write(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TGCFFile).Write(Strm, @Buffer, Count);
end;

procedure StreamOnStream_SetSizeNULL(Strm: TStream; NewSize: TStrmSize); inline;
begin
end;

function StreamOnStream_WriteNULL(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=0;
end;

procedure StreamOnStream_Close(Strm: TStream); inline;
begin
  (Strm.Data.Package as TGCFFile).CloseFile(Strm);
  Strm.Data.fHandle:=ulong(-1);
  Strm.Data.fSize:=0;
  Strm.Data.fPosition:=0;
  Strm.Data.Package:=nil;
end;

class function TGCFFile.IsGCF(FileName: string): boolean;
var
  str: TStream;
begin
  str:=TStream.CreateReadFileStream(FileName);
  result:=IsGCF(str);
  str.Free;
end;

class function TGCFFile.IsGCF(Stream: TStream): boolean;
var
  Header: TCache_FileHeader;
begin
  Stream.Read(Header, sizeof(TCache_FileHeader));
  result:=(HeaderChecksum(@Header.HeaderVersion, SIZE_HEADER_CHECK) = Header.Checksum);
end;

function TGCFFile.GetFileSize(FileID: integer): int64;
var
  i: integer;
    MN: pCache_ManifestNode;
begin
  result:=lpManifestNodes[FileID].CountOrSize and $7FFFFFFF;
  if (lpManifestNodes[FileID].CountOrSize and $80000000<>0) then
  begin
    // FindExtendedFileNode
    if ItemsCount>0 then
      for i:=0 to ItemsCount-1 do
      begin
        MN:=@lpManifestNodes[i];
        if (MN<>nil) and (MN^.Attributes and $00004000<>0) and (MN^.ParentIndex=$FFFFFFFF) and
         (MN^.NextIndex=$FFFFFFFF) and (MN^.ChildIndex=$FFFFFFFF) and (MN^.FileId=lpManifestNodes[FileID].FileId) then
        begin
          inc(result, MN^.CountOrSize shl 31);
          break;
        end;
      end;
  end;
end;

function TGCFFile.GetItemSize(Item: integer): TItemSize;
  function Recurse(Idx: integer): TItemSize;
  var
    f: TItemSize;
  begin
    FillChar(result, sizeof(TItemSize), 0);
    if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE<>HL_GCF_FLAG_FILE then
    begin
      Idx:=lpManifestNodes[Idx].ChildIndex;
      while Idx>0 do
      begin
        if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE<>HL_GCF_FLAG_FILE then
          inc(result.Folders, 1);
        f:=Recurse(Idx);
        inc(result.Size, f.Size);
        inc(result.CSize, f.CSize);
        inc(result.Folders, f.Folders);
        inc(result.Files, f.Files);
        inc(result.CFiles, f.CFiles);
        inc(result.Sectors, f.Sectors);
        Idx:=lpManifestNodes[Idx].NextIndex;
      end;
    end
      else
    begin
      result.Size:=GetFileSize(Idx);

      result.Sectors:=result.Size div HL_GCF_BLOCK_SIZE;
      if result.Sectors*HL_GCF_BLOCK_SIZE<result.Size then
        inc(result.Sectors);
      result.Files:=1;
      result.CSize:=GetCompletedSize(Idx);
      if result.Size=result.CSize then
        result.CFiles:=1;
    end;
  end;
begin
  result:=Recurse(Item);
end;

function TGCFFile.GetItemSizeFromGame(Item: integer): int64;
var
  i: integer;
begin
  result:=0;
  for i:=0 to fManifestHeader.NumOfMinimumFootprintFiles-1 do
    inc(result, ItemSize[lpMinimumFootprintEntries[i]].Size);
end;

function TGCFFile.IsFile(Item: uint32): boolean;
begin
  result:=(lpManifestNodes[Item].Attributes and HL_GCF_FLAG_FILE=HL_GCF_FLAG_FILE);
end;

function TGCFFile.CheckIdx(Item: uint32): uint32;
begin
  result:=lpManifestNodes[Item].FileId;
//  result:=lpFileIdChecksumTableEntries[lpManifestNodes[Item].FileId].FirstChecksumIndex;
end;

function TGCFFile.GetFlags(Item: uint32): uint32;
begin
  result:=lpManifestNodes[Item].Attributes;
end;

function CompareStr(const S1, S2: string): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1), -1, PChar(S2), -1 ) - 2;
end;

function TGCFFile.GetItemByPath(Path: string): integer;
var
  end_block: boolean;
  Hash, HashIdx, HashValue: ulong;
  FileID, HashFileIdx: integer;
  PathEx: AnsiString;
begin
  result:=-1;
{$IFDEF UNICODE}
  PathEx:=Wide2Ansi(ExtractFileName(Path));
{$ELSE}
  PathEx:=ExtractFileName(Path);
{$ENDIF}
  Hash:=jenkinsLookupHash2(@PathEx[1], Length(PathEx), 1);
  HashIdx:=Hash mod fManifestHeader.HashTableKeyCount;
  HashFileIdx:=lpHashTableKeys[HashIdx];
  if HashFileIdx=-1 then
  begin
    if (LowerCase(Path)<>Path) then
    begin
{$IFDEF UNICODE}
      Hash:=jenkinsLookupHash2(@LowerCaseAnsi(PathEx)[1], Length(PathEx), 1);
{$ELSE}
      Hash:=jenkinsLookupHash2(@LowerCase(PathEx)[1], Length(PathEx), 1);
{$ENDIF}
      HashIdx:=Hash mod fManifestHeader.HashTableKeyCount;
      HashFileIdx:=lpHashTableKeys[HashIdx];
      if HashFileIdx=-1 then
        Exit;
    end;
  end;
  dec(HashFileIdx, fManifestHeader.HashTableKeyCount);
  repeat
    HashValue:=lpHashTableIndices[HashFileIdx];
    FileID:=HashValue and $7FFFFFFF;
    end_block:= (HashValue and $80000000 = $80000000);
    if CompareStr(ItemPath[FileID], Path)=0 then
    begin
      result:=FileID;
      Exit;
    end;
    inc(HashFileIdx);
  until end_block;

  if (result=-1) and (LowerCase(Path)<>Path) then
    result:=GetItemByPath(LowerCase(Path));
end;

function TGCFFile.GetItemName(Item: integer): string;
begin
{$IFDEF UNICODE}
  result:=Ansi2Wide(pAnsiChar(@fNameTable[lpManifestNodes[Item].NameOffset+1]));
{$ELSE}
  result:=pAnsiChar(@fNameTable[lpManifestNodes[Item].NameOffset+1]);
{$ENDIF}
end;

function TGCFFile.GetItemPath(Item: integer): string;
var
  res: AnsiString;
begin
  res:=pAnsiChar(@fNameTable[lpManifestNodes[Item].NameOffset+1]);
  Item:=lpManifestNodes[Item].ParentIndex;
  while (Item>-1) do
  begin
    res:=pAnsiChar(@fNameTable[lpManifestNodes[Item].NameOffset+1])+'\'+res;
    Item:=lpManifestNodes[Item].ParentIndex;
  end;
  Delete(res, 1, 1);
{$IFDEF UNICODE}
  result:=Ansi2Wide(res);
{$ELSE}
  result:=res;
{$ENDIF}
end;

function TGCFFile.GetManifestEntry(Idx: integer): TCache_ManifestNode;
begin
  if (Idx<length(lpManifestMapEntries)) and (lpManifestMapEntries[Idx]<ulong(length(lpManifestNodes))) then
    result:=lpManifestNodes[lpManifestMapEntries[Idx]]
      else result:=lpManifestNodes[0];
end;

procedure TGCFFile.GCF_BuildBitMap();
var
  VectorMask: byte;
  ItemTable: array of ulong;
  len, VectorsIdx: ulong;
  i, j: integer;
begin
  if IsNCF then
    Exit;
  len:=fFileHeader.ClusterCount div 8;
  if (len*8<fFileHeader.ClusterCount) then
    inc(len);
  SetLength(fBitMap, len);
  FillChar(fBitMap[0], len, 0);
  for i:=0 to ItemsCount-1 do
    if (lpManifestNodes[i].Attributes and HL_GCF_FLAG_FILE=HL_GCF_FLAG_FILE) then
    begin
      GCF_BuildClustersTable(i, @ItemTable);
      if Length(ItemTable)>0 then
        for j:=0 to Length(ItemTable)-1 do
        begin
          VectorsIdx:=ItemTable[j] div 8;
          VectorMask:=1 shl (ItemTable[j]-VectorsIdx*8);
          fBitMap[VectorsIdx]:=fBitMap[VectorsIdx] xor VectorMask;
        end;
      SetLength(ItemTable, 0);
      ItemTable:=nil;
    end;
end;

{function TGCFFile.GCF_GetClusterIdx(Item: integer; Position: int64): uint32_t;
var
  BlockIdx, ClusterIdx, OffsetInBlock, OffsetAbs, Offset: uint32_t;
begin
  BlockIdx:=lpManifestMapEntries[Item];
  ClusterIdx:=lpBATEntries[BlockIdx].FirstClusterIndex;
  OffsetInBlock:=0;
  OffsetAbs:=0;
  if (OffsetInBlock+fDataHeader.ClusterSize>lpBATEntries[BlockIdx].FileDataSize) then
    Offset:=lpBATEntries[BlockIdx].FileDataSize-OffsetInBlock
      else Offset:=fDataHeader.ClusterSize;
  while (Position>=OffsetAbs+OffsetInBlock+Offset) and (BlockIdx<>fDataHeader.ClusterCount) do
  begin
    while ((Position>=OffsetAbs+OffsetInBlock+Offset) and ((ClusterIdx<fDataBlockTerminator) and
     (OffsetInBlock<lpBATEntries[BlockIdx].FileDataSize))) do
    begin
      // переходим к следующему кластеру
      ClusterIdx:=lpFATEntries[ClusterIdx];
      inc(OffsetInBlock, fDataHeader.ClusterSize);
      if (OffsetInBlock+fDataHeader.ClusterSize>lpBATEntries[BlockIdx].FileDataSize) then
        Offset:=lpBATEntries[BlockIdx].FileDataSize-OffsetInBlock
          else Offset:=fDataHeader.ClusterSize;
    end;
    if (OffsetInBlock>=lpBATEntries[BlockIdx].FileDataSize) then
    begin
      // переходим к следующему блоку
      inc(OffsetAbs, lpBATEntries[BlockIdx].FileDataSize);
      BlockIdx:=lpBATEntries[BlockIdx].NextBlockIndex;
      OffsetInBlock:=0;
      if (BlockIdx<>fDataHeader.ClusterCount) then
        ClusterIdx:=lpBATEntries[BlockIdx].FirstClusterIndex;
      if (OffsetInBlock+fDataHeader.ClusterSize>lpBATEntries[BlockIdx].FileDataSize) then
        Offset:=lpBATEntries[BlockIdx].FileDataSize-OffsetInBlock
          else Offset:=fDataHeader.ClusterSize;
    end;
  end;
  result:=ClusterIdx;
end;  }

procedure TGCFFile.GCF_BuildClustersTable(Item: integer; Table: pCardinalDynArray);
var
  i, len: integer;
  BlockIdx, OffsetInBlock: uint32_t;
begin
  BlockIdx:=lpManifestMapEntries[Item];
  if BlockIdx=fBATHeader.BlockCount then
    Exit;
  len:=ItemSize[Item].Sectors;
  SetLength(Table^, len);
  if len=0 then
    Exit;

  Table^[0]:=lpBATEntries[BlockIdx].FirstClusterIndex;
  i:=0;
  OffsetInBlock:=0;
  if (Table^[0]=fDataBlockTerminator) or (lpBATEntries[BlockIdx].FileDataSize=0) then
  begin
    SetLength(Table^, 0);
    Exit;
  end;

  while ((i+1<len) and (BlockIdx<>fDataHeader.ClusterCount)) do
  begin
    while ((Table^[i]<fDataBlockTerminator) and (OffsetInBlock<lpBATEntries[BlockIdx].FileDataSize)) do
    begin
      // переходим к следующему кластеру
      if (lpFATEntries[Table^[i]]<>fDataBlockTerminator) then
      begin
        Table^[i+1]:=lpFATEntries[Table^[i]];
        inc(i);
      end;
      inc(OffsetInBlock, fDataHeader.ClusterSize);
    end;
    if (OffsetInBlock>=lpBATEntries[BlockIdx].FileDataSize) then
    begin
      // переходим к следующему блоку
      BlockIdx:=lpBATEntries[BlockIdx].NextBlockIndex;
      OffsetInBlock:=0;
      if (BlockIdx<>fDataHeader.ClusterCount) then
        if (lpBATEntries[BlockIdx].FirstClusterIndex<>fDataBlockTerminator) then
        begin
          Table^[i+1]:=lpBATEntries[BlockIdx].FirstClusterIndex;
          inc(i);
        end
          else
        begin
          SetLength(Table^, i+1);
          Exit;
        end;
    end;
  end;
end;

procedure TGCFFile.GCF_RebuildClustersTable(Item: integer; Table: pCardinalDynArray);
var
  BlockIdx, ClusterIdx, BlockSize, Cluster, c: ulong;
  AllSize: int64;
begin
  AllSize:=ItemSize[Item].Size;
  BlockIdx:=lpManifestMapEntries[Item];

  Cluster:=0;
  while ((BlockIdx<fBATHeader.BlockCount) and (AllSize>=0)) do
  begin
    fIsChangeHeader[HEADER_FAT]:=true;
    BlockSize:=0;
    //ClusterIdx:=lpBATEntries[BlockIdx].FirstClusterIndex;
    if Length(Table^)=0 then ClusterIdx:=fFATHeader.ClusterCount
      else if uint32_t(Length(Table^))>=Cluster then ClusterIdx:=Table^[Cluster]
        else ClusterIdx:=GCF_AllocateCluster();
    c:=ClusterIdx;
    if (ClusterIdx<>ulong(-1)) then lpBATEntries[BlockIdx].FirstClusterIndex:=ClusterIdx
      else break;

    while BlockSize<lpBATEntries[BlockIdx].FileDataSize do
    begin
      if (ClusterIdx=fDataBlockTerminator) then
      begin
        // создаем часть таблицы для данного блока данных
        if uint32_t(Length(Table^))>=Cluster then ClusterIdx:=Table^[Cluster]
          else ClusterIdx:=GCF_AllocateCluster();
        if (ClusterIdx<>ulong(-1)) then lpFATEntries[c]:=ClusterIdx
          else break;
        lpFATEntries[c]:=ClusterIdx;
        //c:=ClusterIdx;
      end;
      inc(BlockSize, HL_GCF_BLOCK_SIZE);
      c:=ClusterIdx;
      ClusterIdx:=lpFATEntries[ClusterIdx];
      inc(Cluster);
    end;
    if Length(Table^)>0 then
      lpFATEntries[c]:=fDataBlockTerminator;
    dec(AllSize, lpBATEntries[BlockIdx].FileDataSize);
    BlockIdx:=lpBATEntries[BlockIdx].NextBlockIndex;
  end;
  fIsChangeHeader[HEADER_BAT_HEADER]:=true;
  fIsChangeHeader[HEADER_BAT]:=true;
  fIsChangeHeader[HEADER_FAT_HEADER]:=true;
  fIsChangeHeader[HEADER_FAT]:=true;
end;

function TGCFFile.GCF_IsClusterFree(ClusterIdx: integer): boolean;
var
  VectorMask: byte;
  VectorsIdx: integer;
begin
  VectorsIdx:=ClusterIdx div 8;
  VectorMask:=1 shl (ClusterIdx-VectorsIdx*8);
  Result:=(fBitMap[VectorsIdx] and VectorMask=0);
end;

function TGCFFile.GCF_AllocateCluster(): integer;
var
  i, j, ClusterIdx, VectorsIdx: integer;
begin
  if (Length(fBitMap)>0) then
    for i:=0 to Length(fBitMap)-1 do
      if (fBitMap[i]<>$ff) then
      begin
        ClusterIdx:=i*8;
        for j:=0 to 7 do
          if GCF_IsClusterFree(ClusterIdx+j) then
          begin
            result:=ClusterIdx+j;
            VectorsIdx:=result div 8;
            fBitMap[VectorsIdx]:=fBitMap[VectorsIdx] xor (1 shl (result-VectorsIdx*8));
            inc(fDataHeader.ClustersUsed);
            fDataHeader.Checksum:=fDataHeader.ClusterCount+
             fDataHeader.ClusterSize+fDataHeader.FirstClusterOffset+
             fDataHeader.ClustersUsed;
            Exit;
          end;
      end;
  result:=-1;
end;

procedure TGCFFile.GCF_DeleteBlock(BlockIdx: ulong);
var
  ClusterIdx, NextCluster: ulong;
  i: integer;
begin
  if (BlockIdx<fDataHeader.ClusterCount) then
  begin
    // удаляем следующий блок, если он назначен
    GCF_DeleteBlock(lpBATEntries[BlockIdx].NextBlockIndex);

    ClusterIdx:=lpBATEntries[BlockIdx].FirstClusterIndex;
    // смещаем все последующие блоки...
    if (fBATHeader.BlockCount>BlockIdx) then
      for i:=BlockIdx+1 to fBATHeader.BlockCount-1 do
        if (lpBATEntries[i].ManifestIndex>0) then
          lpBATEntries[i-1]:=lpBATEntries[i];
    // ... и изменяем ссылки на них
    for i:=0 to fBATHeader.BlockCount-1 do
    begin
      if (lpBATEntries[i].NextBlockIndex>=BlockIdx) then
        dec(lpBATEntries[i].NextBlockIndex);
      if (lpBATEntries[i].PreviousBlockIndex>=BlockIdx) then
        dec(lpBATEntries[i].PreviousBlockIndex);
    end;
    for i:=0 to fManifestHeader.NodeCount-1 do
      if (lpManifestMapEntries[i]>=BlockIdx) then
        dec(lpManifestMapEntries[i]);

    // удаляем цепочки кластеров у текущего блока
    while (ClusterIdx<>fDataBlockTerminator) do
    begin
      NextCluster:=lpFATEntries[ClusterIdx];
      lpFATEntries[ClusterIdx]:=fDataBlockTerminator;
      ClusterIdx:=NextCluster;
    end;

    dec(fBATHeader.LastUsedBlock);
    fIsChangeHeader[HEADER_BAT_HEADER]:=true;
    fIsChangeHeader[HEADER_BAT]:=true;
    fIsChangeHeader[HEADER_FAT]:=true;
    fIsChangeHeader[HEADER_MANIFEST_MAP]:=true;
  end;
end;

procedure TGCFFile.GCF_FillClusters();
var
  i: integer;
begin
  for i:=0 to ItemsCount-1 do
    lpManifestMapEntries[i]:=fBATHeader.BlockCount;
  for i:=0 to fBATHeader.BlockCount-1 do
  begin
    FillChar(lpBATEntries[i].Flags, sizeof(TCache_BlockAllocationTableEntry), 0);
    lpBATEntries[i].NextBlockIndex:=fBATHeader.BlockCount;
    lpBATEntries[i].PreviousBlockIndex:=fBATHeader.BlockCount;
    lpBATEntries[i].ManifestIndex:=ulong(-1);
  end;
  fBATHeader.BlocksUsed:=0;
  fBATHeader.LastUsedBlock:=0;
  for i:=0 to fBATHeader.BlockCount-1 do
    if lpBATEntries[i].Flags and $8000=$8000 then
    begin
      lpBATEntries[i].FirstClusterIndex:=fDataBlockTerminator;//pHeader.ClusterSize;
      lpBATEntries[i].NextBlockIndex:=fBATHeader.BlockCount;
    end;
  for i:=0 to fFATHeader.ClusterCount-1 do
    lpFATEntries[i]:=fDataBlockTerminator;
end;

function TGCFFile.CompareFile(Item1: integer; GCF2: TGCFFile; Item2: integer): boolean;
var
  CheckStart1, CheckStart2, CheckCount, i: integer;
  IS1, IS2: TItemSize;
begin
  result:=false;

  if (Item2=-1) then
    Exit;

  // быстрое сравнение - по размеру
  IS1:=ItemSize[Item1];
  IS2:=GCF2.ItemSize[Item2];
  if (IS1.Size<>IS2.Size) or (IS1.Folders<>IS2.Folders) or (IS1.Files<>IS2.Files) then
    Exit;

  // подробное сравнение - по контрольным суммам
  if lpManifestNodes[Item1].Attributes and HL_GCF_FLAG_FILE<>HL_GCF_FLAG_FILE then
    Exit;
  CheckStart1:=lpFileIdChecksumTableEntries[lpManifestNodes[Item1].FileId].FirstChecksumIndex;
  CheckStart2:=GCF2.lpFileIdChecksumTableEntries[GCF2.lpManifestNodes[Item2].FileId].FirstChecksumIndex;
  CheckCount:=lpFileIdChecksumTableEntries[lpManifestNodes[Item1].FileId].ChecksumCount;
  if (uint32_t(CheckCount)<>GCF2.lpFileIdChecksumTableEntries[GCF2.lpManifestNodes[Item2].FileId].ChecksumCount) then
    Exit;
  for i:=0 to CheckCount-1 do
    if (lpChecksumEntries[CheckStart1+i]<>GCF2.lpChecksumEntries[CheckStart2+i]) then
      Exit;


  result:=true;
end;

procedure TGCFFile.CopyHeaders(FromGCF: TGCFFile);
begin
  // File Header
  Move(FromGCF.fFileHeader, fFileHeader, sizeof(TCache_FileHeader));
  // Block Allocation Table
  Move(FromGCF.fBATHeader, fBATHeader, sizeof(TCache_BlockAllocationTableHeader));
  SetLength(lpBATEntries, fBATHeader.BlockCount);
  if fBATHeader.BlockCount>0 then
    Move(FromGCF.lpBATEntries[0], lpBATEntries[0], sizeof(TCache_BlockAllocationTableEntry)*fBATHeader.BlockCount);
  // File Allocation Table
  Move(FromGCF.fFATHeader, fFATHeader, sizeof(TCache_FileAllocationTableHeader));
  SetLength(lpFATEntries, fFATHeader.ClusterCount);
  if fFATHeader.ClusterCount>0 then
    Move(FromGCF.lpFATEntries[0], lpFATEntries[0], sizeof(TCache_FileAllocationTableEntry)*fFATHeader.ClusterCount);
  // Manifest
  Move(FromGCF.fManifestHeader, fManifestHeader, sizeof(TCache_ManifestHeader));
  SetLength(lpManifestNodes, fManifestHeader.NodeCount);
  if fManifestHeader.NodeCount>0 then
    Move(FromGCF.lpManifestNodes[0], lpManifestNodes[0], sizeof(TCache_ManifestNode)*fManifestHeader.NodeCount);
  SetLength(fNameTable, fManifestHeader.NameSize);
  if fManifestHeader.NameSize>0 then
    Move(FromGCF.fNameTable[1], fNameTable[1], fManifestHeader.NameSize);
  SetLength(lpHashTableKeys, fManifestHeader.HashTableKeyCount);
  if fManifestHeader.HashTableKeyCount>0 then
    Move(FromGCF.lpHashTableKeys[0], lpHashTableKeys[0], sizeof(uint32_t)*fManifestHeader.HashTableKeyCount);
  SetLength(lpHashTableIndices, fManifestHeader.NodeCount);
  if fManifestHeader.NodeCount>0 then
    Move(FromGCF.lpHashTableIndices[0], lpHashTableIndices[0], sizeof(uint32_t)*fManifestHeader.NodeCount);
  SetLength(lpMinimumFootprintEntries, fManifestHeader.NumOfMinimumFootprintFiles);
  if fManifestHeader.NumOfMinimumFootprintFiles>0 then
    Move(FromGCF.lpMinimumFootprintEntries[0], lpMinimumFootprintEntries[0], sizeof(uint32_t)*fManifestHeader.NumOfMinimumFootprintFiles);
  SetLength(lpUserConfigEntries, fManifestHeader.NumOfUserConfigFiles);
  if fManifestHeader.NumOfUserConfigFiles>0 then
    Move(FromGCF.lpUserConfigEntries[0], lpUserConfigEntries[0], sizeof(uint32_t)*fManifestHeader.NumOfUserConfigFiles);
  Move(FromGCF.fManifestMapHeader, fManifestMapHeader, sizeof(TCache_ManifestMapHeader));
  SetLength(lpManifestMapEntries, fManifestHeader.NodeCount);
  if fManifestHeader.NodeCount>0 then
    Move(FromGCF.lpManifestMapEntries[0], lpManifestMapEntries[0], sizeof(uint32_t)*fManifestHeader.NodeCount);
  // Checksums
  Move(FromGCF.fChecksumDataContainer, fChecksumDataContainer, sizeof(TCache_ChecksumDataContainer));
  Move(FromGCF.fFileIdChecksumTableHeader, fFileIdChecksumTableHeader, sizeof(TCache_FileIdChecksumTableHeader));
  SetLength(lpFileIdChecksumTableEntries, fFileIdChecksumTableHeader.FileIdCount);
  if fFileIdChecksumTableHeader.FileIdCount>0 then
    Move(FromGCF.lpFileIdChecksumTableEntries[0], lpFileIdChecksumTableEntries[0], sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount);
  SetLength(lpChecksumEntries, fFileIdChecksumTableHeader.ChecksumCount);
  if fFileIdChecksumTableHeader.ChecksumCount>0 then
    Move(FromGCF.lpChecksumEntries[0], lpChecksumEntries[0], sizeof(uint32_t)*fFileIdChecksumTableHeader.ChecksumCount);

  fLatestApplicationVersion:=FromGCF.fLatestApplicationVersion;
  Move(FromGCF.fDataHeader, fDataHeader, sizeof(TCache_DataHeader));
  if fFATHeader.IsLongTerminator=0 then
    fDataBlockTerminator:=$0000FFFF
      else fDataBlockTerminator:=$FFFFFFFF;
  GCF_BuildBitMap();
  FillChar(fIsChangeHeader[0], length(fIsChangeHeader), true);
end;

procedure TGCFFile.FreeBlocks();
var
  i: integer;
  FillBlock: TCache_BlockAllocationTableEntry;
begin
  FillChar(FillBlock, sizeof(TCache_BlockAllocationTableEntry), 0);
  FillBlock.NextBlockIndex:=fBATHeader.BlockCount;
  FillBlock.PreviousBlockIndex:=fBATHeader.BlockCount;
  FillBlock.ManifestIndex:=ulong(-1);
  for i:=0 to fBATHeader.BlockCount-1 do
    Move(FillBlock, lpBATEntries[i], sizeof(TCache_BlockAllocationTableEntry));
  fBATHeader.BlocksUsed:=0;
  fBATHeader.LastUsedBlock:=0;
  // обнуляем ссылки на блоки
  for i:=0 to fManifestHeader.NodeCount-1 do
    lpManifestMapEntries[i]:=fBATHeader.BlockCount;
  for i:=0 to fFATHeader.ClusterCount-1 do
    lpFATEntries[i]:=fDataBlockTerminator;
  fFATHeader.FirstUnusedEntry:=0;
  fDataHeader.ClustersUsed:=0;
  GCF_BuildBitMap();
  fIsChangeHeader[HEADER_BAT_HEADER]:=true;
  fIsChangeHeader[HEADER_BAT]:=true;
  fIsChangeHeader[HEADER_FAT_HEADER]:=true;
  fIsChangeHeader[HEADER_FAT]:=true;
end;

procedure TGCFFile.SetClustersCount(Count: ulong);
var
  Last: ulong;
  i: integer;
begin
  Last:=fFileHeader.ClusterCount;

  fFileHeader.ClusterCount:=Count;
  fBATHeader.BlockCount:=Count;
  SetLength(lpBATEntries, Count);
  for i:=0 to Count-1 do
    if lpBATEntries[i].FirstClusterIndex=Last then
      lpBATEntries[i].FirstClusterIndex:=Count;
  fFATHeader.ClusterCount:=Count;
  SetLength(lpFATEntries, Count);
  for i:=0 to Count-1 do
    if lpFATEntries[i]=Last then
      lpFATEntries[i]:=Count;
  fDataHeader.ClusterCount:=Count;
  for i:=0 to fManifestHeader.NodeCount-1 do
    if lpManifestMapEntries[i]=Last then
      lpManifestMapEntries[i]:=Count;
  fIsChangeHeader[HEADER_BAT_HEADER]:=true;
  fIsChangeHeader[HEADER_BAT]:=true;
  fIsChangeHeader[HEADER_FAT_HEADER]:=true;
  fIsChangeHeader[HEADER_FAT]:=true;
end;

procedure TGCFFile.CalculateChecksumsForHeaders();
begin
  fFileHeader.Checksum:=HeaderChecksum(@fFileHeader.HeaderVersion, SIZE_HEADER_CHECK);
  fBATHeader.Checksum:=HeaderChecksum2(@fBATHeader.BlockCount, SIZE_BAT_HEADER_CHECK);
  fFATHeader.Checksum:=HeaderChecksum2(@fFATHeader.ClusterCount, SIZE_FAT_HEADER_CHECK);
  fManifestHeader.Checksum:=ManifestChecksum(@fManifestHeader, @lpManifestNodes[0],
   @fNameTable[1], @lpHashTableKeys[0], @lpHashTableIndices[0], @lpMinimumFootprintEntries[0], @lpUserConfigEntries[0]);
  //lpChecksumSignature
  fDataHeader.Checksum:=HeaderChecksum2(@fDataHeader.ClusterCount,
   sizeof(TCache_DataHeader) div sizeof(ulong));
end;

procedure TGCFFile.SwapClusters(Idx1, Idx2: uint32);
var
  b1, b2: array[0..HL_GCF_BLOCK_SIZE-1] of byte;
  p1, p2: uint64;
  i, l, ChangedIdx, Idx0: uint32;
begin
  p1:=fDataHeader.FirstClusterOffset+HL_GCF_BLOCK_SIZE*Idx1;
  p2:=fDataHeader.FirstClusterOffset+HL_GCF_BLOCK_SIZE*Idx2;
  // собственно обмен данными
  fStream.Seek(p1, spBegin);
  fStream.Read(b1[0], HL_GCF_BLOCK_SIZE);
  fStream.Seek(p2, spBegin);
  fStream.Read(b2[0], HL_GCF_BLOCK_SIZE);

  if Idx2>=fFATHeader.ClusterCount then
  begin
    l:=fFATHeader.ClusterCount;
    // необходима "косметическая" коррекция заголовков
    Idx0:=$ffffffff;
    for i:=0 to fBATHeader.BlockCount-1 do
    begin
      if (lpBATEntries[i].FirstClusterIndex=0) then
        Idx0:=i;
      if (lpBATEntries[i].FirstClusterIndex<>fDataBlockTerminator) and (lpBATEntries[i].FirstClusterIndex<>l) then
        dec(lpBATEntries[i].FirstClusterIndex);
    end;
    if Idx0<>$ffffffff then
      lpBATEntries[Idx0].FirstClusterIndex:=fFATHeader.ClusterCount-1;
    Idx0:=$ffffffff;
    for i:=0 to fFATHeader.ClusterCount-1 do
    begin
      if (lpFATEntries[i]=0) then
        Idx0:=i;
      if (lpFATEntries[i]<>fDataBlockTerminator) and (lpFATEntries[i]<>l) then
        dec(lpFATEntries[i]);
    end;
    if Idx0<>$ffffffff then
      lpFATEntries[Idx0]:=fFATHeader.ClusterCount-1;
    fStream.Seek(p2, spBegin);
    fStream.Write(b1[0], HL_GCF_BLOCK_SIZE);
  end
    else
  begin
    fStream.Seek(p1, spBegin);
    fStream.Write(b2[0], HL_GCF_BLOCK_SIZE);
    fStream.Seek(p2, spBegin);
    fStream.Write(b1[0], HL_GCF_BLOCK_SIZE);
    // а теперь изменяем заголовки
    ChangedIdx:=$ffffffff;
    l:=fBATHeader.BlockCount-1;
    for i:=0 to l do
    begin
      if (lpBATEntries[i].FirstClusterIndex=Idx1) and (ChangedIdx<>i) then
      begin
        lpBATEntries[i].FirstClusterIndex:=Idx2;
        ChangedIdx:=i;
      end;
      if (lpBATEntries[i].FirstClusterIndex=Idx2) and (ChangedIdx<>i) then
      begin
        lpBATEntries[i].FirstClusterIndex:=Idx1;
        ChangedIdx:=i;
      end;
    end;
    ChangedIdx:=$ffffffff;
    l:=fFATHeader.ClusterCount-1;
    for i:=0 to l do
    begin
      if (lpFATEntries[i]=Idx1) and (ChangedIdx<>i) then
      begin
        lpFATEntries[i]:=Idx2;
        ChangedIdx:=i;
      end;
      if (lpFATEntries[i]=Idx2) and (ChangedIdx<>i) then
      begin
        lpFATEntries[i]:=Idx1;
        ChangedIdx:=i;
      end;
    end;
  end;
end;

function TGCFFile.Read(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize;
var
  ReadSize, ReadedSize, ReadPos, ReadingSize: TStrmSize;
  ClusterIdx: uint32_t;
begin
  if (Count>ItemSize[Strm.Data.fHandle].Size-Strm.Data.fPosition) then
    Count:=ItemSize[Strm.Data.fHandle].Size-Strm.Data.fPosition;

  if (IsNCF) then
  begin
    result:=Strm.Data.FileStream.Read(Buffer^, Count);
    Strm.Data.fPosition:=Strm.Data.FileStream.Position;
  end
    else
  begin
    ReadingSize:=0;
    while (Count>0) do
    begin
      ClusterIdx:=(Strm.Data.fPosition and $ffffffffffffe000) shr 13;
      if ClusterIdx>=ulong(Length(Strm.Data.SectorsTable)) then
        break;
      ClusterIdx:=Strm.Data.SectorsTable[ClusterIdx];
      if ClusterIdx=fDataHeader.ClusterCount then
      begin
        result:=ReadingSize;
        Exit;
      end;
      // получаем размер и позицию читаемого кусочка в текущем кластере
      ReadPos:=(Strm.Data.fPosition and $00001fff) shr 13;
      fStream.Seek(fDataHeader.FirstClusterOffset+ClusterIdx*HL_GCF_BLOCK_SIZE+ReadPos, spBegin);
      ReadSize:=HL_GCF_BLOCK_SIZE;
      if (ReadSize>HL_GCF_BLOCK_SIZE-ReadPos) then
        ReadSize:=HL_GCF_BLOCK_SIZE-ReadPos;
      if (ReadSize>Count) then
        ReadSize:=Count;
      if (ReadSize>Strm.Data.fSize-Strm.Data.fPosition) then
        ReadSize:=Strm.Data.fSize-Strm.Data.fPosition;
      ReadedSize:=fStream.Read(Buffer^, ReadSize);
      inc(ReadingSize, ReadedSize);
      inc(Buffer, ReadedSize);
      inc(Strm.Data.fPosition, ReadedSize);
      dec(Count, ReadedSize);
    end;
    result:=ReadingSize;
  end;
end;

function TGCFFile.Write(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize;
var
  WriteSize, WritedSize, WritePos, WritingSize: TStrmSize;
  ClusterIdx, Cluster: integer;
begin
  if (Count>ItemSize[Strm.Data.fHandle].Size-Strm.Data.fPosition) then
    Count:=ItemSize[Strm.Data.fHandle].Size-Strm.Data.fPosition;

  if (IsNCF) then
  begin
    result:=Strm.Data.FileStream.Write(Buffer^, Count);
    Strm.Data.fPosition:=Strm.Data.FileStream.Position;
    Strm.Data.IsChange:=true;
  end
    else
  begin
    WritingSize:=0;
    while (Count>0) do
    begin
      // если кластеров в таблице не хватает, то получаем новые:
      ClusterIdx:=(Strm.Data.fPosition and $ffffffffffffe000) shr 13;
      while (Length(Strm.Data.SectorsTable)<=ClusterIdx) do
      begin
        Cluster:=GCF_AllocateCluster();
        if (uint32_t(Cluster)>=fDataHeader.ClusterCount) or (Cluster=-1) then
          break;
        SetLength(Strm.Data.SectorsTable, length(Strm.Data.SectorsTable)+1);
        Strm.Data.SectorsTable[length(Strm.Data.SectorsTable)-1]:=Cluster;
      end;
      if (uint32_t(ClusterIdx)=fDataHeader.ClusterCount) or (uint32_t(ClusterIdx)=fDataBlockTerminator) then
        break;

      ClusterIdx:=Strm.Data.SectorsTable[ClusterIdx];
      if uint32_t(ClusterIdx)=fDataHeader.ClusterCount then
      begin
        result:=WritingSize;
        Exit;
      end;
      // получаем размер и позицию записываемого кусочка в текущем кластере
      WritePos:=(Strm.Data.fPosition and $00001fff) shr 13;
      fStream.Seek(integer(fDataHeader.FirstClusterOffset)+ClusterIdx*HL_GCF_BLOCK_SIZE+WritePos, spBegin);
      WriteSize:=HL_GCF_BLOCK_SIZE;
      if (WriteSize>HL_GCF_BLOCK_SIZE-WritePos) then
        WriteSize:=HL_GCF_BLOCK_SIZE-WritePos;
      if (WriteSize>Count) then
        WriteSize:=Count;
      if (WriteSize>Strm.Data.fSize-Strm.Data.fPosition) then
        WriteSize:=Strm.Data.fSize-Strm.Data.fPosition;

      if fStream.Position+WriteSize<fStream.Size then
        fStream.Size:=fStream.Position+WriteSize;

      WritedSize:=fStream.Write(Buffer^, WriteSize);
      inc(WritingSize, WritedSize);
      inc(Buffer, WritedSize);
      inc(Strm.Data.fPosition, WritedSize);
      dec(Count, WritedSize);
    end;
    result:=WritingSize;
    if result>0 then
      Strm.Data.IsChange:=true;
  end;
end;

procedure TGCFFile.SetFileSize(Strm: TStream; Size: TStrmSize);
var
  BlockIdx, sz: ulong;
  AllSize: int64;
begin
  if Size<>Strm.Data.fSize then
  begin
    Strm.Data.IsChange:=true;
    if not IsNCF then
    begin
      BlockIdx:=lpManifestMapEntries[Strm.Data.fHandle];
      AllSize:=0;
      while BlockIdx<fBATHeader.BlockCount do
      begin
        if (Size<AllSize+lpBATEntries[BlockIdx].FileDataSize) then
        begin
          sz:=Size-AllSize;
          lpBATEntries[BlockIdx].FileDataSize:=sz;
          GCF_DeleteBlock(lpBATEntries[BlockIdx].NextBlockIndex);

          break;
        end;
        inc(AllSize, lpBATEntries[BlockIdx].FileDataSize);
        BlockIdx:=lpBATEntries[BlockIdx].NextBlockIndex;
      end;
      lpManifestNodes[Strm.Data.fHandle].CountOrSize:=Size;
    end
      else Strm.Data.FileStream.Size:=Size;
  end;
  Strm.Data.fSize:=Size;
end;

procedure TGCFFile.CloseFile(Strm: TStream; Flag: ulong = 0);
var
  BlockIdx, NewBlockIdx, NewSize, Offset, CheckIdx, Check, Size: ulong;
  AllSize: int64;
  buf: array of byte;
begin

 if (not IsNCF) then
 begin
  // изменяем размер в каждом блоке файла, уменьшая его при необходимости
  BlockIdx:=lpManifestMapEntries[Strm.Data.fHandle];
  AllSize:=ItemSize[Strm.Data.fHandle].Size;
  Offset:=0;

  if Strm.Data.IsChange then
  begin
    // при необходимости - создаем новые блоки
    if (BlockIdx=fBATHeader.BlockCount) then
    begin
      if (AllSize>$7fffffff) then NewSize:=$7fffffff
        else NewSize:=AllSize;
      dec(AllSize, NewSize);

      NewBlockIdx:=fBATHeader.LastUsedBlock+1;
      lpManifestMapEntries[Strm.Data.fHandle]:=NewBlockIdx;
      lpBATEntries[NewBlockIdx].Flags:=Flag;
      lpBATEntries[NewBlockIdx].FileDataOffset:=Offset;
      lpBATEntries[NewBlockIdx].FileDataSize:=NewSize;
      lpBATEntries[NewBlockIdx].FirstClusterIndex:=fDataBlockTerminator;
      lpBATEntries[NewBlockIdx].NextBlockIndex:=fBATHeader.BlockCount;
      lpBATEntries[NewBlockIdx].PreviousBlockIndex:=BlockIdx;
      lpBATEntries[NewBlockIdx].ManifestIndex:=lpBATEntries[BlockIdx].ManifestIndex;
      inc(fBATHeader.LastUsedBlock);
      fIsChangeHeader[HEADER_BAT_HEADER]:=true;
      fIsChangeHeader[HEADER_BAT]:=true;
    end;

    while (BlockIdx<>fBATHeader.BlockCount) do
    begin
      if lpBATEntries[BlockIdx].FileDataSize<=AllSize then
      begin
        // конец файла - удаляем хвост текущей цепочки кластеров и у всех последующих блоков данного файла
        lpBATEntries[BlockIdx].FileDataSize:=AllSize;
        GCF_DeleteBlock(lpBATEntries[BlockIdx].NextBlockIndex);
        lpBATEntries[BlockIdx].NextBlockIndex:=fBATHeader.BlockCount;
      end;

      if (lpBATEntries[BlockIdx].NextBlockIndex=fBATHeader.BlockCount) and
       (lpBATEntries[BlockIdx].FileDataSize<AllSize) then
      begin
        while (AllSize>0) do
        begin
          if (AllSize>$ffffffff) then NewSize:=$7fffffff
            else NewSize:=AllSize;
          inc(Offset, NewSize);
          lpBATEntries[BlockIdx].FileDataSize:=NewSize;
          dec(AllSize, NewSize);

          // при необходимости - создаем новые блоки
          if (AllSize>0) then
          begin
            NewBlockIdx:=fBATHeader.LastUsedBlock+1;
            lpBATEntries[BlockIdx].NextBlockIndex:=NewBlockIdx;

            lpBATEntries[NewBlockIdx].Flags:=lpBATEntries[BlockIdx].Flags;
            lpBATEntries[NewBlockIdx].FileDataOffset:=Offset;
            lpBATEntries[NewBlockIdx].FileDataSize:=AllSize;
            lpBATEntries[NewBlockIdx].FirstClusterIndex:=fDataBlockTerminator;
            lpBATEntries[NewBlockIdx].NextBlockIndex:=fBATHeader.BlockCount;
            lpBATEntries[NewBlockIdx].PreviousBlockIndex:=BlockIdx;
            lpBATEntries[NewBlockIdx].ManifestIndex:=lpBATEntries[BlockIdx].ManifestIndex;
            inc(fBATHeader.LastUsedBlock);
          end;
        end;
      end
        else inc(Offset, lpBATEntries[BlockIdx].FileDataSize);

      dec(AllSize, lpBATEntries[BlockIdx].FileDataSize);
      BlockIdx:=lpBATEntries[BlockIdx].NextBlockIndex;
      fIsChangeHeader[HEADER_BAT_HEADER]:=true;
      fIsChangeHeader[HEADER_BAT]:=true;
    end;

    // меняем длину таблицы секторов
    NewSize:=(Strm.Data.fSize and $ffffffffffffe000) shr 13;
    if ((Strm.Data.fSize and $00001fff)>0) then
      inc(NewSize);
    if NewSize<>ulong(Length(Strm.Data.SectorsTable)) then
    begin
      {for i:=NewSize-1 to Length(Strm.Data.SectorsTable)-1 do
        GCF_IsClusterFree()    }
      SetLength(Strm.Data.SectorsTable, NewSize);
    end;
  end;
 end;

    // пересчет контрольных сумм
    CheckIdx:=lpFileIdChecksumTableEntries[lpManifestNodes[Strm.Data.fHandle].FileId].FirstChecksumIndex;
    AllSize:=Strm.Size;
    SetLength(buf, HL_GCF_CHECKSUM_LENGTH);
    Strm.Position:=0;
    while AllSize>0 do
    begin
      Size:=Strm.Read(buf[0], HL_GCF_CHECKSUM_LENGTH);
      Check:=Checksum(@buf[0], Size);
      lpChecksumEntries[CheckIdx]:=Check;
      dec(AllSize, Size);
      inc(CheckIdx);
    end;
    SetLength(buf, 0);

    GCF_RebuildClustersTable(Strm.Data.fHandle, @Strm.Data.SectorsTable);
    GCF_BuildBitMap();
    CalculateChecksumsForHeaders();
    //SaveChanges();
    SaveToStream(fStream);

  if (IsNCF) then
  begin
    Strm.Data.FileStream.Free;
    //Exit;
  end;
end;

constructor TGCFFile.Create(CommonPath: string = '');
begin
  inherited Create();
  Self.CommonPath:=IncludeTrailingPathDelimiter(CommonPath);
  ParanoiaSave:=true;
  IgnoreCheckError:=false;
  StreamMethods.fSeek:=StreamOnStream_Seek;
  StreamMethods.fGetSiz:=StreamOnStream_GetSize;
  StreamMethods.fSetSiz:=StreamOnStream_SetSize;
  StreamMethods.fRead:=StreamOnStream_Read;
  StreamMethods.fWrite:=StreamOnStream_Write;
  StreamMethods.fClose:=StreamOnStream_Close;
  FillChar(fIsChangeHeader[0], Length(fIsChangeHeader), false);
  Stop:=false;
end;

destructor TGCFFile.Destroy;
begin
  Close();
  inherited Destroy();
end;

////////////////////////////////////////////////////////////////////////////////
//                        методы загрузки/сохранения                          //
////////////////////////////////////////////////////////////////////////////////

function TGCFFile.LoadFromFile(FileName: string): boolean;
begin
  result:=false;
  Close();
  if (not FileExists(FileName)) then
    Exit;
  fStream:=TStream.CreateReadWriteFileStream(FileName);
  if (fStream.Handle=INVALID_HANDLE_VALUE) then
  begin
    fStream.Free;
    Exit;
  end;
  fFileName:=FileName;

  result:=LoadFromStream(fStream);
end;

function TGCFFile.LoadFromStream(Stream: TStream): boolean;
{var
  check, k, c: pByte;
  key: TRSAKey;
  str: TStream;
  s: AnsiString;
  i, j: integer;}
begin
  result:=false;
  fStream:=Stream;

  // File header
  if fStream.Read(fFileHeader, sizeof(TCache_FileHeader))=0 then
    Exit;
  if (fFileHeader.Checksum<>HeaderChecksum(@fFileHeader.HeaderVersion, SIZE_HEADER_CHECK)) then
  begin
    fStream.Free;
    Exit;
  end;
  fIsNCF:=(fFileHeader.CacheType=CACHE_TYPE_NCF);

  if (not IsNCF) then
  begin
    // Block allocation table
    fStream.Read(fBATHeader, sizeof(TCache_BlockAllocationTableHeader));
    if (fBATHeader.Checksum<>HeaderChecksum2(@fBATHeader.BlockCount, SIZE_BAT_HEADER_CHECK)) then
    begin
      fStream.Free;
      Exit;
    end;
    SetLength(lpBATEntries, fBATHeader.BlockCount);
    fStream.Read(lpBATEntries[0], fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry));
    // File allocation table
    fStream.Read(fFATHeader, sizeof(TCache_FileAllocationTableHeader));
    if (fFATHeader.Checksum<>HeaderChecksum2(@fFATHeader.ClusterCount, SIZE_FAT_HEADER_CHECK)) then
    begin
      fStream.Free;
      Exit;
    end;
    SetLength(lpFATEntries, fFATHeader.ClusterCount);
    fStream.Read(lpFATEntries[0], fFATHeader.ClusterCount*sizeof(TCache_FileAllocationTableEntry));
  end;

  // Manifest
  fStream.Read(fManifestHeader, sizeof(TCache_ManifestHeader));
  SetLength(lpManifestNodes, ItemsCount);
   fStream.Read(lpManifestNodes[0], ItemsCount*sizeof(TCache_ManifestNode));
  SetLength(fNameTable, fManifestHeader.NameSize);
   fStream.Read(fNameTable[1], fManifestHeader.NameSize);
  SetLength(lpHashTableKeys, fManifestHeader.HashTableKeyCount);
   fStream.Read(lpHashTableKeys[0], fManifestHeader.HashTableKeyCount*sizeof(uint32_t));
  SetLength(lpHashTableIndices, fManifestHeader.NodeCount);
   fStream.Read(lpHashTableIndices[0], fManifestHeader.NodeCount*sizeof(uint32_t));
  SetLength(lpMinimumFootprintEntries, fManifestHeader.NumOfMinimumFootprintFiles);
   fStream.Read(lpMinimumFootprintEntries[0], fManifestHeader.NumOfMinimumFootprintFiles*sizeof(uint32_t));
  SetLength(lpUserConfigEntries, fManifestHeader.NumOfUserConfigFiles);
   fStream.Read(lpUserConfigEntries[0], fManifestHeader.NumOfUserConfigFiles*sizeof(uint32_t));

  if (fManifestHeader.Checksum<>ManifestChecksum(@fManifestHeader, @lpManifestNodes[0],
   @fNameTable[1], @lpHashTableKeys[0], @lpHashTableIndices[0], @lpMinimumFootprintEntries[0], @lpUserConfigEntries[0])) then
  begin
    fStream.Free;
    Exit;
  end;

  // Manifest map
  fStream.Read(fManifestMapHeader, sizeof(TCache_ManifestMapHeader));
  SetLength(lpManifestMapEntries, ItemsCount);
   fStream.Read(lpManifestMapEntries[0], ItemsCount*sizeof(uint32_t));

  // Checksum's
  fStream.Read(fChecksumDataContainer, sizeof(TCache_ChecksumDataContainer));
  fStream.Read(fFileIdChecksumTableHeader, sizeof(TCache_FileIdChecksumTableHeader));
  SetLength(lpFileIdChecksumTableEntries, fFileIdChecksumTableHeader.FileIdCount);
   fStream.Read(lpFileIdChecksumTableEntries[0], sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount);
  SetLength(lpChecksumEntries, fFileIdChecksumTableHeader.ChecksumCount);
   fStream.Read(lpChecksumEntries[0], sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount));
  fStream.Read(lpChecksumSignature[0], $80);
    (*
  CheckChecksum(@fFileIdChecksumTableHeader, @fChecksumDataContainer, @lpFileIdChecksumTableEntries[0], @lpChecksumEntries[0], c);
  GetMem(k, 128);
  key.n:=nil;
  key.d:=nil;
  key.e:=nil;
  INew(key.n);
  //ISetStr(key.n, AnsiString({$I RSA_NK_n.inc}));
  INew(key.d);
  INew(key.e);
  ISetStr(key.d, AnsiString('16#11#'));
  ISetStr(key.e, AnsiString('16#11#'));
  for i:=1 to 7691 do
  begin
    writeln(i);
    str:=TStream.CreateReadFileStream('e:\Projects\Steam\FileFormats\BLOB\exe\keys\'+Int2Str(i)+'.bin');
    str.Seek(29, spBegin);
    str.Read(k^, 128);
    str.Free;
    s:='16#';
    for j:=0 to 127 do
      s:=s+Wide2Ansi(Int2Hex(k[j], 2));
    ISetStr(key.n, AnsiString(s+'#'));
    //check:=RSADecrypt(key, @lpChecksumSignature[0], $80);
    check:=RSAEncrypt(key, c, $80);
    if (check[0]=lpChecksumSignature[0]) and (check[1]=lpChecksumSignature[1]) then
    //if (check[0]=$00){ and (check[1]=$01) }then
      Writeln(s);
    FreeMem(check, $80);
  end;

  (*key.n:=nil;
  key.d:=nil;
  key.e:=nil;
  INew(key.n);
  ISetStr(key.n, AnsiString({$I RSA_NK_n.inc}));
  INew(key.d);
  ISetStr(key.d, AnsiString('16#11#'));
  ISetStr(key.n, AnsiString('16#8C6B8E70602BB9B0B18289A8F5CAEB7CD78A0ACE26DF02BF8434B'+
   'A30F7646C69FB3C32124990DBC7D3BC77460D98BD4144CC3472F7AA0B6B92C76C4790DA198C53BABFD731F5B'+
   '8671AB346F4FE994E5063DA339DBD032D61A84ABA35408092EE2A5CE32CCD4356C17FC59CEB2E28493848F0A'+
   'E5D3B8EB1A080D9F8681E6D1D9B#'));
  check:=RSADecrypt(key, @lpChecksumEntries[0], $80);
  //if memcmp(check, @lpChecksumSignature[0], $80)<>0 then
  if check[0]<>0 then
  begin
    fStream.Free;
    Exit;
  end;  *)

  fStream.Read(fLatestApplicationVersion, sizeof(uint32_t));
  if (not IsNCF) then
    fStream.Read(fDataHeader, sizeof(TCache_DataHeader));

  if fFATHeader.IsLongTerminator=0 then
    fDataBlockTerminator:=$0000FFFF
      else fDataBlockTerminator:=$FFFFFFFF;

  if (not IsNCF) then
    GCF_BuildBitMap();

  result:=true;
  if IsNCF then PackageType:=PACKAGE_NCF
    else PackageType:=PACKAGE_GCF;
end;

procedure TGCFFile.LoadFromMem(Manifest, Checksum: pByte; MS, CS: uint32; AsGCF: boolean);
begin
  fIsNCF:=(not AsGCF);

  // Manifest
  Move(Manifest^, fManifestHeader, sizeof(TCache_ManifestHeader));
  inc(Manifest, sizeof(TCache_ManifestHeader));
  {if (fManifestHeader.Checksum<>ManifestChecksum(@fManifestHeader, @lpManifestNodes[0],
   @fNameTable[1], @lpHashTableKeys[0], @lpHashTableIndices[0], @lpMinimumFootprintEntries[0], @lpUserConfigEntries[0])) then
    Exit;}
  SetLength(lpManifestNodes, ItemsCount);
   Move(Manifest^, lpManifestNodes[0], ItemsCount*sizeof(TCache_ManifestNode));
   inc(Manifest, ItemsCount*sizeof(TCache_ManifestNode));
  SetLength(fNameTable, fManifestHeader.NameSize);
   Move(Manifest^, fNameTable[1], fManifestHeader.NameSize);
   inc(Manifest, fManifestHeader.NameSize);
  SetLength(lpHashTableKeys, fManifestHeader.HashTableKeyCount);
   Move(Manifest^, lpHashTableKeys[0], fManifestHeader.HashTableKeyCount*sizeof(uint32_t));
   inc(Manifest, fManifestHeader.HashTableKeyCount*sizeof(uint32_t));
  SetLength(lpHashTableIndices, fManifestHeader.NodeCount);
   Move(Manifest^, lpHashTableIndices[0], fManifestHeader.NodeCount*sizeof(uint32_t));
   inc(Manifest, fManifestHeader.NodeCount*sizeof(uint32_t));
  SetLength(lpMinimumFootprintEntries, fManifestHeader.NumOfMinimumFootprintFiles);
   Move(Manifest^, lpMinimumFootprintEntries[0], fManifestHeader.NumOfMinimumFootprintFiles*sizeof(uint32_t));
   inc(Manifest, fManifestHeader.NumOfMinimumFootprintFiles*sizeof(uint32_t));
  SetLength(lpUserConfigEntries, fManifestHeader.NumOfUserConfigFiles);
   Move(Manifest^, lpUserConfigEntries[0], fManifestHeader.NumOfUserConfigFiles*sizeof(uint32_t));
   //inc(Manifest, fManifestHeader.NumOfUserConfigFiles*sizeof(uint32_t));

  // File header
  fFileHeader.HeaderVersion:=1;
  if IsNCF then fFileHeader.CacheType:=CACHE_TYPE_NCF
    else fFileHeader.CacheType:=CACHE_TYPE_GCF;
  if IsNCF then fFileHeader.FormatVersion:=1
    else fFileHeader.FormatVersion:=6;
  fFileHeader.ApplicationID:=fManifestHeader.ApplicationID;
  fFileHeader.ApplicationVersion:=fManifestHeader.ApplicationVersion;
  fFileHeader.IsMounted:=0;
  fFileHeader.Dummy0:=0;
  fFileHeader.FileSize:=0;
  if IsNCF then
  begin
    fFileHeader.ClusterSize:=0;
    fFileHeader.ClusterCount:=0;
  end
    else
  begin
    fFileHeader.ClusterSize:=HL_GCF_BLOCK_SIZE;
    fFileHeader.ClusterCount:=ItemSize[0].Sectors;
  end;
  fFileHeader.Checksum:=HeaderChecksum(@fFileHeader.HeaderVersion, SIZE_HEADER_CHECK);

  {if (not IsNCF) then
  begin
    // Block allocation table
    fStream.Read(fBATHeader, sizeof(TCache_BlockAllocationTableHeader));
    if (fBATHeader.Checksum<>HeaderChecksum2(@fBATHeader.BlockCount, SIZE_BAT_HEADER_CHECK)) then
    begin
      fStream.Free;
      Exit;
    end;
    SetLength(lpBATEntries, fBATHeader.BlockCount);
    fStream.Read(lpBATEntries[0], fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry));
    // File allocation table
    fStream.Read(fFATHeader, sizeof(TCache_FileAllocationTableHeader));
    if (fFATHeader.Checksum<>HeaderChecksum2(@fFATHeader.ClusterCount, SIZE_FAT_HEADER_CHECK)) then
    begin
      fStream.Free;
      Exit;
    end;
    SetLength(lpFATEntries, fFATHeader.ClusterCount);
    fStream.Read(lpFATEntries[0], fFATHeader.ClusterCount*sizeof(TCache_FileAllocationTableEntry));
  end;   }

  // Manifest map
  fManifestMapHeader.HeaderVersion:=1;
  fManifestMapHeader.Dummy0:=0;
  if not IsNCF then
  begin
    SetLength(lpManifestMapEntries, ItemsCount);
    FillChar(lpManifestMapEntries[0], ItemsCount*sizeof(uint32), 0);
  end;

  // Checksum's
  fChecksumDataContainer.HeaderVersion:=1;
  fChecksumDataContainer.ChecksumSize:=CS;
  Move(Checksum^, fFileIdChecksumTableHeader, sizeof(TCache_FileIdChecksumTableHeader));
  inc(Checksum, sizeof(TCache_FileIdChecksumTableHeader));
  SetLength(lpFileIdChecksumTableEntries, fFileIdChecksumTableHeader.FileIdCount);
  Move(Checksum^, lpFileIdChecksumTableEntries[0], sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount);
  inc(Checksum, sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount);
  SetLength(lpChecksumEntries, fFileIdChecksumTableHeader.ChecksumCount);
  Move(Checksum^, lpChecksumEntries[0], sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount));
  inc(Checksum, sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount));
  Move(Checksum^, lpChecksumSignature[0], $80);
  //inc(Checksum, $80);


  fLatestApplicationVersion:=fFileHeader.ApplicationVersion;
  if (not IsNCF) then
  begin
    //fStream.Read(fDataHeader, sizeof(TCache_DataHeader));
  end;

  {if fFATHeader.IsLongTerminator=0 then
    fDataBlockTerminator:=$0000FFFF
      else fDataBlockTerminator:=$FFFFFFFF;  }

  if (not IsNCF) then
    GCF_BuildBitMap();
end;

procedure TGCFFile.SaveToFile(FileName: string);
begin
  fStream:=TStream.CreateWriteFileStream(FileName);
  if fStream.Handle=INVALID_HANDLE_VALUE then
    Exit;
  SaveToStream(fStream);
end;

procedure TGCFFile.SaveToStream(Stream: TStream);
begin
  fSTream:=Stream;

  fSTream.Position:=0;
  // File header
  fStream.Write(fFileHeader, sizeof(TCache_FileHeader));
  fIsNCF:=(fFileHeader.CacheType=CACHE_TYPE_NCF);

  if (not IsNCF) then
  begin
    // Block allocation table
    fStream.Write(fBATHeader, sizeof(TCache_BlockAllocationTableHeader));
    fStream.Write(lpBATEntries[0], fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry));
    // File allocation table
    fStream.Write(fFATHeader, sizeof(TCache_FileAllocationTableHeader));
    fStream.Write(lpFATEntries[0], fFATHeader.ClusterCount*sizeof(TCache_FileAllocationTableEntry));
  end;

  // Manifest
  fStream.Write(fManifestHeader, sizeof(TCache_ManifestHeader));
  fStream.Write(lpManifestNodes[0], ItemsCount*sizeof(TCache_ManifestNode));
  fStream.Write(fNameTable[1], fManifestHeader.NameSize);
  fStream.Write(lpHashTableKeys[0], fManifestHeader.HashTableKeyCount*sizeof(uint32_t));
  fStream.Write(lpHashTableIndices[0], fManifestHeader.NodeCount*sizeof(uint32_t));
  fStream.Write(lpMinimumFootprintEntries[0], fManifestHeader.NumOfMinimumFootprintFiles*sizeof(uint32_t));
  fStream.Write(lpUserConfigEntries[0], fManifestHeader.NumOfUserConfigFiles*sizeof(uint32_t));

  // Manifest map
  fStream.Write(fManifestMapHeader, sizeof(TCache_ManifestMapHeader));
  fStream.Write(lpManifestMapEntries[0], ItemsCount*sizeof(uint32_t));

  // Checksum's
  fStream.Write(fChecksumDataContainer, sizeof(TCache_ChecksumDataContainer));
  fStream.Write(fFileIdChecksumTableHeader, sizeof(TCache_FileIdChecksumTableHeader));
  fStream.Write(lpFileIdChecksumTableEntries[0], sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount);
  fStream.Write(lpChecksumEntries[0], sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount));
  fStream.Write(lpChecksumSignature[0], $80);

  fStream.Write(fLatestApplicationVersion, sizeof(uint32_t));
  if (not IsNCF) then
    fStream.Write(fDataHeader, sizeof(TCache_DataHeader));
end;

procedure TGCFFile.SaveChanges();
begin
  fStream.Seek(0, spBegin);
  // File header
  if fIsChangeHeader[HEADER_FILE_HEADER] then
    fStream.Write(fFileHeader, sizeof(TCache_FileHeader))
      else fStream.Seek(sizeof(TCache_FileHeader), spCurrent);
  fIsNCF:=(fFileHeader.CacheType=CACHE_TYPE_NCF);

  if (not IsNCF) then
  begin
    // Block allocation table
    if fIsChangeHeader[HEADER_BAT_HEADER] then
      fStream.Write(fBATHeader, sizeof(TCache_BlockAllocationTableHeader))
        else fStream.Seek(sizeof(TCache_BlockAllocationTableHeader), spCurrent);
    if fIsChangeHeader[HEADER_BAT] then
      fStream.Write(lpBATEntries[0], fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry))
        else fStream.Seek(fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry), spCurrent);
    // File allocation table
    if fIsChangeHeader[HEADER_FAT_HEADER] then
      fStream.Write(fFATHeader, sizeof(TCache_FileAllocationTableHeader))
        else fStream.Seek(sizeof(TCache_FileAllocationTableHeader), spCurrent);
    if fIsChangeHeader[HEADER_FAT_HEADER] then
      fStream.Write(lpFATEntries[0], fFATHeader.ClusterCount*sizeof(TCache_FileAllocationTableEntry))
        else fStream.Seek(fFATHeader.ClusterCount*sizeof(TCache_FileAllocationTableEntry), spCurrent);
  end;

  // Manifest
  if fIsChangeHeader[HEADER_MANIFEST_HEADER] then
    fStream.Write(fManifestHeader, sizeof(TCache_ManifestHeader))
      else fStream.Seek(sizeof(TCache_ManifestHeader), spCurrent);
  if fIsChangeHeader[HEADER_MANIFEST_NODES] then
    fStream.Write(lpManifestNodes[0], ItemsCount*sizeof(TCache_ManifestNode))
      else fStream.Seek(ItemsCount*sizeof(TCache_ManifestNode), spCurrent);
  if fIsChangeHeader[HEADER_NAMES] then
    fStream.Write(fNameTable[1], fManifestHeader.NameSize)
      else fStream.Seek(fManifestHeader.NameSize, spCurrent);
  if fIsChangeHeader[HEADER_HASH_KEYS] then
    fStream.Write(lpHashTableKeys[0], fManifestHeader.HashTableKeyCount*sizeof(uint32_t))
      else fStream.Seek(fManifestHeader.HashTableKeyCount*sizeof(uint32_t), spCurrent);
  if fIsChangeHeader[HEADER_HASH_INDICIES] then
    fStream.Write(lpHashTableIndices[0], fManifestHeader.NodeCount*sizeof(uint32_t))
      else fStream.Seek(fManifestHeader.NodeCount*sizeof(uint32_t), spCurrent);
  if fIsChangeHeader[HEADER_MFE] then
    fStream.Write(lpMinimumFootprintEntries[0], fManifestHeader.NumOfMinimumFootprintFiles*sizeof(uint32_t))
      else fStream.Seek(fManifestHeader.NumOfMinimumFootprintFiles*sizeof(uint32_t), spCurrent);
  if fIsChangeHeader[HEADER_USER_CONFIG] then
    fStream.Write(lpUserConfigEntries[0], fManifestHeader.NumOfUserConfigFiles*sizeof(uint32_t))
      else fStream.Seek(fManifestHeader.NumOfUserConfigFiles*sizeof(uint32_t), spCurrent);

  // Manifest map
  if fIsChangeHeader[HEADER_MANIFEST_MAP_HEADER] then
    fStream.Write(fManifestMapHeader, sizeof(TCache_ManifestMapHeader))
      else fStream.Seek(sizeof(TCache_ManifestMapHeader), spCurrent);
  if fIsChangeHeader[HEADER_MANIFEST_MAP] then
    fStream.Write(lpManifestMapEntries[0], ItemsCount*sizeof(uint32_t))
      else fStream.Seek(ItemsCount*sizeof(uint32_t), spCurrent);

  // Checksum's
  if fIsChangeHeader[HEADER_CHECKSUM_CONTAINER] then
    fStream.Write(fChecksumDataContainer, sizeof(TCache_ChecksumDataContainer))
      else fStream.Seek(sizeof(TCache_ChecksumDataContainer), spCurrent);
  if fIsChangeHeader[HEADER_FILEID_HEADER] then
    fStream.Write(fFileIdChecksumTableHeader, sizeof(TCache_FileIdChecksumTableHeader))
      else fStream.Seek(sizeof(TCache_FileIdChecksumTableHeader), spCurrent);
  if fIsChangeHeader[HEADER_FILEID] then
    fStream.Write(lpFileIdChecksumTableEntries[0], sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount)
      else fStream.Seek(sizeof(TCache_FileIdChecksumTableEntry)*fFileIdChecksumTableHeader.FileIdCount, spCurrent);
  if fIsChangeHeader[HEADER_CHECKSUMS] then
    fStream.Write(lpChecksumEntries[0], sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount))
      else fStream.Seek(sizeof(ulong)*(fFileIdChecksumTableHeader.ChecksumCount), spCurrent);
  if fIsChangeHeader[HEADER_CHECKSUM_SIGNATURE] then
    fStream.Write(lpChecksumSignature[0], $80)
      else fStream.Seek($80, spCurrent);

  if fIsChangeHeader[HEADER_LAV] then
    fStream.Write(fLatestApplicationVersion, sizeof(uint32_t))
      else fStream.Seek(sizeof(uint32_t), spCurrent);
  if (not IsNCF) then
    fStream.Write(fDataHeader, sizeof(TCache_DataHeader));
  FillChar(fIsChangeHeader[0], length(fIsChangeHeader), false);
end;

procedure TGCFFile.SaveToStreamAsInfo(Stream: TStream);
var
  FileHeader: TCache_FileHeader;
  tmpStream: TStream;
begin
  tmpStream:=fStream;
  FileHeader:=fFileHeader;
  fFileHeader.CacheType:=CACHE_TYPE_NCF;
  fFileHeader.FormatVersion:=1;
  fFileHeader.ClusterCount:=0;
  SaveToStream(Stream);
  fFileHeader.FileSize:=Stream.Position;
  fFileHeader.Checksum:=HeaderChecksum(@fFileHeader.HeaderVersion, SIZE_HEADER_CHECK);
  Stream.Seek(0, spBegin);
  Stream.Write(fFileHeader, sizeof(TCache_FileHeader));
  fFileHeader:=FileHeader;
  fStream:=tmpStream;
end;

procedure TGCFFile.Close();
begin
  fStream.Free;
  SetLength(self.lpBATEntries, 0);
  SetLength(self.lpFATEntries, 0);
  SetLength(self.lpManifestNodes, 0);
  SetLength(self.fNameTable, 0);
  SetLength(self.lpHashTableKeys, 0);
  SetLength(self.lpHashTableIndices, 0);
  SetLength(self.lpMinimumFootprintEntries, 0);
  SetLength(self.lpUserConfigEntries, 0);
  SetLength(self.lpManifestMapEntries, 0);
  SetLength(self.lpChecksumEntries, 0);
end;

////////////////////////////////////////////////////////////////////////////////
//                        методы обработки элементов                          //
////////////////////////////////////////////////////////////////////////////////

function TGCFFile.ExtractItem(Item: ulong; Dest: string): boolean;
  function Recurse(Idx: ulong; Dst: string): int64;
  var
    f: ulong;
    s: string;
  begin
    result:=0;
    if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE=0 then
    begin
      Idx:=lpManifestNodes[Idx].ChildIndex;
      while Idx<>0 do
      begin
        if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE=0 then
        begin
          s:=GetItemName(Idx);
          s:=FixSlashes(IncludeTrailingPathDelimiter(Dst+s));
          CreateDirectory(pChar(s), nil);  // aka MkDir
          f:=Recurse(Idx, s);
          if Stop then
            Exit;
        end
          else f:=Recurse(Idx, Dst);
        inc(result, f);

        Idx:=lpManifestNodes[Idx].NextIndex;
      end;
    end
      else
    begin
      {if Assigned(fOnProgress) then
        fOnProgress(ItemName[Idx], Idx, fManifestHeader.NodeCount, Data);
      if Assigned(fOnProgressObj) then
        fOnProgressObj(ItemName[Idx], Idx, fManifestHeader.NodeCount, Data);     }
      ExtractFile(Idx, Dst+ItemName[Idx], false);
      result:=ItemSize[Idx].Size;
    end;
  end;
var
  Size: int64;
begin
  Size:=GetItemSize(Item).Size;
  if Assigned(OnProgress) then
    OnProgress('', -2, Size, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', -2, Size, Data);
  if lpManifestNodes[Item].Attributes and HL_GCF_FLAG_FILE=HL_GCF_FLAG_FILE then
  begin
    //if ExtractFileName(Dest)<>GetItemName(Item) then
      Dest:=IncludeTrailingPathDelimiter(Dest);//+GetItemName(Item);
  end
    else
  begin
    ForceDirectories(Dest);
    Dest:=IncludeTrailingPathDelimiter(Dest);
  end;
  result:=(Recurse(Item, Dest)=Size);
  if Stop then
  begin
    if Assigned(OnError) then
      OnError('', ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
end;

function TGCFFile.ExtractFile(Item: integer; Dest: string; IsValidation: boolean = false): int64;
var
  StreamF, StreamP: TStream;
  CheckSize, CheckFile, CheckFS, CheckIdx: uint32_t;
  buf: array of byte;
  Size: int64;
begin
  result:=0;
  StreamP:=OpenFile(Item, ACCES_READ);
  if (StreamP=nil) then
    Exit;

  Size:=ItemSize[Item].Size;
  if Assigned(OnProgress) then
    OnProgress(ItemPath[Item], 0, Size, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj(ItemPath[Item], 0, Size, Data);

  StreamF:=nil;
  if (not IsValidation) then
  begin
    if DirectoryExists(Dest) then
      Dest:=IncludeTrailingPathDelimiter(Dest)+ExtractFileName(ItemName[Item]);
    StreamF:=TStream.CreateWriteFileStream(Dest);
    StreamF.Size:=ItemSize[Item].Size;
    if StreamF.Handle=INVALID_HANDLE_VALUE then
    begin
      StreamF.Free;
      Exit;
    end;
  end;

  SetLength(buf, HL_GCF_CHECKSUM_LENGTH);
  CheckSize:=HL_GCF_CHECKSUM_LENGTH;
  while ((StreamP.Position<StreamP.Size) and (CheckSize=HL_GCF_CHECKSUM_LENGTH)) do
  begin
    CheckIdx:=lpFileIdChecksumTableEntries[lpManifestNodes[Item].FileId].FirstChecksumIndex+
     ((StreamP.Position and $ffffffffffff8000) shr 15);
    //WaitForSingleObject(GlobalGCFSemaphore, INFINITE);
    CheckSize:=StreamP.Read(buf[0], HL_GCF_CHECKSUM_LENGTH);
    //ReleaseSemaphore(GlobalGCFSemaphore, 1, nil);

    CheckFile:=Checksum(@buf[0], CheckSize);
    CheckFS:=lpChecksumEntries[CheckIdx];
    if (CheckFile<>CheckFS) and (not IgnoreCheckError) then
    begin
      if Assigned(OnError) then
        OnError(GetItemPath(Item), ERROR_CHECKSUM, Data);
      if Assigned(OnErrorObj) then
        OnErrorObj(GetItemPath(Item), ERROR_CHECKSUM, Data);
      break;
    end
      else if (not IsValidation) then
        StreamF.Write(buf[0], CheckSize);
    inc(result, CheckSize);

    //StreamP.Position:=StreamP.Position+CheckSize;

    if Assigned(OnProgress) then
      OnProgress('', result, Size, Data);
    if Assigned(OnProgressObj) then
      OnProgressObj('', result, Size, Data);
    if Stop then
      break;
  end;
  SetLength(buf, 0);
  StreamP.Free;
  if (not IsValidation) then
    StreamF.Free;
end;

{$IFDEF DECRYPT}
const
  IV: array[0..15] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

procedure DecryptFileChunk(buf: pByte; ChunkSize: integer; Key: Pointer);
var
  AES: TCipher_Rijndael;
  src: array[0..HL_GCF_CHECKSUM_LENGTH-1] of byte;
begin
  Move(buf^, src[0], HL_GCF_CHECKSUM_LENGTH);
  AES:=TCipher_Rijndael.Create();
  AES.Init(Key^, 16, IV[0], 16);
  AES.Mode:=cmCFBx;
  AES.Decode(src[0], buf^, ChunkSize);
  AES.Free;
end;

function TGCFFile.DecryptFile(Item: integer; Key: Pointer): int64;
var
  StreamP: TStream;
  CheckSize, CheckFile, CheckFS, CheckIdx, sz: uint32_t;
  buf: array of byte;
  dec: array[0..HL_GCF_CHECKSUM_LENGTH] of byte;
  CompSize, UncompSize: integer;
  Size: int64;
begin
  result:=0;
  StreamP:=OpenFile(Item, ACCES_READWRITE);
  if (StreamP=nil) then
    Exit;

  Size:=ItemSize[Item].Size;
  if Assigned(OnProgress) then
    OnProgress(ItemName[Item], 0, Size, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj(ItemName[Item], 0, Size, Data);

  SetLength(buf, HL_GCF_CHECKSUM_LENGTH);
  CheckSize:=HL_GCF_CHECKSUM_LENGTH;
  while ((StreamP.Position<StreamP.Size) and (CheckSize=HL_GCF_CHECKSUM_LENGTH)) do
  begin
    CheckIdx:=lpFileIdChecksumTableEntries[lpManifestNodes[Item].FileId].FirstChecksumIndex+
     ((StreamP.Position and $ffffffffffff8000) shr 15);
    CheckSize:=StreamP.Read(buf[0], 8);

    Move(buf[0], CompSize, 4);
    Move(buf[4], UncompSize, 4);
    if (ulong(UncompSize)>fManifestHeader.CompressionBlockSize) or (CompSize>UncompSize) or (UncompSize<-1) or (CompSize<-1) then
    begin
      //Chunk is not compressed!
      CheckSize:=StreamP.Read(buf[8], HL_GCF_CHECKSUM_LENGTH-8);
      DecryptFileChunk(@buf[0], CheckSize, Key);
    end
      else if ((ulong(UncompSize)<=fManifestHeader.CompressionBlockSize) and (CompSize<=UncompSize)) and ((UncompSize>-1) and (CompSize>-1)) then
    begin
      CheckSize:=StreamP.Read(buf[8], UncompSize-8);
      CheckFile:=UncompSize;
      //Chunk is compressed!
      if (CompSize mod 16=0) then sz:=CompSize
        else sz:=CompSize+16-(CompSize mod 16);
      Move(buf[8], dec[0], sz);
      DecryptFileChunk(@dec[0], sz, Key);
      uncompress(@buf[0], CheckFile, @dec[0], sz);
    end;
    StreamP.Seek(-CheckSize, spCurrent);
    StreamP.Write(buf[0], CheckSize);


    CheckFile:=Checksum(@buf[0], CheckSize);
    CheckFS:=lpChecksumEntries[CheckIdx];
    if (CheckFile<>CheckFS) and (not IgnoreCheckError) then
    begin
      if Assigned(OnError) then
        OnError(GetItemPath(Item), ERROR_CHECKSUM, Data);
      if Assigned(OnErrorObj) then
        OnErrorObj(GetItemPath(Item), ERROR_CHECKSUM, Data);
      break;
    end;
    inc(result, CheckSize);

    //StreamP.Position:=StreamP.Position+CheckSize;

    if Assigned(OnProgress) then
      OnProgress('', result, Size, Data);
    if Assigned(OnProgressObj) then
      OnProgressObj('', result, Size, Data);
    if Stop then
      break;
  end;
  lpManifestNodes[Item].Attributes:=lpManifestNodes[Item].Attributes and (not HL_GCF_FLAG_ENCRYPTED);
  fIsChangeHeader[HEADER_MANIFEST_NODES]:=true;
  SaveChanges();
  SetLength(buf, 0);
end;
{$ENDIF}

function TGCFFile.ExtractForGame(Dest: string): boolean;
var
  i: integer;
  AllSize, CSize: int64;
begin
  AllSize:=0;
  CSize:=0;
  for i:=0 to fManifestHeader.NumOfMinimumFootprintFiles-1 do
    inc(AllSize, ItemSize[lpMinimumFootprintEntries[i]].Size);

  if Assigned(OnProgress) then
    OnProgress('', 0, 0, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', 0, 0, Data);
  for i:=0 to fManifestHeader.NumOfMinimumFootprintFiles-1 do
  begin
    inc(CSize, ExtractFile(lpMinimumFootprintEntries[i], Dest+ItemPath[lpMinimumFootprintEntries[i]], false));
    if Stop then
      break;
  end;

  if Stop then
  begin
    if Assigned(OnError) then
      OnError('', ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
  result:=(AllSize=CSize);
end;

function TGCFFile.ValidateItem(Item: integer): boolean;
  function Recurse(Idx: ulong): int64;
  begin
    result:=0;
    if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE=0 then
    begin
      Idx:=lpManifestNodes[Idx].ChildIndex;
      while (Idx<>0) and (Idx<>INVALID_HANDLE_VALUE) do
      begin
        inc(result, Recurse(Idx));
        if Stop then
          Exit;

        Idx:=lpManifestNodes[Idx].NextIndex;
      end;
    end
      else
    begin
      if (lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_ENCRYPTED=HL_GCF_FLAG_ENCRYPTED) then
      begin
        result:=ItemSize[Idx].Size;
        Exit;
      end;
      result:=ExtractFile(Idx, CommonPath, true);
    end;
  end;
var
  Size, CSize: int64;
begin
  Size:=ItemSize[Item].Size;
  if Assigned(OnProgress) then
    OnProgress('', -2, Size, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', -2, Size, Data);

  CSize:=Recurse(Item);
  //fCompleted:=CSize/Size;
  result:=(Size=CSize);

  if Stop then
  begin
    if Assigned(OnError) then
      OnError('', ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
end;

function TGCFFile.CorrectItem(Item: integer): boolean;
var
  bad: boolean;
  F: TStream;
  Size, CSize: int64;
  function Recurse(Idx: ulong): int64;
  begin
    result:=0;
    if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE=0 then
    begin
      Idx:=lpManifestNodes[Idx].ChildIndex;
      while (Idx<>0) and (Idx<>INVALID_HANDLE_VALUE) do
      begin
        inc(result, Recurse(Idx));
        if Stop then
          Exit;

        Idx:=lpManifestNodes[Idx].NextIndex;
      end;
    end
      else
    begin
      bad:=(GetCompletion(Idx)<1);
      inc(CSize, ItemSize[Idx].Size);
      if not bad then
        bad:=(ItemSize[Idx].Size<>ExtractFile(Idx, CommonPath, true));
      if Stop then
        Exit;
      if (bad) and (lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_ENCRYPTED <> HL_GCF_FLAG_ENCRYPTED) then
      begin
        if Assigned(OnError) then
          OnError(ItemName[Idx], ERROR_INCOMPLETE, Data);
        if Assigned(OnErrorObj) then
          OnErrorObj(ItemName[Idx], ERROR_INCOMPLETE, Data);
        F:=OpenFile(Idx, ACCES_WRITE);
        F.Size:=0;
        f.Destroy;
      end;
    end;
  end;
begin
  Size:=ItemSize[Item].Size;
  if Assigned(OnProgress) then
    OnProgress('', -2, Size, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', -2, Size, Data);
  CSize:=0;

  Recurse(Item);

  if Stop then
  begin
    if Assigned(OnError) then
      OnError('', ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
  result:=CSize=Size;
end;

{$IFDEF DECRYPT}
function TGCFFile.DecryptItem(Item: integer; Key: string): boolean;
var
  Size, CSize: int64;
  AESKey: array[0..15] of byte;
  i: integer;

  function Recurse(Idx: ulong): int64;
  begin
    result:=0;
    if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE=0 then
    begin
      Idx:=lpManifestNodes[Idx].ChildIndex;
      while (Idx<>0) and (Idx<>INVALID_HANDLE_VALUE) do
      begin
        inc(result, Recurse(Idx));
        if Stop then
          Exit;

        Idx:=lpManifestNodes[Idx].NextIndex;
      end;
    end
      else
    begin
      if Assigned(OnProgress) then
        OnProgress(ItemName[Idx], Idx, fManifestHeader.NodeCount, Data);
      if Assigned(OnProgressObj) then
        OnProgressObj(ItemName[Idx], Idx, fManifestHeader.NodeCount, Data);
      if lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_ENCRYPTED=HL_GCF_FLAG_ENCRYPTED then
        result:=DecryptFile(Idx, @AESKey[0])
          else result:=ItemSize[Idx].Size;
    end;
  end;
begin
  for i:=0 to 15 do
    AESKey[i]:=Hex2Int(Key[i*2+1]+Key[I*2+2]);
  Size:=ItemSize[Item].Size;
  if Assigned(OnProgress) then
    OnProgress('', -2, Size, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', -2, Size, Data);
  CSize:=0;

  Recurse(Item);

  if Stop then
  begin
    if Assigned(OnError) then
      OnError('', ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
  result:=CSize=Size;
end;
{$ENDIF}

function TGCFFile.GetCompletedSize(Item: integer): int64;
var
  FS: int64;
  BlockIdx: ulong;
begin
  result:=0;
  if lpManifestNodes[Item].Attributes and HL_GCF_FLAG_FILE<>HL_GCF_FLAG_FILE then
  begin
    Item:=lpManifestNodes[Item].ChildIndex;
    while Item>0 do
    begin
      inc(result, GetCompletedSize(Item));
      Item:=lpManifestNodes[Item].NextIndex;
      if Stop then
        Exit;
    end;
  end
    else
  begin
    if not IsNCF then
    begin
      BlockIdx:=lpManifestMapEntries[Item];
      while (BlockIdx<fDataHeader.ClusterCount) do
      begin
        inc(result, lpBATEntries[BlockIdx].FileDataSize);
        BlockIdx:=lpBATEntries[BlockIdx].NextBlockIndex;
      end;
    end
      else
    begin
      FS:=FileSize(CommonPath+ItemPath[Item]);
      if (lpManifestNodes[Item].Attributes and HL_GCF_FLAG_BACKUP_LOCAL=HL_GCF_FLAG_BACKUP_LOCAL) then
        inc(result, GetFileSize(Item))
          else //if FS<=ItemSize[Idx]^.Size then
               inc(result, FS);
    end;
  end;
end;

function TGCFFile.GetCompletion(Item: integer): single;
var
  TotalSize, CompleteSize: int64;
  tmp: single;
begin
  {if Assigned(OnProgress) then
    OnProgress('', 0, 0, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', 0, 0, Data); }

  TotalSize:=ItemSize[Item].Size;
  CompleteSize:=GetCompletedSize(Item);
 // Recurse(Item);

 if (IsNCF) and (not DirectoryExists(CommonPath)) then
 begin
   result:=0;
   Exit;
 end;

  if TotalSize>0 then tmp:=CompleteSize/TotalSize
    else tmp:=0.0000;
  if (TotalSize>CompleteSize) and (tmp=1) then
    tmp:=0.9999;
  if tmp>1 then
    tmp:=1;
  result:=tmp;

  if Stop then
  begin
    if Assigned(OnError) then
      OnError('',ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
end;

function TGCFFile.OpenFile(FileName: string; Access: byte): TStream;
var
  Item: integer;
begin
  result:=nil;
  Item:=ItemByPath[FileName];
  if (Item=-1) then
    Exit;
  if ((lpManifestNodes[Item].Attributes and HL_GCF_FLAG_FILE<>HL_GCF_FLAG_FILE) or
   (ItemSize[Item].Size=0)) then
    Exit;

  {if (IsNCF) then
  begin
    result:=TStream.CreateStreamOnStream(@fStreamMethods);
    result.Data.fHandle:=ulong(Item);
    result.Data.Package:=self;
    result.Data.fSize:=(result.Data.Package as TGCFFile).ItemSize[Item].Size;
    result.Data.fPosition:=0;
    CommonPath:=IncludeTrailingPathDelimiter(CommonPath);
    case Access of
      ACCES_READ: result.Data.FileStream:=TStream.CreateFileStream(CommonPath+FileName, OPEN_MODE_READ);
      ACCES_WRITE: result.Data.FileStream:=TStream.CreateFileStream(CommonPath+FileName, OPEN_MODE_WRITE);
      ACCES_READWRITE: result.Data.FileStream:=TStream.CreateFileStream(CommonPath+FileName, OPEN_MODE_READWRITE);
    end;
    //result.Data.FileStream.Seek(0, spBegin);
  end
    else }result:=OpenFile(Item, Access);
end;

function TGCFFile.OpenFile(Item: integer; Access: byte): TStream;
var
  res: TStream;
begin
  res:=TStream.CreateStreamOnStream(@StreamMethods);
  res.Data.fHandle:=ulong(Item);
  res.Data.Package:=self;
  res.Data.fSize:=(res.Data.Package as TGCFFile).ItemSize[Item].Size;
  res.Data.fPosition:=0;

  if (IsNCF) then
  begin
    CommonPath:=IncludeTrailingPathDelimiter(CommonPath);
    case Access of
      ACCES_READ:
        begin
          res.Data.FileStream:=TStream.CreateReadFileStream(CommonPath+ItemPath[Item]);
          res.Methods.fSetSiz:=StreamOnStream_SetSizeNULL;
          res.Methods.fWrite:=StreamOnStream_WriteNULL;
        end;
      ACCES_WRITE:
        begin
          ForceDirectories(ExtractFilePath(CommonPath+ItemPath[Item]));
          res.Data.FileStream:=TStream.CreateWriteFileStream(CommonPath+ItemPath[Item]);
        end;
      ACCES_READWRITE: res.Data.FileStream:=TStream.CreateReadWriteFileStream(CommonPath+ItemPath[Item]);
    end;
    res.Data.FileStream.Seek(0, spBegin);
  end
    else GCF_BuildClustersTable(Item, @res.Data.SectorsTable);

  result:=res;
end;

function TGCFFile.FindFirst(FindRec: pFindRecord): boolean;
var
  Path: string;
  RootItem, Item: integer;
begin
  result:=false;
  Path:=ExtractFilePath(FindRec.Mask);
  RootItem:=-1;
  if Path<>'' then
  begin
    RootItem:=ItemByPath[Path];
    if RootItem=-1 then
      Exit;
  end;
  if RootItem=-1 then
    RootItem:=0;
  Item:=lpManifestNodes[RootItem].ChildIndex;
  Path:=ExtractFileName(FindRec.Mask);
  while Item>0 do
  begin
    if StrSatisfy(ItemPath[Item], FindRec.Mask) then
    begin
      result:=true;
      FindRec^.PathToFile:=pChar(ItemPath[Item]);
      FindRec^.ItemRoot.Package:=@self;
      FindRec^.ItemRoot.ItemIdx:=Item;
      FindRec^.ItemCurrent.Package:=self;
      FindRec^.ItemCurrent.ItemIdx:=Item;
      Exit;
    end;
    Item:=ManifestEntry[Item].NextIndex;
  end;
end;

function TGCFFile.FindNext(FindRec: pFindRecord): boolean;
var
  Item: integer;
begin
  result:=false;
  Item:=FindRec^.ItemCurrent.ItemIdx;
  Item:=ManifestEntry[Item].NextIndex;
  while (Item>0) do
  begin
    if (StrSatisfy(LowerCase(ItemPath[Item]), FindRec^.Mask)) then
    begin
      result:=true;
      FindRec^.PathToFile:=pChar(ItemPath[Item]);
      FindRec^.ItemCurrent.Package:=self;
      FindRec^.ItemCurrent.ItemIdx:=Item;
      Exit;
    end;
    Item:=ManifestEntry[Item].NextIndex;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//                            методы обновлений                               //
////////////////////////////////////////////////////////////////////////////////

function TGCFFile.CreateInfo(): string;
var
  i: integer;
  //BlockIdx: uint32_t;
  FileName: string;
  Stream: TStream;
begin
  result:='';
  FileName:=fFileName;
  FileName:=Parse(FileName, '.')+'.'+Int2Str(fFileHeader.ApplicationVersion)+'.archive';
  MoveFile(pChar(FileName), pChar(FileName+'.bak'));

  Stream:=TStream.CreateWriteFileStream(FileName);
  if Stream.Handle=INVALID_HANDLE_VALUE then
    Exit;
  for i:=0 to ItemsCount-1 do
  begin
    {BlockIdx:=lpManifestMapEntries[i];
    if (BlockIdx=fFATHeader.ClusterCount) then
      lpManifestMapEntries[i]:=HL_NCF_DIR
        else
    begin  }
      if lpManifestNodes[i].Attributes and HL_GCF_FLAG_FILE<>HL_GCF_FLAG_FILE then
        lpManifestMapEntries[i]:=HL_NCF_DIR
          else if GetCompletion(i)=1 then
            lpManifestMapEntries[i]:=HL_NCF_FILE_NOT_LOAD
              else lpManifestMapEntries[i]:=HL_NCF_FILE_NOT_LOAD;//HL_NCF_DIR;
    //end;
  end;

  SaveToStreamAsInfo(Stream);
  Stream.Free;
  result:=FileName;
end;

function TGCFFile.CreatePatch(InfoFile: string): boolean;
var
  i, ClustersCount, ReadedSize: integer;
  FileName, ItemName: string;
  ToPatch: TList;
  Info, Patch: TGCFFile;
  str, s1, s2: TStream;
  CSize, AllSize: int64;
  buf: array[0..HL_GCF_CHECKSUM_LENGTH-1] of byte;
begin
  result:=false;

  Info:=TGCFFile.Create();
  if not Info.LoadFromFile(InfoFile) then
    Exit;

  FileName:=fFileName;
  FileName:=Parse(FileName, '.')+'.'+Int2Str(Info.CacheVersion)+'_to_'+Int2Str(CacheVersion)+'.update.gcf';

  ToPatch:=TList.Create();
  // определяем, какие файлы необходимо включить в патч
  for i:=0 to fManifestHeader.NodeCount-1 do
    if lpManifestNodes[i].Attributes and HL_GCF_FLAG_FILE=HL_GCF_FLAG_FILE then
      if not CompareFile(i, Info, Info.GetItemByPath(GetItemPath(i))) then
        ToPatch.Add(Pointer(i));

  // определяем, сколько секторов будет в этих файлах
  ClustersCount:=0;
  if ToPatch.Count>0 then
    for i:=0 to ToPatch.Count-1 do
      inc(ClustersCount, ItemSize[integer(ToPatch.Items[i])].Sectors);

  // создаем пустой файл патча
  Patch:=TGCFFile.Create();
  Patch.CopyHeaders(self);
   // обнуляем блоки и ссылки на них
  Patch.FreeBlocks();
  Patch.SetClustersCount(ClustersCount);
  str:=TStream.CreateWriteFileStream(FileName);
  Patch.SaveToStream(str);
  Patch.fDataHeader.FirstClusterOffset:=str.Position;
  str.Seek(0, spBegin);
  Patch.SaveToStream(str);
  str.Size:=str.Position+ClustersCount*HL_GCF_BLOCK_SIZE;

  AllSize:=ClustersCount*HL_GCF_BLOCK_SIZE;
  if Assigned(OnProgress) then
    OnProgress('', -2, AllSize, Data);
  if Assigned(OnProgressObj) then
    OnProgressObj('', -2, AllSize, Data);
  // пишем файлы в патч
  CSize:=0;
  if ToPatch.Count>0 then
    for i:=0 to ToPatch.Count-1 do
    begin
      if Stop then
        break;
      ItemName:=ItemPath[integer(ToPatch.Items[i])];
      if GetCompletion(integer(ToPatch.Items[i]))<1 then
      begin
        if Assigned(OnError) then
          OnError(ItemName, ERROR_INCOMPLETE, Data);
        if Assigned(OnErrorObj) then
          OnErrorObj(ItemName, ERROR_INCOMPLETE, Data);
        continue;
      end;
        if Assigned(OnProgress) then
          OnProgress('', CSize, AllSize, Data);
        if Assigned(OnProgressObj) then
          OnProgressObj('', CSize, AllSize, Data);
      s1:=OpenFile(ItemName, ACCES_READ);
      s2:=Patch.OpenFile(ItemName, ACCES_WRITE);
      while s1.Position<s1.Size do
      begin
        ReadedSize:=s1.Read(buf[0], HL_GCF_CHECKSUM_LENGTH);
        if ReadedSize=0 then
          break;
        inc(CSize, s2.Write(buf[0], ReadedSize));
        if Stop then
          break;
      end;
      s1.Destroy;
      s2.Destroy;
      {if ParanoiaSave then
      begin
        str.Position:=0;
        Patch.SaveToStream(str);
      end; }
    end;

  if Stop then
  begin
    if Assigned(OnError) then
      OnError('', ERROR_STOP, Data);
    if Assigned(OnErrorObj) then
      OnErrorObj('', ERROR_STOP, Data);
  end;
  str.Position:=0;
  Patch.SaveToStream(str);

  Patch.Free;
  result:=(Stop=false);
end;

function TGCFFile.ApplyUpdate(UpdateFile: string): boolean;
var
  update, tmp: TGCFFile;
  //s1, s2: TStream;
  i, deltaSize, ClustersCount: uint32;
begin
  result:=false;

  update:=TGCFFile.Create('');
  if not update.LoadFromFile(UpdateFile) then
  begin
    update.Free;
    Exit;
  end;
  if (fFileHeader.ApplicationID<>update.fFileHeader.ApplicationID) then
  begin
    update.Free;
    Exit;
  end;

  // обновление заголовков (для начала - во временный "файл")
  tmp:=TGCFFile.Create('');
  tmp.CopyHeaders(update);
  ClustersCount:=tmp.ItemSize[0].Sectors;
  tmp.SetClustersCount(ClustersCount);
  //

  // сдвиг первых секторов для записи заголовка при необходимости
  if not IsNCF then
  begin
    deltaSize:=update.fDataHeader.FirstClusterOffset-fDataHeader.FirstClusterOffset;
    if (deltaSize>0) then
    begin
      ClustersCount:=(deltasize and $ffffffffffffe000);
      if (deltaSize and $00001fff<>0) then
        inc(ClustersCount);
      for i:=1 to ClustersCount do
        SwapClusters(i-1, fFATHeader.ClusterCount);
    end;
  end;

  // для NCF все более чем просто
 { if IsNCF then
  begin
    // сперва ме
    for i:=0 to update.fManifestHeader.NodeCount-1 do
      if update
    begin

    end;

    update.Free;
    result:=true;
    Exit;
  end;    }


  update.Free;
  result:=true;
end;

function TGCFFile.CreateMiniGCF(FileName: string): boolean;
var
  mini: TGCFFile;
  _lpManifestMapEntries: array of ulong;
  _lpBATEntries: array of TCache_BlockAllocationTableEntry;
  _lpFATEntries: array of ulong;
  pBATHeader: TCache_BlockAllocationTableHeader;
  str: TStream;
begin
  result:=false;
  mini:=TGCFFile.Create('');
  mini.fFileName:=FileName;
  mini.fStream:=TStream.CreateWriteFileStream(FileName);
  if mini.fStream.Handle=INVALID_HANDLE_VALUE then
    Exit;

  SetLength(_lpManifestMapEntries, ItemsCount);
  SetLength(_lpFATEntries, fFATHeader.ClusterCount);
  SetLength(_lpBATEntries, fBATHeader.BlockCount);
  Move(lpManifestMapEntries[0], _lpManifestMapEntries[0], ItemsCount*sizeof(ulong));
  Move(lpBATEntries[0], _lpBATEntries[0], fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry));
  Move(lpFATEntries[0], _lpFATEntries[0], fFATHeader.ClusterCount*sizeof(ulong));
  Move(fBATHeader.BlockCount, pBATHeader.BlockCount, sizeof(TCache_BlockAllocationTableHeader));

  GCF_FillClusters();
  GCF_BuildBitMap();
  str:=fStream;
  SaveToStream(mini.fStream);
  mini.fStream.Size:=str.Size;
  fStream:=str;
  mini.Free;

  Move(pBATHeader.BlockCount, fBATHeader.BlockCount, sizeof(TCache_BlockAllocationTableHeader));
  Move(_lpManifestMapEntries[0], lpManifestMapEntries[0], ItemsCount*sizeof(ulong));
  Move(_lpBATEntries[0], lpBATEntries[0], fBATHeader.BlockCount*sizeof(TCache_BlockAllocationTableEntry));
  Move(_lpFATEntries[0], lpFATEntries[0], fFATHeader.ClusterCount*sizeof(ulong));
  SetLength(_lpManifestMapEntries, 0);
  SetLength(_lpBATEntries, 0);
  SetLength(_lpFATEntries, 0);
  _lpManifestMapEntries:=nil;
  _lpBATEntries:=nil;
  _lpFATEntries:=nil;

  result:=true;
end;

procedure TGCFFile.CreateItemsTree(Item: integer; RootNode: Pointer; OnItem: TAddTreeItemProc);
  procedure Recurse(Idx: integer; Root: Pointer);
  var
    Dir: Pointer;
  begin
    if (lpManifestNodes[Idx].Attributes and HL_GCF_FLAG_FILE=0) then
    begin
      if Idx<>0 then
        Dir:=OnItem(Root, ItemName[Idx], Idx)
          else Dir:=OnItem(Root, 'root', Idx);
      Idx:=lpManifestNodes[Idx].ChildIndex;
      while Idx>0 do
      begin
        Recurse(Idx, Dir);
        Idx:=lpManifestNodes[Idx].NextIndex;
      end;
    end;
  end;
begin
  Recurse(Item, RootNode);
end;

procedure TGCFFile.CreateItemsList(Item: integer; OnItem: TAddFileItemProc);
begin
  Item:=lpManifestNodes[Item].ChildIndex;
  while (Item>0) do
  begin
    if (lpManifestNodes[Item].Attributes and HL_GCF_FLAG_FILE=HL_GCF_FLAG_FILE) then
      OnItem(ItemName[Item], Item, ItemSize[Item].Size);
    Item:=lpManifestNodes[Item].NextIndex;
  end;
end;

   {
initialization
  GlobalGCFSemaphore:=CreateSemaphore(nil, 1, 1, 'CACHE_Semaphore');

finalization
  CloseHandle(GlobalGCFSemaphore);
        }


end.
