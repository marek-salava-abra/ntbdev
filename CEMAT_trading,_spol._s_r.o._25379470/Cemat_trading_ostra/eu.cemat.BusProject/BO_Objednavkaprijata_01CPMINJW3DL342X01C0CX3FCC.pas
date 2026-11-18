{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 mBusProjectBO, mRowBO:TNxCustomBusinessObject;
 i:integer;
 mBusProject_ID:string;
begin
  try
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    for i:=0 to mRows.count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       if true then begin
         mBusProject_ID:=GetOrCreateBusProject(self.ObjectSpace,self.DisplayName,self.GetFieldValueAsString('Firm_ID'),mRowBO.GetFieldValueAsString('Division_ID'));
         mRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
       end;
    end;
    //if self.NeedSave then self.Save;
  Except
   NxShowSimpleMessage(ExceptionMessage,nil);
  end;
end;

Function GetOrCreateBusProject(var AOS:TNxCustomObjectSpace; var aName, aFirm_ID, aDivision_ID:String):string;
var
 mBusProjectBO:TNxCustomBusinessObject;
 mBP_ID:string;
begin
 Result:='';
 mBP_ID:=GetBP_ID(AOS,aName);
 if NxIsEmptyOID(mBP_ID) then begin
   mBusProjectBO:=aos.CreateObject(Class_BusProject);
   mBusProjectBO.new;
   mBusProjectBO.Prefill;
   mBusProjectBO.SetFieldValueAsString('Code',aName);
   mbusprojectbo.SetFieldValueAsString('Firm_ID',aFirm_ID);
   mBusProjectBO.SetFieldValueAsString('Division_ID',aDivision_ID);
   mBusProjectBO.save;
   Result:=mBusProjectBO.OID;
   mBusProjectBO.free;
 end;
 if not(NxIsEmptyOID(mBP_ID)) then Result:=mBP_ID;
end;


function GetBP_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM BusProjects WHERE Code=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.