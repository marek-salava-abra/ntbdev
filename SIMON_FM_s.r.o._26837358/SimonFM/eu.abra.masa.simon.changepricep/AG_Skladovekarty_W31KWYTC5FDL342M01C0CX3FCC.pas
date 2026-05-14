procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := '##Změnit cenu##';
  mAct.Category := 'tabDetail';
  mAct.OnExecute := @ChangePrice;
end;

Procedure ChangePrice(Sender:tcomponent);
var
 mSite:TSiteForm;
 mSCBO, mSMBO, mStorePrice:TNxCustomBusinessObject;
 mPrice, mPriceWithoutVAT, mUnitRate:Extended;
 mResult,i:integer;
 mUnits,mStorePrices:TNxCustomBusinessMonikerCollection;
 mUnitList:TStringList;
 mSelectedUnit, mStorePrice_ID:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mSCBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mSCBO) then begin
    mUnits:=mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits'));
    mUnitList:=TStringList.Create;
    for i:=0 to mUnits.count-1 do begin
      mUnitList.Add(mUnits.BusinessObject[i].GetFieldValueAsString('Code'));
    end;
    mSelectedUnit:='';
    mPrice:=0;
    if GetDataForPrice(msite,mResult,mprice, mUnitList,mSelectedUnit) then begin
           //NxShowSimpleMessage(mSelectedUnit+' '+FloatToStr(mPrice),mSite);
           if not(NxIsBlank(mSelectedUnit)) and (mPrice>0) then begin
             mUnitRate:=mSCBO.ObjectSpace.SQLSelectFirstAsExtended('Select unitrate from storeunits where parent_id='+Quotedstr(mSCBO.OID)+' and code='+QuotedStr(mSelectedUnit),1);
             mStorePrice_ID:=mSCBO.ObjectSpace.SQLSelectFirstAsString('Select id from storeprices where pricelist_id=''1000000101'' and storecard_id='+QuotedStr(mSCBO.OID),'');
             //NxShowSimpleMessage(mStorePrice_ID+'   '+FloatToStr(mUnitRate),mSite);
             if NxIsEmptyOID(mStorePrice_ID) then begin
               mSMBO:=mscbo.ObjectSpace.CreateObject(Class_StorePrice);
               mSMBO.New;
               mSMBO.SetFieldValueAsString('StoreCard_id',mSCBO.OID);
               msmbo.SetFieldValueAsString('PriceList_ID','1000000101');
               mStorePrices:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
                 mStorePrice:=mStorePrices.AddNewObject;
                 mStorePrice.SetFieldValueAsString('Price_ID','1000000101');
                 mStorePrice.SetFieldValueAsString('Qunit', mSelectedUnit);
                 mStorePrice.SetFieldValueAsFloat('UnitRate',mUnitRate);
                    mPrice:=((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))*mPrice)/100;
                    mprice:= mPrice*(100/((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))));

                 mStorePrice.SetFieldValueAsFloat('Amount',mPrice);

               msmbo.save;
               mSMBO.Free;
              end else begin
                 //NxShowSimpleMessage('našel jsem',mSite);
                 mSMBO:=mscbo.ObjectSpace.CreateObject(Class_StorePrice);
                 mSMBO.Load(mStorePrice_ID,nil);
                 mStorePrices:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
                  for i:=0 to mStorePrices.count-1 do begin
                    mStorePrice:=mStorePrices.BusinessObject[i];
                    //NxShowSimpleMessage(mStorePrice.GetFieldValueAsString('Qunit')+'  '+mSelectedUnit,msite);
                    if (mStorePrice.GetFieldValueAsString('Qunit')=mSelectedUnit) and (mStorePrice.GetFieldValueAsString('Price_ID')='1000000101') then begin
                      //mPrice:=((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))*mPrice)/100;
                      mprice:= mPrice*(100/((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))));
                      mStorePrice.SetFieldValueAsFloat('Amount',mPrice);
                    end;
                   end;
                 msmbo.save;
                 mSMBO.Free;
              end;
           end;
    end;
 end;
end;

Function GetDataForPrice(var ASite : TSiteform; var aResult:integer; var aQuantity:Extended;var aUnits:TStringList; var aSelectedUnit:string):Boolean;
var
    mLabel: TLabel;
    mEd1:TNumEdit;
    mCBunit:TComboBox;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
 begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 210;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro cenu:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Jednotka:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCBunit:= TComboBox.Create(mForm);
    mCBunit.Parent:=mForm;
    mCBunit.Left := 100;
    mCBunit.Top := (mCount*25)+10;
    mCBunit.Width := 50;
    mCBunit.Text := '';
    mCBunit.Items:=aUnits;
    mCBunit.ItemIndex:=0;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Cena s DPH:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 80;
    mLabel.Font.Size := 10;

    mEd1 := TNumEdit.Create(mForm);
    mEd1.Left := 100;
    mEd1.Top := (mCount*25)+10;
    mEd1.Width := 80;
    mEd1.Value := aQuantity;
    mEd1.Parent := mForm;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 52;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 120;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aResult:=1;
         aQuantity:=mEd1.Value;
         Result:=True;
         aSelectedUnit:=mCBunit.Text;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.