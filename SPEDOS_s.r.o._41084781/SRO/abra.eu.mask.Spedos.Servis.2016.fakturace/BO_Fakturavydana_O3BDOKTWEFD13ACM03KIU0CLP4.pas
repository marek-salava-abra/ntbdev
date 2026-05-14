{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mi:integer;
    mnezaplaceno:double;
begin
 if (self.getFieldValueAsString('Docqueue_ID')='8D00000101') or (self.getFieldValueAsString('Docqueue_ID')='7D00000101')
 or (self.getFieldValueAsString('Docqueue_ID')='AD00000101') or (self.getFieldValueAsString('Docqueue_ID')='2I20000101')

  then begin ;
             mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
       try
            mlist:=TStringList.create;
            for i := 0 to mMon.Count-1 do begin


                      mRow := mMon.BusinessObject[i];
                      if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                              try
                                  mBO_target := self.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                                  mBO_target.Load(mrow.GetFieldValueAsString('X_Parent_ID'),nil);
                                  mBO_target.SetFieldValueAsString('InvoicingDocType','03');
                                  mBO_target.SetFieldValueAsString('InvoicingDoc_ID',mrow.OID);
                                  mBO_target.SetFieldValueAsInteger('IsInvoiced',1);
                                  mBO_target.save;
                                  mlist.Add(mBO_target.GetFieldValueAsString('Parent_ID.ServiceDocument_ID'));
                              finally
                                  mBO_target.free;
                              end;

                      end;
           end;
            mlist.Sort;
                for i := 0 to mlist.Count-1 do begin
                            try
                                mBO_target := self.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                mBO_target.Load(mlist.Strings[i],nil);

                                //if mBO_target.getFieldValueAsString('ServiceDocState_ID')='D102000000' then begin
                                   mi:=self.ObjectSpace.SQLExecute('Update ServiceDocuments set X_Fakturovano=' + NxFloatToIBStr(self.GetFieldValueAsFloat('Amount'))+' , InvoicedAmount=' + NxFloatToIBStr(self.GetFieldValueAsFloat('AmountWithoutVAT'))+' , X_Nezaplaceno=' + NxFloatToIBStr(self.GetFieldValueAsFloat('PaidAmount')) +' , ServiceDocState_ID=' + quotedstr('E102000000') +', X_Datum_fakturace=' + IntToStr(trunc(self.GetFieldValueAsDateTime('CreatedAt$DATE')))+ ' where id=' +quotedstr(mlist.Strings[i])) ;
                                   mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 , X_state=' + quotedstr('8XQ1000101') + ' where AssemblyState=3 and ServiceDocument_ID=' +quotedstr(mlist.Strings[i]) +
                                    ' and ((x_state=' + quotedstr('D102000000')+')' +
                                     ' or (x_state=' + quotedstr('5XQ1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('45W1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('3NR1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('3Q22000101')+ ')' +
                                     ' or (x_state=' + quotedstr('3IS1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('7XQ1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('6XQ1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('AXQ1000101')+ ')' +
                                     ' or (x_state=' + quotedstr('3JS1000101')+ '))' +

                                      ) ;






















                                //end else begin
                                //     mi:=self.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('E102000000') + ' where id=' +quotedstr(mlist.Strings[i])) ;
                                //     mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 , X_state=' + quotedstr('9XQ1000101') + ' where ServiceDocument_ID=' +quotedstr(mlist.Strings[i]) +
                                //   ' and x_state=' + quotedstr('D102000000')) ;
                                //end;
                            finally
                                mBO_target.free;
                            end;
                    // end;

                 end ;
          finally
                  mlist.free;
          end;
 end;

end;

procedure beforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mi:integer;
begin
 if (self.getFieldValueAsString('Docqueue_ID')='8D00000101') or (self.getFieldValueAsString('Docqueue_ID')='7D00000101') then begin ;
           mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          try
          mlist:=TStringList.create;


                    for i := 0 to mMon.Count-1 do begin

                              mRow := mMon.BusinessObject[i];
                              if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                                  try
                                      mBO_target := self.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                                      mBO_target.Load(mrow.GetFieldValueAsString('X_Parent_ID'),nil);
                                          mBO_target.SetFieldValueAsString('InvoicingDocType','');
                                          mBO_target.SetFieldValueAsString('InvoicingDoc_ID','');
                                          mBO_target.SetFieldValueAsInteger('IsInvoiced',0);


                                      mlist.Add(mBO_target.GetFieldValueAsString('Parent_ID.ServiceDocument_ID'));

                                      mBO_target.save;
                                   finally
                                   mBO_target.free;
                                   end;


                              end;



                    end;
                    mlist.Sort;
                        for i := 0 to mlist.Count-1 do begin
                                    mi:=self.ObjectSpace.SQLExecute('update ServiceDocuments set ServiceDocState_ID='+quotedstr('D102000000') + ' where id=' + quotedstr(mlist.Strings[i]));
                                    mi:=self.ObjectSpace.SQLExecute('update ServiceAssemblyForms set X_State='+quotedstr('6XQ1000101') + ' where ServiceDocument_ID=' + quotedstr(mlist.Strings[i]));
                         end ;
          finally
                          mlist.free;
          end;
     end;
end;





begin
end.