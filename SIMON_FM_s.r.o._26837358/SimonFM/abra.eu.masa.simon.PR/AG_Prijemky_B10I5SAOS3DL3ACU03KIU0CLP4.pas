Var
  gModalResult : integer;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2, mAction3: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Popis';
    mAction.Hint := 'Doplní Popis';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    mAction.OnUpdate := @ImportOnUpdate;
    mAction2 := Self.GetNewAction;
    mAction2.ShowControl := True;
    mAction2.ShowMenuItem := True;
    mAction2.Caption := 'Data PRS';
    mAction2.Hint := 'Doplní PRS data';
    mAction2.Category := 'tabList';
    mAction2.OnExecute := @PRSData;
    mAction2.OnUpdate := @ImportOnUpdate;
    mAction3 := Self.GetNewAction;
    mAction3.ShowControl := True;
    mAction3.ShowMenuItem := True;
    mAction3.Caption := 'Sklad. karty';
    mAction3.Hint := 'Zobrazí skladové karty';
    mAction3.Category := 'tabList';
    mAction3.OnExecute := @StoreCards;
    mAction3.OnUpdate := @ImportOnUpdate;
  end;

procedure StoreCards(Sender: TObject);
var
mSite: TSiteForm;
mPR: TNxCustomBusinessObject;
mRows: TNxCustomBusinessMonikerCollection;
i: integer;
mRollParams: TNxParameters;
mList: TStringList;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
      mPR := TDynSiteForm(mSite).CurrentObject;
      mRollParams := TNxParameters.Create;
      mList := TStringList.Create;
      mRows:= mpr.GetLoadedCollectionMonikerForFieldCode(mPR.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin

         mlist.Add(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'));
      
      end;
    for i:=0 to mlist.count-1 do mlist[i]:=QuotedStr(mlist[i]);
     msite.ShowSite('W31KWYTC5FDL342M01C0CX3FCC',true,'FilterByUserDynSQLCondition;a.ID in ('+mList.CommaText+')');
    end;
  end;
end;





procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ImportOnExecute(Sender: TObject);
var
mSite: TSiteForm;
mPPLNumber: String;
mPPLDate: TDateTime;
mFV: TNxCustomBusinessObject;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
      mfv := TDynSiteForm(mSite).CurrentObject;
      mPPLNumber:=mfv.GetFieldValueAsString('Description');

                  PPLData(mPPLDate,mPPLNumber, mSite);

                mfv.SetFieldValueAsString('Description',mpplnumber);
  mfv.Save;
  mfv.Free;
 end;
end;
end;

procedure PRSData(Sender: TObject);
var
mSite: TSiteForm;
mDescription: String;
mUnitPrice,mTransportPrice:Extended;
mPPLDate: TDateTime;
mBO, mRowBO, mOtherCostsBO: TNxCustomBusinessObject;
mRowsMoniker: TNxCustomBusinessMonikerCollection;
mFirm_ID:String;

begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
      mBO := TDynSiteForm(mSite).CurrentObject;
      if not(mbo.GetFieldValueAsString('DocQueue_ID')='1710000101') then begin
      NxShowMessage('Info','Nelze opravit, není PRS', mdWarning,false,msite);
      exit;
      end;
      mRowsMoniker:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
      mRowBO:=mRowsMoniker.BusinessObject[0];
      mUnitPrice:=mRowBO.GetFieldValueAsFloat('UnitPrice');
      mTransportPrice:=mRowBO.GetMonikerForFieldCode(mRowBO.GetFieldCode('AdditionalCosts_ID')).BusinessObject.GetFieldValueAsFloat('TransportationAmount');
      mDescription:=mBO.GetFieldValueAsString('Description');
      PRSDataDialog(msite ,mDescription, mUnitPrice, mTransportPrice,mFirm_ID);
      mRowBO.SetFieldValueAsFloat('UnitPrice', mUnitPrice);
       mRowBO.SetFieldValueAsFloat('TotalPrice', mUnitPrice);
      mRowBO.GetMonikerForFieldCode(mRowBO.GetFieldCode('AdditionalCosts_ID')).BusinessObject.SetFieldValueAsFloat('TransportationAmount',mTransportPrice);
      mBO.SetFieldValueAsString('Description',mDescription);
      if not(NxIsEmptyOID(mFirm_ID)) then mbo.SetFieldValueAsString('Firm_ID',mFirm_ID);

    if mbo.needsave then mBO.Save;
   mBO.Free;
  end;
 end;
end;

Function PRSDataDialog(var asite:tsiteform; var aDescription: string;var aUnitPrice,aTransportPrice:Extended; var aFirm_ID:string):boolean;

 var
  mForm: TForm;

    mCbFirm: TRollComboEdit;
    mCbCcFirm: TLabel;
  mLab, mlabel3: TLabel;
  mEd1: TEdit;
  mEd2, mEd3: TNumEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(asite);
  try
    mForm.Caption := 'Zadejte popis';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 550;
    mForm.Height := 220;
    mForm.Scaled := False;
    mform.Position := poScreenCenter;
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 17;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.DataText:=aFirm_ID;
    mCbFirm.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 17;
    mCbFirm.Left:= 110;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    
    mLab := TLabel.Create(mForm);
    mLab.Left := 17;
    mLab.Top := 40;
    mLab.Caption := 'Popis';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 17;
    mLab.Top := 75;
    mLab.Caption := 'Cena';
    mLab.Parent := mForm;

    mLab := TLabel.Create(mForm);
    mLab.Left := 17;
    mLab.Top := 100;
    mLab.Caption := 'Doprava';
    mLab.Parent := mForm;
    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 46;
    mEd1.Width := 200;
    mEd1.Text := aDescription;
    mEd1.Parent := mForm;
    med2 := TNumEdit.Create(mForm);
    med2.left :=110;
    med2.top := 71;
    med2.Value := aUnitPrice;
    med2.DecimalPlaces := 2;
    med2.parent :=mForm;

    med3 := TNumEdit.Create(mForm);
    med3.left :=110;
    med3.top := 96;
    med3.Value := aTransportPrice;
    med3.DecimalPlaces := 2;
    med3.parent :=mForm;
    CreateButton(mForm, mForm, 140, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 140, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then  begin
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aDescription:=mEd1.Text;
      aUnitPrice:=med2.Value;
      aTransportPrice:=med3.value;
      aFirm_id:= mCbFirm.DataText;
      Result:=True
    end else begin
    NxShowSimpleMessage('Ruším',asite);
    Result:=False;
    
    end;
  finally
    mForm.Free;
  end;
end;




Function PPLData(var aPPLdate:TDateTime; var aPPlNumber: string; var aSite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TEdit;
  mEd2: TDateEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte popis';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Popis';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 6;
    mEd1.Width := 200;
    mEd1.Text := aPPlNumber;
    mEd1.Parent := mForm;
    CreateButton(mForm, mForm, 60, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 60, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(aSite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aPPlNumber:=mEd1.Text;
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