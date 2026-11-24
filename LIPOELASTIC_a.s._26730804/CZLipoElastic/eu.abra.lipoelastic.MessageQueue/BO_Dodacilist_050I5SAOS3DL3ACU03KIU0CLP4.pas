uses '.API', '.receivedOrder', '.const';

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mOriginalExternalID, mExternalID, mOriginalPMState_ID: String;
begin
  if (Self.GetFieldValueAsString('DocQueue_ID') = cMQ_BOD_DocQueue_ID_DLDS) and
     not (osNew in Self.State) then begin
    Self.GetOriginalValue('X_ExternalID', mOriginalExternalID);
    Self.GetOriginalValue('PMState_ID', mOriginalPMState_ID);
    mExternalID := Self.GetFieldValueAsString('X_ExternalID');
    if not NxIsEmptyOID(mOriginalExternalID) and
       (mOriginalExternalID <> mExternalID) then
      RaiseException('delivery_sync.external_id_conflict id=' + Self.OID);

    if (Self.GetFieldValueAsString('PMState_ID') = cMQ_BOD_PMState_ID_SYNC_OK) and
       (mOriginalPMState_ID <> cMQ_BOD_PMState_ID_SYNC_OK) then begin
      if mOriginalPMState_ID <> cMQ_BOD_PMState_ID_ZPRACOVAVA_SE then
        RaiseException('delivery_sync.unexpected_state id=' + Self.OID +
          ' state=' + mOriginalPMState_ID);
      if NxIsEmptyOID(mExternalID) then
        RaiseException('delivery_sync.missing field=X_ExternalID id=' + Self.OID);
    end;
  end;

  if (Self.GetFieldValueAsString('DocQueue_ID') = cMQ_BOD_DocQueue_ID_DLDS) and
     (Self.GetFieldValueAsString('PMState_ID') = cMQ_BOD_PMState_ID_VYRIZENO) then
    Self.SetFieldValueAsString('PMState_ID', cMQ_BOD_PMState_ID_SYNC_READY);
end;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrigExternalValue, mFilename, mInstanceKey, mReport_ID, mPrinterName:string;
 mBool:Boolean;
begin
  if osNew in Self.State then
    Set_BillOfDelivery_Orders_Processing(Self);

  self.GetOriginalValue('X_ExternalID',mOrigExternalValue);
  if not(NxIsEmptyOID(self.GetFieldValueAsString('X_ExternalID'))) and NxIsEmptyOID(mOrigExternalValue) then begin
     mReport_ID:='4000000001';
     mInstanceKey:='SK';
     mPrinterName:=cPrinterNameA4;
     mFileName:=Api_get_pdf(self.ObjectSpace,mInstanceKey,'billsofdelivery/'+self.GetFieldValueAsString('X_ExternalID')+'?select=id&report='+mReport_ID,self.GetFieldValueAsString('X_ExternalID')+'.pdf');
     CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LA','Use '+self.GetFieldValueAsString('X_ExternalID')+'.pdf','',ltScripting,Now);
     if FileExists(mFilename) then begin
      //mBool:=ShellAPI.PrintFile(mFilename,mPrinterName);
       mBool := ShellAPI.Execute(
                'open',
                'C:\ABRA_CZ\_exe\PDFXCview\PDFXCview.exe',
                '/printto '+mPrinterName+' "' + mFileName + '"',
                'C:\ABRA_CZ\_exe\PDFXCview'
              );
      CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LA','Print  #'+BoolToStr(mBool,true)+'#',NxGetUserName+NxCrlF+mFilename,ltScripting,Now);

     end;
  end;
end;



begin
end.
