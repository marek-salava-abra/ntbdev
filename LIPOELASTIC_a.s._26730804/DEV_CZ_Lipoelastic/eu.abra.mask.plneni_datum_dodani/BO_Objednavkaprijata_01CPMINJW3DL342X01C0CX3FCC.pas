uses 'EU.Aabra.Mask.Validace.lib';
var
m_begin_save,mEnd_save:double;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mi:Integer;
begin
  mEnd_save:=now();
  if mEnd_save-m_begin_save<5 then
  mi:=self.ObjectSpace.SQLExecute('Update receivedorders set X_SaveTime=' +  NxFloatToIBStr(mEnd_save-m_begin_save) + ' where id=' +quotedstr(self.oid));
 m_begin_save:=0;
  mEnd_save:=0;
end;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
    mMon: TNxCustomBusinessMonikerCollection;
    i,ii:integer;
    xdotaz:boolean;
    mI_Result:integer;
    mr:TStringList;
    mBrand_list:tstringlist;
    mfind:boolean;
    mTermin_dodani:Double;
    mValidDate,mISHoliday:Boolean;
    xTerminDodani:TDateTime;
begin
   if m_begin_save=0 then m_begin_save:=Now;





   // ******* pro otestování ******
  {   mValidDate:= false;
                                                                    xTerminDodani:= 0;
                                                                    ii:=0;
                                                                    if self.GetFieldValueAsDateTime('X_termin_dodani')= 0 then begin
                                                                      xTerminDodani:= Date;
                                                                      if HourOfTheDay(Now) > 11 then xTerminDodani:= xTerminDodani + 1;
                                                                      xTerminDodani:= xTerminDodani + self.GetFieldValueAsInteger('Firm_ID.X_MoveDelivery'); //X_LeadTime
                                                                      mISHoliday:=NxEvalParametersExprAsBooleanDef(self.ObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                      //NxShowSimpleMessage(NxBoolToStr(mISHoliday), nil);
                                                                      if (DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday) then
                                                                      begin
                                                                        while ((DayOfTheWeek(xTerminDodani) in [6,7]) or (mISHoliday)) and (ii<20) do
                                                                        begin
                                                                          xTerminDodani:= xTerminDodani + 1;
                                                                          mISHoliday:=NxEvalParametersExprAsBooleanDef(self.ObjectSpace,nil,'NxDayIsHoliday('+NxFloatToIBStr(xTerminDodani)+'.0)',false);
                                                                          Inc(ii);
                                                                        end;
                                                                      end;
                                                                      self.SetFieldValueAsDateTime('X_Termin_dodani',xTermindodani);
                                                                      //Self.SetFieldValueAsDateTime('X_Termin_Dodani', mTerminDodani);
                                                                    end;

        }

   // ******* pro otestování ******






  if self.GetFieldValueAsDateTime('X_termin_dodani')>1000 then begin
          xdotaz:=false;
          // ted projdeme radky - nejlepe v poradi radek prijemky
          mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          try
                  for i := 0 to mMon.Count-1 do begin
                        if mMon.BusinessObject[i].GetFieldValueAsDateTime('DeliveryDate$Date')<>self.GetFieldValueAsDateTime('X_termin_dodani') then begin
                             if not xdotaz then begin
                                  //NxShowSimpleMessage('Nesouhlasí termín dodání na hlavičce s řádky. Řádky budou aktualizovány',nil);
                                  xdotaz:=true;
                             end;
                              if xdotaz then mMon.BusinessObject[i].setFieldValueAsDateTime('DeliveryDate$Date',self.GetFieldValueAsDateTime('X_termin_dodani'));
                        end;
                  end;

          finally
          end;
   end;

{   if self.GetFieldValueAsBoolean('firm_id.PrefillDiscountKind') then begin
      mBrand_list:=TStringList.create;
      try
           mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                  for i := 0 to mMon.Count-1 do begin
                        if mMon.BusinessObject[i].GetFieldValueAsInteger('rowtype')=3 then begin
                             mfind:=false;
                             for ii := 0 to mBrand_list.Count-1 do begin
                                 if copy(mBrand_list.Strings[ii],1,10)= mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.X_brand_ID') then begin
                                     mfind:=true;
                                     mBrand_list.Strings[ii]:= mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.X_brand_ID') +
                                               NxFloatToIBStr(NxIBStrToFloat(copy(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.X_brand_ID'),11,10)) +
                                               mMon.BusinessObject[i].GetFieldValueAsFloat('TotalPrice'));
                                 end;
                             end;
                             if not mfind then mBrand_list.Add(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.X_brand_ID') +
                                  NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')));

                        end;
                  end;

          if mBrand_list.Count>0 then begin
                    for ii := 0 to mBrand_list.Count-1 do begin
                       if NxIBStrToFloat(copy(mBrand_list.Strings[ii],11,10))>0 then begin

                             mr:=TStringList.create;
                             try
                                self.ObjectSpace.SQLSelect(format('SELECT max(a.Discount) FROM FinancialDiscounts A WHERE A.X_Firm_ID = %s and A.X_Brand_ID = %s and  a.amount<%s',[quotedstr(self.GetFieldValueAsString('Firm_ID')),
                                quotedstr(copy(mBrand_list.Strings[ii],1,10)),
                                copy(mBrand_list.Strings[ii],11,10)]),mr);


                                       if mr.count>0 then begin
                                             //NxShowSimpleMessage(copy(mBrand_list.Strings[ii],1,10) + '   -    ' +copy(mBrand_list.Strings[ii],11,10),nil);
                                             mBrand_list.Strings[ii]:= copy(mBrand_list.Strings[ii],1,10) +
                                                   mr.Strings[0];
                                             //NxShowSimpleMessage(copy(mBrand_list.Strings[ii],1,10) + '   -    ' +copy(mBrand_list.Strings[ii],11,10),nil);
                                       end;

                             finally
                                mr.free
                             end;


                         end;

                    end;
            //NxShowSimpleMessage(copy(mBrand_list.Strings[0],11,10),nil);


            mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                  for i := 0 to mMon.Count-1 do begin
                        if mMon.BusinessObject[i].GetFieldValueAsInteger('rowtype')=3 then begin
                             for ii := 0 to mBrand_list.Count-1 do begin
                                 if copy(mBrand_list.Strings[ii],1,10)= mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.X_brand_ID') then begin
                                     mMon.BusinessObject[i].SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(copy(mBrand_list.Strings[ii],11,10)));


                                 end;
                             end;

                        end;
                  end;









          end;






        //  NxShowSimpleMessage(NxFloatToIBStr(mBrand_list.Count),nil);

      finally
          mBrand_list.free;
      end;


      {
       if self.GetFieldValueAsFloat('LocalAmountWithoutVAT')> 10000 then begin


       end;  }
 //  end; }

end;



{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  m_begin_save:=Now;
end;

begin
end.