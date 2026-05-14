uses '_Knihovny_ALL.Firms_params';
//'_Knihovny_ALL.Progress',
//      '_Knihovny_ALL.Parse';


var
  gProgressForm : TForm;
  mShowProgres:boolean;


  procedure UkonceniPrubehu;
begin
  gProgressForm.Close();
end;

  procedure onDetailExec(Sender: TAction; Index: integer);
var
  msite:TDynSiteForm;
  mTabList: TTabSheet;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i : integer;
  mBO : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
begin
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    //DBGrid :=    TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(msite).MainPanel, 'grdRows'));
//    if mDBGrid = nil then
//        RaiseException('DBGrid nenalezen');


  mForm := TForm.Create(Sender);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Width := 240;  // sirka
  mForm.Height := 170; // vyska
  mForm.Caption := 'Nastanení skladu';

  //mLbl := TLabel.Create(mForm);
  //mLbl.Caption := 'Sklad:';
  //mLbl.Left := 30;
  //mLbl.Top := 10;
  //mLbl.Name := 'lblStore';
  //mForm.InsertControl(mLbl);

  //    cbStores := TComboBox.Create(mForm);
  //    cbStores.Left := 100;
  //    cbStores.Top := 10;
  //    cbStores.Width := 80;
  //    cbStores.Name := 'cbStore';
  //    cbStores.Text := '';
  //    mForm.InsertControl(cbStores);
      //iFillStores(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, cbStores.Items);
  //    if cbStores.Items.Count >= 0 then begin
  //      cbStores.ItemIndex := 0;
  //    end;


  mRg := TRadioGroup.Create(mForm);
  mRg.Left := 15;
  mRg.Top := 40;
  mRg.Height := 60;
  mRg.Caption := 'Pro řádky';
  mRg.Name := 'rgChoiceRows';

  mRbS := TRadioButton.Create(mRg);
  mRbS.Name := 'rbSelected';
  mRbS.Caption := 'označené';
  mRbS.Checked := True;
  mRbS.Left := 50;
  mRbS.Top := 20;
  mRg.InsertControl(mRbS);

  mRbA := TRadioButton.Create(mRg);
  mRbA.Name := 'rbAll';
  mRbA.Caption := 'všechny';
  mRbA.Left := 50;
  mRbA.Top := 40;
  mRg.InsertControl(mRbA);

  mForm.InsertControl(mRg);

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

  if mForm.ShowModal(tform) = mrOK then begin


  try
      if mRbS.Checked then begin
        mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(NxFindSiteForm(Sender)).MainPanel, 'grdRows'));
        mBookmark := mDBGrid.SelectedRows;
        if Assigned(mBookmark) and (mBookMark.Count > 0) then begin
          mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;
          for i := 0 to mBookMark.Count - 1 do begin
            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
            mDBGrid.DataSource.DataSet.Edit;
               NxShowSimpleMessage(mDBGrid.DataSource.DataSet.FieldByName('Store_ID').AsString,nil);
          //  mDBGrid.DataSource.DataSet.FieldByName('Store_ID').AsString := '');

//            mStore

            mDBGrid.DataSource.DataSet.Cancel;
          end;
          mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
        end
      end;


      if mRbA.Checked then begin    // všechny řádky na dokladu pomocí BO
        mBO := TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
        mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
        for i := 0 to mMon.Count - 1 do begin
         // mMon.BusinessObject[i].SetFieldValueAsString('Store_ID', iGetIDByCode(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, 'Stores', cbStores.Text));
//  mStore

        end;
        if Assigned(mDBGrid) then
          mDBGrid.DataSource.DataSet.Refresh;
      end;



  finally
     begin
     end;
  end;



  end;
end;


