uses  'eu.abra.roeh.Logio.Requests',
      'eu.abra.roeh.Logio.Licence',
      'eu.abra.roeh.Logio.lib',
      'eu.abra.roeh.Logio.QrFunc';

var mSite: TSiteForm;

{
Vyvolává se po provedení metody Show na dané agendě. Tato událost se volá i při přepínání agend.
}
procedure FormShow_Hook(Self: TSiteForm);
var mCheckBox: TCheckBox;
begin
  mSite:=Self;
  mCheckBox:=TCheckBox(mSite.FindChildControl('chkABC'));
  if Assigned(mCheckBox) then
  begin
    mCheckBox.Checked:=ShowABCana(Self);
  end;
end;

procedure grdListDrawCell(Sender: TObject; const Left, Top, Right, Bottom: Integer; DataCol: Integer; Column: TColumn; State: TGridDrawState); var
  mDtSet: TDataset;
  mDbGrd: TDbGrid;
  mCanvas: TCanvas;
  mColor, mFontColor: TColor;
  Zn:char;
  mBO: TNxCustomBusinessObject;
begin
  if Sender is TDBGrid then
  begin
    if not(ShowABCana(TDBGrid(Sender).Site)) then exit;
    mDtSet := Column.Grid.DataSource.DataSet;
    mBO := TNxCustomObjectDataSet(mDtSet).CurrentObject;
    if not(Assigned(mBO)) then exit;
    Zn := Copy(mBO.GetFieldValueAsString('X_abc_margin_sales_frequency'),1,1);

    if (Zn in ['A','B','C','D','N']) and (mBO.GetFieldValueAsBoolean('X_AnalyzedCard')) and
      (mBO.GetFieldValueAsBoolean('StoreCard_Id.X_AnalyzedCard') or (Trim(GetParamValue(mBO.ObjectSpace,'STOREMAT'))<>'')) then
    begin
      mDbGrd := TDbGrid(Column.Grid);
      mCanvas := mDbGrd.Canvas;
      if (gdSelected in State) or (TDBGrid(Sender).SelectedRows.CurrentRowSelected) then
      begin
        case Zn of
        'A':mColor := $00115500;
        'B':mColor := $0011AACC;
        'C':mColor := $003368BC;
        'D':mColor := $00444477;
        'N':mColor := $7E5E5211;
        end;
      end else begin
        case Zn of
        'A':mColor := $00229900;
        'B':mColor := $0044DDFF;
        'C':mColor := $000077FF;
        'D':mColor := $000000CC;
        'N':mColor := $00ECDF97;
        end;
      end;
      mFontColor := clWhite;
      if Zn <> 'B' then mCanvas.Font.Color := mFontColor
      else mCanvas.Font.Color := clBlack;
      mCanvas.Brush.Color := mColor;
      mCanvas.Font.Style := nil;
      mDbGrd.DefaultDrawColumnCell(Left, Top, Right, Bottom, DataCol, Column, State);
    end;
  end;
end;


procedure AfterSiteOpen_Hook(Self: TSiteForm);
Var
  mOS : TNxCustomObjectSpace;
  Str : TStringList;
