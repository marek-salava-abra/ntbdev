
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mCount1, mCount2, mCount3:extended;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
 if not(self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='09698507') then begin
  AResult:=True;
  mCount1:=0;
  mCount2:=0;
  mCount3:=0;
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  for i:=0 to mRows.CountOfNotDeleted-1 do begin
    if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
      if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='E300000101' then mCount1:=mCount1+mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity');
      if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='#000000302' then mCount2:=mCount2+mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity');
      if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='~000000502' then mCount3:=mCount3+mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity');
    end;
  end;
   if mCount1>0 then begin
     if not(mCount1=mCount2) then begin
      if NxMessageBox('Upozornění','Dodací list POZOR fakturované množství vratných palet je '+FloatToStr(mCount1)+' ks, fakturované opotřebení je '+FloatToStr(mCount2)+' ks. Přejete si doklad uložit?', mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes
       then AResult:=True else begin
         AResult:=False;
         self.AddValidateError(self.GetFieldCode('Description'),'Vracím do dokladu, přidejte opotřebení.');
       end;
     end;
     if not(mCount1=mCount3) then begin
        if NxMessageBox('Upozornění','Dodací list POZOR fakturované množství vratných palet je '+FloatToStr(mCount1)+' ks, manipulace je '+FloatToStr(mCount3)+' ks. Přejete si doklad uložit?', mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes
         then AResult:=True else begin
           AResult:=False;
           self.AddValidateError(self.GetFieldCode('Description'),'Vracím do dokladu, přidejte manipulaci.');
         end;
       end;
   end;
  end;
end;

begin
end.