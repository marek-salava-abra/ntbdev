function GetReceivedOrder_ID(AOS : TNxCustomObjectSpace; aExternalNumber : string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders WHERE ExternalNumber=''%s'' and DocQueue_ID=''1LA0000101'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aExternalNumber]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;


function GetCounter(AReportHelper:TNxQRScriptHelper):Integer;
begin
  if GlobParams.ParamExist('counter') then
  Result:=GlobParams.ParamByName('counter').AsInteger else
  Result:=1;
end;

function GetPocet(AReportHelper:TNxQRScriptHelper):Integer;
begin
  if GlobParams.ParamExist('pocet') then
  Result:=GlobParams.ParamByName('pocet').AsInteger else
  Result:=1;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;


function BarCodeDialog(var ABarCode : string; aSite:TSiteForm) : boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mBarCodeEdt : TEdit;
begin
  Result := False;
  ABarCode := '';
  mForm := TForm.Create(Application.MainForm);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Left := 30;
  mForm.Top := 50;
  mForm.Width := 290;  // sirka
  mForm.Height := 100; // vyska
  mForm.Caption := 'Výběr dokladu';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Doklad:';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblDocNumber';
  mForm.InsertControl(mLbl);

  mBarCodeEdt := TEdit.Create(mForm);
  mBarCodeEdt.Left := 90;
  mBarCodeEdt.Top := 8;
  mBarCodeEdt.Width := mForm.Width - mBarCodeEdt.Left - 22; //140;
  mBarCodeEdt.Name := 'edtDocNumber';
  mBarCodeEdt.Text := '';
  mForm.InsertControl(mBarCodeEdt);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  Result := mForm.ShowModal(Asite)= mrOK;
  if Result then
    ABarCode := mBarCodeEdt.Text;
end;

function BalikDialog(var aPocetBaliku : Extended; aSite:TSiteForm) : boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mBarCodeEdt : TNumEdit;
begin
  Result := False;
  mForm := TForm.Create(Application.MainForm);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Left := 30;
  mForm.Top := 50;
  mForm.Width := 290;  // sirka
  mForm.Height := 100; // vyska
  mForm.Caption := 'Zadejte data';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Počet balíků:';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblDocNumber';
  mForm.InsertControl(mLbl);

  mBarCodeEdt := TNumEdit.Create(mForm);
  mBarCodeEdt.Left := 90;
  mBarCodeEdt.Top := 8;
  mBarCodeEdt.Width := mForm.Width - mBarCodeEdt.Left - 22; //140;
  mBarCodeEdt.Name := 'edtDocNumber';
  mBarCodeEdt.Value := 1;
  mForm.InsertControl(mBarCodeEdt);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  Result := mForm.ShowModal(Asite)= mrOK;
  if Result then
    aPocetBaliku := mBarCodeEdt.value;
end;

function API_POST(aJSON:TJSONSuperObject):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
begin
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', 'http://192.168.0.81:88/Servis/script/APISync/lib/OrderDate/');
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic QVBJOmFicmFhcGk=');
   mWinHTTP.Send(aJSON.AsJson);
   Result:=TJSONSuperObject.Create;
   Result.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
   Result.S['InputJSON']:='#'+aJSON.AsString+'#'+TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True).AsString+'#';
   if mWinHTTP.status='200' then begin
     Result.S['Status']:='OK';
   end else begin
     Result.S['Status']:='Error1';
   end;
end;

function API_POSTSK(aJSON:TJSONSuperObject):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
begin
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', 'http://192.168.0.79:88/Data/script/APISync/lib/OrderDate/');
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic QVBJOmFicmFhcGk=');
   mWinHTTP.Send(aJSON.AsJson);
   Result:=TJSONSuperObject.Create;
   Result.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
   Result.S['InputJSON']:='#'+aJSON.AsString+'#'+TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True).AsString+'#';
   if mWinHTTP.status='200' then begin
     Result.S['Status']:='OK';
   end else begin
     Result.S['Status']:='Error1';
   end;
end;



{IsAllAvailable}

function IsAllAvailable(AReportHelper:TNxQRScriptHelper;mOrder_ID:String):Boolean;
var
 mBO,mRowBO:TNxCustomBusinessObject;
 i:integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mResult:Boolean;
 mQuantity:Extended;
begin
  mResult:=True;
  mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
  mBO.Load(mOrder_ID,nil);
  mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for i:=0 to mRows.count-1 do begin
    mRowBO:=mRows.BusinessObject[i];
    if mResult and (mrowbo.GetFieldValueAsInteger('RowType')=3) and (mRowBO.GetFieldValueAsFloat('DeliveredQuantity')=0)then begin
      mQuantity:=mbo.ObjectSpace.SQLSelectFirstAsExtended('Select quantity from storesubcards where storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('Storecard_ID'))+
                                                          ' and store_id='+QuotedStr(mRowBO.GetFieldValueAsString('Store_ID')),0);
      if mQuantity<(mRowBO.GetFieldValueAsFloat('Quantity')/mRowBO.GetFieldValueAsFloat('UnitRate')) then mResult:=false;
    end;
  end;
  Result:=mResult;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','2100000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     if not(NxIsEmptyOID(ADivision_ID))then mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetLoadedCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     mMailBO.Save;
     mMailBO.free;

  end;
end;




begin
end.