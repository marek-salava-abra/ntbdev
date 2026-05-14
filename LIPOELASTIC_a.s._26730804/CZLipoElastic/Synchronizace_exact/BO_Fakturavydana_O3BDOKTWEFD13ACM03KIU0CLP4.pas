uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mi:integer;
mQueryID:string;
mString:string;
mData: TJSONSuperObject;
mStringJSON:TJSONSuperObject  ;
mMon:TNxCustomBusinessMonikerCollection;
i,ii:integer;
mDoclist:tstringlist;
mr:tstringlist;
mfind:Boolean;
mBO_ReceivedOrders:TNxCustomBusinessObject;
begin
try
 if (osNew in self.State) then begin
    mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
       mdoclist:=tstringlist.create;
       try
                 for i := 0 to mMon.Count - 1 do begin                                            // zjištení dokladů
                     if mmon.BusinessObject[i].GetFieldValueAsString('BusOrder_id')='1700000101' then begin
                            mr:=tstringlist.create;
                            try
                               self.ObjectSpace.sqlselect('Select sd2.Provide_ID from StoreDocuments2 sd2 where sd2.id=' + QuotedStr(mmon.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID')) , mr);
                               if mr.count>0 then begin
                                   mfind:=false;
                                      for ii:=0 to mDoclist.count-1 do begin
                                          if mr.strings[0]=mDoclist.Strings[ii] then mfind:=true;
                                      end;
                                      if not mfind then  mDoclist.add(mr.strings[0]);
                               end;
                            finally
                                mr.free;
                            end;
                     end;

                 end;


                         if mDoclist.count>0 then begin
                            mBO_ReceivedOrders:=self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                            try
                              for ii:=0 to mDoclist.count-1 do begin                   // odeslání API
                                    mBO_ReceivedOrders.load(mDoclist.Strings[ii],nil);

                                     mStringJSON:=TJSONSuperObject.Create;
                                          try
                                              mString:='{"orderNumber":' + (mBO_ReceivedOrders.GetFieldValueAsString('Externalnumber'))
                                                    //+ ',"countryCode":"' + mBO_ReceivedOrders.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')
                                                    + ',"countryCode":"' + 'cz'
                                                    + '","state":' + inttostr(3)
                                                    + '}';
                                              mStringJSON:= APICallExactstring(self,'Post','https://lipoelastic.cz/api/ExactHook','/StateChanged','?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU',mString,true);
                                               if not (mStringJSON.B['success']) then begin        // chyba v api
                                                         iSendmsgx(self.ObjectSpace,' API Error ' + 'Receivedorders', 'https://lipoelastic.cz/api/ExactHook'+'/StateChanged'+'?_token=sQKkOxZ0HOmmJI99TZhLbDacObkvA9aU' + '       ' + mString  + '   ' + nxbooltostr((mStringJSON.B['success'])) +  ' - ' + inttostr((mStringJSON.I['status'])) + ' / ' +  (mStringJSON.S['message'])  , mToMSG , NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID);
                                               end else begin
                                                   // NxShowSimpleMessage('Stav: '  + NxBoolToString(mStringJSON.B['success']),nil)      ;
                                               end;
                                          finally
                                               mStringJSON.free;
                                          end;
                              end;
                             finally
                                 mBO_ReceivedOrders.free;
                             end;
                          end;
       finally
           mDoclist.free;
       end;
     end;
     except
     end;
end;


begin
end.