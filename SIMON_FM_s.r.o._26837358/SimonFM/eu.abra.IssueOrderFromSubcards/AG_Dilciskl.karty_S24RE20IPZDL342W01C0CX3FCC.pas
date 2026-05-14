uses 'eu.abra.IssueOrderFromSubcards.fcesql';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Objednat';
    mAction.Hint := 'Objednat do min. stavu';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    mAction.OnUpdate := @ImportOnUpdate;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Změnit kód';
    mAction.Hint := 'změní kód skladové karty';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ChangeCode;
    mAction.OnUpdate := @ImportOnUpdate;
  end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ChangeCode(Sender: TObject);
var
  mSite:TsiteForm;
  mStoreCard,mBO: TNxCustomBusinessObject;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mBO:=TDynSiteForm(msite).CurrentObject;
  mStoreCard:=mbo.ObjectSpace.CreateObject(Class_StoreCard);
  mStoreCard.load(mbo.GetFieldValueAsString('StoreCard_ID'),nil);
  mStorecard.SetFieldValueAsString('Code',InputBox('Změna kódu','Změnit kód karty',mStoreCard.GetFieldValueAsString('Code')));
  mStoreCard.save;
  mStoreCard.free;
  mbo.Free;
end;



procedure ImportOnExecute(Sender: TObject);
var
 a: string;
 mList:TstringList;
 msite: TSiteForm;
 mIssuedOrder, mIssuedOrderRow, mStoreSubCard, mUser, mStoreCard, mStoreUnit:TNxCustomBusinessObject;
 mRows, mStoreUnits:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mDialog:Boolean;
 mDocqueue_ID, mFirm_ID, mDivision_ID, mSupplier_ID, mCode :String;
 mUnitRate, mQuantity:Extended;
 i,j: Integer;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
 mOs:=msite.CompanyObjectSpace;
 mList:=Tstringlist.Create;
 mDocqueue_ID:='K200000101';
    muser:= mOS.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID(mOS), nil);
    mDivision_ID:=mUser.GetFieldValueAsString('X_Division_ID');
    muser.Free;
  Try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    if NxMessageBox('Dotaz', 'Přejete si z '+inttostr(mlist.count)+' označených vytvořit objednávku vydanou?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
     IssuedOrderData(msite,mdocqueue_ID, mFirm_ID, mDivision_ID, mDialog);
     if not(mDialog) then begin
       NxShowMessage('Info','Ruším založení objednávky', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mFirm_ID) then begin
       NxShowMessage('Info','Ruším založení objednávky, není vyplněna firma', mdInformation,false,msite);
       exit;
    end;

     mIssuedOrder:=mos.CreateObject(Class_IssuedOrder);
     mIssuedOrder.New;
     mIssuedOrder.Prefill;
     mIssuedOrder.SetFieldValueAsString('Firm_ID',mFirm_ID);
     missuedorder.SetFieldValueAsString('Docqueue_ID',mDocqueue_ID);
     
     mRows:=mIssuedOrder.GetCollectionMonikerForFieldCode(mIssuedOrder.GetFieldCode('rows'));
     

     for i:=0 to mlist.count-1 do begin
      mUnitRate:=1;
      mStoreSubCard:=mos.CreateObject(Class_StoreSubCard);
      mstoresubcard.Load(mlist.strings[i],nil);
      mSupplier_ID:=scrGetSupplier_ID(mOS,mFirm_ID,mStoreSubCard.GetFieldValueAsString('StoreCard_ID'));
      mStoreCard:=mOS.CreateObject(Class_StoreCard);
      mstorecard.Load(mStoreSubCard.GetFieldValueAsString('StoreCard_ID'),nil);
      mStoreUnits:=mStoreCard.GetLoadedCollectionMonikerForFieldCode(mStoreCard.GetFieldCode('StoreUnits'));
      for j:=0 to mStoreUnits.Count-1 do begin
         if not(mStoreUnits.BusinessObject[j].GetFieldValueAsFloat('UnitRate')=1) then begin
          if (mStoreUnits.BusinessObject[j].GetFieldValueAsString('code')='bal') or
             (mStoreUnits.BusinessObject[j].GetFieldValueAsString('code')='bal.') then begin
                mCode:=mStoreUnits.BusinessObject[j].GetFieldValueAsString('code');
                mUnitRate:=mStoreUnits.BusinessObject[j].GetFieldValueAsFloat('UnitRate');
             end;
         end;
      end;
      if (mStoreSubCard.GetFieldValueAsFloat('HighLimitQuantity')-mStoreSubCard.GetFieldValueAsFloat('Quantity')>0) and not(NxIsEmptyOID(mSupplier_ID)) then begin
      if mUnitRate=1 then begin
      mIssuedOrderRow:=mrows.AddNewObject;
      mIssuedOrderRow.SetFieldValueAsInteger('Rowtype',3);
      mIssuedOrderRow.SetFieldValueAsString('Store_ID',mStoreSubCard.GetFieldValueAsString('Store_ID'));
      mIssuedOrderRow.SetFieldValueAsString('StoreCard_ID',mStoreSubCard.GetFieldValueAsString('StoreCard_ID'));
      mIssuedOrderRow.SetFieldValueAsFloat('Quantity', mStoreSubCard.GetFieldValueAsFloat('HighLimitQuantity')-mStoreSubCard.GetFieldValueAsFloat('Quantity'));
      mIssuedOrderRow.SetFieldValueAsString('Division_id',mDivision_ID);
      mIssuedOrderRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if not(mUnitRate=1) then begin
      mQuantity:=NxRoundByValue((mStoreSubCard.GetFieldValueAsFloat('HighLimitQuantity')-mStoreSubCard.GetFieldValueAsFloat('Quantity'))/mUnitRate,ctArithmetic,1);
      mIssuedOrderRow:=mrows.AddNewObject;
      mIssuedOrderRow.SetFieldValueAsInteger('Rowtype',3);
      mIssuedOrderRow.SetFieldValueAsString('Store_ID',mStoreSubCard.GetFieldValueAsString('Store_ID'));
      mIssuedOrderRow.SetFieldValueAsString('StoreCard_ID',mStoreSubCard.GetFieldValueAsString('StoreCard_ID'));
      mIssuedOrderRow.SetFieldValueAsFloat('Quantity', mQuantity);
      mIssuedOrderRow.SetFieldValueAsString('Qunit',mCode);
      mIssuedOrderRow.SetFieldValueAsString('Division_id',mDivision_ID);
      mIssuedOrderRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      end;
     
     
     end;
     if mrows.Count=0 then begin
       NxShowMessage('Info','žádná karta nešla přidat do objednávky', mdInformation,false,msite);
      
      exit;
     end;
     mIssuedOrder.save;
      if NxMessageBox('Dotaz', 'Založil jsem objednávku '+mIssuedOrder.DisplayName+'. Chcete ji zobrazit?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
        mSite.ShowSite('GF53HAH3WBDL3C5P00CA141B44', True, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mIssuedOrder.OID)+';Omezení za zdrojhový doklad');
      end;
     
     
    end;
  finally
  mlist.Free;
  end;


end;


Function IssuedOrderData(asite:tsiteform;var aDocQueue_ID:string;var aFirm_id:string;var aDivision_id:string; var aDialog:Boolean):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmRepair, mCbFirm, mCbPerson, mCbUser, mCbDivision: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser, mCbCcDivision: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9 : TEdit;
    mEd6, mEd7: TMemo;
    mNumEdit: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 190;
    mForm.Caption := 'Zadejte údaje pro objednávku';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
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

    mCbFirm.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 15;
    mCbFirm.Left:= 107;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Řada:';
    mLabel3.Top := 37;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcPerson:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 35;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbPerson.DataText:= aDocQueue_ID;
    mCbPerson.Top:= 35;
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Středisko:';
    mLabel3.Top := 57;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcDivision:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcDivision.Parent:= mForm;
    //mCbCcDivision.BevelOuter:= bvLowered;
    mCbCcDivision.Left:= 228;
    mCbCcDivision.Top:= 55;
    mCbCcDivision.Width:= 255;

    mCbDivision:= TRollComboEdit.Create(mForm);
    mCbDivision.Parent:= mForm;

    mCbDivision.ClassID:= 'OA5JMX4J2FD135CH000ILPWJF4';
    mCbDivision.Complete:= True;
    mCbDivision.ForcedField:= True;
    mCbDivision.Prefilling:= pmNone;
    mCbDivision.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbDivision.DataText:= aDivision_id;
    mCbDivision.Top:= 55;
    mCbDivision.Left:= 107;
    mCbDivision.Width:= 108;
    mCbDivision.ConnectedControl:= mCbCcDivision;
    mCbDivision.ConnectedControlField:= 'Name';

      mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 100;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 100;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aFirm_id:= mCbFirm.DataText;
        aDocQueue_id:= mCbPerson.DataText;
        aDivision_id:= mCbDivision.DataText;
        adialog:=true;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;

begin
end.