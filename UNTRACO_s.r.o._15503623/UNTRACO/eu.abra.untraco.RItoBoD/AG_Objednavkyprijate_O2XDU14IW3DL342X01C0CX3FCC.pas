uses 'eu.abra.untraco.RItoBoD.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2,mBut3: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := '+ Vytvořit DL';
mBut.Category := 'tabList';
mBut.OnExecute := @CreateBOD;
mBut2:= Self.GetNewAction;
mBut2.ShowControl := True;
mBut2.ShowMenuItem := True;
mBut2.Caption := '+ Vytvoř OV';
mBut2.Category := 'tabList';
mBut2.OnExecute := @CreateIO;
mBut2:= Self.GetNewAction;
mBut2.ShowControl := True;
mBut2.ShowMenuItem := True;
mBut2.Caption := '+ Uvolni ceny';
mBut2.Category := 'tabList';
mBut2.OnExecute := @ChangeDisc;


end;




procedure CreateBDEnabled(Sender: TObject);
var
  mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := Assigned(TDynSiteForm(mSite).CurrentObject)
      end;
    end;
  end;
end;



//vlastní vytvoření objednávky
procedure CreateBoD(Sender: TObject);
var
  mSite: TSiteForm;
  mReceivedOrder,mRow, mStoreCard, mStore:TNxCustomBusinessObject;
  mCollRows: TNxCustomBusinessMonikerCollection;
  i,j: Integer;
  mList: TStringList;
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mStoreSubcardQuantity:Extended;
begin
 if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
    if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit dodací listy v agendě pohyby objednávek přijatých?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
      mReceivedOrder:= TDynSiteForm(mSite).CurrentObject;
        mSite.ShowSite('T2FWDKF0NSSOBC2KLELLUBPBXW', True, 'QueryByUserDynSQLCondition;A.Parent_ID='+QuotedStr(mReceivedOrder.OID)+' and a.quantity-a.deliveredquantity>0;Omezení za nedodané');

    end;

    RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));

  end;
 end;
end;

procedure CreateIO(Sender: TObject);
var
  mSite: TSiteForm;
  mReceivedOrder,mRow, mStoreCard, mStore:TNxCustomBusinessObject;
  mCollRows: TNxCustomBusinessMonikerCollection;
  i,j: Integer;
  mList: TStringList;
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mStoreSubcardQuantity:Extended;
begin
 if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
    if NxMessageBox('Dotaz', 'Přejete si zobrazit data v agendě pohyby objednávek přijatých?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
      mReceivedOrder:= TDynSiteForm(mSite).CurrentObject;
        mSite.ShowSite('T2FWDKF0NSSOBC2KLELLUBPBXW', True, 'QueryByUserDynSQLCondition;A.Parent_ID='+QuotedStr(mReceivedOrder.OID)+';Omezení pro tvorbu OV');

    end;

    RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));

  end;
 end;
end;

procedure ChangeDisc(Sender: TObject);
var
  mSite: TSiteForm;
  mReceivedOrder,mRow, mStoreCard, mStore:TNxCustomBusinessObject;
  mCollRows: TNxCustomBusinessMonikerCollection;
  i,j: Integer;
  mList: TStringList;
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mStoreSubcardQuantity:Extended;
begin
 if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
    if NxMessageBox('Dotaz', 'Přejete si uvolnit ceny?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
     mReceivedOrder:=TDynSiteForm(mSite).CurrentObject;
     mReceivedOrder.SetFieldValueAsBoolean('FrozenDiscounts',False);
     mReceivedOrder.save;
    end;
    RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));

  end;
 end;
end;




begin
end.
