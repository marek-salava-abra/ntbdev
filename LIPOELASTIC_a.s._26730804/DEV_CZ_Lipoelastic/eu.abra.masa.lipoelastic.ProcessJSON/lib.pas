uses '.const';

Function ProcessJSONData(var aBO:TNxCustomBusinessObject;var ErrorMessage:string):Boolean;
var
 mOS:TNxCustomObjectSpace;
 mJSONData:TJSONSuperObject;
 mReceivedInvoice_ID:String;
 mReceiptCardRowList, mResultList, mRCList:TStringList;
 i,j:integer;
 mReceiptCardBO, mReceiptCardRowBO:TNxCustomBusinessObject;
 mRCRows:TNxCustomBusinessMonikerCollection;
 mReceiptCard_ID, mReceiptCardRow_ID, mFPDocQueue_ID:string;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mFPAmount:Extended;
begin
  Result:=false;
  mOS:=aBO.ObjectSpace;
  mJSONData:=TJSONSuperObject.ParseString(abo.GetFieldValueAsString('X_Poznamka'),True);
  mReceivedInvoice_ID:= mOS.SQLSelectFirstAsString(
    ' SELECT A.ID FROM ReceivedInvoices A '+
    ' WHERE (exists ('+
      ' SELECT 1 FROM USERDATA ' +
      ' WHERE FIELDCODE= 2000002 '+
      ' AND CLSID='+Quotedstr('42HE04FZGJD13ACM03KIU0CLP4')+
      ' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr(mJSONData.S['DocumentID'])+')))','');
  if NxIsEmptyOID(mReceivedInvoice_ID) and (mJSONData.A['Rows'].Length>0) then begin
    try
      // doplnění cen do příjemek, zapsání řádku příjemky do stringlistu pro documentimportmanagera
      mReceiptCardRowList:=TStringList.Create;
      mResultList:=TStringList.Create;
      mRCList:=TStringList.Create;
      // mResultList.Add(FormatDateTime('d.m.yyyy hh:nn:ss.zzz',Now));
      for i:=0 to mJSONData.A['Rows'].Length-1 do begin
        if mJSONData.A['Rows'].O[i].I['RowType']=3 then begin
          mReceiptCardRow_ID:=mOS.SQLSelectFirstAsString('select id from storedocuments2 where flowtype=''20'' and X_StoreDocuments2_ID='+QuotedStr(mJSONData.A['Rows'].O[i].S['BODRowID']),'');
          if not(NxIsEmptyOID(mReceiptCardRow_ID)) then begin
            try
              mReceiptCard_ID:=mOS.SQLSelectFirstAsString('select parent_id from storedocuments2 where id='+QuotedStr(mReceiptCardRow_ID),'');
              mReceiptCardBO:=mOS.CreateObject(Class_ReceiptCard);
              mReceiptCardBO.Load(mReceiptCard_ID,nil);
              if mRCList.IndexOf(mReceiptCard_ID)=-1 then mRCList.Add(mReceiptCard_ID);
              mRCRows:=mReceiptCardBO.GetLoadedCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
              for j:=0 to mRCRows.count-1 do begin
                mReceiptCardRowBO:=mRCRows.BusinessObject[j];
                if mReceiptCardRowBO.OID=mReceiptCardRow_ID then begin
                  mReceiptCardRowList.Add(mReceiptCardRowBO.OID);
                  if not (mReceiptCardRowBO.GetFieldValueAsFloat('TotalPrice')=mJSONData.A['Rows'].O[i].D['TAmountWithoutVAT']) then begin
                    mReceiptCardRowBO.SetFieldValueAsFloat('UnitPrice',0);
                    mReceiptCardRowBO.SetFieldValueAsFloat('TotalPrice',mJSONData.A['Rows'].O[i].D['TAmountWithoutVAT']);
                  end;
                end;
              end;
              if mReceiptCardBO.NeedSave then mReceiptCardBO.save;
              mReceiptCardBO.free;
            except
              ErrorMessage:=ErrorMessage+#13#10+ExceptionMessage;
            end;
          end;
        end;
      end;
      if (mReceiptCardRowList.count>0) and NxIsBlank(ErrorMessage) then begin
        //mResultList.Add(FormatDateTime('d.m.yyyy hh:nn:ss.zzz',Now));
        try
          mFPDocQueue_ID:=mOS.SQLSelectFirstAsString('Select id from docqueues where documenttype=''04'' and hidden=''N'' and code='+QuotedStr(mJSONData.S['DocQueueCode']),'');
          mInputParams := TNxParameters.Create;
          mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
          mParam.AsString := mReceiptCardRowList.Text;
          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mFPDocQueue_ID;
          mParam := mInputParams.GetOrCreateParam(dtString,'ExpenseType_ID');
          mParam.AsString := '5100000101';
          mParam := mInputParams.GetOrCreateParam(dtInteger, 'RowGroupingKind');
          mParam.AsInteger := 2;
          mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AddToSourceGroups');
          mParam.AsBoolean := True;
          mImportManager := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_ReceivedInvoice);
          mImportManager.AddInputDocuments(mRCList);
          mImportManager.SelectedHeader:=mImportManager.InputDocuments[0];
          mImportManager.LoadParams(mInputParams);
          mImportManager.Execute;
          mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID',mFPDocQueue_ID);
          mImportManager.OutputDocument.SetFieldValueAsString('U_SKIssuedInvoice_ID',mJSONData.S['DocumentID']);
          mImportManager.OutputDocument.SetFieldValueAsString('VarSymbol',mJSONData.S['VarSymbol']);
          mImportManager.OutputDocument.SetFieldValueAsString('ExternalNumber',mJSONData.S['VarSymbol']);
          mImportManager.OutputDocument.SetFieldValueAsString('Description',AnsiLeftStr(mImportManager.OutputDocument.GetFieldValueAsString('Description')+' '+mJSONData.S['DocumentName'],40));
          mImportManager.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',mJSONData.DT8601['DueDate$DATE']);
          mImportManager.OutputDocument.SetFieldValueAsDateTime('VatDate$Date',mJSONData.DT8601['VATDate$DATE']);
          mImportManager.OutputDocument.SetFieldValueAsDateTime('VatAdmitDate$Date',mJSONData.DT8601['VATDate$DATE']);
          if mImportManager.OutputDocument.GetFieldValueAsInteger('TradeType') <> 2 then begin
            mImportManager.OutputDocument.SetFieldValueAsInteger('TradeType', 2);
            mImportManager.OutputDocument.setFieldValueAsString('Country_ID','00000SK000');
          end;
          mFPAmount:=mImportManager.OutputDocument.GetFieldValueAsFloat('Amount');
          if mImportManager.OutputDocument.GetFieldValueAsFloat('Amount') = mJSONData.D['Amount'] then begin
            mImportManager.OutputDocument.save;
            abo.SetFieldValueAsBoolean('X_check',true);
            aBO.Save;
            Result:=true;
          end else begin
            if aBO.GetFieldValueAsDateTime('X_ABRADate') = 0 then begin
              SendInternalMail(mOS, 'abra-alerts-inv@lipoelastic.com',
                'Přenos faktury z ABRA SK do ABRA CZ se nezdařil, ',
                'Nepodařilo se přenést FV '+mJSONData.S['DocumentName']+'. Nesouhlasila celková cena faktury přijaté a proto nebyla uložena.',
                '1100000101');
              aBO.SetFieldValueAsDateTime('X_ABRADate', Date);
              aBO.Save;
            end;
            ErrorMessage:= ErrorMessage+nxCrLf+'Nesouhlasí ceny mezi FV '+mJSONData.S['DocumentName']+'na částku '+FloatToStr(mJSONData.D['Amount'])+' a FP na částku '+FloatToStr(mFPAmount);
            Result:= false;
          end;
        except
          ErrorMessage:=ErrorMessage+#13#10+ExceptionMessage;
        end;
      end;
    except
      ErrorMessage:=ErrorMessage+#13#10+ExceptionMessage;
    end;
  end else begin
    ErrorMessage:=ErrorMessage+#13#10+'Faktura přijatá již existuje ID: '+mReceivedInvoice_ID;
  end;
