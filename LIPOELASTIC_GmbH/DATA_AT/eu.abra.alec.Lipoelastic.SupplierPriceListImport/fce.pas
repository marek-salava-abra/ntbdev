const
    cSQL_X_Aktivni = '';
var
  gProgressForm : TForm;

function GetFirmID: string;
begin
  Result := GlobParams.ParamAsString('GlobalFlag', '');
end;

//Procedura pro nastavení hodnoty
procedure SetFirmID(AValue: string);
var
  mPar: TNxParameter;
begin
  mPar:= GlobParams.GetOrCreateParam(dtString, 'GetFirmID');
  mPar.AsString := AValue;
end;


function SupplierListImportXLSX(Sender: TComponent; AFirmID: string; ADate: TDateTime; ABO: TNxCustomBusinessObject = nil): Boolean;
var
  mOS: TNxCustomObjectSpace;
  mOpenDialog: TOpenDialog;
  mExcel, mXLS, objWorkbook: variant;
  i, mDeliveryDays: integer;
  mBO, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mErrors, mIDs,mAllowed,mList: TStringList;
  mSite: TSiteForm;
  mExcelFileName, mStoreCardQUnit, mSupCurrencyID, mMainStoreUnitID: string;
  mStoreCardCode, mStoreCardName, mSupplierCode, mSupplierName, mSupStoreCardCode, mSupStoreCardName, mSupCurrency, mSupQUnit, mCurrencyID, mStoreCardID: string;
  mPrice, mMinQuantity: Extended;
begin
  Result:= false;
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Microsoft excel not installed', mSite);
    exit;
  end;
  mOpenDialog.Filter := 'Import file (*.xls,*.xlsx)|*.XLS;*.xlsx';
  //mOpenDialog.Options := [ofAllowMultiSelect];
  mErrors:= TStringList.Create;
  try
    if mOpenDialog.Execute then
    begin
      try
        mExcelFileName := mOpenDialog.FileName;
        objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
        mXLS:= objWorkbook.WorkSheets[1];
        ProgressInit(mSite, 'Importing supplier list', mXLS.UsedRange.Rows.Count);
        mOS:= Sender.Site.BaseObjectSpace;
        mCurrencyID :=  '0000EUR000';
        mBO:= mOS.CreateObject(Class_SupplierPriceList);
        try
          if not (Assigned(ABO)) then
          begin
            mBO.New;
            mBO.Prefill;
            mBO.SetFieldValueAsString('Firm_ID', AFirmID);
            mBO.SetFieldValueAsString('Code', NxLeft(mBO.GetFieldValueAsString('Firm_ID.Code'), 37) + ' - '+CFxDate.DateToStr(Date, 'YYYY-MM-DD', '-'));
            mBO.SetFieldValueAsString('Name', NxLeft(mBO.GetFieldValueAsString('Firm_ID.Name'), 87) + ' - '+CFxDate.DateToStr(Date, 'YYYY-MM-DD', '-'));
            mBO.SetFieldValueAsDateTime('ValidFromDate$DATE', ADate);
          end else
          begin
            mBO:= ABO;
          end;
          mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

          for i:= 2 to mXLS.UsedRange.Rows.Count do
          begin
            try
              try
                mStoreCardCode:=    VarToStr(mXLS.Cells[i,1].Value);
                mStoreCardName:=    VarToStr(mXLS.Cells[i,3].Value);
                mSupplierCode:=     VarToStr(mXLS.Cells[i,4].Value);
                mSupplierName:=     VarToStr(mXLS.Cells[i,5].Value);
                mSupStoreCardCode:= VarToStr(mXLS.Cells[i,6].Value);
                mSupStoreCardName:= VarToStr(mXLS.Cells[i,7].Value);
                mPrice:=            NxIBStrToFloat(VarToStr(mXLS.Cells[i,8].Value));
                mSupCurrency:=      VarToStr(mXLS.Cells[i,9].Value);
                mSupQUnit:=         VarToStr(mXLS.Cells[i,10].Value);
                mMinQuantity:=      NxIBStrToFloat(VarToStr(mXLS.Cells[i,11].Value));
                mDeliveryDays:=     StrToIntDef(VarToStr(mXLS.Cells[i,12].Value), 0);

                mStoreCardID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' and Code = '+QuotedStr(mStoreCardCode));
                mSupCurrencyID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Currencies where Code = '+QuotedStr(mSupCurrency));

                OutputDebugString(mStoreCardID+ ' '+mStoreCardCode);
                if NxIsEmptyOID(mStoreCardID) then continue;
                mStoreCardQUnit:= mOS.SQLSelectFirstAsString('SELECT MainUnitCode FROM StoreCards WHERE Hidden = ''N'' and ID = '+QuotedStr(mStoreCardID));
                if UpperCase(mSupQUnit) <> UpperCase(mStoreCardQUnit) then continue;
                mMainStoreUnitID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreUnits WHERE Code = '+QuotedStr(mStoreCardQUnit)+' and Parent_ID = '+QuotedStr(mStoreCardID));

                mRow := mRows.AddNewObject;
                //mRow.Prefill;
                mRow.SetFieldValueAsString('StoreCard_ID',mStoreCardID);
                mRow.SetFieldValueAsString('Code', Nxleft(mSupStoreCardCode, 40));
                mRow.SetFieldValueAsString('Name', NxLeft(mSupStoreCardName, 100));
                mRow.SetFieldValueAsFloat('PurchasePrice', mPrice);
                mRow.SetFieldValueAsFloat('MinimalQuantity', mMinQuantity);
                mRow.SetFieldValueAsInteger('DeliveryTime', mDeliveryDays);
                //mRow.SetFieldValueAsFloat('VATRate', mVATRate);
                mRow.SetFieldValueAsString('Currency_ID', mSupCurrencyID);
                mRow.SetFieldValueAsString('StoreUnit_ID', mMainStoreUnitID);
                mRow.SetFieldValueAsString('QUnit', mSupQUnit);
              except
                OutputDebugString(ExceptionMessage);
              end;
            finally
              ProgressSetPos(i);
            end;
          end;
          mBO.Save;
          Result:= True;
        finally
          mBO.Free;
        end;
      except
        mErrors.Add(ExceptionMessage);
        ProgressDispose();
      end;
    end
    else begin
      ShowMessage('No file selected, process will end.');
      Exit;
    end;
    ProgressDispose();
    if mErrors.Count > 0 then begin
      //Log(#13#10+'Chyby: '+#13#10+mErrors.Text);
      NxMessageBox('Warning', 'While importing errror occured. Pricelist will not be saved.', mdWarning, mdbOk, 0, 0, false, mSite);
      NxShowEditorSite(mSite.SiteContext, mErrors.Text, true);
    end else begin
      NxMessageBox('Info', 'Import done', mdInformation, mdbOk, 0, 0, false, mSite);
      TDynSiteForm(mSite).RefreshData;
    end;
  finally
    mXLS:= Null;
    objWorkbook.Close(False);
    objWorkbook:= Null;
    mExcel.quit;
    mExcel:= Null;
    mErrors.Free;
    mOpenDialog.free;
  end;
