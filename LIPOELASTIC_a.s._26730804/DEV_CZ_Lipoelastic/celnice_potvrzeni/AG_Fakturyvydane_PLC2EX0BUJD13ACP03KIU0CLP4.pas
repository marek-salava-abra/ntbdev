uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'abra.eu.mask.Lipoelastic.Archiv.lib'
      ;

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
  mmAction.Caption := 'Celní deklarace';
  mmAction.Hint := 'Vytvoření dokladu zpětně';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Potvrzení vývozu');
  mMAction.Items.Add('Připojení souboru');
  mMAction.Items.Add('Vytvorení bez příloh');
  mmAction.OnExecuteItem:= @NewCLExecute;
end;



function NewCL(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;

  mText: string;
   mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mbo, mRow_OP, mOP : TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mmesage:string;
  mValidateList:tstringlist;

begin
  result := '';
  mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'O3BDOKTWEFD13ACM03KIU0CLP4','JYC4VDEUPYROX3UX1NTGF3AWT0');   // op to zl

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(abo.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '~000000203';
                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsDateTime('Docdate$date',mManager.InputDocument.GetFieldValueAsDateTime('Docdate$date'));
                  mManager.OutputDocument.SetFieldValueAsBoolean('VatDocument',false);
                  mManager.OutputDocument.SetFieldValueAsString('Period_ID',mManager.InputDocument.GetFieldValueAsString('Period_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Currency_ID',mManager.InputDocument.GetFieldValueAsString('Currency_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.DisplayName);




                  mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  for ii:=0 to mRows.Count-1 do begin
                      //mRows.BusinessObject[ii].SetFieldValueAsstring('VATRate_ID','~000000401');
                      mRows.BusinessObject[ii].SetFieldValueAsstring('VATIndex_ID','~000000401');
                      mRows.BusinessObject[ii].SetFieldValueAsstring('X_ProvideRow_ID',abo.OID);
                      mRows.BusinessObject[ii].SetFieldValueAsFloat('TAmount',mManager.InputDocument.GetFieldValueAsFloat('Amount'));
                      mRows.BusinessObject[ii].SetFieldValueAsFloat('LocalTAmount',mManager.InputDocument.GetFieldValueAsFloat('LocalAmount'));

                  end;

                            mManager.OutputDocument.ClearValidateErrors;
                                      if Not mManager.OutputDocument.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mManager.OutputDocument.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             //NxShowSimpleMessage('Chyba',nil);

                                             TDynSiteForm(mSite).ShowDynFormWithNewDocument('EKUC4KB103WOX4ING20T0JVIB4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // fv

                                             result:='Chyba';
                                      end else begin
                                          mManager.OutputDocument.Save;
                                          result:=mManager.OutputDocument.oid;
                                      end;

                 finally
                  mManager.Free;
                  mParams.free;
                 end;






end;

procedure NewCLExecute(Sender: TAction; Index: integer);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 mBookmark : TBookmarkList;
 i:integer;
begin
   //if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');


    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if Assigned(mSite.CurrentObject) then begin

              if mBookmark.count=0 then begin

                       CreateFile(mSite.CurrentObject,index,msite);

               end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    CreateFile(mSite.CurrentObject,index,msite);
                    end;
                   ProgressDispose()   ;
              end;






      end;
  NxShowSimpleMessage('Zpracování bylo dokončeno',nil);
end;


 Function ErrtElementString(mXMLHead : TNxScriptingXMLWrapper;mElement:string):boolean;
var
mstring:string;
begin
result:=true;
    try
          mstring:=mXMLHead.getElementAsString(mElement);
          result:=false;
    except
          result:=true;
    end;
end;



procedure CreateFile(mBO:TNxCustomBusinessObject;index:integer;mSite: TDynSiteForm);
var
  zadej:string;
  mfilename:string;
  mdir,mfile,mtargetdir,mtargetFile:string;
  mTargetObject:TNxCustomBusinessObject;
  mid:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mdate:double;
  mdatestring:string;
  mhelpfilename:string;
  I:integer;
  mstring:string;
begin

if index=0 then begin
                 PromptForFileName(mFileName, '*.XML', '', 'Soubor XML', '', False) ;
                 mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                        mFile:=copy(mfilename,4+NxCharPosR('\',mfilename),Length(mfilename));
                        mFile:=copy(mFile,1,(Length(mFile)-4));

                 mXMLHead := TNxScriptingXMLWrapper.Create;
                 try
                      mXMLHead.loadFromFile(mfilename);
                                      mid:=mbo.ObjectSpace.SQLSelectFirstAsString('SELECT R.Leftside_ID FROM Relations R WHERE (R.Rel_def = 1696) AND (R.Rightside_ID = ' + QuotedStr(mbo.OID)+')');

                                     if mid='' then begin
                                         mid := NewCL(mbo,msite);
                                     end ;

                                     if mid<>'' then begin
                                           mtargetObject:=mbo.ObjectSpace.CreateObject('JYC4VDEUPYROX3UX1NTGF3AWT0');
                                                 try
                                                    mtargetObject.Load(mid,nil);

                                             if not ErrtElementString(mXMLHead ,'XmlMessage.Data.CZ599A.H.H01') then begin
                                               mtargetObject.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('XmlMessage.Data.CZ599A.H.H01'));
                                               mdatestring:=mXMLHead.getElementAsString('XmlMessage.Data.CZ599A.H.QUZA01');
                                               mdate:=EncodeDate(strtoint(copy(mdatestring,1,4)),strtoint(copy(mdatestring,5,2)),strtoint(copy(mdatestring,7,2)));
                                               //NxShowSimpleMessage(NxFloatToIBStr(mdate),nil);
                                               mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                            end;

                                            if not ErrtElementString(mXMLHead ,'XmlMessage.Data.CZ599C.ExportOperation.MRN') then begin
                                               mtargetObject.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('XmlMessage.Data.CZ599C.ExportOperation.MRN'));
                                               mdatestring:=mXMLHead.getElementAsString('XmlMessage.Data.CZ599C.ExitControlResult.exitDate');
                                               mdate:=EncodeDate(strtoint(copy(mdatestring,1,4)),strtoint(copy(mdatestring,6,2)),strtoint(copy(mdatestring,9,2)));
                                               //NxShowSimpleMessage(NxFloatToIBStr(mdate),nil);
                                               mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                            end;

                                            if not ErrtElementString(mXMLHead ,'XmlMessage.Data.CZ628A.H.H01') then begin
                                               mtargetObject.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('XmlMessage.Data.CZ628A.H.H01'));
                                               //mdatestring:=mXMLHead.getElementAsString('XmlMessage.Data.CZ628C.ExportOperation.declarationAcceptanceDate');
                                               //mdate:=EncodeDate(strtoint(copy(mdatestring,1,4)),strtoint(copy(mdatestring,6,2)),strtoint(copy(mdatestring,9,2)));
                                               //NxShowSimpleMessage(NxFloatToIBStr(mdate),nil);
                                               ///mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                            end;

                                            if not ErrtElementString(mXMLHead ,'XmlMessage.Data.CZ628C.ExportOperation.MRN') then begin
                                               mtargetObject.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('XmlMessage.Data.CZ628C.ExportOperation.MRN'));
                                               mdatestring:=mXMLHead.getElementAsString('XmlMessage.Data.CZ628C.ExportOperation.declarationAcceptanceDate');
                                               mdate:=EncodeDate(strtoint(copy(mdatestring,1,4)),strtoint(copy(mdatestring,6,2)),strtoint(copy(mdatestring,9,2)));
                                               //NxShowSimpleMessage(NxFloatToIBStr(mdate),nil);
                                               mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                            end;


                                            if not ErrtElementString(mXMLHead ,'ExportOperation.MRN') then begin
                                               mtargetObject.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ExportOperation.MRN'));
                                               if not ErrtElementString(mXMLHead ,'ExitControlResult.exitDate') then begin
                                                     mdatestring:=mXMLHead.getElementAsString('ExitControlResult.exitDate');
                                                     mdate:=EncodeDate(strtoint(copy(mdatestring,1,4)),strtoint(copy(mdatestring,6,2)),strtoint(copy(mdatestring,9,2)));
                                                     //NxShowSimpleMessage(NxFloatToIBStr(mdate),nil);
                                                     mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                               end;
                                            end;


                                             if not ErrtElementString(mXMLHead ,'ExportOperation.MRN') then begin
                                               mtargetObject.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ExportOperation.MRN'));
                                               if not ErrtElementString(mXMLHead ,'ExitControlResult.exitDate') then begin
                                                     mdatestring:=mXMLHead.getElementAsString('ExitControlResult.exitDate');
                                                     mdate:=EncodeDate(strtoint(copy(mdatestring,1,4)),strtoint(copy(mdatestring,6,2)),strtoint(copy(mdatestring,9,2)));
                                                     //NxShowSimpleMessage(NxFloatToIBStr(mdate),nil);
                                                     mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                               end;
                                            end;









                                        //mdatestring:=mXMLHead.getElementAsString('XmlMessage.Data.CZ599C.ExportOperation.declarationAcceptanceDate');


                                        mtargetObject.save;
                                                         Create_folder(mtargetObject);

                                                          mtargetdir:=Format('%s\%s\%s', ['\\10.5.5.150\archiv', mtargetObject.GetFieldValueAsString('Period_id.code'),mtargetObject.GetFieldValueAsString('Docqueue_id.code')]);
                                                             mtargetFile:=Format('%s_%s_%s_%s', [inttostr(mtargetObject.GetFieldValueAsInteger('Ordnumber')),
                                                             mtargetObject.GetFieldValueAsString('Docqueue_id.code'),
                                                             mtargetObject.GetFieldValueAsString('Period_id.code'),
                                                             mtargetObject.GetFieldValueAsString('ExternalNumber')
                                                             ]);
                                                            mhelpfilename:='';
                                                            mhelpfilename:=copy(mfilename,1,Length(mfilename)-4);
                                                                          try
                                                                              if NxCopyFile(mhelpfilename+'.xml',mtargetdir+'\'+mtargetFile+'.xml') then begin
                                                                                    DeleteFile(mhelpfilename+'.xml');
                                                                              end;;
                                                                          finally

                                                                          end;



                                                                          try
                                                                              if NxCopyFile(mhelpfilename+'.htm',mtargetdir+'\'+mtargetFile+'.htm') then begin
                                                                                    DeleteFile(mhelpfilename+'.htm');
                                                                              end;
                                                                          finally
                                                                          end;


                                                                           try
                                                                             if (FileExists(mdir + 'VDD'+mfile+'.pdf')) then begin
                                                                                     if NxCopyFile(mdir + 'VDD'+mfile+'.pdf',mtargetdir+'\'+mtargetFile+'.pdf') then begin
                                                                                           DeleteFile(mdir + 'VDD'+mfile+'.pdf');
                                                                                     end;
                                                                             end else begin
                                                                                  NxShowSimpleMessage('Soubor PDF nebyl nalezen , prosím specifikujte.',nil);
                                                                                  PromptForFileName(mFileName, '*.pdf', mdir, 'Soubor PDF', '', False) ;
                                                                                  if NxCopyFile(mFileName,mtargetdir+'\'+mtargetFile+'.pdf') then begin
                                                                                           DeleteFile(mFileName);
                                                                                  end;
                                                                             end;

                                                                          finally

                                                                          end;


                                                         //NxShowSimpleMessage('doklad ' + mTargetObject.DisplayName + ' - ze souboru ' +  mfilename  + ' na ' + mtargetdir + '\' + mtargetFile,nil);
                                                 finally

                                                 end;


                                     end;




                      finally
                          mXMLHead.free;
              end;
        end;
              if index=1 then begin
                      mid:=mbo.ObjectSpace.SQLSelectFirstAsString('SELECT R.Leftside_ID FROM Relations R WHERE (R.Rel_def = 1696) AND (R.Rightside_ID = ' + QuotedStr(mbo.OID)+')');

                                     if mid='' then begin
                                         mid := NewCL(mbo,msite);
                                     end ;

                                     if mid<>'' then begin
                                           mtargetObject:=mbo.ObjectSpace.CreateObject('JYC4VDEUPYROX3UX1NTGF3AWT0');
                                                 try
                                                    mtargetObject.Load(mid,nil);




                                                      Create_folder(mtargetObject);



                                                       PromptForFileName(mFileName, '*.*', mdir, 'Soubor *', '', False) ;
                                                           mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                                                           mFile:=copy(mfilename,4+NxCharPosR('\',mfilename),Length(mfilename));
                                                           mFile:=copy(mFile,1,(Length(mFile)-4));

                                                          mtargetdir:=Format('%s\%s\%s', ['\\10.5.5.150\archiv', mtargetObject.GetFieldValueAsString('Period_id.code'),mtargetObject.GetFieldValueAsString('Docqueue_id.code')]);
                                                             mtargetFile:=Format('%s_%s_%s_%s', [inttostr(mtargetObject.GetFieldValueAsInteger('Ordnumber')),
                                                             mtargetObject.GetFieldValueAsString('Docqueue_id.code'),
                                                             mtargetObject.GetFieldValueAsString('Period_id.code'),
                                                             mtargetObject.GetFieldValueAsString('ExternalNumber')
                                                             ]);

                                                      // NxShowSimpleMessage(mtargetdir+'\'+mtargetFile + RightStr(mFileName,4),nil);


                                                       if not FileExists(mtargetdir+'\'+mtargetFile + RightStr(mFileName,4)) then begin
                                                          //NxShowSimpleMessage('Neexistuje',nil);
                                                                                  if NxCopyFile(mFileName,(mtargetdir+'\'+mtargetFile + RightStr(mFileName,4))) then begin
                                                                                           DeleteFile(mFileName);
                                                                                  end;


                                                       end else begin


                                                              I:=1;
                                                               mhelpfilename:= mtargetdir+'\'+mtargetFile +'_'+IntToStr(I) + RightStr(mFileName,4);
                                                               while FileExists(mtargetdir+'\'+mtargetFile +'_'+IntToStr(I) + RightStr(mFileName,4)) do begin
                                                                      mhelpfilename:= mtargetdir+'\'+mtargetFile +'_'+IntToStr(I+1) + RightStr(mFileName,4);
                                                                   I:=I+1;
                                                               end;
                                                               //NxShowSimpleMessage('mhelpfilename',nil);
                                                               if NxCopyFile(mFileName,mhelpfilename) then begin
                                                                                           DeleteFile(mFileName);
                                                                end;



                                                       end;
                                                   finally
                                                       mtargetObject.free;
                                                   end;
                                     end;
             end;









             if index=2 then begin
                                      mid:=mbo.ObjectSpace.SQLSelectFirstAsString('SELECT R.Leftside_ID FROM Relations R WHERE (R.Rel_def = 1696) AND (R.Rightside_ID = ' + QuotedStr(mbo.OID)+')');

                                     if mid='' then begin
                                         mid := NewCL(mbo,msite);
                                     end ;

                                     if mid<>'' then begin
                                           mtargetObject:=mbo.ObjectSpace.CreateObject('JYC4VDEUPYROX3UX1NTGF3AWT0');
                                                 try
                                                    mtargetObject.Load(mid,nil);
                                                       mstring:='';
                                                       mstring:=InputBox('Zadej číslo', 'MR:','');
                                                             mtargetObject.SetFieldValueAsString('ExternalNumber',mstring);
                                                             mdate:=0;
                                                             mdate:=GetDate(mSite);
                                                             mtargetObject.SetFieldValueAsDateTime('X_Datum_vyvozu',mdate); ;
                                                    mtargetObject.save;


                                                         //NxShowSimpleMessage('doklad ' + mTargetObject.DisplayName + ' - ze souboru ' +  mfilename  + ' na ' + mtargetdir + '\' + mtargetFile,nil);
                                                 finally
                                                       mtargetObject.free;
                                                 end;


                                     end;





              end;

end;




function GetDate(xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum servisu';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Zadej datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;


begin
end.