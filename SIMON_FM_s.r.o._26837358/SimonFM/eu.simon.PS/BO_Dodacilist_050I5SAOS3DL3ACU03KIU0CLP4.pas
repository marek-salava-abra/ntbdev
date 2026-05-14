procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mRows:  TNxCustomBusinessMonikerCollection;
  mRowBO, mBO: TNxCustomBusinessObject;
  i: integer;
  mOtherStore: boolean;
  mPMState_ID, mOrder_ID,mOrigPMState_ID:string;

begin
 if not(self.GetFieldValueAsString('DocQueue_ID') in ['8RC0000101','U200000101']) then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_BillOfDelivery);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='2000000001' then begin
     try
      if not (osSaving in mBO.InternalState) then mBO.PMChangeState('SDDEF00000');
     except
     end;
    end;
  end;
 if (self.GetFieldValueAsString('DocQueue_ID')='8RC0000101') then begin
      mOrder_ID:='';
      mPMState_ID:='';
      //doplněno nulování hodnot před procesem 23.02.2024
      self.GetOriginalValue('PMState_ID',mOrigPMState_ID);
      if (self.GetFieldValueAsString('PMState_ID')='1020000101') and (mOrigPMState_ID='2000000001') then begin
         mOrder_ID:=GetOrder_ID(self.ObjectSpace,self.OID);
         mPMState_ID:='3010000101';   //expeduje se
      end;
      if (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') and (mOrigPMState_ID='1020000101') then begin
         mOrder_ID:=GetOrder_ID(self.ObjectSpace,self.OID);
         mPMState_ID:='4010000101';   //expedováno
      end;
      if (self.GetFieldValueAsString('PMState_ID')='2000000001') and (mOrigPMState_ID='1020000101') then begin
         mOrder_ID:=GetOrder_ID(self.ObjectSpace,self.OID);
         mPMState_ID:='2000000101';   //přijato
      end;

    if not(NxIsEmptyOID(mOrder_ID)) and not(NxIsEmptyOID(mPMState_ID)) then begin
        mBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
        mBO.Load(mOrder_ID,nil);
        mBO.SetFieldValueAsString('PMState_ID',mPMState_ID);
        mbo.save;
        mbo.free;

    end;
  end;
end;

function GetOrder_ID(AOS : TNxCustomObjectSpace; aBillOfDelivery_ID: string) : string;
const
  cSQL = 'SELECT Distinct(A.ID) FROM ReceivedOrders A LEFT JOIN StoreDocuments2 SD2 ON SD2.Parent_ID=''%s'' WHERE A.ID=SD2.Provide_ID';
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