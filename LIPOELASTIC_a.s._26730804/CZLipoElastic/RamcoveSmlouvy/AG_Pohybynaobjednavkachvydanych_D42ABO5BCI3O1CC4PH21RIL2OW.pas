procedure InitSite_Hook(Self: TSiteForm);
var
 muser:TNxCustomBusinessObject;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Rámcová smlouva';
  mMAction.Hint := 'Výstupní pohyb';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowRSDocExecuteItem;
  mMAction.Items.Add('Zobraz smlouvy');
  mMAction.Items.Add('Propoj s smlouvou ');
  mMAction.Items.Add('Odeber ze smlouvy');
end;

{
Vyvolává se po nastavení výchozích vlastností formuláře.
}
procedure SetDefaultProperties_Hook(Self: TSiteForm);
begin

end;

 procedure ShowRSDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo,mBOSource,mBOSourceHelp:TNxCustomBusinessObject;
 msite:TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 mBookmark : TBookmarkList;
 Pocet_zaznamu : integer;
 i,ii:integer;
 mOLE, mRoll,mRoll2,mAgenda, mOResult: Variant;
 mSelected ,_ss:Variant;
 mstring:string;
 mFilter:string;
 mProvideRow_ID,mProvide_ID:string;
 mFind:boolean;
 mSelectList:tstringlist;
 mQuantity:double;
