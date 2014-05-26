#include "stdafx.h"
#include "GCFFile.h"
#include "../Stream.h"
#include "functions.h"
#include <openssl/aes.h>
#include <openssl/modes.h>

#define SIZE_HEADER_CHECK sizeof(FileHeader)-4
#define SIZE_BAT_HEADER_CHECK (sizeof(BlockAllocationTableHeader) / 4)-1
#define SIZE_FAT_HEADER_CHECK (sizeof(FileAllocationTableHeader) / 4)-1
#define SIZE_MANIFEST_CHECK sizeof(ManifestHeader)-4

#define HEADER_FILE_HEADER 0
#define HEADER_BAT_HEADER 1
#define HEADER_BAT 2
#define HEADER_FAT_HEADER 3
#define HEADER_FAT 4
#define HEADER_MANIFEST_HEADER 5
#define HEADER_MANIFEST_NODES 6
#define HEADER_NAMES 7
#define HEADER_HASH_KEYS 8
#define HEADER_HASH_INDICIES 9
#define HEADER_MFE 10
#define HEADER_USER_CONFIG 11
#define HEADER_MANIFEST_MAP_HEADER 12
#define HEADER_MANIFEST_MAP 13
#define HEADER_CHECKSUM_CONTAINER 14
#define HEADER_FILEID_HEADER 15
#define HEADER_FILEID 16
#define HEADER_CHECKSUMS 17
#define HEADER_CHECKSUM_SIGNATURE 18
#define HEADER_LAV 19

StreamMethods *pStreamMethods = NULL;

////////////////////////////////////////////////////////////////////////////////
//                         Вспомогательные функции                            //
////////////////////////////////////////////////////////////////////////////////

void Cache_Close(StreamData *Data)
{
	((CGCFFile*)Data->Package)->StreamClose(Data);
	memset(Data, 0, sizeof(StreamData));
	delete Data;
}

UINT64 Cache_Read(StreamData *Data, void *lpData, UINT64 uiSize)
{
	return ((CGCFFile*)Data->Package)->StreamRead(Data, lpData, uiSize);
}

UINT64 Cache_Write(StreamData *Data, void *lpData, UINT64 uiSize)
{
	return ((CGCFFile*)Data->Package)->StreamWrite(Data, lpData, uiSize);
}

UINT64 Cache_Seek(StreamData *Data, INT64 uiPos, ESeekMode eSeekMode)
{
	return ((CGCFFile*)Data->Package)->StreamSeek(Data, uiPos, eSeekMode);
}

UINT64 Cache_GetSize(StreamData *Data)
{
	return ((CGCFFile*)Data->Package)->StreamGetSize(Data);
}

void Cache_SetSize(StreamData *Data, UINT64 uiSize)
{
	((CGCFFile*)Data->Package)->StreamSetSize(Data, uiSize);
}

CGCFFile::CGCFFile(char *Common)
{
	this->CommonPath = Common;
	this->pHeader = new FileHeader();
	this->pBATHeader = new BlockAllocationTableHeader();
	this->pFATHeader = new FileAllocationTableHeader();
	this->pManifestHeader = new ManifestHeader();
	this->pManifestMapHeader = new ManifestMapHeader();
	this->pChecksumDataContainer = new ChecksumDataContainer();
	this->pFileIDChecksumHeader = new FileIdChecksumTableHeader();
	this->pChecksumSignature = new UINT8();
	this->pDataHeader = new DataHeader();

	this->lpBAT = NULL;
	this->lpChecksum = NULL;
	this->lpFAT = NULL;
	this->lpFileIDChecksum = NULL;
	this->lpHashTableIndices = NULL;
	this->lpHashTableKeys = NULL;
	this->lpManifest = NULL;
	this->lpManifestMap = NULL;
	this->lpMinimumFootprint = NULL;
	this->lpNames = NULL;
	this->lpUserConfig = NULL;

	this->BitMapLen = 0;
	this->lpBitMap = NULL;
	this->Stop = false;
	this->ParanoiaSave = true;
	this->fDataBlockTerminator = 0;
	this->IsNCF = false;
	this->stream = NULL;

	if (pStreamMethods == NULL)
	{
		pStreamMethods = new StreamMethods();
		pStreamMethods->Close = Cache_Close;
		pStreamMethods->Read = Cache_Read;
		pStreamMethods->Write = Cache_Write;
		pStreamMethods->Seek = Cache_Seek;
		pStreamMethods->GetSize = Cache_GetSize;
		pStreamMethods->SetSize = Cache_SetSize;
	}
}

CGCFFile::~CGCFFile()
{
	delete this->pHeader;
	delete this->pBATHeader;
	delete this->pFATHeader;
	delete this->pManifestHeader;
	delete this->pManifestMapHeader;
	delete this->pChecksumDataContainer;
	delete this->pFileIDChecksumHeader;
	delete this->pChecksumSignature;
	delete this->pDataHeader;

	delete []this->lpBAT;
	delete []this->lpFAT;
	delete []this->lpManifest;
	delete []this->lpNames;
	delete []this->lpHashTableKeys;
	delete []this->lpHashTableIndices;
	delete []this->lpMinimumFootprint;
	delete []this->lpUserConfig;
	delete []this->lpManifestMap;
	delete []this->lpFileIDChecksum;
	delete []this->lpChecksum;

	delete []this->lpBitMap;

	if (fileName != "")
		delete stream;
}

////////////////////////////////////////////////////////////////////////////////
//                              секция private                                //
////////////////////////////////////////////////////////////////////////////////

