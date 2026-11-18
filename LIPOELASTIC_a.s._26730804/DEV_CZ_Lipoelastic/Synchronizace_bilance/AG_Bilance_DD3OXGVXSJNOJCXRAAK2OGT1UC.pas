uses 'Synchronizace_bilance.Libs';


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := False;
  mAction.Caption := 'Zajištění LIPOELASTIC.';
  mAction.Items.Add('Zajištění LIPOELASTIC');
  mAction.Items.Add('Přímá výroba');
  //mAction.Items.Add('Jen POZ');
  //mAction.Items.Add('Smazání POZ');
  mAction.Hint := 'Zajištění LIPOELASTIC';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ChangeSelect;
end;






procedure ChangeSelect(Sender: TObject; index: Integer);
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
  mRows_POZ, mRows_OV,mRows_OVpoz:tstringlist;
  mb:boolean;
  mr:tstringlist;
  mdelete:boolean;
  mString,mxString:string;
  mdoklady:string;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mGrid := TDBGrid(NxFindChildControl(mSite.GetSiteAppForm, 'grdList'));
  mDataSet := mGrid.DataSource.DataSet;
    mdoklady:='';
  if index=5 then begin
                mdelete:=false;
                mr:=TStringList.create;
                try
                     msite.BaseObjectSpace.SQLSelect('select distinct io.id from IssuedOrders2 io2 join IssuedOrders IO on io.id=io2.parent_ID where store_id=' + QuotedStr(mStoreCalc_ID),mr);
                     if mr.count>0 then begin
                        mb:=InputQuery('Pozor' ,'Na OV je na kalkulačním skladu pohyb , přejete si vyprázdnit','');
                         if mb then begin
                             ProgressInit(msite, 'Mazání OV ' + '', 100);
                             mBO:=msite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                try
                                       for i:=0 to mr.count-1 do begin
                                           ProgressSetPos(1+NxFloor(i/mr.Count*99), inttostr(i) +' z '+inttostr(mr.Count));
                                           mbo.load(mr.Strings[i],nil);
                                           mbo.Delete;
                                           mdelete:=True;

                                       end;
                                 finally
                                     ProgressDispose()   ;
                                     mbo.free;
                                 end;


                         end;
                     end;
                finally

                    mr.free;
                end;

                mr:=TStringList.create;
                try
                     msite.BaseObjectSpace.SQLSelect('select id from PLMProduceRequests where store_id=' + QuotedStr(mStoreCalc_ID),mr);
                     if mr.count>0 then begin
                          mb:=InputQuery('Pozor' ,'Na Požadavcích je na kalkulačním skladu pohyb , přejete si vyprázdnit','');
                         if mb then begin
                             ProgressInit(msite, 'Mazání OV ' + '', 100);
                              mBO:=msite.BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                                   try
                                       for i:=0 to mr.count-1 do begin
                                           ProgressSetPos(1+NxFloor(i/mr.Count*99), inttostr(i) +' z '+inttostr(mr.Count));
                                           mbo.load(mr.Strings[i],nil);
                                           mbo.Delete;
                                            mdelete:=True;
                                       end;
                                    finally
                                         ProgressDispose()   ;
                                         mbo.free;
                                    end;
                         end;
                     end;
                finally
                    mr.free;
                end;


            if mdelete then begin
                 NxShowSimpleMessage('Proběhlo mazání dokladů, bilance není aktualizovaná, prosím před pokračováním občerstvěte data',nil);
                 exit ;
            end;

      end;
          if index<5 then begin
            mBO_StoreCard:=msite.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');

                   if mGrid.SelectedRows.CurrentRowSelected = False then begin
                    // Neni radek oznacen, tj. oznacuje se nove => (+)

                  end else begin

                  end;

                  mBookmark := mDataset.GetBookmark;
                  mListSupplier:=TStringList.Create;
                  mSCM:=TStringList.create;

                   if mGrid.SelectedRows.Count =0  then begin                  // označené záznamy
                        mBO_StoreCard.load(mDataSet.FieldByName('StoreCArd_ID').AsString,nil);
                        mstring:='';
                          ProgressInit(msite, 'Načtení dat ' + '', 100);
                        mstring:=mstring + mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')+';'+mBO_StoreCard.oid +';'+(NxFloatToIBStr((-1)* (mDataSet.FieldByName('Result').AsFloat)))+';' +
                                                                  ''+ ';' +  // divison
                                                                  ''+ ';' +  // Zakazka
                                                                  ''+ ';' +  // Obchodní prípad
                                                                  ''+ ';' +   // Projekt
                                                                  nxBoolToStr(mBO_StoreCard.GetFieldValueAsBoolean('IsProduct'))+ ';' +  '';



           {     // ****** sici davka
                        mstring:=mstring + mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')+';'+mBO_StoreCard.oid +';'+(NxFloatToIBStr((-1)* NxRoundByValue(mDataSet.FieldByName('Result').AsFloat, 2, 10)))+';' +
                                                                  ''+ ';' +  // divison
                                                                  ''+ ';' +  // Zakazka
                                                                  ''+ ';' +  // Obchodní prípad
                                                                  ''+ ';' +   // Projekt
                                                                  nxBoolToStr(mBO_StoreCard.GetFieldValueAsBoolean('IsProduct'))+ ';' +   // vyrobek

                                                                     '');}

                        mSCM.add(mstring);

                        mfind:=false;
                        for mI_Supplier:=0 to mListSupplier.count-1 do begin
                            if mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')=copy(mListSupplier.Strings[mI_Supplier],4,10) then mFind:=true;
                        end;
                        mstring:='__';
                        if (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))=mSourceCountry) then mstring:=mSourceCountry ;
                        if (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))=mTargetCountry) then mstring:=mTargetCountry ;

                        if (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))<>mSourceCountry) and
                         (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))<>mTargetCountry) then mstring:='__' ;



                        mString:=mString + ';' + mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID') ;

                        if mFind=False then mListSupplier.add(mString)  ;




                   end;



                  if mGrid.SelectedRows.Count > 0 then begin                  // označené záznamy
                    mBookmarkList := mGrid.SelectedRows;




                     ProgressInit(msite, 'Načtení dat ' + '', 100);
                    for I := 0 to (mBookmarkList.Count - 1) do begin
                      mDataSet.GotoBookmark(mBookmarkList.Items(I));
                       ProgressSetPos(1+NxFloor(i/mBookmarkList.Count*99), inttostr(i) +' z '+inttostr(mBookmarkList.Count));



                       mBO_StoreCard.load(mDataSet.FieldByName('StoreCArd_ID').AsString,nil);
                        mstring:='';

                        mstring:=mstring + mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')+';'+mBO_StoreCard.oid +';'+(NxFloatToIBStr((-1)* (mDataSet.FieldByName('Result').AsFloat)))+';' +
                                                                  ''+ ';' +  // divison
                                                                  ''+ ';' +  // Zakazka
                                                                  ''+ ';' +  // Obchodní prípad
                                                                  ''+ ';' +   // Projekt
                                                                  nxBoolToStr(mBO_StoreCard.GetFieldValueAsBoolean('IsProduct'))+ ';' +  '';



           {     // ****** sici davka
                        mstring:=mstring + mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')+';'+mBO_StoreCard.oid +';'+(NxFloatToIBStr((-1)* NxRoundByValue(mDataSet.FieldByName('Result').AsFloat, 2, 10)))+';' +
                                                                  ''+ ';' +  // divison
                                                                  ''+ ';' +  // Zakazka
                                                                  ''+ ';' +  // Obchodní prípad
                                                                  ''+ ';' +   // Projekt
                                                                  nxBoolToStr(mBO_StoreCard.GetFieldValueAsBoolean('IsProduct'))+ ';' +   // vyrobek

                                                                     '');}

                        mSCM.add(mstring);

                        mfind:=false;
                        for mI_Supplier:=0 to mListSupplier.count-1 do begin
                            if mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID')=copy(mListSupplier.Strings[mI_Supplier],4,10) then mFind:=true;
                        end;
                        mstring:='__';
                        if (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))=mSourceCountry) then mstring:=mSourceCountry ;
                        if (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))=mTargetCountry) then mstring:=mTargetCountry ;

                        if (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))<>mSourceCountry) and
                         (Trim(UpperCase(mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))<>mTargetCountry) then mstring:='__' ;



                        mString:=mString + ';' + mBO_StoreCard.GetFieldValueAsString('MainSupplier_ID.Firm_ID') ;

                        if mFind=False then mListSupplier.add(mString)  ;

                    end;
                    end;
                     ProgressDispose()   ;


                     mSCM.Sort;


                     //NxShowSimpleMessage('zacatek ' + inttostr(mSCM.count),nil);
                     for mI_Supplier:=0 to mListSupplier.count-1 do begin
                           mRows_OV:=tstringlist.create;
                           mRows_POZ:=tstringlist.create;
                           mRows_OVpoz:=tstringlist.create;
                           //NxShowSimpleMessage('zacatek cyklu ',nil);
                           ProgressInit(msite, 'Zpracování dat POZ ' + '', 100);
                           for mI_SCM:=0 to mSCM.Count-1 do begin
                               ProgressSetPos(1+NxFloor(mI_SCM/mSCM.Count*99), inttostr(mI_SCM) +' z '+inttostr(mSCM.Count));

                             //NxShowSimpleMessage(copy(mListSupplier.Strings[mI_Supplier],5,10) + ' - ' + copy(mSCM.Strings[mI_SCM],1,10),nil);
                                         if copy(mListSupplier.Strings[mI_Supplier],4,10)=copy(mSCM.Strings[mI_SCM],1,10) then begin
                                             if (index=0)  then begin
                                                       if copy(mListSupplier.Strings[mI_Supplier],1,2)=mSourceCountry then begin

                                                                if (RightStr(mSCM.Strings[mI_SCM],3)) = ';A;' then begin       // je výrobek
                                                                      mRows_POZ.Add(mSCM.Strings[mI_SCM]);
                                                                      mRows_OVpoz.Add(mSCM.Strings[mI_SCM]);
                                                                     mb:= NewPOZ(msite,'4712000101',copy(mListSupplier.Strings[mI_Supplier],4,10),mRows_POZ,
                                                                                        mStoreCalc_ID,    // sklad
                                                                                        '1N00000101'); //středisko
                                                                       //NxShowSimpleMessage('Pocet POZ ' + inttostr(mRows_POZ.count),nil);
                                                                      mRows_POZ.Delete(0);

                                                                      //NxShowSimpleMessage('Savepoz',nil);
                                                                end else begin   // není výrobek
                                                                     mRows_OV.Add(mSCM.Strings[mI_SCM]);
                                                                end;
                                                       end else begin
                                                                mRows_OV.Add(mSCM.Strings[mI_SCM]);
                                                       end;

                                             end;
                                             if (index=1)  then begin


                                                                if (RightStr(mSCM.Strings[mI_SCM],3)) = ';A;' then begin       // je výrobek
                                                                      mRows_POZ.Add(mSCM.Strings[mI_SCM]);
                                                                      mRows_OVpoz.Add(mSCM.Strings[mI_SCM]);
                                                                     mb:= NewPOZ(msite,'4712000101',copy(mListSupplier.Strings[mI_Supplier],4,10),mRows_POZ,
                                                                                        mStoreCalc_ID,    // sklad
                                                                                        '1N00000101'); //středisko
                                                                       //NxShowSimpleMessage('Pocet POZ ' + inttostr(mRows_POZ.count),nil);
                                                                      mRows_POZ.Delete(0);
                                                                      mRows_OV.Add(mSCM.Strings[mI_SCM]);
                                                                      mRows_OVpoz.Add(mSCM.Strings[mI_SCM]);
                                                                      //NxShowSimpleMessage('Savepoz',nil);
                                                                end else begin   // není výrobek
                                                                mRows_OVpoz.Add(mSCM.Strings[mI_SCM]);
                                                                     mRows_OV.Add(mSCM.Strings[mI_SCM]);
                                                                end;


                                             end;
                                         end;
                           end;

                           //NxShowSimpleMessage('Pocet OV ' + inttostr(mRows_OV.count),nil);
                            ProgressDispose()   ;

                           if ((index=0) OR (index=1))  then begin
                               //NxShowSimpleMessage('SaveOV',nil);
                               if mRows_OVpoz.count>0 then begin                                                                     // podklad pr naskladnění výroby
                                          mxString:='';
                                          mxString:= NewOV(msite,'1640000101',copy(mListSupplier.Strings[mI_Supplier],4,10),mRows_OVpoz,
                                                          '41Y0000101',    // sklad
                                                          '1N00000101'); //středisko
                                          mdoklady:=   mdoklady + mxString +', '+ chr(13)  ;
                              end;



                                if mRows_OV.count>0 then begin
                                        mxString:='';
                                        mxString:= NewOV(msite,'7400000101','7F26300101',mRows_OV,              // vyčištění bilance
                                                          mStoreCalc_ID,    // sklad
                                                          '1N00000101'); //středisko

                                        mxString:='';
                                        mxString:= NewOV(msite,'1640000101',copy(mListSupplier.Strings[mI_Supplier],4,10),mRows_OV,             // podklad pro naskladnění
                                                         '41Y0000101',    // sklad
                                                         '1N00000101'); //středisko
                                         mdoklady:=   mdoklady + mxString +', '+ chr(13)  ;
                                end;
                           end;

                        mRows_POZ.free;
                        mRows_OV.free;
                        mRows_OVpoz.free;
                      end;
                      mListSupplier.free;
                      mSCM.free;
                  end;

         mBO_StoreCard.free;
         mDataSet.Refresh;
         TSiteForm(msite).Refresh;
         msite.Refresh;
         mGrid.Refresh;
         NxShowSimpleMessage('Zajištění proběhlo , prosím aktualizujte si data .' + chr(13) +
                             mdoklady
         ,nil);
end;

begin
end.