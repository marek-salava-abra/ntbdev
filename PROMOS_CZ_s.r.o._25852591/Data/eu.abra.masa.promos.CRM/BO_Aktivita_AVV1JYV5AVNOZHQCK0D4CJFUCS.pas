{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mSCBO,mReceiptCardROWBO:TNxCustomBusinessObject;
 mReceiptCardBO, mRelation:TNxCustomBusinessObject;
 mStoreCard_ID, mRelation_ID, mFirm_ID, mCode:string;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
 mNumericPart:integer;
begin
  if self.GetFieldValueAsBoolean('X_CreateSC') then begin
     mOS:=self.ObjectSpace;
     mRelation_ID:=mOS.SQLSelectFirstAsString('Select rightside_id from relations where rel_def=1245 and leftside_id='+QuotedStr(self.OID),'');
     if NxIsEmptyOID(mRelation_ID) then begin
     mCode:=mOS.SQLSelectFirstAsString('Select max(code) from storecards where hidden=''N'' and code like '+QuotedStr('SV'+AnsiRightStr(self.GetFieldValueAsString('Period_ID.Code'),2)+'____'),'');
     if NxIsBlank(mCode) then begin
        mCode:='SV'+AnsiRightStr(self.GetFieldValueAsString('Period_ID.Code'),2)+'0001';
     end else begin
        mCode:='SV'+AnsiRightStr(self.GetFieldValueAsString('Period_ID.Code'),2)+AnsiRightStr('000'+inttostr(StrToInt(AnsiRightStr(mCode,4))+1),4);
     end;
     mFirm_ID:=self.GetFieldValueAsString('Firm_ID');
     mSCBO:=mOS.CreateObject(Class_StoreCard);
     mSCBO.new;
     mSCBO.prefill;
     mSCBO.SetFieldValueAsString('Code',mCode);
     if not(NxIsEmptyOID(self.GetFieldValueAsString('X_StoreCard_ID'))) then
      mSCBO.SetFieldValueAsString('Name','Servis '+self.GetFieldValueAsString('X_StoreCard_ID.Name')) else
      mSCBO.SetFieldValueAsString('Name', 'Servis '+self.GetFieldValueAsString('X_Name'));
     mscbo.SetFieldValueAsString('StoreCardCategory_ID','3000000101');
     mSCBO.SetFieldValueAsString('VatRate_ID','02100X0000');
     mSCBO.save;
     mStoreCard_ID:=mSCBO.OID;
     mSCBO.free;
     //tady založit kartu, kód struktura SVXXYYYY kde SV pevny XX poslední dvojčíslí roku, YYYY pořadí v roku
     // příjemka na sklad 1000000101 řada dokladů 1B70000101, firma z aktivity, vytvořit vazbu na aktivitu
     mReceiptCardBO:=mOS.CreateObject(Class_ReceiptCard);
     mReceiptCardBO.New;
     mReceiptCardBO.Prefill;
     if NxIsEmptyOID(mFirm_ID) then mReceiptCardBO.SetFieldValueAsString('Firm_ID','AAA1000000');
     if not(NxIsEmptyOID(mFirm_id)) then mReceiptCardBO.SetFieldValueAsString('Firm_ID',mFirm_id);
     mReceiptCardBO.SetFieldValueAsString('DocQueue_ID','1B70000101');
     mReceiptCardBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
     mrows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
     mReceiptCardROWBO:=mrows.AddNewObject;
     mReceiptCardROWBO.SetFieldValueAsInteger('RowType',3);
     mReceiptCardROWBO.SetFieldValueAsString('Store_ID','1000000101');
     mReceiptCardROWBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
     mReceiptCardROWBO.SetFieldValueAsString('Division_ID','1000000101');
     mReceiptCardROWBO.SetFieldValueAsFloat('Quantity',1);
     mReceiptCardROWBO.SetFieldValueAsFloat('UnitPrice',0);
     mReceiptCardROWBO.SetFieldValueAsFloat('TotalPrice',0);
     mReceiptCardROWBO.SetFieldValueAsBoolean('CompletePrices',true);
     mReceiptCardBO.save;


     mRelation := mOS.CreateObject(Class_Relation);
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', self.OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mReceiptCardBO.OID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1245);
      mRelation.Save;
     mRelation.free;
    mReceiptCardBO.Free;
    end;
  end;
end;

begin
end.