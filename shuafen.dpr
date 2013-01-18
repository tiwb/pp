program shuafen;

uses
  SysUtils,
  Forms,
  Windows,
  Messages,
  Dialogs,
  unit_mainform in 'unit_mainform.pas' {MainForm},
  unit_ppjob in 'unit_ppjob.pas',
  Unit_PPControls in 'UNIT_PPControls\Unit_PPControls.pas',
  Unit_PPScript in 'UNIT_PPControls\Unit_PPScript.pas',
  unit_PPKickPlayer in 'UNIT_PPControls\unit_PPKickPlayer.pas',
  Unit_Security in 'UNIT_PPControls\Unit_Security.pas',
  Unit_PPConfig in 'UNIT_PPControls\Unit_PPConfig.pas',
  Unit_PPSayString in 'UNIT_PPControls\Unit_PPSayString.pas',
  Unit_PPLog in 'UNIT_PPControls\Unit_PPLog.pas';

{$R *.res}

begin
  Application.Title := '天一网络';
  if FindWindow('TMainForm','天一智能脚本')>0 then
  begin
    ShowMessage('天一智能脚本 已经启动');
    exit;
  end;

  Application.Initialize;
  Application.Title := '天一智能脚本';
  Application.CreateForm(TMainForm, MainForm);
  Application.OnMessage := MainForm.ApplicationEvents1Message;
  Application.Run;

end.
