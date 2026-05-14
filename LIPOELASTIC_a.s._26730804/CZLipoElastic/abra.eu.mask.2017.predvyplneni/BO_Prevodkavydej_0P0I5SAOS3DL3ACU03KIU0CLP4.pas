uses 'abra.eu.mask.2017.predvyplneni.funkce','EU.Aabra.Mask.Validace.lib';

Var
mChange:boolean;

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode,xi: integer;
  mMon:TNxCustomBusinessMonikerCollection;
begin


  if AFieldCode = Self.GetFieldCode('Firm_ID') then begin
           if AValue.AsString<>AOriginalValue.AsString then begin
                 if not NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.store_ID')) then begin
                    //NxShowSimpleMessage(self.GetFieldValueAsString('Firm_ID.Name'),nil);
                  //  self.SetFieldValueAsString('PlannedReverseDocumentDocQu_ID','VA10000101');
                  //  self.SetFieldValueAsString('PlannedReverseDocumentStore_ID',self.GetFieldValueAsString('Firm_ID.store_ID'));
                  //  self.SetFieldValueAsString('IncomingTransferStore',self.GetFieldValueAsString('Firm_ID.store_ID'));
                end;
           end;

  end;

    //  self.SetFieldValueAsboolean('IncomingTransfer',true);
  if AFieldCode = Self.GetFieldCode('FirmOffice_ID') then begin
           if AValue.AsString<>AOriginalValue.AsString then begin
                if not NxIsEmptyOID(self.GetFieldValueAsString('FirmOffice_ID.X_store_ID')) then begin
                    //NxShowSimpleMessage(self.GetFieldValueAsString('FirmOffice_ID.Name'),nil);
                    //self.SetFieldValueAsString('PlannedReverseDocumentDocQu_ID','VA10000101');
                    //self.SetFieldValueAsString('PlannedReverseDocumentStore_ID',self.GetFieldValueAsString('FirmOffice_ID.X_store_ID'));
                    //self.SetFieldValueAsString('IncomingTransferStore',self.GetFieldValueAsString('FirmOffice_ID.X_store_ID'));
                end;
           end;

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