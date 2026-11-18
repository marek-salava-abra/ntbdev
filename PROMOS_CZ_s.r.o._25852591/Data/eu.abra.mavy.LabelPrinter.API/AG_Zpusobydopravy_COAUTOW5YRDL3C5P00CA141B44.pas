uses 'eu.abra.mavy.libs.forms';
procedure OnServiceCodeChange(Sender: TRollComboEdit);
begin
   TBusRollSiteForm(Sender.Site).CurrentObject.SetFieldValueAsString('X_LP_ServiceCode_ID',Sender.DataText);
end;

procedure OnServiceCodeCODChange(Sender: TRollComboEdit);
begin
   TBusRollSiteForm(Sender.Site).CurrentObject.SetFieldValueAsString('X_LP_COD_ServiceCode_ID',Sender.DataText);
end;

procedure OnSendToLPChange(Sender: TCheckBox);
begin
   TBusRollSiteForm(Sender.Site).CurrentObject.SetFieldValueAsBoolean('X_LP_SendToLabelPrinter',Sender.Checked);
end;

procedure OnPostProviderChange(Sender: TRollComboEdit);
var
   mServiceCode, mServiceCodeCOD: TRollComboEdit;
   mSQLResult: TStringList;
   Allowed: String;
   i: Integer;
begin
   TBusRollSiteForm(Sender.Site).CurrentObject.SetFieldValueAsString('X_LP_PDMPostProvider_ID',Sender.DataText);

   if Sender.DataText <> '0000000000' then
   begin
      mServiceCode:= TRollComboEdit(Sender.GetParentForm.FindChildControl('LP_ServiceCode'));
      mServiceCodeCOD:= TRollComboEdit(Sender.GetParentForm.FindChildControl('LP_ServiceCodeCOD'));
      mSQLResult:= TStringList.Create;
      try
         mServiceCode.Parameters.Clear;
         mServiceCodeCOD.Parameters.Clear;

         Allowed:= '_Allowed=';
         Sender.Site.BaseObjectSpace.SQLSelect('Select IssuedContentType_ID From PDMPostProviders2 Where Parent_ID='+QuotedStr(Sender.DataText),mSQLResult);
         For i:= 0 to mSQLResult.Count-1 do
         begin
            Allowed:= Allowed + ';'+ mSQLResult[i];
         end;
         mServiceCode.Parameters.Add(Allowed);
         mServiceCodeCOD.Parameters.Add(Allowed);
      finally
         mSQLResult.Free;
      end;
   end;
end;


{
Vyvolá se po pohybu na hlavním datasetu.
}
procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
begin
  if Assigned( Self.FindChildControl('LP_PostProvider')) then begin
    TRollComboEdit(Self.FindChildControl('LP_PostProvider')).DataText:= Self.CurrentObject.GetFieldValueAsString('X_LP_PDMPostProvider_ID');
    TRollComboEdit(Self.FindChildControl('LP_ServiceCode')).DataText:= Self.CurrentObject.GetFieldValueAsString('X_LP_ServiceCode_ID');
    TRollComboEdit(Self.FindChildControl('LP_ServiceCodeCOD')).DataText:= Self.CurrentObject.GetFieldValueAsString('X_LP_COD_ServiceCode_ID');
    TCheckBox(Self.FindChildControl('LP_SendToLabelPrinter')).Checked:= Self.CurrentObject.GetFieldValueAsBoolean('X_LP_SendToLabelPrinter');
  end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
   pnDetail: TPanel;
   mPostProvider,mServiceCode,mServiceCodeCOD: TRollComboEdit;
   mBevel,mBevel2,mBevel3: TComboBevel;
   mSendToLP: TCheckBox;
