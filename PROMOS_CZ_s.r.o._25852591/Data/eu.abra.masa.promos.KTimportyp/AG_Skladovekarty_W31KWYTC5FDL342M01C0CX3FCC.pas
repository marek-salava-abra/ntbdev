
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction : TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'KT importy';
  mMAction.Hint := 'Importy dat z KT';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @KTImports;
  mMAction.Items.Add('Minimální množství na 01');
  mMAction.Items.Add('Balení');
  mMAction.Items.Add('Balení dodavatel');
end;

procedure KTimports(Sender:TComponent;Index:integer);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,n:integer;
 mList:TStringList;
 mBO, mUnitBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mOpenDlg:TOpenDialog;
 mTempStr, mCode, mQuantity, mStoreSubcard_ID, mStoreCard_ID, mUnit_ID, mSupplier_ID:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.Title := 'Import z Kingtony';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 if mOpenDlg.Execute then begin
        try
          mList:=TStringList.create;
          mList.LoadFromFile(mOpenDlg.FileName);
          n:=mList.Count;
          WaitWin.StartProgress('Čekejte, prosím ...', '',  n);
                 for i:=1 to mlist.count-1 do begin
                    mTempStr:=mList.Strings[i];
                    if NxSearch(mTempStr,Chr(9),[srall],0)>0 then begin
                     mCode:=NxTrapStrTrim(mTempStr,chr(9));
                     mQuantity:=NxTrapStrTrim(mTempStr,chr(9));

                    end else begin
                     mCode:=NxTrapStrTrim(mTempStr,';');
                     mQuantity:=NxTrapStrTrim(mTempStr,';');
                    end;
                    if Index=0 then begin
                      if not(NxIsBlank(mCode)) then begin
                        mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mCode),'');
                        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                          mStoreSubcard_ID:=mOS.SQLSelectFirstAsString('Select id from storesubcards where store_id=''1000000101'' and storecard_id='+QuotedStr(mStoreCard_ID),'');
                          if not(NxIsEmptyOID(mStoreSubcard_ID)) then begin
                             mBO:=mOS.CreateObject(Class_StoreSubCard);
                             mBO.Load(mStoreSubcard_ID,nil);
                             mBO.SetFieldValueAsFloat('LowLimitQuantity',NxIBStrToFloat(mQuantity));
                             mbo.save;
                             mbo.free;
                          end;
                        end;
                      end;
                    end;
                    if Index=1 then begin
                      if NxIBStrToFloat(mQuantity)>0 then begin
                        mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mCode),'');
                        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                             mBO:=mOS.CreateObject(Class_StoreCard);
                             mBO.Load(mStoreCard_ID,nil);
                             mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
                             mUnit_ID:='';
                             mUnit_ID:=mOS.SQLSelectFirstAsString('Select id from storeunits where parent_id='+QuotedStr(mStoreCard_ID)+' and code='+QuotedStr('bal'),'');
                             if NxIsEmptyOID(mUnit_ID) then begin
                              mUnitBO:=mUnits.AddNewObject;
                              mUnitBO.Prefill;
                              mUnitBO.SetFieldValueAsString('Code','bal');
                              mUnitBO.SetFieldValueAsFloat('UnitRate',NxIBStrToFloat(mQuantity));
                             end else begin
                              for j:=0 to mUnits.count-1 do begin
                                mUnitBO:=mUnits.BusinessObject[j];
                                if mUnitBO.OID=mUnit_ID then mUnitBO.SetFieldValueAsFloat('UnitRate',NxIBStrToFloat(mQuantity));
                              end;
                             end;
                             mbo.SetFieldValueAsFloat('X_package',NxIBStrToFloat(mQuantity));
                             mbo.save;
                             mbo.free;
                        end;
                      end;
                    end;
                    if Index=2 then begin
                      if NxIBStrToFloat(mQuantity)>0 then begin
                        mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mCode),'');
                        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                          mSupplier_ID:=mOS.SQLSelectFirstAsString('Select id from suppliers where firm_id='+QuotedStr('TT10000101')+' and storecard_id='+QuotedStr(mStoreCard_ID),'');
                          if not(NxIsEmptyOID(mSupplier_ID)) then begin
                             mBO:=mOS.CreateObject(Class_Supplier);
                             mBO.load(mSupplier_ID,nil);
                             mBO.SetFieldValueAsFloat('Packing',NxIBStrToFloat(mQuantity));
                             mBO.SetFieldValueAsFloat('MinimalQuantity',1);
                             mbo.save;
                             mbo.free;
                          end;
                        end;
                      end;
                    end;
                    WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(n));
                    WaitWin.StepIt;
                   end;
          WaitWin.Stop;
        Except
         WaitWin.Stop;
         NxShowSimpleMessage('Něco se nepovedlo:'+nxCrLf+ExceptionMessage,mSite);
        end;

    NxShowSimpleMessage('Nahráno '+IntToStr(n)+' záznamů.',mSite);
  end;
end;

begin
end.