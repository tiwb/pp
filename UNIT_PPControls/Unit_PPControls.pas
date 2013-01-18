unit Unit_PPControls;

interface

uses Windows,Messages,SysUtils;

type
TPPControl = class
  public                                                
    GameWindow : HWND;
    GameScreen : HDC;
    PlayerStates : array[1..8] of byte;
    PlayerStates_last : array[1..8] of byte;
    LastScoreStates : array[1..8] of byte;
    LastScoreState : byte;
    LastExp : integer;

    function InitGameWindow : boolean;    
    function isInRoom : boolean;
    function isGamePlaying : boolean;
    function isDialogShow : boolean;
    function isMapOK(MapIndex:integer) : boolean;
    function isInChattingRoom : boolean;
    function isInLoginForm : boolean;
    function isChoosingServer : boolean;
    function isAdShow : boolean;
    function isBomb(x,y:byte):boolean;
    function isGround(x,y:byte):boolean;

    function GetNumber(x,y:integer):integer;
    function getPlayerCount : byte;
    function getPlayerCountInGame : integer;
    function GetLastScoreState:byte;
    function SelectMap(i:integer):boolean;
    function GetRoomNumber : integer;

    function CheckColorEql(x,y,color:Cardinal):boolean;
    function EnterServer(i : integer):boolean;
    
    procedure getPlayerStates;
    function KickPlayer(i:byte):boolean;
    procedure PrintString(s:string);
    procedure SayString(s:string;inGame:boolean=false);
    procedure KeyDown(code:byte);
    procedure KeyUp(code:byte);
    procedure Wait(time:cardinal);
    procedure MouseClick(x,y:integer;RightButton : boolean = false);
    procedure MouseWheelUp(t:integer);
    procedure MouseWheelDown(t:integer);
    procedure StartGame;
    procedure StartGame2;
    procedure EnterRoom;
    procedure ExitRoom ;
    procedure StartRoom(Name,Pass:string;FreeRoom:boolean;RoomType:integer);
    procedure ChangeColor(p2:boolean=true;i:byte = 0);
    procedure SelectCharacter(i:byte;p2:boolean = false);

    procedure LockMouse;
    procedure SelectPlayer;
    function GetPlayerName(id:integer):string;

    procedure TextOutDebugInfo(s:string;x:integer=0;y:integer=0);

    function GetMessageNumber(y:integer):integer;

  private
    CurrientColor : byte;
    function getPlayerState(i:integer):byte;
  end;

var
  PPControl : TPPControl;

implementation

uses Unit_PPConfig,Classes,Clipbrd, Unit_PPLog;

const
  PLAYERCHECKPOINT_X : array[1..8] of integer = (72 ,175,278,381,72 ,175,278,381);
  PLAYERCHECKPOINT_Y : array[1..8] of integer = (198,198,198,198,298,298,298,298);
  NUMBERPOINTS : array[0..9,0..9] of word = (
  (1020,1026,2049,2553,2313,2313,2553,2049,1026,1020),
  (96,144,144,144,144,144,144,144,144,96),
  (2044,2050,2049,2041,1025,2050,2558,2049,2049,2046),
  (2044,2050,2049,2041,2049,2049,2041,2049,2050,2044),
  (1542,2313,2313,2313,2553,2049,2049,2041,9,6),
  (2044,2050,2050,2556,2050,2049,2041,2049,2050,2044),
  (1020,1026,2050,2556,2050,2049,2553,2049,1026,1020),
  (2046,2049,2049,2018,68,136,272,544,1088,896),             //7
  (1020,1026,2049,2553,2049,2049,2553,2049,1026,1020),       //8
  (1020,1026,2049,2553,2049,1025,1017,1025,1026,1020));      //9
  NUMBERHASH : array[0..9] of cardinal = (17922,1344,19961,20466,17188,20983,17399,11166,17394,13810);

