unit Form_CacheViewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Menus, ImgList, CommCtrl, SL_Interfaces;

type
  TCacheViewerForm = class(TForm)
    TV_Folders: TTreeView;
    MainMenu1: TMainMenu;
    Splitter1: TSplitter;
    LV_Files: TListView;
    OD: TOpenDialog;
    IL_Small: TImageList;
    IL_Large: TImageList;
    PM_Files: TPopupMenu;
    PM_Prev: TMenuItem;
    N2: TMenuItem;
    PM_Extract: TMenuItem;
    PM_Validate: TMenuItem;
    N3: TMenuItem;
    PM_Properties: TMenuItem;
    SD: TSaveDialog;
    PM_Folders: TPopupMenu;
    PM_F_Extract: TMenuItem;
    PM_F_Validate: TMenuItem;
    MenuItem5: TMenuItem;
    PM_F_Properties: TMenuItem;
    PM_Import: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TV_FoldersChange(Sender: TObject; Node: TTreeNode);
    procedure PM_FilesPopup(Sender: TObject);
    procedure PM_PrevClick(Sender: TObject);
    procedure PM_ValidateClick(Sender: TObject);
    procedure PM_ExtractClick(Sender: TObject);
    procedure PM_PropertiesClick(Sender: TObject);
    procedure PM_F_ExtractClick(Sender: TObject);
    procedure PM_F_ValidateClick(Sender: TObject);
    procedure PM_F_PropertiesClick(Sender: TObject);
    procedure PM_ImportClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    function OnFolder(Root: Pointer; Caption: string; ItemIdx: integer): Pointer;
    procedure OnFile(Caption: string; ItemIdx: integer; ItemSize: uint64);
  public
    { Public declarations }
    procedure ShowForm();
  end;

var
  CacheViewerForm: TCacheViewerForm;
  Cache: ICache;

implementation

{$R *.dfm}

uses
  USE_Types, USE_Utils, MainForm,
    Form_FileProperties, Form_ViewerExtract, Form_FastView;

procedure TCacheViewerForm.ShowForm();
begin
  CacheViewerForm:=TCacheViewerForm.Create(Application);
  with CacheViewerForm do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TCacheViewerForm.FormCreate(Sender: TObject);
begin
  cache.CreateFoldersList(nil, OnFolder);
  TV_Folders.Items[0].Selected:=true;
end;

function TCacheViewerForm.OnFolder(Root: Pointer; Caption: string; ItemIdx: integer): Pointer;
begin
  result:=Pointer(TV_Folders.Items.AddChild(TTreeNode(Root), Caption));
  TTreeNode(result).Data:=Pointer(ItemIdx);
end;

procedure TCacheViewerForm.PM_ExtractClick(Sender: TObject);
var
  i, j: integer;
begin
  Form_ViewerExtract.ItemsCount:=LV_Files.SelCount;
  j:=0;
  for i:=0 to LV_Files.Items.Count-1 do
    if (LV_Files.Items[i].Selected) then
    begin
      Form_ViewerExtract.Items[j]:=integer(LV_Files.Items[i].Data);
      inc(j);
    end;
  IsValidate:=false;
  ExtractForm.L_To.Caption:='e:\Projects\Steam\Client\SteamLite\exe\tmp\';  ////

  Form_ViewerExtract.cache:=cache;

  ExtractForm.Show();
end;

procedure TCacheViewerForm.PM_F_ExtractClick(Sender: TObject);
begin
  Form_ViewerExtract.ItemsCount:=1;
  Form_ViewerExtract.Items[0]:=integer(TV_Folders.Selected.Data);
  IsValidate:=false;
  ExtractForm.L_To.Caption:='e:\Projects\Steam\Client\SteamLite\exe\tmp\';  ////

  Form_ViewerExtract.cache:=cache;

  ExtractForm.Show();
end;

procedure TCacheViewerForm.PM_F_PropertiesClick(Sender: TObject);
begin
  ItemIdx:=integer(TV_Folders.Selected.Data);
  Form_FileProperties.Cache:=Cache;
  PropertiesForm.Show();
end;

procedure TCacheViewerForm.PM_F_ValidateClick(Sender: TObject);
begin
  Form_ViewerExtract.ItemsCount:=1;
  Form_ViewerExtract.Items[0]:=integer(TV_Folders.Selected.Data);
  ExtractForm.L_To.Caption:='-';
  IsValidate:=true;

  Form_ViewerExtract.cache:=cache;

  ExtractForm.Show();
end;

procedure TCacheViewerForm.PM_ImportClick(Sender: TObject);
begin
//
end;

procedure TCacheViewerForm.PM_PrevClick(Sender: TObject);
begin
  Form_FastView.ItemIdx:=integer(LV_Files.Selected.Data);
  Form_FastView.cache:=cache;
  FastViewForm.Show();
end;

procedure TCacheViewerForm.PM_PropertiesClick(Sender: TObject);
begin
  Form_FileProperties.ItemIdx:=integer(LV_Files.Selected.Data);
  Form_FileProperties.Cache:=Cache;
  PropertiesForm.Show();
end;

procedure TCacheViewerForm.PM_ValidateClick(Sender: TObject);
var
  i, j: integer;
begin
  Form_ViewerExtract.ItemsCount:=LV_Files.SelCount;
  j:=0;
  for i:=0 to LV_Files.Items.Count-1 do
    if (LV_Files.Items[i].Selected) then
    begin
      Form_ViewerExtract.Items[j]:=integer(LV_Files.Items[i].Data);
      inc(j);
    end;
  ExtractForm.L_To.Caption:='-';
  IsValidate:=true;

  Form_ViewerExtract.cache:=cache;

  ExtractForm.Show();
end;

procedure TCacheViewerForm.PM_FilesPopup(Sender: TObject);
var
  en: boolean;
begin
  en:=(LV_Files.SelCount<>0);
  if LV_Files.SelCount>1 then
  begin
    PM_Prev.Enabled:=false;
    PM_Properties.Enabled:=false;
  end
    else
  begin
    PM_Prev.Enabled:=en;
    PM_Properties.Enabled:=en;
  end;
  PM_Extract.Enabled:=en;
  PM_Validate.Enabled:=en;
end;

procedure TCacheViewerForm.FormDestroy(Sender: TObject);
begin
  cache.Close();
end;

procedure TCacheViewerForm.OnFile(Caption: string; ItemIdx: integer; ItemSize: uint64);
var
  Item: TListItem;
  s, Descr: string;
  Small: HICON;
begin
  Item:=LV_Files.Items.Add();
  Item.Caption:=Caption;
  s:=ExtractFileExt(Caption);
  Delete(s, 1, 1);
  Item.SubItems.Add(s);
  Item.SubItems.Add(Core.Utils.GetSizeTitle(ItemSize));
  Item.ImageIndex:=ImageList_AddIcon(IL_Large.Handle, Core.Utils.GetIconByExt(ExtractFileExt(Caption), Small, Descr));
  ImageList_AddIcon(IL_Small.Handle, Small);
  Item.SubItems.Add(Descr);
  Item.Data:=Pointer(ItemIdx);
end;

procedure TCacheViewerForm.TV_FoldersChange(Sender: TObject; Node: TTreeNode);
begin
  LV_Files.Items.Clear();
  cache.CreateFilesList(uint32(Node.Data), OnFile);
end;

end.
