procedure InitSite_Hook(Self: TSiteForm);
  var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actGenSerial';
  mAction.Category := 'tabList';
  mAction.Caption := 'Generuj SN';
  mAction.ShowMenuItem := True;
  mAction.ShowControl := True;
  mAction.OnExecute := @generateSerialNumber;
end;

Procedure GenerateSerialNumber(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 mSaveDialog: TSaveDialog;
 i:integer;
begin
 mSite:=TComponent(sender).BusRollSite;
 mList:=TStringList.Create;
 for i:=1 to 200 do begin
   mlist.Add(GenerateNum(8));
 end;
 mSaveDialog:= TSaveDialog.Create(nil);
 mSaveDialog.Filter := 'txt|*.txt';
 mSaveDialog.DefaultExt := 'txt';
 //mSaveDialog.FilterIndex := 0;
 if mSaveDialog.Execute then mList.SaveToFile(mSaveDialog.FileName);
end;


function GenerateNum(AChrCount: Integer): String;
Var
  i: integer;
  mResult, mSwitchResult: string;
  mSwitch: Array of string;

begin
  mResult:= '';
  SetLength(mSwitch,2);
  Randomize;
//Generuje pseudo-náhodný string o délce [AChrCount], složený z velkých a malých písmen a číslic
  for i := 0 to AChrCount -1 do begin
    //mSwitch[0]:= (Chr(ord('a') + RandomRange(0, 26)));
    mSwitch[0]:= (Chr(ord('A') + RandomRange(0, 26)));
    mSwitch[1]:= (Chr(ord('0') + RandomRange(0, 10)));
    mResult:= mResult + mSwitch[RandomRange(0, 2)];
  end;
  Result := mResult;
end;

begin
end.