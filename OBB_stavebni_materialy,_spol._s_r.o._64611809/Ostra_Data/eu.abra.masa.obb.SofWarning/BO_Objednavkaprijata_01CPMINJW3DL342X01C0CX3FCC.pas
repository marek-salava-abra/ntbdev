
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mCount1, mCount2, mcount3:extended;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mDLList:TStringList;
 mDL_ID:string;
 mDeliveredQuantity:extended;
begin
 mDL_ID:='';
 mDeliveredQuantity:=0;
 if not(self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='09698507') then begin
  //mDLList:=TStringList.create;
  //self.ObjectSpace.SQLSelect(Format('select id from storedocuments2 where provide_id=''%s''',[self.OID]),mDLList);
  //if mDLList.count>0 then mDL_ID:=mDLList.Strings[0];
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    for i:=0 to mRows.CountOfNotDeleted-1 do begin
      mDeliveredQuantity:=mDeliveredQuantity+mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity');
    end;
 if (osnew in self.State) or not(mDeliveredQuantity=0) then begin
  AResult:=True;
  mCount1:=0;
  mCount2:=0;
    mCount3:=0;
  //mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  for i:=0 to mRows.CountOfNotDeleted-1 do begin
    if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
      if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='E300000101' then mCount1:=mCount1+mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity');
      if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='#000000302' then mCount2:=mCount2+mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity');
      if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='~000000502' then mCount3:=mCount3+mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity');
    end;
  end;
  if mCount1>0 then begin
   if not(mCount1=mCount2) then begin
    if NxMessageBox('Upozornění','Objednávka POZOR fakturované množství vratných palet je '+FloatToStr(mCount1)+' ks, fakturované opotřebení je '+FloatToStr(mCount2)+' ks. Přejete si doklad uložit?', mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes
     then AResult:=True else begin
       AResult:=False;
       self.AddValidateError(self.GetFieldCode('Description'),'Vracím do dokladu, přidejte opotřebení.');
     end;
   end;
   if not(mCount1=mCount3) then begin
    if NxMessageBox('Upozornění','Objednávka POZOR fakturované množství vratných palet je '+FloatToStr(mCount1)+' ks, manipulace je '+FloatToStr(mCount3)+' ks. Přejete si doklad uložit?', mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes
     then AResult:=True else begin
       AResult:=False;
       self.AddValidateError(self.GetFieldCode('Description'),'Vracím do dokladu, přidejte manipulaci.');
     end;
   end;
  end;
  end;
  end;
end;


begin
end.