function NewPRE(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mDL := ABO.ObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mDL.SetFieldValueAsString('DocQueue_ID', abo.getFieldValueAsString('DocQueue_ID'));
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mMonOutput := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));

      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
        mNewRow := mMonOutput.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', mRow.getFieldValueAsString('Store_ID'));
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
        if mNewRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
            mBO_MonikerInput:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
            mBO_MonikerOutput:=mNewRow.GetLoadedCollectionMonikerForFieldCode(mNewRow.GetFieldCode('DocRowBatches'));
                           for ii:=0 to mBO_MonikerInput.Count-1 do begin
                                             mdocrowbatches:=mBO_MonikerOutput.AddNewObject;

                                                                          mdocrowbatches.Prefill;
                                                                          mdocrowbatches.setFieldValueAsstring('QUnit',mBO_MonikerInput.BusinessObject[ii].getFieldValueAsString('QUnit'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Unitrate',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('unitrate'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Quantity',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity'));
                                                                          mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID'));
                           end;
        end;
      end;


    mDL.ClearValidateErrors;
    if Not mDL.Validate() then begin
      mList := TStringList.Create;
      try
        mDL.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou příjemku nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
       mSite.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mDL);
    end else begin
      mSite.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mDL);
//      mDL.Save;
      result := mDL.OID;
    end;
  finally
    mDL.Free;
  end;
end;



function NewDL(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mDL := ABO.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mDL.SetFieldValueAsString('DocQueue_ID', abo.getFieldValueAsString('DocQueue_ID'));
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mMonOutput := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));

      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
        mNewRow := mMonOutput.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', mRow.getFieldValueAsString('Store_ID'));
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
        if mNewRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
            mBO_MonikerInput:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
            mBO_MonikerOutput:=mNewRow.GetLoadedCollectionMonikerForFieldCode(mNewRow.GetFieldCode('DocRowBatches'));
                           for ii:=0 to mBO_MonikerInput.Count-1 do begin
                                             mdocrowbatches:=mBO_MonikerOutput.AddNewObject;

                                                                          mdocrowbatches.Prefill;
                                                                          mdocrowbatches.setFieldValueAsstring('QUnit',mBO_MonikerInput.BusinessObject[ii].getFieldValueAsString('QUnit'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Unitrate',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('unitrate'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Quantity',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity'));
                                                                          mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID'));
                           end;
        end;
      end;


    mDL.ClearValidateErrors;
    if Not mDL.Validate() then begin
      mList := TStringList.Create;
      try
        mDL.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou příjemku nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
       mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mDL);
    end else begin
      mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mDL);
//      mDL.Save;
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
    mSite := TComponent(Sender).DynSite;
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewDL(mObj,msite);
      end;
    finally
    end;
  end;
end;


procedure NewPREExecute(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewPRE(mObj,msite);
      end;
    finally
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
  mAction.Caption := 'Nová PR z PR s šarží';
  mAction.Hint := 'Vytvoří novou příjemku podle aktuálnho PR.';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @NewDLExecute;


//  mAction := Self.GetNewAction;
//  mAction.ShowControl := True;
//  mAction.ShowMenuItem := True;
//  mAction.Caption := 'Nová PRE z PR s šarží';
//  mAction.Hint := 'Vytvoří novou převodku podle aktuálnho PR.';
//  mAction.Category := 'tabDetail, tabList';
//  mAction.OnExecute := @NewPREExecute;


end;

begin
end.