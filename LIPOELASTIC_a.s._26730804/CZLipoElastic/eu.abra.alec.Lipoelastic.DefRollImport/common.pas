
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'DefRollImport';
  mAction.Caption := 'Import hodnot čís.';
  mAction.Hint := 'Import hodnot číselníku (CSV)';
  mAction.Category := 'tabList';
  mAction.OnExecute := @DefRollImport;
end;



function DefRollImport(Sender: TComponent;):string;
var
  mBO, mBORow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mOS: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mOpenDlg: TOpenDialog;
  mCLSID, mFileName, mTempStr, mCode, mNameCZ, mNameSK, mNameEN, mNameMX, mNameFR, mNameNL, mNameAU, mNameIT, mNameGB, mNameDE: string;
  mID, mStoreAssortmentGroup_ID, mSAGField: string;
  mList: TStringList;
  i: integer;
  mContext: TNxContext;
  mOpenRolSite: TOpenRolSite;
begin
  mSite:= Sender.Site;
  mCLSID:= TBusRollSiteForm(mSite).GetBusinessObjectCLSID;
  mOS:= mSite.BaseObjectSpace;
  mContext:= NxCreateContext(mOS);

  mStoreAssortmentGroup_ID:= '';
  mOpenRolSite := TOpenRolSite.Create(mContext, Roll_StoreAssortmentGroups);
  try
    mOpenRolSite.ParentForm := mSite.GetSiteAppForm;
    mOpenRolSite.MultiChoice := false;
    mOpenRolSite.Detailed := False;
    mOpenRolSite.Open;
    mStoreAssortmentGroup_ID:= mOpenRolSite.ID;
  finally
    mOpenRolSite.Free;
  end;

  if NxIsEmptyOID(mStoreAssortmentGroup_ID) then begin
    NxShowSimpleMessage('Nebyla vybrána žádná sortimentní skupina. Položky budou importovány jako společné pro všechny skupiny.', mSite);
    //exit;
  end;

  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter := 'Soubor importu (*.csv)|*.CSV';
  //mOpenDlg.Options := [ofAllowMultiSelect];
  if mOpenDlg.Execute then mFileName := mOpenDlg.FileName else Exit;
  mList:= TStringList.Create;
  try
    mList.LoadFromFile(mOpenDlg.FileName);
    ProgressInit(mSite, 'Import dat...', mList.Count);
    for i:= 1 to mList.Count -1 do begin
      mTempStr:= mList[i];
      //Kód	Název	SK	DE	EN	FR	NL	MX	AU	IT	GB
      mCode:= NxTrapStrTrim(mTempStr, ';');
      mNameCZ:= NxTrapStrTrim(mTempStr, ';');
      mNameSK:= NxTrapStrTrim(mTempStr, ';');
      mNameDE:= NxTrapStrTrim(mTempStr, ';');
      mNameEN:= NxTrapStrTrim(mTempStr, ';');
      mNameFR:= NxTrapStrTrim(mTempStr, ';');
      mNameNL:= NxTrapStrTrim(mTempStr, ';');
      mNameMX:= NxTrapStrTrim(mTempStr, ';');
      mNameAU:= NxTrapStrTrim(mTempStr, ';');
      mNameIT:= NxTrapStrTrim(mTempStr, ';');
      mNameGB:= NxTrapStrTrim(mTempStr, ';');

      if NxIsBlank(mCode) then begin
        NxShowSimpleMessage('Pole kód musí být vyplněno!', mSite);
        exit;
      end;

      if NxIsBlank(mNameDE) then mNameDE:= mNameCZ;
      if NxIsBlank(mNameSK) then mNameSK:= mNameCZ;
      if NxIsBlank(mNameEN) then mNameEN:= mNameCZ;
      if NxIsBlank(mNameFR) then mNameFR:= mNameCZ;
      if NxIsBlank(mNameNL) then mNameNL:= mNameCZ;
      if NxIsBlank(mNameMX) then mNameMX:= mNameCZ;
      if NxIsBlank(mNameAU) then mNameAU:= mNameCZ;
      if NxIsBlank(mNameIT) then mNameIT:= mNameCZ;
      if NxIsBlank(mNameGB) then mNameGB:= mNameCZ;

      mID:= mOS.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE Hidden =''N'' AND CLSID='+QuotedStr(mCLSID)+' AND Name='+QuotedStr(mNameCZ));
      mBO:= mOS.CreateObject(mCLSID);
      try
        if NxIsEmptyOID(mID) then begin
          mBO.New;
        end else begin
          mBO.Load(mID, nil);
        end;

        mBO.SetFieldValueAsString('Code', mCode);
        mBO.SetFieldValueAsString('Name', mNameCZ);

        if not(NxIsEmptyOID(mStoreAssortmentGroup_ID)) then begin
          mSAGField:= mBO.GetFieldValueAsString('X_AssortmentGroupsList');
          if NxIsBlank(mSAGField) then begin
            mBO.SetFieldValueAsString('X_AssortmentGroupsList', mStoreAssortmentGroup_ID);
          end else begin
            mBO.SetFieldValueAsString('X_AssortmentGroupsList', mSAGField + ';' + mStoreAssortmentGroup_ID);
          end;
        end;

        mBO.SetFieldValueAsString('X_SK_Nazev', '');
        mBO.SetFieldValueAsString('X_DE_Nazev', '');
        mBO.SetFieldValueAsString('X_EN_Nazev', '');
        mBO.SetFieldValueAsString('X_FR_Nazev', '');
        mBO.SetFieldValueAsString('X_NL_Nazev', '');
        mBO.SetFieldValueAsString('X_MEX_Nazev', '');
        //mBO.SetFieldValueAsString('X_AU_Nazev', mNameAU);
        mBO.SetFieldValueAsString('X_IT_Nazev', '');
        mBO.SetFieldValueAsString('X_UK_Nazev', '');

        mBO.SetFieldValueAsString('X_SK_Nazev', mNameSK);
        mBO.SetFieldValueAsString('X_DE_Nazev', mNameDE);
        mBO.SetFieldValueAsString('X_EN_Nazev', mNameEN);
        mBO.SetFieldValueAsString('X_FR_Nazev', mNameFR);
        mBO.SetFieldValueAsString('X_NL_Nazev', mNameNL);
        mBO.SetFieldValueAsString('X_MEX_Nazev', mNameMX);
        //mBO.SetFieldValueAsString('X_AU_Nazev', mNameAU);
        mBO.SetFieldValueAsString('X_IT_Nazev', mNameIT);
        mBO.SetFieldValueAsString('X_UK_Nazev', mNameGB);
        mBO.Save;
        ProgressSetPos(i);
      finally
        mBO.Free;
      end;
    end;
  finally
    mList.Free;
    //mOpenRolSite.Free;
    ProgressDispose();
    mOpenDlg.Free;
    TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
  end;
