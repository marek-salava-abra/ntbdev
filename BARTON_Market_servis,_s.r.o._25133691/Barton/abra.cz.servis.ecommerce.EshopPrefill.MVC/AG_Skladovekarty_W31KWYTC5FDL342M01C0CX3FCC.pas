uses
  'abra.cz.servis.ecommerce.EshopPrefill.MVC.Common';

procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Eshop změny';
  mMAction.Hint := 'Eshop - založení folderu, kopie cest k obrázkům, dokumentům apod.';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @EshopClick;
  mMAction.Items.Add('Nápověda k funkci');
  mMAction.Items.Add('Založení folderu');
  mMAction.Items.Add('Kopie cest k obrázkům');
  mMAction.Items.Add('Kopie cest k dokumentům');
  mMAction.Items.Add('Nastavit výchozí cestu k obrázkům');
  mMAction.Items.Add('Nastavit výchozí cestu k dokumentům');
  mMAction.Items.Add('Kopie poznámky');
  mMAction.Items.Add('Kopie paramerů');
end;

procedure EshopClick(Sender: TObject; AIndex: integer);
var
  I: Integer;
  mBo, mBoCloned: TNxCustomBusinessObject;
  mFoldersOK: Boolean;
  mGx: Variant;
  mRoll: Variant;
  mRollScp: TNxBusinessRoll;
  mSiteForm: TBusRollSiteForm;
  mSourceSC_ID: String;
  mSCsource: TNxCustomBusinessObject;
  mSCtarget: TNxCustomBusinessObject;
  mSelList: TStringList;
  mSqlData, mSqlSource: TMemoryDataset;
  mParProperty_ID : String;
  mParStorecardType_ID : String;
