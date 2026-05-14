uses 'eu.abra.mavy.LabelPrinter.API.consts.consts', 'eu.abra.mavy.LabelPrinter.API.CreatePDM';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOrder_ID,mSQLResult,mOriginalValue: string;
begin
  mOrder_ID:= '';
  mSQLResult:= '';

  Self.GetOriginalValue('PMState_ID',mOriginalValue);

  if not (mOriginalValue = Self.GetFieldValueAsString('PMState_ID')) and (Self.GetFieldValueAsString('DocQueue_ID') in ['8RC0000101']) and (Self.GetFieldValueAsString('PMState_ID') = 'SDDEF00000') then begin
    mOrder_ID:= SQLSingleSelect(Self.ObjectSpace,'SELECT Distinct(A.ID) FROM ReceivedOrders A LEFT JOIN StoreDocuments2 SD2 ON SD2.Parent_ID='+QuotedStr(Self.OID)+' WHERE ((A.DocQueue_ID = ''1W10000101'')) and A.ID=SD2.Provide_ID');
    if not NxIsEmptyOID(mOrder_ID) then begin
      mSQLResult := SQLSingleSelect(Self.ObjectSpace, 'select LeftSide_ID from Relations where Rel_Def = '+IntToStr(1431)+' and RightSide_ID = '+QuotedStr(mOrder_ID));
      if NxIsEmptyOID(mSQLResult) and Self.GetFieldValueAsBoolean('TransportationType_ID.X_LP_SendToLabelPrinter') then begin
        CreatePDMDoc(Self.ObjectSpace,Self,Self.CLSID, False,False);
      end;
    end;
  end;
end;

begin
end.