uses 'EU.Aabra.Mask.Validace.lib';
Var
mChange:boolean;

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode,xi: integer;
begin
 { if AFieldCode = Self.GetFieldCode('FirmOffice_ID') then mChange:=true;
  if false then begin
     // NxShowSimpleMessage('Došlo k zásadní změně parametrů, je nutné přepočítat ceny',nil);

     //if trim(Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp')) <>'' then  begin
         if trim(Self.GetFieldValueAsString('X_Poznam_exp')) <>'' then  begin

             if trim(Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp')) <> trim(Self.GetFieldValueAsString('X_Poznam_exp')) then begin
                   //xi:=NxMessageBox('Na dokladu je již poznámka pro expedici vyplněna . Přejete si ji aktualizovat',
                   //                 Self.GetFieldValueAsString('X_Poznam_exp') + ' na ' + Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp') , mdConfirm, mdbOkCancel, 0, 0, true, nil) ;   //1,2
                   //            if xi=1 then begin
                                   Self.setFieldValueAsString('X_Poznam_exp', Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp'))  ;
                   //            end;
             end;



         end else begin
             Self.setFieldValueAsString('X_Poznam_exp', Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp'))  ;

         end;



     //end;








  end;
  if AFieldCode = Self.GetFieldCode('Firm_ID') then begin
      //NxShowSimpleMessage(self.getFieldValueAsString('Firm_ID.TransportationType_ID'),nil);
      if not NxIsEmptyOID(self.getFieldValueAsString('Firm_ID.TransportationType_ID')) then self.setFieldValueAsString('TransportationType_ID',self.getFieldValueAsString('Firm_ID.TransportationType_ID'));
  end;


  //if mChange then begin
  //    NxShowSimpleMessage('Došlo k zásadní změně parametrů, je nutné přepočítat ceny',nil);
  //end; }
end;


{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
   if NxIsBlank(Self.GetFieldValueAsString('X_Poznam_exp')) then
          Self.setFieldValueAsString('X_Poznam_exp', self.GetFieldValueAsString('Firm_ID.X_Poznam_exp') + ' ' + Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp'))  ;
 if ((nxisblank(Self.getFieldValueAsString('X_Identifikace'))) or (Self.getFieldValueAsString('X_Identifikace')='0')) then Self.SetFieldValueAsString('X_Identifikace',Self.GetFieldValueAsString('Firm_ID.Name')) ;

 if trim(Self.getFieldValueAsString('Firm_ID.Name'))='LIPOELASTIC s.r.o.' then begin
      Self.setFieldValueAsinteger('Tradetype',2);
      Self.setFieldValueAsString('Country_ID','00000SK000');
      Self.setFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
      Self.setFieldValueAsString('IntrastatTransactionType_ID','0101000000');
      Self.setFieldValueAsString('IntrastatTransportationType_ID','2000000000');
 end;




end;





procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mMon:TNxCustomBusinessMonikerCollection;
i:integer;
mr:TStringList;
mList:TStringList;
mText:string;
begin
if true then begin
//if trim(Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp')) <> trim(Self.GetFieldValueAsString('X_Poznam_exp')) then begin
//     Self.setFieldValueAsString('X_Poznam_exp', Self.GetFieldValueAsString('FirmOffice_ID.X_Poznam_exp'))  ;
//end;


 mlist:=TStringList.create;
   // NxShowSimpleMessage('validace osoby 1', nil);
if (copy(self.GetFieldValueAsString('FIRM_ID.K7'),4,1)='1') or (copy(self.GetFieldValueAsString('FIRM_ID.K7'),5,1)='1' ) then begin
        //NxShowSimpleMessage('validace osoby 2 ', nil);
                            if nxisemptyoid(self.GetFieldValueAsString('Person_ID')) then begin
                             // NxShowSimpleMessage('validace osoby', nil);
                                   mList.Add('Pro ' + self.GetFieldValueAsString('Firm_ID.Name') + ' není uvedena osoba pro provizi');
                                   aresult:=false;
                            end;
end;

if (self.GetFieldValueAsString('PaymentType_ID')='3A50000101')  then begin
                            if (self.GetFieldValueAsBoolean('Confirmed')) then begin
                                // NxShowSimpleMessage('validace osoby', nil);
                                  self.SetFieldValueAsBoolean('Confirmed',false)     ;
                                   self.AddValidateError(self.GetFieldCode('Confirmed'),'');
                                   mList.Add('Objednávku ve stavu nezaplaceno není možné potvrdit');


                                   aresult:=false;
                            end;
end;


mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
        try
                for i := 0 to mMon.Count - 1 do begin
                  if mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID.X_Typ_certifikace.X_MX_NAZEV') = 'A' then begin

                      mr:=TStringList.create;
                      try
                        self.ObjectSpace.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('LZVISPIWYGE4HIAJ5PX0LGPWWC') +
                          ' AND (A.X_BusTransaction_ID = ' + quotedstr(mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) + ') AND (A.X_Person_ID = ' + quotedstr(self.GetFieldValueAsString('Person_ID')) + ')',mr);
                          if mr.count=0 then begin
                               if not NxIsEmptyOID(self.GetFieldValueAsString('Person_ID')) then begin
                                     mList.Add('Pro ' + mMon.BusinessObject[i].getFieldValueAsString('Storecard_ID.Name') + ' nemá osoba '
                                         + self.GetFieldValueAsString('Person_ID.LastName') + ' certifikaci');
                                         aresult:=false;
                               end else begin
                                     mList.Add('Pro ' + mMon.BusinessObject[i].getFieldValueAsString('Storecard_ID.Name') + ' musí být uvedena osoba s certifikací');
                                         aresult:=false;
                               end;
                          end;

                      finally
                          mr.free;
                      end;
                  end;
                end;

                if mlist.Count>0 then begin
                    mText := mList.Text;
                    //MessageDlg('Objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,mtWarning, [mbOK], 0);
                    self.AddValidateError(self.GetFieldCode('Person_ID'),'Objednávku nelze uložit z těchto důvodů:' + #13#10 + mText);
               //     NxShowSimpleMessage('chyba osoby', nil);
                end;

           finally
               mlist.free;
           end;


//  mStore


  // certifikace
  if mChange then begin
      // přepočet ceny, změna osoby, firmy, provozovny
      //GetPrice_ID
      //GetBusOrder_ID
      //GetBusTransaction_ID
  end;
end;

end;

begin
end.