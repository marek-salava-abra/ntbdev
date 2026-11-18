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
          mMAction.Hint := 'Doplnění šarží';
          mMAction.Caption := 'Doplnění šarží ';
          mMAction.Items.Add('Doplnění šarží');
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
  mMon,mMonBatches:TNxCustomBusinessMonikerCollection;
  mbo,mBORow,mBOBatch:TNxCustomBusinessObject;
  i,j:integer;
  mNeedQty,mFilledQty,mQuantity:double;
  mResults:tstringlist;
  mexist:double;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce importu je přístupná jen v editaci dokladu.');
        Exit;
      end else begin




               if index=0 then  begin
                     mbo:=TDynSiteForm(msite).CurrentObject;
                     try
                          mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                              try
                                      for j:= 0 to mMon.count -1 do
                                                                        begin
                                                                          mexist:=0;
                                                                          mNeedQty:=0;
                                                                          mBORow:=mMon.BusinessObject[j];
                                                                          if (mBORow.GetFieldValueAsInteger('RowType')=3) then
                                                                          begin
                                                                            if (mBORow.GetFieldValueAsInteger('StoreCard_ID.Category')=2) then
                                                                            begin
                                                                             // NxShowSimpleMessage('kolik?: ' + mSQL,nil) ;
                                                                              mNeedQty:=mBORow.GetFieldValueAsFloat('Quantity')  ;



                                                                               mr:=TStringList.Create;
                                                                                     try
                                                                                            msite.baseobjectspace.SQLSelect('Select sum(quantity) from docrowbatches where Parent_ID=' + quotedstr(mBORow.oid) ,mr);
                                                                                            if mr.count>0 then begin
                                                                                                  mexist:=NxIBStrToFloat(mr.Strings[0]);
                                                                                            end else begin
                                                                                                  mexist:=0;
                                                                                            end;
                                                                                     finally
                                                                                          mr.free;
                                                                                     end;

                                                                                    if mexist<> mNeedQty then begin

                                                                                                  mNeedQty:=mNeedQty-mexist;

                                                                                                  mFilledQty:=0;
                                                                                                   mResults:=TStringList.Create;
                                                                                                   try

                                                                                                          msite.baseobjectspace.SQLSelect(Format(mSQL,[mBORow.GetFieldValueAsString('Store_ID'),mBORow.GetFieldValueAsString('StoreCard_ID')]),mResults);

                                                                                                       for i:= 0 to mResults.Count-1 do
                                                                                                          //NxShowSimpleMessage(mResults.strings[i],nil);
                                                                                                          begin
                                                                                                            if NxIBStrToFloat(copy(mResults.Strings[i],12,5))>0 then begin
                                                                                                                      //NxShowSimpleMessage(mResults.Strings[i],nil);
                                                                                                                      mBOBatch:=mBORow.GetLoadedCollectionMonikerForFieldCode(mBORow.GetFieldCode('DocRowBatches')).AddNewObject;
                                                                                                                      mBOBatch.SetFieldValueAsString('StoreBatch_ID',copy(mResults.Strings[i],1,10)); //ID šarže
                                                                                                                      mQuantity:=NxIBStrToFloat(copy(mResults.Strings[i],12,5)); //množství na šarži
                                                                                                                      if mQuantity >= mNeedQty then
                                                                                                                      begin
                                                                                                                        mBOBatch.SetFieldValueAsFloat('Quantity',mNeedQty);
                                                                                                                        mNeedQty := 0;
                                                                                                                      end else begin
                                                                                                                        mBOBatch.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                                        mNeedQty := mNeedQty - mQuantity;
                                                                                                                      end;
                                                                                                            end;
                                                                                                            if mNeedQty<=0 then break;
                                                                                                       end;
                                                                                                   finally
                                                                                                     mResults.free;
                                                                                                   end;
                                                                                    end;
                                                                            // NxShowSimpleMessage('quantity' + mSQL,nil) ;
                                                                          end;



                                            end;
                                      end;

                              finally
                              end;
                     finally

                     end;



               end;
        end;
end;












begin
end.


begin
end.