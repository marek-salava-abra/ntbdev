
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
mr:tstringlist;
i,ii:integer;
mBO_Moniker_source,mBO_Moniker_target:TNxCustomBusinessMonikerCollection;
mdocrowbatches,mBO_prevodka_vydej:TNxCustomBusinessObject;
begin
 if ((aOutputRow.GetFieldValueAsInteger('Parent_id.Tradetype')=7) and (nxisemptyoid(aOutputRow.getFieldValueAsString('VATIndex_ID')))) then begin
         // NxShowSimpleMessage(aOutputRow..GetFieldValueAsstring('VATRate_ID.ossgoodvatindex_ID'),NIL);
                 if nxisemptyoid(aOutputRow.GetFieldValueAsstring('StoreCard_ID')) then begin
                       if aOutputRow.GetFieldValueAsinteger('StoreCard_ID.OSSSupplyType')=2 then BEGIN
                       //NxShowSimpleMessage('AAA',NIL);
                            aOutputRow.SetFieldValueAsString('VATIndex_ID', aOutputRow.GetFieldValueAsstring('VATRate_ID.ossgoodvatindex_ID'));
                       END;
                       if aOutputRow.GetFieldValueAsinteger('StoreCard_ID.OSSSupplyType')=1 then begin
                            aOutputRow.SetFieldValueAsString('VATIndex_ID', aOutputRow.GetFieldValueAsstring('VATRate_ID.ossservicevatindex_ID'));
                        //    NxShowSimpleMessage('BBB',NIL);
                       end;
                 end;
          end;

 end;





begin
end.