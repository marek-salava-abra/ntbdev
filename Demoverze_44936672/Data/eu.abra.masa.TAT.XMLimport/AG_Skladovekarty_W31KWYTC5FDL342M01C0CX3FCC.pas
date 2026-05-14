procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import Feed ##';
  mAction.Hint := 'Naimportuje skladové karty z XML';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;

Procedure ImportXML(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mFileName:string;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z XML';
  mOpenDlg.Filter := 'Soubory skladových karet z Pohody (*.xml)| *.xml';
  if mOpenDlg.Execute then begin
     mFileName:=mOpenDlg.FileName;
     ImportFile(mOS, mfileName);
  end;
end;

Procedure ImportFile(var AOS:TNxCustomObjectSpace; var mFileName:string);
var
  i,j,k, mCount: Integer;
  mXML, EntryNode, currNode,ImageNodes, n: Variant;
  LogInfoStr:string;
  mName, mCode, mImageURL,mStoreCard_ID,mVatRate_ID:string;
  mBO, mUnitBO:TNxCustomBusinessObject;
  mQtyMain, mQtySenov, mQtyBilovec: Extended;
  mUnits, mPictures:TNxCustomBusinessMonikerCollection;
begin
  LogInfoStr:='';
  mXML := CreateOleObject('Msxml2.DOMDocument.6.0');
  try
    mXML.async := false;
    mXML.load(mFileName);
    EntryNode := mXML.getElementsByTagName('SHOPITEM');
    mCount := min(100000000,EntryNode.Length);
    for i := 0 to  mCount- 1 do begin
      currNode := EntryNode.Item(i);
      mCode:=currNode.selectSingleNode('CATALOG_NUMBER').text;
      mStoreCard_ID:=AOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(mCode)+' and hidden=''N'' ','');
      n := currNode.selectSingleNode('STOCKS/STOCK[@name="Hlavní sklad"]');
      if not VarIsNull(n) then mQtyMain := NxIBStrToFloat(n.text) else mQtyMain := 0;
      n := currNode.selectSingleNode('STOCKS/STOCK[@name="Prodejna Bílovec"]');
      if not VarIsNull(n) then mQtyBilovec := NxIBStrToFloat(n.text) else mQtyBilovec := 0;
      n := currNode.selectSingleNode('STOCKS/STOCK[@name="Prodejna Šenov"]');
      if not VarIsNull(n) then mQtySenov := NxIBStrToFloat(n.text) else mQtySenov := 0;
      if NxIsEmptyOID(mStoreCard_ID) then begin
        mBO:=AOS.CreateObject(Class_StoreCard);
        mBO.New;
        mBO.prefill;
        mBO.SetFieldValueAsString('Code',mCode);
        mBO.SetFieldValueAsString('Name',currNode.selectSingleNode('TITLE').Text);
        mBO.SetFieldValueAsString('StoreCardCategory_ID','1100000101');
        mVatRate_ID:=AOS.SQLSelectFirstAsString('Select id from vatrates where tariff='+currNode.selectSingleNode('VAT').Text+' and country_id=''00000CZ000'' ','');
        mBO.SetFieldValueAsString('VATRate_ID',mVatRate_ID);
        mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
          mUnitBO:=mUnits.BusinessObject[0];
          n:=currNode.selectSingleNode('EAN');
          if not VarIsNull(n) then mUnitBO.SetFieldValueAsString('EAN',n.Text);
          n:=currNode.selectSingleNode('LOGISTIC/WEIGHT');
          if not VarIsNull(n) then mUnitBO.SetFieldValueAsFloat('Weight',NxIBStrToFloat(n.text));
          n:=currNode.selectSingleNode('LOGISTIC/WIDTH');
          if not VarIsNull(n) then mUnitBO.SetFieldValueAsFloat('WIDTH',NxIBStrToFloat(n.text));
          n:=currNode.selectSingleNode('LOGISTIC/HEIGHT');
          if not VarIsNull(n) then mUnitBO.SetFieldValueAsFloat('HEIGHT',NxIBStrToFloat(n.text));
          n:=currNode.selectSingleNode('LOGISTIC/DEPTH');
          if not VarIsNull(n) then mUnitBO.SetFieldValueAsFloat('DEPTH',NxIBStrToFloat(n.text));
          mUnitBO.SetFieldValueAsInteger('SizeUnit',2);
        LogInfoStr:=LogInfoStr+currNode.selectSingleNode('TITLE').Text+Nxcrlf;
        ImageNodes := currNode.selectNodes('IMAGES/IMAGE');
          for k := 0 to ImageNodes.Length - 1 do begin
            LogInfoStr := LogInfoStr + ImageNodes.Item(k).Text + nxCrLf;
          end;
        mBO.save;
        mbo.free;
      end;
    end;
    NxShowSimpleMessage(LogInfoStr,nil);
  finally
    mXML := Null;
  end;
end;

begin
end.