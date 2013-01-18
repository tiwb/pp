unit unit_ppjob;

interface

uses
  Classes,Windows,mmSystem,SysUtils,ShellAPI,Messages,Registry;

type
	TGameState = ( GameState_Unknown, GameState_InGame, GameState_InRoom, GameState_InLobby, GameState_ChoosingServer );

  
  TPPJob = class(TThread)
  public
    ServerIndex : integer;
    ChangeServer : integer;
    CodeLocal : integer;
    CodeRemote : integer;
    
  protected
    procedure Execute; override;
    procedure ShuaDuan;

  private
  	GameState : TGameState;
		LastTime : DWORD;
    ExitTime : DWORD;
    
  end;

var
  PPJob : TPPJob;
implementation

uses Unit_PPControls, Unit_PPScript, unit_PPKickPlayer,
  Unit_PPConfig, Unit_Security, Unit_PPSayString, Unit_PPLog;

var LabelCount : byte;


function EnumChildProc(H: HWnd; P : LParam): Boolean; stdcall;
var
  Buffer: array[0..255] of Char;
begin
  Result :=true;
  GetClassName(H,Buffer,255);

  if StrPas(Buffer)='Static' then
  begin
    inc(LabelCount);
    if LabelCount=PPConfig.ConfigData.LoginIndex then
    begin
      PostMessage(H,WM_LBUTTONDOWN,MK_LBUTTON,0);
      PostMessage(H,WM_LBUTTONUP,MK_LBUTTON,0);
      PostMessage(H,WM_LBUTTONDOWN,MK_LBUTTON,0);
      PostMessage(H,WM_LBUTTONUP,MK_LBUTTON,0);
      Result:=false;
      PPLog.WriteLogChooseServer(LabelCount);
    end;
  end;
end;

procedure TPPJob.ShuaDuan;
var i,j,k : integer;
begin
  if( ChangeServer>0 ) then
  begin
  	PPControl.ExitRoom;
    exit;
  end;

	for i:=14 downto 0 do
  begin
  	j := PPControl.GetMessageNumber(507-i*13);
    if (j>0) then CodeLocal:=j;
    if (j<0) then CodeRemote:=j and $7FFFFFFF;
  end;
  
	PPControl.TextOutDebugInfo(IntToStr(CodeLocal),10,50);
	PPControl.TextOutDebugInfo(IntToStr(CodeRemote),10,70);

  if (ExitTime>0) and (timeGetTime-ExitTime>10000) then
  begin
  	ChangeServer:=2;
    ExitTime:=0;
  end;

	if( timeGetTime - LastTime > 5000 ) then
  begin
  	PPControl.SayString('/to ' + PPConfig.ConfigData.ShuaDuanUsername);
    Sleep(100);
  	PPControl.SayString(PPConfig.ConfigData.ShuaDuanPassword, false);
    LastTime := timeGetTime;
  end;

  if( ExitTime>0 ) then begin
  	PPControl.SayString('/start');
    Sleep(1000);
    exit;
  end;

  if (CodeLocal<>0) and (CodeLocal=CodeRemote) then
  begin
    ExitTime := timeGetTime;
  end;
end;


procedure TPPJob.Execute;
var
  i,j,k : integer;
  PlayerStates_Time : array[1..8] of DWORD;
  PlayerReadyCount : byte;

  PlayerCount : byte;
  Last_PlayerCount : byte;

  ChangeColorTime : DWORD;

  LoginForm : HWND;
  ADwindow : HWND;
  RoomNumber : integer; 

  WaitingTime : DWORD;
  StartTime : DWORD;
  StartPlayerMin : byte;
  DoorClosedCount : byte;

  Reg : TRegistry;

  WorkMethordBackUp : integer;

begin
  ServerIndex := 0;
  ChangeServer := 0;
  PlayerCount := 0;
  ExitTime := 0;
  fillchar(PPControl.PlayerStates,sizeof(PPControl.PlayerStates),0);

  PPControl.InitGameWindow;

  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  Reg.OpenKey('\SOFTWARE\MPlay\Crazy Arcade', true);

  while not Terminated  do
  begin
