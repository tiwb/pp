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
  WriteLog('�ű���ʼ����');
end;

procedure TPPLog.EndLog;
begin
  WriteLog('�ű�ֹͣ����');
  CloseFile(LogFile);
end;

procedure TPPLog.WriteLogKickKill(KickID:integer);
begin
  if not PPConfig.ConfigData.LogKickKill then exit;
  WriteLogWithInt('�ߵ���',KickID);
end;

procedure TPPLog.WriteLogKickNotReady(KickID:integer);
begin
  if not PPConfig.ConfigData.LogKickNotReady then exit;
  WriteLogWithInt('�߲�׼��',KickID );
end;

procedure TPPLog.WriteLogChooseServer(ServerID:integer);
begin
  if not PPConfig.ConfigData.LogChooseServer then exit;
  WriteLogWithInt( 'ѡ�����',ServerID );
end;

procedure TPPLog.WriteLogEnterLobby(LobbyID:integer);
begin
  if not PPConfig.ConfigData.LogEnterLobby then exit;
  WriteLogWithInt( '���������', LobbyID );
end;

procedure TPPLog.WriteLogStartRoom(RoomID:integer);
begin
  if not PPConfig.ConfigData.LogStartRoom then exit;
  WriteLogWithInt( '������' , RoomID );
end;

procedure TPPLog.WriteLogStartGame( PlayerCount:integer );
begin
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLogWithInt( '��Ϸ��ʼ' , PlayerCount );
end;

procedure TPPLog.WriteLogEndGame(Exp:integer);
begin
  if not PPConfig.ConfigData.LogStartEndGame then exit;
  WriteLogWithInt( '��Ϸ����' , Exp );
end;

procedure TPPLog.WriteLogKickOdd(value:integer);
begin
  if not PPConfig.ConfigData.LogKickOdd then exit;
  WriteLogWithInt( '�ߵ���' , value );
end;

procedure TPPLog.WriteLogPlayerEnter(value:integer);
begin
  if not PPConfig.ConfigData.LogPlayerEnter then exit;
  WriteLogWithInt( '��ҽ���' , value );
end;

procedure TPPLog.WriteLogPlayerLeave(value:integer);
begin
  if not PPConfig.ConfigData.LogPlayerEnter then exit;
  WriteLogWithInt( '����뿪' , value );
end;

procedure TPPLog.WriteLogInLobbyFromRoom;
begin
  if not PPConfig.ConfigData.LogInLobby then exit;
  WriteLog('�ӷ���ص�����');
end;

procedure TPPLog.WriteLogInLobbyFromGame;
begin
  if not PPConfig.ConfigData.LogInLobby then exit;
  WriteLog('����Ϸ�ص�����');
end;


begin
  PPLog := TPPLog.Create;
end.
