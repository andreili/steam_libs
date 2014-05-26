#include <openssl/bn.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>

#define MainKeySign_l 256
#define NetworkKey_l 128

extern RSA *MainKeySign;
extern RSA *NetworkKey;
extern RSA *NetworkKeySign;

void RSA_Init();
char *RSASign(RSA *key, char *Mess, UINT32 size, UINT32 sign_size);
char inline *RSASignMessage(RSA *key, char *Mess, UINT32 size);
char inline *RSASignMessage1024(RSA *key, char *Mess, UINT32 size);
char *RSASignFile(RSA *key, char * filename);

char *HashSHA1(char *data, UINT32 size);

char *GetNetworkKey();