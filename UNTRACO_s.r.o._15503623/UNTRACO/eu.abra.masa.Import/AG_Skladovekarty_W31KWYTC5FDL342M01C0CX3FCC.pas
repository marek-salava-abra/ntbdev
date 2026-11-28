var
  gProgressForm : TForm;


procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite.GetSiteAppForm);
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

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import GPSR varování';
  mAction.Items.Add('Import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z XLS souboru ';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ExecuteImportXLSData;
end;

procedure ExecuteImportXLSData(Sender: TComponent;Index:integer);
var
  mSite: TSiteForm;
  mListIDs: TStringList;
  mRes: String;
  mOpenDlg: TOpenDialog;
  mExcelFileName: String;
  mOS:TNxCustomObjectSpace;
  mCode:string;
  mExcel, mWB, mSheet: Variant;
  i, j, k, mResult, mZpusob:integer;
  mStoreCard_ID, mEAN, mStorePriceRow_ID, mFirm_ID, mIntrastatCode, mCountryCode, mUnit:string;
  mCena1,mCena2, mCena25, mCena27, mCena30, mCena31, mHmotnost, mRP, mCena3, mCenaVyprodej:Extended;
  mBO, mSMBO, mStorePrice, mSupplierBO:TNxCustomBusinessObject;
  mUnits, mStorePrices:TNxCustomBusinessMonikerCollection;
  mStorePrice_ID:string;
begin
 if Index=0 then begin
  try
    mResult:=0;
    j:=0;
    mSite := TComponent(Sender).Site;
    mOS:=msite.BaseObjectSpace;
    mOpenDlg:=TOpenDialog.Create(sender);
    mOpenDlg.Title := 'Import z Excelu';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      try

        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
        ProgressInit(mSite, 'importuji karty...', mSheet.UsedRange.Rows.Count);
               i:=2;
               while i<mSheet.UsedRange.Rows.Count+1 do begin
                mCode:=VarToStr(mSheet.Cells[i, 1]);
                mStoreCard_ID:=GetStoreCard_ID(mOS, UpperCase(mCode));
                if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                     mBO:=mOs.CreateObject(Class_StoreCard);
                     mBO.Load(mStoreCard_ID,nil);
                     mBO.SetFieldValueAsString('X_note2',VarToStr(mSheet.Cells[i, 3]));
                     mBO.save;
                end;
                Inc(i);
                ProgressSetPos(i);
              end;
              ProgressDispose();
              //konec importu
              mWB.save;
              mWB.Close;

      finally
      end;
    end;

  finally
   NxShowSimpleMessage('Provedeno.',msite);
  end;
 end;
end;


function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE upper(CODE)=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count = 1 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetCountry_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Countries WHERE Code=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetStoreCardFirm_ID(AOS : TNxCustomObjectSpace; aCode, aFirm_ID : string) : string;
const
  cSQL = 'SELECT sc.ID FROM StoreCards sc left join suppliers s on s.id=sc.mainsupplier_id WHERE Upper(sc.CODE)=''%s'' and s.firm_id=''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode, aFirm_ID]), mList);
    if mList.Count = 1 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetStoreCardFirmEAN_ID(AOS : TNxCustomObjectSpace; aEAN, aFirm_ID : string) : string;
const
  cSQL = 'SELECT sc.ID FROM StoreCards sc left join storeunits su on su.parent_id=sc.id left join suppliers s on s.id=sc.mainsupplier_id WHERE (su.ean)=''%s'' and s.firm_id=''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aEAN, aFirm_ID]), mList);
    if mList.Count = 1 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetSM_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreMenu WHERE text=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetStorePriceRow_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID, aPriceList_ID, aPrice_ID : string) : string;
const
  cSQL = 'SELECT SP2.ID FROM Storeprices sp left join storeprices2 sp2 on sp.id=sp2.parent_id WHERE sp.storecard_id=''%s'' and sp.pricelist_id=''%s'' and sp2.price_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aPriceList_ID, aPrice_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetActionStorePriceRow_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID, aPriceList_ID, aPrice_ID : string) : string;
const
  cSQL = 'SELECT SP2.ID FROM ActionStoreprices sp left join Actionstoreprices2 sp2 on sp.id=sp2.parent_id WHERE sp.storecard_id=''%s'' and sp.pricelist_id=''%s'' and sp2.price_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aPriceList_ID, aPrice_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetKN_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM intraSTATCOMMODITIES WHERE CODE=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

