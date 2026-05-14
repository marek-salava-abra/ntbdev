 //uses 'abra.eu.mask.Spedos.Servis.2016.const';


   function iSelectStore(AOLE: Variant) : string;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('O3ZO2K155FDL3CL100C4RHECN0', 0);
  Result := mRoll.SelectDialog2(True, mXX);
end;

  function iSelectWorkerRole(AOLE: Variant) : string;
var
  mRoll1 : variant;
  mXX1 : string;
begin
  Result := '';
  mXX1 := '0000000000';
  mRoll1 := AOLE.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);
  Result := mRoll1.SelectDialog2(True, mXX1);
end;

  function iSelectDivision(AOLE: Variant) : string;
var
  mRoll2 : variant;
  mXX2 : string;
begin
  Result := '';
  mXX2 := '0000000000';
  mRoll2 := AOLE.GetRoll('OA5JMX4J2FD135CH000ILPWJF4', 0);
  Result := mRoll2.SelectDialog2(True, mXX2);
end;


  function iSelectServiceDocqueue(AOLE: Variant) : TNxOID;
var
  mRoll3 : variant;
  mXX3 : string;
begin
  Result := '';
  mXX3 := '0000000000';
  mRoll3 := AOLE.GetRoll('W2XNBCJK3ZD13ACL03KIU0CLP4', 0);
  mRoll3.Params.Add('FilterDocumentType=SL');
  Result := mRoll3.SelectDialog2(True, mXX3);
end;

  function iSelectSP(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);
  Result := mRoll4.SelectDialog2(True, mXX4);
end;


procedure NXCHANGESP(Sender: TAction;index:integer);
var mSite : TDynSiteForm;
  mBO_source,mBO_SP,mBO_SL  : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr:Tstringlist;
  i, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
mParams : TNxParameters;
mSP,mSPOriginal:string;
mSP_project,mSP_ProjectOriginal:string;
mLastNumber:integer;
 mi:integer;
 mid_ML:string;