//------------------------------------------------------------------------------
// 初始化，获得游戏窗口句饼和绘图句饼
//------------------------------------------------------------------------------
function TPPControl.InitGameWindow:boolean;
begin
  GameWindow := FindWindow('Crazy Arcade',nil);
  GameScreen := GetWindowDC(GameWindow);
  if GameWindow=0 then Result := false else Result := true;
end;
//------------------------------------------------------------------------------
// 获取近似颜色
//------------------------------------------------------------------------------
function TPPControl.CheckColorEql(x,y,color:Cardinal):boolean;
begin
  if( (GetPixel(GameScreen,x,y) and $FCFCFC)=(color and $FCFCFC) ) then Result:=true else Result := false;
end;
//------------------------------------------------------------------------------
// 判断是在登陆窗口中
//------------------------------------------------------------------------------
function TPPControl.isInLoginForm : boolean;
begin
  if (GetPixel(GameScreen,400,398)<>0)and(GetPixel(GameScreen,400,399)=0)and
    (GetPixel(GameScreen,400,554)<>0)and(GetPixel(GameScreen,400,555)=0)
  then Result:=true else Result:= false;
end;
//------------------------------------------------------------------------------
// 判断是否正在选择服务器
//------------------------------------------------------------------------------
function TPPControl.isChoosingServer : boolean;
begin
  if (GetPixel(GameScreen,555,96)<>0)and(GetPixel(GameScreen,555,97)=0)and
     (GetPixel(GameScreen,555,424)<>0)and(GetPixel(GameScreen,555,425)=0)and
     (GetPixel(GameScreen,626,443)<>0)and(GetPixel(GameScreen,626,444)=0)
  then Result:=true else Result:= false;
end;
//------------------------------------------------------------------------------
// 判断是否在房间中
//------------------------------------------------------------------------------
function TPPControl.isInRoom : boolean;
begin
  if (GetPixel(GameScreen,740,11)<>0)and(GetPixel(GameScreen,740,12)=0)
  then Result:=true else Result:= false;
end;
//------------------------------------------------------------------------------
// 判断是否在聊天室中
//------------------------------------------------------------------------------
function TPPControl.isInChattingRoom : boolean;
begin
  if(GetPixel(GameScreen,240,20)=0)and(GetPixel(GameScreen,239,20)<>0)and
    (GetPixel(GameScreen,353,20)=0)and(GetPixel(GameScreen,352,20)<>0)
  then Result:=true else Result:=false;
end;
//------------------------------------------------------------------------------
// 判断是否在游戏中
//------------------------------------------------------------------------------
function TPPControl.isGamePlaying : boolean;
begin
  if (GetPixel(GameScreen,741,36)<>0)and
     (GetPixel(GameScreen,741,35)=0) and
     (GetPixel(GameScreen,723,49)<>0)
  then Result:=true else Result:= false;
end;
//------------------------------------------------------------------------------
// 判断是否有对话框
//------------------------------------------------------------------------------
function TPPControl.isDialogShow : boolean;
begin
  if ((GetPixel(GameScreen,375,358)<>0)and(GetPixel(GameScreen,375,359)=0)) and
     ((GetPixel(GameScreen,375,361)<>$FFFFFF)and(GetPixel(GameScreen,375,360)=$FFFFFF))
  then Result:=true else Result:=false;
end;
//------------------------------------------------------------------------------
// 判断地图
//------------------------------------------------------------------------------
function TPPControl.isMapOK( MapIndex:integer ) : boolean;
begin
  if( MapIndex = 72 ) then
  begin
    if(GetPixel(GameScreen,686,326)=$FFFFFF)and
    (GetPixel(GameScreen,685,326)<>$FFFFFF)and
    (GetPixel(GameScreen,699,326)=$FFFFFF)and
    (GetPixel(GameScreen,670,326)<>$FFFFFF)and
    (GetPixel(GameScreen,711,327)=$FFFFFF)and
    (GetPixel(GameScreen,711,326)<>$FFFFFF)and
    (GetPixel(GameScreen,710,328)=$FFFFFF)and
    (GetPixel(GameScreen,710,329)<>$FFFFFF)and
    (GetPixel(GameScreen,649,361)=0)and
    (GetPixel(GameScreen,650,361)<>0) then
    Result := true else Result := false;
  end else begin
    Result := true;
  end;
