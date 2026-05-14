
procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
  mUser.Load(Self.CompanyCache.GetUserID, nil);
  if (mUser.GetFieldCode('U_StoreChanges')>0) and mUser.GetFieldValueAsBoolean('U_StoreChanges') then begin
mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Změna karty';
mBut.Category := 'tabList';
mBut.OnExecute := @ChangeDeliverDate;
mBut2:= Self.GetNewAction;
mBut2.ShowControl := True;
mBut2.ShowMenuItem := True;
mBut2.Caption := 'Založ kartu';
mBut2.Category := 'tabList';
mBut2.OnExecute := @GenerateStoreCard;
end;
end;

procedure GenerateStoreCard(Sender: TObject);
var
 mStoreCard, mCurrentRow, mBO:TNxCustomBusinessObject;
 mSite : TSiteForm;
 mStoreCard_Code, mStoreCard_Name, mStoreCard_ID, mStoreCardCategory_ID, mVatRate_ID:string;
 
begin
try
 mSite := NxFindSiteForm(TComponent(Sender));
  if Assigned(mSite) then begin
         mCurrentRow:=TDynSiteForm(msite).CurrentObject;
         if not(mCurrentRow.GetFieldValueAsString('StoreCard_ID')='16C2000101') then begin
           ShowMessage('Toto není karta nestandartu!');
           exit;
         end;
         mStoreCardCategory_ID:='';
         mVatRate_ID:='';
         mStoreCard_Code:=mCurrentRow.GetMonikerForFieldCode(mCurrentRow.getfieldcode('BusOrder_id')).BusinessObject.GetFieldValueAsString('Code');
         mStoreCard_Name:=mCurrentRow.GetFieldValueAsString('U_poznamka');
         CreateStoreCard(mSite,mStoreCard_Code,mStoreCard_Name, mStoreCardCategory_ID,mVatRate_ID);
         //ShowMessage(mStoreCard_Code+' '+mStoreCard_Name+' '+mStoreCardCategory_ID+' '+mVatRate_ID);
         if NxIsEmptyOID(mStoreCardCategory_ID) then begin
          ShowMessage('Nevyplnil jste typ skladové karty');
          exit
         end;
         if NxIsEmptyOID(mVatRate_ID) then begin
          ShowMessage('Nevyplnil jste typ DPH sazbu');
          exit
         end;
         mStoreCard_ID:=scrGetStoreCard_ID(mCurrentRow.ObjectSpace,'Code',mStoreCard_Code);
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           ShowMessage('Karta s kódem'+ mStoreCard_Code+' již existuje, nic jsem nezaložil.');
          exit;
         end;
         if NxIsEmptyOID(mStoreCard_ID) then begin
              mStoreCard := mCurrentRow.ObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
              mStoreCard.New;
              mStoreCard.Prefill;
              mStoreCard.SetFieldValueAsString('Code',mStoreCard_Code);
              mStoreCard.SetFieldValueAsString('name',mStoreCard_Name);
              mStoreCard.SetFieldValueAsString('VatRate_ID', mVatRate_ID);
              mStorecard.SetFieldValueAsString('StoreCardCategory_id',mStoreCardCategory_ID);
              mStoreCard.Save;
              mstorecard_id:=mStoreCard.OID;
              mstorecard.free;
         end;
           mBO:= mSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
           mbo.Load(mCurrentRow.OID,nil);
           mbo.SetFieldValueAsString('Storecard_ID', mStoreCard_ID);
           mbo.save;
         
  end;
 finally
  mbo.free;
  RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
 end;
end;

procedure ChangeDeliverDate(Sender: TObject);
var mSite : TSiteForm;
    mGrid : TDBGrid;
    mList : TStringList;
    mBO, mStoreCard, mBOReservation : TNxCustomBusinessObject;
    mStoreCard_ID, mReservation_ID : String;
    i : integer;
    mProrez: Extended;

begin
mList := TStringList.Create;
try
 mSite := NxFindSiteForm(TComponent(Sender));
// mGrid := TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList'));
 if Assigned(mSite) then begin
  TDynSiteForm(mSite).FillListWithSelectedRows(mList);
   if (mList.count) > 0 then begin
     mStoreCard_ID := GetStoreCard2(mList.count,mSite);
     if not(NxIsEmptyOID(mStoreCard_ID))then begin
        mStoreCard:=  mSite.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
        mStoreCard.Load(mStoreCard_ID,nil);
        mProrez:=mStoreCard.GetFieldValueAsFloat('X_prorez');
       if not(NxIsEmptyOID(mStoreCard_ID)) then begin
         mBO := mSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
         mBOReservation:=mSite.BaseObjectSpace.CreateObject('K2M34TV4RNDL342W01C0CX3FCC');
         try
         for i := 0 to (mList.Count - 1) do begin
          mBO.Load(mList.strings[i], nil);
          mreservation_ID:='';
          mReservation_ID:=scrGetReservation_ID(mbo.ObjectSpace,'Owner_ID',mList.Strings[i]);
          //ShowMessage(mReservation_ID);
          mBOReservation.Load(mReservation_ID,nil);
          mBOReservation.SetFieldValueAsString('StoreCard_id', mStoreCard_ID);
          mBOReservation.SetFieldValueAsFloat('Reserved', mBO.GetFieldValueAsFloat('Quantity')*mProrez);
          mBOReservation.Save;
          mBOReservation.free;
          mBO.SetFieldValueAsString('StoreCard_id', mStoreCard_ID);
          mBO.SetFieldValueAsFloat('Quantity', mBO.GetFieldValueAsFloat('Quantity')*mProrez);
          mBO.save;
         end;
          RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
         except showmessage('Chyba při přepsání skladové karty!');
         end;
       end
       else
         MessageDlg('Nekorektně zadané datum', mtError,[mbOk],0);
     end;
    End
   else
    MessageDlg('Nevybrán žádný záznam', mtError,[mbOk],0);
 end;

