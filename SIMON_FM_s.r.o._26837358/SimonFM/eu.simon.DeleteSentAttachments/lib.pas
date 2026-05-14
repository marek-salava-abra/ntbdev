procedure DeleteAttachements (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TstringList;
 mBO:TNxCustomBusinessObject;
 mCol:TNxCustomBusinessMonikerCollection;
 mAtt:TNxCustomBusinessObject;
 i,j, k, l:Integer;
 mDateString:STring;
 msql, mMessage:String;
begin
 mMessage:='';
 for l:=90 to 100 do begin
  mDateString:=IntToStr(trunc(Now-l));
  mList:=TStringList.Create;
  k:=0;
  try
     mSQL:='Select id from EmailsSent where docdate$date=%s and id in (select parent_id from EmailSentAttachments) ';
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
  mMessage:=mMessage+#13#10+'Smazal jsem '+inttostr(k)+' příloh ze dne ' +FormatDateTime('d.m.yyyy',StrToFloat(mDateString));
  end;
  Success := True;
  LogInfoStr := mMessage;
end;

begin
end.