end;
//------------------------------------------------------------------------------
// 检查玩家状态 (  0:关闭 , 1:无人 , 2:有人 , 3:准备 )
//------------------------------------------------------------------------------
function TPPControl.getPlayerState(i:integer):byte;
var c:cardinal;
begin
  c := GetPixel(GameScreen,PLAYERCHECKPOINT_X[i],PLAYERCHECKPOINT_Y[i]);
  if (c=$FFC308)or(c=$FFC410) then
    Result:=1
  else if(c=$E79229)or(c=$E89430) then
    Result:=0
  else if c=0 then
    Result:=3
  else
    Result:=2;
end;
//------------------------------------------------------------------------------
// 检查玩家状态 ( 0:关闭 , 1:无人 , 2:有人 , 3:准备)
//------------------------------------------------------------------------------
procedure TPPControl.getPlayerStates;
var i:integer;
begin
  for i:=1 to 8 do begin
    PlayerStates_last[i] := PlayerStates[i];
    PlayerStates[i] := getPlayerState(i);
  end;
end;
//------------------------------------------------------------------------------
// 获得玩家人数
//------------------------------------------------------------------------------
function TPPControl.getPlayerCount:byte;
var i:byte;
begin
  Result := 0;
  getPlayerStates;
  for i:=1 to 8 do
    if PlayerStates[i]>1 then inc(Result);
end;

function TPPControl.getPlayerCountInGame:integer;
var i:integer;
    c:COLORREF;

begin
  Result := 0;
  for i:=1 to 8 do
  begin
    c := GetPixel( GameScreen,680,40 + 43*i );
    if (c=$303C00)or(c=$6b3800) then
    begin
      if( PPControl.PlayerStates_last[i]>=2) then
      begin
        PPLog.WriteLogPlayerLeave(i);
      end;
      PlayerStates[i] := 1;
      PlayerStates_last[i] :=1;
    end else begin
      inc(Result);
      PlayerStates[i] := 2;
      PlayerStates_last[i] :=2;
    end;
  end;
end;
//------------------------------------------------------------------------------
// 发言
//------------------------------------------------------------------------------
procedure TPPControl.PrintString(s:string);
var i: integer;
begin
  if PPConfig.ConfigData.WorkMethord=0 then
  begin
    //模拟键盘
    clipboard.AsText := s;
    KeyDown( VK_CONTROL );
    KeyDown( ord('V') );
    KeyUp( ord('V') );
    KeyUp( VK_CONTROL );
  end else begin
    //发送消息
    for i := 1 to Length(s) do
    begin
      PostMessage(GameWindow,WM_CHAR,ord(s[i]),1);
    end;
  end;
end;
procedure TPPControl.SayString(s:string;inGame:boolean=false);
begin
  if Length(s)=0 then exit;

  if inGame then
  if PPConfig.ConfigData.WorkMethord=0 then
  begin
    //模拟键盘
    KeyDown( VK_RETURN );
    KeyUp( VK_RETURN );
  end else begin
    //发送消息
    PostMessage(GameWindow,WM_KEYDOWN,VK_RETURN,1);
    PostMessage(GameWindow,WM_KEYUP,VK_RETURN,1);
  end;

  PrintString(s);
  
  if PPConfig.ConfigData.WorkMethord=0 then
  begin
    //模拟键盘
    KeyDown( VK_RETURN );
    KeyUp( VK_RETURN );
  end else begin
    //发送消息
    PostMessage(GameWindow,WM_KEYDOWN,VK_RETURN,1);
    PostMessage(GameWindow,WM_KEYUP,VK_RETURN,1);
  end;
