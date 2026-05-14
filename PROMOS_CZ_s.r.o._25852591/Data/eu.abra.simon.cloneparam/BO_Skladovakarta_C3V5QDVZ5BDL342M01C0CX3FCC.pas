{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList:TStringList;
 i:integer;
 mBO, mParamBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
  mOS:=self.ObjectSpace;
  mList:=TStringList.Create;
  mOS.SqlSelect('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_def=''03'' and X_Value_ID='+Quotedstr(self.OID),mList);
  if not(NxIsEmptyOID(self.GetFieldValueAsString('X_ParamGroup_ID'))) and (mlist.Count=0) then begin
   mOS.SQLSelect('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and x_rel_def=''01'' and x_Value_ID='+Quotedstr(self.GetFieldValueAsString('X_ParamGroup_ID')),mList);
   if mList.Count>0 then begin
     for i:=0 to mlist.count-1 do begin
       mParamBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
       mParamBO.Load(mList.Strings[i],nil);
       mBO:=mParamBO.Clone;
       mBO.SetFieldValueAsString('X_Rel_Def','03');
       mBO.SetFieldValueAsString('X_Value_ID',self.OID);
       mbo.save;
       mbo.free;
     end;
   end;
  end;
  if (NxIsEmptyOID(self.GetFieldValueAsString('X_ParamGroup_ID'))) and (mlist.Count>0) then begin
    mOS.SQLExecute('Delete from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_def=''03'' and X_Value_ID='+Quotedstr(self.OID));
  end;
end;

begin
end.