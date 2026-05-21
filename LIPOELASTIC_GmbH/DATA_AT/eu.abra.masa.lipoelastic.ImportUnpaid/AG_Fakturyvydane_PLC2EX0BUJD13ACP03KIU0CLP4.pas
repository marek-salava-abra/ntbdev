procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSetAmountInv';
  mAction.Caption := '##UNPAID##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;



Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,l,m,mCount:integer;
 mXMLHead:TNxScriptingXMLWrapper;
 mBO, mRowBO, mFirmBO, mDRBBo:TNxCustomBusinessObject;
 mStreet, mCity, mPostCode, mFirmOffice_ID, mOrder_ID, mStore_ID:string;
 mCodeEan, mSCName,mStoreCard_ID,mVATName:string;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mQuantity, mBODQuantity:extended;
 mSQLStreet,mSQLPostCode, mSQLCity, mStoreCode:string;
 mContactFirstName, mContactLastName, mContactEmail: string;
 mPerson_ID, mFPerson_ID, mRO_ID, mRORow_ID, mExternalNumber, mSCEAN, mStoreBatch_ID: string;
 mStoreBatchName, mExpiryDateString, mPayCode, mTransCode, mPayment_ID, mTrans_ID, mSD2_ID, mFileName, mInvoice_ID:string;
 mExpiryDate:Extended;
 mRORowList, mErrList:TStringList;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mOrigInvoiceBO, mInvoiceBO, mInvoiceRowBO:TNxCustomBusinessObject;
 mDelete:Boolean;
 mAmount, mXMLAmount:Extended;
 mExcel, mWB, mSheet: Variant;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import XLS';
 mOpenDlg.Filter := 'Excel files (*.xls, *.xlsx)| *.xls;*.xlsx';
 mErrList:=tstringlist.Create;
 if mOpenDlg.Execute then begin
  try
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          i:=2;
          j:=mSheet.UsedRange.Rows.Count+1;
          WaitWin.StartProgress('Please, wait ...', '', j);
          while i<j  do begin
            WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(j));
            //if not(NxIsBlank(VarToStr(msheet.cells[i,1]))) then begin
              mInvoice_ID:=mOS.SQLSelectFirstAsString('Select ii.id from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.varsymbol='+QuotedStr(VarToStr(msheet.cells[i,1]))
               +' and f.code='+QuotedStr(VarToStr(msheet.cells[i,5])),'');
              if not(NxIsEmptyOID(mInvoice_ID)) then begin
                mOrigInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
                mOrigInvoiceBO.Load(mInvoice_ID);
                mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
                mInvoiceBO.new;
                mInvoiceBO.Prefill;
                mInvoiceBO.SetFieldValueAsString('DocQueue_ID','~000000204');
                mInvoiceBO.SetFieldValueAsString('Period_ID',mOrigInvoiceBO.GetFieldValueAsString('Period_ID'));
                mInvoiceBO.SetFieldValueAsString('Firm_ID',mOrigInvoiceBO.GetFieldValueAsString('Firm_ID'));
                mInvoiceBO.SetFieldValueAsBoolean('VatDocument',false);
                mInvoiceBO.SetFieldValueAsString('Description', mOrigInvoiceBO.GetFieldValueAsString('Description'));
                mInvoiceBO.SetFieldValueAsString('BankAccount_ID', mOrigInvoiceBO.GetFieldValueAsString('BankAccount_ID'));
                mInvoiceBO.SetFieldValueAsString('VarSymbol', mOrigInvoiceBO.GetFieldValueAsString('VarSymbol'));
                mInvoiceBO.SetFieldValueAsDateTime('DocDate$Date',mOrigInvoiceBO.GetFieldValueAsDateTime('DocDate$Date'));
                mInvoiceBO.SetFieldValueAsDateTime('DueDate$Date',mOrigInvoiceBO.GetFieldValueAsDateTime('DueDate$Date'));
                mRows:=mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mInvoiceBO.GetFieldCode('Rows'));
                mInvoiceRowBO:=mRows.AddNewObject;
                mInvoiceRowBO.Prefill;
                mInvoiceRowBO.SetFieldValueAsInteger('RowType',1);
                minvoiceRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(VarToStr(msheet.cells[i,4])));
                mInvoiceRowBO.SetFieldValueAsString('Division_ID','1000000101');
                mInvoiceBO.save;
              end else begin
                mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
                mInvoiceBO.new;
                mInvoiceBO.Prefill;
                mInvoiceBO.SetFieldValueAsString('DocQueue_ID','~000000204');
                mInvoiceBO.SetFieldValueAsString('Firm_ID','AAA1000000');
                mInvoiceBO.SetFieldValueAsBoolean('VatDocument',false);
                mInvoiceBO.SetFieldValueAsString('Description','');;
                mInvoiceBO.SetFieldValueAsString('BankAccount_ID', '2000000101');
                mInvoiceBO.SetFieldValueAsString('VarSymbol',VarToStr(msheet.cells[i,1]));
                mInvoiceBO.SetFieldValueAsDateTime('DocDate$Date',StrToDate(VarToStr(msheet.cells[i,2])));
                mInvoiceBO.SetFieldValueAsDateTime('DueDate$Date',StrToDate(VarToStr(msheet.cells[i,3])));
                mInvoiceBO.SetFieldValueAsString('Period_ID',GetPeriodID(mos, mInvoiceBO.GetFieldValueAsDateTime('DocDate$Date')));
                mRows:=mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mInvoiceBO.GetFieldCode('Rows'));
                mInvoiceRowBO:=mRows.AddNewObject;
                mInvoiceRowBO.Prefill;
                mInvoiceRowBO.SetFieldValueAsInteger('RowType',1);
                minvoiceRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(VarToStr(msheet.cells[i,4])));
                mInvoiceRowBO.SetFieldValueAsString('Division_ID','1000000101');
                mInvoiceBO.save;
              end;
           // end;
           inc(i);
           WaitWin.StepIt;
          end;
         WaitWin.Stop;
         mWB.close;

     except
      WaitWin.Stop;
         mWB.close;
      NxShowSimpleMessage(ExceptionMessage,msite);
  end;
 end;
 mErrList.SaveToFile('C:\AbraDE\'+FormatDateTime('YYYYMMDDHHNNSS',Now)+'INerror.txt');
end;

Function GetPeriodID(var aOS:TNxCustomObjectSpace;var aDate:Extended):string;
var
 mSQL:string;
begin
  Result:=aOS.SQLSelectFirstAsString('select id from periods where datefrom$date<='+IntToStr(trunc(adate))+' and dateto$date>'+IntToStr(trunc(adate)),'');
end;

begin
end.