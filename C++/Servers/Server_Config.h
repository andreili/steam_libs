class CConfigServer
{
private:
	CSteamServer *fServer;
public:
	CConfigServer(int Port);
	~CConfigServer();
};

void ConfigServerProc(void *Param);