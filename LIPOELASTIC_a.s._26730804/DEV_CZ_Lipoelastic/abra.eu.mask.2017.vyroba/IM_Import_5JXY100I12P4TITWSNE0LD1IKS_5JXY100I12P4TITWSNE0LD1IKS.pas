

{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
   // if (self.InputDocument.GetFieldValueAsString('U_PrintLink')<>'') then self.OutputDocument.SetFieldValueAsString('U_PrintLink',self.InputDocument.GetFieldValueAsString('U_PrintLink'));
   // if (self.InputDocument.GetFieldValueAsString('X_poznamka')<>'') then self.OutputDocument.SetFieldValueAsString('X_poznamka',self.InputDocument.GetFieldValueAsString('X_poznamka'));
    //self.OutputDocument.SetFieldValueAsBoolean('WithPrices',false);

end;

procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
 mBusProject_ID, mDivision_ID:String;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reOLEAutomation then begin
     if not(NxIsEmptyOID(aOutputRow.GetFieldValueAsString('Parent_ID.Firm_ID'))) then begin
       mBusProject_ID:=aOutputRow.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID');
       if not(NxIsEmptyOID(mBusProject_ID)) then begin
        mDivision_ID:=aOutputRow.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID.Division_ID');
       end;
       if not(NxIsEmptyOID(mBusProject_ID)) then aOutputRow.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
       if not(NxIsEmptyOID(mDivision_ID)) then aOutputRow.SetFieldValueAsString('Division_ID',mDivision_ID);
      end;
  end;
  if NxIsEmptyOID(AnInputRow.GetFieldValueAsString('Parent_ID.U_SKIssuedOrder_ID')) then begin
   //zakomentováno MASA 12:17 29.12.2025
   {if aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID')='7B10000101' then begin
      aOutputRow.SetFieldValueAsString('Store_ID','1120000101');
      aOutputRow.SetFieldValueAsString('Division_ID','6700000101');
   end;


   if not NxIsEmptyOID(aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID.X_Store_ID')) then aOutputRow.SetFieldValueAsString('Store_ID',aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID.X_Store_ID'));
   if not NxIsEmptyOID(aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID.X_STREDISKO')) then aOutputRow.SetFieldValueAsString('Division_ID',aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID.X_STREDISKO'));
   }

  // if not NxIsBlank(aOutputRow.GetFieldValueAsString('Parent_id.U_PrintLink')) then
  //           aOutputRow.SetFieldValueAsString('Parent_id.U_PrintLink',AnInputRow.GetFieldValueAsString('Parent_id.U_PrintLink'));
 if not NxIsEmptyOID(aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID.X_Store_ID')) then aOutputRow.SetFieldValueAsString('Store_ID',aOutputRow.GetFieldValueAsString('Parent_id.Docqueue_ID.X_Store_ID'));
 if not NxIsBlank(aOutputRow.GetFieldValueAsString('Parent_id.X_poznamka')) then
             aOutputRow.SetFieldValueAsString('Parent_id.X_poznamka',AnInputRow.GetFieldValueAsString('Parent_id.X_poznamka'));

 end;
end;

begin
end.