end;




Function ProcessFile(var aOS:TNxCustomObjectSpace;var ErrorMessage:string):Boolean;
var
 mOS:TNxCustomObjectSpace;
 mJSONData:TJSONSuperObject;
 mReceivedInvoice_ID:String;
 mReceiptCardRowList, mResultList, mRCList:TStringList;
 i,j:integer;
 mReceiptCardBO, mReceiptCardRowBO:TNxCustomBusinessObject;
 mRCRows:TNxCustomBusinessMonikerCollection;
 mReceiptCard_ID, mReceiptCardRow_ID, mFPDocQueue_ID:string;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
begin
  Result:=false;
  mOS:=aOS;
  //mJSONData:=TJSONSuperObject.create;
  mJSONData:=TJSONSuperObject.ParseFile('C:\AbraSK\JSON\FVJSON.json',true);
  mReceivedInvoice_ID:= mOS.SQLSelectFirstAsString(
    ' SELECT A.ID FROM ReceivedInvoices A '+
    ' WHERE (exists ('+
      ' SELECT 1 FROM USERDATA ' +
      ' WHERE FIELDCODE= 2000002 '+
      ' AND CLSID='+Quotedstr('42HE04FZGJD13ACM03KIU0CLP4')+
      ' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr(mJSONData.S['DocumentID'])+')))','');
  if NxIsEmptyOID(mReceivedInvoice_ID) and (mJSONData.A['Rows'].Length>0) then begin
    try
      // doplnění cen do příjemek, zapsání řádku příjemky do stringlistu pro documentimportmanagera
      mReceiptCardRowList:=TStringList.Create;
      mResultList:=TStringList.Create;
      mRCList:=TStringList.Create;
      // mResultList.Add(FormatDateTime('d.m.yyyy hh:nn:ss.zzz',Now));
      for i:=0 to mJSONData.A['Rows'].Length-1 do begin
        if mJSONData.A['Rows'].O[i].I['RowType']=3 then begin
          mReceiptCardRow_ID:=mOS.SQLSelectFirstAsString('select id from storedocuments2 where flowtype=''20'' and X_StoreDocuments2_ID='+QuotedStr(mJSONData.A['Rows'].O[i].S['BODRowID']),'');
          if not(NxIsEmptyOID(mReceiptCardRow_ID)) then begin
            try
              mReceiptCard_ID:=mOS.SQLSelectFirstAsString('select parent_id from storedocuments2 where id='+QuotedStr(mReceiptCardRow_ID),'');
              mReceiptCardBO:=mOS.CreateObject(Class_ReceiptCard);
              mReceiptCardBO.Load(mReceiptCard_ID,nil);
              if mRCList.IndexOf(mReceiptCard_ID)=-1 then mRCList.Add(mReceiptCard_ID);
              mRCRows:=mReceiptCardBO.GetLoadedCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
              for j:=0 to mRCRows.count-1 do begin
                mReceiptCardRowBO:=mRCRows.BusinessObject[j];
                if mReceiptCardRowBO.OID=mReceiptCardRow_ID then begin
                  mReceiptCardRowList.Add(mReceiptCardRowBO.OID);
                  if not (mReceiptCardRowBO.GetFieldValueAsFloat('TotalPrice')=mJSONData.A['Rows'].O[i].D['TAmountWithoutVAT']) then begin
                    mReceiptCardRowBO.SetFieldValueAsFloat('UnitPrice',0);
                    mReceiptCardRowBO.SetFieldValueAsFloat('TotalPrice',mJSONData.A['Rows'].O[i].D['TAmountWithoutVAT']);
                  end;
                end;
              end;
              if mReceiptCardBO.NeedSave then mReceiptCardBO.save;
              mReceiptCardBO.free;
            except
              ErrorMessage:=ErrorMessage+#13#10+ExceptionMessage;
            end;
          end;
        end;
      end;
      NxShowSimpleMessage(IntToStr(mReceiptCardRowList.count)+' '+IntToStr(mRCList.Count)+' '+ErrorMessage,nil);
      if (mReceiptCardRowList.count>0) and NxIsBlank(ErrorMessage) then begin
        //mResultList.Add(FormatDateTime('d.m.yyyy hh:nn:ss.zzz',Now));
        try
          mFPDocQueue_ID:=mOS.SQLSelectFirstAsString('Select id from docqueues where documenttype=''04'' and hidden=''N'' and code='+QuotedStr(mJSONData.S['DocQueueCode']),'');
          mInputParams := TNxParameters.Create;
          mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
          mParam.AsString := mReceiptCardRowList.Text;
          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mFPDocQueue_ID;
          mParam := mInputParams.GetOrCreateParam(dtString,'ExpenseType_ID');
          mParam.AsString := '5100000101';
          mParam := mInputParams.GetOrCreateParam(dtInteger, 'RowGroupingKind');
          mParam.AsInteger := 2;
          mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AddToSourceGroups');
          mParam.AsBoolean := True;
          mImportManager := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_ReceivedInvoice);
          mImportManager.AddInputDocuments(mRCList);
          mImportManager.SelectedHeader:=mImportManager.InputDocuments[0];
          mImportManager.LoadParams(mInputParams);
          //mImportManager.ExecuteWizard(nil);
          mImportManager.Execute;
          mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID',mFPDocQueue_ID);
          mImportManager.OutputDocument.SetFieldValueAsString('U_SKIssuedInvoice_ID',mJSONData.S['DocumentID']);
          mImportManager.OutputDocument.SetFieldValueAsString('VarSymbol',mJSONData.S['VarSymbol']);
          mImportManager.OutputDocument.SetFieldValueAsString('ExternalNumber',mJSONData.S['VarSymbol']);
          mImportManager.OutputDocument.SetFieldValueAsString('Description',AnsiLeftStr(mImportManager.OutputDocument.GetFieldValueAsString('Description')+' '+mJSONData.S['DocumentName'],40));
          mImportManager.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',mJSONData.DT8601['DueDate$DATE']);
          mImportManager.OutputDocument.SetFieldValueAsDateTime('VatDate$Date',mJSONData.DT8601['VATDate$DATE']);
          mImportManager.OutputDocument.SetFieldValueAsDateTime('VatAdmitDate$Date',mJSONData.DT8601['VATDate$DATE']);
          mImportManager.OutputDocument.save;
          //abo.SetFieldValueAsBoolean('X_check',true);
          //if abo.NeedSave then aBO.save;
          Result:=true;
          //NxShowSimpleMessage(mImportManager.OutputDocument.DisplayName,nil);
        except
          ErrorMessage:=ErrorMessage+#13#10+ExceptionMessage;
        end;
      end;
    except
      ErrorMessage:=ErrorMessage+#13#10+ExceptionMessage;
    end;
  end else begin
    ErrorMessage:=ErrorMessage+#13#10+'Faktura přijatá již existuje ID: '+mReceivedInvoice_ID;
  end;
