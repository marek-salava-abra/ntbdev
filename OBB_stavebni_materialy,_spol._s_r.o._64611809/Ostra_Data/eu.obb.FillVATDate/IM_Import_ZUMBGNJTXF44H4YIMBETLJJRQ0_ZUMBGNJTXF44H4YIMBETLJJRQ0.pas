
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 mInputDocument:TNxCustomBusinessObject;
 mDate:Extended;
 i,j:integer;
 mBOD:TNxCustomBusinessObject;
 mBODList:TStringList;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mDate:=0;
  mRows:=self.OutputDocument.GetLoadedCollectionMonikerForFieldCode(self.OutputDocument.GetFieldCode('Rows'));
  for i:=0 to mrows.Count-1 do begin
    mBOD:=self.OutputDocument.ObjectSpace.CreateObject(Class_BillOfDelivery);
    try
      mBOD.load(mrows.BusinessObject[i].GetFieldValueAsString('Provide_ID'),nil);
      if mdate<mbod.GetFieldValueAsDateTime('DocDate$Date') then mdate:=mbod.GetFieldValueAsDateTime('DocDate$Date');
    except
    end;
    mbod.free;
  end;
  self.OutputDocument.SetFieldValueAsDateTime('VATAdmitDate$DATE',mDate);
  self.OutputDocument.SetFieldValueAsDateTime('VATDate$DATE',mDate);

end;

begin
end.