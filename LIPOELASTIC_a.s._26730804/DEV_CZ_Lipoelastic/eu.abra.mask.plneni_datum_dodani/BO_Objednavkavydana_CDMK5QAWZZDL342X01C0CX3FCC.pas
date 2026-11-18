uses 'EU.Aabra.Mask.Validace.lib';
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
    mMon: TNxCustomBusinessMonikerCollection;
    i:integer;
    xdotaz:boolean;
    mI_Result:integer;
begin
  if self.GetFieldValueAsDateTime('X_datum_dodani')>1000 then begin
          xdotaz:=false;
          // ted projdeme radky - nejlepe v poradi radek prijemky
          mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          try
                  for i := 0 to mMon.Count-1 do begin
                        if mMon.BusinessObject[i].GetFieldValueAsDateTime('DeliveryDate$Date')<>self.GetFieldValueAsDateTime('X_datum_dodani') then begin
                             if not xdotaz then begin
                                 // NxShowSimpleMessage('Nesouhlasí termín dodání na hlavičce s řádky. Řádky budou aktualizovány',nil);
                                  xdotaz:=true;
                             end;
                              if xdotaz then mMon.BusinessObject[i].setFieldValueAsDateTime('DeliveryDate$Date',self.GetFieldValueAsDateTime('X_datum_dodani'));
                        end;
                  end;

          finally
          end;
   end;
end;



begin
end.