end;
//------------------------------------------------------------------------------
// 控制部分
//------------------------------------------------------------------------------
procedure TPPControl.KeyDown(code:byte);
begin
  //SendMessage(GameWindow,WM_KEYDOWN,code,0);
  if( code=VK_CONTROL) or ( code=VK_SHIFT ) or (code=VK_RSHIFT) or ( code=VK_RCONTROL ) then
    keybd_event(code,MapVirtualKey(code,0),KEYEVENTF_EXTENDEDKEY,0)
  else
    keybd_event(code,MapVirtualKey(code,0),0,0);
end;

procedure TPPControl.KeyUp(code:byte);
begin
  //SendMessage(GameWindow,WM_KEYUP,code,0);
  if( code=VK_CONTROL) or ( code=VK_SHIFT ) or (code=VK_RSHIFT) or ( code=VK_RCONTROL ) then
    keybd_event(code,MapVirtualKey(code,0),KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP,0)
  else
    keybd_event(code,MapVirtualKey(code,0),KEYEVENTF_KEYUP,0);
end;

procedure TPPControl.Wait(time:cardinal);
begin
  Sleep(time);
end;

procedure TPPControl.MouseClick(x,y:integer;RightButton : boolean = false);
var XY : Cardinal;
  p : TPoint;
begin
  if PPConfig.ConfigData.WorkMethord=0 then
  begin
  //模拟键盘
    x := x * 65535 div 800;
    y := y * 65535 div 600;
    mouse_event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, x, y, 0 , 0 );
    if RightButton then begin
      mouse_event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, x, y, 0 , 0 );
      mouse_event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, x, y, 0 , 0 );
    end else begin
      mouse_event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, x, y, 0 , 0 );
      mouse_event( MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, x, y, 0 , 0 );
    end;
    Sleep(100);
  end else begin
  //发送消息
    GetCursorPos(p);
    XY := y shl 16 or x;
    if RightButton then begin
      PostMessage(GameWindow,WM_RBUTTONDOWN,MK_RBUTTON,XY);
      PostMessage(GameWindow,WM_RButtonUP,0,XY);
    end else begin
      PostMessage(GameWindow,WM_LBUTTONDOWN,MK_LBUTTON,XY);
      PostMessage(GameWindow,WM_LBUTTONUP,0,XY);
    end;
    PostMessage(GameWindow,WM_MOUSEMOVE,0,p.Y shl 16 or p.X)
  end;
  
end;

procedure TPPControl.MouseWheelUp(t:integer);
var p : TPoint;
    i : integer;
begin
  GetCursorPos(p);
  for i:=1 to t do PostMessage(GameWindow,WM_MOUSEWHEEL,$00780000,p.Y shl 16 or p.X);
  //mouse_event( MOUSEEVENTF_WHEEL, 0, 0, -WHEEL_DELTA * t , 0 );
  //Sleep(100);
end;

procedure TPPControl.MouseWheelDown(t:integer);
var p : TPoint;
    i : integer;
begin
  GetCursorPos(p);
  for i:=1 to t do PostMessage(GameWindow,WM_MOUSEWHEEL,$FF88 shl 16,p.Y shl 16 or p.X);
  //mouse_event( MOUSEEVENTF_WHEEL, 0, 0, 1000, 0 );
  //Sleep(100);
end;
//------------------------------------------------------------------------------
// 踢人
//------------------------------------------------------------------------------
function TPPControl.KickPlayer(i:byte):boolean;
begin
  if i<=8 then
  begin
    MouseClick(PLAYERCHECKPOINT_X[i],PLAYERCHECKPOINT_Y[i]);
    Sleep(100);
    if isDialogShow then Result:= true else Result:=false;
    KeyDown(VK_RETURN);
    KeyUp(VK_RETURN);
    //MouseClick(363,386);
  end else Result := false;
