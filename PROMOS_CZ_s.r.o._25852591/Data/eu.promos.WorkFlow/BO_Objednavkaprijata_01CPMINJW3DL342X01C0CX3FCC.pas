uses 'eu.promos.workflow.fce';

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 mRowBO:TNxCustomBusinessObject;
 i:integer;
 mAvailableQuantity,mOrderedQuantity: Extended;
 mNotOnStore: Boolean;
 mPMOrigState_ID:string;
 mSDCount:extended;
begin
 if ((osNew in self.state) or (self.GetFieldValueAsString('PMState_ID') in ['3000000101','6000000101','3010000101'])) {and (self.GetFieldValueAsString('DocQueue_ID')='4200000101')} then begin
  if not(NxIsBlank(Self.GetFieldValueAsString('X_note'))) then begin
    self.SetFieldValueAsString('PMState_ID','1030000101')
  end else begin
    self.GetOriginalValue('PMState_ID',mPMOrigState_ID);
    mNotOnStore:=False;
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
         if not(mNotOnStore) then begin
          mAvailableQuantity:=GetAvailableQuantity(self.ObjectSpace,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
          mOrderedQuantity:=GetOrderedQuantity(Self.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'), mRowBO.OID,mRowBO.GetFieldValueAsString('Store_ID'), Self.GetFieldValueAsDateTime('CreatedAt$DATE'));
          if (mAvailableQuantity-mOrderedQuantity-(mRowBO.GetFieldValueAsFloat('Quantity')-mRowBO.GetFieldValueAsFloat('DeliveredQuantity')))<0 then begin
            mNotOnStore:=True;
            if (NxGetActualUserID(self.ObjectSpace)='1000000101') and (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe)
             then NxShowSimpleMessage(mRowBO.GetFieldValueAsString('StoreCard_ID.code')+#13#10+
                                      'mAvailableQuantity '+FloatToStr(mAvailableQuantity)+#13#10+
                                      'mOrderedQuantity '+FloatToStr(mOrderedQuantity)+#13#10+
                                      'RowQuantity ' +FloatToStr(mRowBO.GetFieldValueAsFloat('Quantity')-mRowBO.GetFieldValueAsFloat('DeliveredQuantity')),nil);
          end;
         end;
        end;
      end;
      mSDCount:=GetSDcount(self.ObjectSpace,self.oid);
      if mNotOnStore and not(mPMOrigState_ID='3010000101') then self.SetFieldValueAsString('PMState_ID','6000000101');
      if mNotOnStore and (mSDCount>0) then self.SetFieldValueAsString('PMState_ID','3010000101');
      if not(mNotOnStore) and ((mSDCount=0) or (mPMOrigState_ID='3010000101')) then self.SetFieldValueAsString('PMState_ID','5000000101');
      if self.GetFieldValueAsString('PMState_ID') in ['5000000101','6000000101'] then begin
        if (self.GetFieldValueAsString('Paymenttype_id')='9000000101') or not(NxIsBlank(Self.GetFieldValueAsString('X_note')))
                   then self.SetFieldValueAsString('PMState_ID','1030000101');
      end;
      if not(self.GetFieldValueAsBoolean('IsAvailableForDelivery')) then self.SetFieldValueAsString('PMState_ID','8000000101');
   end;
  end;
end;


procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mList:TStringList;
 mRows:TNxCustomBusinessMonikerCollection;
 mBool:boolean;
 i:integer;
begin
  mBool:=true;
  mList:=TStringList.Create;
  self.ObjectSpace.SQLSelect(format('select id from storedocuments2 where provide_id=''%s'' ',[self.oid]),mlist);
  //if mlist.count=0 then begin
  if self.GetFieldValueAsString('PMState_ID')='5000000101' then begin
     try
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'M000000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mParam := mInputParams.GetOrCreateParam(dtInteger, 'StoreQuantityKind');
                      mParam.AsInteger := 1;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_ReceivedOrder,Class_BillOfDelivery);
                      mImportMan.AddInputDocument(self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'M000000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.GetFieldValueAsString('FirmOffice_ID'));
                      mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                       for i:=0 to mrows.count-1 do begin
                          if mrows.BusinessObject[i].GetFieldValueAsInteger('RowType')=0 then mRows.BusinessObject[i].MarkForDelete;
                       end;
                      if (mrows.CountOfNotDeleted>0) then mImportMan.OutputDocument.save;


         Except
          //NxShowSimpleMessage(ExceptionMessage,nil);
          //prostě to nesmí zhučet
         end;
  end;
end;


begin
end.