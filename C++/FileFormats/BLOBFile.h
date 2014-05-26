#pragma pack (push, 1)
struct TBLOBDataHeader
{
	UINT16 NameLen;
	UINT32 DataLen;
};

struct TBLOBCompressedDataHeader
{
	UINT32 UncompressedSize;
	UINT32 unknown1;
	UINT16 unknown2;
};

struct TBLOBNodeHeader
{
	UINT16 Magic;
	UINT32 Size;
	UINT32 SlackSize;
};

#define NODE_MAGIC				0x5001
#define NODE_COMPRESSED_MAGIC	0x4301

#pragma pack (pop)

class CBLOBNode
{
private:
	bool fIsData;
	char *fName;
	char *fData;
	UINT32 fNameLen;
	UINT32 fDataSize;
	UINT32 fSlackSize;
	//std::vector<CBLOBNode*> fChildrens;
	UINT32 fChildrensCount;
	CBLOBNode **fChildrens;

	void DeserializeFromMem(char *mem);
	UINT32 GetChildrensSize();

	void SetName(char *NewName, int NameLen);
	CBLOBNode *GetNode(char *NodeName);
	void SetNode(char *NodeName, int NameLen, CBLOBNode *Value);
	CBLOBNode *GetNodeIdx(UINT32 NodeIdxName);
	void SetNodeIdx(UINT32 NodeIdxName, CBLOBNode *Value);
	UINT32 GetChildrensCount(char *mem);
public:
	CBLOBNode();
	~CBLOBNode();
	void DeserializeFromStream(CStream *stream);
	void SerializeToStream(CStream *stream, bool IsCompressed);
	UINT32 SerializeToMem(char **mem, bool IsCompressed);

	UINT32 ChildrensCount() { return fChildrensCount; };
	UINT32 NameLen() { return fNameLen; };
	char *Name() { return fName; };
	UINT32 DataSize() { return fDataSize; };
	UINT32 SlackSize() { return fSlackSize; };
	char *Data() { return fData; };
	void SetData(char *Value, UINT32 size);
	CBLOBNode *Childrens(int Idx);
	CBLOBNode *GetNodeByName(char *NodeName);
	CBLOBNode *GetNodeByIdx(UINT32 NodeIdxName);

	void AddData(char *NodeName, int NameLen, char *data, UINT32 size);
	void AddString(char *NodeName, int NameLen, char* Value, int len);

	UINT16 ReadUINT16(UINT32 Name);
	UINT32 ReadUINT32(UINT32 Name);
	char *ReadString(UINT32 Name);
	bool ReadBool(UINT32 Name);
};

class CBLOBFile
{
private:
	char *fFileName;
	CStream *Stream;
	CBLOBNode *fRootNode;
public:
	CBLOBFile();
	CBLOBFile(char *filename);
	CBLOBFile(CStream *stream);
	CBLOBFile(char *mem, UINT32 size);
	~CBLOBFile();

	void Save(bool IsCompressed);
	void SaveToFile(char *filename, bool IsCompressed);
	UINT32 SaveToMem(char **mem, bool IsCompressed);

	CBLOBNode *RootNode() { return fRootNode; };
};