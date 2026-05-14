procedure InitSite_Hook(Self: TSiteForm);
var
  mAct, mAct2: TBasicAction;
  mAlist:TActionList;
  i:Integer;
begin
  mAlist:=self.GetMainActionList;
  mAct := Self.GetNewAction;
  mAct.Caption := 'Nevydaný MAT do CSV';
  mAct.Category := 'tabList';
  mAct.OnExecute := @NevydanyMAT;
end;

Procedure NevydanyMAT(Sender:TComponent);
var
 mSite:TSiteForm;
 mList, mSaveList:TStringList;
 i,j,k,l :integer;
 mOS:TNxCustomObjectSpace;
 mInputs:TNxCustomBusinessMonikerCollection;
 mBO, mInputBO:TNxCustomBusinessObject;
 mMatQuantity, mVMVQuantity:Extended;
 mSaveDialog: TSaveDialog;
 mFile:string;
begin
 mList:=TStringList.create;
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 if mlist.Count>0 then begin
   Try
    l:=mList.Count;
    mSaveList:=TStringList.Create;
    mSaveList.add('Číslo VYP;zakázka;kód karty;název karty;nevydáno;vydáno');
    WaitWin.StartProgress('Čekejte, prosím ...', '', l);
      for i:=0 to mlist.Count-1 do begin
        mBO:=mOS.CreateObject(Class_PLMJobOrder);
        mBO.Load(mList.strings[i],nil);
        mInputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));
        for j:=0 to mInputs.count-1 do begin
           mInputBO:=mInputs.BusinessObject[j];
           if not NxIsEmptyOID(mInputBO.GetFieldValueAsString('Owner_ID.Master_ID')) then begin
             mMatQuantity:=CalcMatQuantity(mInputBO);
             mVMVQuantity:=mOS.SQLSelectFirstAsExtended('SELECT sum(MD.Quantity) FROM PLMMIPLMaterialDistrib MD '+
                                                                ' JOIN PLMJONodes N ON N.ID = MD.Parent_ID '+
                                                                ' WHERE N.ID = '+QuotedStr(mInputBO.OID),0);
             if mVMVQuantity<mMatQuantity then mSaveList.Add(mBO.DisplayName+';'+
                                                             mbo.GetFieldValueAsString('BusOrder_ID.Code')+';'+
                                                             mInputBO.GetFieldValueAsString('Owner_ID.StoreCard_ID.Code')+';'+
                                                             mInputBO.GetFieldValueAsString('Owner_ID.StoreCard_ID.Name')+';'+
                                                             FloatToStr(mMatQuantity-mVMVQuantity)+';'+
                                                             FloatToStr(mVMVQuantity));
           end;
        end;
        mbo.free;
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(l));
        WaitWin.StepIt;
      end;
     WaitWin.Stop;
     if mSaveList.count>0 then begin
      mSaveDialog := TSaveDialog.Create(mSite);
      mSaveDialog.Title := 'Export nevydaných položek do CSV';
      mSaveDialog.Filter :='Soubory *.csv|*.csv';
      mSaveDialog.DefaultExt :='csv';
      mSaveDialog.FilterIndex := 0;
      if mSaveDialog.Execute then mFile:= mSaveDialog.FileName;
       mSaveList.SaveToFile(mFile);
     end;
   except
    WaitWin.Stop;
   end;
 end;
end;

function CalcMatQuantity(var mBO:TNxCustomBusinessObject):extended;
var
  i, mTreeLevel: Integer;
  mMultiplier, mQuantity: Extended;
  mMasterField: String;
begin
  Result:=0;
  mTreeLevel := mbo.GetFieldValueAsInteger('Owner_ID.TreeLevel');
  mQuantity := mBO.GetFieldValueAsFloat('Quantity');
  mMultiplier := 1;
  mMasterField := 'Owner_ID';

  for i := 2 to mTreeLevel do begin
    mMasterField := mMasterField + '.Master_ID';
    mMultiplier := mMultiplier * mBO.GetFieldValueAsFloat(mMasterField + '.Quantity');
  end;

  mQuantity := mQuantity * mMultiplier;
  Result:=mQuantity;
end;

begin
end.