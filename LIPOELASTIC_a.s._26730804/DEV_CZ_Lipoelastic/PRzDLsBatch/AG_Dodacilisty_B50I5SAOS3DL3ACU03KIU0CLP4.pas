{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
 mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Nový doklad';
  mmAction.Hint := 'Vytvoření dokladu zpětně';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Vytvoří novou příjemku podle aktuálnho DL');
  mMAction.Items.Add('Vytvoří novou OP podle aktuálnho DL');
  mmAction.OnExecuteItem:= @NewDLExecute;
end;


function NewOP(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mOP: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mOP := ABO.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
  try
    mOP.New;
    mOP.Prefill;
    mOP.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mOP.SetFieldValueAsString('FirmOffice_ID', ABO.GetFieldValueAsString('FirmOffice_ID'));
    mOP.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mOP.SetFieldValueAsString('DocQueue_ID', '1S00000101');
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mMonOutput := mOP.GetLoadedCollectionMonikerForFieldCode(mOP.GetFieldCode('ROWS'));
    mOP.SetFieldValueAsString('X_Cilovy_sklad', mMonInput.BusinessObject[0].GetFieldValueAsString('Store_ID'));



      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
        mNewRow := mMonOutput.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', '1120000101');
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
        {if mNewRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
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
        end;}
      end;


    mOP.ClearValidateErrors;
    if Not mOP.Validate() then begin
      mList := TStringList.Create;
      try
        mOP.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou objedn8vku nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
       mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mOP);
    end else begin
      mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mOP);
//      mOP.Save;
      result := mOP.OID;
    end;
  finally
    mOP.Free;
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
    mDL.SetFieldValueAsString('DocQueue_ID', '1A10000101');
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mMonOutput := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));

      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
        mNewRow := mMonOutput.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', '1120000101');
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

procedure NewDLExecute(Sender: TAction; Index: integer);
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
        if index=0 then mID := NewDL(mObj,msite);
        if index=1 then mID := NewOP(mObj,msite);
      end;
    finally
    end;
  end;
end;



begin
end.