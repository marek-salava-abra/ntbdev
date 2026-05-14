uses 'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
    if AFieldCode = Self.GetFieldCode('PayerFirm_ID') then begin
        self.SetFieldValueAsString('Firm_ID',AValue.AsString);
        if not nxisblank(self.getFieldValueAsString('Firm_ID.X_Celorocni_objednavky')) then
               self.SetFieldValueAsString('X_Celorocni_objednavky',self.getFieldValueAsString('Firm_ID.X_Celorocni_objednavky'));
    end;
    //if AFieldCode = Self.GetFieldCode('OutdoorPlaceDescription') then begin
    //    if AOriginalValue.AsString <> AValue.AsString then begin     // při změně
    //        self.SetFieldValueAsString('Name',self.getFieldValueAsString('OutdoorPlaceDescription'));
    //    end;
    //end;
  if AFieldCode = Self.GetFieldCode('X_Datum_montaze') then begin
    if AOriginalValue.AsDateTime<>AValue.AsDateTime then begin
         self.SetFieldValueAsDateTime('X_dat_zaruka_elektro',
                   NxIncMonth(avalue.AsDateTime,self.GetFieldValueAsInteger('X_zaruka_elektro')));
         self.SetFieldValueAsDateTime('X_dat_Zaruka_pevne_dily',
                   NxIncMonth(avalue.AsDateTime,self.GetFieldValueAsInteger('X_Zaruka_pevne_dily')));

    end;
  end;

  if AFieldCode = Self.GetFieldCode('X_zaruka_elektro') then begin
         if AOriginalValue.AsInteger<>AValue.AsInteger then begin
            self.SetFieldValueAsDateTime('X_dat_zaruka_elektro',
                   NxIncMonth(Self.GetFieldValueAsDateTime('X_Datum_montaze'),self.GetFieldValueAsInteger('X_zaruka_elektro')));
         end;
  end;
  if AFieldCode = Self.GetFieldCode('X_Zaruka_pevne_dily') then begin
         if AOriginalValue.AsInteger<>AValue.AsInteger then begin
            self.SetFieldValueAsDateTime('X_dat_Zaruka_pevne_dily',
                   NxIncMonth(Self.GetFieldValueAsDateTime('X_Datum_montaze'),self.GetFieldValueAsInteger('X_Zaruka_pevne_dily')));
         end;

  end;


end;














{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mSL:tstringlist;
  mS_text:string;
  mI_cislo:integer;
  mbusorder_Id:string;
  mI_Result:integer;
  mprefix_pomoc:string;
  mr:tstringlist;
begin
   if NxIsBlank(self.GetFieldValueAsString('Code')) then begin
       self.SetFieldValueAsString('Code','.') ;
   end ;

   if NxIsBlank(self.GetFieldValueAsString('X_ID_Obchodni_dokumentace')) then begin

        mprefix_pomoc:='S';
            if not NxIsEmptyOID(self.getFieldValueAsString('BusOrder_ID')) then begin
                    mprefix_pomoc:=copy(self.getFieldValueAsString('BusOrder_ID.code'),1,2);
                           if mprefix_pomoc='SK' then begin
                                 mprefix_pomoc:='K';
                            end else begin
                                 if mprefix_pomoc<>'' then begin
                                     mprefix_pomoc:=copy(mprefix_pomoc,1,1);
                                     if (mprefix_pomoc<>'A') AND (mprefix_pomoc<>'V') then  mprefix_pomoc:='S';
                                 end else begin
                                     mprefix_pomoc:='S';
                                 end;
                            end;
              end else begin
                  mprefix_pomoc:='S'
              end;

            if Length(self.getFieldValueAsString('X_ID_Obchodni_dokumentace'))<>8 then begin
              if trim(self.getFieldValueAsString('X_ID_Obchodni_dokumentace'))<>'' then begin


                    self.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc + NxPadL(self.getFieldValueAsString('X_ID_Obchodni_dokumentace'), 7, '0'));
              end else begin
                  mr:=TStringList.create;
                  try
                      self.ObjectSpace.SQLSelect('Select max(X_ID_Obchodni_dokumentace) from servicedobjects where substring(X_ID_Obchodni_dokumentace from 1 for 2)='+quotedstr(mprefix_pomoc+'9'),mr);
                      if mr.count>0 then begin
                          if mr.Strings[0]<>'' then begin
                               //if NxIsNumeric(copy(mr.Strings[0],3,6)) then begin
                                     mi_result:=strtoint(copy(mr.Strings[0],3,6)) + 1 ;
                                     self.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL(inttostr(mi_result), 6, '0'));
                               //end;
                          end else begin
                                self.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL('1', 6, '0'));
                          end;
                      end else begin
                         self.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL('1', 6, '0'));
                      end;
                  finally
                     mr.free;
                  end;

              end;
            end;

        end;











   if NxIsBlank(self.GetFieldValueAsString('X_Identifikace')) then begin
       if trim(uppercase(self.GetFieldValueAsString('X_vyrobce_id.Name')))='SPEDOS' then begin
            mSL:=TStringList.create;
            self.ObjectSpace.SQLSelect(format('select X_Identifikace from ServicedObjects where substring(X_Identifikace from 1 for 1)=%s order by X_Identifikace desc',[quotedstr('S')]),mSL);
            if mSL.Count>0 then begin
                  mS_text:=copy(mSL.Strings[0],2,6);
                  try
                    if IsIntegerNumber(StrToInt(mS_text)) then begin
                          mI_cislo:=StrToInt(mS_text) + 1;
                          mS_text:=copy(msl.Strings[0],1,1) + nxright('0000000' + inttostr(mI_cislo),6);
                          self.SetFieldValueAsString('X_Identifikace',ms_text);
                    end;
                  finally
                     msl.free;
                  end;
             end else begin
             self.SetFieldValueAsString('X_Identifikace','S000001');
            end;
       end else begin
        mSL:=TStringList.create;
            self.ObjectSpace.SQLSelect(format('select X_Identifikace from ServicedObjects where substring(X_Identifikace from 1 for 1)=%s order by X_Identifikace desc',[quotedstr('X')]),mSL);
            if mSL.Count>0 then begin
                  mS_text:=copy(mSL.Strings[0],2,6);
                  try
                    if IsIntegerNumber(StrToInt(mS_text)) then begin
                          mI_cislo:=StrToInt(mS_text) + 1;
                          mS_text:=copy(msl.Strings[0],1,1) + nxright('0000000' + inttostr(mI_cislo),6);
                          self.SetFieldValueAsString('X_Identifikace',ms_text);
                    end;
                  finally
                     msl.free;
                  end;
             end else begin
             self.SetFieldValueAsString('X_Identifikace','X000001');
            end;

       end;
   end;

