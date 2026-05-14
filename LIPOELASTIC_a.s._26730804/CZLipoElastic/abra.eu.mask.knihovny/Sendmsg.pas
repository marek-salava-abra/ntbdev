procedure iSendmsg(AOS : TNxCustomObjectSpace;const ASubject : string; const ABody : string; ATo : string; AFrom : string = '');
 var
 mBO,aBO, mRecipient : TNxCustomBusinessObject;
  mSL : TStringList;
  i : integer;
 begin
// aBO:= aos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
// try
//    abo.load(moid,nil);
        mBO := AOS.CreateObject('33XZARXR1BM4L55MOX54NTRBWG');
            try
                mBO.New;
                mBO.Prefill;
                    mBO.SetFieldValueAsString('SenderUser_ID',AFrom);
                    mBO.SetFieldValueAsString('MsgSubject', ASubject);
                    mBO.SetFieldValueAsString('MsgBody', ABody);
                    mBO.SetFieldValueAsDateTime('validtodate$date',now()+14);
                    mBO.SetFieldValueAsBoolean('DeleteAfterDeletingByAll',True);
                    mBO.SetFieldValueAsBoolean('ConfirmReading',False);
                    mSL := TStringList.Create;
                    try
                        NxTokenToStrings(ATO, ';', mSL);
                        for i := 0 to mSL.Count - 1 do begin
                            mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
                            mRecipient.SetFieldValueAsInteger('RecipientType', 0);
                            mRecipient.SetFieldValueAsString('SecurityUser_ID', Ato);
                        end;
                    finally
                        mSL.Free;
                    end;
                mBO.Save;
            finally
                mBO.Free;
            end;
//finally
//        abo.free;
//end;
end;



begin
end.






