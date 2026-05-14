{
Volá se po uzavření účtenky.
}
procedure AfterCloseDocument_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject);
begin
  if (aDocument.GetFieldValueAsString('SellingStand_ID')='D300000101') or (aDocument.GetFieldValueAsString('SellingStand_ID')='A410000101') then begin

    adocument.SetFieldValueAsString('Description2',InputBox('Důvod odpisu','Co je důvodem odpisu?',''));
    aDocument.save;
  end;
  {if (aDocument.GetFieldValueAsString('SellingStand_ID')='1800000101') then begin

    adocument.SetFieldValueAsString('U_Hodiny',InputBox('Počet hodin','Počet hodin na place?',''));
    adocument.SetFieldValueAsString('U_Obsluha',InputBox('Kdo obsluhoval','Kdo obsluhoval?',''));
    aDocument.save;
  end; }
end;

begin
end.