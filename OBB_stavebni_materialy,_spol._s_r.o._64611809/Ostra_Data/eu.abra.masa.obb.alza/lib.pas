uses '.const';

procedure DeletePoukazy (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
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
  mList:=TStringList.Create;
  k:=0;
  try
     mSQL:='Select e.id from EmailsSent e left join EmailSentAttachments ESA on e.id=esa.parent_id where esa.filename='+Quotedstr(cFileName)+' and e.SentState=2 and e.EmailAccount_ID='+Quotedstr(cEmailAccount_ID);
     OS.SQLSelect(msql, mList);
     if mlist.Count>0 then begin
      for i:=0 to mlist.count-1 do begin
         os.SQLExecute(format('update emailssent set sentstate=0 where id=''%s'' ',[mlist.strings[i]]));
         mBO:=os.CreateObject(Class_EmailSent);
         mBO.Load(mList.strings[i],nil);
          mCol:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Attachments'));
          if mCol.count>0 then begin
           for j:=0 to mCol.count-1 do begin
            if mCol.BusinessObject[j].GetFieldValueAsString('FileName')=cFileName then
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
  LogInfoStr := 'Smazal jsem '+inttostr(k)+' poukazů';
end;

begin
end.