end;
//------------------------------------------------------------------------------
// 开始游戏
//------------------------------------------------------------------------------
procedure TPPControl.StartGame;
begin
  //选颜色
  ChangeColor(true,3);
  ChangeColor(false,1);
  Sleep(100);
  //开始
  MouseClick(635,532,PPConfig.ConfigData.RightClickToStart);
  //KeyDown(VK_RETURN);
  //KeyUp(VK_RETURN);
  MouseClick(363,368);
  Sleep(500);
end;

procedure TPPControl.StartGame2;
begin
  MouseClick(632,526,false);
  MouseClick(363,368);
  Sleep(2000);
end;

//------------------------------------------------------------------------------
// 选择地图
//------------------------------------------------------------------------------
function TPPControl.SelectMap(i:integer):boolean;
begin
  if( i=0 ) then begin Result:=true;exit; end;
  MouseClick(528,348);
  Sleep(100);
  if( i>=0 ) then
  begin
    MouseWheelUp(1000);
    MouseWheelDown(i);
  end
  else if( i<0 ) then
  begin
    MouseWheelDown(1000);
    MouseWheelUp(-i);
  end;

  Sleep(100);
  Result := (GetPixel(GameScreen,444,421)=0);
  if not Result then exit;
  MouseClick(500,227);
  MouseClick(500,227);
  Sleep(100);
end;
//------------------------------------------------------------------------------
// 进入房间
//------------------------------------------------------------------------------
procedure TPPControl.EnterRoom;
begin
  PPControl.MouseClick(506,24);
  Sleep(2000);
end;
//------------------------------------------------------------------------------
// 开房间
//------------------------------------------------------------------------------
procedure TPPControl.StartRoom(Name,Pass:string;FreeRoom:boolean;RoomType:integer);
begin
  MouseClick(395,30);

  if (PPConfig.ConfigData.WorkMode=1) or (PPConfig.ConfigData.WorkMode=2) then
  begin
  	// 1:1
    PrintString(Name);
    if Length(Pass)>0 then
    begin
     	MouseClick(431,343);
    	MouseClick(388,316);
    	PrintString(Pass);
    end;
    MouseClick(378,260);
    MouseClick(348,377);
  end else begin
  	if FreeRoom then MouseClick(475,161);
  	PrintString(Name);
  	if Length(Pass)>0 then
  	begin
    	MouseClick(433,245);
    	MouseClick(386,220);
    	PrintString(Pass);
  	end;
  	MouseClick(403,296 + RoomType*28);
  	MouseClick(344,455);
  end;
  
  Sleep(500);
end;
//------------------------------------------------------------------------------
// 变颜色
//------------------------------------------------------------------------------
procedure TPPControl.ChangeColor(p2:boolean=true;i:byte = 0);
begin
  if i=0 then
  begin
    if CurrientColor=1 then CurrientColor:=3
    else CurrientColor:=1;
    MouseClick(510+(CurrientColor-1)*35,457,p2);
  end else begin
    MouseClick(510+(i-1)*35,457,p2);
  end;
end;
//------------------------------------------------------------------------------
// 退出房间
//------------------------------------------------------------------------------
procedure TPPControl.ExitRoom;
begin
  MouseClick(110,585);
  Sleep(1000);
end;
//------------------------------------------------------------------------------
// 进入服务器
//------------------------------------------------------------------------------
function TPPControl.EnterServer(i : integer):boolean;
begin
  if i<0 then begin Result:=false;exit; end;

  MouseWheelUp(50);
  MouseWheelDown(i div 13);

  Sleep(100);

  Result:= not CheckColorEql(674,116+(i mod 13)*23,$00144A);
  if Result then
  begin
    MouseClick(670,123 + (i mod 13) * 23);
    MouseClick(670,123 + (i mod 13) * 23);
    Sleep(300);
    KeyDown( VK_ESCAPE );
    KeyUP( VK_ESCAPE );
    Sleep(300);
  end;
