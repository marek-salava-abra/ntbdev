const
  dates_packedGUID = 'AVV1JYV5AVNOZHQCK0D4CJFUCS';
  dates_siteGUID = 'OYC0P3TDDY1ORIJO2SKTP2KZKG';


{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tabList,tabDetail';
  mAction.Caption := 'Vstupní prohlídky';
  mAction.OnExecute := @Prohlidky_Click;




end;





procedure Prohlidky_Click(Sender: TObject);
var
  mSite: TSiteForm;
  mPerson, mheaderBO, mZarazeni,mAktivita : TNxCustomBusinessObject;
  mPerson_id, mProhlidka_ID, mDivision_ID, mSQL,mSQL1: string;
  mOLE, mStr, mRol: Variant;
  OS: TNxCustomObjectSpace;
  mIDs,mIDs1: TStrings;
  i: integer;
  j:integer;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
      mPerson:= TBusRollSiteForm(mSite).CurrentObject;
      mPerson_id:=mPerson.OID;
      mDivision_ID:='1000000101';
      J:=0;
      try
       mids:=TStringList.Create;
      mSQL:='select w.WorkPosition_ID from workingrelations w left join employees e on e.id=w.employee_id where e.person_id='''+mPerson_ID+''' ';
      TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(mSQL,mIDs);
      if mids.Count>0 then begin
            mZarazeni:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('M0WG20LFN534R35EMBKAPD4JRW');
            mzarazeni.Load(mids.Strings[0],nil);
            if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni1')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni1.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');
                                        
                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni1.Name'));
                                        //mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', mPerson_id);
                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni1.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                            end;

                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni2')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni2.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni2.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni2.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                            end;





                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni3')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni3.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni3.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni3.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                           end;




                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni4')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni4.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni4.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni4.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                              end;




                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni5')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni5.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);

                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni5.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni5.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                              end;




                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni6')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni6.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);

                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni6.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni6.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                        end;





                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni7')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni7.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                        showmessage(mAktivita.GetFieldValueAsString('ID'));
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni7.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni7.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                        end;






                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni8')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni8.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                        showmessage(mAktivita.GetFieldValueAsString('ID'));
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni8.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni8.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                        end;




                                    if not NxIsEmptyOID(mZarazeni.GetFieldValueAsString('X_skoleni9')) then begin
                    mids1:=TStringList.Create;
                    mSQL1:='select A.ID from CRMActivities A where A.person_id=%s and a.status<=%s and a.subject=%s';
                        try
                                TBusRollSiteForm(mSite).BaseObjectSpace.SQLSelect(format(mSQL1,[QuotedStr(mPerson_id),'2',quotedstr(mZarazeni.GetFieldValueAsString('X_skoleni9.Name'))]),mIDs1);
                                mAktivita:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                if mids1.count>0 then begin
                                        mAktivita.Load(mids1.Strings[0],nil);
                                        showmessage(mAktivita.GetFieldValueAsString('ID'));
                                end else begin
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', '1100000101');
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', 'D100000101');
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', '1000000101');

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', '2000000101');
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', 'SUPER00000');
                                        mAktivita.SetFieldValueAsString('Description', mZarazeni.GetFieldValueAsString('X_skoleni9.Name'));
                                        mAktivita.SetFieldValueAsString('Person_ID', mPerson_id);

                                        mAktivita.SetFieldValueAsString('Division_ID','1000000101');
                                        mAktivita.SetFieldValueAsString('Subject', mZarazeni.GetFieldValueAsString('X_skoleni9.Name'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date', Now );
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', Now);
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
                                        J:=J+1;
                                        mAktivita.free;
                               end;
                        finally
                        end;
                        end;





            end;
        finally
        end;

       if j<>0 then showmessage('Bylo vygenerováno ' + inttostr(j) + ' aktivit');
     end;

  end;
end;



begin
end.