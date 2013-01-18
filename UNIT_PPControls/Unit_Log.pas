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
  WriteLog('�ű���ʼ����');
  GameRound := 0;
end;

procedure TPPLog.EndLog;
begin
  WriteLog('�ű�ֹͣ����');
  CloseFile(LogFile);
end;

procedure TPPLog.WriteLogKickKill(KickID:integer;KickName:string);
begin
  if not PPConfig.ConfigData.LogKickKill then exit;
  WriteLog( '���ң�' + IntToStr(KickID) + '�� ' + KickName );
end;

procedure TPPLog.WriteLogKickNotReady(KickID:integer;KickName:string);
begin
  if not PPConfig.ConfigData.LogKickNotReady then exit;
  WriteLog( '��׼����' + IntToStr(KickID) + '�� ' + KickName );
end;

procedure TPPLog.WriteLogChooseServer(ServerID:integer);
begin
  if not PPConfig.ConfigData.LogChooseServer then exit;
  WriteLog( 'ѡ�����:' + IntToStr(ServerID) + '��' );
end;

procedure TPPLog.WriteLogEnterLobby(LobbyID:integer);
begin
  if not PPConfig.ConfigData.LogEnterLobby then exit;
  WriteLog( '���������:' + IntToStr(LobbyID) );
end;

procedure TPPLog.WriteLogStartRoom(RoomID:integer);
begin
  if not PPConfig.ConfigData.LogStartRoom then exit;
  WriteLog( '�����䣺' + IntToStr(RoomID) );
end;

procedure TPPLog.WriteLogStartGame( PlayerCount:integer );
begin
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLog( '��Ϸ��ʼ��' + IntToStr(PlayerCount) + '��' );
end;

procedure TPPLog.WriteLogEndGame;
begin
  inc( GameRound );
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLog( '��Ϸ������' + IntToStr(GameRound) + '��' );
end;

begin
  PPLog := TPPLog.Create;
end.
