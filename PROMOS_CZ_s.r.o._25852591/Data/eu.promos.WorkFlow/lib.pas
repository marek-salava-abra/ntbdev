procedure CheckOrders (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:Integer;
begin
  mList:=TStringList.Create;
  //os.SQLSelect('Select id from receivedorders where docqueue_id=''4200000101'' and closed=''N'' and pmstate_id in (''6000000101'',''5000000101'',''3010000101'') order by createdat$date',mList);
  os.SQLSelect('Select id from receivedorders where closed=''N'' and pmstate_id in (''6000000101'',''5000000101'',''3010000101'') order by createdat$date',mList);
  if mlist.Count>0 then begin
     for i:=0 to mlist.count-1 do begin
       mBO:=OS.CreateObject(Class_ReceivedOrder);
       mBO.Load(mlist.strings[i],nil);
       mBO.Save;
       mBO.Free;

     end;
  end;
  Success := True;
  LogInfoStr := ''+inttostr(i);
end;



procedure CheckOrders2 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i,j:Integer;
 mBool:Boolean;
 mQuantity, mQuantityCR:Extended;
begin
  mList:=TStringList.Create;
  //os.SQLSelect('Select id from receivedorders where docqueue_id=''4200000101'' and closed=''A'' and pmstate_id in (''8000000101'') order by createdat$date',mList);
  os.SQLSelect('Select id from receivedorders where closed=''A'' and pmstate_id in (''7040000101'') order by createdat$date',mList);
  if mlist.Count>0 then begin
     for i:=0 to mlist.count-1 do begin
       mBool:=False;
       mBO:=OS.CreateObject(Class_ReceivedOrder);
       mBO.Load(mlist.strings[i],nil);
       mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
       for j:=0 to mrows.count-1 do begin
         mRowBO:=mrows.BusinessObject[j];
         mQuantity:=OS.SQLSelectFirstAsExtended(format('select sum(ii2.quantity) from storedocuments2 sd2 left join issuedinvoices2 ii2 on sd2.id=ii2.providerow_id where sd2.providerow_id=''%s'' ',[mRowBO.OID]));
         mQuantityCR:=OS.SQLSelectFirstAsExtended(format('select sum(ii2.quantity) from storedocuments2 sd2 left join CashReceived2 ii2 on sd2.id=ii2.providerow_id where sd2.providerow_id=''%s'' ',[mRowBO.OID]));
         if not(mBool) then begin
            if not((mQuantity+mQuantityCR)=mRowBO.GetFieldValueAsFloat('Quantity')) then mBool:=True;
         end;
       end;
       if not(mBool) then mbo.PMChangeState('2010000101');
       mBO.Save;
       mBO.Free;

     end;
  end;
  Success := True;
  LogInfoStr := ''+inttostr(i);
end;



begin
end.