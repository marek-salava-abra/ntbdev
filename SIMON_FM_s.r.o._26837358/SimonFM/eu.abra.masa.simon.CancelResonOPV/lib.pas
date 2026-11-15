procedure Cancel(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mList, mlogs:TStringList;
 mBO, mResBO:TNxCustomBusinessObject;
 mReservation_ID:string;
begin
  mList:=TStringList.Create;
  mlogs:=TStringList.Create;
  OS.SQLSelect('SELECT ro.id'#13#10 +
    'FROM receivedorders ro'#13#10 +
    'WHERE ro.docqueue_id = ''7RQ0000101'''#13#10 +
    '  AND ro.pmstate_id = ''1070000101'''#13#10 +
    '  AND EXISTS ('#13#10 +
    '      SELECT 1'#13#10 +
    '      FROM receivedorders2 ro2'#13#10 +
    '      JOIN reservations r ON r.owner_id = ro2.id'#13#10 +
    '      WHERE ro2.parent_id = ro.id'#13#10 +
    '        AND r.ownerkind = 0'#13#10 +
    '        AND r.reserved > 0 AND r.reserved > r.supplied'#13#10 +
    '  )',mList);
  if mList.count>0 then begin
    mBO:=OS.CreateObject(Class_ReceivedOrder);
    for j:=0 to mlist.count-1 do begin
      mBO.load(mlist.Strings[j],nil);
      mlogs.add(mbo.DisplayName);
      mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
      for i:=0 to mrows.count-1 do begin
         mReservation_ID:=OS.SQLSelectFirstAsString('Select id from reservations where ownerkind=0 and reserved>0 and owner_id='+QuotedStr(mrows.BusinessObject[i].OID),'');
         if not(NxIsEmptyOID(mReservation_ID)) then begin
            mResBO:=OS.CreateObject(Class_Reservation);
            mresbo.Load(mReservation_ID,nil);
            if mResBO.GetFieldValueAsFloat('Supplied')>0 then mResBO.SetFieldValueAsFloat('Reserved', mResBO.GetFieldValueAsFloat('Supplied')) else
            mResBO.SetFieldValueAsFloat('Reserved',0);
            mresbo.save;
            mresbo.Free;
         end;
      end;
    end;
   mbo.free;
  end;
  Success := True;
  LogInfoStr := ''+nxCrLf+mlogs.text;
end;

begin
end.