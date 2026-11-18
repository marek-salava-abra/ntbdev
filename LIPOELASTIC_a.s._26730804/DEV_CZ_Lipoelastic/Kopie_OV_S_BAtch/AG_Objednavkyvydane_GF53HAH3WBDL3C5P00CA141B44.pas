function NewDL(ABO: TNxCustomBusinessObject): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mDocBatchRowSource,mDocBatchRow: TNxCustomBusinessObject;
  mList,mr: TStringList;
  mText: string;
begin
  result := '';
  mDL := ABO.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    mDL.SetFieldValueAsString('U_PrintLink', ABO.GetFieldValueAsString('U_PrintLink'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mDL.SetFieldValueAsString('DocQueue_ID', '1640000101');
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    try
      for i := 0 to mMon.Count-1 do begin
        mRow := mMon.BusinessObject[i];
        mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
        mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
      end;
      mList.Sort;
      mMon := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        mNewRow := mMon.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', '41Y0000101');
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

        mNewRow.SetFieldValueAsString('X_ExternalSpecification', mRow.GetFieldValueAsString('X_ExternalSpecification'));
        mNewRow.SetFieldValueAsString('X_Specifikace_ID', mRow.GetFieldValueAsString('X_Specifikace_ID'));
        mNewRow.SetFieldValueAsString('U_Specifikace_ID', mRow.GetFieldValueAsString('U_Specifikace_ID'));

         if mNewRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
          // NxShowSimpleMessage('Dohledání šarže',nil);
           mr:=tstringlist.Create;
           try
                  ABO.ObjectSpace.SQLSelect('Select id FROM DefRollData A WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                        ' ) AND (A.X_Parent_ID ) = ' + quotedstr(mrow.GetFieldValueAsString('ID')),mr);
                        if mr.count>0 then
                              mDocBatchRowSource:=ABO.ObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                              mDocBatchRow:=ABO.ObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                 try
                                    for ii:=0 to mr.count-1 do begin
                                          mDocBatchRowSource.load(mr.Strings[ii],nil);
                                                      //           NxShowSimpleMessage('Zakládání šarže',nil);
                                                      mDocBatchRow.new;
                                                      mDocBatchRow.Prefill;
                                                      mDocBatchRow.SetFieldValueAsstring('Code',mdl.OID);
                                                      mDocBatchRow.SetFieldValueAsstring('X_Parent_ID',mNewRow.OID);
                                                      mDocBatchRow.SetFieldValueAsstring('X_Firm_ID',mDL.GetFieldValueAsString('Firm_ID'));
                                                      mDocBatchRow.SetFieldValueAsstring('X_Parent2_ID',mNewRow.GetFieldValueAsString('Storecard_ID'));
                                                      mDocBatchRow.SetFieldValueAsstring('X_Batches',mDocBatchRowSource.getFieldValueAsstring('X_Batches'));
                                                      mDocBatchRow.SetFieldValueAsfloat('X_quantity',mDocBatchRowSource.getFieldValueAsfloat('X_quantity'));
                                                      mDocBatchRow.SetFieldValueAsstring('Name',
                                                                                                 copy(mDL.GetFieldValueAsString('Docqueue_ID.code') + '-' +
                                                                                                 //inttostr(mDL.GetFieldValueAsinteger('Ordnumber')) + '/' + mDL.GetFieldValueAsString('Period_ID.code') +
                                                       ' - ' + mNewRow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                       // NxShowSimpleMessage('Uložení šarže',nil);
                                                      mDocBatchRow.save;
                                    end;
                              finally
                                 mDocBatchRow.free;
                                 mDocBatchRowSource.free;
                              end;
           finally
               mr.free;
           end;
         end;









      end;
    finally
      mList.Free;
    end;
    mDL.ClearValidateErrors;

    if Not mDL.Validate() then begin
      mList := TStringList.Create;
      try
        mDL.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou OV nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin
      mDL.Save;
      result := mDL.OID;
    end;
  finally
    mDL.Free;
  end;
end;

procedure NewDLExecute(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := TComponent(Sender).DynSite;
    //OutputDebugString('Nalezen nadřízený SiteForm.');

    // Ziskame aktualni objekt (TNxCustomBusinessObject)
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewDL(mObj);
        if not NxIsEmptyOID(mID) then
          mSite.ShowDynForm('GF53HAH3WBDL3C5P00CA141B44', Nil, Nil, False, 'DoEdit;'+mID);
      end;
    finally
      mObj.Free;
    end;
  end;
end;

procedure NewDLUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
begin
  //OutputDebugString('Jsem v OnUpdate.');
  //OutputDebugString('Sender je '+Sender.ClassName+'.');
  // Zjistime, zda je Sender typu TComponent
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');

      // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
      // a v pripade, ze neni zahajena editace
      mObj := mSite.CurrentObject;
      try
        TAction(Sender).Enabled := not mSite.Edit and Assigned(mObj);
      finally
        mObj.Free;
      end;
    end;
  end;
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Kopie OV pro stříhárnu s šarží';
  mAction.Hint := 'Vytvoří novou OV4 podle aktuálnho OV.';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @NewDLExecute;
 // mAction.OnUpdate := @NewDLUpdate;
end;

begin
end.