uses 'PozadavekNaVyrobuzOV.Libs';


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := False;
  mAction.Caption := 'Test zajištění skriptem.';
  mAction.Items.Add('Test zajištění skriptem');
  mAction.Hint := 'Test';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ChangeSelect;
end;






procedure ChangeSelect(Sender: TObject; AAction: Integer);
var
  I: Integer;
  mBookmark: TBookmark;
  mBookmarkList: TBookmarklist;
  mControl: TControl;
  mDataSet: TDataSet;
  mGrid: TDBGrid;
  mLblCapacityValue: TLabel;
  mLblPriceValue: TLabel;
  mLblWeightValue: TLabel;
  mSite: TSiteForm;
  mSelRows :TStringList;
  mSumCapacity: Double;
  mSumPrice: Double;
  mSumWeight: Double;
  mBO_StoreCard,mbo:TNxCustomBusinessObject;
  mListSupplier:TStringList;
  mI_Supplier,mI_SCM:integer;
  mFind:boolean;
  mSCM:TStringList;
  mRows_POZ, mRows_OV:tstringlist;
  mb:boolean;
  mr:tstringlist;
  mdelete:boolean;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mGrid := TDBGrid(NxFindChildControl(mSite.GetSiteAppForm, 'grdList'));
  mDataSet := mGrid.DataSource.DataSet;
  mdelete:=false;
  mr:=TStringList.create;
  try
       msite.BaseObjectSpace.SQLSelect('select distinct io.id from IssuedOrders2 io2 join IssuedOrders IO on io.id=io2.parent_ID where store_id=' + QuotedStr('51A1000101'),mr);
       if mr.count>0 then begin
          mb:=InputQuery('Pozor' ,'Na OV je na kalkulačním skladu pohyb , přejete si vyprázdnit','');
           if mb then begin
               NxShowSimpleMessage('Mazani', nil);
               mBO:=msite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                   for i:=0 to mr.count-1 do begin
                       mbo.load(mr.Strings[i],nil);
                       mbo.Delete;
                       mdelete:=True;

                   end;
               mbo.free;

           end;
       end;
  finally
      mr.free;
  end;

  mr:=TStringList.create;
  try
       msite.BaseObjectSpace.SQLSelect('select id from PLMProduceRequests where store_id=' + QuotedStr('51A1000101'),mr);
       if mr.count>0 then begin
            mb:=InputQuery('Pozor' ,'Na Požadavcích je na kalkulačním skladu pohyb , přejete si vyprázdnit','');
           if mb then begin
               NxShowSimpleMessage('Mazani', nil);
                mBO:=msite.BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                   for i:=0 to mr.count-1 do begin
                       mbo.load(mr.Strings[i],nil);
                       mbo.Delete;
                        mdelete:=True;
                   end;
               mbo.free;
           end;
       end;
  finally
      mr.free;
  end;


if mdelete then begin
     NxShowSimpleMessage('Proběhlo mazání dokladů, bilance není aktualizovaná, prosím před pokračováním občerstvěte data',nil);
     exit
end;



  mBO_StoreCard:=msite.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');

         if mGrid.SelectedRows.CurrentRowSelected = False then begin
          // Neni radek oznacen, tj. oznacuje se nove => (+)

        end else begin

        end;

        mBookmark := mDataset.GetBookmark;
        mListSupplier:=TStringList.Create;
        mSCM:=TStringList.create;
        if mGrid.SelectedRows.Count > 0 then begin                  // označené záznamy
          mBookmarkList := mGrid.SelectedRows;
          for I := 0 to (mBookmarkList.Count - 1) do begin
            mDataSet.GotoBookmark(mBookmarkList.Items(I));

             mBO_StoreCard.load(mDataSet.FieldByName('StoreCArd_ID').AsString,nil);
              mSCM.add(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')+';'+mBO_StoreCard.oid +';'+(NxFloatToIBStr((-1)* (mDataSet.FieldByName('Result').AsFloat)))+';' +
                                                        ''+ ';' +  // divison
                                                        ''+ ';' +  // Zakazka
                                                        ''+ ';' +  // Obchodní prípad
                                                        ''+ ';' +   // Projekt

                                                           '');

              mfind:=false;
              for mI_Supplier:=0 to mListSupplier.count-1 do begin
                  if mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')=mListSupplier.Strings[mI_Supplier] then mFind:=true;
              end;
              if mFind=False then mListSupplier.add(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID'))  ;


          end;
           mSCM.Sort;
           for mI_Supplier:=0 to mListSupplier.count-1 do begin
                 mRows_OV:=tstringlist.create;
                 mRows_POZ:=tstringlist.create;

                 for mI_SCM:=0 to mSCM.Count-1 do begin
                   if mListSupplier.Strings[mI_Supplier]=copy(mSCM.Strings[mI_SCM],1,10) then begin
                       mRows_OV.Add(mSCM.Strings[mI_SCM]);
                       mRows_POZ.Add(mSCM.Strings[mI_SCM]);
                           if true then  begin
                              if (mListSupplier.Strings[mI_Supplier]='IHFJ800101')          // {výroba SK - podprsenky}
                                 or (mListSupplier.Strings[mI_Supplier]='3D15000101')          //{ výroba podprsenky }
                                 or (mListSupplier.Strings[mI_Supplier]='KG0J800101')          // {výroba SK - pásy}
                                 or (mListSupplier.Strings[mI_Supplier]='UHUJ800101')          //{výroba VM molding}
                                 or (mListSupplier.Strings[mI_Supplier]='4LUJ800101')         //{xxx}
                               then begin


                                      mb:= NewPOZ(msite,'4712000101',mListSupplier.Strings[mI_Supplier],mrows_poz,
                                                        '51A1000101',    // sklad
                                                        '1N00000101'); //středisko
                                      mRows_POZ.Delete(0);
                              end;
                           end;
                   end;
                 end;
                 //****** odeslání dokladu



//                 if mRows_OV.count>0 then begin
//                       if (mListSupplier.Strings[mI_Supplier]='KIBJ800101')          // {Stříhárna  }
//                        then begin
                            mb:= NewOV(msite,'1640000101',mListSupplier.Strings[mI_Supplier],mRows_OV,
                                                '51A1000101',    // sklad
                                                '1N00000101'); //středisko
//                       end;
//                       if (mListSupplier.Strings[mI_Supplier]='CFLE800101')          // {výroba SK}  }
//                        then begin
//                            mb:= NewOV(msite,'1640000101',mListSupplier.Strings[mI_Supplier],mRows_OV,
//                                                '51A1000101',    // sklad
//                                                '1N00000101'); //středisko
//                       end;

//                 end;


              mRows_POZ.free;
              mRows_OV.free;
            end;
            mListSupplier.free;
            mSCM.free;
        end;
   mBO_StoreCard.free;
   mDataSet.Refresh;
   TSiteForm(msite).Refresh;
   msite.Refresh;
end;

begin
end.