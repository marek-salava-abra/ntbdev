procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '##Vytvoř dodací list##';
  mAction.Items.Add('##Vytvoř dodací list##');
  mAction.Items.Add('##Vytvoř převodku výdej##');
  mAction.Items.Add('##Vytvoř záměnu výdej##');
  mAction.Items.Add('##Vytvoř přeměnu výdej##');
  mAction.Items.Add('##Vytvoř příjemku##');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CreateSD;
end;

Procedure CreateSD(Sender:TComponent;index:integer);
var
 mSite:TSiteForm;
 i,j, mResult, mSBCount:integer;
 mList:TStringList;
 mOS:TNxCustomObjectSpace;
 mStore_ID, mDivision_ID, mStoreCard_ID, mName:string;
 mSDBO, mSDRowBO, mDRBBO, mSBBO:TNxCustomBusinessObject;
 mRows, mDRBCol:TNxCustomBusinessMonikerCollection;
 mQuantity:extended;
 mSDSite: TOpenDynSite;
 mClass, mMSite:string;
 frmStoreBatches:TForm;
 mR:TMemoryDataset;
 btnOK: TButton;
 btnStorno: TButton;
 pnlMain, pnlBottom: TPanel;

 iResult,order: Integer;

 mGrid: TDBGrid;
 mDS: TNxCustomObjectDataSet;
 grdStoreBatches: TMultiGrid;
 dtStoreBatches: TMemoryDataset;
 dsStoreBatches: TDataSource;

 mCol: TNxMultiGridColumn;
 mColR: TNxMultiGridRollColumn;
 mColL: TNxMultiGridLookupColumn;
 mColD: TNxMultiGridDateColumn;
 fd: TFieldDef;
 fld: TField;
