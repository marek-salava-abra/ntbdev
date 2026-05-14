Const
msql='select sd.id from ServiceDocuments SD where DocDate$DATE>42000 and not EXISTS (SELECT 1 FROM ServiceAssemblyForms SA WHERE sa.ServiceDocument_ID=sd.id)';





procedure Stav_zaplaceni(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mr:TStringList;
  mid:string;
  I,ii:integer;
    mbo:TNxCustomBusinessObject;
    mi:integer;
begin
  Success := True;
  LogInfoStr := '';
  mr:=TStringList.create;

  try
      os.SQLSelect(msql,mr);
      if mr.count>0 then begin
        for i:=0 to mr.count-1 do begin
               mBO := os.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
               try
                  mbo.load(mr.Strings[i],nil);
                  mbo.save;
               finally
                  mbo.free;
               end;
        end;
      end;
  finally
   mr.free;
  end;
end;

begin
end.