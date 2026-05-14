uses
  'eu.abra.eu.aviza.common';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure _InitSelectionParams_Hook(Self: TDynSiteForm; ASelection, AParams: TNxParameters);
var
  mParams: TNxParameters;
  mPar: TNxParameter;
  mBSID, mBSRowID: String;
  grdList: TDBGrid;
  mDataSet: TNxObjectDataSet;
  grdRows: TMultiGrid;
  mCurrentObject: TNxCustomBusinessObject;
  tabDetail: TTabSheet;
  dtRows: TNxRowsObjectDataSet;
begin
  if Assigned(AParams) then begin
    if AParams.IndexOfName(cParamName) >= 0 then begin
      mParams := AParams.ParamByName(cParamName).AsList;
      mBSID := mParams.ParamByName('RAMA_BV_ID').AsString;
      mBSRowID := mParams.ParamByName('RAMA_BV_ROW_ID').AsString;
      //
      grdList := TDBGrid(Self.FindChildControl('grdList'));
      mDataSet := TNxObjectDataSet(grdList.DataSource.DataSet);
      if not mDataSet.EOF then begin
        mCurrentObject := mDataSet.CurrentObject;
        if NxCompareText(mCurrentObject.OID, mBSID) then begin
          tabDetail := TTabSheet(Self.FindChildControl('tabDetail'));
          TDynSiteForm(Self).SetActivePage(tabDetail);
          grdRows := TMultiGrid(Self.FindChildControl('grdRows'));
          dtRows := TNxRowsObjectDataSet(grdRows.DataSource.DataSet);
          dtRows.First;
          while (not dtRows.EOF) and (not (NxCompareText(dtRows.CurrentObject.OID, mBSID))) do begin
            dtRows.Next;
          end;
        end;
      end;
    end;
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mMultiAction: TMultiAction;
begin
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then
  begin
    mMultiAction.Name := 'multiAviza';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := 'Avíza';
    mMultiAction.Items.Clear;
    mMultiAction.Items.Add('PPL');
    mMultiAction.Items.Add('ČS');
    mMultiAction.Items.Add('ČSOB');
    mMultiAction.Items.Add('CETELEM');
    mMultiAction.Items.Add('Česká pošta');
    mMultiAction.Items.Add('Pošta bez hranic');
    mMultiAction.Items.Add('Unicredit Bank');
    mMultiAction.Items.Add('Komerční banka');
    mMultiAction.Items.Add('PayU');
    mMultiAction.OnExecuteItem := @OnMultiExecute;
  end;
end;

begin
end.