procedure CheckOrders(OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i:integer;
 mMessage, mOrder_ID:string;
 mOrderBO:TNxCustomBusinessObject;
 mSendMail:Boolean;
begin
  mMessage:='Zaplacené OP: ';
  mSendMail:=False;
  mXMLHead:=TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile('c:\abra_export\orders.xml');
  if mXMLHead.getElementsCountInArray('ORDER')>0 then begin
    for i:=0 to mXMLHead.getElementsCountInArray('Order')-1 do begin
       mOrder_ID:=GetOrder_ID(OS,mXMLHead.getElementAsString('Order['+IntToStr(i)+'].Code'));
       if not(NxIsEmptyOID(mOrder_ID)) then begin
          mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
          mOrderBO.Load(mOrder_ID,nil);
           if not(mOrderBO.GetFieldValueAsBoolean('X_Paid')) and (UpperCase(mXMLHead.getElementAsString('Order['+IntToStr(i)+'].Paid'))='ANO') then begin
              mOrderBO.SetFieldValueAsBoolean('X_Paid',True);
              mOrderBO.SetFieldValueAsString('X_PinToPickup',mXMLHead.getElementAsString('Order['+IntToStr(i)+'].PinToPickup'));
              mMessage:=mMessage+#13#10+mOrderBO.DisplayName+' '+mXMLHead.getElementAsString('Order['+IntToStr(i)+'].Code');
              mSendMail:=True;
           end;
          if mOrderBO.needsave then mOrderBO.Save;
          mOrderBO.Free;
       end;
    end;
  end;
  if mSendMail then begin
    //odeslání informací o zaplacených OP
    SendInternalMail(OS,'radim.kovar@obb.cz','','',
                        'Zaplacené objednávky Deus Tectum',mMessage,
                        '','','AAA1000000','#000000101','#000000201');

  end;
  Success := True;
  LogInfoStr := '';
end;

procedure InsertOrderFromDirectory(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j:integer;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mStoreCard_ID, mOrder_ID:string;
begin
  mXMLHead:=TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(Directory+'\'+FileName);
  if mXMLHead.getElementsCountInArray('ORDER')>0 then begin
       mOrder_ID:=GetOrder_ID(OS,mXMLHead.getElementAsString('ORDER[0].ExternalNumber'));
       if NxIsEmptyOID(mOrder_ID) then begin
       mBO:=os.CreateObject(Class_ReceivedOrder);
       mBO.New;
       mbo.Prefill;
       mbo.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ORDER[0].ExternalNumber'));
       mbo.SetFieldValueAsString('Firm_ID',GetFirm_ID(OS,mXMLHead.getElementAsString('ORDER[0].OwnOrgIdentNumber')));
       mbo.SetFieldValueAsString('U_Street',mXMLHead.getElementAsString('ORDER[0].Target_Street'));
       mbo.SetFieldValueAsString('U_City',mXMLHead.getElementAsString('ORDER[0].Target_City'));
       mbo.SetFieldValueAsString('U_PostCode',mXMLHead.getElementAsString('ORDER[0].Target_PostCode'));
       mbo.SetFieldValueAsString('U_Contact',mXMLHead.getElementAsString('ORDER[0].Target_Name'));
       mbo.SetFieldValueAsString('U_Target_Street',mXMLHead.getElementAsString('ORDER[0].Target_Street'));
       mbo.SetFieldValueAsString('U_Target_City',mXMLHead.getElementAsString('ORDER[0].Target_City'));
       mbo.SetFieldValueAsString('U_Target_PostCode',mXMLHead.getElementAsString('ORDER[0].Target_PostCode'));
       mbo.SetFieldValueAsString('U_Target_Name',mXMLHead.getElementAsString('ORDER[0].Target_Name'));
       mbo.SetFieldValueAsString('U_Target_Email',mXMLHead.getElementAsString('ORDER[0].Target_Email'));
       mbo.SetFieldValueAsString('U_Note',mXMLHead.getElementAsString('ORDER[0].Note'));
       mbo.SetFieldValueAsString('U_Target_PhoneNumber',mXMLHead.getElementAsString('ORDER[0].Target_PhoneNumber'));
       mbo.SetFieldValueAsString('X_PinToPickup',mXMLHead.getElementAsString('ORDER[0].PinToPickup'));
       mbo.SetFieldValueAsString('U_TransportText',mXMLHead.getElementAsString('ORDER[0].TransportText'));
       if mXMLHead.getElementAsString('ORDER[0].Paid')='Ano' then mBO.SetFieldValueAsBoolean('X_Paid',true);
       if mXMLHead.getElementAsString('ORDER[0].CashOnDelivery')='Ano' then begin
        mbo.SetFieldValueAsBoolean('U_CashOnDelivery',true);
        mbo.SetFieldValueAsBoolean('U_Eshop_Delivery',true);
       end;
       mbo.SetFieldValueAsString('DocQueue_ID','#000000602');
       mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
            for i:=0 to mXMLHead.getElementsCountInArray('ORDER[0].Rows.Row')-1 do begin
             if mXMLHead.getElementAsInteger('ORDER[0].Rows.Row['+IntToStr(i)+'].RowType')=3 then begin
               mStoreCard_ID:=GetStoreCard_ID(OS,mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].StoreCard.Code'),mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Qunit'));
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mRowBO:=mrows.AddNewObject;
                 mRowBO.Prefill;
                 mRowBO.SetFieldValueAsInteger('RowType',3);
                 mRowBO.SetFieldValueAsString('Store_ID','#000000101');
                 mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                 mRowBO.SetFieldValueAsString('X_StockType_ID','1000000101');
                 mRowBO.SetFieldValueAsString('U_Abra_ID',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Abra_ID'));
                 mRowBO.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Quantity')));
                 mRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].UnitPrice')));
                 //mRowBO.SetFieldValueAsFloat('TotalPrice',mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].TamountWithoutVAT'));
                 mRowBO.SetFieldValueAsString('Division_ID','#000000101');
                 mRowBO.SetFieldValueAsString('BusTransaction_ID','#000000201');
                end;
                if NxIsEmptyOID(mStoreCard_ID) then begin
                 mRowBO:=mRows.AddNewObject;
                 mRowBO.Prefill;
                 mRowBO.SetFieldValueAsInteger('RowType',2);
                 mRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].StoreCard.Code')+' '+mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].StoreCard.Name'));
                 mRowBO.SetFieldValueAsString('QUnit',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Qunit'));
                 mRowBO.SetFieldValueAsString('U_Abra_ID',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Abra_ID'));
                 mRowBO.SetFieldValueAsFloat('Quantity', mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].Quantity'));
                 mRowBO.SetFieldValueAsFloat('UnitPrice',mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].UnitPrice'));
                 //mRowBO.SetFieldValueAsFloat('TotalPrice',mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].TamountWithoutVAT'));
                 mRowBO.SetFieldValueAsString('VatRate_ID',GetVatRate_ID(OS,mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].VatRate')));
                 mRowBO.SetFieldValueAsString('Division_ID','#000000101');
                 mRowBO.SetFieldValueAsString('BusTransaction_ID','#000000201');
                end;
             end;
       end;
      mBO.save;
      SendInternalMail(OS,'radim.kovar@obb.cz','','',
                          'Naimportována objednávka z DEUS '+mbo.DisplayName,'',
                          '','','AAA1000000','#000000101','#000000201');
      mbo.free;
    end else begin
      SendInternalMail(OS,'deus@obb.cz','','',
                          'Při importu z DEUSU došlo ke zdvojení čísla objednávky: '+mXMLHead.getElementAsString('ORDER[0].ExternalNumber')+' druhý doklad byl ignorován. Doporučuji prověřit v Abra Deus  ','',
                          '','','AAA1000000','#000000101','#000000201');

    end;
  end;
  mXMLHead.free;
  ProcessContinue := True;

end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode, aUnit : string) : string;
const
  cSQL = 'SELECT sc.ID FROM StoreCards sc where sc.Code=''%s'' and sc.mainunitcode=''%s'' and sc.Hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode, aUnit]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetBODDQ_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DocQueues where Code=''%s'' and documenttype=''21'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetOTDQ_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DocQueues where Code=''%s'' and documenttype=''22'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetStore_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from Stores where Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetDivision_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from Divisions where Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetDestStore_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DefrollData where Code=''%s'' and hidden=''N'' and clsid=''HAZHZMELAVZ4LHHEMATKUV1JUG'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetITDQ_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DocQueues where Code=''%s'' and documenttype=''24'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetVRDQ_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DocQueues where Code=''%s'' and documenttype=''23'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetICNDQ_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DocQueues where Code=''%s'' and documenttype=''60'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;


function GetIIDQ_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from DocQueues where Code=''%s'' and documenttype=''03'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetVatRate_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from vatrates where tariff=%s ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='02100X0000'
  finally
    mList.Free;
  end;
end;

function GetAvailableQuantity(AOS : TNxCustomObjectSpace; aStoreCard_ID, aStore_ID : string) : Extended;
const
  cSQL = 'SELECT sum(quantity) from StoreSubCards where StoreCard_ID=''%s'' and Store_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID]), mList);
    if mList.Count > 0 then
      Result := NxibStrToFloat(mList.Strings[0])
      else Result:=0
  finally
    mList.Free;
  end;
end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; aOrgIdentNumber : string) : string;
const
  cSQL = 'SELECT F.ID FROM Firms F where F.OrgIdentNumber=''%s'' and F.Hidden=''N'' and f.firm_id is null ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOrgIdentNumber]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetOrderFromICN_ID(AOS : TNxCustomObjectSpace; aICN_ID : string) : string;
const
  cSQL = 'select sd2.provide_id from issuedcreditnotes icn left join issuedinvoices2 ii2 on ii2.parent_id=icn.source_id '+
         'left join storedocuments2 sd2 on sd2.id=ii2.providerow_id  where icn.id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aICN_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetOrder_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from ReceivedOrders where ExternalNumber=''%s'' and DocQueue_ID=''#000000602'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetOrderPIN_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT id from ReceivedOrders where X_pinVR=''%s'' and DocQueue_ID=''#000000602'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetOrderFromDL_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT sd2.provide_id from StoreDocuments sd left join periods p on p.id=sd.period_ID left join storedocuments2 sd2 on sd2.parent_id=sd.id where sd.ordnumber=%s and p.code=''%s'' and sd.DocQueue_ID=''#00000080K'' '; //#### řada DL97
var
  mList : TStringList;
  mDQCode, mOrdNumber, mPeriodCode:string;
begin
  Result:='';
  mDQCode:=NxToken(aCode,'-');
  mOrdNumber:=NxToken(aCode,'/');
  mPeriodCode:=aCode;
  mList := TStringList.Create;
  if mDQCode='DL97' then begin
    try
      AOS.SQLSelect(Format(cSQL, [mOrdNumber,mPeriodCode]), mList);
      if mList.Count > 0 then
        Result := mList.Strings[0]
        else Result:=''
    finally
      mList.Free;
    end;
  end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement, AAtachement1 :String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
  mContext: TNxContext;
  mOS: TNxCustomObjectSpace;
begin
  mContext:=NxCreateNotLoggedContext(AOS);
  mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
  mOS:= mContext.GetObjectSpace;
  if not(ato='') then begin
     mMailBO:=mOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','3000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsBoolean('X_dont_delete',false);
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
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     if not(AAtachement1='') then begin
      if FileExists(AAtachement1) then TNxEmailSent(mMailBO).AttachFile(AAtachement1);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;

Function GetSearchData(var aSite:TSiteForm; var aExternalNumber, aDLNumber:string; var aResult:Integer):boolean;
var
 mEd1, mEd2:TEdit;
 mDed1:TDateEdit;
 mLabel1: TLabel;
 mButOk, mButCancel : TButton;
 mForm:TForm;
 mBEd01,mBEd03,mBEd02,mBEd04,mBEd05,mBed06:TCheckBox;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 500;
    mForm.Height:= 150;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Stačí vyplnit pouze jednu hodnotu';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Číslo objednávky Deus';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 150;
    med1.Width := 300;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'DL číslo';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.parent :=mForm;
    mEd2.top := 35;
    mEd2.left := 150;
    mEd2.Width := 300;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 70;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 70;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    aResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if aResult = 1 then
        aExternalNumber:=mEd1.Text;
        aDLNumber:=med2.text;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

end;

Function GetSearchData2(var aSite:TSiteForm; var aExternalNumber, aDLNumber:string; var aResult:Integer):boolean;
var
 mEd1, mEd2:TEdit;
 mDed1:TDateEdit;
 mLabel1: TLabel;
 mButOk, mButCancel : TButton;
 mForm:TForm;
 mBEd01,mBEd03,mBEd02,mBEd04,mBEd05,mBed06:TCheckBox;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 500;
    mForm.Height:= 150;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Stačí vyplnit pouze jednu hodnotu';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Povolení vratky:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 150;
    med1.Width := 300;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'DL číslo';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.parent :=mForm;
    mEd2.top := 35;
    mEd2.left := 150;
    mEd2.Width := 300;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 70;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 70;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    aResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if aResult = 1 then
        aExternalNumber:=mEd1.Text;
        aDLNumber:=med2.text;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

end;



begin
end.