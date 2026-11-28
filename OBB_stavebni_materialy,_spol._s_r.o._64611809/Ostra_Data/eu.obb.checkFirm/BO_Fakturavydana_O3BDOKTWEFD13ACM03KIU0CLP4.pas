

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mDueDate:Extended;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 AfterDueTerm:Extended;
 AfterDueTermEnabled:Boolean;
begin

  if (AFieldCode=Self.GetFieldCode('Firm_ID')) and (avalue.AsString=AOriginalValue.asstring) then begin
   if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) and (osNew in self.state) then begin
    AfterDueTerm:=0;
    mDueDate:=0;
    if self.GetFieldValueAsBoolean('Firm_ID.AfterDueTermEnabled') then AfterDueTerm:= self.GetFieldValueAsFloat('Firm_ID.AfterDueTerm');
    mList:=TStringList.Create;
    self.ObjectSpace.SQLSelect(format('Select min(DueDate$Date) from issuedinvoices  where firm_id=''%s'' and (amount-paidamount)-(creditamount-paidcreditamount)>0',[self.GetFieldValueAsString('Firm_ID')]),mList);
    mDueDate:=StrToFloat(mList.Strings[0]);
    if (mDueDate+AfterDueTerm<trunc(Date)) and (mDueDate>0) then


    NxShowSimpleMessage('Firma '+self.GetFieldValueAsString('Firm_ID.Name')+ ' překročila splatnost včetně nastavené tolerance. Doklad nebude možno uložit.',nil);
    end;
  end;
end;

begin
end.