finally mList.free;
end;
end;

procedure RefreshDataset(AGrid : TDBGrid);
begin
NxRefreshDataSetWithoutValidate(TNxDataDataSet(AGrid.DataSource.DataSet), true);
end;


function GetStoreCard2(ACount : Integer; ASite : TSiteform) : string;
var mForm : TForm;
    mCb: TRollComboEdit;
    mCbCc: TLabel;
    mLabel1, mLabel2, mLabel3 : TLabel;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 409;
    mForm.Height:= 148;
    mForm.Caption := 'Výběr karty';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Počet označených karet:';
    mLabel1.Top := 8;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 128;

    mLabel2 := TLabel.Create(mForm);
    mLabel2.Parent := mForm;
    mLabel2.Caption := IntToStr(ACount);
    mLabel2.Top := 8;
    mLabel2.Left := 150;
    mLabel2.Height := 13;
    mLabel2.Width := 20;
    mLabel2.Font.Style := [fsBold];

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Vyběr karty:';
    mLabel3.Top := 29;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;
    mLabel3.Font.Style := [fsUnderline];

    mCbCc:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered; není v XE
    mCbCc.Left:= 128;
    mCbCc.Top:= 52;
    mCbCc.Width:= 255;

    mCb:= TRollComboEdit.Create(mForm);
    mCb.Parent:= mForm;

    mCb.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCb.Complete:= True;
    mCb.ForcedField:= True;
    mCb.Prefilling:= pmNone;
    mCb.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb.Top:= 52;
    mCb.Left:= 17;
    mCb.Width:= 108;
    mCb.ConnectedControl:= mCbCc;
    mCb.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 79;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 79;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then
        Result := mCb.DataText
    else Result := '';
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

Function CreateStoreCard(var ASite : TSiteform;var aStoreCardCode:String;var aStoreCardName: string;var aStoreCardCategory_ID:string;var aVatRate_id:String ):boolean;
var mForm : TForm;
    mCb, mCb1: TRollComboEdit;
    mCbCc, mCbCc1: TLabel;
    mLabel1, mLabel2, mLabel3,mLabel4  : TLabel;
    mEd1, mEd2:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 190;
    mForm.Caption := 'Výběr karty';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Kód karty:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;
    mLabel2 := TLabel.Create(mForm);
    mLabel2.Parent := mForm;
    mLabel2.Caption := 'Název karty:';
    mLabel2.Top := 35;
    mLabel2.Left := 17;
    mLabel2.Height := 13;
    mLabel2.Width := 100;
    mLabel2.Font.Size := 10;
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Skladový typ:';
    mLabel3.Top := 60;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 100;
    mLabel3.Font.Size := 10;
    mLabel4 := TLabel.Create(mForm);
    mLabel4.Parent := mForm;
    mLabel4.Caption := 'DPH Sazba:';
    mLabel4.Top := 85;
    mLabel4.Left := 17;
    mLabel4.Height := 13;
    mLabel4.Width := 100;
    mLabel4.Font.Size := 10;
    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 117;
    mEd1.Top := 10;
    mEd1.Width := 200;
    mEd1.Text := aStoreCardCode;
    mEd1.Parent := mForm;
    mEd2 := TEdit.Create(mForm);
    mEd2.Left := 117;
    mEd2.Top := 35;
    mEd2.Width := 200;
    mEd2.Text := aStoreCardName;
    mEd2.Parent := mForm;

    mCbCc:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc.Left:= 228;
    mCbCc.Top:= 60;
    mCbCc.Width:= 255;

    mCb:= TRollComboEdit.Create(mForm);
    mCb.Parent:= mForm;

    mCb.ClassID:= 'K40Q4IS15VDL342P01C0CX3FCC';
    mCb.Complete:= True;
    mCb.ForcedField:= True;
    mCb.Prefilling:= pmNone;
    mCb.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb.Top:= 60;
    mCb.Left:= 117;
    mCb.Width:= 108;
    mCb.ConnectedControl:= mCbCc;
    mCb.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    
    mCbCc1:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc1.Parent:= mForm;
    //mCbCc1.BevelOuter:= bvLowered;
    mCbCc1.Left:= 228;
    mCbCc1.Top:= 85;
    mCbCc1.Width:= 255;

    mCb1:= TRollComboEdit.Create(mForm);
    mCb1.Parent:= mForm;

    mCb1.ClassID:= 'KE4KIBA3Y3CL33N2010DELDFKK';
    mCb1.Complete:= True;
    mCb1.ForcedField:= True;
    mCb1.Prefilling:= pmNone;
    mCb1.TextField:= 'Tariff';  // položka podle které se bude vyhledávat
    mCb1.Top:= 85;
    mCb1.Left:= 117;
    mCb1.Width:= 108;
    mCb1.ConnectedControl:= mCbCc1;
    mCb1.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 110;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 110;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then
        aStoreCardCode:=mEd1.Text;
        aStoreCardName:=mEd2.Text;
        aStoreCardCategory_ID:= mCb.DataText;
        aVatRate_id:=mCb1.DataText;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

function scrGetReservation_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Reservations WHERE %s like ''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;
function scrGetStoreCard_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE %s like ''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;



begin
end.