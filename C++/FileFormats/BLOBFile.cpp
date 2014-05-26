#include "stdafx.h"
#include "..\zlib.h"
#include "../Stream.h"
#include "BLOBFile.h"

CBLOBNode::CBLOBNode()
{
	fIsData = false;
	fNameLen = fDataSize = fSlackSize = 0;
	fName = fData = NULL;
	fChildrens = NULL;
	fChildrensCount = 0;
}

CBLOBNode::~CBLOBNode()
{
	delete fName;
	delete fData;
	int len = fChildrensCount;
	if (len > 0)
		for (int i=0 ; i<len ; i++)
			delete fChildrens[i];
	if (fChildrens != NULL)
		delete fChildrens;
}

void CBLOBNode::DeserializeFromMem(char *mem)
{
	TBLOBNodeHeader *NodeHeader = (TBLOBNodeHeader*)mem;
	TBLOBDataHeader *DataHeader = (TBLOBDataHeader*)mem;
	char *data = NULL;

	if (NodeHeader->Magic == NODE_COMPRESSED_MAGIC)
	{
		mem += sizeof(TBLOBNodeHeader);
		TBLOBCompressedDataHeader *CompressedHeader = (TBLOBCompressedDataHeader*)mem;
		mem += sizeof(TBLOBCompressedDataHeader);
		UINT32 compSize = NodeHeader->Size,
			uncompSize = CompressedHeader->UncompressedSize;
		data = new char[uncompSize];
		if (uncompress((Bytef*)data, (uLongf*)&uncompSize, (Bytef*)mem, compSize) != Z_OK)
			return;
		mem = data;
		NodeHeader = (TBLOBNodeHeader*)mem;
		DataHeader = (TBLOBDataHeader*)mem;
	}

	if (NodeHeader->Magic == NODE_MAGIC)
	{
		fIsData = false;
		fDataSize = NodeHeader->Size;
		fSlackSize = NodeHeader->SlackSize;
		fChildrensCount = GetChildrensCount(mem);
		fChildrens = new CBLOBNode*[fChildrensCount];
		mem += sizeof(TBLOBNodeHeader);
		for (UINT i=0 ; i<fChildrensCount ; i++)
		{
			fChildrens[i] = new CBLOBNode();
			fChildrens[i]->DeserializeFromMem(mem);
			NodeHeader = (TBLOBNodeHeader*)mem;
			DataHeader = (TBLOBDataHeader*)mem;
			if ((NodeHeader->Magic == NODE_MAGIC) || (NodeHeader->Magic == NODE_COMPRESSED_MAGIC))
				mem += NodeHeader->Size + NodeHeader->SlackSize;
			else
				mem += sizeof(TBLOBDataHeader) + DataHeader->DataLen + DataHeader->NameLen;
		}
	}
	else
	{
		fIsData = true;
		fNameLen = DataHeader->NameLen;
		fDataSize = DataHeader->DataLen;
		mem += sizeof(TBLOBDataHeader);
		fName = new char[fNameLen+1];
		memcpy(fName, mem, fNameLen);
		fName[fNameLen] = '\x00';
		mem += fNameLen;
		UINT16 node;
		memcpy(&node, mem, 2);
		if ((node == NODE_MAGIC) || (node == NODE_COMPRESSED_MAGIC))
		{
			DeserializeFromMem(mem);
			fData = NULL;
		}
		else
		{
			fData = new char[fDataSize];
			memcpy(fData, mem, fDataSize);
		}
	}

	if (data != NULL)
		delete data;
}

