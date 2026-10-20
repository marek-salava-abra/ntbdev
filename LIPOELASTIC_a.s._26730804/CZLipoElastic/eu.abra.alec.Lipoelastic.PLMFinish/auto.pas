procedure FinishPLMJobOrders(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mJOBO: TNxCustomBusinessObject;
  mList: TStringList;
  mWar, mErr: string;
  i: integer;
begin
  Success := True;
  LogInfoStr := '';
  mList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT A.ID FROM PLMJobOrders A '+
      ' JOIN StoreCards SC ON SC.ID=A.StoreCard_ID '+
      ' LEFT JOIN ProductionTasks PT ON PT.ID=A.ProductionTask_ID '+
      ' WHERE ( ( (A.ReleasedAt$DATE <> 0 AND PT.Quantity >= A.Quantity AND A.FinishedAt$DATE = 0) )) ', mList);

    for i:= 0 to mList.Count -1 do begin
      mWar:= '';
      mErr:= '';
      mJOBO:= OS.CreateObject(Class_PLMJobOrder);
      try
        mJOBO.Load(mList[i], nil);
        LogInfoStr:= LogInfoStr + nxCrLf + mJOBO.DisplayName;
        if TNxPLMJobOrder(mJOBO).Finish(Date, mWar, mErr) = false then begin
          LogInfoStr:= LogInfoStr + #09 + 'Výrobní příkaz se nepodařilo ukončit';
          Success:= false;
        end else
          LogInfoStr:= LogInfoStr + #09 + 'Ukončen';

        if not(NxIsBlank(mWar)) then
          LogInfoStr:= LogInfoStr + #09 + 'Upozornění: '+ mWar;
        if not(NxIsBlank(mErr)) then
          LogInfoStr:= LogInfoStr + #09 + 'Chyba: '+ mErr;

      finally
        mJOBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;

begin
end.