uses 'eu.promos.adr.ParseData', 'eu.promos.adr.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import dokladů z XML';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mFirm, mOtherIncomeBO, mPriceBO, mUnit:TNxCustomBusinessObject;
 mRows, mUnits:TNxCustomBusinessMonikerCollection;
 mRow:TNxCustomBusinessObject;
 mopenDLG:TOpenDialog;
 i, j, k:integer;
 mXMLHead: TNxScriptingXMLWrapper;
 mCountryCode, mCountry_ID, mFVDocQueue_ID, mFPDocQueue_ID, mFirm_ID, mDivision_ID, mOtherIncome_ID:String;
 mRI_ID,mII_ID,mCR_ID,mStoreCard_ID:String;
 mErrorList:TStringList;
 mStoreName:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(mopenDLG.FileName);
        mErrorList:=TStringList.Create;
        try
           j:=mXMLHead.getElementsCountInArray('SeznamFirem.Firma');
           ProgressInit(mSite, 'Import firem...', j);
           for i := 0 to j - 1 do begin
            //mStoreCard_ID:=GetFirm_ID(mOS,mXMLHead.getElementAsString('datasets.dataset0.rows.row['+IntToStr(i)+'].fields.cislo'));
            if true then begin
            mBO:=mOS.CreateObject(Class_Firm);
            mbo.New;
            mBO.Prefill;
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Nazev')) then
            mBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].nazev'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.Ulice')) then
            mBO.SetFieldValueAsString('ResidenceAddress_ID.Street',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.Ulice'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.Misto')) then
            mBO.SetFieldValueAsString('ResidenceAddress_ID.City',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.Misto'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.PSC')) then
            mBO.SetFieldValueAsString('ResidenceAddress_ID.PostCode',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.PSC'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.Stat')) then
            mBO.SetFieldValueAsString('ResidenceAddress_ID.Country',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.Stat'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.KodStatu')) then
            mBO.SetFieldValueAsString('ResidenceAddress_ID.CountryCode',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].Adresa.KodStatu'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].ICO')) then
            mBO.SetFieldValueAsString('OrgIdentNumber',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].ICO'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].DIC')) then
            mBO.SetFieldValueAsString('VatIdentNumber',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].DIC'));
            if ElementExist(mXMLHead,('SeznamFirem.Firma['+IntToStr(i)+'].Email')) then
            mBO.SetFieldValueAsString('ResidenceAddress_ID.Email',mXMLHead.getElementAsString('SeznamFirem.Firma['+IntToStr(i)+'].Email'));
            mbo.save;
            mbo.Free;

           end;
           ProgressSetPos(i+1);
           end;
        finally
          ProgressDispose();
        end;
      finally
      end;
    end;
   finally
   end;
  end;
end;
begin
end.