end;

function API_PUT(aJSON:TJSONSuperObject; AObjectName, AID:string):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('PUT', cURL + AObjectName + '/' + AID + '?select=id');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorization);
    mWinHTTP.Send(aJSON.AsJson);
    mResultJSON:=TJSONSuperObject.Create;
    mResultJSON.S['Category']:=AObjectName;
    mResultJSON.S['ServiceName']:=cServiceName;
    mResultJSON.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
    mResultJSON.S['InputJSON']:='#'+aJSON.AsString+'#';
    //NxShowSimpleMessage(mWinHTTP.Status, nil);
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
    //NxShowSimpleMessage(ExceptionMessage, nil);
    Result:=TJSONSuperObject.create;
    Result.S['error']:='error';
    mResultJSON:=TJSONSuperObject.Create;
    mResultJSON.S['Category']:=AObjectName;
    mResultJSON.S['ServiceName']:=cServiceName;
    mResultJSON.I['HTTPStatus']:=404;
    mResultJSON.S['InputJSON']:=aJSON.AsString;
    mResultJSON.S['Status']:='Error1';
    //API_Result(mResultJSON);
  end;
end;


procedure SendInternalMail(var AOS:TNxCustomObjectSpace;var ATo, ASubject,ABody,aAccount_ID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     mMailBO.Save;

     mMailBO.free;

  end;
end;

begin
end.