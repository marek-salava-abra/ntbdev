uses 'eu.elso.piecelists.ParseData', 'eu.elso.piecelists.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := 'Import kusovníku XLS';
  mAct.Category := 'tabDetail';
  mAct.OnExecute := @ExecuteImportXLSData;
end;

procedure ExecuteImportXLSData(Sender: TBasicAction);
var
  mSite: TSiteForm;
  mListIDs: TStringList;
  mRes: String;
  mExcel: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mBO:TNxCustomBusinessObject;
begin
  mSite := TSiteForm(Sender.Owner);
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mSite) then begin
    mOpenDialog := TOpenDialog.Create(mSite);
    try
      mOpenDialog.Filter := 'Soubor s daty (*.xls, *.xlsx)|*.xls; *.xlsx';
      mOpenDialog.FileName := '';
      if mOpenDialog.Execute then
        mExcelFileName:= mOpenDialog.FileName
      else
        Exit;
      mExcel := CreateOleObject('Excel.Application');
      mExcel.WorkBooks.Open(mExcelFileName);
      mExcel.Visible := false; // pokud je nastaveno na true otevře EXCEL a můžeme doplňovat hodnoty
      mRes := RunImportXLSData(mSite, mExcel);
      if mRes <> '' then
        ShowMessage(mRes);
    finally
    end;
  end;
end;


Function RunImportXLSData(ASite: TSiteForm; aExcel: Variant): String;
var
  mIC, mCode, mFirmID: String;
  i: integer;
  mLog: TStringList;
  mBO, mRowBO, mStoreCardBO: TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  DueTerm:Integer;
  mStoreCard_ID,mBusOrder_ID, mMessage :String;
  mOS:TNxCustomObjectSpace;
  mEndRow:Integer;
  mNotImportedList:TStringList;
  mGRows:TMultiGrid;
begin
    mOS:=ASite.BaseObjectSpace;
    mBO:=TDynSiteForm(Asite).CurrentObject;
    mEndRow:=StrToInt(InputBox('Dotaz','Zadejte koncový řádek:','25',ASite));
       try
         ProgressInit(ASite, 'Kontrola položek...', mEndRow-1);
           mNotImportedList:=TStringList.Create;
           for i := 2 to mEndRow do begin

              mStoreCard_ID:=GetStoreCard_ID(mOS,VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
              if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCard2_ID(mOS,VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
              if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCard3_ID(mOS,VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
              if nxisemptyoid(mstoreCard_ID) then begin
                mStoreCardBO:=mos.CreateObject(class_storeCard);
                mStoreCardBO.New;
                mstoreCardBo.Prefill;
                mstoreCardBO.SetFieldValueAsString('Code', 'IMPORT');
                mStoreCardBo.SetFieldValueAsString('Name', VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
                mStoreCardBo.SetFieldValueAsString('Specification2', VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
                mStoreCardBo.SetFieldValueAsString('X_Barcode', VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
                mStoreCardBO.SetFieldValueAsString('StoreCardCategory_ID','2000000101');
                mStoreCardBO.SetFieldValueAsString('VatRate_ID','02100X0000');
                mStoreCardBo.save;
                mNotImportedList.Add(VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
                mStoreCardBO.free;
              end;

          ProgressSetPos(i+1);
          end;
          ProgressDispose();
          if mNotImportedList.count>0 then begin
           mMessage:='Založené položky: ';
           for i:=0 to mNotImportedList.count-1 do begin
             mMessage:=mMessage+#13+#10+mNotImportedList.Strings[i];

           end;
           NxShowSimpleMessage(mMessage,aSite);
           //exit;
          end;
        finally

        end;
    try
      mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      ProgressInit(ASite, 'Import položek...', mEndRow-1);
       for i := 2 to mEndRow do begin


          mStoreCard_ID:=GetStoreCard_ID(mOS,VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
              if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCard2_ID(mOS,VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
              if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCard3_ID(mOS,VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 5]));
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mRowBO:=mRows.AddNewObject;
          mrowbo.Prefill;
          mrowbo.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
          mrowbo.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(VarToStr(AExcel.WorkBooks[1].WorkSheets[1].Cells[i, 1])));
          mrowbo.SetFieldValueAsString('SupposedStore_ID','1000000101');
          end;
        ProgressSetPos(i+1);
          end;
      ProgressDispose();
       mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(aSite), 'grdRows'));
        if Assigned(mGRows) then    mGRows.DataSource.DataSet.Refresh;
    finally

    end;
end;


Function GetFirmIDbyOrgIdentNumber(AOS: TNxCustomObjectSpace; AOrgIdentNumber: String): String;
var
  mRes, mOrgIdentNumber: String;
  mList: TStringList;
begin
  mRes := '0000000000';
  if mOrgIdentNumber <> '' then begin
    mList := TStringList.Create;
    try
      aos.SQLSelect('Select ID from Firms where OrgIdentNumber='+QuotedStr(AOrgIdentNumber)+' and firm_ID is null and Hidden=''N''', mList);
      if mList.Count > 0 then
        mRes := mlist.strings[0];
    finally
      mList.Free;
    end;
  end;
  Result := mRes;
end;

// dokhledá firmu dle kódu

Function GetBusOrder_ID(AOS: TNxCustomObjectSpace; ACode: String): String;
var
  mRes, mCode: String;
  mSQLRes: TStringList;
begin
  mRes := '0000000000';
  if ACode <> '' then begin
    mSQLRes := TStringList.Create;
    try
      aos.SQLSelect('Select ID from BusOrders where code='+QuotedStr(ACode)+' and Hidden=''N''', mSQLRes);
      if mSQLRes.Count > 0 then
        mRes := mSQLRes[0];
    finally
      mSQLRes.Free;
    end;
  end;
  Result := mRes
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aPartNumber : string) : string;
const
  cSQL = 'SELECT ID FROM storecards WHERE X_barcode=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aPartNumber]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetStoreCard2_ID(AOS : TNxCustomObjectSpace; aPartNumber : string) : string;
const
  cSQL = 'SELECT ID FROM storecards WHERE Specification2=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aPartNumber]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;
function GetStoreCard3_ID(AOS : TNxCustomObjectSpace; aPartNumber : string) : string;
const
  cSQL = 'SELECT ID FROM storecards WHERE name=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aPartNumber]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;



begin
end.