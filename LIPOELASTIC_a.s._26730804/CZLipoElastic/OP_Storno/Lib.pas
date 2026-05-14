function ZL_delete(mBO:TNxCustomBusinessObject):string;
var
mr:tstringlist;
i,ii :integer;
mbo_ZL:TNxCustomBusinessObject  ;
mmon:TNxCustomBusinessMonikerCollection;

begin
result:='';
mr:=tstringlist.create;
    try
       mbo.ObjectSpace.SQLSelect('select id from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(mbo.oid),mr);
       if mr.count>0 then begin
           mbo_ZL:=mbo.ObjectSpace.CreateObject('WEN033MLM3DL35J301C0CX3F40');
           try
               for i:=0 to mr.Count-1 do begin
                   mbo_zl.load(mr.Strings[i],nil);
                   mbo_ZL.MarkForDelete;
               end;
           finally
               mbo_zl.free;
           end;
       end;


    finally
        mr.free;
    end;

end;






{OP_storno}

function OP_storno(mBO:TNxCustomBusinessObject):string;
begin
result:='';
    mBO.SetFieldValueAsBoolean('Confirmed',false);
              mBO.SetFieldValueAsBoolean('X_canceled',True);
              mBO.SetFieldValueAsBoolean('Closed',True);
              //TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('PMState_ID','3070000101');
              mBO.SetFieldValueAsString('X_poznamka','Nezaplaceno k datu : ' + FormatDateTime('DD.MM.YYYY',now()) +'  ,  '+
                        mBO.getFieldValueAsString('X_poznamka'));
                     mBO.save;
                     //mbo.Refresh;
              result:= mBO.oid;
end;


function ZL_storno(mBO:TNxCustomBusinessObject):string;
var
mr:tstringlist;
i,ii :integer;
mbo_ZL:TNxCustomBusinessObject  ;
mmon:TNxCustomBusinessMonikerCollection;

begin
result:='';
mr:=tstringlist.create;
    try
       mbo.ObjectSpace.SQLSelect('select id from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(mbo.oid) ,mr);
       if mr.count>0 then begin
           mbo_ZL:=mbo.ObjectSpace.CreateObject('WEN033MLM3DL35J301C0CX3F40');
           try
               for i:=0 to mr.Count-1 do begin
                   mbo_zl.load(mr.Strings[i],nil);
                   try
                           mMon := mbo_zl.GetLoadedCollectionMonikerForFieldCode(mbo_zl.GetFieldCode('ROWS'));

                                    for ii := 0 to mMon.Count-1 do begin
                                          //if mMon.BusinessObject[ii].GetFieldValueAsInteger('RowType')=4 then begin
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('TAmount',0);
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('LocalTAmount',0);
                                          //end;
                                    end;
                          mbo_zl.save;
                         // NxShowSimpleMessage('Záloha ' + mbo_zl.DisplayName + ' k ' + mbo.DisplayName + ' byla vynulována', nil);

                    finally

                    end;
                   // mbo.Refresh;
                // mbo_zl.Refresh;
               end;
           finally
               mbo_zl.free;
           end;
       end;


    finally
        mr.free;
    end;

end;


begin
end.