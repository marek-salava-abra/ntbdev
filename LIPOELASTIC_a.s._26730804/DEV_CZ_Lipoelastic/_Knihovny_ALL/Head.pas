

function CopyHead(ABO: TNxCustomBusinessObject;TargetCLSID:string): string;
var
  mBO,mBO_PohybSarze,mBO_PohybSarzenew: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList,mr: TStringList;
  mText: string;
begin
  result := '';
  mBO := ABO.ObjectSpace.CreateObject(TargetCLSID);
  try
    mBO.New;
    mBO.Prefill;
    mBO.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mBO.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mBO.SetFieldValueAsString('DocQueue_ID', '1640000101');
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
      mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        mNewRow := mMon.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

      end;
    finally
      mList.Free;
    end;
    mBO.ClearValidateErrors;
    if Not mBO.Validate() then begin
      mList := TStringList.Create;
      try
        mBO.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin
      mBO.Save;
      result := mbo.OID;
    end;
  finally
    mbo.Free;
  end;
end;





function Inputmanager(OS: TNxCustomObjectSpace;SourceDoc,TargetDoc:string;mParams:TNxParameters;mInputDoc:TStringList;mOutputDoc_ID:String;HeadDocument:string;mDocQueue_ID:string):string;
var
  i,x : integer;
  mMon,mrowsOutput,mrowsinput,mrowsOutput1,mrowsinput1,mrows: TNxCustomBusinessMonikerCollection;
  ii,jj:integer;
  mr:TStringList;
  mManager : TNxDocumentImportManager ;

  mi:integer;
begin
             mManager := NxCreateDocumentImportManager(os,SourceDoc,TargetDoc);
        try
                  for x:=0 to minputDoc.Count-1 do begin   // vstupní doklady
                        if minputDoc.count>1 then begin
                                 if x=0 then mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString:=minputDoc.Strings[x] ; // doklad pro převzetí hlavičkových údajů
                        end;
                     mManager.AddInputDocument(minputDoc.Strings[x]);
                  end;


                  if mOutputDoc_ID<>'' then begin
                         mManager.OutputDocument.Load(mOutputDoc_ID,nil);


                          mManager.LoadParams(mParams);
                          mManager.Execute;
                          mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));

                          //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
                          mRowsInput := mManager.inputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.inputDocument.GetFieldCode('Rows'));
                          mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));

                          for ii:=0 to mRowsOutput.Count-1 do begin
                                             for jj:=0 to mRowsinput.Count-1 do begin
                                                  if mRowsOutput.BusinessObject[ii].getFieldValueAsString('Storecard_ID') = mrowsinput.BusinessObject[jj].getFieldValueAsString('Storecard_ID')  then begin
                                                        //  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsinput.BusinessObject[jj].getFieldValueAsFloat('X_vychystano'));
                                                  end;
                                            end;
                          end;
                          mManager.OutputDocument.Save;
                          Result:=mManager.OutputDocument.oid;
                 end;


                finally
                  mManager.Free;
                end;
end;










begin
end.