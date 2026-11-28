uses 'eu.untraco.XML.fce', 'eu.untraco.XML.progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
  mMAction: TMultiAction;
  mUser:TNxCustomBusinessObject;
begin
  //if (mUser.GetFieldCode('U_StoreChanges')>0) and mUser.GetFieldValueAsBoolean('U_StoreChanges') then begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'XML';
  mMAction.Items.Add('XML Dánsko');
  mMAction.Items.Add('XML Alza');
  mMAction.Items.Add('XML Phoenix');
  mMAction.Hint := 'XML';
  mMAction.Category := 'tabDetail';
  mMAction.OnExecuteItem := @ImportXML_OnExecute;
  mAction2:= Self.GetNewAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := True;
  mAction2.Caption := 'Vytvoř OP';
  mAction2.Hint := 'Vytvoří OP dle skladů';
  mAction2.Category := 'tabList';
  mAction2.OnExecute := @CreateRO;
  //end;
end;

procedure CreateRO(Sender:TComponent);
var
 mSite:TSiteForm;
 mStoreList, mRowList, mOPList:TStringList;
 mBO, mStoreBO:TNxCustomBusinessObject;
 mImportMan: TNxDocumentImportManager;
 mOS: TNxCustomObjectSpace;
 mInputParams, P: TNxParameters;
 mParam, mPar: TNxParameter;
 i,j:integer;
