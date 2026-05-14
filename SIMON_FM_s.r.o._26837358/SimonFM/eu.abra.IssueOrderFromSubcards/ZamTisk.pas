uses 'eu.abra.IssueOrderFromSubcards.fcesql';

procedure ZamTisk(Sender: TObject);
var
 msite: TSiteForm;
 mOS:TNxCustomObjectSpace;
 mActivity, mOutgoingTransfer, mOutgoingTransferRowBO, mRelation, mUser, mStoreCard: TNxCustomBusinessObject;
 mStoreCard_ID, mBusProject_ID,mDivision_ID, mStore_ID, mOutgoingTransfer_ID, mActivity_OID, mActivityNumber:String;
 mMemo, mDescription, mEAN :String;
 mDialog:Boolean;
 mQuantity, mCenaKK: Extended;
 mRows:TNxCustomBusinessMonikerCollection;
 mStringList:TStringList;
 mPrintList:TStringList;
 mText:string;
 mStore2_id, mStoreCard2_ID, mEAN2:String;
 mQuantity2, mCenaKK2:Extended;
 mStore3_id, mStoreCard3_ID, mEAN3:String;
 mQuantity3, mCenaKK3:Extended;
 mStore4_id, mStoreCard4_ID, mEAN4:String;
 mQuantity4, mCenaKK4:Extended;
 mStore5_id, mStoreCard5_ID, mEAN5:String;
 mQuantity5, mCenaKK5:Extended;
 mContext:TNxContext;