end;


{
procedure GetSelectedFirmID(Sender: TComponent);
var
  mParams: TNxParameters;
  //mID: String;
  mSite: TSiteForm;
  mParent: TComponent;
  mContext: TNxContext;
begin
  mParent:= Sender.Owner;
  mSite:= TDynSiteForm(Sender.Owner);
  mContext:= mSite.SiteContext;
  mParams := TNxParameters.Create;
  try
    mParams.GetOrCreateParam(dtString, '_ID').AsString := ''; // Otevření na konkrétním záznamu. '' - bez určení
    if NxShowRoll(mContext, Roll_Firms, mParams, 0, '', mSite) then begin
      SetFirmID(mParams.ParamByName('_ID').AsString);
    end;
  finally
    mParams.Free;
  end;
end;
}

procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite);
  gProgressForm.BorderStyle:= bsToolWindow;
  gProgressForm.Position:= poScreenCenter;
  gProgressForm.ClientWidth:= 220;
  gProgressForm.ClientHeight:= 25;
  gProgressForm.Caption := ACaption;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= gProgressForm.ClientHeight - Height - 2;
    Width:= gProgressForm.ClientWidth - 4;
    Name:= 'prgBar';
    Max := AMaxValue
  end;

  gProgressForm.Show();
  Application.ProcessMessages();
end;

procedure ProgressDispose;
begin
  gProgressForm.Close();
end;

procedure ProgressSetMax(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Max:= aValue;
end;

procedure ProgressSetPos(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Position:= aValue + 1;
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Repaint;

  gProgressForm.Refresh();
  gProgressForm.BringToFront();

  Application.ProcessMessages();
end;

function FrmTeplomer(aParentForm: TForm): TForm;
var Frm: TForm;
begin
  Frm:= TForm.Create(aParentForm);
  Frm.BorderStyle:= bsDialog;
  Frm.Position:= poScreenCenter;
  Frm.ClientWidth:= 150;
  Frm.ClientHeight:= 30;
  with TProgressBar.Create(Frm) do
  begin
    Parent:= Frm;
    Left:= 2;
    Top:= Frm.ClientHeight - Height - 2;
    Width:= Frm.ClientWidth - 4;
    Name:= 'prgBar'
  end;
  Result:= Frm;
end;


begin
end.