uses 'eu.abra.masa.spedos.Inventura.progress';


procedure InsertRow(Sender : TButton);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mBO,mRow: TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  mOpenDlg:TOpenDialog;
  mOS:TNxCustomObjectSpace;
  mExcel, mWB, mSheet: Variant;
  i:integer;
  mVyrData, mStoreCard_ID,mStoreUnit_ID:string;
  mStore_ID,mDivision_ID, mBODDQ_ID:string;
  mDate:extended;
  mResult:Integer;
begin
  try
    mSite := TComponent(Sender).Site;
    mOS:=msite.BaseObjectSpace;
    if TDynSiteForm(mSite).Edit then begin
       NxShowSimpleMessage('Jste ve stavu editace, řádky nepůjde vložit.',mSite);
       exit;
    end;
    mResult:=0;
    mStore_ID:='';
    mDivision_ID:='';
    mBODDQ_ID:='';
    mDate:=0;
    mOpenDlg:=TOpenDialog.Create(sender);
    mOpenDlg.Title := 'Import z Excelu';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      try

        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
        ProgressInit(mSite, 'Zakládám doklady...', mSheet.UsedRange.Rows.Count);
               i:=2;
               while i<mSheet.UsedRange.Rows.Count+1 do begin
                 if NxIBStrToFloat(VarToStr(mSheet.Cells[i, 2]))>0 then begin
                 //if not(VarToStr(mSheet.Cells[i-1, 6])=VarToStr(mSheet.Cells[i, 6])) then begin
                 if i=2 then begin
                   mBO:=mOS.CreateObject(Class_ReceiptCard);
                   mBO.new;
                   mbo.Prefill;
                   mbo.SetFieldValueAsString('Firm_ID','AG21000101');
                   mbo.SetFieldValueAsString('Period_ID','34C0000101');
                   mbo.SetFieldValueAsDateTime('DocDate$Date',StrToDate('7.3.2026'));
                   mbo.SetFieldValueAsString('DocQueue_ID',GetDocQueue_ID(mOS,VarToStr(mSheet.Cells[i, 5])));
                   mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetfieldCode('Rows'));
                 end;
                  mStoreCard_ID:=GetStoreCard_ID(mOS,VarToStr(mSheet.Cells[i, 1]));
                  //mStoreUnit_ID:=GetStoreUnit(mOS,VarToStr(mSheet.Cells[i, 5]),mStoreCard_ID);
                  if not(NxIsEmptyOID(mStoreCard_ID)) {and not(NxIsEmptyOID(mStoreUnit_ID))} and (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 2]))>0) then begin
                    mRow := mrows.AddNewObject;
                    mRow.Prefill;
                    //mRow.SetFieldValueAsInteger('RowType',3);
                    mRow.SetFieldValueAsString('Store_ID',GetStore_ID(mOS,VarToStr(mSheet.Cells[i, 3])));
                    mRow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                    mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 2])));
                    mRow.SetFieldValueAsFloat('UnitPrice',0);
                    mRow.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 7])));
                    mRow.SetFieldValueAsString('Division_ID','D000000101');                                  // GAJDOŠ - uprava střediska na 702
                    mRow.SetFieldValueAsString('BusOrder_ID',GetBusOrder_ID(mOS,VarToStr(mSheet.Cells[i, 6])));
                  end;
                 end;
                //if not(VarToStr(mSheet.Cells[i, 6])=VarToStr(mSheet.Cells[i+1, 6])) then mbo.save;
                Inc(i);
                ProgressSetPos(i);
              end;
      ProgressDispose();
      mbo.save;
      //konec importu
      mWB.Close;


      finally
      end;

   end;
  finally

  end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT sc.ID FROM StoreCards sc left join suppliers sp on sp.storecard_id=sc.id WHERE SC.Code=''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetStore_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Stores WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetBusOrder_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM BusOrders WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetDocQueue_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM DocQueues WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetCurrencyID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Currencies WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetStoreUnit(AOS : TNxCustomObjectSpace; aCode, aParent_ID: string) : string;
