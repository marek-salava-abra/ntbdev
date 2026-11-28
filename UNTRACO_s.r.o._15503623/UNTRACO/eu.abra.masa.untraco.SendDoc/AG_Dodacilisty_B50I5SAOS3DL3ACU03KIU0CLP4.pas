uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.ShortCut := TextToShortCut('Ctrl+w');
  mAction.Caption := '## Odeslat e-mail ##';
  mAction.Hint := 'Vytvoří nový email s přílohami PDF a DOK';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendInvoiceByOutlook;
end;


procedure SendInvoiceByOutlook(Sender: TComponent);
var
  mOutlook, mItem: Variant;
  mBO, mDocumentBO, mBODBO, mDocContBO, mHTMLBO:TNxCustomBusinessObject;
  mPrintList, mFileList, mDocumentList, mDocumentQList, mFirmList, mBODList, mDocList, mInvoiceList:TStringList;
  mSite:TSiteForm;
  mOS:TNxCustomObjectSpace;
  mFileName, mDoc_ID, mTempDir, mTO, mFirm_ID, mFirstFirm_ID, mInvoiceNames, mBODNames, mDODFileName, mOrderNumber, mSubject:String;
  mP:TNxParameters;
  mContext:TNxContext;
  i, j, k, l, mReg:integer;
  mInvoiceForm_ID, mBODForm_ID:string;
  mM: TMemoryStream;
  mDocumentContents:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(Sender).DynSite;
  mDocumentList:=TStringList.Create;
  mDocumentQList:=TStringList.Create;
  mDocList:=TStringList.Create;
  mBODList:=TStringList.Create;
  mInvoiceList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mDocumentList);
  if mDocumentList.Count>0 then begin
    mOS:=TDynSiteForm(mSite).BaseObjectSpace;
    mHTMLBO:=mOS.CreateObject(Class_HtmlTemplate);
    mHTMLBO.Load(cHTMLBillOfDelivery,nil);
    mFirstFirm_ID := '';
    mInvoiceNames :='';
    mBODNames :='';
    mOrderNumber:='';
    mTO:='';
      for i := 0 to mDocumentList.Count - 1 do begin
        mBO := mOS.CreateObject(Class_BillOfDelivery);
        try
          mBO.Load(mDocumentList.Strings[i], nil);
          mFirm_ID := mBO.GetFieldValueAsString('Firm_ID');
          if i = 0 then begin
            // U první faktury si zapamatujeme ID firmy
            mFirstFirm_ID := mFirm_ID;
            mContext:=NxCreateContext_1(mBO);
          end else begin
            // U dalších kontrolujeme, zda sedí s tou první
            if mFirstFirm_ID <> mFirm_ID then begin
              NxShowSimpleMessage('Chyba: Vybrané faktury nepatří stejné firmě!', mSite);
              mBO.Free;
              Exit; // Končíme proceduru, finální uvolnění mDocumentList zařídí block finally níže
            end;
          end;
        finally

        end;
      end;
    try
     mOutlook := CreateOleObject('Outlook.Application');
    except

    end;
    if VarIsNull(mOutlook) then NxShowSimpleMessage('Chyba při získání instance Outlooku', Sender.Site)
    else begin
      //mTempDir:=NxGetTempDir+'Abra_outlook\';
      //if NxGetActualUserID(mOS)='1Y50000101' then
      mTempDir:='C:\ABRA_test\Abra_outlook\';
      ForceDirectories(mTempDir);
      if DirectoryExists(mTempDir) {and not(NxGetActualUserID(mOS)='1Y50000101')} then begin
      {ShellApi.Execute('open',                  // ACommand
                       'cmd.exe',               // AFile (spustíme příkazový řádek)
                       '/c rmdir /s /q "' + mTempDir + '"', // AParams (/c provede příkaz a zavře cmd)
                       ''                       // APath (pracovní adresář netřeba)
                      );
      NxSleep(2000); }

      end;
      ForceDirectories(mTempDir);
      mPrintList:=TStringList.Create;
      mFileList:=TStringList.Create;
       if mDocumentList.Count>0 then begin
        for j:=0 to mDocumentList.count-1 do begin
          mBODBO:=mOS.CreateObject(Class_BillOfDelivery);
          mBODBO.Load(mDocumentList.Strings[j],nil);
          mPrintList.Clear;
          mPrintList.Add(mBODBO.OID);
          if not(NxIsEmptyOID(mBODBO.GetFieldValueAsString('Firm_ID.X_BODForm_ID'))) then mBODForm_ID:=mBODBO.GetFieldValueAsString('Firm_ID.X_BODForm_ID') else mBODForm_ID:=cBODForm_ID;
          mFileName:=NxSearchReplace(mBODBO.DisplayName,'/','-',[srAll]);
          mDODFileName:=mOS.SQLSelectFirstAsString('Select distinct(ro.ExternalNumber) from StoreDocuments2 sd2 left join ReceivedOrders ro on ro.id=sd2.provide_id where sd2.Parent_id='+QuotedStr(mBODBO.OID),'');
          if NxIsBlank(mOrderNumber) then mOrderNumber:=mDODFileName;
          if NxIsBlank(mDODFileName) then mDODFileName:=mFileName;
          if not(NxIsBlank(mDODFileName)) then begin
            if not(DirectoryExists(mTempDir+mBODBO.OID+'\')) then CreateDir(mTempDir+mBODBO.OID+'\');
          end;
          if NxIsBlank(mBODNames) then mBODNames:=mBODBO.DisplayName else mBODNames:=mBODNames+', '+mBODBO.DisplayName;
          mDocList.Clear;
          mOS.SQLSelect('Select RightSide_ID from relations where leftside_id='+QuotedStr(mBODBO.OID)+' and rel_def=620', mDocList);
          if mDocList.Count>0 then begin
            for k:=0 to mDocList.count-1 do begin
              mDocumentBO:=mOS.CreateObject(Class_Document);
              mDocumentBO.Load(mDocList.Strings[k],nil);
              mDocumentContents:=mDocumentBO.GetLoadedCollectionMonikerForFieldCode(mDocumentBO.GetFieldCode('Contents'));
              for l:=0 to mDocumentContents.Count-1 do begin
                mDocContBO:=mDocumentContents.BusinessObject[l];
                mM:=TMemoryStream.Create;
                mM.SetBytes(mDocContBO.GetFieldValueAsBytes('Data_ID.BlobData'));
                mM.SaveToFile(mTempDir+mBODBO.OID+'\'+mDocContBO.GetFieldValueAsString('FileName'));
                mM.free;
                if FileExists(mTempDir+mBODBO.OID+'\'+mDocContBO.GetFieldValueAsString('FileName')) then
                 mFileList.Add(mTempDir+mBODBO.OID+'\'+mDocContBO.GetFieldValueAsString('FileName'));
              end;
              mDocumentBO.free;
            end;
          end;
          CFxReportManager.ExportByIDs(NxCreateContext(mOS),mPrintList,GetDynSourceex(mOS,cExport_ID),cExport_ID,2,'',mTempDir+mBODBO.OID+'\'+mDODFileName+'.DOD');
          if FileExists(mTempDir+mBODBO.OID+'\'+mDODFileName+'.DOD') then mFileList.Add(mTempDir+mBODBO.OID+'\'+mDODFileName+'.DOD');
          CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,mBODForm_ID),mBODForm_ID,rtoFile,pekPDF,mTempDir,mFileName+'.pdf');
          if FileExists(mTempDir+mFileName+'.pdf') then mFileList.Add(mTempDir+mFileName+'.pdf');
          mInvoiceList.Clear;
          mOS.SQLSelect('Select distinct parent_id from issuedinvoices2 where provide_id='+QuotedStr(mBODBO.OID), mInvoiceList);
          if mInvoiceList.Count>0 then begin
            for l:=0 to mInvoiceList.Count-1 do begin
               mPrintList.Clear;
               mBO:=mOS.CreateObject(Class_IssuedInvoice);
               mBO.Load(mInvoiceList.Strings[l],nil);
               mPrintList.Add(mbo.OID);
               mFileName:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
               if NxIsBlank(mInvoiceNames) then mInvoiceNames:=mBO.DisplayName
                 else mInvoiceNames:=mInvoiceNames+', '+mBO.DisplayName;
               mReg:=mOS.SQLSelectFirstAsInteger('SELECT 1 FROM IssuedInvoices2 i2 WHERE i2.Parent_ID = '+QuotedStr(mbo.OID)+'  AND i2.StoreCard_ID IN ( SELECT b.ID '#13#10 +
                                          '      FROM StoreCards b'#13#10 +
                                          '      WHERE b.Hidden = ''N'' '#13#10 +
                                          '        AND EXISTS ('#13#10 +
                                          '            SELECT 1 '#13#10 +
                                          '            FROM USERDATA '#13#10 +
                                          '            WHERE FIELDCODE = 2000212 '#13#10 +
                                          '              AND CLSID = ''C3V5QDVZ5BDL342M01C0CX3FCC'' '#13#10 +
                                          '              AND ID = b.ID '#13#10 +
                                          '              AND STRINGFIELDVALUE <> '''''#13#10 +
                                          '        )'#13#10 +
                                          '  )',0);
                 if mReg = 1 then begin
                          // Pokud mReg=1, jdeme po X_InvoiceRegForm_ID
                          if not(NxIsEmptyOID(mBO.GetFieldValueAsString('Firm_ID.X_InvoiceRegForm_ID'))) then
                            mInvoiceForm_ID := mBO.GetFieldValueAsString('Firm_ID.X_InvoiceRegForm_ID')
                          else
                            mInvoiceForm_ID := cInvoiceRegForm_ID;
                        end else begin
                          // Pokud mReg=0, jdeme po X_InvoiceNoRegForm_ID
                          if not(NxIsEmptyOID(mBO.GetFieldValueAsString('Firm_ID.X_InvoiceNoRegForm_ID'))) then
                            mInvoiceForm_ID := mBO.GetFieldValueAsString('Firm_ID.X_InvoiceNoRegForm_ID')
                          else
                            mInvoiceForm_ID := cInvoiceNoRegForm_ID;
                 end;
                 CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,mInvoiceForm_ID),mInvoiceForm_ID,rtoFile,pekPDF,mTempDir,mFileName+'.pdf');
                 if FileExists(mTempDir+mFileName+'.pdf') then mFileList.Add(mTempDir+mFileName+'.pdf');
                 mBO.Free;
            end;
          end;
          mBODBO.free;
        end;
       end;
      try
        mItem := mOutlook.CreateItem(0);
        mItem.Display;
        mItem.To := mTO;
        //mItem.CC := '';
        if NxIsBlank(mInvoiceNames) then
         mItem.Subject := 'Dodací list č. '+mBODNames
        else mItem.Subject := 'Dodací list č. '+mBODNames+' a faktura č. '+mInvoiceNames;
        mItem.HTMLBody := NxSearchReplace(mHTMLBO.GetFieldValueAsString('HtmlBody'),'#OrderNumber#',mOrderNumber,[srAll])+ mItem.HTMLBody;;
        for i:=0 to mFileList.Count-1 do
        mItem.Attachments.Add(mFileList.Strings[i]);
        mItem.Display; //nebo  .Send pro odeslání
      Except
        NxShowSimpleMessage('Stala se chyba '+NxCrlf+ExceptionMessage,mSite);
        CFxLog.SaveLog(NxCreateContext(mOS),'LS','Mail DL','Uživatel: '+NxGetUserName+NxCrlf+'tempdir: '+mTempDir+NxCrLf+ExceptionMessage,2,now);
      end;
      mFileList.Free;
      mPrintList.Free;
    end;
    mOutlook := Null;
  end;
end;

begin
end.