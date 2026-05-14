

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon,mMon_target: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mID_Head,mID_row:string;
    mstav:boolean;
    mi:integer;
begin

 if self.getFieldValueAsString('Docqueue_ID')='7F00000101' then begin ;
             mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
            for i := 0 to mMon.Count-1 do begin


                  try

                      mRow := mMon.BusinessObject[i];

                      if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                         mr:=TStringList.create;
                             self.ObjectSpace.SQLSelect('select max(io.id||io2.id) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_ID where io.DocQueue_ID=' + quotedstr('1Q10000101') +' and io2.X_parent_ID='+ quotedstr(mrow.GetFieldValueAsString('X_Parent_ID')),mr);
                              if mr.count>0 then begin
                                    mID_Head:=copy(mr.Strings[0],1,10);
                                    mID_row:=copy(mr.Strings[0],11,10);
                                    mstav:=true;
                                   mi:=Self.ObjectSpace.SQLExecute('update IssuedOrders2 set DeliveredQuantity=' + NxFloatToIBStr(mrow.getFieldValueAsFLoat('Quantity')) +' where id=' + quotedstr(mID_row))

                                    {mBO_target := self.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                    mBO_target.Load(mID_Head,nil);

                                          mMon_target:= mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
                                              for ii := 0 to mMon_target.Count-1 do begin

                                                    mNewRow:= mMon_target.BusinessObject[i];
                                                    if mNewRow.OID=mID_row then begin
                                                          mNewRow.SetFieldValueAsFLoat('DeliveredQuantity', mrow.getFieldValueAsFLoat('Quantity'));
                                                          mNewRow.Save;
                                                    end;
                                                    if mNewRow.getFieldValueAsFLoat('DeliveredQuantity')<> (mrow.getFieldValueAsFLoat('Quantity')) then begin
                                                       mstav:=false;
                                                    end;

                                              end;
                                    mBO_target.SetFieldValueAsBoolean('Closed',mstav);
                                    mBO_target.save;
                                    mBO_target.refresh;
                                   mBO_target.free;

;                                 }
                              end;
                          mr.free;
                      end;
                  finally
                  end;



            end;

 end;

end;

procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon,mMon_target: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mID:string;
    mID_Head,mID_Row:string;
    mstav:boolean;
    mi:integer ;
begin
 if self.getFieldValueAsString('Docqueue_ID')='7F00000101' then begin ;
           mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          for i := 0 to mMon.Count-1 do begin
                try
                    mRow := mMon.BusinessObject[i];

                     if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                         mr:=TStringList.create;
                             self.ObjectSpace.SQLSelect('select max(io.ID||io2.id) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_ID where io.DocQueue_ID=' + quotedstr('1Q10000101') +' and io2.X_parent_ID='+ quotedstr(mrow.GetFieldValueAsString('X_Parent_ID')),mr);

                              if mr.count>0 then begin
                              mID_Head:=copy(mr.Strings[0],1,10);
                              mID_row:=copy(mr.Strings[0],11,10);

                                    mi:=Self.ObjectSpace.SQLExecute('update IssuedOrders2 set DeliveredQuantity=' +
                                    NxFloatToIBStr(0) +' where id=' + quotedstr(mID_row))

                                  {
                                    mBO_target := self.ObjectSpace.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');
                                    mBO_target.Load(mID_Head,nil);
                                         mstav:=true;
                                         mMon_target:= mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
                                         for ii := 0 to mMon_target.Count-1 do begin
                                              mNewRow:= mMon_target.BusinessObject[ii];
                                              if mNewRow.oid=mID_row then begin
                                                 mNewRow.SetFieldValueAsFLoat('DeliveredQuantity', 0);
                                                 mNewRow.Save;
                                              end;
                                              if mNewRow.getFieldValueAsFLoat('DeliveredQuantity') - mNewRow.getFieldValueAsFLoat('DeliveredQuantity')>0 then begin
                                                 mstav:=false ;
                                              end;

                                         end;

                                        mBO_target.SetFieldValueAsBoolean('Closed', mstav);

                                    mBO_target.save;
                                   mBO_target.free;   }
                             end;
                          mr.free;
                      end;

                finally
                end;


          end;


     end;
end;



begin
end.