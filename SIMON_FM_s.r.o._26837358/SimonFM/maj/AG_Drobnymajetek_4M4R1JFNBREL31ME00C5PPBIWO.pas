procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import CSV';
  mAction.Items.Add('Ze skladu');
  mAction.Hint := 'Import z textového souboru';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  i:integer;
  mTempStr:string;
  mCode,mInventoryNr,mName,mProductNr,mYearOfProduction,mPurchaseDate,mPurchasePrice,mQuantity,mNote:string;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        for i:=0 to mlist.count-1 do begin
          mTempStr:=mList.Strings[i];
          mCode:=NxTrapStr(mTempStr,';');
          mInventoryNr:=NxTrapStr(mTempStr,';');
          mName:=NxTrapStr(mTempStr,';');
          mProductNr:=NxTrapStr(mTempStr,';');
          mYearOfProduction:=NxTrapStr(mTempStr,';');
          mPurchaseDate:=NxTrapStr(mTempStr,';');
          mPurchasePrice:=NxTrapStr(mTempStr,';');
          mQuantity:=NxTrapStr(mTempStr,';');
          mNote:=NxTrapStr(mTempStr,';');
          mBO:=msite.BaseObjectSpace.CreateObject(Class_SmallAssetCard);
          mbo.New;
          mbo.Prefill;
          mbo.SetFieldValueAsString('Code',mCode);
          mBO.SetFieldValueAsString('X_OldInvNumber',mInventoryNr);
          mBO.SetFieldValueAsString('InventoryNr',AnsiRightStr('00'+IntToStr(i+1),3)+'/0124');
          mBO.SetFieldValueAsString('Name',mName);
          mBO.SetFieldValueAsInteger('YearOfProduction',Trunc(Nxibstrtofloat(mYearOfProduction)));
          mbo.SetFieldValueAsDateTime('PurchaseDate$Date',45292);
          mBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mQuantity));
          mbo.SetFieldValueAsString('Note',mNote);
          if not(NxIsBlank(mPurchaseDate)) then
          mBO.SetFieldValueAsDateTime('X_OldDate',StrToDate(mPurchaseDate));
          mbo.SetFieldValueAsFloat('PurchasePrice',NxIBStrToFloat(mPurchasePrice));
          mBO.SetFieldValueAsString('EvidenceDivision_ID','3100000101');
          mBO.SetFieldValueAsString('ExpensesDivision_ID','3100000101');
          mbo.SetFieldValueAsString('AssetLocation_ID','1300000101');
          mBO.SetFieldValueAsString('Responsible_ID','1100000101');
          mbo.save;
          mbo.Free;
        end;
      finally
        mList.Free;
      end;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
  finally
    mOpenDlg.Free;
  end;
end;


begin
end.