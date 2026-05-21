uses 'CheckPayment.lib';
{
Umožňuje ovlivnit validaci.
}
{
Triggered after saving object data in the database.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
//     if  Self.getFieldValueAsString('X_PaymentStatus_ID')='~000000ORZ' then begin
//        if (Self.getFieldValueAsString('PMState_ID')='~000000002')  then begin
//              Self.PMChangeStateByTransition('~000000005'); // změnit dle hodnot PMStates.ID v konkrétní instalaci
//        end;
//        if (Self.getFieldValueAsString('PMState_ID')='~000000003')  then begin
//              Self.PMChangeStateByTransition('~00000000A'); // změnit dle hodnot PMStates.ID v konkrétní instalaci
//        end;

//     end;
end;






procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
     mTJSONSuperObject:TJSONSuperObject;
     mbopay:TNxCustomBusinessObject;
 begin
  if self.getfieldvalueasstring('Docqueue_ID.code')='ASOC' then begin
            try
             if not nxisemptyoid(self.getfieldvalueasstring('X_payment_ID')) then begin
                       mTJSONSuperObject:=CheckPayment(self);
                   // if mbo.getfieldvalueasfloat('Amount') = nxibstrtofloat( mTJSONSuperObject.S['amount.value']) then begin

                          case mTJSONSuperObject.S['status'] of
                                    'paid': begin

                                               mbopay:=Self.objectspace.createobject('4MUQWZQK1Q1OP2LF40ST0232US');
                                                       try
                                                           mbopay.load(Self.getFieldValueAsString('X_payment_ID'),nil);
                                                           mbopay.SetFieldValueAsString('X_URL',mTJSONSuperObject.S['_links.dashboard.href']);
                                                           mbopay.save;
                                                           if mdebug then NXshowsimplemessage(mTJSONSuperObject.S['_links.dashboard.href'],nil);
                                                       finally
                                                           mbopay.free;
                                                       end;
                                                Self.SetFieldValueAsString('X_PaymentStatus_ID','~000000ORZ');
                                                if Self.getFieldValueAsString('PMState_ID')='~000000002' then begin
                                                     Self.SetFieldValueAsString('PMState_ID','~000000004')  ;
                                                end;

                                            end;
                                    'unpaid': begin
                                                Self.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                                                //Self.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                if Self.getFieldValueAsString('PMState_ID')='~000000002'  then begin                                                      Self.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                      Self.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                end;
                                            end;

                          end;



                          if Self.getFieldValueAsString('PMState_ID')='~000000003'  then begin
                                   if (self.GetFieldValueAsDateTime('DocDate$DATE'))<=(date() - datedif) then begin
                                          self.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS1');
                                          self.SetFieldValueAsString('PMState_ID','~00000000C')  ;
                                   end;


                          end;




               end;
              finally
                   //mTJSONSuperObject.free;
            end;
      end;
end;




begin
end.