begin
 case Index of
            0: begin
                mClass:= Class_BillOfDelivery;
                mMsite:= Site_BillOfDeliveries;
                mName:=  'dodací list';
            end;
            1: begin
                mClass:= Class_OutgoingTransfer;
                mMsite:= Site_OutgoingTransfers;
                mName:=  'převodku výdej';
            end;
            2: begin
                mClass:= Class_OutgoingSubstitution;
                mMsite:= Site_OutgoingSubstitutions;
                mName:=  'záměnu výdej';
            end;
            3: begin
                mClass:= Class_OutgoingTransformation;
                mMsite:= Site_OutgoingTransformations;
                mName:=  'přeměnu výdej';
            end;
            4: begin
                mClass:= Class_ReceiptCard;
                mMsite:= Site_ReceiptCards;
                mName:=  'příjemku';
            end;

 end;
 mSite:=TComponent(Sender).BusRollSite;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=msite.BaseObjectSpace;
 if mlist.count>0 then begin
  mResult:=0;
  if GetDataForBOD(msite, mStore_ID, mDivision_ID, mResult, mName) then begin
      if mResult=1 then begin
         frmStoreBatches:= TForm.Create(mSite);
         frmStoreBatches.Top:= 20;
         frmStoreBatches.Left:= 20;
         frmStoreBatches.Width:= 700;
         frmStoreBatches.Height:= 600;
         frmStoreBatches.Caption:= 'Údaje pro šarže';

         pnlMain := TPanel.Create(frmStoreBatches);
         pnlMain.Align:= alClient;
         pnlMain.Parent:= frmStoreBatches;

         pnlBottom := TPanel.Create(frmStoreBatches);
         pnlBottom.Align:= alBottom;
         pnlBottom.Parent:= frmStoreBatches;
         pnlBottom.Height:= 100;
         pnlBottom.BottomInModalDialog:= True;


        if mlist.Count>0 then begin
            dsStoreBatches := TDataSource.Create(frmStoreBatches);
            dsStoreBatches.Name := 'dsStoreBatches';


            grdStoreBatches:= TMultiGrid.Create(frmStoreBatches);
            grdStoreBatches.Parent := pnlMain;
            grdStoreBatches.Name := 'grdStoreBatchesEdit';
            grdStoreBatches.Align := alClient;

            grdStoreBatches.DataSource := dsStoreBatches;
            grdStoreBatches.Options := [goHeaders, goGap,goFixRowLines, goFixColLines, goRowLines, goColLines, goAllowAppend, goAllowEdit, goAlwaysShowEditor_1, goAlwaysShowSelection, goMultiSelect];

            dtStoreBatches := TMemoryDataset.Create(grdStoreBatches);
            dtStoreBatches.Name := 'dtStoreBatchEdit';

            dtStoreBatches.Filtered := True;
            dtStoreBatches.Close;

            order:=0;
            mColR := TNxMultiGridRollColumn.Create(grdStoreBatches);
            mColR.ClassID:=Roll_StoreBatches;
            mColR.TextField := 'Name';
            mColR.Layout := 0;
            order:=order+1;
            mColR.Order := order;
            mColR.FieldName := 'StoreBatch_Name';
            mColR.Caption := 'Šarže:';
            mColR.Name := 'StoreBatch_Name';
            mColR.Width := 100;
            grdStoreBatches.AddColumn(mColR);

            mColR := TNxMultiGridRollColumn.Create(grdStoreBatches);
            mColR.ClassID:=Roll_StoreCards;
            mColR.TextField := 'Code';
            mColR.Layout := 0;
            order:=order+1;
            mColR.Order := order;
            mColR.FieldName := 'StoreCard_Code';
            mColR.Caption := 'Kód karty';
            mColR.Name := 'StoreCard_Code';
            mColR.Width := 100;
            grdStoreBatches.AddColumn(mColR);

            mColR := TNxMultiGridRollColumn.Create(grdStoreBatches);
            mColR.ClassID:=Roll_StoreCards;
            mColR.TextField := 'Name';
            mColR.Layout := 0;
            order:=order+1;
            mColR.Order := order;
            mColR.FieldName := 'StoreCard_Name';
            mColR.Caption := 'Název karty';
            mColR.Name := 'StoreCard_Name';
            mColR.Width := 300;
            grdStoreBatches.AddColumn(mColR);

            {mColL := TNxMultiGridLookupColumn.Create(grdStoreBatches);
            mColL.Values.Add('NE=0');
            mColL.Values.Add('ANO=1');
            mColL.Layout := 0;
            order:=order+1;
            mColL.Order := order;
            mColL.FieldName := 'Generate';
            mColL.Caption := 'Generovat';
            mColL.Name := 'Generate';
            mColL.Width:= 80;
            grdStoreBatches.AddColumn(mColL); }

            mCol := TNxMultiGridColumn.Create(grdStoreBatches);
            mCol.Layout := 0;
            order:=order+1;
            mCol.Order := order;
            mCol.FieldName := 'Quantity';
            mCol.Caption := 'Skladem';
            mCol.Name := 'Quantity';
            mCol.Width := 60;
            grdStoreBatches.AddColumn(mCol);

            mCol := TNxMultiGridColumn.Create(grdStoreBatches);
            mCol.Layout := 0;
            order:=order+1;
            mCol.Order := order;
            mCol.FieldName := 'Quantity2';
            mCol.Caption := 'Množství';
            mCol.Name := 'Quantity2';
            mCol.Width := 60;
            mCol.Kind := ckText;
            grdStoreBatches.AddColumn(mCol);

            order:=0;

            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'StoreBatch_Name', ftString, 10, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'StoreBatch_Name', False);
            fld.ReadOnly := False;
            fld.FieldName := 'StoreBatch_Name';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'StoreCard_Code', ftString, 10, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'StoreCard_Code', False);
            fld.ReadOnly := False;
            fld.FieldName := 'StoreCard_Code';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'StoreCard_Name', ftString, 10, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'StoreCard_Name', False);
            fld.ReadOnly := False;
            fld.FieldName := 'StoreCard_Name';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'Quantity', ftFloat, 0, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'Quantity', False);
            fld.ReadOnly := False;
            fld.FieldName := 'Quantity';
            fld.FieldKind := fkData;

            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'Quantity2', ftString, 30, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'Quantity2', False);
            fld.ReadOnly := False;
            fld.FieldName := 'Quantity2';
            fld.FieldKind := fkData;
            fld.ValidChars := '0123456789,';

            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'SB_ID', ftString, 10, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'SB_ID', False);
            fld.ReadOnly := False;
            fld.FieldName := 'SB_ID';
            fld.FieldKind := fkData;


            order:=order+1;
            fd := TFieldDef.Create(dtStoreBatches.FieldDefs, 'StoreCard_ID', ftString, 10, False, order);
            fld := fd.CreateField(dtStoreBatches, nil, 'StoreCard_ID', False);
            fld.ReadOnly := False;
            fld.FieldName := 'StoreCard_ID';
            fld.FieldKind := fkData;

            dsStoreBatches.DataSet := dtStoreBatches;
            if not dtStoreBatches.Active then dtStoreBatches.Open;
            SortBatches(mOS, mList);


            mSBCount:=0;
            for i := 0 to (mList.Count - 1) do begin

              //upravit pro příjemku, neexistence dílčí šarže
              if mOS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubbatches where storebatch_id='+QuotedStr(mList.Strings[i])+' and store_id='+QuotedStr(mStore_ID),0)>=0 then begin
                mSBBO:=mOS.CreateObject(Class_StoreBatch);
                mSBBO.Load(mlist.strings[i],nil);
                dtStoreBatches.Append;
                dtStoreBatches.FieldByName('Storebatch_Name').AsString:=mSBBO.OID;
                dtStoreBatches.FieldByName('SB_ID').AsString:=msbbo.OID;
                dtStoreBatches.FieldByName('StoreCard_ID').AsString:=msbbo.GetFieldValueAsString('StoreCard_ID');
                dtStoreBatches.FieldByName('StoreCard_Code').AsString:=msbbo.GetFieldValueAsString('StoreCard_ID');
                dtStoreBatches.FieldByName('StoreCard_Name').AsString:=msbbo.GetFieldValueAsString('StoreCard_ID');
                dtStoreBatches.FieldByName('Quantity').AsFloat:=mOS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubbatches where storebatch_id='+QuotedStr(mList.Strings[i])+' and store_id='+QuotedStr(mStore_ID),0);
                dtStoreBatches.FieldByName('Quantity2').AsString:=FloatToStr(mOS.SQLSelectFirstAsExtended('Select sum(X_quantity) from storebatches where id='+QuotedStr(mList.Strings[i]),0));
                mSBBO.free;
                mSBCount:=mSBCount+1;
               end;
             end;
            dtStoreBatches.FieldByName('Storebatch_Name').ReadOnly:=True;
            dtStoreBatches.FieldByName('StoreCard_Code').ReadOnly:=True;
            dtStoreBatches.FieldByName('StoreCard_Name').ReadOnly:=True;
            dtStoreBatches.FieldByName('Quantity').ReadOnly:=True;
           end;
         dtStoreBatches.First;
         //end;
         btnOk := TButton.Create(frmStoreBatches);
         btnOk.Parent := pnlBottom;
         btnOk.Name := 'btnOk';
         btnOk.Caption := 'Vytvořit';
         btnOk.Font.Style := [fsBold];
         btnOk.Left := 470;
         btnOk.Top := 20;
         btnOk.Width := 200;
         btnOk.Height := 25;
         btnOk.ModalResult := mrOk; //mrNone
         btnOk.Anchors := [akRight];
         btnOK.Hint := 'Vytvoří.';

         btnStorno := TButton.Create(frmStoreBatches);
         btnStorno.Parent := pnlBottom;
         btnStorno.Name := 'btnCancel';
         btnStorno.Caption := 'Zrušit';
         btnStorno.Font.Style := [fsBold];
         btnStorno.Left := 600;
         btnStorno.Top := 20;
         btnStorno.Width := 120;
         btnStorno.Height := 25;
         btnStorno.ModalResult := mrCancel;
         btnStorno.Anchors := [akRight];
         btnStorno.Hint := 'Zruší.';
         //iResult := 10;
         iResult := frmStoreBatches.ShowModal(mSite.GetParentForm);
        end;

  //konec dialogu
       if iResult>0 then begin
        dtStoreBatches.First;
        if iResult = mrOk then begin
          if NxMessageBox('Dotaz', 'Vygenerovat '+mName+' pro '+IntToStr(mSBCount)+' položek?', mdConfirm, mdbYesNo, 2, 0, False, nil) = mrYes then begin
            mSDBO:=mOS.CreateObject(mClass);
            mSDBO.new;
            mSDBO.prefill;
            mRows:=mSDBO.GetLoadedCollectionMonikerForFieldCode(mSDBO.GetFieldCode('Rows'));
            While not dtStoreBatches.Eof do begin
              if StrToFloat(dtStoreBatches.FieldByName('Quantity2').AsString) > 0 then   begin
                 mSDRowBO:=mRows.AddNewObject;
                 mSDRowBO.prefill;
                 if not(mClass=Class_ReceiptCard) then mSDRowBO.SetFieldValueAsInteger('RowType',3);
                 mSDRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
                 mSDRowBO.SetFieldValueAsString('StoreCard_ID',dtStoreBatches.FieldByName('StoreCard_ID').AsString);
                 mSDRowBO.SetFieldValueAsFloat('Quantity',StrToFloat(dtStoreBatches.FieldByName('Quantity2').asString));
                 mSDRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                 mDRBCol:=mSDRowBO.GetLoadedCollectionMonikerForFieldCode(mSDRowBO.GetFieldCode('DocRowBatches'));
                 mDRBBO:=mDRBCol.AddNewObject;
                 mDRBBO.SetFieldValueAsString('StoreBatch_ID',dtStoreBatches.FieldByName('SB_ID').AsString);
              end;
              dtStoreBatches.next;
            end;
            {for i:=0 to mlist.count-1 do begin
               mQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity from storesubbatches where storebatch_id='+QuotedStr(mList.Strings[i])+' and store_id='+QuotedStr(mStore_ID),0);
               if mQuantity>0 then begin
                 mSDRowBO:=mRows.AddNewObject;
                 mSDRowBO.prefill;
                 mSDRowBO.SetFieldValueAsInteger('RowType',3);
                 mSDRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
                 mSDRowBO.SetFieldValueAsString('StoreCard_ID',mos.SQLSelectFirstAsString('Select storecard_id from storebatches where id='+QuotedStr(mlist.strings[i]),''));
                 mSDRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
                 mSDRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                 mDRBCol:=mSDRowBO.GetLoadedCollectionMonikerForFieldCode(mSDRowBO.GetFieldCode('DocRowBatches'));
                 mDRBBO:=mDRBCol.AddNewObject;
                 mDRBBO.SetFieldValueAsString('StoreBatch_ID',mList.Strings[i]);
               end;
            end; }

            if Assigned(mSDBO) then begin
              //TDynSiteForm.ShowDynFormWithNewDocumen('B50I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mBODBO);
              mSDSite:=TOpenDynSite.Create(msite.SiteContext,mMSite);
              mSDSite.NewDoc:=mSDBO;
              mSDSite.InOtherSlot:=true;
              mSDSite.Open;
            end;
          end;
         end;
      end
     end;
  end;

