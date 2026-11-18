uses 'abra.eu.mask.2017.predvyplneni.funkce','EU.Aabra.Mask.Validace.lib';
{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
i:integer;
mMon:TNxCustomBusinessMonikerCollection;
mBustransaction_ID,mBusOrder_ID,mBusProject_ID:string;
begin

            if self.GetFieldValueAsString('Docqueue_ID.CODE')='DVVS' then begin
                                        mMon := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('ROWS'));
                                        for i := 0 to mMon.Count - 1 do begin

                                               if mMon.BusinessObject[i].GetFieldValueAsInteger('Rowtype')=3 then begin
                                                  //mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id','');
                                                  //mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id','');

                                                  if not NxIsEmptyOID((mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                               mBustransaction_ID:=(mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                               mMon.BusinessObject[i].SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                  end;
                                                end;
                                                if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusOrder_id')) then begin
                                                      mBusOrder_ID:=GetBusOrder_ID(mMon.BusinessObject[i]);
                                                      if not nxisblank(mBusProject_ID) then mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                end;
                                                if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusProject_id')) then begin
                                                      mBusProject_ID:=GetProject_ID(mMon.BusinessObject[i]);
                                                      if not nxisblank(mBusProject_ID) then mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                end;

                                        end;
          end;
end;


procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
i:integer;
mMon:TNxCustomBusinessMonikerCollection;
mBustransaction_ID,mBusOrder_ID,mBusProject_ID:string;
begin

            if self.GetFieldValueAsString('Docqueue_ID.CODE')='DVVS' then begin
                                        mMon := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('ROWS'));
                                        for i := 0 to mMon.Count - 1 do begin

                                               if mMon.BusinessObject[i].GetFieldValueAsInteger('Rowtype')=3 then begin
                                                  //mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id','');
                                                  //mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id','');

                                                  if not NxIsEmptyOID((mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                               mBustransaction_ID:=(mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                               mMon.BusinessObject[i].SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                  end;
                                                end;
                                                if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusOrder_id')) then begin
                                                      mBusOrder_ID:=GetBusOrder_ID(mMon.BusinessObject[i]);
                                                      if not nxisblank(mBusProject_ID) then mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                end;
                                                if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusProject_id')) then begin
                                                      mBusProject_ID:=GetProject_ID(mMon.BusinessObject[i]);
                                                      if not nxisblank(mBusProject_ID) then mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                end;

                                        end;
          end;

end;

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mMon:TNxCustomBusinessMonikerCollection;
i:integer;
mr:TStringList;
mList:TStringList;
mText:string;
begin
//NxShowSimpleMessage(
if ((self.GetFieldValueAsString('Docqueue_ID.code')='DMA' )
    or (self.GetFieldValueAsString('Docqueue_ID.code')='DPPO' )) then begin
              if not NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.VatCountry_ID')) then begin
                    if UpperCase(self.GetFieldValueAsString('Firm_ID.VatCountry_ID.Code'))<>'CZ' then begin
                        self.SetFieldValueAsString('Country_id',self.GetFieldValueAsString('Firm_ID.VatCountry_ID'));

                    end;

                end;
end;


 mlist:=TStringList.create;


mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
        try
                for i := 0 to mMon.Count - 1 do begin
                  if (mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.category') = 1) or (mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.category') = 2) then begin


                               if mMon.BusinessObject[i].GetFieldValueAsInteger('BatchStatus') = 1 then begin
                                     mList.Add('Pro ' + mMon.BusinessObject[i].getFieldValueAsString('Storecard_ID.Name') + ' nejsou plně uvedeny šarže ');
                                         aresult:=false;
                               end;

                  end;
                end;

                if mlist.Count>0 then begin
                    mText := mList.Text;
                    //MessageDlg('Objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,mtWarning, [mbOK], 0);
                    self.AddValidateError(self.GetFieldCode('Firm_ID'),'Doklad nelze uložit z těchto důvodů:' + #13#10 + mText);
               //     NxShowSimpleMessage('chyba osoby', nil);
                end;

           finally
               mlist.free;
           end;



end;



begin
end.