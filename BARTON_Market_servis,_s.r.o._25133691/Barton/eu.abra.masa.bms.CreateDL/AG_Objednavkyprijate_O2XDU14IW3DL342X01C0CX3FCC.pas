uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Name := 'actCreateDL';
  mAct.Caption := '##Vytvořit DL##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @CreateDL;
end;

procedure CreateDL(Sender:TComponent);
var
 mSite:TSiteForm;
 mOrderBO, mOrderRowBO, mBoDRowBO:TNxCustomBusinessObject;
 mDLList, mTypeList, mSelectedRows, mLog, mValidateErrors:TStringList;
 mOS:TNxCustomObjectSpace;
 mIndex, i, j:integer;
 mRows, mBoDRows:TNxCustomBusinessMonikerCollection;
 mImportMan, mImportMan2:TNxDocumentImportManager;
 mInputParams, mInputParams2:TNxParameters;
 mParam:TNxParameter;
 mStoreQuantity, mOrderQuantity:Extended;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mOrderBO:=TDynSiteForm(mSite).CurrentObject;
 if assigned(mOrderBO) then begin
    if DialogForDL(msite, mIndex,mOrderBO.DisplayName) then begin
       mTypeList:= TStringList.Create;
       mDLList:=TStringList.Create;
       mLog:=TStringList.Create;
       mTypeList.Duplicates := dupIgnore;
       mTypeList.Sorted:= True;
       mValidateErrors:= TStringList.Create;
       mLog.add('Zpracovávám objednávku '+mOrderBO.DisplayName);
       try
         mRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
         for i:=0 to mRows.count-1 do begin
           mOrderRowBO:=mRows.BusinessObject[i];
           if (mOrderRowBO.GetFieldValueAsInteger('RowType')=3) and (mOrderRowBO.GetFieldValueAsFloat('DeliveredQuantity') < mOrderRowBO.GetFieldValueAsFloat('Quantity')) then
            mTypeList.Add(mOrderRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.X_ExpSkup'));
         end;
         if mIndex=0 then begin
            mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
            mImportMan.AddInputDocument(mOrderBO.OID);
            mImportMan.SelectedHeader:= mImportMan.InputDocuments[0];
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtstring,'DocQueue_ID');
            mParam.AsString:=cDocQueue_DL_ID;
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            mImportMan.OutputDocument.save;
            mDLList.add(QuotedStr(mImportMan.OutputDocument.OID));
            mLog.Add(' - Vytvořen DL pro zbytek '+ mImportMan.OutputDocument.DisplayName);
         end;
         if mIndex=1 then begin
           mLog.Add(' - Obsahuje: '+IntToStr(mTypeList.Count)+' exp.skupin');
           WaitWin.StartProgress('Čekejte, prosím ...', '', mTypeList.Count);
           for i:= 0 to mTypeList.Count - 1 do begin
                mLog.Add(' - Zpracovávám: '+mTypeList.Strings[i]);
                mSelectedRows:=TStringList.Create;
                try
                 //dohledání řádků k dodání stejné expediční skupiny
                 for j:= 0 to mRows.Count - 1 do begin
                    mOrderRowBO:= mRows.BusinessObject(j);
                    if mOrderRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.X_ExpSkup') = mTypeList.strings[i] then
                    if mOrderRowBO.GetFieldValueAsFloat('DeliveredQuantity') < mOrderRowBO.GetFieldValueAsFloat('Quantity') then
                    begin
                       mSelectedRows.Add(mOrderRowBO.OID);
                    end;
                 end;
                 //konec dohledání řádků
                 if mSelectedRows.count>0 then begin
                   try
                    mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
                    mImportMan.AddInputDocument(mOrderBO.OID);
                    mImportMan.SelectedHeader:= mImportMan.InputDocuments[0];
                    mInputParams := TNxParameters.Create;
                    mParam := mInputParams.GetOrCreateParam(dtstring,'DocQueue_ID');
                    mParam.AsString:=cDocQueue_DL_ID;
                    mParam := mInputParams.GetOrCreateParam(dtInteger,'StoreQuantityKind');
                    mParam.asInteger:=mIndex;
                    mParam := mInputParams.GetOrCreateParam(dtstring,'SelectedRows');
                    mParam.AsString:=mSelectedRows.Text;
                    mImportMan.LoadParams(mInputParams);
                    mImportMan.Execute;
                      mBoDRows:= mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                      for j:=0 to mBoDRows.count-1 do begin
                        mBoDRowBO:=mBoDRows.BusinessObject[j];
                        mStoreQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity-bookedquantity from storesubcards where store_id='+QuotedStr(mBoDRowBO.GetFieldValueAsString('Store_ID'))+
                                                                     ' and storecard_id='+QuotedStr(mBoDRowBO.GetFieldValueAsString('StoreCard_ID')),0);
                        mOrderQuantity:=mOS.SQLSelectFirstAsExtended('Select Quantity-deliveredquantity from receivedorders2 where id='+QuotedStr(mBoDRowBO.GetFieldValueAsString('ProvideRow_ID')),0);
                        if mOrderQuantity>mStoreQuantity then mBoDRowBO.MarkForDelete;
                      end;
                    if mBoDRows.CountOfNotDeleted>0 then begin
                      //mImportMan.OutputDocument.SetFieldValueAsString('Description',mTypeList.Strings[i]);
                      mImportMan.OutputDocument.save;
                      mImportMan.OutputDocument.PMChangeState('2010000101');
                      mDLList.add(QuotedStr(mImportMan.OutputDocument.OID));
                      mLog.Add(' - Vytvořen DL pro '+ mTypeList.Strings[i]+' '+ mImportMan.OutputDocument.DisplayName);
                      mImportMan2 := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_LogStoreOutput);
                           try
                              mInputParams2 := TNxParameters.Create;
                              mImportMan2.AddInputDocument(mImportMan.OutputDocument.OID);
                              mImportMan2.SelectedHeader:= mImportMan2.InputDocuments[0];
                              mInputParams2.GetOrCreateParam(dtString, 'StoreGateway_ID').AsString := cStoreGateway_ID;
                              mInputParams2.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cDocQueue_VPZ_ID;
                              mInputParams2.GetOrCreateParam(dtString, 'StoreMan_ID').AsString := cStoreMan_ID;
                              mInputParams2.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition').AsBoolean := True;
                              mInputParams2.GetOrCreateParam(dtString, 'Strategy_ID').AsString := cNxFreePositionsStrategyID;
                              mInputParams2.GetOrCreateParam(dtBoolean, 'IsAccessibilityLimitFilter').AsBoolean := False;
                              mInputParams2.GetOrCreateParam(dtInteger, 'AccessibilityLimit').AsInteger := 0;

                              mImportMan2.LoadParams(mInputParams2);
                              mImportMan2.Execute;
                              if mImportMan2.OutputDocument.Validate then
                              begin
                                 mImportMan2.OutputDocument.Save;
                                 mLog.Add(' - Vytvořen polohovací doklad:'+mImportMan2.OutputDocument.DisplayName);

                                 {//provedení dokladu
                                 mAbraOLE := GetAbraOLEApplication;
                                 mObject := mAbraOLE.CreateObject(Class_LogStoreOutput);
                                 try
                                    mObject.MakeExecuted(mImportMan2.OutputDocument.OID);
                                 finally
                                    mObject := nil;
                                    mAbraOLE := nil;
                                 end;
                                 mLog.Add(' - Proveden polohovací doklad:'+mImportMan2.OutputDocument.DisplayName);
                                 }

                              end
                              else
                              begin
                                 mImportMan2.OutputDocument.GetValidateErrors(mValidateErrors);
                                 mLog.Add(' - Polohovací doklad nebylo možné uložit, chyby:'+mValidateErrors.Text);
                              end;
                           finally
                              mImportMan2.Free;
                           end;
                    end else begin
                      mLog.Add(' - Nevytvořen DL pro'+ mTypeList.Strings[i]);
                    end;
                   except


                   end;
                 end;
                except
                  mLog.Add(' - vyjímka tvorby DL: '+ ExceptionMessage);
                end;
            WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mTypeList.count));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;
         end;
       except
         mLog.Add(' - vyjímka celého skriptu: '+ ExceptionMessage);
       end;
       if mDLList.count>0 then begin
         TDynSiteForm(mSite).RefreshData;
         TDynSiteForm(mSite).ActiveDataSet.SeekID(mOrderBO.OID);
         mSite.ShowSite(Site_BillOfDeliveries,true,'QueryByUserDynSQLCondition;a.id in ('+mDLList.DelimitedText+')');
       end;

       NxShowSimpleMessage(mLog.text,mSite);
    end;
 end;
end;

Function DialogForDL(var ASite : TSiteform; var aIndex:Integer; var aOPName:string;):Boolean;
var
 mButOk, mButCancel : TButton;
 mResult, mCount : integer;
 mList:TStringList;
 mLabel: TLabel;
 mForm : TForm;
 mCombo: TComboBox;
begin
  if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro tvorbu DL z '+aOPName;
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mList:=TStringList.Create;
    mList.add('Zbytek');
    mList.add('Jen zcela pokryté skl. řádky');

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Způsob:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCombo:= TComboBox.Create(mForm);
    mCombo.Parent:=mForm;
    mCombo.Left := 127;
    mCombo.Top := (mCount*25)+10;
    mCombo.Width := 200;
    mCombo.Text := '';
    mCombo.Items:=mList;
    mCombo.ItemIndex:=1;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Default := True;
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
      Result:=True;
      aIndex:=mCombo.ItemIndex;
    end;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.