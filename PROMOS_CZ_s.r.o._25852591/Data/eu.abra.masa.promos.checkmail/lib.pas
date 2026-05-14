procedure  CheckCSV(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mList, mMailList:TStringList;
 i:Integer;
 mSSCBO, mMailBO:TNxCustomBusinessObject;
 mCode, mStoreCard_ID, mSSC_ID, mBalast:string;
 mQuantity:Extended;
begin
  mList:=TStringList.create;
  mList.LoadFromFile(Directory + '\' + FileName);
  //os.SQLExecute('update storesubcards set quantity=0 where store_id='+Quotedstr('1420000101'));
  if mlist.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mCode:=NxTrapStr(mList.Strings[i],';');
      mBalast:=NxTrapStr(mList.Strings[i],';');
      mQuantity:=NxIBStrToFloat(NxTrapStr(mList.Strings[i],';'));
      mStoreCard_ID:=GetStoreCard_ID(OS,mCode);
      if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       try
         mSSC_ID:=GetStoreSubCard_ID(OS, mStoreCard_ID);
         mSSCBO:=os.CreateObject(Class_StoreSubCard);
         if NxIsEmptyOID(mSSC_ID) then begin
           mSSCBO.New;
           mSSCBO.Prefill;
           mSSCBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mSSCBO.SetFieldValueAsString('Store_ID','1420000101');
           mSSCBO.SetFieldValueAsFloat('Quantity',mQuantity);
         end else begin
           mSSCBO.Load(mSSC_ID,nil);
           mSSCBO.SetFieldValueAsFloat('Quantity',mQuantity);
         end;
         mSSCBO.save;
         mSSCBO.Free;
        except
         //potlačení chyby
        end;
      end;
    end;
  end;
  mList.free;
  {mMailList:=TStringList.create;
  OS.SQLSelect('Select id from emailsreceived where processed=''A'' and subject=''DataExchange'' ',mMailList);
  if mMailList.count>0 then begin
     for i:=0 to mMailList.count-1 do begin
       mMailBO:=os.CreateObject(Class_EmailsReceived);
       mMailBO.Load(mMailList.Strings[i],nil);
       mMailBO.Delete;
     end;
  end;
   try
     os.SQLExecute('delete from datachangeslogs where createdby_id=''SUPER00000'' ');
   except
   end; }
  ProcessContinue := True;

end;




procedure SaveAttachCSV(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean;
  Email, EmailAttachment: TNxCustomBusinessObject);
var
  mContent, mBO: TNxCustomBusinessObject;
  mM: TMemoryStream;
  mFile, mFileName, mArchive, mCheckResult: String;
  mLogWindow: TForm;

begin
  // Uložíme CSV soubor z přílohy
  ProcessContinue := True;
  // Pokud se nejedná o přílohu v CSV, tak není co dělat
  if Assigned(EmailAttachment) then begin
  mFile := EmailAttachment.GetFieldValueAsString('FileName');
  if UpperCase(NxRight(EmailAttachment.GetFieldValueAsString('FileName'),4)) <> '.CSV' then
    exit
  else
  begin
    mM:= TMemoryStream.Create;
    try
      // Uložím CSV soubor z přílohy emailu do složky

      mFileName := 'C:\ABRA_EXPORT\' + mFile;
      mM.SetBytes(EmailAttachment.GetFieldValueAsBytes('BlobData'));
      mM.SaveToFile(mFileName);
    finally
      mM.Free;
    end;
   end;
  end;
end;

procedure DownloadCSV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mFileName:string;
 mWinHTTP:Variant;
 mString:string;
 mList:TStringList;
begin
  mFileName := 'C:\ABRA_EXPORT\stock.csv';
  mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
  mWinHTTP.Open('GET','http://207.154.227.54/kingtony/handlowiec/stock.csv');
  mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.ANSI.GetBytes( 'MarekCZ:MarekCZ123?')));
  mWinHTTP.Send('');
  mString:=mWinHTTP.ResponseText;
  mList:=TStringList.Create;
  mList.add(mString);
  mList.SaveToFile(mFileName);

  Success := True;
  LogInfoStr := '';
end;


function BasicAuth(const User, Pass: string): string;
var
  S: string;   // v D7 = ANSI
  B: TBytes;
  i: Integer;
begin
  S := User + ':' + Pass;

  SetLength(B, Length(S));
  for i := 1 to Length(S) do
    B[i-1] := Ord(S[i]);   // přímý převod ANSI → byte

  Result := 'Basic ' + EncodeBase64(B);
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT id FROM StoreCards WHERE Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;


function GetStoreSubCard_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID : string) : String;
const
  cSQL = 'SELECT id FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_ID=''1420000101'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;



begin
end.