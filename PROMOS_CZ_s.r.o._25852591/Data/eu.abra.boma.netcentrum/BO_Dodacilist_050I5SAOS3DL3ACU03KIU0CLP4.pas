uses 'eu.abra.boma.netcentrum.maildoc';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
//procedure _SaveChildren_PreHook(Self: TNxHeaderBusinessObject);
{
procedure _FinalizeSave_PreHook(Self: TNxHeaderBusinessObject);
var
  i: Integer;
  mRO, mBOD: TNxCustomBusinessObject;
  mROIDs: TStringList;
  mOID, mErr: String;
  mCon: TNxContext;
begin
  if (Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) then begin
    mROIDs:=TStringList.Create;
    try
      for i:=0 to Self.Rows.Count -1 do begin
       mOID:=Self.Rows.BusinessObject[i].GetFieldValueAsString('Provide_ID');
        if mROIDs.IndexOf(mOID)= -1 then
          if not(NxIsEmptyOID(mOID)) then
            mROIDs.Append(mOID);
      end;
      for i:=0 to mROIDs.Count -1 do begin
        mRO:=Self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //OP
        try
          mRO.Load(mROIDs[i],nil);
          if Self.GetFieldValueAsBoolean('X_PredanoPP') then begin
            if mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')<4 then begin

              mCon:=NxCreateContext_1(Self);
              try                  //mContext:TNxContext; var mCo: TNxcustomBusinessObject; Atype: Integer; var mErr: String; aMailAddress: String): Boolean;
                if CreateAndSendbyINI(mCon, Self, 4, mErr, mRO.GetFieldValueAsString('X_WEB_Email')) then
                  mRO.SetFieldValueAsInteger('X_WEB_Stav_Dokladu',4);
              finally
                mCon.Free;
              end;
            end;
          end;
          //if (mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=2) and (Self.GetFieldValueAsInteger('U_SendMail')=1) then begin
          //  CreateAndSend(NxCreateContext_1(Self), Self, 2, mOID, mRO.GetFieldValueAsString('X_WEB_Email'));
          //end;
          if mRO.NeedSave then mRO.Save;
        finally
          mRO.Free;
        end;
      end;
    finally
      mROIDs.Free;
    end;
  end;
end;
}

begin
end.