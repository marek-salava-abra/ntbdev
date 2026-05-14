{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mPrinterName, mIDSestavy:string;
 mList:TStringList;
begin
  Try
  if self.GetFieldValueAsBoolean('Ended') then begin
   mPrinterName:='INEO_224E_Obchodni';
   mIDSestavy:='1000000101';
   mlist:=TStringList.Create;
   self.ObjectSpace.SQLSelect(format('Select id from posdocuments where POSReceipt_ID=''%s'' ',[self.OID]),mlist);
   CFxReportManager.PrintByIDs(NxCreateContext_1(self),mlist,'Z4ZRYGMNAJEL3JY400C5PPZRN0',mIDSestavy,rtoPrint,pekPDF,mPrinterName,'');
   mList.free;
  end;
  except
    NxShowSimpleMessage(ExceptionMessage,nil);
  end;
end;

begin
end.