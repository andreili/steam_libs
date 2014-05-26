#include "..\stdafx.h"
#include <process.h>
#include "..\fire666\Csocket.h"

#define MAX_CLIENTS 1024

typedef void (*TOnUserConnected) (void *Client);

#pragma pack (push, 1)
struct TClient
{
    Csocket *Socket;
    char* ServerName;
    int ClientIdx;
	uintptr_t Thread;
	TOnUserConnected OnUser;
};

struct TServerAddr
{
	UINT32 IP;
	UINT16 Port;
};
#pragma pack (pop)

class CSteamServer
{
private:
	bool fStop;
	Csocket *fSocket;
	char* fServerName;
	uintptr_t fThread;
	TOnUserConnected fOnUser;
	TClient fClients[MAX_CLIENTS];
public:
	void __cdecl ThreadProc();
public:
	CSteamServer(int Port, char *Name, TOnUserConnected ServerProc);
    ~CSteamServer();

	void OnClientConnected(Csocket *Socket);
	//char *Name() { return fServerName; };
};

void ThreadProcEx(void *Param);

#define MAX_SERVER_BUFFER 1024

#define SERVER_GENERAL		1
#define SERVER_AUTH			2
#define SERVER_CONFIG		3
#define SERVER_CONTENT_LIST 4
#define SERVER_CSER			5
#define SERVER_MS_HL1		6
#define SERVER_MS_HL2		7
#define SERVER_MS_RDKF		8

#define QUERY_GENERAL_SERVER                 0x00000002UL
#define ACTION_GET_AUTH_SERVERS_LIST         0x00
#define ACTION_GET_AUTH_SERVERS_LIST_1       0x12
#define ACTION_GET_AUTH_SERVERS_LIST_2       0x1c
#define ACTION_GET_CONFIG_SERVERS_LIST       0x03
#define ACTION_GET_CONTENT_LIST_SERVER_LIST  0x06
#define ACTION_GET_CSER_SERVERS_LIST         0x14
#define ACTION_GET_MASTER_SERVERS_LIST_HL1   0x0f
#define ACTION_GET_MASTER_SERVERS_LIST_HL2   0x18
#define ACTION_GET_MASTER_SERVERS_LIST_RDKF  0x1e
//#define ACTION_SHUTDOWN                      0xf0

#define QUERY_CONFIG_SERVER                  0x00000003UL
#define ACTION_GET_VERSIONS_BLOB             0x01
#define ACTION_GET_CDR                       0x02
#define ACTION_GET_NETWORK_KEY               0x04
#define ACTION_GET_UNKNOWN1                  0x05
#define ACTION_GET_UNKNOWN2                  0x06
#define ACTION_GET_UNKNOWN3                  0x07
#define ACTION_GET_UNKNOWN4                  0x08
#define ACTION_UPDATE_CDR                    0x09
//#define ACTION_UPDATE_FILES                  0xf1

#define QUERY_CONTENT_LIST_SERVER            0x00000002UL
#define ACTION_GET_CONTENT_SERVERS           0x00
#define ACTION_GET_OUT_CONTENT_SERVERS       0x0000
#define ACTION_GET_CONTENT_SERVERS_BY_APPID  0x0001
#define ACTION_GET_OUT_CONTENT_SERVERS_EX    0x03
//#define ACTION_UPDATE_LISTS                  0xf2

#define QUERY_CONTENT_SERVER_PACKAGE_MODE	 0x00000003UL
#define ACTION_GET_PACKAGE                   0x00
#define ACTION_DUMMY0                        0x02
#define ACTION_DUMMY1                        0x03

#define QUERY_CONTENT_SERVER_STORAGE_MODE    0x00000007UL
#define ACTION_GET_URL                       0x00
#define ACTION_GET_DUMMY                     0x01
#define ACTION_GET_CDR_                      0x02
#define ACTION_CLOSE_CACHE                   0x03
#define ACTION_GET_MANIFEST                  0x04
#define ACTION_GET_LIST_UPDATE_FILES         0x05
#define ACTION_GET_CHECKSUMS                 0x06
#define ACTION_GET_FILE                      0x07
#define ACTION_OPEN_CACHE                    0x09
#define ACTION_OPEN_CACHE_EX                 0x0a
//#define ACTION_SEND_CACHE                    0xf0

#define QUERY_AUTHENFICATION_SERVER          0x00000004UL
#define ACTION_CREATE_USER                   0x01
#define ACTION_LP_CHECK_USER                 0x0e
#define ACTION_CHECK_LOGIN                   0x1d
#define ACTION_LP_CHECK_EMAIL                0x20
#define ACTION_LP_CHECK_PRODUCT              0x21
#define ACTION_CHECK_EMAIL                   0x22