UINT32 CBLOBNode::SerializeToMem(char **mem, bool IsCompressed)
{
	UINT32 DataSize = GetChildrensSize();
	bool MainMem = (*mem == NULL);
	if (MainMem)
	{
		*mem = new char[DataSize];
		memset(*mem, 0, DataSize);
	}
	char *data = *mem;
	TBLOBDataHeader DataHeader;
	TBLOBNodeHeader NodeHeader;
	if (fIsData)
	{
		DataHeader.NameLen = fNameLen;
		DataHeader.DataLen = fDataSize;
		memcpy(data, &DataHeader, sizeof(TBLOBDataHeader));
		data += sizeof(TBLOBDataHeader);
		memcpy(data, fName, fNameLen);
		data += fNameLen;
		if (fData != NULL)
			memcpy(data, fData, fDataSize);
		DataSize = fDataSize + fNameLen + sizeof(TBLOBDataHeader);
	}
	else
	{
		NodeHeader.Magic = NODE_MAGIC;
		NodeHeader.Size = fDataSize;
		NodeHeader.SlackSize = fSlackSize;
		memcpy(data, &NodeHeader, sizeof(TBLOBNodeHeader));
		data += sizeof(TBLOBNodeHeader);
		int len = fChildrensCount;
		for (int i=0 ; i<len ; i++)
		{
			if (!fChildrens[i]->fIsData)
			{
				DataHeader.DataLen = fChildrens[i]->GetChildrensSize();
				DataHeader.NameLen = fChildrens[i]->fNameLen;
				memcpy(data, &DataHeader, sizeof(TBLOBDataHeader));
				data += sizeof(TBLOBDataHeader);
				memcpy(data, fChildrens[i]->fName, fChildrens[i]->fNameLen);
				data += fChildrens[i]->fNameLen;
			}
			data += fChildrens[i]->SerializeToMem(&data, false);
		}
		data += NodeHeader.SlackSize;
	}

	if (MainMem && IsCompressed)
	{
		UINT32 compSize = DataSize + (DataSize*0.01) + 16;
		data = new char[compSize];
		compress2((Bytef*)data, (uLongf*)&compSize, (Bytef*)*mem, DataSize, 9);
		delete *mem;
		NodeHeader.Magic = NODE_COMPRESSED_MAGIC;
		NodeHeader.Size = compSize;
		NodeHeader.SlackSize = 0;
		TBLOBCompressedDataHeader CompressedHeader;
		CompressedHeader.UncompressedSize = DataSize;
		CompressedHeader.unknown1 = 0;
		CompressedHeader.unknown2 = 0;
		DataSize = compSize + sizeof(TBLOBNodeHeader) + sizeof(TBLOBCompressedDataHeader);
		*mem = new char[DataSize];
		memcpy(*mem, &NodeHeader, sizeof(TBLOBNodeHeader));
		memcpy(*mem+sizeof(TBLOBNodeHeader), &CompressedHeader, sizeof(TBLOBCompressedDataHeader));
		memcpy(*mem+sizeof(TBLOBNodeHeader)+sizeof(TBLOBCompressedDataHeader), data, compSize);
		delete data;
	}

	return DataSize;
}

UINT32 CBLOBNode::GetChildrensSize()
{
	UINT32 res = 0;
	int len = fChildrensCount;
	for (int i=0 ; i<len ; i++)
	{
		res += fChildrens[i]->fDataSize;
		res += fChildrens[i]->fSlackSize;
		res += fChildrens[i]->fNameLen;
		res += sizeof(TBLOBDataHeader);
	}
	if (!fIsData)
	{
		res += fSlackSize;
		res += sizeof(TBLOBNodeHeader);
	}
	return res;
}

UINT32 CBLOBNode::GetChildrensCount(char *mem)
{
	UINT32 res = 0;
	TBLOBNodeHeader *NodeHeader = (TBLOBNodeHeader*)mem;
	char *end = mem + NodeHeader->Size;
	mem += sizeof(TBLOBNodeHeader);
	while (mem<end)
	{
		TBLOBNodeHeader *NodeHeader = (TBLOBNodeHeader*)mem;
		TBLOBDataHeader *DataHeader = (TBLOBDataHeader*)mem;
		res++;
		if ((NodeHeader->Magic == NODE_MAGIC) || (NodeHeader->Magic == NODE_COMPRESSED_MAGIC))
			mem += NodeHeader->Size + NodeHeader->SlackSize;
		else
			mem += sizeof(TBLOBDataHeader) + DataHeader->NameLen + DataHeader->DataLen;
	}
	return res;
}

void CBLOBNode::DeserializeFromStream(CStream *stream)
{
	UINT32 size = (UINT32)stream->GetSize();
	char *data = new char[size];
	stream->Read(data, size);
	DeserializeFromMem(data);
	delete data;
}

void CBLOBNode::SerializeToStream(CStream *stream, bool IsCompressed)
{
	char *data = NULL;
	UINT32 size = SerializeToMem(&data, IsCompressed);
	stream->Write(data, size);
	delete data;
}

void CBLOBNode::SetName(char *NewName, int NameLen)
{
	delete fName;
	fName = CopyStr(NewName, NameLen);
	fNameLen = NameLen;
}

CBLOBNode *CBLOBNode::GetNode(char *NodeName)
{
	int len = fChildrensCount;
	if (len > 0)
		for (int i=0 ; i<len ; i++)
			if (strcmp(fChildrens[i]->fName, NodeName) == 0)
				return fChildrens[i];
	return NULL;
}

void CBLOBNode::SetNode(char *NodeName, int NameLen, CBLOBNode *Value)
{
	int len = fChildrensCount;
	if (len > 0)
		for (int i=0 ; i<len ; i++)
			if (strcmp(fChildrens[i]->fName, NodeName) == 0)
			{
				fChildrens[i]->fData = Value->fData;
				fChildrens[i]->SetName(Value->fName, NameLen);
				fChildrens[i]->fSlackSize = Value->fSlackSize;
				fChildrens[i]->SetData(Value->fData, Value->fDataSize);
				return;
			}
}

CBLOBNode *CBLOBNode::GetNodeIdx(UINT32 NodeIdxName)
{
	return GetNode((char*)&NodeIdxName);
}

