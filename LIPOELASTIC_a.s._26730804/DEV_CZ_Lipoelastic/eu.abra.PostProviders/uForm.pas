uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uCustomScript',
  'eu.abra.PostProviders.uCreatePackage',
  'eu.abra.PostProviders.uMemoMessage',
  'eu.abra.PostProviders.uPostProvider',
  'eu.abra.PostProviders.uAddressFunc',
  'eu.abra.PostProviders.uOutPutPackages',
  'eu.abra.PostProviders.uWeightFunc';

procedure CreateForm(ASite: TSiteForm; APanel: TPanel);
const
  cCountButtons = 12;
var
  grdData, grdContent: TMultiGrid;
  pnBottom: TPanel;
  pnBottomRight: TPanel;
  pnGrid, pnGridContent, pnGridContentControl: TPanel;
  pnLeft, pnLeft2, pnRight: TPanel;
  dsHeader, dsRows, dsContent: TDataSource;
  mBtn: array [0..cCountButtons-1] of TSpeedButton;
  mBtnControl : array [0..5] of TSpeedButton;
  mLeft, i: integer;
  edBusOrder, edBusTransaction, edBusProject , edPeriod, edPDMUser, edPDMProvider, edDocQueue, edDivision, edBankAccount, edStore : TRollComboEdit;
  edDate : TDateEdit;
  lblBusOrder, lblBusTransaction, lblBusProject , lblDate, lblPeriod, lblPDMUser, lblPDMProvider, lblDocQueue, lblDivision, lblBankAccount, lblStore : TLabel;
  lcbBusOrder, lcbBusTransaction, lcbBusProject, lcbPeriod, lcbPDMUser, lcbPDMProvider, lcbDocQueue, lcbDivision, lcbBankAccount, lcbStore : TComboBevel;
  splHorizontal: TSplitter;
begin
  CFxProfiler.EnterProc('postprovider', 'CreateForm');
  pnGrid := TPanel.Create(ASite);
  splHorizontal := TSplitter.Create(ASite);
  pnGridContent := TPanel.Create(ASite);
  pnGridContentControl := TPanel.Create(ASite);
  pnLeft := TPanel.Create(ASite);
  pnLeft2 := TPanel.Create(ASite);
  pnRight := TPanel.Create(ASite);
  pnBottom := TPanel.Create(ASite);
  pnBottomRight := TPanel.Create(ASite);

  dsHeader := TDataSource.Create(ASite);
  with dsHeader do begin
    Name := cdsHeaderData;
    DataSet := TMemoryDataset.Create(ASite);
    PrefillHeaderDataSetFileds(DataSet);
  end;

  dsRows := TDataSource.Create(ASite);
  with dsRows do begin
    Name := cdsPackagesData;
    DataSet := TMemoryDataset.Create(ASite);
    PrefillPackagesDataSetFileds(DataSet);
  end;

  dsContent := TDataSource.Create(ASite);
  with dsContent do begin
    Name := cdsContent;
    DataSet := TMemoryDataset.Create(ASite);
    PrefillContentDataSetFileds(DataSet);
  end;

  dsRows.DataSet.Tag := ObjToInt(dsContent.DataSet);
  dsContent.DataSet.Tag := ObjToInt(dsRows.DataSet);


  //základní konstrukce
  begin
  (*
  with pnLeft2 do begin
    Name := 'pnLeft2';
    Caption := '';
    Parent := APanel;
    Left := 0;
    Top := 0;
    Width := 15;
    Height := 125;
    Align := alTop;
    BevelOuter := bvNone;
    TabOrder := 0;
    AutoSize := true;
  end;
  *)


  with pnLeft do begin
    Name := 'pnLeft';
    Caption := '';
    Parent := APanel;
    Left := 20;
    Top := 0;
    Width := 800;
    Height := 400;
    Align := alTop;
    BevelOuter := bvLowered;
    TabOrder := 0;
    AutoSize := true;
  end;

  with pnRight do begin
    Name := 'pnRight';
    Caption := '';
    Parent := APanel;
    Left := 341;
    Align := alClient;
    BevelOuter := bvLowered;
    TabOrder := 0;
    AutoSize := true;
  end;




  lblDocQueue := TLabel.Create(ASite);
  with lblDocQueue do begin
    Parent := pnLeft;
    Name := clblDocQueue;
    Left := cLeft + cLeftCol;
    Top := cTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := 'Řada: ';
  end;

  lcbDocQueue:= TComboBevel.Create(ASite);
  with lcbDocQueue do begin
    Parent:= pnLeft;
    Name := clcbDocQueue;
    Left:= cLeftlcb;
    Top:= lblDocQueue.Top+cMinusLcb + cLeftCol;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edDocQueue:= TRollComboEdit.Create(ASite);
  with edDocQueue do begin
    Parent:= pnLeft;
    Name := cedDocQueue;
    ClassID:= Roll_DocQueues;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDDocQueue;
    ForcedField:= True;
    Prefilling:= pmNone;
    TextField:= 'CODE';  // položka podle které se bude vyhledávat
    Top:= lblDocQueue.Top+cMinusEd;
    Left:= lblDocQueue.Left + lblDocQueue.Width + cPlusLeft +cLeftCol;
    Width:= cEdWidth;
    Parameters.Add('FilterDocumentType=P0');
    ConnectedControl:= lcbDocQueue;
    ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 4;
  end;

  lblPeriod := TLabel.Create(ASite);
  with lblPeriod do begin
    Parent := pnLeft;
    Name := clblPeriod;
    Left := cLeft+cLeftCol;
    Top := lblDocQueue.Top + cPlusTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := lng_frm_Period;
  end;

  lcbPeriod:= TComboBevel.Create(ASite);
  with lcbPeriod do begin
    Parent:= pnLeft;
    Name := clcbPeriod;
    Left:= cLeftlcb+cLeftCol;
    Top:= lblPeriod.Top+cMinusLcb;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edPeriod:= TRollComboEdit.Create(ASite);
  with edPeriod do begin
    Parent:= pnLeft;
    Name := cedPeriod;
    ClassID:= Roll_Periods;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDPeriod;
    ForcedField:= True;
    Prefilling:= pmNone;
    TextField:= 'CODE';  // položka podle které se bude vyhledávat
    Top:= lblPeriod.Top+cMinusEd;
    Left:= lblPeriod.Left + lblPeriod.Width + cPlusLeft+cLeftCol;
    Width:= cEdWidth;
    ConnectedControl:= lcbPeriod;
    ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 5;
  end;


  lblDate := TLabel.Create(ASite);
  with lblDate do begin
    Parent := pnLeft;
    Name := clblDate;
    Left := cLeft+cLeftCol;
    Top := lblPeriod.Top + cPlusTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := lng_frm_Date;
  end;

  edDate:= TDateEdit.Create(ASite);
  with edDate do begin
    Parent:= pnLeft;
    Name := cedDate;
    DataSource := dsHeader;
    DataField := cFDDate;
    Top:= lblDate.Top+cMinusEd;
    Left:= lblDate.Left + lblDate.Width + cPlusLeft+cLeftCol;
    Width:= cEdWidth;
    TabOrder := 6;
  end;

  lblPDMUser := TLabel.Create(ASite);
  with lblPDMUser do begin
    Parent := pnLeft;
    Name := clblPDMUser;
    Left := cLeft+cLeftCol;
    Top := lblDate.Top + cPlusTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := lng_frm_sender;
  end;

  lcbPDMUser := TComboBevel.Create(ASite);
  with lcbPDMUser do begin
    Parent:= pnLeft;
    Name := clcbPDMUser;
    Left:= cLeftlcb+cLeftCol;
    Top:= lblPDMUser.Top+cMinusLcb;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edPDMUser:= TRollComboEdit.Create(ASite);
  with edPDMUser do begin
    Parent:= pnLeft;
    Name := cedPDMUser;
    ClassID:= Roll_PDMUsers;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDPDMUser;
    ForcedField:= True;
    Prefilling:= pmNone;
    Top:= lblPDMUser.Top+cMinusEd;
    Left:= lblPDMUser.Left + lblPDMUser.width + cPlusLeft+cLeftCol;
    Width:= cEdWidth;
    TextField:= 'PersonName';
    ConnectedControl:= lcbPDMUser;
    ConnectedControlField:= 'PersonName';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 7;
  end;

  lblDivision := TLabel.Create(ASite);
  with lblDivision do begin
    Parent := pnLeft;
    Name := clblDivision;
    Left := cLeft+cLeftCol;
    Top := lblPDMUser.Top + cPlusTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := lng_frm_division;
  end;

  lcbDivision:= TComboBevel.Create(ASite);
  with lcbDivision do begin
    Parent:= pnLeft;
    Name := clcbDivision;
    Left:= cLeftlcb+cLeftCol;
    Top:= lblDivision.Top+cMinusLcb;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edDivision:= TRollComboEdit.Create(ASite);
  with edDivision do begin
    Parent:= pnLeft;
    Name := cedDivision;
    ClassID:= Roll_Divisions;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDDivision;
    ForcedField:= True;
    Prefilling:= pmNone;
    TextField:= 'CODE';  // položka podle které se bude vyhledávat
    Top:= lblDivision.Top+cMinusEd;
    Left:= lblDivision.Left + lblDivision.width + cPlusLeft;
    Width:= cEdWidth;
    ConnectedControl:= lcbDivision;
    ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 8;
    SecurityMask := cSecurityMask_Division;
  end;

  lblPDMProvider := TLabel.Create(ASite);
  with lblPDMProvider do begin
    Parent := pnLeft;
    Name := clblPDMProvider;
    Left := cLeft+cLeftCol2; //cLeftCol2
    Top := cTop;
    Width := cLblWidth+120;
    Height := 13;
    AutoSize := true;
    Caption := lng_frm_PostProvider;
  end;

  lcbPDMProvider := TComboBevel.Create(ASite);
  with lcbPDMProvider do begin
    Parent:= pnLeft;
    Name := clcbPDMProvider;
    Left:= cLeftLcb+cLeftCol2;
    Top:= lblPDMProvider.Top+cMinusLcb;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edPDMProvider:= TRollComboEdit.Create(ASite);
  with edPDMPRovider do begin
    Parent:= pnLeft;
    Name := cedPDMProvider;
    ClassID:= Roll_PDMPostProviders;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDPDMProvider;
    ForcedField:= True;
    Prefilling:= pmNone;
    TextField:= 'CODE';  // položka podle které se bude vyhledávat
    Top:= lblPDMProvider.Top+cMinusEd;
    Left:= lblPDMProvider.Left + lblPDMProvider.width + cPlusLeft;
    Width:= cEdWidth;
    ConnectedControl:= lcbPDMProvider;
    ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 9;
    OnEnter := @edPDMProviderOnEnter;
  end;

  lblStore := TLabel.Create(ASite);
  with lblStore do begin
    Parent := pnLeft;
    Name := clblStore;
    Left := cLeft+cLeftCol2;
    Top := lblPDMProvider.Top + cPlusTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := lng_frm_Store;
  end;

  lcbStore := TComboBevel.Create(ASite);
  with lcbStore do begin
    Parent:= pnLeft;
    Name := clcbStore;
    Left:= cLeftLcb+cLeftCol2;
    Top:= lblStore.Top+cMinusLcb;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edStore := TRollComboEdit.Create(ASite);
  with edStore do begin
    Parent:= pnLeft;
    Name := cedStore;
    ClassID:= Roll_Stores;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDStore;
    ForcedField:= True;
    Prefilling:= pmNone;
    TextField:= 'Code';  // položka podle které se bude vyhledávat
    Top:= lblStore.Top+cMinusEd;
    Left:= lblStore.Left + lblStore.width + cPlusLeft;
    Width:= cEdWidth;
    ConnectedControl:= lcbStore;
    ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 10;
    SecurityMask := cSecurityMask_Store;
  end;

  lblBankAccount := TLabel.Create(ASite);
  with lblBankAccount do begin
    Parent := pnLeft;
    Name := clblBankAccount;
    Left := cLeft+cLeftCol2;
    Top := lblStore.Top + cPlusTop;
    Width := cLblWidth;
    Height := 13;
    AutoSize := false;
    Caption := lng_frm_BankAccount;
  end;

  lcbBankAccount := TComboBevel.Create(ASite);
  with lcbBankAccount do begin
    Parent:= pnLeft;
    Name := clcbBankAccount;
    Left:= cLeftLcb+cLeftCol2;
    Top:= lblBankAccount.Top+cMinusLcb;
    Width:= cLcbWidth;
    Caption := '';
  end;

  edBankAccount := TRollComboEdit.Create(ASite);
  with edBankAccount do begin
    Parent:= pnLeft;
    Name := cedBankAccount;
    ClassID:= Roll_BankAccounts;
    Complete:= True;
    DataSource := dsHeader;
    DataField := cFDBankAccount;
    ForcedField:= True;
    Prefilling:= pmNone;
    TextField:= 'Name';  // položka podle které se bude vyhledávat
    Top:= lblBankAccount.Top+cMinusEd;
    Left:= lblBankAccount.Left + lblBankAccount.width + cPlusLeft;
    Width:= cEdWidth;
    ConnectedControl:= lcbBankAccount;
    ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    Text := '';
    TabOrder := 11;
    SecurityMask := cSecurityMask_BankAccount;  //řešená problému s použitím chráněného objektu.
  end;

  if (ASite.CompanyCache.BusOrdersUsage <> cDontUseBusObjects) then begin
    lblBusOrder := TLabel.Create(ASite);
    with lblBusOrder do begin
      Parent := pnLeft;
      Name := clblBusOrder;
      Left := cLeft+cLeftCol2;
      Top := lblBankAccount.Top + cPlusTop;
      Width := cLblWidth;
      Height := 13;
      AutoSize := false;
      Caption := lng_frm_BusOrder;
    end;

    lcbBusOrder := TComboBevel.Create(ASite);
    with lcbBusOrder do begin
      Parent:= pnLeft;
      Name := clcbBusOrder;
      Left:= cLeftLcb+cLeftCol2;
      Top:= lblBusOrder.Top+cMinusLcb;
      Width:= cLcbWidth;
      Caption := '';
    end;

    edBusOrder:= TRollComboEdit.Create(ASite);
    with edBusOrder do begin
      Parent:= pnLeft;
      Name := cedBusOrder;
      ClassID:= Roll_BusOrders;
      Complete:= True;
      DataSource := dsHeader;
      DataField := cFDBusOrder;
      ForcedField:= True;
      Prefilling:= pmNone;
      TextField:= 'CODE';  // položka podle které se bude vyhledávat
      Top:= lblBusOrder.Top+cMinusEd;
      Left:= lblBusOrder.Left + lblBusOrder.width + cPlusLeft;
      Width:= cEdWidth;
      ConnectedControl:= lcbBusOrder;
      ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
      Parameters.Add('FilterOnlyOpened=1');
      Text := '';
      TabOrder := 12;
    end;
  end;

  if (ASite.CompanyCache.BusTransactionsUsage <> cDontUseBusObjects) then begin
    lblBusTransaction := TLabel.Create(ASite);
    with lblBusTransaction do begin
      Parent := pnLeft;
      Name := clblBusTransaction;
      Left := cLeft+cLeftCol2;
      if ASite.FindChildControl(clblBusOrder) <> nil then
        Top := lblBusOrder.Top + cPlusTop
      else
        Top := lblBankAccount.Top + cPlusTop;
      Width := cLblWidth;
      Height := 13;
      AutoSize := false;
      Caption := lng_frm_BusProject;
    end;

    lcbBusTransaction := TComboBevel.Create(ASite);
    with lcbBusTransaction do begin
      Parent:= pnLeft;
      Name := clcbBusTransaction;
      Left:= cLeftLcb+cLeftCol2;
      Top:= lblBusTransaction.Top+cMinusLcb;
      Width:= cLcbWidth;
      Caption := '';
    end;

    edBusTransaction:= TRollComboEdit.Create(ASite);
    with edBusTransaction do begin
      Parent:= pnLeft;
      Name := cedBusTransaction;
      ClassID:= Roll_BusTransactions;
      Complete:= True;
      DataSource := dsHeader;
      DataField := cFDBusTransaction;
      ForcedField:= True;
      Prefilling:= pmNone;
      TextField:= 'CODE';  // položka podle které se bude vyhledávat
      Top:= lblBusTransaction.Top+cMinusEd;
      Left:= lblBusTransaction.Left + lblBusTransaction.width + cPlusLeft;
      Width:= cEdWidth;
      ConnectedControl:= lcbBusTransaction;
      ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
      Parameters.Add('FilterOnlyOpened=1');
      Text := '';
      TabOrder := 13;
    end;
  end;

  //todo az bude na BO odeslana posta BusProject
