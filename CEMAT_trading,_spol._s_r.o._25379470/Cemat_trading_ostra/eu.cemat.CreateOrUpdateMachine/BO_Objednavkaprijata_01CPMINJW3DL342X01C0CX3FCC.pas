{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('U_machine_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
     Self.SetFieldValueAsString('U_Type_ID',self.GetFieldValueAsString('U_machine_ID.U_Type_ID'));
     self.SetFieldValueAsString('U_Mark_ID',self.GetFieldValueAsString('U_machine_ID.U_Mark_ID'));
     self.SetFieldValueAsString('U_Mark_PZ_ID',self.GetFieldValueAsString('U_machine_ID.U_Mark_PZ_ID'));
     self.SetFieldValueAsString('U_Model',self.GetFieldValueAsString('U_machine_ID.U_Model'));
     Self.SetFieldValueAsString('U_SerialNR',self.GetFieldValueAsString('U_machine_ID.U_SerialNR'));
     Self.SetFieldValueAsDateTime('U_Date_MH',self.GetFieldValueAsDateTime('U_machine_ID.U_Date_MH'));
     Self.SetFieldValueAsFloat('U_MH',self.GetFieldValueAsFloat('U_machine_ID.U_MH'));
     self.SetFieldValueAsString('U_Model_PZ',self.GetFieldValueAsString('U_machine_ID.U_Model_PZ'));
     self.SetFieldValueAsString('U_Type_PZ_ID',self.GetFieldValueAsString('U_machine_ID.U_Type_PZ_ID'));
     self.SetFieldValueAsString('U_Typ_pneu_ID',self.GetFieldValueAsString('U_machine_ID.U_typ_pneu_ID'));
     self.SetFieldValueAsString('U_typ_pasu_ID',self.GetFieldValueAsString('U_machine_ID.U_Typ_pasu_ID'));
     self.SetFieldValueAsString('U_sirka_p_ID',self.GetFieldValueAsString('U_machine_ID.U_sirka_p_ID'));
     self.SetFieldValueAsString('U_sirka_z_ID',self.GetFieldValueAsString('U_machine_ID.U_sirka_z_ID'));
     self.SetFieldValueAsString('U_profil_p_ID',self.GetFieldValueAsString('U_machine_ID.U_profil_p_ID'));
     self.SetFieldValueAsString('U_profil_z_ID',self.GetFieldValueAsString('U_machine_ID.U_profil_z_ID'));
     Self.SetFieldValueAsString('U_prumer_rafku_p_ID',self.GetFieldValueAsString('U_machine_ID.U_prumer_rafku_p_ID'));
     self.SetFieldValueAsString('U_prumer_rafku_z_ID',self.GetFieldValueAsString('U_machine_ID.U_prumer_rafku_z_ID'));
     self.SetFieldValueAsString('U_celkovy_prumer_p_ID',self.GetFieldValueAsString('U_machine_ID.U_celkovy_prumer_p_ID'));
     self.SetFieldValueAsString('U_celkovy_prumer_z_ID',self.GetFieldValueAsString('U_machine_ID.U_celkovy_prumer_z_ID'));
     self.SetFieldValueAsString('U_platna_p_ID',self.GetFieldValueAsString('U_machine_ID.U_platna_p_ID'));
     self.SetFieldValueAsString('U_platna_z_ID',self.GetFieldValueAsString('U_machine_ID.U_platna_z_ID'));


  end;
end;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
Var
 mMachineBO:TNxCustomBusinessObject;
begin
  if NxIsEmptyOID(self.GetFieldValueAsString('U_Machine_ID')) then begin
   if not(NxIsEmptyOID(self.GetFieldValueAsString('U_Type_ID'))) and not(NxIsEmptyOID(self.GetFieldValueAsString('U_Mark_ID'))) then begin
     mMachineBO:=self.ObjectSpace.CreateObject('DK4IQ0V3L5EORHQYMUBJLYHF0O');
     mMachineBO.new;
     mMachineBO.prefill;
     mMachineBO.SetFieldValueAsString('U_Type_ID',self.GetFieldValueAsString('U_Type_ID'));
     mMachineBO.SetFieldValueAsString('U_Mark_ID',self.GetFieldValueAsString('U_Mark_ID'));
     mMachineBO.SetFieldValueAsString('U_Mark_PZ_ID',self.GetFieldValueAsString('U_Mark_PZ_ID'));
     mMachineBO.SetFieldValueAsString('U_Model',self.GetFieldValueAsString('U_Model'));
     mMachineBO.SetFieldValueAsString('U_SerialNR',self.GetFieldValueAsString('U_SerialNR'));
     mMachineBO.SetFieldValueAsDateTime('U_Date_MH',self.GetFieldValueAsDateTime('U_Date_MH'));
     mMachineBO.SetFieldValueAsFloat('U_MH',self.GetFieldValueAsFloat('U_MH'));
     mMachineBO.SetFieldValueAsString('U_Model_PZ',self.GetFieldValueAsString('U_Model_PZ'));
     mMachineBO.SetFieldValueAsString('U_Type_PZ_ID',self.GetFieldValueAsString('U_Type_PZ_ID'));
     mMachineBO.SetFieldValueAsString('U_Typ_pneu_ID',self.GetFieldValueAsString('U_typ_pneu_ID'));
     mMachineBO.SetFieldValueAsString('U_typ_pasu_ID',self.GetFieldValueAsString('U_Typ_pasu_ID'));
     mMachineBO.SetFieldValueAsString('U_sirka_p_ID',self.GetFieldValueAsString('U_sirka_p_ID'));
     mMachineBO.SetFieldValueAsString('U_sirka_z_ID',self.GetFieldValueAsString('U_sirka_z_ID'));
     mMachineBO.SetFieldValueAsString('U_profil_p_ID',self.GetFieldValueAsString('U_profil_p_ID'));
     mMachineBO.SetFieldValueAsString('U_profil_z_ID',self.GetFieldValueAsString('U_profil_z_ID'));
     mMachineBO.SetFieldValueAsString('U_prumer_rafku_p_ID',self.GetFieldValueAsString('U_prumer_rafku_p_ID'));
     mMachineBO.SetFieldValueAsString('U_prumer_rafku_z_ID',self.GetFieldValueAsString('U_prumer_rafku_z_ID'));
     mMachineBO.SetFieldValueAsString('U_celkovy_prumer_p_ID',self.GetFieldValueAsString('U_celkovy_prumer_p_ID'));
     mMachineBO.SetFieldValueAsString('U_celkovy_prumer_z_ID',self.GetFieldValueAsString('U_celkovy_prumer_z_ID'));
     mMachineBO.SetFieldValueAsString('U_platna_p_ID',self.GetFieldValueAsString('U_platna_p_ID'));
     mMachineBO.SetFieldValueAsString('U_platna_z_ID',self.GetFieldValueAsString('U_platna_z_ID'));
     mMachineBO.SetFieldValueAsString('U_firm_ID',self.GetFieldValueAsString('Firm_ID'));
     mMachineBO.save;
     self.SetFieldValueAsString('U_machine_ID',mMachineBO.OID);
     mMachineBO.free;
   end;
  end;
  if not(NxIsEmptyOID(self.GetFieldValueAsString('U_Machine_ID'))) then begin
    mMachineBO:=self.ObjectSpace.CreateObject('DK4IQ0V3L5EORHQYMUBJLYHF0O');
    mMachineBO.Load(self.GetFieldValueAsString('U_Machine_ID'),nil);
    mMachineBO.SetFieldValueAsDateTime('U_Date_MH',self.GetFieldValueAsDateTime('U_Date_MH'));
    mMachineBO.SetFieldValueAsFloat('U_MH',self.GetFieldValueAsFloat('U_MH'));
    mMachineBO.save;
    mMachineBO.free;
  end;
end;



begin
end.