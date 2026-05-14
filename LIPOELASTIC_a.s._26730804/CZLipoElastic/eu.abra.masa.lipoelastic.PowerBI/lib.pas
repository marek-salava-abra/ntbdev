procedure ExportForPowerBI (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'select sc.ean, ssc.quantity, ssc.storecard_id, ssc.store_id, ssc.lowlimitquantity, ssc.highlimitquantity from storesubcards ssc '+
         'left join storecards sc on sc.id=ssc.storecard_id '+
         'left join stores s on s.id=ssc.store_id where sc.X_Aktivni=''A'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
  i:integer;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'StoreQuantity.csv';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      mList2.Add('date;product_ean;quantity;product_id;warehouse_id;low_limit;high_limit');
      for i:=0 to mList.count-1 do begin
       mList2.add(FormatDateTime('d.m.yyyy',date)+';'+mList.strings[i]);
      end;
      mlist2.SaveToFile(mFileName);
    end;
  finally
    mList.Free;
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
         mftp.Put(mFileName, 'StoreQuantity.csv');
         mFTP.Free;

  Success := True;
  LogInfoStr := ''+NxGetTempDir;
end;

procedure ExportForPowerBI2 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'select ssc.ID from storesubcards ssc '+
         'left join storecards sc on sc.id=ssc.storecard_id '+
         'where sc.X_Aktivni=''A'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
  i:integer;
  mBO:TNxCustomBusinessObject;
  mOPQ, mOVQ:Extended;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'StoreQuantity.csv';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      mList2.Add(LowerCase('date;product_ean;quantity;product_id;warehouse_id;low_limit;high_limit;ov_quantity;op_quantity'));
      for i:=0 to mList.count-1 do begin
       mBO:=OS.CreateObject(Class_StoreSubCard);
       mBO.Load(mlist.Strings[i],nil);
       mOVQ:=NxEvalObjectExprAsFloatDef(mBO,'NxGetOrderedQuantityFromIssuedOrders('+QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID')) + ','+Quotedstr(mBO.GetFieldValueAsString('Store_ID'))+')',0);
       mOPQ:=NxEvalObjectExprAsFloatDef(mBO,'NxGetOrderedQuantityFromReceivedOrders('+QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID')) + ','+Quotedstr(mBO.GetFieldValueAsString('Store_ID'))+')',0);
       mList2.add(FormatDateTime('d.m.yyyy',date)+';'+
                  mBO.GetFieldValueAsString('StoreCard_ID.EAN')+';'+
                  NxFloatToIBStr(mBO.GetFieldValueAsFloat('Quantity'))+';'+
                  mBO.GetFieldValueAsString('StoreCard_ID')+';'+
                  mBO.GetFieldValueAsString('Store_ID')+';'+
                  NxFloatToIBStr(mBO.GetFieldValueAsFloat('LowLimitQuantity'))+';'+
                  NxFloatToIBStr(mBO.GetFieldValueAsFloat('HighLimitQuantity'))+';'+
                  NxFloatToIBStr(mOVQ)+';'+NxFloatToIBStr(mOPQ));
       mBO.free;
      end;
      mlist2.SaveToFile(mFileName);
    end;
  finally
    mList.Free;
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
         mftp.Put(mFileName, 'StoreQuantity.csv');
         mFTP.Free;

  Success := True;
  LogInfoStr := ''+NxGetTempDir;
end;

function GetDynSourceE (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Exports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.