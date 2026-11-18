 uses  '_Knihovny_ALL.Progress';
    //  '_Knihovny_ALL.Parse';

var   mvalue:TStringList;



function Import_Doc(OS: TNxCustomObjectSpace;msite:TSiteForm;rucne:boolean;chyba:boolean;index:integer;mDocQueue_ID:string) : Boolean;
var
    mImportFile:TStringList;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  i ,ii: integer;
  opakovani:integer;
  mTabList: TTabSheet;
  mDataset: TNxRowsObjectDataSet;
  mStorecard_ID,mBatch_ID,mFirm_ID:string;
  mList:tstringlist;
  mQuantity:double;
  iRow,iBatch:Integer;
  mRSql:tstringlist;
  mWorkList:Tstringlist;
  mXMLHead : TNxScriptingXMLWrapper;
  mfieldValue,mr:tstringlist;
  mOutputdocument:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  _ss:Variant;
  mstring:string;
  Pocet_zaznamu:integer;
  mParams, mParams1 : TNxParameters;
  mPar,mPar1 : TNxParameter;
  mManager,mManager1 : TNxDocumentImportManager ;
  mValidateList:tstringlist;
  mText,mFilter:string;
  mx:tstringlist;
  mboolean:boolean;
  mIWork,mIOther,mICelkem:integer;
  mSDoklad:string;
  mSresult:string;
  mBOSource:TNxCustomBusinessObject;
  mIInput,mIOutput:integer;
  mBO_InputRows,mBO_OutputRows:TNxCustomBusinessMonikerCollection;
