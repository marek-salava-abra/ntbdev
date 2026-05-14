







{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure _AfterCorrect_PreHook(Self: TNxCustomBusinessObject);
begin
       NxShowSimpleMessage('_AfterCorrect_PreHook',nil);
end;



procedure _BeforeDataChange_PostHook(Self: TNxCustomBusinessObject);
begin
        NxShowSimpleMessage('_BeforeDataChange_PostHook',nil);
end;



{
Vyvolává se po validaci číselníkové položky.
}
procedure _DwarfValidate_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer; var AResult: Boolean);
begin
    NxShowSimpleMessage('Pxxx ' + self.GetFieldValueAsString('StoreCard_ID'),nil);
end;

procedure _FieldCorrect_PostHook(Self: TNxCustomBusinessObject; AFieldCode: integer);
begin
    NxShowSimpleMessage('Pxxx ' + self.GetFieldValueAsString('StoreCard_ID'),nil);
end;

procedure AfterRollValidate_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AResult: Boolean; AParams: TNxParameters; AType: TNxValidate);
begin
     NxShowSimpleMessage('Pxxx ' + self.GetFieldValueAsString('StoreCard_ID'),nil);
end;

{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
{
Vyvolává se před změnou každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_PreHook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter);
begin
      NxShowSimpleMessage('lll ' + self.GetFieldValueAsString('StoreCard_ID'),nil);
end;

procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
     NxShowSimpleMessage('Pxxx ',nil);
end;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
     NxShowSimpleMessage('beforesave',nil);
end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
       NxShowSimpleMessage('BeforeSoftValidate_Hook',nil);
end;



{
Vyvolává se před uložením opraveného dokladu a umožňuje nastavení statusu
dokladu na Opraven v DPH uzávěrce. Využití je pouze na vlastní riziko.
}
procedure CanChangeVATClosingDocumentStatus_Hook(Self: TNxCustomBusinessObject; var Result: Boolean);
begin
      NxShowSimpleMessage('tt',nil);
end;

{
Vyvolává se před validací každé položky. Pomocí tohoto háčku je možné ovlivnit seznam parametrů, které se předávají validaci.
}
procedure CompleteRollValidateParams_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
begin
     NxShowSimpleMessage('iddi',nil);
end;




{
Umožňuje zamezit stornování schválení vyvolané změnou na objektu.
}
{
Umožňuje ovlivnit korekci hodnot polí.
}
procedure Correct_Hook(Self: TNxCustomBusinessObject);
begin
  NxShowSimpleMessage('Pxxx ' + self.GetFieldValueAsString('StoreCard_ID'),nil);
end;

procedure DecisionWhetherToCancelConfirmation_Hook(Self: TNxCustomBusinessObject; const AConfirmationState: Integer; var Result: Boolean);
begin
       NxShowSimpleMessage('iii',nil);
end;

procedure Doplneni_kusovniku(Self: TNxHeaderBusinessObject);
var
mbo,mProductRow,mOutputRow:TNxCustomBusinessObject;
mRows,mOutputs,mInputs,mOperationRows:TNxCustomBusinessMonikerCollection;
k:integer;
mr:tstringlist;
mID_Postup,mID_Kusovnik:string;
begin

  mbo:=self;

  NxShowSimpleMessage('POžadavek na výrobu',nil);

                                                mID_Postup:='';
                                                mID_Kusovnik:='';

                                                 mOutputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Outputs'));   // vyráběná položka  //společný postup RoutineStoreCard_ID
                                                 mInputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));     // kusovník vstup

                                                 mOperationRows:=mOutputs.BusinessObject[0].GetLoadedCollectionMonikerForFieldCode(mOutputs.BusinessObject[0].GetFieldCode('PLMReqRoutines'));

                                                  NxShowSimpleMessage('Vyráběná položka : ' + mbo.getFieldValueAsString('StoreCard_ID') + ' karta TP :' + mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID') , nil);

                                                if mOperationRows.count> 0 then NxShowSimpleMessage('TP vyplněn',nil);

                                                if mInputs.count> 1 then NxShowSimpleMessage('Kusovník vyplněn',nil);







                                                // ***** technologický postup

                                      //        NxShowSimpleMessage(inttostr(mInputs.count),nil);
                                      //        NxShowSimpleMessage(inttostr(mInputs.count),nil);

                                                mr:=tstringlist.create;
                                                try
                                                     self.ObjectSpace.SQLSelect('select id from PLMRoutines where StoreCard_ID=' + QuotedStr(mbo.getFieldValueAsString('StoreCard_ID')),mr) ;
                                                      if mr.count>0 then begin
                                                            //NxShowSimpleMessage('přímý TP ke skladové kartě, funkcionalita abry', nil);
                                                            mID_Postup:=mr.Strings[0] + 'přímý TP ke skladové kartě, funkcionalita abry';
                                                      end else begin
                                                            // **** doplnění společného TP
                                                            if not nxisemptyoid(mbo.getFieldValueAsString('StoreCard_ID.X_parent_ID')) then begin

                                                                   mOutputs.BusinessObject[0].setFieldValueAsString('RoutineStoreCard_ID',mbo.getFieldValueAsString('StoreCard_ID.X_parent_ID'));

                                                                        self.ObjectSpace.SQLSelect('select id from PLMRoutines where StoreCard_ID=' + QuotedStr(mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID')),mr);
                                                                         if mr.count>0 then begin
                                                                              //NxShowSimpleMessage('Společny TP z nadřazené karty', nil);
                                                                              mID_Postup:=mr.Strings[0] + 'Společny TP z nadřazené karty';
                                                                         end else begin
                                                                              if not NxIsEmptyOID(mbo.getFieldValueAsString('StoreCard_ID.X_spolecny_technpostup')) then begin

                                                                                             //NxShowSimpleMessage(' pomocný z karty TP', nil);
                                                                                             mID_Postup:=mbo.getFieldValueAsString('StoreCard_ID.X_spolecny_technpostup') + 'Společny TP z nadřazené karty';
                                                                              end else begin
                                                                                    if not NxIsEmptyOID(mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID')) then begin
                                                                                        // NxShowSimpleMessage(' pomocný z nadřezené karty TP', nil);
                                                                                        mID_Postup:=mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID') + 'Společny TP z nadřazené karty';
                                                                                    end else begin
                                                                                        //NxShowSimpleMessage('0000000000   není TP', nil);
                                                                                        mID_Postup:= '0000000000   není TP';
                                                                                    end;
                                                                              end;

                                                                         end;
                                                            end;
                                                      end;
                                                finally
                                                      mr.free;
                                                end;











                                                // ***** kusovník


                                                mr:=tstringlist.create;
                                                try
                                                     self.ObjectSpace.SQLSelect('select id from PLMPieceLists where StoreCard_ID=' + QuotedStr(mbo.getFieldValueAsString('StoreCard_ID')),mr) ;
                                                      if mr.count>0 then begin
                                                            //NxShowSimpleMessage('přímý TP ke skladové kartě, funkcionalita abry', nil);
                                                            mID_Kusovnik:=mr.Strings[0] + 'přímý Kusovník ke skladové kartě, funkcionalita abry';
                                                      end else begin
                                                            // **** doplnění společného TP
                                                            if not nxisemptyoid(mbo.getFieldValueAsString('StoreCard_ID.X_parent_ID')) then begin

                                                                   mOutputs.BusinessObject[0].setFieldValueAsString('RoutineStoreCard_ID',mbo.getFieldValueAsString('StoreCard_ID.X_parent_ID'));

                                                                        self.ObjectSpace.SQLSelect('select id from PLMPieceLists where StoreCard_ID=' + QuotedStr(mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID')),mr);
                                                                         if mr.count>0 then begin
                                                                              //NxShowSimpleMessage('Společny TP z nadřazené karty', nil);
                                                                              mID_Kusovnik:=mr.Strings[0] + 'Společny kusovník z nadřazené karty';
                                                                         end else begin
                                                                              if not NxIsEmptyOID(mbo.getFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik')) then begin

                                                                                             //NxShowSimpleMessage(' pomocný z karty TP', nil);
                                                                                             mID_Kusovnik:=mbo.getFieldValueAsString('StoreCard_ID.X_spolecny_kusovnik') + 'Společny kusovník z nadřazené karty';
                                                                              end else begin
                                                                                    if not NxIsEmptyOID(mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID')) then begin
                                                                                        // NxShowSimpleMessage(' pomocný z nadřezené karty TP', nil);
                                                                                        mID_Kusovnik:=mOutputs.BusinessObject[0].getFieldValueAsString('RoutineStoreCard_ID') + 'Společny kusovník z nadřazené karty';
                                                                                    end else begin
                                                                                        //NxShowSimpleMessage('0000000000   není TP', nil);
                                                                                        mID_Kusovnik:= '0000000000   není kusovník';
                                                                                    end;
                                                                              end;

                                                                         end;
                                                            end;
                                                      end;
                                                finally
                                                      mr.free;
                                                end;




NxShowSimpleMessage( mID_Postup , nil);
NxShowSimpleMessage( mID_Kusovnik , nil);





end;



function Spolecny_postup(mSite:TDynSiteForm;self:TNxCustomBusinessObject;mOperationRows:TNxCustomBusinessMonikerCollection;mid:string):Boolean;
var
mBOPLMRoutineRow,mBOPLMRoutine,mOutputRow,mOperationRow:TNxCustomBusinessObject;
mBOPLMRoutineRows:TNxCustomBusinessMonikerCollection;
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


   if not(mBO.NeedSave) then mBO.free;

    mbo.save;
//   if assigned(mdbgrid) then  mDBGrid.DataSource.DataSet.Refresh;
    msite.refresh;
end;




function Spolecny_kusovnik(self:TNxCustomBusinessObject;mid:string):Boolean;
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
                                                     mBO.ObjectSpace.SQLSelect('select id from PLMPieceLists where StoreCard_ID=' + QuotedStr(mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID') + ' and busProject_id is not null'),mr) ;
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

                                                                     mBOPLMPieceLists:=mBO.ObjectSpace.CreateObject('031N4GRZ4OT4TC5LYFK2WV1IFS');
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
//    msite.refresh;
end;











{
Umožňuje ovlivnit pořadí zpracování položek business objektu při volání API dotazu.
}
procedure FieldDependsOn_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
begin

end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  //self.SetFieldValueAsString('Division_ID','');
  //self.SetFieldValueAsDateTime('Division_ID','');
  //self.SetFieldValueAsString('Division_ID','');

   NxShowSimpleMessage('Prefil 01',nil);
   self.SetFieldValueAsBoolean('UpdatePLAndRoutDuringEdit',false);



end;


begin
end.