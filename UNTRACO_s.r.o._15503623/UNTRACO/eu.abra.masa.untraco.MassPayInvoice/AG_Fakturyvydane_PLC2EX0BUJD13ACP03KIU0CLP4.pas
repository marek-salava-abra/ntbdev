uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mBut:= Self.GetNewAction;
  mBut.ShowControl := True;
  mBut.ShowMenuItem := True;
  mBut.Caption := 'Hromadná úhrada faktur';
  mBut.Hint := 'Uhradit označené faktury pokladnou';
  mBut.Category := 'tabList';
  mBut.OnExecute := @PayInvoices;
end;

Procedure PayInvoices(Sender:TComponent);
var
 mSite:TSiteForm;
 mIIList, mCRList:TStringList;
 i, j, mResult, mTempResult:Integer;
 mII, mCR, mCRForPrefill, mCRRow:TNxCustomBusinessObject;
 mDialog, mKarta, mUdaje, mStejnaFirma:Boolean;
 mCashDesk_ID, mDocQueue_ID, mFirm_ID:String;
 mOS:TNxCustomObjectSpace;
 mAmount, mRoundedAmount:Extended;
 mRows:TNxCustomBusinessMonikerCollection;
 P: TNxParameters;
 mPar: TNxParameter;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mIIList:=TStringList.create;
 mCashDesk_ID:='';
 mDocQueue_ID:='';
 mResult:=0;
 mTempResult:=0;
 mAmount:=0;
 mRoundedAmount:=0;
 TDynSiteForm(mSite).List.GetSelectedId(mIIList);
 mStejnaFirma:=True;
 if mIIList.count>0 then begin
   for i:=0 to mIIList.count-1 do begin
     mII:=mOS.CreateObject(Class_IssuedInvoice);
     mII.Load(mIIList.strings[i],nil);
     mAmount:=mAmount+mii.GetFieldValueAsFloat('NotPaidAmount');
     mRoundedAmount:=mRoundedAmount+NxRoundByValue(mii.GetFieldValueAsFloat('NotPaidAmount'),ctArithmetic,1);
     if i=0 then mFirm_ID:=mii.GetFieldValueAsString('Firm_ID');
     if i>0 then begin
       if not(mFirm_ID=mii.GetFieldValueAsString('Firm_ID')) then mStejnaFirma:=False;


     end;
     mII.Free;

   end;
   {if not(mStejnaFirma) then begin
          NxShowSimpleMessage('Ruším zadávání plateb, označené doklady nejsou na stejnou firmu',mSite);
          TDynSiteForm(mSite).RefreshData;
          exit;
   end;  }
    if Nxroundbyvalue(mAmount,ctArithmetic,0.01)=0 then begin
         NxShowSimpleMessage('Nelze vytvořit nulový doklad.',mSite);
         exit;
       end;
   if not(mAmount=0) then begin
      //if NxMessageBox('Dotaz','Přejete si uhradit '+IntToStr(mIIlist.count)+' faktur na celkovou částku '+NxFormatNumeric('0.00,',mAmount,mOS)+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       if True then begin
       if Nxroundbyvalue(mAmount,ctArithmetic,0.01)=0 then begin
         NxShowSimpleMessage('Nelze vytvořit nulový doklad.',mSite);
         exit;
       end;
       //GetPaymenttype(mSite,'Přejete si uhradit '+IntToStr(mIIlist.count)+' faktur na celkovou částku '+NxFormatNumeric('0.00,',mAmount,mOS)+'?',mTempResult);
       //if mTempResult=1 then begin
       //   mKarta:=True;
       //   mRoundedAmount:=0;
       //   mUdaje:=GetPaymentDate(mSite,mCashDesk_ID,mDocQueue_ID,mKarta, mResult, mAmount);
       //end;
       mTempResult:=2;
       if mTempResult=2 then begin
          mKarta:=False;
          mAmount:=0;
          mUdaje:=GetPaymentDate(mSite,mCashDesk_ID,mDocQueue_ID,mKarta, mResult, mRoundedAmount);
          if Nxroundbyvalue(mRoundedAmount,ctArithmetic,0.01)=0 then begin
             NxShowSimpleMessage('Doklad byl již plně uhrazen.',mSite);
             exit;
          end;
       end;

        if mResult=2 then begin
          NxShowSimpleMessage('Ruším zadávání plateb',mSite);
          exit;
        end;
         mCRList:=TStringList.Create;
         for i:=0 to mIIList.count-1 do begin
            mII:=mOS.CreateObject(Class_IssuedInvoice);
            mII.Load(mIIList.strings[i],nil);
            mAmount:=mii.GetFieldValueAsFloat('NotPaidAmount');
            if not(mAmount=0) then begin
            mCR:=mOS.CreateObject(Class_CashReceived);
            mCr.New;
            mCr.Prefill;
            mCR.SetFieldValueAsString('CashDesk_ID',mCashDesk_ID);
            mCR.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
            mCr.SetFieldValueAsBoolean('VATDocument',false);
            mCR.SetFieldValueAsString('Firm_ID',mII.GetFieldValueAsString('Firm_ID'));
            mCR.SetFieldValueAsString('Description', 'Zaplacení '+mII.DisplayName);
            mCR.SetFieldValueAsString('PDocumentType','03');
            mCR.SetFieldValueAsString('PDocument_ID',mII.OID);
            if not(mKarta) then mCR.SetFieldValueAsInteger('TotalRounding',257);
            if mKarta then mCR.SetFieldValueAsInteger('TotalRounding',-33554175);
            //mCR.SetFieldValueAsBoolean('EET',False);
            mRows:=mCR.GetCollectionMonikerForFieldCode(mCR.GetFieldCode('Rows'));
             mCRRow:=mRows.AddNewObject;
             mCRRow.SetFieldValueAsInteger('RowType',1);
             mCRRow.SetFieldValueAsString('Text','Zaplacení '+mII.DisplayName);
             mCRRow.SetFieldValueAsFloat('TotalPrice',mii.GetFieldValueAsFloat('NotPaidAmount'));
             mCRRow.SetFieldValueAsString('Division_ID',mII.GetLoadedCollectionMonikerForFieldCode(mII.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'));
            mCR.Save;
            //TNxEETTurnover(mCR.GetMonikerForFieldCode(mcr.GetFieldCode('EETTurnover_ID')).BusinessObject).Process('');
            mCRList.Add(mCR.OID);
            mCR.Free;
            end;
            mII.Free;

         end;
        if  mCRList.Count>0 then begin
           CFxReportManager.PrintByIDs(msite.SiteContext,mCRList,'0Z4R1NY0FJDL3BLX00C5OG4NF4','X400000101',rtoPreview,pekPDF,'','');
          { P := TNxParameters.Create;
           try
             P.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Nově vytvořené pokladní příjmy';
             mPar := P.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; //mPar je typu TNxParameter
             mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
             mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
             mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
             mPar.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mCRList);
             ShowDynForm('S5C2EX0BUJD13ACP03KIU0CLP4',TDynSiteForm(mSite).SiteContext, P, nil, True);
             finally
               P.Free;
             end;
         end else  NxMessageBox('Chyba','Nebyla vybrána žádná faktura s nenulovou výší úhrady!',mdError, mdbOk, mrOK, [mdpSystemModal], False, nil);
          }
         end;

      end;
   end;
 end;
 TDynSiteForm(mSite).RefreshData;
end;

Procedure PayInvoice(Sender:TComponent);
var
 mSite:TSiteForm;
 mIIList, mCRList:TStringList;
 i, j, mResult, mTempResult:Integer;
 mII, mCR, mCRForPrefill, mCRRow:TNxCustomBusinessObject;
 mDialog, mKarta, mUdaje, mStejnaFirma:Boolean;
 mCashDesk_ID, mDocQueue_ID, mFirm_ID:String;
 mOS:TNxCustomObjectSpace;
 mAmount, mRoundedAmount:Extended;
 mRows:TNxCustomBusinessMonikerCollection;
 P: TNxParameters;
 mPar: TNxParameter;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mIIList:=TStringList.create;
 mCashDesk_ID:='';
 mDocQueue_ID:='';
 mResult:=0;
 mTempResult:=0;
 mAmount:=0;
 mRoundedAmount:=0;
 mKarta:=False;
 mCRForPrefill:=mOS.CreateObject(Class_CashReceived);
 mCRForPrefill.new;
 mCRForPrefill.Prefill;
 mCashDesk_ID:=mCRForPrefill.GetFieldValueAsString('CashDesk_ID');
 mDocQueue_ID:=mCRForPrefill.GetFieldValueAsString('DocQueue_ID');
 mCRForPrefill.free;
 mIIList.add(TDynSiteForm(mSite).CurrentObject.OID);;
 mStejnaFirma:=True;
 if mIIList.count>0 then begin
   for i:=0 to mIIList.count-1 do begin
     mII:=mOS.CreateObject(Class_IssuedInvoice);
     mII.Load(mIIList.strings[i],nil);
     mAmount:=mAmount+mii.GetFieldValueAsFloat('NotPaidAmount');
     mRoundedAmount:=mRoundedAmount+NxRoundByValue(mii.GetFieldValueAsFloat('NotPaidAmount'),ctArithmetic,1);
     if i=0 then mFirm_ID:=mii.GetFieldValueAsString('Firm_ID');
     if i>0 then begin
       if not(mFirm_ID=mii.GetFieldValueAsString('Firm_ID')) then mStejnaFirma:=False;


     end;
     mII.Free;

   end;
   if not(mStejnaFirma) then begin
          NxShowSimpleMessage('Ruším zadávání plateb, označené doklady nejsou na stejnou firmu',mSite);
          TDynSiteForm(mSite).RefreshData;
          exit;
   end;
   if Nxroundbyvalue(mAmount,ctArithmetic,0.01)=0 then begin
         NxShowSimpleMessage('Doklad byl již plně uhrazen.',mSite);
         exit;
       end;
   if not(mAmount=0) then begin
      //if NxMessageBox('Dotaz','Přejete si uhradit fakturu úplně nebo její část?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       if true then begin

       GetPaymenttype(mSite,'Přejete si uhradit fakturu úplně nebo její část?',mTempResult);
       if Nxroundbyvalue(mAmount,ctArithmetic,0.01)=0 then begin
         NxShowSimpleMessage('Doklad byl již plně uhrazen.',mSite);
         exit;
       end;
       if mTempResult=1 then begin
          mKarta:=True;
          mRoundedAmount:=0;
          mUdaje:=GetPaymentDate2(mSite,mCashDesk_ID,mDocQueue_ID,mKarta, mResult, mAmount);
       end;
       if mTempResult=2 then begin
          mKarta:=False;
          mAmount:=0;
          mUdaje:=GetPaymentDate2(mSite,mCashDesk_ID,mDocQueue_ID,mKarta, mResult, mRoundedAmount);
          if Nxroundbyvalue(mRoundedAmount,ctArithmetic,0.01)=0 then begin
             NxShowSimpleMessage('Doklad byl již plně uhrazen.',mSite);
             exit;
          end;
       end;

        if mResult=2 then begin
          NxShowSimpleMessage('Ruším zadávání plateb, pokladní příjem nebyl vytvořen.',mSite);
          exit;
        end;

         mCRList:=TStringList.Create;
         for i:=0 to mIIList.count-1 do begin
            mII:=mOS.CreateObject(Class_IssuedInvoice);
            mII.Load(mIIList.strings[i],nil);
            //mAmount:=mii.GetFieldValueAsFloat('NotPaidAmount');
            if not((mAmount+mRoundedAmount)=0) then begin
            mCR:=mOS.CreateObject(Class_CashReceived);
            mCr.New;
            mCr.Prefill;
            mCR.SetFieldValueAsString('CashDesk_ID',mCashDesk_ID);
            mCR.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
            mCr.SetFieldValueAsBoolean('VATDocument',false);
            mCR.SetFieldValueAsString('Firm_ID',mII.GetFieldValueAsString('Firm_ID'));
            mCR.SetFieldValueAsString('Description', 'Zaplacení '+mII.DisplayName);
            mCR.SetFieldValueAsString('PDocumentType','03');
            mCR.SetFieldValueAsString('PDocument_ID',mII.OID);
            mCR.SetFieldValueAsBoolean('X_PayByCard',mKarta);
            mCR.SetFieldValueAsBoolean('X_CheckPayment', False);
            mCR.SetFieldValueAsBoolean('EET',False);
            if not(mKarta) then mCR.SetFieldValueAsInteger('TotalRounding',257);
            if mKarta then mCR.SetFieldValueAsInteger('TotalRounding',-33554175);

            mRows:=mCR.GetCollectionMonikerForFieldCode(mCR.GetFieldCode('Rows'));
             mCRRow:=mRows.AddNewObject;
             mCRRow.SetFieldValueAsInteger('RowType',1);
             mCRRow.SetFieldValueAsString('Text','Zaplacení '+mII.DisplayName);
             mCRRow.SetFieldValueAsFloat('TotalPrice',mAmount+mRoundedAmount);
             mCRRow.SetFieldValueAsString('Division_ID',mII.GetLoadedCollectionMonikerForFieldCode(mII.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'));
            mCR.Save;
            //TNxEETTurnover(mCR.GetMonikerForFieldCode(mcr.GetFieldCode('EETTurnover_ID')).BusinessObject).Process('');
            mCRList.Add(mCR.OID);
            mCR.Free;
            end;
            mII.Free;

         end;
        if  mCRList.Count>0 then begin
           CFxReportManager.PrintByIDs(msite.SiteContext,mCRList,'0Z4R1NY0FJDL3BLX00C5OG4NF4','1600000101',rtoPreview,pekPDF,'','');
          { P := TNxParameters.Create;
           try
             P.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Nově vytvořené pokladní příjmy';
             mPar := P.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; //mPar je typu TNxParameter
             mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
             mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
             mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
             mPar.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mCRList);
             ShowDynForm('S5C2EX0BUJD13ACP03KIU0CLP4',TDynSiteForm(mSite).SiteContext, P, nil, True);
             finally
               P.Free;
             end;
         end else  NxMessageBox('Chyba','Nebyla vybrána žádná faktura s nenulovou výší úhrady!',mdError, mdbOk, mrOK, [mdpSystemModal], False, nil);
          }
         end;

      end;
   end;
 end;
 TDynSiteForm(mSite).RefreshData;
end;


begin
end.