uses 'abra.eu.mask.Lipo.inventura_import.lib';



function Import_Rows_PRV(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean) : Boolean;
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
  mPartialInvProtocol, mRowBO : TNxCustomBusinessObject;
  mMainInvProtocolRow_ID : string;
  mQuantity : double;
   mleft,mtop:integer;
  mB_Result:Boolean;
  mList:TStringList;
  mtext:string;

  mean_old:string;
  mpocet:Double;
  mpopis:string;
  mStoreCard_ID_Old:string;
  mi:integer;
  mDBGrid:TMultiGrid;

begin


   mstart:='0';
    if (not FileExists(AFileName)) and (copy(AFileName,1,2)<>'SK') then begin
      Result := False;
      exit;
    end;

    mstore_id:='';
    try

      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);
        mstart:='0';
           mr:=tstringlist.create;
                                  try
                                      msite.BaseObjectSpace.SQLSelect('select id from stores where code=' + quotedstr(mXMLHead.getElementAsString('StoreCode')),mr);
                                      if mr.count>0 then begin
                                              mStore_id:=mr.Strings[0];
                                      end;
                                  finally
                                     mr.free;
                                  end;


  mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(msite).MainPanel, 'grdRows'));



               for i := 0 to mXMLHead.getElementsCountInArray('pvydej') - 1 do begin
                   mStoreCard_ID:='';
                          mRow := TNxHeaderBusinessObject(TDynSiteForm(mSite).CurrentObject).Rows.AddNewObject;
                                  mRow.Prefill;

                                  mr:=tstringlist.create;
                                  try
                                      msite.BaseObjectSpace.SQLSelect('select id from storecards where ean=' + quotedstr((mXMLHead.getElementAsString('pvydej['+inttostr(i)+'].EAN'))),mr);
                                      if mr.count>0 then begin
                                              mStoreCard_id:=mr.Strings[0];
                                      end;
                                  finally
                                     mr.free;
                                  end;

                                  mRow.SetFieldValueAsstring('Store_ID',mstore_id);
                                  mRow.SetFieldValueAsstring('StoreCard_ID',mstoreCard_id);
                                  mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('pvydej['+inttostr(i)+'].mnozstvi')));

                                  mRow.SetFieldValueAsString('Division_ID',mrow.GetFieldValueAsString('Store_ID.X_BusDivision_ID')); //text bude  ...





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






function Import_Rows_RO(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean;index:integer) : Boolean;
var
mr:tstringlist;
ii,jj:integer;
mstart:string;
mBusOrder_id,mDivision_ID,mBustransaction_id,mStoreCard_ID,mStore_id:string;
mBO_pomoc,mBO_ROW:TNxCustomBusinessObject;
mRows_RO:TNxCustomBusinessMonikerCollection;
mpozice_ID:string;
 mBO : TNxCustomBusinessObject;
  mhead:TNxcustomBusinessObject;
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
  mPartialInvProtocol, mRowBO : TNxCustomBusinessObject;
  mMainInvProtocolRow_ID : string;
  mQuantity : double;
   mleft,mtop:integer;
  mB_Result:Boolean;
  mList:TStringList;
  mtext:string;
  mxx:TStringList;
  mean_old:string;
  mpocet:Double;
  mpopis:string;
  mStoreCard_ID_Old:string;
  mi:integer;
  mMOn:TNxCustomBusinessMonikerCollection;
  mBAtch:TNxCustomBusinessObject;
  mMainInvProtocolRowBatch_ID,mBatch_ID:string;
begin
   mstart:='0';
    if (not FileExists(AFileName)) and (copy(AFileName,1,2)<>'SK') then begin
      Result := False;
      exit;
    end;

    try

      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);
        mstart:='0';
        //NxShowSimpleMessage(mXMLHead.getElementAsString('zakazka'),nil);

