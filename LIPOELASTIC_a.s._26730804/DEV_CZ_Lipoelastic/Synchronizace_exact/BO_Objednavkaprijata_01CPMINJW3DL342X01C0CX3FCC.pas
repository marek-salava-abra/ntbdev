uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
//procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
//var
//mi:integer;
//mQueryID:string;
//mString:string;
//mData: TJSONSuperObject;
//mStringJSON:TJSONSuperObject  ;
//begin
//     if false then begin
     //    self.GetFieldValueAsBoolean('Closed') then begin
          //NxShowSimpleMessage('OP Uzavřeno po uložení  - Closed ' + NxBoolToStr(self.GetFieldValueAsBoolean('Closed')),nil);
//          if  self.GetFieldValueAsString('PMState_ID') <> '4000000101' then begin
//               mi:=self.ObjectSpace.SQLExecute('Update receivedorders set PMState_ID=' + QuotedStr('4000000101') + ' where id=' + quotedstr(self.oid));
//             mStringJSON:=TJSONSuperObject.Create;
//             try

             { *** pro přenos pomocí generovaného JSON
             //  mData := TJSONSuperObject.Create;
               try
               //     mData.D['orderNumber'] := NxIBStrToFloat(self.GetFieldValueAsString('Externalnumber'));
               //     mData.S['countryCode'] := self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode');
               //     mData.I['state'] := self.GetFieldValueAsInteger('PMState_ID.SequenceNumber');
               //     mStringJSON:= APICallExact(self,'Post','https://dev.lipoelastic-garments.com/api/ExactHook','/StateChanged','?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU',mData,true);
                finally
                    mdata.free;
                end; }


                // ***** pro přenost podle seskládaného stringu
//                  mString:='{"orderNumber":' + (self.GetFieldValueAsString('Externalnumber'))
//                        + ',"countryCode":"' + self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')
//                        + '","state":' + inttostr(self.GetFieldValueAsInteger('PMState_ID.SequenceNumber'))
//                        + '}';
//                  mStringJSON:= APICallExactstring(self,'Post','https://dev.lipoelastic-garments.com/api/ExactHook','/StateChanged','?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU',mString,true);


//                   if not (mStringJSON.B['success']) then begin        // chyba v api
//                             iSendmsg(self.ObjectSpace,' API Error ' + 'Receivedorders', 'https://dev.lipoelastic-garments.com/api/ExactHook'+'/StateChanged'+'?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU' + '       ' + mString  , mToMSG , NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID);

//                    NxShowSimpleMessage(NxBoolToString(mStringJSON.B['success']) + ' / ' + IntToStr(mStringJSON.I['status']) + ' / ' + mStringJSON.S['message'] ,nil);
//                   end else begin
                      // NxShowSimpleMessage('Stav: '  + NxBoolToString(mStringJSON.B['success']),nil)      ;

//                   end;

//      finally
//         mStringJSON.free;
//      end;



//          end;
//     end else begin
      //        if  self.GetFieldValueAsString('PMState_ID') = '4000000101' then begin
      //            mi:=self.ObjectSpace.SQLExecute('Update receivedorders set PMState_ID=' + QuotedStr('3000000101') + ' where id=' + quotedstr(self.oid));
      //        end;
//     end;
//end;




begin
end.