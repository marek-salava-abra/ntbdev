var
 mID_old, mDescription:string;

procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
var
 mOldBO:TNxCustomBusinessObject;
 mParams:TNxParameters;
begin
  if CFxOID.IsEmptyOrFull(mID_OLD) then exit else begin
   mParams:=GlobParams;
   mOldBO:=self.BaseObjectSpace.CreateObject(Class_ReceivedOrder);
   mOldBO.Load(mID_OLD,nil);
   if GetReason(self, mDescription) then begin
     mParams.GetOrCreateParam(dtString,'mid_old').AsString:=mID_OLD;
     mParams.GetOrCreateParam(dtString,'description').AsString:=mDescription;
     mParams.GetOrCreateParam(dtBoolean,'NoReason').AsBoolean:=False;
     TDynSiteForm(self).CurrentObject.SetFieldValueAsString('U_OPduplicateReason',AnsiLeftStr(mDescription,500));
   end else begin
     NxShowSimpleMessage('Neuvedli jste důvod kopie objednávky přijaté, doklad nepůjde uložit', self);
     mParams.GetOrCreateParam(dtBoolean,'NoReason').AsBoolean:=True;
   end;
   mID_old:='';
   mDescription:='';
  end
end;



procedure _CanClone_Hook(Self: TDynSiteForm; var ACanClone: Boolean);
begin
  if Self is TDynSiteForm then begin
    if Assigned(Self.CurrentObject) then begin
      mID_OLD:= Self.CurrentObject.OID;
    end;
  end;
end;

Function GetReason(var ASite : TSiteform; var aReason:String;):Boolean;
var
    mLabel: TLabel;
    mMemo: TMemo;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;

begin
  if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Důvod kopie OP:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Zadejte důvod:  ';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mMemo:=TMemo.Create(mForm);
    mMemo.Parent := mForm;
    mMemo.Name := 'memoReason';
    mMemo.Left := 140;
    mMemo.Width := 300;
    mMemo.Height := 100;
    mMemo.Text:='';
    mMemo.Top := (mCount*25)+12;

    mCount:= mCount+5;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Default := True;
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.OnClick := @BtnOkClick;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         Result:=true;
         aReason:=mMemo.Text;
    end;
    mForm.free;
  end;
end;

procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
var
 mReason:Boolean;
begin
  mReason:=false;
  if GlobParams.ParamExist('NoReason') then
   mReason:=GlobParams.ParamByName('NoReason').AsBoolean;
  if mReason then begin
    NxShowSimpleMessage('Doklad byl zkopírován bez udání důvodu. Doklad nelze uložit',self);
    ACanSaveNow:=False;
  end;
end;

procedure _StopEdit_PostHook(Self: TDynSiteForm);
begin
  GlobParams.Clear;
end;

procedure BtnOkClick(Sender: TObject);
var
  mForm: TForm;
  mMemo: TMemo;
begin
  mForm := TForm(TButton(Sender).Parent);
  mMemo := TMemo(mForm.FindComponent('memoReason'));

  if (mMemo <> nil) and (Length(Trim(mMemo.Text)) >= 4) then begin
    mForm.ModalResult := 1;
  end else begin
    NxShowSimpleMessage('Důvod musí být zadán.',nil);
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.