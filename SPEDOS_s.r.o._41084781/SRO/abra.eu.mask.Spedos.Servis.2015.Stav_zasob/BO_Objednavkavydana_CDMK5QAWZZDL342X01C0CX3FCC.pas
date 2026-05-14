





{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mBO,mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mr,mr1,mr2:TStringList;
    mvykryto:boolean ;
    mstav:boolean ;
    mlistvykryto,mlistnevykryto:TStringList;
begin


if Self.GetFieldValueAsString('DocQueue_ID')='7J00000101' then begin                      // logistik
                mlist:=TStringList.create;
                mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                try
                      for i := 0 to mMon.Count-1 do begin
                        mRow := mMon.BusinessObject[i];
                               if not NxIsBlank(mrow.GetFieldValueAsString('X_parent_id')) then begin

                                     mr:=TStringList.create;
                                     try
                                         self.ObjectSpace.SQLSelect('Select (io2.parent_ID) from issuedorders2 IO2 left join issuedOrders IO on io.id=io2.parent_id where io.docqueue_ID=' + quotedstr('1Q10000101') +
                                                    ' and io2.X_parent_id=' + quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                                        if (mr.count)>0 then mlist.add(mr.Strings[0]);
                                     FINALLY
                                       mr.free;
                                     END;
                                end;

                       end;
                finally

                end;

                if mlist.Count>0 then begin
                     mbo:=self.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                      try
                                mbo.load(mList[0],nil);
                                mbo.save;
                      finally
                          mbo.free;
                      end;

                end;
             mlist.free;
end;




end;

procedure Beforesave_Hook(Self: TNxCustomBusinessObject);
var
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mBO,mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mr,mr1,mr2:TStringList;
    mvykryto:boolean ;
    mstav:boolean ;
    mlistvykryto,mlistnevykryto:TStringList;
    m_pocet,m_objednano:double;
begin

 if self.GetFieldValueAsString('DocQueue_ID')='1Q10000101' then begin                      // dispečer
 m_pocet:=0;
 m_objednano:=0;
 mvykryto:=true;
                mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                try
                      mList := TStringList.Create;
                      for i := 0 to mMon.Count-1 do begin
                        mRow := mMon.BusinessObject[i];

                            if mrow.GetFieldValueAsInteger('Rowtype')=3 then begin
                                m_pocet:=m_pocet+mrow.GetFieldValueAsFloat('Quantity');
                                m_objednano:=m_objednano +mrow.GetFieldValueAsFloat('X_skladem');
                                if (mrow.GetFieldValueAsFloat('Quantity') - mrow.GetFieldValueAsFloat('X_skladem'))>0 then begin
                                    mr:=tstringlist.create;
                                    try
                                        self.ObjectSpace.SQLSelect('Select sum(io2.quantity) from issuedorders2 IO2 left join issuedOrders IO on io.id=io2.parent_id where io.docqueue_ID=' + quotedstr('7J00000101') +
                                        ' and io2.X_parent_id=' + quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                         if NxStrToFloat(mr.Strings[0],',')>0 then begin
                                            m_objednano:=m_objednano +NxStrToFloat(mr.Strings[0],',');
                                            if (mrow.GetFieldValueAsFloat('Quantity') - NxStrToFloat(mr.Strings[0],',')- mrow.GetFieldValueAsFloat('X_skladem'))>0 then begin
                                               mvykryto:=false;
                                            end;
                                         end else begin
                                               mvykryto:=false;
                                         end;
                                    finally
                                       mr.free;
                                    end;
                                end;
                            end;
                      end;

              finally
                 mlist.free;
              end;
//                         if mvykryto then self.SetFieldValueAsString('X_Stav_objednvky','Vykryto') else self.SetFieldValueAsString('X_Stav_objednvky','Nevykryto')  ;

    if m_pocet>0 then begin
          if self.GetFieldValueAsFloat('X_Stav_objednavky')<>m_objednano/m_pocet then self.SetFieldValueAsFloat('X_Stav_objednavky',(m_objednano/m_pocet));
          if m_objednano>=m_pocet then self.SetFieldValueAsFloat('X_Stav_objednavky',1);
    end;
   end;


end;



begin
end.