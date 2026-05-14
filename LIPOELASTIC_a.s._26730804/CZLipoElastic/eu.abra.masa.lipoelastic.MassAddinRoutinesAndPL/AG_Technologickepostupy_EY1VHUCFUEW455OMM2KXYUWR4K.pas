uses '.dlg';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin


  mAct := Self.GetNewAction;
  mAct.Caption := '##Přidání operace##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @AddOperation;
end;

Procedure AddOperation(Sender:TComponent);
var
 mSite:TSiteForm;
 mSelectedList:TStringList;
 i,j, k, mPosIndex, mResult, mTACUnit, mTBCUnit:integer;
 mPLMRoutineBO, mPLMRoutineRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mAllNotReleased, mKoo, mFinish:Boolean;
 mOperation_ID, mPhase_ID, mSalaryClass_ID, mWorkplace_ID, mName:string;
 mTAC, mTBC:Extended;
 mCheckReleased, mUsePhases:integer;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete doplnit operaci do  '+IntToStr(mSelectedList.count)+' technologických postupů?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
      //kontrola na schválení TP
      mCheckReleased:=FxCompanyParameters_Get(mOS,'AJP3X3L3BIU4B45PR1OJI3UN5C');  //kontrola hodnoty ve firemních parametrech pro schvalování TP
      mUsePhases:=FxCompanyParameters_Get(mOS,'W2TJPVGH535OT2E1ILPXTIN2TO');
      mAllNotReleased:=True;
      mKoo:=false;
      mFinish:=false;
      if mCheckReleased=0 then begin
          k:=mSelectedList.Count;
          WaitWin.StartProgress('Čekejte, kontroluji ...', '', k);
          for i:=0 to mSelectedList.Count-1 do begin
            mPLMRoutineBO:=mOS.CreateObject(Class_PLMRoutine);
            mPLMRoutineBO.Load(mSelectedList.Strings[i],nil);
            NxShowSimpleMessage(mPLMRoutineBO.GetFieldValueAsString('ReleasedBy_ID'),mSite);
            if mAllNotReleased then begin
              if not(NxIsEmptyOID(mPLMRoutineBO.GetFieldValueAsString('ReleasedBy_ID'))) then mAllNotReleased:=False
            end;
            mPLMRoutineBO.free;
            WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;
          if not(mAllNotReleased) then begin
            NxShowSimpleMessage('Alespoň jeden z označených technologických postupů je schválen, nelze hromadně vložit operaci.',mSite);
            exit;
          end;
      end;
      //konec kontroly TP na schválení
      if mAllNotReleased then begin
        mPosIndex:=0;
        mTAC:=0;
        mTBC:=0;
        if GetDataForPLMRoutine(mSite, mPosindex, mResult, mPhase_ID, mSalaryClass_ID, mWorkplace_ID, mName, mTAC, mTBC, mTACUnit, mTBCUnit, mUsePhases, mKoo, mFinish) then begin
           if mResult=1 then begin
              if NxIsEmptyOID(mWorkplace_ID) then begin
                NxShowSimpleMessage('Pracoviště musí být vyplněné. Ukončuji.', mSite);
                Exit;
              end;
              if NxIsEmptyOID(mSalaryClass_ID) then begin
                NxShowSimpleMessage('Tarifní třída musí být vyplněná. Ukončuji.', mSite);
                Exit;
              end;
              if NxIsEmptyOID(mPhase_ID) and (mUsePhases=0) then begin
                NxShowSimpleMessage('Etapa musí být vyplněná. Ukončuji.', mSite);
                Exit;
              end;
              k:=mSelectedList.Count;
              WaitWin.StartProgress('Čekejte, doplňuji ...', '', k);
              for i:=0 to mSelectedList.Count-1 do begin
                mPLMRoutineBO:=mOS.CreateObject(Class_PLMRoutine);
                mPLMRoutineBO.Load(mSelectedList.Strings[i],nil);
                mRows:=mPLMRoutineBO.GetLoadedCollectionMonikerForFieldCode(mPLMRoutineBO.GetFieldCode('Rows'));
                for j:=0 to mRows.count-1 do begin
                   mPLMRoutineRowBO:=mRows.BusinessObject[j];
                   if mPLMRoutineRowBO.GetFieldValueAsInteger('PosIndex')>=mPosIndex then mPLMRoutineRowBO.SetFieldValueAsInteger('PosIndex',mPLMRoutineRowBO.GetFieldValueAsInteger('PosIndex')+1);
                   if mFinish then mPLMRoutineRowBO.SetFieldValueAsBoolean('Finished',false);
                end;
                mPLMRoutineRowBO:=mRows.AddNewObject;
                mPLMRoutineRowBO.prefill;
                mPLMRoutineRowBO.SetFieldValueAsInteger('PosIndex',mPosIndex);
                mPLMRoutineRowBO.SetFieldValueAsString('X_TPOperation_ID',mOperation_ID);
                mPLMRoutineRowBO.SetFieldValueAsString('Title',mName);
                mPLMRoutineRowBO.SetFieldValueAsInteger('TACUnit',mTACUnit);
                mPLMRoutineRowBO.SetFieldValueAsFloat('UnitTAC',mTAC);
                mPLMRoutineRowBO.SetFieldValueAsInteger('TBCUnit',mTBCUnit);
                mPLMRoutineRowBO.SetFieldValueAsFloat('UnitTBC',mTBC);
                if mKoo then mPLMRoutineRowBO.SetFieldValueAsBoolean('Cooperation',false);
                if mFinish then mPLMRoutineRowBO.SetFieldValueAsBoolean('Finished',True);
                mPLMRoutineRowBO.SetFieldValueAsBoolean('Batch',True);
                mPLMRoutineRowBO.SetFieldValueAsString('Phase_ID',mPhase_ID);
                mPLMRoutineRowBO.SetFieldValueAsString('SalaryClass_ID',mSalaryClass_ID);
                mPLMRoutineRowBO.SetFieldValueAsString('WorkPlace_ID',mWorkplace_ID);
                mPLMRoutineBO.save;
                mPLMRoutineBO.free;
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