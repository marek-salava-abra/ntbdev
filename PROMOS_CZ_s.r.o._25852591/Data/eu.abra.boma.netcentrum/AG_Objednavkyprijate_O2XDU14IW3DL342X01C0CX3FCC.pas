uses 'eu.abra.boma.XMLWeb.form',
      'eu.abra.boma.netcentrum.common',
      'eu.abra.boma.netcentrum.maildoc';
      
procedure ExportFV(Sender: TControl);
var
  mContext: TNxContext;
  mSite: TSiteForm;
  mIDs, mResults: TStringList;
  mLogStr: TStringList;
  mText, mOrigText: String;
  mWarning, mFaktura, mVyskladnen, mPriprava: Boolean;
  mCO, mRow:TNxCustomBusinessObject;
  mBO: TNxCustomBusinessObject;
  i,j,k: Integer;
  mGen:String;
  mInternalOLE,mDocDriver:Variant;
begin
  mText:='';
  mLogStr:=TStringList.Create;
  try
    if GetSiteFromControl(Sender, mSite) then begin
      mContext:=mSite.SiteContext;
      mIDs:=TStringList.Create;
      try
        mIDs.Append('1UP3000201');
        mGen:=NxSearchReplace(FloatToStr(Frac(Now)),',','',[srAll]);
        CFxReportManager.B2BExportByIDs(mContext,mIDs,'40SBPEINEFD13ACM03KIU0CLP4','1400000201',0,'','\\abraserver\SolidniObchod\ISDOC\'+mGen+'.isdoc');
        mInternalOLE:=GetAbraOLEApplication;
        mDocDriver:=mInternalOLE.CreateDocumentDriver;
        mDocDriver.NewDocument('4000000000');
        mDocDriver.AddContentFromFile('\\abraserver\SolidniObchod\ISDOC\'+mGen+'.isdoc');
        mDocDriver.SaveDocument;
        mDocDriver.ProcessDocument;
        DeleteFile('\\abraserver\SolidniObchod\ISDOC\'+mGen+'.isdoc');
      finally
        mIDs.Free;
      end;
    end;
  finally
    mLogStr.Free;
  end;
end;

      
procedure StornoRO(Sender: TControl);
var
  mContext: TNxContext;
  mSite: TSiteForm;
  mIDs, mResults: TStringList;
  mLogStr: TStringList;
  mText, mOrigText: String;
  mWarning, mFaktura, mVyskladnen, mPriprava: Boolean;
  mCO, mRow:TNxCustomBusinessObject;
  mBO: TNxCustomBusinessObject;
  i,j,k: Integer;
begin
  mText:='';
  mLogStr:=TStringList.Create;
  try
    if GetSiteFromControl(Sender, mSite) then begin
      mContext:=mSite.SiteContext;
      mIDs:=TStringList.Create;
      try
        mSite.List.GetSelectedId(mIDs);
        for i:=0 to mIDs.count -1 do begin
          try
            mCo:=mSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //OP
            try
              mCo.Load(mIDs[i],nil);
              mWarning:=False;
              mFaktura:=False;
              mVyskladnen:=False;
              mPriprava:=False;
              for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
                mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
                if mRow.GetFieldValueAsFloat('DeliveredQuantity')>0 then begin
                // existuje dodací list, kontrola zda není již vyskladněno
                  mResults:=TStringList.Create;
                  try
                    mSite.BaseObjectSpace.SQLSelect(Format('Select Parent_ID From StoreDocuments2 where ProvideRow_ID=''%s'' and Provide_ID=''%s''',[mRow.OID,mCo.OID]),mResults);
                    for k:=0 to mResults.Count -1 do begin
                      mBO:=mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4'); //DL
                      try
                        mBO.Load(mResults[k],nil);
                        if mBO.GetFieldValueAsInteger('X_Stav_dokladu')=4 then mFaktura:=True
                        else begin
                          if mBO.GetFieldValueAsInteger('X_Stav_dokladu')=3 then mVyskladnen:=True;
                          if mBO.GetFieldValueAsInteger('X_Stav_dokladu')=2 then mPriprava:=True;
                          mBO.SetFieldValueAsInteger('X_Stav_dokladu',5);
                          if mBO.NeedSave then mBO.Save;
                        end;
                      finally
                        mBO.Free;
                      end;
                    end;
                  finally
                    mResults.Free;
                  end;
                  mWarning:=True;
                end;
              end;
              mCo.SetFieldValueAsInteger('X_Stav_Dokladu',cStorno);
              if mCo.NeedSave then mCo.Save;
              if mFaktura then
                mLogStr.Append(Format('Doklad %s je již fakturován! Je nutné vytvořit příslušné doklady pro vrácení.',[mCo.DisplayName]))
              else
                if mVyskladnen then
                  mLogStr.Append(Format('Doklad %s je již vyskladněn! Je nutné vytvořit příslušné doklady pro vrácení.',[mCo.DisplayName]))
                else
                  if mPriprava then
                    mLogStr.Append(Format('Doklad %s má DL! Tento DL byl nastaven do stavu Storno.',[mCo.DisplayName]))
                  else
                    mLogStr.Append(Format('Doklad %s byl stornován.',[mCo.DisplayName]));
            finally
              mCO.Free;
            end;
          except
            mLogStr.Append(ExceptionMessage);
          end;
        end;
      finally
        mIDs.Free;
      end;
    end;
    NxShowMessage('Výsledek Storna',mLogStr.Text,mdInformation,False,mSite.FindParentForm);
  finally
    mLogStr.Free;
  end;
end;

procedure SendEmails(Sender: TControl);
var
  mSite: TSiteForm;
  mIDs: TStringList;
  mResults,mResults2: TStringList;
  mText: String;
  mType: Integer;
  mCO, mRow:TNxCustomBusinessObject;
  mBO,mII: TNxHeaderBusinessObject;
  i,j,k,l: Integer;
  mInfoList: TStringList;
  mMailAddress: String;
begin
  mType:=1;
  mInfoList := TStringList.Create;
  try
    if GetSiteFromControl(Sender, mSite) then begin
      mForm_Create(mSite);
      mForm.Show;
      mIDs:=TStringList.Create;
      try
        mSite.List.GetSelectedId(mIDs);
        mMemo.Lines.Add(Format('Ke zpracování je celkem %d dokladů.',[mIDs.Count]));
        mMemo.Lines.Add('************************************');
        for i:=0 to mIDs.Count -1 do begin
          try
            mCo:=mSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
            try
              mCo.Load(mIDs[i],nil);
              mMemo.Lines.Add('');
              mMemo.Lines.Add(Format('Zpracování dokladu %s:',[mCO.DisplayName]));
              mResults:=TStringList.Create;
              try
                mResults2:=TStringList.Create;
                try
                  mMailAddress:=mCo.GetFieldValueAsString('X_WEB_Email');
                  if mCo.GetFieldValueAsInteger('X_Stav_Dokladu')=cStorno then begin
                    // áááá, máme tu storno, stav 5
                    if mType<5 then mType:=5;
                  end else begin
                    for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
                      mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
                      if mRow.GetFieldValueAsFloat('DeliveredQuantity')>0 then begin
                        mSite.BaseObjectSpace.SQLSelect(Format('Select Parent_ID From StoreDocuments2 where ProvideRow_ID=''%s'' and Provide_ID=''%s'' group by Parent_ID',[mRow.OID,mCo.OID]),mResults);
                        for k:=0 to mResults.Count -1 do begin
                          mBO:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4')); //DL
                          try
                            mBO.Load(mResults[k],nil);
                            if mBO.GetFieldValueAsBoolean('X_PredanoPP') then begin
                            //předáno přepravní službě, stav 4
                              if mType<4 then mType:= 4;
                            end else begin
                              if mBO.GetFieldValueAsBoolean('IsAvailableForDelivery') then begin
                                if mBO.GetFieldValueAsInteger('X_Stav_Dokladu')=2 then begin
                                  // k Vyskladnění, takže stav 2
                                  if mType<2 then mType:=2;
                                end;
                              end else begin
                                // Faktura, takže stav 3, musíme nahrát předat BO faktury
                                mSite.BaseObjectSpace.SQLSelect(Format('Select Parent_ID From IssuedInvoices2 where Provide_ID=''%s'' group by PArent_ID',[mBO.OID]),mResults2);
                                for l:=0 to mResults2.Count -1 do begin
                                  if mType<3 then mType:=3;
                                end;
                              end;
                            end;
                          finally
                            mBO.Free;
                          end;
                        end;
                      end;
                    end;
                  end;
                  case mType of
                    1: begin
                      CreateAndSend(mSite.SiteContext, mCo, 1, mText, mMailAddress);
                      mMemo.Lines.Add(' - stav 1 - Potvrzení o přijetí');
                      mMemo.Lines.Add(mText);
                    end;
                    2: begin
                      for j:=0 to mResults.Count -1 do begin
                        mBO:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4')); //DL
                        try
                          mBO.Load(mResults[j],nil);
                          CreateAndSend(mSite.SiteContext, mBO, 2, mText, mMailAddress);
                          mMemo.Lines.Add(' - stav 2 - K vyskladnění');
                          mMemo.Lines.Add(mText);
                          if mBO.NeedSave then mBO.Save;
                        finally
                          mBO.Free;
                        end;
                      end;
                    end;
                    3: begin
                      for j:=0 to mResults2.Count -1 do begin
                        mII:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4')); //II
                        try
                          mII.Load(mResults2[j],nil);
                          CreateAndSend(mSite.SiteContext, mII, 3, mText, mMailAddress);
                          mMemo.Lines.Add(' - stav 3 - Vystavená faktura');
                          mMemo.Lines.Add(mText);
                          if mII.NeedSave then mII.Save;
                        finally
                          mII.Free;
                        end;
                      end;
                    end;
                    4: begin
                      for j:=0 to mResults.Count -1 do begin
                        mBO:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4')); //DL
                        try
                          mBO.Load(mResults[j],nil);
                          CreateAndSend(mSite.SiteContext, mBO, 4, mText, mMailAddress);
                          mMemo.Lines.Add(' - stav 4 - Předáno PP');
                          mMemo.Lines.Add(mText);
                          if mBO.NeedSave then mBO.Save;
                        finally
                          mBO.Free;
                        end;
                      end;
                    end;
                    5: begin
                      CreateAndSend(mSite.SiteContext, mCo, 5, mText, mMailAddress);
                      mMemo.Lines.Add(' - stav 5 - storno');
                      mMemo.Lines.Add(mText);
                    end;
                  end;
                  if mCO.NeedValidate then mCO.Save;
                finally
                  mResults2.Free;
                end;
              finally
                mResults.Free;
              end;
            finally
              mCo.Free;
            end;
          except
            mMemo.Lines.Add(ExceptionMessage);
          end;
        end;
      finally
        mIDs.Free;
      end;
    end;
  finally
    mInfoList.Free;
  end;
end;

procedure SendEmailsINI_DEP(Sender: TControl);
var
  mSite: TSiteForm;
  mIDs: TStringList;
  mResults,mResults2: TStringList;
  mText: String;
  mType: Integer;
  mCO, mRow:TNxCustomBusinessObject;
  mBO,mII: TNxHeaderBusinessObject;
  i,j,k,l: Integer;
  mInfoList: TStringList;
  mMailAddress: String;
begin
  mType:=1;
  mInfoList := TStringList.Create;
  try
    if GetSiteFromControl(Sender, mSite) then begin
      mForm_Create(mSite);
      mForm.Show;
      mIDs:=TStringList.Create;
      try
        mSite.List.GetSelectedId(mIDs);
        mMemo.Lines.Add(Format('Ke zpracování je celkem %d dokladů.',[mIDs.Count]));
        mMemo.Lines.Add('************************************');
        for i:=0 to mIDs.Count -1 do begin
          try
            mCo:=mSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
            try
              mCo.Load(mIDs[i],nil);
              mMemo.Lines.Add('');
              mMemo.Lines.Add(Format('Zpracování dokladu %s:',[mCO.DisplayName]));
              mResults:=TStringList.Create;
              try
                mResults2:=TStringList.Create;
                try
                  mMailAddress:=mCo.GetFieldValueAsString('X_WEB_Email');
                  if mCo.GetFieldValueAsInteger('X_Stav_Dokladu')=cStorno then begin
                    // áááá, máme tu storno, stav 5
                    if mType<5 then mType:=5;
                  end else begin
                    for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
                      mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
                      if mRow.GetFieldValueAsFloat('DeliveredQuantity')>0 then begin
                        mSite.BaseObjectSpace.SQLSelect(Format('Select Parent_ID From StoreDocuments2 where ProvideRow_ID=''%s'' and Provide_ID=''%s'' group by Parent_ID',[mRow.OID,mCo.OID]),mResults);
                        for k:=0 to mResults.Count -1 do begin
                          mBO:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4')); //DL
                          try
                            mBO.Load(mResults[k],nil);
                            if mBO.GetFieldValueAsBoolean('X_PredanoPP') then begin
                            //předáno přepravní službě, stav 4
                              if mType<4 then mType:= 4;
                            end else begin
                              if mBO.GetFieldValueAsBoolean('IsAvailableForDelivery') then begin
                                if mBO.GetFieldValueAsInteger('X_Stav_Dokladu')=2 then begin
                                  // k Vyskladnění, takže stav 2
                                  if mType<2 then mType:=2;
                                end;
                              end else begin
                                // Faktura, takže stav 3, musíme nahrát předat BO faktury
                                mSite.BaseObjectSpace.SQLSelect(Format('Select Parent_ID From IssuedInvoices2 where Provide_ID=''%s'' group by PArent_ID',[mBO.OID]),mResults2);
                                for l:=0 to mResults2.Count -1 do begin
                                  if mType<3 then mType:=3;
                                end;
                              end;
                            end;
                          finally
                            mBO.Free;
                          end;
                        end;
                      end;
                    end;
                  end;
                  case mType of
                    1: begin
                      CreateAndSendByINI_DEP(mSite.SiteContext, mCo, 1, mText, mMailAddress);
                      mMemo.Lines.Add(' - stav 1 - Potvrzení o přijetí');
                      mMemo.Lines.Add(mText);
                    end;
                    2: begin
                      for j:=0 to mResults.Count -1 do begin
                        mBO:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4')); //DL
                        try
                          mBO.Load(mResults[j],nil);
                          CreateAndSendByINI_DEP(mSite.SiteContext, mBO, 2, mText, mMailAddress);
                          mMemo.Lines.Add(' - stav 2 - K vyskladnění');
                          mMemo.Lines.Add(mText);
                          if mBO.NeedSave then mBO.Save;
                        finally
                          mBO.Free;
                        end;
                      end;
                    end;
                    3: begin
                      for j:=0 to mResults2.Count -1 do begin
                        mII:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4')); //II
                        try
                          mII.Load(mResults2[j],nil);
                          CreateAndSendByINI_DEP(mSite.SiteContext, mII, 3, mText, mMailAddress);
                          mMemo.Lines.Add(' - stav 3 - Vystavená faktura');
                          mMemo.Lines.Add(mText);
                          if mII.NeedSave then mII.Save;
                        finally
                          mII.Free;
                        end;
                      end;
                    end;
                    4: begin
                      for j:=0 to mResults.Count -1 do begin
                        mBO:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4')); //DL
                        try
                          mBO.Load(mResults[j],nil);
                          CreateAndSendByINI_DEP(mSite.SiteContext, mBO, 4, mText, mMailAddress);
                          mMemo.Lines.Add(' - stav 4 - Předáno PP');
                          mMemo.Lines.Add(mText);
                          if mBO.NeedSave then mBO.Save;
                        finally
                          mBO.Free;
                        end;
                      end;
                    end;
                    5: begin
                      CreateAndSendByINI_DEP(mSite.SiteContext, mCo, 5, mText, mMailAddress);
                      mMemo.Lines.Add(' - stav 5 - storno');
                      mMemo.Lines.Add(mText);
                    end;
                  end;
                  if mCO.NeedValidate then mCO.Save;
                finally
                  mResults2.Free;
                end;
              finally
                mResults.Free;
              end;
            finally
              mCo.Free;
            end;
          except
            mMemo.Lines.Add(ExceptionMessage);
          end;
        end;
      finally
        mIDs.Free;
      end;
    end;
  finally
    mInfoList.Free;
  end;
end;

procedure ImportB2C(Sender: TControl);
var
  mOID: string;
  mFileList: TStrings;
  i, j, mCurrentShop: Integer;
  mXML: Variant;
  mShopStr: String;
  mObj: TNxCustomBusinessObject;
  mObjectSpace: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mInfoList,mErrs: TStringList;
  mSave: Boolean;
begin
  //mExeDir := cSourcePath;
  //mOldDir := GetConstAsString('cXWPostImportPath');
  mInfoList := TStringList.Create;
  mFileList := TStringList.Create;
  mErrs := TStringList.Create;
  try
    if GetSiteFromControl(Sender, mSite) then begin
      mObjectSpace := mSite.BaseObjectSpace;
      mForm_Create(mSite);
      mForm.Show;

      NxGetFileList(cSourcePath, mFileList, '*.XML');
      mMemo.Lines.Add('Zpracování souborů z adresáře ' + cSourcePath);
      mMemo.Lines.Add(NxReplicate('-',Length(cSourcePath) + Length('Zpracování souborů z adresáře ')));
      mMemo.Lines.Add('');
      if mFileList.Count = 0 then begin
        mMemo.Lines.Add('Nebyly nalezeny žádné XML soubory pro import. KONEC.');
        mMemo.Lines.Add('');
        mMemo.Lines.Add('');
        mMemo.Lines.Add('Okno zavřete pomocí křížku v pravém horním rohu.');
        Exit;
      end;
      mMemo.Lines.Add('Byly nalezeny celkem ' + IntToStr(mFileList.Count) + ' soubory ke zpracování.');
      mMemo.Lines.Add('');

      for i := 0 to mFileList.Count - 1 do begin
        mErrs.Clear;
        mMemo.Lines.Add('-- ' + IntToStr(i+1) + '/' + IntToStr(mFileList.Count) + ' ---');
        mMemo.Lines.Add('');
        mMemo.Lines.Add('Zpracování souboru ' + mFileList[i] + ' ...');
        mXML := CreateOLEObject('Msxml2.DOMDocument');
        mXML.load(NxAddSlash(cSourcePath) + mFileList[i]);
        mObj := mObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //Objednávka přijatá
        try
          mOID:=ImportOrder(mObjectSpace, mXML, mErrs, mSave);
          if mSave then mObj.Load(mOID,nil);
          //mObj := CreateBO_IIFromXML(mXML, mOLE, mPars, mOS, True, mInfoList, mFileList[i]);
          mMemo.Lines.Add('Ukládání Objednávky přijaté ...');
          //For j:=0 to mErrs.Count -2 do
          if mErrs.Count>0 then
            mMemo.Lines.AddStrings(mErrs);
          //mObj.Save;
          mMemo.Lines.Add(' ');
          If mSave then begin
            //mObj.Save;
            mShopStr:=TNxHeaderBusinessObject(mObj).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.X_Zkratka');
            mMemo.Lines.Add('--> Uložen doklad ' + mObj.DisplayName + ' <--');
            if mObj.GetFieldValueAsString('PaymentType_ID')=cPlatbaZalohy then begin
              if not(RenameFile(NxAddSlash(cSourcePath) + mFileList[i], NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr) + mFileList[i])) then mMemo.Lines.Add(Format('Nepodařilo se přesunout soubor %s do adresáře %s!',[mFileList[i],NxAddSlash(cZalohaPath)]));
              mMemo.Lines.Add('--> Rezervace vytvořena a XML zkopírován <--');
            end else begin
              if not(RenameFile(NxAddSlash(cSourcePath) + mFileList[i], NxAddSlash(Format(cDonePath,[mShopStr])) + mFileList[i])) then mMemo.Lines.Add(Format('Nepodařilo se přesunout soubor %s do adresáře %s!',[mFileList[i],Format(cDonePath,[mShopStr])]));;
            end;
          end else begin
            mMemo.Lines.Add('--> Neuloženo, zkontrolujte chybové hlášení.  <--');
          end;
          mMemo.Lines.Add('');
        finally
          mObj.Free;
        end;
      end; // for i
      mMemo.Lines.Add('');
      mMemo.Lines.Add('Okno zavřete pomocí křížku v pravém horním rohu.');
    end;
  finally
    mFileList.Free;
    mInfoList.Free;
    mErrs.Free;
  end;
end;

procedure MultiImportB2C(Sender: TControl; Index: Integer);
begin
  case Index of
    0: ImportB2C(Sender);
    1: SendEmails(Sender);
    2: StornoRO(Sender);
    3: ExportFV(Sender);
    4: SendEmailsINI_DEP(Sender);
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var myMultiAction: TMultiAction;
    mAList: TActionList;
    i: integer;
    mAction: TBasicAction;
    mControl: TControl;
begin
  myMultiAction:= Self.GetNewMultiAction;
  myMultiAction.Name:= 'actBOMAB2CImport';
  myMultiAction.ShowControl:= True;
  myMultiAction.ShowMenuItem:= True;
  myMultiAction.Caption:= 'Import B2C';
  myMultiAction.Hint:='Import z e-shopu solidni-obchod.cz';
  myMultiAction.Category:= 'tabList';
  myMultiAction.Items.Add('Import B2C');
  myMultiAction.Items.Add('Odeslání Emailu');
  myMultiAction.Items.Add('Storno Objednávky');
  myMultiAction.Items.Add('B2B Export FV');
  myMultiAction.Items.Add('Odeslání Emailu - TEST nového způsobu');
  //myMultiAction.Items.Add('Zrušit rezervace');
  myMultiAction.OnExecuteItem:= @MultiImportB2C;
  //myMultiAction.OnUpdate := @OnUpdateDetail;
end;

procedure OnUpdateDetail(Sender: TControl);
var
  mSite: TSiteForm;
begin
  mSite := Sender.Site;
  if Assigned(mSite) then begin
    if mSite is TDynSiteForm then begin
      TBasicAction(Sender).Enabled := TDynSiteForm(mSite).Edit;
    end;
  end;
end;

begin
end.