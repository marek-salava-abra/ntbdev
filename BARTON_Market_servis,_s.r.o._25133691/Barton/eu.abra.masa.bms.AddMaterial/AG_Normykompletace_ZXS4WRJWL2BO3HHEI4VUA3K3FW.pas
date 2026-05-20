uses '.dlg';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin


  mAct := Self.GetNewAction;
  mAct.Caption := '##Přidání materiálu##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @AddMaterial;
end;

Procedure AddMaterial(Sender:TComponent);
var
 mSite:TSiteForm;
 mSelectedList:TStringList;
 mOS:TNxCustomObjectSpace;
 mPLMPieceListBO, mPLMPieceListRowBO:TNxCustomBusinessObject;
 i,j,k, mUsePhases, mCheckReleased, mIssue, mResult:integer;
 mAllNotReleased:boolean;
 mStorecard_ID, mStore_ID, mPhase_ID, mQUnit:string;
 mQuantity:Extended;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete doplnit materiál do  '+IntToStr(mSelectedList.count)+' norem?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
      mAllNotReleased:=True;
      {//kontrola hodnoty ve firemních parametrech pro schvalování kusovníku
      mCheckReleased:=FxCompanyParameters_Get(mOS,'GVNBPN5YBD3ORJWIHBGG5MT1FS');
      mUsePhases:=FxCompanyParameters_Get(mOS,'YLXIYJEVCJOOD1BKAFGWOMQ0YK');
      if mCheckReleased=0 then begin
          k:=mSelectedList.Count;
          WaitWin.StartProgress('Čekejte, kontroluji ...', '', k);
          for i:=0 to mSelectedList.Count-1 do begin
            mPLMPieceListBO:=mOS.CreateObject(Class_PLMPieceList);
            mPLMPieceListBO.Load(mSelectedList.Strings[i],nil);
            if mAllNotReleased then begin
              if not(NxIsEmptyOID(mPLMPieceListBO.GetFieldValueAsString('ReleasedBy_ID'))) then mAllNotReleased:=False
            end;
            mPLMPieceListBO.free;
            WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;
          if not(mAllNotReleased) then begin
            NxShowSimpleMessage('Alespoň jeden z označených kusovníků je schválen, nelze hromadně vložit materiál.',mSite);
            exit;
          end;
      end;
      //konec kontroly kusovníku na schválení
      }
      if mAllNotReleased then begin
        mStorecard_ID:='';
        mStore_ID:='';
        mPhase_ID:='';
        mQuantity:=0;
        mResult:=0;
        if GetDataForPLMPiecelist(mSite, mStorecard_ID, mStore_ID, mPhase_ID, mQuantity, mQUnit, mIssue, mResult, mUsePhases) then begin
           if mResult=1 then begin

              if NxIsEmptyOID(mStorecard_ID) then begin
                NxShowSimpleMessage('Skladová karta musí být vyplněná. Ukončuji.', mSite);
                Exit;
              end;

              k:=mSelectedList.Count;
              WaitWin.StartProgress('Čekejte, vkládám ...', '', k);
              for i:=0 to mSelectedList.Count-1 do begin
                mPLMPieceListBO:=mOS.CreateObject(Class_SPMNorm);
                mPLMPieceListBO.Load(mSelectedList.Strings[i],nil);
                mRows:=mPLMPieceListBO.GetLoadedCollectionMonikerForFieldCode(mPLMPieceListBO.GetFieldCode('Rows'));
                mPLMPieceListRowBO:=mRows.AddNewObject;
                mPLMPieceListRowBO.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
                mPLMPieceListRowBO.SetFieldValueAsString('Qunit',mQUnit);
                mPLMPieceListRowBO.SetFieldValueAsFloat('UnitQuantity',mQuantity);
                mPLMPieceListRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
                mPLMPieceListBO.save;
                mPLMPieceListBO.free;
                WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
                WaitWin.StepIt;
              end;
              WaitWin.stop;
              TDynSiteForm(mSite).RefreshData;
              TDynSiteForm(mSite).ActiveDataSet.SeekID(mSelectedList.Strings[i]);
              NxShowSimpleMessage('Provedeno',mSite);
           end;
        end;
      end;
   end;
 end;
end;

begin
end.