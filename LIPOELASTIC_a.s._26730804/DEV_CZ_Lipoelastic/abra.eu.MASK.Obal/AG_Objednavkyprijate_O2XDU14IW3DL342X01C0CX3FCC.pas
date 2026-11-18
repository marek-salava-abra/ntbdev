
var
     mBookmark : TBookmarkList;

procedure obalyVyber(Sender: TAction; Index: integer);
var
  mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');

    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if mBookmark.count=0 then begin

               DoplneniObalu(msite,index);








    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                          DoplneniObalu(msite,index);

         end;

    end;





end;




procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Doplnění obalů';
  mmAction.Hint := 'Stav objednávky';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Doplnění obalů');
  mMAction.Items.Add('Odstranění obalů');
  mmAction.OnExecute:= @obalyVyber;


   mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Převodka';
  mAction.Hint := 'Převodka';
  mAction.Category := 'tabList';
  mAction.OnExecute := @RowOperationOnPrijem;

end;



procedure DoplneniObalu(msite: TSiteForm;index:integer);
  var
  mbo,mRow, mNewRow, mStoreCard : TNxCustomBusinessObject;
  mRows, mCnts : TNxCustomBusinessMonikerCollection;
  i, ii,j : integer;
  mID_Storecards_ID:string;
  mr:TStringList;
  mList:TList;
  mObalList:TStringList;
  mfind:boolean;
  mpocet:double;
  mBustransaction_ID:string;
begin
  mbo:= TDynSiteForm(mSite).CurrentObject;
  mObalList:=tstringlist.create;
  //NxShowSimpleMessage(mbo.oid,nil);
       try
            mRows := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));

                                //   NxShowSimpleMessage(inttostr(mRows.Count),nil);




                                    for i:=0 to mRows.Count-1 do begin
                                        //NxShowSimpleMessage('Odmazáno',nil);
                                      if mRows.BusinessObject[i].GetFieldValueAsInteger('StoreCard_ID.Category')=4 then begin
                                          mRows.BusinessObject[i].MarkForDelete;
                                          //NxShowSimpleMessage('Odmazáno',nil);
                                      end else begin
                                          //NxShowSimpleMessage('Řádek ' + inttostr(i),nil);
                                                    mRow := mRows.BusinessObject[i];

                                                    if (mRow.GetFieldValueAsInteger('RowType') = 3) and not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreCard_ID')) and
                                                       not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreCard_ID.X_Krabicka_ID'))
                                                      // and ((mRow.GetFieldValueAsstring('Store_ID')='1120000101')   or  (mRow.GetFieldValueAsstring('Store_ID')='2G10000101')  )
                                                           then begin
                                                                    //NxShowSimpleMessage('skladová karta',nil);
                                                                    mr:=TStringList.create;
                                                                    mID_Storecards_ID:='';
                                                                    try
                                                                       msite.BaseObjectSpace.SQLSelect('select X_krabicka_id from Subscribers where StoreCard_ID=' +
                                                                       quotedstr(mRow.GetFieldValueAsString('StoreCard_ID'))  +
                                                                       ' and Firm_ID='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID')),mr);
                                                                             if mr.count>0 then begin
                                                                                  mID_Storecards_ID := mr.Strings[0];
                                                                                  //NxShowSimpleMessage('Krabička z adresaře',nil);
                                                                             end else begin
                                                                                  mID_Storecards_ID := mRow.GetFieldValueAsString('StoreCard_ID.X_Krabicka_ID');
                                                                                  //NxShowSimpleMessage('Krabička z SC',nil);
                                                                             end;

                                                                    finally
                                                                        mr.free;
                                                                    end;

                                                                   if mID_Storecards_ID<>'' then begin
                                                                        if mObalList.count>0 then begin
                                                                            mfind:=False;
                                                                            for ii:=0 to mObalList.count-1 do begin
                                                                                //NxShowSimpleMessage('Obal ' + copy(mObalList.Strings[ii],1,10) + ' - ' +mID_Storecards_ID,nil);
                                                                                if copy(mObalList.Strings[ii],1,10)=mID_Storecards_ID then begin

                                                                                      mpocet:=0;
                                                                                      mpocet:= NxIBStrToFloat(copy(mObalList.Strings[ii],11,15))+ (mRow.GetFieldValueAsFloat('Unitrate') * (mRow.GetFieldValueAsFloat('Quantity') * mRow.GetFieldValueAsFloat('Storecard_ID.X_Krabicka_pocet')));
                                                                                      mObalList.Strings[ii]:=(copy(mObalList.Strings[ii],1,10)  + NxFloatToIBStr(mpocet));
                                                                                      //NxShowSimpleMessage('Obal dohledán' + copy(mObalList.Strings[ii],1,10) + NxFloatToIBStr(mpocet),nil);
                                                                                      //mObalList.Delete(ii);
                                                                                      mfind:=true;
                                                                                end;

                                                                            end;
                                                                            if not mfind then begin
                                                                                mObalList.Add(mID_Storecards_ID+NxFloatToIBStr(mRow.GetFieldValueAsFloat('Unitrate') * (mRow.GetFieldValueAsFloat('Quantity') *
                                                                                mRow.GetFieldValueAsFloat('Storecard_ID.X_Krabicka_pocet'))));
                                                                                //NxShowSimpleMessage('Obal přidán - nenalezeno' + mID_Storecards_ID,nil);
                                                                               // NxShowSimpleMessage('Obal dohledán' + copy(mObalList.Strings[ii],1,10) + NxFloatToIBStr(mRow.GetFieldValueAsFloat('Quantity')),nil);
                                                                            end;

                                                                        end else begin
                                                                            mObalList.Add(mID_Storecards_ID+NxFloatToIBStr(mRow.GetFieldValueAsFloat('Unitrate') * (mRow.GetFieldValueAsFloat('Quantity') *
                                                                                mRow.GetFieldValueAsFloat('Storecard_ID.X_Krabicka_pocet'))));
                                                                            //NxShowSimpleMessage('Obal dohledán' + mID_Storecards_ID + NxFloatToIBStr(mRow.GetFieldValueAsFloat('Quantity')),nil);
                                                                        end;


                                                                    end;
                                                              end;
                                                    end;

                                                 // end;
                                               // end;
                                                mRows.free;

                                      end;

                                // NxShowSimpleMessage('počet obalu' + inttostr(mObalList.count),nil);
                                 if mObalList.count>0 then begin
                                     for j:=0 to mObalList.count-1 do begin
                                             mNewRow := mRows.AddNewObject;
                                              mNewRow.Assign(mRow);
                                              mNewRow.SetFieldValueAsInteger('Rowtype', 3);
                                              mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                                              mNewRow.SetFieldValueAsString('StoreCard_ID', copy(mObalList.Strings[j],1,10));
                                              mpocet:= NxIBStrToFloat(copy(mObalList.Strings[j],11,15));

                                              mNewRow.SetFieldValueAsFloat('Quantity', mpocet );
                                              mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));

                                                   mNewRow.SetFieldValueAsString('BusTransaction_id',mNewRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));

                                              mNewRow.SetFieldValueAsString('BusProject_ID', mRow.GetFieldValueAsString('BusProject_ID'));
                                              mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                              mNewRow.SetFieldValueAsFloat('Unitprice', 0);
                                              mNewRow.SetFieldValueAsFloat('TotalPrice', 0);
                                     end;

                                 end;




                     //  NxShowSimpleMessage(IntToStr(mObalList.count),nil);

       {   if false then begin
                if Assigned(mRows) and (mRows.Count >0 ) then begin
                                    for i := 0 to mRows.Count - 1 do begin

                                       //NxShowSimpleMessage('počet obalu' + inttostr(mObalList.count),nil);
                                      if mRows.BusinessObject[i].GetFieldValueAsInteger('StoreCard_ID.Category')=4 then begin
                                          mRows.BusinessObject[i].MarkForDelete;
                                          //NxShowSimpleMessage('Odmazáno',nil);
                                      end ;
                                     end;
                end;
          end;
                }


   finally
                                mbo.Save;
                                mbo.Refresh;
                                mObalList.free;
   end;
