procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Akce dárky';
  mAction.Items.Add('Akce Láhve');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'provede vyhodnocení na akci Dárky';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @Flase;

end;

Procedure OnMyCellclick(Sender :TObject);
var
   mDataSet: TDataSet;
   a,c: Integer;
   b: Double;
   MyBookMarkList: TNxBookmarkList;
begin
      mDataSet:= TMultiGrid(Sender).DataSource.DataSet;
      mDataSet.DisableControls;
      c:= mDataSet.RecNo;
      b:= 0;
      MyBookMarkList:= TMultiGrid(Sender).SelectedRows;

      mDataSet.First;
      While Not(mDataSet.Eof) do
      begin
         //if MyBookMarkList.Find(mDataSet.Bookmark,a) then
         if true then
         begin
            //NxShowSimpleMessage('před: '+FloatToStr(b),nil);
            b:= b + mDataSet.FieldByName('Quantity2').AsFloat * mDataSet.FieldByName('Hodnota').AsFloat;
            //NxShowSimpleMessage('po: '+FloatToStr(b),nil);
         end;
         mDataSet.Next;
      end;
      TLabel(TMultiGrid(Sender).GetParentForm.FindChildControl('lblAmount')).Caption:= FormatFloat('0,',b)+' Kč.';
      mDataSet.RecNo:= c;
      mDataSet.EnableControls;
end;

procedure OnMyKeyUP(Sender: TObject; var Key: TShiftState);
var
   mDataSet: TDataSet;
   a,c: Integer;
   b: Double;
   MyBookMarkList: TNxBookmarkList;
begin
   //NxShowSimpleMessage(IntToStr(Key),nil);
   if (Key = 38) or (Key = 40) or (Key = 13) or (Key = 9) then
   begin
      mDataSet:= TMultiGrid(Sender).DataSource.DataSet;
      mDataSet.DisableControls;
      c:= mDataSet.RecNo;
      b:= 0;
      MyBookMarkList:= TMultiGrid(Sender).SelectedRows;

      mDataSet.First;
      While Not(mDataSet.Eof) do
      begin
         //if MyBookMarkList.Find(mDataSet.Bookmark,a) then
         if true then
         begin
            //NxShowSimpleMessage('před: '+FloatToStr(b),nil);
            b:= b + mDataSet.FieldByName('Quantity2').AsFloat * mDataSet.FieldByName('Hodnota').AsFloat;
            //NxShowSimpleMessage('po: '+FloatToStr(b),nil);
         end;
         mDataSet.Next;
      end;
      TLabel(TMultiGrid(Sender).GetParentForm.FindChildControl('lblAmount')).Caption:= FormatFloat('0,',b)+' Kč.';
      mDataSet.RecNo:= c;
      mDataSet.EnableControls;
   end;
   //NxShowSimpleMessage(FloatToStr(b),nil);
   //TLabel(TMultiGrid(Sender).GetParentForm.FindChildControl('lblReturnAmount')).Caption:= FloatToStr(TNumEdit(TMultiGrid(Sender).GetParentForm.FindChildControl('nueAmount')).Value-StrToInt(TLabel(TMultiGrid(Sender).GetParentForm.FindChildControl('lblAmout')).Caption));
end;


Procedure flase(sender:Tcomponent; index:integer);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mRowBO, mStoreCardBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mGRows:TMultiGrid;
 i,k:integer;
 mValue, mPromotionvalue, mCalculatedValue:extended;
 mString, mSQL, mMessage:string;
 mDivision_ID, mStore_ID, mBusTransaction_ID, mBusOrder_ID, mTransportType_ID:string;
 mPoSplatnosti:Extended;
 mList1, mlist2, ss, mSQLResult, mSQLResult2, mRes, mRes2:TStringList;
 frmBilance: TForm;
 btnOK: TButton;
  btnStorno: TButton;
  btnRefresh : TButton;
  pnlMain, pnlBottom, pnlTOP: TPanel;
  mLabel:TLabel;
  iResult,order: Integer;

  //mGrid: TDBGrid;
  mDS: TNxCustomObjectDataSet;

  mBookmark: TBookmark;
  mBookmarkList: TBookmarklist;
  //mDataSet: TDataSet;
  a:String;

  grdPOZ: TMultiGrid;
  dtPOZ: TMemoryDataset;
  dsPOZ: TDataSource;

  mCol: TNxMultiGridColumn;
  mColR: TNxMultiGridRollColumn;
  mColL: TNxMultiGridLookupColumn;
  mColD: TNxMultiGridDateColumn;
  fd: TFieldDef;
  fld: TField;
  mFound, mFromDL:Boolean;
  mSCQuantity, mSCReservedQuantity, mRowQuantity:Extended;
  mControl: TControl;
  mRowDataset: TNxRowsObjectDataSet;
 Procedure OnMyCellclick2(Sender2 :TField);
