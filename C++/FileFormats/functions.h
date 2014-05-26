#include "../zlib.h"

void ForceDirectories(char *Path);
char *ExtractFilePath(char *Path);
char *ExtractFileName(char *Path);
bool StrSatisfy(char *s, char *mask);
char *ReplaceExt(char *FileName, char *NewExt);
char *MakeStr(char *str1, char *str2);
char *IncludeTrailingPathDelimiter(char *str);
bool DirectoryExists(char *Path);
char* LowerCase(char* str);
bool FindFirst(char *path, FindRecord *rec);
bool FindNext(FindRecord *rec);
UINT32 HeaderChecksum(UINT8 *lpData, int Size);
UINT32 HeaderChecksum2(UINT32 *lpData, int Size);
UINT32 jenkinsLookupHash2(UINT8 *k, UINT32 length, UINT32 initval);
UINT32 Checksum(UINT8 *lpData, UINT32 uiSize);