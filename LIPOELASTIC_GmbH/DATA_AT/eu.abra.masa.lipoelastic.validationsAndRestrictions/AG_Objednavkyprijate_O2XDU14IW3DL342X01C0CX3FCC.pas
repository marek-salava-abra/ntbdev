procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mBO:TNxCustomBusinessObject;
begin
  mBO:=TDynSiteForm(Self).CurrentObject;
  if Assigned(mBO) then begin
    if mbo.GetFieldValueAsString('PMState_ID') in ['~000000004','~000000006','~000000008','~000000101','~000000103','~000000202'] then begin
      ACanEdit:=False;
      NxShowSimpleMessage('You are not allowed to edit order in state '+mbo.GetFieldValueAsString('PMState_ID.X_PR_name')+nxcrlf+
                          'Change state to Imported',self);

    end;
  end;
end;

begin
end.