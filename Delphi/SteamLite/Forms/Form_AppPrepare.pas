unit Form_AppPrepare;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, USE_Types, USE_Utils, SL_Interfaces, ComCtrls;

type
  TAppPrepareForm = class(TForm)
    P_AppType: TPanel;
    RB_TypeGCF: TRadioButton;
    RB_TypeStandAlone: TRadioButton;
    Panel1: TPanel;
    Btn_Cancel: TButton;
    Btn_Next: TButton;
    Btn_Prev: TButton;
    P_CalcSpace: TPanel;
    Label1: TLabel;
    P_SelDstDir: TPanel;
    Label2: TLabel;
    Ed_Dst: TEdit;
    Btn_Browse: TButton;
    L_Info: TLabel;
    P_Components: TPanel;
    TV_Comp: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure Btn_NextClick(Sender: TObject);
    procedure Btn_BrowseClick(Sender: TObject);
    procedure Ed_DstChange(Sender: TObject);
  private
    { Private declarations }
    fAppSize: int64;
    fThread: TThread;
    function CalcSpaceProc(Sender: TThread): integer;
    procedure BuildComponentsTree();
  public
    { Public declarations }
  end;

var
  AppPrepareForm: TAppPrepareForm;
  apps: array of IApp;

implementation

{$R *.dfm}

procedure TAppPrepareForm.Btn_BrowseClick(Sender: TObject);
begin
  Ed_Dst.Text:=Core.UI.GetDirectoryFromDlg(Core.Translation.GetTitle('#SelectDestinationDirectory'));
end;

procedure TAppPrepareForm.Btn_NextClick(Sender: TObject);
begin
  if P_AppType.Visible then
  begin
    P_AppType.Visible:=false;
    P_Components.Visible:=true;
    BuildComponentsTree();
  end
    else if P_Components.Visible then
  begin
    P_AppType.Visible:=false;
    P_CalcSpace.Visible:=true;
    Btn_prev.Enabled:=true;
    Btn_Next.Enabled:=false;
    fThread:=TThread.CreateAutoFree(CalcSpaceProc);
    while fThread<>nil do
      Application.ProcessMessages();
    Btn_Next.Click();
  end
    else if P_CalcSpace.Visible then
  begin
    Btn_Next.Enabled:=true;
    P_CalcSpace.Visible:=false;
    P_SelDstDir.Visible:=true;
    Ed_Dst.Text:=Core.Settings.GetStringValue(VALUE_USER_PATH);
  end;
end;

procedure TAppPrepareForm.FormCreate(Sender: TObject);
begin
  SetWindowLong(TV_Comp.Handle,GWL_STYLE,GetWindowLong(TV_Comp.Handle,GWL_STYLE) or $0100);
  P_AppType.Align:=alClient;
  P_AppType.Visible:=true;

  P_Components.Align:=alClient;
  P_CalcSpace.Align:=alClient;
  P_SelDstDir.Align:=alClient;
  Core.UI.ReloadControlsText(self);
end;

function TAppPrepareForm.CalcSpaceProc(Sender: TThread): integer;
var
  i, l: integer;
begin
  fAppSize:=0;
  l:=Length(apps)-1;
  for i:=0 to l do
    fAppSize:=fAppSize+apps[i].GetAppSize(RB_TypeStandAlone.Checked);
  fThread:=nil;
end;

procedure TAppPrepareForm.Ed_DstChange(Sender: TObject);
var
  freeSp: int64;
begin
  freeSp:=Core.Utils.GetDiskFreeSpace(pChar(Ed_Dst.Text));
  L_Info.Caption:=USE_Utils.Format(Core.Translation.GetTitle('#SpaceInfo'), [
   WideCharToString(Core.Utils.GetSizeTitle(freeSp)),
   WideCharToString(Core.Utils.GetSizeTitle(fAppSize)),
   WideCharToString(Core.Utils.GetSizeTitle(freeSp-fAppSize))
  ]);
end;

procedure TAppPrepareForm.BuildComponentsTree();
var
  root, comp, subComp: TTreeNode;
  i, l: integer;
begin
  TV_Comp.Items.Clear();
  root:=TV_Comp.TopItem;
  l:=Length(apps)-1;
  for i:=0 to l do
  begin
    comp:=TV_Comp.Items.AddChild(root, apps[i].GetName());
  end;
end;

end.
