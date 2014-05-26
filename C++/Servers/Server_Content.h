#pragma pack (push, 1)
#pragma pack (pop)

class CContentServer
{
private:
	CSteamServer *fServer;
public:
	CContentServer(int Port);
	~CContentServer();
};

void ContentServerProc(void *Param);