//------------------------------------------------------------------------------
//  �����Ϸ����
//------------------------------------------------------------------------------
    if GetForegroundWindow<>PPControl.GameWindow then
    begin
      GameState := GameState_Unknown;

      //�رմ���
      i:=0;
      while i<PPConfig.ConfigData.Windows.Count do
      begin
        ADWindow := FindWindow(nil,PChar(PPConfig.ConfigData.Windows[i]));
        if ADWindow>0 then
        begin
          PostMessage(ADWindow,WM_CLOSE,0,0);
          break;
        end;
        inc(i)
      end;
      if i<PPConfig.ConfigData.Windows.Count then continue;

      //���ҵ�½����
      LoginForm := FindWindow('CAMSLogin',nil);
      if LoginForm>0 then
      begin
        LabelCount := 0;
        EnumChildWindows(LoginForm, @EnumChildProc, 0);

        //�������ʧ��
        ADWindow := FindWindow(nil,'����ʧ��'+#13+#10);
        if ADWindow>0 then PostMessage(ADWindow,WM_CLOSE,0,0);
      end
      else if not PPControl.InitGameWindow then
      begin
        //��һ��ESC��
        PPControl.KeyDown(VK_ESCAPE);
        PPControl.KeyUp(VK_ESCAPE);
        //������Ϸ
        LoginForm := FindWindow('CAMSLogin',nil);
        if( LoginForm=0 ) then
          ShellExecute(0,PChar('open'),PChar(PPConfig.GamePath),nil,PChar(ExtractFilePath(PPConfig.GamePath)),SW_NORMAL);
        Sleep(5000);
      end else
      begin
        if PPConfig.ConfigData.AutoGoBack then
          PostMessage(PPControl.GameWindow,WM_SYSCOMMAND,SC_MAXIMIZE,0);
      end;

      Sleep(1000);

    end;

    //�������

    if (PPConfig.ConfigData.WorkMethord=1) and PPConfig.ConfigData.LockMouse then PPControl.LockMouse;

//------------------------------------------------------------------------------
//  �Ի���
//------------------------------------------------------------------------------
    if PPControl.isDialogShow then
    begin
      PPControl.MouseClick(363,368);
      Sleep(100);
      continue;
    end;
//------------------------------------------------------------------------------
//  ��Ϸ�� ��ѭ��
//------------------------------------------------------------------------------
    if PPControl.isGamePlaying then
    begin
      if GameState = GameState_InRoom then
      begin
        PPLog.WriteLogStartGame(PlayerCount);
        PPConfig.Script.Reset;
        GameState := GameState_InGame;
        if( PPConfig.ConfigData.WorkMode=1) then ChangeServer:=2;
      end;

      while PPControl.isGamePlaying do
      begin
        //TextOut(PPControl.GameScreen,0,0,PChar('playing'),5);
        PPConfig.Script.Execute;
        PPControl.GetLastScoreState;
        if PPControl.isDialogShow then
          PPControl.MouseClick(363,368);
      end;

      if GameState = GameState_InGame then
        PPLog.WriteLogEndGame(PPControl.LastExp);

    end;
//------------------------------------------------------------------------------
//  ��������
//------------------------------------------------------------------------------
    if PPControl.isInChattingRoom then
    begin
      PPControl.TextOutDebugInfo('In Chat rom');

      PPControl.KeyDown(VK_ESCAPE);
      PPControl.KeyUp(VK_ESCAPE);

      if (ChangeServer>0) then
      begin
        dec(ChangeServer);
        PPControl.MouseClick(110,585);
        Sleep(3000);
        continue;
      end;
  
      if GameState = GameState_ChoosingServer then
      begin
        //��������˴���ķ����������˳�
        if ServerIndex>PPConfig.ConfigData.ServerIndex+PPConfig.ConfigData.ServerCount then
        begin
          PPControl.MouseClick(110,585);
          Sleep(3000);
          continue;
        end;
      end;

      if GameState = GameState_InRoom then
        PPLog.WriteLogInLobbyFromRoom;

      if GameState = GameState_InGame then
        PPLog.WriteLogInLobbyFromGame;

      Sleep(500);

      //���÷�������������״̬
      PlayerCount := 0;
      FillChar(PPControl.PlayerStates,sizeof(PPControl.PlayerStates),0);
      
      GameState := GameState_InLobby;

      //������
      if PPConfig.ConfigData.RoomName<>'' then
        PPControl.StartRoom(PPConfig.ConfigData.RoomName,PPConfig.ConfigData.RoomPass,PPConfig.ConfigData.FreeRoom, PPConfig.ConfigData.RoomType);


    end;
//------------------------------------------------------------------------------
//  �ӱ��״̬���뷿��
//------------------------------------------------------------------------------
    if PPControl.isInRoom then
    begin
      //���㷿�����
      RoomNumber := PPControl.GetRoomNumber;

      // ˢ����
      CodeLocal := 0;
      CodeRemote := 0;
      ExitTime := 0;

      //�Ӵ������뷿��
      if GameState=GameState_InLobby then
      begin
        //�жϷ����Ƿ���Ч
        if(RoomNumber>0)and(RoomNumber>PPConfig.ConfigData.RoomNumber)then
        begin
          PPControl.ExitRoom;
          continue;
        end;

        //��÷�������״̬
        PlayerCount := PPControl.getPlayerCount;

        //ѡ���ͼ
        if PPControl.SelectMap(PPConfig.ConfigData.MapIndex) then
        begin
          PPLog.WriteLogStartRoom( RoomNumber );
        end else begin
          PPControl.ExitRoom;
          continue;
        end;
      end else begin
      // if not PPControl.isMapOK(PPConfig.ConfigData.MapIndex) then PPControl.SelectMap(PPConfig.ConfigData.MapIndex);
      end;

      //ѡ������
      try
        if(PPConfig.ConfigData.Player1Character>0)and
          ((GameState<>GameState_InGame)or
          (StrToInt(Reg.ReadString('LastSelectedBomber00'))<>PPConfig.ConfigData.Player1Character-1))then
        begin
          Sleep(1000);
          PPControl.SelectCharacter(PPConfig.ConfigData.Player1Character,false);
        end;
        if(PPConfig.ConfigData.Player2Character>0)and
          ((GameState<>GameState_InGame)or
          (StrToInt(Reg.ReadString('LastSelectedBomber01'))<>PPConfig.ConfigData.Player2Character-1))then
        begin
          Sleep(1000);
          PPControl.SelectCharacter(PPConfig.ConfigData.Player2Character,true);
        end;
      except else
      end;

      //��ʼ����������

      // FillChar(PPControl.PlayerStates,sizeof(PPControl.PlayerStates),0);
      for i:=1 to 8 do PlayerStates_Time[i] := TimeGetTime;
      WaitingTime := TimeGetTime;
      PPKickPlayer.Init;
      PPSayString.Clear;
      ChangeColorTime := 0;
      StartTime := 0;

      //�����ж�
      if GameState = GameState_InGame then
      if PPConfig.ConfigData.AutoKickKill and(PPControl.LastScoreState>0)then
      begin
        PPLog.WriteLogKickKill(PPControl.LastScoreState);
        if(PPControl.PlayerStates[PPControl.LastScoreState]>1) then
        begin
          PPSayString.Say(Format(PPConfig.ConfigData.AutoKickNotify,[PPControl.LastScoreState]));
          PPKickPlayer.Kick(PPControl.LastScoreState);
        end;
      end;
 
      GameState := GameState_InRoom;

      //���㿪ʼ����
      if PPConfig.ConfigData.StartPlayer > 0 then
        StartPlayerMin := PPConfig.ConfigData.StartPlayer
      else if RoomNumber>100 then
        StartPlayerMin := 4
      else if RoomNumber>50 then
        StartPlayerMin := 6
      else StartPlayerMin := 8;

      Sleep(100);

      PPControl.MouseClick(0,0);
      
//------------------------------------------------------------------------------
//   �����е�ѭ��
//------------------------------------------------------------------------------
      while PPControl.isInRoom do
      begin
        PPControl.TextOutDebugInfo(IntToStr(RoomNumber));
        //�Ի���
        if PPControl.isDialogShow then
        begin
          if PPConfig.ConfigData.CopyScreen then
          begin
            PPControl.KeyDown(VK_F4);
            PPControl.KeyUp(VK_F4);
          end;
          Sleep(100);
          PPControl.KeyDown(VK_RETURN);
          PPControl.KeyUp(VK_RETURN);
          //PPControl.MouseClick(363,368);
          Sleep(100);
          continue;
        end;

        if PPConfig.ConfigData.WorkMode=1 then ShuaDuan;
        if PPConfig.ConfigData.WorkMode<>0 then begin Sleep(100);continue; end;

        //�����Ϸ��״̬
        Last_PlayerCount := PlayerCount;
        PlayerCount := PPControl.getPlayerCount ;

      	//����й�棬ֱ�ӳ��Կ�ʼ��Ϸ
        if PPControl.isAdShow then
        begin
          if PlayerCount>2 then PPControl.StartGame else
          begin
            PPControl.ChangeColor(true,1);
            PPControl.ChangeColor(false,1);
          end;
        end;

        //����е��ţ��߳�ȥ
        if(PPConfig.ConfigData.AutoKickOdd)and(PlayerCount>Last_PlayerCount)and
          odd(PlayerCount-Last_PlayerCount) then
        begin
          for i:=1 to 8 do
            if (PPControl.PlayerStates_last[i]<=1)and(PPControl.PlayerStates[i]>1) then
            begin
              if PPKickPlayer.Kick(i) then
              begin
                PPSayString.Say( Format(PPConfig.ConfigData.KickOddNotify,[i]),true);
                PPLog.WriteLogKickOdd(i);
              end;
            end;
          continue;
        end;

        PlayerReadyCount := 0;
        
        for i:=1 to 8 do
        begin
          //���λ���ǿյģ���ȡ��T��
          if PPControl.PlayerStates[i]<2 then PPKickPlayer.Cancle(i);
          //����û�׼��������׼������
          if PPControl.PlayerStates[i]=3 then inc(PlayerReadyCount);
          //�������ҽ��룬���¼״̬�仯ʱ��
          if(PPControl.PlayerStates_last[i]<2)and(PPControl.PlayerStates[i]>=2) then
          begin
            PlayerStates_Time[i] := TimeGetTime;
            StartTime := timeGetTime ; //���¿�ʼǰ�ȴ�ʱ��
            PPLog.WriteLogPlayerEnter(i);
          end;

          if( PPControl.PlayerStates_last[i]>=2)and(PPControl.PlayerStates[i]<2) then
          begin
            PPLog.WriteLogPlayerLeave(i);
          end;
          //�߲�׼������
          if (PPConfig.ConfigData.AutoKickTime>0)and
             (TimeGetTime-PlayerStates_Time[i]>1000*PPConfig.ConfigData.AutoKickTime)and
             (PPControl.PlayerStates[i]=2) then
          begin
            if PPKickPlayer.Kick(i) then begin
              PlayerStates_Time[i] := TimeGetTime;
              PPLog.WriteLogKickNotReady(i);
              PPSayString.Say(Format(PPConfig.ConfigData.KickNotReadyNotify,[i]),true);

            end;
          end;
        end;

        //���������ҽ��룬����ʾ
        if PlayerCount>Last_PlayerCount then
        begin
          PPSayString.Say(PPConfig.ConfigData.Notify);
          if PPKickPlayer.Executing then
            PPSayString.Say('Ŀǰ�ű���ǿ���˳� '+PPKickPlayer.GetPlayerKick+'�����');
        end;

        //����ŵĸ������ԣ����һ����
        DoorClosedCount:=0;
        for i:=1 to 8 do if PPControl.PlayerStates[i]=0 then inc(DoorClosedCount);
        if DoorClosedCount<(8-PPConfig.ConfigData.GateNumber) then
          for i:=8 downto 1 do if PPControl.PlayerStates[i]=1 then
          begin
            PPControl.KickPlayer(i);
            break;
          end;
        if DoorClosedCount>(8-PPConfig.ConfigData.GateNumber) then
          for i:=1 to 8 do if PPControl.PlayerStates[i]=0 then
          begin
            PPControl.KickPlayer(i);
            break;
          end;
          
        //ִ�����˹���
        PPKickPlayer.Execute;
        //ִ�з��Թ���
        PPSayString.Execute;

        //���׼������Ҫ����ʼ��Ϸ
        if((PPConfig.ConfigData.WaittingTime>0)and(PlayerCount>2)and
          ((TimeGetTime-WaitingTime)>PPConfig.ConfigData.WaittingTime*1000))or
          ((PlayerReadyCount=PlayerCount-2)and
          (PlayerReadyCount>=StartPlayerMin-2)and
          (timeGetTime>StartTime+1000*PPConfig.ConfigData.StartDelay)and
          (not PPKickPlayer.Executing))or
          (StartPlayerMin=2)then
        begin
          PPControl.StartGame;
          PPConfig.Script.Reset;
        end else begin
          if timeGetTime > ChangeColorTime + PPConfig.ConfigData.ChangeColorTime * 1000 then
          begin
            PPControl.ChangeColor(false,1);
            if(PlayerCount<=2)then
              PPControl.ChangeColor(true,1)
            else
              PPControl.ChangeColor(true,0);

            //��ɫ��ʱ��һ��ESC����ֹ���Ի���ס
            //PPControl.KeyDown(VK_ESCAPE);
            //PPControl.KeyDown(VK_ESCAPE);
            ChangeColorTime := timeGetTime;
          end;
        end;
        // Wait for a second
        Sleep(100);
      end;
    end;  //inRoom
//------------------------------------------------------------------------------
//  ����ڵ�½������
//------------------------------------------------------------------------------
    if (PPConfig.ConfigData.LoginIndex>0) and PPControl.isInLoginForm then
    begin
      PPControl.TextOutDebugInfo('login',0,0);
      WorkMethordBackUp := PPConfig.ConfigData.WorkMethord;
      PPConfig.ConfigData.WorkMethord := 0;
      
      if Length(PPConfig.ConfigData.Player2Password)>0 then
      begin
        PPControl.MouseClick(555,470);
        Sleep(100);
        PPControl.MouseClick(259,432);
        PPControl.MouseClick(440,432);
        Sleep(100);
        PPControl.MouseClick(320,500);
        PPControl.MouseClick(320,480);
        PPControl.PrintString(PPConfig.ConfigData.Player1Name);
        PPControl.MouseClick(320,510);
        PPControl.PrintString(PPConfig.ConfigData.Player1Password);
        PPControl.MouseClick(490,480);
        PPControl.PrintString(PPConfig.ConfigData.Player2Name);
        PPControl.MouseClick(490,512);
        PPControl.PrintString(PPConfig.ConfigData.Player2Password);
      end else begin
        PPControl.MouseClick(167,470);
        Sleep(100);
        PPControl.MouseClick(340,425);
        Sleep(100);
        PPControl.MouseClick(420,500);
        PPControl.MouseClick(420,470);
        PPControl.PrintString(PPConfig.ConfigData.Player1Name);
        PPControl.MouseClick(420,500);
        PPControl.PrintString(PPConfig.ConfigData.Player1Password);
      end;

      PPControl.MouseClick(400,560);
      PPControl.KeyDown(VK_ESCAPE);
      PPControl.KeyUp(VK_ESCAPE);
      Sleep(1000);

      PPConfig.ConfigData.WorkMethord := WorkMethordBackUp;
    end;
//------------------------------------------------------------------------------
//  �������ѡ�������
//------------------------------------------------------------------------------
   	//TextOut(PPControl.GameScreen,0,0,PChar(IntToStr(PPConfig.ConfigData.ServerIndex)),2);
   	if PPControl.isChoosingServer then
   	begin
     	GameState := GameState_ChoosingServer;
      j:=PPConfig.ConfigData.ServerIndex;
      k:=PPConfig.ConfigData.LoginChannel;
      if(PPConfig.ConfigData.WorkMode=1)and(ChangeServer>0) then begin
      	j:=0;
        k:=1;
      end;
      
     	//ѡ��Ƶ��
     	PPControl.MouseClick(535+56*k,70);
     	Sleep(100);

   		for i := j to j + 200 do
   	 	begin
 	     	if PPControl.EnterServer(i) then
       	begin
     	   	ServerIndex := i;
          PPLog.WriteLogEnterLobby(ServerIndex);
          Sleep(1000);
   	     	break;
 	     	end;
     	end;
   	end;
//------------------------------------------------------------------------------
//  ����״̬
//------------------------------------------------------------------------------
    Sleep(100);
  end;

  Reg.CloseKey;
  Reg.Free;

end;
//------------------------------------------------------------------------------
begin
  PPJob := nil;
end.
