uses 'abra.eu.mask.2017.predvyplneni.funkce','EU.Aabra.Mask.Validace.lib';

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