(*
  if (ASite.CompanyCache.BusProjectsUsage <> cDontUseBusObjects) then begin
    lblBusProject := TLabel.Create(ASite);
    with lblBusProject do begin
      Parent := pnLeft;
      Name := clblBusProject;
      Left := cLeft;
      Top := lblBusTransaction.Top + cPlusTop;
      Width := cLblWidth;
      Height := 13;
      AutoSize := false;
      Caption := 'Projekt: ';
    end;

    lcbBusProject := TComboBevel.Create(ASite);
    with lcbBusProject do begin
      Parent:= pnLeft;
      Name := clcbBusProject;
      Left:= cLeftLcb;
      Top:= lblBusProject.Top+cMinusLcb;
      Width:= cLcbWidth;
      Caption := '';
    end;

    edBusProject:= TRollComboEdit.Create(ASite);
    with edBusProject do begin
      Parent:= pnLeft;
      Name := cedBusProject;
      ClassID:= Roll_BusProjects;
      Complete:= True;
      DataSource := dsHeader;
      DataField := cFDBusProject;
      ForcedField:= True;
      Prefilling:= pmNone;
      TextField:= 'CODE';  // položka podle které se bude vyhledávat
      Top:= lblBusProject.Top+cMinusEd;
      Left:= lblBusProject.Left + lblBusProject.width + cPlusLeft;
      Width:= cEdWidth;
      ConnectedControl:= lcbBusProject;
      ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
      Parameters.Add('FilterOnlyOpened=1');
      Text := '';
      TabOrder := 22;
    end;
  end;
*)
  end;


  with pnGrid do begin
    Name := 'pnGrid';
    Caption := '';
    Parent := pnRight;
    Left := 300;
    Top := 0;
    Width := 811;
    Height := 41;
    Align := alClient;
    BevelOuter := bvNone;
    TabOrder := 30;
    AutoSize := true;
  end;

  //Nechce se mu fungovat správně.
  with splHorizontal do
  begin
    Name := 'splHorizontal';
    Parent := pnRight;
    //Top := 500;
    Align := alBottom;
    MinSize := 80;
  end;
  splHorizontal.Visible := False;

  with pnBottom do begin
    Name := 'pnBottom';
    Caption := '';
    Parent := pnRight;
    Left := 0;
    AutoSize := true;
    Height := 41;
    Align := alBottom;
    BevelOuter := bvNone;
    TabOrder := 98;
  end;

  grdData := CreateMultiGrid(ASite, pnGrid);
  grdData.DataSource := dsRows;



  with pnGridContent do begin
    Name := 'pnGridContent';
    Caption := '';
    //Parent := pnRight;
    Parent := APanel;
    Left := 300;
    Top := 0;
    Width := 811;
    Height := 200;
    Align := alBottom;
    BevelOuter := bvNone;
    TabOrder := 30;
    //AutoSize := true;
  end;

  grdContent := CreateMultiGridContent(ASite, pnGridContent);
  grdContent.DataSource := dsContent;

  with pnGridContentControl do begin
    Name := 'pnGridContentControl';
    Caption := '';
    Parent := pnGridContent;
    Left := 300;
    Top := 0;
    Width := 811;
    Height := 41;
    Align := alBottom;
    BevelOuter := bvNone;
    TabOrder := 30;
    AutoSize := true;
  end;


  mLeft:= 1;
  for i:= 0 to 5 do begin
    mBtnControl[i]:= TSpeedButton.Create(ASite);
    mBtnControl[i].Parent:= pnGridContentControl;
    mBtnControl[i].Left:= mLeft;
    mBtnControl[i].Top:= 1;
    mBtnControl[i].Height:= 25;
    mBtnControl[i].Width:= 25;
    mBtnControl[i].Caption:= '';
    mBtnControl[i].Flat:= True;
    mBtnControl[i].Tag:= ObjToInt(dsContent.DataSet);
    if i = 0 then begin
      mBtnControl[i].ImageListName := 'DBNavigatorImages';
      mBtnControl[i].ImageIndex := i;
      mBtnControl[i].onClick:= @btnPDFirstClick;
      mBtnControl[i].Name:= 'btnPDFirstContent';
    end;
    if i = 1 then begin
      mBtnControl[i].ImageListName := 'DBNavigatorImages';
      mBtnControl[i].ImageIndex := i;
      mBtnControl[i].onClick:= @btnPDPriorClick;
      mBtnControl[i].Name:= 'btnPDPriorContent';
    end;
    if i = 2 then begin
      mBtnControl[i].ImageListName := 'DBNavigatorImages';
      mBtnControl[i].ImageIndex := i;
      mBtnControl[i].onClick:= @btnPDNextClick;
      mBtnControl[i].Name:= 'btnPDNextContent';
    end;
    if i = 3 then begin
      mBtnControl[i].ImageListName := 'DBNavigatorImages';
      mBtnControl[i].ImageIndex := i;
      mBtnControl[i].onClick:= @btnPDLastClick;
      mBtnControl[i].Name:= 'btnPDLastContent';
    end;
    if i = 4 then begin
      mBtnControl[i].Visible := true;
      mBtnControl[i].Width:= 80;
      mBtnControl[i].Caption:= lng_frmbtn_Add;
      mBtnControl[i].onClick:= @btnPDAddClick;
      mBtnControl[i].Name:= 'btnPDAddContent';
    end;
    if i = 5 then begin
      mBtnControl[i].Width:= 80;
      mBtnControl[i].Caption:= lng_frmbtn_Delete;
      mBtnControl[i].onClick:= @btnPDDeleteClick;
      mBtnControl[i].Name:= 'btnPDDeleteContent';
    end;
    mLeft:= mLeft + mBtnControl[i].Width;
  end;


  //-------------------


  with pnBottomRight do begin
    Name := 'pnBottomRight';
    Caption := '';
    Parent := pnBottom;
    Left := 720;
    Top := 0;
    Width := 350;
    Height := 41;
    Align := alRight;
    BevelOuter := bvNone;
    TabOrder := 31;
  end;

  mLeft:= 1;
  for i:= 0 to cCountButtons-1 do begin
    if i in [4,5,7,8] then continue;

    mBtn[i]:= TSpeedButton.Create(ASite);
    mBtn[i].Parent:= pnBottom;
    mBtn[i].Left:= mLeft;
    mBtn[i].Top:= 1;
    mBtn[i].Height:= 25;
    mBtn[i].Width:= 25;
    mBtn[i].Caption:= '';
    mBtn[i].Flat:= True;
    mBtn[i].Tag:= ObjToInt(dsRows.DataSet);
    if i = 0 then begin
      mBtn[i].ImageListName := 'DBNavigatorImages';
      mBtn[i].ImageIndex := i;
      mBtn[i].onClick:= @btnPDFirstClick;
      mBtn[i].Name:= 'btnPDFirst';
    end;
    if i = 1 then begin
      mBtn[i].ImageListName := 'DBNavigatorImages';
      mBtn[i].ImageIndex := i;
      mBtn[i].onClick:= @btnPDPriorClick;
      mBtn[i].Name:= 'btnPDPrior';
    end;
    if i = 2 then begin
      mBtn[i].ImageListName := 'DBNavigatorImages';
      mBtn[i].ImageIndex := i;
      mBtn[i].onClick:= @btnPDNextClick;
      mBtn[i].Name:= 'btnPDNext';
    end;
    if i = 3 then begin
      mBtn[i].ImageListName := 'DBNavigatorImages';
      mBtn[i].ImageIndex := i;
      mBtn[i].onClick:= @btnPDLastClick;
      mBtn[i].Name:= 'btnPDLast';
    end;
  (*  if i = 4 then begin
      mBtn[i].Width:= 80;
      mBtn[i].Caption:= 'V&ymazat';
      mBtn[i].onClick:= @btnPDDeleteClick;
      mBtn[i].Name:= 'btnPDDelete';
    end;

    if i = 5 then begin
      mBtn[i].Visible := False;
      mBtn[i].Width:= 80;
      mBtn[i].Caption:= 'Př&idat';
      mBtn[i].onClick:= @btnPDAddClick;
      mBtn[i].Name:= 'btnPDAdd';
    end; *)
    if i = 6 then begin
      mBtn[i].Align := alRight;
      mBtn[i].Parent:= pnBottomRight;
      mBtn[i].Left:= 0;
      mBtn[i].Width:= 70;
      mBtn[i].Name := 'btnPDShowPackages';
      mBtn[i].Caption:= lng_frmbtn_Show;
      mBtn[i].Hint := lng_frmbtnhint_Show;
      mBtn[i].onClick:= @btnPDShowPackagesClick;
    end;
  (*  if i = 7 then begin
      mBtn[i].Width:= 100;
      mBtn[i].Name := 'btnPDRecountWeigth';
      mBtn[i].Caption:= '&Převzít hmotnost';
      mBtn[i].Hint := 'Převezme hmotnost ze zdrojových dokladů pro označené doklady.';
      mBtn[i].onClick:= @btnPDRecountWeightClick;
    end;
    if i = 8 then begin
      mBtn[i].Width:= 100;
      mBtn[i].Name := 'btnPDMassChange';
      mBtn[i].Caption:= '&Hromadná oprava';
      mBtn[i].Hint := 'Hromadně opraví označený(é) záznam(y).';
      mBtn[i].onClick:= @btnPDMassChangeClick;
    end;
    if i = 8 then begin
      mBtn[i].Width:= 100;
      mBtn[i].Name := 'btnPDTransportCosts';
      mBtn[i].Caption:= 'Cena přepravy';
      mBtn[i].Hint := 'Zjistí cenu přepravy';
      mBtn[i].onClick:= @btnPDTransportCostsClick;
    end;  *)
    if i = 9 then begin
      mBtn[i].Align := alRight;
      mBtn[i].Parent:= pnBottomRight;
      mBtn[i].Left:= 0;
      mBtn[i].Width:= 70;
      mBtn[i].Name := 'btnPDCreatePackages';
      mBtn[i].Caption:= lng_frmbtn_Create;
      mBtn[i].Hint := lng_frmbtnhint_Create;
      mBtn[i].onClick:= @btnPDCreatePackagesClick;
    end;
    if i = 10 then begin
      mBtn[i].Align := alRight;
      mBtn[i].Parent:= pnBottomRight;
      mBtn[i].Width:= 70;
      mBtn[i].Left:= 70 +5;
      mBtn[i].Name := 'btnPDExportPackages';
      mBtn[i].Caption:= lng_frmbtn_Export;
      mBtn[i].Hint := lng_frmbtnhint_Export;
      mBtn[i].onClick:= @btnPDExportPackagesClick;
    end;
     if i = 11 then begin
      mBtn[i].Align := alRight;
      mBtn[i].Parent:= pnBottomRight;
      mBtn[i].Width:= 70;
      mBtn[i].Left:= 75+75;
      mBtn[i].Name := 'btnPDPrintPackages';
      mBtn[i].Caption:= lng_frmbtn_Print;
      mBtn[i].Hint := lng_frmbtnhint_Print;
      mBtn[i].onClick:= @btnPDPrintPackagesClick;
    end;
    mLeft:= mLeft + mBtn[i].Width;
  end;

  SetUserButtonEvent(ASite,pnBottom, dsRows.DataSet, dsHeader.DataSet, dsContent.DataSet, mLeft);

  CFxProfiler.ExitProc('postprovider', 'CreateForm');
