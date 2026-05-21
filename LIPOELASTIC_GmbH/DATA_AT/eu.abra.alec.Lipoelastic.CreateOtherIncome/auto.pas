procedure ProcessOtherIncomes(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mList, mWithoutPaymentsList: TStringList;
  mOIBO: TNxCustomBusinessObject;
  mOIRows: TNxCustomBusinessMonikerCollection;
  i, j: integer;
begin
  Success := True;
  LogInfoStr := '';

  mWithoutPaymentsList:= GetOtherIncomeIDsWithoutPayments(OS);
  for i:= 0 to mWithoutPaymentsList.Count -1 do
  begin
    mOIBO:= OS.CreateObject(Class_OtherIncome);
    try
      mOIBO.Load(mWithoutPaymentsList[i], nil);
      mOIBO.Delete;
      LogInfoStr:= LogInfoStr + mOIBO.DisplayName + ' - deleted'+nxCrLf;
    finally
      mOIBO.Free;
    end;
  end;

  mList:= GetDepletedOtherIncomeID(OS);
  for i:= 0 to mList.Count -1 do
  begin
    mOIBO:= OS.CreateObject(Class_OtherIncome);
    try
      mOIBO.Load(mList[i], nil);
      mOIRows:= mOIBO.GetLoadedCollectionMonikerForFieldCode(mOIBO.GetFieldCode('Rows'));
      for j:= 0 to mOIRows.Count -1 do
      begin
        mOIRows.BusinessObject[j].SetFieldValueAsString('Text', Format('Original amount was [%g]', [mOIRows.BusinessObject[j].GetFieldValueAsFloat('TAmount')]));
        mOIRows.BusinessObject[j].SetFieldValueAsFloat('TAmount', 0);
      end;
      mOIBO.Save;
      LogInfoStr:= LogInfoStr + mOIBO.DisplayName + ' - amount set to zero.'+nxCrLf;
    finally
      mOIBO.Free;
    end;
  end;
end;


function GetDepletedOtherIncomeID(AOS: TNxCustomObjectSpace): TStringList;
begin
  Result:= TStringList.Create;
  try
    AOS.SQLSelect(
      ' SELECT P.PDocument_ID FROM Payments P '+
      ' JOIN OtherIncomes OI ON OI.ID = P.PDocument_ID '+
      ' WHERE P.documenttype = ''09'' '+
      ' AND P.PDocumentType = ''01'' '+
      ' AND OI.PaidAmount = 0 '+
      ' AND OI.Amount > 0 '+
      ' GROUP BY P.PDocument_ID '+
      ' HAVING COUNT(p.id) = 2 ', Result);
  except
    Result.Free;
  end;
end;


function GetOtherIncomeIDsWithoutPayments(AOS: TNxCustomObjectSpace): TStringList;
const
  cDOCQUEUE_ID_OTHER_INCOME = '~000000905';
begin
  Result:= TStringList.Create;
  try
    AOS.SQLSelect(
      ' SELECT OI.ID '+
      ' FROM OtherIncomes OI '+
      ' WHERE OI.PaidAmount = 0 '+
      '   AND NOT EXISTS ( '+
      '     SELECT 1 '+
      '     FROM Payments P '+
      '     WHERE P.PDocument_ID = OI.ID '+
      '       AND P.documenttype = ''09'' '+
      '       AND P.PDocumentType = ''01'' '+
      '   ) '+
      '   AND OI.DocQueue_ID = '+QuotedStr(cDOCQUEUE_ID_OTHER_INCOME)
      , Result);
  except
    Result.Free;
  end;
end;



begin
end.