void CGCFFile::BuildBitMap()
{
	if (IsNCF)
		return;
	UINT32 BitMapLen = pFATHeader->ClusterCount / 8;
	if (BitMapLen*8 < pFATHeader->ClusterCount)
		BitMapLen++;
	if (lpBitMap != NULL)
		delete []lpBitMap;
	lpBitMap = new UINT8[BitMapLen];
	memset(lpBitMap, 0, BitMapLen);
	for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
		if ((lpManifest[i].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
		{
			std::vector<UINT32> ItemTable;
			this->BuildClustersTable(i, &ItemTable);
			UINT32 TableLen = ItemTable.size();
			for (UINT32 j=0 ; j<TableLen ; j++)
			{
				UINT32 Idx = ItemTable[j] / 8;
				UINT Mask = 1 << (ItemTable[j]-Idx*8);
				lpBitMap[Idx] = lpBitMap[Idx] ^ Mask;
			}
		}
}

void CGCFFile::BuildClustersTable(UINT32 Item, std::vector<UINT32> *ItemTable)
{
	UINT32 TableLen = this->GetItemSize(Item).Sectors;
	(*ItemTable).resize(TableLen);
	UINT32 BlockIdx = lpManifestMap[Item];
	if (BlockIdx == pBATHeader->BlockCount)
		return;

	(*ItemTable)[0] = lpBAT[BlockIdx].FirstClusterIndex;
	UINT32 i = 0,
		OffsetInBlock = 0;
	if (((*ItemTable)[0] == fDataBlockTerminator) || (lpBAT[BlockIdx].FileDataSize == 0))
	{
		TableLen = 0;
		return;
	}

	while ((i+1<TableLen) && (BlockIdx != pBATHeader->BlockCount))
	{
		while (((*ItemTable)[i]!=fDataBlockTerminator) && (OffsetInBlock < lpBAT[BlockIdx].FileDataSize))
		{
			// переходим к следующему кластеру
			if (lpFAT[(*ItemTable)[i]] != fDataBlockTerminator)
			{
				(*ItemTable)[i+1] = lpFAT[(*ItemTable)[i]];
				i++;
			}
			OffsetInBlock += pDataHeader->ClusterSize;
		}
		if (OffsetInBlock >= lpBAT[BlockIdx].FileDataSize)
		{
			// переходим к следующему блоку
			BlockIdx = lpBAT[BlockIdx].NextBlockIndex;
			OffsetInBlock = 0;
			if (BlockIdx != 0)
				if ((lpBAT[BlockIdx].FirstClusterIndex != fDataBlockTerminator) && (BlockIdx != pBATHeader->BlockCount))
					(*ItemTable)[++i] = lpBAT[BlockIdx].FirstClusterIndex;
				else
				{
					TableLen = i+1;
					return;
				}
		}
	}
}

void CGCFFile::RebuildClustersTable(UINT32 Item, std::vector<UINT32> *ItemTable)
{
	UINT64 AllSize = GetItemSize(Item).Size;
	UINT32 BlockIdx = lpManifestMap[Item],
		Cluster = 0;

	while ((BlockIdx < pBATHeader->BlockCount) && (AllSize >= 0))
	{
		fIsChangeHeader[HEADER_FAT] = true;
		UINT32 BlockSize = 0;
		//ClusterIdx:=lpBATEntries[BlockIdx].FirstClusterIndex;
		UINT32 ClusterIdx = (ItemTable->size() == 0) ? pFATHeader->ClusterCount : ((ItemTable->size() >= Cluster) ? (*ItemTable)[Cluster] : AllocateCluster());
		UINT32 ClusterIdxEx = ClusterIdx;
		if (ClusterIdx != (UINT32)-1)
			lpBAT[BlockIdx].FirstClusterIndex = ClusterIdx;
		else
			break;
		while (BlockSize < lpBAT[BlockIdx].FileDataSize)
		{
			if (ClusterIdx == fDataBlockTerminator)
			{
				// создаем часть таблицы для данного блока данных
				ClusterIdx = (ItemTable->size() >= Cluster) ? (*ItemTable)[Cluster] : ClusterIdx = AllocateCluster();
				if (ClusterIdx != (UINT32)-1)
					lpFAT[ClusterIdxEx] = ClusterIdx;
				else
					break;
			}
			BlockSize += CACHE_BLOCK_SIZE;
			ClusterIdxEx = ClusterIdx;
			ClusterIdx = lpFAT[ClusterIdx];
			Cluster++;
		}
		if (ItemTable->size() > 0)
			lpFAT[ClusterIdxEx] = fDataBlockTerminator;
		AllSize -= lpBAT[BlockIdx].FileDataSize;
		BlockIdx = lpBAT[BlockIdx].NextBlockIndex;
	}
	fIsChangeHeader[HEADER_BAT_HEADER] = true;
	fIsChangeHeader[HEADER_BAT] = true;
	fIsChangeHeader[HEADER_FAT_HEADER] = true;
	fIsChangeHeader[HEADER_FAT] = true;
}

bool CGCFFile::IsClusterFree(UINT32 ClusterIdx)
{
	UINT8 VectorsIdx = ClusterIdx / 8;
	UINT32 VectorMask = 1 << (ClusterIdx - VectorsIdx*8);
	return ((lpBitMap[VectorsIdx] & VectorMask) == 0);
}

INT32 CGCFFile::AllocateCluster()
{
	if (BitMapLen > 0)
		for (int i=0 ; i<BitMapLen ; i++)
			if (lpBitMap[i] != 0xff)
			{
				int ClusterIdx = i*8;
				for (int j=0 ; j<8 ; j++)
					if (IsClusterFree(ClusterIdx + j))
					{
						INT32 res = ClusterIdx + j;
						int VectorsIdx = res / 8;
						lpBitMap[VectorsIdx] = lpBitMap[VectorsIdx] ^ (1 << (res - VectorsIdx*8));
						pDataHeader->ClustersUsed++;
						pDataHeader->Checksum = pDataHeader->ClusterCount + pDataHeader->ClusterSize + 
							pDataHeader->FirstClusterOffset + pDataHeader->ClustersUsed;
						return res;
					}
			}
	return -1;
}

void CGCFFile::DeleteBlock(UINT32 BlockIdx)
{
	if (BlockIdx < pDataHeader->ClusterCount)
	{
		// удаляем следующий блок, если он назначен
		DeleteBlock(lpBAT[BlockIdx].NextBlockIndex);

		UINT32 ClusterIdx = lpBAT[BlockIdx].FirstClusterIndex;
		// смещаем все последующие блоки...
		if (pBATHeader->BlockCount > BlockIdx)
			for (UINT32 i=BlockIdx+1 ; i<pBATHeader->BlockCount ; i++)
				if (lpBAT[i].ManifestIndex > 0)
				{
					lpBAT[i-1] = lpBAT[i];
					memset(&lpBAT[i], 0, sizeof(BlockAllocationTableEntry));
				}
		// ... и изменяем ссылки на них
		for (UINT32 i=0 ; i<pBATHeader->BlockCount ; i++)
		{
			if (lpBAT[i].NextBlockIndex >= BlockIdx)
				lpBAT[i].NextBlockIndex--;
			if (lpBAT[i].PreviousBlockIndex >= BlockIdx)
				lpBAT[i].PreviousBlockIndex--;
		}
		for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
			if (lpManifestMap[i] >= BlockIdx)
				lpManifestMap[i]--;

		// удаляем цепочки кластеров у текущего блока
		while (ClusterIdx != fDataBlockTerminator)
		{
			UINT32 NextCluster = lpFAT[ClusterIdx];
			lpFAT[ClusterIdx] = fDataBlockTerminator;
			ClusterIdx = NextCluster;
		}

		pBATHeader->LastUsedBlock--;
		pBATHeader->BlocksUsed--;		
		fIsChangeHeader[HEADER_BAT_HEADER] = true;
		fIsChangeHeader[HEADER_BAT] = true;
		fIsChangeHeader[HEADER_FAT] = true;
		fIsChangeHeader[HEADER_MANIFEST_MAP] = true;
	}
}

void CGCFFile::FillClusters()
{
	for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
		lpManifestMap[i] = pBATHeader->BlockCount;
	for (UINT32 i=0 ; i<pBATHeader->BlockCount ; i++)
	{
		memset(&lpBAT[i], 0, sizeof(BlockAllocationTableEntry));
		lpBAT[i].NextBlockIndex = pBATHeader->BlockCount;
		lpBAT[i].PreviousBlockIndex = pBATHeader->BlockCount;
		lpBAT[i].ManifestIndex = (UINT32)-1;
	}
	pBATHeader->BlocksUsed = 0;
	pBATHeader->BlocksUsed = 0;
	/*for (UINT32 i=0 ; i<pBATHeader->BlockCount ; i++)
		if ((lpBAT[i].Flags & */
	for (UINT32 i=0 ; i<pFATHeader->ClusterCount ; i++)
		lpFAT[i] = fDataBlockTerminator;
}

bool CGCFFile::CompareFile(UINT32 Item1, CGCFFile *GCF2, UINT32 Item2)
{
	if (Item2 == CACHE_INVALID_ITEM)
		return false;
	// быстрое сравнение - по размеру
	TItemSize S1 = GetItemSize(Item1),
		S2 = GCF2->GetItemSize(Item2);
	if ((S1.Size!=S2.Size) || (S1.Folders!=S2.Folders) || (S1.Files!=S2.Files))
		return true;
	// подробное сравнение - по контрольным суммам
	if ((lpManifest[Item1].Attributes & CACHE_FLAG_FILE) != CACHE_FLAG_FILE)
		return false;
	UINT32 CheckStart1 = lpFileIDChecksum[lpManifest[Item1].FileId].FirstChecksumIndex,
		CheckStart2 = GCF2->lpFileIDChecksum[GCF2->lpManifest[Item2].FileId].FirstChecksumIndex,
		Count = lpFileIDChecksum[lpManifest[Item1].FileId].ChecksumCount;
	if (Count != GCF2->lpFileIDChecksum[GCF2->lpManifest[Item2].FileId].ChecksumCount)
		return false;
	for (UINT32 i=0 ; i<Count ; i++)
		if (lpChecksum[CheckStart1+i] != GCF2->lpChecksum[CheckStart2+i])
			return false;
	return true;
}

void CGCFFile::CopyHeaders(CGCFFile *GCF)
{
	// File Header
	memcpy(this->pHeader, GCF->pHeader, sizeof(FileHeader));
	// Block Allocation Table
	memcpy(this->pBATHeader, GCF->pBATHeader, sizeof(BlockAllocationTableHeader));
	this->lpBAT = new BlockAllocationTableEntry[this->pBATHeader->BlockCount];
	memcpy(this->lpBAT, GCF->lpBAT, sizeof(UINT32)*this->pBATHeader->BlockCount);
	// File Allocation Table
	memcpy(this->pFATHeader, GCF->pFATHeader, sizeof(FileAllocationTableHeader));
	this->lpFAT = new UINT32[this->pFATHeader->ClusterCount];
	memcpy(this->lpFAT, GCF->lpFAT, sizeof(UINT32)*this->pFATHeader->ClusterCount);
	// Manifest
	memcpy(this->pManifestHeader, GCF->pManifestHeader, sizeof(ManifestHeader));
	this->lpManifest = new ManifestNode[this->pManifestHeader->NodeCount];
	memcpy(this->lpManifest, GCF->lpManifest, sizeof(ManifestNode)*this->pManifestHeader->NodeCount);
	this->lpNames = new char[this->pManifestHeader->NameSize];
	memcpy(this->lpNames, GCF->lpNames, this->pManifestHeader->NameSize);
	this->lpHashTableKeys = new UINT32[this->pManifestHeader->HashTableKeyCount];
	memcpy(this->lpHashTableKeys, GCF->lpHashTableKeys, sizeof(UINT32)*this->pManifestHeader->HashTableKeyCount);
	this->lpHashTableIndices = new UINT32[this->pManifestHeader->NodeCount];
	memcpy(this->lpHashTableIndices, GCF->lpHashTableIndices, sizeof(UINT32)*this->pManifestHeader->NodeCount);
	this->lpMinimumFootprint = new UINT32[this->pManifestHeader->NumOfMinimumFootprintFiles];
	memcpy(this->lpMinimumFootprint, GCF->lpMinimumFootprint, sizeof(UINT32)*this->pManifestHeader->NumOfMinimumFootprintFiles);
	this->lpUserConfig = new UINT32[this->pManifestHeader->NumOfUserConfigFiles];
	memcpy(this->lpUserConfig, GCF->lpUserConfig, sizeof(UINT32)*this->pManifestHeader->NumOfUserConfigFiles);
	memcpy(this->pManifestMapHeader, GCF->pManifestMapHeader, sizeof(ManifestMapHeader));
	this->lpManifestMap = new UINT32[this->pManifestHeader->NodeCount];
	memcpy(this->lpManifestMap, GCF->lpManifestMap, sizeof(UINT32)*this->pManifestHeader->NodeCount);
	// Checksums
	memcpy(this->pChecksumDataContainer, GCF->pChecksumDataContainer, sizeof(ChecksumDataContainer));
	memcpy(this->pFileIDChecksumHeader, GCF->pFileIDChecksumHeader, sizeof(FileIdChecksumTableHeader));
	this->lpFileIDChecksum = new FileIdChecksumTableEntry[this->pFileIDChecksumHeader->FileIdCount];
	memcpy(this->lpFileIDChecksum, GCF->lpFileIDChecksum, sizeof(FileIdChecksumTableEntry)*this->pFileIDChecksumHeader->FileIdCount);
	this->lpChecksum = new UINT32[this->pFileIDChecksumHeader->ChecksumCount];
	memcpy(this->lpChecksum, GCF->lpChecksum, sizeof(UINT32)*this->pFileIDChecksumHeader->ChecksumCount);

	memcpy(&this->pLatestApplicationVersion, &GCF->pLatestApplicationVersion, sizeof(UINT32));
	memcpy(this->pDataHeader, GCF->pDataHeader, sizeof(DataHeader));

	if (pFATHeader->IsLongTerminator == 0)
		fDataBlockTerminator = 0x0000FFFF;
	else fDataBlockTerminator = 0xFFFFFFFF;
	BuildBitMap();
	memset(fIsChangeHeader, true, HEADER_LENGTH);
}

void CGCFFile::FreeBlocks()
{
	BlockAllocationTableEntry FillBlock;
	memset(&FillBlock, 0, sizeof(BlockAllocationTableEntry));
	FillBlock.NextBlockIndex = pBATHeader->BlockCount;
	FillBlock.PreviousBlockIndex = pBATHeader->BlockCount;
	FillBlock.ManifestIndex = CACHE_INVALID_ITEM;
	for (UINT32 i=0 ; i<pBATHeader->BlockCount ; i++)
		memcpy(&lpBAT[i], &FillBlock, sizeof(BlockAllocationTableEntry));
	pBATHeader->BlocksUsed = 0;
	pBATHeader->LastUsedBlock = 0;
	// обнуляем ссылки на блоки
	for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
		lpManifestMap[i] = pBATHeader->BlockCount;
	for (UINT32 i=0 ; i<pFATHeader->ClusterCount ; i++)
		lpFAT[i] = fDataBlockTerminator;
	pFATHeader->FirstUnusedEntry = 0;
	pDataHeader->ClustersUsed = 0;
	BuildBitMap();
	fIsChangeHeader[HEADER_BAT_HEADER] = true;
	fIsChangeHeader[HEADER_BAT] = true;
	fIsChangeHeader[HEADER_FAT_HEADER] = true;
	fIsChangeHeader[HEADER_FAT] = true;
}

void CGCFFile::SetSectorsCount(UINT32 NewCount)
{
	UINT32 Last = pHeader->ClusterCount;
	pHeader->ClusterCount = NewCount;
	pBATHeader->BlockCount = NewCount;
	for (UINT32 i=0 ; i<NewCount ; i++)
		if (lpBAT[i].FirstClusterIndex == Last)
			lpBAT[i].FirstClusterIndex = NewCount;
	pFATHeader->ClusterCount = NewCount;
	for (UINT32 i=0 ; i<NewCount ; i++)
		if (lpFAT[i] == Last)
			lpFAT[i] = NewCount;
	pDataHeader->ClusterCount = NewCount;
	for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
		if (lpManifestMap[i] == Last)
			lpManifestMap[i] = NewCount;
	fIsChangeHeader[HEADER_BAT_HEADER] = true;
	fIsChangeHeader[HEADER_BAT] = true;
	fIsChangeHeader[HEADER_FAT_HEADER] = true;
	fIsChangeHeader[HEADER_FAT] = true;
}

void CGCFFile::CalculateChecksumsForHeaders()
{
	pHeader->Checksum = HeaderChecksum((UINT8*)pHeader, sizeof(FileHeader)- sizeof(UINT32));
	pBATHeader->Checksum = HeaderChecksum2(&pBATHeader->BlockCount, sizeof(BlockAllocationTableHeader) / sizeof(UINT32));
	pFATHeader->Checksum = HeaderChecksum2(&pFATHeader->ClusterCount, sizeof(FileAllocationTableHeader) / sizeof(UINT32));
	//??fHeader.pManifestHeader.Checksum:=HeaderChecksum3(@fHeader.pManifestHeader);
	pDataHeader->Checksum = HeaderChecksum2(&pDataHeader->ClusterCount, sizeof(DataHeader) / sizeof(UINT32));
}

UINT64 CGCFFile::GetFileSize(UINT32 Item)
{
	UINT64 res = lpManifest[Item].CountOrSize & 0x7FFFFFFF;
	if ((lpManifest[Item].CountOrSize & 0x80000000) != 0)
	{
		for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
		{
			ManifestNode *MN = &lpManifest[Item];
			if (((MN->Attributes & 0x00004000) != 0) && (MN->ParentIndex == 0xFFFFFFFF) &&
				(MN->NextIndex == 0xFFFFFFFF) && (MN->ChildIndex == 0xFFFFFFFF) && (MN->FileId == lpManifest[Item].FileId))
			{
				res += MN->CountOrSize << 31;
				break;
			}
		}
	}
	return res;
}

////////////////////////////////////////////////////////////////////////////////
//                        методы загрузки/сохранения                          //
////////////////////////////////////////////////////////////////////////////////

bool CGCFFile::LoadFromFile(char *FileName)
{
	fileName = FileName;
	CStream *Stream = new CStream(FileName);
	if (Stream->GetHandle() == INVALID_HANDLE_VALUE)
		return false;
	return this->LoadFromStream(Stream);
}

bool CGCFFile::LoadFromStream(CStream *Stream)
{
	this->stream = Stream;

	// File header
	Stream->Read(this->pHeader, sizeof(FileHeader));
	if (this->pHeader->Checksum != HeaderChecksum((UINT8*)this->pHeader, SIZE_HEADER_CHECK))
		return false;
	this->IsNCF = (this->pHeader->CacheType == CACHE_TYPE_NCF);

	if (!this->IsNCF)
	{
		// Block allocation table
		Stream->Read(this->pBATHeader, sizeof(BlockAllocationTableHeader));
		if (this->pBATHeader->Checksum != HeaderChecksum2((UINT32*)this->pBATHeader, SIZE_BAT_HEADER_CHECK))
			return false;
		this->lpBAT = new BlockAllocationTableEntry[this->pBATHeader->BlockCount];
		Stream->Read(this->lpBAT, this->pBATHeader->BlockCount * sizeof(BlockAllocationTableEntry));

		// File allocation table
		Stream->Read(this->pFATHeader, sizeof(FileAllocationTableHeader));
		if (this->pFATHeader->Checksum != HeaderChecksum2((UINT32*)this->pFATHeader, SIZE_FAT_HEADER_CHECK))
			return false;
		this->lpFAT = new UINT32[this->pFATHeader->ClusterCount];
		Stream->Read(this->lpFAT, this->pFATHeader->ClusterCount * sizeof(UINT32));
	}

	// Manifest
	Stream->Read(this->pManifestHeader, sizeof(ManifestHeader));
	lpManifest = new ManifestNode[pManifestHeader->NodeCount];
	lpNames = new char[pManifestHeader->NameSize];
	lpHashTableKeys = new UINT32[pManifestHeader->HashTableKeyCount];
	lpHashTableIndices = new UINT32[pManifestHeader->NodeCount];
	lpMinimumFootprint = new UINT32[pManifestHeader->NumOfMinimumFootprintFiles];
	lpUserConfig = new UINT32[pManifestHeader->NumOfUserConfigFiles];
	lpManifestMap = new UINT32[pManifestHeader->NodeCount];
	Stream->Read(lpManifest, sizeof(ManifestNode)*pManifestHeader->NodeCount);
	Stream->Read(lpNames, sizeof(char)*pManifestHeader->NameSize);
	Stream->Read(lpHashTableKeys, sizeof(UINT32)*pManifestHeader->HashTableKeyCount);
	Stream->Read(lpHashTableIndices, sizeof(UINT32)*pManifestHeader->NodeCount);
	Stream->Read(lpMinimumFootprint, sizeof(UINT32)*pManifestHeader->NumOfMinimumFootprintFiles);
	Stream->Read(lpUserConfig, sizeof(UINT32)*pManifestHeader->NumOfUserConfigFiles);
	Stream->Read(pManifestMapHeader, sizeof(ManifestMapHeader));
	Stream->Read(lpManifestMap, sizeof(UINT32)*pManifestHeader->NodeCount);

	// Checksum's
	Stream->Read(pChecksumDataContainer, sizeof(ChecksumDataContainer));
	Stream->Read(pFileIDChecksumHeader, sizeof(FileIdChecksumTableHeader));
	lpFileIDChecksum = new FileIdChecksumTableEntry[pFileIDChecksumHeader->FileIdCount];
	lpChecksum = new UINT32[pFileIDChecksumHeader->ChecksumCount];
	Stream->Read(lpFileIDChecksum, sizeof(FileIdChecksumTableEntry)*pFileIDChecksumHeader->FileIdCount);
	Stream->Read(lpChecksum, sizeof(UINT32)*pFileIDChecksumHeader->ChecksumCount);
	Stream->Read(pChecksumSignature, 0x80);
	Stream->Read(&pLatestApplicationVersion, sizeof(UINT32));

	if (!IsNCF)
		Stream->Read(pDataHeader, sizeof(DataHeader));

	if (pFATHeader->IsLongTerminator != 0) fDataBlockTerminator = 0xffffffff;
	else fDataBlockTerminator = 0x0000ffff;

	if (!IsNCF)
		this->BuildBitMap();

	return true;
}

#define CopyPart(from, to, type, count) { memcpy(to, from, sizeof(type)*count); from += sizeof(type)*count; }
#define CopyPartArray(from, to, type, count) { to = new type[count]; memcpy(to, from, sizeof(type)*count); from += sizeof(type)*count; }
void CGCFFile::LoadFromMem(char *Manifest, char *Checksums, UINT32 MS, UINT32 CS, bool AsGCF)
{
	IsNCF = !AsGCF;

	// Manifest
	CopyPart(Manifest, pManifestHeader, sizeof(ManifestHeader), 1);
	// check checksum
	// ...
	CopyPartArray(Manifest, lpManifest, ManifestNode, pManifestHeader->NodeCount);
	CopyPartArray(Manifest, lpNames, char, pManifestHeader->NameSize);
	CopyPartArray(Manifest, lpHashTableKeys, UINT32, pManifestHeader->HashTableKeyCount);
	CopyPartArray(Manifest, lpHashTableIndices, UINT32, pManifestHeader->NodeCount);
	CopyPartArray(Manifest, lpMinimumFootprint, UINT32, pManifestHeader->NumOfMinimumFootprintFiles);
	CopyPartArray(Manifest, lpUserConfig, UINT32, pManifestHeader->NumOfUserConfigFiles);

	// File header
	pHeader->HeaderVersion = 0;
	pHeader->CacheType = (IsNCF) ? CACHE_TYPE_NCF : CACHE_TYPE_GCF;
	pHeader->FormatVersion = (IsNCF) ? 1 : 6;
	pHeader->ApplicationID = pManifestHeader->ApplicationID;
	pHeader->ApplicationVersion = pManifestHeader->ApplicationVersion;
	pHeader->IsMounted = 0;
	pHeader->Dummy0 = 0;
	pHeader->FileSize = 0;
	if (IsNCF)
	{
		pHeader->ClusterSize = 0;
		pHeader->ClusterCount = 0;
	}
	else
	{
		pHeader->ClusterSize = CACHE_BLOCK_SIZE;
		pHeader->ClusterCount = GetItemSize(0).Sectors;
	}
	pHeader->Checksum = HeaderChecksum((UINT8*)pHeader, SIZE_HEADER_CHECK);

	/*if (not IsNCF) then
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
  end; */

	// Manifest map
	pManifestMapHeader->HeaderVersion = 1;
	pManifestMapHeader->Dummy0 = 0;
	if (!IsNCF)
	{
		lpManifestMap = new UINT32[pManifestHeader->NodeCount];
		memset(lpManifestMap, 0, sizeof(UINT32)*pManifestHeader->NodeCount);
	}

	// Checksum's
	pChecksumDataContainer->HeaderVersion = 1;
	pChecksumDataContainer->ChecksumSize = CS;
	CopyPart(Checksums, pFileIDChecksumHeader, FileIdChecksumTableHeader, 1);
	CopyPartArray(Checksums, lpFileIDChecksum, FileIdChecksumTableEntry, pFileIDChecksumHeader->FileIdCount);
	CopyPartArray(Checksums, lpChecksum, UINT32, pFileIDChecksumHeader->ChecksumCount);
	CopyPart(Checksums, pChecksumSignature, UINT8, 0x80);

	pLatestApplicationVersion = pHeader->ApplicationVersion;

	if (!IsNCF)
	{
		//fStream.Read(fDataHeader, sizeof(TCache_DataHeader));
	}

	if (pFATHeader->IsLongTerminator == 0)
		fDataBlockTerminator = 0x0000FFFF;
	else
		fDataBlockTerminator = 0xFFFFFFFF;
	if (!IsNCF)
		BuildBitMap();
}

bool  CGCFFile::SaveToFile(char *FileName)
{
	fileName = FileName;
	CStream *Stream = new CStream(FileName, true);
	if (Stream->GetHandle() == INVALID_HANDLE_VALUE)
		return false;
	return this->SaveToStream(Stream);
}

bool CGCFFile::SaveToStream(CStream *Stream)
{
	this->stream = Stream;

	// File header
	Stream->Write(this->pHeader, sizeof(FileHeader));
	//if (this->pHeader->Checksum != HeaderChecksum((uint8_t*)this->pHeader, SIZE_HEADER_CHECK))
	//	return false;
	this->IsNCF = (this->pHeader->CacheType == CACHE_TYPE_NCF);

	if (!this->IsNCF)
	{
		// Block allocation table
		Stream->Write(this->pBATHeader, sizeof(BlockAllocationTableHeader));
		//if (this->pBATHeader->Checksum != HeaderChecksum2((UINT32*)this->pBATHeader, SIZE_BAT_HEADER_CHECK))
		//	return false;
		Stream->Write(this->lpBAT, this->pBATHeader->BlockCount * sizeof(BlockAllocationTableEntry));

		// File allocation table
		Stream->Write(this->pFATHeader, sizeof(FileAllocationTableHeader));
		//if (this->pFATHeader->Checksum != HeaderChecksum2((UINT32*)this->pFATHeader, SIZE_FAT_HEADER_CHECK))
		//	return false;
		Stream->Write(this->lpFAT, this->pFATHeader->ClusterCount * sizeof(UINT32));
	}

	// Manifest
	Stream->Write(this->pManifestHeader, sizeof(ManifestHeader));
	Stream->Write(lpManifest, sizeof(ManifestNode)*pManifestHeader->NodeCount);
	Stream->Write(lpNames, sizeof(char)*pManifestHeader->NameSize);
	Stream->Write(lpHashTableKeys, sizeof(UINT32)*pManifestHeader->HashTableKeyCount);
	Stream->Write(lpHashTableIndices, sizeof(UINT32)*pManifestHeader->NodeCount);
	Stream->Write(lpMinimumFootprint, sizeof(UINT32)*pManifestHeader->NumOfMinimumFootprintFiles);
	Stream->Write(lpUserConfig, sizeof(UINT32)*pManifestHeader->NumOfUserConfigFiles);
	Stream->Write(pManifestMapHeader, sizeof(ManifestMapHeader));
	Stream->Write(lpManifestMap, sizeof(UINT32)*pManifestHeader->NodeCount);

	// Checksum's
	Stream->Write(pChecksumDataContainer, sizeof(ChecksumDataContainer));
	Stream->Write(pFileIDChecksumHeader, sizeof(FileIdChecksumTableHeader));
	Stream->Write(lpFileIDChecksum, sizeof(FileIdChecksumTableEntry)*pFileIDChecksumHeader->FileIdCount);
	Stream->Write(lpChecksum, sizeof(UINT32)*pFileIDChecksumHeader->ChecksumCount);
	Stream->Write(pChecksumSignature, 0x80);
	Stream->Write(&pLatestApplicationVersion, sizeof(UINT32));

	if (!IsNCF)
		Stream->Write(pDataHeader, sizeof(DataHeader));

	return true;
}

bool CGCFFile::SaveToFileAsInfo(char *FileName)
{
	CStream *Stream = new CStream(FileName, true);
	if (Stream->GetHandle() == INVALID_HANDLE_VALUE)
		return false;

	for (UINT32 i=0 ; i<pManifestHeader->NodeCount ; i++)
	{
		UINT32 BlockIdx =	lpManifestMap[i];
		if (BlockIdx == pBATHeader->BlockCount)
			lpManifestMap[i] = USE_NCF_DIR;
		else
		{
			if ((lpManifest[i].Attributes & CACHE_FLAG_FILE) != CACHE_FLAG_FILE)
				lpManifestMap[i] = USE_NCF_DIR;
			else if (GetCompletion(i) == 1)
				lpManifestMap[i] = USE_NCF_FILE_NOT_LOAD;
			else
				lpManifestMap[i] = USE_NCF_FILE_INCOMPLETE;
		}
	}

	bool ret = this->SaveToStreamAsInfo(Stream);
	delete Stream;
	return ret;
}

bool CGCFFile::SaveToStreamAsInfo(CStream *Stream)
{
	Stream->Seek(0, USE_SEEK_BEGINNING);
	CStream *str = stream;
	FileHeader Header = *pHeader;
	pHeader->CacheType = CACHE_TYPE_NCF;
	pHeader->FormatVersion = 1;
	pHeader->ClusterCount = 0;
	bool res = SaveToStream(Stream);
	if (Stream->GetSize() > MAXUINT32)
		pHeader->FileSize = 0xffffffff;
	else
		pHeader->FileSize = (UINT32)Stream->GetSize();
	pHeader->Checksum = HeaderChecksum((UINT8*)this->pHeader, SIZE_HEADER_CHECK);
	Stream->Seek(0, USE_SEEK_BEGINNING);
	Stream->Write(pHeader, sizeof(FileHeader));
	*pHeader = Header;
	stream = str;
	return res;
}

////////////////////////////////////////////////////////////////////////////////
//                             свойства кэша                                  //
////////////////////////////////////////////////////////////////////////////////

bool CGCFFile::GetIsNCF()
{
	return IsNCF;
}

UINT32 CGCFFile::GetCacheID()
{
	return pHeader->ApplicationID;
}

UINT32 CGCFFile::GetFileVersion()
{
	return pHeader->FormatVersion;
}

UINT32 CGCFFile::GetCacheVersion()
{
	return pHeader->ApplicationVersion;
}

ManifestNode *CGCFFile::GetManifestEntry(UINT32 Item)
{
	return &lpManifest[Item];
}

char *CGCFFile::GetFileName()
{
	return fileName;
}

TItemTree* CGCFFile::GetItemTree(UINT32 Item)
{
	TItemTree *TreeItem = new TItemTree();
	TreeItem->Handle = Item;

	if (lpManifest[Item].ChildIndex != 0)
		TreeItem->FirstChild = this->GetItemTree(lpManifest[Item].ChildIndex);
	else TreeItem->FirstChild = NULL;

	if (lpManifest[Item].NextIndex != 0)
		TreeItem->Next = this->GetItemTree(lpManifest[Item].NextIndex);
	else TreeItem->Next = NULL;

	return TreeItem;
}

UINT32 CGCFFile::GetItemsCount()
{
	return pManifestHeader->NodeCount;
}

TItemSize CGCFFile::GetItemSize(UINT32 Item)
{
	TItemSize res;
	memset(&res, 0, sizeof(TItemSize));
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
	{
		res.Size = this->GetFileSize(Item);
		res.Sectors = (UINT32)(res.Size >> 13);
		if (res.Sectors*CACHE_BLOCK_SIZE < res.Size)
			res.Sectors++;
		res.Files = 1;
		res.CompletedSize = this->GetCompletedSize(Item);
		if (res.CompletedSize == res.Size)
			res.CompletedFiles = 1;
	}
	else
	{
		UINT32 Idx = lpManifest[Item].ChildIndex;
		while (Idx>0)
		{
			if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) != CACHE_FLAG_FILE)
				res.Folders++;
			TItemSize res1 = this->GetItemSize(Idx);
			res.CompletedFiles += res1.CompletedFiles;
			res.CompletedSize += res1.CompletedSize;
			res.Files += res1.Files;
			res.Folders += res1.Folders;
			res.Sectors += res1.Sectors;
			res.Size += res1.Size;
			Idx = lpManifest[Idx].NextIndex;
		}
	}
	return res;
}

