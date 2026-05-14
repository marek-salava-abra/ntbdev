{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
   mMAction: TMultiAction;
  mC,mcc: TControl;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    if (mAction.Name = 'actDelete') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actNew') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actEdit') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actClone') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actPrevious') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actActual') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actNext') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actFillTemporarily') then begin
      mAction.Visible := False;
    end;
  end;


end;
begin
end.