end;

procedure PrefillPackagesDataSetFileds(var APackagesDataSet: TDataSet);
var
  i: integer;
begin
  CFxProfiler.EnterProc('postprovider', 'PrefillPackagesDataSetFileds');
  APackagesDataSet.Fields.Clear;
  APackagesDataSet.FieldDefs.Add(cFDID, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDDisplayNumber, ftWideString, 20);
  APackagesDataSet.FieldDefs.Add(cFDVarSymbol, ftWideString, 20);
  APackagesDataSet.FieldDefs.Add(cFDAmount, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDCashOnDelivery, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDCount, ftInteger, 0);
  APackagesDataSet.FieldDefs.Add(cFDContentType, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDTargetAddressType, ftInteger, 0);
  APackagesDataSet.FieldDefs.Add(cFDTargetAddressTypeSen, ftInteger, 0);
  APackagesDataSet.FieldDefs.Add(cFDFirm_ID, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDFirmOffice_ID, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDPerson_ID, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDAdrName, ftWideString, 220);
  APackagesDataSet.FieldDefs.Add(cFDAdrStreet, ftWideString, 60);
  APackagesDataSet.FieldDefs.Add(cFDAdrCity, ftWideString, 60);
  APackagesDataSet.FieldDefs.Add(cFDAdrPostCode, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDAdrCountryCode, ftWideString, 3);
  APackagesDataSet.FieldDefs.Add(cFDAdrPhoneNumber, ftWideString, 30);
  APackagesDataSet.FieldDefs.Add(cFDDocumentType, ftWideString, 2);
  APackagesDataSet.FieldDefs.Add(cFDCurrency, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDPaymentKind, ftInteger, 0);
  APackagesDataSet.FieldDefs.Add(cFDExistCount, ftInteger, 0);
  APackagesDataSet.FieldDefs.Add(cFDPickupDate, ftDate);
  APackagesDataSet.FieldDefs.Add(cFDDeliveryDate, ftDate);
  APackagesDataSet.FieldDefs.Add(cFDPickupTimeFrom, ftTime);
  APackagesDataSet.FieldDefs.Add(cFDPickupTimeTo, ftTime);
  APackagesDataSet.FieldDefs.Add(cFDDeliveryTimeFrom, ftTime);
  APackagesDataSet.FieldDefs.Add(cFDDeliveryTimeTo, ftTime);

  //B2C - adresa doručení
  APackagesDataSet.FieldDefs.Add(cFDFirm_IDSen, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDFirmOffice_IDSen, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDPerson_IDSen, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDAdrNameSen, ftWideString, 220);
  APackagesDataSet.FieldDefs.Add(cFDAdrStreetSen, ftWideString, 60);
  APackagesDataSet.FieldDefs.Add(cFDAdrCitySen, ftWideString, 60);
  APackagesDataSet.FieldDefs.Add(cFDAdrPostCodeSen, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDAdrCountryCodeSen, ftWideString, 3);
  APackagesDataSet.FieldDefs.Add(cFDAdrPhoneNumberSen, ftWideString, 30);

//pro TopTrans BB popis, počet vratných obalů
  APackagesDataSet.FieldDefs.Add(cFDMUnitNoteBack, ftWideString, 40);
  APackagesDataSet.FieldDefs.Add(cFDManipulationUnitCountBack, ftFloat, 0);

  APackagesDataSet.FieldDefs.Add(cFDTotalWeight, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDTotalWeightUnit, ftInteger, 0);
  for i:= 0 to cServiceTypeMaxCount - 1 do begin
    APackagesDataSet.FieldDefs.Add(cFDPDMServiceType+IntToStr(i), ftWideString, 10);
  end;
  APackagesDataSet.FieldDefs.Add(cFDInsurance, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDNoteForDriver, ftWideString, 57);
  APackagesDataSet.FieldDefs.Add(cFDPersonName, ftWideString, 220);
  APackagesDataSet.FieldDefs.Add(cFDPersonNameSen, ftWideString, 220);
  APackagesDataSet.FieldDefs.Add(cFDFirmBankAccount, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDServiceType, ftInteger);
  APackagesDataSet.FieldDefs.Add(cFDRelationWithIDs, ftWideString, 220);
  APackagesDataSet.FieldDefs.Add(cFDCreatedPDMIDs, ftWideString, 550);


  APackagesDataSet.Open;
  CFxProfiler.ExitProc('postprovider', 'PrefillPackagesDataSetFileds');
end;

procedure PrefillHeaderDataSetFileds(var AHeaderDataSet: TDataSet);
begin
  CFxProfiler.EnterProc('postprovider', 'PrefillHeaderDataSetFileds');
  AHeaderDataSet.Fields.Clear;
  AHeaderDataSet.FieldDefs.Add(cFDDocQueue, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDPeriod, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDPDMUser, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDDivision, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDPDMProvider, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDBankAccount, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDBusOrder, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDBusTransaction, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDBusProject, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDDate, ftDateTime, 0);
  AHeaderDataSet.FieldDefs.Add(cFDPDMProviderDriver, ftInteger, 0);
  AHeaderDataSet.FieldDefs.Add(cFDStore, ftWideString, 10);
  AHeaderDataSet.FieldDefs.Add(cFDSetting, ftWideString, 10); //Play ELE a speciál pro více tech. čísel s jedním dopravcem X_PD_Setting_ID
  AHeaderDataSet.Open;
  CFxProfiler.ExitProc('postprovider', 'PrefillHeaderDataSetFileds');
end;


(* Průnik potřebných parametrů pro základní evropskou dopravu, palet a balíků z 19082021
Weight width  Height  Length  Volume  mu_type content ADR
*)
procedure PrefillContentDataSetFileds(var APackagesDataSet: TDataSet);
begin
  CFxProfiler.EnterProc('postprovider', 'PrefillContentDataSetFileds');
  APackagesDataSet.Fields.Clear;
  APackagesDataSet.FieldDefs.Add(cFDPosindex, ftInteger);
  APackagesDataSet.FieldDefs.Add(cFDParentID, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDDisplayNumber, ftWideString, 20);
  APackagesDataSet.FieldDefs.Add(cFDWeight, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDWeightUnit, ftInteger, 0);
  APackagesDataSet.FieldDefs.Add(cFDWidth, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDHeight, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDLength, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDVolume, ftFloat, 0);
  APackagesDataSet.FieldDefs.Add(cFDManipulationUnit, ftWideString, 10);
  APackagesDataSet.FieldDefs.Add(cFDContent, ftWideString, 200);
  APackagesDataSet.FieldDefs.Add(cFDADRUnit, ftWideString, 10);
  APackagesDataSet.Open;

  SetContentEvents(APackagesDataSet);
  CFxProfiler.ExitProc('postprovider', 'PrefillContentDataSetFileds');
end;



procedure FieldTargetAddressTypeOnChange(Sender: TField);
var
  mPackagesDataset: TMemoryDataset;
  mOS: TNxCustomObjectSpace;
begin
  mPackagesDataset := TMemoryDataset(Sender.DataSet);
  mOS := TSiteForm(mPackagesDataset.Owner).BaseObjectSpace;
  SetAddress(mOS, mPackagesDataset,false);
  SetAdrName(mOS, mPackagesDataset,false);
  SetNoteForDriver(mOS, mPackagesDataset, 'Location');
end;

procedure FieldSenTargetAddressTypeOnChange(Sender: TField);
var
  mPackagesDataset: TMemoryDataset;
  mOS: TNxCustomObjectSpace;
begin
  mPackagesDataset := TMemoryDataset(Sender.DataSet);
  mOS := TSiteForm(mPackagesDataset.Owner).BaseObjectSpace;
  SetAddress(mOS, mPackagesDataset, true);
  SetAdrName(mOS, mPackagesDataset, true);
end;

procedure FieldPDMProviderOnChange(Sender: TField);
var
  mHeaderDataset: TMemoryDataset;
  mOS: TNxCustomObjectSpace;
  mGrid,mGridContent: TMultiGrid;
  mProviderBO :TNxCustomBusinessObject;
begin
  CFxProfiler.EnterProc('postprovider', 'FieldPDMProviderOnChange');
  try
    OutputDebugString('FieldPDMProviderOnChange');
    mProviderBO := nil;
    mHeaderDataset := TMemoryDataset(Sender.DataSet);
    mOS := TSiteForm(mHeaderDataset.Owner).BaseObjectSpace;
    mProviderBO := mOS.CreateObject(Class_PDMPostProvider);
    if (not NxIsEmptyOID(mHeaderDataSet.FieldByName(cFDPDMProvider).AsString)) then
      mProviderBO.Load(mHeaderDataSet.FieldByName(cFDPDMProvider).AsString,nil);
    SetPDMProviderDriver(mOS, mHeaderDataset);
    mGrid := TMultiGrid(TSiteForm(mHeaderDataset.Owner).FindChildControl(cgrdPackagesData));
    mGridContent := TMultiGrid(TSiteForm(mHeaderDataset.Owner).FindChildControl(cgrdContent));
    HideColumnContent(mGridContent, mHeaderDataSet.FieldByName(cFDPDMProviderDriver).AsInteger, mProviderBO );
    RunScript(mOS, mGrid.DataSource.DataSet, mHeaderDataSet, TDataSet(IntToObj(mGrid.DataSource.DataSet.Tag)),cScriptAfterProviderChange);
  finally
    if mProviderBO <> nil then
      mProviderBO.Free;
  end;
  CFxProfiler.ExitProc('postprovider', 'FieldPDMProviderOnChange');
end;



procedure HideColumnContent(var AGrid: TMultiGrid; const ADriver: integer; APostProviderBO : TNxCustomBusinessObject = nil);
var
  i,j: integer;
  mIsPaletteProvider : Boolean;
begin
  CFxProfiler.EnterProc('postprovider', 'HideColumn');
  mIsPaletteProvider := False;

  for i:= 0 to cLayoutContentCount - 1 do begin
    //přijde 0000000000
    if Assigned(APostProviderBO) then
    if not CFxOID.IsEmptyOrFull(APostProviderBO.OID) then
    begin
      mIsPaletteProvider := APostProviderBO.GetFieldValueAsBoolean('X_PD_IsPaletteProvider');
      AGrid.ColumnByName(ccolManipulationUnit+IntToStr(i)).Visible := mIsPaletteProvider;
      //ADR - Odkomentovat
      //AGrid.ColumnByName(ccolADRUnit+IntToStr(i)+IntToStr(j)).Visible := (ADriver = cDriverBalikobot);
    end;
  end;
  CFxProfiler.ExitProc('postprovider', 'HideColumn');
end;

procedure SetPDMProviderDriver(AOS: TNxCustomObjectSpace; var AHeaderDataSet: TDataSet);
begin
  AHeaderDataSet.FieldByName(cFDPDMProviderDriver).AsInteger := GetPDMProviderDriver(AOS, AHeaderDataSet.FieldByName(cFDPDMProvider).AsString);
end;

procedure btnPDFirstClick(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).First;
end;

