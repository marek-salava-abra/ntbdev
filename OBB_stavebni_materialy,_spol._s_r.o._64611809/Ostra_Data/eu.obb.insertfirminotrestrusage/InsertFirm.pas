procedure InsertFirm (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
 mPriceList_ID:String;
 mList:TstringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mPriceList_ID:='1200000101';
  mList:=TstringList.Create;
  OS.SQLSelect('Select id from firms where hidden=''N'' and not(orgidentnumber='''') and firm_id is null and id not in (select firm_id from ActionPriceListRestrictionUses where parent_id=''1000000101'') ',mList);
  for i:=0 to mlist.count-1 do begin
     mBO:=Os.CreateObject(Class_ActionPriceListRestrictionUse);
     mbo.new;
     mbo.SetFieldValueAsString('Parent_ID',mPriceList_ID);
     mbo.SetFieldValueAsString('Firm_ID',mList.strings[i]);
     mbo.SetFieldValueAsInteger('RestrictionType',1);
     mbo.save;
     mbo.free;


  end;
  Success := True;
  LogInfoStr := 'Přidáno '+IntToStr(mlist.Count);
end;

begin
end.