procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Přeúčtování nákladů';
    mAction.Hint := 'Přeúčtování nákladů';
    mAction.Category := 'tabDetail';
    mAction.OnExecute := @GenerateInt;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Přeúčtování výnosů';
    mAction.Hint := 'Přeúčtování výnosů';
    mAction.Category := 'tabDetail';
    mAction.OnExecute := @GenerateInt2;

end;


Procedure GenerateInt(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mlist, mList2:TStringList;
 mOS:TNxCustomObjectSpace;
 mBO, mRowBO, mDivision:TNxCustomBusinessObject;
 mSQL:String;
 mPercent, mAmount, mAmount2:Extended;
 i:Integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows : TMultiGrid;

begin
  mBO:=TComponent(Sender).DynSite.CurrentObject;
  if osNew in mBO.State then begin
  mAmount:=0;
  mSite:=TComponent(sender).DynSite;
  mOS:=mBO.ObjectSpace;
  mList:=TStringList.Create;
  AmountData(mAmount,mSite);
  mAmount2:=mAmount;
  mSQL:='Select id from divisions where x_percent>0';
  mOS.SQLSelect(mSQL,mlist);
  mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
  try
    for i:=0 to mlist.count-1 do begin
       mRowBO:=mRows.AddNewObject;
       mDivision:=mOS.CreateObject(Class_Division);
       mDivision.Load(mlist.Strings[i],nil);
       mRowBO.SetFieldValueAsString('CreditAccount_ID','ME00000101');
       mRowBO.SetFieldValueAsString('CreditDivision_ID','1000000101');
       mRowBO.SetFieldValueAsString('DebitAccount_ID','ME00000101');
       mRowBO.SetFieldValueAsString('DebitDivision_ID',mlist.Strings[i]);

       if i<mlist.count-1 then
       mRowBO.SetFieldValueAsFloat('TAmount',NxRoundByValue((mAmount* mDivision.GetFieldValueAsFloat('X_percent'))/100,ctArithmetic, 0.01))
       else
       mRowBO.SetFieldValueAsFloat('TAmount',mAmount2);
       mAmount2:= mAmount2-(NxRoundByValue((mAmount* mDivision.GetFieldValueAsFloat('X_percent'))/100,ctArithmetic, 0.01));
       mRowbo.SetFieldValueAsString('Text','Přeúčtování nákladů na středisko'+ mDivision.DisplayName);
       mDivision.Free

    end;
  mGRows := TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
   finally
   mlist.Free;
   end;
  end;


end;
Procedure GenerateInt2(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mlist, mList2:TStringList;
 mOS:TNxCustomObjectSpace;
 mBO, mRowBO, mDivision:TNxCustomBusinessObject;
 mSQL:String;
 mPercent, mAmount, mAmount2:Extended;
 i:Integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows : TMultiGrid;

begin
  mBO:=TComponent(Sender).DynSite.CurrentObject;
  if osNew in mBO.State then begin
  mAmount:=0;
  mSite:=TComponent(sender).DynSite;
  mOS:=mBO.ObjectSpace;
  mList:=TStringList.Create;
  AmountData(mAmount,mSite);
  mAmount2:=mAmount;
  mSQL:='Select id from divisions where x_percent>0';
  mOS.SQLSelect(mSQL,mlist);
  mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
  try
    for i:=0 to mlist.count-1 do begin
       mRowBO:=mRows.AddNewObject;
       mDivision:=mOS.CreateObject(Class_Division);
       mDivision.Load(mlist.Strings[i],nil);
       mRowBO.SetFieldValueAsString('CreditAccount_ID','3H00000101');
       mRowBO.SetFieldValueAsString('DebitDivision_ID','1000000101');
       mRowBO.SetFieldValueAsString('DebitAccount_ID','3H00000101');
       mRowBO.SetFieldValueAsString('CreditDivision_ID',mlist.Strings[i]);

       if i<mlist.count-1 then
       mRowBO.SetFieldValueAsFloat('TAmount',NxRoundByValue((mAmount* mDivision.GetFieldValueAsFloat('X_percent'))/100,ctArithmetic, 0.01))
       else
       mRowBO.SetFieldValueAsFloat('TAmount',mAmount2);
       mAmount2:= mAmount2-(NxRoundByValue((mAmount* mDivision.GetFieldValueAsFloat('X_percent'))/100,ctArithmetic, 0.01));
       mRowbo.SetFieldValueAsString('Text','Přeúčtování výnosů na středisko'+ mDivision.DisplayName);
       mDivision.Free

    end;
  mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
   finally
   mlist.Free;
   end;
  end;


end;

Function AmountData(var aKoeficient:Extended; var asite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TNumEdit;
  mEd2: TDateEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte Částku';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mform.Position:=poScreenCenter;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Částka';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd1 := TNumEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 6;
    mEd1.Width := 200;
    mEd1.Value:= aKoeficient;
    mEd1.Parent := mForm;
    CreateButton(mForm, mForm, 60, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 60, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aKoeficient:=mEd1.Value;
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