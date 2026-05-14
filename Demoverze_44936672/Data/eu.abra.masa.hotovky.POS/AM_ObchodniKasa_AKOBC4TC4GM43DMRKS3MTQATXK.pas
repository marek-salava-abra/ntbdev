

{
Vyvolá se, když se nezdaří hledání skladové karty. (Pokud se místo ID dílčí skladové karty vrátí text ABORT, vyhledávání se ukončí bez jakékoli zprávy na kase.)
}
procedure AfterSearchStoreCardError_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aHookStoreUnit_OID: TNxOID; aInput: string);
var
 mInvoice_ID, mTyp, mMessage:String;
 mInvoiceBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
  if Length(aInput)=14 then begin
   mInvoice_ID:=Copy(aInput,5,10);
   mTyp:=Copy(aInput,2,2);
   if mTyp='03' then begin
      aHookStoreUnit_OID  := 'ABORT';
   end;
  end;

end;




{
Volá se před zpracováním příkazové řádky.
}
procedure BeforeAnalyzeInputRow_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; aMode: byte; aInputRow: string);
var
 mInvoice_ID, mTyp, mMessage:String;
 mInvoiceBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
  if Length(aInputRow)=14 then begin
   //aHookStoreUnit_OID  := 'ABORT';
   mInvoice_ID:=Copy(aInputRow,5,10);
   mTyp:=Copy(aInputRow,2,2);
   if mTyp='03' then begin
     mOS:=AContext.GetObjectSpace;
     try
       mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
       mInvoiceBO.Load(mInvoice_ID,nil);
       mMessage:='Přejete si označit fakturu '+mInvoiceBO.DisplayName+' pro zákazníka '+mInvoiceBO.GetFieldValueAsString('Firm_ID.Name')+#13#10+' ulice '+
                 mInvoiceBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.street')+' jako vyzvednutou?';
       if NxMessageBox('Dotaz', mMessage, mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
         mInvoiceBO.SetFieldValueAsString('Description','Vyzvednuto');
         mInvoiceBO.save;
       end;
     mInvoiceBO.free;
     except
          RaiseException(ExceptionMessage);
     end;
   end;
  end;
end;

begin
end.