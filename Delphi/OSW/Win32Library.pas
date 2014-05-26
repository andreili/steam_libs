unit Win32Library;

interface

uses
  Windows;

type
  pDynamicLibrary = ^DynamicLibrary;
  DynamicLibrary = class
    public
      constructor Create(path: pAnsiChar);
      destructor Destroy();
      function GetSymbol(name: pAnsiChar): Pointer;
      function IsLoaded(): boolean;
    private
      m_handle: HMODULE;
  end;

implementation

constructor DynamicLibrary.Create(path: pAnsiChar);
begin
  m_handle:=LoadLibraryA(path);
end;

destructor DynamicLibrary.Destroy();
begin
  if (m_handle<>0) then
    FreeLibrary(m_handle);
end;

function DynamicLibrary.GetSymbol(name: pAnsiChar): Pointer;
begin
  result:=nil;
  if (m_handle=0) then
    Exit;
  result:=GetProcAddress(m_handle, name);
end;

function DynamicLibrary.IsLoaded(): boolean;
begin
  result:=(m_handle<>0);
end;

end.
