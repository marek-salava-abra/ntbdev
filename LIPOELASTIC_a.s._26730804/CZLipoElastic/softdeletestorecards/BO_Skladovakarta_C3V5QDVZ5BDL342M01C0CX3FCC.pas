{
Vyvolává se bezprostředně před provedením metody SoftDelete.
}
procedure BeforeSoftDelete_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
i:integer;
os:TNxCustomObjectSpace;
mtext:string;
begin
   mtext:='';
   mr:=tstringlist.create;
   os:=self.ObjectSpace;
   try
       os.SQLSelect('Select code,name from storecards where X_parent_ID=' + quotedstr(self.oid) + ' and hidden=' + quotedstr('N'),mr);
       if mr.count>0 then begin
             for i:=0 to mr.count-1 do begin
                 mtext:=mtext + chr(10)+chr(13) + mtext;
             end;
       end;
   finally
       mr.free;
   end;
   if mtext<>'' then begin
       NxShowSimpleMessage('Skladová karta ' + self.DisplayName + ' je nadřízená pro :' + mtext + CHr(10)+Chr(13) + ' U uvedených karet upravte novou nadříznou kartu' ,nil);
   end;
end;

begin
end.