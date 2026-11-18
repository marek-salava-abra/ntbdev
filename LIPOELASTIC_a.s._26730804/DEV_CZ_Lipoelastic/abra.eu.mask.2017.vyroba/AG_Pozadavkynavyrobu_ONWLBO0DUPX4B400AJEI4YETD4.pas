
procedure ImportOnExecuteEcENTITY(Sender: TObject);
var
mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  mBO,mRow : TNxCustomBusinessObject;
  mMonVyr_polozka,mMonVyr_kusovnik : TNxCustomBusinessMonikerCollection;
  mOLE, mRoll, mOResult: Variant;
  mStringlist:TStringList;
  mbo_source:TNxCustomBusinessObject;

  mSite:TsiteForm;
mOS:TNxCustomObjectSpace;
mSMBO, mOutputRow, mInputRow, mRowBO, mProductRow, mOperationRow, mStoreCardBO, mUnitBO:TNxCustomBusinessObject;
mRows,mBOPLMPieceListsRows, mInputs, mOutputs,mOperationRows, mUnits,mBOPLMRoutineRows:TNxCustomBusinessMonikerCollection;
mUnit:TNxCustomBusinessObject;
mList:TStringList;
mopenDLG:TOpenDialog;
mParams, mParRow, mParRowNext : TNxParameters;
i, j, k,kk,  n:integer;
mStoreCard_ID, mStorePrice_ID, mBusOrder_ID, mBusOrderCode, mStoreCardCode, mMessage, mTeklaCode,mProduceRequest_ID:String;
mProductCard_ID:String;
mNew:Boolean;
mGRows : TMultiGrid;
mStoreCardList, mImportedList, mNotImportedList, mSaveList:TStringList;
mRozmerA, mRozmerB, mQuantity, mWeight :Extended;
mRozmer, mMnozstvi:double;
MSRozmer:string;
mr:TStringList;
mBOPLMPieceLists, mBOPLMPieceListsRow,mBOPLMRoutineRow,mBOPLMRoutine:TNxCustomBusinessObject;
 begin
 if Sender is TComponent then
    mSite := NxFindSiteForm(TComponent(Sender));
    mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(msite).MainPanel, 'grdreqrows'));
    mbo:=TDynSiteForm(msite).CurrentObject;

                                        mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
                                         mOutputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('OutPuts'));
                                         mInputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));

                                         //mrows.BusinessObject[0].SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
                                         for k:=0 to mrows.count-1 do begin
                                         mProductRow:=mRows.BusinessObject[k];
                                                mr:=tstringlist.create;
                                                try
                                                     msite.BaseObjectSpace.SQLSelect('select id from PLMPieceLists where StoreCard_ID=' + QuotedStr(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID') + ' and busProject_id is not null'),mr) ;
                                                      if mr.count>0 then begin
                                                         //   NxShowSimpleMessage('přímý kusovník, funkcionalita abry', nil);
                                                      end else begin




                                                         // kusovnik

                                                          if NxIsEmptyOID(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik')) then begin
                                                                 //        NxShowSimpleMessage('Není uvedený žádný kusovník', nil);
                                                          end else begin
                                                              //NxShowSimpleMessage('Společný kusovník ' + mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik'),nil);

                                                              if k=k then begin
                                                                     mInputs:=mProductRow.GetLoadedCollectionMonikerForFieldCode(mProductRow.GetFieldCode('Rows'));
                                                                     if mInputs.count>0 then begin
                                                                            for n:=0 to mInputs.count-1 do begin
                                                                                //  NxShowSimpleMessage('Budou mazány existující řádky z kusovníku',nil);
                                                                                  mInputs.BusinessObject[n].MarkForDelete;
                                                                            end;
                                                                     end;









                                                                     mBOPLMPieceLists:=msite.BaseObjectSpace.CreateObject('031N4GRZ4OT4TC5LYFK2WV1IFS');
                                                                        try
                                                                             mBOPLMPieceLists.load(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik'),nil);
                                                                                   mBOPLMPieceListsRows:=mBOPLMPieceLists.GetLoadedCollectionMonikerForFieldCode(mBOPLMPieceLists.GetFieldCode('Rows'));
                                                                                     //       NxShowSimpleMessage(inttostr(mBOPLMPieceListsRows.count),nil);
                                                                                            for kk:=0 to mBOPLMPieceListsRows.count-1 do begin
                                                                                                     mInputRow:=mInputs.AddNewObject;
                                                                                                      mInputRow.Prefill;
                                                                                                      mInputRow.SetFieldValueAsString('InputItem_ID.RealStoreCard_ID',mBOPLMPieceListsRows.BusinessObject[KK].GetFieldValueAsString('Storecard_ID'));
                                                                                                      mInputRow.SetFieldValueAsString('StoreCard_ID',mBOPLMPieceListsRows.BusinessObject[KK].GetFieldValueAsString('Storecard_ID'));
                                                                                                      mInputRow.SetFieldValueAsString('InputItem_ID.SupposedStore_ID','1000000101');
                                                                                                      minputrow.SetFieldValueAsFloat('InputItem_ID.UnitQuantity',mBOPLMPieceListsRows.BusinessObject[KK].GetFieldValueAsFloat('Quantity'));




                                                                                                      minputrow.SetFieldValueAsString('InputItem_ID.Note', '');

                                                                                                      minputrow.SetFieldValueAsBoolean('InputItem_ID.AllowMix',True);
                                                                                                      minputrow.SetFieldValueAsBoolean('InputItem_ID.Replaceable',True);



                                                                                            end;

                                                                        finally
                                                                           mBOPLMPieceLists.free;
                                                                        end;

                                                              end;
                                                           end;






                                                           // technologický postup
                                                          mOutputRow:=mOutputs.BusinessObject[k];
                                                          if NxIsEmptyOID(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_technpostup')) then begin
                                                               //          NxShowSimpleMessage('Není uvedený žádný postup', nil);
                                                          end else begin
                                                          //    NxShowSimpleMessage('Společný postup ' + mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_technpostup'),nil);


                                                                  mOperationRows:=mOutputRow.GetLoadedCollectionMonikerForFieldCode(mOutputRow.GetFieldCode('PLMReqRoutines'));
                                                                      for n:=0 to mOperationRows.count-1 do begin
                                                                          mOperationRows.BusinessObject[n].MarkForDelete;
                                                                      end;


                                                                     mBOPLMRoutine:=msite.BaseObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                                                                        try
                                                                             mBOPLMRoutine.load(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_technpostup'),nil);
                                                                                   mBOPLMRoutineRows:=mBOPLMRoutine.GetLoadedCollectionMonikerForFieldCode(mBOPLMRoutine.GetFieldCode('Rows'));
                                                                                     //       NxShowSimpleMessage(inttostr(mBOPLMPieceListsRows.count),nil);

                                                                                               for n:=0 to mOperationRows.count-1 do begin
                                                                                                      mOperationRows.BusinessObject[n].MarkForDelete;
                                                                                                end;

                                                                                               for kk:=0 to mBOPLMRoutineRows.count-1 do begin


                                                                                                  mOperationRow:=mOperationRows.AddNewObject;
                                                                                                  //NxShowSimpleMessage('postup radek',nil);
                                                                                                  mOperationRow.Prefill;
                                                                                                  mOperationRow.SetFieldValueAsString('Phase_ID',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('Phase_ID'));
                                                                                                  mOperationRow.SetFieldValueAsInteger('PosIndex',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsInteger('PosIndex'));
                                                                                                  mOperationRow.SetFieldValueAsString('Title',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('Title'));
                                                                                                  mOperationRow.SetFieldValueAsString('WorkPlace_ID',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('WorkPlace_ID'));
                                                                                                  mOperationRow.SetFieldValueAsString('SalaryClass_ID',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('SalaryClass_ID'));
                                                                                                  mOperationRow.SetFieldValueAsFloat('TAC',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsFloat('TAC'));
                                                                                                  mOperationRow.SetFieldValueAsInteger('TACUnit',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsInteger('TACUnit'));
                                                                                                  mOperationRow.SetFieldValueAsBoolean('Batch',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsBoolean('Batch'));
                                                                                                  mOperationRow.SetFieldValueAsBoolean('Finished',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsBoolean('Finished'));
                                                                                                  mOperationRow.SetFieldValueAsBoolean('Ongoing',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsBoolean('Ongoing'));




                                                                                                end;











                                                                        finally
                                                                           mBOPLMRoutine.free;
                                                                        end;

                                                              end;





                                                                  end;

                                                finally
                                                    mr.free;
                                                end;


                                         end;






                                         mOperationRows:=mOutputRow.GetLoadedCollectionMonikerForFieldCode(mOutputRow.GetFieldCode('PLMReqRoutines'));
                                         for k:=0 to mOperationRows.count-1 do begin
                                           mOperationRows.BusinessObject[k].MarkForDelete;
                                         end;
                                         mOperationRow:=mOperationRows.AddNewObject;
                                         mOperationRow.SetFieldValueAsString('Title','Příprava');
                                         mOperationRow.SetFieldValueAsString('WorkPlace_ID', '1100000101');
                                         mOperationRow.SetFieldValueAsString('SalaryClass_ID','1000000101');
                                         mOperationRow.SetFieldValueAsFloat('TAC',0);
                                         mOperationRow.SetFieldValueAsInteger('TACUnit',0);
                                         mOperationRow.SetFieldValueAsBoolean('Batch',true);





   if not(mBO.NeedSave) then mBO.free;

    mbo.save;
   if assigned(mdbgrid) then  mDBGrid.DataSource.DataSet.Refresh;
    msite.refresh;
end;

function Spolecny_postup(self:TNxCustomBusinessObject;mSite:TDynSiteForm):Boolean;
var
mBOPLMRoutineRow,mBOPLMRoutine,mOutputRow,mOperationRow:TNxCustomBusinessObject;
mOperationRows,mBOPLMRoutineRows:TNxCustomBusinessMonikerCollection;
n,kk:integer;

mActualRow : TBookmark;
  mBO,mRow : TNxCustomBusinessObject;
  mMonVyr_polozka,mMonVyr_kusovnik : TNxCustomBusinessMonikerCollection;
  mOLE, mRoll, mOResult: Variant;
  mStringlist:TStringList;
  mbo_source:TNxCustomBusinessObject;
mOS:TNxCustomObjectSpace;
mSMBO,  mInputRow, mRowBO, mProductRow,  mStoreCardBO, mUnitBO:TNxCustomBusinessObject;
mRows,mBOPLMPieceListsRows, mInputs, mOutputs, mUnits:TNxCustomBusinessMonikerCollection;
mUnit:TNxCustomBusinessObject;
mList:TStringList;
mopenDLG:TOpenDialog;
mParams, mParRow, mParRowNext : TNxParameters;
i, j, k:integer;
mStoreCard_ID, mStorePrice_ID, mBusOrder_ID, mBusOrderCode, mStoreCardCode, mMessage, mTeklaCode,mProduceRequest_ID:String;
mProductCard_ID:String;
mNew:Boolean;
mGRows : TMultiGrid;
mStoreCardList, mImportedList, mNotImportedList, mSaveList:TStringList;
mRozmerA, mRozmerB, mQuantity, mWeight :Extended;
mRozmer, mMnozstvi:double;
MSRozmer:string;
mr:TStringList;
mBOPLMPieceLists, mBOPLMPieceListsRow:TNxCustomBusinessObject;
begin
mbo:=self;
                                        mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
                                         mOutputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('OutPuts'));
                                         mInputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));
                                         //mrows.BusinessObject[0].SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
                                         for k:=0 to mrows.count-1 do begin
                                                mOutputRow:=mOutputs.BusinessObject[k];
                                                          if NxIsEmptyOID(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_technpostup')) then begin
                                                               //          NxShowSimpleMessage('Není uvedený žádný postup', nil);
                                                          end else begin
                                                          //    NxShowSimpleMessage('Společný postup ' + mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_technpostup'),nil);
                                                                  mOperationRows:=mOutputRow.GetLoadedCollectionMonikerForFieldCode(mOutputRow.GetFieldCode('PLMReqRoutines'));
                                                                      for n:=0 to mOperationRows.count-1 do begin
                                                                          mOperationRows.BusinessObject[n].MarkForDelete;
                                                                      end;
                                                                     mBOPLMRoutine:=msite.BaseObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                                                                        try
                                                                             mBOPLMRoutine.load(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_technpostup'),nil);
                                                                                   mBOPLMRoutineRows:=mBOPLMRoutine.GetLoadedCollectionMonikerForFieldCode(mBOPLMRoutine.GetFieldCode('Rows'));
                                                                                     //       NxShowSimpleMessage(inttostr(mBOPLMPieceListsRows.count),nil);

                                                                                               for n:=0 to mOperationRows.count-1 do begin
                                                                                                      mOperationRows.BusinessObject[n].MarkForDelete;
                                                                                                end;

                                                                                               for kk:=0 to mBOPLMRoutineRows.count-1 do begin
                                                                                                          mOperationRow:=mOperationRows.AddNewObject;
                                                                                                          //NxShowSimpleMessage('postup radek',nil);
                                                                                                          mOperationRow.SetFieldValueAsString('Phase_ID',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('Phase_ID'));
                                                                                                          mOperationRow.SetFieldValueAsInteger('PosIndex',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsInteger('PosIndex'));
                                                                                                          mOperationRow.SetFieldValueAsString('Title',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('Title'));
                                                                                                          mOperationRow.SetFieldValueAsString('WorkPlace_ID',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('WorkPlace_ID'));
                                                                                                          mOperationRow.SetFieldValueAsString('SalaryClass_ID',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsString('SalaryClass_ID'));
                                                                                                          mOperationRow.SetFieldValueAsFloat('TAC',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsFloat('TAC'));
                                                                                                          mOperationRow.SetFieldValueAsInteger('TACUnit',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsInteger('TACUnit'));
                                                                                                          mOperationRow.SetFieldValueAsBoolean('Batch',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsBoolean('Batch'));
                                                                                                          mOperationRow.SetFieldValueAsBoolean('Finished',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsBoolean('Finished'));
                                                                                                          mOperationRow.SetFieldValueAsBoolean('Ongoing',mBOPLMRoutineRows.BusinessObject[kk].GetFieldValueAsBoolean('Ongoing'));
                                                                                                end;
                                                                        finally
                                                                           mBOPLMRoutine.free;
                                                                        end;

                                                              end;

                                         end;
   if not(mBO.NeedSave) then mBO.free;

    mbo.save;
//   if assigned(mdbgrid) then  mDBGrid.DataSource.DataSet.Refresh;
    msite.refresh;
end;




function Spolecny_kusovnik(self:TNxCustomBusinessObject;mSite:TDynSiteForm):Boolean;
var

  mActualRow : TBookmark;
  mBO,mRow : TNxCustomBusinessObject;
  mMonVyr_polozka,mMonVyr_kusovnik : TNxCustomBusinessMonikerCollection;
  mOLE, mRoll, mOResult: Variant;
  mStringlist:TStringList;
  mbo_source:TNxCustomBusinessObject;


mOS:TNxCustomObjectSpace;
mSMBO, mOutputRow, mInputRow, mRowBO, mProductRow, mOperationRow, mStoreCardBO, mUnitBO:TNxCustomBusinessObject;
mRows,mBOPLMPieceListsRows, mInputs, mOutputs,mOperationRows, mUnits:TNxCustomBusinessMonikerCollection;
mUnit:TNxCustomBusinessObject;
mList:TStringList;
mopenDLG:TOpenDialog;
mParams, mParRow, mParRowNext : TNxParameters;
i, j, k,kk,  n:integer;
mStoreCard_ID, mStorePrice_ID, mBusOrder_ID, mBusOrderCode, mStoreCardCode, mMessage, mTeklaCode,mProduceRequest_ID:String;
mProductCard_ID:String;
mNew:Boolean;
mGRows : TMultiGrid;
mStoreCardList, mImportedList, mNotImportedList, mSaveList:TStringList;
mRozmerA, mRozmerB, mQuantity, mWeight :Extended;
mRozmer, mMnozstvi:double;
MSRozmer:string;
mr:TStringList;
mBOPLMPieceLists, mBOPLMPieceListsRow:TNxCustomBusinessObject;
 begin

    mbo:=self;

                                        mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
                                         mOutputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('OutPuts'));
                                         mInputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));
                                         //mrows.BusinessObject[0].SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
                                         for k:=0 to mrows.count-1 do begin
                                         mProductRow:=mRows.BusinessObject[k];
                                                mr:=tstringlist.create;
                                                try
                                                     msite.BaseObjectSpace.SQLSelect('select id from PLMPieceLists where StoreCard_ID=' + QuotedStr(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID') + ' and busProject_id is not null'),mr) ;
                                                      if mr.count>0 then begin
                                                         //   NxShowSimpleMessage('přímý kusovník, funkcionalita abry', nil);
                                                      end else begin
                                                          if NxIsEmptyOID(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik')) then begin
                                                                 //        NxShowSimpleMessage('Není uvedený žádný kusovník', nil);
                                                          end else begin
                                                              //NxShowSimpleMessage('Společný kusovník ' + mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik'),nil);
                                                              if k=k then begin
                                                                     mInputs:=mProductRow.GetLoadedCollectionMonikerForFieldCode(mProductRow.GetFieldCode('Rows'));
                                                                     if mInputs.count>0 then begin
                                                                            for n:=0 to mInputs.count-1 do begin
                                                                                //  NxShowSimpleMessage('Budou mazány existující řádky z kusovníku',nil);
                                                                                  mInputs.BusinessObject[n].MarkForDelete;
                                                                            end;
                                                                     end;

                                                                     mBOPLMPieceLists:=msite.BaseObjectSpace.CreateObject('031N4GRZ4OT4TC5LYFK2WV1IFS');
                                                                        try
                                                                             mBOPLMPieceLists.load(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik'),nil);
                                                                                   mBOPLMPieceListsRows:=mBOPLMPieceLists.GetLoadedCollectionMonikerForFieldCode(mBOPLMPieceLists.GetFieldCode('Rows'));
                                                                                     //       NxShowSimpleMessage(inttostr(mBOPLMPieceListsRows.count),nil);
                                                                                            for kk:=0 to mBOPLMPieceListsRows.count-1 do begin
                                                                                                     mInputRow:=mInputs.AddNewObject;
                                                                                                      mInputRow.Prefill;
                                                                                                      mInputRow.SetFieldValueAsString('InputItem_ID.RealStoreCard_ID',mBOPLMPieceListsRows.BusinessObject[KK].GetFieldValueAsString('Storecard_ID'));
                                                                                                      mInputRow.SetFieldValueAsString('StoreCard_ID',mBOPLMPieceListsRows.BusinessObject[KK].GetFieldValueAsString('Storecard_ID'));
                                                                                                      mInputRow.SetFieldValueAsString('InputItem_ID.SupposedStore_ID','1000000101');
                                                                                                      minputrow.SetFieldValueAsFloat('InputItem_ID.UnitQuantity',mBOPLMPieceListsRows.BusinessObject[KK].GetFieldValueAsFloat('Quantity'));




                                                                                                      minputrow.SetFieldValueAsString('InputItem_ID.Note', '');

                                                                                                      minputrow.SetFieldValueAsBoolean('InputItem_ID.AllowMix',True);
                                                                                                      minputrow.SetFieldValueAsBoolean('InputItem_ID.Replaceable',True);



                                                                                            end;

                                                                        finally
                                                                           mBOPLMPieceLists.free;
                                                                        end;

                                                              end;
                                                           end;
                                                                   mOutputRow:=mOutputs.BusinessObject[k];
                                                                   mOutputRow.SetFieldValueAsString('RoutineType_ID','1000000101');
                                                        end;

                                                finally
                                                    mr.free;
                                                end;


                                         end;
   if not(mBO.NeedSave) then mBO.free;

    mbo.save;
//   if assigned(mdbgrid) then  mDBGrid.DataSource.DataSet.Refresh;
    msite.refresh;
end;




procedure _AfterSave_PreHook(Self: TDynSiteForm);
var
mB_Import:boolean;
begin
//mB_Import:=Spolecny_kusovnik(TDynSiteForm(self).CurrentObject,self);
mB_Import:=Spolecny_postup(TDynSiteForm(self).CurrentObject,self);
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMethodPointer: Pointer;
begin
 { mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Valut export';
  mAction.Hint := 'testování skriptingu - třída TSQLConnection';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ExportOnExecuteEcENTITY;   }
{
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import položek';
  mAction.Hint := 'Import položek';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ImportOnExecuteEcENTITY;
    }
end;



begin
end.