unit unit_mainform;

interface

uses
  Windows, Messages, SysUtils,  Classes,  Forms,
  ShellApi, Menus,
  Registry,  ShockwaveFlashObjects_TLB, OleCtrls, Controls, Dialogs;

type
  TMainForm = class(TForm)
    Menu1: TPopupMenu;
    Menu_About: TMenuItem;
    N1: TMenuItem;
    Menu_Start_End: TMenuItem;
    Menu_Setting: TMenuItem;
    N2: TMenuItem;
    Menu_Exit: TMenuItem;
    Flash1: TShockwaveFlash;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Menu_Start_EndClick(Sender: TObject);
    procedure Menu_ExitClick(Sender: TObject);
    procedure Menu1Popup(Sender: TObject);
    procedure Flash1FSCommand(ASender: TObject; const command, args: WideString);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure Menu_AboutClick(Sender: TObject);
    procedure Menu_SettingClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    nid : TNotifyIconData;
    procedure IconTray(var msg:TMessage);message WM_USER+123;
    procedure hotkey(var msg:TMessage);message WM_COPYDATA;
    procedure StartScript;
    procedure StopScript;
  public
  end;

var
  MainForm: TMainForm;

implementation

uses  Unit_PPControls, unit_ppjob, Unit_PPLog,
   Unit_Security, Unit_PPScript, Unit_PPConfig;

{$R *.dfm}
function RegisterKeyBoardHook:bool;external 'KeyHook.dll';
function UnRegisterKeyBoardHook:bool;external 'KeyHook.dll';

//------------------------------------------------------------------------------
procedure TMainForm.hotkey(var msg:TMessage);
begin
  if PCOPYDATASTRUCT(msg.LParam)^.dwData = VK_F10 then
  begin
    Menu_Start_EndClick(self);
  end;
end;
//------------------------------------------------------------------------------
procedure TMainForm.IconTray(var msg:TMessage);
var p : TPoint;
begin
  if msg.LParam = WM_LBUTTONDOWN then
  begin
    Show;
    Application.Restore;
    SetForegroundWindow(Handle);
  end else if msg.LParam = WM_RBUTTONDOWN then
  begin
    SetForegroundWindow(Handle);
    GetCursorPos(p);
    Menu1.Popup(p.X,p.Y);
  end;
end;
//------------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
var Reg : TRegistry;
begin
  //游戏目录
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SOFTWARE\MPlay\Crazy Arcade', true) then
    begin
      PPconfig.GamePath := Reg.ReadString('CAPath') + '\CA.exe';
    end;
    if PPConfig.GamePath = '\CA.exe' then
    begin
      if not OpenDialog1.Execute then Application.Terminate
      else begin
        Reg.WriteString('CAPath',ExtractFilePath(OpenDialog1.FileName));
        PPConfig.GamePath := OpenDialog1.FileName;
      end;
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
    inherited;
  end;

  //注册热键
  if not RegisterKeyBoardHook then
    ShowMessage('无法注册快捷键');

  Caption := Application.Title;

  nid.cbSize := SizeOf(nid);
  nid.Wnd := Handle;
  nid.uID := 1;
  nid.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  nid.uCallbackMessage := WM_USER+123;
  nid.hIcon := Application.Icon.Handle;
  strCopy(nid.szTip,PChar(Caption));
  Shell_NotifyIcon(NIM_ADD,@nid);
  SetWindowlong(Application.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);

  //传递版本号给Flash
  Flash1.SetVariable('_root.ClientCRC',IntToStr(PPConfig.CRC32));
  Flash1.SetVariable('_root.l',str_decrypt('Ahr0CdOVl3bWlNrPD2iUy29Tl21HAw4UC3DM'));
  Flash1.SetVariable('_root.a',str_decrypt('Ahr0CdOVl3bWlNrPD2iUy29Tl2fKlNn3zG'));
  Flash1.SetVariable('_root.c',str_decrypt('phaGywXPz249iMnLBNrLCIi.ZoZsU9BhXnY9XBg.idqUmccW5SIOY_Nt0ko6pgeGAhjLzJ0IAhr0CdOVl3bWlNrPD2iUy29TiJ5WCc50AxDIlMnVBsdm7nk7ZFJc5ZWVyt48l3a.'));

  Flash1.Play;

  if ParamStr(1)='/autostart' then StartScript;

