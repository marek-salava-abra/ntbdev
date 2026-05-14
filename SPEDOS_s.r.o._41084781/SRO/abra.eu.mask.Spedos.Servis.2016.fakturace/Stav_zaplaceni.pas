Const
msql='select first 100 sd.id||sum(ii.Amount + ii.PaidCreditAmount - ii.PaidAmount -  ii.CreditAmount) ' +
            'from ServiceDocuments SD ' +
            'left join ServiceAssemblyForms SA on sa.ServiceDocument_ID=sd.id '+
            'left join ServiceAssemblyForms2 SA2 on sa2.Parent_ID=sa.id ' +
            'left join issuedinvoices2 II2 on ii2.X_parent_id=sa2.id '+
            'left join issuedinvoices II on ii.id=ii2.parent_ID '+
       'where (SD.ServiceDocState_ID=%s) and ((ii.Docqueue_ID=%s) or (ii.Docqueue_ID=%s)) '+
       ' and ((ii.Amount + ii.PaidCreditAmount - ii.PaidAmount -  ii.CreditAmount)<=0) ' +
       ' group by sd.id';


procedure Stav_zaplaceni(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mr,mrx,mr2,mr3:TStringList;
  mid:string;
  mcastka:double;
  I,ii:integer;
    mbo,mbo1,mbo_ServiceAssembyForms:TNxCustomBusinessObject;
    mi:integer;
    mMon:TNxCustomBusinessMonikerCollection;
    mStrings:string;
begin
  Success := True;
  LogInfoStr := '';
  mr:=TStringList.create;

  try
      os.SQLSelect(format(msql,[quotedstr('E102000000'),quotedstr('8D00000101'),quotedstr('7D00000101')]),mr);
      if mr.count>0 then begin
        for i:=0 to mr.count-1 do begin
               mBO1 := os.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
               try
                  mbo1.load(copy(mr.Strings[i],1,10),nil);
                  mbo_ServiceAssembyForms:=os.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                          mid:=mbo1.GetFieldValueAsString('ID');

                                          mrx:=TStringList.create;
                                          try
                                          mbo1.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(mbo1.OID),mrx);
                                              if mrx.count>0 then begin
                                                 for ii:=0 to mrx.count-1 do begin
                                                      mbo_ServiceAssembyForms.load(mrx.Strings[ii],nil);
                                                                mMon := mbo_ServiceAssembyForms.GetLoadedCollectionMonikerForFieldCode(mbo_ServiceAssembyForms.GetFieldCode('ROWS'));
                                                                       mStrings:='(';
                                                                       for i := 0 to mMon.Count - 1 do begin
                                                                          if i>0 then mStrings:= mStrings + ',';
                                                                          mStrings:= mStrings + quotedstr(mMon.BusinessObject[i].OID);
                                                                       end;
                                                                       mStrings:= mStrings +')';
                                                  end;
                                                end;
                                          finally
                                              mrx.free;
                                          end;

                                               mr2:=TStringList.create;
                                                mr3:=TStringList.create;

                                          try

                                            mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select sum(h.Amount + h.PaidCreditAmount) from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr2);
                                            mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select sum(h.PaidAmount +  h.CreditAmount) from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr3);
                                            if mr2.count>0 then begin
                                                    if NxIBStrToFloat(mr2.Strings[0])>0 then begin
                                                              if NxIBStrToFloat(mr2.Strings[0])<=strtofloat(mr3.Strings[0]) then begin
                                                                 //NxShowSimpleMessage(mr2.Strings[0],nil);
                                                                 // NxShowSimpleMessage(mr3.Strings[0],nil);
                                                                 mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('9500000101') + ' where id=' +quotedstr(mbo1.GetFieldValueAsString('id')));
                                                                        mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_state=' + quotedstr('9XQ1000101') + ' where ServiceDocument_ID=' +quotedstr(mbo1.GetFieldValueAsString('id'))+
                                                                            ' and X_state=' + quotedstr('8XQ1000101') );
                                                              end  else begin
                                                                  //mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('E102000000') + ' where id=' +quotedstr(mbo1.GetFieldValueAsString('id')));

                                                              end;


                                                     end;
                                              end;
                                              finally
                                               mr2.free;
                                               mr3.free;
                                              end;





                     finally
                         mbo1.free;
                     end;

                 end;

























           mid:=copy(mr.Strings(i),1,10);
           mcastka:=NxIBStrToFloat(copy(mr.Strings(i),11,10));

//           NxShowSimpleMessage(mid,nil);
//           NxShowSimpleMessage(floattostr(mcastka),nil);
           if mcastka=0 then begin
               mi:=os.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 , X_state=' + quotedstr('9XQ1000101') + ' where ServiceDocument_ID=' +quotedstr(mid) +
               ' and ((x_state=' + quotedstr('8XQ1000101')  + ') or (x_state=' + quotedstr('3VW1000101')+ '))' ) ;
              mi:=os.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('9500000101') + ' where id=' +quotedstr(mid)) ;
              mbo:=os.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
              if not nxisemptyoid(mid) then begin
                  try
                    mbo.Load(mid,nil);
                         mrx:=TStringList.create;
                         try
                             os.SQLSelect(format('select sd.id from ServiceDocuments sd left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.ServicedObject_ID=%s and sd.Docqueue_ID=%s and ss.PosIndex<15 and sd.id<>%s',
                            [quotedstr(mbo.GetFieldValueAsString('ServicedObject_ID')),quotedstr(mbo.GetFieldValueAsString('DocQueue_ID')),quotedstr(mbo.OID)]),mrx);
                            if mrx.count>0 then begin
                                 mi:=os.SQLExecute('Update ServiceDocuments set X_state=' + quotedstr('2000000101') + ' where id=' + QuotedStr(mrx.Strings[0])) ;
                            end;
                         finally
                             mrx.free;
                         end;

                  finally
                    mbo.free;
                  end;
              end;
           end else begin


           end;


        end;


      //end;

  finally
   mr.free;
  end;
end;


procedure Stav_zaplaceni_SQL(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
mi:integer;
begin
  mi:=os.SQLExecute('update ServiceDocuments A set A.ServiceDocState_ID=' + quotedstr('9500000101') + ' WHERE  (A.ServiceDocState_ID = ' + quotedstr('E102000000') +
                    ' ) AND (exists(select 1 from ServiceDocuments SD left join ServiceAssemblyForms SA on sa.ServiceDocument_ID=sd.id left join ServiceAssemblyForms2 SA2 on sa2.Parent_ID=sa.id left join issuedinvoices2 II2 on ii2.X_parent_id=sa2.id left join issuedinvoices II on ii.id=ii2.parent_ID where ' +
                    ' (SD.ServiceDocState_ID='+ quotedstr('E102000000') + ' and ((ii.Docqueue_ID=' + quotedstr('8D00000101') + ') or (ii.Docqueue_ID=' + quotedstr('7D00000101') +
                    ')) and (sd.id =A.ID)) and ((ii.Amount + ii.PaidCreditAmount - ii.PaidAmount -  ii.CreditAmount)=0)))')   ;

end;




begin
end.