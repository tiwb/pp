unit Unit_PPSayString;

interface

uses Windows,Classes,mmSystem;

type
  TPPSayString = class
  public
    LastSayTime : DWORD;
    constructor Create;
    procedure Execute;
    procedure Say(s:string;Delay:boolean=false);
    procedure Clear;
  private
    StringList : TStringList;
  end;

var
  PPSayString : TPPSayString;

implementation

uses Unit_PPControls, Unit_Security;

const SAY_DELAY = 2000;

constructor TPPSayString.Create;
begin
  StringList := TStringList.Create;
end;

procedure TPPSayString.Say(s:string;Delay:boolean=false);
begin
  if s='' then exit;
  if Delay then LastSayTime :=TimeGetTime;
  StringList.Append(s);
  PPSayString.Execute;
end;

procedure TPPSayString.Clear;
begin
  StringList.Clear;
end;

procedure TPPSayString.Execute;
begin
  if (TimeGetTime-LastSayTime>SAY_DELAY)and(StringList.Count>0) then
  begin
    PPControl.SayString(StringList.Strings[0]);
    StringList.Delete(0);
    LastSayTime := TimeGetTime;
    Sleep(500);
  end;
end;

begin
  PPSayString := TPPSayString.Create;
end.
 