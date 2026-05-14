uses 'abra.eu.simonasdf.zalohy';

function GetFirm_ID(AOS : TNxCustomObjectSpace; aValue : string) : String;
const
  cSQL = 'select d.x_firm_id from defrolldata d left join defrolldata d2 on d2.id=d.x_vip_card_id where d2.x_cardnumber = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

procedure CreateNewService(Sender: TObject);
var
 msite: TSiteForm;
 mZaruka, mRukojet, mKryt, mMatice, mKotouc, mKlic, mNabijecka, mKabel, mKufr, mAkumulator, mPilovyList, mZarucniList, mSklicidlo, mDialog, mZaloha, mKarta: Boolean;
 mFirm_id:string;
 mSerialNumber:string;
 mStoreCardCode:string;
 mStoreCardName:string;
 mCatalogNumber: String;
 mServiceNumber:string;
 mStoreCard_ID:string;
 mPerson_ID:string;
 mFirmRepair_ID:string;
 mDescription: String;
 mAddDescription: String;
 mDocuments: String;
 mFV_ID: string;
 mActivity_OID, mCashReceived_OID:String;
 mActivity, mStoreCardBO, mReceiptCardBO, mReceiptCardROWBO, mRelation, mServiceFirm, mFirm: TNxCustomBusinessObject;
 mPPZ, mPPZRows: TNxCustomBusinessObject;
 mOS: TNxCustomObjectSpace;
 mRows: TNxCustomBusinessMonikerCollection;
 mStringList, mListPPZ, mListFV :TStringList;
 mMainUnitCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;
  i : integer;
  mUnit : TNxCustomBusinessObject;
  mEAN : string;
 mZalohaFloat : extended;
 mZalohaPPZ_ID, mZalohaFV_id, mActivityNumber: String;
 mPPZBO, mFVBO:TNxCustomBusinessObject;
 mOdpovednaosoba_ID, mVipCard, mDivision_ID:String;

