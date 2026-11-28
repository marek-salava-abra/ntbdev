procedure InitSite_Hook(Self: TSiteForm);
var
  mBut: TBasicAction;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mBut:= Self.GetNewAction;
  mBut.ShowControl := True;
  mBut.ShowMenuItem := True;
  mBut.Caption := 'Dobropis + FA';
  mBut.Hint := 'Vytvoří dobropis na označené řádky a následně novou fakturu';
  mBut.Category := 'tabDetail';
  mBut.OnExecute := @CreateDoc;
end;

Procedure CreateDoc(sender:TComponent);
var
 mSite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO, mNewInvoiceBO, mOldRowBO, mNewRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mOS:TNxCustomObjectSpace;
 mReason:string;
 mDVDocQueue_ID, mICN_ID, mIssuedInvoice_ID:string;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if TDynSiteForm(mSite).Edit then begin
    NxShowSimpleMessage('Jste ve stavu editace, funkce není dostupná.',mSite);
    exit;
 end;
 if Assigned(mBO) then begin
    mOS:=mbo.ObjectSpace;
    mList:=TStringList.create;
    mGRows :=  TMultiGrid(mSite.FindChildControl('tabRows.grdRows'));
    if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
    if mList.count=0 then begin
      NxShowSimpleMessage('Není označen ani jeden řádek.',msite);
    end;
    if mlist.count>0 then begin
       mDVDocQueue_ID:='W000000101';
       if GetDataForCreditNote(msite,mDVDocQueue_ID,mReason) then begin
          if NxIsEmptyOID(mDVDocQueue_ID) then begin
            NxShowSimpleMessage('Není vyplněna řada dokladů.',msite);
            exit;
          end;
          if NxIsBlank(mReason) then begin
            NxShowSimpleMessage('Není vyplněn důvod vrácení.',msite);
            exit;
          end;
           mInputParams := TNxParameters.Create;
           mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
           mParam.AsString := mDVDocQueue_ID;
           mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
           mParam.AsString := 'O310000101';
           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
           mParam.AsString := mBO.OID;
           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
           mParam.AsString := mList.Text;
           mImportManager := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
            try
              mImportManager.AddInputDocument(mBO.OID);
              mImportManager.LoadParams(mInputParams);
              mImportManager.Execute;
              mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', mDVDocQueue_ID);
              mImportManager.OutputDocument.SetFieldValueAsString('ReasonDescription',mReason);
              mImportManager.OutputDocument.Save;
              mICN_ID:=mImportManager.OutputDocument.OID;
            except
              NxShowSimpleMessage('Nepovedl se vytvořit dobropis. '+#13#10+ExceptionMessage,mSite);
            end;

            if not(NxIsEmptyOID(mICN_ID)) then begin
              Try
               mNewInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
               mNewInvoiceBO.New;
               mNewInvoiceBO.Prefill;
               mNewInvoiceBO.SetFieldValueAsString('DocQueue_ID',mbo.GetFieldValueAsString('DocQueue_ID'));
               mNewInvoiceBO.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
               mNewInvoiceBO.SetFieldValueAsString('FirmOffice_ID',mbo.GetFieldValueAsString('FirmOffice_ID'));
               mNewInvoiceBO.SetFieldValueAsString('BankAccount_ID',mbo.GetFieldValueAsString('BankAccount_ID'));
               mNewInvoiceBO.SetFieldValueAsString('StoreDocQueue_ID','6310000101');
               mRows:=mNewInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mNewInvoiceBO.GetFieldCode('Rows'));
               for i:=0 to mList.count-1 do begin
                 mOldRowBO:=mOS.CreateObject(Class_IssuedInvoiceRow);
                 mOldRowBO.load(mList.strings[i],nil);
                 mNewRowBO:=mRows.AddNewObject;
                 mNewRowBO.Prefill;
                 mNewRowBO.SetFieldValueAsInteger('RowType',mOldRowBO.GetFieldValueAsInteger('RowType'));
                 mNewRowBO.SetFieldValueAsString('Store_ID',mOldRowBO.GetFieldValueAsString('Store_ID'));
                 mNewRowBO.SetFieldValueAsString('StoreCard_ID',mOldRowBO.GetFieldValueAsString('StoreCard_ID'));
                 mNewRowBO.SetFieldValueAsFloat('Quantity',mOldRowBO.GetFieldValueAsFloat('Quantity'));
                 mNewRowBO.SetFieldValueAsString('Division_ID',mOldRowBO.GetFieldValueAsString('Division_ID'));
                 mNewRowBO.SetFieldValueAsString('BusOrder_ID',mOldRowBO.GetFieldValueAsString('BusOrder_ID'));
                 mNewRowBO.SetFieldValueAsString('BusTransaction_ID',mOldRowBO.GetFieldValueAsString('BusTransaction_ID'));
               end;
               mNewInvoiceBO.save;
               mIssuedInvoice_ID:=mNewInvoiceBO.oid;
               mNewInvoiceBO.free;
              Except
                NxShowSimpleMessage('Nepovedlo se vytvořit fakturu. '+#13#10+ExceptionMessage,mSite);
              end;
              if not(NxIsEmptyOID(mICN_ID)) then
                mSite.ShowSite(Site_IssuedCreditNotes, true, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mICN_ID));
              if not(NxIsEmptyOID(mIssuedInvoice_ID)) then
                mSite.ShowSite(Site_IssuedInvoices, true, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mIssuedInvoice_ID));

            end;
       end;
    end;
 end;
end;

Function GetDataForCreditNote(var ASite : TSiteform; var ADocQueue_ID, aReason : string;):Boolean;
var
    mLabel1, mCbCCDocQueue: TLabel;
    mEd:TMemo;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mCbDocQueue: TRollComboEdit;
    mAllowedDQ:TStringList;
begin
 if ASite <> nil then begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 175;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Data pro dobropis:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mAllowedDQ:=TStringList.create;
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('60')+' and hidden='+QuotedStr('N'),mAllowedDQ);

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Řada dokladů:';
    mLabel1.Top := 12;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCDocQueue:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCDocQueue.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCDocQueue.Left:= 236;
    mCbCCDocQueue.Top:= 12;
    mCbCCDocQueue.Width:= 255;

    mCbDocQueue:= TRollComboEdit.Create(mForm);
    mCbDocQueue.Parent:= mForm;

    mCbDocQueue.ClassID:= Roll_DocQueues;
    mCbDocQueue.Complete:= True;
    mCbDocQueue.Prefilling:= pmNone;
    mCbDocQueue.TextField:= 'Code';  // položka podle které se bude vyhledávat středisko
    mCbDocQueue.Top:= 10;
    mCbDocQueue.Left:= 110;
    mCbDocQueue.Width:= 108;
    mCbDocQueue.DataText:=ADocQueue_ID;
    mCbDocQueue.ConnectedControl:= mCbCCDocQueue;
    mCbDocQueue.ConnectedControlField:= 'Name';
    mCbDocQueue.Parameters.Clear;
    mCbDocQueue.Parameters.Add('_Allowed='+mAllowedDQ.DelimitedText);



    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Důvod:';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd := TMemo.Create(mForm);
    mEd.Left := 110;
    mEd.Top := 37;
    mEd.Width := 380;
    med.Height:= 60;
    mEd.Text := '';
    mEd.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 100;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.Default := True;
    mButOk.Cancel := False;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 100;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.Cancel := True;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
     if mResult = 1 then begin
         ADocQueue_ID:=mCbDocQueue.DataText;
         aReason:=mEd.Text;
         Result:=true;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.