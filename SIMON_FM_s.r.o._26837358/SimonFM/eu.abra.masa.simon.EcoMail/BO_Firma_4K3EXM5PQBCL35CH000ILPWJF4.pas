uses '.fce';

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mFirmOffices:TNxCustomBusinessMonikerCollection;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mJSON, mSubScriberData:TJSONSuperObject;
 mOS:TNxCustomObjectSpace;
 mSpacePos:integer;
 mResJSON:TJSONSuperObject;
 mURL,mName, mSurName, mPretitle, mTempStr, mTempStr2:string;
begin
 try
   mTempStr:='';
   mTempStr2:='';
   mName:='';
   mSurName:='';
   mPretitle:='';
   mFirmOffices:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('FirmOffices'));
   for i:=0 to mFirmOffices.count-1 do begin
     if mFirmOffices.BusinessObject[i].GetFieldValueAsBoolean('X_CommercialsAgreement') then begin
         mBO:=self;
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
         end;
     end;
   end;
 except

 end;
end;

begin
end.