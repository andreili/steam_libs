unit Form_ViewerExtract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, USE_Types, USE_Utils, SL_Interfaces;

type
  TExtractForm = class(TForm)
    Label1: TLabel;
    P_File: TProgressBar;
    Label2: TLabel;
    P_All: TProgressBar;
    L_From: TLabel;
    L_To: TLabel;
    L_Progress: TLabel;
    L_Time: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    function ThreadProc(Sender: TThread): integer;
    procedure OnError(ItemName: string; ErrorCode: integer; Data: Pointer); stdcall;
    procedure OnProgress(Text: string; CurPos, MaxPos: int64; Data: Pointer); stdcall;
  public
    { Public declarations }
    procedure Show();
  end;

var
  ExtractForm: TExtractForm;
  IsValidate: boolean;
  ItemsCount: integer;
  Items: array[0..1023] of integer;
  cache: ICache;

implementation

{$R *.dfm}

uses
  MainForm;

var
  AllSize, CSize: int64;
  FSize, FCSize: int64;
  F: IFileCache;

procedure TExtractForm.FormActivate(Sender: TObject);
var
  th: TThread;
  i: integer;
begin
  AllSize:=0;
  F:=cache.Open();
  for i:=0 to ItemsCount-1 do
    inc(AllSize, F.GetItemSize(Items[i]).Size);

  th:=TThread.Create();
  th.OnExecute:=ThreadProc;
  th.AutoFree:=true;
  th.Resume;
end;

procedure TExtractForm.FormCreate(Sender: TObject);
begin
  if cache=nil then
    Exit;
end;

procedure TExtractForm.Show();
begin
  ExtractForm:=TExtractForm.Create(Application);
  ExtractForm.ShowModal();
  ExtractForm.Free;

  //self.Free;
end;

var
  t_Now, t_All: TDateTime;
  sz: int64;

function TExtractForm.ThreadProc(Sender: TThread): integer;
var
  i: integer;
  res: EValidateResult;
begin
  t_Now:=Now();
  t_All:=0;
  Timer1.Enabled:=true;
  sz:=0;
  res:=VALIDATE_OK;
  for i:=0 to ItemsCount-1 do
    if IsValidate then res:=F.Validate(Items[i])
      else res:=F.Extract(Items[i], pChar(L_To.Caption));
  result:=integer(res);
  Timer1.Enabled:=false;
  ModalResult:=mrOk;
end;

procedure TExtractForm.Timer1Timer(Sender: TObject);
var
  t_NowNew, t_Elp, sp: TDateTime;
  sz_New: int64;
begin
  Timer1.Enabled:=false;
    sz_New:=CSize+FCSize;
    t_NowNew:=Now();
    t_Now:=t_NowNew-t_Now;
    t_All:=t_All+t_Now;
    sp:=(sz_New-sz)/t_Now;
    t_Elp:=(AllSize-sz_New)/sp;

    L_Progress.Caption:=Core.Utils.GetSizeTitle(sz_New)+' / '+Core.Utils.GetSizeTitle(AllSize)+
     ' ('+Core.Utils.GetSizeTitle(Trunc(sp/86400))+'/sec)';
    L_Time.Caption:=TimeToStr(t_All)+' / '+TimeToStr(t_Elp);

    t_Now:=t_NowNew;
    sz:=sz_New;
  Timer1.Enabled:=true;
end;

procedure TExtractForm.OnError(ItemName: string; ErrorCode: integer; Data: Pointer);
begin
 // Interfaces.Utils.Log('ErrorCode: '+IntToStr(ErrorCode)+' on item "'+ItemName+'"', LOG_LEVEL_SHOW_ERRORS);
end;

procedure TExtractForm.OnProgress(Text: string; CurPos, MaxPos: int64; Data: Pointer);
begin
  if CurPos=-2 then
  begin
    //AllSize:=MaxPos;
    //CSize:=0;
  end
    else if CurPos=0 then
  begin
    L_From.Caption:=Text;
    inc(CSize, FCSize);
    FSize:=MaxPos;
    FCSize:=0;
  end
    else
  begin
    FCSize:=CurPos;
  end;

  if CurPos>=0 then
  begin

    P_All.Position:=Trunc((CSize+FCSize)/AllSize*100);
    P_File.Position:=Trunc(FCSize/FSize*100);
  end;
end;

end.
