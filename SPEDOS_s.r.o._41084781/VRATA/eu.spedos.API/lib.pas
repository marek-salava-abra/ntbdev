uses 'eu.spedos.API.fce';

procedure CheckInvoices(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mRowBO, mBODRow:TNxCustomBusinessObject;
 mList2:TStringList;
 aStream:TMemoryStream;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
 mPoSplatnosti:string;
begin
  mList2:=TStringList.create;
  OS.SQLSelect(format('select id from issuedinvoices where (amount-creditamount)>paidamount and duedate$date<%s',[IntToStr(Trunc(Date))]),mList2);
  for k:=0 to mList2.Count-1 do begin
  mBO:=OS.CreateObject(Class_IssuedInvoice);
  mbo.load(mList2.Strings[k],nil);
  mPoSplatnosti:=IntToStr(Trunc(Date-mbo.GetFieldValueAsDateTime('duedate$date')));
  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for i:=0 to mRows.count-1 do begin
     mRowBO:=mRows.BusinessObject[i];
     if (mRowBO.GetFieldValueAsInteger('RowType')=3) and (mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=1) then begin
        mBODRow:=OS.CreateObject(Class_BillOfDeliveryRow);
        mBODRow.Load(mRowBO.GetFieldValueAsString('ProvideRow_ID'),nil);
        mDRBRows:=mBODRow.GetLoadedCollectionMonikerForFieldCode(mBODRow.GetFieldCode('DocRowBatches'));
        if mDRBRows.count>0 then begin
        for j:=0 to mDRBRows.count-1 do begin
           mList:=TStringList.create;
           OS.SQLSelect(format('select code from defrolldata where name=''%s'' and X_BusOrder_ID=''%s'' and clsid=''XNAVPBFTCRO4BBYJZ2FN14T51O'' and hidden=''N'' ',[mDRBRows.BusinessObject[j].GetFieldValueAsString('StoreBatch_ID.Name'),mRowBO.GetFieldValueAsString('BusOrder_ID')]),mList);
           if mlist.Count>0 then begin
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-faktura.php?type=F&ID_montaz_vyrobky='+mlist.Strings[0]+'&datum_fakturovano='+FormatDateTime('YYYY-MM-DD',mbo.GetFieldValueAsDateTime('DocDate$DATE')) +'&cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mBO.ObjectSpace)+'&posplatnosti='+mPoSplatnosti);
                              mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP2.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
           end;
           mlist.free;
        end;
        end;
        mBODRow.free;
     end;
    end;
  end;


  Success := True;
  LogInfoStr := '';
end;

procedure CheckDeposit(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mRowBO, mBODRow:TNxCustomBusinessObject;
 mList2:TStringList;
 aStream:TMemoryStream;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
 mPoSplatnosti:string;
begin
  mList2:=TStringList.create;
  OS.SQLSelect(format('select id from issueddinvoices where (amount)>paidamount and duedate$date<%s',[IntToStr(Trunc(Date))]),mList2);
  for k:=0 to mList2.Count-1 do begin
  mBO:=OS.CreateObject(Class_IssuedDepositInvoice);
  mbo.load(mList2.Strings[k],nil);
  mPoSplatnosti:=IntToStr(Trunc(Date-mbo.GetFieldValueAsDateTime('duedate$date')));
  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
   for i:=0 to mRows.count-1 do begin
     mRowBO:=mRows.BusinessObject[i];
     mJSON:= TJSONSuperObject.CreateNew;
     mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
     mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-faktura.php?type=Z&datum_fakturovano='+FormatDateTime('YYYY-MM-DD',mbo.GetFieldValueAsDateTime('DocDate$DATE')) +'&cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mBO.ObjectSpace)+'&posplatnosti='+mPoSplatnosti);
     mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
     mWinHTTP2.Send();
     mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);

    end;
  end;


  Success := True;
  LogInfoStr := '';
end;

begin
end.