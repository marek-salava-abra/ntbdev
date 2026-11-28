procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
 mList:TStringList;

begin
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
   if not(osNew in self.CurrentObject.State) then begin
   mList:=TstringList.Create;
   Self.CurrentObject.ObjectSpace.SQLSelect(format('select id from storedocuments2 where provide_id=''%s'' ',[Self.CurrentObject.OID]),mList);
   if mList.count=0 then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Oprava zamítnuta, převodka již byla naskladněna na jiné pobočce',Self);
   end;
   end;
  end;
end;

begin
end.