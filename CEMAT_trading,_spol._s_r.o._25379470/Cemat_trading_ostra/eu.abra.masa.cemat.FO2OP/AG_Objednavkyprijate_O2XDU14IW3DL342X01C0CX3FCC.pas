var
 asite:TSiteForm;

procedure My_JIFR_Change(Sender: TObjectComboEdit);
var
  Frm: TMemoryDataset;
  mSQL: String;
begin
 { NxShowSimpleMessage(Sender.DataText,nil);  }
  if NxIsEmptyOID(Sender.DataText) then
  begin
    TComboBox(Sender.GetParentForm.FindChildControl('CEMAT_FirmOffice_ID')).Items.Text:= '';
    TComboBox(Sender.GetParentForm.FindChildControl('CEMAT_FirmOffice_Name')).Items.Text:= '';
  end
  else
  begin
    TComboBox(Sender.GetParentForm.FindChildControl('CEMAT_FirmOffice_ID')).Items.Text:= '';
    TComboBox(Sender.GetParentForm.FindChildControl('CEMAT_FirmOffice_Name')).Items.Text:= '';
    mSQL:= 'Select fo.id as ID, fo.Name as Name, a.street as street, a.postcode as postcode From FirmOffices fo left join addresses a on fo.address_id=a.id Where (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=''AT011EZZ5DFO115YJ1HCZJDXJ4'' AND ID = fo.ID AND (STRINGFIELDVALUE LIKE ''A''))) and fo.Parent_ID = '+QuotedStr(Sender.DataText);
    Frm:= TMemoryDataset.Create(nil);
    try
      Sender.Site.BaseObjectSpace.SQLSelect2(mSQL,Frm);
      if Frm.RecordCount > 0 then
      begin
        Frm.First;
        While Not (Frm.Eof) do
        begin
          TComboBox(Sender.GetParentForm.FindChildControl('CEMAT_FirmOffice_ID')).Items.Add(Frm.FieldByName('ID').AsString);
          TComboBox(Sender.GetParentForm.FindChildControl('CEMAT_FirmOffice_Name')).Items.Add(Frm.FieldByName('Name').AsString+', '+Frm.FieldByName('street').AsString+', '+Frm.FieldByName('postcode').AsString);
          Frm.Next;
        end;
      end;
    finally
      Frm.Free;
    end;
    //
  end;
end;

procedure DisableControlWithNameOnSite(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then
  begin
    DisableAllControlsOnControl(mControl);
  end;
end;



procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);

var
  Frm: TMemoryDataset;
  mSQL: String;
  i: Integer;
begin
  if NxIsEmptyOID(TDynSiteForm(Self).CurrentObject.GetFieldValueAsString('X_FirmOffice_ID')) then
  begin
    TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).Items.Add('');
    TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex:= 0;
  end
  else
  begin
    TComboBox(Self.FindChildControl('CEMAT_FirmOffice_ID')).Items.Text:= '';
    TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).Items.Text:= '';
    mSQL:= 'Select fo.id as ID, fo.Name as Name, a.street as street, a.postcode as postcode From FirmOffices fo left join addresses a on fo.address_id=a.id Where (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=''AT011EZZ5DFO115YJ1HCZJDXJ4'' AND ID = fo.ID AND (STRINGFIELDVALUE LIKE ''A''))) and fo.Parent_ID = '+QuotedStr(TDynSiteForm(Self).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
    Frm:= TMemoryDataset.Create(nil);
    try
      Self.BaseObjectSpace.SQLSelect2(mSQL,Frm);
      if Frm.RecordCount > 0 then
      begin
        Frm.First;
        While Not (Frm.Eof) do
        begin
          if Frm.FieldByName('ID').AsString = TDynSiteForm(Self).CurrentObject.GetFieldValueAsString('X_FirmOffice_ID') then i:= Frm.RecNo-1;

          TComboBox(Self.FindChildControl('CEMAT_FirmOffice_ID')).Items.Add(Frm.FieldByName('ID').AsString);
          TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).Items.Add(Frm.FieldByName('Name').AsString+', '+Frm.FieldByName('street').AsString+', '+Frm.FieldByName('postcode').AsString);
          Frm.Next;
        end;

        TComboBox(Self.FindChildControl('CEMAT_FirmOffice_ID')).ItemIndex:= i;
        TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex:= i;
      end;
    finally
      Frm.Free;
    end;
  end;
end;



procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
begin
   TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('X_FirmOffice_ID',TComboBox(Self.FindChildControl('CEMAT_FirmOffice_ID')).Items[TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex]);
   //NxShowSimpleMessage(TComboBox(Self.FindChildControl('CEMAT_FirmOffice_ID')).Items[TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex],asite);
end;




{
Vyvolá se po pohybu na hlavním datasetu.
}
procedure _MainDatasetAfterScroll_Hook(Self: TDynSiteForm);
var
  mSQL: String;
  mSQLResult: TStringList;
