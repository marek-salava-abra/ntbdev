
Function SendInternalMail(var AOS:TNxCustomObjectSpace;var AEmailAccount_ID, ATo, ACC, ABCC, ASubject, ABody, AAtachement, AFirm_ID, ADivision_ID, ABusOrder_ID, AReplyTo, aDocumentID:string;
                          var aType:integer):string;
Var
  mMailBO,mUserXLink,mMailRecipient:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
begin
  Result:='';
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject(Class_EmailSent);
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',AEmailAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);
     end;




     mMailBO.Save;
     Result:=mMailBO.DisplayName;
     if not(NxIsEmptyOID(aDocumentID)) then begin
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        if aType=1 then mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedInvoice);
        if aType=2 then mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        if aType=3 then mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedCreditNote);
        if aType=4 then mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOffer);
        if aType=5 then mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedDepositInvoice);
        if aType=6 then mUserXLink.SetFieldValueAsString('SourceCLSID', Class_BillOfDelivery);
        mUserXLink.SetFieldValueAsString('Source_ID', aDocumentID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
    end else begin
     mMailBO.free;
    end;
  end;
end;


function mShouldRun(mInvoicingType: Integer; mFriday, m15, mlastDay: Boolean): Boolean;
begin
  case mInvoicingType of
    1: Result := (m15 or mlastDay);   // 15. den v měsíci nebo poslední den
    2: Result := mFriday;           // každý pátek
    3: Result := mlastDay;          // poslední den v měsíci
  else
    Result := False;                 // defaultně nic
  end;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetDocumentIDFromDisplayName(AOS: TNxCustomObjectSpace; ADocumentNumber, ATableName: string;): string;
var
  mParams: TNxParameters;
  mDashPos, mSlashPos: Integer;
  mSQL, mTableName: String;
  mList: TStringList;
begin
  Result:= '';
  if Pos('/', ADocumentNumber) = 0 then exit;

  mDashPos:= Pos('-', ADocumentNumber);
  mSlashPos:= Pos('/', ADocumentNumber);

  mList:= TStringList.Create;
  mParams:= TNxParameters.Create;
  try
    //mParams.GetOrCreateParam(dtString, 'TableName').AsString:= 'ReceivedOrders';
    mParams.GetOrCreateParam(dtString, 'DocQueueCode').AsString:= Copy(ADocumentNumber, 1, mDashPos -1);
    mParams.GetOrCreateParam(dtInteger, 'OrdNumber').AsInteger:= StrToInt(Copy(ADocumentNumber, mDashPos + 1, mSlashPos - mDashPos - 1));
    mParams.GetOrCreateParam(dtString, 'PeriodCode').AsString:= Copy(ADocumentNumber, mSlashPos + 1, Length(ADocumentNumber));

    mSQL:=  Format(
            ' SELECT A.ID FROM %s A '+
            ' JOIN DocQueues DQ ON DQ.ID = A.DocQueue_ID '+
            ' JOIN Periods PE ON PE.ID = A.Period_ID '+
            ' WHERE DQ.Code = :DocQueueCode '+
            ' AND A.OrdNumber = :OrdNumber '+
            ' AND PE.Code = :PeriodCode ', [ATableName]);

    AOS.SQLSelect(mSQL, mList, mParams);

    Result:= mList[0];
  finally
    mParams.Free;
    mList.Free;
  end;
end;

Function GetTemplate_ID(var ASite : TSiteform; var aTemplate_ID:String; var aType:integer; var aTO:string):Boolean;
var
    mLabel, mCbCCTemplate: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBTemplate:TRollComboEdit;
    mED:TEdit;
 begin
 if ASite <> nil then begin
    mAllowed:=TStringList.Create;
    ASite.BaseObjectSpace.SQLSelect('Select id from defrolldata where clsid='+QuotedStr(Class_BO_EmailTemplates)+' and X_TemplateType='+IntToStr(aType),mAllowed);
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Info:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    if not(nxisblank(aTO)) then begin
     mLabel := TLabel.Create(mForm);
     mLabel.Parent := mForm;
     mLabel.Caption := 'Target email:';
     mLabel.Top := (mCount*25)+12;
     mLabel.Left := 17;
     mLabel.Height := 13;
     mLabel.Width := 100;
     mLabel.Font.Size := 10;

     mEd := TEdit.Create(mForm);
     mEd.Left := 140;
     mEd.Top := (mCount*25)+10;
     mEd.Width := 300;
     mEd.Text := aTO;
     mEd.Parent := mForm;

     mCount:= mCount+1;

    end;
    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Template:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCTemplate:= TLabel.Create(mForm);
    mCbCCTemplate.Parent:= mForm;
    mCbCCTemplate.Left:= 236;
    mCbCCTemplate.Top:= (mCount*25)+12;
    mCbCCTemplate.Width:= 255;

    mCBTemplate:= TRollComboEdit.Create(mForm);
    mCBTemplate.Parent:= mForm;
    mCBTemplate.ClassID:= Roll_Email_templates;
    mCBTemplate.Complete:= True;
    mCBTemplate.Prefilling:= pmNone;
    mCBTemplate.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBTemplate.Top:= (mCount*25)+10;
    mCBTemplate.Left:= 140;
    mCBTemplate.Width:= 80;
    mCBTemplate.Parameters.Clear;
    mCBTemplate.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    mCBTemplate.ConnectedControl:= mCbCCTemplate;
    mCBTemplate.ConnectedControlField:= 'Code';



    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aTemplate_ID:=mCBTemplate.DataText;
         aTO:=mED.text;
         Result:=True;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;



procedure UsageAllDeposit(AFV_HeaderBO: TNxCustomBusinessObject);
var
  mImportMan: TNxDocumentImportManager;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mZLV_List, mDZLV_List: TStringList;
  mOS: TNxCustomObjectSpace;
  i, x: integer;
  mOPRS_OID, mDZLV_OID, mSQL, mRowOID: string;
  mSumDZLVAmount, mMaxAmount, mDZLVAmount: Extended;

  mIssuedDepositInvoice, mIssuedInvoice, mIssuedDepositUsage, mHeaderBO: TNxCustomBusinessObject;
  mDataset: TMemoryDataset;
  mRecOrder_OID, mZLV_OID: string;
begin
  OutputDebugString('UsageAllDeposit - start');
  // nejdrive dohledam zdrohjovou OP - jen jedna pro jednu FV - musi zde platit
  mOS := AFV_HeaderBO.ObjectSpace;
  mSQL:= 'SELECT DISTINCT B.Provide_ID FROM IssuedInvoices2 A'+
       ' JOIN StoreDocuments2 B on B.ID = A.ProvideRow_ID'+
       ' WHERE A.Parent_ID = ''%s'' AND B.Provide_ID IS NOT NULL';
  mSQL := Format(mSQL, [AFV_HeaderBO.OID]);
  mRecOrder_OID := mOS.SQLSelectFirstAsString(mSQL,'');
  OutputDebugString('UsageAllDeposit - mRecOrder_OID: ' + mRecOrder_OID);
  if not NxIsEmptyOID(mRecOrder_OID) then begin
    mZLV_List := TStringList.Create;
    mDZLV_List := TStringList.Create;
    try
      //mExist_DZLV := False;
      //mSQL := 'select distinct ID from IssuedDInvoices where ReceivedOrder_ID = ''%s'' and Amount - UsedAmount > 0';
      mSQL := 'select distinct ID from IssuedDInvoices where ReceivedOrder_ID = ''%s'''; // jinak by to nefungovalo pro DZLV - je tim uz ZLV vycerpany
      mSQL := Format(mSQL, [mRecOrder_OID]);
      OutputDebugString('UsageAllDeposit - dohledani ZLV mSQL: ' + mSQL);
      mOS.SQLSelect(mSQL, mZLV_List);
      OutputDebugString('UsageAllDeposit - mZLV_List.Text: ' + mZLV_List.Text);
      for i := 0 to mZLV_List.Count - 1 do begin
        mZLV_OID := mZLV_List.Strings[i];
        // pokusim se dohledat pripadne DZLV pripojene k ZLV - pokud DZLV k ZLV najdu, neresim dlae castku daneho ZLV ale jen castku DZLV
        // ZLV se na FV zucotovava (nema vliv na castku FV), pokud je DZLV, tak se castka DZLV od castky FV odecita (DZLV ma vliv na castku FV)
        mSQL := 'select distinct DZLV.ID as DZLV_ID from IssuedDInvoices ZLV ' +
                'join IssuedDepositUsages IDU on IDU.DepositDocument_ID = ZLV.ID ' +
                'join VATIssuedDInvoices DZLV on IDU.PDocument_ID = DZLV.ID ' +
                'where ZLV.ID = ''%s''';
        mSQL := Format(mSQL, [mZLV_OID]);
        mDZLV_List.Clear;
        OutputDebugString('UsageAllDeposit - dohledani DZLV mSQL: ' + mSQL);
        mOS.SQLSelect(mSQL, mDZLV_List);
        OutputDebugString('UsageAllDeposit - mDZLV_List.Text: ' + mDZLV_List.Text);
        if mDZLV_List.Count > 0 then begin
          OutputDebugString('UsageAllDeposit - resim zuctovani ZLV');
          for x := 0 to mDZLV_List.Count - 1 do begin
            mDZLV_OID := mDZLV_List.Strings[x];
            // az zde otestuji, jestli je DZLV cerpatelny, pokud neni, nic nedelam
            mSQL := 'select AmountWithoutVAT - UsedAmountWithoutVAT from VATIssuedDInvoices where ID = ''%s''';
            mSQL := Format(mSQL, [mDZLV_OID]);
            OutputDebugString('UsageAllDeposit - castka DZLV mSQL: ' + mSQL);
            mDZLVAmount := GetFirstFloatRecordFromSQL(mOS, mSQL);
            if mDZLVAmount > 0 then begin
              mMaxAmount := AFV_HeaderBO.GetFieldValueAsFloat('Amount') - AFV_HeaderBO.GetFieldValueAsFloat('RoundingAmount'); // lubi ?? je ok ?
              mSumDZLVAmount := 0;
              mDataset := TMemoryDataset.Create(nil);
              try
                // pro jeden DZLV muzeme zuctovavat vice radek DZLV, po jednom, jinak to nefunguje
                mSQL := 'select (TAmountWithoutVAT - UsedAmountWithoutVAT - CreditAmountWithoutVAT) as SumAmount, ID as RowOID from VATIssuedDInvoices2 where RowType = 4 and Parent_ID = ''%s'' order by PosIndex';
                mSQL := Format(mSQL, [mDZLV_OID]);
                mOS.SQLSelect2(mSQL, mDataset);
                if mDataset.Active then begin
                  mDataset.First;
                  while not mDataset.Eof do begin
                    mDZLVAmount := mDataset.FieldByName('SumAmount').AsFloat;
                    mRowOID := mDataset.FieldByName('RowOID').AsString;
                    if mSumDZLVAmount >= mMaxAmount then begin
                      OutputDebugString('zuctovani DZLV castka je komplet zuctovana dle predpisu FV - vyskakuji');
                      Exit;
                    end;
                    mSumDZLVAmount := mSumDZLVAmount + mDZLVAmount;
                    if mSumDZLVAmount > mMaxAmount then begin
                      mDZLVAmount := mMaxAmount - (mSumDZLVAmount - mDZLVAmount);
                      OutputDebugString('zuctovani DZLV mohu zuctovat jen castecnou castku DZLV, prekrocila by predpis FV: ' + FloatToStr(mDZLVAmount));
                    end
                    else begin
                      OutputDebugString('zuctovani DZLV mohu zuctovat komplet castku radku DZLV: ' + FloatToStr(mDZLVAmount));
                    end;
                    mHeaderBO := mOS.CreateObject(Class_IssuedInvoice);
                    try
                      mHeaderBO.Load(AFV_HeaderBO.OID, nil); // znovunecteni FV kvuli osSaving
                      // pripravim si vstupni parametry pro ImportMana
                      mInputParams := TNxParameters.Create;
                      try
                        OutputDebugString('zuctovani DZLV do nove FV Nastavuji input params importmanageru');
                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                        mParam.AsString := AFV_HeaderBO.GetFieldValueAsString('DocQueue_ID');
                        OutputDebugString('mDZLVImportList.Text neni list: ' + mDZLV_OID);
                        OutputDebugString('DepositAmounts mDZLVAmount: ' + FloatToStr(mDZLVAmount));
                        mParam := mInputParams.GetOrCreateParam(dtString, 'DepositAmounts');
                        mParam.AsString := FloatToStr(mDZLVAmount);
                        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                        mParam.AsString := mRowOID;
                        mImportMan := NxCreateDocumentImportManager(mOS, Class_VATIssuedDepositInvoice, Class_IssuedInvoice);
                        try
                          //mImportMan.AddInputDocuments(mDZLVImportList); nefunguje... takze po jednom..
                          mImportMan.AddInputDocument(mDZLV_OID);
                          mImportMan.OutputDocument := mHeaderBO; // opravuji existujici FV
                          mImportMan.LoadParams(mInputParams);
                          mImportMan.Execute;
                          mImportMan.CheckOutputDocument;
                          OutputDebugString('Zuctovani DZLV do FV Ukladani FV pomoci ImportMana - start');
                          mImportMan.OutputDocument.Save;
                          OutputDebugString('Zuctovani DZLV do FV Ukladani FV pomoci ImportMana - ulozeno ok');
                        finally
                          mImportMan.Free;
                        end;
                      finally
                        mInputParams.Free;
                      end;
                    finally
                      mHeaderBO.Free;
                    end;
                    mDataset.Next;
                  end;
                end;
              finally
                mDataset.Free;
              end;
            end;
          end;
        end
        else begin
          OutputDebugString('UsageAllDeposit - resim zuctovani ZLV');
          mIssuedDepositInvoice := mOS.CreateObject(Class_IssuedDepositInvoice);
          try
            mIssuedDepositInvoice.Load(mZLV_OID, nil);
            mIssuedInvoice := mOS.CreateObject(Class_IssuedInvoice);
            try
              mIssuedInvoice.Load(AFV_HeaderBO.OID, nil);
              if mIssuedDepositInvoice.GetFieldValueAsFloat('Amount') - mIssuedDepositInvoice.GetFieldValueAsFloat('UsedAmount') > 0 then begin
                mIssuedDepositUsage := NxCreateDepositUsage(mIssuedDepositInvoice, mIssuedInvoice);
                try
                  mIssuedDepositUsage.SetFieldValueAsFloat('LocalAmount', mIssuedDepositInvoice.GetFieldValueAsFloat('LocalAmount') - mIssuedDepositInvoice.GetFieldValueAsFloat('LocalUsedAmount'));
                  mIssuedDepositUsage.SetFieldValueAsFloat('Amount', mIssuedDepositInvoice.GetFieldValueAsFloat('Amount') - mIssuedDepositInvoice.GetFieldValueAsFloat('UsedAmount'));
                  mIssuedDepositUsage.Save;
                  OutputDebugString('UsageAllDeposit - zuctovani ZLV ulozeno');
                finally
                  mIssuedDepositUsage.Free;
                end;
              end
              else
                OutputDebugString('UsageAllDeposit - ZLV nelze zucotvat, je uz plne cerpany');
            finally
              mIssuedInvoice.Free;
            end;
          finally
            mIssuedDepositInvoice.Free;
          end;
        end;
      end;
    finally
      mZLV_List.Free;
      mDZLV_List.Free;
    end;
  end;
end;

function GetFirstFloatRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): Extended;
var
  mDataset: TMemoryDataset;
begin
  Result := 0;
  mDataset := TMemoryDataset.Create(nil);
  try
    AOS.SQLSelect2(ASQL, mDataset);
    if mDataset.Active then begin
      mDataset.First;
      Result := mDataset.FieldList.Fields[0].AsFloat;
    end;
  finally
    mDataset.Free;
  end;
end;

begin
end.