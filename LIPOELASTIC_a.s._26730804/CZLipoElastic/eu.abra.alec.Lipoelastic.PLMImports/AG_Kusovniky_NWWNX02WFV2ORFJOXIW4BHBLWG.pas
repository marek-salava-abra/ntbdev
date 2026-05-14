uses 'eu.abra.alec.Lipoelastic.PLMImports.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import kusovníku';
  mAction.Items.Add('Import kusovníku');
  //mAction.Items.Add('Import TPV');
  //mAction.Caption := 'Import kus. z CSV';
 // mAction.Hint := 'Naimportuje kusovník ze souboru ve formátu CSV';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportPieceList;
end;

{
procedure ImportScript(Sender: TComponent; Index: Integer);
begin
  case Index of
    0: ImportPieceList(Sender);
    1: ImportRoutine(Sender);
  end;
end;
}

procedure ImportPieceList(sender:TComponent);
var
  mBO, mRow: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mRows: TNxCustomBusinessMonikerCollection;
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  mExcel, objWorkbook, mXLS: Variant;
  mExcelFileName: String;
  mFileName, mPLMStoreCard_ID, mPLMStoreCardName, mPLMStoreCardCode, mPLMType, mCode, mName, mSpecification, mSupplier, mStoreCard_ID, mQuantity, mQUnit: string;
  mList: TStringList;
  i: integer;
begin
  mSite:= TComponent(sender).Site;
  mOS:= mSite.BaseObjectSpace;
  mOpenDialog := TOpenDialog.Create(mSite);
  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
    mOpenDialog.Free;
    exit;
  end;
  mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
  //OpenDialog.Options := [ofAllowMultiSelect];

  if mOpenDialog.Execute then
  begin
    try
      mExcelFileName := mOpenDialog.FileName;
      objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
      mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
      ProgressInit(mSite, 'Import kusovníku...', mXLS.UsedRange.Rows.Count);

      mPLMStoreCardCode:= mXLS.Cells[1, 1];
      mPLMStoreCardName:= mXLS.Cells[1, 2];
      mPLMType:=          mXLS.Cells[1, 3];
      mPLMStoreCard_ID:=  mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND IsProduct = ''A'' AND Code = '+QuotedStr(mPLMStoreCardCode));

      if not(NxIsEmptyOID(mPLMStoreCard_ID)) then
      begin
        try
          mBO:= mOS.CreateObject(Class_PLMPieceList);
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('StoreCard_ID', mPLMStoreCard_ID);
          mBO.SetFieldValueAsString('Name', NxLeft(mPLMStoreCardName, 60));
          mBO.SetFieldValueAsInteger('PieceListType', StrToInt(mPLMType));
          mBO.SetFieldValueAsString('QUnit', mBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
          mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          for i:= 3 to mList.Count -1 do begin
            mCode:=           VarToStr(mXLS.Cells[i, 1]);
            mName:=           VarToStr(mXLS.Cells[i, 2]);
            mSpecification:=  VarToStr(mXLS.Cells[i, 3]);
            mSupplier:=       VarToStr(mXLS.Cells[i, 4]);
            mQuantity:=       VarToStr(mXLS.Cells[i, 5]);
            mQUnit:=          VarToStr(mXLS.Cells[i, 6]);

            mStoreCard_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND Code = '+QuotedStr(mCode));
            if not(NxIsEmptyOID(mStoreCard_ID)) then
            begin
              mRow:= mRows.AddNewObject;
              mRow.Prefill;
              mRow.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
              mRow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(NxSearchReplace(mQuantity, ',', '.', [srAll])));
              mRow.SetFieldValueAsString('QUnit', mQUnit);
              //mRow.SetFieldValueAsInteger('Issue', 0);              //doplníme, pokud bude potřeba
              mRow.SetFieldValueAsBoolean('AllowMix', false);         //mix šarží změníme podle potřeby
              mRow.SetFieldValueAsBoolean('Replaceable', false);      //aut. náhrada změníme podle potřeby
              //mRow.SetFieldValueAsBoolean('RecordSN', false);       //evidovat SČ
              mRow.SetFieldValueAsString('Note', NxLeft(mSpecification, 150));
              //mRow.SetFieldValueAsString('SupposedStore_ID', '2100000101');
              //mRow.SetFieldValueAsBoolean('DoNotMultiply', false);  //konstantní výdej
              mRow.SetFieldValueAsInteger('CostingMethod', 0);        //způsob kalkulace
              mRow.SetFieldValueAsFloat('WastePercentage', 0);        //procento ztrát
            end else
            begin
              NxShowSimpleMessage('Skladová karta s kódem '+mCode+' nenalezena. Ukončuji.', mSite);
              exit;
            end;
            ProgressSetPos(i);
          end;
          mBO.Save;
        finally
          mBO.Free;
        end;
      end else
      begin
        NxShowSimpleMessage('Skladová karta s kódem '+mPLMStoreCardCode+' nenalezena, nebo nemá příznak "Výrobek". Ukončuji.', mSite);
      end;
    finally
      ProgressDispose();
      mOpenDialog:= nil;
      mOpenDialog.Free;
      mExcel.Quit;
      mExcel:= nil;
    end;
  end;
end;



begin
end.