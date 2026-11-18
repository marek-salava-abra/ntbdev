procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actObal';
  mAction.Caption := 'Přesuň obaly';
  mAction.Hint := 'Přesune obaly do obalů';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Obal;
end;

Procedure Obal(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k:integer;
 mList:TStringList;
 mKrabicka_ID, mSacek_ID:string;
 mBO, mUnitBO, mContainerBO:TNxCustomBusinessObject;
 mUnits, mContainers:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.Create;
 mOS.SQLSelect('select id from storecards where hidden=''N'' and (not(X_Krabicka_ID is null) or not(X_sacek_id is null))', mList);
 if mList.count>0 then begin
   try
    WaitWin.StartProgress('Plním obaly ...', '', mList.Count);
     for i:=0 to mlist.count-1 do begin
      mBO:=mOS.CreateObject(Class_StoreCard);
      mBO.Load(mList.Strings[i],nil);
      mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
      for j:=0 to mUnits.count-1 do begin
        mUnitBO:=mUnits.BusinessObject[j];
        if mUnitBO.GetFieldValueAsString('Code')=mbo.GetFieldValueAsString('MainUnitCode') then begin
          mContainers:=mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreContainers'));
          if mContainers.count>0 then begin
            for k:=0 to mContainers.count-1 do mContainers.BusinessObject[k].MarkForDelete;
          end;
          mKrabicka_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and category=4 and id='+QuotedStr(mbo.GetFieldValueAsString('X_Krabicka_ID')),'');
          mSacek_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and category=4 and id='+QuotedStr(mbo.GetFieldValueAsString('X_Sacek_ID')),'');
          if not(NxIsEmptyOID(mKrabicka_ID)) then begin
             mContainerBO:=mContainers.AddNewObject;
             mContainerBO.prefill;
             mContainerBO.SetFieldValueAsString('StoreCard_ID',mKrabicka_ID);
             mContainerbo.SetFieldValueAsFloat('UnitQuantity',1);
          end;
          if not(NxIsEmptyOID(mSacek_ID)) then begin
             mContainerBO:=mContainers.AddNewObject;
             mContainerBO.prefill;
             mContainerBO.SetFieldValueAsString('StoreCard_ID',mSacek_ID);
             mContainerbo.SetFieldValueAsFloat('UnitQuantity',1);
          end;
        end;
      end;
      mBO.save;
      mbo.free;
      WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mlist.Count));
      WaitWin.StepIt;
     end;
    WaitWin.Stop;
   except
    NxShowSimpleMessage(ExceptionMessage,mSite);
    WaitWin.Stop;
   end;
 end;
end;

begin
end.