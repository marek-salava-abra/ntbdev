

{
Vyvolává se po změně každé položky. A to vždy.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mID : string;
  mOS: TNxCustomObjectSpace;
  mBO : TNxCustomBusinessObject;
begin
  mID := '';
  if AFieldCode = 2000003 then begin
    if AnsiCompareStr(AValue.AsString, AOriginalValue.AsString) = 0 then
      exit;
    //if Self.GetFieldValueAsFloat('U_U_RentalAmount') <> 0 then
    //  exit;
    mID := Self.GetFieldValueAsString('U_RentalDevice_ID');
    if NxIsEmptyOID(mID) then
      exit;
    mOS := Self.ObjectSpace;
    mBO := mOS.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mID, nil);
    Self.SetFieldValueAsFloat('U_U_RentalAmount', mBO.GetFieldValueAsFloat('U_RentalAmount'));
    Self.SetFieldValueAsFloat('U_DepositAmount', mBO.GetFieldValueAsFloat('U_RecommendDeposit'));
    CalcPrice(Self, 1);
  end;

  if AFieldCode = 2000009 then begin
    if AnsiCompareStr(AValue.AsString, AOriginalValue.AsString) = 0 then
      exit;
    if Self.GetFieldValueAsFloat('U_U_RentalAmount2') <> 0 then
      exit;
    mID := Self.GetFieldValueAsString('U_RentalDevice2_ID');
    if NxIsEmptyOID(mID) then
      exit;
    mOS := Self.ObjectSpace;
    mBO := mOS.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mID, nil);
    Self.SetFieldValueAsFloat('U_U_RentalAmount2', mBO.GetFieldValueAsFloat('U_RentalAmount'));
    CalcPrice(Self, 2);
  end;

  if AFieldCode = 2000010 then begin
    if AnsiCompareStr(AValue.AsString, AOriginalValue.AsString) = 0 then
      exit;
    if Self.GetFieldValueAsFloat('U_U_RentalAmount3') <> 0 then
      exit;
    mID := Self.GetFieldValueAsString('U_RentalDevice3_ID');
    if NxIsEmptyOID(mID) then
      exit;
    mOS := Self.ObjectSpace;
    mBO := mOS.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mID, nil);
    Self.SetFieldValueAsFloat('U_U_RentalAmount3', mBO.GetFieldValueAsFloat('U_RentalAmount'));
    CalcPrice(Self, 3);
  end;
  
  if AFieldCode in [Self.GetFieldCode('RealEnd$DATE'), Self.GetFieldCode('RealStart$DATE')] then begin
    CalcPrice(Self, 1);
    CalcPrice(Self, 2);
    CalcPrice(Self, 3);
  end;
  
  if AFieldCode in [Self.GetFieldCode('U_CorrectRentalAmount1'), Self.GetFieldCode('U_U_RentalAmount')] then
    CalcPrice(Self, 1);
  if AFieldCode in [Self.GetFieldCode('U_CorrectRentalAmount2'), Self.GetFieldCode('U_U_RentalAmount2')] then
    CalcPrice(Self, 2);
  if AFieldCode in [Self.GetFieldCode('U_CorrectRentalAmount3'), Self.GetFieldCode('U_U_RentalAmount3')] then
    CalcPrice(Self, 3);
end;

{
Vyvolává se před změnou každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_PreHook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter);
begin

end;

procedure CalcPrice(Self : TNxCustomBusinessObject; AIndex : integer);
var
  mQuantity : Double;
  mTotalPrice : Double;
begin
  mQuantity := NxFloor(Self.GetFieldValueAsDateTime('RealEnd$DATE')) - NxFloor(Self.GetFieldValueAsDateTime('RealStart$DATE'));
  mTotalPrice := 0;
  if AIndex = 1 then begin
    mTotalPrice := Self.GetFieldValueAsFloat('U_U_RentalAmount') * mQuantity + Self.GetFieldValueAsFloat('U_CorrectRentalAmount1');
    Self.SetFieldValueAsFloat('U_TotalRentalAmount1', mTotalPrice);
  end;
  if AIndex = 2 then begin
    mTotalPrice := Self.GetFieldValueAsFloat('U_U_RentalAmount2') * mQuantity + Self.GetFieldValueAsFloat('U_CorrectRentalAmount2');
    Self.SetFieldValueAsFloat('U_TotalRentalAmount2', mTotalPrice);
  end;
  if AIndex = 3 then begin
    mTotalPrice := Self.GetFieldValueAsFloat('U_U_RentalAmount3') * mQuantity + Self.GetFieldValueAsFloat('U_CorrectRentalAmount3');
    Self.SetFieldValueAsFloat('U_TotalRentalAmount3', mTotalPrice);
  end;
end;

