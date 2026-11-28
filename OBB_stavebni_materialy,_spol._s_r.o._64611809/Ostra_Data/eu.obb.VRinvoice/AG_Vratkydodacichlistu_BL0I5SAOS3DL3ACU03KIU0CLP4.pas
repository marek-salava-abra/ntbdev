procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser : TNxCustomBusinessObject;
begin
  //if not Assigned(Self.BaseObjectSpace) then
   mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
   if mUser.GetFieldValueAsBoolean('U_VR') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Dobropisovat';
    mAction.Hint := 'Provede vygenerování mínusové faktury';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    //mAction.OnUpdate := @ImportOnUpdate;
   end;
end;

procedure ImportOnExecute(sender:Tcomponent);
var
 mSite:TsiteForm;
 mList:TStringList;
 mVR, mVRRow, mII, mIIRow, mUser:TNxCustomBusinessObject;
 mVRRows, mInvoiceRows:TNxCustomBusinessMonikerCollection;
 i, j, k:Integer;
 mFirm_ID, mVS, mInvoice_ID:String;
 mOS:TNxCustomObjectSpace;
 mRozdilnaFirma, mJizProvedeno, mBezFaktury, mCerpatelny, mFromDL:Boolean;
begin
 mFirm_ID:='';
 mRozdilnaFirma:=False;
 mJizProvedeno:=False;
 mBezFaktury:=False;
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mUser:=mOS.CreateObject(Class_SecurityUser);
 mUser.Load(NxGetActualUserID(mOS),nil);
 if NxIsEmptyOID(mUser.GetFieldValueAsString('X_II_ID')) then begin
   NxShowSimpleMessage('Přihlášený uživatel nemá na sobě vyplněnou výchozí řadu faktur. Tlačítko nelze použít.', mSite);
   exit;
 end;
 mList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 mRozdilnaFirma:=false;
 mCerpatelny:=false;
 mBezFaktury:=false;
 mJizProvedeno:=false;
 mFromDL:=False;
 if mList.count>0 then begin

    for i:=0 to mList.Count-1 do begin

     mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
     mVR.Load(mList.Strings[i],nil);
     if i=0 then mFirm_ID:=mVR.GetFieldValueAsString('Firm_ID');
     if i>0 then begin
       if not(mFirm_ID=mVR.GetFieldValueAsString('Firm_ID')) then mRozdilnaFirma:=True;
     end;

    end;
    if mRozdilnaFirma then begin
     NxShowSimpleMessage('Označené doklady jsou vystaveny pro rozdílné firmy. Mínusovou fakturu nelze vytvořit.', mSite);
     exit;
    end;
    for i:=0 to mList.Count-1 do begin
     mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
     mVR.Load(mList.Strings[i],nil);
     if not(mvr.GetFieldValueAsBoolean('IsAvailableForDelivery')) then begin
      mCerpatelny:=True;
      //NxShowSimpleMessage(mvr.DisplayName,mSite);
     end;

    end;
    if mCerpatelny then begin
     NxShowSimpleMessage('Označené doklady nejsou čerpatelné. Mínusovou fakturu nelze vytvořit.', mSite);
     exit;
    end;
    for i:=0 to mList.Count-1 do begin
     mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
     mVR.Load(mList.Strings[i],nil);
     if (mvr.GetFieldValueAsBoolean('U_vratkaDL')) then begin
      mFromDL:=True;
      //NxShowSimpleMessage(mvr.DisplayName,mSite);
     end;

    end;
    if mFromDL then begin
     NxShowSimpleMessage('Označené doklady jsou vytvořené jen z DL. Mínusovou fakturu nelze vytvořit.', mSite);
     exit;
    end;
    for i:=0 to mList.Count-1 do begin
     mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
     mVR.Load(mList.Strings[i],nil);
     mVS:='';
     if not(mBezFaktury) then begin
       for j:=0 to mVR.GetLoadedCollectionMonikerForFieldCode(mVR.GetFieldCode('Rows')).count-1 do begin;
       mVS:=GetVS(mOS,mVR.GetLoadedCollectionMonikerForFieldCode(mVR.GetFieldCode('Rows')).BusinessObject[j].GetFieldValueAsString('RDocumentRow_ID'));
       //NxShowSimpleMessage(mVS+' '+mVR.GetLoadedCollectionMonikerForFieldCode(mVR.GetFieldCode('Rows')).BusinessObject[j].GetFieldValueAsString('RDocumentRow_ID') ,mSite);
       if NxIsBlank(mVS) and not(mBezFaktury) then mBezFaktury:=True;
      end;
     end;
    end;
    if mBezFaktury then begin
     NxShowSimpleMessage('Některý z označených dokladů nebyl fakturován zákazníkovi, nebo fakturu nelze dohledat. Mínusovou fakturu nelze vytvořit.', mSite);
     exit;

    end;
    for i:=0 to mList.Count-1 do begin
     mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
     mVR.Load(mList.Strings[i],nil);
     if not(mJizProvedeno) then mJizProvedeno:=mvr.GetFieldValueAsBoolean('U_dobropisovano');

    end;
    if mJizProvedeno then begin
     NxShowSimpleMessage('Některý z označených dokladů byl již dobropisován. Mínusovou fakturu nelze vytvořit . ', mSite);
     exit;
    end;

    if NxMessageBox('Dotaz','Přejete si vygenerovat mínusovou fakturu na označené vratky?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     try
      mII:=mOS.CreateObject(Class_IssuedInvoice);
      mII.New;
      mII.Prefill;
      mII.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_II_ID'));
      mII.SetFieldValueAsString('Firm_ID',mFirm_ID);
      mII.SetFieldValueAsString('Description','Dobropis hromadné vratky');
      mII.SetFieldValueAsBoolean('U_vratka',True);
      mInvoiceRows:=mII.GetCollectionMonikerForFieldCode(mII.GetFieldCode('Rows'));
      for i:=0 to mList.Count-1 do begin
       mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
       mVR.Load(mList.Strings[i],nil);
       mVRRows:=mVR.GetLoadedCollectionMonikerForFieldCode(mVR.GetFieldCode('Rows'));
       for j:=0 to mVRRows.Count-1 do begin
         mIIRow:=mInvoiceRows.AddNewObject;
         mIIRow.SetFieldValueAsInteger('RowType',0);
         mIIRow.SetFieldValueAsString('Text',mVR.DisplayName+' z '+FormatDateTime('d.m.yyyy',mvr.GetFieldValueAsDateTime('DocDate$Date')));
         mIIRow.SetFieldValueAsString('Division_ID',mVRRows.BusinessObject[j].GetFieldValueAsString('Division_ID'));
         mIIRow.SetFieldValueAsString('BusTransaction_ID',mVRRows.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID'));
         mIIRow:=mInvoiceRows.AddNewObject;
         mIIRow.SetFieldValueAsInteger('RowType',2);
         mIIRow.SetFieldValueAsString('Text',mVRRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.Code') +' '+mVRRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.Name')+ '   z faktury s VS: '+GetVS(mOS,mVRRows.BusinessObject[j].GetFieldValueAsString('RDocumentRow_ID')));
         mIIRow.SetFieldValueAsFloat('Quantity',mVRRows.BusinessObject[j].GetFieldValueAsFloat('Quantity'));
         mIIRow.SetFieldValueAsFloat('UnitPrice',-(GetPrice(mOS,mVRRows.BusinessObject[j].GetFieldValueAsString('RDocumentRow_ID'))-mVRRows.BusinessObject[j].GetFieldValueAsFloat('StoreCard_ID.U_opotrebeni')));
         mIIRow.SetFieldValueAsString('Qunit',mVRRows.BusinessObject[j].GetFieldValueAsString('Qunit'));
        // mIIRow.SetFieldValueAsFloat('VatRate',21);//mVRRows.BusinessObject[j].GetFieldValueAsFloat('StoreCard_ID.VatRate'));
         mIIRow.SetFieldValueAsString('VatRate_ID','02100X0000');
         mIIRow.SetFieldValueAsString('Division_ID',mVRRows.BusinessObject[j].GetFieldValueAsString('Division_ID'));
         mIIRow.SetFieldValueAsString('BusOrder_ID',mVRRows.BusinessObject[j].GetFieldValueAsString('BusOrder_ID'));
         mIIRow.SetFieldValueAsString('BusTransaction_ID',mVRRows.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID'));
         mVRRows.BusinessObject[j].SetFieldValueAsFloat('DeliveredQuantity',mVRRows.BusinessObject[j].GetFieldValueAsFloat('Quantity'));
       end;
       mVR.SetFieldValueAsBoolean('U_dobropisovano',true);
       mVR.SetFieldValueAsBoolean('IsAvailableForDelivery',false);
       mVR.Save;
       mvr.Free;
      end;
      if mInvoiceRows.CountOfNotDeleted>0 then begin
       mII.save;
       mInvoice_ID:=mii.OID;
      end;
     except
         NxShowSimpleMessage('Nepovedlo se, vracím zpět. '+ExceptionMessage,mSite);
         exit;
     end;
      for i:=0 to mList.Count-1 do begin
        mVR:=mOS.CreateObject(Class_RefundedBillOfDelivery);
        mVR.Load(mList.Strings[i],nil);
        mvr.SetFieldValueAsString('Description', 'Dobropisováno fakturou: '+mii.DisplayName);
        mVR.Save;
        mvr.Free;

       end;
      if not(NxIsEmptyOID(mInvoice_ID)) then begin
        if NxMessageBox('Dotaz','Vytvořil jsem doklad '+mii.DisplayName+'. Přejete si jej nyní zobrazit?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
         msite.ShowDynForm('PLC2EX0BUJD13ACP03KIU0CLP4', nil, nil, True, 'DoShow;' + mii.OID);
        end;
      end;
      mii.free;
    end;
 end;
 TDynSiteForm(mSite).RefreshData;
 mlist.free;
end;

procedure _SetReadOnlyForDetail_Hook(Self: TDynSiteForm; AReadOnly: Boolean);
begin

end;

function GetPrice(AOS : TNxCustomObjectSpace; ABodRow_ID : string) : Extended;
const
  cSQL = 'SELECT TAmountWithoutVAT/(quantity*UnitRate) from IssuedInvoices2 where ProvideRow_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ABodRow_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetVS(AOS : TNxCustomObjectSpace; ABodRow_ID : string) : String;
const
  cSQL = 'SELECT Parent_ID from IssuedInvoices2 where ProvideRow_ID=''%s'' ';
var
  mList : TStringList;
  mII_ID:String;
  mII:TNxCustomBusinessObject;
begin
  mList := TStringList.Create;
  Result:='';
  try
    AOS.SQLSelect(Format(cSQL, [ABodRow_ID]), mList);
    if mList.Count > 0 then
      mII_ID:= mList.Strings[0];
      if not(NxIsEmptyOID(mII_ID)) then begin
        mII:=aos.CreateObject(Class_IssuedInvoice);
        mII.Load(mII_ID,nil);
        Result:=mii.GetFieldValueAsString('VarSymbol');
        mii.Free;


      end;
  finally
    mList.Free;
  end;
end;


begin
end.
