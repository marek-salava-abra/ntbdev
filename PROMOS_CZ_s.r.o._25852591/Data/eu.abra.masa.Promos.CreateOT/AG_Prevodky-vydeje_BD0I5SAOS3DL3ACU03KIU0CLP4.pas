procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actInsertRows';
  mAction.Caption := 'Doplnění Dýr';
  mAction.Hint := 'Doplní skladovou zásobu do minima';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @InsertRows;
end;

procedure InsertRows(sender:TComponent);
var
 mSite:TSiteForm;
 mNeededQuantity, mAvailableQuantity:Extended;
 mStoreSubCardList:TStringList;
 i:integer;
 mFirm_ID:string;
 mOS:TNxCustomObjectSpace;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mOTRowBO, mSSCBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
  if not(TDynSiteForm(mSite).Edit) then begin
    NxShowSimpleMessage('Nejste ve stavu editace, řádky nepůjde vložit.',mSite);
    exit;
  end;
      mStoreSubCardList:=TStringList.create;
      mOS.SQLSelect('Select ssc.id from storesubcards ssc left join storecards sc on sc.id=ssc.storecard_id where ssc.store_id='+Quotedstr('2100000101')+' and ssc.lowlimitquantity>0 and ssc.lowlimitquantity>(ssc.quantity-ssc.bookedquantity) order by sc.code',mStoreSubCardList);
      if mStoreSubCardList.count>0 then begin
        mControl:= mSite.FindChildControl('tabRows.grdRows');
        mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
        if Assigned(mDataset) then begin
        mDataSet.DisableControls;
         WaitWin.StartProgress('Čekejte, prosím ...', '', mStoreSubCardList.Count);
          for i:=0 to mStoreSubCardList.count-1 do begin
                  mSSCBO:=mOS.CreateObject(Class_StoreSubCard);
                  msscbo.load(mStoreSubCardList.strings[i],nil);
                  mNeededQuantity:=mSSCBO.GetFieldValueAsFloat('LowLimitQuantity')-(mSSCBO.GetFieldValueAsFloat('Quantity')-mSSCBO.GetFieldValueAsFloat('BookedQuantity'));
                  mAvailableQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity-bookedquantity from storesubcards where storecard_id='+QuotedStr(mSSCBO.GetFieldValueAsString('StoreCard_ID'))+
                                                                   ' and store_id='+Quotedstr('1000000101'),0);
                  if mAvailableQuantity>0 then begin
                         mOTRowBO:=mDataset.CreateBusinessObject;
                         mOTRowBO.Prefill;
                         mOTRowBO.SetFieldValueAsString('Store_ID','1000000101');
                         mOTRowBO.SetFieldValueAsString('StoreCard_ID',mSSCBO.GetFieldValueAsString('StoreCard_ID'));
                         if mNeededQuantity<mAvailableQuantity then
                         mOTRowBO.SetFieldValueAsFloat('Quantity',mNeededQuantity) else
                         mOTRowBO.SetFieldValueAsFloat('Quantity',mAvailableQuantity);
                         mOTRowBO.SetFieldValueAsString('Division_ID','1000000101');
                  end;

           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mStoreSubCardList.Count));
             WaitWin.StepIt;
          end;
         WaitWin.Stop;
         TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
         mDataset.RefreshAndRestoreLastSelectedItem;
         mDataSet.EnableControls;
        end;
     end;
end;

begin
end.