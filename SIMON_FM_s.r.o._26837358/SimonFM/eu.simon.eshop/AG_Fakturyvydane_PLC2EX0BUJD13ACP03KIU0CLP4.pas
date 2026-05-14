uses 'eu.simon.eshop.mail';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser : TNxCustomBusinessObject;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
   for i := 0 to mAList.ActionCount-1 do begin
    mCAction := mALIst.Actions[i];
    if (mCAction.Name = 'actBarCodeReader') then
      TBasicAction(mCAction).ShortCut :=  TextToShortCut ('Ctrl+Q');
  end;
   mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
   mUser.Load(Self.CompanyCache.GetUserID, nil);
   if (mUser.GetFieldCode('U_PPL')>0) and mUser.GetFieldValueAsBoolean('U_PPL') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Číslo PPL';
    mAction.Hint := 'Provede zadání čísla PPL do faktury';
    mAction.Category := 'tabList';
    mAction.OnExecute := @SetPPL;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Odeslat PPL';
    mAction.Hint := 'Odešle označené PPL zakázky';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ExecutePPL;
     mAList := Self.GetMainActionList;


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'PPL EAN';
  mAction.ShortCut := TextToShortCut('Ctrl+B'); //16450;
  mAction.Hint := 'Označí dle PPL EAN';
  mAction.Category := 'tabList';
  mAction.OnExecute := @BarCodeOnExecute;
    //mAction.OnUpdate := @ImportOnUpdate;
  end;
end;

procedure SetPPL(Sender:TComponent);
var
 mSite:TsiteForm;
 mCurrentBO:TNxCustomBusinessObject;
 mNumber:String;
 mDialog:Boolean;
begin
  msite:=TComponent(Sender).DynSite;
  mCurrentBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mCurrentBO) then begin
    mNumber:='';
    PPLNumber(mSite, mNumber,mDialog);
    if not(mDialog) then exit;
    //NxShowSimpleMessage(mNumber,mSite);
    mCurrentBO.SetFieldValueAsString('X_PPLNumber',mNumber);
    mCurrentBO.Save;
    TDynSiteForm(mSite).RefreshData;
  end;
end;

procedure ExecutePPL(Sender:TComponent);
var
 mSite:TsiteForm;
 mList:TStringList;
 i:Integer;
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 aTo, ACC, ABCC, ASubject, ABody, AAtachement, AFirm_ID, ADivision_ID, ABusTransaction_ID:String;
begin
 msite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).CurrentObject.ObjectSpace;
 mList:=Tstringlist.Create;
 TDynSiteForm(mSite).FillListWithSelectedRows(mList);
 for i:=0 to mlist.Count-1 do begin
     mBO:=mOS.CreateObject(Class_IssuedInvoice);
     mbo.Load(mList.Strings[i],nil);
     mbo.SetFieldValueAsDateTime('U_expeditionPPL',Now);
     mbo.SetFieldValueAsBoolean('U_pplsent',True);
     if mbo.GetFieldValueAsString('TransportationType_ID.Code')='P2' then begin
      ASubject:='Zakázka byla předána přepravci PPL';
      aBody:='<br><br>Vážený zákazníku,<br><br>'+
             'Vaše zásilka číslo: '+
             '<a href="http://www.ppl.cz/main2.aspx?cls=Package&amp;idSearch='+mbo.GetFieldValueAsString('X_PPLNumber')+'" target="_blank">'+mbo.GetFieldValueAsString('X_PPLNumber')+'</a> byla předána dopravní společnosti<br>'+
             '<br>'+
             'Celková částka zásilky činí: <br>'+
             FormatFloat('0.00,',mbo.GetFieldValueAsFloat('Amount'))+' CZK<br>'+
             '<br>Děkujeme za Váš nákup.<br><br>Tým Simon FM</div><br></div>';
      AAtachement:='';
      AFirm_ID:=mbo.GetFieldValueAsString('Firm_ID');
      ADivision_ID:='1400000101';
      ABusTransaction_ID:='1900000101';
      aTo:=GetEmail(mOS,mBO.OID);
      if nxisblank(aTo) then ato:=mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_id.email');
     if NxIsValidEMail(ato,false) then SendInternalMail2(mos,aTo, ACC, ABCC, ASubject, ABody, AAtachement, AFirm_ID, ADivision_ID, ABusTransaction_ID,'');
     end;
     if mbo.GetFieldValueAsString('TransportationType_ID.Code')='P1' then begin
      ASubject:='Zakázka byla předána přepravci Česká pošta';
      aBody:='<br><br>Vážený zákazníku,<br><br>'+
             'Vaše zásilka číslo: '+
             '<a href="https://www.postaonline.cz/trackandtrace/-/zasilka/cislo?parcelNumbers='+mbo.GetFieldValueAsString('X_PPLNumber')+'" target="_blank">'+mbo.GetFieldValueAsString('X_PPLNumber')+'</a> byla předána dopravní společnosti<br>'+
             '<br>'+
             'Celková částka zásilky činí: <br>'+
             FormatFloat('0.00,',mbo.GetFieldValueAsFloat('Amount'))+' CZK<br>'+
             '<br>Děkujeme za Váš nákup.<br><br>Tým Simon FM</div><br></div>';
      AAtachement:='';
      AFirm_ID:=mbo.GetFieldValueAsString('Firm_ID');
      ADivision_ID:='1400000101';
      ABusTransaction_ID:='1900000101';
      aTo:=GetEmail(mOS,mBO.OID);
      if nxisblank(aTo) then ato:=mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_id.email');
     if NxIsValidEMail(ato,false) then SendInternalMail2(mos,aTo, ACC, ABCC, ASubject, ABody, AAtachement, AFirm_ID, ADivision_ID, ABusTransaction_ID,'');
     end;
     if mbo.GetFieldValueAsString('TransportationType_ID.Code')='01' then begin
      ASubject:='Zakázka byla připravena k předání';
      aBody:='<br><br>Vážený zákazníku,<br><br>'+
             'Vaše zásilka je připravena k předání na naší maloobchodní prodejně<br><br>'+
             'Celková částka zásilky činí: <br>'+
             FormatFloat('0.00,',mbo.GetFieldValueAsFloat('Amount'))+' CZK<br>'+
             '<br>Děkujeme za Váš nákup.<br><br>Tým Simon FM</div><br></div>';
      AAtachement:='';
      AFirm_ID:=mbo.GetFieldValueAsString('Firm_ID');
      ADivision_ID:='1400000101';
      ABusTransaction_ID:='1900000101';
      aTo:=GetEmail(mOS,mBO.OID);
      if nxisblank(aTo) then ato:=mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_id.email');
     if NxIsValidEMail(ato,false) then SendInternalMail2(mos,aTo, ACC, ABCC, ASubject, ABody, AAtachement, AFirm_ID, ADivision_ID, ABusTransaction_ID,'');
     end;
     mbo.save;
     mbo.free;
 end;