var
   mDataSet2: TDataSet;
   a,c: Integer;
   b: Double;
   MyBookMarkList: TNxBookmarkList;
begin
      mDataSet2:= sender2.DataSet;
      if mDataSet2.RecordCount>0 then begin
      mDataSet2.DisableControls;
      c:= mDataSet2.RecNo;
      b:= 0;
      MyBookMarkList:= grdPoz.SelectedRows;

      mDataSet2.First;
      While Not(mDataSet2.Eof) do
      begin
         //if MyBookMarkList.Find(mDataSet.Bookmark,a) then
         if true then
         begin
            //NxShowSimpleMessage('před: '+FloatToStr(b),nil);
            b:= b + mDataSet2.FieldByName('Quantity2').AsFloat * mDataSet2.FieldByName('Hodnota').AsFloat;
            //NxShowSimpleMessage('po: '+FloatToStr(b),nil);
         end;
         mDataSet2.Next;
      end;
      TLabel(grdPOZ.GetParentForm.FindChildControl('lblAmount')).Caption:= FormatFloat('0,',b)+' Kč.';
      mDataSet2.RecNo:= c;
      mDataSet2.EnableControls;
    end;
end;

begin

 mValue:=0;
 mCalculatedValue:=0;
 mPromotionvalue:=0;
 mPoSplatnosti:=0;
 mList1:=tstringlist.Create;
 mList2:=tstringlist.create;
 mSite:=TComponent(sender).Site;
 mOS:=msite.BaseObjectSpace;
 mBO := TDynSiteForm(mSite).CurrentObject;
 if not(NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID'))) then begin
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(trunc(date))]),mlist1);
   mos.SQLSelect(format('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  and ii.localpaidamount<ii.localamount and ii.duedate$date<%s ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),inttostr(30+trunc(date))]),mlist2);
   mPoSplatnosti:=Max_1((StrToFloat(mlist1.strings[0])-StrToFloat(mlist2.strings[0])),0);
 end;
 mRows:=mbo.GetloadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
 //mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
 for i:=0 to mrows.count-1 do begin
 if i=0 then begin
   mStore_ID:=mrows.BusinessObject[i].GetFieldValueAsString('Store_ID');
   mDivision_ID:=mrows.BusinessObject[i].GetFieldValueAsString('Division_ID');
   mBusOrder_ID:=mrows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID');
   mBusTransaction_ID:=mrows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID');
 end;
 if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_akce1') then
      mValue:=mValue+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT');
  if mRows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_Akce1spec') then
      mValue:=mValue+(2*mrows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT'));
  if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')='2840000101' then
      mPromotionvalue:=mPromotionvalue+(mrows.BusinessObject[i].GetFieldValueAsFloat('StoreCard_ID.U_PromotionValue')*mrows.BusinessObject[i].GetFieldValueAsFloat('Quantity'));
  end;
  mString:=AnsiRightStr(AnsiLeftStr(mbo.GetFieldValueAsString('Firm_ID.K0'),4),1);
  //if NxGetActualUserID(mOS)='SUPER00000' then NxShowSimpleMessage('#'+mString+'#'+#13#10+'#'+mbo.GetFieldValueAsString('Firm_ID.K0')+'#',mSite);
  if (mString=' ') or (Length(mbo.GetFieldValueAsString('Firm_ID.K0'))<4) then  begin
    NxShowSimpleMessage('Akce platí pouze pro realizační firmy. Pro tuto firmu nelze dárky přidávat. ', msite);
    exit;
  end;
  // je v OP
  if (mValue>0)and(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then begin
    mMessage:='Aktuální hodnota zboží v akci v této OP je: '+#13#10+
              'Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky.'+#13#10+
              'Akce platí pouze pro realizační firmy a to při neztrátových akcích.'+#13#10+
              'Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.';
  end;
  if (mValue>0) and (mPoSplatnosti=0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO') then begin
   mMessage:= 'Aktuální hodnota zboží v akci  v tomto dokladu je: '+#13#10+
              'ZÁKAZNÍK MÁ VŠE UHRAZENO VE SPLATNOSTI a proto BYLA odměna znásobena.'+#13#10+
              'Akce platí pouze pro realizační firmy a to při neztrátových akcích. '+#13#10+
              'Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.';
   mValue:=2*mValue;
  end;
  if (mValue>0) and (mPoSplatnosti>0)and not(mbo.GetFieldValueAsString('DocQueue_id.Documenttype')='RO')then begin
   mMessage:='Aktuální hodnota zboží v akci v tomto dokladu je: '+#13#10+
             'ZÁKAZNÍK MÁ FAKTURY PO SPLATNOSTI, proto odměna NEBYLA násobena. '+#13#10+
             'Akce platí pouze pro realizační firmy a to při neztrátových akcích. '+#13#10+
             'Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.';
  end;
  if mValue>0 then begin
    if not(TDynSiteForm(mSite).Edit) then begin
      NxShowSimpleMessage('Tlačítko funguje pouze během editace dokladu (nový doklad, oprava dokladu).',msite);
      exit;
    end;
    //NxShowSimpleMessage('Aktuální hodnota zboží v akci "dárky" v této OP je: '+FormatFloat('0,',1*mValue)+' Kč. Pokud nebude mít zákazník při fakturaci závazky po splatnosti, může získat dvojnásobek uvedené částky. Akce platí pouze pro realizační firmy a to při neztrátových akcích. Doklad musí být ziskový minimálně 3%. Za ziskovost odpovídá obchodní zástupce.'+#13#10+'Nyní jsou v na řádcích dokladu dokladu (nikoliv v tomto formuláři) vloženy dárky v hodnotě '+FormatFloat('0,',mPromotionvalue)+' Kč.',mSite);
    // má hodnotu a nic nedluží
    //NxShowSimpleMessage('zde dotáhneme dialog na dárky',msite);
    // skript na řádky
    mSQL:='SELECT  ID FROM StoreCards A '+
          'WHERE (A.Hidden = ''N'' ) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000027 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND '+
          '(dbo.ib_string_left(dbo.StringValueOfField(A.ID, ''C3V5QDVZ5BDL342M01C0CX3FCC'', 2000027, %s) ,1) LIKE ''A''))) and '+
          '(exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000025 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND (CAST(STRINGFIELDVALUE AS NUMERIC(6,0)) BETWEEN 1 AND %s)))  order by '+
          '(SELECT Cast(stringfieldvalue as numeric(6,0)) FROM USERDATA WHERE FIELDCODE=2000025 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID) desc ';
    frmBilance := TForm.Create(mSite);
    mSQLResult := TStringList.Create;
    mSQLResult2 := TStringList.Create;
    ss := TStringList.Create;
    try
    //   mSite.FillListWithSelectedRows(ss);
    //   if ss.Count>0 then
       msite.BaseObjectSpace.SQLSelect(format(mSQL,[inttostr(trunc(date)),FormatFloat('0',1*mValue)]),ss);
       if ss.Count=0 then begin
         NxShowSimpleMessage('Nenašel jsem žádnou odměnu , která by byla v hodnotě dokladu, hodnota objednávky pro dárky je jen '+FormatFloat('0,',1*mValue)+' Kč.',msite);
         exit;
       end;
       begin
         frmBilance.Top:= 20;
         frmBilance.Left:= 20;
         frmBilance.Width:= 800;
         frmBilance.Height:= 600;
         frmBilance.Caption:= 'Výdej dárků';

         pnlTop := TPanel.Create(frmBilance);
         pnlTop.Align:= alTop;
         pnlTop.Parent:= frmBilance;
         pnlTop.Height:= 110;

         mLabel := TLabel.Create(pnlTop);
         mLabel.Parent := pnlTop;
         mlabel.Left := 5;
         mLabel.Caption := mMessage;
         mLabel.Font.Size := 10;

         mLabel := Tlabel.Create(pnlTop);
         mlabel.Parent := pnlTOP;
         mLabel.left := 382;
         mLabel.Font.Size := 10;
         mLabel.Caption := FormatFloat('0,',mValue)+' Kč.';
         mlabel.Font.Style := [fsBold];

         mLabel := Tlabel.Create(pnlTop);
         mlabel.Parent := pnlTOP;
         mLabel.left := 382;
         mLabel.Top := 90;
         mLabel.Font.Size := 10;
         mLabel.Name := 'lblAmount';
         mLabel.Caption := FormatFloat('0,',mPromotionvalue)+' Kč.';
         mlabel.Font.Style := [fsBold];

         mLabel := Tlabel.Create(pnlTop);
         mlabel.Parent := pnlTOP;
         mLabel.left := 5;
         mLabel.Top := 90;
         mLabel.Caption := 'Nyní jsou ve formuláři zadány odměny v hodnotě: ';
         mlabel.Font.Size := 10;

         pnlMain := TPanel.Create(frmBilance);
         pnlMain.Align:= alClient;
         pnlMain.Parent:= frmBilance;

         pnlBottom := TPanel.Create(frmBilance);
         pnlBottom.Align:= alBottom;
         pnlBottom.Parent:= frmBilance;
         pnlBottom.Height:= 150;
         pnlBottom.BottomInModalDialog:= True;

         if (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='03') or (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='05') then begin
           mLabel := Tlabel.Create(pnlBottom);
           mlabel.Parent := pnlBottom;
           mLabel.left := 5;
           mlabel.Align := alLeft;
           mLabel.Caption := 'Pozor. Přes tento formulář nelze snížit množství odměn, které byly importovány z dodacího listu.'+#13#10+'Takový pokus skončí chybou a budete muset začít znovu.';
           mlabel.Font.Style := [fsBold];
         end;

       //  mGrid:= TDbGrid(mSite.FindChildControl('grdList'));
      //   mGrid.DataSource.DataSet.DisableControls;
         if True then begin
          // mBookmark := mGrid.DataSource.DataSet.Bookmark;
           if ss.Count > 0 then begin
        //     NxShowMessage('C','Prošel jsem',mdInformation,True,frmBilance);
            dsPOZ := TDataSource.Create(frmBilance);
            dsPOZ.Name := 'dsPOZ';

            grdPOZ:= TMultiGrid.Create(frmBilance);
            grdPOZ.Parent := pnlMain;
            grdPOZ.Name := 'grdPOZEdit';
            grdPOZ.Align := alClient;

            grdPOZ.DataSource := dsPOZ;
            grdPOZ.Options := [goHeaders, goGap,goFixRowLines, goFixColLines, goRowLines, goColLines, goAllowAppend, goAllowEdit, goAlwaysShowEditor_1, goAlwaysShowSelection, goMultiSelect];
            grdPOZ.OnKeyUp := @OnMyKeyUP;



            dtPOZ := TMemoryDataset.Create(grdPOZ);
            dtPOZ.Name := 'dtVMVEdit';
          //  dtVMV.OnFilterRecord := @dtVYPFilterRecord;
            dtPOZ.Filtered := True;
            dtPOZ.Close;

            order:=0;


            mColR := TNxMultiGridRollColumn.Create(grdPOZ);
            mColR.ClassID:='S3WZQKDB5FDL342M01C0CX3FCC';
            mColR.TextField := 'Code';
            mColR.Layout := 0;
            order:=order+1;
            mColR.Order := order;
            mColR.FieldName := 'StoreCard_Code';
            mColR.Caption := 'Katalogové číslo';
            mColR.Name := 'StoreCard_Code';
            mColR.Width := 120;
            grdPOZ.AddColumn(mColR);

            mColR := TNxMultiGridRollColumn.Create(grdPOZ);
            mColR.ClassID:='S3WZQKDB5FDL342M01C0CX3FCC';
            mColR.TextField := 'Name';
            mColR.Layout := 0;
            order:=order+1;
            mColR.Order := order;
            mColR.FieldName := 'StoreCard_Name';
            mColR.Caption := 'Název dárku - odměny';
            mColR.Name := 'StoreCard_Name';
            mColR.Width := 350;
            grdPOZ.AddColumn(mColR);

            {mColL := TNxMultiGridLookupColumn.Create(grdPOZ);
            mColL.Values.Add('NE=0');
            mColL.Values.Add('ANO=1');
            mColL.Layout := 0;
            order:=order+1;
            mColL.Order := order;
            mColL.FieldName := 'Generate';
            mColL.Caption := 'Generovat';
            mColL.Name := 'Generate';
            mColL.Width:= 80;
            grdPOZ.AddColumn(mColL); }

            mCol := TNxMultiGridColumn.Create(grdPOZ);
            mCol.Layout := 0;
            order:=order+1;
            mCol.Order := order;
            mCol.FieldName := 'Quantity';
            mCol.Caption := 'Skladem';
            mCol.Name := 'Quantity';
            mCol.Width := 60;
            grdPOZ.AddColumn(mCol);

            mCol := TNxMultiGridColumn.Create(grdPOZ);
            mCol.Layout := 0;
            order:=order+1;
            mCol.Order := order;
            mCol.FieldName := 'Quantity2';
            mCol.Caption := 'Vydat/vydáno';
            mCol.Name := 'Quantity2';
            mCol.Width := 80;
            grdPOZ.AddColumn(mCol);

            mCol := TNxMultiGridColumn.Create(grdPOZ);
            mCol.Layout := 0;
            order:=order+1;
            mCol.Order := order;
            mCol.FieldName := 'Hodnota';
            mCol.Caption := 'Hranice odměny';
            mCol.Name := 'Hodnota';
            mCol.Width := 60;
            grdPOZ.AddColumn(mCol);

            order:=0;

            {order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'BusOrder_Code', ftString, 10, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'BusOrder_Code', False);
            fld.ReadOnly := False;
            fld.FieldName := 'BusOrder_Code';
            fld.FieldKind := fkData;  }

            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'StoreCard_Code', ftString, 10, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'StoreCard_Code', False);
            fld.ReadOnly := False;
            fld.FieldName := 'StoreCard_Code';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'StoreCard_Name', ftString, 10, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'StoreCard_Name', False);
            fld.ReadOnly := False;
            fld.FieldName := 'StoreCard_Name';
            fld.FieldKind := fkData;



            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'Quantity', ftFloat, 0, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'Quantity', False);
            fld.ReadOnly := False;
            fld.FieldName := 'Quantity';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'Quantity2', ftFloat, 0, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'Quantity2', False);
            fld.ReadOnly := False;
            fld.FieldName := 'Quantity2';
            fld.FieldKind := fkData;
            fld.OnChange := @OnMyCellclick2;

            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'Quantity3', ftFloat, 0, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'Quantity3', False);
            fld.ReadOnly := False;
            fld.FieldName := 'Quantity3';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'Hodnota', ftFloat, 0, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'Hodnota', False);
            fld.ReadOnly := False;
            fld.FieldName := 'Hodnota';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtPOZ.FieldDefs, 'SC_ID', ftString, 10, False, order);
            fld := fd.CreateField(dtPOZ, nil, 'SC_ID', False);
            fld.ReadOnly := False;
            fld.FieldName := 'SC_ID';
            fld.FieldKind := fkData;


            dsPOZ.DataSet := dtPoz;

            if not dtPOZ.Active then dtPOZ.Open;

            for i := 0 to (SS.Count - 1) do begin
             mStoreCardBO:=mSite.BaseObjectSpace.CreateObject(Class_StoreCard);
             mStoreCardBO.Load(ss.strings[i],nil);
             mRowQuantity:=0;
             mFromDL:=False;
                for k:=0 to mrows.Count-1 do begin
                  if (mRows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID')=mStoreCardBO.OID) then begin
                    //if ((mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='03') or (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='05')) and not(NxIsEmptyOID(mrows.BusinessObject[k].GetFieldValueAsString('ProvideRow_ID'))) then mFromDL:=True;
                    mRowQuantity:=mRowQuantity+mrows.BusinessObject[k].GetFieldValueAsFloat('Quantity');
                  end;
                end;
                if not(mfromDL) then begin
                dtPOZ.Append;
                //dtPOZ.FieldByName('BusOrder_Code').AsString:=mDataSet.FieldByName('BusOrder_ID').AsString;
                dtPOZ.FieldByName('StoreCard_Code').AsString:=mStoreCardBO.OID;
                dtPOZ.FieldByName('StoreCard_Name').AsString:=mStoreCardBO.OID;
                mRes:=TStringList.Create;
                mSite.BaseObjectSpace.SQLSelect(format('Select sum(quantity) from storesubcards where storecard_id=''%s'' and store_ID=''%s'' ',[mStoreCardBO.OID, mStore_ID]),mRes);
                mSCQuantity:=NxIBStrToFloat(mRes.Strings[0]);
                mSCReservedQuantity:=NxEvalObjectExprAsFloat(mbo,'NxGetReservedQuantity('+Quotedstr(mStoreCardBO.OID)+','+Quotedstr(mStore_ID)+')');
                if mSCReservedQuantity<mSCQuantity then dtPoz.FieldByName('Quantity').AsFloat:=mSCQuantity-mSCReservedQuantity else dtPoz.FieldByName('Quantity').AsFloat:=0;

                dtpoz.FieldByName('Quantity3').AsFloat:=mRowQuantity;
                dtpoz.FieldByName('Hodnota').AsFloat:=mStoreCardBO.GetFieldValueAsFloat('U_PromotionValue');
                dtPOZ.FieldByName('SC_ID').AsString:=mStoreCardBO.OID;
                dtpoz.FieldByName('Quantity2').AsFloat:=mRowQuantity;
                mRes.free;
                end;
             mStoreCardBO.free;
             end;
            //mDataSet.GotoBookmark(mBookmark);
            //dtPOZ.FieldByName('BusOrder_Code').ReadOnly:=True;
            dtPOZ.FieldByName('StoreCard_Code').ReadOnly:=True;
            dtPOZ.FieldByName('StoreCard_Name').ReadOnly:=True;
            dtPoz.FieldByName('Quantity').ReadOnly:=True;
            dtPoz.FieldByName('Hodnota').ReadOnly:=True;
           end;
           dtPOZ.First;
         end;

         btnOk := TButton.Create(frmBilance);
         btnOk.Parent := pnlBottom;
         btnOk.Name := 'btnOk';
         btnOk.Caption := 'Vložit dárky';
         btnOk.Font.Style := [fsBold];
         btnOk.Left := 470;
         btnOk.Top := 90;
         btnOk.Width := 200;
         btnOk.Height := 25;
         btnOk.ModalResult := mrOk; //mrNone
         btnOk.Anchors := [akRight];
         btnOK.Hint := 'Vytvoří doklady podle zadání ve formuláři.';

         btnStorno := TButton.Create(frmBilance);
         btnStorno.Parent := pnlBottom;
         btnStorno.Name := 'btnCancel';
         btnStorno.Caption := 'Zrušit';
         btnStorno.Font.Style := [fsBold];
         btnStorno.Left := 600;
         btnStorno.Top := 90;
         btnStorno.Width := 120;
         btnStorno.Height := 25;
         btnStorno.ModalResult := mrCancel;
         btnStorno.Anchors := [akRight];
         btnStorno.Hint := 'Zruší odvod a zapomene změny.';

         //iResult := 10;
         iResult := frmBilance.ShowModal(mSite.GetParentForm);
        end;
         if iResult>0 then begin
            dtPOZ.First;
            if iResult = mrOk then begin

                While not dtPOZ.Eof do begin
                 if dtPOZ.FieldByName('Quantity2').asfloat > 0 then mCalculatedValue:=mCalculatedValue+(dtPOZ.FieldByName('Quantity2').asfloat*dtPOZ.FieldByName('Hodnota').asfloat);
                 dtPOZ.Next;
                end;
                 if mCalculatedValue>mValue then begin
                  NxShowSimpleMessage('Hodnota odměn zadaných přes tlačítko  ('+FormatFloat('0,',mCalculatedValue)+') je vyšší než je nárok zákazníka ('+FormatFloat('0,',mvalue)+'). V dokladu jsem neprovedl žádnou změnu. Zopakujte prosím celou akci a zadejte správné množství odměn.',msite);
                  exit;
                 end;

            end;
            if (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='03') or (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='05') then begin
              dtPOZ.First;
              if iResult = mrOk then begin
                While not dtPOZ.Eof do begin
                  if dtPOZ.FieldByName('Quantity2').asfloat<dtPOZ.FieldByName('Quantity3').AsFloat then begin
                    for i:=0 to mRows.Count-1 do begin
                     if not(NxIsEmptyOID(mrows.BusinessObject[k].GetFieldValueAsString('ProvideRow_ID'))) and (mrows.BusinessObject[k].GetFieldValueAsString('StoreCard_ID')=dtPOZ.FieldByName('SC_ID').AsString) then begin
                       NxShowSimpleMessage('Ve formuláři jste snížili jste množstí dárků u řádků, které byly importovány z DL. Již vydané množství dárku nelze měnit. Neprovedl jsem žádnou změnu, klikněte na akce dárky a začněte znovu.',mSite);
                       exit;
                     end;
                    end;
                  end;
                 dtPOZ.Next;
                end;
              end;
            end;
            dtPOZ.First;
            if iResult = mrOk then begin
                for i:=0 to mRows.Count-1 do begin
                  if (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='03') or (mbo.GetFieldValueAsString('DocQueue_ID.DocumentType')='05') then begin
                   if mrows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_PromotionChoice') and NxIsEmptyOID(mrows.BusinessObject[k].GetFieldValueAsString('ProvideRow_ID')) then mrows.BusinessObject[i].MarkForDelete;
                  end else begin
                   if mrows.BusinessObject[i].GetFieldValueAsBoolean('StoreCard_ID.U_PromotionChoice') then mrows.BusinessObject[i].MarkForDelete;
                  end;
                end;
                try
                mControl:= mSite.FindChildControl('tabRows.grdRows');
                mRowDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
                mRowDataSet.DisableControls;
                  While not dtPOZ.Eof do begin
                  if (dtPOZ.FieldByName('Quantity2').asfloat > 0) then begin
                    if Assigned(mRowDataset) then begin
                     mRowBO := mRowDataSet.CreateBusinessObject;
                     mRowBO.Prefill;
                     mrowbo.SetFieldValueAsInteger('RowType',3);
                     mRowBo.SetFieldValueAsString('Store_ID',mStore_ID);
                     mrowBo.SetFieldValueAsString('StoreCard_ID',dtPOZ.FieldByName('SC_ID').AsString);
                     mRowBO.SetFieldValueAsFloat('Quantity', dtPOZ.FieldByName('Quantity2').asfloat);
                     mRowBo.SetFieldValueAsString('Division_ID',mDivision_ID);
                     mRowBo.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
                     mRowBo.SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
                    end;
                   end;
                   dtPOZ.Next;
                  end;

                finally
                   //Aby se o změně dozvěděl hlavičkový dataset


                      TDynSiteForm(mSite).ActiveDataSet.UpdateFields;
                      mRowDataset.RefreshAndRestoreLastSelectedItem;
                      mRowDataSet.EnableControls;
                end;
            end;
       end;
    finally
      frmBilance.Free;
      mSQLResult.Free;
      mSQLResult2.Free;
      //NxShowSimpleMessage('Provedeno.',mSite);

      //TDynSiteForm(mSite).RefreshData;
    end;






   //konec skriptu
  end;

  //má hodnotu a dluží

  if mValue=0 then NxShowSimpleMessage('Doklad neobsahuje žádné zboží v akci dárky "lahvobbraní".',msite);

end;

begin
end.