procedure btnPDPriorClick(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Prior;
end;

procedure btnPDNextClick(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Next;
end;

procedure btnPDLastClick(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Last;
end;

procedure btnPDAddClick(Sender: TSpeedButton);
begin
  AddContentRow(TMemoryDataset(IntToObj(Sender.Tag)) );
  // TMultiGrid(sender.Owner.FindComponent(cgrdPackagesData)).DataSource.DataSet );
end;

procedure btnPDDeleteClick(Sender: TSpeedButton);
begin
  if not TMemoryDataset(IntToObj(Sender.Tag)).Eof then
    TMemoryDataset(IntToObj(Sender.Tag)).Delete;
end;


procedure ActKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  mGrd: TMultiGrid;
begin
  mGrd := nil;
  if (Key = VK_DOWN) and (not(ssAlt in shift)) then
  begin
    //focusnout hmotnost by bylo hezké
    if Tcomponent(sender).owner is TMultiGrid then
    begin
      mGrd := TMultiGrid(Tcomponent(sender).owner);
      if mGrd.DataSource.DataSet.RecNo = mGrd.DataSource.DataSet.RecordCount then
        AddContentRow(TMemoryDataset( mGrd.DataSource.DataSet ) );
    end;
  end;
end;




procedure btnPDTransportCostsClick(Sender : TControl);
var
  mErrors, mSoftErrors, mCreatedPDM : TStringList;
  mMemo : TForm;
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet,mContentDataSet: TMemoryDataset;
  mAuto, mPDMProviderID: String;
  mRes, i : Integer;
  mBO: TNxCustomBusinessObject;
begin
  mPDMProviderID :='';
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mPackagesDataSet := TMemoryDataset(IntToObj(Sender.Tag));
  mHeaderDataSet := TMemoryDataset(TDataSource(mSite.FindComponent(cdsHeaderData)).DataSet);
  mContentDataSet := TMemoryDataset( IntToObj(mPackagesDataSet.Tag) );
  mErrors := TStringList.Create;
  mCreatedPDM:= TStringList.Create;
  try
    mSoftErrors := TStringList.Create;
    try
      //Omezení více zásilek na jeden doklad
      {if ExistPDMReceivedDoc(Sender) <> '' then
      begin
        mErrors.Add(lng_msg_ExistPackage);
        mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+mErrors.Text);
        try
          mMemo.ShowModal(mSite);
        finally
          mMemo.Free;
        end;
        Exit;
      end;}

      ValidatePackages(mPackagesDataset, mHeaderDataSet, mContentDataSet, mOS, mErrors, mSoftErrors);
      if Trim(mErrors.Text)<> '' then begin
        mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+mErrors.Text);
        try
          mMemo.ShowModal(mSite);
        finally
          mMemo.Free;
        end;
        Exit;
      end;
      if Trim(mSoftErrors.Text)<> '' then begin
        mMemo := CreateMemoMessage(mSite, lng_msg_Continue+cCrLf+ mSoftErrors.Text, true);
        try
          if (mMemo.ShowModal(mSite) <> mrYes) then
            Exit;
        finally
          mMemo.Free;
        end;
      end;
      mErrors.Clear;
      mSoftErrors.Clear;
      try
        CreatePackages(mPackagesDataset, mHeaderDataSet,mContentDataSet, mOS, mErrors, mSoftErrors,mCreatedPDM);
        if (not NxIsEmptyOID(mHeaderDataSet.FieldByName(cFDPDMProvider).AsString)) then
          mPDMProviderID := mHeaderDataSet.FieldByName(cFDPDMProvider).AsString;
        TransportcostsPackages(mSite, mCreatedPDM, GetProviderDriver(mOS, mPDMProviderID ), 0);
        if Trim(mErrors.Text)<> '' then begin
          mMemo := CreateMemoMessage(mSite, lng_msg_error +cCrLf+mErrors.Text);
          try
            mMemo.ShowModal(mSite);
          finally
            mMemo.Free;
          end;
          Exit;
        end
        else
        begin

        end;
      finally
        //Smažu dočasné BO
        for i := 0 to mCreatedPDM.Count -1 do
        begin
          try
            mBO := mOS.CreateObject(Class_PDMIssuedDoc);
            if mBO.Test(mCreatedPDM[i]) then
            begin
              mBO.Load(mCreatedPDM[i],nil);
              mBO.Delete;
              OutputDebugString('Dočasný soubor PDMIssuedDoc byl odstraněn.');
            end;
          finally
            mBO.free;
          end;
        end;

      end;
    finally
      mSoftErrors.Free;
    end;
  finally
    mErrors.Free;
    mCreatedPDM.free;
  end;
end;


procedure btnPDCreatePackagesClick(Sender : TControl);
var
  mErrors, mSoftErrors,mCreatedPDM : TStringList;
  mMemo : TForm;
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet, mContentDataSet: TMemoryDataset;
  mAuto: String;
  mRes : Integer;
begin
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mPackagesDataSet := TMemoryDataset(IntToObj(Sender.Tag));
  mHeaderDataSet := TMemoryDataset(TDataSource(mSite.FindComponent(cdsHeaderData)).DataSet);
  mContentDataSet := TMemoryDataset( IntToObj(mPackagesDataSet.Tag) );
  mErrors := TStringList.Create;
  mCreatedPDM:= TStringList.Create;
  try
    mSoftErrors := TStringList.Create;
    try
      //Omezení více zásilek na jeden doklad
      {if ExistPDMReceivedDoc(Sender) <> '' then
      begin
        mErrors.Add(lng_msg_ExistPackage);
        mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+mErrors.Text);
        try
          mMemo.ShowModal(mSite);
        finally
          mMemo.Free;
        end;
        Exit;
      end;}

      ValidatePackages(mPackagesDataset, mHeaderDataSet,mContentDataSet, mOS, mErrors, mSoftErrors);
      if Trim(mErrors.Text)<> '' then begin
        mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+mErrors.Text);
        try
          mMemo.ShowModal(mSite);
        finally
          mMemo.Free;
        end;
        Exit;
      end;
      if Trim(mSoftErrors.Text)<> '' then begin
        mMemo := CreateMemoMessage(mSite, lng_msg_Continue+cCrLf+ mSoftErrors.Text, true);
        try
          if (mMemo.ShowModal(mSite) <> mrYes) then
            Exit;
        finally
          mMemo.Free;
        end;
      end;
      mErrors.Clear;
      mSoftErrors.Clear;
      CreatePackages(mPackagesDataset, mHeaderDataSet,mContentDataSet, mOS, mErrors, mSoftErrors,mCreatedPDM);
      //Uložil do datasetu
      if mCreatedPDM.Count > 0 then
      begin
        mPackagesDataset.Edit;
        mPackagesDataset.FieldByName(cFDCreatedPDMIDs).AsString := mCreatedPDM.Text;
        mPackagesDataset.Post;
      end;

      if Trim(mErrors.Text)<> '' then begin
        mMemo := CreateMemoMessage(mSite, lng_msg_error+cCrLf+mErrors.Text);
        try
          mMemo.ShowModal(mSite);
        finally
          mMemo.Free;
        end;
        Exit;
      end else begin
        //todo PEMI: Doplněno o dotaz na okamžitý export. (Po exportu se stáhne u BB, DPD štítek a může následovat tisk na štítkové tiskárně. !Podle konzultanta!)
        //NxShowSimpleMessage('Balíky byly úspěšně vytvořené.', mSite);
        //todo PEMI: Doplněno o dotaz na okamžitý export. (Po exportu se stáhne u BB, DPD štítek a může následovat tisk na štítkové tiskárně. !Podle konzultanta!)
        //teoretikcy nutno omezit na určité dopravce.
        mAuto := GetExtrasSetings('baliky','AutoExport','');
        if mAuto = '' then
        begin
        //  mRes := NxMessageBox('Tvorba dokladu odeslané pošty','Balíky byly úspěšně vytvořeny. Přejete si exportovat data?',mdConfirm,mdbYesNoCancel,mrYes,nil,False,mSite)
        end
        else
          if mAuto = 'N' then
          begin
            //nic se neprovede
          end
          else
          begin
            TSpeedButton(mSite.FindComponent('btnPDExportPackages')).Click;

            //AUTOPRINT
            mAuto := GetExtrasSetings('baliky','AutoPrint','');
            if mAuto = '' then
              mRes := NxMessageBox(lng_msgtit_CreatePackage,lng_msg_CreatePackage,mdConfirm,mdbYesNoCancel,mrYes,nil,False,mSite)
            else
              if mAuto = 'N' then
              begin
                //nic se neprovede
              end
              else
              begin
                TSpeedButton(mSite.FindComponent('btnPDPrintPackages')).Click;
              end;
          end;
      end;
    finally
      mSoftErrors.Free;
    end;
  finally
    mErrors.Free;
    mCreatedPDM.Free;
  end;
end;

procedure btnPDShowPackagesClick(Sender : TControl);
var
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
begin
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mIDs := TStringList.Create;
  try
    mDataSet := TMemoryDataset(IntToObj(Sender.Tag));
    mDataSet.DisableControls;
    try
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(TRollSiteForm(mSite).SiteParams) then begin
        if TRollSiteForm(mSite).SiteParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite) then
          mDocumentType := TRollSiteForm(mSite).SiteParams.ParamAsString(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite, '');
      end else begin
        mDocumentType := mDataSet.FieldByName(cFDDocumentType).AsString;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);
      mGrid := TMultiGrid(mSite.FindComponent(cgrdPackagesData));
      FillSortedStringsFromSelectedRows(mGrid, mIDs);
      medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMPRovider));
      mPostProvider := medPDMPRovider.DataText;
      mStation_ID := StringsToSelDat(mOS, mIDs);
      try
        if CFxOID.IsEmpty(mPostProvider) then begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
        end else begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
        end;
        mIDs.Clear;
        mOS.SQLSelect(mSQL, mIDs);
      finally
        ClearSelDat(mOS, mStation_ID);
      end;
      if (mIDs.Count > 0) then begin
        for i:= 0 to mIDs.Count-1 do begin
          mTmp := mIDs[i];
          mID := NxTrapStr(mTmp, ';');
          mIDs[i] := QuotedStr(mID);
        end;
        sqlCondition := 'a.id in ('+mIDs.CommaText+')';
        mSite.ShowDynForm(Site_PDMIssuedDocs, Nil,Nil, False,
                         'QueryByUserDynSQLCondition;'+sqlCondition+lng_QueryTit_RecordForDocument);
      end else
        NxShowSimpleMessage(lng_msg_NoRecordsFound, mSite);
    finally
      mDataSet.EnableControls;
    end;
  finally
    mIDs.Free;
  end;
end;

procedure btnPDExportPackagesClick(Sender : TControl);
var
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
  mMemo: TForm;
  mBO: TNxCustomBusinessObject;
begin
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mIDs := TStringList.Create;
  gLog := TNxCustomLog.Create(Balikobot_LogName);
  try
    mDataSet := TMemoryDataset(IntToObj(Sender.Tag));
    mDataSet.DisableControls;
    try
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(TRollSiteForm(mSite).SiteParams) then begin
        if TRollSiteForm(mSite).SiteParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite) then
          mDocumentType := TRollSiteForm(mSite).SiteParams.ParamAsString(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite, '');
      end else begin
        mDocumentType := mDataSet.FieldByName(cFDDocumentType).AsString;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);
      mGrid := TMultiGrid(mSite.FindComponent(cgrdPackagesData));
      FillSortedStringsFromSelectedRows(mGrid, mIDs);
      medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMProvider));
      mPostProvider := medPDMPRovider.DataText;
      mStation_ID := StringsToSelDat(mOS, mIDs);
      mIDs.Clear;
      //Najdu co se právě vytvořilo
      if mDataSet.FieldByName(cFDCreatedPDMIDs).AsString <> '' then
         mIDs.Text := mDataSet.FieldByName(cFDCreatedPDMIDs).AsString;

      if mIDs.Count = 0 then
      begin
        //Postaru dohledám to co je již v odeslané poště
        try
          if CFxOID.IsEmpty(mPostProvider) then begin
            mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
          end else begin
            mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
          end;
          mIDs.Clear;
          mOS.SQLSelect(mSQL, mIDs);
          for i:= 0 to mIDs.Count-1 do begin
            mTmp := mIDs[i];
            mID := NxTrapStr(mTmp, ';');
            mIDs[i] := mID;
          end;
        finally
          ClearSelDat(mOS, mStation_ID);
        end;
      end;

      if (mIDs.Count > 0) then
      begin
        OutputDebugString(mIDs.Text);
        try
          ExportPackages(mSite,mSite.BaseObjectSpace, mIDs, GetProviderDriver(mOS,mPostProvider), 0);
        except
          //PEMI - Mazání po nepovedeném exportu.
          for i:= 0 to mIDs.Count-1 do begin
            mBO := nil;
            mBO := mOS.CreateObject(Class_PDMIssuedDoc);
            try
              mBO.Load( mIDs[i],nil);
              if (mBO.GetFieldValueAsInteger('X_PD_status') <= 1) then
              begin
                mBO.Delete;
              end;
            finally
              mBO.Free;
            end;
          end;
          try
            mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+ExceptionMessage);
            mMemo.ShowModal(mSite);
          finally
            mMemo.Free;
          end;
        end;
      end else
        NxShowSimpleMessage(lng_msg_NoRecordsFound, mSite);
    finally
      mDataSet.EnableControls;
    end;
  finally
    mIDs.Free;
    FreeLog;
  end;
end;