#define IncSize(size, delta) { size.Size+=delta.Size; size.CompletedSize+=delta.CompletedSize; \
	size.Folders+=delta.Folders; size.Files+=delta.Files; size.CompletedFiles+=delta.CompletedFiles; size.Sectors+=delta.Sectors; }
TItemSize CGCFFile::GetItemSizeFromGame(UINT32 Item)
{
	TItemSize res;
	memset(&res, 0, sizeof(TItemSize));
	for (UINT32 i=0 ; i<pManifestHeader->NumOfMinimumFootprintFiles ; i++)
	{
		IncSize(res, GetItemSize(lpMinimumFootprint[i]));
	}
	return res;
}

bool CGCFFile::IsFile(UINT32 Item)
{
	return ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE);
}

UINT32 CGCFFile::CheckIdx(UINT32 Item)
{
	return lpManifest[Item].FileId;
}

////////////////////////////////////////////////////////////////////////////////
//                      методы работы с именами элеметнов                     //
////////////////////////////////////////////////////////////////////////////////

UINT32 CGCFFile::GetItem(char *Item)
{
	int DelimiterPos = -1;
	for (UINT32 i=0 ; i<strlen(Item) ; i++)
		if (Item[i] == '\\')
			DelimiterPos = i;
	char *FileName = &Item[++DelimiterPos];
	UINT32 Hash = jenkinsLookupHash2((UINT8*)FileName, strlen(FileName), 1),
		HashIdx = Hash % pManifestHeader->HashTableKeyCount,
		HashFileIdx = lpHashTableKeys[HashIdx];
	if (HashFileIdx == CACHE_INVALID_ITEM)
		if (strcmp(LowerCase(Item), Item) != 0)
		{
			Hash = jenkinsLookupHash2((UINT8*)LowerCase(Item), strlen(FileName), 1);
			HashIdx = Hash % pManifestHeader->HashTableKeyCount;
			HashFileIdx = lpHashTableKeys[HashIdx];
		}
	if (HashFileIdx == CACHE_INVALID_ITEM)
		return CACHE_INVALID_ITEM;

	HashFileIdx -= pManifestHeader->HashTableKeyCount;
	while (true)
	{
		UINT32 Value = this->lpHashTableIndices[HashFileIdx];
		UINT32 FileID = Value & 0x7FFFFFFF;
		if (strcmp(GetItemPath(FileID), Item) == 0)
			return FileID;
		if ((Value & 0x80000000) == 0x80000000)
			break;
		HashFileIdx++;
	}

	return CACHE_INVALID_ITEM;
}

