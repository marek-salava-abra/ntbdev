procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Exportovat OVCreaton';
mBut.Category := 'tabList';
mBut.OnExecute := @ExportOV;

end;

procedure ExportOV(sender:TComponent);
var
 mSite:TSiteForm;
 mList, mEmptyCard:TstringList;
 mOS:TNxCustomObjectSpace;
 mBO, mUser:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mContext:TNxContext;
 mFTP:TFTP;
 mFileName, mDestFile, mErrorCard:String;
 i:Integer;
 mError:Boolean;
begin
  mSite:=TComponent(sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  mOS:=mBO.ObjectSpace;
  mError:=False;
  mErrorCard:='Následující karty nemají vyplněny externí kód: ';
   if Assigned(mBO) then begin
   if NxMessageBox('Dotaz','Přejete si exportovat objednávku? '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
    mUser:=mBO.ObjectSpace.CreateObject(Class_SecurityUser);
    mUser.Load(NxGetActualUserID_1(mBO),nil);
   if NxIsBlank(mbo.GetFieldValueAsString('Firm_ID.U_ExportDir')) then begin
    NxShowSimpleMessage('Pro tohoto dodavatele nelze objednávku exportovat.(není přiřazen exportní adresář pro firmu)  ' +mbo.GetFieldValueAsString('Firm_ID.Name'),mSite);
    exit;
   end;
   if NxIsBlank(mUser.GetFieldValueAsString('U_ExportDir')) then begin
    NxShowSimpleMessage('Nemáte právo exportovat objednávku (není přiřazen exportní adresář pro uživatele). ' +mUser.GetFieldValueAsString('Name'),mSite);
    exit;
   end;
   if NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID.U_Export_ID')) then begin
    NxShowSimpleMessage('Pro tohoto dodavatele nelze objednávku exportovat.(není vytvořena exportní definice pro firmu) ' +mbo.GetFieldValueAsString('Name'),mSite);
    exit;
   end;
   if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID.U_Export_ID'))) then begin
    mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));

    for i:=0 to mrows.Count-1 do begin
        mEmptyCard:=TStringList.Create;
          mOS.SQLSelect(Format('Select ExternalNumber from Suppliers where StoreCard_ID=''%s'' and firm_id=''%s'' ',[mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'),mbo.GetFieldValueAsString('Firm_ID')]),mEmptyCard);
          if mEmptyCard.Count=0 then begin
           mErrorCard:=mErrorCard+Chr(10)+Chr(13)+mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.Code') +' '+mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.Name');
           mError:=True;
          end;
          if mEmptyCard.count>0 then begin
           if NxIsBlank(mEmptyCard.Strings[0]) then begin
            mErrorCard:=mErrorCard+Chr(10)+Chr(13)+mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.Code') +' '+mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.Name');
            mError:=True;
           end;
          end;
        mEmptyCard.free;
    end;
    if mError then NxShowSimpleMessage(mErrorCard,mSite);
    mList:=TStringList.Create;
    mlist.Add(mBO.OID);
    mOS:=mbo.ObjectSpace;
    mFileName:=NxGetTempDir+NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.csv';
    mDestFile:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.csv';
    if mlist.Count>0 then begin

      CFxReportManager.ExportByIDs(NxCreateContext_1(mbo),mList,'W0NZQGROZZDL342X01C0CX3FCC',mbo.GetFieldValueAsString('Firm_ID.U_Export_ID'),0,'',mFileName);
      mFTP:= TFTP.Create;
      mFTP.Host:='91.239.200.220';
      mFTP.Port:=21;
      mftp.UserName:='export_obb_cz';
      mFTP.Password:='hyNUvkuw65987oziT';
      mftp.Connect;
      mFTP.Passive:=true;
      try
      mFTP.MakeDir(muser.GetFieldValueAsString('U_ExportDir'));
      except
      end;
      mFTP.ChangeDir(muser.GetFieldValueAsString('U_ExportDir'));
      try
      mFTP.MakeDir(mbo.GetFieldValueAsString('Firm_ID.U_ExportDir'));
      except
      end;
      mftp.ChangeDirUp;
      mftp.Put(mfilename, muser.GetFieldValueAsString('U_ExportDir')+'/'+mbo.GetFieldValueAsString('Firm_ID.U_ExportDir')+'/'+mDestFile);
    end;
    NxShowSimpleMessage('Export byl dokončen. Soubor naleznete ve složce abra export na svém počítači. Soubor se ukládá pouze do složky na stálém počítači uživatele, který export provedl. ',mSite);
    end;
    end;
   end;
end;


begin
end.