{ // při testech zjištěno, že řadení dle příjemky je kontraproduktivní, proto zakomentováno
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  i: Integer;
begin
  if Assigned(Self) then
  begin        // Naskladneni do pozic Class_SiteLogStoreInput
    if Self.GetSiteCLSID <> 'VQL23RLXWQM4XGN2I0S5VXCAPC'  then
      Exit;

    for i := 0 to Self.ComponentCount - 1 do
    begin
      if Self.Components(i) is TNxRowsObjectDataSet then
      begin
                                  // Radek naskladneni do pozice Class_LogStoreInputRowStr
        if TNxRowsObjectDataSet(Self.Components(i)).BusinessObjectCLSID = 'NN1LJOKSWNI4DIFQKYMV1DXHW0' then
        begin
           TNxRowsObjectDataSet(Self.Components(i)).Sorted := False;
           Exit;
        end;
      end;
    end;
  end;
end;
}

begin
end.