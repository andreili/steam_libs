class CMDS
{
private:
	CSteamServer *fServer;
public:
	CMDS(int Port);
	~CMDS();
};

void MasterDirectoryServerProc(void *Param);