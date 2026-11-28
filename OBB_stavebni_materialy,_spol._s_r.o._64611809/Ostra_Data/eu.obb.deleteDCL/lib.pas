procedure DeleteDCL (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
begin
  try
     os.SQLExecute(format('delete from datachangeslogs where clsid=''O3BDOKTWEFD13ACM03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''050I5SAOS3DL3ACU03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''42HE04FZGJD13ACM03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''CDMK5QAWZZDL342X01C0CX3FCC'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''0RXJZGDLBBDL3ACR03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''0P0I5SAOS3DL3ACU03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''1D0I5SAOS3DL3ACU03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''E03ZNUMDTCC4PDAUIEY1MBTJC0'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''W402MSU3BBDL3ACR03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''1T0I5SAOS3DL3ACU03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
     os.SQLExecute(format('delete from datachangeslogs where clsid=''WG02MSU3BBDL3ACR03KIU0CLP4'' and servercreatedat$date<%s ',[IntToStr(Trunc(Date-365))]));
   except
   end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.