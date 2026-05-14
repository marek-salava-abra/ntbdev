Var
mbo_IssuedOrder:TNxCustomBusinessObject;
mMonIssuedInvoice: TNxCustomBusinessMonikerCollection;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target,mbo_IssuedOrder,mRowIsssuedinvoice: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow,mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr,mr1:TStringList;
    mfind:boolean ;
    mpocet:integer;

begin
 mpocet:=0;

 if self.getFieldValueAsString('Docqueue_ID')='ME00000101' then begin ;
    mbo_IssuedOrder:=self.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
 try
    mbo_IssuedOrder.New;
    mbo_IssuedOrder.Prefill;
    mbo_IssuedOrder.SetFieldValueAsString('Firm_ID', self.GetFieldValueAsString('Firm_ID'));
    mbo_IssuedOrder.SetFieldValueAsString('Description', 'Balíček z '+self.GetFieldValueAsString('Description'));
    mbo_IssuedOrder.SetFieldValueAsString('DocQueue_ID', '1Q10000101');



             mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
             mMonIssuedInvoice:= mbo_IssuedOrder.GetLoadedCollectionMonikerForFieldCode(mbo_IssuedOrder.GetFieldCode('ROWS'));
            for i := 0 to mMon.Count-1 do begin
                  try

                      mRow := mMon.BusinessObject[i];
                      if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                           // zápis do ML
                              mBO_target := self.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                              mBO_target.Load(mrow.GetFieldValueAsString('X_Parent_ID'),nil);
                                  mBO_target.SetFieldValueAsFLoat('QuantityDelivered', mrow.getFieldValueAsFLoat('Quantity'));
                              mBO_target.save;
                              mBO_target.free;
                           // kontrola a vytvoření balíčku
                             mr:=tstringlist.create;
                             try
                                self.ObjectSpace.SQLSelect(format('select count(io2.id) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                                  ' io.DocQueue_ID=%s and io2.X_parent_ID=%s',
                                                                  [quotedstr('1Q10000101'),quotedstr(mrow.getFieldValueAsstring('X_parent_id'))]),mr);
                                if strtoint(mr.Strings[0])=0 then begin
                                    // není objednávka od dispečera
                                    mr1:=TStringList.create;
                                    Try
                                        self.ObjectSpace.SQLSelect(format('select max(PLU) from StoreUnits where Parent_ID=%s and PLU>0',[quotedstr(mrow.GetFieldValueAsString('StoreCard_ID'))]),mr1);


                                       if mr1.Strings[0]<>'0' then begin

                                              if mRow.GetFieldValueAsInteger('RowType')=3 then begin
                                                  mRowIsssuedinvoice:= mMonIssuedInvoice.AddNewObject;
                                                  mRowIsssuedinvoice.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                                                  mRowIsssuedinvoice.SetFieldValueAsDateTime('DeliveryDate$Date', date);
                                                  mRowIsssuedinvoice.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                  mRowIsssuedinvoice.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                                                  mRowIsssuedinvoice.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
                                                  mRowIsssuedinvoice.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('X_parent_ID'));
                                                  mpocet:=mpocet+1;
                                              end;


                                            //NxShowSimpleMessage('jedná se o neobjednannou balíčkovou kartu, objednejte ji prosím',nil);
                                        end;
                                    finally
                                        mr1.free;
                                    end;
                                end;




                             finally
                                 mr.free;
                             end;
                      end;
                  finally
                  end;
             end;

      if mpocet>0 then begin
                    //TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44',NxCreateContext(self.ObjectSpace), mbo_IssuedOrder);
                    //mbo_IssuedOrder.save;
                    mpocet:=0;
      end;
     finally
         mbo_IssuedOrder.free;
     end;
  end;
end;

procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
begin
 if self.getFieldValueAsString('Docqueue_ID')='ME00000101' then begin ;
           mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          for i := 0 to mMon.Count-1 do begin
                try
                    mRow := mMon.BusinessObject[i];
                    if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                            mBO_target := self.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                            mBO_target.Load(mrow.GetFieldValueAsString('X_Parent_ID'),nil);
                               mBO_target.SetFieldValueAsFLoat('QuantityDelivered', 0);
                            mBO_target.save;

                        mBO_target.free;
                    end;

                finally
                end;


          end;


     end;
end;




{
Vyvolává se před načtením objektu z databáze.
}
procedure BeforeLoad_Hook(Self: TNxCustomBusinessObject);
begin

end;

begin
end.