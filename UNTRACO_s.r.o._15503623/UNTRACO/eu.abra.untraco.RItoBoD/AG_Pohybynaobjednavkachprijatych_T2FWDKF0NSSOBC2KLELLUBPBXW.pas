uses 'eu.abra.untraco.RItoBOD.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2, mBut3: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Vytvořit DL';
mBut.Category := 'tabList';
mBut.OnExecute := @CreateBOD;
mBut2:= Self.GetNewAction;
mBut2.ShowControl := True;
mBut2.ShowMenuItem := True;
mBut2.Caption := 'Vytvoř OV';
mBut2.Category := 'tabList';
mBut2.OnExecute := @CreateIO;
mBut3:= Self.GetNewAction;
mBut3.ShowControl := True;
mBut3.ShowMenuItem := True;
mBut3.Caption := 'Vytvoř OVO';
mBut3.Category := 'tabList';
mBut3.OnExecute := @CreateIO2;
end;


procedure CreateBOD(Sender: TObject);
var mSite : TSiteForm;
    mGrid : TDBGrid;
    mList, mList2 : TStringList;
    mReceivedOrder,mRow, mStoreCard, mStore:TNxCustomBusinessObject;
    i,j: Integer;
    mImportMan: TNxDocumentImportManager;
    mOS: TNxCustomObjectSpace;
    mInputParams: TNxParameters;
    mParam: TNxParameter;
    mStoreSubcardQuantity:Extended;


begin
mList := TStringList.Create;
 mInputParams := TNxParameters.Create;
 mlist2 := TStringList.create;
try
 mSite := NxFindSiteForm(TComponent(Sender));
