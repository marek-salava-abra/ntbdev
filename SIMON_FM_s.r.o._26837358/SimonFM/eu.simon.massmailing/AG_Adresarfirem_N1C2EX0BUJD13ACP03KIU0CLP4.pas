uses 'eu.simon.massmailing.mail';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Hromadná korespondence';
    mAction.Hint := 'Hromadně odešle email s přílohou';
    mAction.Category := 'tabList';
    mAction.OnExecute := @MassMail;


end;

Procedure MassMail(Sender:TComponent);
var
 mSite:TSiteForm;
 mList:Tstringlist;
 mOpenDlg:TOpenDialog;
 mFileName, mFileName2,mSubject,mBody:String;
 i:Integer;
 mOS:TNxCustomObjectSpace;
 mTO:String;
 mFirmBO:TNxCustomBusinessObject;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mList:=TStringList.create;
  mOS:=TBusRollSiteForm(mSite).CurrentObject.ObjectSpace;
  if Assigned(mOs) then begin
     TBusRollSiteForm(mSite).FillListWithSelectedRows(mList);
     if mlist.Count>0 then begin
      if NxMessageBox('Dotaz', 'Přejete si automaticky vygenerovat maily pro '+IntToStr(mlist.Count)+' označených záznamů??', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin

          mOpenDlg := TOpenDialog.Create(Sender);
          if mOpenDlg.Execute then mfilename:=mOpenDlg.FileName;
          if NxMessageBox('Druhá příloha', 'Přejete si přidat druhou přílohu?', mdConfirm, mdbYesNo, 0,0,false,mSite)= mrYes then begin
           mOpenDlg := TOpenDialog.Create(Sender);
           if mOpenDlg.Execute then mfilename2:=mOpenDlg.FileName;
          end;
          if mMailData(mSite, mSubject,mBody) then begin
            for i:=0 to mlist.count-1 do begin
             mFirmBO:=mos.CreateObject(Class_Firm);
             mFirmBO.Load(mlist.strings[i],nil);
             mTO:=mFirmBO.GetFieldValueAsString('ResidenceAddress_ID.email');
             if NxIsValidEMail(mTO,False) then begin
               SendInternalMail(mOS,mto,'','', mSubject,mBody,mFileName, mFileName2, mFirmBO.OID,
                      '4100000101',mFirmBO.GetFieldValueAsString('U_BusTransaction_ID'));
             end;
            end;
           end;
           NxShowSimpleMessage('Emaily byly vygenerovány',mSite);
      end;
     end;
  end;
end;

function mMailData(var aSite:TSiteForm;var aSubject,aBody:String):Boolean;
var
 mForm:TForm ;
 mEd:TEdit;
 mMemo:TMemo;
 mLabel3:TLabel;
 mResult:Integer;
 mbutOK, mButCancel:TButton;
begin
 mForm := TForm.Create(asite);
  try
    mForm.Caption := 'Změňte OP';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 550;
    mForm.Height := 220;
    mForm.Scaled := False;
    mform.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Předmět';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd := TEdit.Create(mForm);
    mEd.Left := 107;
    mEd.Top := 17;
    mEd.Width := 380;
    mEd.Text := '';
    mEd.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Tělo';
    mLabel3.Top := 42;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mMemo:= TMemo.Create(mForm);
    mMemo.Left := 107;
    mMemo.Top := 42;
    mMemo.Width := 380;
    mMemo.Height:= 60;
    mMemo.Text := '';
    mMemo.Parent := mForm;


    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 139;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 139;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    mResult := mForm.Showmodal(asite);
    if mResult = 1 then  begin
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);


      aSubject:=med.Text;
      aBody:=mMemo.Text;
      Result:=True
    end else begin
    NxShowSimpleMessage('Ruším',asite);
    Result:=False;

    end;
  finally
    mForm.Free;
  end;
end;

begin
end.