begin
    mSite := TComponent(Sender).DynSite;
    mOs:=msite.CompanyObjectSpace;
    mStoreCard_ID:='';
    mZalohaPPZ_ID:='';
    mZalohaFV_id:='';
    mZalohaFloat:=0;
    mVipCard:='';
    mFirm_id:='';
    mDivision_ID:='';
    mListPPZ:= TStringList.Create;
    mListFV:=TStringList.create;
    NewServiceData(msite,mFirm_id, mPerson_ID, mStoreCard_ID,mFirmRepair_ID, mDescription, mStoreCardCode, mStoreCardName,mSerialNumber,
                   mCatalogNumber, mServiceNumber, mZaruka, mRukojet, mKryt, mMatice, mKotouc, mKlic, mNabijecka, mKabel, mKufr, mAkumulator, mPilovyList, mZarucniList, mSklicidlo, mDialog, mAddDescription, mDocuments, mFV_ID, mZaloha, mKarta, mOdpovednaosoba_ID, mVipCard);
    if not(mDialog) then begin
        NxShowMessage('Info','Ruším založení aktivity', mdWarning,false,msite);
       exit;
    end;
    if not(NxIsEmptyOID(mFirmRepair_ID)) and mZaloha then begin
        mServiceFirm:=mos.CreateObject(Class_Firm);
        mServiceFirm.load(mFirmRepair_ID,nil);
        mZalohaFloat:=mServiceFirm.GetFieldValueAsFloat('U_zaloha_oprava');
    end;
    
    if not(NxIsBlank(mStoreCard_ID)) then begin
      mStoreCardBO:=mos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
      mStoreCardBO.Load(mStoreCard_ID,nil);
      mSerialNumber:=mStoreCardBO.GetFieldValueAsString('Specification2');
      mStoreCardBO.Free;
    end;

   // NxShowSimpleMessage(FloatToStr(mZalohaFloat)+' '+mServiceFirm.DisplayName+' '+NxGetActualUserID(mos)+' '
   //          +BoolToStr(mZaloha,true)+' '+BoolToStr(mKarta,true),msite);
    
    mActivity:=mOS.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
    mActivity.New;
    mActivity.Prefill;
    mActivity.SetFieldValueAsString('ActivityArea_ID','1000000101');
    mActivity.SetFieldValueAsString('ActivityType_ID','1000000101');
    if ((NxGetActualUserID(mOS)='1G10000101')
    or (NxGetActualUserID(mOS)='2R10000101')
    or (NxGetActualUserID(mOS)='1W00000101')
    or (NxGetActualUserID(mOS)='2F10000101')
    or (NxGetActualUserID(mOS)='1610000101')
    or (NxGetActualUserID(mOS)='3I00000101')
    //or (NxGetActualUserID(mOS)='2420000101')
    or (NxGetActualUserID(mOS)='2000000101')
    or (NxGetActualUserID(mOS)='3E20000101')
    or (NxGetActualUserID(mOS)='SUPER00000')
    or (NxGetActualUserID(mOS)='3E80000101')
    or (NxGetActualUserID(mOS)='3EA0000101')
    or (NxGetActualUserID(mOS)='5EM0000101')) then begin

     mActivity.SetFieldValueAsString('ActQueue_ID','3000000101');
     mActivity.SetFieldValueAsString('Division_ID','5100000101');
    end;
    if not((NxGetActualUserID(mOS)='1G10000101')
        or (NxGetActualUserID(mOS)='3EA0000101')
        or (NxGetActualUserID(mOS)='3E80000101')
        or (NxGetActualUserID(mOS)='3E20000101')
        or (NxGetActualUserID(mOS)='SUPER00000')
        or (NxGetActualUserID(mOS)='2R10000101')
        or (NxGetActualUserID(mOS)='1W00000101')
        or (NxGetActualUserID(mOS)='2F10000101')
        or (NxGetActualUserID(mOS)='1610000101')
        or (NxGetActualUserID(mOS)='3I00000101')
        or (NxGetActualUserID(mOS)='2B10000101')
        or (NxGetActualUserID(mOS)='2000000101')
        or (NxGetActualUserID(mOS)='5EM0000101')) then begin
     mActivity.SetFieldValueAsString('Division_ID','1100000101');
     mActivity.SetFieldValueAsString('ActQueue_ID','1100000101');
    end;
    if NxGetActualUserID(mOS)='2R10000101' then begin
     mActivity.SetFieldValueAsString('ActQueue_ID','3000000101');
     mActivity.SetFieldValueAsString('Division_ID','5100000101');
    end;
    if NxGetActualUserID(mOS)='2420000101' then begin
     mActivity.SetFieldValueAsString('ActQueue_ID','1100000101');
     mActivity.SetFieldValueAsString('Division_ID','5100000101');
    end;
    if NxGetActualUserID(mOS)='3EA0000101' then begin
     mActivity.SetFieldValueAsString('ActQueue_ID','3000000101');
     mActivity.SetFieldValueAsString('Division_ID','5100000101');
    end;
    if NxGetActualUserID(mOS)='5EM0000101' then begin
     mActivity.SetFieldValueAsString('ActQueue_ID','3000000101');
     mActivity.SetFieldValueAsString('Division_ID','5100000101');
    end;
    if NxGetActualUserID(mOS)='3E80000101' then begin
     mActivity.SetFieldValueAsString('ActQueue_ID','3000000101');
     mActivity.SetFieldValueAsString('Division_ID','5100000101');
    end;
   // NxShowSimpleMessage(NxGetActualUserID(mOS),nil);
    if NxIsEmptyOID(mFirm_id) then mFirm_id:=GetFirm_ID(mos,mVipCard);
    mActivity.SetFieldValueAsString('Firm_ID',mFirm_id);
    mActivity.SetFieldValueAsString('Person_ID',mPerson_ID);

    mActivity.SetFieldValueAsString('BusTransaction_ID','1000000101');
    mActivity.SetFieldValueAsString('SolverRole_ID','1100000101');
    mActivity.SetFieldValueAsString('U_ServiceFirm_ID',mFirmRepair_ID);
    mActivity.SetFieldValueAsString('U_ServiceSerialNumber',mSerialNumber);
    mActivity.SetFieldValueAsString('U_SLdodavatel',mServiceNumber);
    mActivity.SetFieldValueAsString('Description',mDescription);
    mActivity.SetFieldValueAsInteger('Status',1);
    if mZaruka then mActivity.SetFieldValueAsInteger('U_ServiceType',2);
    if not(mZaruka) then mActivity.SetFieldValueAsInteger('U_ServiceType',3);
    mActivity.SetFieldValueAsString('U_AddDescription', mAddDescription);
    mActivity.SetFieldValueAsString('U_documents', mDocuments);
    mactivity.SetFieldValueAsBoolean('U_rukojet',mRukojet);
    mactivity.SetFieldValueAsBoolean('U_kryt',mKryt);
    mactivity.SetFieldValueAsBoolean('U_matice',mMatice);
    mactivity.SetFieldValueAsBoolean('U_kotouc',mKotouc);
    mactivity.SetFieldValueAsBoolean('U_klic',mKlic);
    mactivity.SetFieldValueAsBoolean('U_nabijecka',mNabijecka);
    mactivity.SetFieldValueAsBoolean('U_kabel',mKabel);
    mactivity.SetFieldValueAsBoolean('U_kufr',mKufr);
    mactivity.SetFieldValueAsBoolean('U_akumulator',mAkumulator);
    mactivity.SetFieldValueAsBoolean('U_pilovylist',mPilovyList);
    mactivity.SetFieldValueAsBoolean('U_zarucnilist',mZarucniList);
    mactivity.SetFieldValueAsBoolean('U_sklicidlo',mSklicidlo);
    mActivity.SetFieldValueAsDateTime('U_vychystano',Date);
    mActivity.SetFieldValueAsFloat('U_zaloha',mZalohaFloat);
    //ShowMessage(mOdpovednaosoba_ID);
    mActivity.SetFieldValueAsString('U_odpovednaosoba_ID',mOdpovednaosoba_ID);
    mActivity.Save;
    mActivity_OID:=mActivity.OID;
    mActivityNumber:=mActivity.DisplayName;
    mDivision_ID:=mActivity.GetFieldValueAsString('Division_ID');
    mActivity.free;
    //zaloha ppz
    if (mZalohaFloat>0) and mZaloha and not(mKarta) then begin
       mZalohaPPZ_ID:= CreateDepositPPZ(mos, mFirm_id, mPerson_ID,'Záloha '+mActivityNumber,mZalohaFloat,mActivityNumber,mActivity_OID, mDivision_ID);
       mActivity:=mOS.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
       mActivity.Load(mActivity_OID,nil);
       mPPZBO:=mos.CreateObject(Class_CashReceived);
       if not(NxIsEmptyOID(mZalohaPPZ_ID)) then begin
        mPPZBO.Load(mZalohaPPZ_ID,nil);
        mActivity.SetFieldValueAsString('U_doklad',mppzbo.DisplayName);
       end;
       mActivity.save;
       mActivity.Free;
       mPPZBO.Free;
    end;
    //zaloha fv
    if (mZalohaFloat>0) and mZaloha and mKarta then begin

       mZalohaFV_id:= CreateDepositFV(mos, mFirm_id, mPerson_ID,'Záloha '+mActivityNumber,mZalohaFloat,mActivityNumber,mActivity_OID, mDivision_ID);
       mActivity:=mOS.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
       mActivity.Load(mActivity_OID,nil);
       mFVBO:=mos.CreateObject(Class_IssuedInvoice);
       if not(NxIsEmptyOID(mZalohaFV_id)) then begin
        mFVBO.Load(mZalohafv_ID,nil);
        mActivity.SetFieldValueAsString('U_doklad',mFVBO.DisplayName);
       end;
       mActivity.save;
       mActivity.Free;
       mFVBO.Free;
    end;
    
    
    mActivity:=mOS.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
    mActivity.Load(mActivity_OID,nil);
    
    if NxIsBlank(mStoreCard_ID)then begin
      mStoreCardBO:=mos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
      mStoreCardBO.New;
      mStoreCardBO.Prefill;
      mStoreCardBO.SetFieldValueAsString('Code', mActivity.DisplayName);
      mStoreCardBO.SetFieldValueAsString('Name', mStoreCardName);
      mStoreCardBO.SetFieldValueAsString('Specification2',leftstr(mSerialNumber,30));
      mStoreCardBO.SetFieldValueAsString('Specification',leftstr(mCatalogNumber,30));
      mStoreCardbo.SetFieldValueAsString('StoreCardCategory_ID','3000000101');
      mStoreCardbo.SetFieldValueAsString('VatRate_ID','02100X0000');
      mStoreCardBO.SetFieldValueAsString('StoreMenuItem_ID','1W10000101');
      mStoreCardBO.SetFieldValueAsString('DealerDiscount_ID','1400000101');
      if mStoreCardBO.Getfieldvalueasstring('MainUnitCode')='ks' then begin
          if NxIsBlank( mStoreCardBO.GetFieldValueAsString('EAN')) then begin
            mMainUnitCode := mStoreCardBO.GetFieldValueAsString('MainUnitCode');
            mUnits := mStoreCardBO.GetCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits'));
            for i := 0 to mUnits.count - 1 do begin
              mUnit := mUnits.BusinessObject[i];
              if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
                mEAN := GenIntEAN(mStoreCardBO);
                mUnit.SetFieldValueAsString('EAN', mEAN);

              end;
            end;
          end;
        end;
      mStoreCardBO.Save;
      mStoreCard_ID:=mStoreCardBO.OID;
      mStoreCardBO.Free;

    end;
    mActivity.SetFieldValueAsString('U_ServicedStoreCard_ID', mStoreCard_ID);
    
    mActivity.save;
    
    

    
    
    if NxMessageBox('Dotaz', 'Založil jsem aktivitu '+mActivity.DisplayName+'. Chcete založit doklad PRS?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
     mReceiptCardBO:=mOS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
     mReceiptCardBO.New;
     mReceiptCardBO.Prefill;
     if NxIsEmptyOID(mFirm_id) then mReceiptCardBO.SetFieldValueAsString('Firm_ID','AAA1000000');
     if not(NxIsEmptyOID(mFirm_id)) then mReceiptCardBO.SetFieldValueAsString('Firm_ID',mFirm_id);
     mReceiptCardBO.SetFieldValueAsString('DocQueue_ID','1710000101');
     mReceiptCardBO.SetFieldValueAsString('Person_ID',mPerson_ID);
     mrows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
     mReceiptCardROWBO:=mrows.AddNewObject;
     mReceiptCardROWBO.SetFieldValueAsInteger('RowType',3);
     mReceiptCardROWBO.SetFieldValueAsString('Store_ID','1C00000101');
     mReceiptCardROWBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
     mReceiptCardROWBO.SetFieldValueAsString('Division_ID',mDivision_ID);
     mReceiptCardROWBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
     mReceiptCardROWBO.SetFieldValueAsFloat('Quantity',1);
     mReceiptCardROWBO.SetFieldValueAsFloat('UnitPrice',0);
     mReceiptCardROWBO.SetFieldValueAsFloat('TotalPrice',0);
     mReceiptCardBO.save;
     
     
     mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity.OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mReceiptCardBO.OID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1245);
      mRelation.Save;
     mRelation.free;
    mReceiptCardBO.Free;
    if NxMessageBox('Dotaz', 'Založil jsem aktivitu '+mActivity.DisplayName+'. Chcete ji vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
     if not(NxIsEmptyOID(mActivity_OID)) then begin
        mStringList:=TStringList.Create;
        mStringList.Add(mActivity_OID);
        CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1300000101',rtoPreview,pekPDF,'','');
    end;
    end;
    if not(NxIsEmptyOID(mZalohaPPZ_ID)) then begin
                mListPPZ.Add(mZalohaPPZ_ID);

                CFxReportManager.PrintByIDs(msite.SiteContext,mListPPZ,'0Z4R1NY0FJDL3BLX00C5OG4NF4','3000000101',rtoPreview,pekPDF,'','');
    
    end;
    if not(NxIsEmptyOID(mZalohaFV_id)) then begin
                mListFV.Add(mZalohaFV_id);

                CFxReportManager.PrintByIDs(msite.SiteContext,mListFV,'40SBPEINEFD13ACM03KIU0CLP4','5200000101',rtoPreview,pekPDF,'','');
               mListFV.Free;
    end;
    end;
    //mStringList.Create;
    //mStringList.Add(mActivity.oid);

    //NxPrintByIDs(msite.SiteContext,mStringList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1300000101',rtoPreview,pekPDF,'','');
    RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
    
end;




procedure RefreshDataset(AGrid : TDBGrid);
begin
NxRefreshDataSetWithoutValidate(TNxDataDataSet(AGrid.DataSource.DataSet), true);
end;

function GenIntEAN(ABO : TNxCustomBusinessObject) : string;
var
  mContext: TNxContext;
  mList: TStrings;
  mSQLSelect : string;
  mEAN : string;
  mEANPrefix : string;
  mNumEAN : Longint;
  mEANLen : integer;
  APrefix: string;
const
  cSQL =  'select max(cast(ib_string_left(ean, 12) as varchar(12)) ) from StoreUnits where ean like ''%s_______'' ';
begin
  Result := '';
    APrefix:='200055';
    mSQLSelect := Format(cSQL, [APrefix]);
    mList := TStringList.Create;
    try
      mContext := NxCreateContext_1(ABO);
      try
        mContext.SQLSelect(mSQLSelect, mList);
      finally
        mContext.Free;
      end;
      if (mList.Count > 0) then begin
        mEAN := mList.Strings[0];
        mEAN := Trim(mEAN);
        mEANPrefix := NxLeft(mEAN, 6);
        mEANLen := Length(mEAN);
        mEAN := NxRight(mEAN, mEANLen - 6);
        mNumEAN := StrToInt(mEAN);
        mNumEAN := mNumEAN + 1;
        mEAN := IntToStr(mNumEAN);
        mEAN := NxPadL(mEAN, mEANLen - 6, '0');
        mEAN := mEANPrefix + mEAN;
        NxCorrectEAN13(mEAN);
        Result := mEAN;
      end;
    finally
      mList.Free;
    end;
end;



Function NewServiceData(asite:tsiteform;var aFirm_id:string;var aPerson_id:string; var aStoreCard_ID:string; var aFirmService_ID:string; var aMemo:String;
                        var aStorecardCode:string; var aStoreCardName:string; var aStoreCardSpecification2:string; var aStoreCardCat:String; var aDodSL:string;
                        var aZaruka:Boolean; var aRukojet:boolean; var aKryt:boolean; var aMatice:Boolean; var aKotouc:Boolean; var aKlic:Boolean;
                        var aNabijecka:boolean; var aKabel:boolean; var aKufr:Boolean; var aAkumulator:Boolean; var aPilovyList:Boolean;
                        var aZarucnilist:Boolean; var aSklicidlo:Boolean; var aDialog:Boolean; var aAddDescription: string; var aDocuments:string;
                        var aFV_ID:string; var aZaloha:Boolean; var aKarta:Boolean; var AOdpovednaOsoba, aVipCard:String):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmRepair, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9, mEd10 : TEdit;
    mEd6, mEd7: TMemo;
    mBEd01, mBEd02, mBEd03, mBEd04, mBEd05,mBEd06, mBEd07, mBEd08, mBEd09, mBEd10, mBEd11, mBEd12, mBEd13, mBEd14, mBEd15: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 590;
    mForm.Caption := 'Zadejte údaje pro servis';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 15;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 15;
    mCbFirm.Left:= 107;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'VIP Karta';
    mLabel3.Top := 37;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd10 := TEdit.Create(mForm);
    mEd10.Left := 107;
    mEd10.Top := 35;
    mEd10.Width := 200;
    mEd10.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Osoba:';
    mLabel3.Top := 57;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcPerson:= Tlabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 55;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'K1MQ4TFKGJD13E3C01K0LEIOE0';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'LastName';  // položka podle které se bude vyhledávat
    mCbPerson.Top:= 55;
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'LastAndFirstName';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sér. číslo:';
    mLabel3.Top := 79;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcStoreCard:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStoreCard.Parent:= mForm;
    //mCbCcStoreCard.BevelOuter:= bvLowered;
    mCbCcStoreCard.Left:= 228;
    mCbCcStoreCard.Top:= 55;
    mCbCcStoreCard.Width:= 255;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;

    mCbStoreCard.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard.Complete:= True;
    mCbStoreCard.ForcedField:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Specification2';  // položka podle které se bude vyhledávat
    mCbStoreCard.Top:= 77;
    mCbStoreCard.Left:= 107;
    mCbStoreCard.Width:= 108;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'SN textově:';
    mLabel3.Top := 97;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 107;
    mEd1.Top := 99;
    mEd1.Width := 380;
    mEd1.Text := '';
    mEd1.Parent := mForm;
    {
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Kód karty';
    mLabel3.Top := 101;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd2 := TEdit.Create(mForm);
    mEd2.Left := 107;
    mEd2.Top := 97;
    mEd2.Width := 200;
    mEd2.Text := 'Nevyplňovat...';
    mEd2.Parent := mForm; }

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Název karty';
    mLabel3.Top := 123;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd3 := TEdit.Create(mForm);
    mEd3.Left := 107;
    mEd3.Top := 117;
    mEd3.Width := 380;
    mEd3.Text := '';
    mEd3.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Katalog. číslo';
    mLabel3.Top := 145;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd4 := TEdit.Create(mForm);
    mEd4.Left := 107;
    mEd4.Top := 137;
    mEd4.Width := 380;
    mEd4.Text := '';
    mEd4.Parent := mForm;

    {mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Číslo SL dodav.';
    mLabel3.Top := 167;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd5 := TEdit.Create(mForm);
    mEd5.Left := 107;
    mEd5.Top := 159;
    mEd5.Width := 200;
    mEd5.Text := '';
    mEd5.Parent := mForm;}

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Popis';
    mLabel3.Top := 189;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd6 := TMemo.Create(mForm);
    mEd6.Left := 107;
    mEd6.Top := 185;
    mEd6.Width := 380;
    med6.Height:= 60;
    mEd6.Text := '';
    mEd6.Parent := mForm;

    mBEd01:= TCheckBox.Create(mForm);
    mBEd01.Left := 17;
    mBEd01.Top := 251;
    mBEd01.Caption :='Záruční oprava';
    mBEd01.Checked := False;
    mBEd01.Parent := mForm;

    ///// Firma Oprava
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Opravář:';
    mLabel3.Top := 273;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirmRepair:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirmRepair.Parent:= mForm;
    //mCbCcFirmRepair.BevelOuter:= bvLowered;
    mCbCcFirmRepair.Left:= 228;
    mCbCcFirmRepair.Top:= 271;
    mCbCcFirmRepair.Width:= 255;

    mCbFirmRepair:= TRollComboEdit.Create(mForm);
    mCbFirmRepair.Parent:= mForm;

    mCbFirmRepair.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirmRepair.Complete:= True;
    mCbFirmRepair.ForcedField:= True;
    mCbFirmRepair.Prefilling:= pmNone;
    mCbFirmRepair.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirmRepair.Top:= 271;
    mCbFirmRepair.Left:= 107;
    mCbFirmRepair.Width:= 108;
    mCbFirmRepair.ConnectedControl:= mCbCcFirmRepair;
    mCbFirmRepair.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru


    ///// Konec firma orpava


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Příslušenství dodávané s nářadím';
    mLabel3.Top := 300;
    mLabel3.Left := 17;

    mBEd02:= TCheckBox.Create(mForm);
    mBEd02.Left := 17;
    mBEd02.Top := 313;
    mBEd02.Caption := 'Rukojeť';
    mBEd02.Checked := False;
    mBEd02.Parent := mForm;

    mBEd03:= TCheckBox.Create(mForm);
    mBEd03.Left := 17;
    mBEd03.Top := 333;
    mBEd03.Caption := 'Kryt';
    mBEd03.Checked := False;
    mBEd03.Parent := mForm;

    mBEd04:= TCheckBox.Create(mForm);
    mBEd04.Left := 17;
    mBEd04.Top := 353;
    mBEd04.Caption := 'Matice';
    mBEd04.Checked := False;
    mBEd04.Parent := mForm;

    mBEd05:= TCheckBox.Create(mForm);
    mBEd05.Left := 17;
    mBEd05.Top := 373;
    mBEd05.Caption := 'Kotouč';
    mBEd05.Checked := False;
    mBEd05.Parent := mForm;

    mBEd06:= TCheckBox.Create(mForm);
    mBEd06.Left := 17;
    mBEd06.Top := 393;
    mBEd06.Caption:='Klíč';
    mBEd06.Checked := False;
    mBEd06.Parent := mForm;

    mBEd07:= TCheckBox.Create(mForm);
    mBEd07.Left := 17;
    mBEd07.Top := 413;
    mBED07.Caption:='Nabíječka';
    mBEd07.Checked := False;
    mBEd07.Parent := mForm;
    
    mBEd14:= TCheckBox.Create(mForm);
    mBEd14.Left := 17;
    mBEd14.Top := 443;
    mBED14.Caption:='Záloha';
    mBEd14.Checked := False;
    mBEd14.Parent := mForm;

    /// druhy sloupec

    mBEd08:= TCheckBox.Create(mForm);
    mBEd08.Left := 117;
    mBEd08.Top := 313;
    mBEd08.Caption:='Kabel QuickLock';
    mBEd08.Checked := False;
    mBEd08.Parent := mForm;

    mBEd09:= TCheckBox.Create(mForm);
    mBEd09.Left := 117;
    mBEd09.Top := 333;
    mBEd09.Caption:='Kufr';
    mBEd09.Checked := False;
    mBEd09.Parent := mForm;

    mBEd10:= TCheckBox.Create(mForm);
    mBEd10.Left := 117;
    mBEd10.Top := 353;
    mBEd10.Caption :='Akumulátor';
    mBEd10.Checked := False;
    mBEd10.Parent := mForm;

    mBEd11:= TCheckBox.Create(mForm);
    mBEd11.Left := 117;
    mBEd11.Top := 373;
    mBEd11.Caption := 'Pilový list';
    mBEd11.Checked := False;
    mBEd11.Parent := mForm;

    mBEd12:= TCheckBox.Create(mForm);
    mBEd12.Left := 117;
    mBEd12.Top := 393;
    mBEd12.Caption:='ZL/certifikát';
    mBEd12.Checked := False;
    mBEd12.Parent := mForm;

    mBEd13:= TCheckBox.Create(mForm);
    mBEd13.Left := 117;
    mBEd13.Top := 413;
    mBEd13.Caption := 'Skličidlo, kleština';
    mBEd13.Checked := False;
    mBEd13.Parent := mForm;
    
    mBEd15:= TCheckBox.Create(mForm);
    mBEd15.Left := 117;
    mBEd15.Top := 443;
    mBEd15.Caption := 'Kartou?';
    mBEd15.Checked := False;
    mBEd15.Parent := mForm;

    /// druhy sloupec
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Příslušenství ostatní';
    mLabel3.Top := 300;
    mLabel3.Left := 227;

    mEd7 := TMemo.Create(mForm);
    mEd7.Left := 227;
    mEd7.Top := 320;
    mEd7.Width := 260;
    med7.Height:= 60;
    mEd7.Text := '';
    mEd7.Parent := mForm;
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Doklady';
    mLabel3.Top := 390;
    mLabel3.Left := 227;
    
    mEd8 := TEdit.Create(mForm);
    mEd8.Left := 227;
    mEd8.Top := 410;
    mEd8.Width := 260;
    mEd8.Text := '';
    mEd8.Parent := mForm;
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Odp. osoba:';
    mLabel3.Top := 467;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcUser:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcUser.Parent:= mForm;
    //mCbCcUser.BevelOuter:= bvLowered;
    mCbCcUser.Left:= 228;
    mCbCcUser.Top:= 467;
    mCbCcUser.Width:= 255;

    mCbUser:= TRollComboEdit.Create(mForm);
    mCbUser.Parent:= mForm;

    mCbUser.ClassID:= 'G1W2A2CBNNDL3DZ403KIU0CLP4';
    mCbUser.Complete:= True;
    mCbUser.ForcedField:= True;
    mCbUser.Prefilling:= pmNone;
    mCbUser.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbUser.Top:= 467;
    mCbUser.Left:= 107;
    mCbUser.Width:= 108;
    mCbUser.ConnectedControl:= mCbCcUser;
    mCbUser.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 499;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 499;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aFirm_id:= mCbFirm.DataText;
        aFirmService_ID:= mCbFirmRepair.DataText;
        aPerson_id:= mCbPerson.DataText;
        if not(NxIsEmptyOID(mCbStoreCard.DataText)) then aStoreCard_ID:= mCbStoreCard.DataText;
        aStoreCardSpecification2:= mEd1.text;
        aStorecardCode:=mEd2.Text;
        aStoreCardName:=med3.Text;
        aStoreCardCat:=mEd4.Text;
        aDodSL:= mEd5.Text;
        aMemo:=mEd6.Text;
        aZaruka:=mbed01.Checked;
        aRukojet:=mbed02.Checked;
        aKryt:=mbed03.Checked;
        aMatice:=mbed04.Checked;
        aKotouc:=mbed05.Checked;
        aKlic:=mbed06.checked;
        aNabijecka:=mbed07.checked;
        aKabel:=mBEd08.checked;
        aKufr:=mBEd09.checked;
        aAkumulator:=mbed10.checked;
        aPilovyList:=mbed11.checked;
        aZarucnilist:=mbed12.checked;
        aSklicidlo:=mbed13.checked;
        aDocuments:=mEd8.Text;
        aAddDescription:=med7.Text;
        adialog:=true;
        aZaloha:=mbed14.Checked;
        aKarta:=mbed15.Checked;
        AOdpovednaOsoba:=mCbUser.DataText;
        aVipCard:=med10.Text;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;

begin
end.