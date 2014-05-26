#include "stdafx.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
//						standart file stream's													 //
///////////////////////////////////////////////////////////////////////////////////////////////////

void CloseFileStream(StreamData *Data)
{
	CloseHandle(Data->Handle);
}

UINT64 ReadFileStream(StreamData *Data, void *lpData, UINT64 uiSize)
{
	UINT32 res;
	if (!ReadFile(Data->Handle, lpData, uiSize, (LPDWORD)&res, NULL))
		return 0;
	return res;
}

UINT64 WriteFileStream(StreamData *Data, void *lpData, UINT64 uiSize)
{
	UINT32 res;
	if (!WriteFile(Data->Handle, lpData, uiSize, (LPDWORD)&res, NULL))
		return 0;
	return res;
}

UINT64 SeekFileStream(StreamData *Data, INT64 uiPos, ESeekMode eSeekMode)
{
	LONG *lPos = (LONG*)&uiPos,
		lPos1 = *lPos,
		lPos2 = *(lPos+1);
	return SetFilePointer(Data->Handle, lPos1, &lPos2, (DWORD)eSeekMode);
}

UINT64 GetSizeFileStream(StreamData *Data)
{
	UINT32 res1[2];
	res1[0] = GetFileSize(Data->Handle, (LPDWORD)&res1[1]);
	return res1[0] + res1[1]*0xFFFFFFFF;
}

void SetSizeFileStream(StreamData *Data, UINT64 uiSize)
{
	UINT64 pos = SeekFileStream(Data, 0, USE_SEEK_CURRENT);
	SeekFileStream(Data, uiSize, USE_SEEK_BEGINNING);
	SetEndOfFile(Data->Handle);
	SeekFileStream(Data, pos, USE_SEEK_BEGINNING);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//								memory stream's													 //
///////////////////////////////////////////////////////////////////////////////////////////////////

void CloseMemoryStream(StreamData *Data)
{
	if (Data->Memory != NULL)
	{
		delete Data->Memory;
		Data->Memory = NULL;
	}
}

UINT64 GetSizeMemoryStream(StreamData *Data)
{
	return Data->Size;
}

void SetSizeMemoryStream(StreamData *Data, UINT64 uiSize)
{
	if (Data->Memory==NULL)
	{
		Data->Memory = new UINT8[uiSize];
	}
	else
	{
		realloc(Data->Memory, uiSize);
	}
	if (Data->Position > uiSize)
		Data->Position = uiSize;
	Data->Size = uiSize;
	if (uiSize==0)
	{
		delete Data->Memory;
		Data->Memory = NULL;
	}
}

UINT64 SeekMemoryStream(StreamData *Data, INT64 uiPos, ESeekMode eSeekMode)
{
	UINT64 NewPos;
	switch (eSeekMode)
	{
	case USE_SEEK_BEGINNING: 
		NewPos = uiPos;
		break;
	case USE_SEEK_CURRENT: 
		NewPos = Data->Position + uiPos;
		break;
	case USE_SEEK_END: 
		NewPos = Data->Size + uiPos;
		break;
	}
	if (NewPos>Data->Size)
		SetSizeMemoryStream(Data, NewPos);
	Data->Position = NewPos;
	return NewPos;
}

UINT64 ReadMemoryStream(StreamData *Data, void *lpData, UINT64 uiSize)
{
	if (uiSize + Data->Position > Data->Size)
		uiSize = Data->Size - Data->Position;
	memcpy(lpData, &Data->Memory+Data->Position, uiSize);
	return uiSize;
}

UINT64 WriteMemoryStream(StreamData *Data, void *lpData, UINT64 uiSize)
{
	if (uiSize + Data->Position > Data->Size)
		uiSize = Data->Size - Data->Position;
	memcpy(&Data->Memory+Data->Position, lpData, uiSize);
	return uiSize;
}