const
  cSQL = 'SELECT ID FROM StoreUnits WHERE upper(code)=''%s'' and Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [UpperCase(aCode),aParent_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Inventura z XLS';
  mAction.Hint := 'Přidání řádků z excelu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @InsertRow;
end;

Function GetDataForReturn(var ASite : TSiteform; var aStore_ID, aDivision_ID, aBODDQ_ID: string; var aDate:Extended;var aResult:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBBOD, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mCbDivision, mBODDQ, mVRDQ: TRollComboEdit;
    mAllowedBOD, mAllowedVR:TStringList;
    mParBOD, mParVR:String;
    {mAllowed:=TStringList.create;
    mSQL3 := 'select id from StoreCards where hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbMaterial.Parameters.Clear;
    mCbMaterial.Parameters.Add('_Allowed='+mParam3);}
begin
 if ASite <> nil then begin
    mAllowedBOD:=TStringList.create;
    mAllowedVR:=TStringList.create;
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('21'),mAllowedBOD);
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('23'),mAllowedVR);
    mParBOD:=mAllowedBOD.DelimitedText;
    mParVR:=mAllowedVR.DelimitedText;
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 220;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro vracení:';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Sklad:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCMaterialComposition:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCMaterialComposition.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCMaterialComposition.Left:= 236;
    mCbCCMaterialComposition.Top:= 10;
    mCbCCMaterialComposition.Width:= 255;

    mCbMaterialComposition:= TRollComboEdit.Create(mForm);
    mCbMaterialComposition.Parent:= mForm;

    mCbMaterialComposition.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 110;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aStore_ID;
    mCbMaterialComposition.ConnectedControl:= mCbCCMaterialComposition;
    mCbMaterialComposition.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Středisko:';
    mLabel1.Top := 30;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCDivision:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCDivision.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCDivision.Left:= 236;
    mCbCCDivision.Top:= 31;
    mCbCCDivision.Width:= 255;

    mCbDivision:= TRollComboEdit.Create(mForm);
    mCbDivision.Parent:= mForm;

    mCbDivision.ClassID:= 'OA5JMX4J2FD135CH000ILPWJF4';
    mCbDivision.Complete:= True;
    mCbDivision.Prefilling:= pmNone;
    mCbDivision.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbDivision.Top:= 31;
    mCbDivision.Left:= 110;
    mCbDivision.Width:= 108;
    mCbDivision.DataText:=aDivision_ID;
    mCbDivision.ConnectedControl:= mCbCCDivision;
    mCbDivision.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Dodací listy:';
    mLabel1.Top := 50;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBBOD:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBBOD.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCBBOD.Left:= 236;
    mCBBOD.Top:= 51;
    mCBBOD.Width:= 255;

    mBODDQ:= TRollComboEdit.Create(mForm);
    mBODDQ.Parent:= mForm;

    mBODDQ.ClassID:= 'W2XNBCJK3ZD13ACL03KIU0CLP4';
    mBODDQ.Complete:= True;
    mBODDQ.Prefilling:= pmNone;
    mBODDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mBODDQ.Top:= 51;
    mBODDQ.Left:= 110;
    mBODDQ.Width:= 108;
    mBODDQ.DataText:=aBODDQ_ID;
    mBODDQ.Parameters.Clear;
    mBODDQ.Parameters.Add('_Allowed='+mParBOD);
    mBODDQ.ConnectedControl:= mCBBOD;
    mBODDQ.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Datum:';
    mLabel1.Top := 70;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mDed := TDateEdit.Create(mForm);
    mDed.Left := 110;
    mDed.Top := 69;
    mDed.Width := 80;
    mDed.Date := aDate;
    mDed.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 145;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 145;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then
         aResult:=1;
         aStore_ID:=mCbMaterialComposition.DataText;
         aDivision_ID:=mCbDivision.DataText;
         aBODDQ_ID:=mBODDQ.DataText;
         aDate:=mDed.Date;
         Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.