uses 'eu.abra.IssueOrderFromSubcards.fcesql', 'eu.abra.IssueOrderFromSubcards.createzamestnanec';

procedure CreateTheft(Sender: TObject);
var
 mSite:TsiteForm;
 mParams, mTemplates: TNxParameters;
 mPopis, mEan, mStoreCard_ID, mDivision_ID,mBusProject_ID, mStore_ID, mDisplayName: String;
 mQuantity:Extended;
 mDialog:Boolean;
 mUser, mStoreCard, mBillOfDelivery, mBillOfDeliveryRow:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mSite := TComponent(Sender).BusRollSite;
  mBusProject_ID:='';
  mStore_ID:='';
  mStoreCard_ID:='';
  mDialog:=false;
  mEan:='';
  mQuantity:=1;
  mPopis:='';
  mOs:=msite.CompanyObjectSpace;
  muser:= mOS.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID(mOS), nil);
    mDivision_ID:=mUser.GetFieldValueAsString('X_Division_ID');
  TheftData(msite, mStore_ID, mStoreCard_ID,mEan, mDialog, mQuantity, mPopis, mUser);


    //muser.Free;

    if not(mDialog) then begin
       NxShowMessage('Info','Ruším založení krádeže', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mStoreCard_ID) and not(mEAN='') then begin
      mStoreCard_ID:=scrGetStoreCard_ID(mOS, mEAN);

    end;
  mStoreCard:= mOS.CreateObject(Class_StoreCard);
    mStoreCard.Load(mStoreCard_ID,nil);
    if NxMessageBox('Dotaz', 'Chcete přidat '+mStoreCard.GetFieldValueAsString('Name')+' v počtu '+FloatToStr(mQuantity)+' do DLV Krádež?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin


            mBillOfDelivery:=mOS.CreateObject(Class_BillOfDelivery);
            mBillOfDelivery.New;
            mBillOfDelivery.Prefill;
            mBillOfDelivery.SetFieldValueAsString('Docqueue_ID','2B00000101');
            mBillOfDelivery.SetFieldValueAsString('Description',mPopis);
            mBillOfDelivery.SetFieldValueAsString('U_Odpis','17Y0000101');
            mrows:=mBillOfDelivery.GetCollectionMonikerForFieldCode(mBillOfDelivery.GetFieldCode('Rows'));
            mBillOfDeliveryRow:=mrows.AddNewObject;
            mBillOfDeliveryRow.SetFieldValueAsInteger('RowType',3);
            mBillOfDeliveryRow.SetFieldValueAsString('Store_ID',mStore_ID);
            mBillOfDeliveryRow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mBillOfDeliveryRow.SetFieldValueAsString('Division_ID',mDivision_ID);
            mBillOfDeliveryRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mBillOfDeliveryRow.SetFieldValueAsFloat('Quantity',mQuantity);
            mBillOfDelivery.save;
            mDisplayName:=mBillOfDelivery.DisplayName;
            mBillOfDelivery.Free;

        NxShowSimpleMessage('Založil jsem dodací list '+mDisplayName,mSite);
    end;

end;

Function TheftData(asite:tsiteform;var aStore_id:string; var aStoreCard_ID:string;
                        var aEAN: string; var aDialog:Boolean; var aQuantity:Extended; var aDescription:String; var aUser:TNxCustomBusinessObject):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmRepair, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9 : TEdit;
    mEd6, mEd7: TMemo;
    mNumEdit, mNumEdit1: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mP1:TPanel;
begin

    mForm:= TForm.Create(aSite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Parent:=nil;
    mForm.Width:= 520;
    mForm.Height:= 220;
    mForm.Caption := 'Zadejte údaje o krádeži';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcPerson:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 35;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbPerson.Top:= 15;
    mCbPerson.DataText:= aStore_id;
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Skl. karta:';
    mLabel3.Top := 42;
    mLabel3.Left := 17;
    mLabel3.Height := 13;


    mCbCcStoreCard:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStoreCard.Parent:= mForm;
    //mCbCcStoreCard.BevelOuter:= bvLowered;
    mCbCcStoreCard.Left:= 228;
    mCbCcStoreCard.Top:= 40;
    mCbCcStoreCard.Width:= 255;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;

    mCbStoreCard.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard.Complete:= True;
    mCbStoreCard.ForcedField:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard.Top:= 40;
    mCbStoreCard.DataText:= aStoreCard_ID;
    mCbStoreCard.Left:= 107;
    mCbStoreCard.Width:= 108;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'EAN:';
    mLabel3.Top := 67;
    mLabel3.Left := 17;
    mLabel3.Height := 13;



    mEd8 := TEdit.Create(mForm);
    mEd8.Left := 107;
    mEd8.Top := 65;
    mEd8.Width := 380;
    mEd8.Text := '';
    mEd8.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Množství:';
    mLabel3.Top := 92;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mNumEdit:= TNumEdit.Create(mForm);
    mNumEdit.Parent :=mForm;
    mNumEdit.ParentFont:=false;
    mNumEdit.left := 107;
    mNumEdit.top := 90;
    mNumEdit.Value := aQuantity;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Popis:';
    mLabel3.Top := 117;
    mLabel3.Left := 17;
    mLabel3.Height := 13;


    mEd1:= TEdit.Create(mForm);
    mEd1.Parent :=mForm;
    mEd1.left := 107;
    mEd1.top := 115;
    mEd1.Width := 380;
    mEd1.Text := aDescription;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 149;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 149;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aStore_id:= mCbPerson.DataText;
        if not(NxIsEmptyOID(mCbStoreCard.DataText)) then aStoreCard_ID:= mCbStoreCard.DataText;
        aEAN:=mEd8.Text;
        aQuantity:= mNumEdit.Value;
        aDescription:=med1.Text;
        adialog:=true;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;




begin
end.