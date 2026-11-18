procedure FormCreate_Hook(Self: TSiteForm);
var
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    if (mAction.Name = 'actDelete') then begin
      mAction.Visible := False;
    end;
  end;
end;

begin
end.