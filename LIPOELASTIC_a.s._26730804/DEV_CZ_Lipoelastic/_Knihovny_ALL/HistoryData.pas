Function GetHistoryData(OS: TNxCustomObjectSpace; AClassID,AID,aName: string;Adate:TDate):string;
var
  mr: TStringList;
begin
mr:=TStringList.create;
  try


  os.SQLSelect('SELECT hd.stringfieldvalue FROM HistoryData HD left join UserFieldDefs2 UDF2 on hd.FieldCode=udf2.FieldCode where '
              +' hd.CLSID=' + quotedstr(AClassID)+' and HD.ValidFrom$DATE<= '+NxFloatToIBStr(Adate)
              +' and hd.id=' + quotedstr(AID) + ' and udf2.FieldName=' + quotedstr(aName)
              +' order by HD.ValidFrom$DATE desc ', mr);
    if mr.Count>0 then begin
        result:=mr.Strings[0];
    end else begin
        result:='NoData';
    end;
  finally
    mr.free;
  end;

end;


begin
end.