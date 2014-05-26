unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, TabNotBk,
  SteamTypes, SteamWorks,
  ClientCommon, FriendsCommon, UtilsCommon, UserCommon, GameServerCommon,
  ISteamClient006_, ISteamUtils004_, ISteamFriends006_, ISteamFriends005_,
  ISteamUser014_, ISteamGameServer010_;

type
  TForm1 = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    LW_Clans: TListView;
    Btn_RefrClans: TButton;
    I_Clan1: TImage;
    I_Clan2: TImage;
    I_Clan3: TImage;
    Btn_RefrFr: TButton;
    LW_Friends: TListView;
    I_Friend1: TImage;
    I_Friend2: TImage;
    I_Friend3: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Btn_RefrClansClick(Sender: TObject);
    procedure LW_ClansSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Btn_RefrFrClick(Sender: TObject);
    procedure LW_FriendsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  pRec = ^TRec;
  TRec = record
    id: CSteamID;
    icon_small,
    icon_medium,
    icon_large: TBitmap;
  end;

var
  Form1: TForm1;
  hPipe: HSteamPipe;
  hUser: HSteamUser;
  SW: CSteamAPILoader;
  client: ISteamClient006;
  user: ISteamUser014;
  utils: ISteamUtils004;
  friends: ISteamFriends006;
  gs: ISteamGameServer010;

  cClan: pRec = nil;

implementation

{$R *.dfm}

function swap(d: uint32): uint32; inline;
var
  b: pbyte;
  b1: byte;
begin
  b:=@d;
  b1:=b^;
  b^:=pbyte(b+2)^;
  pbyte(b+2)^:=b1;
  result:=puint32(b)^;
end;

function GetImage(idx: integer): TBitMap;
var
  w, h, size, i: uint32;
  data: puint8;
  bmp: TBitMap;
begin
  result:=nil;
  if (idx<>0) and (utils.GetImageSize(idx, w, h)) then
  begin
    size:=w*h*4;
    GetMem(data, size);
    if utils.GetImageRGBA(idx, data, size) then
    begin
      bmp:=TBitmap.Create();
      bmp.SetSize(w, h);
      bmp.PixelFormat:=pf32bit;
      for i:=0 to w*h-1 do
      begin
        puint32(data)^:=swap(puint32(data)^);
        inc(data, 4);
      end;
      dec(data, size);
      for i:=0 to h-1 do
      begin
          Move(data^, bmp.ScanLine[i]^, h*4);
          inc(data, 4*w);
      end;
      result:=bmp;
      dec(data, size);
      FreeMem(data, size);
    end;
  end;
end;

procedure TForm1.Btn_RefrClansClick(Sender: TObject);
var
  i, num: integer;
  id: CSteamID;
  LI: TListItem;
  rec: pRec;
begin
  LW_Clans.Clear();
  num:=friends.GetClanCount();
  for i:=0 to num-1 do
  begin
    id:=friends.GetClanByIndex(i);
    LI:=LW_Clans.Items.Add();
    LI.Caption:=CSteamID2String(id);
    LI.SubItems.Add(UTF8ToString(friends.GetClanName(id)));
    LI.SubItems.Add(UTF8ToString(friends.GetClanTag(id)));

    new(rec);
    rec.id:=id;
    rec.icon_small:=nil;
    rec.icon_medium:=nil;
    rec.icon_large:=nil;
    LI.Data:=rec;
  end;
end;

procedure TForm1.Btn_RefrFrClick(Sender: TObject);
var
  i, num: integer;
  id: CSteamID;
  LI: TListItem;
  rec: pRec;
  efr: EFriendFlags;
begin
  LW_Friends.Clear();
  num:=friends.GetFriendCount(k_EFriendFlagAll);
  for i:=0 to num-1 do
  begin
    id:=friends.GetFriendByIndex(i, k_EFriendFlagAll);
    writeln(byte(friends.GetFriendRelationship(id)));
    LI:=LW_Friends.Items.Add();
    LI.Caption:=CSteamID2String(id);
    LI.SubItems.Add((friends.GetFriendPersonaName(id)));

    new(rec);
    rec.id:=id;
    rec.icon_small:=nil;
    rec.icon_medium:=nil;
    rec.icon_large:=nil;
    LI.Data:=rec;
  end;
end;

{$APPTYPE CONSOLE}

procedure TForm1.FormCreate(Sender: TObject);
var
  buf: array[0..1023] of AnsiChar;
begin
  SW:=CSteamAPILoader.Create();
  if not SW.Load() then
  begin
    MessageBox(Handle, 'Steamclient library not loaded!', 'Error!', MB_ICONERROR);
    Halt(0);
  end;

  client:=ISteamClient006(SW.CreateInterface(STEAMCLIENT_INTERFACE_VERSION_006));
  hPipe:=client.CreateSteamPipe();
  hUser:=client.ConnectToGlobalUser(hPipe);
  if (hPipe=0) or (hUser=0) then
  begin
    MessageBox(Handle, 'Steamclient not initializated!', 'Error!', MB_ICONERROR);
    Halt(0);
  end;
  Caption:=client.GetUniverseName(k_EUniversePublic);

  user:=ISteamUser014(client.GetISteamUser(hUser, hPipe, STEAMUSER_INTERFACE_VERSION_014));
  utils:=ISteamUtils004(client.GetISteamUtils(hPipe, STEAMUTILS_INTERFACE_VERSION_004));
  friends:=ISteamFriends006(client.GetISteamFriends(hUser, hPipe, STEAMFRIENDS_INTERFACE_VERSION_006));
  //gs:=ISteamGameServer010(client.GetISteamFriends(hUser, hPipe, STEAMGAMESERVER_INTERFACE_VERSION_010));
  //writeln(gs.GetSteamID().m_unAll64Bits);

  if (user=nil) or (utils=nil) or (friends=nil) then
  begin
    MessageBox(Handle, 'Interfaces not initializated!', 'Error!', MB_ICONERROR);
    Halt(0);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  client.ReleaseUser(hPipe, hUser);
  client.ReleaseSteamPipe(hPipe);
end;

procedure TForm1.LW_ClansSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  rec: pRec;
begin
  rec:=Item.Data;
  {if rec.icon_small=nil then
    rec.icon_small:=GetImage(friends.GetSmallFriendAvatar(rec^.id));
  if rec.icon_medium=nil then
    rec.icon_medium:=GetImage(friends.GetMediumFriendAvatar(rec^.id));
  if rec.icon_large=nil then
    rec.icon_large:=GetImage(friends.GetLargeFriendAvatar(rec^.id));

  I_Clan1.Picture.Bitmap:=rec.icon_large;
  I_Clan2.Picture.Bitmap:=rec.icon_medium;
  I_Clan3.Picture.Bitmap:=rec.icon_small; }
  cClan:=rec;
end;

procedure TForm1.LW_FriendsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  rec: pRec;
begin
  rec:=Item.Data;
 { if rec.icon_small=nil then
    rec.icon_small:=GetImage(friends.GetSmallFriendAvatar(rec^.id));
  if rec.icon_medium=nil then
    rec.icon_medium:=GetImage(friends.GetMediumFriendAvatar(rec^.id));
  if rec.icon_large=nil then
    rec.icon_large:=GetImage(friends.GetLargeFriendAvatar(rec^.id));     }

  I_Friend1.Picture.Bitmap:=rec.icon_large;
  I_Friend2.Picture.Bitmap:=rec.icon_medium;
  I_Friend3.Picture.Bitmap:=rec.icon_small;
  cClan:=rec;
end;

end.
