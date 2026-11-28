procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Vytvořit převodku příjem';
mBut.Category := 'tabList';
mBut.OnExecute := @Import;

end;

procedure Import(sender:TComponent);
var
 mString, mString2, mDQCode, mOrdNumber, mPeriodCode, mDocument_ID:sTring;
 mDestinationStore_id,mprevodkaprijem_ID, mDivision_ID, mFirm_ID, mFirmOffice_ID:String;
 mList:TStringList;
 mSite:TSiteForm;
 mContext: TNxContext;
 mOLE: TNxCustomObjectSpace;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mUser, mTransferBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
begin
   try
    mDocument_ID:='';
    mDQCode:='';
    mOrdNumber:='';
    mPeriodCode:='';
    mSite:=TComponent(sender).DynSite;
    mUser:=msite.GetFakeBusinessObject.ObjectSpace.CreateObject(Class_SecurityUser);
    mUser.Load(NxGetActualUserID_1(msite.GetFakeBusinessObject),nil);
    mDestinationStore_id:=muser.GetFieldValueAsString('X_store_ID');
    mDivision_ID:=muser.GetFieldValueAsString('X_division_ID');
    mprevodkaprijem_ID:=muser.GetFieldValueAsString('X_trasnfer_ID');
    if NxIsEmptyOID(mDestinationStore_id) then begin
      NxShowSimpleMessage('Uživatel nemá vyplněn výchozí sklad.',mSite);
      exit;
    end;
    if NxIsEmptyOID(mDivision_ID) then begin
      NxShowSimpleMessage('Uživatel nemá vyplněn výchozí středisko.',mSite);
      exit;
    end;
    if NxIsEmptyOID(mprevodkaprijem_ID) then begin
      NxShowSimpleMessage('Uživatel nemá vyplněn výchozí řadu dokladu pro převodku příjem.',mSite);
      exit;
    end;
    muser.Free;

    mString:=InputBox('Převodka příjem','Zadejte číslo dokladu','');
    mString2:=mString;
    if (NxSearch(mString2,'-',[srAll],0)=0) or (NxSearch(mString2,'/',[srAll],0)=0) then begin
      NxShowSimpleMessage('Nepodařilo se dohledat doklad s číslem '+mString2+'.',mSite);
      exit;
    end;
    mDQCode:=NxToken(mString,'-');
    mOrdNumber:=NxToken(mString,'/');
    mPeriodCode:=mString;
    mList:=TStringList.Create;
    msite.GetFakeBusinessObject.ObjectSpace.SQLSelect(format('Select sd.id from storedocuments sd /*left*/ join periods p on p.id=sd.period_id /*left*/ join docqueues dq on dq.id=sd.docqueue_id where sd.documenttype=''%s'' and dq.code=''%s'' and p.code=''%s'' and sd.ordnumber=%s',['22',UpperCase(mDQCode),mPeriodCode,mOrdNumber]),mList);
    if mList.count>0 then mDocument_ID:=mList.Strings[0];
    if NxIsEmptyOID(mDocument_ID) then begin
      NxShowSimpleMessage('Nepodařilo se dohledat doklad s číslem '+mString2+'.',mSite);
      exit;
    end;
    if not(NxIsEmptyOID(mDocument_ID)) then begin
      mTransferBO:=msite.GetFakeBusinessObject.ObjectSpace.CreateObject(Class_OutgoingTransfer);
      mTransferBO.Load(mDocument_ID,nil);
      mFirm_ID:=mTransferBO.GetFieldValueAsString('Firm_ID');
      mFirmOffice_ID:=mTransferBO.GetFieldValueAsString('FirmOffice_ID');
      if not(mTransferBO.GetFieldValueAsBoolean('IsAvailableForDelivery')) then begin
        NxShowSimpleMessage('Doklad '+mString2+' již není čerpatelný.',mSite);
        exit;


      end;
      try
        mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
        mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
        mOle:= mContext.GetObjectSpace;
        mInputParams := TNxParameters.Create;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := mprevodkaprijem_ID;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
        mParam.AsString := mDestinationStore_id;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Division_ID');
        mParam.AsString := mDivision_ID;
        mImportMan := NxCreateDocumentImportManager(mOLE, Class_OutgoingTransfer, Class_IncomingTransfer);
        mImportMan.AddInputDocument(mDocument_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mprevodkaprijem_ID);
        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
        mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
        mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
        mImportMan.OutputDocument.SetFieldValueAsString('Description',mTransferBO.GetFieldValueAsString('Description'));
        mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:=0 to mRows.count-1 do begin
          mrows.BusinessObject[i].SetFieldValueAsString('Division_ID',mDivision_ID);
        end;
        mImportMan.OutputDocument.save;
        NxShowSimpleMessage('Založil jsem převodku příjem '+mImportMan.OutputDocument.DisplayName+'.',mSite);
        mprevodkaprijem_ID:=mImportMan.OutputDocument.OID;
        mContext.free;
      finally


      end;
    end;
   finally
    TDynSiteForm(mSite).RefreshData;
    TDynSiteForm(mSite).ActiveDataSet.SeekID(mprevodkaprijem_ID);
   end;

end;


begin
end.