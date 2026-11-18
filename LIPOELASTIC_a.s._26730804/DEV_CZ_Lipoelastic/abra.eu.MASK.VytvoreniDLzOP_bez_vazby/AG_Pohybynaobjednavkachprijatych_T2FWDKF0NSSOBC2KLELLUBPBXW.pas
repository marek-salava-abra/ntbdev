

{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUser: TNxCustomBusinessObject;
  mC: TControl;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
       {  if not(mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Hint := '';
                mMAction.Caption := 'Nový DL bez vazby';
                mMAction.Items.Add('Vytvoření nového dodacího listu bez vazby FV');
                mMAction.Category := 'tabList';
                mMAction.OnExecuteItem := @NewBilOFDeliveryClick;


                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Hint := '';
                mMAction.Caption := 'Nová OV3';
                mMAction.Items.Add('Vytvoření nové OV3 customize');
                mMAction.Category := 'tabList';
                mMAction.OnExecuteItem := @NewOVClick;
         end;  }
   finally
      muser.free;
   end;
end;




procedure NewBilOFDeliveryClick(sender: TBasicAction;index: Integer);
var
  mBO_row : TNxCustomBusinessObject;
  i:integer;
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mBookmark : TBookmarkList;
  Pot_zaznam : string;
  Xresult:Boolean;
  Pocet_zaznamu:integer;
  opakovani:integer;
  mStore_id:string;
  mDocQueue_ID:string;
  mHead1: TNxCustomBusinessObject;
  mHead : TNxHeaderBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
    mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO_Row := TDynSiteForm(mSite).CurrentObject;
    if mBookmark.count=0 then Pocet_zaznamu:=1;
    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count;
    Pot_zaznam:='';
    Xresult:= (InputQuery('Nastavení', 'Vyberte sklad pro DL 88/99',Pot_zaznam));
    if ((pot_zaznam<>'88') and (pot_zaznam<>'99')) and (Xresult=True) then begin
        ShowMessage('Sklad musí být uveden kódem 88 nebo 99');
        Xresult:= false;
    end ;
    if Xresult= false then  exit;
    if (Pot_zaznam='88') or (Pot_zaznam='99') then begin
        if (Pot_zaznam='88') then begin
            mStore_id:='1K10000101';
            mDocQueue_ID:='HA10000101';
        end;
        if (Pot_zaznam='99') then begin
            mStore_id:='1U00000101';
            mDocQueue_ID:='6C10000101';
        end;
        if mBookmark.Count = 0 then begin
            opakovani:=mBookmark.Count;
        end;
        if mBookmark.Count >0 then opakovani:=mBookmark.Count-1;
            mHead1:= TDynSiteForm(mSite).CurrentObject;
            mHead := TNxHeaderBusinessObject(mHead1.ObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4'));
            mHead.New;
            mHead.Prefill;
            mHead.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID);
            for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
                if mBookmark.Count > 0 then begin
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO_Row := TDynSiteForm(mSite).CurrentObject;
                end else begin
                    mBO_Row := TDynSiteForm(mSite).CurrentObject;
                end;
                mRow := mhead.Rows.AddNewObject;
                mRow.Prefill;
                mRow.SetFieldValueAsInteger('RowType',3); //Typ radku je 1
                mRow.SetFieldValueAsString('Store_ID',mStore_id); //text bude  ...
                mRow.SetFieldValueAsString('Storecard_ID',mBO_row.GetFieldValueAsString('Storecard_ID')); //text bude  ...
                mRow.SetFieldValueAsString('BusOrder_ID',mBO_row.GetFieldValueAsString('BusOrder_ID')); //text bude  ...
                mRow.SetFieldValueAsFloat('Quantity',mBO_row.GetFieldValueAsFloat('Quantity')); //text bude  ...
                mRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Store_ID.X_BusDivision_ID'));
                mRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('StoreCard_ID.X_Obchodni_pripad'));
            end;
            mHead.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID);
            mHead.save ;
        end;
        mhead.free;
end;



procedure NewOVClick(sender: TBasicAction;index: Integer);
var
  mBO_row : TNxCustomBusinessObject;
  i:integer;
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mBookmark : TBookmarkList;
  Pot_zaznam : string;
  Xresult:Boolean;
  Pocet_zaznamu:integer;
  opakovani:integer;
  mStore_id:string;
  mDocQueue_ID:string;
  mHead1: TNxCustomBusinessObject;
  mHead : TNxHeaderBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
    mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO_Row := TDynSiteForm(mSite).CurrentObject;
    if mBookmark.count=0 then Pocet_zaznamu:=1;
    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count;


            mStore_id:='2J10000101';
            mDocQueue_ID:='8B10000101';

        if mBookmark.Count = 0 then begin
            opakovani:=mBookmark.Count;
        end;
        if mBookmark.Count >0 then opakovani:=mBookmark.Count-1;
            mHead1:= TDynSiteForm(mSite).CurrentObject;
            mHead := TNxHeaderBusinessObject(mHead1.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC'));
            mHead.New;
            mHead.Prefill;
            mHead.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID);
            //mHead.SetFieldValueAsString('Firm_ID', mHead1.getFieldValueAsString('Firm_ID'));
            for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
                if mBookmark.Count > 0 then begin
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO_Row := TDynSiteForm(mSite).CurrentObject;
                end else begin
                    mBO_Row := TDynSiteForm(mSite).CurrentObject;
                end;
                if mBO_row.GetFieldValueAsString('X_ExternalSpecification')<>'' then begin
                    mRow := mhead.Rows.AddNewObject;
                    mRow.Prefill;
                    mRow.SetFieldValueAsInteger('RowType',3); //Typ radku je 1
                    mRow.SetFieldValueAsString('Store_ID',mStore_id); //text bude  ...
                    mRow.SetFieldValueAsString('Storecard_ID',mBO_row.GetFieldValueAsString('Storecard_ID')); //text bude  ...
                    mRow.SetFieldValueAsString('X_ExternalSpecification',mBO_row.GetFieldValueAsString('X_ExternalSpecification')); //text bude  ...
                    mRow.SetFieldValueAsString('BusOrder_ID',mBO_row.GetFieldValueAsString('BusOrder_ID')); //text bude  ...
                    mRow.SetFieldValueAsFloat('Quantity',mBO_row.GetFieldValueAsFloat('Quantity')); //text bude  ...
                    mRow.SetFieldValueAsString('Division_ID',mRow.GetMonikerForFieldCode(mRow.GetFieldCode('Store_ID')).BusinessObject.GetFieldValueAsString('X_BusDivision_ID'));
                    mRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetMonikerForFieldCode(mRow.GetFieldCode('StoreCard_ID')).BusinessObject.GetFieldValueAsString('X_Obchodni_pripad'));
                end;
            end;
            mHead.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID);
            mHead.save ;

        mhead.free;
end;


begin
end.