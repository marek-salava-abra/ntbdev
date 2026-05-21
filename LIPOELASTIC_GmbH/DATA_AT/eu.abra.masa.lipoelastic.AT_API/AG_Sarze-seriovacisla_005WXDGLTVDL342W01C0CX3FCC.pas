uses '.API', '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actActualizeDataOverAPI';
  mAction.Caption := '##Batches data from CZE##';
  mAction.Hint := 'Download and correct data from CZE batches';
  mAction.Category := 'tabList';
  mAction.OnExecute := @GetData;
end;

Procedure GetData(Sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i,j,k:integer;
 mJSON, mResultJSON:TJSONSuperObject;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mlist);
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 if mList.Count>0 then begin
   if NxMessageBox('Prompt','Check data for '+IntToStr(mList.count)+' selected batches?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
         try
          k:=mList.Count;
          WaitWin.StartProgress('Please, wait ...', '', k);
          for i:=0 to mlist.count-1 do begin
            mBO:=mOS.CreateObject(Class_StoreBatch);
            mBO.Load(mList.strings[i],nil);
            mJSON:=TJSONSuperObject.Create;
            mJSON.S['ean']:=mbo.GetFieldValueAsString('StoreCard_ID.EAN');
            mJSON.S['batchCode']:=mbo.GetFieldValueAsString('Name');
            mResultJSON:= TJSONSuperObject.Create;
            mResultJSON:= API_POST(mJSON, 'GetDataFromBatch');
            //NxShowSimpleMessage(mResultJSON.AsString,mSite);
            //mBO.SetFieldValueAsString('X_Verze', mResultJSON.S['version']);
            mBO.SetFieldValueAsString('Specification', mResultJSON.S['specification']);
            mBO.SetFieldValueAsDateTime('ExpirationDate$DATE', mResultJSON.DT8601['expirationDate']);
            mBO.save;
            mBO.free;
            WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;
          TBusRollSiteForm(mSite).RefreshData;
          TBusRollSiteForm(mSite).DataSet.SeekID(mList.Strings[i]);
         except
          WaitWin.Stop;
          NxShowSimpleMessage('Something happend:'+NxCrlF+ExceptionMessage,mSite);
         end;
   end;
 end;
end;

begin
end.