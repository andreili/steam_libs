
#define CHUNK_SIZE 0x8000

#pragma pack (push, 1)
struct TPKGHeader
{
	UCHAR Version;
	INT32 CompLevel;
	INT32 FilesCount;
};

struct TPKGFileHeader
{
	INT32 UnpackedSize;
	INT32 PackedSize;
	INT32 FileStart;
	INT32 FileNameLen;
};

struct TPKGFile
{
	TPKGFileHeader Header;
	char *FileName;
};
#pragma pack (pop)

class CPKGFile
{
private:
	char *fFileName;
	CStream *stream;
	TPKGHeader fHeader;
	TPKGFile *fFiles;
public:
	CPKGFile();
	CPKGFile(char *filename);
	~CPKGFile();

	void Extract(char *DstDir);
	bool Pack(char *InpDir, char *OutFileName, char *MSTFile);
};