end;
{Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
   mr:TStringList;
   mID:string;
   mxresult:string;
begin
  mr:=TStringList.Create;
  mID:='';
  try
       self.ObjectSpace.SQLSelect(format('SELECT (SELECT UD1.STRINGFIELDVALUE FROM USERDATA UD1 WHERE UD1.FIELDCODE=2000001 AND UD1.CLSID='+ quotedstr('30WZS5NA4NQOT2YY3XUDDDL4WC')+' AND UD1.ID = A.ID ) FROM DefRollData A WHERE A.CLSID = '+ quotedstr('30WZS5NA4NQOT2YY3XUDDDL4WC')+
          ' and (A.X_zarizeni_ID=%s) and (A.X_vyrobce_ID=%s) and (A.X_typ_zarizeni_ID=%s)',
          [quotedstr(self.GetFieldValueAsString('X_zarizeni_ID')),
          quotedstr(self.GetFieldValueAsString('X_Vyrobce_ID')),
          quotedstr(self.GetFieldValueAsString('X_typ_zarizeni_ID'))]),mr);
                // 3 položky

       if mr.count=1 then begin
          mid:=mr.Strings[0];
       end else begin


//self.ObjectSpace.SQLSelect(format(
      self.ObjectSpace.SQLSelect(format('SELECT (SELECT UD1.STRINGFIELDVALUE FROM USERDATA UD1 WHERE UD1.FIELDCODE=2000001 AND UD1.CLSID='+ quotedstr('30WZS5NA4NQOT2YY3XUDDDL4WC')+' AND UD1.ID = A.ID ) FROM DefRollData A WHERE A.CLSID = '+ quotedstr('30WZS5NA4NQOT2YY3XUDDDL4WC')+
          ' and (A.X_zarizeni_ID=%s) and (A.X_Vyrobce_id=%s) and (A.X_Typ_zarizeni_ID is null)',
          [quotedstr(self.GetFieldValueAsString('X_zarizeni_ID')),
          quotedstr(self.GetFieldValueAsString('X_Vyrobce_ID'))]),mr);


                 if mr.count=1 then begin
                    mid:=mr.Strings[0];
                 end else begin
                      // 1 položka
      self.ObjectSpace.SQLSelect(format('SELECT (SELECT UD1.STRINGFIELDVALUE FROM USERDATA UD1 WHERE UD1.FIELDCODE=2000001 AND UD1.CLSID='+ quotedstr('30WZS5NA4NQOT2YY3XUDDDL4WC')+' AND UD1.ID = A.ID ) FROM DefRollData A WHERE A.CLSID = '+ quotedstr('30WZS5NA4NQOT2YY3XUDDDL4WC')+
          ' and (A.X_zarizeni_ID=%s) and (A.X_Vyrobce_id is null) and (A.X_Typ_zarizeni_ID is null)',
          [quotedstr(self.GetFieldValueAsString('X_zarizeni_ID')),
          ]),mr);

                            if mr.count=1then begin
                             mid:=mr.Strings[0];
                            end else begin
                                mid:='';
                            end;

                 end;
       end;
  finally
      mr.free;
  end;
  if self.GetFieldValueAsString('Bustransaction_ID')<>mid then begin
     self.setFieldValueAsString('Bustransaction_ID',mid) ;
  end;

  self.SetFieldValueAsString('Firm_ID',self.getFieldValueAsString('payerFirm_ID')) ;
end;
{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsString('Code','.');
  self.SetFieldValueAsString('firm_id','3X23000101');
  self.SetFieldValueAsString('payerfirm_id','3X23000101');
end;

begin
end.