begin

  if Assigned(self.CurrentObject)  and assigned(TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name'))) then begin
    TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).Items.Text:= '';
    mSQL:= 'Select fo.Name, a.street From FirmOffices fo left join addresses a on fo.address_id=a.id Where fo.ID = '+QuotedStr(Self.CurrentObject.GetFieldValueAsString('X_FirmOffice_ID'));
    mSQLResult:= TStringList.Create;
    try
      Self.BaseObjectSpace.SQLSelect(mSQL,mSQLResult);
      if mSQLResult.Count > 0 then
      begin
        TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).Items.Add(NxSearchReplace(mSQLResult[0],'"','',[srall]));
        TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex:= 0;
      end
      else
      begin
        TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).Items.Add('');
        TComboBox(Self.FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex:= 0;
      end;
    finally
     // mSQLResult.Free;
    end;
  end;
end;

procedure _SetFirstFocus_Hook(Self: TRollSiteForm; ANew: Boolean);
begin
  DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_Firm_ID');
end;

// Rekurze - vyhledá všechny prvky na panelu. -> Díky varantnímu formuláři -> Nejde se dostatna prvky přímo.
procedure DisableAllControlsOnControl(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do
  begin
    DisableAllControlsOnControl(AComponent.Components(i));
  end;

  if AComponent is TObjectComboEdit then
  begin
    //NxShowSimpleMessage('B - Vyhodit',nil);
    TObjectComboEdit(AComponent).OnChange:= @My_JIFR_Change;
  end;
end;



{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}

procedure InitSite_Hook(Self: TSiteForm);
var
  tabData: TTabSheet;
  mpn_X_Firm_ID: TNxGeneralRollMovablePanel;
  i: Integer;
begin
  tabData:= TTabSheet(Self.FindChildControl('tabHeader'));  // Předka
  if Assigned(tabData) then
  begin
    aSite:=self;
    With TPanel.Create(Self) do
    begin
      //Parent:= tabData;
      Parent:= TNxDefinablePanel(tabData.FindChildControl('pnHeader'));  // Tady Def. panel.
      Name:= 'pnlFirmOffice';
      top:= 28;
      Left:= 790;
      Width:= 500;
      Height:= 40;
      Caption:= '';
    end;

    With TLabel.Create(Self) do
    begin
      Parent:= TPanel(tabData.FindChildControl('pnlFirmOffice'));
      Top:= 4;
      Left:= 2;
      Width:= 200;
      Height:= 25;
      Caption:= 'Provozovna:';
    end;

    With TComboBox.Create(Self) do
    begin
      Parent:= TPanel(tabData.FindChildControl('pnlFirmOffice'));
      Name:= 'CEMAT_FirmOffice_Name';
      Top:= 2;
      Left:= 90;
      Width:= 370;
      Height:= 25;
      Items.Add('');
      OnExit:=@ShowMessage;
    end;

    With TComboBox.Create(Self) do
    begin
      Parent:= TPanel(tabData.FindChildControl('pnlFirmOffice'));
      Name:= 'CEMAT_FirmOffice_ID';
      Top:= 20;
      Left:= 100;
      Width:= 0;
      Height:= 25;
      Items.Add('');
      OnExit:=@ShowMessage;
    end;

  end;

end;

Procedure ShowMessage(Sender:TComboBox);
var
 mFirmOfficeBO:TNxCustomBusinessObject;
 mFirmOffice_ID:string;
begin
  mFirmOffice_ID:=TComboBox(TDynSiteForm(asite).FindChildControl('CEMAT_FirmOffice_ID')).Items[TComboBox(TDynSiteForm(asite).FindChildControl('CEMAT_FirmOffice_Name')).ItemIndex];
  if not(NxIsEmptyOID(mFirmOffice_ID)) then begin
     mFirmOfficeBO:=asite.BaseObjectSpace.CreateObject(Class_FirmOffice);
     mFirmOfficeBO.load(mFirmOffice_ID,nil);
     TDynSiteForm(asite).CurrentObject.SetFieldValueAsString('U_name',mFirmOfficeBO.GetFieldValueAsString('Parent_ID.Name'));
     TDynSiteForm(asite).CurrentObject.SetFieldValueAsString('U_Street',mFirmOfficeBO.GetFieldValueAsString('Address_ID.Street'));
     TDynSiteForm(asite).CurrentObject.SetFieldValueAsString('U_City_postcode',mFirmOfficeBO.GetFieldValueAsString('Address_ID.City'));
     TDynSiteForm(asite).CurrentObject.SetFieldValueAsString('U_postcode',mFirmOfficeBO.GetFieldValueAsString('Address_ID.PostCode'));
     TDynSiteForm(asite).ActiveDataSet.RefreshCurrentItem;
  end;
end;

begin
end.