unit Unit_PPLog;

interface
type
  TPPLog = class
  public
    procedure BeginLog;
    procedure EndLog;
    procedure WriteLog( s:string );
    procedure WriteLogWithInt( s:string; i:Integer );

    procedure WriteLogKickKill( KickID : integer );
    procedure WriteLogKickNotReady( KickID : integer );
    procedure WriteLogChooseServer( ServerID : integer );
    procedure WriteLogEnterLobby( LobbyID : integer );
    procedure WriteLogStartRoom( RoomID : integer );
    procedure WriteLogStartGame( PlayerCount : integer);
    procedure WriteLogEndGame( Exp:integer) ;
    procedure WriteLogKickOdd( value : integer);
    procedure WriteLogPlayerEnter( value : integer);
    procedure WriteLogPlayerLeave( value:integer);
    procedure WriteLogInLobbyFromRoom;
    procedure WriteLogInLobbyFromGame;

  private
    LogFile : text;
  end;

  var PPLog : TPPLog;


implementation
uses Unit_PPconfig,Unit_PPControls,SysUtils,windows;

{$I-}

procedure TPPLog.WriteLog(s:string);
begin
  //PPControl.TextOutDebugInfo(s);
  Write(LogFile, DateTimeToStr(Date+Time));
  Write(LogFile,chr(9));
  WriteLn(LogFile,s);
end;

procedure TPPLog.WriteLogWithInt(s:string;i:integer);
begin
  WriteLog(s + chr(9) + IntToStr(i));
end;

procedure TPPLog.BeginLog;
begin
  AssignFile(LogFile,'log.txt');
  Append(LogFile);
  if IOResult<>0 then rewrite(LogFile);
  WriteLn(LogFile,'---------------------------------------------------------');
  WriteLog('脚本开始运行');
end;

procedure TPPLog.EndLog;
begin
  WriteLog('脚本停止运行');
  CloseFile(LogFile);
end;

procedure TPPLog.WriteLogKickKill(KickID:integer);
begin
  if not PPConfig.ConfigData.LogKickKill then exit;
  WriteLogWithInt('踢捣乱',KickID);
end;

procedure TPPLog.WriteLogKickNotReady(KickID:integer);
begin
  if not PPConfig.ConfigData.LogKickNotReady then exit;
  WriteLogWithInt('踢不准备',KickID );
end;

procedure TPPLog.WriteLogChooseServer(ServerID:integer);
begin
  if not PPConfig.ConfigData.LogChooseServer then exit;
  WriteLogWithInt( '选择分区',ServerID );
end;

procedure TPPLog.WriteLogEnterLobby(LobbyID:integer);
begin
  if not PPConfig.ConfigData.LogEnterLobby then exit;
  WriteLogWithInt( '进入服务器', LobbyID );
end;

procedure TPPLog.WriteLogStartRoom(RoomID:integer);
begin
  if not PPConfig.ConfigData.LogStartRoom then exit;
  WriteLogWithInt( '开房间' , RoomID );
end;

procedure TPPLog.WriteLogStartGame( PlayerCount:integer );
begin
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLogWithInt( '游戏开始' , PlayerCount );
end;

procedure TPPLog.WriteLogEndGame(Exp:integer);
begin
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLogWithInt( '游戏结束' , Exp );
end;

procedure TPPLog.WriteLogKickOdd(value:integer);
begin
  if not PPConfig.ConfigData.LogKickOdd then exit;
  WriteLogWithInt( '踢单号' , value );
end;

procedure TPPLog.WriteLogPlayerEnter(value:integer);
begin
  if not PPConfig.ConfigData.LogPlayerEnter then exit;
  WriteLogWithInt( '玩家进入' , value );
end;

procedure TPPLog.WriteLogPlayerLeave(value:integer);
begin
  if not PPConfig.ConfigData.LogPlayerEnter then exit;
  WriteLogWithInt( '玩家离开' , value );
end;

procedure TPPLog.WriteLogInLobbyFromRoom;
begin
  if not PPConfig.ConfigData.LogInLobby then exit;
  WriteLog('从房间回到大厅');
end;

procedure TPPLog.WriteLogInLobbyFromGame;
begin
  if not PPConfig.ConfigData.LogInLobby then exit;
  WriteLog('从游戏回到大厅');
end;


begin
  PPLog := TPPLog.Create;
end.
