uses 'abra.eu.mask.Lipo.inventura_import.Rows_RO',
     'abra.eu.mask.Lipo.inventura_import.fce'
;

const
    mFilter='*.xml';


 {
 function AddBatch(ObjectSpace: TNxCustomObjectSpace; StoreCard_ID: string; isBOD: Boolean = False): string;
var mBO,
    mStoreBatch: TNxCustomBusinessObject;
    mSQL: string;
    mResult: TStringList;
begin
  mBO:= ObjectSpace.CreateObject(Class_StoreCard);
  mStoreBatch:= ObjectSpace.CreateObject(Class_StoreBatch);
  mResult:= TStringList.Create;
  try
    mBO.Load(StoreCard_ID, nil);
    mSQL:=Format('Select ID from StoreBatches where Name=''%s'' and StoreCard_ID=''%s''';,['* - ' + mBO.GetFieldValueAsString('Code'),mBO.OID]);
    ObjectSpace.SQLSelect(mSQL,mResult);
    if mResult.Count = 0 then
    begin
      if isBOD then Result := '0000000000'
      else begin
        mStoreBatch.New;
        mStoreBatch.Prefill;
        mStoreBatch.SetFieldValueAsBoolean(SerialNumber', False);
        mStoreBatch.SetFieldValueAsString('StoreCard_ID', StoreCard_ID);
        mStoreBatch.SetFieldValueAsString('Name','* - ' + mBO.GetFieldValueAsString('Code'));
        mStoreBatch.Save;
        Result:= mStoreBatch.OID;
      end;
    end else
      Result:= mResult[0];
  finally
    mResult.Free;
    mStoreBatch.Free;
    mBO.Free;
  end;
end;
          }


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
          mMAction.Hint := 'Import inventury z XML';
          mMAction.Caption := 'Import inventury z XML ';
          mMAction.Items.Add('Import inventury z XML');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @ImportInventuryOnExec;


end;



procedure ImportInventuryOnExec(Sender: TComponent;index:integer);
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
                      mresult:=Import_Inventury(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
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






 function Import_Inventury(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean) : Boolean;
var
mr:tstringlist;
ii,jj:integer;
mstart:string;
mBusOrder_id,mDivision_ID,mBustransaction_id,mStoreCard_ID,mStore_id:string;
mBO_pomoc,mBO_ROW:TNxCustomBusinessObject;
mRows_RO:TNxCustomBusinessMonikerCollection;
mpozice_ID:string;
 mBO : TNxCustomBusinessObject;
  mhead:TNxHeaderBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  P:integer;
  pocet:integer;
  tpocet:string;
  mForm : TForm;
  mBtn : TButton;
  mLbl,mLbl1 : TLabel;
  cbStoreCards : TComboBox;
  cbpocet,cbean,cbpopis:TEdit;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;

  i : integer;
  mPartialInvProtocol, mRowBO,mBOBatch,mStoreBatch : TNxCustomBusinessObject;
  mMainInvProtocolRow_ID : string;
  mQuantity : double;
   mleft,mtop:integer;
  mB_Result:Boolean;
  mList,mx:TStringList;
  mtext:string;

  mean_old:string;
  mpocet:Double;
  mpopis:string;
  mStoreCard_ID_Old:string;
  mi:integer;
  mDBGrid:TMultiGrid;
  mID_Batch:string;
  mRDocumentRow_ID:string;
begin


   mstart:='0';
   mstore_id:='';
    try

      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);
        mstart:='0';
           mr:=tstringlist.create;

  mstore_id:='1120000101';

  mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(msite).MainPanel, 'grdRows'));



               for i := 0 to mXMLHead.getElementsCountInArray('Storecard') - 1 do begin
                   mStoreCard_ID:='';
                          mRow := TNxHeaderBusinessObject(TDynSiteForm(mSite).CurrentObject).Rows.AddNewObject;
                                  mRow.Prefill;



                                 mRow.SetFieldValueAsstring('Store_ID',mstore_id);
                                  mRow.SetFieldValueAsstring('StoreCard_ID',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].id'));
                                  mRow.SetFieldValueAsFloat('Quantity',nxibstrtofloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].quantity')));

                                  mRow.SetFieldValueAsString('Division_ID',mrow.GetFieldValueAsString('Store_ID.X_BusDivision_ID')); //text bude  ...

                                  mRDocumentRow_ID:='';
                                  mx:=tstringlist.create;
                                  try
                                      os.SQLSelect(format('select id from storedocuments2 where storeCard_id=%s and Parent_id=%s',
                                      [quotedstr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].id')),quotedstr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('U_DL'))]),mx);
                                      if mx.count>0 then begin
                                           mRow.SetFieldValueAsString('RDocumentRow_ID',mx.Strings[0]);
                                      end else begin
                                                 mRow.SetFieldValueAsString('RDocumentRow_ID','');
                                      end;


                                  finally
                                      mx.free;
                                  end;


                                  if (mRow.getFieldValueAsInteger('StoreCard_ID.category')=1) or (mRow.getFieldValueAsInteger('StoreCard_ID.category')=2)  then begin


                                             mr:=tstringlist.create;
                                             try
                                                 os.SQLSelect(format('Select ID from StoreBatches where Name=''%s'' and StoreCard_ID=''%s''',[mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].batch'),mRow.GetFieldValueAsString('Storecard_id')]),mr);

                                                         if mr.count>0 then begin
                                                               mID_Batch:=mr.Strings[0] ;


                                                         end else begin
                                                                                        mStoreBatch:= os.CreateObject(Class_StoreBatch);
                                                                                        mStoreBatch.New;
                                                                                        mStoreBatch.Prefill;
                                                                                        mStoreBatch.SetFieldValueAsBoolean('SerialNumber', False);
                                                                                        mStoreBatch.SetFieldValueAsString('StoreCard_ID', mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].ID'));
                                                                                        mStoreBatch.SetFieldValueAsString('Name',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].batch'));
                                                                                        mStoreBatch.Save;
                                                                                        mID_Batch:=mStoreBatch.oid;


                                                          end;
                                                          mBOBatch:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches')).AddNewObject;
                                                          mBOBatch.SetFieldValueAsString('StoreBatch_ID',mID_Batch);
                                                          mBOBatch.SetFieldValueAsFloat('Quantity',nxibstrtofloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].quantity')));

                                               finally
                                               mr.free;
                                               end;

                                    end;

                end;
                 if Assigned(mDBGrid) then
                      mDBGrid.DataSource.DataSet.Refresh;

                //TDynSiteForm(msite).CurrentObject.save;
                //TDynSiteForm(msite).CurrentObject.Refresh  ;
                //msite.Refresh;
        finally
             mXMLHead.FREE;
        end;



end;





begin
end.