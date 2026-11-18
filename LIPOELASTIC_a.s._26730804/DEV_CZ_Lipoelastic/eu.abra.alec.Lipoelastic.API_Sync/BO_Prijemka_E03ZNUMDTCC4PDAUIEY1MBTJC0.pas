uses '.API';


procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mOS:TNxCustomObjectSpace;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 i,j:Integer;
 mBO, mBatchMovementBO:TNxCustomBusinessObject;
 mBatchMovement_ID:string;
 mJSON:TJSONSuperObject;
 mID:string;
begin
  if self.GetFieldValueAsBoolean('X_ZAPI') then begin
    self.GetOriginalValue('U_SKBillOfDelivery_ID',mID);
    if not(NxIsEmptyOID(mID)) then begin
       mJSON:=TJSONSuperObject.Create;
       mJSON.S['X_ExternalDocument']:='';
       API_PUT(mJSON, 'BillsOfDelivery', mID);
    end;
    mOS:=Self.ObjectSpace;
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    if mRows.Count>0 then begin
      for i := 0 to mRows.count -1 do begin
          mBO:=mRows.BusinessObject[i];
          mDocRowBatches:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('DocRowBatches'));
          if mDocRowBatches.count>0 then begin
            for j:=0 to mDocRowBatches.Count-1 do begin
              mBatchMovement_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr(Class_Pohyby_sarzi_OV_SLARSB0H4CK4T32XPZTP33J3XS)+
                                                            ' and X_SK_batch='+QuotedStr(mDocRowBatches.BusinessObject[j].GetFieldValueAsString('StoreBatch_ID.Name')),'');
              if not(NxIsEmptyOID(mBatchMovement_ID)) then begin
                mBatchMovementBO:=mOS.CreateObject(Class_Pohyby_sarzi_OV_SLARSB0H4CK4T32XPZTP33J3XS);
                mBatchMovementBO.load(mBatchMovement_ID,nil);
                mBatchMovementBO.SetFieldValueAsString('X_SK_Batch','');
                mBatchMovementBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
                mBatchMovementBO.save;
                mBatchMovementBO.free;
              end;
            end;
          end;
      end;
    end;
  end;
end;

begin
end.