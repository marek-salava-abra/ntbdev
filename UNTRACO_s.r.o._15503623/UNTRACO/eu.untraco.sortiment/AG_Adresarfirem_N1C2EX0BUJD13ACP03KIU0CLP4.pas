procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Přidat sortimentní slevy';
mBut.Category := 'tabDetail';
mBut.OnExecute := @Import;

end;


procedure Import (sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mCurrentBO, mDiscountBO:TNxCustomBusinessObject;
 mSQL, ID, mAss_ID:String;
 mList:TStringList;
 mCol:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mParams:TNxParameters;
 mRoll, mOLE:Variant;
 mSelected : Variant;
 mDiscount:Extended;
 mCount:integer;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:= TBusRollSiteForm(mSite).CurrentObject.ObjectSpace;
 mCurrentBO := TBusRollSiteForm(mSite).CurrentObject;
 mDiscount:=StrToFloat(InputBox('Procento slevy','Procento slevy','0'));
 //mParams := TNxParameters.Create;
 //aContext:=NxCreateContext_1(mCurrentBO);
 //mRoll:=aContext.GetRoll('QVD5MPM0ZEI4XH5RNSIBE00MGG',0);
 //mParams.GetOrCreateParam(dtString, '_ID', pkInputOutput).AsString := ID;
 //NxShowRoll(TBusRollSiteForm(mSite).SiteContext, 'QVD5MPM0ZEI4XH5RNSIBE00MGG', mParams, 0, '', msite);
 //NxShowSimpleMessage(mParams.ParamByName('_ID').AsString, mSite);
 //mSQL:='Select id from StoreAssortmentGroups where hidden=''N'' ';
 mList:=TStringList.Create;
 mOLE := GetAbraOLEApplication;
 mSelected := mOLE.CreateStrings;
 mRoll := mOLE.getRoll('QVD5MPM0ZEI4XH5RNSIBE00MGG',0);
 mRoll.MultiSelectDialog(True, mSelected);
 //mos.SQLSelect(mSQL,mList);
 mCol:= mCurrentBO.GetLoadedCollectionMonikerForFieldCode(mCurrentBO.GetFieldCode('AssortmentDiscounts'));
 //if mCol.Count=0 then begin
    for i:=0 to mSelected.Count-1 do begin
        mCount:=mOS.SQLSelectFirstAsInteger('Select count(id) from storecards where hidden=''N'' and StoreAssortmentGroup_ID='+QuotedStr(mSelected.strings[i]),0);
        if mCount>0 then begin
          mAss_ID:=mOS.SQLSelectFirstAsString('Select id from FirmAssortmentDiscounts where parent_id='+QuotedStr(mCurrentBO.OID)+' and StoreAssortmentGroup_ID='+QuotedStr(mSelected.strings[i]),'');
          if NxIsEmptyOID(mAss_ID) then begin
            mDiscountBO:=mCol.AddNewObject;
            mDiscountBO.Prefill;
            mDiscountBO.SetFieldValueAsString('StoreAssortmentGroup_ID', mSelected.Strings[i]);
            mDiscountBO.SetFieldValueAsFloat('Discount', mDiscount);
            mDiscountBO.SetFieldValueAsString('Price_ID','1000000101');
          end;
        end;
    end;
 //end;
 mCurrentBO.save;
 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
end;

begin
end.