char *CGCFFile::GetItemName(UINT32 Item)
{
	return &lpNames[lpManifest[Item].NameOffset];
}

char *CGCFFile::GetItemPath(UINT32 Item)
{
	size_t len = strlen(&lpNames[lpManifest[Item].NameOffset]);
	UINT32 Idx = lpManifest[Item].ParentIndex;
	while (Idx != CACHE_INVALID_ITEM)
	{
		len += strlen(&lpNames[lpManifest[Idx].NameOffset]) + 1;
		Idx= lpManifest[Idx].ParentIndex;
	}
	len--;

	char *res = new char[len+1];
	memset(res, 0, len+1);
	size_t l = strlen(&lpNames[lpManifest[Item].NameOffset]);
	memcpy(&res[len-l], &lpNames[lpManifest[Item].NameOffset], l);
	len -= strlen(&lpNames[lpManifest[Item].NameOffset]);
	res[--len] = '\\';
	Item = lpManifest[Item].ParentIndex;
	while ((Item != CACHE_INVALID_ITEM) && (Item != 0))
	{
		l = strlen(&lpNames[lpManifest[Item].NameOffset]);
		memcpy(&res[len-l], &lpNames[lpManifest[Item].NameOffset], l);
		len -= strlen(&lpNames[lpManifest[Item].NameOffset]);
		res[--len] = '\\';
		Item = lpManifest[Item].ParentIndex;
	}
	return res;
}