{Vrátí pro vybrané balíky z grydu již existující odeslanou poštu}
function ExistPDMReceivedDoc(Sender : TControl;):String;
var
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
begin
  Result := '';
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mIDs := TStringList.Create;
  try
    mDataSet := TMemoryDataset(IntToObj(Sender.Tag));
    mDataSet.DisableControls;
    try
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(TRollSiteForm(mSite).SiteParams) then begin
        if TRollSiteForm(mSite).SiteParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite) then
          mDocumentType := TRollSiteForm(mSite).SiteParams.ParamAsString(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite, '');
      end else begin
        mDocumentType := mDataSet.FieldByName(cFDDocumentType).AsString;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);
      mGrid := TMultiGrid(mSite.FindComponent(cgrdPackagesData));
      FillSortedStringsFromSelectedRows(mGrid, mIDs);
      medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMPRovider));
      mPostProvider := medPDMPRovider.DataText;
      mStation_ID := StringsToSelDat(mOS, mIDs);
      try
        if CFxOID.IsEmpty(mPostProvider) then begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
        end else begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
        end;
        mIDs.Clear;
        mOS.SQLSelect(mSQL, mIDs);
      finally
        ClearSelDat(mOS, mStation_ID);
      end;
      if (mIDs.Count > 0) then
        Result := mIDs.Text
      else
        Result := '';
    finally
      mDataSet.EnableControls;
    end;
  finally
    mIDs.Free;
  end;
end;



procedure btnPDPrintPackagesClick(Sender : TControl);
var
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
  mMemo: TForm;
begin
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mIDs := TStringList.Create;
  try
    mDataSet := TMemoryDataset(IntToObj(Sender.Tag));
    mDataSet.DisableControls;
    try
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(TRollSiteForm(mSite).SiteParams) then begin
        if TRollSiteForm(mSite).SiteParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite) then
          mDocumentType := TRollSiteForm(mSite).SiteParams.ParamAsString(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite, '');
      end else begin
        mDocumentType := mDataSet.FieldByName(cFDDocumentType).AsString;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);
      mGrid := TMultiGrid(mSite.FindComponent(cgrdPackagesData));
      FillSortedStringsFromSelectedRows(mGrid, mIDs);
      medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMProvider));
      mPostProvider := medPDMPRovider.DataText;
      mStation_ID := StringsToSelDat(mOS, mIDs);
      mIDs.Clear;
      //Najdu co se právě vytvořilo
      if mDataSet.FieldByName(cFDCreatedPDMIDs).AsString <> '' then
         mIDs.Text := mDataSet.FieldByName(cFDCreatedPDMIDs).AsString;

      if mIDs.Count = 0 then
      begin
        try
          if CFxOID.IsEmpty(mPostProvider) then begin
            mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
          end else begin
            mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
          end;
          mIDs.Clear;
          mOS.SQLSelect(mSQL, mIDs);
          for i:= 0 to mIDs.Count-1 do begin
            mTmp := mIDs[i];
            mID := NxTrapStr(mTmp, ';');
            mIDs[i] := QuotedStr(mID);
          end;
        finally
          ClearSelDat(mOS, mStation_ID);
        end;
      end;

      if (mIDs.Count > 0) then
      begin
        OutputDebugString(mIDs.Text);
        try //todo  GetProviderDriver nahradit funkcí na dohledání správného dopravce
          PrintPackages(mSite.BaseObjectSpace, mIDs, GetProviderDriver(mOS,mPostProvider), 0);
        except
          try
            mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+ExceptionMessage);
            mMemo.ShowModal(mSite);
          finally
            mMemo.Free;
          end;
        end;
      end;
      // else
      //  NxShowSimpleMessage('Pro vybrané doklady nejsou žádné balíky.', mSite);
    finally
      mDataSet.EnableControls;
    end;
  finally
    mIDs.Free;
  end;
end;




procedure MassChange(ADataSet: TDataSet; ASite: TSiteForm; AValues: TStringList);
var
  i: integer;
  mFieldName, mFieldValue: string;
begin
  if not (ADataSet.State = dsEdit) then
    ADataSet.Edit;
  for i:= 0 to AValues.Count - 1 do begin
    mFieldName := AValues.Names[i];
    mFieldValue := AValues.ValueFromIndex[i];
    ADataSet.FieldByName(mFieldName).AsString := mFieldValue;
  end;
end;

procedure FillSortedStringsFromSelectedRows(AGrid: TMultiGrid; AIDs: TStringList);
var
  mDataSet: TDataSet;
  i: integer;
  bm: TBookmark;
  mbs: TBookmarkStr;
begin
  AIDs.Clear;
  mDataSet := AGrid.DataSource.DataSet;
  if AGrid.SelectedRows.Count > 0 then begin
    bm:= mDataSet.GetBookmark;
    mDataSet.DisableControls;
    try
      for i:= 0 to AGrid.SelectedRows.Count - 1 do begin
        mbs := AGrid.SelectedRows.Items[I];
        mDataSet.GotoBookmark(mbs);
        AIDs.Add(mDataSet.FieldByName(cFDID).AsString);
      end;
    finally
      mDataSet.GotoBookmark(bm);
      mDataSet.EnableControls;
    end;
  end;
  if (AIDs.count = 0) then begin
    AIDs.Add(mDataSet.FieldByName(cFDID).AsString);
  end;
end;

function CreateMultiGridContent(AOwner: TForm; AParent: TWinControl): TMultiGrid;
begin
  CFxProfiler.EnterProc('postprovider', 'CreateMultiGridContent');
  try
    Result := TMultiGrid.Create(AOwner);
    Result.Parent := AParent;
    Result.Align := alClient;
    Result.ReadOnly := false;
    Result.Enabled := true;
    Result.Name:= cgrdContent;
    Result.Height := 250;
    Result.TabOrder:= 12;
    Result.Ctl3D := True;
    Result.ParentCtl3D := False;
    Result.Options := [goGap, goHeaders, goRowLines, goColLines, goFixRowLines, goFixColLines, goAllowEdit, goAlwaysShowEditor];//[goGap, goHeaders, goRowLines, goColLines, goFixRowLines, goFixColLines,  goAlwaysShowEditor,goAllowInsert, goAllowAppend, goAllowAppend  ,goAllowEdit ];//
    Result.DefaultLayout := cLayoutPackage;

    CreateLayoutContent(Result, cLayoutPackage);
    CreateLayoutContent(Result, cLayoutCargo);


    Result.OnGetColumnReadOnly:= @ColumnReadOnlyContent;
    //Result.OnEnter:= @OnEnterContent;
    Result.OnKeyDown:= @ActKeyDown;
    Result.EditMode := true;
    Result.Enabled := true;

  except
    OutputDebugString(ExceptionMessage);
  end;
  CFxProfiler.ExitProc('postprovider', 'CreateMultiGridContent');
end;


function CreateMultiGrid(AOwner: TForm; AParent: TWinControl): TMultiGrid;
begin
  CFxProfiler.EnterProc('postprovider', 'CreateMultiGrid');
  try
    Result := TMultiGrid.Create(AOwner);
    Result.Parent := AParent;
    Result.Align := alClient;
    Result.ReadOnly := false;
    Result.Enabled := true;
    Result.Name:= cgrdPackagesData;
    Result.TabOrder:= 10;
    Result.Ctl3D := True;
    Result.ParentCtl3D := False;
    Result.Options := [goGap, goHeaders, goRowLines, goColLines, goFixRowLines, goFixColLines, goAllowEdit, goAlwaysShowEditor];
    Result.DefaultLayout := cLayoutFirm;

    CreateLayout(Result, cLayoutFirm);
    CreateLayout(Result, cLayoutPerson);

    Result.OnGetColumnReadOnly:= @MGColumnReadOnly;
    Result.OnEnter:= @MGOnEnter;
    Result.EditMode := true;
    Result.OnGetBackgroundColor:=@MGGetBackgroundColor;
    //Result.OnLayoutIndexNeeded := @MGLayoutIndexNeeded;
  except
    OutputDebugString(ExceptionMessage);
  end;
  CFxProfiler.ExitProc('postprovider', 'CreateMultiGrid');
end;

procedure CreateLayout(var AMultiGrid: TMultiGrid; const ALayout: integer);
var
  c00: TNxMultiGridColumn;
  c01: TNxMultiGridColumn;
  c02: TNxMultiGridColumn;
  c03: TNxMultiGridColumn;
  c04: TNxMultiGridRollColumn;
  c05: TNxMultiGridColumn;
  c06: TNxMultiGridRollColumn;
  c07: TNxMultiGridColumn;
  c08: TNxMultiGridColumn;
  cDateTime00: TNxMultiGridDateColumn;
  cDateTime01: TNxMultiGridDateColumn;

  cTime00: TNxMultiGridColumn;
  cTime01: TNxMultiGridColumn;
  cTime02: TNxMultiGridColumn;
  cTime03: TNxMultiGridColumn;
begin
  c00 := TNxMultiGridColumn.Create(AMultiGrid);
  c01 := TNxMultiGridColumn.Create(AMultiGrid);
  c02 := TNxMultiGridColumn.Create(AMultiGrid);
  c03 := TNxMultiGridColumn.Create(AMultiGrid);
  c04 := TNxMultiGridRollColumn.Create(AMultiGrid);
  c05 := TNxMultiGridColumn.Create(AMultiGrid);
  c06 := TNxMultiGridRollColumn.Create(AMultiGrid);
  c07 := TNxMultiGridColumn.Create(AMultiGrid);
  c08 := TNxMultiGridColumn.Create(AMultiGrid);
  cDateTime00 := TNxMultiGridDateColumn.Create(AMultiGrid);
  cDateTime01 := TNxMultiGridDateColumn.Create(AMultiGrid);

  cTime00 := TNxMultiGridColumn.Create(AMultiGrid);
  cTime01 := TNxMultiGridColumn.Create(AMultiGrid);
  cTime02 := TNxMultiGridColumn.Create(AMultiGrid);
  cTime03 := TNxMultiGridColumn.Create(AMultiGrid);

  with c00 do
  begin
    Name := ccolDisplayNumber+IntToStr(ALayout);
    Caption := lng_frm_DocNumber;
    FieldName := cFDDisplayNumber;
    Width := 90;
    Layout := ALayout;
    Line := 0;
    Order := 0;
    Elastic := false;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c00);

  with c01 do
  begin
    Name := ccolVarSymbol+IntToStr(ALayout);
    Caption := lng_frm_VarSymbol;
    FieldName := cFDVarSymbol;
    Width := 90;
    Layout := ALayout;
    Line := 0;
    Order := 1;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c01);

  with c02 do
  begin
    Name := ccolAmount+IntToStr(ALayout);
    Caption := lng_frm_Amount;
    FieldName := cFDAmount;
    Width := 80;
    Layout := ALayout;
    Line := 0;
    Order := 2;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c02);

  with c03 do
  begin
    Name := ccolCashOnDelivery+IntToStr(ALayout);
    Caption := lng_frm_COD;
    FieldName := cFDCashOnDelivery;
    Width := 80;
    Layout := ALayout;
    Line := 0;
    Order := 3;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c03);

  with c04 do
  begin
    Name := ccolCurrency+IntToStr(ALayout);
    Caption := lng_frm_Currency;
    FieldName := cFDCurrency;
    Width := 50;
    Layout := ALayout;
    Line := 0;
    Order := 4;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
    TextField := 'Code';
  end;
  AMultiGrid.AddColumn(c04);
  with TNxMultiGridCustomRollColumn(c04) do
  begin
    ClassID:= Roll_Currencies;
  end;

  (* Nahrazeno gridem content
  with c05 do
  begin
    Name := ccolCount+IntToStr(ALayout);
    Caption := 'Počet balíků';
    FieldName := cFDCount;
    Width := 70;
    Layout := ALayout;
    Line := 0;
    Order := 5;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c05);
  *)
  with c05 do
  begin
    Name := ccolExistCount+IntToStr(ALayout);
    Caption := 'Existujících';
    FieldName := cFDExistCount;
    Width := 70;
    Layout := ALayout;
    Line := 0;
    Order := 0;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c05);

  with c06 do
  begin
    Name := ccolContentType+IntToStr(ALayout);
    Caption := lng_frm_ContentType;
    Width := 70;
    Layout := ALayout;
    Line := 0;
    Order := 6;
    Elastic := False;
    FieldName := cFDContentType;
    ReadOnly := False;
    Complete := True;
    CompleteMinLength := 0;
    TextField := 'Code';
    OnDataChangeEvent := @OnChangeContentType //doplněno o filtrování dopl. služeb dle typu obsahu
  end;
  AMultiGrid.AddColumn(c06);
  with TNxMultiGridCustomRollColumn(c06) do
  begin
    ClassID:= Roll_PDMIssuedContentTypes;
  end;

  AddServiceTypeCols(AMultiGrid, ALayout);

  with c07 do
  begin
    Name := ccolInsurance+IntToStr(ALayout);
    Caption := lng_frm_Insurance;
    FieldName := cFDInsurance;
    Width := 60;
    Layout := ALayout;
    Line := 0;
    Order := 7+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c07);

  with c08 do
  begin
    Name := ccolNoteForDriver+IntToStr(ALayout);
    Caption := lng_frm_NoteForDriver;
    FieldName := cFDNoteForDriver;
    Width := 120;
    Layout := ALayout;
    Line := 0;
    Order := 8+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c08);

  //Liftágo
  with cDateTime00 do
  begin
    Name := ccolPickupDate+IntToStr(ALayout);
    Caption := lng_frm_PickupDate;
    FieldName := cFDPickupDate;
    Width := 120;
    Layout := ALayout;
    Line := 1;
    Order := 9+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cDateTime00);

  with cTime00 do
  begin
    Name := ccolPickupTimeFrom+IntToStr(ALayout);
    Caption := lng_frm_PickupFrom;
    FieldName := cFDPickupTimeFrom;
    Width := 120;
    Layout := ALayout;
    Line := 1;
    Order := 10+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cTime00);

  with cTime01 do
  begin
    Name := ccolPickupTimeTo+IntToStr(ALayout);
    Caption := lng_frm_PickupTo;
    FieldName := cFDPickupTimeTo;
    Width := 120;
    Layout := ALayout;
    Line := 1;
    Order := 11+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cTime01);

  with cDateTime01 do
  begin
    Name := ccolDeliveryDate+IntToStr(ALayout);
    Caption := lng_frm_DeliveryDate;
    FieldName := cFDDeliveryDate;
    Width := 120;
    Layout := ALayout;
    Line := 1;
    Order := 12+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cDateTime01);

  with cTime02 do
  begin
    Name := ccolDeliveryTimeFrom+IntToStr(ALayout);
    Caption := lng_frm_DeliveryFrom;
    FieldName := cFDDeliveryTimeFrom;
    Width := 120;
    Layout := ALayout;
    Line := 1;
    Order := 13+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cTime02);

  with cTime03 do
  begin
    Name := ccolDeliveryTimeTo+IntToStr(ALayout);
    Caption := lng_frm_DeliveryFrom;
    FieldName := cFDDeliveryTimeTo;
    Width := 120;
    Layout := ALayout;
    Line := 1;
    Order := 14+cServiceTypeMaxCount;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cTime03);



  (*
  cTime00.OnUserActionEvent := @OnUserActionEvent;
  cTime01.OnUserActionEvent := @OnUserActionEvent;
  cTime02.OnUserActionEvent := @OnUserActionEvent;
  cTime03.OnUserActionEvent := @OnUserActionEvent;
    *)
  cTime00.OnSetTextEvent := @OnSetTextEvent;
  cTime01.OnSetTextEvent := @OnSetTextEvent;
  cTime02.OnSetTextEvent := @OnSetTextEvent;
  cTime03.OnSetTextEvent := @OnSetTextEvent;

  cTime00.OnCompletionEvent := @OnSetTextEvent;
  cTime01.OnCompletionEvent := @OnSetTextEvent;
  cTime02.OnCompletionEvent := @OnSetTextEvent;
  cTime03.OnCompletionEvent := @OnSetTextEvent;

      (*
  cTime00.OnDataChangeEvent := @OnDataChangeEvent;
  cTime01.OnDataChangeEvent := @OnDataChangeEvent;
  cTime02.OnDataChangeEvent := @OnDataChangeEvent;
  cTime03.OnDataChangeEvent := @OnDataChangeEvent;

  cTime00.OnChangeEvent := @OnChangeEvent;
  cTime01.OnChangeEvent := @OnChangeEvent;
  cTime02.OnChangeEvent := @OnChangeEvent;
  cTime03.OnChangeEvent := @OnChangeEvent;
        *)

  //AddPackageCols(AMultiGrid, ALayout);
  AddAddressCols(AMultiGrid, ALayout, False);
  AddAddressCols(AMultiGrid, ALayout, True);
  AddManipulationUnitsCols(AMultiGrid, ALayout); //Balíkobot