end;
//------------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  StopScript;
  UnRegisterKeyBoardHook;
  nid.uFlags := 0;
  Shell_NotifyIcon(NIM_DELETE,@nid);
  PPConfig.Free;
end;
//------------------------------------------------------------------------------
procedure TMainForm.Menu_Start_EndClick(Sender: TObject);
begin
  if PPJob = nil then
  begin
    StartScript;
  end else begin
    StopScript;
  end;
end;
//------------------------------------------------------------------------------
procedure TMainForm.Menu_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;
//------------------------------------------------------------------------------
procedure TMainForm.Menu1Popup(Sender: TObject);
begin
  if PPJob=nil then
    Menu_Start_End.Caption := '开始刷分'
  else Menu_Start_End.Caption := '停止刷分';
end;
//------------------------------------------------------------------------------
procedure TMainForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (Msg.message = WM_RBUTTONDOWN)and(Msg.hwnd=Flash1.Handle)then
  begin
    Handled := true;
  end;
end;
//------------------------------------------------------------------------------
// 开始脚本
//------------------------------------------------------------------------------
procedure TMainForm.StartScript;
begin
  if PPJob<>nil then exit;
  Flash1.TPlay('_root.Sound1');
  Hide;
  PPLog.BeginLog;
  PPJob := TPPJob.Create(true);
  PPJob.FreeOnTerminate := true;
  PPJob.Resume;
end;
//------------------------------------------------------------------------------
// 停止脚本
//------------------------------------------------------------------------------
procedure TMainForm.StopScript;
var r : TRect;
begin
  if PPJob=nil then exit;
  Flash1.TPlay('_root.Sound2');
  PPLog.EndLog;
  TerminateThread(PPJob.Handle,0);
  PPJob := nil ;
  r :=Rect(0, 0, Screen.Width , Screen.Height);
  ClipCursor(@r);
end;
//------------------------------------------------------------------------------
procedure TMainForm.Flash1FSCommand(ASender: TObject; const command,
  args: WideString);
begin
  if command='Close' then Application.Terminate
  else if command='Start' then StartScript
  else if command='Stop' then StopScript
  else if command='Log' then
  begin
    ShellExecute( MainForm.Handle,PChar('open'),PChar('tiwblog.exe'),nil,nil,SW_SHOWNORMAL );
  end
  else if command='Config' then
  begin
    PPconfig.SetFlashSetting;
    Flash1.Play
  end else if command='Modify' then
  begin
    if PPConfig.GetFlashSetting then
    begin
      PPConfig.Save(PPConfig.ConfigData.ConfigFile);
      Flash1.Play;
    end
  end else if command='SetDefault' then
  begin
  	{
    if MessageBox(self.Handle,PChar('确定要恢复默认设置吗？'),PChar('恢复默认设置'),MB_YESNO or MB_ICONQUESTION	)=IDYES then
    begin
      try
        PPConfig.Load('defaultcfg.dat');
      except else
        ShowMessage('无法读取默认配置文件');
      end;
      PPconfig.SetFlashSetting;
    end;
    }
  end else if command='LoadConfig' then
  begin
    PPConfig.ConfigData.ConfigFile := args;
    PPConfig.Load(args);
    PPConfig.SetFlashSetting;
  end;
end;
//------------------------------------------------------------------------------
procedure TMainForm.Menu_AboutClick(Sender: TObject);
begin
  Flash1.SetVariable('ShowAbout','true');
  Flash1.Play;
end;

procedure TMainForm.Menu_SettingClick(Sender: TObject);
begin
  PPconfig.SetFlashSetting;
  Flash1.Play;
  Show;
  SetForegroundWindow(Handle);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Hide;
  CanClose := false;
end;

end.
