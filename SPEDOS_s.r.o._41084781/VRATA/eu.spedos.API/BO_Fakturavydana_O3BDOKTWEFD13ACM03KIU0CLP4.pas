uses 'eu.spedos.API.fce';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mRowBO, mBODRow:TNxCustomBusinessObject;
 mList:TStringList;
 aStream:TMemoryStream;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
begin
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  for i:=0 to mRows.count-1 do begin
     mRowBO:=mRows.BusinessObject[i];
     if (mRowBO.GetFieldValueAsInteger('RowType')=3) and (mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=1) then begin
        mBODRow:=self.ObjectSpace.CreateObject(Class_BillOfDeliveryRow);
        mBODRow.Load(mRowBO.GetFieldValueAsString('ProvideRow_ID'),nil);
        mDRBRows:=mBODRow.GetLoadedCollectionMonikerForFieldCode(mBODRow.GetFieldCode('DocRowBatches'));
        if mDRBRows.count>0 then begin
        for j:=0 to mDRBRows.count-1 do begin
           mList:=TStringList.create;
           self.ObjectSpace.SQLSelect(format('select code from defrolldata where name=''%s'' and X_BusOrder_ID=''%s'' and clsid=''XNAVPBFTCRO4BBYJZ2FN14T51O'' and hidden=''N'' ',[mDRBRows.BusinessObject[j].GetFieldValueAsString('StoreBatch_ID.Name'),mRowBO.GetFieldValueAsString('BusOrder_ID')]),mList);
           if mlist.Count>0 then begin
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek.php?ID_montaz_vyrobky='+mlist.Strings[0]+'&datum_fakturovano='+FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('DocDate$DATE')) +'&cis_zak='+ mRowBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(Self.ObjectSpace)+'&fakturovano=1');
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


begin
end.