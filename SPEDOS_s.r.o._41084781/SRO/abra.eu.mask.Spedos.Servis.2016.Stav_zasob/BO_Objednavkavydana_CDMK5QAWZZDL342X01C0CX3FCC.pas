





{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  i, mPosIndex: integer;
  mMon,mRows_ML: TNxCustomBusinessMonikerCollection;
  mBO,mRow,mRow_ML, mNewRow,mBO_ML: TNxCustomBusinessObject;
  mList: TStringList;
  mr,mr1,mr2:TStringList;
    mvykryto:boolean ;
    mstav:boolean ;
    mlistvykryto,mlistnevykryto:TStringList;
    mML_ID:string;
    m_pocet,m_objednano:double;
begin

if Self.GetFieldValueAsString('DocQueue_ID')='1Q10000101' then begin
      mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
       for i := 0 to mMon.Count-1 do begin
                        mRow := mMon.BusinessObject[i];
                               if (mrow.GetFieldValueAsString('X_parent_ID')<>'') and (mML_ID='') then begin
                                      mr:=TStringList.create ;
                                      try
                                          self.ObjectSpace.SQLSelect('select parent_id from ServiceAssemblyForms2 where id=' +
                                              quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                              if mr.count>0 then begin
                                                 mML_ID:=mr.Strings[0];

                                              end;
                                      finally
                                           mr.free;
                                      end;
                                end;

       end;


         if mML_ID<>'' then begin
                   mBO_ML:=self.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                   try
                      mBO_ML.load(mML_ID,nil);




                           if StrToInt(mBO_ml.getFieldValueAsstring('X_State.code'))<50 then begin
                           mBO_ml.SetFieldValueAsString('X_State','3IS1000101');
                                       //mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3IS1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));

                                      //mBO_ML.SetFieldValueAsString('X_state','3IS1000101');
                                      //mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));

                                       mRows_ML := mBO_ML.GetLoadedCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('ROWS'));

                                                for i := 0 to mRows_ML.Count-1 do begin
                                                    mRow_ML := mRows_ML.BusinessObject[i];
                                                    if (mRow_ML.GetFieldValueAsInteger('Itemtype')=1) then begin
                                                        m_pocet:=m_pocet + mRow_ML.GetFieldValueAsFloat('Quantity');
                                                        mr:=tstringlist.create;
                                                        try
                                                           mBO_ml.ObjectSpace.SQLSelect('select sum(io2.Quantity) from IssuedOrders2 IO2 where io2.X_parent_ID=' + quotedstr(mRow_ML.GetFieldValueAsString('ID')),mr);
                                                                 if mr.count>0 then begin
                                                                    if NxIBStrToFloat(mr.Strings[0])>0 then m_objednano:=m_objednano+NxIBStrToFloat(mr.Strings[0]);
                                                                 //NxShowSimpleMessage('mpocet' + NxFloatToIBStr(m_objednano),nil) ;
                                                                 end;
                                                         finally
                                                                mr.free;
                                                         end;
                                                    end;
                                                end;

                                                if m_pocet>0 then begin
                                                      if mBO_ml.GetFieldValueAsFloat('X_Stav_objednani')<>m_objednano/m_pocet then mBO_ml.SetFieldValueAsFloat('X_Stav_objednani',(m_objednano/m_pocet));
                                                      if m_objednano>=m_pocet then mBO_ml.SetFieldValueAsFloat('X_Stav_objednani',1);
                                                end;
                          end;
                      mbo_ml.save;
                      mbo_ml.ObjectSpace
                   finally
                      mBO_ML.free;
                   end;
         end;

 end;





if Self.GetFieldValueAsString('DocQueue_ID')='7J00000101' then begin                      // logistik
                mlist:=TStringList.create;
                mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                try
                      for i := 0 to mMon.Count-1 do begin
                        mRow := mMon.BusinessObject[i];
                               if mrow.GetFieldValueAsString('X_parent_ID')='' then mML_ID:=mrow.GetFieldValueAsString('X_parent_ID');

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