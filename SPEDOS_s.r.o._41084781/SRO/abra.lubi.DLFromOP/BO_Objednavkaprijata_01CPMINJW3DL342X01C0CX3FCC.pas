const
  cDLDocQueueOID = 'P600000101';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  i: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
begin
  mOS := Self.ObjectSpace;
  try
    mInputParams := TNxParameters.Create;
    mList := TStringList.Create;
    try
      mCollRows := Self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i := 0 to mCollRows.Count - 1 do begin
        mRow := mCollRows.BusinessObject(i);
        if (not (osDeleted in mRow.State)) and (not (osMarkForDelete in mRow.State)) then begin
          if mRow.GetFieldValueAsInteger('RowType') = 3 then
            mList.Add(mRow.OID);
        end;
      end;
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := cDLDocQueueOID;
      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
      mParam.AsString := mList.Text;
      mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
      try
        mImportMan.AddInputDocument(self.OID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', cDLDocQueueOID); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', self.GetFieldValueAsString('Firm_ID'));
          mImportMan.OutputDocument.Save;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
      mList.Free;
    end;
  except
    // Roberte - chybu poziram - event se vola opakovane, pri opakovanem volani managera na OP, ktera jiz ma DL vytvoren, manager generuje vyjimku
    //ShowMessage('Chyba DL z OP: ' + ExceptionMessage);
  end;
end;

begin
end.