end;
//------------------------------------------------------------------------------
// 判断玩家的分数
//------------------------------------------------------------------------------
function TPPControl.GetLastScoreState:byte;
var i,a,b,c:integer;
begin
  Result := 0;
  if not((GetPixel(GameScreen,153,214)=0)and(GetPixel(GameScreen,153,213)<>0)) then exit;

  //获得游戏结束后的人数
  getPlayerCountInGame;

	// 获得得分有错误
  for i:=8 downto 1 do
	  LastScoreStates[i] := 0;
  LastScoreState := 0;
  exit;

  for i:=8 downto 1 do
  begin
    //如果这个位置是自己
    if (GetPixel(PPControl.GameScreen,290,226+25*i)=$CEAA31)or
       (GetPixel(PPControl.GameScreen,290,226+25*i)=$D0AC38)then
    begin
      a := GetNumber(381,226+25*i);
      b := GetNumber(395,226+25*i);
      c := GetNumber(416,226+25*i);
      if(a>=0)and(b>=0)and(c>=0)then
        LastExp :=a*100 + b*10 + c;
     LastScoreStates[i] := 0;
    end else begin
      if GetNumber(296,226+25*i)>0 then
      begin
        Result := i;
        if LastScoreStates[Result] <> 1 then
          SayString(Format(PPConfig.ConfigData.AutoKickNotify,[i]));
        LastScoreStates[i] := 1;
      end else begin
        LastScoreStates[i] := 0;
      end;
    end;
  end;
  LastScoreState := Result;

  //TextOut(GameScreen,0,0,PChar(intToStr(Result)),1);
end;
//------------------------------------------------------------------------------
// 判断是否有公告
//------------------------------------------------------------------------------
function TPPControl.isAdShow:boolean;
begin
  if(GetPixel(PPControl.GameScreen,330,312)<>0)
  then
    Result := true
  else
    Result := false;
end;
//------------------------------------------------------------------------------
// 判断数字
//------------------------------------------------------------------------------
function TPPControl.GetNumber(x,y:integer):integer;
var i,j,k:word;
  m : cardinal;
begin
  m:=0;
  for j:= 0 to 9 do
  begin
    k:=0;
    for i:= 0 to 11 do
    begin
      k:=k shl 1 or Integer(GetPixel(PPControl.GameScreen,x+i,y+j)=0);
    end;
    m := m + k;
  end;
  Result := -1;
  for i:= 0 to 9 do
    if NUMBERHASH[i]=m then Result := i;
end;
//------------------------------------------------------------------------------
// 判断某个位置是否是地板（工厂01）
//------------------------------------------------------------------------------
function TPPControl.isGround(x,y:byte):boolean;
var c:Cardinal;
begin
  c := GetPixel(GameScreen,40+40*x,50+40*y);
  //TextOut(GameScreen,0,0,PChar(IntToHex(c,6)),6);
  if(c=$C6AEA5)or(c=$D6BEB5)or  //XP 工厂01
    (c=$D8C0B8)or(c=$C8B0A8)or  //98 工厂01
    (c=$635D63)then             //XP 赛车06
  Result:=true else Result:=false;
end;
//------------------------------------------------------------------------------
// 判断某个位置上是否有炸弹
//------------------------------------------------------------------------------
function TPPControl.isBomb(x,y:byte):boolean;
//var color : Cardinal;
begin
  //color := GetPixel(GameScreen,40+40*x,50+40*y);
  //TextOut(GameScreen,x*50+y*50,0,PChar(IntToHex(Color,6)),6);
  Result := not isGround(x,y);
end;
//------------------------------------------------------------------------------
//  锁定鼠标移动
//------------------------------------------------------------------------------
procedure TPPControl.LockMouse;
var r : TRect;
begin
  r := Rect(0,0,1,1);
  ClipCursor(@r);
