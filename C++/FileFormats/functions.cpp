#include "stdafx.h"
#include "functions.h"

void ForceDirectories(char *Path)
{
	char *newP = new char[strlen(Path)+1];
	memcpy(newP, Path, strlen(Path));
	newP[strlen(Path)] = '\x00';
	for (size_t i=0 ; i<strlen(newP) ; i++)
		if (newP[i] == '\\')
		{
			newP[i] = '\x00';
			CreateDirectoryA(newP, NULL);
			newP[i] = '\\';
		}
	CreateDirectoryA(newP, NULL);
}

char *ExtractFilePath(char *Path)
{
	//int len = 0;
	int i = 0;
	for (i=strlen(Path)-1 ; i>=0 ; i--)
		if (Path[i] == '\\')
			break;
	if (i==0)
		return "";
	char *res = new char[i];
	memcpy(res, Path, i);
	res[i] = '\x00';
	return res;
	/*len = strlen(Path) - i + 1;
	char *res = new char[len];
	memcpy(res, &Path[i], len);*/
}

char *ExtractFileName(char *Path)
{
	//int len = 0;
	int i = 0;
	for (i=strlen(Path)-1 ; i>=0 ; i--)
		if (Path[i] == '\\')
			break;
	if (i==0)
		return Path;
	return &Path[i+1];
	/*len = strlen(Path) - i + 1;
	char *res = new char[len];
	memcpy(res, &Path[i], len);*/
}

bool StrSatisfy(char *s, char *mask)
{
	bool ret;
next_char:
	ret = true;
	if ((*s == '\x00') && (*mask == '\x00'))
		return ret;
	if ((*mask == '*') && (mask[1] == '\x00'))
		return ret;
	if (*s == '\x00')
	{
		while (*mask =='*')
			mask++;
		return (*mask == '\x00');
	}
	ret = false;
	if (*mask == '\x00')
		return ret;
	if (*mask == '?')
	{
		s++;
		mask++;
		goto next_char;
	}
	if (*mask =='*')
	{
		mask++;
		while (*s != '\x00')
		{
			ret = StrSatisfy(s, mask);
			if (ret)
				return ret;
			s++;
		}
		return ret;
	}
	ret = (*s == *mask);
	s++;
	mask++;
	if (ret)
		goto next_char;
	return ret;
}

char *ReplaceExt(char *FileName, char *NewExt)
{
	int i;
	for (i=strlen(FileName) ; i>=0 ; i--)
		if (FileName[i] == '.')
			break;
	if (i==0)
		return FileName;
	int l = i+strlen(NewExt)+1;
	char *res = new char[l];
	memcpy(res, FileName, i+1);
	memcpy(&res[i+1], NewExt, strlen(NewExt));
	res[l] = '\x00';
	return res;
}

char *MakeStr(char *str1, char *str2)
{	
	int len = strlen(str1) + strlen(str2)+1;
	char *res = new char[len];
	sprintf_s(res, len, "%s%s", str1, str2);
	return res;
	/*size_t l1 = strlen(str1),
		l2 = strlen(str2);
	char *res = new char[l1+l2+1];
	memcpy(res, str1, l1);
	memcpy(&res[l1], str2, l2);
	res[l1+l2] = '\x00';
	return res;*/
}

char *IncludeTrailingPathDelimiter(char *str)
{
	size_t l = strlen(str);
	char *res = new char[l+1];
	memcpy(res, str, l);
	if (res[l-1]!='\\')
		res[(l++)] = '\\';
	res[l]='\x00';
	return res;
}

bool DirectoryExists(char *Path)
{
	DWORD e = SetErrorMode(SEM_NOOPENFILEERRORBOX | SEM_FAILCRITICALERRORS);
	int code = GetFileAttributesA(Path);
	SetErrorMode(e);
	return (code != -1) && ((FILE_ATTRIBUTE_DIRECTORY & code) != 0);
}

char* LowerCase(char* str)
{	
	int differ = 'A'-'a';
	char ch;
	size_t ii = strlen(str);
	for (size_t i=0; i <ii;i++)
	{
		strncpy_s(&ch,1,str+i,1);
		if (ch>='A' && ch<='Z')
		{
			ch = ch-differ;
			memcpy(str+i,&ch,1);
		}
	}
	return str;
}

bool FindFirst(char *path, FindRecord *rec)
{
	rec->CustomData = new WIN32_FIND_DATAA;
	rec->Handle = FindFirstFileA(path, (LPWIN32_FIND_DATAA)rec->CustomData);
	return (rec->Handle != INVALID_HANDLE_VALUE);
}

bool FindNext(FindRecord *rec)
{
	return (bool)FindNextFileA(rec->Handle, (LPWIN32_FIND_DATAA)rec->CustomData);
}

UINT32 HeaderChecksum(UINT8 *lpData, int Size)
{
	UINT32 Checksum = 0;
	for (int i=0 ; i<Size ; i++)
		Checksum += *(lpData++);
	return Checksum;
}

