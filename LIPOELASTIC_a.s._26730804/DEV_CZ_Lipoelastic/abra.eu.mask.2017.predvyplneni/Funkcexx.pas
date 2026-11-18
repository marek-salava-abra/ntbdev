function GetBusTransaction_ID(mRows:TNxCustomBusinessObject):TNxOID;
begin
    if not NxIsEmptyOID(mRows.GetFieldValueAsstring('Storecard_ID')) then begin
           result:=(mRows.GetFieldValueAsString('StoreCard_id.X_Obchodni_pripad'));
    end;
end;

function GetProject_ID(mRows:TNxCustomBusinessObject):TNxOID;         // typ obchodu
var
  mr,mr1,mr2:tstringlist;
  mbo:TNxCustomBusinessObject;
  mID:string;
  mBustransaction_ID:string;
begin
      mID:='';
      result:='';
          // z tabulky
           // není osoba z tabulky

           if not nxisemptyoid('Parent_id.Person_ID') then begin

                             mr:=TStringList.create;
                             try
                                  mRows.objectspace.sqlselect('select X_BusProject_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_Office_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.FirmOffice_ID')) +
                                      ' and X_person_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.Person_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                      if mr.count=1 then begin
                                      //NxShowSimpleMessage('tabulka firma provozovna osoba',nil);
                                          result:=mr.Strings[0];
                                          mid:=mr.Strings[0];
                                      end;
                             finally
                                mr.free;
                             end;

                             if mid='' then begin
                                 mr:=TStringList.create;
                                 try
                                  mRows.objectspace.sqlselect('select X_BusProject_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_person_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.Person_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                    if mr.count=1 then begin
                                        //NxShowSimpleMessage('tabulka firma osoba',nil);
                                        result:=mr.Strings[0];
                                        mid:=mr.Strings[0];
                                    end;
                                 finally
                                    mr.free;
                                 end;
                              end;
                              if mid='' then begin
                                 mr:=TStringList.create;
                                 try
                                  mRows.objectspace.sqlselect('select X_BusProject_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and X_person_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.Person_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                    if mr.count=1 then begin     // osoba
                                        //NxShowSimpleMessage('tabulka osoba',nil);
                                        result:=mr.Strings[0];
                                        mid:=mr.Strings[0];
                                    end;
                                 finally
                                    mr.free;
                                 end;
                              end;
                          // přímo z dat
                          if mid='' then begin
                              result:=mRows.GetFieldValueAsString('Parent_id.Person_id.X_BusProject_ID')
                          end;
                      end;

                      if nxisemptyoid('Parent_id.Person_ID') then begin
                           mr:=TStringList.create;
                             try
                                  mRows.objectspace.sqlselect('select X_BusProject_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_Office_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.FirmOffice_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                      if mr.count=1 then begin
                                      //NxShowSimpleMessage('tabulka firma provozovna ',nil);
                                          result:=mr.Strings[0];
                                          mid:=mr.Strings[0];
                                      end;
                             finally
                                mr.free;
                             end;

                             if mid='' then begin
                                 mr:=TStringList.create;
                                 try
                                  mRows.objectspace.sqlselect('select X_BusProject_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                    if mr.count=1 then begin
                                        //NxShowSimpleMessage('tabulka firma osoba',nil);
                                        result:=mr.Strings[0];
                                        mid:=mr.Strings[0];
                                    end;
                                 finally
                                    mr.free;
                                 end;
                                 //if mid<>'' then NxShowSimpleMessage('id z tabulky' + mid,nil);
                              end;


                              if mid='' then begin
                                    if not nxisemptyoid(mRows.getfieldvalueasstring('Parent_id.FirmOffice_ID.X_BusProject_ID')) then result:=mRows.GetFieldValueAsString('Parent_id.FirmOffice_ID.X_BusProject_ID') else begin
                                          if not nxisemptyoid(mRows.getfieldvalueasstring('Parent_id.Firm_ID.X_BusProject_ID')) then result:=mRows.GetFieldValueAsString('Parent_id.Firm_id.X_BusProject_ID');
                                    end;
                              //if mid<>'' then NxShowSimpleMessage('id z čiselniku' + mid,nil);
                              end;


                      end;





end;

function GetBusOrder_ID(mRows:TNxCustomBusinessObject):TNxOID;       // obchodník
var
  mr,mr1,mr2:tstringlist;
  mbo:TNxCustomBusinessObject;
  mID:string;
  mBustransaction_ID:string;
begin
      mID:='';
      result:='';
          // z tabulky
           // není osoba z tabulky

           if not nxisemptyoid('Parent_id.Person_ID') then begin

                             mr:=TStringList.create;
                             try
                                  mRows.objectspace.sqlselect('select X_BusOrder_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_Office_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.FirmOffice_ID')) +
                                      ' and X_person_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.Person_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                      if mr.count=1 then begin
                                      //NxShowSimpleMessage('tabulka firma provozovna osoba',nil);
                                          result:=mr.Strings[0];
                                          mid:=mr.Strings[0];
                                      end;
                             finally
                                mr.free;
                             end;

                             if mid='' then begin
                                 mr:=TStringList.create;
                                 try
                                  mRows.objectspace.sqlselect('select X_BusOrder_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_person_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.Person_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                    if mr.count=1 then begin
                                        //NxShowSimpleMessage('tabulka firma osoba',nil);
                                        result:=mr.Strings[0];
                                        mid:=mr.Strings[0];
                                    end;
                                 finally
                                    mr.free;
                                 end;
                              end;
                              if mid='' then begin
                                 mr:=TStringList.create;
                                 try
                                  mRows.objectspace.sqlselect('select X_BusOrder_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and X_person_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.Person_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                    if mr.count=1 then begin     // osoba
                                        //NxShowSimpleMessage('tabulka osoba',nil);
                                        result:=mr.Strings[0];
                                        mid:=mr.Strings[0];
                                    end;
                                 finally
                                    mr.free;
                                 end;
                              end;
                          // přímo z dat
                          if mid='' then begin
                              result:=mRows.GetFieldValueAsString('Parent_id.Person_id.X_BusOrder_ID')
                          end;
                      end;

                      if nxisemptyoid('Parent_id.Person_ID') then begin
                           mr:=TStringList.create;
                             try
                                  mRows.objectspace.sqlselect('select X_BusOrder_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_Office_ID=' + quotedstr(mRows.GetFieldValueAsString('Parent_id.FirmOffice_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                      if mr.count=1 then begin
                                      //NxShowSimpleMessage('tabulka firma provozovna ',nil);
                                          result:=mr.Strings[0];
                                          mid:=mr.Strings[0];
                                      end;
                             finally
                                mr.free;
                             end;

                             if mid='' then begin
                                 mr:=TStringList.create;
                                 try
                                  mRows.objectspace.sqlselect('select X_BusOrder_ID from defrolldata where clsid=' + quotedstr('0IUJNYXHSF2ORJ2CUL2XVEMLJW') +
                                      ' and  x_firm_id='+ quotedstr(mRows.GetFieldValueAsString('Parent_id.Firm_ID')) +
                                      ' and X_Bustransaction_ID=' + quotedstr(mRows.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))+ ' and hidden= ' + quotedstr('N'),mr);
                                    if mr.count=1 then begin
                                        //NxShowSimpleMessage('tabulka firma osoba',nil);
                                        result:=mr.Strings[0];
                                        mid:=mr.Strings[0];
                                    end;
                                 finally
                                    mr.free;
                                 end;
                                 //if mid<>'' then NxShowSimpleMessage('id z tabulky' + mid,nil);
                              end;


                              if mid='' then begin
                                    if not nxisemptyoid(mRows.getfieldvalueasstring('Parent_id.FirmOffice_ID.X_BusOrder_ID')) then result:=mRows.GetFieldValueAsString('Parent_id.FirmOffice_ID.X_BusOrder_ID') else begin
                                          if not nxisemptyoid(mRows.getfieldvalueasstring('Parent_id.Firm_ID.X_BusOrder_ID')) then result:=mRows.GetFieldValueAsString('Parent_id.Firm_id.X_BusOrder_ID');
                                    end;
                              //if mid<>'' then NxShowSimpleMessage('id z čiselniku' + mid,nil);
                              end;


                      end;





end;

function GetBusDivision_ID(mRows:TNxCustomBusinessObject):TNxOID;
begin

end;

function GetPrice_ID(mRows:TNxCustomBusinessObject):Double;
begin

end;

begin
end.