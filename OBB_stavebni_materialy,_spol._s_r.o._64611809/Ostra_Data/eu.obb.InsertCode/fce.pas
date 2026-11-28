procedure HideCards (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mSCBO:TNxCustomBusinessObject;
 i:Integer;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('select sc.id from storecards sc '+
                      'left join issuedinvoices2 ii2 on ii2.storecard_id=sc.id '+
                      'left join issuedinvoices ii on ii.id=ii2.parent_ID '+
                      'left join cashreceived2 cr2 on cr2.storecard_id=sc.id '+
                      'left join cashreceived cr on cr.id=cr2.parent_ID '+
                      'where sc.code like ''%s'' and sc.id in '+
                      '(select storecard_id from storesubcards group by storecard_id having sum(quantity)=0) and (ii.docdate$date<%s or cr.docdate$date<%s)',['99AB%',inttostr(Trunc(Date-7)),inttostr(Trunc(Date-7))]),mList);
  for i:=0 to mList.Count-1 do begin
    mSCBO:=os.CreateObject(Class_StoreCard);
    mscbo.Load(mList.Strings[i],nil);
    LogInfoStr:=LogInfoStr+ mSCBO.DisplayName+Chr(10)+chr(13);
    mSCBO.SetFieldValueAsBoolean('Hidden', True);
    mscbo.save;
    mscbo.free;



  end;
  Success := True;
  //LogInfoStr := '';
end;

begin
end.