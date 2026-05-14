uses
  'Tanaka.DigiToo.Constants';

const
  c_FormFonts=['Arial','Times New Roman'];

var
  HTTP_Ret_StatusCode, gButClicked: integer;
  HTTP_Ret_Headers, HTTP_Ret_StatusText: string;

function GetQueue_ID(OS:TNxCustomObjectSpace; AUTH_TOKEN, pcQueue_ID: string): string;
var
  Typ, url, headers, SQL, str: String;
  reg: TJSONSuperObject;
  stream: TMemoryStream;
  loDigitoo: TNxCustomBusinessObject;
begin
  Result:= pcQueue_ID;
  if pcQueue_ID='' then exit;

  reg:=TJSONSuperObject.Create;
  stream:= TMemoryStream.Create;
  try
    try
      url:=ReplaceStr(URL_QUEUES, '%QUEUE_ID%',pcQueue_ID);

      reg.SaveToStream(stream);

      headers:='Authorization:Bearer '+AUTH_TOKEN;
      headers:= headers+#13#10+cAgentHeader+cScriptVersion;

      str:=HTTPReadOLE(url,stream,false,headers,'');
      if str='' then begin
        reg:=TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(stream.GetBytes),true); // ABRA nekonvertuje z UTF-8 !
        str:= reg.O['data'].S['id'];
        if (str<>'') then Result:= str;
      end;
    except
    end;
  finally
    reg.Free;
    stream.Free;
  end;
end;

function GetAccountToken(OS:TNxCustomObjectSpace; AUTH_TOKEN: string; pcDigitoo_ID: string = ''):string;
var
  Typ, url, headers, SQL, str: String;
  reg: TJSONSuperObject;
  stream: TMemoryStream;
  loDigitoo: TNxCustomBusinessObject;
begin
  Result:= AUTH_TOKEN;

  reg:=TJSONSuperObject.Create;
  stream:= TMemoryStream.Create;
  try
    try
      url:= URL_ACCOUNT_TOKEN;

      reg.SaveToStream(stream);

      headers:='Authorization:Bearer '+AUTH_TOKEN;
      headers:= headers+#13#10+cAgentHeader+cScriptVersion;

      str:=HTTPReadOLE(url,stream,false,headers,'');
      if str='' then begin
        reg:=TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(stream.GetBytes),true); // ABRA nekonvertuje z UTF-8 !
        str:= reg.O['data'].S['accessToken'];
        if (str<>'') then begin
          Result:= str;
          if not NxIsEmptyOID(pcDigitoo_ID) then begin
            loDigitoo:= OS.CreateObject(DIGITOO_CLSID);
            try
              loDigitoo.Load(pcDigitoo_ID, nil);
              if loDigitoo.GetFieldValueAsString('U_Token')<>str then loDigitoo.SetFieldValueAsString('U_Token', str);
              if loDigitoo.NeedSave then loDigitoo.Save;
            finally
              loDigitoo.Free;
            end;
          end;
        end;
      end;
    except
    end;
  finally
    reg.Free;
    stream.Free;
  end;
end;

