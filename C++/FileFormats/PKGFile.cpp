#include "stdafx.h"
#include "../Config.h"
#include "PKGFile.h"
#include "../Stream.h"
#include "functions.h"
#include "../zlib.h"

void DecompressBuf(char *InBuf, int InBytes, int OutEstimate, char **OutBuf, int *OutBytes)
{
	z_stream stream;
	memset(&stream, 0, sizeof(z_stream));
	stream.zalloc = (alloc_func)0;
    stream.zfree = (free_func)0;
	int BufInc = (InBytes + 0xff) & (!0xff);
	*OutBytes = (OutEstimate==0) ? BufInc : OutEstimate;
	*OutBuf = new char[*OutBytes];
	
	stream.next_in = (Bytef*)InBuf;
	stream.avail_in = InBytes;
	stream.next_out = (Bytef*)*OutBuf;
	stream.avail_out = *OutBytes;
	if (inflateInit(&stream) != 0)
	{
		*OutBytes = 0;
		return;
	}
	while (inflate(&stream, Z_NO_FLUSH) != Z_STREAM_END)
	{
		char *P = *OutBuf;
		*OutBytes += BufInc;
		*OutBuf = (char*)realloc(*OutBuf, *OutBytes);
		stream.next_out = (Bytef*)(OutBuf + ((char*)stream.next_out - P));
		stream.avail_out = BufInc;
	}
	inflateEnd(&stream);
	*OutBuf = (char*)realloc(*OutBuf, stream.total_out);
	*OutBytes = stream.total_out;
}

void CompressBuf(char *InBuf, int InBytes, char **OutBuf, int *OutBytes)
{
	z_stream stream;
	memset(&stream, 0, sizeof(z_stream));
	stream.zalloc = (alloc_func)0;
    stream.zfree = (free_func)0;
	*OutBytes = ((InBytes + (InBytes / 10) + 12) + 255);// & (!255);
	*OutBuf = new char[*OutBytes];
	
	stream.next_in = (Bytef*)InBuf;
	stream.avail_in = InBytes;
	stream.next_out = (Bytef*)*OutBuf;
	stream.avail_out = *OutBytes;

	if (deflateInit(&stream, Z_BEST_COMPRESSION) != 0)
	{
		*OutBytes = 0;
		return;
	}
	while (deflate(&stream, Z_FINISH) != Z_STREAM_END)
	{
		char *P = *OutBuf;
		*OutBytes += 256;
		//*OutBuf = (char*)realloc(*OutBuf, *OutBytes);
		stream.next_out = (Bytef*)(OutBuf + ((char*)stream.next_out - P));
		stream.avail_out = 256;
	}
	deflateEnd(&stream);
	*OutBuf = (char*)realloc(*OutBuf, stream.total_out);
	*OutBytes = stream.total_out;
}

CPKGFile::CPKGFile()
{
	fFiles = NULL;
	stream = NULL;
}

CPKGFile::CPKGFile(char *filename)
{
	fFileName = filename;
	stream = new CStream(fFileName, false);
	if (stream->GetHandle() == INVALID_HANDLE_VALUE)
		return;
	stream->Seek(stream->GetSize()-sizeof(TPKGHeader), USE_SEEK_BEGINNING);
	stream->Read(&fHeader, sizeof(TPKGHeader));
	stream->Seek(stream->GetSize()-sizeof(TPKGHeader), USE_SEEK_BEGINNING);

	UINT64 StartPos = stream->Position();
	fFiles = new TPKGFile[fHeader.FilesCount];
	if (fHeader.FilesCount > 0)
		for (int i=0 ; i<fHeader.FilesCount ; i++)
		{
			stream->Seek(StartPos-sizeof(TPKGFileHeader), USE_SEEK_BEGINNING);
			stream->Read(&fFiles[i].Header, sizeof(TPKGFileHeader));
			stream->Seek(StartPos-sizeof(TPKGFileHeader)-fFiles[i].Header.FileNameLen, USE_SEEK_BEGINNING);
			fFiles[i].FileName = new char[fFiles[i].Header.FileNameLen];
			stream->Read(fFiles[i].FileName, fFiles[i].Header.FileNameLen);

			StartPos -= sizeof(TPKGFileHeader) + fFiles[i].Header.FileNameLen;
		}

	if (fHeader.FilesCount > 0)
	{
		char FN[100];
		sprintf_s(FN, 100, "%s.mst", fFileName);
		CStream *str = new CStream(FN, true);
		for (int i=0 ; i<fHeader.FilesCount ; i++)
		{
			str->Write(fFiles[i].FileName, fFiles[i].Header.FileNameLen-1);
			str->Write("\x0d\x0a", 2);
		}
		delete str;
	}
}

