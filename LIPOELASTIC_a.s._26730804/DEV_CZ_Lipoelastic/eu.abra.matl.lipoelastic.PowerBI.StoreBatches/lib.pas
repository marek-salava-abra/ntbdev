procedure ExportForPowerBI (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'select sc.ean, ssb.storecard_id,ssb.store_id,ssb.storebatch_id,sb.Name, ssb.quantity, cast(day(sb.expirationdate$date) as varchar)||''.''||cast(month(sb.expirationdate$date) as varchar)||''.''||cast(YEAR(sb.expirationdate$date) as varchar) '+
          'from storesubbatches ssb '+
         'left join storecards sc on sc.id=ssb.storecard_id '+
         'left join storebatches sb on ssb.StoreBatch_ID=sb.ID '+
         'left join stores s on s.id=ssb.store_id where ((sc.X_Aktivni=''A'') and (ssb.quantity > 0)) ';

var
  mList, mList2: TStringList;
  mFileName:String;
  mFTP:TFTP;
  i:integer;
begin
  try
    mList := TStringList.create;
    mList2 :=TStringList.create;
    mFileName:=NxGetTempDir+'StoreBatchesQuantity.csv';
    try
      OS.SQLSelect(cSQL, mList);
      if mList.Count > 0 then begin
        mList2.Add('date; product_ean; product_id; warehouse_id; batch_id; batch_name; quantity; expiration');
        for i:=0 to mList.count-1 do begin
         mList2.add(FormatDateTime('d.m.yyyy',date)+';'+mList.strings[i]);
        end;
        mlist2.SaveToFile(mFileName);
      end;
    finally
      mList.Free;
      mList2.Free;
    end;
           mFTP:= TFTP.Create;
           mFTP.Host:='www.lipoelastic-medical-products.com.uvirt35.active24.cz';
           //mFTP.Port:=34000;
           mftp.UserName:='lipoelasti20';
           mFTP.Password:='iMO4Jxf9MI';
           mftp.Connect;
           mFTP.Passive:=true;
           mFTP.TransferType:=ftBinary;
           mFTP.ChangeDir('803d1d72d39a50559c96225092f73f4f');
           mftp.Put(mFileName, 'StoreBatchesQuantity.csv');
           mFTP.Free;

    Success := True;
    LogInfoStr := ''+NxGetTempDir;
  except
    LogInfoStr := Exceptionmessage+' '+''+NxGetTempDir;
  end;
end;



begin
end.