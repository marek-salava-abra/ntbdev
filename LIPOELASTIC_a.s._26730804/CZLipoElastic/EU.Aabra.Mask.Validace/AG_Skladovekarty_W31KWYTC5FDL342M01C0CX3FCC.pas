procedure _CanDelete_Hook(Self: TRollSiteForm; var ACanDelete: Boolean);
var
mr:tstringlist;
i:integer;
os:TNxCustomObjectSpace;
mtext:string;
begin
        mtext:='';
         mr:=tstringlist.create;
         os:=self.BaseObjectSpace;
         try
             os.SQLSelect('Select code,name from storecards where X_parent_ID=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid) + ' and hidden=' + quotedstr('N'),mr);
             if mr.count>0 then begin
                   for i:=0 to mr.count-1 do begin
                       mtext:=mtext + chr(10)+chr(13) + mr.Strings[i];
                   end;
             end;
         finally
             mr.free;
         end;
         if mtext<>'' then begin
             NxShowSimpleMessage('Skladová karta ' + TBusRollSiteForm(self).CurrentObject.DisplayName + ' je nadřízená pro :' + mtext + CHr(10)+Chr(13) + ' U uvedených karet nejprve upravte novou nadřízenou kartu' ,nil);
             ACanDelete:=false;
         end;
end;



begin
end.