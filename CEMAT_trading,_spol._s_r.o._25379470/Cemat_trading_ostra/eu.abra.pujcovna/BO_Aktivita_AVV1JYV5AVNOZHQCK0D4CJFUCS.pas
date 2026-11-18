uses 'eu.abra.pujcovna.mail';

{
Umožňuje ovlivnit validaci.
}


procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRentalDevice:TNxCustomBusinessObject;
 mList, mList2:TstringList;
 i:Integer;
 mUser:TNxCustomBusinessObject;
 mUser_ID:String;
begin
  mList:=TstringList.Create;
  mList2:=TStringList.Create;
  mUser_ID:=NxGetActualUserID_1(self);
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(mUser_ID,nil);
  self.ObjectSpace.SQLSelect(format('Select X_RentalDevice_ID from defrolldata where clsid=''VFNPR04IPRQ41HGAGUTXNGLWYW'' and x_activity_id=''%s'' ',[self.OID]),mList);
  if mlist.count>0 then begin
    for i:=0 to mlist.count-1 do begin
     mRentalDevice:=self.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
     mRentalDevice.load(mList.strings[i],nil);
     //NxShowSimpleMessage(mRentalDevice.oid,nil);
       if self.GetFieldValueAsInteger('Status')=1 then mRentalDevice.SetFieldValueAsInteger('U_Stav',2);
       if self.GetFieldValueAsInteger('Status')=2 then begin
         mRentalDevice.SetFieldValueAsInteger('U_Stav',6);
         mList2.Add(mRentalDevice.GetFieldValueAsString('U_BusTransaction_ID.Code')+' '+mRentalDevice.GetFieldValueAsString('Name')+' '+mRentalDevice.GetFieldValueAsString('U_serialNumber')+' '+mRentalDevice.GetFieldValueAsString('U_Description')+' '+self.GetFieldValueAsString('Firm_ID.Name'));
       end;
     mRentalDevice.save;
     mRentalDevice.free;

    end;
    if self.GetFieldValueAsInteger('Status')=2 then begin
       SendInternalMail(self.ObjectSpace,'servis@cemat.cz;rusnak@cemat.cz',
        mUser.GetFieldValueAsString('Address_ID.Email'),'',
        'Kontrola PZ','Kontrola vyjmenovaných PZ '+mlist2.DelimitedText,'', self.GetFieldValueAsString('Firm_ID'),
                   '1000000101','');

    end;
  end;
end;

begin
end.