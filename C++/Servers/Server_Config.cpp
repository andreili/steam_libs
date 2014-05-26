#include "stdafx.h"
#include "../Config.h"
#include "Server_Config.h"
#include "Server_Steam.h"
#include "../FileFormats/BLOBFile.h"
#include "../RSAMod.h"
#include "../Stream.h"

char *NKHeader = "\x30\x81\x9d\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01\x05\x00\x03\x81\x8b\x00\x30\x81\x87\x02\x81\x81\x00";
int NKHeaderLen = 29;

CConfigServer::CConfigServer(int Port)
{
	// init
	//...
	/*CBLOBFile *blob = new CBLOBFile(GetConfigStr("Config", "CDR"));
	blob->SaveToFile(".\\files\\cdr.unc", false);

	// replacing network key
	char *NK = GetNetworkKey(),
		key[138];
	UINT32 Size = NKHeaderLen+128+3;
	memcpy(key, NKHeader, NKHeaderLen);
	memcpy(key+NKHeaderLen, NK, 128);
	memcpy(key+NKHeaderLen+128, "\x02\x01\x11", 3);
	CBLOBNode *Node = blob->RootNode()->GetNodeByIdx(0x00000005);
	for (UINT32 i=0 ; i<Node->ChildrensCount() ; i++)
	{
		Node->Childrens(i)->SetData(key, Size);
	}
	blob->SaveToFile(".\\files\\cdr_new.unc", false);

	delete blob;*/

	fServer = new CSteamServer(Port, "CfS", ConfigServerProc);
}

CConfigServer::~CConfigServer()
{
	delete fServer;
}

void ConfigServerProc(void *Param)
{
	TClient *Client = (TClient*)Param;
	Csocket *Socket = Client->Socket;
	char *ClientAddr = Socket->GetAddr();
#ifdef LOG
	Log(Client->ServerName, "Accepted client %s", ClientAddr);
#endif

	UINT32 Family;
	Socket->RecvInt32(&Family, true);
	if (Family != QUERY_CONFIG_SERVER)
	{
		#ifdef LOG
		Log(Client->ServerName, "Client %s sended unknown family - %h", ClientAddr, Family);
		#endif
		Socket->Send("\x00", 1);
		delete Socket;
		return;
	}
	Socket->Send("\x01", 1);
	Socket->SendInt32(Socket->GetIP());

	UINT32 Size,
		ReplySize = 0,
		SteamVersion = GetConfigInt("Config", "Steam"),
		SteamUIVersion = GetConfigInt("Config", "SteamUI");
	UINT16 size;
	Socket->RecvInt32(&Size, true);
	char Command,
		*Data,
		*NK,
		*sign,
		*reply = NULL;

	Socket->Recv(&Command, 1);
	if (Size > 1)
	{
		Data = new char[Size-1];
		Socket->Recv(Data, Size-1);
	}
	CBLOBFile *blob;
	CBLOBNode *rootNode;
	CStream *str;
	switch (Command)
	{
	case ACTION_GET_VERSIONS_BLOB:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending Versions Blob", ClientAddr);
		#endif

		blob = new CBLOBFile();
		rootNode = blob->RootNode();
		rootNode->AddString("\x00\x00\x00\x00", 4, "\x00\x00\x00\x00", 4);
		rootNode->AddData("\x01\x00\x00\x00", 4, (char*)&SteamVersion, 4);
		rootNode->AddData("\x02\x00\x00\x00", 4, (char*)&SteamUIVersion, 4);
		rootNode->AddString("\x03\x00\x00\x00", 4, "\x00\x00\x00\x00", 4);
		rootNode->AddString("\x04\x00\x00\x00", 4, "\x14\x00\x00\x00", 4);
		rootNode->AddString("\x05\x00\x00\x00", 4, "\x17\x00\x00\x00", 4);
		rootNode->AddString("\x06\x00\x00\x00", 4, "\x0e\x00\x00\x00", 4);
		rootNode->AddString("\x07\x00\x00\x00", 4, "boo\x00", 4);
		//rootNode->AddString("\x08\x00\x00\x00", 4, "\x5c\x01\x00\x00", 4);
		rootNode->AddString("\x09\x00\x00\x00", 4, "foo\x00", 4);
		rootNode->AddString("\x0a\x00\x00\x00", 4, "\x11\x00\x00\x00", 4);
		rootNode->AddString("\x0b\x00\x00\x00", 4, "bar\x00", 4);
		rootNode->AddString("\x0c\x00\x00\x00", 4, "\x12\x00\x00\x00", 4);
		rootNode->AddString("\x0d\x00\x00\x00", 4, "foo\x00", 4);
		rootNode->AddString("\x0e\x00\x00\x00", 4, "", 0);
		rootNode->AddString("\x0f\x00\x00\x00", 4, "\x50\x01\x00\x00", 4);
		ReplySize = blob->SaveToMem(&reply, false);
		delete blob;

		Socket->SendInt32(ReplySize, true);
		Socket->Send(reply, ReplySize);
		break;
	case ACTION_GET_CDR:
	case ACTION_UPDATE_CDR:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending CDR", ClientAddr);
		#endif

		if (Command == ACTION_UPDATE_CDR)
		{
			Socket->Send("\x00\x00\x00\x01\x31\x2d\x00\x00\x00\x01\x2c", 11);
			// check checksum
			// ...
		}

		str = new CStream(GetConfigStr("Config", "CDR"), false);
		ReplySize = (UINT32)str->GetSize();
		reply = new char[ReplySize];
		str->Read(reply, ReplySize);
		delete str;

		Socket->SendInt32(ReplySize, true);
		Socket->Send(reply, ReplySize);
		delete reply;
		break;
	case ACTION_GET_NETWORK_KEY:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Sending Network Key", ClientAddr);
		#endif
		// Network Key
		size = NKHeaderLen+NetworkKey_l+3;
		reply = new char[size];
		memcpy(reply, NKHeader, NKHeaderLen);
		NK = GetNetworkKey();
		memcpy(reply+29, NK, NetworkKey_l);
		delete NK;
		memcpy(reply+29+NetworkKey_l, "\x02\x01\x11", 3);
		Socket->SendInt16(size, true);
		Socket->Send(reply, size);

		// signature
		sign = RSASign(MainKeySign, reply, size, 256);
		Socket->SendInt16(256, true);
		Socket->Send(sign, 256);

		delete sign;
		delete reply;
		break;
	case ACTION_GET_UNKNOWN1:
	case ACTION_GET_UNKNOWN2:
	case ACTION_GET_UNKNOWN4:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Unknown command %h, sending zero reply", ClientAddr, Command);
		#endif
		Socket->Send("\x00", 1);
		break;
	case ACTION_GET_UNKNOWN3:
		#ifdef LOG
		Log(Client->ServerName, "Client %s - Unknown command %h, sending recorded reply", ClientAddr, Command);
		#endif
		Socket->Send("\x00\x01\x31\x2d\x00\x00\x00\x01\x2c", 9);
		break;
	default:
		#ifdef LOG
		Log(Client->ServerName, "Client %s sended unknown command - %1h", ClientAddr, Command);
		#endif
		Socket->Send("\x00", 1);
		break;
	}
	if (Size > 1)
	{
		delete Data;
		Data = NULL;
	}

	delete Socket;
	#ifdef LOG
	Log(Client->ServerName, "Client %s disconnected", ClientAddr);
	#endif
	Client->Socket = NULL;
}