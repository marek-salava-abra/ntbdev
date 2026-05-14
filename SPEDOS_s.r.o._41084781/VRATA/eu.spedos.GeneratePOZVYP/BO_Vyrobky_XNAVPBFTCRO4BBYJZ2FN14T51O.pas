{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  self.ObjectSpace.SQLSelect(format('SELECT ID FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID='+Quotedstr('HTI3OTLGNRPO32EEISEPC0XZ0K')+' AND (Upper(STRINGFIELDVALUE Collate UTF8) = ''%s'') ',[self.GetFieldValueAsString('Code')]),mList);
  if mlist.Count>0 then begin
     try
     mBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mbo.Load(mlist.Strings[0],nil);
     mbo.SetFieldValueAsDateTime('ScheduledAt$DATE',self.GetFieldValueAsDateTime('X_Datum_vyroby$date'));
     mbo.SetFieldValueAsDateTime('PlanedStartAt$DATE',self.GetFieldValueAsDateTime('X_Datum_vyroby$date')-14);
     mbo.save;
     except

     end;

  end;
end;

begin
end.