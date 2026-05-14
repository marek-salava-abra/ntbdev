procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mr,mx:tstringlist;
  mbo:TNxCustomBusinessObject;
  mtext,mtext1:string;
begin
  mCode := Self.GetFieldCode('NewBatchName');         //   ********   kontrola materiálové šarže
  if AFieldCode = mCode then begin
    if AOriginalValue.AsString <> AValue.AsString then
              if copy(UpperCase(AValue.AsString),1,3)='MAT' then begin
                  mtext:='';
                  mtext1:='';
                    mr:=TStringList.create;
                      try
                         self.ObjectSpace.SQLSelect('select id from StoreBatches sb where name=' + quotedstr(AValue.AsString) + ' and hidden='+quotedstr('N'),mr);
                         if mr.count>0 then begin
                             mtext:='Šarže ' + AValue.AsString + ' již je v systému použita';
                                  mx:=TStringList.create;
                                  try
                                      self.ObjectSpace.SQLSelect('select DSB.id from DocRowBatches DSB join StoreDocuments2 sd2 on sd2.id= dsb.parent_id join StoreDocuments sd on sd.id=sd2.parent_id where dsb.StoreBatch_ID=' + QuotedStr(mr.Strings[0]),mx);
                                      if mx.count>0 then begin
                                           mbo:=self.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                           try
                                              mbo.load(mx.Strings[0],nil);
                                              mtext1:= chr(13) + ' ze dne ' + FormatDateTime('DD.MM.YYYY',mbo.GetFieldValueAsDateTime('Parent_ID.Parent_ID.DocDate$DATE')) +
                                                                 ' na dokladu ' + mbo.GetFieldValueAsString('Parent_ID.Parent_ID.DisplayName') + chr(13) +
                                                                 ' pro skladovou kartu ' + mbo.GetFieldValueAsString('Parent_ID.Storecard_ID.DisplayName') +  chr(13) +
                                                                 ' v množství ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('Quantity')) + ' ' + mbo.GetFieldValueAsString('Parent_ID.Storecard_ID.MainUnitCode') +
                                                                 ' ze kterého zbývá ' +NxFloatToIBStr(mbo.GetFieldValueAsFloat('StoreSubBatch_ID.Quantity'))  + ' ' + mbo.GetFieldValueAsString('Parent_ID.Storecard_ID.MainUnitCode')

                                                                 ;
                                           finally
                                              mbo.free;
                                           end;
                                      end;
                                  finally
                                   mx.free;
                                  end;
                         end;


                    finally
                        mr.free;
                    end;
                    if mtext<>'' then NxShowSimpleMessage(mtext + chr(13) + mtext1,nil);
              end;


  end;
end;


begin
end.