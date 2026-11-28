procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Vyskladnit PřímýZávoz';
mBut.Category := 'tabList';
mBut.OnExecute := @PZtoBOD;

end;

Procedure PZtoBOD(Sender:TComponent);
var
 mSite:TSiteForm;
 mRows:TNxCustomBusinessMonikerCollection;
 mBO,mBOReservation, mRowBO, mBOD, mUser:TNxCustomBusinessObject;
 mReservation_ID, mBOD_ID,mReceivedOrder_ID, mFirm_ID:String;
 i, j:Integer;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mOS:TNxCustomObjectSpace;
 mList,mList2, mResList:TStringList;
 AfterDueTerm,mduedate:Extended;
 AfterDueTermEnabled:Boolean;
begin
  mList:=TStringList.Create;
  mReceivedOrder_ID:='';
  mReservation_ID:='';
  mBOD_ID:='';
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  mOS:=mBO.ObjectSpace;
  mUser:=mbo.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(mBO),nil);
  try
  if NxIsEmptyOID(mUser.GetFieldValueAsString('X_BOD_ID')) then begin
    NxShowSimpleMessage('Uživatel nemá výchozí řadu DL, kontaktujte IT správce v OBB',mSite);
    exit;
  end;
  if  mbo.GetFieldValueAsBoolean('Closed') then begin
    NxShowSimpleMessage('Nelze provést: objednávka je již pravděpodobně vyřízena',mSite);
    exit;
  end;
  if not(mbo.GetFieldValueAsBoolean('Closed')) then begin

  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for i:=0 to mRows.Count-1 do begin
    mRowBO:=mrows.BusinessObject[i];
    if (mRowBO.GetFieldValueAsString('X_StockType_ID')='2000000101') and (mRowBO.GetFieldValueAsInteger('RowType')=3) and (GetQuantity(mos,mrowbo.GetFieldValueAsString('Store_ID'),mrowbo.GetFieldValueAsString('StoreCard_ID'))>=mrowbo.GetFieldValueAsFloat('Quantity')) and (mrowbo.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
    //NxShowSimpleMessage(FloatToStr(GetQuantity(mos,mrowbo.GetFieldValueAsString('Store_ID'),mrowbo.GetFieldValueAsString('StoreCard_ID')))+' '+mRowBO.GetFieldValueAsString('StoreCard_ID.Name') ,mSite);

    mRowBO.SetFieldValueAsString('X_StockType_ID','1000000101');
    mList.Add(mRowBO.OID);
    if NxIsEmptyOID(mReservation_ID) then begin
      mBOReservation:=mbo.ObjectSpace.CreateObject(Class_Reservation);
      mBOReservation.new;
      mBOReservation.SetFieldValueAsString('StoreCard_ID',mRowBO.GetFieldValueAsString('StoreCard_ID'));
      mBOReservation.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
      mBOReservation.SetFieldValueAsString('Owner_ID',mRowBO.OID);
      mBOReservation.SetFieldValueAsInteger('OwnerKind',0);
      mBOReservation.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
      mBOReservation.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
      mBOReservation.SetFieldValueAsFloat('Reserved',mRowBO.GetFieldValueAsFloat('Quantity'));
      mBOReservation.SetFieldValueAsFloat('UnitRate',mRowBO.GetFieldValueAsFloat('UnitRate'));
      mBOReservation.SetFieldValueAsString('Qunit',mRowBO.GetFieldValueAsString('Qunit'));
      mBOReservation.SetFieldValueAsDateTime('DateFrom$DATE',date);
      mBOReservation.SetFieldValueAsDateTime('DateTo$DATE',date);
      mBOReservation.SetFieldValueAsInteger('Priority',99);
      mBOReservation.Save;
      mBOReservation.Free;


     end;

   end;
  end;
  mbo.save;
  mbo.Refresh;
  mFirm_ID:= mbo.GetFieldValueAsString('Firm_ID');
  mReceivedOrder_ID:=mbo.OID;
  mbo.free;
  mRows.free;
    AfterDueTerm:=0;
    mDueDate:=0;
    if mbo.GetFieldValueAsBoolean('Firm_ID.AfterDueTermEnabled') then AfterDueTerm:= mbo.GetFieldValueAsFloat('Firm_ID.AfterDueTerm');
    mList2:=TStringList.Create;
    mbo.ObjectSpace.SQLSelect(format('Select min(DueDate$Date) from issuedinvoices  where firm_id=''%s'' and (amount-paidamount)-(creditamount-paidcreditamount)>0',[mbo.GetFieldValueAsString('Firm_ID')]),mList2);
    mDueDate:=StrToFloat(mList2.Strings[0]);
    if (mDueDate+AfterDueTerm<trunc(Date)) and (mDueDate>0) then begin
     NxShowSimpleMessage('Firma '+mbo.GetFieldValueAsString('Firm_ID.Name')+ ' překročila splatnost včetně nastavené tolerance. Doklad nebude možno uložit. Ukončuji',nil);
     exit;
    end;

  //TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem;
  end;
  if mList.Count=0 then begin
     NxShowSimpleMessage('Dodací list nelze vystavit, pravděpodobně z těchto důvodů: firma nemá dostatečný kredit nebo žádný řádek nelze vyskladnit v objednané výši.',mSite);
     exit;
  end;
  //TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem;
          try
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mUser.GetFieldValueAsString('X_BOD_ID');
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                mParam.AsString := mList.Text;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
                try
                  mImportMan.AddInputDocument(mReceivedOrder_ID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_BOD_ID')); // musi byt...
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);

                      mImportMan.OutputDocument.Save;
                      //mBod:=mImportMan.OutputDocument;
                      mBOD_ID:=mImportMan.OutputDocument.OID;
                      mBOD:=mOS.CreateObject(Class_BillOfDelivery);
                      mBOD.Load(mBOD_ID,nil);
                  end;
                mImportMan.Free;
                mInputParams.Free;
                finally




                end;
           except
            for j:=0 to mlist.count-1 do begin
             mResList:=TStringList.Create;
             mOS.SQLSelect(Format('Select id from reservations where owner_id=''%s'' ',[mlist.strings[j]]),mResList);
             if mReslist.Count>0 then begin
               mBOReservation:=mos.CreateObject(Class_Reservation);
               mBOReservation.Load(mResList.strings[0],nil);
               mBOReservation.Delete;

             end;
             mResList.free;
            end;
            NxShowSimpleMessage('Dodací list nelze vystavit, pravděpodobně z těchto důvodů: firma nemá dostatečný kredit nebo žádný řádek nelze vyskladnit v objednané výši.',msite);
           end;
           //NxShowSimpleMessage(mlist.DelimitedText,mSite);
      mBO:=mOS.CreateObject(Class_ReceivedOrder);
      mbo.Load(mReceivedOrder_ID,nil);
      mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
      for i:=0 to mRows.Count-1 do begin
       for j:=0 to mlist.count-1 do begin
         if mlist.Strings[j]=mRows.BusinessObject[i].oid then mrows.BusinessObject[i].SetFieldValueAsString('X_StockType_ID','2000000101');

       end;
      end;
      mbo.save;
      mbo.Refresh;
      mbo.free;
      mlist.Free;



      if not(NxIsEmptyOID(mBOD_ID)) then begin
        if NxMessageBox('Dotaz','Vytvořil jsem dodací list '+mBOD.DisplayName+'. Přejete si doklad zobrazit a editovat množství na položkách?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
         msite.ShowDynForm('B50I5SAOS3DL3ACU03KIU0CLP4', nil, nil, False, 'DoEdit;' + mBOD.OID);
        end;
      end;
  TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem;
  finally
  end;
end;


function GetReservation_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT ID FROM Reservations WHERE Owner_ID=''%s'' and OwnerKind=0 ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0])
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetQuantity(AOS : TNxCustomObjectSpace; AStore_ID,AstoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Quantity FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AStore_ID,AstoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.