  uses 'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.const',
       'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.funkce';












procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
   mMAction: TMultiAction;
begin

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Logistik';
  mMAction.Hint := 'Operace logistika';
  mMAction.Category := 'tabList';
//  mMAction.OnUpdate := @LogistikOnUpdate;
  mMAction.OnExecuteItem := @LogistikExecuteItem;
  mMAction.Items.Add('Přeobjednat u dodavatele');
  mMAction.Items.Add('Termíny u dodavatele');
  mMAction.Items.Add('Odeslat technikovi');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Označit skladem';
  mMAction.Hint := 'Položky označí tak, aby se neobjednávaly';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @StoreStateExecuteItem;
  mMAction.Items.Add('Označit skladem');


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Stavy na skladech';
  mMAction.Hint := 'Aktualizuje stav na skladě';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @StoreExecuteItem;
  mMAction.Items.Add('Bez ohledu na ostatní ML');
  mMAction.Items.Add('S ohledem na ostatní ML');
end;

procedure LogistikExecuteItem(Sender: TAction; Index: integer);
var
  mSite : TSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr:Tstringlist;

  mList: TStringList;
  mText: string;
  result:string;
  mParams : TNxParameters;
      mBookmark : TBookmarkList;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mForm: TDynSiteForm;
     mBO_target: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  ABO,mRow, mNewRow: TNxCustomBusinessObject;


    mfind:boolean ;
begin

mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mForm := TComponent(Sender).DynSite;
    try
                abo := TDynSiteForm(mSite).CurrentObject;


                if index=0 then begin
                     try
                             mlist:=TStringList.create;

                               if (TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID')='1Q10000101') and
                                 (TDynSiteForm(mSite).CurrentObject.GetFieldValueAsBoolean('Closed')=false)
                                     then begin
                      //            NewOV(TDynSiteForm(mSite).CurrentObject,mBookmark,mform);


                              result := '';
                                            try
                                              mBO_target := ABO.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                              mBO_target.New;
                                                mBO_target.Prefill;
                                                mBO_target.SetFieldValueAsString('Firm_ID', 'CXC0000101');
                                                if not NxIsBlank(ABO.GetFieldValueAsString('U_Provozovatel_id')) then mBO_target.SetFieldValueAsString('U_Provozovatel_id', ABO.GetFieldValueAsString('U_Provozovatel_id'));
                                                mBO_target.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
                                                mBO_target.SetFieldValueAsString('DocQueue_ID', '7J00000101');
                                                            if mBookmark.count=0 then begin
                                                               mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
                                                               for i := 0 to mMon.Count-1 do begin
                                                                  mRow := mMon.BusinessObject[i];
                                                                  mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                                                  if mrow.GetFieldValueAsFloat('Quantity') -mrow.GetFieldValueAsFloat('DeliveredQuantity') - mrow.GetFieldValueAsFloat('X_skladem')>0 then begin
                                                                          mr:=tstringlist.create;
                                                                          mBO_target.ObjectSpace.SQLSelect('Select io2.ID from issuedorders2 IO2 left join issuedOrders IO on io.id=io2.parent_id where io.docqueue_ID=' + quotedstr('7J00000101') +
                                                                           ' and io2.X_parent_id=' + quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                                                           if mr.count>0 then begin
                                                                            mfind:=true;
                                                                           end else begin
                                                                              mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
                                                                           end;
                                                                           mr.free;
                                                                  end;
                                                                end;
                                                             end else begin
                                                                 mList := TStringList.Create;
                                                                 for ii := 0 to mbookmark.Count-1 do begin
                                                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(ii));
                                                                        ABO:= TDynSiteForm(mSite).CurrentObject;
                                                                       mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
                                                                       for i := 0 to mMon.Count-1 do begin
                                                                          mRow := mMon.BusinessObject[i];
                                                                          mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                                                          if mrow.GetFieldValueAsFloat('Quantity') -mrow.GetFieldValueAsFloat('DeliveredQuantity') - mrow.GetFieldValueAsFloat('X_skladem')>0 then begin
                                                                                  mr:=tstringlist.create;
                                                                                  mBO_target.ObjectSpace.SQLSelect('Select io2.ID from issuedorders2 IO2 left join issuedOrders IO on io.id=io2.parent_id where io.docqueue_ID=' + quotedstr('7J00000101') +
                                                                                   ' and io2.X_parent_id=' + quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                                                                   if mr.count>0 then begin
                                                                                    mfind:=true;
                                                                                   end else begin
                                                                                      mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
                                                                                   end;
                                                                                   mr.free;
                                                                          end;
                                                                        end;
                                                                 end;
                                                             end;

                                     mfind:=false;
                                        mList.Sort;
                                        if mfind then NxShowSimpleMessage('Pozor, operace již byly provedena dříve, budou dohrány pouze nové položky',nil);
                                        mfind:=true;
                                        mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
                                              for i := 0 to mList.Count-1 do begin
                                                    mRow := TNxCustomBusinessObject(mList.Objects[i]);
                                                      // dohrání rozdílů
                                                      mr:=tstringlist.create;
                                                      mBO_target.ObjectSpace.SQLSelect('Select io2.id from issuedorders2 IO2 left join issuedOrders IO on io.id=io2.parent_id where io.docqueue_ID=' + quotedstr('7J00000101') +
                                                        ' and io2.X_parent_id=' + quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                                        if mr.count=0 then begin
                                                               if (mRow.GetFieldValueAsInteger('RowType')=3)  then begin
                                                                  mNewRow := mMon.AddNewObject;
                                                                  mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
                                                                  mNewRow.SetFieldValueAsString('Store_ID', 'M000000101');
                                                                  mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                                  mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                  mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                                                                  mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                  mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                                                                  mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                                  mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                  mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
                                                                  mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('X_parent_ID'));
                                                                  if not NxIsBlank(mRow.GetFieldValueAsString('X_Description')) then mNewRow.SetFieldValueAsString('X_Description', mRow.GetFieldValueAsString('X_Description'));

                                                                  mfind:=False;
                                                              end;
                                                        end;
                                                        mr.free;
                                              end;
                                      TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mForm.SiteContext, mBO_target);
                                      finally

                                           mBO_target.Free;
                                      end;
                              end else begin
                                  NxShowSimpleMessage('Operace přeobjednání je možná pouze pro nevyčerpané objednávky a pouze na řadě OOD',nil);
                                end;

                        finally
                           mlist.Free;
                        end

                 end;

                  if index=1 then begin
                     // termíny u dodavatele - Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
                  end;
                  if index=2 then begin
                      if (TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID')='1Q10000101') and
                         (TDynSiteForm(mSite).CurrentObject.GetFieldValueAsBoolean('Closed')=false)
                       then begin
                          NewPRV(TDynSiteForm(mSite).CurrentObject);
                      end else begin
                          NxShowSimpleMessage('Operace převedení je možná pouze pro nevyčerpané objednávky a pouze na řadě ODD',nil);
                      end;
                  end;
       finally
          abo.Free;
       end;

 end;


 procedure StoreStateExecuteItem(Sender: TAction; Index: integer);
var
 mSite: TDynSiteForm;
begin
      mSite := TComponent(Sender).DynSite;
      NxShowSimpleMessage('Tato funkce zatím není podporována',nil);
 end;


procedure StoreExecuteItem(Sender: TAction; Index: integer);
var
 mSite: TDynSiteForm;
begin
      mSite := TComponent(Sender).DynSite;
      if index=0 then begin
         Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
      end;

      if index=1 then begin
         Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
      end;
      if index=2 then begin
         Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
      end;

 end;



procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
   mMGColRoll:TNxMultiGridColumn;
//   TNxMultiGridObjectRollColumn;
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
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_skladem' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_skladem', ftFloat, 0, False, 002);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'quantity', False) do begin
        ReadOnly:= False;
        FieldName:= 'X_skladem';
        FieldKind:= fkData;
      end;
      iPreparePosition(3, 0, 4);
      mMGColRoll:= (TNxMultiGridColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_skladem';
      mMGColRoll.Caption := 'Korekce obj.';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := True;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 13;
      mMGColRoll.Kind := ckUser;
      mMG.AddColumn(mMGColRoll);
    end;
  end;


end;




function FindColumnByFieldName(ASiteForm: TSiteForm; AFieldName: String): TNxMultiGridColumn;
var
  mMG: TMultiGrid;
  i: Integer;
begin
  Result := nil;
  mMG := TMultiGrid(NxFindChildControl(ASiteForm.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = AFieldName then
        Result := TNxMultiGridColumn(mMG.Columns[i]);
end;

function FindColumnByFieldName2(AMG: TMultiGrid; AFieldName: String): TNxMultiGridColumn;
var
  i: Integer;
begin
  Result := nil;
  if Assigned(AMG) then
    for i:=AMG.ColumnCount-1 downto 0 do
      if AMG.Columns[i].FieldName = AFieldName then
        Result := TNxMultiGridColumn(AMG.Columns[i]);
end;



begin
end.

