uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;


procedure _AfterDataChange_PostHook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
mi:integer;
mQueryID:string;
mString:string;
mData: TJSONSuperObject;
mStringJSON:TJSONSuperObject  ;
begin
    if self.GetFieldValueAsString('VarSymbol')<>'' then begin

            mr:=tstringlist.create;
            try
                self.ObjectSpace.SQLSelect('select pms.SequenceNumber from receivedorders RO join PMStates PMS on PMS.id=ro.PMState_ID where ro.externalnumber=' + quotedstr(self.GetFieldValueAsString('VarSymbol')) + ' and ro.PaymentType_ID=' + quotedstr('9000000101')+ ' and ro.X_canceled=' + quotedstr('N') ,mr);
                if mr.count>0 then begin
                        if (self.GetFieldValueAsFloat('NotPaidAmount')=0) and (self.GetFieldValueAsFloat('UsedAmount')=0) and (self.GetFieldValueAsFloat('Amount')<>0) then begin
                          if StrToInt(mr.Strings[0])<3 then begin
                              mStringJSON:=TJSONSuperObject.Create;
                                try

                                             mString:='{"orderNumber":' + (self.GetFieldValueAsString('VarSymbol'))
                                                  + ',"countryCode":"' + 'cz'
                                                  + '","state":' + '2'
                                                  + '}';
                                            mStringJSON:= APICallExactstring(self,'Post','https://lipoelastic.cz/api/ExactHook','/StateChanged','?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU',mString,true);

                                            //NxShowSimpleMessage('Zaloha',nil);

                                             if not (mStringJSON.B['success']) then begin        // chyba v api
                                                       iSendmsgx(self.ObjectSpace,' API Error ' + 'IssuedDepositInvoice', 'https://lipoelastic.cz/api/ExactHook'+'/StateChanged'+'?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU' + '       ' + mString  , mToMSG , NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID);
                                                     // procedure iSendmsgx(AOS : TNxCustomObjectSpace;const ASubject : string; const ABody : string; ATo : string; AFrom : string = '');
                                             end;
                                finally
                                   mi:=self.ObjectSpace.SQLExecute('update receivedorders  set PMState_ID=' + quotedstr('3000000101') + ' where externalnumber=' + quotedstr(self.GetFieldValueAsString('VarSymbol')));

                                   mStringJSON.free;
                                end;
                          end ;

                        end;





                end;
            finally

            end;
     end;
end;




begin
end.