uses 'abra.eu.mask.Lipo.inventura_import.Rows_RO',
     'abra.eu.mask.Lipo.inventura_import.fce'
;

const
    mFilter='*.xml';
    mSQL='select sb.id || ''='' || sb2.quantity  from storecards sc ' +
         'join storesubcards sc2 on sc.id=sc2.storecard_id ' +
         'join storebatches sb on sc.id=sb.storecard_id ' +
         'join storesubbatches sb2 on sb2.storebatch_id=sb.id ' +
         'where sc2.storecard_id=''%s'' and sc2.store_id=''%s'' and sb2.quantity>0 order by sb2.quantity desc' ;





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
          mMAction.Hint := 'Import z XML';
          mMAction.Caption := 'Import z XML ';
          mMAction.Items.Add('Import z XML');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @OnExec;


        mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Doplnění šarží';
          mMAction.Caption := 'Doplnění šarží ';
          mMAction.Items.Add('Doplnění šarží');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @On1Exec;


end;



procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce importu je přístupná jen v editaci dokladu.');
        Exit;
      end else begin




               if index=0 then  begin



                    if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
                      mresult:=Import_Rows_PRV(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
                      if mresult then begin
                         //mresult:=nxcopyfile(mFileName,mdir + '\Zpracovane\' + mFileName);
                                                            if mresult then begin
                                                                //DeleteFile(mFileName);

                                                            end;
                      end;
                    end;
               end;
        end;
end;










procedure On1Exec(Sender: TComponent;index:integer);
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
                                                                          mBORow:=mMon.BusinessObject[j];
                                                                          if (mBORow.GetFieldValueAsInteger('RowType')=3) then
                                                                          begin
                                                                            if (mBORow.GetFieldValueAsInteger('StoreCard_ID.Category')=2) then
                                                                            begin
                                                                             // NxShowSimpleMessage('kolik?: ' + mSQL,nil) ;
                                                                              mNeedQty:=mBORow.GetFieldValueAsFloat('Quantity');



                                                                               mr:=TStringList.Create;
                                                                                     try
                                                                                            msite.baseobjectspace.SQLSelect('Select sum(quantity) from docrowbatches where Parent_ID=' + quotedstr(mBORow.oid),mr);
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

                                                                                                          msite.baseobjectspace.SQLSelect(Format(mSQL,[mBORow.GetFieldValueAsString('StoreCard_ID'),mBORow.GetFieldValueAsString('Store_ID')]),mResults);

                                                                                                          for i:= 0 to mResults.Count-1 do
                                                                                                          begin
                                                                                                            mBOBatch:=mBORow.GetLoadedCollectionMonikerForFieldCode(mBORow.GetFieldCode('DocRowBatches')).AddNewObject;
                                                                                                            mBOBatch.SetFieldValueAsString('StoreBatch_ID',mResults.Names[i]); //ID šarže
                                                                                                            mQuantity:=NxIBStrToFloat(mResults.ValueFromIndex[i]); //množství na šarži
                                                                                                            if mQuantity >= mNeedQty then
                                                                                                            begin
                                                                                                              mBOBatch.SetFieldValueAsFloat('Quantity',mNeedQty);
                                                                                                              mNeedQty := 0;
                                                                                                            end else begin
                                                                                                              mBOBatch.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                              mNeedQty := mNeedQty - mQuantity;
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
