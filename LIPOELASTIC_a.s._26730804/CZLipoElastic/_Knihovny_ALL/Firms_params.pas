const
FolderStorecardsPublic='C:\Share\Public\Storecards\';
FolderStorecardsShare='C:\Share\Share\Storecards\';
FolderFirmsPublic='C:\Share\Public\Firms\';
FolderFirmsShare='C:\Share\Share\Firms\';

function UserParam(self: TSiteForm;mParam:integer):boolean;
var
  mUser: TNxCustomBusinessObject;
begin
  mUser := self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(self.CompanyCache.GetUserID, nil);
            if copy(mUser.GetFieldValueAsString('X_Button_parametr'),mParam,1)='1' then Result:=True else Result:=False;
  finally
    mUser.Free;
  end;
end;





begin
end.