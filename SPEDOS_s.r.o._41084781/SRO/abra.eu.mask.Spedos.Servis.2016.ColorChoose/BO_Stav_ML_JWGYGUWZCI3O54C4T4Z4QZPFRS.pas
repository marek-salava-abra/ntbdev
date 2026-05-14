

{
Vyvoláva sa po zmene každej položky. A to len, pokiaľ k tejto zmene nedochádza vďaka načítaniu objektu z databázy alebo vďaka vytváraniu kópie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=Self.GetFieldCode('X_Color')) and (AValue.AsInteger<>AOriginalValue.AsInteger) then begin
    //UpdateChildColors(Self);
  end;
end;

procedure UpdateChildColors(ABO: TNxCustomBusinessObject);
var mSQL:String;
begin
  mSQL:=Format('Update ServicedObjects SO set X_Color=%s where ID in (Select ID from SYS$ServicedObjects2 where Superior_ID=%s)',[IntToStr(ABO.GetFieldValueAsInteger('X_Color')), QuotedStr(ABO.OID)]);
  ABO.ObjectSpace.SQLExecute(mSQL);
end;

begin
end.