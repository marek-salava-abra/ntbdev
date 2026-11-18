uses 'abra.eu.mask.Lipo.inventura_import.Rows_RO',
     'abra.eu.mask.Lipo.inventura_import.fce'
;

const
    mFilter='*.xml';
//    mSQL='select sb.id|| CAST(sb2.quantity AS VARCHAR(10)) from storecards sc ' +
//         ' join storebatches sb on sb.storecard_id=sc.id ' +
//         ' join storesubbatches sb2 on ((sb2.StoreCard_ID=sc.id) and (sb2.store_id=''%s'')) ' +
//         ' where (sc.id=''%s'') and (sb2.store_id=''%s'') and (sb2.quantity>0) order by sb2.quantity desc' ;


mSQL='SELECT sb.StoreBatch_ID,sb.quantity FROM STORESUBBATCHES SB JOIN STOREBATCHES B ON SB.STOREBATCH_ID = B.ID ' +
     ' WHERE (SB.Store_ID =''%s'') AND (SB.Quantity>0) ' +
     ' AND (B.StoreCard_ID = ''%s'' ) ORDER BY B.ExpirationDate$Date ';





procedure FormCreate_Hook(Self: TSiteForm);
var
mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  mAct: TBasicAction;
  i:integer;

begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Korekce šarží';
          mMAction.Caption := 'Korekce šarží ';
          mMAction.Items.Add('Doplnění šarží');
          mMAction.Items.Add('Korekce po odmazání');
          mMAction.Items.Add('Problémové šarže');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @OnExec;


end;



procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
  mMonikerRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  mBO_Head,mBO_Row,mBO_Batch:TNxCustomBusinessObject;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  iRows,iBatches:integer;
  mNeedQtyRow,mNeedQtyBatch,mStoreQty,mQuantity:double;
  mHelpQtyRow,mHelpQtyBatch:double;
  mResults:tstringlist;
  mexist:double;
  mSite: TSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
   mDL: TNxCustomBusinessObject;
  ii,mIDataset, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  mpocet:integer;
  mDatasetList:tstringlist;
  mFindRow,mFindBatch:Boolean;
  mChyba:integer;
  mString:string;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
 mControl:= mSite.FindChildControl('tabRows.grdRows');
 mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
 mBO_Head := TDynSiteForm(mSite).CurrentObject;
 mDatasetList:=tstringlist.create;
    try
      if not Assigned(mBO_Head) then begin

      end;


      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce korekce je přístupná jen v editaci dokladu.');
        Exit;
      end else begin


              if index=1 then begin
                        mDatasetList:=tstringlist.create;
                              if mDataSet.Active then begin
                                          mDataSet.First;
                                          while not mDataSet.Eof do begin
                                              //NxShowSimpleMessage(mDataSet.FieldByName('Storecard_ID').Asstring + inttostr(mDataSet.FieldByName('PosIndex').AsInteger),nil);
                                              mstring:=mDataSet.FieldByName('Storecard_ID').Asstring + inttostr(mDataSet.FieldByName('PosIndex').AsInteger)   ;
                                              mDatasetList.add(mString);
                                              mstring:='';
                                              mpocet:=mpocet+1;
                                              mDataSet.Next;
                                          end;
                              end;
               end;

              mMonikerRows := mBO_Head.GetLoadedCollectionMonikerForFieldCode(mBO_Head.GetFieldCode('ROWS'));
                  for iRows:= 0 to mMonikerRows.count -1 do begin
                      mFindRow:=false;
                      if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('RowType')=3) then begin
                              mNeedQtyRow:=0;
                              mNeedQtyRow:=mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('Quantity')  ;

                              if index=2 then begin     // kontrola stavu na skladové karty
                                     mr:=tstringlist.create;
                                     try
                                            msite.baseobjectspace.SQLSelect('Select sum(Quantity) from StoreSubCards where StoreCard_ID=' + quotedstr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID'))
                                                                            + ' and Store_ID=' + quotedstr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID')) ,mr);
                                            if mr.count>0 then begin
                                                  mStoreQty:=NxIBStrToFloat(mr.Strings[0]);
                                            end;
                                            if mStoreQty<(mNeedQtyRow) then begin
                                                  NxShowSimpleMessage('Nedostatečné množství na skladové kartě' , nil);
                                                  NxShowSimpleMessage('Nedostatečné množství na skladové kartě ' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID.displayname') + ' (' + NxFloatToIBStr(mNeedQtyRow) + ') z (' + NxFloatToIBStr(mStoreQty) +')',nil);
                                            end;
                                            mStoreQty:=0;
                                     finally
                                          mr.free;
                                     end;

                              end;

                              if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin
                                     mNeedQtyBatch:=0;
                                     mNeedQtyBatch:=mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('Quantity')  ;
                                     mMonBatches:=mMonikerRows.BusinessObject[iRows].GetLoadedCollectionMonikerForFieldCode(mMonikerRows.BusinessObject[iRows].GetFieldCode('DocRowBatches'));
                                            mFindBatch:=false;

                                            mHelpQtyBatch:=0;
                                            for iBatches:= 0 to mMonBatches.count -1 do begin  // kontrola stavu na šarži
                                                mHelpQtyBatch:= mHelpQtyBatch+mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity');
                                                if index=2 then begin
                                                      mResults:=TStringList.Create;
                                                      try
                                                           msite.baseobjectspace.SQLSelect('Select sum(Quantity) from StoreSubBatches where StoreBatch_ID=' + quotedstr(mMonBatches.BusinessObject[iBatches].GetFieldValueAsString('StoreBatch_ID'))
                                                                            + ' and Store_ID=' + quotedstr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID')) ,mResults);
                                                           if mResults.Count>0 then begin
                                                               mStoreQty:=NxIBStrToFloat(mResults.Strings[0]);
                                                               if mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity')>mStoreQty then begin
                                                                   NxShowSimpleMessage('', nil);
                                                                   NxShowSimpleMessage('Nedostatečné množství na šarži ' + mMonBatches.BusinessObject[iBatches].GetFieldValueAsString('Name') + ' (' + NxFloatToIBStr(mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity')) + ') z (' + NxFloatToIBStr(mStoreQty) +')',nil);
                                                               end;
                                                           end;

                                                      finally
                                                          mResults.free;
                                                      end;
                                                end;

                                            end;

                                              //NxShowSimpleMessage(NxFloatToIBStr(mNeedQtyBatch) + ' - ' + NxFloatToIBStr(mHelpQtyBatch),nil);
                                                if (mNeedQtyBatch<>mHelpQtyBatch) or (mNeedQtyBatch=0) then begin
                                                    if index=0 then begin
                                                                 mNeedQtyBatch:=mNeedQtyBatch-mHelpQtyBatch;
                                                                 mResults:=TStringList.Create;
                                                                 try
                                                                        msite.baseobjectspace.SQLSelect(Format(mSQL,[mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID'),mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID')]),mResults);
                                                                     for i:= 0 to mResults.Count-1 do begin
                                                                          if NxIBStrToFloat(copy(mResults.Strings[i],12,5))>0 then begin
                                                                                    //NxShowSimpleMessage(mResults.Strings[i],nil);
                                                                                    mBO_Batch:=mMonikerRows.BusinessObject[iRows].GetLoadedCollectionMonikerForFieldCode(mMonikerRows.BusinessObject[iRows].GetFieldCode('DocRowBatches')).AddNewObject;
                                                                                    mBO_Batch.SetFieldValueAsString('StoreBatch_ID',copy(mResults.Strings[i],1,10)); //ID šarže
                                                                                    mQuantity:=0;
                                                                                    mQuantity:=NxIBStrToFloat(copy(mResults.Strings[i],12,5)); //množství na šarži
                                                                                    if mQuantity >= mNeedQtyBatch then begin
                                                                                      mBO_Batch.SetFieldValueAsFloat('Quantity',mNeedQtyBatch);
                                                                                      mNeedQtyBatch := 0;
                                                                                    end else begin
                                                                                      mBO_Batch.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                      mNeedQtyBatch := mNeedQtyBatch - mQuantity;
                                                                                    end;
                                                                          end;
                                                                          if mNeedQtyBatch<=0 then break;
                                                                     end;
                                                                 finally
                                                                   mResults.free;
                                                                 end;
                                                    End;
                                                    if (index=1) or (index=2) then begin
                                                           if index=1 then begin
                                                              //NxShowSimpleMessage('korekce',nil);
                                                              mFindRow:=false;
                                                              for mIDataset:=0 to mDatasetList.count-1 do begin     // dohledání řádku
                                                                  mstring:=(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Storecard_ID')+inttostr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('PosIndex'))) ;
                                                                  if  mstring = mDatasetList.Strings[mIDataset] then begin
                                                                      mFindRow:=true;
                                                                  end;

                                                              end;
                                                              if not mFindRow then begin    // smazání řádku
                                                                  //NxShowSimpleMessage('položka nenalezena ' + inttostr( mMonInput.BusinessObject[i].GetFieldValueAsInteger('Posindex')),nil);
                                                                  mChyba:=mChyba+1 ;
                                                                  mMonikerRows.BusinessObject[iRows].SetFieldValueAsInteger('Rowtype',0);
                                                                  mMonikerRows.BusinessObject[iRows].SetFieldValueAsstring('Text','Korekce');
                                                                  mMonikerRows.BusinessObject[iRows].MarkForDelete;
                                                                  mFindRow:=False;
                                                                  //NxShowSimpleMessage('korekce',nil);
                                                              end;

                                                           end;

                                                            if (index=2) then begin
                                                                  NxShowSimpleMessage('Počet šarží (' + NxFloatToIBStr(mHelpQtyBatch) + ')na ' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Storecard_id.Displayname') + ' neodpovídá množství (' + NxFloatToIBStr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('quantity')) + ')',nil);
                                                            end;
                                                    end;
                                                end;






                              end;




                      end;
                  end;
      end;
         if (mchyba>0) and (index=1) then NxShowSimpleMessage('Korekce proběhla' , nil);

    finally
        mBO_Head.free;
    end;

end;


begin
end.
uses 'abra.eu.mask.Lipo.inventura_import.Rows_RO',
     'abra.eu.mask.Lipo.inventura_import.fce'
;

const
    mFilter='*.xml';
//    mSQL='select sb.id|| CAST(sb2.quantity AS VARCHAR(10)) from storecards sc ' +
//         ' join storebatches sb on sb.storecard_id=sc.id ' +
//         ' join storesubbatches sb2 on ((sb2.StoreCard_ID=sc.id) and (sb2.store_id=''%s'')) ' +
//         ' where (sc.id=''%s'') and (sb2.store_id=''%s'') and (sb2.quantity>0) order by sb2.quantity desc' ;


mSQL='SELECT sb.StoreBatch_ID,sb.quantity FROM STORESUBBATCHES SB JOIN STOREBATCHES B ON SB.STOREBATCH_ID = B.ID ' +
     ' WHERE (SB.Store_ID =''%s'') AND (SB.Quantity>0) ' +
     ' AND (B.StoreCard_ID = ''%s'' ) ORDER BY B.ExpirationDate$Date ';





procedure FormCreate_Hook(Self: TSiteForm);
var
mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  mAct: TBasicAction;
  i:integer;

begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Korekce šarží';
          mMAction.Caption := 'Korekce šarží ';
          mMAction.Items.Add('Doplnění šarží');
          mMAction.Items.Add('Korekce po odmazání');
          mMAction.Items.Add('Problémové šarže');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @OnExec;


end;



procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
  mMonikerRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  mBO_Head,mBO_Row,mBO_Batch:TNxCustomBusinessObject;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  iRows,iBatches:integer;
  mNeedQtyRow,mNeedQtyBatch,mStoreQty,mQuantity:double;
  mHelpQtyRow,mHelpQtyBatch:double;
  mResults:tstringlist;
  mexist:double;
  mSite: TSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
   mDL: TNxCustomBusinessObject;
  ii,mIDataset, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  mpocet:integer;
  mDatasetList:tstringlist;
  mFindRow,mFindBatch:Boolean;
  mChyba:integer;
  mString:string;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
 mControl:= mSite.FindChildControl('tabRows.grdRows');
 mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
 mBO_Head := TDynSiteForm(mSite).CurrentObject;
 mDatasetList:=tstringlist.create;
    try
      if not Assigned(mBO_Head) then begin

      end;


      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce korekce je přístupná jen v editaci dokladu.');
        Exit;
      end else begin


              if index=1 then begin
                        mDatasetList:=tstringlist.create;
                              if mDataSet.Active then begin
                                          mDataSet.First;
                                          while not mDataSet.Eof do begin
                                              //NxShowSimpleMessage(mDataSet.FieldByName('Storecard_ID').Asstring + inttostr(mDataSet.FieldByName('PosIndex').AsInteger),nil);
                                              mstring:=mDataSet.FieldByName('Storecard_ID').Asstring + inttostr(mDataSet.FieldByName('PosIndex').AsInteger)   ;
                                              mDatasetList.add(mString);
                                              mstring:='';
                                              mpocet:=mpocet+1;
                                              mDataSet.Next;
                                          end;
                              end;
               end;

              mMonikerRows := mBO_Head.GetLoadedCollectionMonikerForFieldCode(mBO_Head.GetFieldCode('ROWS'));
                  for iRows:= 0 to mMonikerRows.count -1 do begin
                      mFindRow:=false;
                      if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('RowType')=3) then begin
                              mNeedQtyRow:=0;
                              mNeedQtyRow:=mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('Quantity')  ;

                              if index=2 then begin     // kontrola stavu na skladové karty
                                     mr:=tstringlist.create;
                                     try
                                            msite.baseobjectspace.SQLSelect('Select sum(Quantity) from StoreSubCards where StoreCard_ID=' + quotedstr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID'))
                                                                            + ' and Store_ID=' + quotedstr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID')) ,mr);
                                            if mr.count>0 then begin
                                                  mStoreQty:=NxIBStrToFloat(mr.Strings[0]);
                                            end;
                                            if mStoreQty<(mNeedQtyRow) then begin
                                                  NxShowSimpleMessage('Nedostatečné množství na skladové kartě' , nil);
                                                  NxShowSimpleMessage('Nedostatečné množství na skladové kartě ' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID.displayname') + ' (' + NxFloatToIBStr(mNeedQtyRow) + ') z (' + NxFloatToIBStr(mStoreQty) +')',nil);
                                            end;
                                            mStoreQty:=0;
                                     finally
                                          mr.free;
                                     end;

                              end;

                              if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin
                                     mNeedQtyBatch:=0;
                                     mNeedQtyBatch:=mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('Quantity')  ;
                                     mMonBatches:=mMonikerRows.BusinessObject[iRows].GetLoadedCollectionMonikerForFieldCode(mMonikerRows.BusinessObject[iRows].GetFieldCode('DocRowBatches'));
                                            mFindBatch:=false;

                                            mHelpQtyBatch:=0;
                                            for iBatches:= 0 to mMonBatches.count -1 do begin  // kontrola stavu na šarži
                                                mHelpQtyBatch:= mHelpQtyBatch+mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity');
                                                if index=2 then begin
                                                      mResults:=TStringList.Create;
                                                      try
                                                           msite.baseobjectspace.SQLSelect('Select sum(Quantity) from StoreSubBatches where StoreBatch_ID=' + quotedstr(mMonBatches.BusinessObject[iBatches].GetFieldValueAsString('StoreBatch_ID'))
                                                                            + ' and Store_ID=' + quotedstr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID')) ,mResults);
                                                           if mResults.Count>0 then begin
                                                               mStoreQty:=NxIBStrToFloat(mResults.Strings[0]);
                                                               if mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity')>mStoreQty then begin
                                                                   NxShowSimpleMessage('', nil);
                                                                   NxShowSimpleMessage('Nedostatečné množství na šarži ' + mMonBatches.BusinessObject[iBatches].GetFieldValueAsString('Name') + ' (' + NxFloatToIBStr(mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity')) + ') z (' + NxFloatToIBStr(mStoreQty) +')',nil);
                                                               end;
                                                           end;

                                                      finally
                                                          mResults.free;
                                                      end;
                                                end;

                                            end;

                                              //NxShowSimpleMessage(NxFloatToIBStr(mNeedQtyBatch) + ' - ' + NxFloatToIBStr(mHelpQtyBatch),nil);
                                                if (mNeedQtyBatch<>mHelpQtyBatch) or (mNeedQtyBatch=0) then begin
                                                    if index=0 then begin
                                                                 mNeedQtyBatch:=mNeedQtyBatch-mHelpQtyBatch;
                                                                 mResults:=TStringList.Create;
                                                                 try
                                                                        msite.baseobjectspace.SQLSelect(Format(mSQL,[mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID'),mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID')]),mResults);
                                                                     for i:= 0 to mResults.Count-1 do begin
                                                                          if NxIBStrToFloat(copy(mResults.Strings[i],12,5))>0 then begin
                                                                                    //NxShowSimpleMessage(mResults.Strings[i],nil);
                                                                                    mBO_Batch:=mMonikerRows.BusinessObject[iRows].GetLoadedCollectionMonikerForFieldCode(mMonikerRows.BusinessObject[iRows].GetFieldCode('DocRowBatches')).AddNewObject;
                                                                                    mBO_Batch.SetFieldValueAsString('StoreBatch_ID',copy(mResults.Strings[i],1,10)); //ID šarže
                                                                                    mQuantity:=0;
                                                                                    mQuantity:=NxIBStrToFloat(copy(mResults.Strings[i],12,5)); //množství na šarži
                                                                                    if mQuantity >= mNeedQtyBatch then begin
                                                                                      mBO_Batch.SetFieldValueAsFloat('Quantity',mNeedQtyBatch);
                                                                                      mNeedQtyBatch := 0;
                                                                                    end else begin
                                                                                      mBO_Batch.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                      mNeedQtyBatch := mNeedQtyBatch - mQuantity;
                                                                                    end;
                                                                          end;
                                                                          if mNeedQtyBatch<=0 then break;
                                                                     end;
                                                                 finally
                                                                   mResults.free;
                                                                 end;
                                                    End;
                                                    if (index=1) or (index=2) then begin
                                                           if index=1 then begin
                                                              //NxShowSimpleMessage('korekce',nil);
                                                              mFindRow:=false;
                                                              for mIDataset:=0 to mDatasetList.count-1 do begin     // dohledání řádku
                                                                  mstring:=(mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Storecard_ID')+inttostr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('PosIndex'))) ;
                                                                  if  mstring = mDatasetList.Strings[mIDataset] then begin
                                                                      mFindRow:=true;
                                                                  end;

                                                              end;
                                                              if not mFindRow then begin    // smazání řádku
                                                                  //NxShowSimpleMessage('položka nenalezena ' + inttostr( mMonInput.BusinessObject[i].GetFieldValueAsInteger('Posindex')),nil);
                                                                  mChyba:=mChyba+1 ;
                                                                  mMonikerRows.BusinessObject[iRows].SetFieldValueAsInteger('Rowtype',0);
                                                                  mMonikerRows.BusinessObject[iRows].SetFieldValueAsstring('Text','Korekce');
                                                                  mMonikerRows.BusinessObject[iRows].MarkForDelete;
                                                                  mFindRow:=False;
                                                                  //NxShowSimpleMessage('korekce',nil);
                                                              end;

                                                           end;

                                                            if (index=2) then begin
                                                                  NxShowSimpleMessage('Počet šarží (' + NxFloatToIBStr(mHelpQtyBatch) + ')na ' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Storecard_id.Displayname') + ' neodpovídá množství (' + NxFloatToIBStr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('quantity')) + ')',nil);
                                                            end;
                                                    end;
                                                end;






                              end;




                      end;
                  end;
      end;
         if (mchyba>0) and (index=1) then NxShowSimpleMessage('Korekce proběhla' , nil);

    finally
        mBO_Head.free;
    end;

end;


begin
end.
