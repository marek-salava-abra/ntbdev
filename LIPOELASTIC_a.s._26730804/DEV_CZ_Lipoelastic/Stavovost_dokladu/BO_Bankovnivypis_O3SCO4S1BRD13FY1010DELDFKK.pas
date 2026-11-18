
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mr:tstringlist;
  i:integer;
  mBO:TNxCustomBusinessObject;
  mRows : TNxCustomBusinessMonikerCollection;
begin
  if NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID='SUPER00000' then begin

    mRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
        for i := 0 to mRows.Count - 1 do begin
             if (mRows.BusinessObject[i].GetFieldValueAsstring('PDocumentType') = '03') then begin
                 if not NxIsEmptyOID(mRows.BusinessObject[i].GetFieldValueAsstring('PDocument_ID')) then begin
                       mbo:=self.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                       try
                          mbo.Load(mRows.BusinessObject[i].GetFieldValueAsstring('PDocument_ID'),nil);
                          mbo.save;
                       finally
                           mbo.free;
                       end;
                 end;
             end;
        end;
  end;
end;



begin
end.