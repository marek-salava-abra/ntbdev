uses 'Synchronizace.API'    ;

const
mTable='DefRollData';
mApiTable='Material_slozeni_ZYGPIPN1YBF4DDFNSSO30G0OGS';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
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

                  mQuery:='{'   ;
                  mquery:=mquery + '"id": "' +  Self.OID +'"'  ;
                  mquery:=mquery + ', "Code":"' +  Self.GetFieldValueAsString('Code') +'" ';
                  mquery:=mquery + ', "Name":"' +  Self.GetFieldValueAsString('Name') +'" ';
                  mquery:=mquery + ', "Hidden": '  +  BoolToStr(Self.GetFieldValueAsBoolean('Hidden')) +' ' ;

                  mquery:=mquery + ', "X_synchronizace_ID":"'  +  Self.GetFieldValueAsString('X_synchronizace_ID') +'" ' ;
                  mquery:=mquery + ', "X_EN_NAZEV":"'  +  Self.GetFieldValueAsString('X_EN_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_DE_NAZEV":"'  +  Self.GetFieldValueAsString('X_DE_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_MX_NAZEV":"'  +  Self.GetFieldValueAsString('X_MX_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_ES_NAZEV":"'  +  Self.GetFieldValueAsString('X_ES_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_IT_Nazev":"'  +  Self.GetFieldValueAsString('X_IT_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_FR_Nazev":"'  +  Self.GetFieldValueAsString('X_FR_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_NL_Nazev":"'  +  Self.GetFieldValueAsString('X_NL_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_US_Nazev":"'  +  Self.GetFieldValueAsString('X_US_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_UK_NAZEV":"'  +  Self.GetFieldValueAsString('X_UK_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_amoena":"'  +  Self.GetFieldValueAsString('X_amoena') +'" ' ;
                  mquery:=mquery + ', "X_MEX_Nazev":"'  +  Self.GetFieldValueAsString('X_MEX_Nazev') +'" ' ;
//                  mquery:=mquery + ', "X_CZ_Nazev":"'  +  Self.GetFieldValueAsString('X_CZ_Nazev') +'" ' ;
//                  mquery:=mquery + ', "X_SK_Nazev":"'  +  Self.GetFieldValueAsString('X_SK_Nazev') +'" ' ;
                 mquery:=mquery +'}';





        //mstring:=                      inputbox('AAA','AA',mQuery)    ;
            for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                        mTarget:=mTargetList.strings[i];
                // *** dohledání záznamu v cílové databázi
                  mQueryID:='{ "class": "' + mApiTable +'", "select": ["ID",], "where": " id = ' + QuotedStr(Self.OID) +'" }';
                        mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);

                  IF mid='' THEN BEGIN
                           mNewQueryID:='{"info_type": "New_value" '
                                     +','+' "mSQL": INSERT INTO ' + mtable + ' (Code,Name,ID,Hidden,CLSID) VALUES (' +
                                            quotedstr(Self.GetFieldValueAsString('Code'))
                                            + ','+ quotedstr(Self.GetFieldValueAsString('Name'))
                                            + ','+ quotedstr(Self.OID)
                                            + ','+ quotedstr('N')
                                            + ','+ quotedstr(Self.GetFieldValueAsString('CLSID'))
                                            + ')"}';
        //mstring:=                      inputbox('AAA','AA',mNewQueryID)    ;
                            aString:=CallNewValueWithID(self,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID);
                          // ověření založení karty
                            mQueryID:='{ "class": "' + mApiTable +'", "select": ["ID",], "where": " id = ' + QuotedStr(Self.OID) +'" }';
                                mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);

                  END;
                  if mid='' then begin
                      NxShowSimpleMessage('založení záznamu v ' + mtarget +  ' selhalo',nil);
                  end else begin
                     mString:= CallRestApi(self,'PUT',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu
                  end;
            end;
            finally
      //        mTargetList.free;
            end;
        end;
end;



{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}

procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
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
   //NxGetUserName='mskacel' then begin
   mTargetList:=tstringlist.create;
    TRY
          mTargetList:=CreateTargetList;
          //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
          //             NxShowSimpleMessage(self.ObjectSpace.GetConnectionName,nil);
          for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                      mTarget:=mTargetList.strings[i];
                            mQueryID:='{ "class": "' + mApiTable +'", "select": ["ID",], "where": " id = ' + QuotedStr(Self.OID) +'" }';

                            mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);

                if mID<>'' then begin
                    mString:= CallRestApi(self,'DELETE',mtarget,mApiTable,'/' + mid ,'{}');  // smazání

                end;
          end;
    finally
   //   mTargetList.free;
    end;

end;



begin
end.
