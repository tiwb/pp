unit Unit_PPConfig;

interface
uses SysUtils,Unit_PPScript,Classes,Dialogs;

type
  TTransferPacket = record
    //软件设置
    WorkMethord : integer;
    ConfigFile : string;
    RightClickToStart : boolean;
    WorkMode : integer;
    
    //基本设置
    StartPlayer : integer;
    WaittingTime : Cardinal;
    Notify : string;
    Player1Character : byte;
    Player2Character : byte;
    LockMouse : boolean;
    
    //开房设置
    RoomName : string;
    RoomPass : string;
    RoomNumber : integer;
    FreeRoom : boolean;
    RoomType : integer;
    MapIndex : integer;
    GateNumber : integer;

    //踢人设置
    AutoKickOdd : boolean;
    AutoKickTime : Cardinal;
    AutoKickKill : boolean;
    AutoKickNotify : string;

    //登陆设置
    LoginIndex : integer;
    LoginChannel : integer;
    ServerIndex : integer;
    ServerCount : integer;
    Player1Name : string;
    Player1Password : string;
    Player2Name : string;
    Player2Password : string;
    
    //脚本
    Script : string;

    //日志
    LogKickKill : boolean;
    LogKickNotReady : boolean;
    LogChooseServer : boolean;
    LogEnterLobby : boolean;
    LogStartRoom : boolean;
    LogStartEndGame : boolean;
    LogKickOdd : boolean;
    LogPlayerEnter : boolean;
    LogInLobby : boolean;

    //窗口
    WindowToClose : string;
    Windows : TStringList;

    //换色时间
    ChangeColorTime : word;
    KickNotReadyNotify : string;
    KickOddNotify : string;

    //刷段
    ShuaDuanUsername : string;
    ShuaDuanPassword : string;

    //开始延时
    StartDelay : word;
    AutoGoBack : boolean;

    CopyScreen : boolean;

  end;

  PTransferPacket = ^TTransferPacket;

  TPPConfig = class
  public
    ConfigData : PTransferPacket;
    Script : TPPScript;
    GamePath : string;
    CRC32 : LongWord;

    constructor Create;
    destructor Free;

    procedure SetFlashSetting;
    function GetFlashSetting:boolean;
    procedure Save(filename:string);
    procedure Load(filename:string);
  private
    function GetFlashByte(name:string):integer;
    function GetFlashBool(name:string):boolean;
    function GetFlashString(name:string):string;
  end;

var
  PPConfig : TPPConfig;
implementation


uses unit_mainform,Unit_Security,IniFiles;

const VER_PLATFORM_WIN32_WINDOWS = 1 ;

constructor TPPConfig.Create;
var Ini: TIniFile;
begin
  //文件校验码
  CRC32 := $38A07B6C;
  FileCRC32(ParamStr(0),CRC32);
  FileCRC32('KeyHook.dll',CRC32);
  
  ConfigData := new(PTransferPacket);
  ConfigData.Windows := TStringList.Create;
  Script := TPPScript.Create;

  Ini := TIniFile.Create( ExtractFilePath(ParamStr(0)) + 'config.ini' );
  try
    ConfigData.WorkMethord := Ini.ReadInteger('Config','WorkMethord',0);
    ConfigData.ConfigFile := Ini.ReadString('Config','ConfigFile','赛车06.cfg');
    ConfigData.RightClickToStart := Ini.ReadBool('Config','RightClickToStart',true)
  finally
    Ini.Free;
  end;
  
  try
    Load(ConfigData.ConfigFile);
  except else
    ShowMessage('读取配置文件时出错');
    try
      Load('defaultcfg.dat');
    except else
      ShowMessage('无法读取默认配置文件');
    end;
  end;
end;