end;

Function GetDataForBOD(var ASite : TSiteform; var aStore_ID, aDivision_ID: string; var aResult:integer;var aName:string):Boolean;
var
    mLabel1,mCbCCSourceStore,mCbCCDestStore, mCbCCDivision: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mNumEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mDed, mDed1:TDateEdit;
    mCbSourceStore, mCBDestStore, mCBDivision: TRollComboEdit;
    mAllowedBOD, mAllowedVR:TStringList;
    mParBOD, mParVR:String;
    {mAllowed:=TStringList.create;
    mSQL3 := 'select id from StoreCards where hidden=''N'' ';
    dSite.BaseObjectSpace.SQLSelect(mSQL3,mAllowed);
    mParam3:=mAllowed.DelimitedText;
    mCbMaterial.Parameters.Clear;
    mCbMaterial.Parameters.Add('_Allowed='+mParam3);}
begin
 if ASite <> nil then begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 175;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Data pro '+aName;


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Sklad:';
    mLabel1.Top := 12;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCDestStore:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCDestStore.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCDestStore.Left:= 236;
    mCbCCDestStore.Top:= 12;
    mCbCCDestStore.Width:= 255;

    mCBDestStore:= TRollComboEdit.Create(mForm);
    mCBDestStore.Parent:= mForm;

    mCBDestStore.ClassID:= Roll_Stores;
    mCBDestStore.Complete:= True;
    mCBDestStore.Prefilling:= pmNone;
    mCBDestStore.TextField:= 'Code';  // položka podle které se bude vyhledávat středisko
    mCBDestStore.Top:= 10;
    mCBDestStore.Left:= 110;
    mCBDestStore.Width:= 108;
    mCBDestStore.DataText:=aStore_ID;
    mCBDestStore.ConnectedControl:= mCbCCDestStore;
    mCBDestStore.ConnectedControlField:= 'Name';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Středisko:';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCDivision:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCDivision.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCDivision.Left:= 236;
    mCbCCDivision.Top:= 37;
    mCbCCDivision.Width:= 255;

    mCBDivision:= TRollComboEdit.Create(mForm);
    mCBDivision.Parent:= mForm;

    mCBDivision.ClassID:= Roll_Divisions;
    mCBDivision.Complete:= True;
    mCBDivision.Prefilling:= pmNone;
    mCBDivision.TextField:= 'Code';  // položka podle které se bude vyhledávat středisko
    mCBDivision.Top:= 35;
    mCBDivision.Left:= 110;
    mCBDivision.Width:= 108;
    mCBDivision.DataText:=aDivision_ID;
    mCBDivision.ConnectedControl:= mCbCCDivision;
    mCBDivision.ConnectedControlField:= 'Name';

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Default:= true;
    mButOk.Top := 100;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 100;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then
         aResult:=1;
         aStore_ID:=mCBDestStore.DataText;
         aDivision_ID:=mCBDivision.DataText;
         Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;


procedure SortBatches(AOS: TNxCustomObjectSpace; AList: TStringList);
var
  mSelectedIDs: string;
  mResult: TMemoryDataset;
begin
  mSelectedIDs := AList.CommaText;
  mSelectedIDs := StringReplace(mSelectedIDs, ',', ''',''', [rfReplaceAll, rfIgnoreCase]);
  mResult := TMemoryDataset.Create(nil);
  try
    AOS.SQLSelect2(Format('select sb.id as ID from storebatches sb left join storecards sc on sc.id=sb.storecard_id where sb.id in (''%s'') order by sc.name, sb.name', [mSelectedIDs]), mResult);
    AList.Clear;
    mResult.First;
    while not mResult.Eof do
    begin
      Alist.Add(mResult.FieldByName('ID').AsString);
      mResult.Next;
    end;
  finally
    mResult.Free;
  end;
end;

begin
end.