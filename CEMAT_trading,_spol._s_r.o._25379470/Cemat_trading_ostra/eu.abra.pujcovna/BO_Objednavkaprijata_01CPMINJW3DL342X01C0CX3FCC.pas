{
Umožňuje ovlivnit validaci.
}
//procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList2:tStringList;
 mDeviceBO:TNxCustomBusinessObject;
 i:integer;
begin

  if osNew in self.state then begin
    if not(NxIsEmptyOID(self.GetFieldValueAsString('U_Activity_ID'))) then begin
      MakeRelation(self,1231,self.GetFieldValueAsString('U_Activity_ID'),self.OID);


    end;
    if not(NxIsBlank(self.GetFieldValueAsString('U_listIDs'))) then begin
      mList2:=Tstringlist.Create;
      for i:=0 to Trunc(Length(self.GetFieldValueAsString('U_listIDs'))/10)-1 do begin
        mList2.add(copy(self.GetFieldValueAsString('U_listIDs'),(i*10)+1,10));
      end;
       for i:=0 to mList2.count-1 do begin
              mDeviceBO:= self.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
              mDeviceBO.Load(mlist2.strings[i],nil);
              mDeviceBO.SetFieldValueAsInteger('U_Stav',4);
              mDeviceBO.save;
              mdevicebo.free;
       end;
     end;

  end;
end;


function MakeRelation(mBO :TNxCustomBusinessObject; ARelDef : integer; ALeftSide_ID : string; ARightSide_ID : string) : string;
var
 ARelation:TNxCustomBusinessObject;
begin
  ARelation:=mBO.ObjectSpace.CreateObject(Class_Relation);
  ARelation.New;
  ARelation.SetFieldValueAsString('LEFTSIDE_ID', ALeftSide_ID);
  ARelation.SetFieldValueAsString('RIGHTSIDE_ID', ARightSide_ID);
  ARelation.SetFieldValueAsInteger('REL_DEF', ARelDef);
  ARelation.Save;
  Result := ARelation.OID;
end;

begin
end.