uses 'eu.obb.eshopfunc.changerows', 'eu.obb.eshopfunc.lib', 'eu.obb.eshopfunc.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
  i : integer;
  mUser:TNxCustomBusinessObject;
begin
  mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import DEUS';
  mAction.Hint := 'Naimportuje data z Deus Tectum';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ImportDEUS;
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'DL DEUS';
  mAction.Hint := 'Vytvoří dodací list Deus';
  mAction.Category := 'tabList';
  mAction.OnExecute := @DL_DEUS;

  {mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dobropis DEUS';
  mAction.Hint := 'Vytvoří dobropis Deus';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Dobropis_DEUS;  }

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'DEUS tisk protokolVR';
  mAction.Hint := 'DEUS tisk protokol VR';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ProtokolVR_DEUS;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'DL DEUS tisk';
  mAction.Hint := 'DEUS tisk dodacího listu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @TiskDL;

    {mMAction := Self.GetNewMultiAction;
    mMAction.ShowControl := True;
    mMAction.ShowMenuItem := True;
    mMAction.Caption := 'VR Deus';
    mMAction.Items.Add('Nic');
    mMAction.Items.Add('VR Deus');
    mMAction.Items.Add('VR Deus Palety');
    mMAction.Items.Add('VR Deus Edit');
    mMAction.Hint := 'Multiakce2';
    mMAction.Category := 'tabList';
    mMAction.OnExecuteItem := @MultiAkce2;   }

    {mMAction := Self.GetNewMultiAction;
    mMAction.ShowControl := True;
    mMAction.ShowMenuItem := True;
    mMAction.Caption := 'Dobropis DEUS';
    mMAction.Items.Add('Nic');
    mMAction.Items.Add('DV Deus');
    mMAction.Items.Add('DV Deus Palety');
    mMAction.Items.Add('DV Deus Edit');
    mMAction.Hint := 'Multiakce3';
    mMAction.Category := 'tabList';
    mMAction.OnExecuteItem := @MultiAkce3;  }


  if mUser.GetFieldValueAsBoolean('U_Deus') then begin
    mMAction := Self.GetNewMultiAction;
    mMAction.ShowControl := True;
    mMAction.ShowMenuItem := True;
    mMAction.Caption := 'Koordinátor';
    mMAction.Items.Add('Nic');
    mMAction.Items.Add('Fakturace Deus');
    mMAction.Items.Add('Připraveno Deus');
    mMAction.Items.Add('Tisk Deus seznam OP bez FV');
    mMAction.Items.Add('Filtr Deus');
    mMAction.Items.Add('Editace polí');
    mMAction.Items.Add('Dobropis DEUS');
    mMAction.Items.Add('Převodka příjem k dobropisu DEUS');
    mMAction.Hint := 'Multiakce';
    mMAction.Category := 'tabList';
    mMAction.OnExecuteItem := @MultiAkce;


    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Změnit Deus';
    //mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
    mAction.Hint := 'Změní DEUS Data na řádku';
    mAction.Category := 'tabDetail';
    mAction.OnExecute := @ChangeDEUS;

    {mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Fakturace Deus';
    //mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
    mAction.Hint := 'Vyfakturuje';
    mAction.Category := 'tabList';
    mAction.OnExecute := @FakturaceDeus;  }

  end;

end;
procedure MultiAkce(sender:Tcomponent; index:integer);
begin
  if index=0 then exit;
  if index=1 then FakturaceDeus(sender);
  if index=2 then SendInfo(sender);
  if index=3 then TiskDeus(sender);
  if index=4 then UkazDeus(sender);
  if index=5 then EditFields(sender);
  if index=6 then Dobropis_DEUS(sender);
  if index=7 then ShowIT(sender);
end;

procedure MultiAkce2(sender:Tcomponent; index:integer);
begin
  if index=0 then exit;
  if index=1 then VR_DEUS(sender);
  if index=2 then VR_DEUSPalety(sender);
  if index=3 then VR_DEUSEdit(sender);
end;

procedure MultiAkce3(sender:Tcomponent; index:integer);
begin
  if index=0 then exit;
  if index=1 then DV_DEUS(sender);
  if index=2 then DV_DEUSPalety(sender);
  if index=3 then DV_DEUSEdit(sender);
end;

