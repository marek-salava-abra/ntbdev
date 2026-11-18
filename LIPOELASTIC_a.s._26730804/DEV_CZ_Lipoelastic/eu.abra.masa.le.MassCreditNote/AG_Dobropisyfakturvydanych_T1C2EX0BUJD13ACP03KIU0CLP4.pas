uses 'eu.abra.masa.le.MassCreditNote.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '###Vrácení z CSV###';
  mAction.Hint := 'Vrátí dle CSV souborů';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateCreditNote;

end;

Procedure CreateCreditNote(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mDate:Extended;
 mICNDQ_ID, mVRDQ_ID,mStore_ID, mII_ID, mIIRow_ID, mRSource_ID, mICN_ID:string;
 mResult,i,j,k,l:integer;
 mFileList, mRowList, mICNList, mRowsList, mFileContentL, mRowList2:TStringList;
 mInvoiceBO:TNxCustomBusinessObject;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mTempString:string;
 mBatchCode, mCurrencyCode, mInvoiceNo, mDQCode, mOrdNuber, mPCode, mBName: string;
 mUnitPrice, mDiscountPrice, mQuantity, mICNQuantity: Extended;
 mICNRows, mFakeICNRows:TNxCustomBusinessMonikerCollection;
 mICNRow:TNxCustomBusinessObject;
 mFakeICNBO, mFakeICNRowBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mICNDQ_ID:='2B10000101';
 mStore_ID:='3D30000101';
 mVRDQ_ID:='PA10000101';
 mICNList:=TStringList.Create;
 GetDataForReturn(mSite, mStore_ID, mICNDQ_ID, mVRDQ_ID, mDate, mResult);
      if mResult=1 then begin
       if NxIsEmptyOID(mStore_ID) or NxIsEmptyOID(mICNDQ_ID) or NxIsEmptyOID(mVRDQ_ID) then begin
             NxShowSimpleMessage('Není zadaný sklad, nebo řady dokladů, ukončuji.',mSite);
           end else begin
              mOpenDlg := TOpenDialog.Create(TComponent(Sender));
              mOpenDlg.Options:=[ofAllowMultiSelect];
              mOpenDlg.DefaultExt:='csv';
              if mOpenDlg.Execute then begin
                mFileList:=TStringList.create;
                mFileList.AddStrings(mOpenDlg.files);
                WaitWin.StartProgress('Čekejte, prosím ...', '', mFileList.Count);
                for i:=0 to mFileList.count-1 do begin
                   mFileContentL:=tstringlist.Create;
                   mRowsList:=TStringList.Create;
                   mRowList:=TStringList.create;
                   mRowList.NameValueSeparator:=';';
                   mRowList2:=TStringList.create;
                   mRowList2.NameValueSeparator:=';';
                   mFileContentL.LoadFromFile(mFileList.strings[i]);
                     for j:=0 to mFileContentL.Count-1 do begin
                       mTempString:=mFileContentL.strings[j];
                       mBatchCode:=NxTrapStr(mTempString,';');
                       mUnitPrice:=NxIBStrToFloat(NxTrapStr(mTempString,';'));
                       mDiscountPrice:=NxIBStrToFloat(NxTrapStr(mTempString,';'));
                       mCurrencyCode:=NxTrapStr(mTempString,';');
                       mQuantity:=NxIBStrToFloat(NxTrapStr(mTempString,';'));
                       mInvoiceNo:=NxTrapStr(mTempString,';');
                       if j=0 then begin
                         mDQCode:=NxTrapStr(mInvoiceNo,'-');
                         mOrdNuber:=NxTrapStr(mInvoiceNo,'/');
                         mPCode:=NxTrapStr(mInvoiceNo,'/');
                         mII_ID:=mOS.SQLSelectFirstAsString(format('select ii.id from issuedinvoices ii left join docqueues dq on dq.id=ii.docqueue_id left join periods p on p.id=ii.period_id where dq.code=''%s'' and ii.ordnumber=%s and p.code=''%s'' ',[mDQCode,mOrdNuber,mPCode]));
                         if not(NxIsEmptyOID(mII_ID)) then begin
                           mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
                           mInvoiceBO.load(mII_ID,nil);
                           //NxShowSimpleMessage(mInvoiceBO.DisplayName,mSite);
                         end;
                       end;
                       mIIRow_ID:=mOS.SQLSelectFirstAsString(format('Select ii2.id from issuedinvoices2 ii2 left join storedocuments2 sd2 on sd2.id=ii2.providerow_id left join docrowbatches drb on drb.parent_id=sd2.id left join storebatches sb on sb.id=drb.storebatch_id where ii2.parent_id=''%s'' and sb.name=''%s'' ',[mII_ID,mBatchCode]));
                       if not(NxIsEmptyOID(mIIRow_ID)) then begin
                         mRowsList.Add(mIIRow_ID);
                         mRowList.Add(mIIRow_ID+';'+floattostr(mQuantity));
                         mRowList2.Add(mIIRow_ID+';'+mBatchCode);
                       end;
                     end;
                     //NxShowSimpleMessage('řádky: '+IntToStr(mRowsList.count)+'  filerows: '+IntToStr(mFileContentL.count)+' '+mInvoiceBO.DisplayName,msite);

                        mInputParams := TNxParameters.Create;
                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                        mParam.AsString := mICNDQ_ID;
                        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                        mParam.AsString := mII_ID;
                        mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
                        mParam.AsBoolean := True;
                        mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                        mParam.AsString := mVRDQ_ID;
                        mImportMan:=NxCreateDocumentImportManager(mOS,Class_IssuedInvoice,Class_IssuedCreditNote);
                        mImportMan.AddInputDocument(mInvoiceBO.OID);
                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mICNDQ_ID);
                        mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID',mVRDQ_ID);
                        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mInvoiceBO.GetFieldValueAsString('Firm_ID'));
                        mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mInvoiceBO.GetFieldValueAsString('FirmOffice_ID'));
                        mimportman.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',44965);
                        mImportMan.OutputDocument.SetFieldValueAsDateTime('VatDate$Date',44965);
                        mImportMan.OutputDocument.SetFieldValueAsFloat('CurrRate',23.78);
                        mICNRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                        for k:=0 to mICNRows.Count-1 do begin
                          mICNRow:=mICNRows.BusinessObject[k];
                          if mRowsList.IndexOf(mICNRow.GetFieldValueAsString('RSource_ID'))<0 then mICNRow.MarkForDelete;
                          mICNRow.SetFieldValueAsFloat('UnitPrice',0.9*mICNRow.GetFieldValueAsFloat('UnitPrice'));
                          mICNRow.SetFieldValueAsString('Store_ID',mStore_ID);
                          for l:=0 to mRowList.count-1 do begin
                             mRSource_ID:=mRowList.Names[l];
                             mICNQuantity:=NxIBStrToFloat(mRowList.ValueFromIndex[l]);
                             if mICNRow.GetFieldValueAsString('Rsource_ID')=mRSource_ID then mICNRow.SetFieldValueAsFloat('X_Quantity',mICNQuantity);
                          end;
                          for l:=0 to mRowList2.count-1 do begin
                             mRSource_ID:=mRowList2.Names[l];
                             mBName:=(mRowList2.ValueFromIndex[l]);
                             if mICNRow.GetFieldValueAsString('Rsource_ID')=mRSource_ID then mICNRow.SetFieldValueAsString('X_bname',mBName);
                          end;
                        end;
                        mImportMan.OutputDocument.save;
                        mICN_ID:=mImportMan.OutputDocument.OID;
                        mICNList.Add(mImportMan.OutputDocument.OID);
                        mImportMan.free;

                        mRowList.free;
                   mFileContentL.free;
                   WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mFileList.Count));
                   WaitWin.StepIt;
                   end;
                 WaitWin.Stop;
              end;
           end;
      end;
end;

begin
end.