end;

function GetEmail(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'Select ro.X_AES_Email from issuedinvoices2 II2 '+
  'left join storedocuments2 sd2 on ii2.providerow_id=sd2.id ' +
  'left join receivedorders2 ro2 on sd2.providerow_id=ro2.id '  +
  'left join receivedorders ro on ro.id=ro2.parent_ID '+
  'where ii2.parent_id=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

Procedure PPLNumber(var aSite:TSiteForm; var aNumber:String;var  aDialog:Boolean);
var
 mEd:TEdit;
 aResult:Integer;
 aLabel:TLabel;
 mForm:TForm;
 mButOk, mButCancel : TButton;
 mResult : integer;
begin
  mForm:=TForm.Create(aSite);
  mForm.Caption:='Zadejte číslo PPL';
  mForm.Width := 350;
  mForm.Height := 120;

  aLabel := TLabel.Create(mForm);
  aLabel.Parent := mForm;
  aLabel.Caption := 'Číslo balíku';
  aLabel.Top := 10;
  aLabel.Left := 17;
  aLabel.Height := 13;

  mEd := TEdit.Create(mForm);
  mEd.Left := 107;
  mEd.Top := 10;
  mEd.Width := 200;
  mEd.Text := '';
  mEd.Parent := mForm;

  mButOk:= TButton.Create(mForm);
  mButOk.Parent := mForm;
  mButOk.Caption := 'Ok';
  mButOk.Top := 39;
  mButOk.Left := 152;
  mButOk.Height := 24;
  mButOk.Width := 62;
  mButOk.ModalResult := 1;

  mButCancel := TButton.Create(mForm);
  mButCancel.Parent := mForm;
  mButCancel.Caption := 'Cancel';
  mButCancel.Top := 39;
  mButCancel.Left := 220;
  mButCancel.Height := 24;
  mButCancel.Width := 62;
  mButCancel.ModalResult := 2;


  mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin

        adialog:=true;
        aNumber:=mEd.text;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
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
  mForm.Caption := 'Výběr faktury';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'PPL EAN:';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblSerialNumber';
  mForm.InsertControl(mLbl);

  mBarCodeEdt := TEdit.Create(mForm);
  mBarCodeEdt.Left := 90;
  mBarCodeEdt.Top := 8;
  mBarCodeEdt.Width := mForm.Width - mBarCodeEdt.Left - 22; //140;
  mBarCodeEdt.Name := 'edtSerialNumber';
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




procedure BarCodeOnExecute(Sender : TComponent);
const
  cSQL_PPL = 'SELECT A.ID FROM IssuedInvoices A ' +
            ' WHERE a.X_PPLNumber = ''%s'' ';

var
  mStrBatchCode, mOID : string;
  mSite: TSiteForm;
  mGrid : TDBGrid;
  mActiveDataSet : TNxDataDataSet;
  SL : TStringList;
  i : integer;
begin
  mSite := tcomponent(Sender).DynSite;
  if not BarCodeDialog(mStrBatchCode, mSite) then
    exit;

  mGrid := TDBGrid(NxFindChildControl(mSite.MainPanel, 'grdList'));
  if not Assigned(mGrid) then begin
    NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
    exit;
  end;
  mActiveDataSet := TNxDataDataSet(mGrid.DataSource.DataSet);
  mActiveDataSet.DisableControls;
  try
    SL := TstringList.Create;
    try
      mSite.GetFakeBusinessObject.ObjectSpace.SQLSelect(Format(cSQL_PPL, [mStrBatchCode]),  SL);

      if SL.Count = 0 then begin
        NxShowMessage('info','nenalezeno',mdInformation,false,mSite);
        exit;
      end;
      for i := 0 to SL.Count - 1 do begin
        mActiveDataSet.SeekID(SL.Strings[i]);
        mGrid.SelectRows_1(SL.Strings[i]);
      end;
    finally
      SL.Free;
    end;
  finally
    mActiveDataSet.EnableControls;
  end;
end;

begin
end.