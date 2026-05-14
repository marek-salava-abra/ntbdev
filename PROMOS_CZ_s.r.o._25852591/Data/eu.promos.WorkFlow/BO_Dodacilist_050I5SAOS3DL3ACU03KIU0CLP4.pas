{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mOrigPMState_ID, mOrder_ID, mPMState_ID:string;
mBO:TNxCustomBusinessObject;
mList:TStringList;
begin
     self.GetOriginalValue('PMState_ID',mOrigPMState_ID);
      if (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') then begin

         mOrder_ID:=GetOrder_ID(self.ObjectSpace,self.OID);
         mPMState_ID:='8000000101';
      end;
      if not(NxIsEmptyOID(mOrder_ID)) and not(NxIsEmptyOID(mPMState_ID)) then begin
        mBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
        mBO.Load(mOrder_ID,nil);
        mList:=TStringList.Create;
        self.ObjectSpace.SQLSelect(format('Select min(sd.pmstate_id) from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd2.provide_id=''%s'' ',[mOrder_ID]),mList);
        if mList.Strings[0]='SDDEF00000' then begin
         if mbo.GetFieldValueAsBoolean('Closed') then begin
          if not(mbo.GetFieldValueAsString('PMState_ID')='6000000101') then mBO.SetFieldValueAsString('PMState_ID',mPMState_ID);
         end;
        end;
        if mbo.NeedSave then mBO.Save;
        mBO.free;
      end;

end;

function GetOrder_ID(AOS : TNxCustomObjectSpace; aBillOfDelivery_ID: string) : string;
const
  cSQL = 'SELECT MAX(A.ID) FROM ReceivedOrders A LEFT JOIN StoreDocuments2 SD2 ON SD2.Parent_ID=''%s'' WHERE A.ID=SD2.Provide_ID';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aBillOfDelivery_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;


begin
end.