destructor TPPConfig.Free;
var Ini: TIniFile;
begin
    Ini := TIniFile.Create( ExtractFilePath(ParamStr(0)) + 'config.ini' );
  try
    Ini.WriteInteger('Config','WorkMethord',ConfigData.WorkMethord);
    Ini.WriteString('Config','ConfigFile', ConfigData.ConfigFile);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
  Dispose(ConfigData);
end;

function TPPConfig.GetFlashByte(name:string):Integer;
var str : string;
begin
  str := MainForm.Flash1.GetVariable(name);
  if( str<>'undefined' ) then
    Result := StrToInt(str)
  else
    Result := -1;
end;

function TPPConfig.GetFlashBool(name:string):boolean;
begin
  Result := StrToBool(MainForm.Flash1.GetVariable(name)); 
end;

function TPPConfig.GetFlashString(name:string):string;
begin
  Result := MainForm.Flash1.GetVariable(name);
end;

function TPPConfig.GetFlashSetting:boolean;
begin
  Result := false;
  ConfigData.WorkMethord := GetFlashByte('Tabs.tab0.WorkMethord.selectedIndex');
  ConfigData.ConfigFile := GetFlashString('Tabs.tab0.ConfigFile.value');
  ConfigData.WorkMode := GetFlashByte('Tabs.tab0.WorkMode.value');

  ConfigData.StartPlayer := GetFlashByte('Tabs.tab1.StartPlayer.value');
  ConfigData.WaittingTime := GetFlashByte('Tabs.tab1.WaittingTime.text');
  ConfigData.Notify := GetFlashString('Tabs.tab1.Notify.text');
  ConfigData.Player1Character := GetFlashByte('Tabs.tab1.Player1.value');
  ConfigData.Player2Character := GetFlashByte('Tabs.tab1.Player2.value');
  ConfigData.LockMouse := GetFlashBool('Tabs.tab1.LockMouse.selected');
  ConfigData.AutoGoBack := GetFlashBool('Tabs.tab1.AutoGoBack.selected');
  ConfigData.StartDelay := GetFlashByte('Tabs.tab1.StartDelay.text');

  ConfigData.RoomName := GetFlashString('Tabs.tab2.RoomName.text');
  ConfigData.RoomPass := GetFlashString('Tabs.tab2.RoomPass.text');
  ConfigData.FreeRoom := GetFlashBool('Tabs.tab2.RoomFree.selected');
  ConfigData.RoomType := GetFlashByte('Tabs.tab2.RoomType.selectedIndex');
  ConfigData.GateNumber := GetFlashByte('Tabs.tab2.GateNumber.text');
  ConfigData.RoomNumber := GetFlashByte('Tabs.tab2.RoomNumber.text');
  ConfigData.MapIndex := GetFlashByte('Tabs.tab2.MapIndex.text');

  ConfigData.AutoKickOdd := GetFlashBool('Tabs.tab3.AutoKickOdd.selected');
  ConfigData.AutoKickTime := GetFlashByte('Tabs.tab3.AutoKickTime.text');
  ConfigData.AutoKickKill := GetFlashBool('Tabs.tab3.AutoKickKill.selected');
  ConfigData.AutoKickNotify := GetFlashString('Tabs.tab3.KillNotify.text');
  ConfigData.ChangeColorTime := GetFlashByte('Tabs.tab3.ChangeColorTime.text');
  ConfigData.KickNotReadyNotify := GetFlashString('Tabs.tab3.KickNotReadyNotify.text');
  ConfigData.KickOddNotify := GetFlashString('Tabs.tab3.KickOddNotify.text');

  ConfigData.LoginIndex := GetFlashByte('Tabs.tab4.AutoLogin.value');
  ConfigData.LoginChannel := GetFlashByte('Tabs.tab4.LoginChannel.value');
  ConfigData.ServerIndex := GetFlashByte('Tabs.tab4.ServerIndex.text');
  ConfigData.ServerCount := GetFlashByte('Tabs.tab4.ServerCount.text');
  ConfigData.Player1Name := GetFlashString('Tabs.tab4.Player1Name.text');
  ConfigData.Player1Password := GetFlashString('Tabs.tab4.Player1Pass.text');
  ConfigData.Player2Name := GetFlashString('Tabs.tab4.Player2Name.text');
  ConfigData.Player2Password := GetFlashString('Tabs.tab4.Player2Pass.text');

  ConfigData.Script := GetFlashString('Tabs.tab5.Script.text');


  ConfigData.LogKickKill := GetFlashBool('Tabs.tab6.LogKickKill.selected');
  ConfigData.LogKickNotReady := GetFlashBool('Tabs.tab6.LogKickNotReady.selected');
  ConfigData.LogChooseServer := GetFlashBool('Tabs.tab6.LogChooseServer.selected');
  ConfigData.LogEnterLobby := GetFlashBool('Tabs.tab6.LogEnterLobby.selected');
  ConfigData.LogStartRoom := GetFlashBool('Tabs.tab6.LogStartRoom.selected');
  ConfigData.LogStartEndGame := GetFlashBool('Tabs.tab6.LogStartEndGame.selected');
  ConfigData.LogKickOdd := GetFlashBool('Tabs.tab6.LogKickOdd.selected');
  ConfigData.LogPlayerEnter := GetFlashBool('Tabs.tab6.LogPlayerEnter.selected');
  ConfigData.LogInLobby := GetFlashBool('Tabs.tab6.LogInLobby.selected');
  ConfigData.CopyScreen := GetFlashBool('Tabs.tab6.CopyScreen.selected');

  ConfigData.WindowToClose := GetFlashString('Tabs.tab7.WindowToClose.text');

  ConfigData.ShuaDuanUsername := GetFlashString('Tabs.tab8.Username.text');
  ConfigData.ShuaDuanPassword := GetFlashString('Tabs.tab8.Password.text');

  ConfigData.Windows.Text := ConfigData.WindowToClose;
 
  if not Script.Load(ConfigData.Script) then
  begin
    ShowMessage('路线脚本' + Script.getLastError);
    exit;
  end;

  if Win32Platform  = VER_PLATFORM_WIN32_WINDOWS then PPConfig.ConfigData.WorkMethord := 1;
    
  Result := true;
