procedure FormCreate_Hook(Self: TSiteForm);
var
  mPanel: TPanel;
  mBut: TButton;
begin
  mPanel := TPanel(Self.MainPanel.FindChildControl('pnDetail'));
  if mPanel <> Nil then begin

    mBut := CreateButton(mPanel.Owner, mPanel, 110, -180, 100, 20, 'Provozovna', 1);
    mBut.Name := 'btnFO';
    mBut.Font.Style := [fsBold];
    mBut.Font.Style := [0, 1];
    mBut.Anchors := [akTop, akRight];
    mBut.OnClick := @SetFO;


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



Procedure SetFO(sender:TButton);
var
 mSite:TSiteForm;
 mGx,mRoll : Variant;
 aID:string;
 mList:Variant;
 mBO, mFOBO:TNxCustomBusinessObject;
begin
  mSite:=TComponent(sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
  if not(NxIsEmptyOID(mbo.GetFieldValueAsString('U_Firm_ID'))) then begin
      mGx := GetAbraOLEApplication;
      mList:=GetAbraOLEStrings;
      mGx.SQLSelect(format('select id from FirmOffices where parent_id=''%s'' ',[mbo.GetFieldValueAsString('U_Firm_ID')]),mList);
      if mlist.count>0 then begin

      mRoll := mGx.GetAgenda('YM2EMGXR1N3OTAOQQKO3PARQXO');
      //mRoll.Params.Add('_Allowed=' + mList.Text);
      aID:=mRoll.SingleSelectFromSelected2(mList,'Omezení', aID);
      if not(NxIsEmptyOID(aID)) then begin
        mBO.SetFieldValueAsString('U_FirmOffice_ID',aID);
        mFOBO:=msite.BaseObjectSpace.CreateObject(Class_FirmOffice);
        mFOBO.Load(aID,nil);
        mBO.SetFieldValueAsString('U_FO_Name',mFOBO.GetFieldValueAsString('Name'));
        mBO.SetFieldValueAsString('U_FO_Street',mFOBO.GetFieldValueAsString('Address_ID.Street'));
        mBO.SetFieldValueAsString('U_FO_City',mFOBO.GetFieldValueAsString('Address_ID.City'));
        mBO.SetFieldValueAsString('U_FO_PostCode',mFOBO.GetFieldValueAsString('Address_ID.PostCode'));
        TBusRollSiteForm(mSite).DataSet.UpdateFields;
      end;
      end;
  end;
end;




begin
end.