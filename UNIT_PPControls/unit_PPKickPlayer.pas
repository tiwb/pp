unit unit_PPKickPlayer;

interface
uses Windows;

type
  TPPKickPlayer = class
  public
    Executing : boolean;
    constructor Create;
    procedure Execute;
    function Kick(i:byte):boolean;
    procedure Cancle(i:byte);
    procedure CancleAll;
    procedure Init;
    function GetPlayerKick:string;
  public
    KickState : array[1..8] of byte;
    KickTime : DWORD;

  end;

var
  PPKickPlayer : TPPKickPlayer;

implementation

uses SysUtils,Unit_PPControls,MMSystem;

const
	KICK_TIME = 5000;

function TPPKickPlayer.GetPlayerKick:string;
var i:integer;
begin
  Result := '';
  for i:=1 to 8 do
  if KickState[i]<>0 then
  begin
    Result := Result + IntToStr(i) + ' ';
  end;
end;

procedure TPPKickPlayer.Init;
begin
	fillchar(KickState,sizeof(KickState),0);
  KickTime :=timeGetTime;
  Executing := false;
end;
//------------------------------------------------------------------------------
//   增加踢人
//------------------------------------------------------------------------------
function TPPKickPlayer.Kick(i:byte):boolean;
begin
  Result := PPControl.KickPlayer(i);
  if Result then
  begin
    Executing := true;
    KickState[i] := 1;
    KickTime := timeGetTime;
    Sleep(500);
  end;
end;
//------------------------------------------------------------------------------
//   取消踢人
//------------------------------------------------------------------------------
procedure TPPKickPlayer.Cancle(i:byte);
var j:byte;
begin
  if KickState[i]=0 then exit;
  KickState[i] := 0;
  Executing := false;
  for j:= 1 to 8 do if KickState[j]>0 then Executing:= true;
end;
//------------------------------------------------------------------------------
//   全部取消
//------------------------------------------------------------------------------
procedure TPPKickPlayer.CancleAll;
begin
  Init;
end;
//------------------------------------------------------------------------------
//   执行踢人过程
//------------------------------------------------------------------------------
procedure TPPKickPlayer.Execute;
var
  i:byte;
begin
  if TimeGetTime-KickTime<KICK_TIME then exit;
  for i := 1 to 8 do
    if KickState[i]>0 then
    begin
      PPControl.KickPlayer(i);
      KickTime := timeGetTime;
      break;
    end;
end;
//------------------------------------------------------------------------------
//  构造函数
//------------------------------------------------------------------------------
constructor TPPKickPlayer.Create;
begin
  Init;
end;

begin
  PPKickPlayer := TPPKickPlayer.Create();
end.
