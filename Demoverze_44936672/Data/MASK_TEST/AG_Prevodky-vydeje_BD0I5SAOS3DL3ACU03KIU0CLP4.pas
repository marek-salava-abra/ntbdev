procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
  mCreateIncomingTransfer: TCheckBox;

begin
    mCreateIncomingTransfer := TCheckBox(Self.FindChildControl('chkIncomingTransfer'));
    if Assigned(mCreateIncomingTransfer) then begin
      mCreateIncomingTransfer.Checked := True;
    end;
end;


begin
end.