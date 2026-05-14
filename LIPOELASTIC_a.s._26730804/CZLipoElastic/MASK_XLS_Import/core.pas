uses 'MASK_XLS_Import.fce';

procedure ImportXLS(Sender: TComponent);
var
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  mOS: TNxCustomObjectSpace;
  mBOSource,mBOTarget: TNxCustomBusinessObject;
  mRows,MBatches: TNxCustomBusinessMonikerCollection;
  objWorkbook, mXLS, mExcel: Variant;
  mExcelFileName, mErrLog, mStoreCard_ID, mRateExists: string;
  mCountryCodeList: TStringList;
  i, j, k: integer;
  mBO:TNxCustomBusinessObject;
begin
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  mOS:= Sender.Site.BaseObjectSpace;
  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
    exit;
  end;
  mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
  //mOpenDialog.Options := [ofAllowMultiSelect];
  if mOpenDialog.Execute then
  begin
    try
      mExcelFileName := mOpenDialog.FileName;
      objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
      mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
      ProgressInit(mSite, 'Importování...', mXLS.UsedRange.Rows.Count);
      mErrLog:= '';
      for i:= 0 to mXLS.UsedRange.Rows.Count do
      begin

//        mCardCode:= VarToStr(mXLS.Cells[i,1]);
//        mStoreCard_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM StoreCards WHERE Hidden=''N'' AND Code='+QuotedStr(mCardCode));
//        if not NxIsEmptyOID(mStoreCard_ID) then
//        begin
          //mBO:= mOS.CreateObject(Class_StoreCard);
          try
           // mBO.Load(mStoreCard_ID, nil);
            //mVATRates:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('VATRates'));
            //NxShowSimpleMessage(mXLS.Cells[i,1],nil);
            //for k:= 6 to 32 do begin
             // mCountry_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM Countries WHERE Hidden=''N'' AND Code='+QuotedStr(VarToStr(mXLS.Cells[1,k])));
             // mVATRate_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM VATRates WHERE Hidden=''N'' AND Country_ID='+QuotedStr(mCountry_ID)+' AND Tariff='+QuotedStr(VarToStr(mXLS.Cells[i,k])));
             // mRateExists:= mOS.SQLSelectFirstAsString(' SELECT ID FROM StoreCardVATRates WHERE Parent_ID='+QuotedStr(mStoreCard_ID)+' AND Country_ID='+QuotedStr(mCountry_ID)+' AND VATRate_ID='+QuotedStr(mVATRate_ID));
             // if not(NxIsEmptyOID(mRateExists)) then continue;
             // mRate:= mVATRates.AddNewObject;
              //mRate.Prefill;
             // mRate.SetFieldValueAsString('Country_ID', mCountry_ID);
             // mRate.SetFieldValueAsString('VATRate_ID', mVATRate_ID);
            //end;
             // mBO.Save;
          finally
           // mBO.Free;
            ProgressSetPos(i);
          end;
  //      end else
  //      begin
  //        mErrLog:= #10+'Karta s kódem '+mCardCode+' nenalezena.';
  //        continue;
 //       end;
      end;
    finally
      //mCountryCodeList.Free;
      mOpenDialog.Free;
      objWorkbook.close;
      mExcel.Quit;
      mExcel:= nil;
      mXLS:= nil;
      ProgressDispose();
      TDynSiteForm(mSite).RefreshData;
    end;
  end;
end;

begin
end.