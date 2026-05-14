{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
 try
  self.OutputDocument.SetFieldValueAsString('Firm_ID',self.InputDocument.getFieldValueAsString('Firm_ID'));
  self.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.InputDocument.getFieldValueAsString('FirmOffice_ID'));
  self.OutputDocument.SetFieldValueAsString('Description',self.InputDocument.getFieldValueAsString('Description'))   ;
  self.OutputDocument.SetFieldValueAsString('TransportationType_ID',self.InputDocument.getFieldValueAsString('TransportationType_ID'))   ;
  except

  end;
end;




procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
mr:tstringlist;
i,ii:integer;
mBO_Moniker_source,mBO_Moniker_target:TNxCustomBusinessMonikerCollection;
mdocrowbatches,mBO_prevodka_vydej:TNxCustomBusinessObject;
begin
mr:=tstringlist.create;
try
if not NxIsBlank(AInputRow.GetFieldValueAsString('U_Jmenopacienta')) then
aOutputRow.SetFieldValueAsString('U_Jmenopacienta',AInputRow.GetFieldValueAsString('U_Jmenopacienta'));


  if AInputRow.GetFieldValueAsInteger('Storecard_ID.Category')=2 then begin
  //    AInputRow.ObjectSpace.SQLSelect('Select sd2.id from receivedorders2 ro2 left join Storedocuments2 sd2 on sd2.ProvideRow_ID=ro2.id left join Storedocuments SD on sd.id=sd2.parent_ID left join DocRowBatches DRB on DRB.Parent_ID=sd2.id ' +
  //    ' where sd.documenttype=''22'' and RO2.X_ReceivedOrderRow_ID = ' + quotedstr(AInputRow.oid),mr);
      AInputRow.ObjectSpace.SQLSelect('Select sd2.id from receivedorders2 ro2 left join Storedocuments2 sd2 on sd2.ProvideRow_ID=ro2.id left join Storedocuments SD on sd.id=sd2.parent_ID ' +
      ' where sd.documenttype=''22'' and RO2.X_ReceivedOrderRow_ID = ' + quotedstr(AInputRow.oid),mr);

              //if mr.count>0 then begin
              if true then begin
                      mBO_prevodka_vydej:=AInputRow.ObjectSpace.CreateObject('110I5SAOS3DL3ACU03KIU0CLP4');
                              try
                                 for i:=0 to mr.count-1 do begin
                                           mBO_prevodka_vydej.load(mr.strings[i],nil);
                                              if mBO_prevodka_vydej.GetFieldValueAsInteger('Storecard_ID.Category')=2 then begin

                                                               mBO_Moniker_source:=mBO_prevodka_vydej.GetLoadedCollectionMonikerForFieldCode(mBO_prevodka_vydej.GetFieldCode('DocRowBatches'));
                                                               mBO_Moniker_target:=aOutputRow.GetLoadedCollectionMonikerForFieldCode(aOutputRow.GetFieldCode('DocRowBatches'));

                                                               for ii:=0 to mBO_Moniker_source.Count-1 do begin

                                                                         mdocrowbatches:=mBO_Moniker_target.AddNewObject;

                                                                          mdocrowbatches.Prefill;
                                                                          mdocrowbatches.setFieldValueAsstring('QUnit',mBO_Moniker_source.BusinessObject[ii].getFieldValueAsString('QUnit'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Unitrate',mBO_Moniker_source.BusinessObject[ii].GetFieldValueAsFloat('UnitRate'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Quantity',mBO_Moniker_source.BusinessObject[ii].GetFieldValueAsFloat('Quantity'));
                                                                          mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mBO_Moniker_source.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID'));
                                                               end;
                                              end;
                                end;
                            finally
                                mBO_prevodka_vydej.free;
                            end;
          end;
   end;
finally
    mr.free;
end;


end;

begin
end.