begin
  mSite := TComponent(sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO := TDynSiteForm(mSite).CurrentObject;
    mSelected := mOLE.CreateStrings;
    mOLE := GetAbraOLEApplication;
    mroll := mOLE.GetAgenda('PE1A4AOZ2BDOPHHR1C1U1MTNQK');
    mSelected := mOLE.CreateStrings;
    mSelectList:=tstringlist.create;
    mBOSource:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('YJUQQV50PHW4R5A44IPVN441MS');
    if (index=1) then begin

                       mProvideRow_ID:='';
                               mProvide_ID:='';
                               mProvideRow_ID:= mroll.SingleSelectFromSelected2(mSelected, 'Rámcova smlouva: ' + mbo.GetFieldValueAsString('Storecard_id.DisplayName') , '');
                               //NxShowSimpleMessage(mProvideRow_ID,nil);
                              if mProvideRow_ID<>'' then begin
                                            mBOSource.Load(mProvideRow_ID,nil);
                                            mProvide_ID:=mBOSource.GetFieldValueAsString('Parent_id');
                               end else begin
                                    NxShowSimpleMessage('Položka není vybrána , přerušuji operaci',nil);
                                    exit;
                               end;

    end;


    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count else Pocet_zaznamu:=1;
            for i := 0 to Pocet_zaznamu-1 do begin // projdu vsechny oznacene zaznamy
                if mBookmark.Count > 0 then begin
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                end;
                mBO:= TDynSiteForm(mSite).CurrentObject;

                if index=0 then begin
                                 mFind:=false;
                                 for ii:=0 to mSelectList.count-1 do begin
                                      if mSelectList.strings[ii]=mBO.GetFieldValueAsString('ProvideRow_ID') then mFind:=true;
                                 end;
                                 if not mFind then mSelectList.Add(mBO.GetFieldValueAsString('ProvideRow_ID'));
                end;

                                if index=1 then begin
                                         if NxIsEmptyOID(mbo.getFieldValueAsString('ProvideRow_ID')) then begin
                                              mbo.setFieldValueAsString('ProvideRow_ID',mProvideRow_ID);
                                              mbo.setFieldValueAsString('Provide_ID',mProvide_ID);
                                              mbo.save;
                                              mquantity:=mquantity +mBO.getFieldValueAsFloat('Quantity');
                                         end else begin
                                              mBOSourceHelp:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('YJUQQV50PHW4R5A44IPVN441MS');
                                              try
                                                  if mBOSourceHelp.getFieldValueAsFloat('OrderedQuantity')>=mBO.getFieldValueAsFloat('Quantity') then begin
                                                          mBOSourceHelp.Load(mbo.getFieldValueAsString('ProvideRow_ID'),nil);
                                                          mBOSourceHelp.SetFieldValueAsFloat('OrderedQuantity',(mBOSourceHelp.getFieldValueAsFloat('OrderedQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                          mBOSourceHelp.SetFieldValueAsFloat('OrderedUnitQuantity',(mBOSourceHelp.getFieldValueAsFloat('OrderedUnitQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                  end else begin
                                                          mBOSourceHelp.SetFieldValueAsFloat('OrderedQuantity',0);
                                                          mBOSourceHelp.SetFieldValueAsFloat('OrderedUnitQuantity',0);
                                                  end;
                                                  mBOSourceHelp.save;
                                              finally
                                                  //mBOSourceHelp.free;
                                              end;


                                              mbo.setFieldValueAsString('ProvideRow_ID',mProvideRow_ID);
                                              mbo.setFieldValueAsString('Provide_ID',mProvide_ID);
                                              mbo.save;

                                              mquantity:=mquantity +mBO.getFieldValueAsFloat('Quantity');
                                         end;

                               end;

                               if index=2 then begin
                                  if not NxIsEmptyOID(mbo.getFieldValueAsString('ProvideRow_ID')) then begin

                                      mBOSourceHelp:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('YJUQQV50PHW4R5A44IPVN441MS');
                                              try
                                                  mBOSourceHelp.Load(mbo.getFieldValueAsString('ProvideRow_ID'),nil);
                                                  if mBOSourceHelp.getFieldValueAsFloat('OrderedQuantity')>=mBO.getFieldValueAsFloat('Quantity') then begin
                                                      mBOSourceHelp.SetFieldValueAsFloat('OrderedQuantity',(mBOSourceHelp.getFieldValueAsFloat('OrderedQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                      mBOSourceHelp.SetFieldValueAsFloat('OrderedUnitQuantity',(mBOSourceHelp.getFieldValueAsFloat('OrderedUnitQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                  end else begin
                                                      mBOSourceHelp.SetFieldValueAsFloat('OrderedQuantity',0);
                                                      mBOSourceHelp.SetFieldValueAsFloat('OrderedUnitQuantity',0);
                                                  end;

                                                  mBOSourceHelp.save;
                                              finally
                                                  //mBOSourceHelp.free;
                                              end;
                                              mbo.setFieldValueAsString('ProvideRow_ID','');
                                              mbo.setFieldValueAsString('Provide_ID','');
                                              mbo.save;
                                  end;

                               end;

            end;

           if index=0 then begin
                  if mSelectList.count>0 then ShowSelectedDynForm(msite, mSelectList, 'PE1A4AOZ2BDOPHHR1C1U1MTNQK','Pohyby' ) else NxShowSimpleMessage('K dokladům není přiřazena žádná rámcová smlouva',nil);

           end;
           if index=1 then begin
                     mBOSource.Load(mProvideRow_ID,nil);
                     mBOSource.SetFieldValueAsFloat('OrderedQuantity',(mBOSource.getFieldValueAsFloat('OrderedQuantity')+mQuantity));
                     mBOSource.SetFieldValueAsFloat('OrderedUnitQuantity',(mBOSource.getFieldValueAsFloat('OrderedUnitQuantity')+mQuantity));
                     mBOSource.save;
                     mBOSource.Refresh;
           end;

end;

procedure ShowSelectedDynForm(AForm: TSiteForm; AOIDs: TStrings; AFormCLSID: string; ASelCaption: string);
var
  mPars: TNxParameters;
  mParameter: TNxParameter;
begin
  if AOIDs.Count> 0 then begin
    mPars := TNxParameters.Create;
    try
      mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := ASelCaption;
      mParameter := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
      mParameter.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3;
      if AOIDs.count>0 then mParameter.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsTockListStr(AOIDs);
      AForm.ShowDynForm(AFormCLSID, mPars, nil, True, '');

    finally
      mPars.Free;
    end;
  end ;
end ;




begin
end.
