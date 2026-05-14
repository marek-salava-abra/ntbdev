{
naplánovaná úloha, kontrola opv ve stavu VO dodáno, pokud bude existovat faktura, změnit stav na VO fakturováno.
}

procedure ChangePMStateOnOPV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mOrderList, mLogs:tstringlist;
 i,j:integer;
 mOrderBO:TNxCustomBusinessObject;
 mInvoicedStoreDoc_ID:string;
begin
  mOrderList:=TStringList.Create;
  mLogs:=TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM ReceivedOrders A WHERE A.DOCQUEUE_ID = '+Quotedstr('7RQ0000101')+' AND A.PMSTATE_ID ='
               +QuotedStr('2080000101')+' AND ((''N'' = ''A'') OR ((''N'' = ''N'') AND (A.Revided_ID IS NULL))) ', mOrderList);
  if mOrderList.count>0 then begin
    j:=0;
    for i:=0 to mOrderList.Count-1 do begin
      mInvoicedStoreDoc_ID:=OS.SQLSelectFirstAsString('Select distinct(sd2.parent_id) from receivedorders2 ro2 left join storedocuments2 sd2 on sd2.providerow_id=ro2.id where '+
                                             'ro2.parent_id='+QuotedStr(mOrderList.Strings[i])+' and exists(select ii2.id from issuedinvoices2 ii2 where providerow_id=sd2.id)','');
      if not(NxIsEmptyOID(mInvoicedStoreDoc_ID)) then begin
        mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
        mOrderBO.Load(mOrderList.strings[i],nil);
        mOrderBO.PMChangeState('A060000101');
        mOrderBO.free;
        Inc(j)
      end;
      mLogs.add('Order_ID: '+mOrderList.Strings[i]+' mInvoicedStoreDoc_ID: '+mInvoicedStoreDoc_ID);
    end;
  end;
  Success := True;
  LogInfoStr := 'Počet zpracovávnaých dokladů '+IntToStr(mOrderList.count)+#13#10+
                'Počet změněných dokladů '+IntToStr(j)
                +#13#10+#13#10+mLogs.text;
end;

begin
end.