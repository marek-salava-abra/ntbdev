uses 'eu.abra.mavy.libs.progress';

procedure ImportXLSX(Sender: TComponent);
var
  mOS: TNxCustomObjectSpace;
  mOpenDialog: TOpenDialog;
  mExcel, mXLS, objWorkbook: variant;
  i,iXLS_Row,iXLS_Columns : integer;
  mBO, mBONewHelp,mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mErrors : TStringList;
  mSite: TSiteForm;
  mExcelFileName, : string;
  mBegin ,mEnd:integer;
  mPrice: Extended;
  mTable,mCLSID:string;
  mFields,mtables,mCLSIDs,mWheres,mHiddens,mTypes,mLenghs,mcreates:tstringlist;
  mID:string;
  mR:Tstringlist;
  mSave:boolean;
  mLengh:Integer;
  mx:tstringlist;
  mXID:string;
  mParentStoreAssortmentGroups:string;
  Isaved, Icreated:integer;
  mcreated:boolean;
  mHelpBoolean:boolean;
begin
  mSite := Sender.Site;
  mOS:= Sender.Site.BaseObjectSpace;
  mcreated:=false;
  try
  mOpenDialog := TOpenDialog.Create(mSite);

  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
    exit;
  end;
  mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
  //mOpenDialog.Options := [ofAllowMultiSelect];
  mErrors:= TStringList.Create;
    if mOpenDialog.Execute then begin
                try
                  mExcelFileName := mOpenDialog.FileName;
                  objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
                  mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
                  isaved:=0;
                  icreated:=0;
                  mtable:=VarTostr(mXLS.Cells[1,4]);
                  mCLSID:=VarTostr(mXLS.Cells[1,6]);

                  mBegin:=StrToInt(VarTostr(mXLS.Cells[1,10]));
                  mEnd:=StrToInt(VarTostr(mXLS.Cells[1,12]));

                  mFields:=TStringList.create;
                  mtables:=TStringList.create;
                  mCLSIDs:=TStringList.create;
                  mWheres:=TStringList.create;
                  mHiddens:=TStringList.create;
                  mTypes:=TStringList.create;
                  mLenghs:=TStringList.create;
                  mcreates:=TStringList.create;

                   for iXLS_Columns:= 10 to mXLS.UsedRange.Columns.Count do begin
                                   if trim(VarToStr(mXLS.Cells[3,iXLS_Columns]))<>'' then begin
                                         mFields.add(trim(VarToStr(mXLS.Cells[3,iXLS_Columns])));
                                          mtables.add(trim(VarToStr(mXLS.Cells[4,iXLS_Columns])));
                                          mCLSIDs.add(trim(VarToStr(mXLS.Cells[5,iXLS_Columns])));
                                          mWheres.add(trim(VarToStr(mXLS.Cells[6,iXLS_Columns])));
                                          mHiddens.add(trim(VarToStr(mXLS.Cells[7,iXLS_Columns])));
                                          mTypes.add(trim(VarToStr(mXLS.Cells[8,iXLS_Columns])));
                                          mLenghs.add(trim(VarToStr(mXLS.Cells[9,iXLS_Columns])));
                                          mcreates.add(trim(VarToStr(mXLS.Cells[10,iXLS_Columns])));
                                   end;
                   end;


                // NxShowSimpleMessage(inttostr(mFields.count),nil);

                  ProgressInit(mSite, 'Import položek', mXLS.UsedRange.Rows.Count);

                  mBO:= mOS.CreateObject(mCLSID);
            //      try


                            for iXLS_Row:= mBegin to mEnd do begin // mXLS.UsedRange.Rows.Count do begin
                                     msave:=false;
                          // ***** dohledání položky
                                        mid:='';
                                        if (mid='') and  (trim(VarToStr(mXLS.Cells[iXLS_Row,2]))<>'') then begin
                                           mr:=tstringlist.create;
                                                   try
                                                   mOS.SQLSelect('Select id from ' + mtable + ' where (' + trim(VarToStr(mXLS.Cells[3,2])) + '= ' + quotedstr(VarToStr(mXLS.Cells[iXLS_Row,2])) + ') and (hidden=' + quotedstr('N') + ')',mr);
                                                           if mr.count=1 then begin
                                                                   mid:=mr.Strings[0];
                                                           end;
                                                   finally
                                                       mr.free;
                                                   end;
                                        end;

                                        if (mid='') and  (trim(VarToStr(mXLS.Cells[iXLS_Row,4]))<>'') then begin
                                           mr:=tstringlist.create;
                                                   try
                                                   mOS.SQLSelect('Select id from ' + mtable + ' where (' + trim(VarToStr(mXLS.Cells[3,4])) + '= ' + quotedstr(VarToStr(mXLS.Cells[iXLS_Row,4])) + ') and (hidden=' + quotedstr('N') + ')',mr);
                                                           if mr.count=1 then begin
                                                                   mid:=mr.Strings[0];
                                                           end;
                                                   finally
                                                       mr.free;
                                                   end;
                                        end;

                                        if (mid='') and  (trim(VarToStr(mXLS.Cells[iXLS_Row,5]))<>'') then begin
                                           mr:=tstringlist.create;
                                                   try
                                                   mOS.SQLSelect('Select id from ' + mtable + ' where (' + trim(VarToStr(mXLS.Cells[3,5])) + '= ' + quotedstr(VarToStr(mXLS.Cells[iXLS_Row,5])) + ') and (hidden=' + quotedstr('N') + ')',mr);
                                                           if mr.count=1 then begin
                                                                   mid:=mr.Strings[0];
                                                           end;
                                                   finally
                                                       mr.free;
                                                   end;
                                        end;

                                         //  NxShowSimpleMessage(mid + ' / ' + IntToStr(mXLS.UsedRange.Columns.Count ) + ' / ' +  IntToStr(mFields.Count),nil);


                                           // *** založení neba načtení položky ***
                                                     if mid='' then begin
                                                             mBO.New;
                                                             mBO.Prefill;
                                                             mSave:=true;
                                                             icreated :=icreated +1;
                                                             mcreated:=true;
                                                     end else begin
                                                             mbo.load(mid,nil);
                                                             mSave:=True;
                                                             mcreated:=false;
                                                     end;

                                                     mParentStoreAssortmentGroups:='';
                                                     mParentStoreAssortmentGroups:=mbo.GetFieldValueAsString('X_StoreAssortmentGroup_ID');



                                            iXLS_Columns:=0;
                                            for iXLS_Columns:= 0 to mFields.Count-1 do begin        // sloupce
                                                              if copy(mTypes.Strings[iXLS_Columns],1,1)='S' then begin
                                                                 if VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])<>'' then begin
                                                              //      NxShowSimpleMessage(QuotedStr(mFields.Strings[iXLS_Columns]) + ' / ' + quotedstr(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))),nil);

                                                                    if trim(mtables.Strings[iXLS_Columns])<>'' then begin
                                                                       if VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])<>'' then begin
                                                                                    mx:=tstringlist.create;
                                                                                    try
                                                                                        mXID:='';
                                                                                        if UpperCase(trim(mtables.Strings[iXLS_Columns]))='DEFROLLDATA' then begin
                                                                                              mos.SQLSelect('select id from ' + mtables.Strings[iXLS_Columns] + ' where (CLSID=' + quotedstr(mCLSIDs.Strings[iXLS_Columns]) +
                                                                                                            ') AND ((X_StoreAssortmentGroup_ID=' + quotedstr(mParentStoreAssortmentGroups) + ') or (X_StoreAssortmentGroup_ID is null)) ' +
                                                                                                            ' and (X_NewFilterParam=' + quotedstr('A') + ')'+
                                                                                                            ' and ('+ mWheres.Strings[iXLS_Columns]  + ' = ' +quotedstr(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))+') order by X_StoreAssortmentGroup_ID desc'
                                                                                                            ,mx);


                                                                                        end else begin
                                                                                                mos.SQLSelect('select id from ' + mtables.Strings[iXLS_Columns] + ' where ' + mWheres.Strings[iXLS_Columns]  + ' = ' +quotedstr(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])) ,mx);
                                                                                        end;

                                                                                      //  msave:=InputQuery('aa','',
                                                                                      //      'select id from ' + mtables.Strings[iXLS_Columns] + ' where (CLSID=' + quotedstr(mCLSIDs.Strings[iXLS_Columns]) +
                                                                                      //                      ') AND ((X_StoreAssortmentGroup_ID=' + quotedstr(mParentStoreAssortmentGroups) + ') or (X_StoreAssortmentGroup_ID is null)) ' +
                                                                                      //                      ' and (X_NewFilterParam=' + quotedstr('A') + ')'+
                                                                                      //                      ' and ('+ mWheres.Strings[iXLS_Columns]  + ' = ' +quotedstr(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))+')'
                                                                                      //
                                                                                      //                      );


                                                                                        if mx.count>0 then begin

                                                                                              mxid:=mx.Strings[0];
                                                                                               //NxShowSimpleMessage('select id from ' + mtables.Strings[iXLS_Columns] + ' where ' + mWheres.Strings[iXLS_Columns]  + '=' +quotedstr(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))
                                                                                               //,nil);
                //                                                                            mxid:=mOS.SQLSelectFirstAsString('select id from ' + mtables.Strings[iXLS_Columns] + ' where ' + mWheres.Strings[iXLS_Columns]  + ' = ' +quotedstr(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])) );
                                                                                            //NxShowSimpleMessage(mxid,nil);

                                                                                            if mBO.getFieldValueAsString(mFields.Strings[iXLS_Columns])<> mxid then begin
                                                                                                  mBO.SetFieldValueAsString(mFields.Strings[iXLS_Columns] ,mxid);
                                                                                                  msave:=True;
                                                                                            end;
                                                                                         end else begin
                                                                                            if UpperCase(trim(mcreates.Strings[iXLS_Columns]))='A' then begin
                                                                                                    mBONewHelp:= mOS.CreateObject(mCLSIDs.Strings[iXLS_Columns]);
                                                                                                    try
                                                                                                       mBONewHelp.new;
                                                                                                       mBONewHelp.prefill;
                                                                                                       mBONewHelp.SetFieldValueAsString('Code',VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]));
                                                                                                       mBONewHelp.SetFieldValueAsString('Name',VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]));
                                                                                                        mBONewHelp.SetFieldValueAsBoolean('X_NewFilterParam',True);
                                                                                                         mBONewHelp.SetFieldValueAsString('X_StoreAssortmentGroup_ID',mParentStoreAssortmentGroups);
                                                                                                       mBONewHelp.SetFieldValueAsString(mFields.Strings[iXLS_Columns] ,VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]));
                                                                                                       mBONewHelp.save;
                                                                                                       mBO.SetFieldValueAsString(mFields.Strings[iXLS_Columns] ,mBONewHelp.oid);
                                                                                                       mSave:=true;
                                                                                                    finally
                                                                                                       mBONewHelp.free;
                                                                                                    end;
                                                                                             end;
                                                                                         end;
                                                                                   finally
                                                                                       mx.free;
                                                                                   end;
                                                                      end;
                                                                    end else begin





                                                                                  if StrToInt(mLenghs.Strings[iXLS_Columns])>0 then begin
                                                                                      mLengh:=0;
                                                                                       mLengh:=StrToInt(mLenghs.Strings[iXLS_Columns]);
                                                                                       if mBO.getFieldValueAsString(mFields.Strings[iXLS_Columns]) <>
                                                                                         (trim(copy(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]),1,mLengh))) then begin
                                                                                               mBO.SetFieldValueAsString(mFields.Strings[iXLS_Columns] ,
                                                                                                 (trim(copy(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]),1,mLengh))));
                                                                                                 msave:=True;
                                                                                       end;
                                                                                  end else begin
                                                                                      if mBO.getFieldValueAsString(mFields.Strings[iXLS_Columns]) <> quotedstr(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) then begin
                                                                                               //NxShowSimpleMessage(QuotedStr(mFields.Strings[iXLS_Columns])+'   ' +  quotedstr(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])),nil);
                                                                                               mBO.SetFieldValueAsString(mFields.Strings[iXLS_Columns] , (VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])) );
                                                                                               msave:=True;
                                                                                      end;
                                                                                  end;
                                                                    end;
                                                                 end;
                                                              end;







                                                       if trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))<>'' then begin
                                                              if copy(mTypes.Strings[iXLS_Columns],1,1)='B' then begin
                                                                    mHelpBoolean:=false;
                                                                    if (UpperCase(copy(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])),1,1))='A') or (UpperCase(copy(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])),1,1))='Y') or (UpperCase(copy(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])),1,1))='T') then begin
                                                                         mHelpBoolean:=true;
                                                                    end else begin
                                                                         mHelpBoolean:=false;
                                                                    end;
                                                                    //NxShowSimpleMessage(mFields.Strings[iXLS_Columns] + ' /' + NxBoolToString(mHelpBoolean),nil);
                                                                    if mBO.GetFieldValueAsBoolean(mFields.Strings[iXLS_Columns]) <> mHelpBoolean then begin
                                                                             mBO.SetFieldValueAsBoolean(mFields.Strings[iXLS_Columns] , mHelpBoolean );
                                                                             msave:=True;
                                                                    end;
                                                              end;

                                                              if copy(mTypes.Strings[iXLS_Columns],1,1)='F' then begin
                                                                    if NxIsValidFloat(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])),(-1)) then begin
                                                                          if mBO.GetFieldValueAsFloat(mFields.Strings[iXLS_Columns]) <> NxIBStrToFloat(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) then begin
                                                                                   mBO.SetFieldValueAsFloat(mFields.Strings[iXLS_Columns] , NxIBStrToFloat(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) );
                                                                                   msave:=True;
                                                                          end;
                                                                    end;
                                                              end;

                                                              if copy(mTypes.Strings[iXLS_Columns],1,1)='D' then begin
                                                                    if NxIsValidFloat(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)])),(-1)) then begin
                                                                          if mBO.GetFieldValueAsDateTime(mFields.Strings[iXLS_Columns]) <> NxIBStrToFloat(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) then begin
                                                                                   mBO.SetFieldValueAsDateTime(QuotedStr(mFields.Strings[iXLS_Columns]) , NxIBStrToFloat(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) );
                                                                                   msave:=True;
                                                                          end;
                                                                    end;
                                                              end;

                                                              if copy(mTypes.Strings[iXLS_Columns],1,1)='I' then begin
                                                                    if NxIsNumeric(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) then begin
                                                                        if mBO.GetFieldValueAsInteger(mFields.Strings[iXLS_Columns]) <> StrToInt(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) then begin
                                                                                 mBO.SetFieldValueAsInteger(mFields.Strings[iXLS_Columns] , StrToInt(trim(VarToStr(mXLS.Cells[iXLS_Row,(iXLS_Columns+10)]))) );
                                                                                 msave:=True;
                                                                        end;
                                                                    end;
                                                              end;
                                                       end;

                                            end;                       // konec sloupce

                                    ProgressSetPos(iXLS_Row);

                                    if msave then begin
                                        //NxShowSimpleMessage('Uloženo',nil);
                                        if not mcreated then begin
                                              //mbo.SetFieldValueAsBoolean('X_aktivni',true);
                                              mbo.Save;
                                             isaved:=isaved + 1;
                                             msave:=false;
                                        end;


                                    end;

                            end;    // konec řádku
                  finally
                        mBO.Free;
                  end;
             ProgressDispose();
             NxShowSimpleMessage(' Pozměněno ' + inttostr(isaved) + 'záznamu ,  z toho ' + inttostr(Icreated)  + ' nových',nil);
//             except
                                        //mErrors.Add(ExceptionMessage);


//             end;











      end else begin
      ShowMessage('Nebyl vybrán žádný soubor, import bude ukončen.');
      Exit;
    end;
    //ProgressDispose();
    if mErrors.Count > 0 then begin
      //Log(#13#10+'Chyby: '+#13#10+mErrors.Text);
      NxMessageBox('Upozornění', 'Při importu došlo k chybám, položky nebyly uložen', mdWarning, mdbOk, 0, 0, false, mSite);
      NxShowEditorSite(mSite.SiteContext, mErrors.Text, true);
    end else begin
      NxMessageBox('Informace', 'Import byl dokončen', mdInformation, mdbOk, 0, 0, false, mSite);
      //TDynSiteForm(mSite).RefreshData;
    end;
  finally
    mErrors.Free;
    mOpenDialog.free;
    //objWorkbook.free;
    //mxls.free;
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import (XLSX)';
  mAction.Items.Add('Import (XLSX)');
  //mAction.Items.Add('EKO-KOM - Obaly');
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXLSX;
end;


begin
end.