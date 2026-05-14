

procedure _SaveChanges_PostHook(Self: TDynSiteForm);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mBO,mRowBO:TNxCustomBusinessObject;
 mMessage:string;
begin
 mBO:=self.CurrentObject;
 if Assigned(mBO) then begin
    mMessage:='';
    j:=0;
    mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
    for i:=0 to mRows.count-1 do begin
      mRowBO:= mRows.BusinessObject[i];
      if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
        k:=mbo.ObjectSpace.SQLSelectFirstAsInteger('Select count(id) from storedocuments2 where flowtype=''20'' and storecard_id='+
                                                   QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+' and store_id='+
                                                   Quotedstr(mRowBO.GetFieldValueAsString('Store_ID')),0);
        if k=0 then begin
          j:=j+1;
          if j=1 then mMessage:='Nenalezené kombinace skladová karta a sklad na příjmu';
          mMessage:=mMessage+#13#10+mRowBO.GetFieldValueAsString('StoreCard_ID.code')+'    '+mRowBO.GetFieldValueAsString('Store_ID.code');
        end;
      end;
    end;
   if j>0 then NxShowSimpleMessage(mMessage,Self);
 end;
  //NxShowSimpleMessage(self.CurrentObject.DisplayName,Self);
end;

begin
end.