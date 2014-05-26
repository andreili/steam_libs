#include "stdafx.h"
#include "../Config.h"
#include "Server_Steam.h"
#include "Server_MasterDirectory.h"

TServerAddr *Servers[9];
int ServersCount[9];

void LoadServerList(char *SectionName, int ListIdx)
{
	int Count = GetConfigInt(SectionName, "Count");

	if (Count>0)
	{
		ServersCount[ListIdx] = Count;
		Servers[ListIdx] = new TServerAddr[Count];
		for (int i=0 ; i<Count ; i++)
		{
			char *Addr = GetConfigStr(SectionName, "Server", i+1);
			int b1, b2, b3, b4;
			sscanf_s(Addr, "%i.%i.%i.%u:%i", &b1, &b2, &b3, &b4, &Servers[ListIdx][i].Port);
			Servers[ListIdx][i].IP = (b4<<24) + (b3<<16) + (b2<<8) + b1;
			delete Addr;
		}
	}
}

CMDS::CMDS(int Port)
{
	// init
	LoadServerList("Config", SERVER_CONFIG);
	LoadServerList("Auth", SERVER_AUTH);
	LoadServerList("CList", SERVER_CONTENT_LIST);	
	LoadServerList("CSER", SERVER_CSER);
	//LoadServerList("", SERVER_MS_HL1);
	//LoadServerList("", SERVER_MS_HL2);
	//LoadServerList("", SERVER_MS_RDKF);

	fServer = new CSteamServer(Port, "MDS", MasterDirectoryServerProc);
}

CMDS::~CMDS()
{
	delete fServer;
}

void MasterDirectoryServerProc(void *Param)
{
	TClient *Client = (TClient*)Param;
	Csocket *Socket = Client->Socket;
	char *ClientAddr = Socket->GetAddr();
#ifdef LOG
	Log(Client->ServerName, "Accepted client %s", ClientAddr);
#endif

	UINT32 Family;
	Socket->RecvInt32(&Family, true);
	if (Family != QUERY_GENERAL_SERVER)
	{
		#ifdef LOG
		Log(Client->ServerName, "Client %s sended unknown family - %h", ClientAddr, Family);
		#endif
		Socket->Send("\x00", 1);
		delete Socket;
		return;
	}
	Socket->Send("\x01", 1);

	UINT32 Size, ListIdx;
	Socket->RecvInt32(&Size, true);
	char Command,
		*Data;
	Socket->Recv(&Command, 1);
	if (Size > 1)
	{
		Data = new char[Size-1];
		Socket->Recv(Data, Size-1);
	}
	switch (Command)
	{
	case ACTION_GET_AUTH_SERVERS_LIST:
	case ACTION_GET_AUTH_SERVERS_LIST_1:
	case ACTION_GET_AUTH_SERVERS_LIST_2:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list auth servers", ClientAddr);
		#endif
		ListIdx = SERVER_AUTH;
		break;
	case ACTION_GET_CONFIG_SERVERS_LIST:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list config servers", ClientAddr);
		#endif
		ListIdx = SERVER_CONFIG;
		break;
	case ACTION_GET_CONTENT_LIST_SERVER_LIST:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list content lists servers", ClientAddr);
		#endif
		ListIdx = SERVER_CONTENT_LIST;
		break;
	case ACTION_GET_CSER_SERVERS_LIST:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list CSER servers", ClientAddr);
		#endif
		ListIdx = SERVER_CSER;
		break;
	/*case ACTION_GET_MASTER_SERVERS_LIST_HL1:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list of HL1 Master servers", ClientAddr);
		#endif
		ListIdx = SERVER_MS_HL1;
		break;
	case ACTION_GET_MASTER_SERVERS_LIST_HL2:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list of HL2 Master servers", ClientAddr);
		#endif
		ListIdx = SERVER_MS_HL2;
		break;
	case ACTION_GET_MASTER_SERVERS_LIST_RDKF:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending out list of RDKF Master servers", ClientAddr);
		#endif
		ListIdx = SERVER_MS_RDKF;
		break;*/
	default:
		#ifdef LOG
		Log(Client->ServerName, "Client %s sended unknown command - %1h", ClientAddr, Command);
		#endif
		break;
	}
	if (Size > 1)
		delete Data;
	
	// making reply packet
	UINT16 Count = ServersCount[ListIdx];
	#ifdef LOG
	Log(Client->ServerName, "Sended to %s %i server items", ClientAddr, Count);
	#endif
	Size = Count*sizeof(TServerAddr)+2;
	Socket->SendInt32(Size, true);
	Socket->SendInt16(Count, true);
	if (Count > 0)
		Socket->Send((char*)&Servers[ListIdx][0], Size);

	delete Socket;
	#ifdef LOG
	Log(Client->ServerName, "Client %s disconnected", ClientAddr);
	#endif
	Client->Socket = NULL;
}