const
  constStoragePath = '\\192.168.0.36\abra\Servis';
  constNewDirStr = '%s\%s';


  {

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mresult:Boolean;
begin
  // Zjistime kod polozky Nazev


                        if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, self.oid]));
                                if  not mresult then begin    // servisovaný objekt
                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, self.oid]));
                                        //ShowMessage(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServicedObject_ID')]));

                                end;
                        end;


end;


  }


begin
end.