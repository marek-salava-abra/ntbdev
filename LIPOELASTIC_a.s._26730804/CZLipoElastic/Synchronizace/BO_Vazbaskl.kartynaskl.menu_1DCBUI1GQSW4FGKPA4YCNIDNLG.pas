uses 'Synchronizace.API'    ;

const
mTable='StoreCardMenuItemLinks';
mApiTable='StoreCardMenuItemLinks';




procedure XXX_AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  aString:string;
  mstring:string;
  ARequest:string;
  mSite:TSiteForm;
  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i:integer;
  mTarget:string;
begin
   if true then begin
   //NxGetUserName='mskacel' then begin
   mTargetList:=tstringlist.create;
    TRY
          mTargetList:=CreateTargetList;
          //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
          //             NxShowSimpleMessage(self.ObjectSpace.GetConnectionName,nil);
       mQuery:='{}';
       IF mManual then BEGIN                   // **** ruční vykopírování údajů
          mQuery:='{'
             +'"id": "' +  Self.OID +'", '
             +'"Storecard_ID":"'  +  Self.GetFieldValueAsString('Storecard_ID') +'", '
             +'"StoreMenuItem_ID":"' +  Self.GetFieldValueAsString('StoreMenuItem_ID') +'"'



             +'}';

        //     mstring:=                      inputbox('AAA','AA',mQuery)    ;

        END ELSE BEGIN                   // **** celkové vykopírování BO do JSON
             mQuery:= CallRestApi(TBusRollSiteForm(msite).CurrentObject,'GET',msource,mApiTable,'/'+Self.OID,'{}');
          //   mQuery:= CorrectQuery(mQuery, '"ObjVersion":');
          //   mQuery:= CorrectQuery(mQuery, '"DisplayName":');
          //   mQuery:=NxRemoveDiacritics(mQuery);

        end;

      //  NxShowSimpleMessage(mQuery,nil) ;
    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];

                mQuery:='{'
//                                               "isbasiclink": false,
                                           +'"id": "' +  self.oid +'", '
                                           +'"Storecard_ID":"'  +  self.GetFieldValueAsString('Storecard_ID') +'", '
                                           +'"StoreMenuItem_ID":"' +  self.GetFieldValueAsString('StoreMenuItem_ID') +'"'
                                         + '}';
                                      //mstring:= inputbox('Vazba skladového menu ','AA',mQuery)    ;


                                      mQueryID:='{'
                                              + ' "class": "StoreCardMenuItemLinks",'
                                              +' "select": ["ID",],'
                                              + ' "where": " "Storecard_ID = ' + QuotedStr(self.GetFieldValueAsString('Storecard_ID')) + ' and StoreMenuItem_ID=' + QuotedStr(self.GetFieldValueAsString('StoreMenuItem_ID'))
                                              +' " '
                                              + '}';

                                          mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);

                                      if mID='' then begin
                                            mQuery:= CallRestApi(TBusRollSiteForm(msite).CurrentObject,'Post',msource,'StoreCardMenuItemLinks','',mQuery);
                                             //mstring:= inputbox('Vazba na skladové menu','Založení vazby skladového menu',mQuery)    ;
                                      end else begin
                                            mQuery:= CallRestApi(TBusRollSiteForm(msite).CurrentObject,'put',msource,'StoreCardMenuItemLinks','/'+mid,mQuery);
                                            //mstring:= inputbox('Vazba na skladové menu','Oprava vazby skladového menu',mQuery)    ;
                                      end;
   end;

   finally
  //   mTargetList.free;
   end;
end;
end;

begin ;
end.