////////////////////////////////////////////////////////////////////////////////
//                        методы обработки элементов                          //
////////////////////////////////////////////////////////////////////////////////
UINT64 CGCFFile::ExtractItem_Recurse(UINT32 Item, char *Dest)
{
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
	{
		return ExtractFile(Item, Dest, false);
	}
	else
	{
		CreateDirectoryA(Dest, NULL);
		UINT64 uiSize = 0;
		Item = lpManifest[Item].ChildIndex;
		while (Item != 0)
		{
			uiSize += ExtractItem_Recurse(Item, MakeStr(IncludeTrailingPathDelimiter(Dest), GetItemName(Item)));
			Item = lpManifest[Item].NextIndex;
		}
		return uiSize;
	}
	return 0;
}

UINT64 CGCFFile::DecryptItem_Recurse(UINT32 Item, char *key)
{
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == 0)
	{
		UINT64 res = 0;
		Item = lpManifest[Item].ChildIndex;
		while (Item != 0)
		{
			res += DecryptItem_Recurse(Item, key);
			if (Stop) 
				return res;
			Item = lpManifest[Item].NextIndex;
		}
		return res;
	}
	else
	{
		if ((lpManifest[Item].Attributes & CACHE_FLAG_ENCRYPTED) == CACHE_FLAG_ENCRYPTED)
			return DecryptFile(Item, key);
		else
			return GetItemSize(Item).Size;
	}
}