void CBLOBNode::SetNodeIdx(UINT32 NodeIdxName, CBLOBNode *Value)
{
	SetNode((char*)&NodeIdxName, 4, Value);
}

void CBLOBNode::SetData(char *Value, UINT32 size)
{
	if (fData != NULL)
	{
		if (size != fDataSize)
			realloc(fData, size);
	}
		else
			fData = new char[size];
	fDataSize = size;
	memcpy(fData, Value, size);
}

void CBLOBNode::AddData(char *NodeName, int NameLen, char *data, UINT32 size)
{
	fIsData = false;
	int idx = fChildrensCount;
	if (fChildrens != NULL)
		fChildrens = (CBLOBNode**)realloc(fChildrens, (idx+1)*sizeof(CBLOBNode*));
	else
		fChildrens = new CBLOBNode*[1];
	fChildrensCount++;
	fChildrens[idx] = new CBLOBNode();
	fChildrens[idx]->fIsData = true;
	fChildrens[idx]->SetName(NodeName, NameLen);
	fChildrens[idx]->SetData(data, size);

	if (fDataSize == 0)
		fDataSize = sizeof(TBLOBNodeHeader);
	fDataSize += fChildrens[idx]->fNameLen + fChildrens[idx]->fDataSize + sizeof(TBLOBDataHeader);
}

void CBLOBNode::AddString(char *NodeName, int NameLen, char* Value, int len)
{
	AddData(NodeName, NameLen, Value, len);
}

UINT16 CBLOBNode::ReadUINT16(UINT32 Name)
{
	if ((GetNodeByIdx(Name) == NULL) || (GetNodeByIdx(Name)->Data() == NULL))
		return 0;
	return *(UINT16*)GetNodeByIdx(Name)->Data();
}

UINT32 CBLOBNode::ReadUINT32(UINT32 Name)
{
	if ((GetNodeByIdx(Name) == NULL) || (GetNodeByIdx(Name)->Data() == NULL))
		return 0;
	return *(UINT32*)GetNodeByIdx(Name)->Data();
}

char *CBLOBNode::ReadString(UINT32 Name)
{
	if ((GetNodeByIdx(Name) == NULL) || (GetNodeByIdx(Name)->Data() == NULL))
		return "";
	//return GetNodeByIdx(Name)->Data();
	return CopyStr(GetNodeByIdx(Name)->Data(), GetNodeByIdx(Name)->DataSize());
}

bool CBLOBNode::ReadBool(UINT32 Name)
{
	if ((GetNodeByIdx(Name) == NULL) || (GetNodeByIdx(Name)->Data() == NULL))
		return false;
	return *(bool*)GetNodeByIdx(Name)->Data();
}

CBLOBNode *CBLOBNode::Childrens(int Idx)
{
	return CBLOBNode::fChildrens[Idx];
}

CBLOBNode *CBLOBNode::GetNodeByName(char *NodeName)
{
	return GetNode(NodeName);
}

CBLOBNode *CBLOBNode::GetNodeByIdx(UINT32 NodeIdxName)
{
	return GetNodeIdx(NodeIdxName);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//                                           CBLOBFile                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////

CBLOBFile::CBLOBFile()
{
	fFileName = NULL;
	Stream = NULL;
	fRootNode = new CBLOBNode();
}

CBLOBFile::CBLOBFile(char *filename)
{
	fRootNode = new CBLOBNode();
	fFileName = CopyStr(filename);
	Stream = new CStream(filename);
	if (Stream->GetHandle() == INVALID_HANDLE_VALUE)
	{
		this->~CBLOBFile();
		return;
	}
	fRootNode->DeserializeFromStream(Stream);
	delete Stream;
}

CBLOBFile::CBLOBFile(CStream *stream)
{
	fRootNode = new CBLOBNode();
	fRootNode->DeserializeFromStream(stream);
}

CBLOBFile::CBLOBFile(char *mem, UINT32 size)
{
	fRootNode = new CBLOBNode();
	Stream = new CStream(mem, (UINT64)size);
	fRootNode->DeserializeFromStream(Stream);
	delete Stream;
}

CBLOBFile::~CBLOBFile()
{
	delete fFileName;
	delete fRootNode;
}

void CBLOBFile::Save(bool IsCompressed)
{
	Stream = new CStream(fFileName);
	if (Stream->GetHandle() == INVALID_HANDLE_VALUE)
		return;
	fRootNode->SerializeToStream(Stream, IsCompressed);
	delete Stream;
}

void CBLOBFile::SaveToFile(char *filename, bool IsCompressed)
{
	Stream = new CStream(filename, true);
	if (Stream->GetHandle() == INVALID_HANDLE_VALUE)
		return;
	fRootNode->SerializeToStream(Stream, IsCompressed);
	delete Stream;
}

UINT32 CBLOBFile::SaveToMem(char **mem, bool IsCompressed)
{
	return fRootNode->SerializeToMem(mem, IsCompressed);
	return NULL;
}