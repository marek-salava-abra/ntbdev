uses 'eu.abra.exportpictures.progress';

procedure MojeCopyOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mObj: TNxCustomBusinessObject;
begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');
      if mSite is TBusRollSiteForm then begin
        // Ziskame aktualni objekt (TNxCustomBusinessObject)
        mObj := TBusRollSiteForm(mSite).DataSet.CurrentObject;
        if Assigned(mObj) then begin
                   GetEmployeesPicture(mObj.ObjectSpace, msite);
        end;
      end;
    end;
  end;
end;


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  // Nastavime, aby se tato akce zobrazovala jako tlacitko
  mAction.ShowControl := True;
  // Nastavime, aby se tato akce zobrazila v menu
  mAction.ShowMenuItem := True;
  // Nastavime nadpis tlacitka
  mAction.Caption := 'Export obrázků';
  // Nastavime hint
  mAction.Hint := 'Export';
  // Nastavime, aby se tato akce nabizela na zalozkach Seznam a Detail
  mAction.Category := 'tabDetail, tabList';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @MojeCopyOnExecute;


end;

function GetEmployeesPicture(aobjspace: TNxCustomObjectSpace; aSite: TSiteForm): string;
  function GetExtension(mExt: string): string;
  begin
    if mExt = 'TJPEGImage' then
      Result:= 'jpg';
    if mExt = 'TPNGImage' then
      Result:= 'png';
  end;

var
  mFileStream: TFileStream;
  mFieldValue: TNxParameters;
  mFieldName, mRes: TStringList;
  mPictureID, mSQL, mS, mExt: string;
  mBO: TNxCustomBusinessObject;
  p1, p2: Pointer;
  j,k: Integer;

begin
  if DirectoryExists('d:\wamp\www\images\') then begin
  Result:= '';
  begin
    mSQL:= 'select A.Picture_ID from StorecardPICTURES A';
  end;
  mRes:= TStringList.Create;
  mPictureID:= '0000000000';
  try
    aObjSpace.SQLSelect(mSQl, mRes);
    ProgressInit(aSite, 'Příprava obrázků...', mRes.count);
    if mRes.Count > 0 then
      begin

      for k:=0 to mres.count -1 do begin

      mPictureID:= mRes[k];

      mFieldValue:= TNxParameters.Create;
      mFieldName:= TStringList.Create;
      try
    mFieldName.Text:= 'BlobData';
    mBO:= aObjSpace.CreateObject('S1AUUMOM3REL3C5V00CA141B44');
    try
      mBO.Load(mPictureID, nil);
      if mBO.GetFieldValueAsBoolean('ExternalFile') then begin
       if FileExists(mbo.GetFieldValueAsString('PathAndFileName')) then begin
          NxCopyFile(mbo.GetFieldValueAsString('PathAndFileName'), NxSearchReplace(mbo.GetFieldValueAsString('PathAndFileName'),'\\192.168.101.20\public\E-Shop-Data\obrázky\','d:\wamp\www\images\',[srAll]));


       end;
      end;
      if not(mbo.GetFieldValueAsBoolean('ExternalFile')) then begin
      mBO.GetFields(mFieldName, mFieldValue);
      mBO.GetFieldValues(mFieldValue);
      mS:= mFieldValue.Params[0].AsString;
      if Length(mS) > 4 then
      begin
        //ShowDebugMessage('Create image file ' + aEmployees_ID);
        p1:= @J;
        p2:= @mS;
        move(p2, p1, 4);
        mExt:= Copy(mS, 5, j);
        Result:= 'd:\wamp\www\images\'+mPictureID+ '.jpg'; //+ GetExtension(mExt);
        mFileStream:= TFileStream.Create(Result, fmCreate, 0);
        try
          NxWriteString(mFileStream, Copy(mS, 5 + j, Length(mS)));
        finally
         mFileStream.Free;
        end;
      end;
      end;
    finally
      mBO.Free;
      ProgressSetPos(k+1);
    end;
  finally
    mFieldName.Free;
    mFieldValue.Free;

 end;
   end;


      End;
  finally
    mRes.Free;
    ProgressDispose();
  end;
  if NxIsEmptyOID(mPictureID) then
  begin
    //ShowDebugMessage('Err: ' + mSQL);
    Exit;
  end;
 end;
end;
begin
end.