procedure onListExec(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,mBookmarkIndex,mRowIndex,mBatchIndex:integer;
 mBookmarkIndexAll,mRowIndexALL,mBatchIndexALL:integer;
 mForm: TDynSiteForm;
 mBookmark:TBookmarkList;
 mMonRows,mMonBatchs:TNxCustomBusinessMonikerCollection;
begin
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmarkIndex:=0;
    mRowIndex:=0;
    mBatchIndex:=0;
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    VytvoreniPrubehu(msite, 'Označené záznamy',3,
                          'Doklad',mBookmarkIndex,mBookmark.Count,
                          'Řádek',mRowIndex,120,
                          'Šarže',mBatchIndex,5,
                           );

    if mBookmark.count>0 then begin                                 // ****** pro více dokladů
        for mBookmarkIndex := 0 to mBookmark.Count- 1 do begin
        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mBookmarkIndex));
         Prubeh(mBookmarkIndex, mBookmark.Count,
                  mRowIndex,0,
                  mBatchIndex,0);


    end;

          // *************************  řádky
          mMonRows := TDynSiteForm(msite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(msite).CurrentObject.GetFieldCode('ROWS'));
          for mRowIndex:= 0 to mMonRows.count -1 do begin
                  // ********************************  šarže
                    if true and ((mMonRows.BusinessObject[mRowIndex].GetFieldValueAsinteger('Storecard_ID.Category')=1) or
                                 (mMonRows.BusinessObject[mRowIndex].GetFieldValueAsinteger('Storecard_ID.Category')=2)) then begin //pokud je karta šaržová
                                      mMonBatchs := mMonRows.BusinessObject[mRowIndex].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[mRowIndex].GetFieldCode('DocRowBatches'));
                                      for mBatchIndex:= 0 to mMonBatchs.count -1 do begin
                                             Prubeh(mBookmarkIndex, mBookmark.Count,
                                                    mRowIndex,mMonBatchs.count,
                                                    mBatchIndex,0);



                                          //Prubeh('Doklad',mBookmarkIndex,mBookmark.Count, mBookmarkIndexAll,
                                          //               'Řádek',mRowIndex,mMonRows.Count,mRowIndexAll,
                                          //               'Šarže',mBatchIndex,mMonbatchs.count,mBatchIndexAll);
                                      end;

                                //  mBOBatch:=mBORow.GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[mRowIndex].CurrentObject.GetFieldCode('DocRowBatches')).AddNewObject;

                    end;
                          //    NxShowSimpleMessage(TDynSiteForm(mSite).CurrentObject.oid,nil);

          end;

    if mBookmark.count>0 then begin                                 // ****** pro více dokladů
             end;
    end;

//UkonceniPrubehu()

end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Hromadná změna';
  mmAction.Hint := 'OnExec';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Pomocí BO Logiky');
  mMAction.Items.Add('Přímý zápis do databáze');
  mmAction.OnExecute:= @onListExec;

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Hromadná změna na řádcích';
  mmAction.Hint := 'OnExec';
  mmAction.Category := 'tabDetail';
  mMAction.Items.Add('Pomocí BO Logiky');
  mMAction.Items.Add('Přímý zápis do databáze');
  mmAction.OnExecute:= @onDetailExec;

end;