CPKGFile::~CPKGFile()
{
	delete fFiles;
	delete stream;
}

void CPKGFile::Extract(char *DstDir)
{
	char *chunk = new char[CHUNK_SIZE];
	for (int i=0 ; i<fHeader.FilesCount ; i++)
	{
		char FN[MAX_PATH],
			*ChuncUnc;
		sprintf_s(FN, MAX_PATH, "%s%s", DstDir, fFiles[i].FileName);
		ForceDirectories(ExtractFilePath(FN));
		CStream *str = new CStream(FN, true);
		if (str->GetHandle() == INVALID_HANDLE_VALUE)
			continue;

		INT32 PackedSize = fFiles[i].Header.PackedSize;
		if (PackedSize > 0)
		{
			stream->Seek(fFiles[i].Header.FileStart, USE_SEEK_BEGINNING);
			while (PackedSize > 0)
			{
				INT32 ComprSize,
					UnpackedSize;
				stream->Read(&ComprSize, 4);
				stream->Read(chunk, ComprSize);
				DecompressBuf(chunk, fFiles[i].Header.UnpackedSize, CHUNK_SIZE, &ChuncUnc, &UnpackedSize);
				str->Write(ChuncUnc, UnpackedSize);
				PackedSize -= ComprSize;
				delete ChuncUnc;
			}
		}
		delete str;
	}
	delete chunk;
}

bool CPKGFile::Pack(char *InpDir, char *OutFileName, char *MSTFile)
{
	char buf[256];
	fHeader.Version = 0;
	fHeader.CompLevel = 9;
	fHeader.FilesCount = 0;

	FILE *f;
	fopen_s(&f, MSTFile, "rt");
	while (!feof(f))
	{
		buf[0] = '\x00';
		fscanf(f, "%s", buf);
		if (buf[0] == '\x00')
			continue;
		fHeader.FilesCount++;
	}
	int i=0;
	fseek(f, 0, SEEK_SET);
	fFiles = new TPKGFile[fHeader.FilesCount];
	while (!feof(f))
	{
		fscanf(f, "%s", buf);
		if (buf == "")
			continue;
		fFiles[i].Header.FileNameLen = strlen(buf)+1;
		fFiles[i].FileName = CopyStr(buf, fFiles[i].Header.FileNameLen-1);
		i++;
	}
	fclose(f);

	fseek(f, 0, SEEK_SET);
	stream = new CStream(OutFileName, true);
	char UncomprChunk[CHUNK_SIZE],
		*ComprChunk;
	for (i=0 ; i<fHeader.FilesCount ; i++)
	{
		CStream *str = new CStream(MakeStr(InpDir, fFiles[i].FileName), false);
		fFiles[i].Header.UnpackedSize = (UINT32)str->GetSize();
		fFiles[i].Header.FileStart = (UINT32)stream->Position();

		INT32 Compressed = 0,
			TotalCompressedSize = 0,
			CompressedSize;
		while (Compressed < fFiles[i].Header.UnpackedSize)
		{
			UINT32 ReadSize = (UINT32)str->Read(UncomprChunk, CHUNK_SIZE);
			CompressedSize = CHUNK_SIZE;
			CompressBuf(UncomprChunk, ReadSize, &ComprChunk, &CompressedSize);
			stream->Write(&CompressedSize, 4);
			stream->Write(ComprChunk, CompressedSize);
			TotalCompressedSize += CompressedSize;
			Compressed += ReadSize;
			delete ComprChunk;
		}
		fFiles[i].Header.PackedSize = TotalCompressedSize;
		delete str;
	}

	for (i=0 ; i<fHeader.FilesCount ; i++)
	{
		stream->Write(fFiles[i].FileName, fFiles[i].Header.FileNameLen);
		stream->Write(&fFiles[i].Header, sizeof(TPKGFileHeader));
	}
	stream->Write(&fHeader, sizeof(TPKGHeader));
	//delete stream;
	return true;
}