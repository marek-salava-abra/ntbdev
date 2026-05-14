procedure FormCreate_Hook(Self: TSiteForm);
var
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mC: TControl;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    // Zcela odstranime funkci Opravit
 //   if (mAction.Name = 'actDelete') then begin
 //     mAction.Visible := False;
 //   end;
    if (mAction.Name = 'actReCalculatePricesByRef') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'aclPMChangeState') then begin
      mAction.Visible := False;
    end;
     if (mAction.Name = 'actSCM') then begin
      mAction.Visible := False;
    end;
     if (mAction.Name = 'actActivity') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actFind') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actFindDoc') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actFindNext') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actCooperations') then begin
      mAction.Visible := False;
    end;

  end;

 // mC := Self.MainPanel.FindChildControl('rgdisplaymodeofrows');
 // if Assigned(mC) then begin
 //   TRadioGroup(mC).Visible:= false;
 // end;

end;


begin
end.