Procedure ShowIT(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 mPrintList,mQueryList:TStringList;
 mOLE:TNxCustomObjectSpace;
 mContext:TNxContext;
 mExternalNumber, mDLNumber, mOrder_ID:string;
 mResult:integer;
begin
  mSite:=TComponent(Sender).DynSite;
  mSite.ShowSite('BH0I5SAOS3DL3ACU03KIU0CLP4', False, 'QueryByUserDynSQLCondition;A.X_DocumentID = '+QuotedStr(TDynSiteForm(msite).CurrentObject.OID));
end;

Procedure TiskDL(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 mPrintList,mQueryList:TStringList;
 mOLE:TNxCustomObjectSpace;
 mContext:TNxContext;
 mExternalNumber, mDLNumber, mOrder_ID:string;
 mResult:integer;
begin
  mSite:=TComponent(Sender).DynSite;
  mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
  mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
  mOle:= mContext.GetObjectSpace;
  mExternalNumber:='';
  mDLNumber:='';
  mOrder_ID:='';
  GetSearchData(msite, mExternalNumber,mDLNumber,mResult);
  if mResult=1 then begin
      if not(NxIsBlank(mExternalNumber)) then begin
        mOrder_ID:=GetOrder_ID(mOLE,mExternalNumber);
      end;
      if NxIsEmptyOID(mOrder_ID) and not(NxIsBlank(mDLNumber)) then begin
        mOrder_ID:=GetOrderFromDL_ID(mOLE,mDLNumber);
      end;
      if NxIsEmptyOID(mOrder_ID) then begin
        NxShowSimpleMessage('Žádný doklad nenalezen. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz',mSite);
        exit;
      end;
      if not(NxIsEmptyOID(mOrder_ID)) then begin
      mBO:=mOLE.CreateObject(Class_ReceivedOrder);
      mBO.Load(mOrder_ID,nil);

      if Assigned(mBO) then begin
              mPrintList:=TStringList.Create;
              mQueryList:=TStringList.create;
              mbo.ObjectSpace.SQLSelect('SELECT sd.id FROM StoreDocuments2 sd2 left join storedocuments sd on sd.id=sd2.parent_id WHERE sd.documenttype=''21'' and sd2.Provide_ID = '+QuotedStr(MBO.OID),mQueryList);
              if mQueryList.count>0 then begin
               mPrintList.Add(mQueryList.strings[0]);
              end;
              if mQueryList.count=0 then begin
                NxShowSimpleMessage('Dodací list neexistuje',mSite);
                exit;
              end;
              if NxMessageBox('Dotaz',' Dodací list objednávce DEUS '+mbo.GetFieldValueAsString('ExternalNumber')+' byl nalezen. Chcete jej nyní vytisknout ?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin

               CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoPreview,pekPDF,'','');

              end;
           exit;
       end;
      end;
   end;
end;

Procedure Dobropis_DEUS(sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mVRchoice, mVRPalety, mVRComplete:boolean;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
   if NxMessageBox('Dotaz',' Skutečně si přejete vrátit zboží z eshopu , objednávka  '+mBO.DisplayName+'? V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       mList:=TStringList.Create;
       mbo.ObjectSpace.SQLSelect(format('Select ii2.parent_id from storedocuments2 sd2 left join issuedinvoices2 ii2 on ii2.provide_id=sd2.parent_id where sd2.FlowType=''21'' and sd2.provide_id=''%s'' group by ii2.parent_id ',[mbo.oid]),mlist);
       //NxShowSimpleMessage(mlist.DelimitedText,mSite);
       if mlist.Count=0 then begin
         NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádnou fakturu.',mSite);
         exit;
       end;
       if NxIsEmptyOID(mlist.strings[0]) then begin
          NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádnou fakturu.',mSite);
          exit;
       end;
       mVRchoice:=Mbo.GetFieldValueAsBoolean('U_VRChoice');
       mVRPalety:=Mbo.GetFieldValueAsBoolean('U_VRPalety');
       mVRComplete:=Mbo.GetFieldValueAsBoolean('U_VR_complete');

       if (strtoint(BoolToStr(mVRchoice))+strtoint(BoolToStr(mVRPalety))+strtoint(BoolToStr(mVRComplete)))=-1 then begin
         if mVRchoice then DV_DEUSEdit(sender);
         if mVRPalety then DV_DEUSPalety(sender);
         if mVRComplete then DV_DEUS(sender);
       end else begin
         NxShowSimpleMessage('Dobropis je povolen, ale je zatrženo více voleb a požadavek nelze zpracovat. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz ',msite);
         exit;
       end;
   end;
 end;
end;


Procedure EditFields(sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
 mVRchoice, mVRPalety, mVRComplete, mPaid, mEshopDelivery,mCashOnDelivery:boolean;
 mPin, mNote:string;
 mResult:integer;
 mDate:Extended;
begin
  mResult:=0;
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
    if NxMessageBox('Dotaz',' Přejete si editovat hodnoty na  '+mBO.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       mPin:=mbo.GetFieldValueAsString('X_PinToPickup');
       mVRchoice:=Mbo.GetFieldValueAsBoolean('U_VRChoice');
       mVRPalety:=Mbo.GetFieldValueAsBoolean('U_VRPalety');
       mVRComplete:=Mbo.GetFieldValueAsBoolean('U_VR_complete');
       mPaid:=mbo.GetFieldValueAsBoolean('X_Paid');
       mEshopDelivery:=mBO.GetFieldValueAsBoolean('U_Eshop_Delivery');
       mCashOnDelivery:=mbo.GetFieldValueAsBoolean('U_CashOnDelivery');
       mDate:=mbo.GetFieldValueAsDateTime('U_CollectionDate');
       mNote:=mBO.GetFieldValueAsString('U_DeusDBnote');
       GetDataEdit(msite, mPin,mVRchoice,mVRPalety,mVRComplete,mPaid, mEshopDelivery, mCashOnDelivery,mDate, mNote,mResult);
       if mResult=1 then begin
         mBO.SetFieldValueAsString('X_PinToPickup',mPin);
         mBO.SetFieldValueAsString('U_DeusDBnote',mNote);
         mBO.SetFieldValueAsBoolean('U_VRChoice',mVRchoice);
         mBO.SetFieldValueAsBoolean('U_VRPalety',mVRPalety);
         mBO.SetFieldValueAsBoolean('U_VR_complete',mVRComplete);
         mBO.SetFieldValueAsBoolean('X_Paid',mPaid);
         mBO.SetFieldValueAsBoolean('U_Eshop_Delivery',mEshopDelivery);
         mBO.SetFieldValueAsDateTime('U_CollectionDate',mDate);
         mBO.SetFieldValueAsBoolean('U_CashOnDelivery',mCashOnDelivery);
         mbo.save;
         TDynSiteForm(mSite).RefreshData;
         TDynSiteForm(msite).ActiveDataSet.SeekID(mbo.OID);
       end;
    end;
  end;
end;

Function GetDataEdit(var aSite:TSiteForm; var aString:string;var aVRchoice, aVRPalety,aVRComplete, aPaid, aEshopDelivery, aCashOnDelivery:boolean;var aDate:extended;var aNote:string; var aResult:Integer):boolean;
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
    mForm.Height:= 310;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro editaci';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'PIN:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 150;
    med1.Width := 150;

    mBEd01:= TCheckBox.Create(mForm);
    mBEd01.Left := 17;
    mBEd01.Top := 35;
    mBEd01.Caption :='Vrátit s editací';
    mBEd01.Checked := aVRchoice;
    mBEd01.Parent := mForm;

    mBEd02:= TCheckBox.Create(mForm);
    mBEd02.Left := 17;
    mBEd02.Top := 60;
    mBEd02.Caption :='Vrátit palety';
    mBEd02.Checked := aVRPalety;
    mBEd02.Parent := mForm;

    mBEd03:= TCheckBox.Create(mForm);
    mBEd03.Left := 17;
    mBEd03.Top := 85;
    mBEd03.Caption :='Vrátit kompletně';
    mBEd03.Checked := aVRComplete;
    mBEd03.Parent := mForm;

    mBEd04:= TCheckBox.Create(mForm);
    mBEd04.Left := 17;
    mBEd04.Top := 110;
    mBEd04.Caption :='Zaplaceno';
    mBEd04.Checked := aPaid;
    mBEd04.Parent := mForm;

    mBEd06:= TCheckBox.Create(mForm);
    mBEd06.Left := 17;
    mBEd06.Top := 135;
    mBEd06.Caption :='Dobírka';
    mBEd06.Checked := aCashOnDelivery;
    mBEd06.Parent := mForm;

    mBEd05:= TCheckBox.Create(mForm);
    mBEd05.Left := 17;
    mBEd05.Top := 160;
    mBEd05.Caption :='Eshop - Rozvoz';
    mBEd05.Checked := aEshopDelivery;
    mBEd05.Parent := mForm;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Datum nakládky';
    mLabel1.Top := 187;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mDed1 := TDateEdit.Create(mForm);
    mDed1.parent :=mForm;
    mDed1.top := 185;
    mDed1.left := 150;
    mDed1.Width := 150;
    mded1.date := aDate;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Pozn. k povoleným VR';
    mLabel1.Top := 212;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.parent :=mForm;
    mEd2.top := 210;
    mEd2.left := 150;
    mEd2.Width := 300;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 250;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 250;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    aResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if aResult = 1 then
        aString:=mEd1.Text;
        aVRchoice:=mBEd01.Checked;
        aVRPalety:=mBEd02.Checked;
        aVRComplete:=mBEd03.Checked;
        aPaid:=mbed04.checked;
        aEshopDelivery:=mbed05.checked;
        aCashOnDelivery:=mBed06.checked;
        aDate:=mDEd1.Date;
        aNote:=mEd2.Text;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

end;


Procedure TiskDeus(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
    mList:=TStringList.Create;
    //mList.Add(mBO.OID);
    msite.BaseObjectSpace.SQLSelect('Select id from receivedorders where firm_id=''#000001001'' ',mlist);
    CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mList,GetDynSource(mbo.ObjectSpace,'#000000M01'),'#000000M01',rtoPreview,pekPDF,'','');

  end;
end;

Procedure ProtokolVR_DEUS(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 mPrintList,mQueryList:TStringList;
 mOLE:TNxCustomObjectSpace;
 mContext:TNxContext;
 mExternalNumber, mDLNumber, mOrder_ID:string;
 mResult:integer;
 mList:TStringList;
begin
  mSite:=TComponent(Sender).DynSite;
  mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
  mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
  mOle:= mContext.GetObjectSpace;
  mExternalNumber:='';
  mDLNumber:='';
  mOrder_ID:='';
  GetSearchData2(msite, mExternalNumber,mDLNumber,mResult);
  if mResult=1 then begin
      if not(NxIsBlank(mExternalNumber)) then begin
        mOrder_ID:=GetOrderPIN_ID(mOLE,mExternalNumber);
      end;
      if NxIsEmptyOID(mOrder_ID) and not(NxIsBlank(mDLNumber)) then begin
        mOrder_ID:=GetOrderFromDL_ID(mOLE,mDLNumber);
      end;
      if NxIsEmptyOID(mOrder_ID) then begin
        NxShowSimpleMessage('Žádný doklad nenalezen. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mSite);
        exit;
      end;
      if not(NxIsEmptyOID(mOrder_ID)) then begin
      mBO:=mOLE.CreateObject(Class_ReceivedOrder);
      mBO.Load(mOrder_ID,nil);
       if assigned(mBO) then begin
          if not(mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='09698507') then begin
            NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' není pro firmu DEUS',mSite);
            exit;
          end;
          if NxIsBlank(mbo.GetFieldValueAsString('X_PinVR')) then begin
            NxShowSimpleMessage('Není vyplněno číslo povolení vratky Deus.V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz ',mSite);
            exit;
          end;
          mList:=TStringList.create;
          mList.Add(mbo.OID);
          CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mList,GetDynSource(mbo.ObjectSpace,'#000000P04'),'#000000P04',rtoPreview,pekPDF,'','');
       end;
     end;
   end;
end;

Procedure UkazDeus(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).DynSite;
 mSite.ShowSite('O2XDU14IW3DL342X01C0CX3FCC', False, 'QueryByUserDynSQLCondition;A.Firm_ID=''#000001001'' ');
end;

Procedure FakturaceDeus(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mPrintList, mIIList, mQueryList:TStringList;
 mBOD_ID, mOrder_ID, mIIDocQueue_ID,mCode, mFileName1:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows, mFVRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mDateString:string;
begin
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  mDateString:='';
  if mbo.GetFieldValueAsDateTime('U_CollectionDate')>0 then
  mDateString:=' Datum plánovaného odvozu přepravní službou  '+DateTimeToStr(mbo.GetFieldValueAsDateTime('U_CollectionDate'));
 if NxMessageBox('Dotaz','Přejete si vystavit fakturu pro DEUS objednávku '+mbo.GetFieldValueAsString('ExternalNumber')+' ?'+mDateString+' V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
  if Assigned(mBO) then begin
  mQueryList:=TStringList.Create;
  mbo.ObjectSpace.SQLSelect('SELECT sd.id FROM StoreDocuments2 sd2 left join storedocuments sd on sd.id=sd2.parent_id WHERE sd.documenttype=''21'' and sd2.Provide_ID = '+QuotedStr(MBO.OID),mQueryList);
  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
  //kontrola skladové dostupnosti
     for i:=0 to mRows.count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
         if NxIsBlank(mCode) then mCode:=mRowBO.GetFieldValueAsString('Store_ID.Code');
       end;
     end;
  mIIDocQueue_ID:=GetIIDQ_ID(mbo.ObjectSpace,'FV'+mCode);
       if NxIsEmptyOID(mIIDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu faktur s kódem FV'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
  if mQueryList.count=0 then begin
    NxShowSimpleMessage('K objednávce není vystaven dodací list. Toto tlačítko slouží k fakturaci zakázek s rozvozem , na které byl prodejnou vystaven DL',msite);

   exit;
  end;
  if mQueryList.count>0 then mBOD_ID:=mQueryList.strings[0];
  //NxShowSimpleMessage(mBOD_ID,nil);
  mbo.ObjectSpace.SQLSelect('SELECT Parent_ID FROM IssuedInvoices2 WHERE Provide_ID = '+QuotedStr(mBOD_ID)+' AND Provide_ID IS NOT NULL',mQueryList);
  if mQueryList.count>0 then begin
    NxShowSimpleMessage('Faktura k objednávce je již vystavena, ukončuji akci',msite);
    exit;
  end;
  // tisk dodacího listu
           mPrintList:=TStringList.Create;
           if not(NxIsEmptyOID(mBOD_ID)) then mPrintList.Add(mbod_ID);
           if mPrintList.count>0 then begin
              mIIList:=TStringList.create;

              mbo.ObjectSpace.SQLSelect('SELECT Provide_ID FROM StoreDocuments2 WHERE Parent_ID = '+QuotedStr(mBOD_ID)+' AND Provide_ID IS NOT NULL',mQueryList);
              if mQueryList.count>0 then mOrder_ID:=mQueryList.strings[0];
              mInputParams := TNxParameters.Create;
              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := mIIDocQueue_ID;
              if not(NxIsEmptyOID(mOrder_ID)) then begin
               mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
               mParam.AsString := mOrder_ID;
              end else begin
               mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
               mParam.AsString := mBOD_ID;
              end;
              mImportMan:=NxCreateDocumentImportManager(mBO.ObjectSpace,Class_BillOfDelivery,Class_IssuedInvoice);
              mImportMan.AddInputDocument(mBOD_ID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mIIDocQueue_ID);
              mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
              //mImportMan.OutputDocument.SetFieldValueAsFloat('DocumentDiscount',3); //sleva 3 procenta
              mImportMan.OutputDocument.SetFieldValueAsBoolean('IsRowDiscount',True);
              mFVRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
              for j:=0 to mFVRows.count-1 do begin
                if mFVRows.BusinessObject[j].GetFieldValueAsInteger('RowType')=3 then begin
                 if (mFVRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='6000000101') and not(mFVRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.StoreMenuItem_ID')='2110000101') then mFVRows.BusinessObject[j].SetFieldValueAsFloat('RowDiscount',6);
                end;
              end;
              mImportMan.OutputDocument.save;
              mFileName:='DodList.PDF';
              mFileName1:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
              mIIList.Add(mImportMan.OutputDocument.OID);
               CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mIIList,'40SBPEINEFD13ACM03KIU0CLP4','1H30000101',rtoFile,pekPDF,NxGetTempDir,mFileName1);


              mQueryList.free;
              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoFile,pekPDF,NxGetTempDir,mFileName);
              //send internal mail
              SendInternalMail(mbo.ObjectSpace,'deus@obb.cz','info@nadum.cz','',
                          'Vystavený dodací list a faktura  pro objednávku z eshopu Deus: '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                          NxGetTempDir+'\'+mFileName,NxGetTempDir+'\'+mFileName1,'AAA1000000','#000000101','#000000201');
              DeleteFile(NxGetTempDir+'\'+mFileName1);
              DeleteFile(NxGetTempDir+'\'+mFileName);
              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mIIList,'40SBPEINEFD13ACM03KIU0CLP4','1H30000101',rtoPreview,pekPDF,'','');
              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoPreview,pekPDF,'','');
           end;
           mPrintList.free;
           mIIList.free;
          //tisk dodacího listu
   end;
  end;
end;

Procedure SendInfo(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
begin
  mSite:=TComponent(Sender).DynSite;
  NxShowSimpleMessage('Nic tu není',msite);
end;

{
Vyvolává se před tiskem/exportem. Pomocí tohoto háčku je možné ovlivnit parametry, které obdrží samotná funkce tisk/export.
}
procedure BeforePrint_Hook(Self: TSiteForm; APrintID: string; AParams: TNxParameters);
begin

end;

Procedure DL_DEUS(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mRecipient:string;
 i,j,k,l, mResult:integer;
 mAvailableQuantity:Extended;
 mDvojky, mNeniSkladem, mBusTransactionChecked:boolean;
 mPIN, mPrijemce:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mList, mPrintList, mIIList, mQueryList:TStringList;
 mBOD_ID, mBODDocQueue_ID, mCode, mFileName, mIIDocQueue_ID, mOrder_ID, mFileName1:string;
 mOTDocQueue_ID, mOT_ID:string;
 mRidic, mSpolecnost:string;
 mFVRows:TNxCustomBusinessMonikerCollection;
 mBODName, mDateString:string;
 mOTBO, mOTRowBO, mROBO, mRORowsBO, mUserXLink:TNxCustomBusinessObject;
 mOTRows, mRORows, mITRows:TNxCustomBusinessMonikerCollection;
 mContext: TNxContext;
 mOLE, mOLE2: TNxCustomObjectSpace;
 mSourceStore, mIT_ID, mOTNumber, mITNumber:string;
begin
  mSite:=TComponent(Sender).DynSite;
  mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
  mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
  mOle:= mContext.GetObjectSpace;
  mBO:=mOLE.CreateObject(Class_ReceivedOrder);
  mBO.Load(TDynSiteForm(mSite).CurrentObject.OID,nil);
  mDvojky:=False;
  mNeniSkladem:=False;
  mBusTransactionChecked:=False;
  mResult:=0;
  mCode:='';
  if Assigned(mBO) then begin
     //kontrola platby
     if not(mbo.GetFieldValueAsBoolean('IsAvailableForDelivery')) then begin
       //NxShowSimpleMessage('Objednávka '+mBO.DisplayName+' není čerpatelná. Doklady nelze vystavit.', mSite);
       if NxMessageBox('Dotaz',' Dodací list k objednávce DEUS '+mbo.GetFieldValueAsString('ExternalNumber')+' již existuje. Chcete jej znovu vytisknout ?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
          mPrintList:=TStringList.Create;
          mQueryList:=TStringList.create;
          mbo.ObjectSpace.SQLSelect('SELECT sd.id FROM StoreDocuments2 sd2 left join storedocuments sd on sd.id=sd2.parent_id WHERE sd.documenttype=''21'' and sd2.Provide_ID = '+QuotedStr(MBO.OID),mQueryList);
          if mQueryList.count>0 then begin
           mPrintList.Add(mQueryList.strings[0]);
           CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoPreview,pekPDF,'','');
          end;
       end;
       exit;
     end;
     if not(mBO.GetFieldValueAsBoolean('X_Paid') or mbo.GetFieldValueAsBoolean('U_CashOndelivery')) then begin
       NxShowSimpleMessage('Objednávka '+mBO.DisplayName+' není označená jako uhrazená. Doklady nelze vystavit. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mSite);
       exit;
     end;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
     mList:=TStringList.create;
     for i:=0 to mRows.count-1 do begin
       if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=2 then mDvojky:=True;
     end;
     if mDvojky then begin
       NxShowSimpleMessage('Objednávka '+mBO.DisplayName+' obsahuje neskladové řádky, doklady nelze vystavit. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mSite);
       exit;
     end;
     //Kontrola obchodního případu 9700-9799
      for i:=0 to mRows.count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if not(mBusTransactionChecked) and not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusTransaction_ID'))) then begin
           if not((AnsiLeftStr(mRowBO.GetFieldValueAsString('BusTransaction_ID.Code'),2)='97') and (Length(mRowBO.GetFieldValueAsString('BusTransaction_ID.Code'))=4))
               then mBusTransactionChecked:=True;
        end;
      end;
      if mBusTransactionChecked then begin
       NxShowSimpleMessage('Objednávka '+mBO.DisplayName+' nemá obchodní případ v rozsahu 9700-9799 .V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mSite);
       exit;
     end;
     //konec kontroly obchodního případu
     //kontrola skladové dostupnosti
     for i:=0 to mRows.count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
         mList.Add(mRowBO.OID);
         if (mRowBO.GetFieldValueAsInteger('StoreCard_ID.OutOfStockDelivery')=0)  then begin
          mAvailableQuantity:=GetAvailableQuantity(mBO.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
          if mAvailableQuantity<mRowBO.GetFieldValueAsFloat('Quantity') then mNeniSkladem:=True;
         end;
         if NxIsBlank(mCode) then begin
           mCode:=mRowBO.GetFieldValueAsString('Store_ID.Code');
           mSourceStore:=mRowBO.GetFieldValueAsString('Store_ID');
         end;
       end;
     end;
     if mNeniSkladem then begin
       NxShowSimpleMessage('Objednávka '+mBO.DisplayName+' některé zboží není skladem, nebo prodej blokuje jiná rezervace, doklady nelze vystavit.V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mSite);
       exit;
     end;
     //konec kontroly skladové dostupnosti
     if not(mbo.GetFieldValueAsBoolean('U_Eshop_delivery')) then  GetData(msite, mPin, mPrijemce, mResult);

     if mResult=1 then begin
       if not(mPIN=mbo.GetFieldValueAsString('X_PinToPickup')) and not(mbo.GetFieldValueAsBoolean('U_Eshop_delivery')) then begin
         NxShowSimpleMessage('Zadaný PIN se neshoduje. Doklady nelze vystavit.V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mSite);
         exit;
       end;
       if (NxIsBlank(mRidic) or NxIsBlank(mSpolecnost)) and (mbo.GetFieldValueAsBoolean('U_Eshop_delivery')) then begin
         NxShowSimpleMessage('Není vyplněn řidič nebo přepravní společnost, doklady nelze vystavit.V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz',msite);
         exit;
       end;
       //tvorba převodu ze zdrojového skladu na 97 + změna skladu na OP97
       mOTDocQueue_ID:=GetOTDQ_ID(mbo.ObjectSpace,'SV'+mCode);
       if NxIsEmptyOID(mOTDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu převodek výdej s kódem SV'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
        //řešení rezervací
       try

        mInputParams := TNxParameters.Create;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := mOTDocQueue_ID;         //#### řada SP97 upraveno
        //mParam :=  mInputParams.NewFromDataType(dtBoolean, 'OutgoingTransferWithoutProvideReceivedOrder');
        //mParam.AsBoolean := True;
        //mParam :=  mInputParams.GetPrCreateParam(dtInteger, '');
        mImportMan := NxCreateDocumentImportManager(mOLE, Class_ReceivedOrder, Class_OutgoingTransfer);
        mImportMan.AddInputDocument(mbo.OID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mOTDocQueue_ID);  //#### řada SP97 upraveno
        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID','1IA0000101');
        mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
        mImportMan.OutputDocument.SetFieldValueAsString('Description', mbo.DisplayName+' '+mbo.GetFieldValueAsString('Externalnumber'));
        mOTRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:=0 to mOTRows.count-1 do begin
         if mOTrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='U300000101' then mOTRows.BusinessObject[i].MarkForDelete;
        end;
        mImportMan.OutputDocument.save;
        mOT_ID:=mImportMan.OutputDocument.OID;
        mOTNumber:=mImportMan.outputdocument.DisplayName;
        //mContext.free;
        mOTBO:=mbo.ObjectSpace.CreateObject(Class_OutgoingTransfer);
        mOTBO.load(mOT_ID,nil);
        mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
        for i:=0 to mOTRows.count-1 do begin
          mOLE.SQLExecute(format('Update storedocuments2 set provide_id=''0000000000'' where id=''%s'' ',[mOTRows.BusinessObject[i].OID]));
          mOLE.SQLExecute(format('Update storedocuments2 set provideRow_id=''0000000000'' where id=''%s'' ',[mOTRows.BusinessObject[i].OID]));
          mOLE.SQLExecute(format('Update storedocuments2 set reservedquantity=0 where id=''%s'' ',[mOTRows.BusinessObject[i].OID]));
        end;
        //mOTBO.save;
        for i:=0 to mRows.count-1 do begin
          mOLE.SQLExecute(format('Update receivedOrders2 set DeliveredQuantity=0 where id=''%s'' ',[mRows.BusinessObject[i].OID]));
          mOLE.SQLExecute(format('Update Reservations set Supplied=0 where Owner_id=''%s'' ',[mRows.BusinessObject[i].OID]));
        end;
        mOLE.SQLExecute(format('Update receivedOrders set Closed=''N'' where id=''%s'' ',[mbo.oid]));
      finally
       mbo.free;
       mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
       mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
       mOle:= mContext.GetObjectSpace;
       mBO:=mOLE.CreateObject(Class_ReceivedOrder);
       mBO.Load(TDynSiteForm(mSite).CurrentObject.OID,nil);
       mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      end;


       try

        mInputParams := TNxParameters.Create;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := '#00000080L';         //#### řada SP97 upraveno
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
        mParam.AsString := '#000000101';
        mImportMan := NxCreateDocumentImportManager(mOLE, Class_OutgoingTransfer, Class_IncomingTransfer);
        mImportMan.AddInputDocument(mOT_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','#00000080L');  //#### řada SP97 upraveno
        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID','1IA0000101');
        mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
        mImportMan.OutputDocument.SetFieldValueAsString('Description',mbo.DisplayName+' '+mbo.GetFieldValueAsString('Externalnumber'));
        mITRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:=0 to mITRows.count-1 do begin
          mITrows.BusinessObject[i].SetFieldValueAsString('Division_ID','#000000101');
        end;
        mImportMan.OutputDocument.save;
        mIT_ID:=mImportMan.OutputDocument.OID;
        mITNumber:=mImportMan.outputdocument.DisplayName;
        //mContext.free;
      finally


      end;
      for i:=0 to mrows.count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       mRowBO.SetFieldValueAsString('Store_ID','#000000101');
       mRowBO.SetFieldValueAsString('Division_ID','#000000101');
      end;
      mBO.SetFieldValueAsString('X_StockNumber',mCode);
      mBO.SetFieldValueAsString('X_SourceStore',mSourceStore);
      mBO.SetFieldValueAsString('X_OoutgoingTransferID',mOT_ID);
      mBO.SetFieldValueAsString('X_IncomingTransferID',mIT_ID);
      mBO.SetFieldValueAsString('X_OutgoingTransferNumber',mOTNumber);
      mBO.SetFieldValueAsString('X_IncomingTransferNumber',mITNumber);
      mbo.save;
      mUserXLink := mBO.ObjectSpace.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mOT_ID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IncomingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mIT_ID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;



                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := '#00000080K';  //#### řada DL97    upraveno
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                mParam.AsString := mList.Text;
                mImportMan := NxCreateDocumentImportManager(mOLE, Class_ReceivedOrder, Class_BillOfDelivery);
                try
                  mImportMan.AddInputDocument(mBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','#00000080K');  //#### řada DL97   upraveno
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_eshopDL',true);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Prevzal',mPrijemce);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Driver',mRidic);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Transport_company',mSpolecnost);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_ExtNumber',mBO.GetFieldValueAsString('ExternalNumber'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_Street',mBO.GetFieldValueAsString('U_Target_Street'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_City',mBO.GetFieldValueAsString('U_Target_City'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_Name',mBO.GetFieldValueAsString('U_Target_Name'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_PostCode',mBO.GetFieldValueAsString('U_Target_PostCode'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_Email',mBO.GetFieldValueAsString('U_Target_Email'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_PhoneNumber',mBO.GetFieldValueAsString('U_Target_PhoneNumber'));
                      mImportMan.OutputDocument.Save;
                      //mBod:=mImportMan.OutputDocument;
                      mBOD_ID:=mImportMan.OutputDocument.OID;
                      mFileName:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                  end;
                mImportMan.Free;
                mInputParams.Free;
                finally
                end;

          // tisk dodacího listu
           mPrintList:=TStringList.Create;
           if not(NxIsEmptyOID(mBOD_ID)) then mPrintList.Add(mbod_ID);
           if mPrintList.count>0 then begin
              mIIList:=TStringList.create;
              mQueryList:=TStringList.Create;
              mbo.ObjectSpace.SQLSelect('SELECT Provide_ID FROM StoreDocuments2 WHERE Parent_ID = '+QuotedStr(mBOD_ID)+' AND Provide_ID IS NOT NULL',mQueryList);
              if mQueryList.count>0 then mOrder_ID:=mQueryList.strings[0];
              mInputParams := TNxParameters.Create;
              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := '#00000080R';  //#### řada FV97 upraveno
              if not(NxIsEmptyOID(mOrder_ID)) then begin
               mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
               mParam.AsString := mOrder_ID;
              end else begin
               mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
               mParam.AsString := mBOD_ID;
              end;
              mImportMan:=NxCreateDocumentImportManager(mOLE,Class_BillOfDelivery,Class_IssuedInvoice);
              mImportMan.AddInputDocument(mBOD_ID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '#00000080R'); //#### řada FV97  upraveno
              mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
              mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
              //mImportMan.OutputDocument.SetFieldValueAsFloat('DocumentDiscount',3); //sleva 3 procenta
              mImportMan.OutputDocument.SetFieldValueAsBoolean('IsRowDiscount',True);
              mFVRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
              for j:=0 to mFVRows.count-1 do begin
                if mFVRows.BusinessObject[j].GetFieldValueAsInteger('RowType')=3 then begin
                 if (mFVRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='6000000101') and not(mFVRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.StoreMenuItem_ID')='2110000101') then mFVRows.BusinessObject[j].SetFieldValueAsFloat('RowDiscount',6);
                end;
              end;
              mImportMan.OutputDocument.save;
              mFileName1:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
              mIIList.Add(mImportMan.OutputDocument.OID);
               CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mIIList,'40SBPEINEFD13ACM03KIU0CLP4','1H30000101',rtoFile,pekPDF,NxGetTempDir,mFileName1);

              mIIList.free;
              mQueryList.free;
              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoFile,pekPDF,NxGetTempDir,mFileName);
              //send internal mail
              SendInternalMail(mbo.ObjectSpace,'deus@obb.cz','info@nadum.cz','',
                          'Vystavený dodací list a faktura pro objednávku z eshopu  '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                          NxGetTempDir+'\'+mFileName,NxGetTempDir+'\'+mFileName1,'AAA1000000','#000000101','#000000201');
              //CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mIIList,'40SBPEINEFD13ACM03KIU0CLP4','1H30000101',rtoPreview,pekPDF,'','');
              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoPreview,pekPDF,'','');

           end;
           mPrintList.free;
          //tisk dodacího listu
     end;
  end;
  if  mbo.GetFieldValueAsBoolean('U_Eshop_delivery') then begin
      mDateString:='';
      if mbo.GetFieldValueAsDateTime('U_CollectionDate')>0 then
       mDateString:=' Datum plánovaného odvozu přepravní službou  '+DateTimeToStr(mbo.GetFieldValueAsDateTime('U_CollectionDate'));
      if NxMessageBox('Dotaz','Opravdu si přejete vystavit dodací list k objednávce Deus '+mbo.GetFieldValueAsString('ExternalNumber')+' ?'+mDateString+ ' .Dodací list přiložte k zakázce. Fakturu bude vystavovat koordinátor eshopu po potvrzení doručení zboží. V případě dotazů kontaktuje koordinátora e-shopu 778 113 579 nebo deus@obb.cz', mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin

       //tvorba převodu ze zdrojového skladu na 97 + změna skladu na OP97
       mOTDocQueue_ID:=GetOTDQ_ID(mbo.ObjectSpace,'SV'+mCode);
       if NxIsEmptyOID(mOTDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu převodek výdej s kódem SV'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
        //řešení rezervací
       try

        mInputParams := TNxParameters.Create;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := mOTDocQueue_ID;         //#### řada SP97 upraveno
        //mParam :=  mInputParams.NewFromDataType(dtBoolean, 'OutgoingTransferWithoutProvideReceivedOrder');
        //mParam.AsBoolean := True;
        mImportMan := NxCreateDocumentImportManager(mOLE, Class_ReceivedOrder, Class_OutgoingTransfer);
        mImportMan.AddInputDocument(mbo.OID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mOTDocQueue_ID);  //#### řada SP97 upraveno
        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID','1IA0000101');
        mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
        mImportMan.OutputDocument.SetFieldValueAsString('Description', mbo.DisplayName+' '+mbo.GetFieldValueAsString('Externalnumber'));
        mOTRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:=0 to mOTRows.count-1 do begin
         if mOTrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='U300000101' then mOTRows.BusinessObject[i].MarkForDelete;
        end;
        mImportMan.OutputDocument.save;
        mOT_ID:=mImportMan.OutputDocument.OID;
        mOTNumber:=mImportMan.outputdocument.DisplayName;
        //mContext.free;
        mOTBO:=mbo.ObjectSpace.CreateObject(Class_OutgoingTransfer);
        mOTBO.load(mOT_ID,nil);
        mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
        for i:=0 to mOTRows.count-1 do begin
          mOLE.SQLExecute(format('Update storedocuments2 set provide_id=''0000000000'' where id=''%s'' ',[mOTRows.BusinessObject[i].OID]));
          mOLE.SQLExecute(format('Update storedocuments2 set provideRow_id=''0000000000'' where id=''%s'' ',[mOTRows.BusinessObject[i].OID]));
          mOLE.SQLExecute(format('Update storedocuments2 set reservedquantity=0 where id=''%s'' ',[mOTRows.BusinessObject[i].OID]));
        end;
        //mOTBO.save;
        for i:=0 to mRows.count-1 do begin
          mOLE.SQLExecute(format('Update receivedOrders2 set DeliveredQuantity=0 where id=''%s'' ',[mRows.BusinessObject[i].OID]));
          mOLE.SQLExecute(format('Update Reservations set Supplied=0 where Owner_id=''%s'' ',[mRows.BusinessObject[i].OID]));
        end;
        mOLE.SQLExecute(format('Update receivedOrders set Closed=''N'' where id=''%s'' ',[mbo.oid]));
      finally
       mbo.free;
       mContext:=NxCreateNotLoggedContext(msite.GetFakeBusinessObject.ObjectSpace);
       mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
       mOle:= mContext.GetObjectSpace;
       mBO:=mOLE.CreateObject(Class_ReceivedOrder);
       mBO.Load(TDynSiteForm(mSite).CurrentObject.OID,nil);
       mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      end;


       try

        mInputParams := TNxParameters.Create;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := '#00000080L';         //#### řada SP97 upraveno
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
        mParam.AsString := '#000000101';
        mImportMan := NxCreateDocumentImportManager(mOLE, Class_OutgoingTransfer, Class_IncomingTransfer);
        mImportMan.AddInputDocument(mOT_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','#00000080L');  //#### řada SP97  upraveno
        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID','1IA0000101');
        mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
        mImportMan.OutputDocument.SetFieldValueAsString('Description',mbo.DisplayName+' '+mbo.GetFieldValueAsString('Externalnumber'));
        mITRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:=0 to mITRows.count-1 do begin
          mITrows.BusinessObject[i].SetFieldValueAsString('Division_ID','#000000101');
        end;
        mImportMan.OutputDocument.save;
        mIT_ID:=mImportMan.OutputDocument.OID;
        mITNumber:=mImportMan.OutputDocument.DisplayName;
        //mContext.free;
      finally


      end;
      for i:=0 to mrows.count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       mRowBO.SetFieldValueAsString('Store_ID','#000000101');
       mRowBO.SetFieldValueAsString('Division_ID','#000000101');
      end;
      mBO.SetFieldValueAsString('X_StockNumber',mCode);
      mBO.SetFieldValueAsString('X_SourceStore',mSourceStore);
      mBO.SetFieldValueAsString('X_OoutgoingTransferID',mOT_ID);
      mBO.SetFieldValueAsString('X_IncomingTransferID',mIT_ID);
      mBO.SetFieldValueAsString('X_OutgoingTransferNumber',mOTNumber);
      mBO.SetFieldValueAsString('X_IncomingTransferNumber',mITNumber);
      mbo.save;
      mUserXLink := mBO.ObjectSpace.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mOT_ID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IncomingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mIT_ID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;

                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := '#00000080K';  //#### řada DL97    upraveno
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                mParam.AsString := mList.Text;
                mImportMan := NxCreateDocumentImportManager(mOLE, Class_ReceivedOrder, Class_BillOfDelivery);
                try
                  mImportMan.AddInputDocument(mBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '#00000080K'); //#### řada DL97  upraveno
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_eshopDL',true);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(msite.GetFakeBusinessObject));
                      //mImportMan.OutputDocument.SetFieldValueAsBoolean('U_eshopDL',true);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Prevzal',mPrijemce);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Driver',mRidic);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Transport_company',mSpolecnost);
                      mImportMan.OutputDocument.SetFieldValueAsString('U_ExtNumber',mBO.GetFieldValueAsString('ExternalNumber'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_Street',mBO.GetFieldValueAsString('U_Target_Street'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_City',mBO.GetFieldValueAsString('U_Target_City'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_Name',mBO.GetFieldValueAsString('U_Target_Name'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_PostCode',mBO.GetFieldValueAsString('U_Target_PostCode'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_Email',mBO.GetFieldValueAsString('U_Target_Email'));
                      mImportMan.OutputDocument.SetFieldValueAsString('U_Target_PhoneNumber',mBO.GetFieldValueAsString('U_Target_PhoneNumber'));
                      mImportMan.OutputDocument.Save;
                      //mBod:=mImportMan.OutputDocument;
                      mBOD_ID:=mImportMan.OutputDocument.OID;
                      mBODName:=mImportMan.OutputDocument.DisplayName;
                      mFileName:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                  end;
                mImportMan.Free;
                mInputParams.Free;
                finally
                end;

          // tisk dodacího listu
           mPrintList:=TStringList.Create;
           if not(NxIsEmptyOID(mBOD_ID)) then mPrintList.Add(mbod_ID);
           if mPrintList.count>0 then begin

              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoFile,pekPDF,NxGetTempDir,mFileName);
              //send internal mail
              SendInternalMail(mbo.ObjectSpace,'deus@obb.cz','','',
                          'V Abře OBB byl vystaven dodací list pro objednávku Deus  '+mbo.GetFieldValueAsString('ExternalNumber')+ ': DL číslo: '+mBODName,'Faktura nebyla vystavena. '+mDateString,
                          NxGetTempDir+'\'+mFileName,'','AAA1000000','#000000101','#000000201');
              CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPrintList,'05DOXDMCSZDL3FUD00C5OG4NF4','#000000E01',rtoPreview,pekPDF,'','');

           end;
           mPrintList.free;
          //tisk dodacího listu
       end;
      end;
end;

Procedure VR_DEUS(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mBO, mUser, mDLBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mBO_ID, mBOD_ID:string;
 mList:TStringList;
 mParam:TNxParameter;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mList:=TStringList.Create;
 if not(mbo.GetFieldValueAsBoolean('U_VR_Complete')) then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá povoleno vrátit zboží z eshopu. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz',mSite);
   exit;
 end;
 mOS.SQLSelect(format('Select parent_id from storedocuments2 where FlowType=''21'' and provide_id=''%s'' group by parent_id ',[mbo.oid]),mlist);
 if mlist.Count=0 then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádný dodací list.',mSite);
   exit;
 end;
 if mList.count>0 then begin
   mDLBO:=mos.CreateObject(Class_BillOfDelivery);
   mDLBO.load(mlist.strings[0],nil);
   if NxMessageBox('Dotaz',' Přejete si vrátit '+mDLBO.DisplayName+' k objednávce s externím číslem '+mbo.GetFieldValueAsString('ExternalNumber')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                mUser:=mOS.CreateObject(Class_SecurityUser);
                mUser.Load(NxGetActualUserID_1(mBO),nil);
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mUser.GetFieldValueAsString('X_RBOD_ID');
                mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_RefundedBillOfDelivery);
                try
                  mImportMan.AddInputDocument(mDLBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_RBOD_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_vratkaDL',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('Finished',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('IsAvailableForDelivery',False);
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka nefakturovaného '+mbo.DisplayName);
                      mImportMan.OutputDocument.Save;
                      //mBod:=mImportMan.OutputDocument;
                      //mBOD_ID:=mImportMan.OutputDocument.OID;
                      //mBOD:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                      //mBOD.Load(mBOD_ID,nil);
                      mImportMan.Free;
                      mInputParams.Free;
                  end;
                except
                 NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
                end;
    end;
  end;
end;

Procedure VR_DEUSEdit(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mBO, mUser, mDLBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mBO_ID, mBOD_ID:string;
 mList:TStringList;
 mParam:TNxParameter;
 mContext:TNxContext;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mList:=TStringList.Create;
 if not(mbo.GetFieldValueAsBoolean('U_VRChoice')) then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá povoleno vrátit vrátit zboží z eshopu V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz.',mSite);
   exit;
 end;
 mOS.SQLSelect(format('Select parent_id from storedocuments2 where FlowType=''21'' and provide_id=''%s'' group by parent_id ',[mbo.oid]),mlist);
 if mlist.Count=0 then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádný dodací list.',mSite);
   exit;
 end;
 if mList.count>0 then begin
   mDLBO:=mos.CreateObject(Class_BillOfDelivery);
   mDLBO.load(mlist.strings[0],nil);
   if NxMessageBox('Dotaz',' Přejete si vrátit '+mDLBO.DisplayName+' k objednávce s externím číslem '+mbo.GetFieldValueAsString('ExternalNumber')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                mUser:=mOS.CreateObject(Class_SecurityUser);
                mUser.Load(NxGetActualUserID_1(mBO),nil);
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mUser.GetFieldValueAsString('X_RBOD_ID');
                mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_RefundedBillOfDelivery);
                try
                  mImportMan.AddInputDocument(mDLBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_RBOD_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_vratkaDL',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('Finished',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('IsAvailableForDelivery',False);
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka nefakturovaného '+mbo.DisplayName);
                      mImportMan.OutputDocument.Save;
                      //mBod:=mImportMan.OutputDocument;
                      //mBOD_ID:=mImportMan.OutputDocument.OID;
                      //mBOD:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                      //mBOD.Load(mBOD_ID,nil);
                      mContext:=NxCreateNotLoggedContext_1(mBO);
                      mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
                      ShowDynForm('BL0I5SAOS3DL3ACU03KIU0CLP4', mContext, nil, nil, false, 'DoEditOnly;'+mImportMan.OutputDocument.OID);
                      mImportMan.Free;
                      mInputParams.Free;
                  end;
                except
                 NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
                end;
    end;
  end;
end;


Procedure VR_DEUSPalety(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mBO, mUser, mDLBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mBO_ID, mBOD_ID:string;
 mList, mList2:TStringList;
 mParam:TNxParameter;
 mPLICN, mPLVR:tstringlist;
 mFileName1, mFileName2:string;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mList:=TStringList.Create;
 if not(mbo.GetFieldValueAsBoolean('U_VRPalety')) then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá povoleno vrátit zboží z eshopu. V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz',mSite);
   exit;
 end;
 mOS.SQLSelect(format('Select parent_id from storedocuments2 where FlowType=''21'' and provide_id=''%s'' group by parent_id ',[mbo.oid]),mlist);
 if mlist.Count=0 then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádný dodací list.',mSite);
   exit;
 end;
 if mList.count>0 then begin
   mDLBO:=mos.CreateObject(Class_BillOfDelivery);
   mDLBO.load(mlist.strings[0],nil);
   if NxMessageBox('Dotaz',' Přejete si vrátit palety z '+mDLBO.DisplayName+' k objednávce s externím číslem '+mbo.GetFieldValueAsString('ExternalNumber')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                mUser:=mOS.CreateObject(Class_SecurityUser);
                mUser.Load(NxGetActualUserID_1(mBO),nil);
                mList2:=TStringList.Create;
                mOS.SQLSelect(format('Select sd2.id from storedocuments2 sd2 left join storecards sc on sc.id=sd2.storecard_id where sc.storecardcategory_ID=''E300000101'' and sd2.parent_id=''%s'' ',[mDLBO.OID]),mList2);
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mUser.GetFieldValueAsString('X_RBOD_ID');
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                mParam.AsString := mList2.text;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_RefundedBillOfDelivery);
                try
                  mImportMan.AddInputDocument(mDLBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mUser.GetFieldValueAsString('X_RBOD_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_vratkaDL',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('Finished',True);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('IsAvailableForDelivery',False);
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka nefakturovaného '+mbo.DisplayName);
                      mImportMan.OutputDocument.Save;
                      mImportMan.Free;
                      mInputParams.Free;
                  end;
                except
                 NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
                end;
    end;
  end;
end;

Procedure DV_DEUS(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mBO, mUser, mDLBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mBO_ID, mBOD_ID:string;
 mList:TStringList;
 mParam:TNxParameter;
 mPLICN, mPLVR:TStringList;
 mFileName1, mCode, mICNDocQueue_ID, mVRDocQueue_ID:string;
 mRows, mVRRows:TNxCustomBusinessMonikerCollection;
 mRowBO, mVRBO:TNxCustomBusinessObject;
 i,j:integer;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mList:=TStringList.Create;
 if not(mbo.GetFieldValueAsBoolean('U_VR_Complete')) then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá povoleno vrátit kompletní.',mSite);
   exit;
 end;
 mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if NxIsBlank(mCode) then mCode:=mRowBO.GetFieldValueAsString('Store_ID.Code');
         end;
       end;
       mICNDocQueue_ID:=GetICNDQ_ID(mbo.ObjectSpace,'DV'+mCode);
       mVRDocQueue_ID:=GetVRDQ_ID(mbo.ObjectSpace,'VR'+mCode);
       if NxIsEmptyOID(mICNDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu dobropisů s kódem DV'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
       if NxIsEmptyOID(mVRDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu vratek s kódem VR'+mcode+'. Ukončuji.', mSite);
         exit;
       end;

 mOS.SQLSelect(format('Select ii2.parent_id from storedocuments2 sd2 left join issuedinvoices2 ii2 on ii2.provide_id=sd2.parent_id where sd2.FlowType=''21'' and sd2.provide_id=''%s'' group by ii2.parent_id ',[mbo.oid]),mlist);
 if mlist.Count=0 then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádnou fakturu.',mSite);
   exit;
 end;
 if mList.count>0 then begin
   mDLBO:=mos.CreateObject(Class_IssuedInvoice);
   mDLBO.load(mlist.strings[0],nil);
   mOS.SQLSelect(format('Select id from issuedcreditnotes where source_id=''%s'' ',[mDLBO.oid]),mlist);
   if mlist.Count>0 then begin
     // NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' již má dobropis.',mSite);
     // exit;
   end;
   if NxMessageBox('Dotaz',' Přejete si vrátit '+mBO.DisplayName+' k objednávce s externím číslem '+mbo.GetFieldValueAsString('ExternalNumber')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mICNDocQueue_ID;
                mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                mParam.AsString := mVRDocQueue_ID;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
                try
                  mImportMan.AddInputDocument(mDLBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mICNDocQueue_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka DEUS');
                      mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vratka z eshopu firmy Deus');
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_DeusVR',true);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_Generate',true);
                      mImportMan.OutputDocument.Save;
                      mPLICN:=TStringList.Create;
                      mPLICN.Add(mImportMan.OutputDocument.OID);
                      mFileName1:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                      mFileName:='vratka.pdf';
                      mPLVR:=TStringList.create;
                      mOS.SQLSelect(format('select provide_id from issuedcreditnotes2 where parent_id=''%s'' group by provide_id ',[mImportMan.OutputDocument.OID]),mPLVR);
                      Try
                        mVRBO:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                        mVRBO.Load(mPLVR.strings[0],nil);
                        mVRRows:=mVRBO.GetLoadedCollectionMonikerForFieldCode(mVRBO.GetFieldCode('Rows'));
                        for j:=0 to mVRRows.count-1 do begin
                          if mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')=0 then mVRRows.BusinessObject[j].MarkForDelete;
                          if mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')<mVRRows.BusinessObject[j].GetFieldValueAsFloat('Quantity') then
                             mVRRows.BusinessObject[j].SetFieldValueAsFloat('Quantity',mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity'));
                        end;
                        mVRBO.save;
                        mvrbo.free;
                      except

                      end;
                      CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLICN,'KLFAXNODG3DL3ACT03KIU0CLP4','1U40000101',rtoFile,pekPDF,NxGetTempDir,mFileName1);
                      CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLVR,'0HDOXDMCSZDL3FUD00C5OG4NF4','#000000P01',rtoFile,pekPDF,NxGetTempDir,mFileName);

                      SendInternalMail(mbo.ObjectSpace,'slosar@obb.cz','deus@obb.cz','',
                          'Vystavená vratka a dobropis pro objednávku z eshopu  '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                          NxGetTempDir+'\'+mFileName,NxGetTempDir+'\'+mFileName1,'AAA1000000','#000000101','#000000201');
                      //CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLVR,'0HDOXDMCSZDL3FUD00C5OG4NF4','#000000P01',rtoPreview,pekPDF,'','');
                      mImportMan.Free;
                      mInputParams.Free;
                  end;
                except
                 NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
                end;
    end;
  end;
end;

Procedure DV_DEUSEdit(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mBO, mUser, mDLBO, mVRBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mBO_ID, mBOD_ID:string;
 mList:TStringList;
 mParam:TNxParameter;
 mContext:TNxContext;
 mPLICN, mPLVR:TStringList;
 mFileName1, mCode, mICNDocQueue_ID, mVRDocQueue_ID:string;
 mRows, mVRRows:TNxCustomBusinessMonikerCollection;
 mRowBO:TNxCustomBusinessObject;
 i,j:integer;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mList:=TStringList.Create;
 if not(mbo.GetFieldValueAsBoolean('U_VRChoice')) then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá povoleno vrátit s editací.',mSite);
   exit;
 end;
 mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if NxIsBlank(mCode) then mCode:=mRowBO.GetFieldValueAsString('Store_ID.Code');
         end;
       end;
       mICNDocQueue_ID:=GetICNDQ_ID(mbo.ObjectSpace,'DV'+mCode);
       mVRDocQueue_ID:=GetVRDQ_ID(mbo.ObjectSpace,'VR'+mCode);
       if NxIsEmptyOID(mICNDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu dobropisů s kódem DV'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
       if NxIsEmptyOID(mVRDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu vratek s kódem VR'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
 mOS.SQLSelect(format('Select ii2.parent_id from storedocuments2 sd2 left join issuedinvoices2 ii2 on ii2.provide_id=sd2.parent_id where sd2.FlowType=''21'' and sd2.provide_id=''%s'' group by ii2.parent_id ',[mbo.oid]),mlist);
 if mlist.Count=0 then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádnou fakturu.',mSite);
   exit;
 end;
 if mList.count>0 then begin
   mDLBO:=mos.CreateObject(Class_IssuedInvoice);
   mDLBO.load(mlist.strings[0],nil);
    mOS.SQLSelect(format('Select id from issuedcreditnotes where source_id=''%s'' ',[mDLBO.oid]),mlist);
  { if mlist.Count>0 then begin
      NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' již má dobropis.',mSite);
      exit;
   end; }
   if NxMessageBox('Dotaz',' Přejete si vrátit '+mBO.DisplayName+' k objednávce s externím číslem '+mbo.GetFieldValueAsString('ExternalNumber')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mICNDocQueue_ID;
                mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                mParam.AsString := mVRDocQueue_ID;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
                try
                  mImportMan.AddInputDocument(mDLBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mICNDocQueue_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID', mVRDocQueue_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka DEUS');
                      mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vratka z eshopu firmy Deus');
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_DeusVR',true);
                      mImportMan.OutputDocument.Save;
                      mContext:=NxCreateNotLoggedContext_1(mBO);
                      mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
                      ShowDynForm('T1C2EX0BUJD13ACP03KIU0CLP4', mContext, nil, nil, false, 'DoEditOnly;'+mImportMan.OutputDocument.OID);
                      if NxMessageBox('Dotaz',' Přejete si vygenerovat převodku k '+mImportMan.OutputDocument.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then
                       CreateTransferFromICN(mImportMan.OutputDocument);
                      mPLICN:=TStringList.Create;
                      mPLICN.Add(mImportMan.OutputDocument.OID);
                      mFileName1:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                      mFileName:='vratka.pdf';
                      mPLVR:=TStringList.create;
                      mOS.SQLSelect(format('select provide_id from issuedcreditnotes2 where parent_id=''%s'' group by provide_id ',[mImportMan.OutputDocument.OID]),mPLVR);
                      Try
                        mVRBO:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                        mVRBO.Load(mPLVR.strings[0],nil);
                        mVRRows:=mVRBO.GetLoadedCollectionMonikerForFieldCode(mVRBO.GetFieldCode('Rows'));
                        for j:=0 to mVRRows.count-1 do begin
                          if mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')=0 then mVRRows.BusinessObject[j].MarkForDelete;
                          if mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')<mVRRows.BusinessObject[j].GetFieldValueAsFloat('Quantity') then
                             mVRRows.BusinessObject[j].SetFieldValueAsFloat('Quantity',mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity'));
                        end;
                        mVRBO.save;
                        mvrbo.free;
                      except

                      end;
                      CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLICN,'KLFAXNODG3DL3ACT03KIU0CLP4','1U40000101',rtoFile,pekPDF,NxGetTempDir,mFileName1);
                      CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLVR,'0HDOXDMCSZDL3FUD00C5OG4NF4','#000000P01',rtoFile,pekPDF,NxGetTempDir,mFileName);

                      SendInternalMail(mbo.ObjectSpace,'slosar@obb.cz','','',
                          'Vystavená vratka a dobropis pro objednávku z eshopu  '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                          NxGetTempDir+'\'+mFileName,NxGetTempDir+'\'+mFileName1,'AAA1000000','#000000101','#000000201');
                      //CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLVR,'0HDOXDMCSZDL3FUD00C5OG4NF4','#000000P01',rtoPreview,pekPDF,'','');
                      mImportMan.Free;
                      mInputParams.Free;
                  end;
                except
                 NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
                end;
    end;
  end;
end;



Procedure DV_DEUSPalety(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName:string;
 mOpnDlg:TOpenDialog;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mBO, mUser, mDLBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mBO_ID, mBOD_ID:string;
 mList,mList2:TStringList;
 mParam:TNxParameter;
 mPLICN, mPLVR:TStringList;
 mFileName1, mCode, mICNDocQueue_ID, mVRDocQueue_ID:string;
 mRows, mVRRows:TNxCustomBusinessMonikerCollection;
 mRowBO, mVRBO:TNxCustomBusinessObject;
 i,j:integer;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mBO.ObjectSpace;
 mBO_ID:=mbo.OID;
 mList:=TStringList.Create;
 if not(mbo.GetFieldValueAsBoolean('U_VRPalety')) then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá povoleno vrátit palety.',mSite);
   exit;
 end;
 mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if NxIsBlank(mCode) then mCode:=mRowBO.GetFieldValueAsString('Store_ID.Code');
         end;
       end;
       mICNDocQueue_ID:=GetICNDQ_ID(mbo.ObjectSpace,'DV'+mCode);
       mVRDocQueue_ID:=GetVRDQ_ID(mbo.ObjectSpace,'VR'+mCode);
       if NxIsEmptyOID(mICNDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu dobropisů s kódem DV'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
       if NxIsEmptyOID(mVRDocQueue_ID) then begin
         NxShowSimpleMessage('Nepovedlo se dohledat řadu vratek s kódem VR'+mcode+'. Ukončuji.', mSite);
         exit;
       end;
 mOS.SQLSelect(format('Select ii2.parent_id from storedocuments2 sd2 left join issuedinvoices2 ii2 on ii2.provide_id=sd2.parent_id where sd2.FlowType=''21'' and sd2.provide_id=''%s'' group by ii2.parent_id ',[mbo.oid]),mlist);
 if mlist.Count=0 then begin
   NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' nemá žádnou fakturu.',mSite);
   exit;
 end;
 if mList.count>0 then begin
   mDLBO:=mos.CreateObject(Class_IssuedInvoice);
   mDLBO.load(mlist.strings[0],nil);
   mOS.SQLSelect(format('Select id from issuedcreditnotes where source_id=''%s'' ',[mDLBO.oid]),mlist);
   if mlist.Count>0 then begin
      //NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' již má dobropis.',mSite);
      //exit;
   end;
   if NxMessageBox('Dotaz',' Přejete si vrátit '+mBO.DisplayName+' k objednávce s externím číslem '+mbo.GetFieldValueAsString('ExternalNumber')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                mUser:=mOS.CreateObject(Class_SecurityUser);
                mUser.Load(NxGetActualUserID_1(mBO),nil);
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := mICNDocQueue_ID;
                mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                mParam.AsString := mVRDocQueue_ID;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
                try
                  mImportMan.AddInputDocument(mDLBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mICNDocQueue_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','Vratka DEUS');
                      mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vratka z eshopu firmy Deus');
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_DeusVR',true);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('U_Generate',true);
                      mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                      for i:=0 to mrows.count-1 do begin
                         if not(NxIsEmptyOID(mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'))) then begin
                           if not(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='E300000101') then mrows.BusinessObject[i].MarkForDelete;
                         end;
                      end;
                      mImportMan.OutputDocument.Save;
                      mPLICN:=TStringList.Create;
                      mPLICN.Add(mImportMan.OutputDocument.OID);
                      mFileName1:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                      mFileName:='vratka.pdf';
                      mPLVR:=TStringList.create;
                      mOS.SQLSelect(format('select provide_id from issuedcreditnotes2 where parent_id=''%s'' group by provide_id ',[mImportMan.OutputDocument.OID]),mPLVR);
                      Try
                        mVRBO:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                        mVRBO.Load(mPLVR.strings[0],nil);
                        mVRRows:=mVRBO.GetLoadedCollectionMonikerForFieldCode(mVRBO.GetFieldCode('Rows'));
                        for j:=0 to mVRRows.count-1 do begin
                          if mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')=0 then mVRRows.BusinessObject[j].MarkForDelete;
                          if mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')<mVRRows.BusinessObject[j].GetFieldValueAsFloat('Quantity') then
                             mVRRows.BusinessObject[j].SetFieldValueAsFloat('Quantity',mVRRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity'));
                        end;
                        mVRBO.save;
                        mvrbo.free;
                      except

                      end;
                      CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLICN,'KLFAXNODG3DL3ACT03KIU0CLP4','1U40000101',rtoFile,pekPDF,NxGetTempDir,mFileName1);
                      CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLVR,'0HDOXDMCSZDL3FUD00C5OG4NF4','#000000P01',rtoFile,pekPDF,NxGetTempDir,mFileName);

                      SendInternalMail(mbo.ObjectSpace,'slosar@obb.cz','','',
                          'Vystavená vratka a dobropis pro objednávku z eshopu  '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                          NxGetTempDir+'\'+mFileName,NxGetTempDir+'\'+mFileName1,'AAA1000000','#000000101','#000000201');
                      //CFxReportManager.PrintByIDs(NxCreateContext(mbo.ObjectSpace),mPLVR,'0HDOXDMCSZDL3FUD00C5OG4NF4','#000000P01',rtoPreview,pekPDF,'','');
                      mImportMan.Free;
                      mInputParams.Free;
                  end;
                except
                 NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
                end;
    end;
  end;
end;

Procedure ImportDEUS(Sender:TComponent);
var
 mSite:TSiteForm;
 mFileName, mStoreCard_ID:string;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j:integer;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRowBO, mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 if not(TDynSiteForm(mSite).Edit) then begin
        NxShowSimpleMessage('Nejste ve stavu editace, soubor nepůjde naimportovat.',mSite);
        exit;
 end;
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.Title := 'Import dat od DT';
 mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
 if mOpenDlg.Execute then begin
    mXMLHead:=TNxScriptingXMLWrapper.Create;
    mXMLHead.loadFromFile(mOpenDlg.FileName);
    mBO:=TDynSiteForm(mSite).CurrentObject;
    mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
    for j:=0 to mRows.count-1 do begin
      mrows.BusinessObject[j].MarkForDelete;
    end;
    mControl:= mSite.FindChildControl('tabRows.grdRows');
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    if Assigned(mDataset) then begin
      mDataSet.DisableControls;
          if mXMLHead.getElementsCountInArray('ORDER')>0 then begin
            for i:=0 to mXMLHead.getElementsCountInArray('ORDER[0].Rows.Row')-1 do begin
             if mXMLHead.getElementAsInteger('ORDER[0].Rows.Row['+IntToStr(i)+'].RowType')=3 then begin
               mStoreCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].StoreCard.Code'),mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Qunit'));
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mRowBO:=mDataset.CreateBusinessObject;
                 mRowBO.Prefill;
                 mRowBO.SetFieldValueAsInteger('RowType',3);
                 mRowBO.SetFieldValueAsString('Store_ID','#000000101');
                 mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                 mRowBO.SetFieldValueAsString('X_StockType_ID','1000000101');
                 mRowBO.SetFieldValueAsString('U_Abra_ID',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Abra_ID'));
                 mRowBO.SetFieldValueAsFloat('Quantity', mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].Quantity'));
                 mRowBO.SetFieldValueAsFloat('UnitPrice',mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].UnitPrice'));
                 //mRowBO.SetFieldValueAsFloat('TotalPrice',mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].TamountWithoutVAT'));
                 mRowBO.SetFieldValueAsString('Division_ID','#000000101');
                 mRowBO.SetFieldValueAsString('BusTransaction_ID','#000000201');
                 mRowBO.SetFieldValueAsString('Parent_ID.ExternalNumber',mXMLHead.getElementAsString('ORDER[0].ExternalNumber'));
                 mRowBO.SetFieldValueAsString('Parent_ID.Firm_ID',GetFirm_ID(mOS,mXMLHead.getElementAsString('ORDER[0].OwnOrgIdentNumber')));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Street',mXMLHead.getElementAsString('ORDER[0].Target_Street'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_City',mXMLHead.getElementAsString('ORDER[0].Target_City'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_PostCode',mXMLHead.getElementAsString('ORDER[0].Target_PostCode'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Contact',mXMLHead.getElementAsString('ORDER[0].Target_Name'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_Street',mXMLHead.getElementAsString('ORDER[0].Target_Street'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_City',mXMLHead.getElementAsString('ORDER[0].Target_City'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_PostCode',mXMLHead.getElementAsString('ORDER[0].Target_PostCode'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_Name',mXMLHead.getElementAsString('ORDER[0].Target_Name'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_Email',mXMLHead.getElementAsString('ORDER[0].Target_Email'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Note',mXMLHead.getElementAsString('ORDER[0].Note'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_PhoneNumber',mXMLHead.getElementAsString('ORDER[0].Target_PhoneNumber'));
                 mRowBO.SetFieldValueAsString('Parent_ID.DocQueue_ID','#000000602');
                 if mXMLHead.getElementAsString('ORDER[0].CashOnDelivery')='Ano' then begin
                   mRowBO.SetFieldValueAsBoolean('Parent_ID.U_CashOnDelivery',true);
                   mRowBO.SetFieldValueAsBoolean('Parent_ID.U_Eshop_Delivery',true);
                 end;
                end;
                if NxIsEmptyOID(mStoreCard_ID) then begin
                 mRowBO:=mDataset.CreateBusinessObject;
                 mRowBO.Prefill;
                 mRowBO.SetFieldValueAsInteger('RowType',2);
                 mRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].StoreCard.Code')+' '+mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].StoreCard.Name'));
                 mRowBO.SetFieldValueAsString('QUnit',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Qunit'));
                 mRowBO.SetFieldValueAsString('U_Abra_ID',mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].Abra_ID'));
                 mRowBO.SetFieldValueAsFloat('Quantity', mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].Quantity'));
                 mRowBO.SetFieldValueAsFloat('UnitPrice',mXMLHead.getElementAsFloat('ORDER[0].Rows.Row['+IntToStr(i)+'].UnitPrice'));
                 mRowBO.SetFieldValueAsString('VatRate_ID',GetVatRate_ID(mOS,mXMLHead.getElementAsString('ORDER[0].Rows.Row['+IntToStr(i)+'].VatRate')));
                 mRowBO.SetFieldValueAsString('Division_ID','#000000101');
                 mRowBO.SetFieldValueAsString('BusTransaction_ID','#000000201');
                 mRowBO.SetFieldValueAsString('Parent_ID.ExternalNumber',mXMLHead.getElementAsString('ORDER[0].ExternalNumber'));
                 mRowBO.SetFieldValueAsString('Parent_ID.Firm_ID',GetFirm_ID(mOS,mXMLHead.getElementAsString('ORDER[0].OwnOrgIdentNumber')));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Street',mXMLHead.getElementAsString('ORDER[0].Target_Street'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_City',mXMLHead.getElementAsString('ORDER[0].Target_City'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_PostCode',mXMLHead.getElementAsString('ORDER[0].Target_PostCode'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Contact',mXMLHead.getElementAsString('ORDER[0].Target_Name'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_Street',mXMLHead.getElementAsString('ORDER[0].Target_Street'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_City',mXMLHead.getElementAsString('ORDER[0].Target_City'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_PostCode',mXMLHead.getElementAsString('ORDER[0].Target_PostCode'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_Name',mXMLHead.getElementAsString('ORDER[0].Target_Name'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_Email',mXMLHead.getElementAsString('ORDER[0].Target_Email'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Note',mXMLHead.getElementAsString('ORDER[0].Note'));
                 mRowBO.SetFieldValueAsString('Parent_ID.U_Target_PhoneNumber',mXMLHead.getElementAsString('ORDER[0].Target_PhoneNumber'));
                 mRowBO.SetFieldValueAsString('Parent_ID.DocQueue_ID','#000000602');
                 if mXMLHead.getElementAsString('ORDER[0].CashOnDelivery')='Ano' then begin
                   mRowBO.SetFieldValueAsBoolean('Parent_ID.U_CashOnDelivery',true);
                   mRowBO.SetFieldValueAsBoolean('Parent_ID.U_Eshop_Delivery',true);
                 end;

                end;
             end;
            end;
          end;
    end;
    TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
    mDataset.RefreshAndRestoreLastSelectedItem;
    mDataSet.EnableControls;
 end;
end;



Function GetData1(var aSite:TSiteForm; var aString, bString:string; var aResult:Integer):boolean;
var
 mEd1, mEd2:TEdit;
 mLabel1: TLabel;
 mButOk, mButCancel : TButton;
 mForm:TForm;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 280;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro výdej';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Řidič:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 125;
    med1.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Přep. společnost:';
    mLabel1.Top := 35;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.parent :=mForm;
    mEd2.top := 35;
    mEd2.left := 125;
    med2.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'V případě dotazů kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz';
    mLabel1.Top := 60;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 80;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 80;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    aResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if aResult = 1 then
        aString:=mEd1.Text;
        bString:=mEd2.Text;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

end;

Function GetData(var aSite:TSiteForm; var aString, bString:string; var aResult:Integer):boolean;
var
 mEd1, mEd2:TEdit;
 mLabel1: TLabel;
 mButOk, mButCancel : TButton;
 mForm:TForm;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 230;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro výdej';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'PIN:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 125;
    med1.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Převzal:';
    mLabel1.Top := 35;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.parent :=mForm;
    mEd2.top := 35;
    mEd2.left := 125;
    med2.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Objednávka je označena pro vlastní odvoz zákazníkem eshopu. Pokud připravujete zakázku pro odvoz přepravní službou a chcete vystavit DL, kontaktujte koordinátora e-shopu 778 113 579 nebo deus@obb.cz';
    mLabel1.Top := 60;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 80;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 80;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    aResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if aResult = 1 then
        aString:=mEd1.Text;
        bString:=mEd2.Text;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

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


begin
end.