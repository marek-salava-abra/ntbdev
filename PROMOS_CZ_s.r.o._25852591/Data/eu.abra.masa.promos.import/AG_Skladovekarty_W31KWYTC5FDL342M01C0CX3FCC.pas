uses 'eu.abra.masa.promos.import.progress';
Const
 cPath='\\192.168.101.20\Programy\AbraG3\zz_media\bosch\el_rucni\';





procedure FormCreate_Hook(Self: TSiteForm);
var
  mBut: TBasicAction;
  mMAction : TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Nový import';
  mMAction.Hint := 'Naimportuje data z CSV, kód název cena skupina';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @ImportTXT_OnExecute;
  mMAction.Items.Add('Import z CSV');




  //mAction.OnUpdate := @ImportTXT_OnUpdate;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO, mPicture, mStorePicture, mSMBO, mUnit : TNxCustomBusinessObject;
  i,j,k, l, m: integer;
  mOS: TNxCustomObjectSpace;
  mRowTxt:String;
  mStoreCardCode, mStoreCardName, mStoreCardEAN, mPicture_ID, mPomoc_ID, mStorePrice_ID, mStoreCardCategory: String;
  mStoreCard_ID: String;
  mPrice:Extended;
  mXMLHead : TNxScriptingXMLWrapper;
  mPictures, mUnits:TNxCustomBusinessMonikerCollection;
begin


  if index=0 then begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        ProgressInit(mSite, 'import KingTony...', mList.count);
        mOS:=msite.CompanyObjectSpace;
        for i:=0 to mList.count-1 do begin
          mStoreCard_ID:='';
          mRowTxt := mlist.strings[i];
          mStoreCardCode:= NxToken(mRowTxt, ';');
          mStoreCardName:=NxToken(mRowTxt, ';');
          mPrice:=NxIBStrToFloat(NxToken(mRowTxt, ';'));
          mStoreCardCategory:=NxToken(mRowTxt, ';');
          //mStoreCardEAN:=NxToken(mRowTxt, ';');
          if AnsiLeftStr(mStoreCardName,1)='"' then begin
            mStoreCardName:=NxTrimL(mStoreCardName,'"');
            mStoreCardName:=NxSearchReplace(mStoreCardName,'""','"',[srAll]);
            mStoreCardName:=NxTrimR(mStoreCardName,'"');
          end;
                  //if not(NxIsBlank(mStoreCardEAN)) then mStoreCard_ID:=GetStoreCardFromEan_ID(mOS,mStoreCardEAN);
          if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCardFromCode_ID(mOS,mStoreCardCode);
          if NxIsEmptyOID(mstorecard_id) and not(nxisblank(mStoreCardName)) then begin
           mBO:=Mos.createobject(class_storecard);
           mbo.new;
           mbo.prefill;
           mbo.SetFieldValueAsString('code',mStoreCardCode);
           mbo.SetFieldValueAsString('name',Ansileftstr(mStoreCardName,100));
           mbo.SetFieldValueAsString('StoreCardCategory_ID','1000000101');
           mbo.SetFieldValueAsString('VatRate_ID','02100X0000');
           if not(NxIsBlank(mStoreCardEAN)) then begin
             mUnits:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('storeunits'));
             mUnit:=munits.BusinessObject[0];
             munit.SetFieldValueAsString('Ean',mStoreCardEAN);
           end;
           mbo.save;
           mStoreCard_ID:=mbo.oid;
           mbo.free;
          end;
          if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsBlank(mStoreCardName)) then begin
          mbo:= mOS.CreateObject(Class_StoreCard);
          mbo.Load(mStoreCard_ID,nil);
          //mbo.SetFieldValueAsString('U_oldName',mbo.GetFieldValueAsString('Name'));
          mbo.SetFieldValueAsString('Name',Ansileftstr(mStoreCardName,100));
          mbo.SetFieldValueAsString('StoreaSSORTMENTGROUP_ID', GetAGFromCode_ID(mOS,mStoreCardCategory));
          mbo.save;
          mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,'1000000101');
            if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             for m:=0 to mUnits.count-1 do begin
             mUnit:=mUnits.BusinessObject[m];
             if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
                if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                   mUnit.SetFieldValueAsFloat('Amount',mPrice);
                  mUnit.save;
                end;
              end;

            end;
             msmbo.save;
             mSMBO.Free;
            end;
           if NxIsEmptyOID(mStorePrice_ID) then begin
            mSMBO:=mos.CreateObject(Class_StorePrice);
            mSMBO.New;
            mSMBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
            mSMBO.SetFieldValueAsString('PriceList_ID','1000000101');
            mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
            mUnit:=mUnits.AddNewObject;
            mUnit.SetFieldValueAsFloat('Amount',mPrice);
            mUnit.SetFieldValueAsString('Price_ID','1000000101');
            mUnit.SetFieldValueAsString('Qunit',mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
            mSMBO.save;
            msmbo.Free;
           end;

          mbo.free;
          end;
          ProgressSetPos(i+1);

        end;

      finally
        ProgressDispose();
        mList.Free;
        RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
      end;
      NxShowMessage('info','Import dokončen.',mdInformation,false,mSite);
    end else
      NxShowMessage('info','Import přerušen.',mdInformation,false,mSite);
  finally
    mOpenDlg.Free;
  end;
  end;


end;



procedure ImportTXT_OnUpdate(Sender : TComponent);
var
  mSite : TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := TDynSiteForm(mSite).edit;
      end;
    end;
  end
end;

procedure RefreshDataset(AGrid : TDBGrid);
begin
NxRefreshDataSetWithoutValidate(TNxDataDataSet(AGrid.DataSource.DataSet), true);
end;

function GetStoreCardFromEan_ID(AOS : TNxCustomObjectSpace; EAN: string) : string;
const
  cSQL = 'SELECT su.parent_ID FROM StoreEans SE left join storeunits su on su.id=se.parent_ID WHERE se.EAN=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [EAN]);
    AOS.SQLSelect(Format(cSQL,  [EAN]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCardFromCode_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from storecards where code=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetAGFromCode_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from storeaSSORTMENTGROUPS where code=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetPicture_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from Pictures where PathAndFileName=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCardPicture_ID(AOS : TNxCustomObjectSpace; ACode: string;aStoreCard_ID:String) : string;
const
  cSQL = 'SELECT ID from StoreCardPictures where Picture_ID=''%s'' and Parent_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode,aStoreCard_ID]);
    AOS.SQLSelect(Format(cSQL,  [ACode,aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.