// mGrid := TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList'));
 if Assigned(mSite) then begin
  TDynSiteForm(mSite).FillListWithSelectedRows(mList);
   if (mList.count) > 0 then begin
     if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit dodací listy z ' + (inttostr(mlist.count))+' záznamů?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
      mRow:= mSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
         mReceivedOrder:=msite.BaseObjectSpace.CreateObject(Class_ReceivedOrder);
         mos:=msite.BaseObjectSpace;
         // skladový doklad tvorba zacatek Centrální sklad
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='1000000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := 'K000000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'K000000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec centrální sklad
       // skladový doklad tvorba zacatek PHARMOS OSTRAVA
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='1300000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '1710000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1710000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec PHARMOS OSTRAVA
        // skladový doklad tvorba zacatek Dentimed Litomyšl
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='2100000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '3210000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '3210000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Dentimed Litomyšl
       // skladový doklad tvorba zacatek MK Market Praha
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='2100000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '3210000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '3210000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec MK Market Praha
       // skladový doklad tvorba zacatek Martek Medical Brno
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='2200000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '2310000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2310000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Martek Medical Brno
       // skladový doklad tvorba zacatek Medimat České Budějovice
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='3200000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '3310000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '3310000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Medimat České Budějovice
       // skladový doklad tvorba zacatek Medist Zábřeh na Moravě
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='4200000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '4310000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '4310000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Medist Zábřeh na Moravě
       // skladový doklad tvorba zacatek Semileas Semily
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='5200000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '5310000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '5310000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Semileas Semily
       // skladový doklad tvorba zacatek Untraco Ostrava E-SHOP
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='6200000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '6310000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '6310000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Untraco Ostrava E-SHOP
       // skladový doklad tvorba zacatek Krmík Frenštát p. Radhoštěm
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='7200000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := 'M410000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'M410000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Krmík Frenštát p. Radhoštěm
       // skladový doklad tvorba zacatek Distrimed Český Těšín
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='1400000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '1H10000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1H10000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Distrimed Český Těšín
       // skladový doklad tvorba zacatek Městská nemocnice OVA -Fifejdy
         for i:=0 to mlist.count-1 do begin
          mrow.load(mlist.Strings[i],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
           if (mrow.GetFieldValueAsInteger('RowType')=3) and (mrow.GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           if mRow.GetFieldValueAsString('Store_ID')='1500000101' then begin
             mStoreSubcardQuantity:=0;
             mStoreSubcardQuantity:=GetQuantity(mOS,mrow.GetFieldValueAsString('Store_ID'),mrow.GetFieldValueAsString('StoreCard_ID'));
              if (mStoreSubcardQuantity-mRow.GetFieldValueAsFloat('Quantity'))<0 then begin
                mStoreCard:=mos.CreateObject(Class_StoreCard);
                mStoreCard.Load(mrow.GetFieldValueAsString('StoreCard_ID'),nil);
                mStore:=mos.CreateObject(Class_Store);
                mStore.Load(mrow.GetFieldValueAsString('Store_ID'),nil);
                if NxMessageBox('Dotaz', 'Množství na kartě '+mStoreCard.GetFieldValueAsString('Name')+' na skladě '+mstore.GetFieldValueAsString('Name')+' bude záporné. Přejete si pokračovat?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrNo then exit;
                mStoreCard.Free;
                mstore.Free;

              end;
             mList2.Add(mRow.OID);
           end;
         end;
         end;
         if mlist2.count>0 then begin
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '1J10000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList2.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1J10000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
            finally
              mImportMan.Free;
            end;

       j:=j+1;
       mlist2.Clear;
       mInputParams.ClearData;
       end;
       //konec Městská nemocnice OVA -Fifejdy


        end;
     end;
     End
   else
    MessageDlg('Nevybrán žádný záznam', mtError,[mbOk],0);


    finally
    mList.free;

end;
RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
if j=0 then ShowMessage('Již bylo vše importováno, nelze tvořit DL');
    if j>0 then ShowMessage('Vytvořil jsem '+IntToStr(j)+' dodacích listů');
end;


procedure CreateIO(Sender: TObject);
var mSite : TSiteForm;
    mGrid : TDBGrid;
    mList, mList2 : TStringList;
    mReceivedOrder,mRow, mStoreCard, mStore:TNxCustomBusinessObject;
    i,j: Integer;
    mImportMan: TNxDocumentImportManager;
    mOS: TNxCustomObjectSpace;
    mInputParams: TNxParameters;
    mParam: TNxParameter;
    mStoreSubcardQuantity:Extended;


begin
mList := TStringList.Create;
 mInputParams := TNxParameters.Create;
try
 mSite := NxFindSiteForm(TComponent(Sender));
// mGrid := TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList'));
 if Assigned(mSite) then begin
  TDynSiteForm(mSite).FillListWithSelectedRows(mList);
   if (mList.count) > 0 then begin
     if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit objednávku vydanou z ' + (inttostr(mlist.count))+' záznamů?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
      mRow:= mSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
         mReceivedOrder:=msite.BaseObjectSpace.CreateObject(Class_ReceivedOrder);
         mrow.load(mlist.Strings[0],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
         mos:=msite.BaseObjectSpace;
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '6100000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_IssuedOrder);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '6100000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.SetFieldValueAsString('ExternalNumber', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
               if NxMessageBox('Dotaz', 'Vytvořil jsem OV, přejete si zobrazit?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then

        mSite.ShowSite('GF53HAH3WBDL3C5P00CA141B44', True, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mImportMan.OutputDocument.OID)+';Omezení pro tvorbu OV');
            finally
              mImportMan.Free;
            end;

         end;
       end;
     End
   else
    MessageDlg('Nevybrán žádný záznam', mtError,[mbOk],0);


      finally
      mList.free;

  end;
RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));

end;

procedure CreateIO2(Sender: TObject);
var mSite : TSiteForm;
    mGrid : TDBGrid;
    mList, mList2 : TStringList;
    mReceivedOrder,mRow, mStoreCard, mStore:TNxCustomBusinessObject;
    i,j: Integer;
    mImportMan: TNxDocumentImportManager;
    mOS: TNxCustomObjectSpace;
    mInputParams: TNxParameters;
    mParam: TNxParameter;
    mStoreSubcardQuantity:Extended;


begin
mList := TStringList.Create;
 mInputParams := TNxParameters.Create;
try
 mSite := NxFindSiteForm(TComponent(Sender));
// mGrid := TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList'));
 if Assigned(mSite) then begin
  TDynSiteForm(mSite).FillListWithSelectedRows(mList);
   if (mList.count) > 0 then begin
     if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit objednávku vydanou z ' + (inttostr(mlist.count))+' záznamů?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
      mRow:= mSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
         mReceivedOrder:=msite.BaseObjectSpace.CreateObject(Class_ReceivedOrder);
         mrow.load(mlist.Strings[0],nil);
          mReceivedOrder.Load(mrow.GetFieldValueAsString('Parent_ID'),nil);
         mos:=msite.BaseObjectSpace;
         mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
         mParam.AsString := '1P10000101';
         mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
         mParam.AsString := mList.Text;
         mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_IssuedOrder);
            try
              mImportMan.AddInputDocument(mReceivedOrder.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1P10000101'); // musi byt...
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrder.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Description', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.SetFieldValueAsString('ExternalNumber', mReceivedOrder.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                end;
               if NxMessageBox('Dotaz', 'Vytvořil jsem OVO, přejete si zobrazit?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then

        mSite.ShowSite('GF53HAH3WBDL3C5P00CA141B44', True, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mImportMan.OutputDocument.OID)+';Omezení pro tvorbu OV');
            finally
              mImportMan.Free;
            end;

         end;
       end;
     End
   else
    MessageDlg('Nevybrán žádný záznam', mtError,[mbOk],0);


      finally
      mList.free;

  end;
RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));

end;

begin
end.