begin
    mIWork:=0;
    mIOther:=0;
    mICelkem:=0;
    mSDoklad:='';
    mWorkList:=tstringlist.create;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    if mBookmark.count=0 then Pocet_zaznamu:=1;
    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count;
         if mBookmark.Count = 0 then begin
            opakovani:=mBookmark.Count;
            //acode:= mBO.GetFieldValueAsString('id');
        end;
        ProgressInit(msite, 'Načtení dat ' , 100);
        if mBookmark.Count >0 then opakovani:=mBookmark.Count-1;

        for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
            if mBookmark.Count > 0 then begin
                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                ProgressSetPos(1+NxFloor(((i+1)/opakovani)*99), inttostr(i+1) +' z '+inttostr(opakovani+1));
            end;;

                      mr:=tstringlist.create;
                      mx:=tstringlist.create;
                      try
                            // msite.BaseObjectSpace.SQLSelect('Select distinct(sd.ID) from Receivedorders2 ro2 join Receivedorders RO on RO.id=ro2.Parent_ID join storedocuments2 SD2 on (sd2.ProvideRow_ID=ro2.id) join storedocuments SD on ((sd.id=sd2.Parent_ID) and (sd.Documenttype=' + QuotedStr('21') + '))'
                            msite.BaseObjectSpace.SQLSelect('Select distinct(ro.ID) from Receivedorders2 ro2 join Receivedorders RO on RO.id=ro2.Parent_ID join storedocuments2 SD2 on (sd2.ProvideRow_ID=ro2.id) join storedocuments SD on ((sd.id=sd2.Parent_ID) and (sd.Documenttype=' + QuotedStr('21') + '))'
                                                               + ' where (not exists (select 1 from IssuedInvoices2 II2 where ii2.ProvideRow_ID=sd2.id )) and sd.id=' + QuotedStr(TDynSiteForm(msite).CurrentObject.oid)
                                                                , mr);

                             if mr.count>0 then begin
                             mIWork:=mIWork+1;
                              //   NxShowSimpleMessage(mvalue.Strings[3] + ' - ' + mr.Strings[0],nil);

                                    msite.BaseObjectSpace.SQLSelect('Select distinct(RO.ID) from Receivedorders2 ro2 join Receivedorders RO on RO.id=ro2.Parent_ID join storedocuments2 SD2 on (sd2.ProvideRow_ID=ro2.id) join storedocuments SD on ((sd.id=sd2.Parent_ID) and (sd.Documenttype=' + QuotedStr('21') + '))'
                                                               + ' where (not exists (select 1 from IssuedInvoices2 II2 where ii2.ProvideRow_ID=sd2.id )) and sd.id=' + QuotedStr(TDynSiteForm(msite).CurrentObject.oid)
                                                                , mX);

                                            if mx.count>0 then begin
                                                    mBOSource:=msite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                                                    try
                                                          mBOSource.load(mx.Strings[0],nil);
                                                            //  mManager.OutputDocument.SetFieldValueAsInteger('Tradetype',mBOSource.getFieldValueAsInteger('Tradetype'));
                                                            //  mManager.OutputDocument.SetFieldValueAsString('Country_ID',mBOSource.getFieldValueAsstring('Country_ID'));






                                        mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','O3BDOKTWEFD13ACM03KIU0CLP4');   // op to fv
                                 //    dl-FV    mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'050I5SAOS3DL3ACU03KIU0CLP4','O3BDOKTWEFD13ACM03KIU0CLP4');   // op to fv

                                        mParams := TNxParameters.Create();
                                        try
                                          mManager.AddInputDocument(mr.Strings[0]);
                                          mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;
                                          mParams.GetOrCreateParam(dtString, 'Currency_ID').AsString := mBOSource.GetFieldValueAsString('Currency_ID');
                                          mManager.LoadParams(mParams);

                                          //if mManager.CheckOutputDocument then begin;

                                                              mManager.Execute;
                                                              mManager.OutputDocument.SetFieldValueAsBoolean('PricesWithVAT',mManager.InputDocument.GetFieldValueAsBoolean('PricesWithVAT'));

                                                              //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$date',mManager.InputDocument.GetFieldValueAsDateTime('DocDate$date'));
                                                              //mManager.OutputDocument.SetFieldValueAsString('Period_ID',mManager.InputDocument.GetFieldValueAsString('Period_ID'));


                                                              mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                                                              mManager.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mManager.InputDocument.GetFieldValueAsString('FirmOffice_ID'));
                                                              mManager.OutputDocument.SetFieldValueAsString('Person_ID',mManager.InputDocument.GetFieldValueAsString('Person_ID'));

                                                              mManager.OutputDocument.SetFieldValueAsString('BankAccount_ID',mManager.InputDocument.getFieldValueAsstring('BankAccount_ID'));
                                                              mManager.OutputDocument.SetFieldValueAsString('Currency_ID',mManager.InputDocument.getFieldValueAsstring('Currency_ID'));

                                                              mManager.OutputDocument.SetFieldValueAsInteger('Tradetype',mManager.InputDocument.getFieldValueAsInteger('Tradetype'));
                                                              mManager.OutputDocument.SetFieldValueAsString('Country_ID',mManager.InputDocument.getFieldValueAsstring('Country_ID'));

                                                              mManager.OutputDocument.SetFieldValueAsString('PaymentType_ID',mManager.InputDocument.getFieldValueAsstring('PaymentType_ID'));
                                                              mManager.OutputDocument.SetFieldValueAsString('TransportationType_ID',mManager.InputDocument.getFieldValueAsstring('TransportationType_ID'));
                                                              mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.getFieldValueAsstring('Description'));
                                                              mManager.OutputDocument.SetFieldValueAsString('X_Delivery_adress_id',mManager.InputDocument.getFieldValueAsstring('X_Delivery_adress_id'));




                                                               if mDocQueue_ID='2F10000101' then begin
                                                                          mManager.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID',mBOSource.getFieldValueAsString('IntrastatDeliveryTerm_ID'));  ;
                                                                          mManager.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID',mBOSource.getFieldValueAsString('IntrastatTransactionType_ID'))  ;
                                                                          mManager.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID',mBOSource.getFieldValueAsString('IntrastatTransportationType_ID'))  ;

                                                                         {

                                                                          if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID')) then begin
                                                                              mManager.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'))  ;
                                                                          end else begin
                                                                              mManager.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                                                          end;

                                                                          if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType')) then begin
                                                                              mManager.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'))  ;
                                                                          end else begin
                                                                              mManager.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID','1101000000')  ;
                                                                          end;

                                                                          if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_')) then begin
                                                                              mManager.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'))  ;
                                                                          end else begin
                                                                              mManager.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                                                          end;    }
                                                                 end;









                                                              mBO_InputRows:=mManager.InputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.InputDocument.GetFieldCode('Rows'));
                                                              mBO_OutputRows:=mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));

                                                              for mIOutput:=0 to mBO_OutputRows.count-1 do begin

                                                                  for mIInput:=0 to mBO_OutputRows.count-1 do begin

                                                                      if  mBO_OutputRows.BusinessObject[mIOutput].GetFieldValueAsString('Storecard_ID') =  mBO_InputRows.BusinessObject[mIInput].GetFieldValueAsString('Storecard_ID') then begin
                                                                             mBO_OutputRows.BusinessObject[mIOutput].setFieldValueAsFloat('Unitprice',mBO_InputRows.BusinessObject[mIInput].GetFieldValueAsFloat('Unitprice'));
                                                                      end;

                                                                  end;




                                                              end;
                                                              if NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('PaymentType_ID')) then begin
                                                                 mManager.OutputDocument.setFieldValueAsString('PaymentType_ID',mBOSource.getFieldValueAsString('PaymentType_ID'));
                                                              end;

                                                              if NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('TransportationType_ID')) then begin
                                                                 mManager.OutputDocument.setFieldValueAsString('TransportationType_ID',mBOSource.getFieldValueAsString('TransportationType_ID'));
                                                              end;

                                                              //NxShowSimpleMessage(mManager.InputDocument.getFieldValueAsstring('Currency_ID'),nil);
                                                              mManager.OutputDocument.SetFieldValueAsString('Currency_ID',mManager.InputDocument.getFieldValueAsstring('Currency_ID'));

                                                                       mManager.OutputDocument.ClearValidateErrors;
                                                                                          if Not mManager.OutputDocument.Validate() then begin
                                                                                                mValidateList := TStringList.Create;
                                                                                                try
                                                                                                   mManager.OutputDocument.GetValidateErrors(mValidateList);
                                                                                                   mText := mValidateList.Text;
                                                                                                   NxToken(mText, '=');
                                                                                                   MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                                                   mtWarning, [mbOK], 0);
                                                                                                 finally
                                                                                                   mValidateList.Free;
                                                                                                 end;
                                                                                                 //NxShowSimpleMessage('Chyba',nil);

                                                                                                 TDynSiteForm(mSite).ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // fv

                                                                                          end else begin
                                                                                              mManager.OutputDocument.SetFieldValueAsString('Currency_ID',mBOSource.getFieldValueAsstring('Currency_ID'));
                                                                                              mManager.OutputDocument.Save;
                                                                                              mSDoklad:=mSDoklad + chr(10) + mManager.OutputDocument.DisplayName + ',' ;
                                                                                              mWorkList.Add(mManager.OutputDocument.oid);
                                                                                              UsageAllDeposit(mManager.OutputDocument);

                                                                                          end;

                                                      finally
                                                           mBOSource.free;
                                                      end;




                                          mx.free;

                                         finally
                                          mManager.Free;
                                          mParams.free;
                                         end;


                             end else begin
                                 mIOther:=mIOther+1;
                             end;
                             end;
                      finally
                          mr.free;
                      end;

             TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;

        end;
        ProgressDispose();
                                                    if mWorkList.count>0 then begin

                                                         mFilter:= '';
                                                         for i:= 0 to mWorkList.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mWorkList[i]]);
                                                            if i = mWorkList.Count-1  then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                            end;
                                                          end;
                                                          //if mIWork>0 then begin
                                                               //msite.ShowSite('PLC2EX0BUJD13ACP03KIU0CLP4',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                               mSresult:='';
                                                               if (opakovani+1)>0 then mSresult:=mSresult + 'Z ' + IntToStr(opakovani+1) ;
                                                               if mIWork>0 then  mSresult:=mSresult + ' bylo vytvořeno ' + IntToStr(mIWork) +' dokladů.';
                                                               if mIOther>0 then mSresult:=mSresult + chr(10) + '(' +inttostr(mIOther) + ' již bylo vytvořeno dříve.)';


                                                           //end;
                                                    end else begin
                                                        NxShowSimpleMessage('Po importu nebyly vytvořeny žádné faktury',nil);
                                                    end;



     msite.Refresh;

