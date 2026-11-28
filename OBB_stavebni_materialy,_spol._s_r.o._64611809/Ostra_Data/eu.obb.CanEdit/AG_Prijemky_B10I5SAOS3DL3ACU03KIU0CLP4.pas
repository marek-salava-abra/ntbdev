procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
 mList:TStringList;
begin
  mList:=tstringlist.Create;
  TDynSiteForm(self).BaseObjectSpace.SQLSelect(format('select id from relations where rel_def=1011 and rightside_id=''%s'' ',[TDynSiteForm(self).CurrentObject.OID]),mList);
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
   if not(osNew in self.CurrentObject.State) then begin
   if (((self.CurrentObject.GetFieldValueAsDateTime('DocDate$Date')+1)>date) and (mList.count=0)) then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Oprava zamítnuta.Příjemka není vystavena dnes nebo je svázaná s přijatou fakturou.',Self);
   end;
   end;
  end;
end;

begin
end.