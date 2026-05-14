{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows, mPictures:TNxCustomBusinessMonikerCollection;
 mUserXLink, mRowBO, mPictureBO:TNxCustomBusinessObject;
 i,j:integer;
 mUserXLink_ID:string;
begin
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  for i:=0 to mRows.CountOfNotDeleted-1 do begin
    mRowBO:=mRows.BusinessObject[i];
    mPictures:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('Rows'));
    for j:=0 to mPictures.CountOfNotDeleted-1 do begin
       mPictureBO:=mPictures.BusinessObject[j];
       mUserXLink_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from userxlinks where Source_ID='+QuotedStr(self.OID)+
                                                              ' and SourceCLSID='+QuotedStr(Class_PLMRoutine)+
                                                              ' and Destination_ID='+QuotedStr(mPictureBO.GetFieldValueAsString('PLMPicture_ID'))+
                                                              ' and DestinationCLSID='+QuotedStr(Class_PLMPicture),'');
       if NxIsEmptyOID(mUserXLink_ID) then begin
         mUserXLink:=self.ObjectSpace.CreateObject(Class_UserXLink);
         mUserXLink.New;
         mUserXLink.Prefill;
         mUserXLink.SetFieldValueAsString('Source_ID',self.OID);
         mUserXLink.SetFieldValueAsString('SourceCLSID',Class_PLMRoutine);
         mUserXLink.SetFieldValueAsString('Destination_ID',mPictureBO.GetFieldValueAsString('PLMPicture_ID'));
         mUserXLink.SetFieldValueAsString('DestinationCLSID',Class_PLMPicture);
         mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem',true);
         mUserXLink.SetFieldValueAsString('Description',self.DisplayName);
         mUserXLink.save;
         mUserXLink.free;
       end;
    end;
  end;
end;

begin
end.