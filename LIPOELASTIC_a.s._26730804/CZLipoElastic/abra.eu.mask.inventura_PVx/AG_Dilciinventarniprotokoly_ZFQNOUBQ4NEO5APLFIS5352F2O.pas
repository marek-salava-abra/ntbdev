const
cSQL_row = 'SELECT B.ID FROM MainInvProtocolRows B ' +
           ' LEFT JOIN MainInvProtocols A ON A.ID=B.Parent_ID ' +
           ' WHERE A.ID=''%s'' AND B.StoreCard_ID=''%s'' ';
Var
  mbo,mbo1: TNxCustomBusinessObject;
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  Xresult:Boolean;
  i: integer;
  mr,mr1,mr3:tstringlist;



procedure Pruvodce_DIP(sender: TBasicAction;index: Integer);
  procedure iFillStorecards(AOS : TNxCustomObjectSpace; AList : TStrings);
  const
    cSQL = 'SELECT ID FROM Storecards WHERE Hidden=''N'' ORDER BY EAN';

  begin
    AOS.SQLSelect(cSQL, AList);
  end;
var
  mBO : TNxCustomBusinessObject;
  mhead:TNxHeaderBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  P:integer;
  pocet:integer;
  tpocet:string;
  mForm : TForm;
  mBtn : TButton;
  mLbl,mLbl1 : TLabel;
  cbStoreCards : TComboBox;
  cbpocet,cbean,cbpopis:TEdit;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;

  i : integer;
  mPartialInvProtocol, mRowBO : TNxCustomBusinessObject;
  mMainInvProtocolRow_ID, mStoreCard_ID : string;
  mQuantity : double;
   mleft,mtop:integer;
  mB_Result:Boolean;
  mList:TStringList;
  mtext:string;
  result:string;
  mean_old:string;
  mpocet:Double;
  mpopis:string;
  mStoreCard_ID_Old:string;