procedure ChangePaymentStatus(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
var
  lcDigitooID, lcSQL, AUTH_TOKEN, str, lcUrl, headers, lcDigitoo_ID: string;
  lnIndex, lnType: integer;
  loDig: TNxCustomBusinessObject;
  OS: TNxCustomObjectSpace;
  stream: TMemoryStream;
  JSON: TJSONSuperObject;
  laPom: TStringList;
  lfPrevAmount, lfPrevPaidAmount, lfAmount, lfPaidAmount: extended;
begin
  if ADwarfCode<>2 then exit;
  lcDigitooID:= Self.GetFieldValueAsString('X_DigitooDocumentUrl');
  if lcDigitooID='' then exit;
  lnIndex:= NxAtR('/',lcDigitooID);
  if lnIndex>0 then lcDigitooID:= NxRest(lcDigitooID,lnIndex+1);
  if lcDigitooID='' then exit;
  lfAmount:= Self.GetFieldValueAsFloat('Amount');
  lfPaidAmount:= Self.GetFieldValueAsFloat('PaidAmount');
  Self.GetOriginalValue_1('Amount', lfPrevAmount);
  Self.GetOriginalValue_1('PaidAmount', lfPrevPaidAmount);
  if ((lfAmount<=lfPaidAmount) and (lfPrevAmount>lfPrevPaidAmount))
      or ((lfAmount>lfPaidAmount) and (lfPrevAmount<=lfPrevPaidAmount)) then begin
    OS:= Self.ObjectSpace;
    loDig:= OS.CreateObject(DIGITOO_CLSID);
    laPom:= TStringList.Create;
    laPom.Delimiter:= ';';
    stream:= TMemoryStream.Create;
    JSON:= TJSONSuperObject.Create;
    try
      try
        case Self.CLSID of
          Class_ReceivedInvoice,
          Class_ReceivedDepositInvoice,
          Class_VATReceivedDepositInvoice: lnType:= 0;
          Class_IssuedInvoice: lnType:= 1;
          else lnType:= 2;
        end;
        lcSQL:='SELECT X.StringFieldValue, DD.ID'
          +#13' FROM DefRollData DD'
          +#13' JOIN UserData TYP ON TYP.CLSID = DD.CLSID AND TYP.ID = DD.ID AND TYP.FieldCode='+IntToStr(loDig.GetFieldCode('U_Type'))
          +#13' JOIN UserData X ON X.CLSID = DD.CLSID AND X.ID = DD.ID AND X.FieldCode='+IntToStr(loDig.GetFieldCode('U_Token'))
          +#13' WHERE DD.CLSID='+QuotedStr(DIGITOO_CLSID)+' AND DD.Hidden=''N'' and Typ.StringFieldValue='+QuotedStr(IntToStr(lnType));
        OS.SQLSelect(lcSQL, laPom);
        if laPom.Count>0 then begin
          laPom.DelimitedText:= laPom[0];
          AUTH_TOKEN:= laPom[0];
          lcDigitoo_ID:= laPom[1];
          AUTH_TOKEN:= GetAccountToken(OS, AUTH_TOKEN, lcDigitoo_ID);
          if (AUTH_TOKEN='') then exit;
          stream.Clear;
          lcUrl:= ReplaceStr(URL_CHANGE_PAYMENT_STATUS, '%DOCUMENT_ID%',lcDigitooID);
          JSON.S['status']:= NxIifStr(lfAmount<=lfPaidAmount,'paid','unpaid');
          JSON.SaveToStream(stream);
          headers:='Authorization:Bearer '+AUTH_TOKEN;
          headers:= headers+#13#10+cAgentHeader+cScriptVersion;
          //showmessage(lcURL+':'+JSON.S['status']);
          str:=HTTPReadOLE(lcUrl,stream,true,headers,'PATCH');
        end;
      except
      end;
    finally
      loDig.Free;
      laPom.Free;
      stream.Free;
      JSON.Free;
    end;
  end;
end;

function UpravTextChyby(pcError: string): string;
var
  lnIndex: integer;
begin
  Result:= pcError;
  lnIndex:= NxAt('scripting callstack',pcError);
  if lnIndex>0 then Result:= Trim(Copy(pcError,1,lnIndex-1));
end;

function GetCountry_ID(OS: TNxCustomObjectSpace; pcCountryCode: string; var pbEUmember: boolean): string;
var
  laPom: TStringList;
  lcSQL: string;
begin
  laPom:= TStringList.Create;
  laPom.Delimiter:= ';';
  Result:= '';
  pbEUmember:= False;
  try
    lcSQL:= 'Select C.ID, Coalesce(C2.EUMember,''N'')'
           +' from Countries C'
           +' left join Countries2 C2 on C.ID=C2.Parent_ID'
           +' where coalesce(C2.DateOfChange$DATE,0)<='+IntToStr(Trunc(date()))
           +'       and C.Code='+QuotedStr(pcCountryCode)
           +'       and C.Code<>'''''
           +'       and C.Hidden=''N'''
           +' order by coalesce(C2.DateOfChange$DATE,0) desc';
    OS.SQLSelect(lcSQL, laPom);
    if laPom.Count>0 then begin
      laPom.DelimitedText:= laPom[0];
      Result:= laPom[0];
      if laPom[1]='A' then pbEUmember:= True;
    end;
  finally
    laPom.Free;
  end;
end;

function GetPeriod_ID(OS: TNxCustomObjectSpace;
                      pdDate: TDateTime): string;
var
  laPom: TStringList;
begin
  laPom:= TSTringList.Create;
  try
    OS.SQLSelect('Select ID from Periods'
                +' where DateFrom$DATE<='+IntToStr(Trunc(pdDate))
                +'       and DateTo$DATE>'+IntToStr(Trunc(pdDate)), laPom);
    if laPom.count>0 then Result:= laPom[0]
                     else Result:= '';
  finally
    laPom.Free;
  end;
end;

function GetData(OS: TNxCustomObjectSpace;
                 pcTableName: string;
                 pcFieldName: string;
                 pcValue: string;
                 pcReturnFieldName: string = 'ID';
                 pbQuote: boolean = True;
                 pcAndWhere: string = ''): string;
var
  lsSQL : string;
  laSQL : TStringList;
begin
  Result := '';
  lsSQL := 'select '+pcReturnFieldName+' from '+pcTableName
          +' where '+NxIifStr(pbQuote, 'Upper('+pcFieldName+')', pcFieldName)+'=';
  if pbQuote then lsSql:= lsSql+QuotedStr(AnsiUpperCase(pcValue))
             else lsSql:= lsSql+pcValue;
  if pcAndWhere<>'' then lsSQL:= lsSQL+' and '+pcAndWhere;
  laSQL := TStringList.Create;
  laSQL.Delimiter:= ';';
  laSQL.StrictDelimiter:= True;
  try
    try
      OS.SQLSelect(lsSQL, laSQL);
    except
    end;
    if laSQL.Count > 0 then begin
      laSQL.DelimitedText:= laSQL[0];
      Result:= laSQL[0];
    end;
  finally
    laSQL.Free;
  end;
end;

function getValidateErrs(poObj: TNxCustomBusinessObject): string;
var
  laErr: TStringList;
begin
  laErr := TStringList.Create;
  try
    poObj.GetValidateErrors(laErr);
    //laErr.Delimiter := #13#10;
    Result := laErr.Text;
  finally
    laErr.Free;
  end;
end;

function ExistujeUzaverkaDPH(OS: TNxCustomObjectSpace; pdVATDate: TDate): boolean;
var
  laPom: TStringList;
  lcSQL: string;
begin
  Result:= False;
  laPom:= TStringList.Create;
  try
    lcSQL:= 'Select VC.ID'
        +#13' from VATClosings VC'
        +#13' join VATSummaryDefinitions VSD on VSD.ID=VC.VATDefinition_ID'
        +#13' where VC.ClosingType=0'
        +#13'       and VSD.ClosingKind=0'
        +#13'       and VC.DateFrom$DATE<='+IntToStr(Trunc(pdVATDate))
        +#13'       and VC.DateTo$DATE>='+IntToStr(Trunc(pdVATDate));
    OS.SQLSelect(lcSQL, laPom);
    if laPom.Count>0 then Result:= True;
  finally
    laPom.Free;
  end;
end;

// nastavi/zrusi vazbu
function SetRelationOS(OS: TNxCustomObjectSpace;Rel_Def:integer;Left_ID,Right_ID:TNxOID;enabled:Boolean=true;
                      Value:Extended=0;Aditive:Boolean=false):TNxOID;
var
  loObj: TNxCustomBusinessObject;
  list: TStringList;
  SP: TNxParameters;
begin
  Result:='';
  SP:=TNxParameters.Create;
  list:=TStringList.Create;
  try
    SP.GetOrCreateParam(dtString,'Left_ID').AsString:=Left_ID;
    SP.GetOrCreateParam(dtString,'Right_ID').AsString:=Right_ID;
    SP.GetOrCreateParam(dtInteger,'Rel_Def').AsInteger:=Rel_Def;
    OS.SQLSelect('SELECT ID FROM Relations WHERE Rel_Def=:Rel_Def AND LeftSide_ID=:Left_ID AND RightSide_ID=:Right_ID',list,SP);

    loObj:=OS.CreateObject(Class_Relation);
    try
      if list.Count>0 then begin
        loObj.Load(list[0],nil);
        if enabled then begin
          if Aditive then Value:=Value+loObj.GetFieldValueAsFloat('NumValue');
          if Abs(loObj.GetFieldValueAsFloat('NumValue')-Value)>=0.0000001 then begin
            loObj.SetFieldValueAsFloat('NumValue',Value);
            loObj.Save;
          end;
        end else loObj.Delete;
      end else if enabled then begin
        loObj.New;
        loObj.Prefill;
        loObj.SetFieldValueAsInteger('Rel_Def',Rel_Def);
//        if Value<1 then Value:=Now;
        loObj.SetFieldValueAsFloat('NumValue',Value);
        loObj.SetFieldValueAsString('LeftSide_ID',Left_ID);
        loObj.SetFieldValueAsString('RightSide_ID',Right_ID);
        loObj.Save;
        Result:=loObj.OID;
      end;
    finally
      loObj.Free;
    end;
  finally
    list.Free;
    SP.Free;
  end;
end;

procedure AppendRegisterType(regType:String; ret:TStringList; registers:TJSONSuperObjectArray);
var
  registerType, obj: TJSONSuperObject;
  options: TJSONSuperObjectArray;
  i: Integer;
  row: TStringList;
begin
  if ret.Count>0 then begin
    registerType:=TJSONSuperObject.Create;
    row:= TStringList.Create;
    row.Delimiter:=';';
    try
      registerType.S('type'):=regType;
      registerType.O['options']:=registerType.CreateJSONArray;
      options:=registerType.A('options');
      for i:=0 to ret.Count-1 do begin
        row.DelimitedText:=ret[i];
        {
        if (row.Count<3) OR (row[2]='') then begin // label nesmi byt prazdny
          continue;
        end;
        }
        if (row[0]='') or (row[1]='') then continue;
        obj:=TJSONSuperObject.Create;
        options.Add(obj);
        obj.S('value'):=row[0];
        obj.S('label'):=row[1];
      end;
      registers.Add(registerType);
    finally
      row.Free;
    end;
  end;
end;

function HTTPReadOLE(
  url:string;dest:TMemoryStream;isPOST:Boolean=false;addHeaders:string='';method:String='';port:integer=0;cert:Pointer=0;
  retHeaders:Boolean=false;SetOptions:String='';UseConn:String='';
  UseLogin:Boolean=true
):string;
var
  i, i1, i2, pCnt: Longint;
  str: string;
  list: TStringList;
  WR, RS, Data: Variant;
  tb: TBytes;
  prog: TForm;
  p, p2: Pointer;

  procedure AddProgress(text:string);
  begin
    pCnt:=pCnt+1;
    SetProgress(prog,pCnt,cProgressMax,DateTimeToStr(Now)+': '+text);
  end;

begin
  prog:=TForm(GlobParams.ParamAsObject('SOAPProgress',nil));
  Result:='neznámá chyba';
  HTTP_Ret_Headers:='';
  HTTP_Ret_StatusCode:=0;
  pCnt:=0;

  AddProgress('Příprava exportu');
  dest.Position:=0;
  Data:=VarArrayCreate([0,dest.Size-1],varByte);
  if dest.Size>0 then begin
    tb:=dest.GetBytes;
    for i:=0 to length(tb)-1 do Data[i]:=tb[i];
    SetLength(tb,0);
  end;
  dest.Size:=0;

  list:=TStringList.Create;
  list.Delimiter:=';';

  try
    try
      WR:=CreateOleObject('WinHttp.WinHttpRequest.5.1');
    except
      Result:='Nelze získat OLE WinHttp';
      exit;
    end;

    if VarIsClear(WR) then begin
      Result:='Nelze získat OLE WinHttp';
      exit;
    end;

    AddProgress('Příprava spojení');
    try
      //WR.SetTimeouts(0,400000,400000,400000);
    except
      Result:='Chyba při nastavování Time-Outu: '+ExceptionMessage;
      exit;
    end;

    if method='' then method:= NxIIfStr(isPost,'POST','GET');

    try
      WR.Open(method,url,false);
    except
      Result:='Chyba při otevírání URL: '+ExceptionMessage;
      exit;
    end;

    WR.Option(WINHTTPREQ_OPTION_SslErrorIgnoreFlags):=WINHTTP_OPTION_SSERRIALL;
    //WR.Option(9{WinHttpRequestOption_SecureProtocols}):=$800{TLS 1.2};

    if UseLogin and (GlobParams.ParamAsString('HTTPSSGLogin','')<>'') then begin
      WR.SetCredentials(GlobParams.ParamAsString('HTTPSSGLogin',''),GlobParams.ParamAsString('HTTPSSGPswd',''),0);
    end;

    if addHeaders<>'' then begin
      WR.SetRequestHeader('Content-Type','application/json');
      list.Text:=addHeaders;
      str:='';
      for i:=list.Count-1 downto 0 do begin
        i1:=pos(':',list[i]);
        if i1>1 then begin
          try
            WR.SetRequestHeader(trim(copy(list[i],1,i1-1)),trim(copy(list[i],i1+1,1000))+#13#10+str);
          except
            Result:='Chyba při nastavování hlavičky '+trim(copy(list[i],1,i1-1))+': '+ExceptionMessage;
            exit;
          end;
          str:='';
        end else str:=list[i]+#13#10+str;
      end;
    end;

    AddProgress('Odesílání dat');
    try
      WR.Send(Data);
    except
      Result:='Chyba při odesílání dotazu: '+ExceptionMessage;
      exit;
    end;
    AddProgress('Čtení dat');

    try
      if retHeaders then HTTP_Ret_Headers:=WR.GetAllResponseHeaders;
      HTTP_Ret_StatusCode:=WR.Status;
      HTTP_Ret_StatusText:=WR.StatusText;
      case (HTTP_Ret_StatusCode div 100) of
        3: Result:= 'Chyba přesměrování: '+HTTP_Ret_StatusText;
        4: Result:= 'Chyba na straně klienta: '+HTTP_Ret_StatusText;
        5: Result:= 'Chyba na straně serveru: '+HTTP_Ret_StatusText;
      else Result:= '';
      end;
    except
      Result:='Chyba při čtení návratových hodnot: '+ExceptionMessage;
      exit;
    end;

    try
      //AddProgress('Čtení dat 2');
      Data:=WR.ResponseBody;
      if Length(Data)>0 then dest.AppendBytes(Data);
      dest.Position:=0;
      Data:=Null;
    except
      Result:='Chyba při čtení dat: '+ExceptionMessage;
      exit;
    end;
    AddProgress('Data načtena');

   // Result:='';
  finally
    list.Free;
    WR:=Null;
  end;
end;

{pos - pozice (od 1)
cnt - max. pocet, -1=nemenit, 0= nezobrazovat prubeh
info - text zpravy, ''=nemenit}
function SetProgress(form:TForm;posI,cnt:integer;info:string):Boolean;
var
  lab: TLabel;
  prog: TProgressBar;
  but: TButton;
  i: integer;
begin
  Result:=false;
  if not(Assigned(form)) then exit;
  prog:=TProgressBar(form.FindComponent('Prog'));
  if not(assigned(prog)) then exit;
  if cnt=0 then begin
    if prog.Visible then prog.Visible:=false;
  end else begin
    if not(prog.Visible) then prog.Visible:=true;
    if cnt>0 then prog.Max:=cnt;
    if (posI>=0) or (prog.Position>prog.Max) then begin
      posI:=min(max(posI,0),prog.Max);
      prog.Position:=posI;
    end;
  end;

  if info<>'' then begin
    lab:=TLabel(form.FindComponent('Lab'));
    if not(assigned(lab)) then exit;
    lab.Caption:=info;
  end;
  SetMainProgress(form,-1,'');

  Application.ProcessMessages;
  but:=TButton(form.FindComponent('Stop'));
  if not(assigned(but)) then exit;
  Result:=but.Visible and not(but.Enabled);
end;

function CheckIndexForVATRate(OS: TNxCustomObjectSpace; pcVATIndex_ID, pcVATRate_ID: string; pnTradeType: integer; pbIncome: boolean): boolean;
var
  lcSQL: string;
  laPom: TStringList;
begin
  Result:= True;
  laPom:= TStringList.Create;
  try
    lcSQL:= 'Select ID'
        +#13' from VATIndexes'
        +#13' where ID='+QuotedStr(pcVATIndex_ID)
        +#13'       and VATRate_ID='+QuotedStr(pcVATRate_ID)
        +#13'       and (IsCommon=''A'' or Income='+NxIIfStr(pbIncome,'''A''','''N''')+')'
        +#13'       and IsAllowance=''N'''
        +#13'       and ForCustomsDeclaration=''N'''
        +#13'       and ForDomesticReverseCharge=''N'''
        +#13'       and ForInsolventVATCorrection=''N'''
        +#13'       and ForBadDeptVATCorrection=''N''';

    case pnTradeType of
      1:lcSQL:= lcSQL
            +#13' and VATIndexType=0';
      2:lcSQL:= lcSQL
            +#13' and VATIndexType=1';
      3:lcSQL:= lcSQL
            +#13' and VATIndexType=2';
      4:lcSQL:= lcSQL
            +#13' and VATIndexType=0';
    end;
    OS.SQLSelect(lcSQL, laPom);
    if laPom.Count=0 then Result:= False;
  finally
    laPom.Free;
  end;
end;

function GetSQLFloat(Value:Extended):String;
begin
  Result:=StringReplace(FloatToStr(Value),',','.',[rfReplaceAll]);
end;

function GetFloatDef(str:string;default:Extended=0):Extended;
begin
//  Result:=StrToFloatDef(StringReplace(StringReplace(str,'.',',',[rfReplaceAll]),' ','',[rfReplaceAll]),default);
  Result:=CFxFloat.StrToFloatDef(StringReplace(StringReplace(str,'.',',',[rfReplaceAll]),' ','',[rfReplaceAll]),default,',');
end;

function ShowProgress(pCaption:string;posI,cnt:integer;info:string;showStop:Boolean=false;showMemo:Boolean=false;RichMemo:Boolean=false;ShowMainLine:integer=0):TForm;
var
  lab: TLabel;
  prog: TProgressBar;
  but: TButton;
  memo: TMemo;
  edit: TRichEdit;
  addW, posY: integer;
  MP: TPanel;
  MF: TForm;
begin
  addW:=NxIIfInt(showMemo,200,0);
  MF:=TForm.Create(nil);
  Result:=MF;
  with MF do begin
    DefaultMonitor:=dmActiveForm;
    ClientWidth:=320+addW;
    ClientHeight:=53+NxIIfInt(showMemo,255,0)+NxIIfInt(ShowMainLine>0,25,0);
    Left:=(Screen.Width-Result.Width) div 2;
    Top:=max(0,((Screen.Height-Result.Height) div 2)-300); // muze zavazet hlaseni ABRY, ktere je taky uprostred
    BorderStyle:=bsSingle;
    FormStyle:=fsStayOnTop;
    BorderIcons:=[nil];
    Caption:=pCaption;
  end;

  MP:=TPanel.Create(MF);
  with MP do begin
    Parent:=MF;
    ParentBackground:=true;
    ParentBackground:=false;
    Name:='MainPanel';
    Caption:='';
    BorderStyle:=bsNone;
    BevelOuter:=bvNone;
    BevelInner:=bvNone;
    Align:=alClient;
  end;
  posY:=5;

  but:=CreateButtonP(MF,MP,MP.ClientWidth-75,posY,'Stop','Zastav','');
  but.Height:=20;
  but.Cancel:=true;
  but.OnClick:=@StopClick;
  but.Visible:=showStop;

  if ShowMainLine>0 then begin
    prog:=TProgressBar.Create(MF);
    with prog do begin
      Parent:=MP;
      Left:=5;
      Top:=posY;
      Width:=MP.ClientWidth-Left-5-NxIIfInt(Top=5,75,0)-NxIIfInt(showMemo,240,0);
      Height:=20;
      Orientation:=pbHorizontal;
      prog.Min:=0;
      prog.Max:=ShowMainLine*100;
      Name:='MainProg';
      Position:=0;
      Tag:=0;
    end;

    if showMemo then begin
      lab:=CreateLabelP(MF,MP,prog.Left+prog.Width+5,posY+3,'MainLab','');
      posY:=posY+25;
    end else begin
      posY:=posY+prog.Height+2;
      lab:=CreateLabelP(MF,MP,5,posY,'MainLab','');
      posY:=posY+18;
    end;
  end;

  if ShowMainLine<=0 then begin
    lab:=CreateLabelP(MF,MP,5,posY,'Lab',info);
    posY:=posY+20;
  end;

  prog:=TProgressBar.Create(MF);
  with prog do begin
    Parent:=MP;
    Left:=5;
    Top:=posY;
    Width:=MP.ClientWidth-Left-5-NxIIfInt(Top=5,75,0);
    Height:=20;
    Orientation:=pbHorizontal;
    prog.Min:=0;
    prog.Max:=cnt;
    Name:='Prog';
  end;
  if cnt<=0 then prog.Visible:=false
  else prog.Position:=min(max(posI,0),cnt);
  posY:=posY+prog.Height+2;

  if ShowMainLine>0 then begin
    lab:=CreateLabelP(MF,MP,5,posY,'Lab',info);
    posY:=posY+18;
  end;

  if showMemo then begin
    if RichMemo then begin
      edit:=TRichEdit.Create(MF);
      with edit do begin
        Parent:=MP;
        Name:='Memo';
        Left:=5;
        Top:=posY;
        Width:=MP.ClientWidth-5-Left;
        Height:=MP.ClientHeight-5-Top;
        ScrollBars:=ssBoth;
        WordWrap:=false;
        Text:='';
        ParentShowHint:=false;
        ShowHint:=false;
        ParentFont:=true;
        ParentColor:=false;
      end;
      edit.PlainText:=true;
      edit.SelAttributes.Color:=1;
      // ABRA zrejme blokuje zmenu fontu, takze nema smysl resit formatovani
      if edit.SelAttributes.Color=1 then begin
        GlobParams.GetOrCreateParam(dtObject,'ProgRichEdit'+IntToStr(ObjToInt(edit.Lines))).AsObject:=edit;
      end else GlobParams.DeleteByName('ProgRichEdit'+IntToStr(ObjToInt(memo.Lines)));
    end else begin
      memo:=CreateMemoP(MF,MP,5,posY,MP.ClientWidth-10,MP.ClientHeight-5-posY,'Memo','','');
      memo.ScrollBars:=ssBoth;
      memo.WordWrap:=false;
      GlobParams.DeleteByName('ProgRichEdit'+IntToStr(ObjToInt(memo.Lines)));
    end;
  end else MF.ClientHeight:=posY+5;
  MF.Show;
end;

function CreateMemoP(owner:TComponent;parent:TWinControl;Left,Top,Width,Height:integer;Name,Text,Hint:string):TMemo;
begin
  Result:=TMemo.Create(owner);
  Result.Parent:=parent;
  Result.Name:=Name;
  Result.Left:=Left;
  Result.Top:=Top;
  Result.Width:=Width;
  Result.Height:=Height;
  Result.WordWrap:=false;
  Result.Text:=Text;
  Result.ParentShowHint:=false;
  Result.ShowHint:=Hint<>'';
  Result.DoubleBuffered:=false;
  Result.Hint:=Hint;
end;

function CreateLabelP(owner:TComponent;parent:TWinControl;Left,Top:integer;Name,Caption:string):TLabel;
begin
  Result:=TLabel.Create(owner);
  Result.Parent:=parent;
  Result.Name:=Name;
  Result.Caption:=Caption;
  Result.Left:=Left;
  Result.Top:=Top;
  Result.Visible:=false;
  Result.Visible:=true;
  Result.Transparent:=true;
end;

function CreateButtonP(owner:TComponent;parent:TWinControl;Left,Top:integer;Name,Caption,Hint:string):TButton;
begin
  Result:=TButton.Create(owner);
  Result.Parent:=parent;
  Result.Left:=Left;
  Result.Top:=Top;
  Result.Name:=Name;
  Result.Width:=70;
  Result.DoubleBuffered:=false;
//  Result.DoubleBuffered:=false;
  Result.Caption:=Caption;
  Result.ParentShowHint:=false;
  Result.ShowHint:=Hint<>'';
  Result.Hint:=Hint;
end;

function ShowMultiText(Msg:string;buttons:string='c0=&OK';defBut:integer=0;sCaption:string='';hints:string='';PF:TForm=nil):integer;
var
  MF: TForm;
  memo: TMemo;
  but, but2: TButton;
  ratio: Extended;
  listB, listH: TStringList;
  i, i1, maxW, W, maxWB, rowW, rows, res, cancI: integer;
  str, hint: string;
  mon: TMonitor;
begin
  Result:=0;
  MF:=TForm.Create(Nil);
  listB:=TStringList.Create;
  listH:=TStringList.Create;
  try
    if hints<>'' then listH.CommaText:=hints;
    if buttons='' then buttons:='c0=&OK';
    listB.CommaText:=buttons;
    if defBut<0 then defBut:=0;
    if defBut>listB.Count then defBut:=0;

    mon:=nil;
    try
      if Assigned(PF) then begin
        PF.ClassName;
        mon:=PF.Monitor;
      end;
    except
      mon:=nil;
    end;

    with MF do begin
      DefaultMonitor:=dmActiveForm;
      Caption:=NxIIfStr(sCaption='','Dotaz ABRA G4',sCaption);
      BorderStyle:=bsDialog;
      FormStyle:=fsStayOnTop;
      KeyPreview:=true;
      ClientWidth:=Screen.WorkAreaWidth-100;
      ClientHeight:=300;

      Font.Name:=GetFormFont(Font.Name);
      Color:=clWhite;
      Tag:=defBut;
      OnKeyDown:=@_MultiTextFormKDown;
      OnShow:=@_MultiTextFormShow;
    end;

    maxW:=Screen.WorkAreaWidth-20;
    rowW:=5;
    rows:=1;
    maxWB:=10;
    gButClicked:=defBut;
    cancI:=defBut;
    for i:=0 to listB.Count-1 do begin
      str:=listB[i];
      hint:='';
      if i<listH.Count then hint:=listH[i];
      but:=CreateButtonP(MF,MF,rowW,MF.ClientHeight-30,'but'+IntToStr(i),'',hint);
      but.OnClick:=@_MultiTextClick;
//      but.ModalResult:=6;

//      but.Cancel:=true;
//      but.Default:=defBut=i;
      but.Tag:=-1;
      i1:=pos('=',str);
      if i1>1 then begin
        if UpperCase(copy(str,1,1))='C' then begin
          cancI:=i;
          Delete(str,1,1);
          i1:=i1-1;
        end;
        but.Tag:=StrToInt(copy(str,1,i1-1));
        str:=copy(str,i1+1,100);
      end;
      but.Caption:=str;
      W:=Max(70,6+MF.Canvas.TextWidth(StringReplace(str,'&','',nil)));
      but.Width:=W;
      rowW:=rowW+W+5;
      if rowW>maxW then begin
        for i1:=0 to i-1 do begin
          but2:=TButton(MF.FindComponent('but'+IntToStr(i1)));
          but2.Top:=but2.Top-30;
        end;
        rows:=rows+1;
        rowW:=5+W+5;
        but.Left:=5;
      end;
      but.Anchors:=[akBottom,akLeft];
      maxWB:=max(maxWB,rowW);
    end;
    but:=TButton(MF.FindComponent('but'+IntToStr(cancI)));
    but.Cancel:=true;
    gButClicked:=but.Tag;

    memo:=TMemo.Create(MF);
    with memo do begin
      Parent:=MF;
      Top:=5;
      Left:=5;
      Name:='Logs';
//      WordWrap:=false;
      Text:=Msg;
      Width:=MF.ClientWidth-10;
      Height:=MF.ClientHeight-rows*30-10;
//      ReadOnly:=true;
//      ScrollBars:=ssBoth;
      ReadOnly:=true;
      Color:=clWhite;
      BevelOuter:=bvNone;
      BevelInner:=bvNone;
      BevelKind:=bkNone;
      TabStop:=false;
      Anchors:=[akLeft,akRight,akTop,akBottom];
      BorderStyle:=bsNone;
      Brush.Color:=clWhite;
      Ctl3D:=false;
    end;
    i:=max(memo.Lines.Count,1)*MF.Canvas.TextHeight('X')+rows*30+15+MF.Height-MF.ClientHeight;
    W:=maxW;
    if i>(Screen.WorkAreaHeight-10) then begin
      i:=Screen.WorkAreaHeight-10;
      memo.ScrollBars:=ssBoth;
    end else begin
      W:=0;
      for i1:=0 to memo.Lines.Count-1 do W:=max(W,MF.Canvas.TextWidth(memo.Lines[i1]));
      W:=W+20;
      if W>maxW then memo.ScrollBars:=ssBoth;
    end;
    MF.Height:=i;

    MF.ClientWidth:=min(max(W,maxWB),maxW);

    if Assigned(mon) then begin
      MF.Left:=mon.WorkareaLeft+Max((mon.WorkAreaWidth-MF.Width) div 2,0);
      MF.Top:=mon.WorkareaTop+Max((mon.WorkAreaHeight-MF.Height) div 2,0);
      //PlaceFormAtMiddlePrepare(MF,MF);
    end;

    if rows=1 then begin
      W:=(MF.ClientWidth-maxWB) div 2;
      for i:=0 to listB.Count-1 do begin
        but:=TButton(MF.FindComponent('but'+IntToStr(i)));
        but.Left:=but.Left+W;
      end;
    end;

//    NxAddAppWindowStyle(MF.Handle);
    MF.ShowModal(nil);
    Result:=gButClicked;
  finally
    listH.Free;
    listB.Free;
    MF.Free;
  end;
end;

function GetFormFont(Default:string):string;
var
  i, i1: integer;
begin
  Result:=Default;
  for i:=0 to Length(c_FormFonts)-1 do begin
    for i1:=0 to Screen.Fonts.Count-1 do if UpperCase(c_FormFonts[i])=UpperCase(Screen.Fonts[i1]) then begin
      Result:=Screen.Fonts[i1];
      exit;
    end;
  end;
end;

procedure _MultiTextClick(but:TButton);
begin
  gButClicked:=but.Tag;
  TForm(but.Owner).ModalResult:=NxIIfInt(but.Cancel,7,6);
end;

procedure _MultiTextFormKDown(MF:TForm;var Key: Word; Shift: TShiftState);
var
  memo: TMemo;
begin
  if (Key=ord('C')) and (ssCtrl in Shift) then begin
    Key:=0;
    memo:=TMemo(MF.FindComponent('Logs'));
    if memo.SelLength<=0 then begin
      memo.SelectAll;
      memo.CopyToClipboard;
      memo.SelLength:=0;
    end else memo.CopyToClipboard;
  end;
end;

procedure _MultiTextFormShow(MF:TForm);
begin
  TButton(MF.FindComponent('but'+IntToStr(MF.Tag))).SetFocus;
  //PlaceFormAtMiddleShow(MF);
end;


function ShowDialog(Msg:string;IsAppForm:Boolean=true;PF:TForm=nil):Boolean;
begin
  Result:=ShowMultiText(Msg,'1=&Ano,c0=&Ne',0,'','',PF)>0;
end;


function GetProgressMemoLines(form:TForm):TStrings;
var
  c: TWinControl;
begin
  Result:=nil;
  if not(assigned(form)) then exit;
  c:=TWinControl(form.FindComponent('Memo'));
  if not(assigned(c)) then exit;
  if c is TMemo then Result:=TMemo(c).Lines;
  if c is TRichEdit then Result:=TRichEdit(c).Lines;
end;

procedure StopClick(Sender:TButton);
begin
  if not(Assigned(Sender)) then exit;
  if not(Sender.Visible) then exit;
  if Sender.Tag>0 then begin
    TForm(Sender.Owner).ModalResult:=6;
    exit;
  end;
  if not(ShowDialog('Opravdu chcete zastavit další zpracování?')) then exit;
  Sender.Enabled:=false;
end;

procedure StopProgress(form:TForm;NoShow:Boolean=false);
var
  but: TButton;
  c: TWinControl;
begin
  if not(assigned(form)) then exit;
  if not(NoShow) then form.Hide;
  Application.ProcessMessages;
  but:=TButton(form.FindComponent('Stop'));
  but.Caption:='OK';
  but.Default:=true;
  but.Cancel:=true;
  but.Tag:=1;
  but.Visible:=true;
  but.Enabled:=true;
  but.TabOrder:=0;

  c:=TWinControl(form.FindComponent('Memo'));
  if assigned(c) then if c is TRichEdit then begin
    GlobParams.DeleteByName('ProgRichEdit'+IntToStr(ObjToInt(TRichEdit(c).Lines)));
  end;

  if not(NoShow) then form.ShowModal(nil);
end;

procedure SetMainProgress(form:TForm;posI:integer;info:string);
var
  lab: TLabel;
  prog, MProg: TProgressBar;
  but: TButton;
  i: integer;
  pCH: Boolean;
begin
  if not(Assigned(form)) then exit;
  MProg:=TProgressBar(form.FindComponent('MainProg'));
  if not(assigned(MProg)) then exit;
  lab:=TLabel(form.FindComponent('MainLab'));
  prog:=TProgressBar(form.FindComponent('Prog'));
  if posI<0 then posI:=MProg.Tag;
  pCH:=MProg.Tag<>posI;
  if pCH then MProg.Tag:=posI;

  i:=100;
  if prog.Visible then i:=max(0,min(100,(prog.Position*100) div prog.Max));
  MProg.Position:=min(MProg.Max,posI*100+i);

  if (info<>'') or pCH then begin
    if info='' then begin
      info:=RTTI.GetStrProp(lab,'Caption');
      i:=pos(') ',info);
      if i>0 then Delete(info,1,i+1);
    end;
    lab.Caption:='('+IntToStr(posI+1)+'/'+IntToStr(MProg.Max div 100)+') '+info;
  end;
  //Application.ProcessMessages;
end;

procedure SetMainProgressMax(form:TForm;ShowMainLine:integer);
var
  lab: TLabel;
  prog, MProg: TProgressBar;
  but: TButton;
  i: integer;
  pCH: Boolean;
begin
  if ShowMainLine<=0 then exit;
  if not(Assigned(form)) then exit;
  MProg:=TProgressBar(form.FindComponent('MainProg'));
  if not(assigned(MProg)) then exit;
  MProg.Position:=min(MProg.Position,ShowMainLine*100);
  MProg.Tag:=min(MProg.Tag,ShowMainLine);
  MProg.Max:=ShowMainLine*100;
  SetMainProgress(form,-1,'');
end;

function GetPeriodOS(OS:TNxCustomObjectSpace;aDate:TDateTime=0):TNxOID;
var
  list: TStringList;
begin
  Result:='';
  if aDate<1 then aDate:=Date else aDate:=DateOf(aDate);
  list:=TStringList.Create;
  try
    OS.SQLSelect('SELECT ID FROM Periods WHERE DateFrom$DATE<='+IntToStr(Round(aDate))
      +' AND DateTo$DATE>'+IntToStr(Round(aDate))+' ORDER BY SequenceNumber',list);
    if list.Count>0 then Result:=list[0];
  finally
    list.Free;
  end;
end;

function GetDBSubStr(Str,From:string;sFor:string=''):string;
begin
  case CFxNxRuntime.NxGetDatabaseCode of
    'ORA':Result:='SUBSTR('+Str+','+From+NxIIfStr(sFor='','',','+sFor)+')';
    'IB':Result:='SUBSTRING('+Str+' FROM '+From+NxIIfStr(sFor='','',' FOR '+sFor)+')';
     else Result:='SUBSTRING('+Str+','+From+NxIIfStr(sFor='',',999999',','+sFor)+')';
  end;
end;

function ParseCSV(src:string;delimiter:char;dest:TStrings):integer;
var
  i, state: integer;
  str: string;
  quote: Boolean;
begin
  Result:=0;
  if not(Assigned(dest)) then exit;
  dest.Delimiter:=delimiter;
  dest.StrictDelimiter:=true;
  try
    dest.DelimitedText:=src;
    Result:=dest.Count;
  except
    Result:=ParseCSVSlow(src,delimiter,dest);
  end;
end;

function ParseCSVSlow(src:string;delimiter:char;dest:TStrings):integer;
var
  i, state: integer;
  str: string;
  quote: Boolean;
begin
  Result:=0;
  if not(Assigned(dest)) then exit;
  dest.Clear;
  state:=0;
  str:='';
  quote:=false;
  for i:=1 to length(src) do begin
    case state of
      0:begin
          if src[i]='"' then begin
            state:=1;
            if quote then str:=str+'"';
          end else if src[i]=delimiter then begin
            quote:=false;
            dest.Add(str);
            str:='';
          end
          else str:=str+src[i];
          quote:=false;
        end;
      1:begin
          quote:=true;
          if src[i]='"' then state:=0
          else str:=str+src[i];
        end;
    end;
  end;
  dest.Add(str);
  Result:=dest.Count;
end;

function SetRelation(OS: TNxCustomObjectSpace;
                     Rel_Def:integer;
                     Left_ID,Right_ID:TNxOID;
                     enabled:Boolean=true;
                     Value:Extended=0;
                     Aditive:Boolean=false):string;
var
  loObj: TNxCustomBusinessObject;
  list: TStringList;
  SP: TNxParameters;
begin
  Result:='';
  SP:=TNxParameters.Create;
  list:=TStringList.Create;
  loObj:=OS.CreateObject(Class_Relation);
  try
    try
      SP.GetOrCreateParam(dtString,'Left_ID').AsString:=Left_ID;
      SP.GetOrCreateParam(dtString,'Right_ID').AsString:=Right_ID;
      SP.GetOrCreateParam(dtInteger,'Rel_Def').AsInteger:=Rel_Def;
      OS.SQLSelect('SELECT ID FROM Relations WHERE Rel_Def=:Rel_Def AND LeftSide_ID=:Left_ID AND RightSide_ID=:Right_ID',list,SP);
      if list.Count>0 then begin
        loObj.Load(list[0],nil);
        if enabled then begin
          if Aditive then Value:=Value+loObj.GetFieldValueAsFloat('NumValue');
          if Abs(loObj.GetFieldValueAsFloat('NumValue')-Value)>=0.0000001 then begin
            loObj.SetFieldValueAsFloat('NumValue',Value);
            loObj.Save;
          end;
        end else loObj.Delete;
      end else if enabled then begin
        loObj.New;
        loObj.Prefill;
        loObj.SetFieldValueAsInteger('Rel_Def',Rel_Def);
  //        if Value<1 then Value:=Now;
        loObj.SetFieldValueAsFloat('NumValue',Value);
        loObj.SetFieldValueAsString('LeftSide_ID',Left_ID);
        loObj.SetFieldValueAsString('RightSide_ID',Right_ID);
        loObj.Save;
      end;
    except
      Result:= ExceptionMessage;
    end;
  finally
    loObj.Free;
    list.Free;
    SP.Free;
  end;
end;

begin
end.