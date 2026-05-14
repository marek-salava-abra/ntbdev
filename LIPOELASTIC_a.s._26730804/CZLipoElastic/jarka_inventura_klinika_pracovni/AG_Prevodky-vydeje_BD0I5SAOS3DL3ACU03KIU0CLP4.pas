  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head';


var
  mSite : TDynSiteForm;
  mfilter:string;
    mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder,mbustransaction,mbusproject,mbankacount: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;





 procedure Prevodka_prijem(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  self:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
 aString:string;
  mstring:string;
  ARequest:string;

  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mstore_id:string;
 x : TNxParameters;
  mImportMan : TNxDocumentImportManager ;
  mValidateList:tstringlist;
  mText:string;
begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin
                      mImportMan := NxCreateDocumentImportManager(msite.baseobjectspace, '0P0I5SAOS3DL3ACU03KIU0CLP4', '1D0I5SAOS3DL3ACU03KIU0CLP4');
                      mstore_id:='';
                      try
                              mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                              mIBookmark:=0;
                              if mBookmark.count>0 then begin
                                   mIBookmark:=mBookmark.count-1;
                                   ProgressInit(msite, 'Zpracování dat ' + '', 100);
                              end;

                              for mICount:=0 to mIBookmark do begin
                                  if mBookmark.count>0 then begin
                                       mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                       ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                  end;
                                  mImportMan.AddInputDocument(TDynSiteForm(msite).CurrentObject.oid);

                                 mr:=tstringlist.create;
                                  try
                                          msite.BaseObjectSpace.SQLSelect('Select X_Store_ID from FirmOffices where id=' + quotedstr(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('FirmOffice_ID')),mr);
                                          if mr.count>0 then begin
                                               mstore_id:=mr.Strings[0];
                                          end;
                                  finally
                                      mr.free;
                                  end;


                                if mstore_id='' then begin
                                  mr:=tstringlist.create;
                                  try
                                          msite.BaseObjectSpace.SQLSelect('Select id from Stores where X_Firm_ID=' + quotedstr(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID')),mr);
                                          if mr.count>0 then begin
                                               mstore_id:=mr.Strings[0];
                                          end else begin
                                             NxShowSimpleMessage('Pro uvedenou provozovnu , ani firmu není uveden sklad', nil);
                                             exit;
                                          end;
                                  finally
                                      mr.free;
                                  end;
                               end;

                              end;
                                    x := TNxParameters.Create;
                                          try
                                                         x.GetOrCreateParam(dtString, 'SelectedHeader', pkInput).AsString := TDynSiteForm(msite).CurrentObject.oid;
                                                        x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := 'VA10000101' ;
                                                        x.GetOrCreateParam(dtString, 'Store_ID', pkInput).AsString := mstore_id ;

                                                        mImportMan.LoadParams(x);
                                                          mImportMan.Execute;

                                                        //mImportMan.outputdocument.SetFieldValueAsString('DocQueue_ID','VA10000101');

                                                          mImportMan.outputdocument.ClearValidateErrors;
                                                               // if true then begin
                                                              if true then begin   //if Not mhead.Validate() then begin
                                                                    mList := TStringList.Create;
                                                                    try
                                                                       mImportMan.outputdocument.GetValidateErrors(mList);
                                                                       mText := mList.Text;
                                                                       NxToken(mText, '=');
                                                                       //MessageDlg('Automaticky vytvořenou převodku příjem nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                      // mtWarning, [mbOK], 0);
                                                                     finally
                                                                       mList.Free;
                                                                     end;
                                                                     TDynSiteForm(mSite).ShowDynFormWithNewDocument('BH0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mImportMan.outputdocument);
                                                                     //mhead.refresh;
                                                                    TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItemMode;
                                                              end else begin
                                                                   mImportMan.outputdocument.Save;
                                                                    //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                                    NxShowSimpleMessage('Převodka příjem ' + mImportMan.outputdocument.DisplayName + ' byla vytvořena',nil);
                                                              end;
                                                           finally
                                                               x.free;
                                                           end;

                       finally
                          mImportMan.free;
                       end;
                end;
            end;

                      if mBookmark.count>0 then  ProgressDispose()   ;
    end;
end;








  function mIportmanager(mSite:tdynsiteform;Self: TNxCustomBusinessObject;mDocQueue_ID:string;index:integer):string;
Var
mresult:Boolean;
mOP_ID: string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP ,mRowDocRowBatches: TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mRowsInput, mRowsOutput:TNxCustomBusinessMonikerCollection;
  mRowsInputBatch, mRowsOutputBatch:TNxCustomBusinessMonikerCollection;
  ii,jj,iib,jjb:integer;
  mmesage:string;
  mValidateList:tstringlist;
  mText:string;
begin

                mManager := NxCreateDocumentImportManager(self.ObjectSpace,'E03ZNUMDTCC4PDAUIEY1MBTJC0', '0P0I5SAOS3DL3ACU03KIU0CLP4');

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(self.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;


                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));



                  //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
                  //mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  //for ii:=0 to mRows.Count-1 do begin
                  //    mRows.BusinessObject[ii].SetFieldValueAsstring('Store_ID',0);
                  //end;


                  mRowsInput := mManager.InputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.InputDocument.GetFieldCode('Rows'));
                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));

                   for ii:=0 to mRowsOutput.Count-1 do begin
                                     for jj:=0 to mRowsinput.Count-1 do begin
                                          if mRowsOutput.BusinessObject[ii].getFieldValueAsString('Storecard_ID') = mrowsinput.BusinessObject[jj].getFieldValueAsString('Storecard_ID')  then begin



                                                 // ** šarže
                                                if mRowsOutput.BusinessObject[ii].getFieldValueAsinteger('Storecard_ID.Category')=2 then begin
                                                           mRowsInputBatch := mRowsInput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsInput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                           mRowsOutputBatch := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));

                                                          // for iib:=0 to mRowsOutputBatch.Count-1 do begin
                                                                  for jjb:=0 to mRowsInputBatch.Count-1 do begin
                                                                      // if mRowsOutputBatch.BusinessObject[iib].getFieldValueAsString('StoreBatch_ID') = mRowsInputBatch.BusinessObject[jjb].getFieldValueAsString('StoreBatch_ID')  then begin
                                                                            mRowDocRowBatches := mRowsOutputBatch.AddNewObject;
                                                                            mRowDocRowBatches.Prefill;
                                                                                mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',jjb);
                                                                                mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mRowsInputBatch.BusinessObject[jjb].getFieldValueAsString('StoreBatch_ID'));
                                                                                mRowDocRowBatches.SetFieldValueAsFloat('Quantity',mRowsInputBatch.BusinessObject[jjb].GetFieldValueAsFloat('quantity'));
                                                                      // end;
                                                                  end;
                                                           //end;

                                                            //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsinput.BusinessObject[jj].getFieldValueAsFloat('X_vychystano'));
                                                  end;




                                          end;
                                    end;
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

                                             TDynSiteForm(mSite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);    // ov

                                             result:='Chyba';
                                      end else begin
                                          mManager.OutputDocument.Save;
                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                      end;


                  result:= inttostr(mManager.OutputDocument.GetFieldValueAsInteger('Ordnumber'));



                 finally
                  mManager.Free;
                  mParams.free;
                 end;


end;








procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Vytvořit YPT';
  mMAction.Hint := 'Vytvořit YPT';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Vytvořit YPT');
  mMAction.OnExecuteItem := @Prevodka_prijem;

end;

begin
end.





