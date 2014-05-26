unit Form_FileProperties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, ValEdit, SL_Interfaces;

type
  TPropertiesForm = class(TForm)
    Label1: TLabel;
    Ed_FileName: TEdit;
    Panel1: TPanel;
    Label2: TLabel;
    L_Size: TLabel;
    Label4: TLabel;
    L_Completion: TLabel;
    Panel2: TPanel;
    VLE_Fields: TValueListEditor;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Show();
  end;

var
  PropertiesForm: TPropertiesForm;
  ItemIdx: integer;
  Cache: ICache;

implementation

{$R *.dfm}

uses
  USE_Types, USE_Utils;

procedure TPropertiesForm.Show();
begin
  self:=TPropertiesForm.Create(Application);
  self.ShowModal();
  self.Free;
end;

const
  HL_GCF_FLAG_FILE                      =$00004000;	// The item is a file.
  HL_GCF_FLAG_ENCRYPTED                 =$00000100;	// The item is encrypted.
  HL_GCF_FLAG_BACKUP_LOCAL              =$00000040;	// Backup the item before overwriting it.
  HL_GCF_FLAG_COPY_LOCAL                =$0000000a;	// The item is to be copied to the disk.
  HL_GCF_FLAG_COPY_LOCAL_NO_OVERWRITE   =$00000001;

procedure TPropertiesForm.FormCreate(Sender: TObject);
var
  Size: TItemSize;
  Flags: uint;
  F: IFileCache;
begin
  if Cache=nil then
    Exit;
  F:=cache.Open();
  Ed_FileName.Text:=F.GetItemName(ItemIdx);
  Size:=F.GetItemSize(ItemIdx);
  L_Size.Caption:=Core.Utils.GetSizeTitle(Size.CSize)+' / '+
   Core.Utils.GetSizeTitle(Size.Size)+' ('+Int2Str(Size.Sectors*$2000)+')';
  L_Completion.Caption:=Double2Str(Core.Utils.RoundMax(F.GetCompletion(ItemIdx)*100, 100))+'%';

  Flags:=F.GetItemFlags(ItemIdx);
  VLE_Fields.InsertRow('#Flags', '0x'+Int2Hex(Flags, 8), false);
  if Flags and HL_GCF_FLAG_FILE=HL_GCF_FLAG_FILE then
  begin
    VLE_Fields.InsertRow('#Encrypted', '', false);
    VLE_Fields.InsertRow('#BackupLocal', '', false);
    VLE_Fields.InsertRow('#CopyLocal', '', false);
    VLE_Fields.InsertRow('#CopyLocalNoOverwrite', '', false);
    if Flags and HL_GCF_FLAG_ENCRYPTED=HL_GCF_FLAG_ENCRYPTED then
      VLE_Fields.Values['#Encrypted']:='#Yes'
      else VLE_Fields.Values['#Encrypted']:='#No';
    if Flags and HL_GCF_FLAG_BACKUP_LOCAL=HL_GCF_FLAG_BACKUP_LOCAL then
      VLE_Fields.Values['#BackupLocal']:='#Yes'
      else VLE_Fields.Values['#BackupLocal']:='#No';
    if Flags and HL_GCF_FLAG_COPY_LOCAL=HL_GCF_FLAG_COPY_LOCAL then
      VLE_Fields.Values['#CopyLocal']:='#Yes'
      else VLE_Fields.Values['#CopyLocal']:='#No';
    if Flags and HL_GCF_FLAG_COPY_LOCAL_NO_OVERWRITE=HL_GCF_FLAG_COPY_LOCAL_NO_OVERWRITE then
      VLE_Fields.Values['#CopyLocalNoOverwrite']:='#Yes'
      else VLE_Fields.Values['#CopyLocalNoOverwrite']:='#No';
  end;
  Core.UI.ReloadControlsText(self);
end;

end.