begin
 mOS := Self.BaseObjectSpace;
 CreateForcasetTable(mOS); // Založíme si tabulku jestli není
 Str := TStringList.Create;
 try
   mOs.SQLselect('Select FORECASTDATE from PARAM_INV where USER_ID='''+ Self.CompanyCache.GetUserID +'''',Str);
   if Str.Count = 0 then begin
     mOs.SQLExecute('INSERT INTO PARAM_INV (USER_ID,FORECASTDATE) Values(''' +  Self.CompanyCache.GetUserID+''','+NxFloatToIBStr(Date)+')');
   end else begin
     if StrToFloat(Str.Strings(0))< Date then
      mOs.SQLExecute('Update PARAM_INV Set FORECASTDATE ='+NxFloatToIBStr(Date)+' where USER_ID=''' +  Self.CompanyCache.GetUserID+'''');
   end;
 finally
   str.Free;
 end;
 FreqCalcValidate(Self.BaseObjectSpace, Self);
end;

procedure CreateForcasetTable(mOS:TNxCustomObjectSpace);
Const
  cCreateTable = 'CREATE TABLE PARAM_INV (USER_ID ID, FORECASTDATE DATETIME)';
  cCreateTableOra = 'CREATE TABLE PARAM_INV (USER_ID char(10), FORECASTDATE Double  precision);';
Var
  Str : TStringList;
begin
  Str := TStringList.Create;
  try
    if CFxNxRuntime.NxGetDatabaseCode = 'IB' then begin
     mOS.SQLSelect('select RDB$RELATION_NAME from  RDB$RELATIONS R where  Upper(R.RDB$RELATION_NAME) = ''PARAM_INV''',Str);
     if Str.Count =0 then mOS.SQLExecute(cCreateTable);
    end;

    if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then begin
      mOS.SQLSelect('select table_name from user_tables where Upper(table_name)= ''PARAM_INV''',Str);
      if Str.Count =0 then mOS.SQLExecute(cCreateTableOra);
    end;

  if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then begin
      mOS.SQLSelect('select name from sysobjects where Upper(name)= ''PARAM_INV''',Str);
      if Str.Count =0 then mOS.SQLExecute(cCreateTable);
    end;

  finally
    Str.Free;
  end;
end;

procedure ShowFormLastDate(Self: TBasicAction;mDate:TDateTime);
var
  frmDate: Tform;
  lblDat: TLabel;
  btnOK: TButton;
  DateEdit1: TDateEdit;
  mOS : TNxCustomObjectSpace;
