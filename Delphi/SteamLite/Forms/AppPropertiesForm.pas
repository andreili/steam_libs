unit AppPropertiesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, USE_Utils;

type
  TForm_AppProperties = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    L_Name: TLabel;
    L_CommonPath: TLabel;
    Label4: TLabel;
    L_Developer: TLabel;
    Label6: TLabel;
    L_HomePage: TLabel;
    Label8: TLabel;
    L_AppID: TLabel;
    Label10: TLabel;
    L_Size: TLabel;
    Label12: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label13: TLabel;
    LV_Caches: TListView;
    Panel4: TPanel;
    Panel5: TPanel;
    LV_UDR: TListView;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowForm();
  end;

var
  Form_AppProperties: TForm_AppProperties;
  AppID: uint32;

implementation

{$R *.dfm}

uses
  MainForm, SL_Interfaces;

procedure TForm_AppProperties.ShowForm();
begin
  Form_AppProperties:=TForm_AppProperties.Create(Application);
  with Form_AppProperties do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TForm_AppProperties.FormCreate(Sender: TObject);
var
  //AppInfo: pDetailedAppInfo;
  App: IApplication;
  Caches: TCachesArray;
  i: integer;
  Item: TListItem;
begin
  Core.UI.ReloadControlsText(self);
  //AppInfo:=Mess.GetDetailedAppInfo(AppID);
  App:=Core.ApplicationsList.GetApplication(AppID);
  if App<>nil then
  begin
    L_Name.Caption:=App.GetName();
    L_CommonPath.Caption:=App.GetFolderName();
    L_Developer.Caption:=Ansi2Wide(App.GetUserDefinedRecord('developer'));
    L_HomePage.Caption:=Ansi2Wide(App.GetUserDefinedRecord('homepage'));
    L_AppID.Caption:=IntToStr(App.GetAppID());
    L_Size.Caption:=Core.Utils.GetSizeTitle(App.GetSize);
    Caches:=App.GetCaches;
    if Length(Caches)>0 then
      for i:=0 to Length(Caches)-1 do
      begin
        if (Caches[i]=nil) then
          continue;
        Item:=LV_Caches.Items.Add();
        Item.Caption:=Caches[i].GetFolderName();
        Item.SubItems.Add(IntToStr(Caches[i].GetAppID()));
        Item.SubItems.Add(Core.Utils.GetSizeTitle(Caches[i].GetSize()));
        Item.SubItems.Add(IntToStr(Caches[i].GetVersion()));
        if (Caches[i].GetCompletion()<0) then Item.SubItems.Add(Core.Translation.GetTitle('#NotLoaded'))
          else Item.SubItems.Add(Double2Str(Round(Caches[i].GetCompletion()*1000)/10)+'%');
      end;
  end;
end;

end.