begin
   pnDetail:= TPanel(Self.FindChildControl('pnDetail'));

   CreateLabel('LPNastaveni', 'LabelPrinter nastavení', 10, 150, -1, 12,[fsBold],TLabel(Self.FindChildControl('lblCode')).Parent);

   //Založím si položky
   mPostProvider:= TRollComboEdit.Create(Self);
   mBevel:= TComboBevel.Create(Self);

   mServiceCode:= TRollComboEdit.Create(Self);
   mBevel2:= TComboBevel.Create(Self);

   mServiceCodeCOD:= TRollComboEdit.Create(Self);
   mBevel3:= TComboBevel.Create(Self);

   mSendToLP:= TCheckBox.Create(Self);

   With TLabel.Create(Self) do
   begin
      Parent:= TLabel(Self.FindChildControl('lblCode')).Parent;
      Top:= 180 + 3;
      Left:= 10;
      Name:= '';
      Caption:= 'Poštovní poskytovatel:';
   end;

   With mPostProvider do
   begin
      Parent := pnDetail;
      ClassID:= Roll_PDMPostProviders;
      TextField:='Code';
      Name := 'LP_PostProvider';
      DataText:= '0000000000';
      ForcedField:=true;
      Complete:=true;
      Left := 170;
      Top := 180;
      Width := 120;
      Height := 18;
      ReadOnly := False;
      TabOrder := 4;
      ConnectedControl:=mBevel;
      ConnectedControlField:='Name';
      OnChange:= @OnPostProviderChange;
      OnExit:=@OnPostProviderChange;
   end;


   With mBevel do //Popisek u číselníku
   begin
      Parent:=pnDetail;
      LabelCaption:='';  //První zobrazení... název pro předvyplnění
      Top:=180;
      Left:=300;
      Width:=150;
   end;

   // Druhá položka:
   With TLabel.Create(Self) do
   begin
      Parent:= TLabel(Self.FindChildControl('lblCode')).Parent;
      Top:= 205 + 3;
      Left:= 10;
      Name:= '';
      Caption:= 'Kód přepravní služby:';
   end;

   With mServiceCodeCOD do
   begin
      Parent := pnDetail;
      ClassID:= Roll_PDMIssuedContentTypes;
      TextField:='Code';
      Name := 'LP_ServiceCode';
      DataText:= '0000000000';
      ForcedField:=true;
      Complete:=true;
      Left := 170;
      Top := 205;
      Width := 120;
      Height := 18;
      ReadOnly := False;
      TabOrder := 5;
      ConnectedControl:=mBevel2;
      ConnectedControlField:='Name';
      OnChange:= @OnServiceCodeChange;
      OnExit:= @OnServiceCodeChange;
   end;

   With mBevel2 do //Popisek u číselníku
   begin
      Parent:=pnDetail;
      LabelCaption:='';  //První zobrazení... název pro předvyplnění
      Top:=205;
      Left:=300;
      Width:=150;
   end;

      // Druhá položka:
   With TLabel.Create(Self) do
   begin
      Parent:= TLabel(Self.FindChildControl('lblCode')).Parent;
      Top:= 230 + 3;
      Left:= 10;
      Name:= '';
      Caption:= 'Kód přepravní služby (dobírka):';
   end;

   With mServiceCode do
   begin
      Parent := pnDetail;
      ClassID:= Roll_PDMIssuedContentTypes;
      TextField:='Code';
      Name := 'LP_ServiceCodeCOD';
      DataText:= '0000000000';
      ForcedField:=true;
      Complete:=true;
      Left := 170;
      Top := 230;
      Width := 120;
      Height := 18;
      ReadOnly := False;
      TabOrder := 6;
      ConnectedControl:=mBevel3;
      ConnectedControlField:='Name';
      OnChange:= @OnServiceCodeCODChange;
      OnExit:= @OnServiceCodeCODChange;
   end;

   With mBevel3 do //Popisek u číselníku
   begin
      Parent:=pnDetail;
      LabelCaption:='';
      Top:=230;
      Left:=300;
      Width:=150;
   end;

  With mSendToLP do
  begin
    Parent := pnDetail;
    Top:= 260;
    Left:= 10;
    Name:= 'LP_SendToLabelPrinter';
    Width:= 200;
    Height:= 18;
    Caption:= 'Odesílat do LabelPrinter';
    Checked:= False;
    WordWrap:= True;
    OnClick:= @OnSendToLPChange;
    OnExit:=@OnSendToLPChange;
  end;
end;

begin
end.