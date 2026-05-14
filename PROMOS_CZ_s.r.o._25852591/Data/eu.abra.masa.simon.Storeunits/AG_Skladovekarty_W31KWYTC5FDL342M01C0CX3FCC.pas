procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin


  mAct := Self.GetNewAction;
  mAct.Caption := '##Změna MOQ##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ChangeMOQ;

  {mAct := Self.GetNewAction;
  mAct.Caption := '##Změna POS##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ChangePOS;}
end;

procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka,mMGColVychystano,mMGColDeliveredQuantity: TNxMultiGridColumn;
  mMGColRoll: TNxMultiGridColumn;
  b: Boolean;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin
mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdUnits'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
    if mMG.Columns[i].FieldName = 'X_MOQ' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_MOQ', ftFloat, 0, False, 103);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'MOQ', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_MOQ';
            FieldKind:= fkData;
          end;
      iPreparePosition(0, 0, 3);
      mMGColRoll:= (TNxMultiGridColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_MOQ';
      mMGColRoll.Caption := 'Min. obj.';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 0;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 3;
      mMG.AddColumn(mMGColRoll);
    end;
 end;
end;

Procedure ChangePOS(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k, mResult:integer;
 mBO, mUnitBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 mSelectedList:TStringList;
 mMOQ:Extended;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 k:=mSelectedList.Count;
 WaitWin.StartProgress('Čekejte, prosím ...', '', k);
 for i:=0 to mSelectedList.count-1 do begin
    mBO:=mOS.CreateObject(Class_StoreCard);
    mBO.Load(mSelectedList.Strings[i],nil);
    mPictures:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
    for j:=0 to mPictures.count-1 do mPictures.BusinessObject[j].SetFieldValueAsInteger('PosIndex',j+1);
    mbo.save;
    mbo.free;
    WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
    WaitWin.StepIt;
   end;
  WaitWin.Stop;
end;

Procedure ChangeMOQ(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k, mResult:integer;
 mBO, mUnitBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mSelectedList:TStringList;
 mMOQ:Extended;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete změnit minimální objednací množství na '+IntToStr(mSelectedList.count)+' kartách?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
      mMOQ:=1;
      mResult:=0;
      if GetMOQ(mSite, mMOQ, mResult) then begin
           if mResult=1 then begin
              k:=mSelectedList.Count;
              WaitWin.StartProgress('Čekejte, prosím ...', '', k);
              for i:=0 to mSelectedList.Count-1 do begin
                mBO:=mOS.CreateObject(Class_StoreCard);
                mBO.Load(mSelectedList.Strings[i],nil);
                mUnits:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
                for j:=0 to mUnits.count-1 do begin
                   mUnitBO:=mUnits.BusinessObject[j];
                   if mUnitBO.GetFieldValueAsString('Code')='ks' then mUnitBO.SetFieldValueAsFloat('X_MOQ',mMOQ);
                end;
                mBO.save;
                mBO.free;
                WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
                WaitWin.StepIt;
              end;
              WaitWin.Stop;
              TBusRollSiteForm(mSite).RefreshData;
              TBusRollSiteForm(mSite).DataSet.SeekID(mSelectedList.Strings[i]);
              NxShowSimpleMessage('Provedeno',mSite);
           end;
      end;
   end;
 end;
end;

Function GetMOQ(var ASite : TSiteform; var aMOQ:Extended;var aResult:integer;):Boolean;
var
    mLabel1: TLabel;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
begin
 if ASite <> nil then begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 125;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Data pro MOQ:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Objednací množství:';
    mLabel1.Top := 12;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;


    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := 10;
    mNumEd.Width := 80;
    mNumEd.Value := aMOQ;
    mNumEd.DecimalPlaces:=0;
    mNumEd.Parent := mForm;



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 50;
    mButOk.Left := 252;
    mButOk.Default := True;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 50;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then
         aResult:=1;
         aMOQ:=mNumEd.Value;
         Result:=true;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.