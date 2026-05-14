uses 'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.const';

function iSelectStorecard(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;

procedure NewOVExecute(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
  mBookmark : TBookmarkList;
  mform:tform ;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewOV(mObj,mBookmark,TDynSiteForm);
        if not NxIsEmptyOID(mID) then
          mSite.ShowDynForm('GF53HAH3WBDL3C5P00CA141B44', Nil, Nil, False, 'DoEdit;'+mID);
      end;
    finally
      mObj.Free;
    end;
  end;
end;

function NewOV(ABO: TNxCustomBusinessObject;mbookmark:TBookmarkList;mform:TDynSiteForm): string;
var
  mBO_target: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
begin
  result := '';
  mBO_target := ABO.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
  mBO_target.New;
    mBO_target.Prefill;
    mBO_target.SetFieldValueAsString('Firm_ID', 'CXC0000101');
    if not NxIsBlank(ABO.GetFieldValueAsString('U_Provozovatel_id')) then mBO_target.SetFieldValueAsString('U_Provozovatel_id', ABO.GetFieldValueAsString('U_Provozovatel_id'));
    mBO_target.SetFieldValueAsString('Description', copy(ABO.GetFieldValueAsString('Description'),1,150));
    mBO_target.SetFieldValueAsString('DocQueue_ID', '7J00000101');
  if mBookmark.count=0 then begin
     mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
     mList := TStringList.Create;
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
       for ii := 0 to mbookmark.Count-1 do begin
             ABO.Load(mBookMark.items(ii),nil);
             mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
             mList := TStringList.Create;
             for i := 0 to mMon.Count-1 do begin
                mRow := mMon.BusinessObject[i];
                mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                if mrow.GetFieldValueAsFloat('Quantity') -mrow.GetFieldValueAsFloat('DeliveredQuantity') - mrow.GetFieldValueAsFloat('X_skladem')>0 then begin
                        mr:=tstringlist.create;
                        mBO_target.ObjectSpace.SQLSelect('Select sum(io2.quantity) from issuedorders2 IO2 left join issuedOrders IO on io.id=io2.parent_id where io.docqueue_ID=' + quotedstr('7J00000101') +
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
    try

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
                      mNewRow.SetFieldValueAsString('X_HeadParent_ID',mRow.GetFieldValueAsString('X_HeadParent_ID'));
                      if not NxIsBlank(mRow.GetFieldValueAsString('U_Description')) then mNewRow.SetFieldValueAsString('U_Description', copy(mRow.GetFieldValueAsString('U_Description'),1,150));

                      mfind:=False;
                  end;
                end;
                mr.free;

      end;
     finally

    end;

    TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mForm.SiteContext, mBO_target);
    mBO_target.Free;
end;

function NewPRV(ABO: TNxCustomBusinessObject): string;
var
  mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon,mMon_source: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mSite: TDynSiteForm;
    aa:string;
    mresult:Boolean;
begin
  result := '';
  mBO_target := ABO.ObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4');

  try
    mBO_target.New;
    mBO_target.Prefill;
    mBO_target.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    if not NxIsBlank(ABO.GetFieldValueAsString('U_Provozovatel_id')) then mBO_target.SetFieldValueAsString('X_Provozovatel_id', ABO.GetFieldValueAsString('U_Provozovatel_id'));
    mBO_target.SetFieldValueAsString('Description', copy(ABO.GetFieldValueAsString('Description'),1,150));
    mBO_target.SetFieldValueAsString('DocQueue_ID', '7F00000101');
    mBO_target.SetFieldValueAsDateTime('U_Transport_date', now());
    mMon_source := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    mfind:=false;
    try
      for i := 0 to mMon_source.Count-1 do begin
        mRow := mMon_source.BusinessObject[i];
        mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
        mr:=tstringlist.create;
              mBO_target.ObjectSpace.SQLSelect('Select sd2.id from storedocuments2 SD2 left join storedocuments SD on SD.id=SD2.parent_id where SD.docqueue_ID=' + quotedstr('7F00000101') +
                ' and sd2.id=' + quotedstr(mrow.GetFieldValueAsString('ID')),mr);

         if mr.count>0 then begin
          mfind:=true;
         end else begin
            mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
            mMon_source.BusinessObject[i].SetFieldValueAsFloat('DeliveredQuantity',mMon_source.BusinessObject[i].getFieldValueAsFloat('Quantity'));
         end;
         mr.free;
      end;
      mList.Sort;
      if mfind then NxShowSimpleMessage('Pozor, operace již byly provedena dříve, budou dohrány pouze nové položky',nil);
      mfind:=true;
      mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
            mRow := TNxCustomBusinessObject(mList.Objects[i]);
              // dohrání rozdílů
              mr:=tstringlist.create;
              mBO_target.ObjectSpace.SQLSelect('Select sd2.id from storedocuments2 SD2 left join storedocuments SD on SD.id=SD2.parent_id where SD.docqueue_ID=' + quotedstr('7F00000101') +
                ' and sd2.id=' + quotedstr(mrow.GetFieldValueAsString('ID')),mr);
                if mr.count=0 then begin
                   if (mRow.GetFieldValueAsInteger('RowType')=3) and
                   (mRow.GetFieldValueAsFloat('Quantity')>mRow.GetFieldValueAsFloat('DeliveredQuantity')) then begin
                      mNewRow := mMon.AddNewObject;
                      mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
                      mNewRow.SetFieldValueAsString('Store_ID', 'M000000101');
                      mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                      mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                      mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                      mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity')-mRow.GetFieldValueAsFloat('DeliveredQuantity'));
                      mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                      mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                      mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                      mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
                      mfind:=False;
                  end;
                end;
                mr.free;

      end;
     finally

    end;
    if mList.count>0 then begin
    mList.free;
    mBO_target.ClearValidateErrors;
    if Not mBO_target.Validate() then begin
      mList := TStringList.Create;
      try
        mBO_target.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou převodku výdej nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin



      mBO_target.Save;

      result := mBO_target.OID;
            NxShowSimpleMessage('Převodka výdej byla vytvořena',nil);
         abo.SetFieldValueAsBoolean('Closed',true);
         abo.Save;
    end;
    end;
  finally
    mBO_target.Free;
  end;
end;



procedure Doplneni_zasob(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);

var
mr,mr1,mr2:Tstringlist;
i,ii:integer;
self:TNxCustomBusinessObject;
mBO:TNxCustomBusinessObject;
Mbo_row:TNxCustomBusinessObject;
pocet:double;
Sklad_technika:double;
Centralni_sklad:double;
mPrevodka_Dispecera_pot:double;
mObjednavka_Dispecera_pot:double;
mObjednavka_Dispecera_npot:double;
mObjednavka_Logistika_pot:double;
mObjednavka_Logistika_npot:double;
most_obj_disp:Double;
most_obj_central:double;
mtermin_Dispecera:Date;
mtermin_Logistika:Date;

stav:double;

m_parent_ID:string;
mstav:Boolean;
mpokracovat:Boolean;
mTechnik:string;
mCentral:string;
mTechnik_popis:string;
mCentral_popis:string;
mDate_technik:date;
mDate_central:date;
Sklad_central:double;
M_Log_ok,M_centr_ok:string;
mMon:TNxCustomBusinessMonikerCollection;
begin
    mpokracovat:=true;
    m_parent_ID:='';
     mr:=TStringList.Create;
    os.SQLSelect('Select SA.ID from ServiceAssemblyForms SA where (sa.AssemblyState<2)',mr);
//  if ladit then NxShowSimpleMessage('Select SA2.ID from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA.id=sa2.Parent_id where (sa2.X_storno='+quotedstr('N')+') and (sa2.ItemType=1) and (sa2.Quantity-sa2.QuantityDelivered)>0 order by sa2.parent_ID',nil);
    if mr.count>0 then begin
        mstav:=true;
        for i:=0 to mr.Count-1 do begin       // doklad
            try
              Mbo := os.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
              Mbo.Load(mr.Strings[i],nil);
              mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                for ii := 0 to mMon.Count-1 do begin
                    Mbo_row:= mMon.BusinessObject[ii];
                            if Mbo_row.GetFieldValueAsInteger('ItemType')=1 then begin
                                    mpokracovat:=true;
                                    mDate_central:=0;
                                    M_centr_ok:='';
                                    M_Log_ok:='';
                                    pocet:=0;
                                    Sklad_technika:=0;
                                    Centralni_sklad:=0;
                                    mPrevodka_Dispecera_pot:=0;
                                    mObjednavka_Dispecera_pot:=0;
                                    mObjednavka_Dispecera_npot:=0;
                                    mObjednavka_Logistika_pot:=0;
                                    mObjednavka_Logistika_npot:=0;
                                    most_obj_disp:=0;
                                    most_obj_central:=0;
                                    mtermin_Dispecera:=0;
                                    mtermin_Logistika:=0;
                                    pocet:=Mbo_row.GetFieldValueAsfloat('Quantity')-Mbo_row.GetFieldValueAsfloat('QuantityDelivered');
                                      if pocet>0 then begin
                                          if true then begin // Převodka
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select sum(SD2.Quantity-SD2.DeliveredQuantity) from Storedocuments2 SD2 left join Storedocuments SD on SD.id=SD2.parent_id where' +
                                                  ' SD2.store_id=%s and SD2.storecard_id=%s ' +
                                                  ' AND SD.Documenttype=' + quotedstr('22') +  ' AND SD.Finished=%s ',[QuotedStr('M000000101'),QuotedStr(Mbo_row.GetFieldValueAsString('StoreCard_ID')),quotedstr('N')]),mr1);
                                              if strtoint(mr1.Strings[0])>0 then begin
                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                      mPrevodka_Dispecera_pot:=strtofloat(mr1.Strings[0]);
                                                      mpokracovat:=false;

                                                  end;
                                              end ;
                                              mr1.free;
                                          end;


                                          if true then begin //  objednavka dispečera potvrzená
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                                  ' io.Confirmed=%s and io.Closed=%s and io.DocQueue_ID=%s and io2.X_parent_ID=%s',
                                                                  [quotedstr('A'),quotedstr('N'),quotedstr('1Q10000101'),quotedstr(Mbo_row.OID)]),mr1);
                                              if mr1.Count>0 then begin
                                                  mObjednavka_Dispecera_pot:=StrToFloat(mr1.Strings[0]) ;
                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                      mObjednavka_Dispecera_pot:=strtofloat(mr1.Strings[0]);
                                                      end;
                                                  end;
                                                  mr1.free;
                                              end;

                                          if true then begin //  objednavka dispečera nepotvrzená
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                   ' io.Confirmed=%s and io.Closed=%s and io.DocQueue_ID=%s and io2.X_parent_ID=%s',
                                                   [quotedstr('N'),quotedstr('N'),quotedstr('1Q10000101'),quotedstr(Mbo_row.OID)]),mr1);
                                              if mr1.Count>0 then begin

                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                       mObjednavka_Dispecera_npot:=StrToFloat(mr1.Strings[0]);
                                                  end;
                                              end;
                                              mr1.free;
                                          end;

                                          if true then begin //  ostatní objednávky na sklad technika
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                   ' io2. store_id=%s and io2.storecard_id=%s and io.Closed=%s and io.DocQueue_ID=%s',
                                                   [quotedstr(Mbo_row.GetFieldValueAsString('Store_id')),QuotedStr(Mbo_row.GetFieldValueAsString('StoreCard_id')),quotedstr('N'),quotedstr('1Q10000101')]),mr1);
                                              if mr1.Count>0 then begin
                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                      most_obj_disp:=StrToFloat(mr1.Strings[0]);
                                                  end;
                                              end;
                                              mr1.free;
                                          end;

                                          if true then begin //  ostatní objednávky na centrální sklad
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                   ' io2. store_id=%s and io2.storecard_id=%s and io.Closed=%s and io.DocQueue_ID=%s',
                                                   [quotedstr(Mbo_row.GetFieldValueAsString('Store_id')),QuotedStr(Mbo_row.GetFieldValueAsString('StoreCard_id')),quotedstr('N'),quotedstr('1Q10000101')]),mr1);
                                              if mr1.Count>0 then begin
                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                      most_obj_central:=StrToFloat(mr1.Strings[0]);
                                                  end;
                                              end;
                                              mr1.free;
                                          end;

                                          if true then begin //  sklad technika
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select sum(quantity) from storesubcards where store_id=%s and storecard_id=%s',[QuotedStr(Mbo_row.GetFieldValueAsString('Store_id')),QuotedStr(Mbo_row.GetFieldValueAsString('StoreCard_ID'))]),mr1);
                                              if mr1.Count>0 then begin
                                                  if strtofloat(mr1.Strings[0])>=pocet then begin
                                                      Sklad_technika:=strtofloat(mr1.Strings[0]);
                                                  end;
                                              end;
                                              mr1.free;
                                          end;


                                          if true then begin // objednávka logistika potvrzená
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                 ' io.Confirmed=%s and io.DocQueue_ID=%s and io2.X_parent_ID=%s',
                                                 [quotedstr('A'),quotedstr('7J00000101'),quotedstr(Mbo_row.oid)]),mr1);
                                              if mr1.Count>0 then begin

                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                       mObjednavka_Logistika_pot:=StrToFloat(mr1.Strings[0]) ;
                                                        mr2:=tstringlist.create;
                                                        os.SQLSelect(format('select io2.DeliveryDate$Date from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                              ' io.Confirmed=%s and io.DocQueue_ID=%s and io2.X_parent_ID=%s',
                                                              [quotedstr('A'),quotedstr('7J00000101'),quotedstr(Mbo_row.oid)]),mr2);
                                                              if mr2.Count>0 then begin
                                                                  mDate_central:=strtofloat(mr2.Strings[0]);
                                                              end;
                                                              mr2.free;
                                                  end;

                                              end;
                                              mr1.free;
                                           end;
                                           if true then begin // centrální sklad
                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select sum(quantity) from storesubcards where store_id=%s and storecard_id=%s',[QuotedStr('M000000101'),QuotedStr(Mbo_row.GetFieldValueAsString('StoreCard_ID'))]),mr1);
                                              if mr1.Count>0 then begin
                                                  if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                      Centralni_sklad:=StrToFloat(mr1.Strings[0]);
                                                      Sklad_central:=strtofloat(mr1.Strings[0]);
                                                  end;
                                              end;
                                              mr1.free;
                                          end;

                                          if true then begin //   objednávka vydaná logistik nepotvrzená
                                            mr1:=TStringList.Create;
                                            os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                               ' io.Confirmed=%s and io.DocQueue_ID=%s and io2.X_parent_ID=%s',
                                               [quotedstr('N'),quotedstr('7J00000101'),quotedstr(Mbo_row.OID)]),mr1);
                                            if mr1.Count>0 then begin

                                                if strtofloat(mr1.Strings[0])>0 then begin // je pokryto skladem technika
                                                    mObjednavka_Logistika_npot:=StrToFloat(mr1.Strings[0]);
                                                end;
                                            end;
                                            mr1.free;
                                          end;


                                              mr1:=TStringList.Create;
                                              os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                                   ' io2.X_parent_ID=%s and io.DocQueue_ID=%s',
                                                   [QuotedStr(Mbo_row.oid),quotedstr('7J00000101')]),mr1);
                                              if mr1.Count=1 then begin
                                                  if strtofloat(mr1.Strings[0])=0 then begin // je pokryto skladem technika
                                                     M_Centr_ok:='AVH1000101';
                                                  end;
                                              end;
                                              mr1.free;
                                            mr1:=TStringList.Create;
                                            os.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                               ' io2.X_parent_ID=%s and io.DocQueue_ID<>%s',
                                               [quotedstr(Mbo_row.OID),quotedstr('7J00000101')]),mr1);
                                            if mr1.Count>0 then begin
                                                if strtofloat(mr1.Strings[0])=0 then begin // je pokryto skladem technika
                                                    M_Log_ok:='AVH1000101';
                                                   // if ladit then NxShowSimpleMessage('termín stanoven',nil);
                                                end;
                                            end;
                                            mr1.free;




                                 mTechnik:='4VH1000101';
                                 mTechnik_popis:='Nezajištěno';
                                 mCentral:='4VH1000101';
                                 mCentral_popis:='Nezajištěno';



                         mCentral:='';
                         mCentral_popis:='';
                         if true then begin
                               if pocet>mPrevodka_Dispecera_pot then begin
                                   if pocet-mPrevodka_Dispecera_pot>mObjednavka_Logistika_pot then begin
                                        if pocet-mPrevodka_Dispecera_pot>mObjednavka_Logistika_pot+mObjednavka_Logistika_npot then begin
                                             if pocet-mPrevodka_Dispecera_pot-most_obj_central>Sklad_central then begin
                                                   //if ladit then NxShowSimpleMessage('neni skladem',nil);
                                                   mCentral:='4VH1000101';
                                                   mCentral_popis:='Nezajištěno';
                                             end else begin
                                                   //if ladit then NxShowSimpleMessage('skladem',nil);
                                                   mCentral:='7VH1000101';
                                                   mCentral_popis:='Skladem';
                                             end;
                                        end else begin
                                             //if ladit then NxShowSimpleMessage('není objednáno',nil);
                                             mCentral:='5VH1000101';
                                              mCentral_popis:='Poptáváno';
                                        end;
                                   end else begin
                                       //if ladit then NxShowSimpleMessage('není potvrzeno',nil);
                                            mCentral:='6VH1000101';
                                             mCentral_popis:='Termín stanoven';
                                   end;
                               end else begin
                                  //if ladit then NxShowSimpleMessage('je převáděno',nil);
                                  mCentral:='8VH1000101';
                                  mCentral_popis:='Převáděno';
                               end;
                            end;

                         mtechnik:='';
                         mTechnik_popis:='';

                               if pocet>mPrevodka_Dispecera_pot then begin //
                                   if pocet-mPrevodka_Dispecera_pot>mObjednavka_Dispecera_pot then begin
                                        if pocet-mPrevodka_Dispecera_pot>mObjednavka_Dispecera_pot+mObjednavka_Dispecera_npot then begin
                                             if pocet-mPrevodka_Dispecera_pot-most_obj_disp>Sklad_technika then begin
                                                   //if ladit then NxShowSimpleMessage('neni skladem',nil);
                                                   mtechnik:='4VH1000101';
                                                   mTechnik_popis:='Nezajištěno';
                                             end else begin
                                                   //if ladit then NxShowSimpleMessage('skladem',nil);
                                                   mtechnik:='7VH1000101';
                                                   mTechnik_popis:='Skladem';
                                                   mCentral:='AVH1000101';
                                                   mCentral_popis:='';
                                                   mDate_central:=0;
                                             end;
                                        end else begin
                                             //if ladit then NxShowSimpleMessage('ení objednáno',nil);
                                             mtechnik:='5VH1000101';
                                       mTechnik_popis:='Poptáváno';
                                        end;
                                   end else begin
                                       if ladit then NxShowSimpleMessage('není potvrzeno',nil);

                                       mtechnik:='6VH1000101';
                                             mTechnik_popis:='Termín stanoven';
                                   end;
                               end else begin
                                  //if ladit then NxShowSimpleMessage('je převáděno',nil);
                                  mtechnik:='8VH1000101';
                                  mTechnik_popis:='Převáděno';
                               end;



                               if M_Log_ok<>'' then begin
                                  mDate_central:=0;
                                  mTechnik:='AVH1000101';
                                  mTechnik_popis:='Zajištěno';
                               end;



                               if M_centr_ok<>'' then begin
                                  if mTechnik_popis='Zajištěno'then begin
                                      mDate_central:=0;
                                      mCentral:='AVH1000101';
                                      mCentral_popis:='';
                                  end else begin
                                      mDate_central:=0;
                                      mCentral:='AVH1000101';
                                      mCentral_popis:='Zajištěno';
                                  end;
                               end;

                                        Mbo_row.SetFieldValueAsString('U_Stav_centralni_sklad',mCentral_popis);
                                          Mbo_row.SetFieldValueAsString('X_Stav_centralni_sklad',mCentral);
                                          Mbo_row.SetFieldValueAsString('X_Stav_sklad_technika',mTechnik);
                                          Mbo_row.SetFieldValueAsString('U_Stav_sklad_technika',mTechnik_popis);
                                          Mbo_row.SetFieldValueAsDateTime('U_Termin',mDate_central);
                                          Mbo_row.SetFieldValueAsDateTime('X_Termin',mDate_central);
                                Mbo_row.Save;
                                Mbo_row.free;
                        end;

                            end;
                    ii:=ii+1;
                end;
                mbo.Save;
                i:=i+1;
                mBO.free;
             finally

             end;

      end;

  end;
        mr.free;
  // doklad
  mr:=TStringList.create;
  os.SQLSelect('Select SA.ID from ServiceAssemblyForms SA where (sa.AssemblyState<2)',mr);
