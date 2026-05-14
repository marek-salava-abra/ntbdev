procedure CheckActionPriceList (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
Var
 mList:TStringList;
 mSQL:String;
begin
  Success := True;
  LogInfoStr := '';
  mlist:=TStringList.create;
  mSQL:='Select id from ActionPriceLists where hidden=''N'' and DateTo$date='+IntToStr(trunc(date));
  os.SQLSelect(mSQL,mList);
  if mList.count>0 then begin
     Success := False;
     LogInfoStr := 'Našel jsem ceník s koncem dnes. Je nutné vytisknout štítky' + mSQL;
  end;

end;

begin
end.