begin
    mSite := TComponent(Sender).DynSite;
    mOS:=mSite.CompanyObjectSpace;
    mbo:=TDynSiteForm(mSite).CurrentObject;
    mInputParams := TNxParameters.Create;
      if NxMessageBox('Dotaz', 'Přejete si vytvořit objednávky z nabídky '+mbo.DisplayName+'?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
         mStoreList:= Tstringlist.Create;
         mOPList:=TStringList.Create;
         mOS.SQLSelect(format('select store_id from issuedoffers2 where parent_id=''%s'' group by store_id',[mBO.OID]),mStoreList);
         for i:=0 to mStoreList.count-1 do begin
            mStoreBO:=mOS.CreateObject(class_store);
            mstorebo.Load(mStoreList.strings[i],nil);
            if NxIsEmptyOID(mStoreBO.GetFieldValueAsString('X_RO_DocQueue_ID')) then begin
             NxShowSimpleMessage('Sklad '+mStoreBO.GetFieldValueAsString('Name')+' nemá přiřazenou řadu objednávek. Ukončuji.',mSite);
             exit;
            end;
            mstorebo.Free;

         end;
          for i:=0 to mStoreList.count-1 do begin
            mStoreBO:=mOS.CreateObject(class_store);
            mstorebo.Load(mStoreList.strings[i],nil);
            mRowList:=TStringList.create;
            mOS.SQLSelect(format('select ID from issuedoffers2 where parent_id=''%s'' and store_id=''%s'' ',[mBO.OID, mStoreBO.OID]),mRowList);
            mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
            mParam.AsString := mStoreBO.GetFieldValueAsString('X_RO_DocQueue_ID');
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
            mParam.AsString := mRowList.Text;
            mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedOffer, Class_ReceivedOrder);
            try
             mImportMan.AddInputDocument(mBO.OID);
             mImportMan.LoadParams(mInputParams);
             mImportMan.Execute;
             mImportMan.CheckOutputDocument;
            if Assigned(mImportMan.OutputDocument) then begin
              mImportMan.OutputDocument.SetFieldValueAsString('Period_ID', mbo.GetFieldValueAsString('Period_ID'));
              mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mBO.GetFieldValueAsDateTime('DocDate$Date'));
              mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mStoreBO.GetFieldValueAsString('X_RO_DocQueue_ID')); // musi byt...
              mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mbo.GetFieldValueAsString('Firm_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mbo.GetFieldValueAsString('FirmOffice_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', mbo.GetFieldValueAsString('PaymentType_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('TransportationType_ID', mbo.GetFieldValueAsString('TransportationType_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('ExternalNumber', mbo.GetFieldValueAsString('ExternalNumber'));
              mImportMan.OutputDocument.Save;
              mOPList.Add(mImportMan.OutputDocument.OID);
            end;
            finally
              mImportMan.Free;
           end;


            mRowList.Free;
            mstorebo.Free;

         end;
         if mOPList.count>0 Then begin
          if NxMessageBox('Dotaz', 'Přejete si zobrazit vytvořené objednávky?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
            P := TNxParameters.Create;
           try
             P.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Nově vytvořené objednávky';
             mPar := P.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; //mPar je typu TNxParameter
             mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
             mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
             mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
             mPar.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mOPList);
             ShowDynForm('O2XDU14IW3DL342X01C0CX3FCC',TDynSiteForm(mSite).SiteContext, P, nil, True);
             finally
               P.Free;
             end;
          end;

         end;
      end;
end;

procedure ImportXML_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList, mFileList : TStringList;
  mBO, mRowBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  i,j: integer;
  mXMLHead : TNxScriptingXMLWrapper;
  mstrings : TStrings;
  mstring, mFileName : String;
  mOS:TNxCustomObjectSpace;
  mFile, mErrorFile : TstringList;
  mRows:TNxCustomBusinessMonikerCollection;
  mStorecard_ID, mFirm_ID:String;
begin
 if Index=0 then begin
  mSite := TComponent(Sender).DynSite;
  mOpenDlg := TOpenDialog.create(mSite);
  //mOpenDlg.Options:=([ofAllowMultiSelect]);
  mOpenDlg.DefaultExt:='XML';
  mOpenDlg.Filter := 'Soubory XML (*.XML)| *.XML';
  mos:=msite.CompanyObjectSpace;
  try
    if mOpenDlg.Execute then begin
      mFileName:=mOpenDlg.FileName;
      try
        mBO:=TDynSiteForm(mSite).CurrentObject;
        mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        mFile := TStringList.Create();
        if FileExists(mFilename) then begin
         mFile.LoadFromFile(mFilename);
         if NxSearch(mfile.Strings[0],'<ord>',[srAll],0)=0 then begin
         if NxSearch(mFile.strings[0],'> <',[srAll],0)>0 then mFile.Strings[0]:=NxSearchReplace(mFile.Strings[0],'> <','><ord><',[srAll]);
         if NxSearch(mFile.strings[0],'><',[srAll],0)>0 then mFile.Strings[0]:=NxSearchReplace(mFile.Strings[0],'> <','><ord><',[srAll]);
         if NxSearch(mFile.strings[0],'><',[srAll],0)=0 then mFile.Strings[0]:=mFile.Strings[0]+'<ord>';
         mFile.Add('</ord>');
         end;
         mfile.SaveToFile(mFilename);
         mfile.Free;
   end;
        mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(mFileName);
        if not(NxIsBlank(mXMLHead.getAttributeValue('order','partner_ico'))) then begin
         mbo.SetFieldValueAsString('Firm_id',GetFirm_ID(mOS,mXMLHead.getAttributeValue('order','partner_ico')));
         mbo.SetFieldValueAsString('FirmOffice_ID',GetFO_ID(mOS,mXMLHead.getAttributeValue('order','partner_id')));
        end;
         if (NxIsBlank(mXMLHead.getAttributeValue('order','partner_ico'))) then begin
         mFirm_ID:=GetFirmXML_ID(mOS,mXMLHead.getAttributeValue('order','partner_id'));
         if not(NxIsEmptyOID(mFirm_ID)) then begin
          mbo.SetFieldValueAsString('Firm_id',mFirm_ID);
          mbo.SetFieldValueAsString('FirmOffice_ID',GetFirmOfficeXML_ID(mOS,mFirm_ID,mXMLHead.getAttributeValue('order','branch_id')));
         end;
         if NxIsEmptyOID(mFirm_ID) then begin
          mbo.SetFieldValueAsString('Firm_id',GetFirm2_ID(mOS,mXMLHead.getAttributeValue('order','branch_id')));
          mbo.SetFieldValueAsString('FirmOffice_ID',GetFO_ID(mOS,mXMLHead.getAttributeValue('order','branch_id')));
         end;
        end;
        //NxShowSimpleMessage(mXMLHead.getAttributeValue('order','partner_ico'),mSite);
        mbo.SetFieldValueAsString('ExternalNumber',mXMLHead.getAttributeValue('order','order_id'));
        mbo.SetFieldValueAsDateTime('DeadLineToSend$DATE',Date);
        mbo.SetFieldValueAsDateTime('SentDate$DATE',Date);
        mBO.SetFieldValueAsString('ActualSolverRole_ID','6100000101');
        mBO.SetFieldValueAsString('ResponsibleRole_ID','6100000101');
        mbo.SetFieldValueAsString('TransportationType_ID','7600000101');
        mbo.SetFieldValueAsString('PaymentType_ID','00000U1000');
        ProgressInit(mSite, 'Import dat...', mXMLHead.getElementsCountInArray('order.Items.item'));
         for i:=0 to mXMLHead.getElementsCountInArray('order.Items.item')-1 do begin
          // NxShowSimpleMessage(mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean'),mSite);
          mStorecard_ID:=GetStoreCard_ID(mOS,mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean'));
          if NxIsEmptyOID(mStorecard_ID) then begin
             NxShowSimpleMessage('V systému nebyla nalezena karta s EAN '+mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean')+'.'+#10+#13+'Operace bude ukončena',mSite);
             ProgressDispose();
             exit;
          end;
          if not(NxIsEmptyOID(mStorecard_ID)) then begin
          mRowBO:=mrows.AddNewObject;
          mrowbo.SetFieldValueAsInteger('RowType',3);
          mRowBO.SetFieldValueAsString('Store_ID','1000000101');
          mrowbo.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
          mRowBO.SetFieldValueAsString('Qunit',GetStoreUnit(mOS,mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean')));
          mrowbo.SetFieldValueAsFloat('Quantity',GetStoreUnitRate(mOS,mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean'))*NxIBStrToFloat(mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','qty')));
          mRowBO.SetFieldValueAsString('Division_ID','1000000101');
          end;
         ProgressSetPos(i+1);
         end;
      ProgressDispose();
      finally
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
        TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
      end;
    end else
      ShowMessage('Import přerušen.');
  finally
    mOpenDlg.Free;
  end;
  end;
 if Index=1 then begin
     mSite := TComponent(Sender).DynSite;
     mOpenDlg := TOpenDialog.create(mSite);
     mOpenDlg.DefaultExt:='ORD';
     mOpenDlg.Filter := 'Soubory ORD (*.ORD)| *.ord';
     mos:=msite.CompanyObjectSpace;
     try
       if mOpenDlg.Execute then begin
         mFileName:=mOpenDlg.FileName;
          try
           mBO:=TDynSiteForm(mSite).CurrentObject;
           mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
           mXMLHead := TNxScriptingXMLWrapper.Create;
           mXMLHead.loadFromFile(mFileName);
           mbo.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('body.xml_document.form_header.userdocid'));
           mBO.SetFieldvalueAsString('Firm_ID',GetFirmXML_ID(mOS,mXMLHead.getElementAsString('body.xml_document.form_header.buyer_ean')));
           mBO.SetFieldValueAsString('FirmOffice_ID',GetFirmOfficeXML_ID(mOS,mBO.GetFieldValueAsString('Firm_ID'),mXMLHead.getElementAsString('body.xml_document.form_header.delivery_ean')));
           mbo.SetFieldValueAsDateTime('DeadLineToSend$DATE',Date);
           mbo.SetFieldValueAsDateTime('SentDate$DATE',Date);
           mBO.SetFieldValueAsString('ActualSolverRole_ID','6100000101');
           mBO.SetFieldValueAsString('ResponsibleRole_ID','6100000101');
           mbo.SetFieldValueAsString('TransportationType_ID','7600000101');
           mbo.SetFieldValueAsString('PaymentType_ID','00000U1000');
           mBO.SetFieldValueAsString('Description',AnsiLeftStr(mXMLHead.getElementAsString('body.xml_document.form_header.free_text'),40));
           ProgressInit(mSite, 'Import dat...', mXMLHead.getElementsCountInArray('body.xml_document.line_items.item'));
           for i:=0 to mXMLHead.getElementsCountInArray('body.xml_document.line_items.item')-1 do begin
          // NxShowSimpleMessage(mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean'),mSite);
            mStorecard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('body.xml_document.line_items.item['+inttostr(i)+'].article_ean'));
          if NxIsEmptyOID(mStorecard_ID) then begin
             NxShowSimpleMessage('V systému nebyla nalezena karta s EAN '+mXMLHead.getElementAsString('body.xml_document.line_items.item['+inttostr(i)+'].article_ean')+'.'+#10+#13+'Operace bude ukončena',mSite);
             ProgressDispose();
             exit;
          end;
          if not(NxIsEmptyOID(mStorecard_ID)) then begin
          mRowBO:=mrows.AddNewObject;
          mrowbo.SetFieldValueAsInteger('RowType',3);
          mRowBO.SetFieldValueAsString('Store_ID','1000000101');
          mrowbo.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
          mRowBO.SetFieldValueAsString('Qunit',GetStoreUnit(mOS,mXMLHead.getElementAsString('body.xml_document.line_items.item['+inttostr(i)+'].article_ean')));
          mrowbo.SetFieldValueAsFloat('Quantity',GetStoreUnitRate(mOS,mXMLHead.getElementAsString('body.xml_document.line_items.item['+inttostr(i)+'].article_ean'))*NxIBStrToFloat(mXMLHead.getElementAsString('body.xml_document.line_items.item['+inttostr(i)+'].quantity')));
          mRowBO.SetFieldValueAsString('Division_ID','1000000101');
          end;
         ProgressSetPos(i+1);
         end;
      ProgressDispose();
      finally
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
        TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
      end;
       end;
     finally
    mOpenDlg.Free;
  end;
 end;
 if Index=2 then begin
     mSite := TComponent(Sender).DynSite;
     mOpenDlg := TOpenDialog.create(mSite);
     mOpenDlg.DefaultExt:='ORD';
     mOpenDlg.Filter := 'Soubory ORD (*.ORD)| *.ord';
     mos:=msite.CompanyObjectSpace;
     try
       if mOpenDlg.Execute then begin
         mFileName:=mOpenDlg.FileName;
          try

            if FileExists(mFilename) then begin
             mFile := TStringList.Create();
             mFile.LoadFromFile(mFilename);
             if NxSearch(mfile.Strings[0],'<ord>',[srAll],0)=0 then begin
                 if NxSearch(mFile.strings[0],'> <',[srAll],0)>0 then mFile.Strings[0]:=NxSearchReplace(mFile.Strings[0],'> <','><ord><',[srAll]);
                 if NxSearch(mFile.strings[0],'><',[srAll],0)>0 then mFile.Strings[0]:=NxSearchReplace(mFile.Strings[0],'> <','><ord><',[srAll]);
                 if NxSearch(mFile.strings[0],'><',[srAll],0)=0 then mFile.Strings[0]:=mFile.Strings[0]+'<ord>';
                 mFile.Add('</ord>');
             end;
             mfile.SaveToFile(mFilename);
             mfile.Free;
           end;

           mBO:=TDynSiteForm(mSite).CurrentObject;
           mRows:=mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
           mXMLHead := TNxScriptingXMLWrapper.Create;
           mXMLHead.loadFromFile(mFileName);
           mbo.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('biztalk_1.body.xml_document.form_header.userdocid'));
           mBO.SetFieldvalueAsString('Firm_ID',GetFirmXML_ID(mOS,mXMLHead.getElementAsString('biztalk_1.body.xml_document.form_header.buyer_ean')));
           mBO.SetFieldValueAsString('FirmOffice_ID',GetFirmOfficeXML_ID(mOS,mBO.GetFieldValueAsString('Firm_ID'),mXMLHead.getElementAsString('biztalk_1.body.xml_document.form_header.delivery_ean')));
           mbo.SetFieldValueAsDateTime('DeadLineToSend$DATE',Date);
           mbo.SetFieldValueAsDateTime('SentDate$DATE',Date);
           mBO.SetFieldValueAsString('ActualSolverRole_ID','6100000101');
           mBO.SetFieldValueAsString('ResponsibleRole_ID','6100000101');
           mbo.SetFieldValueAsString('TransportationType_ID','7600000101');
           mbo.SetFieldValueAsString('PaymentType_ID','00000U1000');
           mBO.SetFieldValueAsString('Description',AnsiLeftStr(mXMLHead.getElementAsString('biztalk_1.body.xml_document.form_header.free_text'),40));
           ProgressInit(mSite, 'Import dat...', mXMLHead.getElementsCountInArray('biztalk_1.body.xml_document.line_items.item'));
           for i:=0 to mXMLHead.getElementsCountInArray('biztalk_1.body.xml_document.line_items.item')-1 do begin
          // NxShowSimpleMessage(mXMLHead.getAttributeValue('order.Items.Item['+inttostr(i)+']','code_ean'),mSite);
            mStorecard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('biztalk_1.body.xml_document.line_items.item['+inttostr(i)+'].article_ean'));
          if NxIsEmptyOID(mStorecard_ID) then begin
             NxShowSimpleMessage('V systému nebyla nalezena karta s EAN '+mXMLHead.getElementAsString('biztalk_1.body.xml_document.line_items.item['+inttostr(i)+'].article_ean')+'.'+#10+#13+'Operace bude ukončena',mSite);
             ProgressDispose();
             exit;
          end;
          if not(NxIsEmptyOID(mStorecard_ID)) then begin
          mRowBO:=mrows.AddNewObject;
          mrowbo.SetFieldValueAsInteger('RowType',3);
          mRowBO.SetFieldValueAsString('Store_ID','1000000101');
          mrowbo.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
          mRowBO.SetFieldValueAsString('Qunit',GetStoreUnit(mOS,mXMLHead.getElementAsString('biztalk_1.body.xml_document.line_items.item['+inttostr(i)+'].article_ean')));
          mrowbo.SetFieldValueAsFloat('Quantity',GetStoreUnitRate(mOS,mXMLHead.getElementAsString('biztalk_1.body.xml_document.line_items.item['+inttostr(i)+'].article_ean'))*NxIBStrToFloat(mXMLHead.getElementAsString('biztalk_1.body.xml_document.line_items.item['+inttostr(i)+'].quantity')));
          mRowBO.SetFieldValueAsString('Division_ID','1000000101');
          end;
         ProgressSetPos(i+1);
         end;
      ProgressDispose();
      finally
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
        TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
      end;
       end;
     finally
    mOpenDlg.Free;
  end;
 end;
end;







begin
end.