end;
//------------------------------------------------------------------------------
//  选择玩家
//------------------------------------------------------------------------------
procedure TPPcontrol.SelectPlayer;
begin
  Sleep(500);
  KeyDown(VK_F5);
  KeyUp(VK_F5);
  Sleep(500);
  ChangeColor(false,1);
  Sleep(500);
  ChangeColor(true,3);
  Sleep(500);
  KeyDown(VK_F5);
  KeyUp(VK_F5);
  Sleep(500);
end;
//------------------------------------------------------------------------------
//  选择人物
//------------------------------------------------------------------------------
procedure TPPControl.SelectCharacter(i:byte;p2:boolean = false);
const
  X: array[1..8] of integer = (530,630,730,530,730,530,630,730);
  Y: array[1..8] of integer = (90, 90, 90,160,160,230,230,230);
begin
  if(i<1)or(i>8)then exit;
  MouseClick(X[i],Y[i],p2);
  Sleep(100);
end;
//------------------------------------------------------------------------------
//  获得人名
//------------------------------------------------------------------------------
function TPPControl.GetPlayerName(id:integer):string;
begin
  Result := '';
  if id>8 then exit;
  MouseClick(PLAYERCHECKPOINT_X[id],PLAYERCHECKPOINT_Y[id],true);
  Sleep(500);
  MouseClick(480,100);
  //KeyDown(VK_ESCAPE);
  //KeyUP(VK_ESCAPE);

  Sleep(500);
  MouseClick(70,545);

  Sleep(500);

  KeyDown(VK_CONTROL);
  KeyDown(ord('X'));
  SendMessage(GameWindow,WM_KeyUp,ord('X'),0);
  KeyUp(ord('X'));
  KeyUp(VK_CONTROL);

  Sleep(500);

  MouseClick(200,545);
  {
  SendMessage(GameWindow,WM_KEYDOWN,VK_SHIFT,0);
  SendMessage(GameWindow,WM_KEYDOWN,VK_HOME,0);
  SendMessage(GameWindow,WM_KEYUP,VK_HOME,0);
  SendMessage(GameWindow,WM_KEYUP,VK_SHIFT,0);

  KeyDown(VK_CONTROL);
  KeyDown(ord('C'));
  SendMessage(GameWindow,WM_KeyUp,ord('C'),0);
  KeyUp(ord('C'));
  KeyUp(VK_CONTROL);

  KeyDown(VK_ESCAPE);
  KeyUp(VK_ESCAPE);
  }
  Result := ClipBoard.AsText;
end;

procedure TPPControl.TextOutDebugInfo(s:string;x:integer=0;y:integer=0);
begin
  //TextOut(GameScreen,x,y,PChar(s),length(s));
end;

function TPPControl.GetRoomNumber:integer;
var a,b,c:integer;

begin
  a := GetNumber(118,58);
  b := PPControl.GetNumber(105,58);
  c := PPControl.GetNumber(92,58);
  if (a<0) or (b<0) or (c<0) then
    Result := -1
  else
    Result := a + b*10 + c*100;
end;

//------------------------------------------------------------------------------
//  获得信息串
//------------------------------------------------------------------------------
function TPPControl.GetMessageNumber(y:integer):integer;
var x : integer;
		i : integer;
    f : integer;
begin
	Result := 0;

  for x:=420 downto 150 do
  begin
    if GetPixel(GameScreen,x,y)=$00FFFF then begin f:=$00FFFF;break; end;
    if GetPixel(GameScreen,x,y)=$FFFFFF then begin f:=$FFFFFF;break; end;
  end;

  if x=150 then exit;

 	for i:=0 to 50 do
  if GetPixel(GameScreen,x-i,y)=f then Result := Result xor (1 shl (i and 31));
  Result := Result and $7FFFFFFF;
  if f=$FFFFFF then Result := Result or $80000000;
end;

//------------------------------------------------------------------------------
// 创建实例
//------------------------------------------------------------------------------
begin
  PPControl := TPPControl.Create;
end.