end;

procedure TPPConfig.SetFlashSetting;
var sr: TSearchRec;
    files:string;
begin
  if Win32Platform  = VER_PLATFORM_WIN32_WINDOWS then PPConfig.ConfigData.WorkMethord := 1;

  with MainForm.Flash1 do
  begin
    //查找配置文件并传递给Flash
    files := '';
    if FindFirst('config\*.cfg', faAnyFile, sr) = 0 then
    begin
      if (sr.Attr and faDirectory )<>faDirectory then
        files := files + sr.name;
      while FindNext(sr)=0 do
      if (sr.Attr and faDirectory )<>faDirectory then
      begin
        files := files + ',' + sr.Name;
      end;
      FindClose(sr);
    end;

    SetVariable('Tabs.tab0.files', files );
    SetVariable('Tabs.tab0.filename', ConfigData.ConfigFile );
    SetVariable('Tabs.tab0.WorkMethord.selectedIndex', IntToStr(ConfigData.WorkMethord) );
    SetVariable('Tabs.tab0.WorkMode.selectedIndex', IntToStr(ConfigData.WorkMode) );

    SetVariable('Tabs.tab1.StartPlayer.selectedIndex',IntToStr(ConfigData.StartPlayer div 2));
    SetVariable('Tabs.tab1.WaittingTime.text',IntToStr(ConfigData.WaittingTime));
    SetVariable('Tabs.tab1.Notify.text',ConfigData.Notify);
    SetVariable('Tabs.tab1.Player1.selectedIndex',IntToStr(ConfigData.Player1Character));
    SetVariable('Tabs.tab1.Player2.selectedIndex',IntToStr(ConfigData.Player2Character));
    SetVariable('Tabs.tab1.LockMouse.selected',BooltoStr(ConfigData.LockMouse));
    SetVariable('Tabs.tab1.StartDelay.text',IntToStr(ConfigData.StartDelay));
    SetVariable('Tabs.tab1.AutoGoBack.selected',BooltoStr(ConfigData.AutoGoBack));

    SetVariable('Tabs.tab2.RoomName.text',ConfigData.RoomName);
    SetVariable('Tabs.tab2.RoomPass.text',ConfigData.RoomPass);
    SetVariable('Tabs.tab2.RoomFree.selected',BoolToStr(ConfigData.FreeRoom));
    SetVariable('Tabs.tas2.RoomType.selectedIndex',IntToStr(ConfigData.RoomType));
    SetVariable('Tabs.tab2.GateNumber.text',IntToStr(ConfigData.GateNumber));
    SetVariable('Tabs.tab2.RoomNumber.text',IntToStr(ConfigData.RoomNumber));
    SetVariable('Tabs.tab2.MapIndex.text',IntToStr(ConfigData.MapIndex));

    SetVariable('Tabs.tab3.ChangeColorTime.text',IntToStr(ConfigData.ChangeColorTime));
    SetVariable('Tabs.tab3.AutoKickOdd.selected',BoolToStr(ConfigData.AutoKickOdd));
    SetVariable('Tabs.tab3.AutoKickTime.text',IntToStr(ConfigData.AutoKickTime));
    SetVariable('Tabs.tab3.AutoKickKill.selected',BoolToStr(ConfigData.AutoKickKill));
    SetVariable('Tabs.tab3.KillNotify.text',ConfigData.AutoKickNotify);
    SetVariable('Tabs.tab3.KickNotReadyNotify.text',ConfigData.KickNotReadyNotify);
    SetVariable('Tabs.tab3.KickOddNotify.text',ConfigData.KickOddNotify);

    SetVariable('Tabs.tab4.AutoLogin.selectedIndex',IntToStr(ConfigData.LoginIndex));
    SetVariable('Tabs.tab4.LoginChannel.selectedIndex',IntToStr(ConfigData.LoginChannel));
    SetVariable('Tabs.tab4.ServerIndex.text',IntToStr(ConfigData.ServerIndex));
    SetVariable('Tabs.tab4.ServerCount.text',IntToStr(ConfigData.ServerCount));
    SetVariable('Tabs.tab4.Player1Name.text',ConfigData.Player1Name);
    SetVariable('Tabs.tab4.Player1Pass.text',ConfigData.Player1Password);
    SetVariable('Tabs.tab4.Player2Name.text',ConfigData.Player2Name);
    SetVariable('Tabs.tab4.Player2Pass.text',ConfigData.Player2Password);

    SetVariable('Tabs.tab5.Script.text',ConfigData.Script);

    SetVariable('Tabs.tab6.LogKickKill.selected',BoolToStr(ConfigData.LogKickKill));
    SetVariable('Tabs.tab6.LogKickNotReady.selected',BoolToStr(ConfigData.LogKickNotReady));
    SetVariable('Tabs.tab6.LogChooseServer.selected',BoolToStr(ConfigData.LogChooseServer));
    SetVariable('Tabs.tab6.LogEnterLobby.selected',BoolToStr(ConfigData.LogEnterLobby));
    SetVariable('Tabs.tab6.LogStartRoom.selected',BoolToStr(ConfigData.LogStartRoom));
    SetVariable('Tabs.tab6.LogStartEndGame.selected',BoolToStr(ConfigData.LogStartEndGame));
    SetVariable('Tabs.tab6.LogKickOdd.selected',BoolToStr(ConfigData.LogKickOdd));
    SetVariable('Tabs.tab6.LogPlayerEnter.selected',BoolToStr(ConfigData.LogPlayerEnter));
    SetVariable('Tabs.tab6.LogInLobby.selected',BoolToStr(ConfigData.LogInLobby));
    SetVariable('Tabs.tab6.CopyScreen.selected',BoolToStr(ConfigData.CopyScreen));

    SetVariable('Tabs.tab7.WindowToClose.text',ConfigData.WindowToClose);

    SetVariable('Tabs.tab8.Username.text', ConfigData.ShuaDuanUsername);
		SetVariable('Tabs.tab8.Password.text', ConfigData.ShuaDuanPassword);

  end;
