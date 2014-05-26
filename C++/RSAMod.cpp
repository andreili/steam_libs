#include "stdafx.h"
#include "RSAMod.h"
#include "Stream.h"
#include <openssl/bio.h>

RSA *MainKeySign;
RSA *NetworkKey;
RSA *NetworkKeySign;

// MainKeySign
#define MainKeySign_n "86724794f8a0fcb0c129b979e7af2e1e309303a7042503d835708873b1df8a9e307c228b9c0862f8f5dbe6f81579233db8a4fe6ba14551679ad72c01973b5ee4ecf8ca2c21524b125bb06cfa0047e2d202c2a70b7f71ad7d1c3665e557a7387bbc43fe52244e58d91a14c660a84b6ae6fdc857b3f595376a8e484cb6b90cc992f5c57cccb1a1197ee90814186b046968f872b84297dad46ed4119ae0f402803108ad95777615c827de8372487a22902cb288bcbad7bc4a842e03a33bd26e052386cbc088c3932bdd1ec4fee1f734fe5eeec55d51c91e1d9e5eae46cf7aac15b2654af8e6c9443b41e92568cce79c08ab6fa61601e4eed791f0436fdc296bb373"
#define MainKeySign_e "07e89acc87188755b1027452770a4e01c69f3c733c7aa5df8aac44430a768faef3cb11174569e7b44ab2951da6e90212b0822d1563d6e6abbdd06c0017f46efe684adeb74d4113798cec42a54b4f85d01e47af79259d4670c56c9c950527f443838b876e3e5ef62ae36aa241ebc83376ffde9bbf4aae6cabea407cfbb08848179e466bcb046b0a857d821c5888fcd95b2aae1b92aa64f3a6037295144aa45d0dbebce075023523bce4243ae194258026fc879656560c109ea9547a002db38b89caac90d75758e74c5616ed9816f3ed130ff6926a1597380b6fc98b5eeefc5104502d9bee9da296ca26b32d9094452ab1eb9cf970acabeecde6b1ffae57b56401"
#define MainKeySign_d "11"
// NetworkKey
#define NetworkKey_n "bf973e24beb372c12bea4494450afaee290987fedae8580057e4f15b93b46185b8daf2d952e24d6f9a23805819578693a846e0b8fcc43c23e1f2bf49e843aff4b8e9af6c5e2e7b9df44e29e3c1c93f166e25e42b8f9109be8ad03438845a3c1925504ecc090aabd49a0fc6783746ff4e9e090aa96f1c8009baf9162b66716059"
#define NetworkKey_e "11"
#define NetworkKey_d "4ee3ec697bb34d5e999cb2d3a3f5766210e5ce961de7334b6f7c6361f18682825b2cfa95b8b7894c124ada7ea105ec1eaeb3c5f1d17dfaa55d099a0f5fa366913b171af767fe67fb89f5393efdb69634f74cb41cb7b3501025c4e8fef1ff434307c7200f197b74044e93dbcf50dcc407cbf347b4b817383471cd1de7b5964a9d"

#define set_key(key, value) { key=BN_new(); BN_hex2bn(&key, value); }
#define prepare_key(key) { key->iqmp=BN_new(); key->p=BN_new(); key->q=BN_new(); key->dmp1=BN_new(); key->dmq1=BN_new(); }

void RSA_Init()
{
	MainKeySign = RSA_new();
	prepare_key(MainKeySign);
	set_key(MainKeySign->n,  MainKeySign_n);
	set_key(MainKeySign->e,  MainKeySign_e);
	set_key(MainKeySign->d,  MainKeySign_d);
	
	NetworkKey = RSA_new();
	prepare_key(NetworkKey);
	set_key(NetworkKey->n,  NetworkKey_n);
	set_key(NetworkKey->e,  NetworkKey_e);
	set_key(NetworkKey->d,  NetworkKey_d);
	
	NetworkKeySign = RSA_new();
	prepare_key(NetworkKeySign);
	set_key(NetworkKeySign->n,  NetworkKey_n);
	set_key(NetworkKeySign->e,  NetworkKey_d);
	set_key(NetworkKeySign->d,  NetworkKey_e);
}

char *RSASign(RSA *key, char *Mess, UINT32 size, UINT32 sign_size)
{
	char *sign = new char[sign_size];
	memset(sign, 0, sign_size);
	sign[0] = '\x00';
	sign[1] = '\x01';
	memset(&sign[2], 0xff, sign_size-38);
	memcpy(&sign[sign_size-36], "\x00\x30\x21\x30\x09\x06\x05\x2b\x0e\x03\x02\x1a\x05\x00\x04\x14", 0x10);

	void *hash = HashSHA1(Mess, size);
	memcpy((void*)&sign[sign_size-20], hash, 20);
	delete hash;

	RSA_public_encrypt(sign_size, (UCHAR*)sign, (UCHAR*)sign, key, RSA_NO_PADDING);

	return sign;
}

char *RSASignMessage(RSA *key, char *Mess, UINT32 size)
{
	return RSASign(key, Mess, size, 128);
}

char *RSASignMessage1024(RSA *key, char *Mess, UINT32 size)
{
	return RSASign(key, Mess, size, 256);
}

char *RSASignFile(RSA *key, char * filename)
{
	CStream *str = new CStream(filename, false);
	UINT32 size = (UINT32)str->GetSize();
	char *data = new char[size];
	str->Read(data, str->GetSize());
	delete str;

	char *res = RSASignMessage(key, data, size);
	delete data;

	// save signature to file
	char buf[MAX_PATH];
	sprintf_s(buf, MAX_PATH, "%s%s", filename, "_rsa_signature");
	str = new CStream(buf, true);
	str->Write(res, 128);
	delete str;

	return res;
}

char *HashSHA1(char *data, UINT32 size)
{
	char *res = new char[20];
	SHA_CTX sha;
	SHA1_Init(&sha);
	SHA1_Update(&sha, data, size);
	SHA1_Final((u_char*)res, &sha);
	return res;
}

char *GetNetworkKey()
{
	char *res = new char[NetworkKey_l];
	BN_bn2bin(NetworkKey->n, (u_char*)res);
	return res;
}