begin
  try
    if AIndex = 0 then begin
      NxMessageBox('Nápověda',
        'a) Postup pro založení folderu: ' +CHR(13)+
        'Označte jednu nebo více karet a zvolte funkci založit folder.' +CHR(13)+
        CHR(13)+
        'b) Postup pro kopírování: ' +CHR(13)+
        '1. Označte karty, které si přejete měnit. ' +CHR(13)+
        '2. V multiakci Eshop kopie vyberte příslušnou funkci. ' +CHR(13)+
        '3. Vyberte zdrojovou kartu, ze které mají být vlastnosti kopírovány.' +CHR(13)+
        CHR(13)+
        'Jednotlivé funkce vyvoláte pomocí multiakce (šipečky) u tlačítka "Eshop změny"', mdInformation, mdbOk, 1, [mdpSystemModal], False, nil);
    end else begin
      mSiteForm := TBusRollSiteForm(TComponent(Sender).Site);
      if Assigned(mSiteForm) then begin
        mSelList := TStringList.Create;
        mSiteForm.list.GetSelectedId(mSelList);
        if mSelList.Count > 0 then begin

          if AIndex > 0 then begin
            // ZALOZENI FOLDERU
            if AIndex = 1 then begin
              if NxMessageBox('Dotaz', 'Přejete si založit folder k označeným kartám? ', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                mFoldersOK := True;
                for I := 0 to (mSelList.Count - 1) do begin
                  mSCtarget := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                  mSCtarget.Load(mSelList.Strings[I], nil);
                  if CallCreateScFolder(mSCtarget, True) then else begin
                     mFoldersOK := False;
                    // Chybovou hlasku vrati finalne volana funkce CreateEshopFolder2.
                  end;
                end;
                if mFoldersOK then begin
                  NxMessageBox('Informace', 'Vytvoření cest k obrázkům bylo dokončeno.', mdInformation, mdbOK, 2, [mdpSystemModal], False, nil);
                end;
              end;
            end;
          end;
          
          // KOPIROVACI FUNKCE
          if (AIndex = 2) or (AIndex = 3) or (AIndex = 6) or (AIndex = 7) then begin
            // Dotaz na zdrojovou kartu
            mGx := GetAbraOLEApplication;
            mSourceSC_ID := '0000000000';
            mRoll := mGx.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 3);
            mSourceSC_ID := mRoll.SelectDialog2(True, mSourceSC_ID);
            if (mSourceSC_ID <> '0000000000') and (mSourceSC_ID <> '') then begin
              // Zjisteni kodu a nazvu pro dialog
              mSqlData := TMemoryDataset.Create(nil);
              mSiteForm.BaseObjectSpace.SQLSelect2('SELECT A.Code, A.Name FROM StoreCards A WHERE A.ID = '+QuotedStr(mSourceSC_ID), mSqlData);

              // KOPIE CEST K OBRAZKUM
              if AIndex = 2 then begin
                mSCsource := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                mSCsource.Load(mSourceSC_ID, nil);
                if (mSCsource.GetFieldValueAsString('X_ImagesPath') <> '') then begin
                  if NxMessageBox('Dotaz', 'Přejete si zkopírovat cestu k obrázkům z ' +
                                            mSqlData.FieldByName('Code').AsString+' '+mSqlData.FieldByName('Name').AsString +
                                            ' na označené karty?', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                    for I := 0 to (mSelList.Count - 1) do begin
                      mSCtarget := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                      mSCtarget.Load(mSelList.Strings[I], nil);
                      mSCtarget.SetFieldValueAsString('X_ImagesPath', mSCsource.GetFieldValueAsString('X_ImagesPath'));
                      mSCtarget.Save;
                    end;
                    if NxMessageBox('Dotaz', 'Kopie cest k obrázkům byla dokončena. Občerstvit agendu ?'  + CHR(13) +CHR(13)+
                        '(Při občersvení dojde k odznačení záznamů. Chcete-li s označenými zaznamy provést jinou hromadou změnu, tak zvolte ne.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                      mSiteForm.RefreshData;
                    end;
                  end;
                end else begin
                  ShowMessage('Vybraná zdrojová karta má prázdnou cestu k obrázkům. Není co kopírovat.')
                end;
              end;

              // KOPIE CEST K DOKUMENTUM
              if AIndex = 3 then begin
                mSCsource := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                mSCsource.Load(mSourceSC_ID, nil);
                if (mSCsource.GetFieldValueAsString('X_DocumentsPath') <> '') then begin
                  if NxMessageBox('Dotaz', 'Přejete si zkopírovat cestu k dokumentům z ' +
                                            mSqlData.FieldByName('Code').AsString+' '+mSqlData.FieldByName('Name').AsString +
                                            ' na označené karty?', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                    for I := 0 to (mSelList.Count - 1) do begin
                      mSCtarget := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                      mSCtarget.Load(mSelList.Strings[I], nil);
                      mSCtarget.SetFieldValueAsString('X_DocumentsPath', mSCsource.GetFieldValueAsString('X_DocumentsPath'));
                      mSCtarget.Save;
                    end;
                    if NxMessageBox('Dotaz', 'Kopie cest k dokumentům byla dokončena. Občerstvit agendu ?'  + CHR(13) +CHR(13)+
                        '(Při občersvení dojde k odznačení záznamů. Chcete-li s označenými zaznamy provést jinou hromadou změnu, tak zvolte ne.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                      mSiteForm.RefreshData;
                    end;
                  end;
                end else begin
                  ShowMessage('Vybraná zdrojová karta má prázdnou cestu k dokumentům. Není co kopírovat.')
                end;
              end;

            end;
          end;

          // KOPIE POZNAMKY
          if AIndex = 6 then begin
            mSCsource := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
            mSCsource.Load(mSourceSC_ID, nil);
            if (mSCsource.GetFieldValueAsString('X_Note') <> '') then begin
              if NxMessageBox('Dotaz', 'Přejete si zkopírovat poznámku z karty ' +
                                        mSqlData.FieldByName('Code').AsString+' '+mSqlData.FieldByName('Name').AsString +
                                        ' na označené karty?' + CHR(13)+ CHR(13)+
                                        ('Upozornění: Poznámka na cílových kartách bude kompletně přepsána poznámkou ze zdrojové karty.'), mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                for I := 0 to (mSelList.Count - 1) do begin
                  mSCtarget := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                  mSCtarget.Load(mSelList.Strings[I], nil);
                  mSCtarget.SetFieldValueAsString('X_Note', mSCsource.GetFieldValueAsString('X_Note'));
                  mSCtarget.Save;
                end;
                if NxMessageBox('Dotaz', 'Kopie poznámky byla dokončena. Občerstvit agendu ?'  + CHR(13) +CHR(13)+
                    '(Při občersvení dojde k odznačení záznamů. Chcete-li s označenými zaznamy provést jinou hromadou změnu, tak zvolte ne.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                  mSiteForm.RefreshData;
                end;
              end;
            end else begin
              ShowMessage('Vybraná zdrojová karta má prázdnou poznámku. Není co kopírovat.')
            end;
          end;

          // PUVDONI CESTA K OBRAZKUM
          // Standardni cesta - zde se pouze vymaze puvodni cesta, skript v EshopPrefillCustom
          // doplni cestu dle konretni firmy, default je code.
          if AIndex = 4 then begin
            if NxMessageBox('Dotaz', 'Přejete si nastavit výchozí cestu k obrázkům u označených karet?' + CHR(13) +CHR(13)+
                                     '(Odkaz na obrázky v současné cestě bude vymazán.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
              for I := 0 to (mSelList.Count - 1) do begin
                mSCtarget := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                mSCtarget.Load(mSelList.Strings[I], nil);
                mSCtarget.SetFieldValueAsString('X_ImagesPath', '');
                mSCtarget.Save;
              end;
              if NxMessageBox('Dotaz', 'Nastavení cest k obrázkům bylo dokončeno. Občerstvit agendu ?'  + CHR(13) +CHR(13)+
                 '(Při občersvení dojde k odznačení záznamů. Chcete-li s označenými zaznamy provést jinou hromadou změnu, tak zvolte ne.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                mSiteForm.RefreshData;
              end;
            end;
          end;

          // PUVDONI CESTA K DOKUMENTUM
          // Standardni cesta - zde se pouze vymaze puvodni cesta, skript v EshopPrefillCustom
          // doplni cestu dle konretni firmy, default je code.
          if AIndex = 5 then begin
            if NxMessageBox('Dotaz', 'Přejete si nastavit výchozí cestu k dokumentům u označených karet?' + CHR(13) +CHR(13)+
                            '(Odkaz na dokumenty v současné cestě bude vymazán.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
              for I := 0 to (mSelList.Count - 1) do begin
                mSCtarget := mSiteform.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                mSCtarget.Load(mSelList.Strings[I], nil);
                mSCtarget.SetFieldValueAsString('X_DocumentsPath', '');
                mSCtarget.Save;
              end;
              if NxMessageBox('Dotaz', 'Nastavení cest k dokumentům bylo dokončeno. Občerstvit agendu ?'  + CHR(13) +CHR(13)+
                 '(Při občersvení dojde k odznačení záznamů. Chcete-li s označenými zaznamy provést jinou hromadou změnu, tak zvolte ne.)', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                mSiteForm.RefreshData;
              end;
            end;
          end;

          // KOPIE PARAMETRU Z JEDNE KARTY NA OZNACENE
          if (AIndex = 7) then begin
                if mSqlData.RecordCount > 0 then begin
                  if NxMessageBox('Dotaz', 'Přejete si zkopírovat vlastnosti z karty ' +
                                            mSqlData.FieldByName('Code').AsString+' '+mSqlData.FieldByName('Name').AsString +
                                            ' na označené karty ?', mdConfirm, mdbYesNo, 2, [mdpSystemModal], False, nil) = 6 then begin
                    mParProperty_ID := GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString;
                    mParStorecardType_ID := GlobParams.GetOrCreateParam(dtString, 'ParStorecardType_ID').AsString;
                    GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
                    GlobParams.GetOrCreateParam(dtString, 'ParStorecardType_ID').AsString := '';

                    // Nacteni vlastnosti zdrojove karty
                    mSqlSource := TMemoryDataset.Create(nil);
                    mSiteForm.BaseObjectSpace.SQLSelect2('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + QuotedStr('CROP15BJD5VOB5AKA0X2MBJIVW')+' AND A.X_StoreCard_ID = ' + QuotedStr(mSourceSC_ID), mSqlSource);
                    if mSqlSource.RecordCount > 0 then begin
                      for I := 0 to (mSelList.Count - 1) do begin
                        // Smazani existujich vlastnosti
                        {if AIndex = 1 then begin
                          mSqlData := TMemoryDataset.Create(nil);
                          mSiteForm.BaseObjectSpace.SQLSelect2('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + QuotedStr('CROP15BJD5VOB5AKA0X2MBJIVW')+' AND A.X_StoreCard_ID = ' + QuotedStr(mSelList.Strings[I]), mSqlData);
                          if mSqlData.RecordCount > 0 then begin
                            mSqlData.First;
                            while not mSqlData.Eof do begin
                              mBo := mSiteForm.BaseObjectSpace.CreateObject('CROP15BJD5VOB5AKA0X2MBJIVW');
                              mBo.Load(mSqlData.FieldByName('ID').AsString, nil);
                              mBo.Delete;
                              mSqlData.Next;
                            end;
                          end;
                        end;}
                        // Samotne prekopirovani vlastnosti na cilovou kartu...
                        // Pokud je zvoleno doplneni, nactou se do mSqlSource pouze chybejici vlastnosti
                        {if AIndex = 0 then begin
                          mSqlSource := TMemoryDataset.Create(nil);
                          mSiteForm.BaseObjectSpace.SQLSelect2('SELECT A.ID' +
                                                                ' FROM DefRollData A'+
                                                                ' WHERE A.CLSID = ' + QuotedStr('CROP15BJD5VOB5AKA0X2MBJIVW') +
                                                                  ' AND A.X_StoreCard_ID = ' + QuotedStr(mSourceSC_ID) +
                                                                  ' AND A.X_Property_ID NOT IN'+
                                                                  ' (SELECT A.X_Property_ID FROM DefRollData A WHERE A.CLSID = ' + QuotedStr('CROP15BJD5VOB5AKA0X2MBJIVW')+' AND A.X_StoreCard_ID = ' + QuotedStr(mSelList.Strings[I]) +')', mSqlSource);
                        end;}
                        if mSqlSource.RecordCount > 0 then begin
                          mSqlSource.First;
                          while not mSqlSource.Eof do begin
                            mBo := mSiteForm.BaseObjectSpace.CreateObject('CROP15BJD5VOB5AKA0X2MBJIVW');
                            mBo.Load(mSqlSource.FieldByName('ID').AsString, nil);
                            mBoCloned := mSiteForm.BaseObjectSpace.CreateObject('CROP15BJD5VOB5AKA0X2MBJIVW');
                            mBoCloned := mBo.Clone;
                            mBoCloned.SetFieldValueAsString('X_StoreCard_ID', mSelList.Strings[I]);
                            mBoCloned.Save;
                            mSqlSource.Next;
                          end;
                        end;
                      end;
                      // Obcesveni ciselniku vlastnosti
                      mRollScp := mSiteForm.SiteContext.GetRoll('HKPFGRKK4BIO15MWPDII1TWKOK', 0);
                      mRollScp.Reload;
                      NxMessageBox('Informace', 'Kopie vlastností byla dokončena', mdInformation, mdbOk, 1, [mdpSystemModal], False, nil)
                    end else begin
                      ShowMessage('Vybraná zdrojová karta nemá žádné vlastnosti. Není co kopírovat.')
                    end;

                    GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := mParProperty_ID;
                    GlobParams.GetOrCreateParam(dtString, 'ParStorecardType_ID').AsString := mParStorecardType_ID;
                  end;
                end;
            end;

        end else begin
          ShowMessage('Nejsou označeny žádné záznamy.');
        end;
      end else begin
        ShowMessage('Nenalezen "siteform". ');
      end;
    end;
  finally
    I := nil;
    mGx := nil;
    mRoll := nil;
    mRollScp := nil;
    mSiteForm := nil;
    mSCsource := nil;
    mSCtarget := nil;
    mSourceSC_ID := nil;
    mSelList := nil;
    mSqlData := nil;
    mSqlSource := nil;
  end;
end;

begin
end.