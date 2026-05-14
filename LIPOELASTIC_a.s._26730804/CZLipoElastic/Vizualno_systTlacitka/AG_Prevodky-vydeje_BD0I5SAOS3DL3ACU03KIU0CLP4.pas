procedure FormCreate_Hook(Self: TSiteForm);
var
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mC: TControl;
begin
 // if NxCreateContext(self.BaseObjectSpace).GetCompanyCache.GetUserID='SUPER00000' then begin
 //             mAList := Self.GetMainActionList;
 //             for i := 0 to mAList.ActionCount-1 do begin
 //               mAction := mALIst.Actions[i];
 //               if (mAction.Name = 'actNewRelatedTransfer') then begin
 //                 mAction.Visible := False;
 //               end;
 //             end;
 // end;
end;


begin
end.