procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import z XML';
  mAction.Hint := 'XML';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML_OnExecute;

end;

procedure importXML_ONExecute(sender:TComponent);
var
 mFileName:string;
 mString:string;
 mList:TStringList;
 i,j,k:integer;
 mFirm_ID:string;
 Success:Boolean;
begin
  j:=0;
  k:= 2000000;
  mFileName:='D:\AbraGen\makitaTEST.xml';
  mFirm_ID:=GetFirm_ID(TComponent(sender).BusRollSite.BaseObjectSpace,'60754605');
  Success := getXMLFile(mFileName);

  if Success then begin
    Success := processXML_XMLDOM(TComponent(sender).BusRollSite.BaseObjectSpace, mFileName, mFirm_ID,  k, '');
  end
  else begin

  end;
end;


procedure GetAndParseMakita(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mFileName:string;
 mString:string;
 mList:TStringList;
 i,j,k:integer;
 mFirm_ID:string;
begin
  LogInfoStr := LogInfoStr + FormatDateTime('DD.MM.YYYY hh:nn:sss',now)+ ' Start.'+#13#10;
  j:=0;
  k:= 2000000;
  mFileName:='D:\AbraGen\_feed\TEST.xml';
  mFirm_ID:='';
  Success := getXMLFile(mFileName);

  if Success then begin
    LogInfoStr := LogInfoStr + FormatDateTime('DD.MM.YYYY hh:nn:sss',now)+ ' Feed stažen a uložen na disk.'+#13#10;
    Success := processXML_XMLDOM(OS, mFileName, mFirm_ID,  k, LogInfoStr);
  end
  else begin
    LogInfoStr := LogInfoStr + FormatDateTime('DD.MM.YYYY hh:nn:sss',now)+ ' Nepodařilo se stáhnout XML.'+#13#10;
  end;
end;


function processXML_XMLDOM(OS: TNxCustomObjectSpace; mFilename, mFirm_ID:String; maxCount: Integer; var LogInfoStr: String): Boolean;
var
  i,j, mCount: Integer;
  mXML, EntryNode, currNode, mCurrElement: Variant;
  mStore_ID, mStoreCard_ID: string;
  mSCBO:TNxCustomBusinessObject;
  mEshopNC, mOriginalValueE, mWarranty,mWasteAmount: Extended;
  mOriginalValueB: boolean;
begin
  Result := False;
  mXML := CreateOleObject('Msxml2.DOMDocument');
  try
    mXML.async := false;
    mXML.load(mFileName);
    EntryNode := mXML.getElementsByTagName('ITEM');
    mCount := min(maxCount,EntryNode.Length);
    //mCount:=10;
    LogInfoStr := LogInfoStr + FormatDateTime('DD.MM.YYYY hh:nn:sss',now)+ ' XML načten ze souboru (počet položek: '+inttostr(mCount)+').'+#13#10;
    NxShowSimpleMessage(LogInfoStr,nil);
    for i := 0 to  mCount- 1 do
    begin
      currNode := EntryNode.Item(i);
      if i<10 then begin
        NxshowSimplemessage(currNode.selectSingleNode('PRODUCTNO').text, nil)
      end;

    end;
    Result := True;
    LogInfoStr := LogInfoStr + 'Upraveno '+inttostr(j)+' z celkového počtu '+IntToStr(mCount);
  finally
    mXML := Null;
  end;
end;

function getXMLFile(mFileName: String): Boolean;
var
  mWinHTTP:Variant;
  mStream:TMemoryStream;
begin
  Result := False;
  mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
  mStream:=TMemoryStream.Create;
  try
    mWinHTTP.Open('GET','https://olejspol.cz/modules/mergado/xml/0/mergado_feed_cs-CZK_27a6f7cf13f.xml');
    //mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes( 'FeProdukt:FP2531')));
    mWinHTTP.SetRequestHeader('Content-Type','application/xml');
    mWinHTTP.Send();
    if VarToStr(mWinHTTP.Status) = '200' then begin
      mStream.SetBytes(mWinHTTP.ResponseBody);
      mStream.saveToFile(mFileName);
      Result := True;
    end;
  finally
    mStream.Free;
    mWinHTTP := Null;
  end;
end;

function ElementExists(AEntryNode : Variant; AName: string): Boolean;
var
  i: integer;
  mCurrNode: Variant;
begin
  Result:= False;
  mCurrNode:= AEntryNode.ChildNodes ;
  For i := 0 To mCurrNode.Length - 1  do begin
    if mCurrNode.Item(i).BaseName = AName Then begin
      Result:= True;
      break;
    end;
  end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aFirm_ID, aCode : string) : string;
const
  cSQL = 'SELECT sc.ID FROM StoreCards sc join suppliers s on s.id=sc.mainsupplier_id where s.firm_id=''%s'' and s.ExternalNumber=''%s'' and sc.Hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    //OutputDebugString(Format(cSQL, [aFirm_ID, aCode]));
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; aICO : string) : string;
const
  cSQL = 'SELECT ID FROM Firms where OrgIdentNumber=''%s'' and Hidden=''N'' and firm_id is null ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aICO]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;


begin
end.