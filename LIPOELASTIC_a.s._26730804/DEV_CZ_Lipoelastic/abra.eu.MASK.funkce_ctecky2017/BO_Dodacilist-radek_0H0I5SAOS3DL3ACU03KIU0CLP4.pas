

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mr,mx:tstringlist;
i:integer;
begin

  if self.GetFieldValueAsString('Store_id')<>'2G10000101' then begin

  if self.GetFieldValueAsInteger('rowtype')=3 then begin
       if (self.GetFieldValueAsInteger('storecard_id.category')=1) or (self.GetFieldValueAsInteger('storecard_id.category')=2) then begin
             //if (self.GetFieldValueAsInteger('BatchStatus')<>0) then begin
                 mr:=tstringlist.create;
                 try
                     self.ObjectSpace.SQLSelect('Select max(sb.ExpirationDate$DATE) from DocRowBatches drb LEFT JOIN StoreBatches SB on sb.id=drb.StoreBatch_ID  where DRB.parent_id=' + quotedstr(self.oid),mr);
                     if mr.count>0 then begin
                              //NxShowSimpleMessage(mr.Strings[0],nil) ;
                              mx:=tstringlist.create;
                              try
                                 // --- Vyhozeno, dobrá funkce, ale děvčata stejně ignorují ---
                                 {  self.ObjectSpace.SQLSelect('Select min(sb.ExpirationDate$DATE) from StoreSubBatches SSB  LEFT JOIN StoreBatches SB on sb.id=ssb.StoreBatch_ID where ssb.Quantity>0 and ssb.Store_ID=' + quotedstr(self.GetFieldValueAsString('Store_id')) + ' and ssb.StoreCard_ID=' + quotedstr(self.GetFieldValueAsString('Storecard_id') ),mx)  ;
                                       if mx.count>0 then begin
                                      // NxShowSimpleMessage(mx.Strings[0],nil);
                                          if (NxIBStrToFloat(mr.Strings[0])-NxIBStrToFloat(mx.Strings[0]) )>7 then begin
                                             if (NxIBStrToFloat(mx.Strings[0])>0) then begin
                                                NxShowSimpleMessage('Existuje starší šarže o ' +
                                                IntToStr(trunc(NxIBStrToFloat(mr.Strings[0])-NxIBStrToFloat(mx.Strings[0])) ) + ' dnů '
                                                ,nil);
                                                NxBeep(btFailure);
                                             end;
                                           end;
                                        end;}
                              finally
                                 mx.free;
                              end;
                     end;
                 finally
                     mr.free;
                 end;
                        // end;
                   end;
              end;
        end;
end;


begin
end.