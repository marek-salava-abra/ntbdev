
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mSCBO:TNxCustomBusinessObject;
 mCount:Integer;
begin
  if self.GetFieldValueAsString('X_rel_def')='02' then begin
    mCount:=self.ObjectSpace.SQLSelectFirstAsInteger('Select count(id) from defrolldata where X_Value_ID='+QuotedStr(self.GetFieldValueAsString('X_Value_ID'))+' and X_rel_Def='+
                                                     QuotedStr('02')+' and clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' ');
    if mCount=0 then begin
       mSCBO:=self.ObjectSpace.CreateObject(Class_StoreCard);
       mSCBO.Load(self.GetFieldValueAsString('X_Value_ID'),nil);
       mSCBO.SetFieldValueAsBoolean('X_WithRP',False);
       mscbo.save;
       mscbo.free;
    end;
  end;
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mSCBO:TNxCustomBusinessObject;
begin
  if osNew in self.State then begin
    if self.GetFieldValueAsString('X_Rel_Def')='02' then begin
       mSCBO:=self.ObjectSpace.CreateObject(Class_StoreCard);
       mSCBO.Load(self.GetFieldValueAsString('X_Value_ID'),nil);
       mSCBO.SetFieldValueAsBoolean('X_WithRP',True);
       mscbo.save;
       mscbo.free;
    end;
  end;
end;


begin
end.