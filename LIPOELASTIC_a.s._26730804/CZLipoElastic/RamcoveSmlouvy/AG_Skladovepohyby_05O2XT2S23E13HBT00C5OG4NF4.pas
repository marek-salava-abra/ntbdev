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
  mMAction.Caption := 'Objednávka přijatá';
  mMAction.Hint := 'Výstupní pohyb';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowOPDocExecuteItem;
  mMAction.Items.Add('Zobraz doklad');
  mMAction.Items.Add('Propoj s objednávkou ');
  mMAction.Items.Add('Odpoj objednávku');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Objednávka vydana';
  mMAction.Hint := 'Výstupní pohyb';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowOVDocExecuteItem;
  mMAction.Items.Add('Zobraz doklad');
  mMAction.Items.Add('Propoj s objednávkou ');
  mMAction.Items.Add('Odpoj objednávku');

end;

{
Vyvolává se po nastavení výchozích vlastností formuláře.
}
 procedure ShowOPDocExecuteItem(Sender: TAction; Index: integer);
begin
    ShowRSDocExecuteItem(Sender,Index,'OP');
end;

 procedure ShowOVDocExecuteItem(Sender: TAction; Index: integer);
begin
   ShowRSDocExecuteItem(Sender,Index,'OV');
end;

 procedure ShowRSDocExecuteItem(Sender: TAction; Index: integer; mType : string);
var
 mbo,mBOSourceOP,mBOSourceOV,mBOSourceHelp:TNxCustomBusinessObject;
 msite:TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 mBookmark : TBookmarkList;
 Pocet_zaznamu : integer;
 i,ii:integer;
 mOLEOP, mRollOP: Variant;
 mOLEOV, mRollOV,mRoll2,mAgenda, mOResult: Variant;
 mSelectedOP,mSelectedOV ,_ss:Variant;
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
    if mType='OP' then begin
              mOLEOP := GetAbraOLEApplication;
              mrollOP := mOLEOP.GetAgenda('T2FWDKF0NSSOBC2KLELLUBPBXW');
              mSelectedOP := mOLEOP.CreateStrings;
              mBOSourceOP:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
    end;

    if mType='OV' then begin
          mOLEOV := GetAbraOLEApplication;
          mrollOV := mOLEOP.GetAgenda('D42ABO5BCI3O1CC4PH21RIL2OW');
          mSelectedOV := mOLEOP.CreateStrings;
          mBOSourceOV:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');
    end;

    mSelectList:=tstringlist.create;

    if (index=1) then begin

                       mProvideRow_ID:='';
                               mProvide_ID:='';
                               if mType='OP' then begin
                                     mProvideRow_ID:= mrollOP.SingleSelectFromSelected2(mSelected, 'Rámcova smlouva: ' + mbo.GetFieldValueAsString('Storecard_id.DisplayName') , '');
                                           //NxShowSimpleMessage(mProvideRow_ID,nil);
                                          if mProvideRow_ID<>'' then begin
                                                        mBOSourceOP.Load(mProvideRow_ID,nil);
                                                        mProvide_ID:=mBOSourceOP.GetFieldValueAsString('Parent_id');
                                           end else begin
                                                NxShowSimpleMessage('Položka není vybrána , přerušuji operaci',nil);
                                                exit;
                                           end;
                               end ;
                               if mType='OV' then begin
                                      mProvideRow_ID:= mrollOP.SingleSelectFromSelected2(mSelected, 'Rámcova smlouva: ' + mbo.GetFieldValueAsString('Storecard_id.DisplayName') , '');
                                           //NxShowSimpleMessage(mProvideRow_ID,nil);
                                          if mProvideRow_ID<>'' then begin
                                                        mBOSourceOV.Load(mProvideRow_ID,nil);
                                                        mProvide_ID:=mBOSourceOV.GetFieldValueAsString('Parent_id');
                                           end else begin
                                                NxShowSimpleMessage('Položka není vybrána , přerušuji operaci',nil);
                                                exit;
                                           end;
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
                                              if mType='OP' then mBOSourceHelp:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                              if mType='OV' then mBOSourceHelp:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');
                                              try
                                                  if mBOSourceHelp.getFieldValueAsFloat('DeliveredQuantity')>=mBO.getFieldValueAsFloat('Quantity') then begin
                                                          mBOSourceHelp.Load(mbo.getFieldValueAsString('ProvideRow_ID'),nil);
                                                          mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceHelp.getFieldValueAsFloat('DeliveredQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                          mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceHelp.getFieldValueAsFloat('DeliveredQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                  end else begin
                                                          mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',0);
                                                          mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',0);
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

                                      if mType='OP' then mBOSourceHelp:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                      if mType='OV' then mBOSourceHelp:=TDynSiteForm(mSite).BaseObjectSpace.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');
                                              try
                                                  mBOSourceHelp.Load(mbo.getFieldValueAsString('ProvideRow_ID'),nil);
                                                  if mBOSourceHelp.getFieldValueAsFloat('DeliveredQuantity')>=mBO.getFieldValueAsFloat('Quantity') then begin
                                                      mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceHelp.getFieldValueAsFloat('DeliveredQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                      mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceHelp.getFieldValueAsFloat('DeliveredQuantity')-mBO.getFieldValueAsFloat('Quantity')));
                                                  end else begin
                                                      mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',0);
                                                      mBOSourceHelp.SetFieldValueAsFloat('DeliveredQuantity',0);
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
                  if mSelectList.count>0 then begin
                         if mType='OP' then ShowSelectedDynForm(msite, mSelectList, 'T2FWDKF0NSSOBC2KLELLUBPBXW','Pohyby' ) else NxShowSimpleMessage('K dokladům není přiřazena žádná rámcová smlouva',nil);
                         if mType='OV' then ShowSelectedDynForm(msite, mSelectList, 'D42ABO5BCI3O1CC4PH21RIL2OW','Pohyby' ) else NxShowSimpleMessage('K dokladům není přiřazena žádná rámcová smlouva',nil);
                  end;
           end;
           if index=1 then begin
                   if mType='OP' then begin
                     mBOSourceOP.Load(mProvideRow_ID,nil);
                     mBOSourceOP.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceOP.getFieldValueAsFloat('DeliveredQuantity')+mQuantity));
                     mBOSourceOP.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceOP.getFieldValueAsFloat('DeliveredQuantity')+mQuantity));
                     mBOSourceOP.save;
                   end;
                   if mType='OV' then begin
                     mBOSourceOV.Load(mProvideRow_ID,nil);
                     mBOSourceOV.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceOV.getFieldValueAsFloat('DeliveredQuantity')+mQuantity));
                     mBOSourceOV.SetFieldValueAsFloat('DeliveredQuantity',(mBOSourceOV.getFieldValueAsFloat('DeliveredQuantity')+mQuantity));
                     mBOSourceOV.save;
                   end;
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