end;

//Nedopatřením se může abra v chybě zacyklit. Toto řeší problém.



procedure OnSetTextEvent(Sender : TNxMultiGridCustomColumn; var AText : string);
var mTime : TTime;
begin
  mTime := TimeOf( Now());
  OutputDebugString('OnSetTextEvent '+AText);
  if not TryStrToTime(AText,mTime) then
  begin
    OutputDebugString('Oprava time');
    Sender.Grid.DataSource.DataSet.Edit;
    Sender.Grid.DataSource.DataSet.FieldByName(sender.FieldName).AsDateTime := TimeOf( Now());
    Sender.Grid.DataSource.DataSet.Post;
    AText := TimeToStr(TimeOf( Now()));
  end;
end;


procedure OnUserActionEvent(Sender : TNxMultiGridCustomColumn; var AText : string);
begin
  OutputDebugString('OnUserActionEvent '+AText);
  AText := '01:01';
  Sender.Text := '01:01';
  OutputDebugString('after: '+AText);
end;

procedure OnDataChangeEvent(Sender : TNxMultiGridCustomColumn;);
begin
  OutputDebugString('OnDataChangeEvent '+ Sender.Text);
end;

procedure OnChangeEvent(Sender : TNxMultiGridCustomColumn;);
begin
  OutputDebugString('OnChangeEvent '+ Sender.Text);
end;




procedure CreateLayoutContent(var AMultiGrid: TMultiGrid; const ALayout: integer);
var
  mCol: TNxMultiGridColumn;
  mColLookup: TNxMultiGridLookupColumn;
  mColRoll : TNxMultiGridRollColumn;
  i, j: integer;
begin

  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolPosindex+IntToStr(ALayout);
    Caption := '#';
    FieldName := cFDPosindex;
    Width := 20;
    Layout := ALayout;
    Line := 0;
    Order := 0;
    Elastic := False;
    ReadOnly := true;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);

  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolParentName+IntToStr(ALayout);
    Caption := lng_frm_DocNumber;
    FieldName := cFDDisplayNumber;
    Width := 90;
    Layout := ALayout;
    Line := 0;
    Order := 0;
    Elastic := False;
    ReadOnly := true;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);


  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolWeight+IntToStr(ALayout);
    Caption := lng_frm_Weight;
    FieldName := cFDweight;
    Width := 50;
    Layout := ALayout;
    Line := 0;
    Order := 0;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);

  mColLookup := TNxMultiGridLookupColumn.Create(AMultiGrid);
  with mColLookup do
  begin
    Name := ccolWeightUnit+IntToStr(ALayout);
    Caption := '';
    FieldName := cFDWeightUnit;
    Width := 50;
    Layout := ALayout;
    Line := 0;
    Order := 1;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
    Values.add(cUnitgStr+'='+IntToStr(cUnitg));
    Values.add(cUnitkgStr+'='+IntToStr(cUnitkg));
    Values.add(cUnittStr+'='+IntToStr(cUnitt));
  end;
  AMultiGrid.AddColumn(mColLookup);


  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolWidth+IntToStr(ALayout);
    Caption := lng_frm_Width;
    FieldName := cFDWidth;
    Width := 50;
    Layout := ALayout;
    Line := 0;
    Order := 2;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);

  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolHeight+IntToStr(ALayout);
    Caption := lng_frm_Height;
    FieldName := cFDHeight;
    Width := 50;
    Layout := ALayout;
    Line := 0;
    Order := 3;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);

  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolLength+IntToStr(ALayout);
    Caption := lng_frm_Length;
    FieldName := cFDLength;
    Width := 50;
    Layout := ALayout;
    Line := 0;
    Order := 4;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);

  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolVolume+IntToStr(ALayout);
    Caption := lng_frm_Volume;
    FieldName := cFDVolume;
    Width := 100;
    Layout := ALayout;
    Line := 0;
    Order := 5;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);


  mColRoll := TNxMultiGridRollColumn.Create(AMultiGrid);
  with mColRoll do
  begin
    Name := ccolManipulationUnit+IntToStr(ALayout);
    Caption := lng_frm_ManipulationUnit;
    Width := 100;
    Layout := ALayout;
    Line := 0;
    Order := 6;
    Elastic := False;
    FieldName := cFDManipulationUnit;
    ReadOnly := True;
    Complete := True;
    CompleteMinLength := 0;
    TextField := 'Name';
    OnDataChangeEvent := @OnChangeManipulationUnit //BUG
  end;
  AMultiGrid.AddColumn(mColRoll);
  with TNxMultiGridCustomRollColumn(mColRoll) do
  begin
    ClassID:= Roll_ManipulationUnitsRoll;
  end;

  mCol := TNxMultiGridColumn.Create(AMultiGrid);
  with mCol do
  begin
    Name := ccolContent+IntToStr(ALayout);
    Caption := lng_frm_Content;
    FieldName := cFDContent;
    Width := 160;
    Layout := ALayout;
    Line := 0;
    Order := 7;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(mCol);

  //ADR - Odkomentovat
  mColRoll := TNxMultiGridRollColumn.Create(AMultiGrid);

  //ADR - Odkomentovat - povolit
  with mColRoll do
  begin
    Name := ccolADRUnit+IntToStr(ALayout);
    Caption := lng_frm_ADRUnit;
    Width := 80;
    Layout := ALayout;
    Line := 0;
    Order := 99;
    Elastic := False;
    FieldName := cFDADRUnit;
    ReadOnly := True;
    Complete := True;
    CompleteMinLength := 0;
    TextField := 'Name';
    Visible := false; //Schválně
  end;

  AMultiGrid.AddColumn(mColRoll);
  with TNxMultiGridCustomRollColumn(mColRoll) do
  begin
    //ClassID:= Roll_UserRoll_AccordDangereusesRoute;
    ClassID:= Roll_StoreCards;//DEV ROLL
  end;


end;


//Plaetová přeprava Balíkobot (Malinko se musíme poprat s řešením TopTrans ve starém řešení)
procedure AddManipulationUnitsCols(var AMultiGrid: TMultiGrid; const ALayout: integer);
var
  cCount: TNxMultiGridColumn;
  cContainer: TNxMultiGridRollColumn;
  cNote: TNxMultiGridColumn;
  i, j: integer;
begin

  cCount := TNxMultiGridColumn.Create(AMultiGrid);
  cContainer := TNxMultiGridRollColumn.Create(AMultiGrid);
  cNote := TNxMultiGridColumn.Create(AMultiGrid);

  //Počet k vrácení
  with cCount do
  begin
    Name := ccolCountMUnitBack+IntToStr(ALayout);
    Caption := lng_frm_CountBack;
    FieldName := cFDManipulationUnitCountBack;
    Width := 70;
    Layout := ALayout;
    Line := 1;
    Order := (4*(i+1+8))+6;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cCount);
  //Popis co se bude vracet
  with cNote do
  begin
    Name := ccolManipulationUnitNoteBack+IntToStr(ALayout);
    Caption := lng_frm_MUnitNoteBack;
    FieldName := cFDMUnitNoteBack;
    Width := 180;
    Layout := ALayout;
    Line := 1;
    Order := (4*(i+1+8))+7;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(cNote);


end;

procedure AddServiceTypeCols(var AMultiGrid: TMultiGrid; const ALayout: integer);
var
  mServiceType: TNxMultiGridRollColumn;
  i: integer;
begin
  for i:= 0 to cServiceTypeMaxCount-1 do begin
    mServiceType := TNxMultiGridRollColumn.Create(AMultiGrid);
    with mServiceType do
    begin
      Name := ccolServiceType+IntToStr(ALayout)+IntToStr(i);
      Caption := lng_frm_ServiceType;
      Width := 70;
      Layout := ALayout;
      Line := 0;
      Order := 7+i;
      Elastic := False;
      FieldName := cFDPDMServiceType+IntToStr(i);
      ReadOnly := False;
      Complete := True;
      CompleteMinLength := 0;
      TextField := 'Name';
    end;
    AMultiGrid.AddColumn(mServiceType);
    with TNxMultiGridCustomRollColumn(mServiceType) do
    begin
      ClassID:= Roll_PDMServiceTypes;
    end;
  end;
end;



procedure _AddAddressCols(var AMultiGrid: TMultiGrid; const ALayout: integer);
var
  cColType0: TNxMultiGridLookupColumn;
  cColType1: TNxMultiGridLookupColumn;
  cCol0: TNxMultiGridColumn;
  cCol1: TNxMultiGridColumn;
  cCol2: TNxMultiGridColumn;
  cCol3: TNxMultiGridColumn;
  cCol4: TNxMultiGridColumn;
  cCol5: TNxMultiGridColumn;
  cCol6: TNxMultiGridColumn;
  cCol7: TNxMultiGridColumn;
  cCol8: TNxMultiGridColumn;
  cCol9: TNxMultiGridColumn;
  cCol10: TNxMultiGridColumn;
  cCol11: TNxMultiGridColumn;
  cCol12: TNxMultiGridColumn;
  cCol13: TNxMultiGridColumn;

  procedure iAddTNxMultiGridColumn(var AComponent: TNxMultiGridColumn; AName,Caption,FieldName:String; AOrder,ALine: Integer; AWidth: Integer = 150;);
  begin
    AComponent := TNxMultiGridColumn.Create(AMultiGrid);
    with AComponent do
    begin
      Name := AName+IntToStr(ALayout);
      Caption := Caption;
      FieldName := FieldName;
      Width := AWidth;
      Layout := ALayout;
      Line := ALine;
      Order := AOrder;
      Elastic := False;
      ReadOnly := True;
      Complete := False;
      CompleteMinLength := 0;
    end;
    AMultiGrid.AddColumn(AComponent);
  end;

  procedure iAddAddressType (var AComponent: TNxMultiGridLookupColumn; AName,Caption,FieldName:String; AOrder,ALine: Integer; AWidth: Integer = 150;);
  begin
    AComponent := TNxMultiGridLookupColumn.Create(AMultiGrid);
    with AComponent do
    begin
      Name := AName+IntToStr(ALayout);
      Caption := Caption;
      FieldName := FieldName;
      Width := AWidth;
      Layout := ALayout;
      Line := ALine;
      Order := AOrder;
      Elastic := False;
      ReadOnly := False;
      Complete := False;
      CompleteMinLength := 0;
      Values.add(cFromFirmStr+'='+IntToStr(cFromFirm));
      Values.add(cFromFirmOfficeStr+'='+IntToStr(cFromFirmOffice));
      Values.add(cFromPersonStr+'='+IntToStr(cFromPerson));
    end;
    AMultiGrid.AddColumn(AComponent);
  end;

