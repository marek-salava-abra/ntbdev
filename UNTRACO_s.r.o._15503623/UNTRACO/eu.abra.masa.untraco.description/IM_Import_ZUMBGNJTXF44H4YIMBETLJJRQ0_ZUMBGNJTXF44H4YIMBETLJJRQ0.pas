
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 mID:string;
begin
 mID:=self.InputHeaders[0].GetFieldValueAsString('ExternalNumber');
 if self.OutputDocument.GetFieldValueAsString('DocQueue_ID.Code') in ['FVE','FVEB']
  then self.OutputDocument.SetFieldValueAsString('Description',mID);
end;

begin
end.