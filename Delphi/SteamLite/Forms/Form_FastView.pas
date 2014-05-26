unit Form_FastView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, KControls, KHexEditor, KFunctions, StdCtrls, SL_Interfaces;

type
  TFastViewForm = class(TForm)
    KHexEditor1: TKHexEditor;
    MainMenu1: TMainMenu;
    View1: TMenuItem;
    MM_Hex: TMenuItem;
    MM_Text: TMenuItem;
    MM_HTML: TMenuItem;
    MM_Media: TMenuItem;
    N1: TMenuItem;
    MM_CodeWin: TMenuItem;
    MM_CodeDOS: TMenuItem;
    MM_Unicode: TMenuItem;
    MM_UTF8: TMenuItem;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MM_HexClick(Sender: TObject);
    procedure MM_TextClick(Sender: TObject);
    procedure MM_HTMLClick(Sender: TObject);
    procedure MM_MediaClick(Sender: TObject);
    procedure MM_UnicodeClick(Sender: TObject);
    procedure MM_UTF8Click(Sender: TObject);
    procedure MM_CodeWinClick(Sender: TObject);
    procedure MM_CodeDOSClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Show();
  end;

var
  FastViewForm: TFastViewForm;
  ItemIdx: integer;
  cache: ICache;

implementation

{$R *.dfm}

uses
  USE_Types, USE_Utils, SL_Mess;

type
  ViewMode =
    (Mode_Hex,
     Mode_Text);

var
  Stream: TStream;
  F: IFileCache;
  VM: ViewMode;

procedure TFastViewForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IsChanges: boolean;
  mr: integer;
  s: AnsiString;
begin
  case VM of
    Mode_Hex: IsChanges:=KHexEditor1.Modified;
    Mode_Text: IsChanges:=Memo1.Modified;
    else IsChanges:=false;
  end;
  if IsChanges then
  begin
    mr:=MessageBox(Handle, '#QSaveChanges', '', MB_ICONQUESTION or MB_YESNOCANCEL);
    if mr=mrCancel then Action:=caNone
      // сохраняем изменения
      else if mr=mrYes then
      begin
        case VM of
          Mode_Hex:
            begin
              Stream.Size:=KHexEditor1.Data.Size;
              KHexEditor1.SaveToUSEStream(Stream);
            end;
          Mode_Text:
            begin
              s:=Wide2Ansi(Memo1.Text);
              Stream.Position:=0;
              Stream.Size:=Length(s);
              Stream.Write(s[1], Length(s));
              s:='';
            end;
        end;
      end;
  end;

  if Action<>caNone then
    Stream.Free;
end;

procedure TFastViewForm.FormCreate(Sender: TObject);
begin
  if cache=nil then
    Exit;

  F:=Cache.Open();
  Stream:=F.OpenFile(F.GetItemName(ItemIdx), ACCES_READWRITE);
  if Stream<>nil then
  begin
    MM_HexClick(Sender);
  end;
end;

procedure TFastViewForm.MM_CodeDOSClick(Sender: TObject);
begin
//
end;

procedure TFastViewForm.MM_CodeWinClick(Sender: TObject);
begin
//
end;

procedure TFastViewForm.MM_HexClick(Sender: TObject);
begin
  KHexEditor1.Visible:=true;
  KHexEditor1.Align:=alClient;
  KHexEditor1.LoadFromUSEStream(Stream);
end;

procedure TFastViewForm.MM_HTMLClick(Sender: TObject);
begin
//
end;

procedure TFastViewForm.MM_MediaClick(Sender: TObject);
begin
//
end;

procedure TFastViewForm.MM_TextClick(Sender: TObject);
var
  buf: AnsiString;
begin
  Memo1.Visible:=true;
  Memo1.Align:=alClient;

  buf:='';
  if (Stream.Size<>0) then
  begin
    SetLength(buf, Stream.Size);
    Stream.Position:=0;
    Stream.Read(buf[1], Stream.Size);
  end;
  Memo1.Text:=Ansi2Wide(buf);
  buf:='';
end;

procedure TFastViewForm.MM_UnicodeClick(Sender: TObject);
begin
//
end;

procedure TFastViewForm.MM_UTF8Click(Sender: TObject);
begin
//
end;

procedure TFastViewForm.Show();
begin
  self:=TFastViewForm.Create(Application);
  self.ShowModal();
  self.Free;
end;

end.
