procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mRowBO, mUser:TNxCustomBusinessObject;
 mDate:Extended;
 mVersion:integer;
begin
  mUser:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.ObjectSpace),nil);
  if not(mUser.GetFieldValueAsBoolean('U_Rezervace')) then begin

       if not(NxIsEmptyOID(self.GetFieldValueAsString('Reservation_ID')))  then begin
         if self.GetFieldValueAsDateTime('Parent_ID.CreatedAt$Date')>0 then mDate:=self.GetFieldValueAsDateTime('Parent_ID.CreatedAt$Date') else mDate:=Date;
         if (self.GetFieldValueAsDateTime('Reservation_ID.DateTo$DATE')>self.GetFieldValueAsDateTime('Parent_ID.U_MaxReservationDate')) and (self.GetFieldValueAsDateTime('Parent_ID.U_MaxReservationDate')>0) then begin
             if ((self.GetFieldValueAsDateTime('Reservation_ID.DateTo$DATE')-mDate)>61) and (self.GetFieldValueAsFloat('Reservation_ID.Supplied')<self.GetFieldValueAsFloat('Reservation_ID.Reserved')) then begin
               self.AddValidateError(self.GetFieldCode('StoreCard_ID'), 'Nemáte právo uložit doklad s rezervací delší než 60 dní od data vystavení OP. '+#10#13+'Doklady s rezervací delší než 60 dní nelze fakturovat částečně. '+#10#13+'Pokud potřebujete čerpat OP částečně, '+#10#13+'opravte si datum platnosti rezervací na max 60 dní od data vystavení OP a kontaktujte centrálu, '+#10#13+'aby Vám znovu zapsala vyjímku s delší rezervací.');
               AResult:=false;
             end;
         end;
         if (self.GetFieldValueAsDateTime('Parent_ID.U_MaxReservationDate')=0) then begin
             if ((self.GetFieldValueAsDateTime('Reservation_ID.DateTo$DATE')-mDate)>61) and (self.GetFieldValueAsFloat('Reservation_ID.Supplied')<self.GetFieldValueAsFloat('Reservation_ID.Reserved')) then begin
               self.AddValidateError(self.GetFieldCode('StoreCard_ID'), 'Nemáte právo uložit doklad s rezervací delší než 60 dní od data vystavení OP. '+#10#13+'Doklady s rezervací delší než 60 dní nelze fakturovat částečně. '+#10#13+'Pokud potřebujete čerpat OP částečně, '+#10#13+'opravte si datum platnosti rezervací na max 60 dní od data vystavení OP a kontaktujte centrálu, '+#10#13+'aby Vám znovu zapsala vyjímku s delší rezervací.');
               AResult:=false;
             end;
         end;
    end;
  end;
end;

begin
end.