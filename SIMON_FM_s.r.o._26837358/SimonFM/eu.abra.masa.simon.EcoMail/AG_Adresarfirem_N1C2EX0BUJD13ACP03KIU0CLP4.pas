uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
  var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actEcomail';
  mAction.Category := 'tabList';
  mAction.Caption := 'Odešle data do EcoMail';
  mAction.ShowMenuItem := True;
  mAction.ShowControl := True;
  mAction.OnExecute := @SendToEcoMail;
end;

procedure SendToEcoMail(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i,k:integer;
 mBO:TNxCustomBusinessObject;
 mJSON, mSubScriberData:TJSONSuperObject;
 mOS:TNxCustomObjectSpace;
 mSpacePos:integer;
 mResJSON:TJSONSuperObject;
 mURL,mName, mSurName, mPretitle, mTempStr, mTempStr2:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 if mList.count>0 then begin
   if NxMessageBox('Dotaz', 'Přejete si odeslat označené do EcoMailu?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
      try
       k:=mList.Count;
       WaitWin.StartProgress('Čekejte, prosím ...', '', k);
       for i:=0 to k-1 do begin
         mTempStr:='';
         mTempStr2:='';
         mName:='';
         mSurName:='';
         mPretitle:='';
         mBO:=mOS.CreateObject(Class_Firm);
         mBO.Load(mList.Strings[i],nil);
         mJSON:=TJSONSuperObject.Create;
         mSubScriberData:=TJSONSuperObject.Create;
         if NxIsBlank(mbo.GetFieldValueAsString('VATIdentNumber')) then begin
           mTempStr:=mbo.GetFieldValueAsString('Name');
           if ((NxSearch(mTempStr,'Ing.',[srAll],0)>0) or (NxSearch(mTempStr,'Bc.',[srAll],0)>0)) then begin
              mPretitle:=NxTrapStrTrim(mTempStr,' ');
              mName:=NxTrapStrTrim(mTempStr,' ');
              mSurName:=NxTrapStrTrim(mTempStr,' ');
           end else begin
              mName:=NxTrapStrTrim(mTempStr,' ');
              mSurName:=NxTrapStrTrim(mTempStr,' ');
           end;
           mSubScriberData.S['pretitle']:=mName;
           mSubScriberData.S['name']:=mName;
           mSubScriberData.S['surname']:=mSurName;
           mURL:=cURL+'lists/'+cB2CListID+'/subscribe';
         end else begin
           mTempStr2:=mbo.GetFieldValueAsString('ResidenceAddress_ID.Recipient');
           if not(NxIsBlank(mTempStr2)) then begin
             mName:=NxTrapStrTrim(mTempStr2,' ');
             mSurName:=NxTrapStrTrim(mTempStr2,' ');
             mSubScriberData.S['name']:=mName;
             mSubScriberData.S['surname']:=mSurName;
           end;
           mSubScriberData.S['company']:=mbo.GetFieldValueAsString('Name');
           mURL:=cURL+'lists/'+cB2BListID+'/subscribe';
         end;
         mSubScriberData.S['email']:=mBO.GetFieldValueAsString('ResidenceAddress_ID.Email');
         mSubScriberData.S['street']:=mBO.GetFieldValueAsString('ResidenceAddress_ID.Street');
         mSubScriberData.S['city']:=mBO.GetFieldValueAsString('ResidenceAddress_ID.City');
         mSubScriberData.S['zip']:=mBO.GetFieldValueAsString('ResidenceAddress_ID.PostCode');
         mSubScriberData.S['country']:=mBO.GetFieldValueAsString('ResidenceAddress_ID.CountryCode');
         mSubScriberData.S['phone']:=mBO.GetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1');
         mSubScriberData.S['source']:='Abra';
         mJSON.O['subscriber_data']:=mSubScriberData;
         mJSON.B['update_existing']:=True;
         mJSON.B['resubscribe']:=False;
         mJSON.B['trigger_autoresponders']:=False;
         //NxShowSimpleMessage(mJSON.AsString,mSite);
         mResJSON:=API_POST(mUrl,mJSON,mOS);
         if mResJSON.I['id']>0 then begin
          mBO.SetFieldValueAsBoolean('X_Ecomail',true);
          mBO.SetFieldValueAsInteger('X_EcomailID',mResJSON.I['id']);
          mbo.save;
         end;
         WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
         WaitWin.StepIt;
        end;
       WaitWin.Stop;
      except
       WaitWin.Stop;
       NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
      end;
   end;
 end;
end;

begin
end.