begin
    mleft:=600;
    mtop:=300;

    mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabRows'));
    if mTabList = nil then RaiseException('tabRows nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdRows'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBO := TDynSiteForm(mSite).CurrentObject;
   mHead := TNxHeaderBusinessObject(mBO.ObjectSpace.CreateObject('U0D05ZPUL3IOVHE2PRXQGEOVG4'));
   mhead.Load(mbo.OID,nil);
    mpocet:=1;
    mpopis:='Posledni Karta';
    mForm := TForm.Create(Sender);
        mForm.BorderIcons := [biSystemMenu];
        mForm.Width := 600;  // sirka
        mForm.Height := 130; // vyska
        mForm.Caption := 'Nastavení řádku dokladu';
        mform.Left:=mleft;
        mform.top:=mtop;

        mLbl := TLabel.Create(mForm);
        mLbl.Caption := 'Skladová karta EAN:';
        mLbl.Left := 30;
        mLbl.Top := 30;
        mLbl.Name := 'lblStoreCard';
        mForm.InsertControl(mLbl);

              mLbl1 := TLabel.Create(mForm);
        mLbl1.Caption := 'Počet:';
        mLbl1.Left := 300;
        mLbl1.Top := 30;
        mLbl1.Name := 'lblPocet';
        mForm.InsertControl(mLbl1);

        mBtn := TButton.Create(mForm);
        mBtn.Width := 100;
        mBtn.Height := 25;
        mBtn.Caption := 'OK';
        mBtn.ModalResult := mrOk;
        mBtn.Cancel := False;
        mBtn.Default := True;
        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 25;
        mBtn.Top := mForm.Height - mBtn.Height - 40;
        mBtn.Name := 'btnOK';
        mForm.InsertControl(mBtn);

        mBtn := TButton.Create(mForm);
        mBtn.Width := 100;
        mBtn.Height := 25;
        mBtn.Caption := 'Storno';
        mBtn.ModalResult := mrCancel;
        mBtn.Cancel := True;
        mBtn.Left := mForm.Width - (mBtn.Width+2) - 25;;
        mBtn.Top := mForm.Height - mBtn.Height - 40;
        mBtn.Name := 'btnCancel';
        mForm.InsertControl(mBtn);

        cbean := TEdit.Create(mForm);
        cbean.Left := 130;
        cbean.Top := 32;
        cbean.Width := 150;
        cbean.Name := 'cbean';
        //cbean.Text := '';
        mForm.InsertControl(cbean);

        cbpocet := TEdit.Create(mForm);
        cbpocet.Left := 350;
        cbpocet.Top := 30;
        cbpocet.Width := 150;
        cbpocet.Name := 'cbpocet';
        //cbpocet.Text := '1';
        mForm.InsertControl(cbpocet);

        cbpopis := TEdit.Create(mForm);
        cbpopis.Left := 30;
        cbpopis.Top := 5;
        cbpopis.Width := 250;
        cbpopis.Enabled:=false;

        cbpopis.Name := 'cbpopis';
        //cbpocet.Text := '1';
        mForm.InsertControl(cbpopis);

    while UpperCase(cbPocet.Text)<> 'KONEC' do begin

        cbean.Text := '';
        cbpocet.Text := NxFloatToIBStr(mpocet);
        cbpopis.Text := mpopis;

       if mForm.ShowModal(msite) = mrCancel then begin
            mB_Result:=False;
        end else begin
            mB_Result:=true;
        end;


        if mB_Result then begin

              if (mean_old=cbean.Text) then begin
                 mpocet:=mpocet+1;

              end else begin

                        try
                          try

                           mStoreCard_ID:='';


                           mMainInvProtocolRow_ID:='';
                            try
                            //mStoreCard_ID:='';
                                                if cbean.Text='' then begin
                                                      mStoreCard_ID := '';
                                                end else begin
                                                  mStoreCard_ID := iGetIDByCode(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, 'StoreCards', cbean.Text);
                                                end;


                                                  if NxIsEmptyOID(mStoreCard_ID) then begin
                                                      ShowMessage('Ean karty nenalezen, zboží odložte a dohledejte následně. S aktiální položkou nebude manipulováno');


                                                                          mPartialInvProtocol := mhead.ObjectSpace.CreateObject(Class_PartialInvProtocol);
                                                                          try

                                                                              mPartialInvProtocol.Load(mhead.OID, nil);
                                                                              mQuantity:= mpocet;
                                                                              mMainInvProtocolRow_ID := iGetOrCreateMainInvProtocolRow_ID(mhead.ObjectSpace, mPartialInvProtocol.GetFieldValueAsString('MainProtocol_ID'),
                                                                                                      mStoreCard_ID_Old, mPartialInvProtocol.GetFieldValueAsBoolean('AddRows'));


                                                                                    if NxIsEmptyOID(mMainInvProtocolRow_ID) then begin
                                                                                         ShowMessage('Skladová karta není zpracovávána inventurou, zboží odložte a později zpracujte ručně');
                                                                                    end;


                                                                                  mRowBO := mPartialInvProtocol.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
                                                                                  try
                                                                                   ///NxShowSimpleMessage( ' DDD' + mStoreCard_ID,nil);
                                                                                        mRowBO.New;
                                                                                        mRowBO.Prefill;
                                                                                        mRowBO.SetFieldValueAsString('Parent_ID', mPartialInvProtocol.OID);
                                                                                        mRowBO.SetFieldValueAsString('MIPRow_ID', mMainInvProtocolRow_ID);
                                                                                        mRowBO.SetFieldValueAsFloat('RealQuantity', mpocet);
                                                                                        //NxShowSimpleMessage( ' eee' + mStoreCard_ID,nil);
                                                                                         mRowBO.Save;
                                                                                         mean_old:=cbean.Text;
                                                                                         mStoreCard_ID_Old:=mStoreCard_ID;
                                                                                         mpocet:=1;
                                                                                         //NxShowSimpleMessage('Zápis',nil);
                                                                                   finally
                                                                                         mRowBO.free;
                                                                                   end;
                                                                                  //mDBGrid.DataSource.DataSet.Refresh;
                                                                                  TDynSiteForm(NxFindSiteForm(Sender)).RefreshData;


                                                                          finally
                                                                          mPartialInvProtocol.Free;
                                                                      end;
                                                            exit;
                              end else begin

                                  mr:=tstringlist.create;
                                  try
                                     mSite.BaseObjectSpace.SQLSelect('Select code || '' - '' || name from storecards where id=' + quotedstr(mStoreCard_ID),mr);
                                     if mr.count>0 then mpopis:=mr.Strings[0] ;
                                  finally
                                      mr.free;
                                  end;

                                  if mean_old<>'' then begin
                                  mPartialInvProtocol := mhead.ObjectSpace.CreateObject(Class_PartialInvProtocol);
                                  try

                                      mPartialInvProtocol.Load(mhead.OID, nil);
                                      mQuantity:= mpocet;
                                      mMainInvProtocolRow_ID := iGetOrCreateMainInvProtocolRow_ID(mhead.ObjectSpace, mPartialInvProtocol.GetFieldValueAsString('MainProtocol_ID'),
                                                              mStoreCard_ID, mPartialInvProtocol.GetFieldValueAsBoolean('AddRows'));


                                            if NxIsEmptyOID(mMainInvProtocolRow_ID) then begin
                                                 ShowMessage('Skladová karta není zpracovávána inventurou, zboží odložte a později zpracujte ručně');
                                            end;

                                          mean_old:=cbean.Text;
                                          mRowBO := mPartialInvProtocol.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
                                          try
                                           ///NxShowSimpleMessage( ' DDD' + mStoreCard_ID,nil);
                                                mRowBO.New;
                                                mRowBO.Prefill;
                                                mRowBO.SetFieldValueAsString('Parent_ID', mPartialInvProtocol.OID);
                                                mRowBO.SetFieldValueAsString('MIPRow_ID', mMainInvProtocolRow_ID);
                                                mRowBO.SetFieldValueAsFloat('RealQuantity', mQuantity);
                                                //NxShowSimpleMessage( ' eee' + mStoreCard_ID,nil);
                                                 mRowBO.Save;

                                                 mpocet:=1;
                                                 //NxShowSimpleMessage('Zápis',nil);
                                           finally
                                                 mRowBO.free;
                                           end;
                                          //mDBGrid.DataSource.DataSet.Refresh;
                                          TDynSiteForm(NxFindSiteForm(Sender)).RefreshData;


                                  finally
                                  mPartialInvProtocol.Free;
                              end;
                              mStoreCard_ID_Old:=mStoreCard_ID;
                              end;
                              end;
                            finally
                            end;
                          except
                          end;
                        finally
                        end;
                     // end else begin
                                 if mB_Result=false then exit ;
                      end;
              end;
  end;


end;






















procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
begin
      mAList := Self.GetMainActionList;
        mMAction := Self.GetNewMultiAction;
        mMAction.ShowControl := True;
        mMAction.ShowMenuItem := True;
        mMAction.Hint := '';
        mMAction.Caption := 'Průvodce invx.';
        mMAction.Items.Add('Průvodce invx.');
        mMAction.Category := 'tabRows';
        mMAction.OnExecuteItem := @Pruvodce_DIP;
end;

function iGetIDByCode(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE ean=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;

function iGetOrCreateMainInvProtocolRow_ID(AOS : TNxCustomObjectSpace; AMainInvProtocol_ID : TNxOID; AStoreCard_ID : string;
                                             ACreateNew : Boolean) : TNxOID;
  const
    cSQL = 'SELECT B.ID FROM MainInvProtocolRows B ' +
           ' LEFT JOIN MainInvProtocols A ON A.ID=B.Parent_ID ' +
           ' WHERE A.ID=''%s'' AND B.StoreCard_ID=''%s'' ';
  var
    L : TStringList;
    mMainProtocolRowBO : TNxCustomBusinessObject;
  begin
    Result := '';
    L := TStringList.Create;
    try

      AOS.SQLSelect(format(cSQL, [AMainInvProtocol_ID, AStoreCard_ID]), L);
      if L.Count > 0 then begin
        Result := L.Strings[0];
        exit;
      end;
    finally
      L.Free;
    end;
    if ACreateNew then begin
      mMainProtocolRowBO := AOS.CreateObject(Class_MainInvProtocolRow);
      try
        mMainProtocolRowBO.New;
        mMainProtocolRowBO.SetFieldValueAsString('Parent_ID', AMainInvProtocol_ID);
        mMainProtocolRowBO.SetFieldValueAsString('StoreCard_ID', AStoreCard_ID);
        mMainProtocolRowBO.Save;
        Result := mMainProtocolRowBO.OID;
      finally
        mMainProtocolRowBO.Free;
      end;
    end;
  end;


begin
end.