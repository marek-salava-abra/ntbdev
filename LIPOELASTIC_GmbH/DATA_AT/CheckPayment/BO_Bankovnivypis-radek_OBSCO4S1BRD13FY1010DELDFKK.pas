uses 'CheckPayment.lib';
{
Triggered after saving object data in the database.
}
{
Triggered after the physical deletion of an actual object from the database.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
    mID:string;
    mBORO:TNxCustomBusinessObject;

begin
  if self.getfieldvalueasstring('PDocumentType')='10' then begin
       mID:='';
       mID:=self.ObjectSpace.SQLSelectFirstAsString('select ro.id from receivedorders ro join issueddinvoices ZL on zl.ReceivedOrder_ID=ro.id where zl.id='
       + quotedstr(self.getfieldvalueasstring('PDocument_ID')));
       if mid<>'' then begin
            mBORO:=self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
            try
                mboro.load(mID,nil);
                    mboro.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                    mboro.SetFieldValueAsString('PMState_ID','~000000003')  ;
                mboro.save;

                    if mdebug then NXshowsimplemessage('Saving status' +  mboro.DisplayName  ,nil);
            finally
                mboro.free;
            end;
       end;

  end;
end;




procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
    mID:string;
    mBORO:TNxCustomBusinessObject;

begin
  if self.getfieldvalueasstring('PDocumentType')='10' then begin
       mID:='';
       mID:=self.ObjectSpace.SQLSelectFirstAsString('select ro.id from receivedorders ro join issueddinvoices ZL on zl.ReceivedOrder_ID=ro.id where zl.id='
       + quotedstr(self.getfieldvalueasstring('PDocument_ID')));
       if mid<>'' then begin
            mBORO:=self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
            try
                mboro.load(mID,nil);
                    mboro.SetFieldValueAsString('X_PaymentStatus_ID','~000000ORZ');
                    mboro.SetFieldValueAsString('PMState_ID','~000000004')  ;
                mboro.save;

                    if mdebug then NXshowsimplemessage('Saving status' +  mboro.DisplayName  ,nil);
            finally
                mboro.free;
            end;
       end;

  end;
end;



begin
end.