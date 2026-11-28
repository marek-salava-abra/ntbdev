procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mBO, mRowBO, mUserBO:TNxCustomBusinessObject;
 mErrorList, mBusStatus, mOrderStatus, mCList1, mCList2, mCList3:TStringList;
 mCode, mName, mStatusText, mPMName, mStatus1, mStatus2, mStatus3:string;
 mOrderStatusAuth:Boolean;
begin
  mOrderStatusAuth:=False;
  mBO:=TDynSiteForm(Self).CurrentObject;
  mUserBO:=mBO.ObjectSpace.CreateObject(Class_SecurityUser);
  mUserBO.Load(NxGetActualUserID_1(mBO),nil);
  mOrderStatusAuth:=mUserBO.GetFieldValueAsBoolean('U_OrderStatusAuth');
  mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
  mErrorList:=TStringList.Create;
  mBusStatus:=TStringList.Create;
  mOrderStatus:=TStringList.Create;
  mCList1:=TStringList.Create;
  mCList2:=TStringList.Create;
  mCList3:=TStringList.Create;
  mStatus1:='';
  mStatus2:='';
  mStatus3:='';
  mBusStatus.Text:=mBO.ObjectSpace.SQLSelectFirstAsString('Select Enumeration from userfielddefs2 where parent_id=''1300000101'' and fieldcode=2000034','');
  mOrderStatus.Text:=mBO.ObjectSpace.SQLSelectFirstAsString('Select Enumeration from userfielddefs2 where parent_id=''1300000101'' and fieldcode=2000037','');
  for i:=0 to mRows.count-1 do begin
    mRowBO:=mRows.BusinessObject[i];
    if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
      if mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_BusinessStatus') in [1, 2, 3] then begin
        mCode:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
        mName:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
        mStatusText:=mBusStatus.Strings[mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_BusinessStatus')];
        if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM'))) then
         mPMName:=mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM.U_ProductManName')
         else mPMName:='';
        mErrorList.Add(mCode+' '+mStatusText+' '+mPMName);
      end;
      if (mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_OrderStatus')=2) and not(mBO.GetFieldValueAsString('Firm_ID')='1IA0000101') then begin
        mCode:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
        mName:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
        mStatusText:=mOrderStatus.Strings[mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_OrderStatus')];
        if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM'))) then
         mPMName:=mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM.U_ProductManName')
         else mPMName:='';
        mStatus1:=mStatusText;
        mCList1.Add(mCode+' '+mName+'  Manažer: '+mPMName);
      end;
      if (mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_OrderStatus')=3) and not(mBO.GetFieldValueAsString('Firm_ID')='1IA0000101') then begin
        mCode:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
        mName:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
        mStatusText:=mOrderStatus.Strings[mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_OrderStatus')];
        if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM'))) then
         mPMName:=mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM.U_ProductManName')
         else mPMName:='';
        mStatus2:=mStatusText;
        mCList2.Add(mCode+' '+mName+'  Manažer: '+mPMName);
      end;
      if (mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_OrderStatus')=4) and not(mBO.GetFieldValueAsString('Firm_ID')='1IA0000101') then begin
        mCode:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
        mName:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
        mStatusText:=mOrderStatus.Strings[mRowBO.GetFieldValueAsInteger('StoreCard_ID.U_OrderStatus')];
        if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM'))) then
         mPMName:=mRowBO.GetFieldValueAsString('StoreCard_ID.X_ProductM.U_ProductManName')
         else mPMName:='';
        mStatus3:=mStatusText;
        mCList3.Add(mCode+' '+mName+'  Manažer: '+mPMName);
      end;
    end;
  end;
  if mErrorList.count>0 then begin
    if NxMessageBox('Dotaz','Objednávka obsahuje zboží, které mají vyplněnou kontrolovanou dostupnost'+NxCrlf+NxCrLf+mErrorList.Text+NxCrlf+NxCrlf+
                    'Objednání podléhá schválení či vyjádření produkt manažera, opravdu uložit?', mdConfirm, mdbYesNo, 0, 0, False, self)= mrYes
                    then ACanSaveNow:=True else ACanSaveNow:=False;
  end;
  if mCList1.count>0 then begin
    if mOrderStatusAuth then begin
      if NxMessageBox('Dotaz','Objednávka obsahuje zboží, které mají status '+mStatus1+NxCrlf+NxCrLf+mCList1.Text+NxCrlf+NxCrlf+
                          'Zboží se objednává pouze centrálně a kontaktujte produkt manažera, opravdu uložit?', mdConfirm, mdbYesNo, 0, 0, False, self)= mrYes
                    then ACanSaveNow:=True else ACanSaveNow:=False;
    end else begin
      NxShowSimpleMessage('Objednávka obsahuje zboží, které mají status '+mStatus1+NxCrlf+NxCrLf+mCList1.Text+NxCrlf+NxCrlf+
                          'Zboží se objednává pouze centrálně. Kontaktujte produkt manažera.',Self);
      ACanSaveNow:=False;
    end;
  end;
  if mCList2.count>0 then begin
    if NxMessageBox('Dotaz','Objednávka obsahuje zboží, které mají status '+mStatus2+NxCrlf+NxCrLf+mCList2.Text+NxCrlf+NxCrlf+
                    'Objednávka tohoto zboží se vždy konzultuje s produkt manažerem. Skutečně uložit?', mdConfirm, mdbYesNo, 0, 0, False, self)= mrYes
                    then ACanSaveNow:=True else ACanSaveNow:=False;
  end;
  if mCList3.count>0 then begin
    if NxMessageBox('Dotaz','Objednávka obsahuje zboží, které mají status '+mStatus3+NxCrlf+NxCrLf+mCList3.Text+NxCrlf+NxCrlf+
                    'Zboží se přednostně převáží mezi pobočkami, konzultuje s produkt manažerem. Skutečně uložit?', mdConfirm, mdbYesNo, 0, 0, False, self)= mrYes
                    then ACanSaveNow:=True else ACanSaveNow:=False;
  end;
  mErrorList.free;
  mBusStatus.free;
  mOrderStatus.free;
  mUserBO.free;
end;

begin
end.