begin

  iAddAddressType(cColType0,ccolTargetAddressType,lng_frm_TargetAddress,cFDTargetAddressType,0,2);
  iAddTNxMultiGridColumn(cCol0,ccolAdrName,lng_frm_FirmName,cFDAdrName,1,2);
  if (ALayout = cLayoutFirm) then
      cCol0.Caption := lng_frm_FirmName
    else
      cCol0.Caption := lng_frm_PersonName;
  iAddTNxMultiGridColumn(cCol1,ccolAdrStreet,lng_frm_Street,cFDAdrStreet,2,2);
  iAddTNxMultiGridColumn(cCol2,ccolAdrCity,lng_frm_City,cFDAdrCity,3,2);
  iAddTNxMultiGridColumn(cCol3,ccolAdrPostCode,lng_frm_PostCode,cFDAdrPostCode,4,2);
  iAddTNxMultiGridColumn(cCol4,ccolAdrCountryCode,lng_frm_CountryCode,cFDAdrCountryCode,5,2,50);
  iAddTNxMultiGridColumn(cCol5,ccolAdrPhoneNumber,lng_frm_PhoneNumber,cFDAdrPhoneNumber,6,2);
  iAddTNxMultiGridColumn(cCol6,ccolPersonName,lng_frm_PersonName,cFDPersonName,7,2);
  //Sender address
  iAddAddressType(cColType1,ccolTargetAddressTypeSen,lng_frm_Sen_TargetAddress,cFDTargetAddressTypeSen,0,3);
  iAddTNxMultiGridColumn(cCol7,ccolAdrNameSen,lng_frm_Sen_FirmName,cFDAdrNameSen,1,3);
  if (ALayout = cLayoutFirm) then
      cCol7.Caption := lng_frm_FirmName
    else
      cCol7.Caption := lng_frm_PersonName;
  iAddTNxMultiGridColumn(cCol8,ccolAdrStreetSen,lng_frm_Sen_Street,cFDAdrStreetSen,2,3);
  iAddTNxMultiGridColumn(cCol9,ccolAdrCitySen,lng_frm_Sen_City,cFDAdrCitySen,3,3);
  iAddTNxMultiGridColumn(cCol10,ccolAdrPostCodeSen,lng_frm_Sen_PostCode,cFDAdrPostCodeSen,4,3);
  iAddTNxMultiGridColumn(cCol11,ccolAdrCountryCodeSen,lng_frm_Sen_CountryCode,cFDAdrCountryCodeSen,5,3,50);
  iAddTNxMultiGridColumn(cCol12,ccolAdrPhoneNumberSen,lng_frm_Sen_PhoneNumber,cFDAdrPhoneNumberSen,6,3);
  iAddTNxMultiGridColumn(cCol13,ccolPersonNameSen,lng_frm_Sen_PersonName,cFDPersonNameSen,7,3);
end;

procedure MGColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
var
  mDataset: TDataSet;
begin

  mDataset := TNxMultiGridCustomColumn(Sender).Grid.DataSource.DataSet;
  AReadOnly := (NxAt(ccolAdr, Sender.Name) > 0) or
               (NxAt(ccolDisplayNumber, Sender.Name) > 0) or
               //(NxAt(ccolAmount, Sender.Name) > 0) or
               (NxAt(ccolExistCount, Sender.Name) > 0) or
               (NxAt(ccolCurrency, Sender.Name) > 0) or
               (NxAt(ccolPersonName, Sender.Name) > 0);
  AReadOnly := AReadOnly or ((NxAt(ccolVarSymbol, Sender.Name) > 0) and (mDataset.FieldByName(cFDDocumentType).AsString = cDocumentTypeIssuedInvoice));
end;

procedure ColumnReadOnlyContent(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
  AReadOnly := false;
  if (NxAt(ccolParentName, Sender.Name) > 0)
    or(NxAt(ccolPosindex, Sender.Name) > 0)
  then AReadOnly := true;
end;

procedure MGOnEnter(Sender: TObject);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  mDataset: TDataset;
  i, j, mIndex: integer;
  mAllowedContentTypes, mAllowedServiceTypes, mAllowedDepots: string;
  mServiceType: Integer;
begin
  CFxProfiler.EnterProc('postprovider', 'MGOnEnter');
  mDataset := TMultiGrid(Sender).DataSource.DataSet;
  if (mDataset.RecordCount = 1) then begin
    //obezlička aby šel editovat jeden řádek
    //NxPostKey(VK_DOWN, nil, false);
    //NxPostKey(VK_UP, nil, false);
  end;
  mSite := TSiteForm(TMultiGrid(Sender).Owner);

  mServiceType := 0;

  if Assigned(TRollSiteForm(mSite).SiteParams) then
    if TRollSiteForm(mSite).SiteParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cServiceType) then
      mServiceType := TRollSiteForm(mSite).SiteParams.ParamAsInteger(NxGetActualUserID(mSite.BaseObjectSpace)+cServiceType, 0);
  OutputDebugString('param ServiceType '+IntToStr(mServiceType));

  mOS := mSite.BaseObjectSpace;
  medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMPRovider));
  mPostProvider := medPDMPRovider.DataText;
  if not CFxOID.IsEmpty(mPostProvider) then
  begin
    //povolime jen typy obsahu dle poskytovatele
    mAllowedContentTypes := GetAllowedContentTypes(mOS, mPostProvider, mServiceType );
    for i:= 0 to cLayoutCount-1 do begin
      mIndex := TNxMultiGridCustomRollColumn(TMultiGrid(Sender).ColumnByName(ccolContentType+IntToStr(i))).Parameters.IndexOfName('_Allowed');
      if (mIndex <> -1) then
        TNxMultiGridCustomRollColumn(TMultiGrid(Sender).ColumnByName(ccolContentType+IntToStr(i))).Parameters.Delete(mIndex);
      if mAllowedContentTypes <> '' then
        TNxMultiGridCustomRollColumn(TMultiGrid(Sender).ColumnByName(ccolContentType+IntToStr(i))).Parameters.Add('_Allowed='+mAllowedContentTypes);
      for j:= 0 to cServiceTypeMaxCount-1 do begin
        mIndex := TNxMultiGridCustomRollColumn(TMultiGrid(Sender).ColumnByName(ccolServiceType+IntToStr(i)+IntToStr(j))).Parameters.IndexOfName('_Allowed');
        if (mIndex <> -1) then
          TNxMultiGridCustomRollColumn(TMultiGrid(Sender).ColumnByName(ccolServiceType+IntToStr(i)+IntToStr(j))).Parameters.Delete(mIndex);
        if mAllowedServiceTypes <> '' then
          TNxMultiGridCustomRollColumn(TMultiGrid(Sender).ColumnByName(ccolServiceType+IntToStr(i)+IntToStr(j))).Parameters.Add('_Allowed='+mAllowedServiceTypes)
      end;
    end;
  end;
  CFxProfiler.ExitProc('postprovider', 'MGOnEnter');
end;

procedure OnChangeContentType(Sender: TObject);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  medPDMPRovider: TRollComboEdit;
  medPDMContentType : TNxMultiGridColumn;
  mPostProvider: TNxOID;
  mDataset: TDataset;
  i, j, mIndex: integer;
  mAllowedContentTypes, mAllowedServiceTypes, mAllowedDepots, mPostContentType: string;
begin
  CFxProfiler.EnterProc('postprovider', 'OnChangeContentType');
  mSite := TSiteForm(TNxMultiGridCustomRollColumn(Sender).Grid.Owner);
  mOS := mSite.BaseObjectSpace;
  medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMPRovider));
  mPostProvider := medPDMPRovider.DataText;
  if not CFxOID.IsEmpty(mPostProvider) then
  begin
    mPostContentType := TNxMultiGridCustomRollColumn(Sender).Grid.DataSource.DataSet.FieldByName(TNxMultiGridCustomRollColumn(Sender).FieldName).AsString;
    if not CFxOID.IsEmpty(mPostContentType) then
    begin
      //povolime jen sluzby dle poskytovatele a typu obsahu
      mAllowedServiceTypes := GetAllowedServiceTypes(mOS, mPostProvider,mPostContentType );
      for i:= 0 to cLayoutCount-1 do
      begin
        for j:= 0 to cServiceTypeMaxCount-1 do
        begin
          mIndex := TNxMultiGridCustomRollColumn(TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolServiceType+IntToStr(i)+IntToStr(j))).Parameters.IndexOfName('_Allowed');
          if (mIndex <> -1) then
            TNxMultiGridCustomRollColumn(TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolServiceType+IntToStr(i)+IntToStr(j))).Parameters.Delete(mIndex);
          //if mAllowedServiceTypes <> '' then
            TNxMultiGridCustomRollColumn(TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolServiceType+IntToStr(i)+IntToStr(j))).Parameters.Add('_Allowed='+mAllowedServiceTypes);
        end;
      end;
    end;
  end;
  CFxProfiler.ExitProc('postprovider', 'OnChangeContentType');
end;

//Pouze pro cargo
procedure OnChangeManipulationUnit(Sender: TObject);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  medPDMPRovider: TRollComboEdit;
  medPDMContentType : TNxMultiGridColumn;
  mPostProvider: TNxOID;
  mDataset: TDataset;
  i,mIndex: integer;
  mAllowedID: string;
begin
  mSite := TSiteForm(TNxMultiGridCustomRollColumn(Sender).Grid.Owner);
  mOS := mSite.BaseObjectSpace;
  medPDMPRovider := TRollComboEdit(mSite.FindChildControl(cedPDMPRovider));
  mPostProvider := medPDMPRovider.DataText;
  if not CFxOID.IsEmpty(mPostProvider) then begin
    if not Assigned( TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolManipulationUnit+IntToStr(cLayoutCargo) ) ) then
      continue;
    mAllowedID := GetAllowedManipulationUnits(mOS, mPostProvider);
    for i:= 0 to cLayoutContentCount-1 do
    begin
      mIndex := TNxMultiGridCustomRollColumn(TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolManipulationUnit+IntToStr(i))).Parameters.IndexOfName('_Allowed');
      if (mIndex <> -1) then
        TNxMultiGridCustomRollColumn(TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolManipulationUnit+IntToStr(i))).Parameters.Delete(mIndex);
      //if mAllowedServiceTypes <> '' then
      TNxMultiGridCustomRollColumn(TNxMultiGridCustomRollColumn(Sender).Grid.ColumnByName(ccolManipulationUnit+IntToStr(i))).Parameters.Add('_Allowed='+mAllowedID);
    end;
  end;
end;

//POKUD JIŽ EXISTUJÍ BALÍKY, PAK JE PODBARVENO BARVOU
procedure MGGetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer;
                                const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
  mDataSet: TDataset;
begin
  if Sender is TMultiGrid then begin
    mDataSet := TMultiGrid(Sender).DataSource.DataSet;
    if mDataSet.RecordCount > 0 then begin
      if mDataSet.FieldByName(cFDExistCount).AsInteger > 0 then
        ABckColor := clSkyBlue;
        //ABckColor := 16777184;
    end;
  end;
end;

procedure MGLayoutIndexNeeded(Sender : TObject; var Layout : integer);
var
  mDataSet: TDataset;
begin
  if Sender is TMultiGrid then begin
    mDataSet := TMultiGrid(Sender).DataSource.DataSet;
    case mDataSet.FieldByName(cFDTargetAddressType).AsInteger of
      cFromFirm, cFromFirmOffice: Layout := cLayoutFirm;
      cFromPerson: Layout := cLayoutPerson
    else
      Layout := cLayoutFirm;
    end;
  end;
end;

procedure edPDMProviderOnEnter(Sender: TObject);
var
  mList: TStringList;
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  i, mIndex: integer;
begin
  mList:= TStringList.create;
  try

    mSite := TSiteForm(TRollComboEdit(Sender).Owner);
    mOS := mSite.BaseObjectSpace;
    mOS.SQLSelect(cSQLAllowedPostDriver, mList);
    //for i:= 0 to mList.Count - 1 do
    //  mList[i] := QuotedStr(mList[i]);
    mList.Delimiter := ';';
    mIndex := TRollComboEdit(Sender).Parameters.IndexOf('_Allowed');
    if mIndex > -1 then
      TRollComboEdit(Sender).Parameters.Delete(mIndex);
    TRollComboEdit(Sender).Parameters.Add('_Allowed='+mList.DelimitedText);
  finally
    mList.Free;
  end;
end;

