#include "stdafx.h"
#include "../Config.h"
#include "Server_Content.h"
#include "Server_Steam.h"
#include "../FileFormats/GCFFile.h"
#include "../FileFormats/functions.h"
#include "../RSAMod.h"
#include "../Stream.h"

CContentServer::CContentServer(int Port)
{
	// init
	// ...

	fServer = new CSteamServer(Port, "CS", ContentServerProc);
}

CContentServer::~CContentServer()
{
	delete fServer;
}

void ContentServerProc(void *Param)
{
	TClient *Client = (TClient*)Param;
	Csocket *Socket = Client->Socket;
	char *ClientAddr = Socket->GetAddr();
#ifdef LOG
	Log(Client->ServerName, "Accepted client %s", ClientAddr);
#endif

	//Sleep(1000);
	UINT32 Family;
	Socket->RecvInt32(&Family, true);

	UINT32 Size,
		CommandEx,
		FilenameLen,
		ReplySize,
		PartSize;
	char Command,
		*Data,
		*filename,
		*FN,
		*Reply;
	CStream *str;

	switch (Family)
	{
	case QUERY_CONTENT_SERVER_PACKAGE_MODE:
		Socket->Send("\x01", 1);
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Package mode entered", ClientAddr);
		#endif

		while (true)
		{
			Socket->RecvInt32(&Size, true);
			Socket->RecvInt32(&CommandEx, true);
			if (Size > 4)
			{
				Data = new char[Size-4];
				Socket->Recv(Data, Size-4);
			}

			if (CommandEx == ACTION_DUMMY0)
			{
				Socket->Send("\x00\x00\x00\x02", 4);
				break;
			}
			else if (CommandEx == ACTION_DUMMY1)
			{
				break;
			}
			else if (CommandEx == ACTION_GET_PACKAGE)
			{
				FilenameLen = htonl(*((UINT32*)Data+1));
				if (FilenameLen > MAX_PATH)
					break;
				filename = CopyStr(Data+8, FilenameLen);
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Sending file: %s", ClientAddr, filename);
				#endif

				FN = MakeStr(GetConfigStr("Servers", "filesPath"), filename);
				if (strcmp(filename+(strlen(filename)-14), "_rsa_signature") != 0)
				{
					delete (RSASignFile(NetworkKeySign, FN));
				}

				str = new CStream(FN, false);
				ReplySize = (UINT32)str->GetSize();
				Socket->SendInt32(ReplySize, true);
				Socket->SendInt32(ReplySize, true);
				Reply = new char[ReplySize];
				PartSize = (UINT32)str->Read(Reply, ReplySize);
				delete str;
				Socket->Send(Reply, PartSize);
				delete Reply;
			}
		}

		break;
	case QUERY_CONTENT_SERVER_STORAGE_MODE:
		Socket->Send("\x01", 1);
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Storage mode entered", ClientAddr);
		#endif

		while (true)
		{
			Socket->RecvInt32(&Size, true);
			Socket->Recv(&Command, 1);
			if (Size > 1)
			{
				Data = new char[Size-1];
				Socket->Recv(Data, Size-1);
			}

			if (Command == ACTION_GET_CDR_)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Sending CDR", ClientAddr);
				#endif

				str = new CStream(GetConfigStr("Config", "CDR"), false);
				ReplySize = (UINT32)str->GetSize();
				Reply = new char[ReplySize];
				str->Read(Reply, ReplySize);
				delete str;

				Socket->SendInt32(ReplySize, true);
				Socket->Send(Reply, ReplySize);
				delete Reply;

				break;
			}
			else if (Command == ACTION_GET_URL)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Send banner URL", ClientAddr);
				#endif
			}
			else if (Command == ACTION_GET_DUMMY)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Send NULL", ClientAddr);
				#endif
				break;
			}
			else if (Command == ACTION_OPEN_CACHE)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Open cache", ClientAddr);
				#endif
			}
			else if (Command == ACTION_OPEN_CACHE_EX)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Open cache from account", ClientAddr);
				#endif
			}
			else if (Command == ACTION_GET_MANIFEST)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Get manifest", ClientAddr);
				#endif
			}
			else if (Command == ACTION_GET_CHECKSUMS)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Get checksums", ClientAddr);
				#endif
			}
			else if (Command == ACTION_GET_LIST_UPDATE_FILES)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Get list update files", ClientAddr);
				#endif
			}
			else if (Command == ACTION_GET_FILE)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Get file", ClientAddr);
				#endif
			}
			else if (Command == ACTION_CLOSE_CACHE)
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Close cache", ClientAddr);
				#endif
			}
			else
			{
				#ifdef LOG
				Log(Client->ServerName, "Client %s - Uncknow command: %h", ClientAddr, Command);
				#endif
			}
		}

		break;
	case 0xcccccccc:
		Socket->Send("\x00", 1);
		delete Socket;
		return;
		break;
	default:
		#ifdef LOG
		Log(Client->ServerName, "Client %s sended unknown family - %i", ClientAddr, Family);
		#endif
		Socket->Send("\x00", 1);
		delete Socket;
		return;
		break;
	}

	delete Socket;
	#ifdef LOG
	Log(Client->ServerName, "Client %s disconnected", ClientAddr);
	#endif
	Client->Socket = NULL;
}