begin
 mSite := TComponent(Sender).BusRollSite;
 mOs:=msite.CompanyObjectSpace;
 mContext:= NxCreateContext(mOS);
 mStoreCard_ID:='';
 mStoreCard2_ID:='';
 mStoreCard3_ID:='';
 mStoreCard4_ID:='';
 mStoreCard5_ID:='';
 mDialog:=false;
 mQuantity:=1;
 mQuantity2:=1;
 mQuantity3:=1;
 mQuantity4:=1;
 mQuantity5:=1;
 mCenaKK:=0;
 mCenaKK2:=0;
 mCenaKK3:=0;
 mCenaKK4:=0;
 mCenaKK5:=0;

    try
    TiskZamData(msite, mBusProject_ID, mStore_ID, mStoreCard_ID, mEAN, mDialog, mQuantity, mCenaKK,
               mStore2_id, mStoreCard2_ID, mEAN2,mQuantity2, mCenaKK2,
               mStore3_id, mStoreCard3_ID, mEAN3,mQuantity3, mCenaKK3,
               mStore4_id, mStoreCard4_ID, mEAN4,mQuantity4, mCenaKK4,
               mStore5_id, mStoreCard5_ID, mEAN5,mQuantity5, mCenaKK5);
    muser:= mOS.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID(mOS), nil);
    mDivision_ID:=mUser.GetFieldValueAsString('X_Division_ID');
    muser.Free;

    if not(mDialog) then begin
       NxShowMessage('Info','Ruším založení Zaměstnaneckého prodeje', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mStoreCard_ID) and not(mEAN='') then begin
      mStoreCard_ID:=scrGetStoreCard_ID(mOS, mEAN);

    end;
    if NxIsEmptyOID(mStoreCard2_ID) and not(mEAN2='') then begin
      mStoreCard2_ID:=scrGetStoreCard_ID(mOS, mEAN2);

    end;
    if NxIsEmptyOID(mStoreCard3_ID) and not(mEAN3='') then begin
      mStoreCard3_ID:=scrGetStoreCard_ID(mOS, mEAN3);

    end;
    if NxIsEmptyOID(mStoreCard4_ID) and not(mEAN4='') then begin
      mStoreCard4_ID:=scrGetStoreCard_ID(mOS, mEAN4);

    end;
    if NxIsEmptyOID(mStoreCard5_ID) and not(mEAN5='') then begin
      mStoreCard5_ID:=scrGetStoreCard_ID(mOS, mEAN5);

    end;
    if (((mStoreCard_ID='3I35000101') or (mStoreCard_ID='1J35000101')) and (mCenaKK=0)) or
       (((mStoreCard2_ID='3I35000101') or (mStoreCard2_ID='1J35000101')) and (mCenaKK2=0)) or
       (((mStoreCard3_ID='3I35000101') or (mStoreCard3_ID='1J35000101')) and (mCenaKK3=0)) or
       (((mStoreCard4_ID='3I35000101') or (mStoreCard4_ID='1J35000101')) and (mCenaKK4=0)) or
       (((mStoreCard5_ID='3I35000101') or (mStoreCard5_ID='1J35000101')) and (mCenaKK5=0))
    then begin
       NxShowMessage('Info','Ruším založení Zaměstnaneckého prodeje, nebyla vyplněna cena pro skladovou kartu', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mBusProject_ID) then begin
       NxShowMessage('Info','Ruším založení Zaměstnaneckého prodeje, není vyplněn zaměstnanec', mdInformation,false,msite);
       exit;
    end;
    mPrintList:=TStringList.create;
    if NxMessageBox('Dotaz', 'Chcete přidat položky do zaměstnaneckého prodeje?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
        mStoreCard:= mOS.CreateObject(Class_StoreCard);
        mStoreCard.Load(mStoreCard_ID,nil);

        mOutgoingTransfer_ID:=scrOutgoingTransfer_ID(mOS,(inttostr(NxExtractMonth(now))));
        if (NxExtractMonth(now))=1 then mText:='Leden';
        if (NxExtractMonth(now))=2 then mText:='Únor';
        if (NxExtractMonth(now))=3 then mText:='Březen';
        if (NxExtractMonth(now))=4 then mText:='Duben';
        if (NxExtractMonth(now))=5 then mText:='Květen';
        if (NxExtractMonth(now))=6 then mText:='Červen';
        if (NxExtractMonth(now))=7 then mText:='Červenec';
        if (NxExtractMonth(now))=8 then mText:='Srpen';
        if (NxExtractMonth(now))=9 then mText:='Září';
        if (NxExtractMonth(now))=10 then mText:='Říjen';
        if (NxExtractMonth(now))=11 then mText:='Listopad';
        if (NxExtractMonth(now))=12 then mText:='Prosinec';
        if NxIsEmptyOID(mOutgoingTransfer_ID) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.New;
            mOutgoingTransfer.Prefill;
            mOutgoingTransfer.SetFieldValueAsString('Docqueue_ID','R200000101');
            mOutgoingTransfer.SetFieldValueAsString('Description','Drobný prodej MO '+mText+ ' '+ mOutgoingTransfer.GetFieldValueAsString('Period_ID.code'));
            mrows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;

        End;
        if not(NxIsEmptyOID(mOutgoingTransfer_ID)) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.Load(mOutgoingTransfer_ID,nil);
            mrows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        End;
        mStoreCard.Free;
        end;
        if not(NxIsEmptyOID(mStoreCard2_ID)) then begin
        mStoreCard:= mOS.CreateObject(Class_StoreCard);
        mStoreCard.Load(mStoreCard2_ID,nil);
        if NxIsEmptyOID(mOutgoingTransfer_ID) then mOutgoingTransfer_ID:=scrOutgoingTransfer_ID(mOS,(inttostr(NxExtractMonth(now))));
        if NxIsEmptyOID(mOutgoingTransfer_ID) then begin
        if (NxExtractMonth(now))=1 then mText:='Leden';
        if (NxExtractMonth(now))=2 then mText:='Únor';
        if (NxExtractMonth(now))=3 then mText:='Březen';
        if (NxExtractMonth(now))=4 then mText:='Duben';
        if (NxExtractMonth(now))=5 then mText:='Květen';
        if (NxExtractMonth(now))=6 then mText:='Červen';
        if (NxExtractMonth(now))=7 then mText:='Červenec';
        if (NxExtractMonth(now))=8 then mText:='Srpen';
        if (NxExtractMonth(now))=9 then mText:='Září';
        if (NxExtractMonth(now))=10 then mText:='Říjen';
        if (NxExtractMonth(now))=11 then mText:='Listopad';
        if (NxExtractMonth(now))=12 then mText:='Prosinec';

            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.New;
            mOutgoingTransfer.Prefill;
            mOutgoingTransfer.SetFieldValueAsString('Docqueue_ID','R200000101');
            mOutgoingTransfer.SetFieldValueAsString('Description','Drobný prodej MO '+mText+ ' '+ mOutgoingTransfer.GetFieldValueAsString('Period_ID.code'));
            mrows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore2_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard2_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity2);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK2);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;

        End;
        if not(NxIsEmptyOID(mOutgoingTransfer_ID)) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.Load(mOutgoingTransfer_ID,nil);
            mrows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore2_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard2_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity2);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK2);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        End;
        mStoreCard.Free;
        end;
        if not(NxIsEmptyOID(mStoreCard3_ID)) then begin
        mStoreCard:= mOS.CreateObject(Class_StoreCard);
        mStoreCard.Load(mStoreCard3_ID,nil);
        if NxIsEmptyOID(mOutgoingTransfer_ID) then mOutgoingTransfer_ID:=scrOutgoingTransfer_ID(mOS,(inttostr(NxExtractMonth(now))));
        if (NxExtractMonth(now))=1 then mText:='Leden';
        if (NxExtractMonth(now))=2 then mText:='Únor';
        if (NxExtractMonth(now))=3 then mText:='Březen';
        if (NxExtractMonth(now))=4 then mText:='Duben';
        if (NxExtractMonth(now))=5 then mText:='Květen';
        if (NxExtractMonth(now))=6 then mText:='Červen';
        if (NxExtractMonth(now))=7 then mText:='Červenec';
        if (NxExtractMonth(now))=8 then mText:='Srpen';
        if (NxExtractMonth(now))=9 then mText:='Září';
        if (NxExtractMonth(now))=10 then mText:='Říjen';
        if (NxExtractMonth(now))=11 then mText:='Listopad';
        if (NxExtractMonth(now))=12 then mText:='Prosinec';
        if NxIsEmptyOID(mOutgoingTransfer_ID) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.New;
            mOutgoingTransfer.Prefill;
            mOutgoingTransfer.SetFieldValueAsString('Docqueue_ID','R200000101');
            mOutgoingTransfer.SetFieldValueAsString('Description','Drobný prodej MO '+mText+ ' '+ mOutgoingTransfer.GetFieldValueAsString('Period_ID.code'));
            mrows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore3_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard3_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity3);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK3);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;

        End;
        if not(NxIsEmptyOID(mOutgoingTransfer_ID)) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.Load(mOutgoingTransfer_ID,nil);
            mrows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore3_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard3_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity3);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK3);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        End;
        mStoreCard.Free;
        end;
        if not(NxIsEmptyOID(mStoreCard4_ID)) then begin
        mStoreCard:= mOS.CreateObject(Class_StoreCard);
        mStoreCard.Load(mStoreCard4_ID,nil);
        if NxIsEmptyOID(mOutgoingTransfer_ID) then mOutgoingTransfer_ID:=scrOutgoingTransfer_ID(mOS,(inttostr(NxExtractMonth(now))));
        if (NxExtractMonth(now))=1 then mText:='Leden';
        if (NxExtractMonth(now))=2 then mText:='Únor';
        if (NxExtractMonth(now))=3 then mText:='Březen';
        if (NxExtractMonth(now))=4 then mText:='Duben';
        if (NxExtractMonth(now))=5 then mText:='Květen';
        if (NxExtractMonth(now))=6 then mText:='Červen';
        if (NxExtractMonth(now))=7 then mText:='Červenec';
        if (NxExtractMonth(now))=8 then mText:='Srpen';
        if (NxExtractMonth(now))=9 then mText:='Září';
        if (NxExtractMonth(now))=10 then mText:='Říjen';
        if (NxExtractMonth(now))=11 then mText:='Listopad';
        if (NxExtractMonth(now))=12 then mText:='Prosinec';
        if NxIsEmptyOID(mOutgoingTransfer_ID) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.New;
            mOutgoingTransfer.Prefill;
            mOutgoingTransfer.SetFieldValueAsString('Docqueue_ID','R200000101');
            mOutgoingTransfer.SetFieldValueAsString('Description','Drobný prodej MO '+mText+ ' '+ mOutgoingTransfer.GetFieldValueAsString('Period_ID.code'));
            mrows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore4_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard4_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity4);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK4);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;

        End;
        if not(NxIsEmptyOID(mOutgoingTransfer_ID)) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.Load(mOutgoingTransfer_ID,nil);
            mrows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore4_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard4_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity4);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK4);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        End;
        mStoreCard.Free;
        end;
        if not(NxIsEmptyOID(mStoreCard5_ID)) then begin
        mStoreCard:= mOS.CreateObject(Class_StoreCard);
        mStoreCard.Load(mStoreCard5_ID,nil);
        if NxIsEmptyOID(mOutgoingTransfer_ID) then mOutgoingTransfer_ID:=scrOutgoingTransfer_ID(mOS,(inttostr(NxExtractMonth(now))));
        if (NxExtractMonth(now))=1 then mText:='Leden';
        if (NxExtractMonth(now))=2 then mText:='Únor';
        if (NxExtractMonth(now))=3 then mText:='Březen';
        if (NxExtractMonth(now))=4 then mText:='Duben';
        if (NxExtractMonth(now))=5 then mText:='Květen';
        if (NxExtractMonth(now))=6 then mText:='Červen';
        if (NxExtractMonth(now))=7 then mText:='Červenec';
        if (NxExtractMonth(now))=8 then mText:='Srpen';
        if (NxExtractMonth(now))=9 then mText:='Září';
        if (NxExtractMonth(now))=10 then mText:='Říjen';
        if (NxExtractMonth(now))=11 then mText:='Listopad';
        if (NxExtractMonth(now))=12 then mText:='Prosinec';
        if NxIsEmptyOID(mOutgoingTransfer_ID) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.New;
            mOutgoingTransfer.Prefill;
            mOutgoingTransfer.SetFieldValueAsString('Docqueue_ID','R200000101');
            mOutgoingTransfer.SetFieldValueAsString('Description','Drobný prodej MO '+mText+ ' '+ mOutgoingTransfer.GetFieldValueAsString('Period_ID.code'));
            mrows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore5_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard5_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity5);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK5);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;

        End;
        if not(NxIsEmptyOID(mOutgoingTransfer_ID)) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.Load(mOutgoingTransfer_ID,nil);
            mrows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore5_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard5_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity5);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK5);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mOutgoingTransferRowBO.SetFieldValueAsDateTime('X_DateOfSell',now);
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        End;
        mStoreCard.Free;
        end;
        // založit stringlist s ID řádku a pak udělat tisk toho řádku automaticky na tiskárnu která je v siti
        // PrintRowOoutgoingTransfer doplnit datum na řádek kdy byla položka
        // NxPrintByIDs(Self.Context, mIDs, CLSID, Report_ID, rtoPrint, pekARP, '\\192.168.101.10\Datamax_E4205e_01', '');
        CFxReportManager.PrintByIDs(mContext,mPrintList,'WBFDIVPW1ZE13HBT00C5OG4NF4','1T60000101',rtoPreview,pekPDF, '', '');
        //CFxReportManager.PrintByIDs(NxCreateContext_1(mOutgoingTransfer),mPrintList,'WBFDIVPW1ZE13HBT00C5OG4NF4','1Y50000101',rtoPrint, pekPDF, '\\192.168.101.10\Datamax_E4205e_01', '');
        mPrintList.free;
        NxShowMessage('Info','Položky byly přidány', mdInformation,false,msite);
    end;
    finally

     mos.Free;

    end;

