#pragma pack (push, 1)
struct TServerItem
{
	UINT32 ID;
	UINT32 ClientUpdateIP;
	UINT16 ClientUpdatePort;
	UINT32 ContentServerIP;
	UINT16 ContentServerPort;
};
#pragma pack (pop)

class CContentListServer
{
private:
	CSteamServer *fServer;
public:
	CContentListServer(int Port);
	~CContentListServer();
};

void ContentListServerProc(void *Param);