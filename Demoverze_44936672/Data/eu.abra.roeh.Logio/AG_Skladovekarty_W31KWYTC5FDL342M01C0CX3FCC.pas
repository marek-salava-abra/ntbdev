uses  'eu.abra.roeh.Logio.Logio',
      'eu.abra.roeh.Logio.lib',
      'eu.abra.roeh.Logio.Licence',
      'eu.abra.roeh.Logio.AutoServ',
      'eu.abra.roeh.Logio.frmDod',
      'eu.abra.roeh.Logio.QRFunc';
//      'eu.abra.roeh.Logio.funcSPM';
      
var mSite: TSiteForm;

procedure calculateFields(Sender: TDataSet);
var
//  mSite: TSiteForm;
  mBOStoreCard: TNxCustomBusinessObject;
  mIsSklad: {TCheckBox}TCheckBox;
  mSklad: {TComboEdit}TRollComboEdit;
  mStore_ID: string;
  mPomStr: String;
  mTabList: TWinControl;
begin
  mBOStoreCard:=TNxCustomObjectDataSet(Sender).ActiveObject;
  if not(Assigned(mBOStoreCard)) then exit; //nejsou žádné záznamy
//  mSite := Sender.Site;

  mTabList:=TWinControl(mSite.FindChildControl('tabList'));
  mIsSklad:=TCheckBox(mSite.FindChildControl('chkNoMatter'));
  if Assigned(mIsSklad) then
  begin
  //mIsSklad:=TCheckBox(NxFindChildControl(TWinControl(NxFindChildControl(NxGetSiteAppForm(mSite), 'tabList')), 'chkNoMatter'));
    if mIsSklad.Checked then
      //všechny
      mStore_ID:=GetParamValue(mBOStoreCard.ObjectSpace,'DefaultSt') //defaultní sklad
    else begin
      mSklad:=TRollComboEdit(mSite.FindChildControl('cedFilter'));
      mStore_ID:=mSklad.DataText;  // byl Date Text XE
    end;
    if NxIsEmptyOID(mStore_ID) then exit; //není vybrán sklad, tak nemá cenu něco zobrazit

    if mBOStoreCard.GetFieldValueAsBoolean('X_AnalyzedCard') then //jen u těch co to má smysl
    begin
      mPomStr:=NxEvalObjectExprAsString(mBOStoreCard,'NxSQLSelect(''Select X_AnalyzedCard From StoreSubCards Where Store_ID=''+NxQuotedStr('''+mStore_ID+''')+'' and StoreCard_ID='' + NxQuotedStr(''' + mBOStoreCard.OID +'''),''N'')');
      if mPomStr='A' then
      begin
        mPomStr:=NxEvalObjectExprAsString(mBOStoreCard,'NxSQLSelect(''Select X_abc_margin_sales_frequency From StoreSubCards Where Store_ID=''+NxQuotedStr('''+mStore_ID+''')+'' and StoreCard_ID='' + NxQuotedStr(''' + mBOStoreCard.OID +'''),''N'')');
        Sender.FieldByName('U_Color').AsString:=Copy(mPomStr,1,1);
      end;
    end;
  end;
end;

procedure Test(Self: {TBasicAction}TAction);
var
 S : string;
 mSuccess : Boolean;
begin
 AutoLoadInventoroSubCards (TSiteForm(Self.Owner).BaseObjectSpace,mSuccess,s);
end;

{
Vyvolává se po provedení metody Show na dané agendě. Tato událost se volá i při přepínání agend.
}
procedure FormShow_Hook(Self: TSiteForm);
var
  mCheckBox: TCheckBox;
  mTabList: TWinControl;
begin
//  mTabList:=TWinControl(mSite.FindChildControl('tabList'));
  mCheckBox:=TCheckBox(Self.FindChildControl('chkABC'));
  if Assigned(mCheckBox) then
  begin
    mCheckBox.Checked:=ShowABCana(Self);
  end;
end;

procedure grdListDrawCell(Sender: TObject; const Left, Top, Right, Bottom: Integer; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  mDtSet: TDataset;
  mDbGrd: TDbGrid;
  mCanvas: TCanvas;
  mColor, mFontColor: TColor;

  mSklad: TComboEdit;
  mIsSklad: TCheckBox;
  mStore_ID: String;
  mBOStoreCard: TNxCustomBusinessObject;
  mRowSet: TMemoryDataset;
  mSubCards: TStringList;
 // mParameters: TNxParameters;
  mPomStr: String;
begin
  if Sender is TDBGrid then
  begin
    if not(ShowABCana(TDBGrid(Sender).Site)) then exit;
    mPomStr := TDBGrid(Sender).DataSource.DataSet.FieldByName('U_Color').AsString;
    if (mPomStr in ['A','B','C','D','N']) then
    begin
      mDbGrd := TDbGrid(Column.Grid);
      mCanvas := mDbGrd.Canvas;
      if (gdSelected in State) or (TDBGrid(Sender).SelectedRows.CurrentRowSelected) then
      begin
        case mPomStr of
        'A':mColor := $00115500;
        'B':mColor := $0011AACC;
        'C':mColor := $003368BC;
        'D':mColor := $00444477;
        'N':mColor := $7E5E5211;
        end;
      end else begin
        case mPomStr of
        'A':mColor := $00229900;
        'B':mColor := $0044DDFF;
        'C':mColor := $000077FF;
        'D':mColor := $000000CC;
        'N':mColor := $00ECDF97;
        end;
      end;
      if (gdSelected in State) and (TDBGrid(Sender).SelectedRows.CurrentRowSelected) then mColor:=clSkyBlue;
      mFontColor := clWhite;
      if mPomStr <> 'B' then mCanvas.Font.Color := mFontColor
      else mCanvas.Font.Color := clBlack;
      mCanvas.Brush.Color := mColor;
      mCanvas.Font.Style := nil;
      mDbGrd.DefaultDrawColumnCell(Left, Top, Right, Bottom, DataCol, Column, State);
    end;
  end;
end;

procedure actImportClick(Self: {TBasicAction}TAction);
var
 S : string;
begin
  if TestLicence(true,S) then
    ImportLogio(TSiteForm(Self.Owner));
// AutoLoadInventoroSubCards (TSiteForm(Self.Owner).BaseObjectSpace,mSuccess,mLogInfoStr);
end;


procedure actAktualClickDodav(Self: TMultiAction{TMultiAction};Index: integer);
var
 S : string;
begin
 if TestLicence(true,S) then begin
   case Index of
     0:OpenFrm(TSiteForm(Self.Owner));
     1:ImportLogioDodav(TSiteForm(Self.Owner));
   end;
 end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
  mMultiAct : TMultiAction;
  mControl: TControl;
  mCheckBox: TCheckBox;
  mFieldDef : TFieldDef;
  mField: TField;
begin
  if Self is TBusRollSiteForm then
  begin
    mControl := Self.FindChildControl('tabList');
    mControl := TWinControl(mControl).FindChildControl('grdList');
    if Assigned(mControl) and (mControl is TDBGrid) then
    begin
      TDBGrid(mControl).OnDrawColumnCell := @grdListDrawCell;
      TDBGrid(mControl).Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete];
      
      //přidání hiden kalkulated položky
      mFieldDef := TFieldDef.Create(TDBGrid(mControl).DataSource.DataSet.FieldDefs, 'U_Color', ftWideString, 1, False, 100);
      mField := mFieldDef.CreateField(TDBGrid(mControl).DataSource.DataSet, nil, 'UColor', False);
      mField.ReadOnly := True;
      mField.Size := 1;
      mField.FieldName := 'U_Color';
      mField.FieldKind := fkCalculated;
      TDBGrid(mControl).DataSource.DataSet.OnCalcFields := @calculateFields;
      mSite:=Self;
    end;
  end;
//ABC škrtátko
  mControl := Self.FindChildControl('tabList');
  mControl := TWinControl(mControl).FindChildControl('pnInfoTopRighter');
  if Assigned(mControl) and (mControl is TPanel) then
  begin
    mCheckBox := TCheckBox.Create(mControl);
    mCheckBox.Parent:=TWinControl(mControl);
    mCheckBox.Caption:='ABC Analýza';
    mCheckBox.Checked:=ShowABCana(Self);
    mCheckBox.Name:='chkABC';
    mCheckBox.Top:=2;
    mCheckBox.Left:=10;
    mCheckBox.Width:=80;
    mCheckBox.OnClick:= @SaveABC2Storage;
  end;
//Konec škrtátka
  if IsSupervisor(Self.BaseObjectSpace) then begin
     mAct:= Self.GetNewAction;
     mAct.Name:= 'actImportLogio';
     mAct.Caption:= 'Import sklad. limitů';
     mAct.Category:= 'tabList';
     mAct.OnExecute:= @actImportClick;
{
    mAct:= Self.GetNewAction;
     mAct.Name:= 'actTest';
     mAct.Caption:= 'Test';
     mAct.Category:= 'tabList';
     mAct.OnExecute:= @test;
}

  end;
  
   if IsMassChange(Self.BaseObjectSpace) then begin
     mMultiAct:= Self.GetNewMultiAction;
     mMultiAct.ShowMenuItem := True;
     mMultiAct.Name:= 'actAktualDodav';
     mMultiAct.Caption:= 'Aktualizace dod.';
     mMultiAct.Items.Text := 'Aktualizace dod.'#13#10'Import dod.';
     mMultiAct.Category:= 'tabList';
     mMultiAct.OnExecuteItem:= @actAktualClickDodav;
     mMultiAct.Enabled := true;
   end;
end;

procedure SaveABC2Storage(Sender: TControl);
var
  mSite: TSiteForm;
  mChecked: String;
  mComponent: TComponent;
begin
  mSite:= TCheckBox(Sender).Site;
  if Sender is TCheckBox then
  begin
    if TCheckBox(Sender).Checked then mChecked:='A'
      else mChecked:='N';
    SetValueToStorageForUserOS('ABC_Show',mChecked,mSite.BaseObjectSpace);
    mComponent:=mSite.FindComponent('grdList');
    if Assigned(mComponent) then
      if mComponent is TDBGrid then TDBGrid(mComponent).Repaint;
  end;
end;

function ShowABCana(aSite: TSiteForm): Boolean;
begin
  try
    Result:=(GetValueFromStorageForUserOS('ABC_Show',aSite.BaseObjectSpace) = 'A');
  except
    Result:=False;
  end;
end;

begin
end.