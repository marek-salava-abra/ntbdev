procedure iSendMail(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string; AFrom : string = '');
  function iSearchEmailAccount_ID(AOS : TNxCustomObjectSpace; const AEMail : string) : TNxOID;
  const
    cSQL = 'SELECT A.ID FROM EmailAccounts A WHERE A.Hidden=''N'' AND A.AccountAddress LIKE ''%s'' ORDER BY A.AccountAddress';
  var
    mList : TStringList;
  begin
    Result := '';
    mList := TStringList.Create;
    try
      AOS.SQLSelect(Format(cSQL, [AEmail]), mList);
      if mList.Count > 0 then
        Result := mList.Strings[0];
    finally
      mList.Free;
    end;
  end;
var
  mBO, mRecipient : TNxCustomBusinessObject;
  mSL : TStringList;
  i : integer;
begin
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID',iSearchEmailAccount_ID(AOS, AFrom));
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 1);
    mBO.SetFieldValueAsString('Division_ID', '2100000101');
    mSL := TStringList.Create;
    try
      NxTokenToStrings(ATO, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 0);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;
    mBO.Save;
  finally
    mBO.Free;
  end;
end;



begin
end.