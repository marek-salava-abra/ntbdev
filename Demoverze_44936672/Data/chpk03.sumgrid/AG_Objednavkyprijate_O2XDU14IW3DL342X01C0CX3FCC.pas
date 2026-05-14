procedure MyAfterScroll(Sender: TNxRowsObjectDataSet);
var
   mBO: TNxCustomBusinessObject;
   mRows: TNxCustomBusinessMonikerCollection;
   mRow: TNxCustomBusinessObject;
   UserFormPanelNamegrdRows:TPanel;
   i: Integer;
   mSuma: Double;
   mSC_ID: String;
begin
   if Assigned(Sender.DynSite) then
   begin
      UserFormPanelNamegrdRows:= TPanel(Sender.DynSite.FindChildControl('AMBGPanel'));
      mBO := Sender.CurrentObject;  //aktuální řádekExpression
      try
        mSC_ID:= mBO.GetFieldValueAsString('StoreCard_ID');
        mSuma:= 0;
      finally
        mBO.Free;
      end;

      if Not NxIsEmptyOID(mSC_ID) then
      begin
          mBO:= Sender.DynSite.CurrentObject;
         try
            mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
            For i:= 0 to mRows.Count - 1 do
            begin
               mRow:= mRows.BusinessObject[i];
               if mSC_ID = mRow.GetFieldValueAsString('StoreCard_ID') then
               begin
                  mSuma:= mSuma + mRow.GetFieldValueAsFloat('Quantity');
               end;
            end;
         finally
            mBO.Free;
         end;
      end;
      UserFormPanelNamegrdRows.Font.Style:=[fsBold];
      UserFormPanelNamegrdRows.Caption:=Format('Počet %s kusů',[NxFormatNumeric('0.00,',msuma)]);
   end;
end;

procedure _AfterChangeUDF_Hook(Self: TSiteForm; AUDFCLSID: string; AUDFForm: TForm);
var
   tabRows: TTabSheet;
   UserFormPanelNamegrdRows: TPanel;
   mLabel: TLabel;
begin
   if Assigned(Self.FindChildControl('tabRows')) then
   begin
      tabRows:= TTabSheet(Self.FindChildControl('tabRows'));
      UserFormPanelNamegrdRows:= TPanel(Self.FindChildControl('AMBGPanel'));
      if Assigned(UserFormPanelNamegrdRows) then
      begin
                TMultiGrid(Self.FindChildControl('tabRows.grdRows')).DataSource.DataSet.AfterScroll:= @MyAfterScroll;

      end;
   end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mPanel: TPanel;
  mInfoGridPanel : TPanel;
begin
  mPanel:= TPanel(NxFindChildControl(NxGetSiteAppForm(Self), 'pnRowsTop'));
  mInfoGridPanel:=TPanel.Create(mPanel);
  mInfoGridPanel.Parent:=mPanel;
  mInfoGridPanel.Left:=400;
  mInfoGridPanel.Width:=200;
  mInfoGridPanel.top:=-3;
  mInfoGridPanel.Name:='AMBGPanel';
  mInfoGridPanel.Caption:='Počet kusů: 0      Počet párů: 0';
end;

begin
end.