//předvyplní formulář před zobrazením
procedure PrefillHeaderDataSet(var AHeaderDataset: TDataSet; AOS:TNxCustomObjectSpace );
const
  cSQL2 = 'SELECT PostProvider_ID, Division_ID FROM PDMUsers PU JOIN PDMPostProviders PPP ON PPP.ID = PU.PostProvider_ID WHERE PPP.X_PD_IsLicensed = ''A'' and (PPP.X_PD_Driver > 0) and PU.SecurityUser_ID = ';
  cSQL3 = 'SELECT ID FROM DocQueues WHERE OutOfUse = ''N'' and DocumentType = ''P0''';
  cSQL4 = 'SELECT ID FROM PDMUsers WHERE SecurityUser_ID = ';
  cSQL5 = 'SELECT ID FROM BusOrders WHERE Closed = ''N'' and Hidden = ''N''';
  cSQL6 = 'SELECT ID FROM BusTransactions WHERE Closed = ''N'' and Hidden = ''N''';
  cSQL7 = 'SELECT ID FROM BusProjects WHERE Closed = ''N'' and Hidden = ''N''';
var
  mList: TStringList;
  mOS: TNxCustomObjectSpace;
  mStr: string;
  mContext:TNxContext;
begin
  CFxProfiler.EnterProc('postprovider', 'PrefillHeaderDataSet');
  mList:= TStringList.create;
  mContext:= NxCreateContext(AOS);
  try

    //mSite := AHeaderDataset.Site;
    mOS := AOS;


    AHeaderDataset.Edit;

    //predvyplneni poskytovatele pokud je jeden
    mOS.SQLSelect(cSQLAllowedPostDriver, mList);
    if (mList.Count = 1) then
      AHeaderDataset.FieldByName(cFDPDMProvider).AsString := mList[0];

    //predvyplneni radu pokud je jedna
    mOS.SQLSelect(cSQL3, mList);
    if (mList.Count = 1) then
      AHeaderDataset.FieldByName(cFDDocQueue).AsString := mList[0];

    //predvyplneni uzivatele pokud je jeden
    mOS.SQLSelect(cSQL4+QuotedStr(NxGetActualUserID(mOS)), mList);
    if (mList.Count = 1) then begin
      AHeaderDataset.FieldByName(cFDPDMUser).AsString := mList[0];
      if not CFxOID.IsEmpty(AHeaderDataset.FieldByName(cFDPDMUser).AsString) then begin
        //poskytovatele a stredisko beru z uzivatele
        mOS.SQLSelect(cSQL2+QuotedStr(NxGetActualUserID(mOS)), mList);
        if (mList.Count = 1) then begin
          mStr := mList[0];
          AHeaderDataset.FieldByName(cFDPDMProvider).AsString := NxTrapStr(mStr, ';');
          AHeaderDataset.FieldByName(cFDDivision).AsString := mStr;
        end;
      end;
    end;

    //predvyplneni datumu a období
    AHeaderDataset.FieldByName(cFDDate).AsDateTime := Date();
    AHeaderDataset.FieldByName(cFDPeriod).AsString := GetPeriodID(mOS, Date());

    //predvyplneni zakazky pokud je jedna
    mOS.SQLSelect(cSQL5, mList);
    if (mList.Count = 1) and (mContext.GetCompanyCache.BusOrdersUsage = 1) then
      AHeaderDataset.FieldByName(cFDBusOrder).AsString := mList[0];

    //predvyplneni obchodniho pripadu pokud je jeden
    mOS.SQLSelect(cSQL6, mList);
    if (mList.Count = 1) and (mContext.GetCompanyCache.BusTransactionsUsage = 1) then
      AHeaderDataset.FieldByName(cFDBusTransaction).AsString := mList[0];

    //predvyplneni projektu pokud je jeden
    mOS.SQLSelect(cSQL7, mList);
    if (mList.Count = 1) and (mContext.GetCompanyCache.BusProjectsUsage = 1) then
      AHeaderDataset.FieldByName(cFDBusProject).AsString := mList[0];

    SetPDMProviderDriver(mOS, AHeaderDataset);

    AHeaderDataset.Post;
  finally
    mList.Free;
    mContext.Free;
  end;
  CFxProfiler.ExitProc('postprovider', 'PrefillHeaderDataSet');
end;


//Zapne háčky po zobrazení okna balíky. V ImportManageru je tato logika nepotřebná. Děje se přímím voláním RunScript
procedure SetHeaderEvents(var AHeaderDataSet: TDataSet);
var
  mField: TField;
begin
  mField:= AHeaderDataSet.Fields.FindField(cFDPDMProvider);
  if mField <> nil then
    mField.OnChange := @FieldPDMProviderOnChange;
end;

//Zapne háčky po vytvoření datasetu
//Zapne se jenom pokud existuje alespoň jeden script v Balíky - nastavení s indexem 6
//NICETOHAVE - Šlo by ještě polepšit o nastavení políček, kde se tento háček bude vyhodnocovat. Takže až budou parametry parametrů.
procedure SetContentEvents(var AHeaderDataSet: TDataSet);
var
  mField: TField;
  mList: TStringList;
begin

  mList:=TStringList.Create();
  try
    if Assigned(AHeaderDataSet.Owner) and (AHeaderDataSet.Owner <> nil) then
      GetScripts(TSiteForm(AHeaderDataSet.Owner).BaseObjectSpace, cScriptAfterContentFieldChange, mList);

    if mList.Count > 0 then
    begin
      mField := nil;
      mField:= AHeaderDataSet.Fields.FindField(cFDWidth);
      if mField <> nil then
        mField.OnChange := @FieldsContentOnChange;

      mField := nil;
      mField:= AHeaderDataSet.Fields.FindField(cFDHeight);
      if mField <> nil then
        mField.OnChange := @FieldsContentOnChange;

      mField := nil;
      mField:= AHeaderDataSet.Fields.FindField(cFDLength);
      if mField <> nil then
        mField.OnChange := @FieldsContentOnChange;

      mField := nil;
      mField:= AHeaderDataSet.Fields.FindField(cFDVolume);
      if mField <> nil then
        mField.OnChange := @FieldsContentOnChange;

      mField := nil;
      mField:= AHeaderDataSet.Fields.FindField(cFDManipulationUnit);
      if mField <> nil then
        mField.OnChange := @FieldsContentOnChange;
    end;
  finally
    mList.Free;
  end;

end;


procedure FieldsContentOnChange(AField: TField);
var mOS:TNxCustomObjectSpace;
begin
  //RunScript -
  mOS := TSiteForm(AField.DataSet.Owner).BaseObjectSpace;
  RunScript_Content(mOS,AField.DataSet,AField, cScriptAfterContentFieldChange);
end;


//Zapne háčky po vytvoření datasetu
//Zapne se jenom pokud existuje alespoň jeden script v Balíky - nastavení s indexem 6
//NICETOHAVE - Šlo by ještě polepšit o nastavení políček, kde se tento háček bude vyhodnocovat. Takže až budou parametry parametrů.
procedure SetUserButtonEvent(ASite:TSiteForm;AParent: TWinControl;var APackagesDataSet, AHeaderDataSet, AContentDataSet: TDataSet; ALeft:Integer);
var
  mListButtons: TStringList;
  i,mLeft:Integer;
  mScript:String;
  mBtnControl: TSpeedButton;
begin

  mLeft := ALeft;

  mListButtons:=TStringList.Create();
  try
    GetScriptsButton(ASite.BaseObjectSpace, cScriptUserButton, mListButtons);

    for i :=0 to mListButtons.Count -1 do
    begin
      mScript := mListButtons.ValueFromIndex[i];
      mBtnControl:= TSpeedButton.Create(ASite);
      mBtnControl.Hint :=mScript;
      mBtnControl.Parent:= AParent;
      mBtnControl.Left:= mLeft;
      mBtnControl.Top:= 1;
      mBtnControl.Height:= 25;
      mBtnControl.Width:= 25;
      mBtnControl.Caption:= NxTrim(mListButtons.Names[i],'"');
      mBtnControl.Width := ASite.Canvas.TextWidth(NxTrim(mListButtons.Names[i],'"')) +15;
      mBtnControl.Flat:= True;
      //mBtnControl.Tag:= ObjToInt(dsContent.DataSet);
      //mBtnControl.ImageListName := 'DBNavigatorImages';
      //mBtnControl.ImageIndex := i;
      mBtnControl.onClick:= @btnPDUserButtonClick;
      mBtnControl.Name:= 'btnPDUserButton'+IntToStr(i);
      mLeft := mLeft +mBtnControl.Width +10;

    end;
  finally
    mListButtons.Free;
  end;

end;

procedure btnPDUserButtonClick(Sender: TSpeedButton);
var mOS:TNxCustomObjectSpace;
   mPackagesDataSet, mHeaderDataSet,mContentDataSet:TDataSet;
   mSite: TSiteForm;
begin
  //RunScript -
  mSite := TSiteForm(Sender.Owner);
  mOS := mSite.BaseObjectSpace;
  //Najít datsety
  mPackagesDataSet := TDataSource(mSite.FindComponent(cdsPackagesData)).DataSet;
  mHeaderDataSet := TDataSource(mSite.FindComponent(cdsHeaderData)).DataSet;
  mContentDataSet := TDataSource(mSite.FindComponent(cdsContent)).DataSet;
  CFxScriptingEngine.CallScript(Sender.Hint, [ObjToInt(mSite), ObjToInt(mPackagesDataSet), ObjToInt(mHeaderDataSet), ObjToInt(mContentDataSet), cScriptUserButton]);
end;





procedure AddAddressCols(var AMultiGrid: TMultiGrid; const ALayout: integer; ASender: Boolean);
var
  mSufix : String;
  mLine: Integer;
  c10: TNxMultiGridLookupColumn;
  c11: TNxMultiGridColumn;
  c12: TNxMultiGridColumn;
  c13: TNxMultiGridColumn;
  c14: TNxMultiGridColumn;
  c15: TNxMultiGridColumn;
  c16: TNxMultiGridColumn;
  c17: TNxMultiGridColumn;
begin
  mSufix := NxIIfStr(ASender, cFDSen,'' );
  mLine := NxIIfInt(ASender, 3,2 );

  c10 := TNxMultiGridLookupColumn.Create(AMultiGrid);
  c11 := TNxMultiGridColumn.Create(AMultiGrid);
  c12 := TNxMultiGridColumn.Create(AMultiGrid);
  c13 := TNxMultiGridColumn.Create(AMultiGrid);
  c14 := TNxMultiGridColumn.Create(AMultiGrid);
  c15 := TNxMultiGridColumn.Create(AMultiGrid);
  c16 := TNxMultiGridColumn.Create(AMultiGrid);
  c17 := TNxMultiGridColumn.Create(AMultiGrid);

  with c10 do
  begin
    Name := ccolTargetAddressType+mSufix+IntToStr(ALayout);
    Caption := lng_frm_TargetAddress;
    FieldName := cFDTargetAddressType+mSufix;
    Width := 80;
    Layout := ALayout;
    Line := mLine;
    Order := 0;
    Elastic := False;
    ReadOnly := False;
    Complete := False;
    CompleteMinLength := 0;
    Values.add(cFromFirmStr+'='+IntToStr(cFromFirm));
    Values.add(cFromFirmOfficeStr+'='+IntToStr(cFromFirmOffice));
    Values.add(cFromPersonStr+'='+IntToStr(cFromPerson));
  end;
  AMultiGrid.AddColumn(c10);

  with c11 do
  begin
    Name := ccolAdrName+mSufix+IntToStr(ALayout);
    if (ALayout = cLayoutFirm) then
      Caption := lng_frm_FirmName
    else
      Caption := lng_frm_PersonName;
    FieldName := cFDAdrName+mSufix;
    Width := 150;
    Layout := ALayout;
    Line := mLine;
    Order := 1;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c11);

  with c12 do
  begin
    Name := ccolAdrStreet+mSufix+IntToStr(ALayout);
    Caption := lng_frm_Street;
    FieldName := cFDAdrStreet+mSufix;
    Width := 150;
    Layout := ALayout;
    Line := mLine;
    Order := 2;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c12);

  with c13 do
  begin
    Name := ccolAdrCity+mSufix+IntToStr(ALayout);
    Caption := lng_frm_City;
    FieldName := cFDAdrCity+mSufix;
    Width := 150;
    Layout := ALayout;
    Line := mLine;
    Order := 3;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c13);

  with c14 do
  begin
    Name := ccolAdrPostCode+mSufix+IntToStr(ALayout);
    Caption := lng_frm_PostCode;
    FieldName := cFDAdrPostCode+mSufix;
    Width := 100;
    Layout := ALayout;
    Line := mLine;
    Order := 4;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c14);

  with c15 do
  begin
    Name := ccolAdrCountryCode+mSufix+IntToStr(ALayout);
    Caption := lng_frm_CountryCode;
    FieldName := cFDAdrCountryCode+mSufix;
    Width := 50;
    Layout := ALayout;
    Line := mLine;
    Order := 5;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c15);

  with c16 do
  begin
    Name := ccolAdrPhoneNumber+mSufix+IntToStr(ALayout);
    Caption := lng_frm_PhoneNumber;
    FieldName := cFDAdrPhoneNumber+mSufix;
    Width := 150;
    Layout := ALayout;
    Line := mLine;
    Order := 6;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c16);

  with c17 do
  begin
    Name := ccolPersonName+mSufix+IntToStr(ALayout);
    Caption := lng_frm_PersonName;
    FieldName := cFDPersonName+mSufix;
    Width := 150;
    Layout := ALayout;
    Line := mLine;
    Order := 7;
    Elastic := False;
    ReadOnly := True;
    Complete := False;
    CompleteMinLength := 0;
  end;
  AMultiGrid.AddColumn(c17);
end;


begin
end.