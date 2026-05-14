
Const
      cDescription = 'Aut. zdanění';
      cRowtext = 'Zdanění zálohy: ';
      cDZL_Agenda = 'ZSR1DT11PBWOJ3MELFAGIQ22QO';
      cDZL_DocQueue_ID = 'B200000101'; //řada dokladu DZV   //1E00000101
      cVATRate_ID = '02100X0000';  //21% DPH

Function CreateDocDZL(AZL:TNxCustomBusinessObject; mAMount: double; mOP_ID: string; ADate: Double):string;
var mManager : TNxDocumentImportManager ;
  mParams : TNxParameters;
  mRow, mRow_OP, mOP, mUsage : TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mDate: TDateTime;
  mRowText, mVatRate_ID, mUsageID, mQuery, mAccID : string;
  mList : TStringList;
begin
  result := '';
  mManager := NxCreateDocumentImportManager(AZL.ObjectSpace,Class_IssuedDepositInvoice,Class_VATIssuedDepositInvoice);
  mOP := AZL.ObjectSpace.CreateObject(Class_ReceivedOrder);
  mParams := TNxParameters.Create();
  //mList := tStringlist.create;
  try
    if not NxIsEmptyOID(mOP_ID) then begin
      //potrebujeme radek objednávky
      mOP.Load(mOP_ID,nil);
      mRows_OP := mOP.GetLoadedCollectionMonikerForFieldCode(mOP.GetFieldCode('Rows'));
      mRow_OP := mRows_OP.BusinessObject[0];
      mVatRate_ID := mRow_OP.GetFieldValueAsString('VATRate_ID');
    end else begin //jinak to vememe z řádku ZL
      mRows_OP := AZL.GetLoadedCollectionMonikerForFieldCode(AZL.GetFieldCode('Rows'));
      mRow_OP := mRows_OP.BusinessObject[0];
      mVatRate_ID := cVATRate_ID;
    end;

    mManager.AddInputDocument(AZL.OID);
    mParams.GetOrCreateParam(dtFloat, 'DepositAmount').AsFloat := mAmount;
    mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cDZL_DocQueue_ID;
    mParams.GetOrCreateParam(dtDateTime, 'VatDate').AsdateTime := mDate;
    mDate := ADate;
    mManager.LoadParams(mParams);
    mManager.Execute;
    mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('AccDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('VATDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsBoolean('PricesWithVAT', True);
    //mManager.OutputDocument.SetFieldValueAsString('X_ContractNumber', mOP.GetFieldValueAsString('X_ContractNumber'));
    mManager.OutputDocument.SetFieldValueAsString('Description', NxLeft('Zúčtování '+AZL.DisplayName, 50));
    //JIPE doplněno dohledání období
     mManager.OutputDocument.SetFieldValueAsString('Period_ID',HledejID('ID','periods',
        'datefrom$date<=' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date'))
         + ' and dateto$date > ' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date')),'OID','',AZL.ObjectSpace));

    mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
    mRow := mRows.AddNewObject;
    mRow.Prefill;
    mRow.SetFieldValueAsInteger('RowType',4);
    mRow.SetFieldValueAsString('Division_ID',mRow_OP.GetFieldValueAsString('Division_ID'));
    mRow.SetFieldValueAsString('VATRate_ID',mVatRate_ID);
    mRowText := cRowtext + AZL.GetFieldValueAsString('DisplayName');
    mRow.SetFieldValueAsString('Text',mRowText);
    mRow.SetFieldValueAsFloat('PaymentAmount',mAmount);
    mManager.OutputDocument.Save;
    Result := mManager.OutputDocument.OID;

    // FINE: úprava data zúčtování - nechtějí aktuální den, ale stejné datum jako zdanění
    mUsageID := HledejID('ID', 'IssuedDepositUsages', 'DepositDocument_ID = '+QuotedStr(AZL.OID)+' AND PDocument_ID = '+QuotedStr(mManager.OutputDocument.OID), '', '', AZL.ObjectSpace);
    if (not NxIsEmptyOID(mUsageID)) then begin
      mUsage := AZL.ObjectSpace.CreateObject(Class_IssuedDepositUsage);
      try
        mUsage.Load(mUsageID, nil);
        mUsage.SetFieldValueAsDateTime('PaymentDate$DATE', mDate);
        mUsage.SetFieldValueAsDateTime('AccDate$DATE', mDate);
        mUsage.Save;
      finally
        mUsage.Free;
      end;
      // doklad zúčtování musíme ručně přeúčtovat
      mList := tStringlist.create;
      try
        mList.Add(mUsageID);
        //CFxAccounting.ReAccount(Class_IssuedDepositUsage, mList);
      finally
        mList.Free;
      end;

    end;

  finally
    mManager.Free;
    mOP.Free;
    mParams.free;
    //mList.Free;
  end;
end;

procedure CreateDZL(Sender: TObject);
var
  mSiteForm : TSiteForm;
  mDBGrid : TDBGrid;
  mList, mDocList, mErrList : tStringList;
  mZL : TNxCustomBusinessObject;
  mAmount, mDate : double;
  i : integer;
  mOP_ID: string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
begin
  try
    if not (Sender is TComponent) then exit;
    mSiteForm := TComponent(Sender).Site;
    if not Assigned(mSiteForm) then exit;
    if not (mSiteForm is TDynSiteForm) then exit;
    mDBGrid := TDBGrid(mSiteForm.FindChildControl('tabList.grdList'));
    if not Assigned(mDBGrid) then exit;
    mList := tStringlist.create;
    try
      mDBGrid.FillListFromSelectedRows_1(mList, false);    //true, aktualni zaznam , false jen oznacene
      if mList.count = 0 then begin
        showmessage('Nebyl vybrán žádný záznam!');
        exit;
      end;
      mDate := Date();
      if 0 = MyShowForm1(mDate) then exit;

      if NxMessageBox('Potvrzení', 'Přejete si zahájit tvorbu "Daňových zálohových listů vydaných" pro označené záznamy?'
      + chr(13) + 'K datu: ' + DateToStr(mDate)
      + chr(13) + ' Pokračovat?',
                  mdConfirm, mdbYesNo, 0, 0, False, Nil) = mrNo then exit;
      mZL := mSiteForm.BaseObjectSpace.CreateObject(Class_IssuedDepositInvoice);
      try
        mDocList := TStringList.Create;
        mErrList := TStringList.Create;
        try
          for i := 0 to mList.Count-1 do begin
            mZL.Load(mList.Strings[i],nil);
            //je na ZL co zúčtovat
            mAmount :=  mZL.GetFieldValueAsFloat('PaidAmount')- mZL.GetFieldValueAsFloat('UsedAmount');
            if mAmount > 0 then begin
              mOP_ID := mZL.GetFieldValueAsString('ReceivedOrder_ID');
              if true then begin //not NxIsEmptyOID(mOP_ID) then begin
                //createDZL
                mDocList.Add(CreateDocDZL(mZL,mAmount, mOP_ID, mDate));
              end
              else begin
                //není vytvořeno z OP
              end;
            end
            else begin
              //není co zúčtovat
            end;
          end;
          if mDocList.Count>0 then begin
            mP := TNxParameters.Create;
            try
              mP.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Právě vytvořené DZL';
              mPar := mP.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; //DoNotLocalize
              mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ; //DoNotLocalize
              mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ; //DoNotLocalize
              mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
              mPar.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mDocList) ; //DoNotLocalize
              ShowDynForm(cDZL_Agenda, NxCreateContext_1(mZL), mP, nil, false);
            finally
              mP.Free;
            end;
          end
          else begin
            showmessage('Nevytvořen žádný DZL');
          end;
        finally
          mDocList.Free;
          mErrList.Free;
        end;
      finally
        mZL.Free;
      end;
    finally
      mList.Free;
    end;
  except
    ShowMessage(ExceptionMessage);
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvoř DZL';
  mAction.Hint := 'Z označených záznamů vytvoří hromadně  "Daňový zálohový list vydaný" dle pravidel';
  mAction.Category := 'tabList'; //jen na seznamu
  mAction.OnExecute := @CreateDZL;
 end;

function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL, AResult: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0]
    else
      Result := AResult;
  finally
    mSQLRes.Free;
  end;
end;

function MyShowForm1(var ADate: Double):integer;
var
  mForm: TForm;
  mLab: TLabel;
  mResult: integer;
  mButt1,mButt2: TButton;
  mLeft,mWidth,mSkip,mTopStart:integer;
  mDateEdit : TDateEdit ;
begin
  mForm := TForm.Create(Nil);
  try
    mLeft := 10;
    mWidth := 110;
    mSkip := 35;
    mTopStart := 10 ;
    mForm.Caption := 'ABRA G3 ® - Zvolte datum???';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Position := poDesktopCenter;
    mForm.Width := 300;
    mForm.Height := 150;
    mForm.Scaled := False;

    mLab:= TLabel.Create(mForm);
    mLab.Caption := 'Zúčtovat k:';
    mLab.Left := mLeft + 20;
    mLab.Top := mTopStart + 2  ;
    mLab.Width := mWidth;
    mLab.Parent := mForm;

    mDateEdit:= TDateEdit.Create(mForm);
    mDateEdit.Left := mLab.Left + mLab.Width ;
    mDateEdit.Top := mTopStart;
    mDateEdit.Width := mWidth;
    mDateEdit.Date:= ADate;
    //mDateEdit.DecimalPlaces := 0;
    mDateEdit.Parent := mForm;

    mButt1 := CreateButton(mForm, mForm, mLab.Top+2*mSkip, mLeft, 70, 25, 'Pokračovat', 1);
    mButt2 := CreateButton(mForm, mForm, mLab.Top+2*mSkip, mLeft + mLab.Width, 70, 25, 'Přerušit', 2);
    mResult := mForm.ShowModal(nil);
    //Result := mDateEdit.date;

    if mResult = 1 then begin
      Result := mresult ;
      ADate := mDateEdit.date;
    end
    else begin
      Result := 0;
    end;
  finally

    mForm.Free;
  end;
end;

function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;

Function HledejID(What,Where,When,Alias,Res:string;mOS:TNxCustomObjectSpace):string;
 var
  mResult:TStrings;
  mSQL:String;
 begin
   try
     mResult := TStringList.Create;
     mSQL := 'Select '+ What +' from '+ Where + ' Where '+ When;
      //ShowMessage(mSQL);
      mOS.SQLSelect(mSQL, mResult);
      if (mResult.Count > 0) then begin
        Result:=mResult.Strings[0] ;
      end
      else begin
        Result:=Res;
      end;
    finally
      mResult := Nil;
    end;
 end;

begin
end.