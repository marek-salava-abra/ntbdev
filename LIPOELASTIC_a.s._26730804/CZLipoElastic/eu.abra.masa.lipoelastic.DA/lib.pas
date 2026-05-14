procedure DeleteAttachements (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TstringList;
 mBO:TNxCustomBusinessObject;
 mCol:TNxCustomBusinessMonikerCollection;
 mAtt:TNxCustomBusinessObject;
 i,j, k:Integer;
 mDateString:STring;
 msql:String;
begin
  mDateString:=IntToStr(trunc(Now-90));
  //mDateString:='44927';
  mList:=TStringList.Create;
  k:=0;
  try
     //mSQL:='Select id from EmailsSent where X_dont_delete=''N'' and docdate$date=''%s'' ';
     mSQL:='Select id from emailssent where docdate$date=''%s'' ';
     OS.SQLSelect(Format(mSQL, [mDateString]), mList);
     if mlist.Count>0 then begin
      for i:=0 to mlist.count-1 do begin
         os.SQLExecute(format('update emailssent set sentstate=0 where id=''%s'' ',[mlist.strings[i]]));
         mBO:=os.CreateObject(Class_EmailSent);
         mBO.Load(mList.strings[i],nil);
          mCol:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Attachments'));
          if mCol.count>0 then begin
           for j:=0 to mCol.count-1 do begin
            mCol.BusinessObject[j].MarkForDelete;
            k:=k+1;
           end;
          end;
         mbo.save;
         mbo.free;
         mBO:=os.CreateObject(Class_EmailSent);
         mBO.Load(mList.strings[i],nil);
         mbo.SetFieldValueAsInteger('SentState',2);
         mbo.save;
         mbo.free;
      end;
     end;
  finally
  end;
  Success := True;
  LogInfoStr := 'Smazal jsem '+inttostr(k)+' příloh ze dne ' +FormatDateTime('d.m.yyyy',StrToFloat(mDateString));
end;

begin
end.