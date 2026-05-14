uses 'eu.abra.boma.netcentrum.maildoc','eu.abra.boma.netcentrum.common';

procedure AfterSave_Hook(Self: TNxHeaderBusinessObject);
var
  i: Integer;
  mRO,mRowBO: TNxCustomBusinessObject;
  mROIDs, mRowBOs: TStringList;
  mOID, mMailAddress: String;
begin
  if Self.GetFieldValueAsString('Firm_ID')=cFirm_ID then begin
    if osNew in Self.State then begin
      MakeISDOCII_NC(Self.ObjectSpace,Self.OID);
    end;
    Self.SetFieldValueAsString('X_MailAddress','NetCentrum@aftersave.eu');
  end;
  if Self.GetFieldValueAsString('Firm_ID')=cFirmTS_ID then begin
    if osNew in Self.State then begin
      MakeISDOCII_TS(Self.ObjectSpace,Self.OID);
    end;
    Self.SetFieldValueAsString('X_MailAddress','technistore@aftersave.eu');
  end;
end;
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}

procedure _BeforeDelete_PreHook(Self: TNxHeaderBusinessObject);
var
  i: Integer;
  mRO,mRowBO: TNxCustomBusinessObject;
  mROIDs, mRowBOs: TStringList;
  mOID, mMailAddress: String;
begin
  mRowBOs:=TStringList.Create;
  mROIDs:=TStringList.Create;
  try
    for i:=0 to Self.Rows.Count -1 do begin
     mOID:=Self.Rows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID');
      if mRowBOs.IndexOf(mOID)= -1 then
        if not(NxIsEmptyOID(mOID)) then
          mRowBOs.Append(mOID);
    end;
    for i:=0 to mRowBOs.Count -1 do begin
      mRowBO:=Self.ObjectSpace.CreateObject('0H0I5SAOS3DL3ACU03KIU0CLP4'); //řádek DL
      try
        mRowBO.Load(mRowBOs[i],nil);
        mOID:=mRowBO.GetFieldValueAsString('Provide_ID');
        if mROIDs.IndexOf(mOID)= -1 then
          if not(NxIsEmptyOID(mOID)) then
            mROIDs.Append(mOID);
      finally
        mRowBO.Free;
      end;
    end;
    for i:=0 to mROIDs.Count -1 do begin
      mRO:=Self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //OP
      try
        mRO.Load(mROIDs[i],nil);
        if mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=3 then begin
          mRO.SetFieldValueAsInteger('X_WEB_Stav_Dokladu',2);
        end;
        //if mRO.NeedSave then mRO.Save;
      finally
        mRO.Free;
      end;
    end;
  finally
    mRowBOs.Free;
    mROIDs.Free;
  end;
end;

{
Vyvolává se na konci uložení objektu (i v případě výskytu výjimky)

procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
begin
  Self.SetFieldValueAsString('X_MailAddress',Self.GetFieldValueAsString('X_MailAddress')+'_FinalizeSave_PreHook');
end;

procedure _SaveChildren_PostHook(Self: TNxCustomBusinessObject);
begin
  Self.SetFieldValueAsString('X_MailAddress',Self.GetFieldValueAsString('X_MailAddress')+'_SaveChildren_PostHook');
end;

procedure _SaveChildren_PreHook(Self: TNxCustomBusinessObject);
begin
  Self.SetFieldValueAsString('X_MailAddress',Self.GetFieldValueAsString('X_MailAddress')+'_SaveChildren_PreHook');
end;

procedure _AfterDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
begin
  Self.SetFieldValueAsString('X_MailAddress',Self.GetFieldValueAsString('X_MailAddress')+'_AfterDwarfSave_Hook');
end;
}
{
procedure AfterSave_Hook(Self: TNxHeaderBusinessObject);
var
  i: Integer;
  mRO,mRowBO: TNxCustomBusinessObject;
  mROIDs, mRowBOs: TStringList;
  mOID, mMailAddress: String;
begin
  if Self.GetFieldValueAsString('Firm_ID')=cFirm_ID then begin
    if osNew in Self.State then begin
      MakeISDOCII(Self.ObjectSpace,Self.OID);
    end;
    Self.SetFieldValueAsString('X_MailAddress','AfterSave');
  end;
{  mRowBOs:=TStringList.Create;
  mROIDs:=TStringList.Create;
  try
    for i:=0 to Self.Rows.Count -1 do begin
     mOID:=Self.Rows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID');
      if mRowBOs.IndexOf(mOID)= -1 then
        if not(NxIsEmptyOID(mOID)) then
          mRowBOs.Append(mOID);
    end;
    for i:=0 to mRowBOs.Count -1 do begin
      mRowBO:=Self.ObjectSpace.CreateObject('0H0I5SAOS3DL3ACU03KIU0CLP4'); //řádek DL
      try
        mRowBO.Load(mRowBOs[i],nil);
        mOID:=mRowBO.GetFieldValueAsString('Provide_ID');
        if mROIDs.IndexOf(mOID)= -1 then
          if not(NxIsEmptyOID(mOID)) then
            mROIDs.Append(mOID);
      finally
        mRowBO.Free;
      end;
    end;
    for i:=0 to mROIDs.Count -1 do begin
      mRO:=Self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //OP
      try
        mRO.Load(mROIDs[i],nil);
        if mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')<3 then begin
          mRO.SetFieldValueAsInteger('X_WEB_Stav_Dokladu',3);
          if mRO.GetFieldValueAsString('Firm_ID')=cFirm_ID then
            if not(CreateAndSend(NxCreateContext_1(Self), Self, 3, mOID, mRO.GetFieldValueAsString('X_WEB_Email')))
              then Self.SetFieldValueAsString('X_SendMail_Note',mOID);
        end;
        if mRO.NeedSave then mRO.Save;
      finally
        mRO.Free;
      end;
    end;
  finally
    mRowBOs.Free;
    mROIDs.Free;
  end;
end;
}
begin
end.