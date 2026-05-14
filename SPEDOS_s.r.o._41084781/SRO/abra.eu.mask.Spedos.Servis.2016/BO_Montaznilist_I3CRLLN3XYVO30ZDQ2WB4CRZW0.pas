



{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mcode:integer;
mr:tstringlist;
begin
if self.GetFieldValueAsString('ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
        if osUpdated in self.State then begin
          if AFieldCode = Self.GetFieldCode('X_Protokol') then begin
                  if Length(avalue.AsString)=7 then begin
                     mr:=tstringlist.create;
                        try
                            self.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where X_Protokol='+quotedstr(avalue.AsString) + ' and X_Protokol_prefix='+quotedstr(Self.GetFieldValueAsString('X_Protokol_prefix')),mr);
                               //NxShowSimpleMessage(IntToStr(mr.Count),nil);
                               if mr.count>0 then begin
                                  if self.oid<>mr.Strings[0] then begin
                                     NxShowSimpleMessage('Pozor, číslo protokolu již existuje',nil);
                                  end;
                               end;
                        finally
                            mr.free;
                        end;
                   end;

          end;
        end;
//        if AFieldCode = self.GetFieldValueAsDateTime('Startdate$date') then begin
//         if avalue.AsDateTime<>AOriginalValue.AsDateTime then begin
//           NxShowSimpleMessage(self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID'),nil);
//        end;
end;
end;


{
Vyvolává se před fyzickým vymazáním vlastního objektu z databáze.
}
procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mr:TStringList;
  mi:Integer;
begin
      if self.GetFieldValueAsString('ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
          mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                              for i := 0 to mMon.Count-1 do begin
                                  mRow := mMon.BusinessObject[i];
                                  if ((mRow.GetFieldValueAsInteger('itemtype')=4) and (mRow.GetFieldValueAsString('text')='Práce - evidenční pro mzdy'))
                                      or (mRow.GetFieldValueAsInteger('itemtype')=0)

                                      then begin
                                      //NxShowSimpleMessage('Mazání dokladu',nil);
                                        mi:=self.ObjectSpace.SQLExecute('delete from CRMActivities where X_parent_ID=' + quotedstr(mrow.oid));
                                  end;
                              end;
      end;
end;

procedure Beforesave_Hook(Self: TNxCustomBusinessObject);
var
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mr:TStringList;
    mvykryto:boolean ;
    mstav:boolean ;
    mkoeficient:double;
    mkoeficient_oprava:double;
    m_pocet,m_objednano:double;
    mtechnik:string;
    mresult:Boolean;
begin
if self.GetFieldValueAsString('ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
        if self.GetFieldValueAsDateTime('X_CreatedDate$DATE')<100 then self.SetFieldValueAsDateTime('X_CreatedDate$DATE',now()) ;

           if nxisemptyoid(self.getFieldValueAsString('X_Path')) then begin ;       // cesta k úložišti
             self.SetFieldValueAsString('X_path',(Format('%s\%s\%s\%s\%s', [self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML',self.oid])));

           end;
          if self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID') <> self.GetFieldValueAsString('X_ServicedObject_ID') then begin
                  self.SetFieldValueAsString('X_ServicedObject_ID',self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'));
          end;

           mr:=tstringlist.create;         // napočítání koeficientu
           try
           self.ObjectSpace.SQLSelect('select count(sa2.id) from SERVICEASSEMBLYFORMS2 sa2 where sa2.itemtype=4 and sa2.text=' + quotedstr('Práce - evidenční pro mzdy') + ' and sa2.parent_ID=' + quotedstr(self.oid),mr);
                 if mr.count>0 then begin
                    if NxIBStrToFloat(mr.Strings[0])>0 then begin
                          mkoeficient:=trunc(100/(NxIBStrToFloat(mr.Strings[0])));
                              mkoeficient_oprava:=100-(mkoeficient*(NxIBStrToFloat(mr.Strings[0])));
                         end;
                    end
            finally
                mr.free;
            end;
            {m_pocet:=0;
            m_objednano:=0;

            mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                                for i := 0 to mMon.Count-1 do begin
                                    mRow := mMon.BusinessObject[i];
                                    if (mRow.GetFieldValueAsInteger('itemtype')=4) and (mRow.GetFieldValueAsString('text')='Práce - evidenční pro mzdy')  then begin
                                        mrow.SetFieldValueAsFloat('X_koeficient',mkoeficient+mkoeficient_oprava);
                                        mkoeficient_oprava:=0;
                                        if not nxisemptyoid(mrow.GetFieldValueAsString('X_workerrole_ID')) then begin
                                             mtechnik:=mrow.getFieldValueAsString('X_Workerrole_ID');
                                        end else begin
                                           mtechnik:= mrow.getFieldValueAsString('Workerrole_ID');
                                        end;
                                        //mresult:=NxCRM(0,mRow,mtechnik,mrow.GetFieldValueAsDateTime('X_Konec_prace')-0.14,mrow.GetFieldValueAsDateTime('X_Konec_prace'));
                                    end;

                                    if (mRow.GetFieldValueAsInteger('itemtype')=1) then begin
                                        m_pocet:=m_pocet + mRow.GetFieldValueAsFloat('Quantity');
                                        mr:=tstringlist.create;
                                        try
                                           self.ObjectSpace.SQLSelect('select sum(io2.Quantity) from IssuedOrders2 IO2 where io2.X_parent_ID=' + quotedstr(mrow.GetFieldValueAsString('ID')),mr);
                                                 if mr.count>0 then begin
                                                    if NxIBStrToFloat(mr.Strings[0])>0 then m_objednano:=m_objednano+NxIBStrToFloat(mr.Strings[0]);
                                                 end;
                                         finally
                                                mr.free;
                                         end;
                                    end;
                                end;

            if m_pocet>0 then begin
                  if self.GetFieldValueAsFloat('X_Stav_objednani')<>m_objednano/m_pocet then self.SetFieldValueAsFloat('X_Stav_objednani',(m_objednano/m_pocet));
                  if m_objednano>=m_pocet then self.SetFieldValueAsFloat('X_Stav_objednani',1);
            end;
                 }

                 if not nxisblank(self.GetFieldValueAsstring('X_zavada_code')) then begin
                          mr:=tstringlist.create;
                          try
                               self.ObjectSpace.SQLSelect('select ID FROM DefRollData WHERE CLSID = ''FOJ2LARQEZ34F1WPAVKBORUFOC'' AND code='+
                                quotedstr(copy(self.GetFieldValueAsString('X_zavada_code'),5,3)),mr);
                                     if mr.count>0 then self.SetFieldValueAsString('X_Opravovana_cast_ID',mr.Strings[0]);
                          finally
                               mr.free;
                          end;
                          mr:=tstringlist.create;
                          try
                               self.ObjectSpace.SQLSelect('select ID FROM DefRollData WHERE CLSID = ''H2WTBSP5ZWVOB1UVQHWUI1ABKK'' AND code='+
                                quotedstr(copy(self.GetFieldValueAsString('X_zavada_code'),3,2)),mr);
                                     if mr.count>0 then self.SetFieldValueAsString('X_Typ_poruchy_ID',mr.Strings[0]);
                          finally
                               mr.free;
                          end;
                          mr:=tstringlist.create;
                          try
                               self.ObjectSpace.SQLSelect('select ID FROM DefRollData WHERE CLSID = ''UAM5BGU23YMOF4QOEHZYGUML1C'' AND code='+
                                quotedstr(copy(self.GetFieldValueAsString('X_zavada_code'),1,2)),mr);
                                     if mr.count>0 then self.SetFieldValueAsString('X_Pricina_poruchy_ID',mr.Strings[0]);
                          finally
                               mr.free;
                          end;



                 end;






                  if trunc(self.GetFieldValueAsDateTime('StartDate$DATE'))=trunc(self.GetFieldValueAsDateTime('EndDate$DATE'))  then begin
                      if self.GetFieldValueAsDateTime('StartDate$DATE')>=self.GetFieldValueAsDateTime('EndDate$DATE') then self.setFieldValueAsDateTime('StartDate$DATE',self.GetFieldValueAsDateTime('EndDate$DATE')-0.01);
                  end else begin
                      self.setFieldValueAsDateTime('StartDate$DATE',self.GetFieldValueAsDateTime('EndDate$DATE')-0.01);
                  end;
            if nxisblank(self.getFieldValueAsString('X_protokol_prefix')) then begin
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then self.SetFieldValueAsString('X_protokol_prefix','S');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='5B20000101' then self.SetFieldValueAsString('X_protokol_prefix','S');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101' then self.SetFieldValueAsString('X_protokol_prefix','P');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101' then self.SetFieldValueAsString('X_protokol_prefix','P');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='7B20000101' then self.SetFieldValueAsString('X_protokol_prefix','B');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101' then self.SetFieldValueAsString('X_protokol_prefix','B');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101' then self.SetFieldValueAsString('X_protokol_prefix','F');
              if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101' then self.SetFieldValueAsString('X_protokol_prefix','F');
          end;
        //  if NxIsEmptyOID(self.getFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID')) then begin
        //     NxShowSimpleMessage('Pro práci s dodkladem musí být vyplněn obchodní případ. Prosím doplňte na Servisovaném předmětu zařízení, výrobce a druh zařízení, jinak dojde k problémům se zaúčtováním',nil);
        //  end;
        end;
end;


procedure New_Hook(Self: TNxCustomBusinessObject);
begin
    if self.GetFieldValueAsString('ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then self.SetFieldValueAsString('X_protokol_prefix','S');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='5B20000101' then self.SetFieldValueAsString('X_protokol_prefix','S');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101' then self.SetFieldValueAsString('X_protokol_prefix','P');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101' then self.SetFieldValueAsString('X_protokol_prefix','P');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='7B20000101' then self.SetFieldValueAsString('X_protokol_prefix','B');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101' then self.SetFieldValueAsString('X_protokol_prefix','B');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101' then self.SetFieldValueAsString('X_protokol_prefix','F');
          if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101' then self.SetFieldValueAsString('X_protokol_prefix','F');
          self.SetFieldValueAsDateTime('StartDate$DATE',self.GetFieldValueAsDateTime('ServiceDocument_ID.PromisedDeadLine$DATE')- EncodeTime(1,0,0,0));
          self.SetFieldValueAsDateTime('EndDate$DATE',self.GetFieldValueAsDateTime('ServiceDocument_ID.PromisedDeadLine$DATE'));
          self.SetFieldValueAsstring('X_Docqueue_ID',self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID'));
          self.SetFieldValueAsInteger('X_Ordnumber',self.GetFieldValueAsInteger('ServiceDocument_ID.Ordnumber'));
          self.SetFieldValueAsstring('X_Period_ID',self.GetFieldValueAsString('ServiceDocument_ID.Period_ID'));
    end;
end;

begin
end.