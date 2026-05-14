procedure  CheckCSV(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mList, mMailList:TStringList;
 i:Integer;
 mSSCBO, mMailBO:TNxCustomBusinessObject;
 mCode, mStoreCard_ID, mSSC_ID:string;
 mQuantity:Extended;
begin
  mList:=TStringList.create;
  mList.LoadFromFile(Directory + '\' + FileName);
  if mlist.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mCode:=NxTrapStr(mList.Strings[i],';');
      mQuantity:=NxIBStrToFloat(NxTrapStr(mList.Strings[i],';'));
      mStoreCard_ID:=GetStoreCard_ID(OS,mCode);
      if not(NxIsEmptyOID(mStoreCard_ID)) then begin
         mSSC_ID:=GetStoreSubCard_ID(OS, mStoreCard_ID);
         mSSCBO:=os.CreateObject(Class_StoreSubCard);
         if NxIsEmptyOID(mSSC_ID) then begin
           mSSCBO.New;
           mSSCBO.Prefill;
           mSSCBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mSSCBO.SetFieldValueAsString('Store_ID','5R10000101');
           mSSCBO.SetFieldValueAsFloat('Quantity',mQuantity);
         end else begin
           mSSCBO.Load(mSSC_ID,nil);
           mSSCBO.SetFieldValueAsFloat('Quantity',mQuantity);
         end;
         mSSCBO.save;
         mSSCBO.Free;
      end;
    end;
  end;
  mList.free;
  mMailList:=TStringList.create;
  OS.SQLSelect('Select id from emailsreceived where processed=''A'' and subject=''DataExchange'' ',mMailList);
  if mMailList.count>0 then begin
     for i:=0 to mMailList.count-1 do begin
       mMailBO:=os.CreateObject(Class_EmailsReceived);
       mMailBO.Load(mMailList.Strings[i],nil);
       mMailBO.Delete;
     end;
  end;
   try
     os.SQLExecute('delete from datachangeslogs where createdby_id=''SUPER00000'' and not(clsid=''O3SCO4S1BRD13FY1010DELDFKK'') ');
   except
   end;
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

      mFileName := 'D:\abra_ex\' + mFile;
      mM.SetBytes(EmailAttachment.GetFieldValueAsBytes('BlobData'));
      mM.SaveToFile(mFileName);
    finally
      mM.Free;
    end;
   end;
  end;
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
  cSQL = 'SELECT id FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_ID=''5R10000101'' ';
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