begin
  mOS:= TSiteForm(Self.Owner).BaseObjectSpace;
  frmDate := TForm.Create(nil);
  try
  lblDat := TLabel.Create(frmDate);
  btnOK := TButton.Create(frmDate);
  DateEdit1 := TDateEdit.Create(frmDate);
   with frmDate do
  begin
    Name := 'frmDatum';
    Left := 573;
    Top := 345;
    BorderStyle := bsDialog;
    Caption := 'Dat. další plánované objednávky';
    ClientHeight := 84;
    ClientWidth := 257;
    Color := clBtnFace;
    OldCreateOrder := False;
    Position := poScreenCenter;
    PixelsPerInch := 96;
  end;

  with lblDat do
  begin
    Name := 'lblDat';
    Parent := frmDate;
    Left := 8;
    Top := 16;
    Width := 129;
    Height := 13;
    Caption := 'Dat. další plán. objednávky.:';
  end;
  with DateEdit1 do
  begin
    Name := 'DateEdit1';
    Parent := frmDate;
    Left := 144;
    Top := 12;
    Width := 105;
    Height := 21;
    //XE NumGlyphs := 2;
    TabOrder := 1;
  end;

  with btnOK do
  begin
    Name := 'btnOK';
    Parent := frmDate;
    Left := 88;
    Top := 40;
    Width := 75;
    Height := 25;
    Caption := '&OK';
    TabOrder := 0;
    ModalResult := 1;
    Default := True;
  end;

  if mDate = 0 then DateEdit1.Text := ''
  else DateEdit1.Date := mDate;
  if frmDate.ShowModal(Self.Site)=mrOk then begin
    mOs.SQLExecute('delete from PARAM_INV where USER_ID = ''' +  TSiteForm(Self.Owner).CompanyCache.GetUserID+'''');
    mOs.SQLExecute('INSERT INTO PARAM_INV (USER_ID,FORECASTDATE) Values(''' +  TSiteForm(Self.Owner).CompanyCache.GetUserID+''','+NxFloatToIBStr(DateEdit1.Date)+')');
  end;
  finally
    frmDate.Free;
  end;
end;

procedure ShowFormCorrectDate(mForm:TForm;mOS : TNxCustomObjectSpace;mExp:Byte);
{mExp 0 - Datum a čas Expotr z SW ABRA
mExp 1 - datum a čas ukončení importu do SW ABRA}
var
  frmDate: Tform;
  lblDat: TLabel;
  btnOK: TButton;
  DateEdit1: TDateEdit;

  mPars: TNxParameters;
  mCon: TNxContext;
  mName: string
begin
  frmDate := TForm.Create(nil);
  try
  lblDat := TLabel.Create(frmDate);
  btnOK := TButton.Create(frmDate);
  DateEdit1 := TDateEdit.Create(frmDate);
   with frmDate do
  begin
    Name := 'frmDatum';
    Left := 573;
    Top := 345;
    BorderStyle := bsDialog;
    case mExp of
     0:Caption := 'Dat. exportu z SW ABRA';
     1:Caption := 'Dat. importu z Inv.';
    end;
    ClientHeight := 84;
    ClientWidth := 257;
    Color := clBtnFace;
    OldCreateOrder := False;
    Position := poScreenCenter;
    PixelsPerInch := 96;
  end;

  with lblDat do
  begin
    Name := 'lblDat';
    Parent := frmDate;
    Left := 8;
    Top := 16;
    Width := 129;
    Height := 13;
    case mExp of
     0:Caption := 'Dat. exportu:';
     1:Caption := 'Dat. importu:';
    end;
  end;
  with DateEdit1 do
  begin
    Name := 'DateEdit1';
    Parent := frmDate;
    Left := 144;
    Top := 12;
    Width := 105;
    Height := 21;
    // XE NumGlyphs := 2;
    TabOrder := 1;
  end;

  with btnOK do
  begin
    Name := 'btnOK';
    Parent := frmDate;
    Left := 88;
    Top := 40;
    Width := 75;
    Height := 25;
    Caption := '&OK';
    TabOrder := 0;
    ModalResult := 1;
    Default := True;
  end;
  if frmDate.ShowModal(mForm)=mrOk then begin
    mCon := NxCreateContext(mOS);
    try
      mPars := TNxParameters.Create;
      try
        case mExp of
          0: mName := cExpToInv;
          1: mName := cImpFromInv;
          else RaiseException('Nepovolený parametr mExp ve funkci IntDateExportImportInv:' + IntToStr(mExp));
        end;
        mPars.GetOrCreateParam(dtDateTime, mName).AsDateTime := DateEdit1.Date;
        mCon.GetCompanyCache.SavePropertiesForCompany(mName, mPars);
      finally
        mPars.Free;
      end;
    finally
      mCon.Free;
    end;
  end;
  finally
    frmDate.Free;
  end;
end;


procedure actForecastToDate(Self: TBasicAction);
Var
  Str : TStringList;
  mOS : TNxCustomObjectSpace;
  S : string;
begin
  if not TestLicence(true,s) then Exit;
 Str := TStringList.Create;
 mOs := TSiteForm(Self.Owner).BaseObjectSpace;
 Try
   S := 'Select FORECASTDATE from PARAM_INV where Upper(USER_ID) = ''' + TSiteForm(Self.Owner).CompanyCache.GetUserID+'''';
   mOS.SQLSelect(S,Str);
   if Str.Count>0 then ShowFormLastDate(Self,StrToFloat(Str.Strings[0]))
    else ShowFormLastDate(Self,0);
 finally
   Str.Free;
 end;
end;

procedure actRequestsClick(Self: TBasicAction);
var
 S: string;
begin
  if TestLicence(true,s) then
    CreateRequests(TSiteForm(Self.Owner));
end;

procedure actOutgoingTransfer(Self: TBasicAction);
var
 S : string;
begin
  if TestLicence(true,S) then
    CreateOutgoingTransfer(TSiteForm(Self.Owner));
end;

procedure FreqCalcValidate(mOS: TNxCustomObjectSpace; AParent: TSiteForm);
var
  mDateExp,mDateImp:TDateTime;
  mPosun : Integer;
begin
  mDateExp := IntDateExportImportInv(mOS,0,0);
  mDateImp := IntDateExportImportInv(mOS,0,1);
  mPosun := 0;
  if not TryStrToInt(GetParamValue(mOS,'FREQCALC'),mPosun) then RaiseException('Parametr FREQCALC v číselníku Objednávání skladu není celé číslo!');
  if (mDateExp+mPosun) <Date then
    NxShowMessage(Application.Title, 'Datum (' + FormatDateTime('DD.MM.YYYY:HH.NN',mDateExp) +') posledního exportu je starší než povolený limit!', mdError, false, AParent);
  if (mDateImp+mPosun) <Date then
    NxShowMessage(Application.Title, 'Datum (' + FormatDateTime('DD.MM.YYYY:HH.NN',mDateImp) +') importu z Inventora je starší než povolený limit!', mdError, false, AParent);
end;

procedure actAktualComputet(Self: TMultiAction;Index: integer);
var
 S : string;
begin
 if TestLicence(true,S) then
    ShowFormCorrectDate(TSiteForm(Self.Owner),TSiteForm(Self.Owner).BaseObjectSpace,Index);
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mControl: TControl;
  mCheckBox: TCheckBox;
  mAct,mAct2: TBasicAction;
  mMultiAct : TMultiAction;
begin
  mAct:= Self.GetNewAction;
  mAct.Name:= 'actForecastToDate';
  mAct.Caption:= 'Obj.do';
  mAct.Category:= 'tabFilter'; //tabFilter,
  mAct.OnExecute:= @actForecastToDate;

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actImportRequests';
  mAct.Caption:= 'Generování pož.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actRequestsClick;

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actOutgoingTransfer';
  mAct.Caption:= 'Převodka výd.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actOutgoingTransfer;

 if IsSupervisor(Self.BaseObjectSpace) then begin
     mMultiAct:= Self.GetNewMultiAction;
     mMultiAct.ShowMenuItem := True;
     mMultiAct.Name:= 'actAktualCom';
     mMultiAct.Caption:= 'Akt. data exportu';
     mMultiAct.Items.Text := 'Akt. data exportu'#13#10'Akt. data importu';
     mMultiAct.Category:= 'tabList';
     mMultiAct.OnExecuteItem:= @actAktualComputet;
     mMultiAct.Enabled := true;
 end;
  if Self is TDynSiteForm then
  begin
    mControl := Self.FindChildControl('tabList');
    mControl := TWinControl(mControl).FindChildControl('grdList');
    if Assigned(mControl) and (mControl is TDBGrid) then
    begin
      TDBGrid(mControl).OnDrawColumnCell := @grdListDrawCell;
      TDBGrid(mControl).Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete];
    end;
  end;
//ABC škrtátko
  mControl := Self.FindChildControl('tabList');
  mControl := TWinControl(mControl).FindChildControl('pnRestrictionSelectionPanel');
  if Assigned(mControl) and (mControl is TPanel) then
  begin
    mCheckBox := TCheckBox.Create(mControl);
    mCheckBox.Parent:=TWinControl(mControl);
    mCheckBox.Caption:='ABC Analýza';
    mCheckBox.Checked:=ShowABCana(Self);
    mCheckBox.Name:='chkABC';
    mCheckBox.Top:=5;
    mCheckBox.Left:=500;
    mCheckBox.Width:=80;
    mCheckBox.OnClick:= @SaveABC2Storage;
    mSite:=Self;
  end;
//Konec škrtátka
end;


procedure SaveABC2Storage(Sender: TControl);
var
//  mSite: TSiteForm;
  mChecked: String;
  mComponent: TComponent;
begin
//  mSite:= NxFindSiteForm(Sender);
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