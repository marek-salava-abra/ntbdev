function IssuedOrder_State_ID (Self:TNxCustomBusinessObject):string;
var
   mr:tstringlist;
   mState_ID:string;
begin
mState_ID:='';
 {if self.getFieldValueAsString('PMState_ID')<>'3070000101' then begin   // není stornováno

          if ((self.GetFieldValueAsInteger('PMState_ID.SequenceNumber')<5) and (self.GetFieldValueAsBoolean('Confirmed'))) then begin   // Přijato    5
              mState_ID:=('4000000101');
              mr:=TStringList.create;
              try
                 self.ObjectSpace.SQLSelect('Select sum(Amount-PaidAmount) from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(self.oid) + ' and DocQueue_ID<>' + quotedstr('47D2000101'),mr);
                 if NxIBStrToFloat(mr.Strings[0])>0 then begin
                      mState_ID:=('RODEF00000');     // čeká na platbu
                 end else begin
                      mState_ID:=('2000000101');     // v přípravě
                 end;
              finally
                  mr.free;
              end;
          end;
          if ((self.GetFieldValueAsInteger('PMState_ID.SequenceNumber')<30) and (not nxisemptyoid(self.GetFieldValueAsString('X_Logistik_ID')))) then begin   // Vychystávání  30
              mState_ID:=('5050000101');
          end;

          if ((self.GetFieldValueAsInteger('PMState_ID.SequenceNumber')<90) and (self.GetFieldValueAsBoolean('Closed'))) then begin   // vyřízeno      90
              mState_ID:=('3040000101');
          end;

          if ((self.GetFieldValueAsBoolean('X_canceled'))) then begin   // stornováno          99
              mState_ID:=('3070000101');
          end;

           if not (self.GetFieldValueAsBoolean('Confirmed')) then begin
              mState_ID:=('1000000101');
           end;

   end; }

   result:=mState_ID;
end;




function Receivedorder_State_ID (Self:TNxCustomBusinessObject):string;
var
   mr:tstringlist;
   mState_ID:string;
begin
mState_ID:='';
 if self.getFieldValueAsString('PMState_ID')<>'3070000101' then begin   // není stornováno

           if (self.GetFieldValueAsBoolean('Confirmed')) then begin
                 mState_ID:=('4000000101');       // přijato
                       mr:=TStringList.create;
                              try
                              self.ObjectSpace.SQLSelect('Select id from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(self.oid) + ' and DocQueue_ID<>' + quotedstr('47D2000101'),mr);
                                    if mr.count<>0 then begin   // existuje záloha
                                          self.ObjectSpace.SQLSelect('Select sum(Amount-PaidAmount) from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(self.oid) + ' and DocQueue_ID<>' + quotedstr('47D2000101'),mr);
                                                 if NxIBStrToFloat(mr.Strings[0])>0 then begin
                                                      mState_ID:=('RODEF00000');     // čeká na platbu
                                                 end else begin
                                                      mState_ID:=('2000000101');     // v přípravě
                                                 end;

                                    end else begin
                                        mState_ID:=('2000000101');      // bez zálohy  v přípravě
                                    end;
                              finally
                                  mr.free;
                              end;
                end else begin

                 mState_ID:=('1000000101');
            end;


                      if (mState_ID=('4000000101')) and (not nxisemptyoid(self.GetFieldValueAsString('X_Logistik_ID'))) then begin   // Vychystávání  30
                          mState_ID:=('5050000101');
                      end;

                  //*********
                  if (self.GetFieldValueAsBoolean('Confirmed')) then begin
                      if  ( not nxisemptyoid(self.GetFieldValueAsString('X_Logistik_ID'))) then begin
                           if (self.GetFieldValueAsBoolean('Closed')) then begin
                               mState_ID:=('3000000101');
                           end else begin
                               mState_ID:=('5050000101');
                           end;
                      end;
                  end;

                  if (mState_ID=('3000000101')) then begin
                              // je faktura?
                               mr:=TStringList.create;
                              try
                                 self.ObjectSpace.SQLSelect('SELECT ro.id FROM Receivedorders RO join Receivedorders2 RO2 on ro2.parent_id=RO.id WHERE ((not exists (SELECT 1 FROM IssuedInvoices2 II2 left join Storedocuments2 SD2 on SD2.id=II2.ProvideRow_ID where SD2.ProvideRow_ID=RO2.ID )) '
                                                          + ' or ( exists (SELECT 1 FROM IssuedInvoices2 II2 left join Storedocuments2 SD2 on SD2.id=II2.ProvideRow_ID where (SD2.ProvideRow_ID=RO2.ID) and (II2.Quantity<RO2.Quantity) )) ) '
                                                          + ' and (ro.id=' + quotedstr(self.OID) + ') group by RO.ID ',mr);

                                                if mr.count=0 then  begin
                                                      self.ObjectSpace.SQLSelect('SELECT sum(ii.Amount) -sum(II.PaidAmount) FROM Receivedorders RO join Receivedorders2 RO2 on ro2.parent_id=RO.id left join Storedocuments2 SD2 on SD2.ProvideRow_ID=RO2.ID left join IssuedInvoices2 II2 on SD2.id=II2.ProvideRow_ID left join IssuedInvoices II on ii.id=II2.Parent_ID '
                                                                                 + ' WHERE (ro.id=' + quotedstr(self.OID) + ')',mr);

                                                        if NxIBStrToFloat(mr.Strings[0])>0 then begin
                                                            mState_ID:=('2040000101');
                                                          //  NxShowSimpleMessage('Neni zaplaceno',nil);
                                                        end else begin
                                                            mState_ID:=('~000000102');
                                                           // NxShowSimpleMessage('Je zaplaceno',nil);
                                                        end;


                                                    //  NxShowSimpleMessage('Neni fakturováno vše',nil);

                                                end;
                              finally
                                  mr.free;
                              end;

                      // je zaplacena faktura




                  end;


               end;



                // if ((self.GetFieldValueAsInteger('PMState_ID.SequenceNumber')<90) and (self.GetFieldValueAsBoolean('Closed'))and (not (self.GetFieldValueAsBoolean('X_canceled')))) then begin   // vyřízeno      90
                //      mState_ID:=('3040000101');
                // end;

                 if ((self.GetFieldValueAsBoolean('X_canceled'))) then begin   // stornováno          99
                      mState_ID:=('3070000101');
                 end;



   result:=mState_ID;
end;

begin
end.