#include "stdafx.h"
#include "../Config.h"
#include "Server_Steam.h"
#include "Server_ContentList.h"

int PKGServersCount;
TServerItem *PKGServers;

CContentListServer::CContentListServer(int Port)
{
	// init
	PKGServersCount = GetConfigInt("PKGServers", "Count");
	PKGServers = new TServerItem[PKGServersCount];
	if (PKGServersCount > 0)
		for (int i=0 ; i<PKGServersCount ; i++)
		{
			char *Addr = GetConfigStr("PKGServers", "Server", i+1);
			int b1, b2, b3, b4;
			sscanf_s(Addr, "%i.%i.%i.%i:%i", &b1, &b2, &b3, &b4, &PKGServers[i].ClientUpdatePort);
			PKGServers[i].ClientUpdateIP = (b4<<24) + (b3<<16) + (b2<<8) + b1;

			PKGServers[i].ID = 0;
			PKGServers[i].ContentServerIP = PKGServers[i].ClientUpdateIP;
			PKGServers[i].ContentServerPort = PKGServers[i].ClientUpdatePort;
			delete Addr;
		}

	fServer = new CSteamServer(Port, "CL", ContentListServerProc);
}

CContentListServer::~CContentListServer()
{
	delete fServer;
	delete PKGServers;
}

struct TServerQueryHeader
{
	UINT32 AppID;
	UINT32 Version;
	UINT16 NumServers;
	UINT32 Region;
	UINT64 unk;
};

void ContentListServerProc(void *Param)
{
	TClient *Client = (TClient*)Param;
	Csocket *Socket = Client->Socket;
	char *ClientAddr = Socket->GetAddr();
#ifdef LOG
	Log(Client->ServerName, "Accepted client %s", ClientAddr);
#endif

	UINT32 Family;
	Socket->RecvInt32(&Family, true);
	if (Family != QUERY_CONTENT_LIST_SERVER)
	{
		#ifdef LOG
		Log(Client->ServerName, "Client %s sended unknown family - %h", ClientAddr, Family);
		#endif
		Socket->Send("\x00", 1);
		delete Socket;
		return;
	}
	Socket->Send("\x01", 1);

	UINT32 Size,
		ReplySize;
	UINT16 CommandEx,
		SendedCount;
	Socket->RecvInt32(&Size, true);
	char Command,
		*Data;
	Socket->Recv(&Command, 1);
	if (Size > 1)
	{
		Data = new char[Size-1];
		Socket->Recv(Data, Size-1);
	}

	TServerQueryHeader Header;
	switch (Command)
	{
	case ACTION_GET_CONTENT_SERVERS:
		//Socket->RecvInt16(&CommandEx);
		CommandEx = *((UINT16*)Data);
		Header.unk = 0;
		memcpy(&Header, Data+2, Size-1);
		printf("Header: AppID=%i\x09Version=%i\x09Region=%i\x09unk=%i\n", Header.AppID, Header.Version, Header.NumServers, Header.Region, Header.unk);
		// region = 0x57
		switch (CommandEx)
		{
		case ACTION_GET_OUT_CONTENT_SERVERS:
			#ifdef LOG
			Log(Client->ServerName, "Client %s - Sending out content servers (Which have the initial packages)", ClientAddr);
			#endif

			SendedCount = min(PKGServersCount, Header.NumServers);
			ReplySize = 2 + SendedCount * 16;
			Socket->SendInt32(ReplySize, true);
			Socket->SendInt16(SendedCount, true);
			Socket->Send((char*)PKGServers, SendedCount*16);
			break;
		case ACTION_GET_CONTENT_SERVERS_BY_APPID:
			#ifdef LOG
			Log(Client->ServerName, "Client %s - Sending out content servers for app:%i ver:%i num:%i region:%h unk:%h", ClientAddr, Header.AppID, Header.Version, Header.NumServers, Header.Region, Header.unk);
			#endif

			// fix to normal content servers list
			SendedCount = min(PKGServersCount, Header.NumServers);
			ReplySize = 2 + SendedCount * 16;
			Socket->SendInt32(ReplySize, true);
			Socket->SendInt16(SendedCount, true);
			Socket->Send((char*)PKGServers, SendedCount*16);
			break;
		}
		break;
	case ACTION_GET_OUT_CONTENT_SERVERS_EX:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out content servers (Which have the initial packages)", ClientAddr);
		#endif

		SendedCount = PKGServersCount;
		ReplySize = 2 + SendedCount * 6;
		Socket->SendInt32(ReplySize, true);
		Socket->SendInt16(SendedCount, true);
		for (int i=0 ; i<SendedCount ; i++)
			Socket->Send((char*)&PKGServers[i].ClientUpdateIP, SendedCount*6);
		break;
	}
	if (Size > 1)
		delete Data;

	delete Socket;
	#ifdef LOG
	Log(Client->ServerName, "Client %s disconnected", ClientAddr);
	#endif
	Client->Socket = NULL;
}