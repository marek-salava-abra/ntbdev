procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
  mUser:TNxCustomBusinessObject;
begin
  mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if muser.GetFieldValueAsBoolean('U_splatnost') then begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změna datumu platby';
 // mAction.Items.Add('Změna datumu splatnosti');
  mAction.Items.Add('Změna datumu platby');
  mAction.Hint := 'změní termín platby na dokladu';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ChangeDueDate;
  end;
end;

procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
begin
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsDateTime('X_PaymentDate',0);
  TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
end;

Procedure ChangeDueDate(Sender:TComponent;index:integer);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mDate:extended;
 mList:TStringList;
 i:integer;
begin
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  mList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  if Assigned(mBO) then begin
   {if index=0 then begin
    if NxMessageBox('Dotaz','Přejete si změnit splatnost na faktuře '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      if GetDate(mdate,mSite,'splatnosti') then begin
        mbo.ObjectSpace.SQLExecute(format('update issuedinvoices set duedate$date=%s where id=''%s'' ',[IntToStr(trunc(mdate)),mBO.OID]));
        //NxShowSimpleMessage(IntToStr(trunc(mdate)),msite);
        TDynSiteForm(mSite).RefreshData;
        TDynSiteForm(mSite).ActiveDataSet.SeekID(mbo.OID);
      end;
    end;
   end; }
   if index=0 then begin
    if NxMessageBox('Dotaz','Přejete si změnit termín platby na '+IntToStr(mlist.Count)+' zálohových listech?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      if GetDate(mdate,mSite,'platby') then begin
        for i:=0 to mlist.Count-1 do begin
          mbo.ObjectSpace.SQLExecute(format('update issueddinvoices set X_PaymentDate=%s where id=''%s'' ',[IntToStr(trunc(mdate)),mlist.Strings[i]]));
        end;
        TDynSiteForm(mSite).RefreshData;
        TDynSiteForm(mSite).ActiveDataSet.SeekID(mbo.OID);
      end;
    end;
   end;
  end;
end;


Function GetDate(var aDate:TDateTime; var Asite:TSiteForm;var aText:string):boolean;

var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TEdit;
  mEd2: TDateEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Asite);
  Result:=False;
  try
    mForm.Caption := 'Zadejte údaje pro ';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mForm.Position := poScreenCenter;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := format('Datum %s:',[aText]);
    mLab.Parent := mForm;
    mEd2 := TDateEdit.Create(mForm);
    mEd2.Left := 110;
    mEd2.Top := 10;
    mEd2.Width := 80;
    mEd2.Date := date;
    mEd2.Parent := mForm;
    CreateButton(mForm, mForm, 35, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 35, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(Asite);
    if mResult = 1 then begin
       aDate:= mEd2.Date;
       Result:=True;
    end;
  finally
    mForm.Free;
  end;
end;


function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;

begin
end.