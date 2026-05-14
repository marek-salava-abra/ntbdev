procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
 if not NxIsBlank(self.OutputDocument.GetFieldValueAsString('X_poznamka')) then
             self.OutputDocument.SetFieldValueAsString('X_poznamka',self.InputDocument.GetFieldValueAsString('X_poznamka'));

 if not NxIsBlank(self.OutputDocument.GetFieldValueAsString('X_Poznam_exp')) then
             self.OutputDocument.SetFieldValueAsString('X_Poznam_exp',self.InputDocument.GetFieldValueAsString('X_Poznam_exp'));

 if not NxIsBlank(self.OutputDocument.GetFieldValueAsString('X_Poznam_exp_ext')) then
             self.OutputDocument.SetFieldValueAsString('X_Poznam_exp_ext',self.InputDocument.GetFieldValueAsString('X_Poznam_exp_ext'));
end;


{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
mr:tstringlist;
os:TNxCustomObjectSpace;
mBO_PohybSarze,mBO_PohybSarzeNew:TNxCustomBusinessObject;
i:integer;
begin
   mr:=tstringlist.create;
   os:=AInputRow.ObjectSpace;

//      NxShowSimpleMessage('sarze',nil);
       // dohledání pohybu šarže
       try
            os.SQLSelect('SELECT a.ID FROM DefRollData A where A.CLSID = ' +
            quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' and a.X_Parent_ID=' + quotedstr(AInputRow.oid),mr) ;
            if mr.count>0 then begin
                   for i := 0 to mr.Count-1 do begin




                        mBO_PohybSarze:= os.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
  //                      NxShowSimpleMessage('nahr8t9 sarye',nil);
                        mBO_PohybSarze.load(mr.Strings[i] , nil);
                        //NxShowSimpleMessage('sarze ' + mr.Strings[i],nil);


                        mBO_PohybSarzeNew:= os.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                        mBO_PohybSarzeNew.new;
    //                    NxShowSimpleMessage('yakladani say2',nil);
                        mBO_PohybSarzeNew.Prefill;



                        mBO_PohybSarzeNew.SetFieldValueAsFloat('X_quantity',mBO_PohybSarze.GetFieldValueAsFloat('X_quantity'));
                        mBO_PohybSarzeNew.SetFieldValueAsstring('Code',aOutputRow.GetFieldValueAsString('Parent_id'));
                                    mBO_PohybSarzeNew.SetFieldValueAsstring('X_Parent_ID',aOutputRow.OID);
                                    mBO_PohybSarzeNew.SetFieldValueAsstring('X_Parent2_ID',aOutputRow.getFieldValueAsString('StoreCard_ID'));
                        mBO_PohybSarzeNew.SetFieldValueAsstring('X_Storecard_ID',aOutputRow.getFieldValueAsString('StoreCard_ID'));
                        mBO_PohybSarzeNew.SetFieldValueAsstring('X_Batches',mBO_PohybSarze.getFieldValueAsstring('X_Batches'));
                        mBO_PohybSarzeNew.SetFieldValueAsstring('Name', mBO_PohybSarze.getFieldValueAsstring('name'));
                        mBO_PohybSarzenew.save;
                        try


                        finally
                             mBO_PohybSarze.Free;
                            mBO_PohybSarzenew.Free;
                        end;
                  end;
             end;
      finally
          mr.free;
       end;




end;

begin
end.