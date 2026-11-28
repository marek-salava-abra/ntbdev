procedure _AfterSave_PreHook(Self: TDynSiteForm);
Var
 mRows:TNxCustomBusinessMonikerCollection;
 mRowBO, mBOProject, mBOReservation, mBO:TNxCustomBusinessObject;
 i:Integer;
 mString, mReservation_ID:String;
 mlist:TStringList;
begin
  mBO:=self.CurrentObject;
  if not(self.CurrentObject.GetFieldValueAsString('DocQueue_ID.Code')='OP97') then begin
  if not(self.CurrentObject.GetFieldValueAsBoolean('Closed')) then begin
  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for i:=0 to mRows.Count-1 do begin
    mRowBO:=mrows.BusinessObject[i];

    if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
    mReservation_ID:=GetReservation_ID(mbo.ObjectSpace,mRowBO.OID);
    if not(NxIsEmptyOID(mReservation_ID)) then begin

     if (mRowBO.GetFieldValueAsString('X_StockType_ID')='2000000101') then begin
      mBOReservation:=mbo.ObjectSpace.CreateObject(Class_Reservation);
      mBOReservation.Load(mReservation_ID,nil);
      if mBOReservation.GetFieldValueAsFloat('Supplied')=0 then mBOReservation.Delete;
     end;
     if (mRowBO.GetFieldValueAsString('X_StockType_ID')='1000000101') and (not(mRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='6000000101')) then begin
      mBOReservation:=mbo.ObjectSpace.CreateObject(Class_Reservation);
      mBOReservation.Load(mReservation_ID,nil);
      if mBOReservation.GetFieldValueAsFloat('Supplied')>0 then mBOReservation.SetFieldValueAsFloat('Reserved',mBOReservation.GetFieldValueAsFloat('Supplied'));
      if mBOReservation.GetFieldValueAsFloat('Supplied')=0 then mBOReservation.delete;
     end;
    end;
    if NxIsEmptyOID(mReservation_ID) then begin
      if (mRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='6000000101') and (mRowBO.GetFieldValueAsString('X_StockType_ID')='1000000101') then begin
      mBOReservation:=mbo.ObjectSpace.CreateObject(Class_Reservation);
      mBOReservation.new;
      mBOReservation.SetFieldValueAsString('StoreCard_ID',mRowBO.GetFieldValueAsString('StoreCard_ID'));
      mBOReservation.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
      mBOReservation.SetFieldValueAsString('Owner_ID',mRowBO.OID);
      mBOReservation.SetFieldValueAsInteger('OwnerKind',0);
      mBOReservation.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
      mBOReservation.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
      mBOReservation.SetFieldValueAsFloat('Reserved',mRowBO.GetFieldValueAsFloat('Quantity'));
      mBOReservation.SetFieldValueAsFloat('UnitRate',mRowBO.GetFieldValueAsFloat('UnitRate'));
      mBOReservation.SetFieldValueAsString('Qunit',mRowBO.GetFieldValueAsString('Qunit'));
      mBOReservation.SetFieldValueAsDateTime('DateFrom$DATE',mRowBO.GetFieldValueAsDateTime('Parent_ID.DocDate$Date'));
      mBOReservation.SetFieldValueAsDateTime('DateTo$DATE',14+mRowBO.GetFieldValueAsDateTime('Parent_ID.DocDate$Date'));
      mBOReservation.Save;
      mBOReservation.Free;
      end;

    end;
   end;
  end;
  mrows.Free;
  end;
  end;
  TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
end;


function GetReservation_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT ID FROM Reservations WHERE Owner_ID=''%s'' and OwnerKind=0 ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0])
      else Result:=''
  finally
    mList.Free;
  end;
end;

begin
end.