Function GetData(var ASite : TSiteform; var aFirm_ID:string; var aResult, aZpusob:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBBOD, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mCbDivision, mBODDQ, mVRDQ: TRollComboEdit;
    mAllowedBOD, mAllowedVR, mListZpusob:TStringList;
    mParBOD, mParVR:String;
    cbZpusob:TComboBox;
    {mAllowed:=TStringList.create;
    mSQL3 := 'select id from StoreCards where hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbMaterial.Parameters.Clear;
    mCbMaterial.Parameters.Add('_Allowed='+mParam3);}
begin
 Result:=false;
 if ASite <> nil then begin
    {mAllowedBOD:=TStringList.create;
    mAllowedVR:=TStringList.create;
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('IO'),mAllowedBOD);
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('23'),mAllowedVR);
    mParBOD:=mAllowedBOD.DelimitedText;
    mParVR:=mAllowedVR.DelimitedText; }
    mListZpusob:=TStringList.create;
    mListZpusob.add('kódu');
    mListZpusob.add('EANu');
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 140;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Hlavní dodavatel:';



    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Firma:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBBOD:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBBOD.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCBBOD.Left:= 236;
    mCBBOD.Top:= 11;
    mCBBOD.Width:= 255;

    mBODDQ:= TRollComboEdit.Create(mForm);
    mBODDQ.Parent:= mForm;

    mBODDQ.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mBODDQ.Complete:= True;
    mBODDQ.Prefilling:= pmNone;
    mBODDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mBODDQ.Top:= 11;
    mBODDQ.Left:= 137;
    mBODDQ.Width:= 108;
    mBODDQ.DataText:=aFirm_ID;
    {mBODDQ.Parameters.Clear;
    mBODDQ.Parameters.Add('_Allowed='+mParBOD);  }
    mBODDQ.ConnectedControl:= mCBBOD;
    mBODDQ.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Dohledávání podle:';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    cbZpusob := TComboBox.Create(mForm);
    cbZpusob.Parent:= mForm;
    cbZpusob.Left := 137;
    cbZpusob.Top := 35;
    cbZpusob.Width := 108;
    cbZpusob.Text := '';
    cbZpusob.Items:=mListZpusob;
    cbZpusob.ItemIndex:=0;
    mForm.InsertControl(cbZpusob);

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 70;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 70;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then begin
         aResult:=1;
         aFirm_ID:=mBODDQ.DataText;
         Result:=true;
         aZpusob:=cbZpusob.ItemIndex;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    end;
    //mForm.free;
  end;
end;

Function GetData2(var ASite : TSiteform; var aFirm_ID:string; var aResult, aZpusob:integer;):Boolean;
var
    mLabel1,mCbCCMaterialComposition, mCbCCDivision, mCBBOD, mCBVR: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed:TDateEdit;
    mCbMaterialComposition, mCbDivision, mBODDQ, mVRDQ: TRollComboEdit;
    mAllowedBOD, mAllowedVR, mListZpusob:TStringList;
    mParBOD, mParVR:String;
    cbZpusob:TComboBox;
    {mAllowed:=TStringList.create;
    mSQL3 := 'select id from StoreCards where hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbMaterial.Parameters.Clear;
    mCbMaterial.Parameters.Add('_Allowed='+mParam3);}
begin
 Result:=false;
 if ASite <> nil then begin
    {mAllowedBOD:=TStringList.create;
    mAllowedVR:=TStringList.create;
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('IO'),mAllowedBOD);
    ASite.BaseObjectSpace.SQLSelect('Select id from docqueues where documenttype='+QuotedStr('23'),mAllowedVR);
    mParBOD:=mAllowedBOD.DelimitedText;
    mParVR:=mAllowedVR.DelimitedText; }
    mListZpusob:=TStringList.create;
    mListZpusob.add('kódu');
    mListZpusob.add('EANu');
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 140;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Dohledávání:';


    {
    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Firma:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCBBOD:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCBBOD.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCBBOD.Left:= 236;
    mCBBOD.Top:= 11;
    mCBBOD.Width:= 255;

    mBODDQ:= TRollComboEdit.Create(mForm);
    mBODDQ.Parent:= mForm;

    mBODDQ.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mBODDQ.Complete:= True;
    mBODDQ.Prefilling:= pmNone;
    mBODDQ.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mBODDQ.Top:= 11;
    mBODDQ.Left:= 137;
    mBODDQ.Width:= 108;
    mBODDQ.DataText:=aFirm_ID;
    mBODDQ.Parameters.Clear;
    mBODDQ.Parameters.Add('_Allowed='+mParBOD);
    mBODDQ.ConnectedControl:= mCBBOD;
    mBODDQ.ConnectedControlField:= 'Name';  }

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Dohledávání podle:';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    cbZpusob := TComboBox.Create(mForm);
    cbZpusob.Parent:= mForm;
    cbZpusob.Left := 137;
    cbZpusob.Top := 35;
    cbZpusob.Width := 108;
    cbZpusob.Text := '';
    cbZpusob.Items:=mListZpusob;
    cbZpusob.ItemIndex:=0;
    mForm.InsertControl(cbZpusob);

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 70;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 70;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then begin
         aResult:=1;
         //aFirm_ID:=mBODDQ.DataText;
         Result:=true;
         aZpusob:=cbZpusob.ItemIndex;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    end;
   // mForm.free;
  end;
end;



begin
end.