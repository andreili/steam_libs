unit LoadingForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, SL_Mess, SL_Interfaces;

type
  TForm_Loading = class(TForm)
    ProgressBar1: TProgressBar;
    L_Operation: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowForm();
  end;

var
  Form_Loading: TForm_Loading = nil;

implementation

uses
  USE_Utils, MainForm;

{$R *.dfm}

procedure TForm_Loading.FormCreate(Sender: TObject);
begin
  Core.UI.ReloadControlsText(self);
end;

procedure TForm_Loading.ShowForm();
begin
  Form_Loading:=TForm_Loading.Create(Application);
  with Form_Loading do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
