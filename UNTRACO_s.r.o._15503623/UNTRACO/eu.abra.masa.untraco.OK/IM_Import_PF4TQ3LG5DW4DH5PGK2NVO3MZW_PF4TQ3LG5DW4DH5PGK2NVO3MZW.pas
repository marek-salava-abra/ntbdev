
{
Vyvolává se po vyplnění řádků výstupního dokladu importovacím managerem
}
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 i:integer;
 mIDS:string;
begin
    if self.InputDocuments[0].GetFieldValueAsString('DocQueue_ID')='10K0000101' then begin
        self.OutputDocument.SetFieldValueAsString('BankAccount_ID','1000000101');
        self.OutputDocument.SetFieldValueAsString('ConstSymbol_ID','0000008000');
        self.OutputDocument.SetFieldValueAsString('X_ES_ID',self.InputDocuments[0].GetFieldValueAsString('ExternalNumber'));
        for i:=0 to self.InputDocumentCount-1 do begin
          if i=0 then mIDS:=self.InputDocuments[0].OID
           else mIDS:=mIDS+'|'+self.InputDocuments[i].OID;
        end;
        self.OutputDocument.SetFieldValueAsString('X_IssuedOfferIDs',mIDS);
        self.OutputDocument.SetFieldValueAsBoolean('X_GoodsForHospital',True);
    end;
end;

begin
end.