Procedure ComplPrice(sender:Tcomponent);
var
 mSite:Tsiteform;
 mOS:TNxCustomObjectSpace;
 mReceiptCard, mRowBO:TNxCustomBusinessObject;
 mList:TstringList;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mDocNumnber, mFirm_ID:String;
 mPrice,mTransportprice:Extended;
begin
   mSite:=TComponent(sender).DynSite;
   mOS:=mSite.BaseObjectSpace;
   mList:=TStringList.create;
   mFirm_id:='';
   mDocNumnber:='';
   mPrice:=0;
   mTransportprice:=0;
   mOS.SQLSelect(format('Select rightside_id from relations where rel_def=1245 and leftside_id=''%s'' ',[TDynSiteForm(mSite).CurrentObject.OID]),mList);
   if mList.Count>0 then begin
      if PRSDataDialog(msite, mDocNumnber, mPrice, mTransportprice,mFirm_ID) then begin
      //NxShowSimpleMessage(mFirm_ID,mSite);
      mReceiptCard:=mos.CreateObject(Class_ReceiptCard);
      mReceiptCard.Load(mList.strings[0],nil);
      mReceiptCard.SetFieldValueAsString('Description',mDocNumnber);
      if not(NxIsEmptyOID(mFirm_ID)) then mReceiptCard.SetFieldValueAsString('Firm_ID',mFirm_ID);
      mRows:=mReceiptCard.GetLoadedCollectionMonikerForFieldCode(mReceiptCard.GetFieldCode('Rows'));
      mRowBO:=mRows.BusinessObject[0];
      //for i:=0 to mRows.Count-1 do begin
        mRowBO.SetFieldValueAsBoolean('CompletePrices',true);
        mRowBO.SetFieldValueAsFloat('UnitPrice',mPrice);
        mRowBO.GetMonikerForFieldCode(mRowBO.GetFieldCode('AdditionalCosts_ID')).BusinessObject.SetFieldValueAsFloat('TransportationAmount',mTransportPrice);

      //end;
      if mReceiptCard.NeedSave then mReceiptCard.save;
      end;
    TDynSiteForm(mSite).RefreshData;
   end;
end;

Function PRSDataDialog(var asite:tsiteform; var aDescription: string;var aUnitPrice,aTransportPrice:Extended; var aFirm_ID:string):boolean;

 var
  mForm: TForm;

    mCbFirm: TRollComboEdit;
    mCbCcFirm: TLabel;
  mLab, mlabel3: TLabel;
  mEd1: TEdit;
  mEd2, mEd3: TNumEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(asite);
  try
    mForm.Caption := 'Zadejte popis';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 550;
    mForm.Height := 220;
    mForm.Scaled := False;
    mform.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 17;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.DataText:=aFirm_ID;
    mCbFirm.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 17;
    mCbFirm.Left:= 110;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru


    mLab := TLabel.Create(mForm);
    mLab.Left := 17;
    mLab.Top := 40;
    mLab.Caption := 'Popis';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 17;
    mLab.Top := 75;
    mLab.Caption := 'Cena';
    mLab.Parent := mForm;

    mLab := TLabel.Create(mForm);
    mLab.Left := 17;
    mLab.Top := 100;
    mLab.Caption := 'Doprava';
    mLab.Parent := mForm;
    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 46;
    mEd1.Width := 200;
    mEd1.Text := aDescription;
    mEd1.Parent := mForm;
    med2 := TNumEdit.Create(mForm);
    med2.left :=110;
    med2.top := 71;
    med2.Value := aUnitPrice;
    med2.DecimalPlaces := 2;
    med2.parent :=mForm;

    med3 := TNumEdit.Create(mForm);
    med3.left :=110;
    med3.top := 96;
    med3.Value := aTransportPrice;
    med3.DecimalPlaces := 2;
    med3.parent :=mForm;
    CreateButton2(mForm, mForm, 140, 20, 70, 25, 'Cancel', 2);
    CreateButton2(mForm, mForm, 140, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then  begin
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aDescription:=mEd1.Text;
      aUnitPrice:=med2.Value;
      aTransportPrice:=med3.value;
      aFirm_id:= mCbFirm.DataText;
      Result:=True
    end else begin
    NxShowSimpleMessage('Ruším',asite);
    Result:=False;

    end;
  finally
    mForm.Free;
  end;
end;

function CreateButton2(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;


begin
end.