//              mRows_RO := TDynSiteForm(msite).CurrentObject.GetCollectionMonikerForFieldCode(TDynSiteForm(msite).CurrentObject.GetFieldCode('Rows'));

        mBO := TDynSiteForm(mSite).CurrentObject;
        mHead := mBO.ObjectSpace.CreateObject('U0D05ZPUL3IOVHE2PRXQGEOVG4');
              mhead.Load(mbo.OID,nil);
          //NxShowSimpleMessage(mXMLHead.getElementAsString('VFPData.inventura[1].mnozstvi'),nil);
               for i := 0 to mXMLHead.getElementsCountInArray('StoreCard') - 1 do begin
                          mPartialInvProtocol := mhead.ObjectSpace.CreateObject(Class_PartialInvProtocol);
                                  try

                                      mPartialInvProtocol.Load(mhead.OID, nil);
                                      mQuantity:= mpocet;
                                      mMainInvProtocolRow_ID := iGetOrCreateMainInvProtocolRow_ID(mhead.ObjectSpace, mhead.GetFieldValueAsString('MainProtocol_ID'),
                                                              mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].id'), mPartialInvProtocol.GetFieldValueAsBoolean('AddRows'));

                                          mRowBO := mhead.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
                                          try
                                                mRowBO.New;
                                                mRowBO.Prefill;
                                                mRowBO.SetFieldValueAsString('Parent_ID', mhead.oid);
                                                mRowBO.SetFieldValueAsString('MIPRow_ID', mMainInvProtocolRow_ID);

                                                mRowBO.SetFieldValueAsDateTime('TimeStamp$DATE',Now);

                                                if (mRowBO.getFieldValueAsinteger('MIPRow_ID.Storecard_ID.Category')=1) or
                                                   (mRowBO.getFieldValueAsinteger('MIPRow_ID.Storecard_ID.Category')=2) then begin
                                                       mRowBO.SetFieldValueAsBoolean('RealQuantityChanged',true);
                                          //           NxShowSimpleMessage('Šarže',nil);
                                                      {
                                                     if index=1 then begin

                                                                  if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].batch')<>'' then begin
                                                                                 mxx:=TStringList.create;
                                                                                        try
                                                                                           msite.BaseObjectSpace.SQLSelect('Select max(id) from StoreBatches where Name=' + quotedstr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].batch')) ,mxx);
                                                                                           if mxx.count>0 then
                                                                                                 mbatch_id:=mxx.Strings[0]
                                                                                           else
                                                                                                 mbatch_id:='' ;

                                                                                           mMainInvProtocolRowBatch_ID:='';
                                                                                           mMainInvProtocolRowBatch_ID := iGetOrCreateMainInvProtocolRowBatch_ID(mhead.ObjectSpace, mMainInvProtocolRow_ID,
                                                                                                      mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].id'), mPartialInvProtocol.GetFieldValueAsBoolean('AddRows'),mbatch_id);


                                                                                           if mMainInvProtocolRowBatch_ID<>'' then begin




                                                                                                        mBAtch:= mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('ROWS')).AddNewObject;
                                                                                                              mBAtch.Prefill;
                                                                                                              mBAtch.SetFieldValueAsstring('MIPBatch_ID',mMainInvProtocolRowBatch_ID);
                                                                                                              mBAtch.SetFieldValueAsstring('qUnit','AA');
                                                                                                              mBAtch.SetFieldValueAsFloat('RealQuantity',NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].quantity')));
                                                                                                              //mBAtch.SetFieldValueAsFloat('UnitRealQuantity',2);


                                                                                            end;


                                                                                        finally
                                                                                           mxx.free;
                                                                                        end;


                                                                    end;
                                                                       }

                                                           mRowBO.Save;
                                                           mi:=os.SQLExecute('update PartialInvProtocolRows set RealQuantity=' + mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].quantity') + ' where id=' + QuotedStr(mRowBO.oid));


                                                end else begin
                                                      mRowBO.SetFieldValueAsBoolean('RealQuantityChanged',true);
                                                      mRowBO.SetFieldValueAsFloat('RealQuantity',NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].quantity')));
                                                      mRowBO.Save;
                                               end;











                                                 //end;



                                                //mi:=msite.BaseObjectSpace.SQLExecute('update PartialInvProtocolRows set RealQuantity=' +
                                                //   QuotedStr();


                                           finally
                                                 mRowBO.free;
                                           end;
                                          TDynSiteForm(msite).RefreshData;


                                  finally
                                  mPartialInvProtocol.Free;
                              end;


                end;
                TDynSiteForm(msite).CurrentObject.Refresh  ;
                msite.Refresh;
        finally
             mXMLHead.FREE;
        end;



