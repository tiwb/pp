unit Unit_PPScript;

interface

uses Classes,SysUtils;

type
TScriptCommand = record
  Command : byte;
  lParam  : Cardinal;
  rParam : Cardinal;
end;

TPPScript = class
  public
    Commands_Count : word;
    Commands_Currient : word;

    function Load(const Source:string) : boolean;
    function Execute : boolean;
    function getLastError : string;
    procedure Reset;
    constructor Create;
  private
    error : string;
    Commands : array[1..65535] of TScriptCommand;
    Commands_Strings : TStrings;
  end;

var
  PPScript : TPPScript;

implementation

uses Unit_PPControls, Unit_Security;
const
  CMD_KEYDOWN  = 1;
  CMD_KEYUP    = 2;
  CMD_WAIT     = 3;
  CMD_SAY      = 4;
  CMD_WAITBOMB = 5;
  CMD_WAITGROUND = 6;


//------------------------------------------------------------------------------
//  ���캯��
//------------------------------------------------------------------------------
constructor TPPScript.Create;
begin
  Commands_Strings := TStringList.Create;
end;
//------------------------------------------------------------------------------
//  ��һ���ַ����ж�ȡ�ű���Ϣ
//------------------------------------------------------------------------------
function TPPScript.Load(const Source:string) : boolean ;
const
  RETURN = Chr(13);
  TAB = Chr(9);
  
var i,j,k,l:integer;
  cmd : array[1..99] of string;
  ss : TStrings;
  s : string;
  lParam,rParam : Cardinal;
  sCMD : string;

begin
  Result := false;
  FillChar(Commands,SizeOf(Commands),0);
  Commands_Strings.Clear;
  Commands_Count := 0;
  Commands_Currient := 0;

  ss := TStringList.Create;

  ss.Text := Source;

  for i := 0 to ss.Count-1 do
  begin
    s := ss.Strings[i];
    l := Length(s);
    j := 1; k :=1 ;
    fillChar(cmd,SizeOf(cmd),0);
    if (j>l) then continue;
    while (j<=l)and(s[j]=TAB)or(s[j]=' ') do inc(j);
    while j<=l do
    begin
      if (s[j]=TAB) or (s[j]=' ') then
      begin
        while (s[j]=TAB) or (s[j]=' ') do inc(j);
        inc(k);
      end else if (s[j]='/')and(s[j+1]='/') then
      begin
        j:=l+1;   //����ɨ��
      end else if (s[j]='"') then
      begin
        inc(j);
        while s[j]<>'"' do
        begin
          if j>l then begin
            error := Format('���� �� %d : δ�������ַ�������',[i+1]);
            exit;
          end;
          if s[j]='\' then inc(j);
          cmd[k] := cmd[k] + s[j];
          inc(j);
        end;
        inc(j);
      end else begin
        cmd[k] := cmd[k] + s[j];
        inc(j);
      end;
    end;
    //�����������
    sCMD := cmd[1];
    if sCMD='' then continue;
    if (sCMD='Say')or(sCMD='SayString')or(sCMD='����') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_SAY;
      Commands[Commands_Count].lParam := Commands_Strings.Add(cmd[2]);
      continue;
    end;
    if (cmd[2]='1P_Up')or(cmd[2]='1P_��') then lParam:=82
    else if (cmd[2]='1P_Down' )or(cmd[2]='1P_��') then lParam:=70
    else if (cmd[2]='1P_Left' )or(cmd[2]='1P_��') then lParam:=68
    else if (cmd[2]='1P_Right')or(cmd[2]='1P_��') then lParam:=71
    else if (cmd[2]='1P_Bomb' )or(cmd[2]='1P_��') then lParam:=16
    else if (cmd[2]='2P_Up'   )or(cmd[2]='2P_��') then lParam:=38
    else if (cmd[2]='2P_Down' )or(cmd[2]='2P_��') then lParam:=40
    else if (cmd[2]='2P_Left' )or(cmd[2]='2P_��') then lParam:=37
    else if (cmd[2]='2P_Right')or(cmd[2]='2P_��') then lParam:=39
    else if (cmd[2]='2P_Bomb' )or(cmd[2]='2P_��') then lParam:=161
    else if cmd[2]<>'' then lParam := StrToInt(cmd[2]) else lParam:=0;
    if cmd[3]<>'' then rParam := StrToInt(cmd[3]) else rParam:=0;
    if (sCMD='KeyDown')or(sCMD='����') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_KEYDOWN;
      Commands[Commands_Count].lParam := lParam;
    end else
    if (sCMD='KeyUp')or(sCMD='�ɿ�') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_KEYUP;
       Commands[Commands_Count].lParam := lParam;
    end else
    if (sCMD='Wait')or(sCMD='Sleep')or(sCMD='Delay')or(sCMD='�ȴ�') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_WAIT;
      Commands[Commands_Count].lParam := lParam;
    end else
    if (sCMD='KeyPress')or(sCMD='����') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_KEYDOWN;
      Commands[Commands_Count].lParam := lParam;
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_WAIT;
      Commands[Commands_Count].lParam := rParam;
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_KEYUP;
      Commands[Commands_Count].lParam := lParam;
    end else
    if (sCMD='WaitGround')or(sCMD='���ذ�') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_WAITBOMB;
      Commands[Commands_Count].lParam := lParam;
      Commands[Commands_Count].rParam := rParam;
    end else
    if (sCMD='WaitBomb')or(sCMD='�ȴ��ذ�') then
    begin
      inc(Commands_Count);
      Commands[Commands_Count].Command := CMD_WAITGROUND;
      Commands[Commands_Count].lParam := lParam;
      Commands[Commands_Count].rParam := rParam;
    end else begin
      error := Format('���� �� %d : δ֪���� "%s"',[i+1,sCMD]);
      exit;
    end;
  end;
  Result := true;
end;
//------------------------------------------------------------------------------
//  ����һ�����
//------------------------------------------------------------------------------
function TPPScript.Execute : boolean;
begin
  case Commands[Commands_Currient].Command of
    CMD_KEYDOWN   : PPControl.KeyDown(Byte(Commands[Commands_Currient].lParam));
    CMD_KEYUP     : PPControl.KeyUp(Byte(Commands[Commands_Currient].lParam));
    CMD_WAIT      : PPControl.Wait(Commands[Commands_Currient].lParam);
    CMD_SAY       : PPControl.SayString(Commands_Strings[Commands[Commands_Currient].lParam],true);
    CMD_WAITGROUND: if PPControl.isGround(Commands[Commands_Currient].lParam,Commands[Commands_Currient].rParam) then
                      begin
                        Sleep(100);
                        dec(Commands_Currient);
                      end;
    CMD_WAITBOMB : if not PPControl.isGround(Commands[Commands_Currient].lParam,Commands[Commands_Currient].rParam) then
                      begin
                        Sleep(100);
                        dec(Commands_Currient);
                      end;
    else
      Sleep(100);
  end;
  inc(Commands_Currient);
  if Commands_Currient>Commands_Count then
  begin
    Commands_Currient := 0;
    Result := false;
  end else Result := true;

end;
//------------------------------------------------------------------------------
//  ���ýű�����
//------------------------------------------------------------------------------
procedure TPPScript.Reset;
begin
  Commands_Currient := 0;
end;

function TPPScript.getLastError : string;
begin
  Result := error;
end;

end.
