
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
mcena:double;
mr:tstringlist;
begin
  if not NxIsEmptyOID(AnInputRow.GetFieldValueAsString('BusOrder_ID')) then begin
      mr:=tstringlist.create;
      try
      AnInputRow.ObjectSpace.SQLSelect(
          'select max(sp2x.amount) from storecards A left join storeprices SPx on SPx.StoreCard_ID= A.ID left join storeprices2 SP2x on SP2x.parent_id=SPx.ID LEFT JOIN PriceListValidities PLV3 on PLV3.ID = SPx.PRICELISTVALIDITY_ID' +
          ' WHERE SP2x.price_id = (SELECT ID from pricedefinitions PDx WHERE PDx.basic = ' + quotedstr('A') + ') and SP2x.qunit = A.mainunitcode and SPx.StoreCard_ID = A.ID and '+
          ' SPx.pricelist_id = ' + quotedstr(AnInputRow.GetFieldValueAsString('BusOrder_ID.X_Pricelist_ID')) + ' and ' +
          ' a.id= ' +quotedstr(AnInputRow.GetFieldValueAsString('Storecard_ID')),mr);

            if mr.count>0 then begin
                if nxibstrtofloat(mr.Strings[0])<>0 then begin
                    aOutputRow.SetFieldValueAsFloat('Unitprice',nxibstrtofloat(mr.Strings[0]));
                end else begin
                    NxShowSimpleMessage('Pozor, není uvedena cena za poukaz',nil);
                end;
            end else begin ;
                NxShowSimpleMessage('Pozor, karta není uvedena v ceníku pro poukazy',nil);
            end;
      finally
         mr.free;
      end;













  //    aOutputRow.SetFieldValueAsFloat('UnitPrice',mcena);
  end;
end;

begin
end.