//  if ladit then NxShowSimpleMessage('Select SA2.ID from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA.id=sa2.Parent_id where (sa2.X_storno='+quotedstr('N')+') and (sa2.ItemType=1) and (sa2.Quantity-sa2.QuantityDelivered)>0 order by sa2.parent_ID',nil);
    if mr.count>0 then begin
        mstav:=true;
        if ladit then NxShowSimpleMessage(inttostr(mr.count),nil);
        for i:=0 to mr.Count-1 do begin
            try
            mBO:= os.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
            mBO.load(mr.Strings[i],nil);
                  mr1:=TStringList.create;
                  os.SQLSelect('SELECT DF.ID FROM ServiceAssemblyForms SA left join ServiceAssemblyForms2 SA2 on sa.id=sa2.Parent_id left join DefRollData DF on df.id=sa2.X_Stav_centralni_sklad' +
                              ' where sa.id='+ quotedstr(mr.Strings[i]) + ' and (sa2.X_storno='+quotedstr('N') +') and (sa2.ItemType=1) order by df.code',mr1);
                       if mr1.count>0 then begin
                          mbo.SetFieldValueAsString('X_Stav_centralni_sklad',mr1.Strings[0]);
                          //mbo.SetFieldValueAsString('X_Termin_naskladneni',0);
                                           // if ladit then NxShowSimpleMessage(inttostr(i) +' - ' + mr1.Strings[0],nil);
                       end;
                       mr1.free;
            mbo.Save;
            finally

            end;
            mbo.free;
            i:=i+1;
        end;
    end;
    mr.free;
end;


begin
end.