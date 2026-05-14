

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
mMon:TNxCustomBusinessMonikerCollection;
I:integer;
mParent_id:string;
m_price:double;
begin
mParent_id:='';

mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
     for i := 0 to mMon.Count-1 do begin

        if not NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('X_Group_macro_ID')) then begin
                  // mprice:=mprice + mMon.BusinessObject[i].GetFieldValueAsFloat('X_Group_macro_ID') ;

              if uppercase(mMon.BusinessObject[i].getFieldValueAsString('X_Group_macro_ID.Specification2'))='ND' then begin
                           //if (mMon.BusinessObject[i].getFieldValueAsString('X_Group_macro_ID.Specification2')) then begin
                                 if mParent_id<>mMon.BusinessObject[i].getFieldValueAsString('X_Group_macro_ID') then m_price:=0;

                                     if mMon.BusinessObject[i].GetFieldValueAsInteger('Rowtype')=3 then begin

                                                  if mMon.BusinessObject[i].getFieldValueAsString('Storecard_ID.name')=mMon.BusinessObject[i].getFieldValueAsString('X_Group_macro_ID.name') then begin
                                                       m_price:=m_price+mMon.BusinessObject[i].getFieldValueAsfloat('TAmountWithoutVAT');
                                                       mMon.BusinessObject[i].setFieldValueAsfloat('unitprice',m_price/mMon.BusinessObject[i].getFieldValueAsfloat('Quantity'));

                                                  end else begin
                                                       m_price:=m_price+mMon.BusinessObject[i].getFieldValueAsfloat('TAmountWithoutVAT');
                                                       mMon.BusinessObject[i].setFieldValueAsfloat('unitprice',0);
                                                       mMon.BusinessObject[i].setFieldValueAsfloat('totalprice',0);

                                                  end;
                                       end;
                                          mParent_id:=mMon.BusinessObject[i].getFieldValueAsString('X_Group_macro_ID') ;

                          // end;
               end;
         end;
     end;
end;


begin
end.