typedef void (*Stream_Close) (StreamData *Data);
typedef UINT64 (*Stream_Read) (StreamData *Data, void *lpData, UINT64 uiSize);
typedef UINT64 (*Stream_Write) (StreamData *Data, void *lpData, UINT64 uiSize);
typedef UINT64 (*Stream_GetSize) (StreamData *Data);
typedef void (*Stream_SetSize) (StreamData *Data, UINT64 uiSize);
typedef UINT64 (*Stream_Seek) (StreamData *Data, INT64 uiPos, ESeekMode eSeekMode);

struct StreamMethods
{
	Stream_Close Close;
	Stream_Read Read;
	Stream_Write Write;
	Stream_Seek Seek;
	Stream_GetSize GetSize;
	Stream_SetSize SetSize;
};

class CStream
{
private:
	StreamMethods *Methods;
	StreamData *Data;
public:
	// package stream
	CStream(StreamMethods *Stream_Methods, StreamData *Stream_Data)
	{
		this->Methods = Stream_Methods;
		this->Data = Stream_Data;
	}
	// file stream
	CStream(char *FileName, bool IsWrite = false);
	// memory stream
	CStream(UINT64 uiSize);
	CStream(char *mem, UINT64 uiSize);

	~CStream()
	{
		Close();
	}
	void Close()
	{
		this->Methods->Close(this->Data);
	}
	UINT64 Read(void *lpData, UINT64 uiSize)
	{
		return this->Methods->Read(this->Data, lpData, uiSize);
	}
	UINT64 Write(void *lpData, UINT64 uiSize)
	{
		return this->Methods->Write(this->Data, lpData, uiSize);
	}
	UINT64 Seek(INT64 uiPos, ESeekMode eSeekMode)
	{
		return this->Methods->Seek(this->Data, uiPos, eSeekMode);
	}
	UINT64 GetSize()
	{
		return this->Methods->GetSize(Data);
	}
	void SetSize(UINT64 uiSize)
	{
		this->Methods->SetSize(Data, uiSize);
	}
	UINT64 Position()
	{
		return Seek(0, USE_SEEK_CURRENT);
	}
		handle_t GetHandle()
	{
		return Data->Handle;
	}
	void *GetMemory()
	{
		return Data->Memory;
	}
};