begin
    mSite := TComponent(Sender).DynSite;
 if (msite.CurrentObject.GetFieldValueAsInteger('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin

      mID_SO := iSelectSP(mSite.GetAbraOLEApplication);

      if mID_SO<>'' then begin
          mBO_SP:=TComponent(Sender).DynSite.BaseObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
          try
          mBO_SP.load(mID_SO,nil);



                      try
                      //mr:=TStringList.create;

                      mBO_source:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
                      mid_ML:=mBO_source.oid;
                          mSPOriginal:=mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID');

                          mSP_ProjectOriginal:=mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.BusProject_ID');

                          mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObject_ID=' + quotedstr(mBO_SP.OID)+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                          mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ServicedObject_ID=' + quotedstr(mBO_SP.OID)+ ' where servicedocument_ID=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;

                     mBO_source.Refresh;
                     //mSite.Refresh;
                     mBO_source:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;

                     mBO_source.load(mid_ml,nil);
                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObjectIDCode=' + quotedstr(mBO_SP.GetFieldValueAsString('code'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObjectText=' + quotedstr(mBO_SP.GetFieldValueAsString('Name'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set OutdoorPlaceDescription=' + quotedstr(mBO_SP.GetFieldValueAsString('OutdoorPlaceDescription'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                     mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_id_zakaznika_id=' + quotedstr(mBO_SP.GetFieldValueAsString('X_id_zakaznika_id'))+ ' where ServiceDocument_ID=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_id=' + quotedstr(mBO_SP.GetFieldValueAsString('X_id_zakaznika_id'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ServicedObject_id=' + quotedstr(mBO_SP.OID)+ ' where ServiceDocument_ID=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                               if not NxIsEmptyOID(mBO_SP.GetFieldValueAsString('PayerPerson_ID')) then
                               mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set PayerPerson_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('PayerPerson_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;

                              if not NxIsEmptyOID(mBO_SP.GetFieldValueAsString('BusProject_ID')) then
                              mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusProject_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('BusProject_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                              if not NxIsEmptyOID(mBO_SP.GetFieldValueAsString('BusTransaction_ID')) then
                              mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusTransaction_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('BusTransaction_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                              if not NxIsEmptyOID(mBO_SP.GetFieldValueAsString('BusOrder_ID')) then
                              mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusOrder_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('BusOrder_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                              if mBO_source.getFieldValueAsString('servicedocument_ID.BusOrder_ID')<>mSP_ProjectOriginal then begin
                             NxShowSimpleMessage('Nové zařízení není pod stejnou smlouvu, prosím zkontrolujte ceny a proveďte občerstvení.',msite);
                          end;

                     mBO_SL:=msite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                     try
                        mbo_sl.load(mBO_source.GetFieldValueAsString('servicedocument_ID'),nil);

                            mbo_sl.SetFieldValueAsString('Firm_ID',mBO_SP.GetFieldValueAsString('Firm_ID')) ;
                            mbo_sl.SetFieldValueAsString('PayerFirm_ID',mBO_SP.GetFieldValueAsString('PayerFirm_ID'));



                            //mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set Firm_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('Firm_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                            //mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set FirmOffice_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('FirmOffice_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                            //mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set PayerFirm_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('PayerFirm_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                            //mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set PayerFirmOffice_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('PayerFirmOffice_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                            mBO_SL.save;
                     finally
                        mBO_SL.free;
                     end;
//                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set Firm_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('Firm_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
//                     mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set FirmOffice_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('FirmOffice_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;



                             // mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set Person_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('Person_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;

                            //  mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set PayerPerson_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('PayerPerson_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;


                          //    mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusProject_ID=' + quotedstr('')+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                          //    mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusProject_ID=' + quotedstr('')+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                          //    mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusTransaction_ID=' + quotedstr('')+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
                          //    mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set BusOrder_ID=' + quotedstr('')+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;




                     if not NxIsEmptyOID(mBO_SP.GetFieldValueAsString('Person_ID')) then
                              mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set Person_ID=' + quotedstr(mBO_SP.GetFieldValueAsString('Person_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;






                 //  mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ServicedObject_ID=' + quotedstr(mID_SO)+ ' where ServiceDocument_ID=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;







                  finally

                  end;

                  //mdbgrid.Refresh;
                                                msite.RefreshData;
                                                msite.ActiveDataSet.seekid(mID_ML);
                                                msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;










          finally
             mBO_SP.free;
          end;
      end;

      end else begin
          NxShowSimpleMessage('Změna je přípustná pouze na neuzavřeném SL',nil);
      end;


end;






procedure ChangeSleva(Sender: TAction;index:integer);
var
msite:TDynSiteForm;
mMon:TNxCustomBusinessMonikerCollection;
mBo:TNxCustomBusinessObject;
i:integer;
msleva:string;
mresult:boolean;
mrow:TNxCustomBusinessObject;
mMat,mPrac:boolean;
begin
 mMat:=false;
 mPrac:=false;
  mSite := TComponent(Sender).DynSite;
  mBo:=msite.CurrentObject;
 msleva:='0';
  if index=8 then mresult:=InputQuery('Sleva', 'Procentuální sleva na materiál',msleva);
  if index=9 then mresult:=InputQuery('Sleva', 'Procentuální sleva na služby',msleva);

        if mBo.GetFieldValueAsString('ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
          mMon := mBo.GetLoadedCollectionMonikerForFieldCode(mBo.GetFieldCode('ROWS'));
                              for i := 0 to mMon.Count-1 do begin
                                  mRow := mMon.BusinessObject[i];
                                  if ((mRow.GetFieldValueAsInteger('itemtype')=1) and (index=8)) then begin

                                      mMat:=true;
                                      mRow.SetFieldValueAsInteger('X_Radkova_sleva',StrToInt(msleva));
                                      //  mrow.SetFieldValueAsInteger('X_Radkova_sleva',StrToInt(msleva));
                                  end;
                                  if (mRow.GetFieldValueAsInteger('itemtype')<>1) and (index=9) then begin

                                  mprac:=true;
                                      mRow.SetFieldValueAsInteger('X_Radkova_sleva',StrToInt(msleva));
                                  end;
                              end;
      end;
   mBo.save;
   if mMat then NxShowSimpleMessage('Proběhla změna slevy na materiál',nil);
   if mprac then NxShowSimpleMessage('Proběhla změna slevy na práci',nil);

end;



procedure NXCHANGEDOCQueue(Sender: TAction;index:integer);
var mSite : TDynSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr,mrx:Tstringlist;
  i,j, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
mParams : TNxParameters;
mNumber,mNumberOriginal:string;
mLastNumber:integer;
 mi:integer;
 mprefix:string;
 mid_ML:string;
begin
    mSite := TComponent(Sender).DynSite;
  mNumberOriginal:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID.CODE') + '-' + inttostr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsInteger('servicedocument_ID.Ordnumber')) +'/'+TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Period_ID.CODE') ;
      mID_SO:='';
      mID_SO := iSelectServiceDocqueue(mSite.GetAbraOLEApplication);
      mid_ML:=TDynSiteForm.CurrentObject.oid;
      try
  {        mr:=TStringList.create;

          TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace.SQLSelect('Select id from DocQueues2 where period_ID=' + QuotedStr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Period_ID')) + ' and DocQueue_ID=' + QuotedStr(mID_SO),mr);
          if mr.count>0 then begin
              try
                  mBO_source:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace.CreateObject('CZTZCFMM53D133N2010DELDFKK');
                  mBO_source.load(mr.Strings[0],nil);
                       mLastNumber:=mBO_source.GetFieldValueAsInteger('LastNumber');
                       mBO_source.SetFieldValueAsInteger('LastNumber',mLastNumber+1);
                       mBO_source.save;
              finally
                  mBO_source.free;
              end;

           end;  }
          mNumberOriginal:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID.CODE') + '-' + inttostr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsInteger('servicedocument_ID.Ordnumber')) +'/'+TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Period_ID.CODE') ;
   //       i:=mLastNumber ;
             mrx:=TStringList.create ;
              try
                 mSite.BaseObjectSpace.SQLSelect('Select max(OrdNumber) from ServiceDocuments where period_ID=' + QuotedStr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Period_ID')) + ' and DocQueue_ID=' +
                 QuotedStr(mID_SO),mrx);
                 i:=strtoint(mrx.Strings[0])+1;

              finally
                 mrx.Free;
              end

      finally
          mr.free;
      end;


      mi:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace.SQLExecute('Update ServiceDocuments set Docqueue_ID=' + quotedstr(mID_SO) +
       ',ordnumber=' + inttostr(i) + ' where id=' +quotedstr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID'))) ;
    TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
    mNumber:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID.CODE') + '-' + inttostr(i) +'/'+TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Period_ID.CODE') ;

   mprefix:='';

      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='1A20000101' then mprefix:='S';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='5B20000101' then mprefix:='S';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='4B20000101' then mprefix:='P';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='6B20000101' then mprefix:='P';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='7B20000101' then mprefix:='B';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='8B20000101' then mprefix:='B';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='9B20000101' then mprefix:='F';
      if TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID.Docqueue_ID')='AB20000101' then mprefix:='F';

 mi:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Protokol_prefix=' + quotedstr(mprefix) +
       ' where ServiceDocument_ID=' +quotedstr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID'))) ;
 mi:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Docqueue_ID=' + quotedstr(mID_SO) +
       ', X_ordnumber=' + inttostr(i) +
       ' where ServiceDocument_ID=' +quotedstr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('servicedocument_ID'))) ;



NxShowSimpleMessage('Proběhla změna dokladu z ' + mNumberOriginal + ' na ' + mNumber,nil);

msite.RefreshData;
                                    msite.ActiveDataSet.seekid(mID_ML);
                                    msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;

end;







procedure ChangeWorkerRole_id(Sender: TAction; Index: integer);
var mSite : TDynSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr:Tstringlist;
  i, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
mParams : TNxParameters;
mNumber,mNumberOriginal:string;
mLastNumber:integer;
 mi:integer;
 mprefix:string;
 mid_ML:string;
begin
    mi:=0;
    mSite := TComponent(Sender).DynSite;
      mID_SO:='';
      mID_SO := iSelectWorkerRole(mSite.GetAbraOLEApplication);

      //mid_ML:=TDynSiteForm.CurrentObject.oid;
      try
          if mID_SO<>'' then begin
          mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set X_Monter1_ID=' + quotedstr(mID_SO) + ' where id=' +
           QuotedStr(mSite.CurrentObject.OID));

          mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set WorkerRole_ID=' + quotedstr(mID_SO) + ' where parent_id=' +
           QuotedStr(mSite.CurrentObject.OID));
           mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set X_WorkerRole_ID=' + quotedstr(mID_SO) + ' where parent_id=' +
           QuotedStr(mSite.CurrentObject.OID));
             if mi=1 then begin
                 NxShowSimpleMessage('Změna technika proběhla',nil);
             end;
          end;
      finally

      end;

          mid_ML:=mSite.CurrentObject.oid ;
          msite.RefreshData;
          msite.ActiveDataSet.seekid(mID_ML);
          msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;



end;

procedure ChangeStore_ID(Sender: TAction; Index: integer);
var mSite : TDynSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr:Tstringlist;
  i, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
mParams : TNxParameters;
mNumber,mNumberOriginal:string;
mLastNumber:integer;
 mi:integer;
 mprefix:string;
 mid_ML:string;
begin
    mi:=0;
    mSite := TComponent(Sender).DynSite;
      mID_SO:='';
      mID_SO := iSelectStore(mSite.GetAbraOLEApplication);
      try
          if mID_SO<>'' then begin
                mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set Store_ID=' + quotedstr(mID_SO) + ' where parent_id=' +
                QuotedStr(mSite.CurrentObject.oid));
                if mi=1 then begin
                    NxShowSimpleMessage('Změna skladu proběhla',nil);
                end;
          end;

      finally

      end;
          mid_ML:=mSite.CurrentObject.oid;
          msite.RefreshData;
          msite.ActiveDataSet.seekid(mID_ML);
          msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;

end;


procedure ChangeUmisteni_ID(Sender: TAction; Index: integer);
var
 mSite : TDynSiteForm;
 mID,mID_SO,mID_zakaznika:string;
 mi:integer;
 mid_ML:string;
 mBO_source:TNxCustomBusinessObject;
 mr2:tstringlist;
 mOLE_SP,mRoll_SP,mOResult_SP:variant;
 mIDs_SP:TStringList;
 mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mI_ML:integer;
begin
  mi:=0;
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    mOLE_SP:= GetAbraOLEApplication;
                        mOResult_SP:= mOLE_SP.CreateStrings;
                        mRoll_SP:= mOLE_SP.GetRoll('BTYHA5DHLTDO14H21XNZM2CPIK', 0);   // sp
                             if not mRoll_SP.MultiSelectDialog(True, mOResult_SP) then Exit;
                                    mIDs_SP:= TStringList.Create;
                                    try
                                        mIDs_SP.Text:= mOResult_SP.Text;
                                         mID_zakaznika:= mIDs_SP.Strings[0];
                                    finally
                                       mIDs_SP.free;
                                    end;


    if mBookmark.count=0 then begin

                    mID_zakaznika:='';
                    if (nxstrtoint(msite.CurrentObject.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20) or
                      (NxGetActualUserID(msite.BaseObjectSpace)='SUPER00000') then begin


                          if mID_zakaznika<>'' then begin
                              try
                                        mi:=msite.BaseObjectSpace.SQLExecute('Update ServicedObjects set X_id_zakaznika_id='+ QuotedStr(mID_zakaznika) + ' where ID=' +quotedstr(msite.CurrentObject.GetFieldValueAsstring('X_ServicedObject_ID'))) ;
                                        mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_id='+ QuotedStr(mID_zakaznika) + ' where id=' +quotedstr(msite.CurrentObject.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                        mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_id_zakaznika_id='+ QuotedStr(mID_zakaznika) + ' where ServiceDocument_ID=' +quotedstr(msite.CurrentObject.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                               mID_ML:=msite.CurrentObject.oid;
                               finally
                               end;
                               mid_ML:=mSite.CurrentObject.oid;
                                msite.RefreshData;
                                msite.ActiveDataSet.seekid(mID_ML);
                                msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                          end;
                end else begin
                     NxShowSimpleMessage('Servisní list nesmí být uzavřený',nil);
                end;


    end else begin

        if NxGetActualUserID(msite.BaseObjectSpace)='SUPER00000' then begin
             for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
                  if (NxGetActualUserID(msite.BaseObjectSpace)='SUPER00000') then begin


                          if mID_zakaznika<>'' then begin
                              try
                                        mi:=msite.BaseObjectSpace.SQLExecute('Update ServicedObjects set X_id_zakaznika_id='+ QuotedStr(mID_zakaznika) + ' where ID=' +quotedstr(msite.CurrentObject.GetFieldValueAsstring('X_ServicedObject_ID'))) ;
                                        mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_id='+ QuotedStr(mID_zakaznika) + ' where id=' +quotedstr(msite.CurrentObject.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                        mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_id_zakaznika_id='+ QuotedStr(mID_zakaznika) + ' where ServiceDocument_ID=' +quotedstr(msite.CurrentObject.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                               mID_ML:=msite.CurrentObject.oid;
                               finally
                               end;
                               mid_ML:=mSite.CurrentObject.oid;

                          end;
                  end;

             end;
        msite.RefreshData;
                                msite.ActiveDataSet.seekid(mID_ML);
                                msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;

        end else begin
            NxShowSimpleMessage('Uvedená operace je určena jen pro jeden zázanam',nil);
        end;

    end;







end ;

procedure ChangePlatceSL_ID(Sender: TAction; Index: integer);
var
 mSite : TDynSiteForm;
 mID,mID_SO,mID_zakaznika:string;
 mi:integer;
 mid_ML:string;
 mBO_SL:TNxCustomBusinessObject;
 mr2:tstringlist;
 mOLE_SP,mRoll_SP,mOResult_SP:variant;
 mIDs_SP:TStringList;
begin
  mi:=0;
    mSite := TComponent(Sender).DynSite;
      mID_zakaznika:='';
          if nxstrtoint(msite.CurrentObject.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin

                        mOLE_SP:= GetAbraOLEApplication;
                        mOResult_SP:= mOLE_SP.CreateStrings;
                        mRoll_SP:= mOLE_SP.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);   // sp
                             if not mRoll_SP.MultiSelectDialog(True, mOResult_SP) then Exit;
                                    mIDs_SP:= TStringList.Create;
                                    try
                                        mIDs_SP.Text:= mOResult_SP.Text;
                                         mID_zakaznika:= mIDs_SP.Strings[0];
                                    finally
                                       mIDs_SP.free;
                                    end;
                          if mID_zakaznika<>''then begin
                                mBO_SL:=mSite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                try
                                  mBO_sl.load(msite.CurrentObject.GetFieldValueAsString('ServiceDocument_ID'),nil);
                                  mbo_sl.SetFieldValueAsString('Firm_ID',mID_zakaznika);
                                  mbo_sl.SetFieldValueAsString('PayerFirm_ID',mID_zakaznika);
                                  mbo_sl.save;
                                finally
                                  mbo_sl.free;
                                end;
                                mid_ML:=mSite.CurrentObject.oid;
                                msite.RefreshData;
                                msite.ActiveDataSet.seekid(mID_ML);
                                msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                          end;
                     end else begin
                     NxShowSimpleMessage('Servisní list nesmí být uzavřený',nil);
                end;

end ;

procedure ChangeDivision_ID(Sender: TAction; Index: integer);
var
 mSite : TDynSiteForm;
 mID,mID_SO,mcode:string;
 mi:integer;
 mid_ML:string;
 mBO_source,mBODivision:TNxCustomBusinessObject;
 mr2,mr3:tstringlist;
begin
  mcode:='';
  mi:=0;
    mSite := TComponent(Sender).DynSite;
      mID_SO:='';
      mID_SO := iSelectDivision(mSite.GetAbraOLEApplication);
        if mID_SO<>'' then begin
          mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceDocuments set Division_ID=' + quotedstr(mID_SO) + ' where id=' + QuotedStr(mSite.CurrentObject.GetFieldValueAsString('servicedocument_ID')));
          mid_ML:=mSite.CurrentObject.GetFieldValueAsString('servicedocument_ID') ;

          if mi=1 then begin
              //NxShowSimpleMessage('Změna střediska proběhla na ' + QuotedStr(msite.CurrentObject.GetFieldValueAsString('ServiceDocument_ID.division_id.code')),nil);
          end;

          mBODivision:=msite.BaseObjectSpace.CreateObject('O1X54EUXPZCL35CH000ILPWJF4');
          try
             mBODivision.load(mID_SO,nil);
             mcode:=mBODivision.GetFieldValueAsString('code');

          finally
             mBODivision.free;
          end;

          if mcode<>'' then begin
                  mr2:=TStringList.Create;
                      try
                          msite.BaseObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mcode),mr2);
                          if mr2.count>0 then begin
                                      mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set ServiceWorkSpace_ID =' +
                                      quotedstr(mr2.Strings[0]) + ' where id=' + QuotedStr(mSite.CurrentObject.oid));

                          end;
                      finally
                         mr2.free;
                      end;
                  mr3:=TStringList.Create;
                      try
                          msite.BaseObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mcode),mr3);
                          if mr3.count>0 then begin
                                      mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set ResponsibleRole_ID =' +
                                      quotedstr(mr3.Strings[0]) + ' where id=' + QuotedStr(mSite.CurrentObject.oid));

                          end;
                      finally
                         mr3.free;
                      end;


          end;



          msite.RefreshData;
          msite.ActiveDataSet.seekid(mID_ML);
          msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
        end;
end;





{
Vyvolává se po načtení vlastností formuláře.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

procedure mservis(Sender: TAction; Index: integer);

begin
    if index=0 then NXCHANGESP(Sender,index);
    if index=1 then NXCHANGEDOCQueue(Sender,index);
    if index=2 then ChangeWorkerRole_id(Sender,index);
    if index=3 then ChangeStore_ID(Sender,index);
    if index=4 then ChangeDivision_ID(Sender,index);
    if index=5 then ChangeUmisteni_ID(Sender,index);
    if index=6 then ChangePlatceSL_ID(Sender,index);
    if (index=8) or (index=9) then ChangeSleva(Sender,index);

end;


{
Vyvolává se po provedení metody CloseQuery. Pomocí tohoto háčku je možné ovlivnit, zda je možné agendu/formulář zavřít.
}
procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin

end;

 procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;

  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
            if mUser.GetFieldValueAsString('id')='2510000101' then mUserFilter:= true;
            if mUser.GetFieldValueAsString('id')='2U10000101' then mUserFilter:= true;
  finally
    mUser.Free;
  end;

 mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Servisní operace';
  mMAction.Hint := 'Servisní operace';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @mservis;
  mMAction.Items.Add('Změna Servisovaného předmětu');
  mMAction.Items.Add('Změna typu servisu');
  mMAction.Items.Add('Změna technika');
  mMAction.Items.Add('Změna skladu');
  mMAction.Items.Add('Změna střediska');
  mMAction.Items.Add('Změna provozovatele');
  mMAction.Items.Add('Změna plátce jen na SL - jednorázová');
  mMAction.Items.Add('');
  mMAction.Items.Add('Změna slev materiálu');
  mMAction.Items.Add('Změna slev služeb');
end;

begin
end.