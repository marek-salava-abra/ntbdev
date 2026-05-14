procedure _AfterEditRec_Hook(Self: TDynSiteForm);
var
 mActList:TActionList;
 i:integer;
begin
 mActList := self.GetMainActionList;
  for i := 0 to mActList.ActionCount - 1 do begin
    if mActList.Actions[i].Name = 'actUpdateFirm' then begin
      if TDynSiteForm(Self).CurrentObject.GetFieldValueAsInteger('DealerDiscountKind')=3 then
       mActList.Actions[i].Execute;
      Break;
    end;
  end;
end;

begin
end.