end;


Procedure SCParamImport(sender:TComponent);
var
  mExcel, objWorkbook, mXLS: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mSite : TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  i: Integer;
  mDivision_ID, mCode, mName, mDiv, mWorkPlace_ID: string;
  mHourlyRate: Extended;
begin
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
    exit;
  end;
  mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
  mOpenDialog.Options := [ofAllowMultiSelect];
  try
    if mOpenDialog.Execute then
    begin
      try
        mExcelFileName := mOpenDialog.FileName;
        objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);

        ProgressInit(mSite, 'Import pracovišť', mExcel.ActiveWorkbook.WorkSheets[1].UsedRange.Rows.Count);

        mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
        mOS:= Sender.Site.BaseObjectSpace;
        for i:= 2 to mXLS.UsedRange.Rows.Count do
        begin
          try
            try
              mCode :=      NxLeft(VarToStr(mXLS.Cells[i,1]), 15);
              mName :=      NxLeft(VarToStr(mXLS.Cells[i,2]), 30);
              mHourlyRate:= NxIBStrToFloat(VarToStr(mXLS.Cells[i,3]));
              mDiv  :=      VarToStr(mXLS.Cells[i,4]);

              mWorkPlace_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM PLMWorkPlaces WHERE Hidden = ''N'' AND Code ='+QuotedStr(mName));
              mDivision_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Divisions WHERE Hidden = ''N'' AND Code ='+QuotedStr(mDiv));
              mBO:= mOS.CreateObject(Class_PLMWorkPlace);

              if NxIsEmptyOID(mWorkPlace_ID) then begin
                mBO.New;
                mBO.Prefill;
              end else begin
                mBO.Load(mWorkPlace_ID, nil);
              end;
              //Kód	Název	Sazba	Středisko	S/N	Umístění
              mBO.SetFieldValueAsString('Code', NxLeft(mXLS.Cells[i,1], 15));
              mBO.SetFieldValueAsString('Name', NxLeft(mXLS.Cells[i,2], 30));
              mBO.SetFieldValueAsFloat('HourlyRate', NxIBStrToFloat(mXLS.Cells[i,3]));
              mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
              //mBO.SetFieldValueAsString('X_SerialNumber', NxLeft(mXLS.Cells[i,5], 50));
              //mBO.SetFieldValueAsInteger('X_Umisteni', StrToInt(mXLS.Cells[i,6]));

              ProgressSetPos(i);
              mBO.Save;
            except
              ShowMessage(ExceptionMessage);
              exit;
              mExcel.Quit;
              ProgressDispose();
            end;
          finally
            mBO.Free;
          end;
        end;
      finally
        objWorkbook.RefreshAll;
        mXLS:= nil;
        //mExcel := nil;
        mExcel.Quit;
        ProgressDispose();
      end;
    end;
  finally
    mOpenDialog.Free;
    TBusRollSiteForm(mSite).RefreshData;
  end;
end;

var
  gProgressForm : TForm;


procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite);
  gProgressForm.BorderStyle:= bsToolWindow;
  gProgressForm.Position:= poScreenCenter;
  gProgressForm.ClientWidth:= 220;
  gProgressForm.ClientHeight:= 25;
  gProgressForm.Caption := ACaption;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= gProgressForm.ClientHeight - Height - 2;
    Width:= gProgressForm.ClientWidth - 4;
    Name:= 'prgBar';
    Max := AMaxValue
  end;

  gProgressForm.Show();
  Application.ProcessMessages();
end;

procedure ProgressDispose;
begin
  gProgressForm.Close();
end;

procedure ProgressSetMax(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Max:= aValue;
end;

procedure ProgressSetPos(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Position:= aValue + 1;
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Repaint;

  gProgressForm.Refresh();
  gProgressForm.BringToFront();

  Application.ProcessMessages();
end;

function FrmTeplomer(aParentForm: TForm): TForm;
var Frm: TForm;
begin
  Frm:= TForm.Create(aParentForm);
  Frm.BorderStyle:= bsDialog;
  Frm.Position:= poScreenCenter;
  Frm.ClientWidth:= 150;
  Frm.ClientHeight:= 30;
  with TProgressBar.Create(Frm) do
  begin
    Parent:= Frm;
    Left:= 2;
    Top:= Frm.ClientHeight - Height - 2;
    Width:= Frm.ClientWidth - 4;
    Name:= 'prgBar'
  end;
  Result:= Frm;
end;


begin
end.