bool CGCFFile::ExtractItem(UINT32 Item, char *Dest)
{
	UINT64 uiSize = GetItemSize(Item).Size;
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) != CACHE_FLAG_FILE)
		ForceDirectories(Dest);
	return (ExtractItem_Recurse(Item, Dest) == uiSize);
}

UINT64 CGCFFile::ExtractFile(UINT32 Item, char *Dest, bool IsValidation)
{
	CStream *fileIn = this->OpenFile(Item, CACHE_OPEN_READ),
		*fileOut;
	if (fileIn == NULL)
		return 0;
	if (!IsValidation)
	{
		if (DirectoryExists(Dest))
			Dest = MakeStr(IncludeTrailingPathDelimiter(Dest), GetItemName(Item));
		fileOut = new CStream(Dest, true);
		if (fileOut->GetHandle() == INVALID_HANDLE_VALUE)
			return 0;
		fileOut->SetSize(GetItemSize(Item).Size);
	}

	UINT8 buf[CACHE_CHECKSUM_LENGTH];
	UINT32 CheckSize = CACHE_CHECKSUM_LENGTH;
	UINT64 res = 0;
	while ((fileIn->Position()<fileIn->GetSize()) && (CheckSize == CACHE_CHECKSUM_LENGTH))
	{
		if (Stop)
			break;
		UINT32 CheckIdx = lpFileIDChecksum[lpManifest[Item].FileId].FirstChecksumIndex + ((fileIn->Position() & 0xffffffffffff8000) >> 15);
		CheckSize = (UINT32)fileIn->Read(buf, CheckSize);

		UINT32 CheckFile = Checksum(buf, CheckSize),
			CheckFS = lpChecksum[CheckIdx];
		if (CheckFile != CheckFS)
		{
			break;
		}
		else if (!IsValidation)
		{
			fileOut->Write(buf, CheckSize);
		}

		res += CheckSize;
	}
	delete fileIn;
	if (!IsValidation)
		delete fileOut;
	return 0;//res;
}

UCHAR IV[16] = {0};
void DecryptFileChunk(char *buf, UINT32 size, char *key)
{
	AES_KEY aes_key;
	AES_set_decrypt_key((UCHAR*)key, 128, &aes_key);
	AES_cbc_encrypt((UCHAR*)buf, (UCHAR*)buf, size, &aes_key, IV, false);
}

UINT64 CGCFFile::DecryptFile(UINT32 Item, char *key)
{
	UINT64 res = 0;
	CStream *str = OpenFile(Item, CACHE_OPEN_READWRITE);
	if (str == NULL)
		return 0;
	char buf[CACHE_CHECKSUM_LENGTH],
		dec[CACHE_CHECKSUM_LENGTH];
	UINT32 CheckSize = CACHE_CHECKSUM_LENGTH;
	INT32 CompSize,
		UncompSize,
		sz;
	while ((str->Position() < str->GetSize()) && (CheckSize == CACHE_CHECKSUM_LENGTH))
	{
		UINT32 CheckIdx = lpFileIDChecksum[lpManifest[Item].FileId].FirstChecksumIndex +
			((str->Position() & 0xffffffffffff8000) >> 15);
		INT32 CheckSize = (INT32)str->Read(buf, 8);

		memcpy(&CompSize, &buf[0], 4);
		memcpy(&UncompSize, &buf[4], 4);
		if (((UINT32)UncompSize > pManifestHeader->CompressionBlockSize) || (CompSize > UncompSize) || (UncompSize < -1) || (CompSize < -1))
		{
			// Chunk is not compressed
			CheckSize = (UINT32)str->Read(&buf[8], CACHE_CHECKSUM_LENGTH-8);
			DecryptFileChunk(&buf[0], CheckSize, key);
		}
		else if (((UINT32)UncompSize <= pManifestHeader->CompressionBlockSize) && (CompSize <= UncompSize) && (UncompSize > -1) || (CompSize > -1))
		{
			// Chunk is compressed
			CheckSize = (UINT32)str->Read(&buf[8], UncompSize-8);
			INT32 CheckFile = UncompSize;
			if (CompSize%16 == 0)
				sz = CompSize;
			else
				sz = CompSize + 16 - (CompSize%16);
			memcpy(dec, buf, sz);
			DecryptFileChunk(&dec[0], sz, key);
			uncompress((Bytef*)&buf[0], (uLongf*)&CheckFile, (Bytef*)&dec[0], sz);
		}
		str->Seek(-CheckSize, USE_SEEK_CURRENT);
		str->Write(&buf[0], CheckSize);

		UINT32 Check1 = Checksum((UINT8*)&buf[0], CheckSize),
			Check2 = lpChecksum[CheckIdx];
		if (Check1 != Check2)
			break;
		res += CheckSize;
	}

	lpManifest[Item].Attributes = lpManifest[Item].Attributes & (!CACHE_FLAG_ENCRYPTED);
	return res;
}

bool CGCFFile::ExtractForGame(char *Dest)
{
	UINT64 AllSize = 0,
		CompletedSize = 0;
	for (UINT32 i=0; i < pManifestHeader->NumOfMinimumFootprintFiles ; i++)
		AllSize += GetItemSize(lpMinimumFootprint[i]).Size;
	for (UINT32 i=0; i < pManifestHeader->NumOfMinimumFootprintFiles ; i++)
	{
		if (Stop)
			break;
		CompletedSize += ExtractFile(lpMinimumFootprint[i], MakeStr(Dest, GetItemPath(lpMinimumFootprint[i])), false);
	}
	return (AllSize==CompletedSize);
}

bool CGCFFile::ValidateItem(UINT32 Item)
{
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
	{
		return (ExtractFile(Item, "", true) == GetItemSize(Item).Size);
	}
	else
	{
		bool ret = true;
		Item = lpManifest[Item].ChildIndex;
		while (Item != 0)
		{
			if (Stop)
				break;
			if (!ValidateItem(Item))
				ret = false;
			Item = lpManifest[Item].NextIndex;
		}
		return ret;
	}
}

bool CGCFFile::CorrectItem(UINT32 Item)
{
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
	{
		if (!ExtractFile(Item, "", true) == GetItemSize(Item).Size)
		{
			CStream *str = OpenFile(Item, CACHE_OPEN_WRITE);
			str->SetSize(0);
			delete str;
			//return false;
		}
		else return true;
	}
	else
	{
		bool ret = true;
		Item = lpManifest[Item].ChildIndex;
		while (Item != 0)
		{
			if (Stop)
				break;
			if (!ValidateItem(Item))
				ret = false;
			Item = lpManifest[Item].NextIndex;
		}
		return ret;
	}
	return true;
}

bool CGCFFile::DecryptItem(UINT32 Item, char *key)
{
	// key
	UINT64 size = GetItemSize(Item).Size,
		CSize = DecryptItem_Recurse(Item, key);
	return (size == CSize);
}

