procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import Heureka';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mFirmOfficeBO:TNxCustomBusinessObject;
 mFirmOffices:TNxCustomBusinessMonikerCollection;
 i:integer;
 mOpenDlg:TOpenDialog;
 mTempStr:String;
 mid, mvnor,mid_nadrazeneho, mnazev, mabra_id, mabra_id_nadrazeneho, mid_zbozi_cz, mid_zbozi_cz2, mid_heureka: String;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter:= 'Import z CSV|*.csv';
  mOpenDlg.FilterIndex:= 0;
  if mOpenDlg.Execute then begin
   mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=1 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
         mID:= NxTrapStrTrim(mTempStr, ';');
         mvnor:= NxTrapStrTrim(mTempStr, ';');
         mid_nadrazeneho:= NxTrapStrTrim(mTempStr, ';');
         mnazev:=NxTrapStrTrim(mTempStr, ';');
         mabra_id:= NxTrapStrTrim(mTempStr, ';');
         mabra_id_nadrazeneho:= NxTrapStrTrim(mTempStr, ';');
         mid_zbozi_cz:= NxTrapStrTrim(mTempStr, ';');
         mid_zbozi_cz2:=NxTrapStrTrim(mTempStr, ';');
         mid_heureka:=NxTrapStrTrim(mTempStr, ';');
         if not(NxIsEmptyOID(mabra_id)) then begin
          mBO:=mOS.CreateObject(Class_StoreMenuItem);
          mBO.Load(mabra_id,nil);
          if NxIBStrToFloat(mid_zbozi_cz)>0 then
           mBo.SetFieldValueAsString('X_ZboziCZ1_ID',mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr(Class_CategoriesZboziCZ)+' and code='+QuotedStr(mid_zbozi_cz),''));
          if NxIBStrToFloat(mid_zbozi_cz2)>0 then
           mBo.SetFieldValueAsString('X_ZboziCZ2_ID',mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr(Class_CategoriesZboziCZ)+' and code='+QuotedStr(mid_zbozi_cz2),''));
          if NxIBStrToFloat(mid_heureka)>0 then
           mBo.SetFieldValueAsString('X_HeurekaCZ_ID',mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr(Class_CategoriesHeurekaCZ)+' and x_heurekaid='+QuotedStr(mid_heureka),''));
          mbo.save;
          mBO.Free;
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' záznamů.',mSite);
    end;
   end;
end;




begin
end.