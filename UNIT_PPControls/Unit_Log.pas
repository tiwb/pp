unit Unit_PPLog;

interface
type
  TPPLog = class
  public
    procedure BeginLog;
    procedure EndLog;
    procedure WriteLogKickKill( KickID : integer; KickName : string );
    procedure WriteLogKickNotReady( KickID : integer; KickName : string );
    procedure WriteLogChooseServer( ServerID : integer );
    procedure WriteLogEnterLobby( LobbyID : integer );
    procedure WriteLogStartRoom( RoomID : integer );
    procedure WriteLogStartGame( PlayerCount : integer);
    procedure WriteLogEndGame;

  private
    LogFile : text;
    GameRound : integer;
    procedure WriteLog( s:string );
  end;

  var PPLog : TPPLog;


implementation
uses Unit_PPconfig,SysUtils;

procedure TPPLog.WriteLog(s:string);
begin
  Write(LogFile, TimeToStr(Time));
  Write(LogFile,chr(9));
  WriteLn(LogFile,s);
end;

procedure TPPLog.BeginLog;
begin
  Assign(LogFile,'log.txt');
  Append(LogFile);
  WriteLog('脚本开始运行');
  GameRound := 0;
end;

procedure TPPLog.EndLog;
begin
  WriteLog('脚本停止运行');
  CloseFile(LogFile);
end;

procedure TPPLog.WriteLogKickKill(KickID:integer;KickName:string);
begin
  if not PPConfig.ConfigData.LogKickKill then exit;
  WriteLog( '捣乱：' + IntToStr(KickID) + '号 ' + KickName );
end;

procedure TPPLog.WriteLogKickNotReady(KickID:integer;KickName:string);
begin
  if not PPConfig.ConfigData.LogKickNotReady then exit;
  WriteLog( '不准备：' + IntToStr(KickID) + '号 ' + KickName );
end;

procedure TPPLog.WriteLogChooseServer(ServerID:integer);
begin
  if not PPConfig.ConfigData.LogChooseServer then exit;
  WriteLog( '选择分区:' + IntToStr(ServerID) + '区' );
end;

procedure TPPLog.WriteLogEnterLobby(LobbyID:integer);
begin
  if not PPConfig.ConfigData.LogEnterLobby then exit;
  WriteLog( '进入服务器:' + IntToStr(LobbyID) );
end;

procedure TPPLog.WriteLogStartRoom(RoomID:integer);
begin
  if not PPConfig.ConfigData.LogStartRoom then exit;
  WriteLog( '开房间：' + IntToStr(RoomID) );
end;

procedure TPPLog.WriteLogStartGame( PlayerCount:integer );
begin
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLog( '游戏开始：' + IntToStr(PlayerCount) + '人' );
end;

procedure TPPLog.WriteLogEndGame;
begin
  inc( GameRound );
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLog( '游戏结束：' + IntToStr(GameRound) + '局' );
end;

begin
  PPLog := TPPLog.Create;
end.
