{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
mr:tstringlist;
i:integer;
mBO_pohyb_sarze,mdocrowbatches:TNxCustomBusinessObject;
mBO_Moniker:TNxCustomBusinessMonikerCollection;
begin
  // if false then begin
    if not(CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin
     //if AInputRow.GetFieldValueAsInteger('Storecard_ID.Category') =2 then begin
             mr:=TStringList.create;
                  try
                       AInputRow.ObjectSpace.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ''EC2R2HSFK5UOZ5MYVJWJOHUC4S'' and A.X_Parent_ID ='+quotedstr(AInputRow.oid),mr);
                       if mr.count>0 then begin
                            mBO_pohyb_sarze:=AInputRow.ObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                            try
                                 for i:=0 to mr.count-1 do begin
                                           mBO_pohyb_sarze.load(mr.strings[i],nil);
                                           //NxShowSimpleMessage(mBO_pohyb_sarze.GetFieldValueAsString('Name'),nil);


                                              mBO_Moniker:=aOutputRow.GetLoadedCollectionMonikerForFieldCode(aOutputRow.GetFieldCode('DocRowBatches'));

                                                                         mdocrowbatches:=mBO_Moniker.AddNewObject;

                                                                          mdocrowbatches.Prefill;
                                                                          mdocrowbatches.setFieldValueAsstring('QUnit',AInputRow.getFieldValueAsString('QUnit'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Unitrate',AInputRow.GetFieldValueAsFloat('unitrate'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Quantity',mBO_pohyb_sarze.GetFieldValueAsFloat('X_quantity'));
                                                                          mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mBO_pohyb_sarze.GetFieldValueAsstring('X_Batches'));
                                                                          {

                                                                          mBO_Moniker.BusinessObject[i].SetFieldValueAsstring('Parent_ID',AInputRow.getFieldValueAsstring('ID'));


                                                                          mBO_Moniker.BusinessObject[i].setFieldValueAsstring('StoreBatch_ID',mBO_pohyb_sarze.GetFieldValueAsstring('X_Parent_ID'));
                                                                          }


                                 end;


                            finally
                                mBO_pohyb_sarze.free;
                            end;
                       end;
                  finally
                      mr.free;
                  end;
     end;
end;

begin
end.