end;

















procedure FormCreate_Hook(Self: TSiteForm);
var
mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  mAct: TBasicAction;
  i:integer;
begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Vystav faktury ';
          mMAction.Caption := 'FVT - Vytvoření faktur podle podkladu ';
          mMAction.Items.Add('FVT - Vystavení faktur podle DL');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @ImportFVTOnExec;

          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Vystav faktury ';
          mMAction.Caption := 'FVE - Vytvoření faktur podle podkladu ';
          mMAction.Items.Add('FVE - Vystavení faktur podle DL');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @ImportFVEOnExec;



end;



procedure ImportFVEOnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  msite:TSiteForm;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
      if false then begin
     // if not TDynSiteForm(mSite).Edit then begin
     //   ShowMessage('Akce importu je přístupná jen v editaci dokladu.');
     //   Exit;
      end else begin
               if index=0 then  begin
                   mresult:=Import_Doc(msite.baseobjectspace,msite,false,false,index,'2F10000101');
               end;
        end;
end;

procedure ImportFVTOnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  msite:TSiteForm;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
      if false then begin
     // if not TDynSiteForm(mSite).Edit then begin
     //   ShowMessage('Akce importu je přístupná jen v editaci dokladu.');
     //   Exit;
      end else begin
               if index=0 then  begin
                   mresult:=Import_Doc(msite.baseobjectspace,msite,false,false,index,'O200000101');
               end;
        end;
end;





{
Vyvoláva sa po načítaní vlastností formulára.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

function FNParsevalue(AData : string; ASeparator: string):tstringlist;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mList:tstringlist;
    ahead:tstringlist;
begin
    ahead:=tstringlist.create;

    mStr := AData;
    try
        while AnsiPos(ASeparator,mStr)>0 do  begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                ahead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);

        end;
        ahead.Add(mStr);


   finally

   end;

   result:=ahead;
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
            mDZLVAmount := mOS.SQLSelectFirstAsExtended(mSQL,0);
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






begin
end.