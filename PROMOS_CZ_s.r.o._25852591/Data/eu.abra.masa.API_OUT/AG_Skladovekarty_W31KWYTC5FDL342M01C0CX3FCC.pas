procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actExportImages';
  mAction.Caption := 'Export obrázků skladových karet';
  mAction.Hint := 'vyexportuje obrázky na Simon';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ExportImages;
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actExportDocuments';
  mAction.Caption := 'Export tech. listu';
  mAction.Hint := 'vyexportuje listy na Simon';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ExportDocuments;
end;

Procedure ExportImages(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mSCPictureBO, mPictureBO, mTempPictureBO:TNxCustomBusinessObject;
 mJSON,mJSON2,mResultJSON:TJSONSuperObject;
 mList:TStringList;
 i,j,k,l:integer;
 mPictures:TNxCustomBusinessMonikerCollection;
 mBody:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 k:=0;
 l:=0;
 mBody:='';
 if mlist.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete si odeslat obrázky od '+IntToStr(mlist.count)+' karet do Simonu?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.count);
     for i:=0 to mlist.count-1 do begin
        mBO:=mOS.CreateObject(Class_StoreCard);
        mBO.Load(mList.strings[i],nil);
        mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
        mJSON:=TJSONSuperObject.Create;
        mJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
        mJSON.O['Pictures'] := mJSON.CreateJSONArray;
        for j:=0 to mPictures.count-1 do begin
          mSCPictureBO:=mPictures.BusinessObject[j];
          mPictureBO:=mOS.CreateObject(Class_Picture);
          mPictureBO.Load(mSCPictureBO.GetFieldValueAsString('Picture_ID'),nil);
          mTempPictureBO:=mOS.CreateObject(Class_Picture);
          mTempPictureBO.new;
          mTempPictureBO.Prefill;
          mTempPictureBO.SetFieldValueAsString('PictureTitle','#'+mPictureBO.GetFieldValueAsString('PictureTitle'));
          mTempPictureBO.SetFieldValueAsBoolean('ExternalFile',False);
          mTempPictureBO.SetFieldValueAsString('PathAndFileName',mPictureBO.GetFieldValueAsString('PathAndFileName'));
          mTempPictureBO.save;
          mJSON2:=TJSONSuperObject.Create;
          mJSON2.S['name'] := mPictureBO.GetFieldValueAsString('PictureTitle');
          mJSON2.B['isExternal'] := mPictureBO.GetFieldValueAsBoolean('ExternalFile');
          mJSON2.S['PathAndFileName'] := mPictureBO.GetFieldValueAsString('PathAndFileName');
          mJSON2.S['type'] := mPictureBO.GetFieldValueAsString('PictureType');
          mJSON2.S['base64Data'] := decodePicture(loadPictureAndSaveToFile(mTempPictureBO.GetFieldValueAsBytes('BlobData')));
          mJSON.A['Pictures'].Add(mJSON2);
          mTempPictureBO.delete;
        end;
        //mJSON.SaveToFile('C:\ABRA_logs\json\'+mBO.OID+'.json');
        mResultJSON:= API_POST(mJSON,'https://api.simonfm.cz/SimonFM/script/eu.abra.masa.API_IN/lib/Pictures');
        k:=k+ mResultJSON.I['Found'];
        l:=l+ mResultJSON.I['NotFound'];
        if mResultJSON.I['Found']=1 then mBody:=mBody+#13#10+mbo.GetFieldValueAsString('Code');
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.count));
        WaitWin.StepIt;
     end;
     WaitWin.Stop;
     SendInternalMail(mOS,'eshop@naradi-simon.cz','','','Listy z PROMOS',mBody,'','','1000000101','');
     NxShowSimpleMessage('Celkem odesláno:  '+IntToStr(mList.count)+#13#10+
                         'Nalezeno:         '+IntToStr(k)+#13#10+
                         'Nenalezeno:       '+IntToStr(l),mSite);
   end;
 end;
end;

Procedure ExportDocuments(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mSCPictureBO, mPictureBO, mTempPictureBO:TNxCustomBusinessObject;
 mJSON,mJSON2,mResultJSON:TJSONSuperObject;
 mList:TStringList;
 i,j,k,l:integer;
 mPictures:TNxCustomBusinessMonikerCollection;
 mBody:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 k:=0;
 l:=0;
 mBody:='';
 if mlist.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete si odeslat technické listy od '+IntToStr(mlist.count)+' karet do Simonu?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.count);
     for i:=0 to mlist.count-1 do begin
        mBO:=mOS.CreateObject(Class_StoreCard);
        mBO.Load(mList.strings[i],nil);
        mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
        mJSON:=TJSONSuperObject.Create;
        mJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
        mJSON.S['FileName']:=mbo.GetFieldValueAsString('X_Product_Sheet_FileName');
        //mJSON.SaveToFile('C:\ABRA_logs\json\'+mBO.OID+'.json');
        mResultJSON:= API_POST(mJSON,'https://api.simonfm.cz/SimonFM/script/eu.abra.masa.API_IN/lib/Documents');
        k:=k+ mResultJSON.I['Found'];
        l:=l+ mResultJSON.I['NotFound'];
        if mResultJSON.I['Found']=1 then mBody:=mBody+#13#10+mbo.GetFieldValueAsString('Code');
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.count));
        WaitWin.StepIt;
     end;
     WaitWin.Stop;
     SendInternalMail(mOS,'eshop@naradi-simon.cz','','','Listy z PROMOS',mBody,'','','1000000101','');
     NxShowSimpleMessage('Celkem odesláno:  '+IntToStr(mList.count)+#13#10+
                         'Nalezeno:         '+IntToStr(k)+#13#10+
                         'Nenalezeno:       '+IntToStr(l),mSite);
   end;
 end;
end;





function API_POST(aJSON:TJSONSuperObject;aURL:string):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', aURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic UHJvbW9zOnByb21vcw==');
   mWinHTTP.Send(aJSON.AsJson);
   mResultJSON:=TJSONSuperObject.Create;
   //NxShowSimpleMessage(mWinHTTP.status,nil);
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
     mResultJSON.S['Status']:='OK';
   end else begin
     Result:=TJSONSuperObject.create;
     Result.S['ID']:='';
     mResultJSON.S['Status']:='Error1';
   end;
   //API_Result(mResultJSON);
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.I['HTTPStatus']:=404;
   mResultJSON.S['InputJSON']:=aJSON.AsString;
   mResultJSON.S['Status']:='Error1';
   //API_Result(mResultJSON);
  end;
end;



function loadPictureAndSaveToFile(aBlobData: TBytes): String;
var
  mPicture: TPicture;
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  mPicture := TPicture.Create;
  try
    NxCreateTempFile(Result);
    OutputDebugString(Result);
    mStream.SetBytes(aBlobData);
    mPicture.LoadMultiFormatFromStream(mStream);
    mPicture.SaveToFile(Result);
  finally
    mPicture.Free;
    mStream.Free;
  end;
end;

function decodePicture(aFileName: String): String;
var
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  try
    mStream.LoadFromFile(aFileName);
    Result := EncodeBase64(mStream.GetBytes);
    DeleteFile(aFileName);
  finally
    mStream.Free;
  end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject(Class_EmailSent);
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID', '1200000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','0');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;



     mMailBO.Save;
     mMailBO.free;

  end;
end;


begin
end.