end;










   function iGetOrCreateMainInvProtocolRow_ID(AOS : TNxCustomObjectSpace; AMainInvProtocol_ID : TNxOID; AStoreCard_ID : string;
                                             ACreateNew : Boolean) : TNxOID;
  const
    cSQL = 'SELECT B.ID FROM MainInvProtocolRows B ' +
           ' LEFT JOIN MainInvProtocols A ON A.ID=B.Parent_ID ' +
           ' WHERE A.ID=''%s'' AND B.StoreCard_ID=''%s'' ';
  var
    L : TStringList;
    mMainProtocolRowBO : TNxCustomBusinessObject;
  begin
    Result := '';
    L := TStringList.Create;
    try

      AOS.SQLSelect(format(cSQL, [AMainInvProtocol_ID, AStoreCard_ID]), L);
      if L.Count > 0 then begin
        Result := L.Strings[0];
     //   NxShowSimpleMessage('Položka na Hlavním protokolu existuje',nil);
        exit;
      end;
    finally
      L.Free;
    end;
    if ACreateNew then begin
      mMainProtocolRowBO := AOS.CreateObject(Class_MainInvProtocolRow);
      try
        mMainProtocolRowBO.New;
        mMainProtocolRowBO.SetFieldValueAsString('Parent_ID', AMainInvProtocol_ID);
        mMainProtocolRowBO.SetFieldValueAsString('StoreCard_ID', AStoreCard_ID);
        mMainProtocolRowBO.Save;
        Result := mMainProtocolRowBO.OID;
   //     NxShowSimpleMessage('Položka se na  Hlavním protokolu zakládá',nil);
      finally
        mMainProtocolRowBO.Free;
      end;
    end;
  end;



   function iGetOrCreateMainInvProtocolRowBatch_ID(AOS : TNxCustomObjectSpace; AMainInvProtocol_ID : TNxOID; AStoreCard_ID : string;
                                             ACreateNew : Boolean; Mbatch_ID:string) : TNxOID;
  const
    cSQL = 'SELECT B.ID FROM MainInvProtocolBatches MB left join MainInvProtocolRows B on b.id=mb.Parent_ID ' +
           ' LEFT JOIN MainInvProtocols A ON A.ID=B.Parent_ID ' +
           ' WHERE A.ID=''%s'' AND B.StoreCard_ID=''%s'' AND mb.StoreBatch_ID=''%s''';
  var
    L : TStringList;
    mMainProtocolRowBO,mMainProtocolRowBatchBO : TNxCustomBusinessObject;
  begin
    Result := '';
    L := TStringList.Create;
    try

      AOS.SQLSelect(format(cSQL, [AMainInvProtocol_ID, AStoreCard_ID,Mbatch_ID]), L);
      if L.Count > 0 then begin
        Result := L.Strings[0];
        NxShowSimpleMessage('Položka na  Hlavním protokolu existuje',nil);
        exit;
      end;
    finally
      L.Free;
    end;
    if Result= '' then begin
      mMainProtocolRowBatchBO := AOS.CreateObject('1HABDJDLP5BON5ZQGTUQI0EUCC');
      try
        mMainProtocolRowBatchBO.New;
        mMainProtocolRowBatchBO.SetFieldValueAsString('Parent_ID', AMainInvProtocol_ID);
        mMainProtocolRowBatchBO.SetFieldValueAsString('StoreBatch_ID', Mbatch_ID);
        mMainProtocolRowBatchBO.SetFieldValueAsString('QUnit', 'ks');
      //  mMainProtocolRowBatchBO.SetFieldValueAsfloat('UnitDocumentedQuantity', 0);



        mMainProtocolRowBatchBO.Save;
        Result := mMainProtocolRowBatchBO.OID;
        NxShowSimpleMessage('Šarže se na  Hlavním protokolu zakládá',nil);
      finally
        mMainProtocolRowBatchBO.Free;
      end;
    end;
  end;










begin
end.