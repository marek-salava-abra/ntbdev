function GetDate(Sender: TComponent;msite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(Sender);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum servisu';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Zadej datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(msite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;


procedure Exec(Sender: TAction;index:integer);
var mSite: TRollSiteForm;
    mOLE, mRoll, mOResult: Variant;
    mStoreCards, mBikes: TStringList;
    i, j,k: Integer;
    mBO,mbo_target,mBO_ML,mBO_ML_target,mbo_ml_target_row: TNxCustomBusinessObject;
    mError: string;
    mids,mr:TStringList;
    mMonList:boolean;
    mMon:TNxCustomBusinessMonikerCollection;
    mdate:Double;
    mID:string;
    mID_SL:string;
begin
  mSite:= TRollSiteForm(NxFindSiteForm(Sender));
  if mSite = nil then Exit;
  //mbo:= TRollSiteForm(mSite).CurrentObject;
           {

           zadání datumu

           na sl obebrat smlouovu na techto SL

           SL05,SL09 sl 10 smayat}


end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Ukončení smlouvy';
  mMAction.Hint := 'Ukončení smlouvy';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @Exec;
  mMAction.Items.Add('Ukončení smlouvy');



end;

begin
end.