procedure ProgressSetMax(aValue,aValue1,aValue2: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Max:= aValue;
  TProgressBar(gProgressForm.FindChildControl('prgBar1')).Max:= aValue1;
  TProgressBar(gProgressForm.FindChildControl('prgBar2')).Max:= aValue2;
end;

procedure Prubeh(aValue,AMax: Integer;
                  aValue1,AMax1: Integer;
                  aValue2,AMax2: Integer);
var
  mPrg: TProgressBar;
  mPrg1: TProgressBar;
  mPrg2: TProgressBar;
begin
  mPrg := TProgressBar(gProgressForm.FindChildControl('prgBar'));
  mPrg.Position:= aValue + 1;
  TLabel(gProgressForm.FindChildControl('lblCountProc')).Caption:= IntToStr(NxFloor((AValue/AMax)*100))+' %';
  TLabel(gProgressForm.FindChildControl('lblQuantity')).Caption:= inttostr(AValue)+'/'+inttostr(AMax);
  mPrg.Repaint;

  mPrg1 := TProgressBar(gProgressForm.FindChildControl('prgBar1'));
  mPrg1.Position:= aValue1 + 1;
  TLabel(gProgressForm.FindChildControl('lblCountProc1')).Caption:= IntToStr(NxFloor((AValue1/AMax1)*100))+' %';
  TLabel(gProgressForm.FindChildControl('lblQuantity1')).Caption:= inttostr(AValue1)+'/'+inttostr(AMax1);
  mPrg1.Repaint;

  mPrg2 := TProgressBar(gProgressForm.FindChildControl('prgBar'));
  mPrg2.Position:= aValue2 + 1;
  TLabel(gProgressForm.FindChildControl('lblCountProc2')).Caption:= IntToStr(NxFloor((AValue2/AMax2)*100))+' %';
  TLabel(gProgressForm.FindChildControl('lblQuantity2')).Caption:= inttostr(AValue2)+'/'+inttostr(AMax2);
  mPrg2.Repaint;
  gProgressForm.Refresh();
  gProgressForm.BringToFront();







  Application.ProcessMessages();
end;


  function CreateProgressInfo(AForm: TForm; AProcCount: Integer; AInfo: string): TForm;
var
  mForm: TForm;
  mProgr: TProgressBar;
  mLabel: TLabel;
begin
  mForm := TForm.Create(AForm);
  with mForm do begin
    Width := 760;
    Height := 50;
    Caption := 'Prubeh zpracovani';
    Position := poScreenCenter;//OwnerFormCenter;
    FormStyle := fsStayOnTop;
    BorderStyle := bsDialog;
    with TLabel.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 16;
      Width := 600;
      Height := 32;
      //AutoSize := False;
      Name := 'lblInfoLabel';
      Caption := AInfo;
      Transparent := True;
      //WordWrap := True;
      Font.Height := -26;
      Font.Style := [fsBold];
      Tag := 3;
    end;
    with TProgressBar.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 48;
      Width := 706;
      Height := 66;
      Tag := 3;
      Name := 'pgInfoBar';
      Max := AProcCount;
      Position := 0;
    end;
  end;
  Result := mForm;
end;



procedure VytvoreniPrubehu(ASite : TSiteForm;ACaption : string;APruhu:integer;
                           AName:string;AActual,AMax:integer;
                           AName1:string;AActual1,AMax1:integer;
                           AName2:string;AActual2,AMax2:integer;
                           );
begin
  gProgressForm:= TForm.Create(ASite);
  gProgressForm.BorderStyle:= bsToolWindow;
  gProgressForm.top:= poScreenCenter-200;
  gProgressForm.left:= poScreenCenter-200;

  gProgressForm.FormStyle := fsStayOnTop;
  //gProgressForm.ClientWidth:= 240;
  //gProgressForm.ClientHeight:=  80;
  gProgressForm.Width:= 350;
  gProgressForm.Height:= (APruhu * 30) + 40;

  gProgressForm.Caption := ACaption;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= 20;
    Width:= gProgressForm.Width - 50;
    Name:= 'prgBar';
    Max := amax;
  end;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= 50;
    Width:= gProgressForm.Width - 50;
    Name:= 'prgBar1';
    Max := amax1;
  end;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= 80;
    Width:= gProgressForm.Width - 50;
    Name:= 'prgBar2';
    Max := amax2;
  end;



  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 100;
    Top:= 8;
    autosize := true;
    Name:= 'lblQuantity';
    Caption := inttostr(AActual)+'/'+inttostr(AMax);
  end;

  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 100;
    Top:= 38;
    autosize := true;
    Name:= 'lblQuantity1';
    Caption :=  inttostr(AActual1)+'/'+inttostr(AMax1);
  end;
  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 100;
    Top:= 68;
    autosize := true;
    Name:= 'lblQuantity2';
    Caption :=  inttostr(AActual2)+'/'+inttostr(AMax2);
  end;


  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 250;
    Top:= 8;
    autosize := true;
    Name:= 'lblTime';
    Caption := '16:14';
  end;

  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 250;
    Top:= 38;
    autosize := true;
    Name:= 'lblTIme1';
    Caption := '15:20';
  end;
  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 250;
    Top:= 68;
    autosize := true;
    Name:= 'lblTime2';
    Caption := '18:20';
  end;






  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= gProgressForm.ClientWidth - 40;
    Top:=  20;
    autosize := true;
    Name:= 'lblCountProc';
    Caption := NxFloatToIBStr(int((AActual/AMax) * 100))+'%';
  end;
  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= gProgressForm.ClientWidth - 40;
    Top:= 50;
    autosize := true;
    Name:= 'lblCountProc1';
    Caption := NxFloatToIBStr(int((AActual1/AMax1) * 100))+'%';
  end;
  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= gProgressForm.ClientWidth - 40;
    Top:= 80;
    autosize := true;
    Name:= 'lblCountProc2';
    Caption := NxFloatToIBStr(int((AActual2/AMax2) * 100))+'%';
  end;





  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 5;
    Top:= 8;
    autosize := true;
    Name:= 'lblText';
    Caption := 'Doklad';
  end;

  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 5;
    Top:= 38;
    autosize := true;
    Name:= 'lblText1';
    Caption := 'Řádek';
  end;
  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 5;
    Top:= 68;
    autosize := true;
    Name:= 'lblText2';
    Caption := 'Šarže';
  end;

  gProgressForm.Show;
  Application.ProcessMessages();
end;


begin
end.




