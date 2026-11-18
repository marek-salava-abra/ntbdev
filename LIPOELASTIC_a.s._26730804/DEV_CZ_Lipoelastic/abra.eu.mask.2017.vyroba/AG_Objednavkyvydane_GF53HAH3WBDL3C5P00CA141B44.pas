var
xSite: TDynSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mOLE_SP, mRoll_SP, mOResult_SP: Variant;












procedure RowOperationOnPrijem(Sender: Tcomponent);
var
  mSite : TDynSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i : integer;
  mBO : TNxCustomBusinessObject;
  mMon,mrowsOutput,mrowsinput,mrowsOutput1,mrowsinput1,mrows: TNxCustomBusinessMonikerCollection;
  ii,jj:integer;
  mEAN,mOldEan:string;
  mPokracovani:Boolean;
  mstorecard_ID:string;
  mr:TStringList;
  mpocet,mpomoc_pocet:double;
  mManager,mManager1 : TNxDocumentImportManager ;
  mParams,mParams1, mP : TNxParameters;
  mPar : TNxParameter;
  mi:integer;
  mbo_PRV:TNxCustomBusinessObject;
  mid:string;
  mfind:Boolean;
begin
 mSite := TComponent(Sender).DynSite;


        mDBGrid := TMultiGrid(NxFindChildControl(msite.MainPanel, 'grdRows'));
  try
        mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'CDMK5QAWZZDL342X01C0CX3FCC','E03ZNUMDTCC4PDAUIEY1MBTJC0');
        try

                mParams := TNxParameters.Create();
                //mList := tStringlist.create;
                try
                  mManager.AddInputDocument(TDynSiteForm(mSite).CurrentObject.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '4910000101';;

                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));


                  //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
                  mRowsInput := mManager.inputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.inputDocument.GetFieldCode('Rows'));
                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  for ii:=0 to mRowsOutput.Count-1 do begin
                      //NxShowSimpleMessage(NxFloatToIBStr(mRowsinput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano')),nil);
                      //mfind:=false;
                      for jj:=0 to mRowsinput.Count-1 do begin
                            if mRowsOutput.BusinessObject[ii].getFieldValueAsString('Storecard_ID') = mrowsinput.BusinessObject[jj].getFieldValueAsString('Storecard_ID')  then begin

                                    mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsinput.BusinessObject[jj].getFieldValueAsFloat('X_vychystano'));

                                    mRowsOutput.BusinessObject[ii].SetFieldValueAsstring('BusOrder_id',mRowsinput.BusinessObject[jj].getFieldValueAsstring('BusOrder_id'));
                                    mRowsOutput.BusinessObject[ii].SetFieldValueAsstring('BusTransaction_ID',mRowsinput.BusinessObject[jj].getFieldValueAsstring('BusTransaction_ID'));
                                    mRowsOutput.BusinessObject[ii].SetFieldValueAsstring('BusProject_ID',mRowsinput.BusinessObject[jj].getFieldValueAsstring('BusProject_ID'));


                                    if mRowsoutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')=0 then begin
                                            mRowsoutput.BusinessObject[ii].MarkForDelete;
                                    end;//NxShowSimpleMessage(NxFloatToIBStr(mRowsinput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano')),nil);
                            end;
                      end;
                  end;

                  mManager.OutputDocument.Save;

                  //mid:=mManager.OutputDocument.oid;



                finally
                  mManager.Free;
                  //mOP.Free;
                  mParams.free;
                  //mList.Free;
                end;
         mSite.CurrentObject.Refresh;

                  mRows := mSite.CurrentObject.GetLoadedCollectionMonikerForFieldCode(mSite.CurrentObject.GetFieldCode('Rows'));

                  for jj:=0 to mRows.Count-1 do begin
                      mRows.BusinessObject[jj].setFieldValueAsFloat('X_vychystano',0);
                      //if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;
                    end;
                    //TDynSiteForm(mSite).CurrentObject.setFieldValueAsFloat('X_vychystano',0);
                    TDynSiteForm(mSite).CurrentObject.save;

      //            mbo.save;



  finally
      //mParams.free;
  end;
  finally
      //mManager.free;
  end;

TDynSiteForm(mSite).CurrentObject.Refresh;
mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
        if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;
end;




