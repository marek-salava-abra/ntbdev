function NewDL(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mDocqueue_ID,mStore_ID:string;
begin
  result := '';
    mDocqueue_ID:='5B10000101';
    mStore_ID:='1120000101';
  mDL := ABO.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mDL.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID);
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mMonOutput := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));

      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
        mNewRow := mMonOutput.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', mStore_ID);
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

      end;


    mDL.ClearValidateErrors;
    if Not mDL.Validate() then begin
      mList := TStringList.Create;
      try
        mDL.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou OP nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
       mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mDL);
    end else begin
      mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mDL);
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



procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
{  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Nová OP z OV ';
  mAction.Hint := 'Vytvoří novou OP podle aktuální OV.';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @NewDLExecute;
    }
end;

begin
end.