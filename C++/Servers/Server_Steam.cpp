#include "stdafx.h"
#include "Server_Steam.h"

CSteamServer::CSteamServer(int Port, char *Name, TOnUserConnected ServerProc)
{
	fStop = false;
	fServerName = Name;
    memset(fClients, 0, sizeof(TClient)*MAX_CLIENTS);
	fSocket = new Csocket(eSocketProtocolTCP);
	if ((fSocket->BindPort(Port) == SOCKET_ERROR) || (!fSocket->ListenServer()))
	{
		this->~CSteamServer();
		return;
	}
	fOnUser = ServerProc;
	_beginthread(ThreadProcEx, 0, this);
#ifdef LOG
	Log(fServerName, "Binded on port %i", Port);
#endif
}

CSteamServer::~CSteamServer()
{
#ifdef LOG
	Log(fServerName, "Stopped");
#endif
	fStop = true;
	delete fSocket;
	//fThread
	fSocket = NULL;
	for (int i=0 ; i<MAX_CLIENTS ; i++)
		if (fClients[i].Socket != NULL)
		{
			delete fClients[i].Socket;
			fClients[i].Socket = NULL;
		}
}

void ThreadProcEx(void *Param)
{
	((CSteamServer*)Param)->ThreadProc();
}

void CSteamServer::ThreadProc()
{
	fSocket->SetTimeOut(1000);
	while (!fStop)
	{
		Csocket *Client = fSocket->AcceptConnect();
		if (Client != NULL) 
			OnClientConnected(Client);
	}
}

void CSteamServer::OnClientConnected(Csocket *Socket)
{
	bool free = false;
	while (!free)
	{
		for (int i=0 ; i<MAX_CLIENTS ; i++)
			if (fClients[i].Socket == NULL)
			{
				Socket->SetTimeOut(1000);
				fClients[i].Socket = Socket;
				fClients[i].ServerName = fServerName;
				fClients[i].ClientIdx = i;
				fClients[i].OnUser = fOnUser;
				fClients[i].Thread = _beginthread(fOnUser, 0, &fClients[i]);
				free = true;
				break;
			}
		if (!free)
			Sleep(100);
	}
}