{

procedure RowOperationOnPrijem(Sender: Tcomponent);
var
  mSite : TDynSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i : integer;
  mBO : TNxCustomBusinessObject;
  mMon,mrowsOutput,mrowsinput,mrows: TNxCustomBusinessMonikerCollection;
  ii,jj:integer;
  mEAN,mOldEan:string;
  mPokracovani:Boolean;
  mstorecard_ID:string;
  mr:TStringList;
  mpocet,mpomoc_pocet:double;
  mManager : TNxDocumentImportManager ;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mi:integer;
begin
 mSite := TComponent(Sender).DynSite;


        mDBGrid := TMultiGrid(NxFindChildControl(msite.MainPanel, 'grdRows'));
  try



                mParams := TNxParameters.Create();
                //mList := tStringlist.create;
                try
                  mManager.AddInputDocument(TDynSiteForm(mSite).CurrentObject.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '4910000101';
                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));
                  mRowsInput := mManager.inputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.inputDocument.GetFieldCode('Rows'));
                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  for ii:=0 to mRowsOutput.Count-1 do begin
                      mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsinput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano'));
                      if mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')=0 then begin
                          mRowsOutput.BusinessObject[ii].MarkForDelete;
                      end;//NxShowSimpleMessage(NxFloatToIBStr(mRowsinput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano')),nil);
                  end;
                 mManager.OutputDocument.Save;

                  NxShowSimpleMessage('Byl vytvořen doklad' + mManager.OutputDocument.GetFieldValueAsString('Docqueue_id.Code') + '-' + inttostr(mManager.OutputDocument.GetFieldValueAsInteger('ordnumber')) + '/' + mManager.OutputDocument.GetFieldValueAsString('Period_id.Code') ,nil);






                finally
                  mManager.Free;
                  //mOP.Free;
                  mParams.free;
                  //mList.Free;
                end;
          mSite.CurrentObject.Refresh;
         mBO := mSite.CurrentObject;
                  mRows := MBO.GetLoadedCollectionMonikerForFieldCode(MBO.GetFieldCode('Rows'));
                  for ii:=0 to mRows.Count-1 do begin
                      mRows.BusinessObject[ii].setFieldValueAsFloat('X_vychystano',0);
                      if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;
                  end;
                  mbo.save;


  finally

  end;
 //mi:=mSite.BaseObjectSpace.SQLExecute('update IssuedOrders2 set X_vychystano=0 where id=' + quotedstr(msite.CurrentObject.oid));
 //TDynSiteForm(mSite).CurrentObject.Refresh;
if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;
end;










  }



procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction,mMAction1: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;


// if mUserFilter then begin
 { mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Vychystávání';
  mMAction.Hint := 'Vychystávání';
  mMAction.Category := 'tabList'; //jen na seznamu
  mMAction.OnExecuteItem := @SendSLExecuteItem;
  mMAction.Items.Add('Vychystávání dle dokladu s množstvím');
  mMAction.Items.Add('Vychystávání dle dokladu');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Vychystávání s konrolou';
  mMAction.Hint := 'Vychystávání';
  mMAction.Category := 'tabDetail'; //jen na seznamu
  mMAction.OnExecuteItem := @RowOperationOnExecute;
  mMAction.Items.Add('Ručně množství');
  mMAction.Items.Add('Jen čtečka');


         mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := 'Naskladnění';
        mAction.Hint := 'Naskladnění';
        mAction.Category := 'tabDetail';
        mAction.OnExecute := @RowOperationOnPrijem;
                                                     }


//end;


end;





procedure RowOperationOnExecute(Sender: Tcomponent; Index: integer);
var
  mSite: TDynSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i : integer;
  mBO : TNxCustomBusinessObject;
  mMon,mrows : TNxCustomBusinessMonikerCollection;
  ii:integer;
  mEAN,mOldEan:string;
  mPokracovani:Boolean;
  mstorecard_ID:string;
  mr:TStringList;
  mpocet,mpomoc_pocet,mvychystano:double;
  mfind:boolean;
