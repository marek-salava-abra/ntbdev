{
 pozor nevyplněné tagy DatevDebtorCode a DatevCreditorCode, přidat fci ElementExists
 firmu dohledávat (měla by být založena importem z SalesOrder) a doplnit údaje

}

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpXML';
  mAction.Caption := '##Import XML##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpCSV';
  mAction.Caption := '##Import CSV##';
  mAction.Hint := 'Naimportuje CSV data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportCSV;
end;

Procedure ImportCSV(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i:integer;
 mBO, mBankBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mTempStr, mCode, mName, mB2B, mTransportCode, mBankAccount, mEmail, mArt, mSalesRep, mCountry, mFirm_ID,mBankAccount_ID:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z CSV';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 if mOpenDlg.Execute then begin
  try
   mList:=TStringList.Create;
   mList.LoadFromFile(mOpenDlg.FileName);
   WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
   for i:=1 to mlist.Count-1 do begin
     mTempStr:=mList.Strings[i];
     mCode:=NxTrapStrTrim(mTempStr,';');
     mName:=NxTrapStrTrim(mTempStr,';');
     mB2B:=NxTrapStrTrim(mTempStr,';');
     mTransportCode:=NxTrapStrTrim(mTempStr,';');
     mBankAccount:=NxTrapStrTrim(mTempStr,';');
     mEmail:=NxTrapStrTrim(mTempStr,';');
     mArt:=NxTrapStrTrim(mTempStr,';');
     mSalesRep:=NxTrapStrTrim(mTempStr,';');
     mCountry:=NxTrapStrTrim(mTempStr,';');
     mFirm_ID:=mOS.SQLSelectFirstAsString('Select id from firms where code='+QuotedStr(mCode)+' and firm_id is null and hidden=''N'' ','');
     if not(NxIsEmptyOID(mFirm_ID)) then begin
        mBO:=mOS.CreateObject(Class_Firm);
        mBO.Load(mFirm_ID,nil);
        mBO.SetFieldValueAsString('TransportationType_ID',mOS.SQLSelectFirstAsString('Select id from TransportationTypes where code='+QuotedStr(AnsiLeftStr(mTransportCode,4))+' and hidden=''N'' ',''));
        mBO.SetFieldValueAsBoolean('X_B2B',True);
        mBO.SetFieldValueAsString('ElectronicAddress_ID.Email',mEmail);
        if NxIsBlank(mBO.GetFieldValueAsString('ResidenceAddress_ID.Country')) then
          mBO.SetFieldValueAsString('ResidenceAddress_ID.Country', mCountry);
        if not(NxIsBlank(mSalesRep)) then begin
          mBO.SetFieldValueAsString('X_SalesRep_ID',GetOrCreateSR(mOS, mSalesRep));
        end;
        if not(NxIsBlank(mBankAccount)) then begin
          mBankAccount:=NxSearchReplace(mBankAccount,' ','',[srAll]);
          mBankAccount_ID:=mOS.SQLSelectFirstAsString('Select id from FirmBankAccounts where parent_id='+QuotedStr(mbo.OID)+' and BankAccount='+QuotedStr(mBankAccount),'');
          if NxIsEmptyOID(mBankAccount_ID) then begin
            mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
            mBankBO:=mRows.AddNewObject;
            mBankBO.SetFieldValueAsString('BankAccount', mBankAccount);
          end;
        end;
        mBO.save;
        mbo.free;
     end;
     WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
     WaitWin.StepIt;
   end;
   WaitWin.Stop;
  except
   WaitWin.Stop;
  end;
 end;
end;

Function GetOrCreateSR(var AOS:TNxCustomObjectSpace; var aCode:string;):string;
var
 mBO:TNxCustomBusinessObject;
 mID:string;
begin
 mID:=aOS.SQLSelectFirstAsString('Select id from BusTransactions where code='+QuotedStr(aCode)+' and hidden=''N'' ','');
 if NxIsEmptyOID(mID) then begin
   mBO:=AOS.CreateObject(Class_BusTransaction);
   mBO.new;
   mBO.prefill;
   mBO.SetFieldValueAsString('Code',aCode);
   mbo.save;
   mID:=mBO.OID;
   mbo.free;
 end;
 Result:=mID;
end;

Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,mCount:integer;
 mXMLHead:TNxScriptingXMLWrapper;
 mBO:TNxCustomBusinessObject;
 mFirm_ID,mPricelistCode,mPriceList_ID, EID, mAddressType, mDefault:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z XML';
 mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
 mOpenDlg.Options := [ofAllowMultiSelect];
 if mOpenDlg.Execute then begin
  try
    mCount:=mOpenDlg.Files.Count;
    //WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i:=0 to mOpenDlg.Files.Count-1 do begin
       mXMLHead:=TNxScriptingXMLWrapper.Create;
       mXMLHead.loadFromFile(mOpenDlg.Files[i]);
       for j:=0 to mXMLHead.getElementsCountInArray('Accounts.Account')-1 do begin
         EID:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+']','ID');
         mFirm_ID:=mOS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and Firm_ID is null and X_ID_Exact='+QuotedStr(EID),'');
          if (NxIsEmptyOID(mFirm_ID)) then begin
            mBO:=mOS.CreateObject(Class_Firm);
            mBO.new;
            mbo.prefill;
            mbo.SetFieldValueAsString('Code',mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+']','code'));
            mBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Name'));
            mBO.SetFieldValueAsString('X_ID_Exact',EID);
            for k:=0 to  mXMLHead.getElementsCountInArray('Accounts.Account['+IntToStr(j)+'].Address')-1 do begin
              mAddressType:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+']','type');
              mDefault:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+']','default');
              if (mAddressType='VIS') and (mDefault='1') then begin
                mBO.SetFieldValueAsString('ResidenceAddress_ID.Street',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].AddressLine1'));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.PostCode',AnsiLeftStr(mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].PostalCode'),10));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.City',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].City'));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.Phonenumber1',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Phone'));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.Email',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Email'));
                try
                  mBO.SetFieldValueAsString('ResidenceAddress_ID.CountryCode',mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].country','code'));
                except
                end;
              end;
            end;
            try
             mBO.SetFieldValueAsString('Note',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Note'));
            except
            end;
            mBO.SetFieldValueAsString('VATIdentNumber',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].VatNumber'));
            try
             mBo.SetFieldValueAsString('X_Exact_DatevDebtorCode',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].DatevDebtorCode'));
            except
            end;
            try
             mBo.SetFieldValueAsString('X_Exact_DatevCreditorCode',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].DatevCreditorCode'));
            except
            end;
            try
              mPricelistCode:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].PriceList','code');
              mPricelist_id:=mOS.SQLSelectFirstAsString('Select id from pricelists where name='+QuotedStr(mPricelistCode)+' and hidden=''N'' ','');
              mBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
            except

            end;
            mbo.save;
            mBO.free;
         end;
         if not(NxIsEmptyOID(mFirm_ID)) then begin
            mBO:=mOS.CreateObject(Class_Firm);
            mBO.Load(mFirm_ID,nil);
            for k:=0 to  mXMLHead.getElementsCountInArray('Accounts.Account['+IntToStr(j)+'].Address')-1 do begin
              mAddressType:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+']','type');
              mDefault:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+']','default');
              if (mAddressType='VIS') and (mDefault='1') then begin
                mBO.SetFieldValueAsString('ResidenceAddress_ID.Street',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].AddressLine1'));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.PostCode',AnsiLeftStr(mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].PostalCode'),10));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.City',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].City'));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.Phonenumber1',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Phone'));
                mBO.SetFieldValueAsString('ResidenceAddress_ID.Email',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Email'));
                try
                  mBO.SetFieldValueAsString('ResidenceAddress_ID.CountryCode',mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].Address['+IntToStr(k)+'].country','code'));
                except
                end;
              end;
            end;
            try
             mBO.SetFieldValueAsString('Note',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].Note'));
            except
            end;
            mBO.SetFieldValueAsString('VATIdentNumber',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].VatNumber'));
            try
             mBo.SetFieldValueAsString('X_Exact_DatevDebtorCode',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].DatevDebtorCode'));
            except
            end;
            try
             mBo.SetFieldValueAsString('X_Exact_DatevCreditorCode',mXMLHead.getElementAsString('Accounts.Account['+IntToStr(j)+'].DatevCreditorCode'));
            except
            end;
            try
              mPricelistCode:=mXMLHead.getAttributeValue('Accounts.Account['+IntToStr(j)+'].PriceList','code');
              mPricelist_id:=mOS.SQLSelectFirstAsString('Select id from pricelists where name='+QuotedStr(mPricelistCode)+' and hidden=''N'' ','');
              mBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
            except

            end;
            mbo.save;
            mBO.free;
         end;
       end;
      end;
  except
    NxShowSimpleMessage(ExceptionMessage,msite);

  end;
 end;
end;

begin
end.