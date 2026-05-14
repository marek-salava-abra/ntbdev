
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 mCount:integer;
begin
 mCount:=self.OutputDocument.ObjectSpace.SQLSelectFirstAsInteger('Select count(id) from FIRMASSORTMENTDISCOUNTS where parent_id='+QuotedStr(self.OutputDocument.GetFieldValueAsString('Firm_ID')),0);
 if mCount>0 then begin
  self.OutputDocument.SetFieldValueAsBoolean('FrozenDiscounts',false);
  self.OutputDocument.SetFieldValueAsInteger('DealerDiscountKind',3);
 end;
end;

begin
end.