UINT64 CGCFFile::GetCompletedSize(UINT32 Item)
{
	UINT64 res = 0;
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
	{
		if (!IsNCF)
		{
			UINT32 BlockIdx = lpManifestMap[Item];
			while ((BlockIdx != pBATHeader->BlockCount))
			{
				res += lpBAT[BlockIdx].FileDataSize;
				BlockIdx = lpBAT[BlockIdx].NextBlockIndex;
			}
		}
		else
		{
			LARGE_INTEGER res1;
			char *FN = MakeStr(CommonPath, GetItemPath(Item));
			HANDLE hFile = CreateFileA(FN, GENERIC_READ, FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
			if (hFile != INVALID_HANDLE_VALUE)
			{
				if (GetFileSizeEx(hFile, &res1))
					res = res1.QuadPart;
				CloseHandle(hFile);
			}
		}
	}
	else
	{
		UINT32 Idx = lpManifest[Item].ChildIndex;
		while (Idx > 0)
		{
			res += GetCompletedSize(Idx);
			Idx = lpManifest[Idx].NextIndex;
		}
	}
	return res;
}

double CGCFFile::GetCompletion(UINT32 Item)
{
	UINT64 Size = GetItemSize(Item).Size,
		CompletedSize = GetCompletedSize(Item);
	double res = 0;
	if (Size>0)
		res = ((double)CompletedSize/(double)Size);
	if ((Size>CompletedSize) && (res==1))
		res = 0.9999;
	if (res>1)
		res=1;
	return res;
}

bool CGCFFile::FindFirst(FindRecord *pFindRecord)
{
	char *Path = ExtractFilePath(pFindRecord->Mask);
	int ItemRoot = CACHE_INVALID_ITEM;
	if (Path != "")
	{
		ItemRoot = this->GetItem(Path);
		if (ItemRoot == CACHE_INVALID_ITEM)
			return false;
	}
	if (ItemRoot == CACHE_INVALID_ITEM)
		ItemRoot = 0;
	UINT32 Item = lpManifest[ItemRoot].ChildIndex;
	Path = ExtractFileName(pFindRecord->Mask);
	while (Item != 0)
	{
		if (StrSatisfy(GetItemPath(Item), pFindRecord->Mask))
		{
			pFindRecord->Path = GetItemPath(Item);
			pFindRecord->Root.Package = this;
			pFindRecord->Root.Item = Item;
			pFindRecord->Current.Package = this;
			pFindRecord->Current.Item = Item;
			return true;
		}
		Item = lpManifest[Item].NextIndex;
	}
	return false;
}

bool CGCFFile::FindNext(FindRecord *pFindRecord)
{
	UINT32 Item = pFindRecord->Current.Item;
	Item = lpManifest[Item].NextIndex;
	while (Item != 0)
	{
		if (StrSatisfy(GetItemPath(Item), pFindRecord->Mask))
		{
			pFindRecord->Path = GetItemPath(Item);
			pFindRecord->Current.Package = this;
			pFindRecord->Current.Item = Item;
			return true;
		}
		Item = lpManifest[Item].NextIndex;
	}
	return false;
}

char *CGCFFile::CreateInfo()
{
	char *V = new char[10];
	_itoa_s(pHeader->ApplicationVersion, V, 10, 10);
	char *InfoName = ReplaceExt(fileName, MakeStr(V, ".archive"));
	MoveFileA(InfoName, MakeStr(InfoName, ".bak"));

	CGCFFile *Info = new CGCFFile(CommonPath);
	Info->CopyHeaders(this);
	if (!Info->SaveToFileAsInfo(InfoName))
		InfoName = "";
	delete Info;
	return InfoName;
}

char *CGCFFile::CreatePatch(char *InfoFile)
{
	CGCFFile *Info = new CGCFFile(CommonPath);
	if (!Info->LoadFromFile(InfoFile))
		return "";

	char *V1 = new char[10];
	_itoa_s(pHeader->ApplicationVersion, V1, 10, 10);
	char *V2 = new char[10];
	_itoa_s(Info->GetCacheVersion(), V2, 10, 10);
	char *PatchName = ReplaceExt(fileName, MakeStr(MakeStr(MakeStr(V1, "_to_"), V2), ".update.gcf"));
	MoveFileA(PatchName, MakeStr(PatchName, ".bak"));
	
	std::vector<bool> ToPatch;
	ToPatch.resize(pManifestHeader->NodeCount);
	// определяем, какие файлы необходимо включить в патч
	for (UINT i=0; i<pManifestHeader->NodeCount ; i++)
		if ((lpManifest[i].Attributes & CACHE_FLAG_FILE) == CACHE_FLAG_FILE)
		{
			ToPatch[i] = (!CompareFile(i, Info, i));//Info->GetItem(GetItemPath(i))));
		}
		else ToPatch[i] = false;

	// определяем, сколько секторов будет в этих файлах
	UINT32 SectorsCount = 0;
	for (UINT i=0 ; i<ToPatch.size() ; i++)
		if (ToPatch[i])
			SectorsCount += GetItemSize(i).Sectors;
	
	// создаем пустой файл патча
	CGCFFile *Patch = new CGCFFile(CommonPath);
	Patch->CopyHeaders(this);
	// обнуляем блоки и ссылки на них
	Patch->FreeBlocks();
	Patch->SetSectorsCount(SectorsCount);

	CStream *str = new CStream(PatchName, true);
	Patch->SaveToStream(str);
	Patch->pDataHeader->FirstClusterOffset = (UINT32)str->Position();
	str->Seek(0, USE_SEEK_BEGINNING);
	Patch->SaveToStream(str);
	str->SetSize(str->Position() + CACHE_BLOCK_SIZE*SectorsCount);

	UINT64 AllSize = SectorsCount*CACHE_BLOCK_SIZE,
		CSize = 0;
	// пишем файлы в патч
	UINT8 buf[CACHE_CHECKSUM_LENGTH];
	for (UINT i=0 ; i<ToPatch.size() ; i++)
	{
		if (ToPatch[i])
		{
			if (Stop)
				break;
			char *ItemName = this->GetItemPath(i);
			if (GetCompletion(i)<1)
				continue;
			CStream *f1 = OpenFile(ItemName, CACHE_OPEN_READ),
				*f2 = OpenFile(ItemName, CACHE_OPEN_WRITE);
			while (f1->Position() != f1->GetSize())
			{
				UINT32 ReadedSize = (UINT32)f1->Read(buf, CACHE_CHECKSUM_LENGTH);
				if (ReadedSize == 0)
					break;
				CSize += f2->Write(buf, ReadedSize);
				if (Stop)
					break;
			}
			delete f1;
			delete f2;
		}
	}
	str->Seek(0, USE_SEEK_BEGINNING);
	Patch->SaveToStream(str);
	delete Patch;
	return PatchName;
}





////////////////////////////////////////////////////////////////////////////////
//                         методы работы с потоками                           //
////////////////////////////////////////////////////////////////////////////////

CStream *CGCFFile::OpenFile(char* FileName, UINT8 Mode)
{
	UINT32 Item = GetItem(FileName);
	if (Item == CACHE_INVALID_ITEM)
		return NULL;
	if ((lpManifest[Item].Attributes & CACHE_FLAG_FILE) != CACHE_FLAG_FILE)
		return NULL;
	return OpenFile(Item, Mode);
}

CStream *CGCFFile::OpenFile(UINT32 Item, UINT8 Mode)
{
	StreamData *Data = new StreamData();
	memset(Data, 0, sizeof(StreamData));
	Data->Handle = (handle_t)Item;
	Data->Package = this;
	Data->Size = this->GetItemSize(Item).Size;

	if (IsNCF)
		Data->FileStream = (CStream*)new CStream(MakeStr(CommonPath, GetItemPath(Item)), Mode==CACHE_OPEN_WRITE);
	else
		BuildClustersTable(Item, &Data->Sectors);

	return new CStream(pStreamMethods, Data);
}

#define AllocateBlock() { UINT32 NewBlockIdx = pBATHeader->LastUsedBlock+1; \
			lpManifestMap[(UINT32)Data->Handle] = NewBlockIdx; \
			lpBAT[NewBlockIdx].Flags = 0; \
			lpBAT[NewBlockIdx].FileDataOffset = (UINT32)Offset; \
			lpBAT[NewBlockIdx].FileDataSize = NewSize; \
			lpBAT[NewBlockIdx].FirstClusterIndex = fDataBlockTerminator; \
			lpBAT[NewBlockIdx].NextBlockIndex = pBATHeader->BlockCount; \
			lpBAT[NewBlockIdx].PreviousBlockIndex = BlockIdx; \
			lpBAT[NewBlockIdx].ManifestIndex = lpBAT[BlockIdx].ManifestIndex; \
			pBATHeader->LastUsedBlock++; \
			pBATHeader->BlocksUsed++; }

