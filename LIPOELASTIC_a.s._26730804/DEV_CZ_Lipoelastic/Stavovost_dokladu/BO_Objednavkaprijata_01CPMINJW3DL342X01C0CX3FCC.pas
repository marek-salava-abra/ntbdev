uses '_Knihovny_ALL.Stavovost';


{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
  var
mPLState_ID:string;
mi:integer;
begin
//NxShowSimpleMessage(NxCreateContext_1(self).GetCompanyCache.GetUserID,nil);
  if NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID='SUPER00000' then begin

        mPLState_ID:='' ;
        mPLState_ID:=ReceivedOrder_State_ID(Self);
                if mPLState_ID<>'' then begin
                      if self.GetFieldValueAsString('PMState_ID')<>mPLState_ID then begin
                           mi:=self.ObjectSpace.SQLExecute('update Receivedorders set PMState_ID=' + QuotedStr(mPLState_ID) + ' where id=' + quotedstr(self.oid));
                //           self.SetFieldValueAsString('PMState_ID',mPLState_ID);
                      end;
                end;
  end;
end;

procedure New_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsString('PMState_ID','1000000101');

end;



{
Umožňuje ovlivnit validaci.

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mPLState_ID:string;
begin
mPLState_ID:='' ;
mPLState_ID:=ReceivedOrder_State_ID(Self);
if mPLState_ID<>'' then begin
      if self.GetFieldValueAsString('PMState_ID')<>mPLState_ID then begin
           self.SetFieldValueAsString('PMState_ID',mPLState_ID);
      end;
end;

end;}








begin
end.