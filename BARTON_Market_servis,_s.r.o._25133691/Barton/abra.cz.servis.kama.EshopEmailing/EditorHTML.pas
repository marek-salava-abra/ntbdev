const
  cAppPath = ExtractFilePath(ParamStr(0))+ 'HTMLEditor\';
  cAppExeName = cAppPath + 'WYSIWYG.exe';
  cOleInstaller = cAppPath + 'Install\x-lite.exe';
  cGUID_XStandard = '{0EED7206-1661-11D7-84A3-00606744831D}';
  cMBCaption = 'Chyba';
  cMBMessage = 'Pravděpodobně nemáte nainstalovaný doplněk x-lite potřebný pro provoz aplikace'#13#10'Přejete si spustit instalaci?';


procedure CallButtonBody(Self: TSiteForm);
begin
  EditWYSIWYG(Self, 'X_EmailBody');
end;

procedure CallButtonRows(Self: TSiteForm);
begin
  EditWYSIWYG(Self, 'X_EmailRows');
end;

procedure EditWYSIWYG(Self: TSiteForm; AFieldName: String);
var
  mSite: TSiteForm;
  mSCSite: TBusRollSiteForm;
  mStrings: TStringList;
  mFileName, mExeName: String;
  mControl: TControl;
  mBO: TNxCustomBusinessObject;
begin
  if Assigned(Self) then begin
    mSite := Self;
    if not CheckComObj then begin
      if ConfirmInstall then begin
        OutputDebugString('Instalace potvrzena pro: ' + cOleInstaller);
        if FileExists(cOleInstaller) then begin
          OutputDebugString('Instalator nalezen: ' + cOleInstaller);
          if NxExecFile(cOleInstaller, False, True) then begin
            OutputDebugString('Instalace provedena: ' + cOleInstaller);
          end else begin
            OutputDebugString('Instalace neprovedena: ' + cOleInstaller);
            Showmessage('Instalace selhala, soubor "' + cOleInstaller + '. O instalaci požádejte administrátora');
          end;
        end else
          Showmessage('Instalace selhala, soubor "' + cOleInstaller + '" nenalezen');
      end;
    end else begin
      if not FileExists(cAppExeName) then begin
        Showmessage('Aplikace nenalezena: ' + cAppExeName);
        exit;
      end;
      mSCSite := TBusRollSiteForm(mSite);
      if mSCSite.Edit then begin
        if (Copy(AFieldName, 1, 2) = 'X_') or (Copy(AFieldName, 1, 2) = 'U_') then begin
          mControl := NxFindChildControl(NxGetSiteAppForm(mSite), 'mem'+AFieldName);
        end else
          mControl := NxFindChildControl(NxGetSiteAppForm(mSite), 'memoComment');
        mStrings := TStringList.Create;
        try
          //mBO := TBusRollSiteForm(mSite).DataSet.CurrentObject;
          //mStrings.Text := mBO.GetFieldValueAsString(AFieldName);
          OutputDebugString(mControl.Name) ;
          mStrings.Text := TMemo(mControl).DataSource.DataSet.FieldByName(AFieldName).AsString;
          if NxCreateTempFile(mFileName) then begin
            mStrings.SaveToFile(mFileName);
            //ExeName
            mExeName := GetAppPath;
            //Param
            mExeName := mExeName + ' "f:' + mFileName+ '"';
            NxExecFile(mExeName, false, true);
            if FileExists(mFileName) then begin
              mStrings.LoadFromFile(mFileName);
              //mBO.SetFieldValueAsString(AFieldName, mStrings.Text);
              TMemo(mControl).DataSource.DataSet.FieldByName(AFieldName).AsString := mStrings.Text;
              //RefreshDataSet(mSite);
            end;
            DeleteFile(mFileName);
          end;
        finally
          mStrings.Free;
        end;
      end;
    end;
  end;
end;



procedure RefreshDataSet(ASite: TSiteForm);
begin
  TBusRollSiteForm(ASite).DataSet.RefreshCurrentItem;
end;

function ConfirmInstall: Boolean;
begin
  Result := MessageDlg(cMBMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function GetAppPath: String;
begin
  Result := cAppExeName;
end;

function CheckComObj: Boolean;
begin
  try
    CreateComObject(cGUID_XStandard);
    Result := True;
  except
    Result := False;
  end;
end;


begin
end.