begin
 mSite := TComponent(Sender).DynSite;



  try
        mBO := TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
        mPokracovani:=true;

        mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(NxFindSiteForm(Sender)).MainPanel, 'grdRows'));

            //mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;
                  mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                  mr:=TStringList.create;
                  try
                      msite.BaseObjectSpace.SQLSelect('select sum(X_vychystano) from issuedorders2 where parent_id=' + quotedstr(mbo.oid),mr);
                      if NxIBStrToFloat(mr.Strings[0])>0 then begin
                          NxShowSimpleMessage('Doklad je již vychystáván, ale nenaskladněn. Množství bude připočítáno k aktiálním stavům, nebo nejprve naskladněte',mSite);
                          if false then begin
                              for ii:=0 to mMon.Count-1 do begin             // smazání položek
                                  mMon.BusinessObject[ii].SetFieldValueAsFloat('X_vychystano',0);
                              end;
                          end;
                      end;
                  finally

                  end;

                  mvychystano:=0;
                  while mPokracovani do begin
                     mPokracovani:=InputQuery('Dohledání položky','EAN',mEAN);
                         mr:=TStringList.create;
                         try
                            mSite.BaseObjectSpace.SQLSelect('select su.Parent_ID from StoreEANs SE left join StoreUnits Su on su.id=se.Parent_ID where se.ean=' + quotedstr(mEAN),mr);
                            if mr.count>0 then begin
                               if mr.count=1 then begin
                                   mrows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                   mfind:=false;
                                   for ii:=0 to mRows.Count-1 do begin
                                          mpocet:=0;
                                          mpomoc_pocet:=0;
                                          if (mRows.BusinessObject[ii].getFieldValueAsString('Storecard_id')=mr.Strings[0]) and (mRows.BusinessObject[ii].GetFieldValueAsFloat('Quantity')<>mRows.BusinessObject[ii].GetFieldValueAsFloat('X_vychystano')) then begin
                                               mfind:=true;
                                               if ((mRows.BusinessObject[ii].GetFieldValueAsFloat('Quantity')-
                                                  mRows.BusinessObject[ii].GetFieldValueAsFloat('DeliveredQuantity'))>=mRows.BusinessObject[ii].GetFieldValueAsFloat('X_vychystano')) then begin

                                                     mpocet:=mRows.BusinessObject[ii].GetFieldValueAsFloat('X_vychystano');

                                                     if index=0 then begin
                                                             mpomoc_pocet:=NxIBStrToFloat(

                                                             InputBox('Zadej množství pro skladovou kartu' ,
                                                             mRows.BusinessObject[ii].getFieldValueAsString('Storecard_id.code')+ ' - ¨' + mRows.BusinessObject[ii].getFieldValueAsString('Storecard_id.name'),
                                                             '1'));
                                                             end else begin
                                                                 mpomoc_pocet:=1;
                                                             end;
                                                     mpocet:= mpocet+mpomoc_pocet;
                                                     if mpocet<=mRows.BusinessObject[ii].GetFieldValueAsFloat('Quantity')- mRows.BusinessObject[ii].GetFieldValueAsFloat('DeliveredQuantity') then begin
                                                        mRows.BusinessObject[ii].SetFieldValueAsFloat('X_vychystano',mpocet);
                                                        mRows.BusinessObject[ii].Save;
                                                      end else begin
                                                        NxShowSimpleMessage('Pro ean ' + mEAN + ' Překračujete povolený počet jednotek',nil);
                                                        exit;
                                                      end;
                                                     if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;
                                               end else begin
                                                    NxShowSimpleMessage('Pro ean ' + mEAN + ' Překračujete povolený počet jednotek',nil);
                                                        exit;

                                               end;
                                               mvychystano:=mvychystano+mpocet;
                                          end;
                                    end;
                                    if not mfind then begin
                                       NxShowSimpleMessage('Ean ' + mEAN + ' není použit v této objednávce ',nil);
                                       exit;
                                    end;
                               end else begin
                                   if (mEAN<>'') and (mr.count>0) then NxShowSimpleMessage('Pro ean ' + mEAN + ' je v systému více skladových karet',nil);
                                        exit;
                               end;
                             end else begin
                                if (mEAN<>'') and (mr.count=0) then NxShowSimpleMessage('Pro ean ' + mEAN + ' není v systému žádná skladová karta',nil);
                                    exit;
                             end;

                         finally
                            mr.free;
                         end;

                     mEAN:='';
                     mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
                  end;


                mbo.SetFieldValueAsFloat('X_vychystano',mvychystano);
                mbo.save;

                 mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);



        if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;


  finally

  end;



end;





begin
end.