end;


Function TiskZamData(asite:tsiteform;var aBusProject_ID:string;var aStore_id:string; var aStoreCard_ID:string;
                        var aEAN: string; var aDialog:Boolean; var aQuantity:Extended; var aCenaKK:Extended;
                        var aStore2_id, aStoreCard2_ID, aEAN2: String; var aQuantity2, aCenaKK2: Extended;
                        var aStore3_id, aStoreCard3_ID, aEAN3: String; var aQuantity3, aCenaKK3: Extended;
                        var aStore4_id, aStoreCard4_ID, aEAN4: String; var aQuantity4, aCenaKK4: Extended;
                        var aStore5_id, aStoreCard5_ID, aEAN5: String; var aQuantity5, aCenaKK5: Extended):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbStore, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbStoreCard2, mCbStore2, mCbStoreCard3, mCbStore3, mCbStoreCard4, mCbStore4, mCbStoreCard5, mCbStore5: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5: TEdit;
    mEd6, mEd7: TMemo;
    mNumEdit, mNumEdit1: TNumEdit;
    mNumEdit2, mNumEdit3, mNumEdit4, mNumEdit5,mNumEdit6, mNumEdit7,mNumEdit8, mNumEdit9: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 620;
    mForm.Height:= 260;
    mForm.Caption := 'Zadejte údaje pro zaměstnanecký prodej';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Zaměstnanec:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 15;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'ZX20VMNR1NV4N30K2MRDAXLRN4';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 15;
    mCbFirm.Left:= 107;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';

     //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 37;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Skl. karta:';
    mLabel3.Top := 37;
    mLabel3.Left := 130;
    mLabel3.Height := 13;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'EAN:';
    mLabel3.Top := 37;
    mLabel3.Left := 245;
    mLabel3.Height := 13;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Množství:';
    mLabel3.Top := 37;
    mLabel3.Left := 370;
    mLabel3.Height := 13;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Cena KK:';
    mLabel3.Top := 37;
    mLabel3.Left := 480;
    mLabel3.Height := 13;

    mCbStore:= TRollComboEdit.Create(mForm);
    mCbStore.Parent:= mForm;

    mCbStore.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore.Complete:= True;
    mCbStore.ForcedField:= True;
    mCbStore.Prefilling:= pmNone;
    mCbStore.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStore.Top:= 55;
    mCbStore.DataText:= '2D00000101';
    mCbStore.Left:= 17;
    mCbStore.Width:= 108;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;

    mCbStoreCard.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard.Complete:= True;
    mCbStoreCard.ForcedField:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard.Top:= 55;
    mCbStoreCard.DataText:= aStoreCard_ID;
    mCbStoreCard.Left:= 130;
    mCbStoreCard.Width:= 108;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru





    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 245;
    mEd1.Top := 55;
    mEd1.Width := 120;
    mEd1.Text := '';
    mEd1.Parent := mForm;



    mNumEdit:= TNumEdit.Create(mForm);
    mNumEdit.Parent :=mForm;
    mNumEdit.left := 370;
    mNumEdit.top := 55;
    mNumEdit.Width:= 100;
    mNumEdit.Value := aQuantity;


    mNumEdit1:= TNumEdit.Create(mForm);
    mNumEdit1.Parent :=mForm;
    mNumEdit1.left := 480;
    mNumEdit1.top := 55;
    mNumEdit1.Value := aCenaKK;

    // druhá karta
    mCbStore2:= TRollComboEdit.Create(mForm);
    mCbStore2.Parent:= mForm;

    mCbStore2.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore2.Complete:= True;
    mCbStore2.ForcedField:= True;
    mCbStore2.Prefilling:= pmNone;
    mCbStore2.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStore2.Top:= 80;
    mCbStore2.DataText:= '2D00000101';
    mCbStore2.Left:= 17;
    mCbStore2.Width:= 108;

    mCbStoreCard2:= TRollComboEdit.Create(mForm);
    mCbStoreCard2.Parent:= mForm;

    mCbStoreCard2.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard2.Complete:= True;
    mCbStoreCard2.ForcedField:= True;
    mCbStoreCard2.Prefilling:= pmNone;
    mCbStoreCard2.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard2.Top:= 80;
    mCbStoreCard2.DataText:= aStoreCard2_ID;
    mCbStoreCard2.Left:= 130;
    mCbStoreCard2.Width:= 108;



    mEd2 := TEdit.Create(mForm);
    mEd2.Left := 245;
    mEd2.Top := 80;
    mEd2.Width := 120;
    mEd2.Text := '';
    mEd2.Parent := mForm;



    mNumEdit2:= TNumEdit.Create(mForm);
    mNumEdit2.Parent :=mForm;
    mNumEdit2.left := 370;
    mNumEdit2.top := 80;
    mNumEdit2.Width:= 100;
    mNumEdit2.Value := aQuantity2;


    mNumEdit3:= TNumEdit.Create(mForm);
    mNumEdit3.Parent :=mForm;
    mNumEdit3.left := 480;
    mNumEdit3.top := 80;
    mNumEdit3.Value := aCenaKK2;

    // třetí karta
    mCbStore3:= TRollComboEdit.Create(mForm);
    mCbStore3.Parent:= mForm;

    mCbStore3.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore3.Complete:= True;
    mCbStore3.ForcedField:= True;
    mCbStore3.Prefilling:= pmNone;
    mCbStore3.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStore3.Top:= 105;
    mCbStore3.DataText:= '2D00000101';
    mCbStore3.Left:= 17;
    mCbStore3.Width:= 108;

    mCbStoreCard3:= TRollComboEdit.Create(mForm);
    mCbStoreCard3.Parent:= mForm;

    mCbStoreCard3.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard3.Complete:= True;
    mCbStoreCard3.ForcedField:= True;
    mCbStoreCard3.Prefilling:= pmNone;
    mCbStoreCard3.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard3.Top:= 105;
    mCbStoreCard3.DataText:= aStoreCard3_ID;
    mCbStoreCard3.Left:= 130;
    mCbStoreCard3.Width:= 108;



    mEd3 := TEdit.Create(mForm);
    mEd3.Left := 245;
    mEd3.Top := 105;
    mEd3.Width := 120;
    mEd3.Text := '';
    mEd3.Parent := mForm;



    mNumEdit4:= TNumEdit.Create(mForm);
    mNumEdit4.Parent :=mForm;
    mNumEdit4.left := 370;
    mNumEdit4.top := 105;
    mNumEdit4.Width:= 100;
    mNumEdit4.Value := aQuantity3;


    mNumEdit5:= TNumEdit.Create(mForm);
    mNumEdit5.Parent :=mForm;
    mNumEdit5.left := 480;
    mNumEdit5.top := 105;
    mNumEdit5.Value := aCenaKK3;

    // čtvrtá  karta
    mCbStore4:= TRollComboEdit.Create(mForm);
    mCbStore4.Parent:= mForm;

    mCbStore4.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore4.Complete:= True;
    mCbStore4.ForcedField:= True;
    mCbStore4.Prefilling:= pmNone;
    mCbStore4.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStore4.Top:= 130;
    mCbStore4.DataText:= '2D00000101';
    mCbStore4.Left:= 17;
    mCbStore4.Width:= 108;

    mCbStoreCard4:= TRollComboEdit.Create(mForm);
    mCbStoreCard4.Parent:= mForm;

    mCbStoreCard4.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard4.Complete:= True;
    mCbStoreCard4.ForcedField:= True;
    mCbStoreCard4.Prefilling:= pmNone;
    mCbStoreCard4.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard4.Top:= 130;
    mCbStoreCard4.DataText:= aStoreCard4_ID;
    mCbStoreCard4.Left:= 130;
    mCbStoreCard4.Width:= 108;



    mEd4 := TEdit.Create(mForm);
    mEd4.Left := 245;
    mEd4.Top := 130;
    mEd4.Width := 120;
    mEd4.Text := '';
    mEd4.Parent := mForm;



    mNumEdit6:= TNumEdit.Create(mForm);
    mNumEdit6.Parent :=mForm;
    mNumEdit6.left := 370;
    mNumEdit6.top := 130;
    mNumEdit6.Width:= 100;
    mNumEdit6.Value := aQuantity4;


    mNumEdit7:= TNumEdit.Create(mForm);
    mNumEdit7.Parent :=mForm;
    mNumEdit7.left := 480;
    mNumEdit7.top := 130;
    mNumEdit7.Value := aCenaKK4;

    // Pátá karta
    mCbStore5:= TRollComboEdit.Create(mForm);
    mCbStore5.Parent:= mForm;

    mCbStore5.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore5.Complete:= True;
    mCbStore5.ForcedField:= True;
    mCbStore5.Prefilling:= pmNone;
    mCbStore5.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStore5.Top:= 155;
    mCbStore5.DataText:= '2D00000101';
    mCbStore5.Left:= 17;
    mCbStore5.Width:= 108;

    mCbStoreCard5:= TRollComboEdit.Create(mForm);
    mCbStoreCard5.Parent:= mForm;

    mCbStoreCard5.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard5.Complete:= True;
    mCbStoreCard5.ForcedField:= True;
    mCbStoreCard5.Prefilling:= pmNone;
    mCbStoreCard5.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard5.Top:= 155;
    mCbStoreCard5.DataText:= aStoreCard5_ID;
    mCbStoreCard5.Left:= 130;
    mCbStoreCard5.Width:= 108;



    mEd5 := TEdit.Create(mForm);
    mEd5.Left := 245;
    mEd5.Top := 155;
    mEd5.Width := 120;
    mEd5.Text := '';
    mEd5.Parent := mForm;



    mNumEdit8:= TNumEdit.Create(mForm);
    mNumEdit8.Parent :=mForm;
    mNumEdit8.left := 370;
    mNumEdit8.top := 155;
    mNumEdit8.Width:= 100;
    mNumEdit8.Value := aQuantity5;


    mNumEdit9:= TNumEdit.Create(mForm);
    mNumEdit9.Parent :=mForm;
    mNumEdit9.left := 480;
    mNumEdit9.top := 155;
    mNumEdit9.Value := aCenaKK5;










    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 189;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 189;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aBusProject_id:= mCbFirm.DataText;
        if not(NxIsEmptyOID(mCbStore.DataText)) then aStore_id:= mCbStore.DataText;
        if not(NxIsEmptyOID(mCbStoreCard.DataText)) then aStoreCard_ID:= mCbStoreCard.DataText;
        aEAN:=mEd1.Text;
        aQuantity:= mNumEdit.Value;
        aCenaKK:=mNumEdit1.Value;

        if not(NxIsEmptyOID(mCbStore2.DataText)) then aStore2_id:= mCbStore2.DataText;
        if not(NxIsEmptyOID(mCbStoreCard2.DataText)) then aStoreCard2_ID:= mCbStoreCard2.DataText;
        aEAN2:=mEd2.Text;
        aQuantity2:= mNumEdit2.Value;
        aCenaKK2:=mNumEdit3.Value;

        if not(NxIsEmptyOID(mCbStore3.DataText)) then aStore3_id:= mCbStore3.DataText;
        if not(NxIsEmptyOID(mCbStoreCard3.DataText)) then aStoreCard3_ID:= mCbStoreCard3.DataText;
        aEAN3:=mEd3.Text;
        aQuantity3:= mNumEdit4.Value;
        aCenaKK3:=mNumEdit5.Value;

        if not(NxIsEmptyOID(mCbStore4.DataText)) then aStore4_id:= mCbStore4.DataText;
        if not(NxIsEmptyOID(mCbStoreCard4.DataText)) then aStoreCard4_ID:= mCbStoreCard4.DataText;
        aEAN4:=mEd4.Text;
        aQuantity4:= mNumEdit6.Value;
        aCenaKK4:=mNumEdit7.Value;

        if not(NxIsEmptyOID(mCbStore5.DataText)) then aStore5_id:= mCbStore5.DataText;
        if not(NxIsEmptyOID(mCbStoreCard5.DataText)) then aStoreCard5_ID:= mCbStoreCard5.DataText;
        aEAN5:=mEd5.Text;
        aQuantity5:= mNumEdit8.Value;
        aCenaKK5:=mNumEdit9.Value;

        adialog:=true;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;



begin
end.