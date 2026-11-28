procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Vytvořit OP z OV';
mBut.Category := 'tabList';
mBut.OnExecute := @Import;

end;

procedure Import(sender:TComponent);
var
 mString, mString2, mDQCode, mOrdNumber, mPeriodCode, mDocument_ID:sTring;
 mDestinationStore_id,mObjednavka_ID, mDivision_ID, mFirm_ID, mFirmOffice_ID, mObjednavkaDQ_ID, mBT_ID:String;
 mList:TStringList;
 mSite:TSiteForm;
 mContext: TNxContext;
 mOLE: TNxCustomObjectSpace;
 mUser, mOPBO, mOVBO, mOPRowBO, mOVRowBO:TNxCustomBusinessObject;
 mOPRows, mOVRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
begin
   try
    mDocument_ID:='';
    mDQCode:='';
    mOrdNumber:='';
    mPeriodCode:='';
    mSite:=TComponent(sender).DynSite;
    mUser:=msite.GetFakeBusinessObject.ObjectSpace.CreateObject(Class_SecurityUser);
    mUser.Load(NxGetActualUserID_1(msite.GetFakeBusinessObject),nil);
    mDestinationStore_id:=muser.GetFieldValueAsString('X_store_ID');
    mDivision_ID:=muser.GetFieldValueAsString('X_division_ID');
    mObjednavkaDQ_ID:=mUser.GetFieldValueAsString('X_RO_ID');
    if NxIsEmptyOID(mDestinationStore_id) then begin
      NxShowSimpleMessage('Uživatel nemá vyplněn výchozí sklad.',mSite);
      exit;
    end;
    if NxIsEmptyOID(mDivision_ID) then begin
      NxShowSimpleMessage('Uživatel nemá vyplněn výchozí středisko.',mSite);
      exit;
    end;
    if NxIsEmptyOID(mObjednavkaDQ_ID) then begin
      NxShowSimpleMessage('Uživatel nemá vyplněn výchozí řadu dokladu pro objednávku.',mSite);
      exit;
    end;
    muser.Free;

    mString:=InputBox('Objednávka vydaná','Zadejte číslo dokladu','');
    mString2:=mString;
    if (NxSearch(mString2,'-',[srAll],0)=0) or (NxSearch(mString2,'/',[srAll],0)=0) then begin
      NxShowSimpleMessage('Nepodařilo se dohledat doklad s číslem '+mString2+'.',mSite);
      exit;
    end;
    mDQCode:=NxToken(mString,'-');
    mOrdNumber:=NxToken(mString,'/');
    mPeriodCode:=mString;
    mList:=TStringList.Create;
    msite.GetFakeBusinessObject.ObjectSpace.SQLSelect(format('Select sd.id from issuedorders sd /*left*/ join periods p on p.id=sd.period_id /*left*/ join docqueues dq on dq.id=sd.docqueue_id where dq.code=''%s'' and p.code=''%s'' and sd.ordnumber=%s',[UpperCase(mDQCode),mPeriodCode,mOrdNumber]),mList);
    if mList.count>0 then mDocument_ID:=mList.Strings[0];
    if NxIsEmptyOID(mDocument_ID) then begin
      NxShowSimpleMessage('Nepodařilo se dohledat doklad s číslem '+mString2+'.',mSite);
      exit;
    end;
    if not(NxIsEmptyOID(mDocument_ID)) then begin

      try
        mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
        mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
        mOVBO:=mContext.GetObjectSpace.CreateObject(Class_IssuedOrder);
        mOVBO.Load(mDocument_ID,nil);
        mOPBO:=mContext.GetObjectSpace.Createobject(Class_ReceivedOrder);
        mOPBO.New;
        mopbo.Prefill;
        mopbo.SetFieldValueAsString('DocQueue_ID',mObjednavkaDQ_ID);
        mOPBO.SetFieldValueAsString('Firm_ID','1IA0000101');
        mOPBO.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
        mOPBO.SetFieldValueAsBoolean('IsRowDiscount', True);
        mOPBO.SetFieldValueAsString('Description',AnsiLeftStr(mOVBO.displayname+' '+movbo.GetFieldValueAsString('Firm_ID.Name'),50));
        mOPRows:=mOPBO.GetLoadedCollectionMonikerForFieldCode(mOPBO.GetFieldCode('Rows'));
        mOVRows:=mOVBO.GetLoadedCollectionMonikerForFieldCode(mOVBO.GetFieldCode('Rows'));
        for i:=0 to mOVRows.count-1 do begin
          mOVRowBO:=movrows.BusinessObject[i];
          if mOVRowBO.GetFieldValueAsInteger('RowType') in [0,1,2,3] then begin
            mOPRowBO:=mOPRows.AddNewObject;
            mOPRowBO.SetFieldValueAsInteger('RowType',mOVRowBO.GetFieldValueAsInteger('RowType'));
            moprowbo.SetFieldValueAsString('Store_ID',mDestinationStore_id);
            mOProwbo.SetFieldValueAsString('StoreCard_ID',mOVRowBO.GetFieldValueAsString('StoreCard_ID'));
            moprowbo.SetFieldValueAsString('QUnit', mOVRowbo.GetFieldValueAsString('QUnit'));
            mOPRowbo.SetFieldValueAsFloat('Quantity',movrowbo.GetFieldValueAsfloat('Quantity'));
            mOPRowbo.SetFieldValueAsFloat('UnitQuantity',movrowbo.GetFieldValueAsfloat('UnitQuantity'));
            mOPRowbo.SetFieldValueAsFloat('UnitRate',movrowbo.GetFieldValueAsfloat('UnitRate'));
            mOPRowBo.SetFieldValueAsString('U_Poznamka',mOVRowBO.GetFieldValueAsString('U_poznamka'));
            mOPRowbo.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOPRowbo.SetFieldValueAsString('BusTransaction_ID',mBT_ID);
            moprowbo.SetFieldValueAsString('X_StockType_ID','1000000101');
            mOprowbo.SetFieldValueAsFloat('UnitPrice',0);
            mOPROWbo.SetFieldValueAsFloat('TotalPrice',0);
          end;
        end;
        mOPBO.save;
        mObjednavka_ID:=mopbo.oid;
        NxShowSimpleMessage('Založil jsem objednávku přijatou '+mOPBO.DisplayName+'.',mSite);
        mContext.free;
      finally


      end;
    end;
   finally
    TDynSiteForm(mSite).RefreshData;
    TDynSiteForm(mSite).ActiveDataSet.SeekID(mObjednavka_ID);
   end;

end;


begin
end.