{
Zápis do reportovacího číselníku.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mAmount: extended;
 mReportBO: TNxCustomBusinessObject;
 mReport1_ID,mReport2_ID,mReport3_ID: String;
begin
  if self.GetFieldValueAsString('ActQueue_ID')='2000000101' then begin
    if self.GetFieldValueAsInteger('Status')=2 then begin
       if not(NxIsEmptyOID(self.GetFieldValueAsString('U_RentalDevice_ID'))) then begin
       mReport1_ID:=scrReport_ID(self.ObjectSpace,self.OID,self.GetFieldValueAsString('U_RentalDevice_ID'));
        if NxIsEmptyOID(mReport1_ID) then begin
          mReportBO:=self.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mReportBO.New;
          mReportBO.SetFieldValueAsString('X_activity_ID',self.OID);
          mReportBO.SetFieldValueAsString('U_firm_ID',self.GetFieldValueAsString('Firm_ID'));
          mReportBO.SetFieldValueAsString('U_person_ID',self.GetFieldValueAsString('Person_ID'));
          mReportBO.SetFieldValueAsString('X_RentalDevice_ID',self.GetFieldValueAsString('U_RentalDevice_ID'));
          mReportBO.SetFieldValueAsFloat('U_rentalamount',self.GetFieldValueAsFloat('U_TotalRentalAmount1'));
          mReportBO.SetFieldValueAsDateTime('U_endDate',Self.GetFieldValueAsDateTime('RealEnd$DATE'));
          mReportBO.Save;
          mReportBO.Free;
        end;
        if not(NxIsEmptyOID(mReport1_ID)) then begin
          mReportBO:=self.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mReportBO.Load(mReport1_ID,nil);
          mReportBO.SetFieldValueAsFloat('U_rentalamount',self.GetFieldValueAsFloat('U_TotalRentalAmount1'));
          mReportBO.SetFieldValueAsDateTime('U_endDate',Self.GetFieldValueAsDateTime('RealEnd$DATE'));
          mReportBO.Save;
          mReportBO.Free;
        end;
  
      end;
      if not(NxIsEmptyOID(self.GetFieldValueAsString('U_RentalDevice2_ID'))) then begin
       mReport2_ID:=scrReport_ID(self.ObjectSpace,self.OID,self.GetFieldValueAsString('U_RentalDevice2_ID'));
        if NxIsEmptyOID(mReport2_ID) then begin
          mReportBO:=self.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mReportBO.New;
          mReportBO.SetFieldValueAsString('X_activity_ID',self.OID);
          mReportBO.SetFieldValueAsString('U_firm_ID',self.GetFieldValueAsString('Firm_ID'));
          mReportBO.SetFieldValueAsString('U_person_ID',self.GetFieldValueAsString('Person_ID'));
          mReportBO.SetFieldValueAsString('X_RentalDevice_ID',self.GetFieldValueAsString('U_RentalDevice2_ID'));
          mReportBO.SetFieldValueAsFloat('U_rentalamount',self.GetFieldValueAsFloat('U_TotalRentalAmount2'));
          mReportBO.SetFieldValueAsDateTime('U_endDate',Self.GetFieldValueAsDateTime('RealEnd$DATE'));
          mReportBO.Save;
          mReportBO.Free;
        end;
        if not(NxIsEmptyOID(mReport2_ID)) then begin
          mReportBO:=self.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mReportBO.Load(mReport2_ID,nil);
          mReportBO.SetFieldValueAsFloat('U_rentalamount',self.GetFieldValueAsFloat('U_TotalRentalAmount2'));
          mReportBO.SetFieldValueAsDateTime('U_endDate',Self.GetFieldValueAsDateTime('RealEnd$DATE'));
          mReportBO.Save;
          mReportBO.Free;
        end;

      end;
      if not(NxIsEmptyOID(self.GetFieldValueAsString('U_RentalDevice3_ID'))) then begin
       mReport3_ID:=scrReport_ID(self.ObjectSpace,self.OID,self.GetFieldValueAsString('U_RentalDevice3_ID'));
        if NxIsEmptyOID(mReport3_ID) then begin
          mReportBO:=self.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mReportBO.New;
          mReportBO.SetFieldValueAsString('X_activity_ID',self.OID);
          mReportBO.SetFieldValueAsString('U_firm_ID',self.GetFieldValueAsString('Firm_ID'));
          mReportBO.SetFieldValueAsString('U_person_ID',self.GetFieldValueAsString('Person_ID'));
          mReportBO.SetFieldValueAsString('X_RentalDevice_ID',self.GetFieldValueAsString('U_RentalDevice3_ID'));
          mReportBO.SetFieldValueAsFloat('U_rentalamount',self.GetFieldValueAsFloat('U_TotalRentalAmount3'));
          mReportBO.SetFieldValueAsDateTime('U_endDate',Self.GetFieldValueAsDateTime('RealEnd$DATE'));
          mReportBO.Save;
          mReportBO.Free;
        end;
        if not(NxIsEmptyOID(mReport3_ID)) then begin
          mReportBO:=self.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mReportBO.Load(mReport3_ID,nil);
          mReportBO.SetFieldValueAsFloat('U_rentalamount',self.GetFieldValueAsFloat('U_TotalRentalAmount3'));
          mReportBO.SetFieldValueAsDateTime('U_endDate',Self.GetFieldValueAsDateTime('RealEnd$DATE'));
          mReportBO.Save;
          mReportBO.Free;
        end;

      end;
    end;
  end;

end;

function scrReport_ID(AOS : TNxCustomObjectSpace; AActivity_ID : string; ADevice_ID: string) : String;
const
  cSQL = 'SELECT ID  FROM defrolldata WHERE clsid=''VFNPR04IPRQ41HGAGUTXNGLWYW'' and X_Activity_ID=''%s'' and X_RentalDevice_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AActivity_ID,ADevice_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;



begin
end.