end;

procedure TPPConfig.Save( filename:string );
var m : TMemoryStream;
    w : TWriter;
begin
  m := TMemoryStream.Create;
  w := TWriter.Create(m,1024);
  try
    w.WriteString('TIWB');
    w.WriteInteger(400);
    w.WriteInteger(ConfigData.StartPlayer);
    w.WriteInteger(ConfigData.WaittingTime);
    w.WriteInteger(ConfigData.StartDelay);
    w.WriteString(ConfigData.Notify);
    w.WriteInteger(ConfigData.Player1Character);
    w.writeInteger(ConfigData.Player2Character);
    w.WriteBoolean(configData.LockMouse);
    w.WriteBoolean(ConfigData.AutoGoBack);

    w.WriteString(ConfigData.RoomName);
    w.WriteString(ConfigData.RoomPass);
    w.WriteInteger(ConfigData.RoomNumber);
    w.WriteBoolean(ConfigData.FreeRoom);
    w.WriteInteger(ConfigData.RoomType);
    w.WriteInteger(ConfigData.MapIndex);
    w.WriteInteger(ConfigData.GateNumber);

    w.WriteInteger(ConfigData.ChangeColorTime);
    w.WriteInteger(ConfigData.AutoKickTime);
    w.WriteString(ConfigData.KickNotReadyNotify);
    w.WriteBoolean(ConfigData.AutoKickOdd);
    w.WriteString(ConfigData.KickOddNotify);
    w.WriteBoolean(ConfigData.AutoKickKill);
    w.WriteString(ConfigData.AutoKickNotify);

    w.WriteInteger(ConfigData.LoginIndex);
    w.WriteInteger(ConfigData.ServerIndex);
    w.WriteInteger(ConfigData.ServerCount);
    w.WriteString(str_encrypt(ConfigData.Player1Name));
    w.WriteString(str_encrypt(ConfigData.Player1Password));
    w.WriteString(str_encrypt(ConfigData.Player2Name));
    w.WriteString(str_encrypt(ConfigData.Player2Password));

    w.WriteString(ConfigData.Script);

    w.WriteBoolean(ConfigData.LogKickKill);
    w.WriteBoolean(ConfigData.LogKickNotReady);
    w.WriteBoolean(ConfigData.LogChooseServer);
    w.WriteBoolean(ConfigData.LogEnterLobby);
    w.WriteBoolean(ConfigData.LogStartRoom);
    w.WriteBoolean(ConfigData.LogStartEndGame);
    w.WriteBoolean(ConfigData.LogKickOdd );
    w.WriteBoolean(ConfigData.LogPlayerEnter);
    w.WriteBoolean(ConfigData.LogInLobby);
    w.WriteBoolean(ConfigData.CopyScreen);

    w.WriteString(ConfigData.WindowToClose);

    // ver 4.00
    w.WriteInteger(ConfigData.WorkMode);
    w.WriteInteger(ConfigData.LoginChannel);
    w.WriteString(ConfigData.ShuaDuanUsername);
    w.WriteString(ConfigData.ShuaDuanPassword);

    w.FlushBuffer;
    m.SaveToFile('config\' + filename);
  finally
    m.Free;
  end;


end;

procedure TPPConfig.Load( filename:string );
var m : TMemoryStream;
  r : TReader;
  ver : Integer;
begin

  m := TMemoryStream.Create;
  r := TReader.Create(m,1024);
  try
    m.LoadFromFile('config\' + filename );
    r.Position := 0;

    if r.ReadString <> 'TIWB' then
    begin
      ShowMessage('配置版本不正确!');
      exit;
    end;

    ver := r.ReadInteger;

		if ver > 400 then
    begin
      ShowMessage('配置版本不正确!');
      exit;
    end;

    ConfigData.StartPlayer := r.ReadInteger;
    ConfigData.WaittingTime := r.ReadInteger;
    ConfigData.StartDelay :=  r.ReadInteger;
    ConfigData.Notify := r.ReadString;
    ConfigData.Player1Character := r.ReadInteger;
    ConfigData.Player2Character := r.ReadInteger;
    ConfigData.LockMouse := r.ReadBoolean;
    ConfigData.AutoGoBack := r.ReadBoolean;

    ConfigData.RoomName := r.ReadString;
    ConfigData.RoomPass := r.ReadString;
    ConfigData.RoomNumber := r.ReadInteger;
    ConfigData.FreeRoom := r.ReadBoolean;
    ConfigData.RoomType := r.ReadInteger;
    ConfigData.MapIndex := r.ReadInteger;
    ConfigData.GateNumber := r.ReadInteger;

    ConfigData.ChangeColorTime := r.ReadInteger;
    ConfigData.AutoKickTime := r.ReadInteger;
    ConfigData.KickNotReadyNotify := r.ReadString;
    ConfigData.AutoKickOdd := r.ReadBoolean;
    ConfigData.KickOddNotify := r.ReadString;
    ConfigData.AutoKickKill := r.ReadBoolean;
    ConfigData.AutoKickNotify := r.ReadString;

    ConfigData.LoginIndex := r.ReadInteger;
    ConfigData.ServerIndex := r.ReadInteger;
    ConfigData.ServerCount := r.ReadInteger;
    ConfigData.Player1Name := str_decrypt(r.ReadString);
    ConfigData.Player1Password := str_decrypt(r.ReadString);
    ConfigData.Player2Name := str_decrypt(r.ReadString);
    ConfigData.Player2Password := str_decrypt(r.ReadString);

    ConfigData.Script := r.ReadString;

    ConfigData.LogKickKill := r.ReadBoolean;
    ConfigData.LogKickNotReady := r.ReadBoolean;
    ConfigData.LogChooseServer := r.ReadBoolean;
    ConfigData.LogEnterLobby := r.ReadBoolean;
    ConfigData.LogStartRoom := r.ReadBoolean;
    ConfigData.LogStartEndGame := r.ReadBoolean;
    ConfigData.LogKickOdd := r.ReadBoolean;
    ConfigData.LogPlayerEnter := r.ReadBoolean;
    ConfigData.LogInLobby := r.ReadBoolean;
    ConfigData.CopyScreen := r.ReadBoolean;

    ConfigData.WindowToClose := r.ReadString;
    ConfigData.Windows.Text := ConfigData.WindowToClose;

    if ver>=400 then
    begin
      ConfigData.WorkMode := r.ReadInteger;
      ConfigData.LoginChannel := r.ReadInteger;
      ConfigData.ShuaDuanUsername := r.ReadString;
      ConfigData.ShuaDuanPassword := r.ReadString;
    end else begin
      ConfigData.WorkMode := 0;
      ConfigData.LoginChannel := 1;
      ConfigData.ShuaDuanUsername := '';
      ConfigData.ShuaDuanPassword := '天一智能脚本';
    end;

    //ShowMessage( ConfigData.Player1Password );
    //ShowMessage( ConfigData.Player2Password );
  finally
    m.Free;
  end;

  if Win32Platform  = VER_PLATFORM_WIN32_WINDOWS then PPConfig.ConfigData.WorkMethord := 1;

  if not Script.Load(ConfigData.Script) then
    ShowMessage('路线脚本' + Script.getLastError);
end;

begin
  PPConfig := TPPConfig.Create;
end.
