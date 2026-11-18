procedure iSendCRM(AOS : TNxCustomObjectSpace;mOID:string;const mActivityArea : string; const mDescription : string; const mFirm : string; const mActivityType : string;
                                               const mActQueue : string; const mDivision : string; const mSubject : string; const mSolverRole : string;const date1 : Double;const date2 : Double);
 var
 mBO,aBO : TNxCustomBusinessObject;
//  mActivityArea,mDescription,mFirm,mActivityType,mActQueue,mDivision,mSubject,mSolverRole:string;
 begin
 mBO := AOS.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
  try
    mBO.New;
    mBO.Prefill;

                mBO.SetFieldValueAsString('ActivityArea_ID', mActivityArea) ;
                mBO.SetFieldValueAsString('Description', 'Konfigurační list');
                mBO.SetFieldValueAsString('ActivityType_ID', mActivityType);
                mBO.SetFieldValueAsString('ActQueue_ID', mActQueue);
                mBO.SetFieldValueAsString('Division_ID', mDivision);
                mBO.SetFieldValueAsString('Subject', mSubject);
                mBO.SetFieldValueAsDateTime('RealStart$Date', date1);
                mBO.SetFieldValueAsDateTime('RealEnd$Date', date1);
                mBO.SetFieldValueAsString('SolverRole_ID',mSolverRole );
                aBO:= aos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                  try
                    abo.load(moid,nil);
                        mbo.SetFieldValueAsString('Firm_ID',abo.GetFieldValueAsString('X_Firm_ID'));
                        mbo.SetFieldValueAsString('FirmOffice_ID',abo.GetFieldValueAsString('X_Office_ID'));
                        mbo.SetFieldValueAsString('Person_ID',abo.GetFieldValueAsString('X_Person_ID'));
                        mbo.SetFieldValueAsString('BusOrder_ID',abo.GetFieldValueAsString('X_BusOrder_ID'));
                        mbo.SetFieldValueAsString('Bustransaction_ID',abo.GetFieldValueAsString('X_BusTransaction_ID'));
                  finally
                    abo.free;
                  end;

          mBO.Save

             finally
             end;
end;
begin
end.