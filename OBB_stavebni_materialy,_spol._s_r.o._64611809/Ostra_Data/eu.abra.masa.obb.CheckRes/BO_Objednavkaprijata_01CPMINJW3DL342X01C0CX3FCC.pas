{
Umožňuje ovlivnit validaci.

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mRowBO, mUser:TNxCustomBusinessObject;
 mDate:Extended;
begin
  mUser:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.ObjectSpace),nil);
  if not(mUser.GetFieldValueAsBoolean('U_Rezervace')) then begin
    mRows:=Self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    for i:=0 to mrows.Count-1 do begin
       mRowBO:=mrows.BusinessObject[i];
       if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('Reservation_ID'))) then begin
         if self.GetFieldValueAsDateTime('CreatedAt$Date')>0 then mDate:=self.GetFieldValueAsDateTime('CreatedAt$Date') else mDate:=Date;
         if ((mRowBO.GetFieldValueAsDateTime('Reservation_ID.DateTo$DATE')-mDate)>61) and (mRowBO.GetFieldValueAsFloat('Reservation_ID.Supplied')<mRowBO.GetFieldValueAsFloat('Reservation_ID.Reserved')) then begin
           self.AddValidateError(self.GetFieldCode('Description'), 'Nelze měnit rezervace '+mRowBO.GetFieldValueAsString('StoreCard_ID.Name'));
           AResult:=false;
         end;
       end;
    end;
  end;
end;  }

begin
end.