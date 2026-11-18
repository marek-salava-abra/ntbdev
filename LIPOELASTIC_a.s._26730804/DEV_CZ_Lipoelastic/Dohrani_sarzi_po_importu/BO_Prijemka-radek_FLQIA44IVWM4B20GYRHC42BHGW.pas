 uses  '_Knihovny_ALL.Progress',
       '_Knihovny_ALL.Parse',
       'Synchronizace_dokladu_na_SK.API' ;
{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
mBO_Moniker:TNxCustomBusinessMonikerCollection;
mdocrowbatches:TNxCustomBusinessObject;
mParselist:tstringlist;
i:integer;
mr:TStringList;
begin
  if (self.GetFieldValueAsInteger('Storecard_ID.Category')=2) and not(self.GetFieldValueAsBoolean('Parent_ID.X_ZAPI')) then begin        // karta je šaržová
//       NxShowSimpleMessage(inttostr(self.GetFieldValueAsInteger('BatchStatus')),nil);
        if self.GetFieldValueAsInteger('BatchStatus')=1 then begin            // nejsou kompletně zadány šarže
               if self.GetFieldValueAsString('X_Storebatches')<>'' then begin
                               //NxShowSimpleMessage('Zadej šarže' + self.GetFieldValueAsString('X_Storebatches'),nil);
                               mBO_Moniker:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('DocRowBatches'));
                               mParselist:=TStringList.create;
                               try
                                   Parsevalue(self.GetFieldValueAsString('X_Storebatches'),';',self.GetFieldValueAsString('X_Storebatches'),mParselist,NxCharCount(';',self.GetFieldValueAsString('X_Storebatches')));
                                    for i:=0 to mParselist.count-1 do begin
                                        //     ?New;777;7;?New;12345464888949;3;
                                        if mParselist.Strings[i]='?New' then begin
                                              if (mParselist.Strings[i+1]<>'') and (NxIBStrToFloat(mParselist.Strings[i+2])<>0) then begin
                                                    mr:=TStringList.create;
                                                    try
                                                           self.ObjectSpace.SQLSelect('SELECT id FROM StoreBatches A WHERE A.Name = ' + quotedstr(mParselist.Strings[i+1]) +' AND A.StoreCard_ID = ' +quotedstr(self.GetFieldValueAsString('Storecard_ID')) +' AND A.Hidden = '+ quotedstr('N')   ,mr) ;
                                                           //mBatch_ID:=API_GetOrCreateBatch(mSite,mtarget,mDocBatchRow.GetFieldValueAsString('X_Batches'));
                                                           if mr.count=1 then begin
                                                                mdocrowbatches:=mBO_Moniker.AddNewObject;
                                                                          mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mr.Strings[0]);
                                                                          mdocrowbatches.Prefill;
                                                                          mdocrowbatches.setFieldValueAsstring('QUnit',self.GetFieldValueAsString('Qunit'));
                                                                          mdocrowbatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mParselist.Strings[i+2]));

                                                           end;

                                                    finally
                                                        mr.free;
                                                    end;
                                              end;
                                              i:=i+2;
                                        end;



                                    end;

                               finally
                                   mParselist.free;
                               end;

               end;
        end;

  end;
end;

begin
end.