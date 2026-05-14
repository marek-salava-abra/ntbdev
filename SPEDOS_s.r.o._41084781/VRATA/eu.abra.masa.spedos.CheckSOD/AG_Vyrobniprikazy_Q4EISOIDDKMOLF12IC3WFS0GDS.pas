procedure InitSite_Hook(Self: TSiteForm);
var
  mAct, mAct2: TBasicAction;
  mAlist:TActionList;
  i:Integer;
begin
  mAlist:=self.GetMainActionList;
  mAct := Self.GetNewAction;
  mAct.Caption := 'Získání čísel z OD';
  mAct.Category := 'tabList';
  mAct.OnExecute := @GetDataOD;
end;

Procedure GetDataOD(sender:TComponent);
var
 mList, mOPList:TStringList;
 i,j,k:integer;
 mSite:TSiteForm;
 mBO, mOperationBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
  mSite:=TComponent(sender).DynSite;
  mList:=TStringList.Create;
  mOS:=mSite.BaseObjectSpace;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
  for i:=0 to mlist.Count-1 do begin
     mBO:=mOS.CreateObject(Class_PLMJobOrder);
     mBO.Load(mList.Strings[i],nil);
     if NxIsBlank(mBO.GetFieldValueAsString('U_id_vyrobku')) and not(NxIsBlank(mBO.GetFieldValueAsString('U_vyrobni_cislo'))) then begin
       mBO.SetFieldValueAsString('U_id_vyrobku',GetIDVyrobkuOD(mOS,mBO.GetFieldValueAsString('U_vyrobni_cislo')));
     end;
     if mBO.NeedSave then begin
      mBO.save;
      mOPList:=TStringList.Create;
      mOS.SQLSelect('SELECT a.id FROM PLMOperations A JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
                    'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
                    'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID JOIN DocQueues JODQ ON JODQ.ID = JO.DocQueue_ID '+
                    'JOIN Periods JOP ON JOP.ID = JO.Period_ID LEFT JOIN PLMWorkers W ON W.ID=A.PerformedBy_ID '+
                    'WHERE N.Parent_ID='+QuotedStr(mBO.OID),mOPList);
      if mOPList.count>0 then begin
        for j:=0 to mOPList.Count-1 do begin
           mOperationBO:=mOS.CreateObject(Class_PLMOperation);
           mOperationBO.load(mOPList.Strings[j],nil);
           mOperationBO.Invalidate;
           mOperationBO.save;
           mOperationBO.free;
        end;
      end;
     end;
     mBO.free;
     WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
     WaitWin.StepIt;
  end;
  WaitWin.Stop;
  TDynSiteForm(mSite).RefreshData;
  NxShowSimpleMessage('Hotovo',mSite);
end;

function GetIDVyrobkuOD (AOS: TNxCustomObjectSpace; aVyrobniCislo:string): string;
var
 mJSON: TJSONSuperObject;
 mWinHTTP: Variant;
begin
             mJSON:= TJSONSuperObject.CreateNew;
             if not(NxIsBlank(aVyrobniCislo)) then begin
             mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
             mWinHTTP.Open('GET','https://sod.spedos.cz/api/api.abra-get-vyrobek.php?vyrobni_cislo='+aVyrobniCislo);
             mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
             mWinHTTP.Send();
             mJSON:= TJSONSuperObject.CreateNew;
             mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
             //NxShowSimpleMessage(mJSON.AsString,nil);
             Result:=mJSON.S['ID_montaz_vyrobky'];
     end;
end;

begin
end.