uses '.fce';


{procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
begin
  if TDynSiteForm(self).CurrentObject.GetFieldValueAsInteger('OrdNumber')=58 then begin
    ACanEdit:=false;
    NxShowSimpleMessage('Nelze editovat doklad s pořadovým číslem 58',Self);
  end;
end;
}




begin
end.