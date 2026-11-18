 uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';

procedure ImportXLS(Sender: TComponent);
var
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  mOS: TNxCustomObjectSpace;
  mBO,mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  objWorkbook, mXLS, mExcel: Variant;
  mExcelFileName, mErrLog,mDivision  : string;
  mList: TStringList;
  i, j, k: integer;
  mPhonenumber:string;
  mStringHelp:String;
  mValidateList,mValueList:tstringlist;
  mtext:string;
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
      mXLS:= mExcel.ActiveWorkbook.WorkSheets[2];
      ProgressInit(mSite, 'Importování...', mXLS.UsedRange.Rows.Count);
      mErrLog:= '';
          // NxShowSimpleMessage(inttostr(mXLS.UsedRange.Rows.Count),nil);
      mlist:=tstringlist.create;
      for i:= 0 to mXLS.UsedRange.Rows.Count do
      begin
              mStringHelp:='';
              mPhonenumber:= mXLS.Cells[i+1,1];
              if (trim(mPhonenumber)<>'Celkem') and (trim(mPhonenumber)<>'Seznam čísel') and (trim(mPhonenumber)<>'') then begin
                    //mStringHelp:=msite.BaseObjectSpace.SQLSelectFirstAsString('select X_Firm_ID,X_FirmOffice_id,X_Person_ID,X_Division_ID,ID from CCPhoneDevices where PhoneNumber=' + quotedstr(mPhonenumber) + ' and hidden=' + QuotedStr('N'));

                    if mStringHelp='' then begin
                        mStringHelp:='0000000000;0000000000;0000000000;0000000000;0000000000;'  ;
                      //  mErrLog:= #10+'Telefonní číslo '+mPhonenumber+' nenalezena.';
                    end;
                    mStringHelp:=mStringHelp+mPhonenumber+';' ;
                    mStringHelp:=mStringHelp+(vartostr(mXLS.Cells[i+1,2]))+';' ;
                    mStringHelp:=mStringHelp+(vartostr(mXLS.Cells[i+1,13]))+';' ;
                    mStringHelp:=mStringHelp+(vartostr(mXLS.Cells[i+1,14]))+';' ;

                    mList.add(mStringHelp);
                        ProgressSetPos(i);
               end;
      end;

    mList.Sort;

    mbo:=TDynSiteForm(msite).BaseObjectSpace.CreateObject('0LHHWWVMXVD13ACQ03KIU0CLP4');
    if mlist.Count>0 then begin




              for i:=0 to mList.count-1 do begin
                    mValueList:=tstringlist.create;
                    mValueList:=fnparsevalue(mList.Strings[i],';');
                    mdivision:='';
                    if not NxIsEmptyOID(mValueList.Strings[3]) then mDivision:= mValueList.Strings[3]  else mDivision:='1N00000101' ;
                    try
                          if (i=0) then begin                  // první doklad nový

                                    mbo.new;
                                    mbo.Prefill;
                                    mbo.SetFieldValueAsString('Docqueue_ID','2721000101');
                                  if not NxIsEmptyOID(mValueList.Strings[0]) then mbo.SetFieldValueAsString('Firm_ID',mValueList.Strings[0]);
                                  if not NxIsEmptyOID(mValueList.Strings[1]) then mbo.SetFieldValueAsString('FirmOffice_ID',mValueList.Strings[1]);
                                  if not NxIsEmptyOID(mValueList.Strings[2]) then mbo.SetFieldValueAsString('Person_ID',mValueList.Strings[2]);


                                    mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

                                    mRow:=mRows.AddNewObject;
                                            mRow.Prefill;
                                            mRow.SetFieldValueAsString('Text',mValueList.Strings[5])  ;
                                            //if not NxIsEmptyOID(mValueList.Strings[4]) then mRow.SetFieldValueAsString('X_PhoneNumber_ID',mValueList.Strings[4])  ;
                                            mRow.SetFieldValueAsString('Division_ID',mDivision)  ;
                                            mRow.SetFieldValueAsString('VATRate_ID','02100X0000')  ;
                                            mRow.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat(mValueList.Strings[7]))  ;
                                            mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mValueList.Strings[8]))  ;
                            end else begin
                                 if copy(mList.Strings[i-1],1,10)= copy(mList.Strings[i],1,10) then begin       // stejná firma
                                            mRow:=mRows.AddNewObject;
                                            mRow.Prefill;
                                            mRow.SetFieldValueAsString('Text',mValueList.Strings[5])  ;
                                            //if not NxIsEmptyOID(mValueList.Strings[4]) then mRow.SetFieldValueAsString('X_PhoneNumber_ID',mValueList.Strings[4])  ;
                                            mRow.SetFieldValueAsString('Division_ID',mDivision)  ;
                                            mRow.SetFieldValueAsString('VATRate_ID','02100X0000')  ;
                                            mRow.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat(mValueList.Strings[7]))  ;
                                            mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mValueList.Strings[8]))  ;
                                 end else begin
                                       mBO.ClearValidateErrors;
                                            if Not mBO.Validate() then begin
                                                  mValidateList := TStringList.Create;
                                                  try
                                                     mBO.GetValidateErrors(mValidateList);
                                                     mText := mValidateList.Text;
                                                     NxToken(mText, '=');
                                                     //mtWarning, [mbOK], 0);
                                                   finally
                                                     mValidateList.Free;
                                                   end;
                                                   TDynSiteForm.ShowDynFormWithNewDocument('W01A21CP33DL35IV01C0CX3F40', TDynSiteForm(msite).SiteContext, mBO);
                                            end else begin
                                                 //mBO.Save;
                                                 TDynSiteForm.ShowDynFormWithNewDocument('W01A21CP33DL35IV01C0CX3F40', TDynSiteForm(msite).SiteContext, mBO);
                                            end;

                                            mbo.new;
                                                  mbo.Prefill;
                                                  mbo.SetFieldValueAsString('Docqueue_ID','2721000101');
                                                  mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
                                                  mRow:=mRows.AddNewObject;
                                                          mRow.Prefill;
                                                          mRow.SetFieldValueAsString('Text',mValueList.Strings[5])  ;
                                                          //if not NxIsEmptyOID(mValueList.Strings[4]) then mRow.SetFieldValueAsString('X_PhoneNumber_ID',mValueList.Strings[4])  ;
                                                          mRow.SetFieldValueAsString('Division_ID',mDivision)  ;
                                                          mRow.SetFieldValueAsString('VATRate_ID','02100X0000')  ;
                                                          mRow.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat(mValueList.Strings[7]))  ;
                                                          mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mValueList.Strings[8]))  ;
                                 end;
                            end;
                      finally
                          mValueList.free;
                      end;
              end;



                                    mBO.ClearValidateErrors;
                                      if Not mBO.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mBO.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               //mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             TDynSiteForm.ShowDynFormWithNewDocument('W01A21CP33DL35IV01C0CX3F40', TDynSiteForm(msite).SiteContext, mBO);


                                      end else begin
                                           //mBO.Save;
                                           TDynSiteForm.ShowDynFormWithNewDocument('W01A21CP33DL35IV01C0CX3F40', TDynSiteForm(msite).SiteContext, mBO);
                                      end;






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




{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'importXLS';
  mAction.Caption := 'Import XLS';
  mAction.Items.Add('Import (XLSX)');
  //mAction.Hint := 'Naklonuje skladovou kartu dle šablony z XLSX souboru';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CloneOrImportSwitch;
end;

procedure CloneOrImportSwitch(Sender: TComponent; Index: integer);
begin
  case Index of
    0: ImportXLS(Sender.Site);
  end;
end;


begin
end.