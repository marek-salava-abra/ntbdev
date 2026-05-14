procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportRewards';
  mAction.Caption := '##Odměny##';
  mAction.Hint := 'naimportuje data z CSV do odměn';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportRewards;

end;

Procedure ImportRewards(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,l: integer;
 mCode, mWagePeriod_ID, mPersonalCode,mWL_ID:string;
 mWageListBO:TNxCustomBusinessObject;
 mList, mLog:TStringList;
 mTempStr, mRewardA, mRewardB, mRewardC:string;
begin
  mSite := TComponent(Sender).DynSite;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z csv';
  mOpenDlg.Filter := 'Soubory aplikace CSV (*.csv)| *.csv';
  if mOpenDlg.Execute then begin
    try
      mList:=TStringList.Create;
      mLog:=TStringList.Create;
      mLog.Clear;
      mList.LoadFromFile(mOpenDlg.FileName);
      k:=mList.count;
          mWagePeriod_ID:= GetActivePeriod_ID(mSite.BaseObjectSpace);
          if NxIsEmptyOID(mWagePeriod_ID) then begin
            NxShowSimpleMessage('Nemám aktivní mzdové období, ukončuji.',mSite);
            exit;
          end;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
              for i:=1 to mList.count-1 do begin
               mTempStr:=mList.Strings[i];
               mCode:=NxTrapStrTrim(mTempStr,';');
               mRewardA:=NxTrapStrTrim(mTempStr,';');
               mRewardB:=NxTrapStrTrim(mTempStr,';');
               mRewardC:=NxTrapStrTrim(mTempStr,';');
               mPersonalCode:=AnsiRightStr('00'+mCode,3);
               mWL_ID:=GetWL_ID(mOS,mWagePeriod_ID,mPersonalCode);
               if not(NxIsEmptyOID(mWL_ID)) then begin
                mWageListBO:=mOS.CreateObject(Class_WageListPartial);
                mWageListBO.load(mWL_ID,nil);
                if not(NxIsBlank(mRewardA)) then
                 mWageListBO.SetFieldValueAsFloat('U_Benefit_A',NxIBStrToFloat(mRewardA));
                if not(NxIsBlank(mRewardB)) then
                 mWageListBO.SetFieldValueAsFloat('U_Benefit_B',NxIBStrToFloat(mRewardB));
                if not(NxIsBlank(mRewardC)) then
                 mWageListBO.SetFieldValueAsFloat('U_Benefit_C',NxIBStrToFloat(mRewardC));
                if mWageListBO.NeedSave then mWageListBO.save;
                mWageListBO.free;
               end else begin
                 mLog.add('Osobní číslo: '+mPersonalCode);
               end;
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
          end;
          WaitWin.Stop;
          if mLog.count>0 then begin
            NxShowSimpleMessage('Nenalezené mzdové listy pro hlavní pracovní poměr:'+#13#10+mLog.Text,mSite);
          end;
    except
     WaitWin.Stop;
     NxShowSimpleMessage('Něco se nepovedlo:'+#13#10+ExceptionMessage,mSite);
    end;
   end;
end;

function GetWL_ID(AOS : TNxCustomObjectSpace; aPeriod_ID,aPersonalNumber : string) : string;
const
  cSQL = 'select wl.id from wagelistpartial wl join workingrelations wr on wr.id=wl.workingrelation_id join employees e on e.id=wr.employee_id '+
         'join persons p on p.id=e.person_id where wl.wageperiod_id=''%s'' and p.personalnumber=''%s'' and wr.employpattern_id=''1000000000'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aPeriod_ID,aPersonalNumber]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;


Function GetActivePeriod_ID(AOS: TNxCustomObjectSpace;): String;
var
  mRes, mCode: String;
  mSQLRes: TStringList;
begin
  mRes := '0000000000';

    mSQLRes := TStringList.Create;
    try
      aos.SQLSelect('Select ID from wageperiods where wperiodinitialized=''A'' and wperiodclosed=''N'' ', mSQLRes);
      if mSQLRes.Count > 0 then
        mRes := mSQLRes[0];
    finally
      mSQLRes.Free;
    end;

  Result := mRes;
end;

begin
end.