var
 aSite:TSiteForm;
{
procedure _CanSaveNow_Hook(Self: TRollSiteForm; var ACanSaveNow: Boolean);
begin
  TBusRollSiteForm(self).CurrentObject.SetFieldValueAsBoolean('U_Symbol',
   TCheckBox(TBusRollSiteForm(Self).FindChildControl('Lipo_Symbol')).Checked);
end;


procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
begin
 if Assigned(self.CurrentObject)  and assigned(TCheckBox(Self.FindChildControl('Lipo_Symbol'))) then begin
  TBusRollSiteForm(self).CurrentObject.SetFieldValueAsBoolean('U_Symbol',
   TCheckBox(TBusRollSiteForm(Self).FindChildControl('Lipo_Symbol')).Checked);
 end;
end;}

procedure InitSite_Hook(Self: TSiteForm);
var
  tabData: TTabSheet;
  i: Integer;
begin
  tabData:= TTabSheet(Self.FindChildControl('tabPhoto'));  // Předka
  if Assigned(tabData) then
  begin
    aSite:=self;
    With TPanel.Create(Self) do
    begin
      //Parent:= tabData;
      Parent:= TPanel(tabData.FindChildControl('pnPhotoProperties'));  // Tady Def. panel.
      Name:= 'pnlCheckboxes';
      top:= 20;
      Left:= 480;
      Width:= 500;
      Height:= 25;
      Caption:= '';
    end;
    With TCheckBox.Create(Self) do
    begin
      Parent:= TPanel(tabData.FindChildControl('pnlCheckboxes'));
      Name:= 'Lipo_Symbol';
      Caption:='Udržovací symbol';
      Top:= 2;
      Left:= 10;
      Width:= 180;
      Height:= 23;
      Readonly:=true;
      //OnExit:=@SetSymbol;
    end;
  end;
end;



Procedure SetSymbol(Sender:TCheckBox);
begin
  TBusRollSiteForm(aSite).CurrentObject.SetFieldValueAsBoolean('U_Symbol',
   TCheckBox(TBusRollSiteForm(asite).FindChildControl('Lipo_Symbol')).Checked);
end;


begin
end.