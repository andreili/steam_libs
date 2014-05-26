program SteamLite_one;



uses
  Forms,
  SysUtils,
  LoadingForm in 'Forms\LoadingForm.pas' {Form_Loading},
  MainForm in 'Forms\MainForm.pas' {Form_Main},
  AppPropertiesForm in 'Forms\AppPropertiesForm.pas' {Form_AppProperties},
  Form_ViewerExtract in 'Forms\Form_ViewerExtract.pas' {ExtractForm},
  Form_CacheViewer in 'Forms\Form_CacheViewer.pas' {CacheViewerForm},
  Form_FastView in 'Forms\Form_FastView.pas' {FastViewForm},
  Form_FileProperties in 'Forms\Form_FileProperties.pas' {PropertiesForm},
  SL_Interfaces in 'SL_Interfaces.pas',
  Int_Applications in 'Interfaces\Int_Applications.pas',
  Int_ApplicationsList in 'Interfaces\Int_ApplicationsList.pas',
  Int_Core in 'Interfaces\Int_Core.pas',
  Int_File in 'Interfaces\Int_File.pas',
  Int_FileFormat_GCF in 'Interfaces\Int_FileFormat_GCF.pas',
  Int_FileFormats in 'Interfaces\Int_FileFormats.pas',
  Int_GameConverter in 'Interfaces\Int_GameConverter.pas',
  Int_Log in 'Interfaces\Int_Log.pas',
  Int_Network in 'Interfaces\Int_Network.pas',
  Int_p2p in 'Interfaces\Int_p2p.pas',
  Int_Settings in 'Interfaces\Int_Settings.pas',
  Int_Translation in 'Interfaces\Int_Translation.pas',
  Int_Utils in 'Interfaces\Int_Utils.pas',
  Int_Works in 'Interfaces\Int_Works.pas',
  Int_UI in 'Interfaces\Int_UI.pas',
  Form_AppPrepare in 'Forms\Form_AppPrepare.pas' {AppPrepareForm};

{$R WindowsXP.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm_Main, Form_Main);
  Application.Run;
end.
