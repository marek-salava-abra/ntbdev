uses 'eu.abra.alec.Lipoelastic.PLMWorkPlaceImport.fce';

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
  mAction.Name := 'actPLMWPImport';
  mAction.Caption := 'Import pracovišť (XLSX)';
  mAction.Hint := 'Import pracovišť z XLSX';
  mAction.Category := 'tabList';
  mAction.OnExecute := @actPLMWPImport;
end;

procedure _StopEdit_PreHook(Self: TRollSiteForm);
begin

end;

Procedure actPLMWPImport(sender:TComponent);
var
  mExcel, objWorkbook, mXLS: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mSite : TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  i, j, mWPCount: Integer;
  mDivision_ID, mCode, mName, mDiv, mWorkPlace_ID, mRealCode, mSN, mAquisitionStr: string;
  mHourlyRate: Extended;
  mAquisitionDate: TDateTime;

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
              mCode :=      NxLeft(VarToStr(mXLS.Cells[i,2]), 12);
              mName :=      NxLeft(VarToStr(mXLS.Cells[i,3]), 30);
              mSN :=        VarToStr(mXLS.Cells[i,4]);
              //mHourlyRate:= NxIBStrToFloat(VarToStr(mXLS.Cells[i,3]));
              mDiv  :=      VarToStr(mXLS.Cells[i,5]);
              mAquisitionStr:= VarToStr(mXLS.Cells[i,6]);
              if not NxIsBlank(mAquisitionStr) then mAquisitionDate:= StrToDate(mAquisitionStr);

              mCode:= mCode+'-';
              mWPCount:= mOS.SQLSelectFirstAsInteger('SELECT COUNT(ID) FROM PLMWorkPlaces WHERE Hidden =''N'' AND Code like '+QuotedStr(mCode+'%'));
              mWorkPlace_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM PLMWorkPlaces WHERE Hidden = ''N'' AND Code like '+QuotedStr(mCode+ NxPadL(IntToStr(mWPCount+1), 2, '0'))+' ORDER BY Code DESC');

              if mDiv = 'VM' then
                mDivision_ID:= '6700000101'
              else
                mDivision_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Divisions WHERE Hidden = ''N'' AND Code ='+QuotedStr(mDiv));

              mRealCode:= mCode+ NxPadL(IntToStr(mWPCount + 1), 2, '0');

              mBO:= mOS.CreateObject(Class_PLMWorkPlace);
              if NxIsEmptyOID(mWorkPlace_ID) then begin
                mBO.New;
                mBO.Prefill;
              //end else begin
                //mBO.Load(mWorkPlace_ID, nil);
              //end;
              //Kód	Název	Sazba	Středisko	S/N	Umístění
              mBO.SetFieldValueAsString('Code', mRealCode);
              mBO.SetFieldValueAsString('Name', mName);
              //mBO.SetFieldValueAsFloat('HourlyRate', NxIBStrToFloat(mXLS.Cells[i,3]));
              mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
              mBO.SetFieldValueAsString('X_SN', mSN);
              mBO.SetFieldValueAsDateTime('X_AquisitionDate', mAquisitionDate);
              //mBO.SetFieldValueAsString('X_SerialNumber', NxLeft(mXLS.Cells[i,5], 50));
              //mBO.SetFieldValueAsInteger('X_Umisteni', StrToInt(mXLS.Cells[i,6]));
              mBO.SetFieldValueAsString('X_Supplier_ID', '');
              mBO.SetFieldValueAsString('X_Parent_ID', '');

              ProgressSetPos(i);
              //NxShowSimpleMessage(datetostr(mbo.GetFieldValueAsDateTime('X_AquisitionDate')), mSite);
              mBO.Save;
              end;
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


begin
end.