void CGCFFile::StreamClose(StreamData *Data)
{
	if (IsNCF)
	{
		delete Data->FileStream;
		return;
	}
	if (Data->IsChange)
	{
		// изменяем таблицу секторов и блоков
		UINT32 BlockIdx = lpManifestMap[(UINT32)Data->Handle];
		UINT64 AllSize = GetItemSize((UINT32)Data->Handle).Size;
		UINT64 Offset = 0;

		if (BlockIdx == pBATHeader->BlockCount)
		{
			UINT32 NewSize = (UINT32)((AllSize > 0x7fffffff) ? 0x7fffffff : AllSize);
			AllSize -=NewSize;
			AllocateBlock();
			fIsChangeHeader[HEADER_BAT_HEADER] = true;
			fIsChangeHeader[HEADER_BAT] = true;
		}

		while (BlockIdx != pBATHeader->BlockCount)
		{
			if (lpBAT[BlockIdx].FileDataSize <= AllSize)
			{
				// конец файла - удаляем хвост текущей цепочки кластеров и у всех последующих блоков данного файла
				lpBAT[BlockIdx].FileDataSize = (UINT32)AllSize;
				DeleteBlock(lpBAT[BlockIdx].NextBlockIndex);
				lpBAT[BlockIdx].NextBlockIndex = pBATHeader->BlockCount;
			}

			if ((lpBAT[BlockIdx].NextBlockIndex == pBATHeader->BlockCount) && (lpBAT[BlockIdx].FileDataSize < AllSize))
			{
				while (AllSize > 0)
				{
					UINT32 NewSize = (UINT32)((AllSize>0x7fffffff) ? 0x7fffffff : AllSize);
					Offset += NewSize;
					lpBAT[BlockIdx].FileDataSize = NewSize;
					AllSize -= NewSize;

					// при необходимости - создаем новые блоки
					if (AllSize > 0)
						AllocateBlock();
				}
			}
			else
				Offset += lpBAT[BlockIdx].FileDataSize;
			AllSize -= lpBAT[BlockIdx].FileDataSize;
			BlockIdx = lpBAT[BlockIdx].NextBlockIndex;
			fIsChangeHeader[HEADER_BAT_HEADER] = true;
			fIsChangeHeader[HEADER_BAT] = true;
		}

		// меняем длину таблицы секторов
		UINT32 NewSize = (UINT32)((Data->Size & 0xffffffffffffe000) >> 13);
		if (NewSize < Data->Sectors.size())
			Data->Sectors.resize(NewSize);

		RebuildClustersTable((UINT32)Data->Handle, &Data->Sectors);
		BuildBitMap();
		CalculateChecksumsForHeaders();
		//SaveChanges();
		SaveToStream(stream);
	}
}

UINT64 CGCFFile::StreamRead(StreamData *Data, void *lpData, UINT64 uiSize)
{
	UINT32 Item = (UINT32)Data->Handle;
	if (uiSize > GetItemSize(Item).Size - Data->Position)
		uiSize = GetItemSize(Item).Size - Data->Position;

	if (IsNCF)
	{
		UINT32 res = (UINT32)((CStream*)Data->FileStream)->Read(lpData, uiSize);
		Data->Position = ((CStream*)Data->FileStream)->Position();
		return res;
	}
	else
	{
		UINT32 ReadingSize = 0;
		while (uiSize>0)
		{
			if (Stop)
				break;
			UINT32 ClusterIdx = (Data->Position & 0xffffffffffffe000) >>13;
			if (ClusterIdx > Data->Sectors.size())
				break;
			ClusterIdx = Data->Sectors[ClusterIdx];
			if (ClusterIdx >= pFATHeader->ClusterCount)
				break;
			UINT32 ReadPos = (Data->Position & 0x00001fff);
			stream->Seek(pDataHeader->FirstClusterOffset + ClusterIdx*CACHE_BLOCK_SIZE + ReadPos, USE_SEEK_BEGINNING);
			UINT64 ReadSize = CACHE_BLOCK_SIZE;
			if (ReadSize > ReadSize-ReadPos)
				ReadSize = ReadSize - ReadPos;
			if (ReadSize > uiSize)
				ReadSize = uiSize;
			if (ReadSize > Data->Size-Data->Position)
				ReadSize = Data->Size-Data->Position;
			UINT32 ReadedSize = (UINT32)stream->Read(lpData, ReadSize);
			ReadingSize += ReadedSize;
			lpData = (void*)((UINT8*)lpData+ReadedSize);
			Data->Position += ReadedSize;
			uiSize -= ReadedSize;
		}
		return ReadingSize;
	}
}

UINT64 CGCFFile::StreamWrite(StreamData *Data, void *lpData, UINT64 uiSize)
{
	UINT32 Item = (UINT32)Data->Handle;
	if (uiSize > GetItemSize(Item).Size - Data->Position)
		uiSize = GetItemSize(Item).Size - Data->Position;

	if (IsNCF)
	{
		UINT32 res = (UINT32)((CStream*)Data->FileStream)->Write(lpData, uiSize);
		Data->Position = ((CStream*)Data->FileStream)->Position();
		Data->IsChange = true;
		return res;
	}
	else
	{
		UINT32 WritingSize = 0;
		while (uiSize>0)
		{
			if (Stop)
				break;
			UINT32 ClusterIdx = (Data->Position & 0xffffffffffffe000) >>13;
			// если кластеров в таблице не хватает, то получаем новые:
			if (Data->Sectors.size() <= ClusterIdx)
			{
				UINT32 Cluster = AllocateCluster();
				if (((UINT32)Cluster >= pDataHeader->ClusterCount) || (Cluster == -1))
					break;
				Data->Sectors.resize(Data->Sectors.size()+1);
				Data->Sectors[Data->Sectors.size()-1] = Cluster;
			}
			if (ClusterIdx > Data->Sectors.size())
				break;
			ClusterIdx = Data->Sectors[ClusterIdx];
			if (ClusterIdx >= pFATHeader->ClusterCount)
				break;
			UINT64 WritePos = (Data->Position & 0x00001fff);
			stream->Seek(pDataHeader->FirstClusterOffset + ClusterIdx*CACHE_BLOCK_SIZE + WritePos, USE_SEEK_BEGINNING);
			UINT64 WriteSize = CACHE_BLOCK_SIZE;
			if (WriteSize > WriteSize-WritePos)
				WriteSize = WriteSize - WritePos;
			if (WriteSize > uiSize)
				WriteSize = uiSize;
			if (WriteSize > Data->Size-Data->Position)
				WriteSize = Data->Size-Data->Position;
			UINT32 WritedSize = (UINT32)stream->Read(lpData, WriteSize);
			WritingSize += WritedSize;
			lpData = (void*)((UINT8*)lpData+WritedSize);
			Data->Position += WritedSize;
			uiSize -= WritingSize;
		}
		if (WritingSize > 0)
			Data->IsChange = true;
		return WritingSize;
	}
}

UINT64 CGCFFile::StreamSeek(StreamData *Data, INT64 uiPos, ESeekMode eSeekMode)
{
	switch (eSeekMode)
	{
	case USE_SEEK_BEGINNING: Data->Position = uiPos;
		break;
	case USE_SEEK_CURRENT: Data->Position = Data->Position + uiPos;
		break;
	case USE_SEEK_END: Data->Position = Data->Size + uiPos;
		break;
	}
	return Data->Position;
}

UINT64 CGCFFile::StreamGetSize(StreamData *Data)
{
	return Data->Size;
}

void CGCFFile::StreamSetSize(StreamData *Data, UINT64 uiSize)
{
	if (uiSize != Data->Size)
	{
		Data->IsChange = true;
		if (!IsNCF)
		{
			UINT32 BlockIdx = lpManifestMap[(UINT32)Data->Handle];
			UINT32 AllSize = 0;
			while (BlockIdx < pBATHeader->BlockCount)
			{
				if (uiSize < AllSize + lpBAT[BlockIdx].FileDataSize)
				{
					lpBAT[BlockIdx].FileDataSize = (UINT32)uiSize - AllSize;
					DeleteBlock(lpBAT[BlockIdx].NextBlockIndex);
					break;
				}
				AllSize += lpBAT[BlockIdx].FileDataSize;
				BlockIdx = lpBAT[BlockIdx].NextBlockIndex;
			}
			lpManifest[(UINT32)Data->Handle].CountOrSize = (UINT32)uiSize;
		}
		else
			Data->FileStream->SetSize(uiSize);
		Data->Size = uiSize;
	}
}