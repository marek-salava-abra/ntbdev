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
  mAction.Caption := '#Import strojů (XLSX)';
  mAction.Hint := '#Import strojů z XLSX';
  mAction.Category := 'tabList';
  mAction.OnExecute := @actMachineImport;
end;

Procedure actMachineImport(sender:TComponent);
var
  mExcel, objWorkbook, mXLS: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mSite : TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  i: Integer;
  mDivision_ID, mCode, mName, mDiv, mSupplier_ID, mSN, mSupplier, mMachine_ID, mMachineTypeName, mMachineType_ID: string;
  mHourlyRate: Extended;
  mBuyDate, mCommisionDate: TDateTime;

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

        ProgressInit(mSite, 'Import strojů', mExcel.ActiveWorkbook.WorkSheets[1].UsedRange.Rows.Count);

        mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
        mOS:= Sender.Site.BaseObjectSpace;
        for i:= 2 to mXLS.UsedRange.Rows.Count do
        begin
          try
            try
              mCode :=          NxLeft(VarToStr(mXLS.Cells[i,1]), 15);
              mName :=          NxLeft(VarToStr(mXLS.Cells[i,2]), 30);
              mMachineTypeName:=VarToStr(mXLS.Cells[i,3]);
              mSN:=             VarToStr(mXLS.Cells[i,4]);
              mDiv  :=          VarToStr(mXLS.Cells[i,5]);
              mBuyDate:=        VarToDateTime(mXLS.Cells[i,6]);
              mCommisionDate:=  VarToDateTime(mXLS.Cells[i,7]);
              mSupplier:=       VarToStr(mXLS.Cells[i,8]);


              mMachine_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE Hidden = ''N'' AND CLSID =''5AO1FW0NQXEO3GSP02043OHSBC'' AND Code='+QuotedStr(mCode));
              mDivision_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Divisions WHERE Hidden = ''N'' AND Code ='+QuotedStr(mDiv));
              mSupplier_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Firms WHERE Hidden = ''N'' AND Code ='+QuotedStr(mSupplier));
              //mMachineType_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE Hidden = ''N'' AND CLSID='''' AND Name='+QuotedStr(mMachineTypeName));
              mBO:= mOS.CreateObject('5AO1FW0NQXEO3GSP02043OHSBC');  //číselník strojů

              if NxIsEmptyOID(mMachine_ID) then begin
                mBO.New;
                mBO.Prefill;
              end else begin
                mBO.Load(mMachine_ID, nil);
              end;
              //Kód	Název	Sazba	Středisko	S/N	Umístění
              mBO.SetFieldValueAsString('Code', NxPadL(mCode, 3, '0'));
              mBO.SetFieldValueAsString('Name', mName);
              mBO.SetFieldValueAsString('X_SerialNumber', mSN);
              mBO.SetFieldValueAsString('X_Division_ID', mDivision_ID);
              mBO.SetFieldValueAsDateTime('X_AcquisitionDate', mBuyDate);
              mBO.SetFieldValueAsDateTime('X_CommisionDate', mCommisionDate);
              mBO.SetFieldValueAsString('X_Supplier_ID', mSupplier_ID);
              //mBO.SetFieldValueAsString('X_MachineType_ID', mMachineType_ID);

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


begin
end.