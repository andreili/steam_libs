#include "stdafx.h"
#include "Stream.h"
#include "StreamsProc.h"

CStream::CStream(char *FileName, bool IsWrite)
{
	StreamData *Data = new StreamData();
	memset(Data, 0, sizeof(StreamData));
	Data->Handle = INVALID_HANDLE_VALUE;
	if (IsWrite)
		Data->Handle = CreateFileA(FileName, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	else
		Data->Handle = CreateFileA(FileName, GENERIC_READ, FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (Data->Handle == INVALID_HANDLE_VALUE)
	{
		delete Data;
		return;
	}
	this->Data = Data;
	this->Methods = new StreamMethods();
	this->Methods->Close = CloseFileStream;
	this->Methods->Read = ReadFileStream;
	this->Methods->Write = WriteFileStream;
	this->Methods->GetSize = GetSizeFileStream;
	this->Methods->SetSize = SetSizeFileStream;
	this->Methods->Seek = SeekFileStream;
}

CStream::CStream(UINT64 uiSize)
{
	StreamData *Data = new StreamData();
	memset(Data, 0, sizeof(StreamData));
	Data->Handle = INVALID_HANDLE_VALUE;

	
	this->Data = Data;
	this->Methods = new StreamMethods();
	this->Methods->Close = CloseMemoryStream;
	this->Methods->Read = ReadMemoryStream;
	this->Methods->Write = WriteMemoryStream;
	this->Methods->GetSize = GetSizeMemoryStream;
	this->Methods->SetSize = SetSizeMemoryStream;
	this->Methods->Seek = SeekMemoryStream;
}

CStream::CStream(char *mem, UINT64 uiSize)
{
	StreamData *Data = new StreamData();
	memset(Data, 0, sizeof(StreamData));
	Data->Handle = INVALID_HANDLE_VALUE;
	Data->Memory = (UINT8*)mem;
	Data->Size = uiSize;

	
	this->Data = Data;
	this->Methods = new StreamMethods();
	this->Methods->Close = CloseMemoryStream;
	this->Methods->Read = ReadMemoryStream;
	this->Methods->Write = WriteMemoryStream;
	this->Methods->GetSize = GetSizeMemoryStream;
	this->Methods->SetSize = SetSizeMemoryStream;
	this->Methods->Seek = SeekMemoryStream;
}