procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
 mBO, mRecBO:TNxCustomBusinessObject;
 mAtt,mRec:TNxCustomBusinessMonikerCollection;
begin
      mBO:=TDynSiteForm(self).CurrentObject;
      if FileExists(mBO.GetFieldValueAsString('U_fileName')) then TNxEmailSent(mBO).AttachFile(mBO.GetFieldValueAsString('U_fileName'));
      mRec:=mbo.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Recipients'));
      if not(NxIsBlank(mBO.GetFieldValueAsString('U_Recepient'))) then begin

       mRecBO:=mRec.AddNewObject;
       mRecBo.SetFieldValueAsString('Email',mBO.GetFieldValueAsString('U_Recepient'));
       mRecBo.SetFieldValueAsInteger('EmailType',0);
      end;
      if not(NxIsBlank(mBO.GetFieldValueAsString('Firm_ID.U_dalemaily'))) then begin
       //mRec:=mbo.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Recipients'));
       mRecBO:=mRec.AddNewObject;
       mRecBo.SetFieldValueAsString('Email',mBO.GetFieldValueAsString('Firm_ID.U_dalemaily'));
       mRecBo.SetFieldValueAsInteger('EmailType',1);
      end;
      TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;

end;

begin
end.