UINT32 HeaderChecksum2(UINT32 *lpData, int Size)
{
	UINT32 Checksum = 0;
	for (int i=0 ; i<Size ; i++)
		Checksum += *(lpData++);
	return Checksum;
}

#define DO1(buf,i)  {s1 += buf[i]; s2 += s1;}
#define DO2(buf,i)  DO1(buf,i); DO1(buf,i+1);
#define DO4(buf,i)  DO2(buf,i); DO2(buf,i+2);
#define DO8(buf,i)  DO4(buf,i); DO4(buf,i+4);
#define DO16(buf)   DO8(buf,0); DO8(buf,8);

#define mix(a,b,c) \
{ \
  a -= b; a -= c; a ^= (c>>13); \
  b -= c; b -= a; b ^= (a<<8); \
  c -= a; c -= b; c ^= (b>>13); \
  a -= b; a -= c; a ^= (c>>12);  \
  b -= c; b -= a; b ^= (a<<16); \
  c -= a; c -= b; c ^= (b>>5); \
  a -= b; a -= c; a ^= (c>>3);  \
  b -= c; b -= a; b ^= (a<<10); \
  c -= a; c -= b; c ^= (b>>15); \
}

UINT32 jenkinsLookupHash2(UINT8 *k, UINT32 length, UINT32 initval)
{
   UINT32 a,b,c,len;

   /* Set up the internal state */
   len = length;
   a = b = 0x9e3779b9;  /* the golden ratio; an arbitrary value */
   c = initval;           /* the previous hash value */

   /*---------------------------------------- handle most of the key */
   while (len >= 12)
   {
      a += (k[0] +((UINT32)k[1]<<8) +((UINT32)k[2]<<16) +((UINT32)k[3]<<24));
      b += (k[4] +((UINT32)k[5]<<8) +((UINT32)k[6]<<16) +((UINT32)k[7]<<24));
      c += (k[8] +((UINT32)k[9]<<8) +((UINT32)k[10]<<16)+((UINT32)k[11]<<24));
      mix(a,b,c);
      k += 12; len -= 12;
   }

   /*------------------------------------- handle the last 11 bytes */
   c += length;
   switch(len)              /* all the case statements fall through */
   {
   case 11: c+=((UINT32)k[10]<<24);
   case 10: c+=((UINT32)k[9]<<16);
   case 9 : c+=((UINT32)k[8]<<8);
      /* the first byte of c is reserved for the length */
   case 8 : b+=((UINT32)k[7]<<24);
   case 7 : b+=((UINT32)k[6]<<16);
   case 6 : b+=((UINT32)k[5]<<8);
   case 5 : b+=k[4];
   case 4 : a+=((UINT32)k[3]<<24);
   case 3 : a+=((UINT32)k[2]<<16);
   case 2 : a+=((UINT32)k[1]<<8);
   case 1 : a+=k[0];
     /* case 0: nothing left to add */
   }
   mix(a,b,c);
   /*-------------------------------------------- report the result */
   return c;
}

/*UINT32 adler32 (UINT32 adler, const UINT8 *buf, UINT32 len)
{
	unsigned long s1 = adler & 0xffff;
	unsigned long s2 = (adler >> 16) & 0xffff;
	int k;

	if (buf == 0) return 1L;

	while (len > 0) 
	{
		k = len < 5552 ? len : 5552;
		len -= k;
		while (k >= 16) 
		{
			DO16(buf);
			buf += 16;
			k -= 16;
		}
		if (k != 0) do 
		{
			s1 += *buf++;
			s2 += s1;
		} while (--k);
		s1 %= 65521UL;
		s2 %= 65521UL;
	}
	return (s2 << 16) | s1;
}

UINT32 CRC32(UINT8 *lpBuf, UINT32 nBufLen) 
{ 
unsigned long table [] = {
	0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3,
	0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91,
	0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
	0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5,
	0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B,
	0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
	0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F,
	0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D,
	0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
	0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01,
	0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457,
	0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
	0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB,
	0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9,
	0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
	0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD,
	0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683,
	0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
	0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7,
	0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5,
	0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
	0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79,
	0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F,
	0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
	0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713,
	0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21,
	0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
	0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45,
	0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB,
	0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
	0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF,
	0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D }; 

	UINT32 res = 0xFFFFFFFF; 
	for (UINT32 i=0 ; i<nBufLen ; i++, lpBuf++) 
		res = ((res >> 8) & 0x00FFFFFF) ^ table[(res ^ *lpBuf) & 0xFF];
	return res ^ 0xFFFFFFFF; 
}*/

UINT32 Checksum(UINT8 *lpData, UINT32 uiSize)
{
	//return (adler32(0, lpData, uiSize) ^ CRC32(lpData, uiSize));
	return (adler32(0, lpData, uiSize) ^ crc32(0, lpData, uiSize));
}