end;





procedure RowOperationOnPrijem(Sender: Tcomponent);
var
  xSite:TDynSiteForm;
  mList, mDocList, mErrList,mIDs_SP : tStringList;
  mZL : TNxCustomBusinessObject;
  mAmount, mDate : double;
  i,ii : integer;
  mOP_ID: string;
  mParams,mParamsDL, mP : TNxParameters;
  mPar : TNxParameter;


mManager,mManagerDL : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP : TNxCustomBusinessObject;
  mRows, mRowsDL,mRows_OP : TNxCustomBusinessMonikerCollection;
  mEAN,mOldEan:string;
  mPokracovani:Boolean;
  mstorecard_ID:string;
  mr:TStringList;
  mpocet,mpomoc_pocet:double;
  mSpotreba:boolean;
begin
    mspotreba:=false;
    xSite := TComponent(Sender).DynSite;
    if NxIsEmptyOID(TDynSiteForm(xSite).CurrentObject.GetFieldValueAsString('X_Cilovy_sklad')) then begin
         NxShowSimpleMessage('Objednávka není určena pro převod',nil);
    end else begin

                mManager := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','0P0I5SAOS3DL3ACU03KIU0CLP4');

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(TDynSiteForm(xSite).CurrentObject.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := 'QA10000101';
                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));
                  mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  for ii:=0 to mRows.Count-1 do begin
                      if mRows.BusinessObject[ii].GetFieldValueAsInteger('Storecard_id.Category')=4 then begin
                           mRows.BusinessObject[ii].MarkForDelete;
                           mspotreba:=true;

                      end;
                  end;
//                  xSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', xsite.SiteContext, mManager.OutputDocument);
                  mManager.OutputDocument.Save;
                  //Result := mManager.OutputDocument.OID;
                finally
                  mManager.Free;
                  //mOP.Free;
                  mParams.free;
                  //mList.Free;
                end;



               if mspotreba then begin
                            mManagerDL := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','050I5SAOS3DL3ACU03KIU0CLP4');

                            mParamsDL := TNxParameters.Create();
                            try
                              mManagerDL.AddInputDocument(TDynSiteForm(xSite).CurrentObject.OID);
                              mParamsdl.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := 'JA10000101';
                              mManagerDL.LoadParams(mParamsDL);
                              mManagerDL.Execute;
                              mManagerDL.OutputDocument.SetFieldValueAsString('Firm_ID',mManagerDL.InputDocument.GetFieldValueAsString('Firm_ID'));
                              mManagerDL.OutputDocument.SetFieldValueAsString('Description',mManagerDL.InputDocument.GetFieldValueAsString('Description'));
                              mRowsDL := mManagerDL.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManagerDL.OutputDocument.GetFieldCode('Rows'));
                              for ii:=0 to mRowsDL.Count-1 do begin
                                  if mRowsDL.BusinessObject[ii].GetFieldValueAsInteger('Storecard_id.Category')<>4 then begin
                                       mRowsDL.BusinessObject[ii].MarkForDelete;
                                  end;
                              end;
            //                  xSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', xsite.SiteContext, mManager.OutputDocument);
                              mManagerDL.OutputDocument.Save;
                              //Result := mManager.OutputDocument.OID;
                            finally
                              mManagerDL.Free;
                              mParamsDL.free;
                            end;
                end;
       end;
end;






begin
end.