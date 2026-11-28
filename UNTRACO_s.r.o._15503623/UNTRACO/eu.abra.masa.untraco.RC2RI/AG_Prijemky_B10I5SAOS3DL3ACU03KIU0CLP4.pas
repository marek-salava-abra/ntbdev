procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCreateRI';
  mAction.Caption := 'Vytvořit FPZ';
  mAction.Hint := 'Vytvoří faktury přijaté z označených příjemek';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateRI;
end;

procedure CreateRI(Sender:TComponent);
var
 mSite:TSiteForm;
 mRCList, mRIList:TStringList;
 i,j,k:integer;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mOS:TNxCustomObjectSpace;
 mRCBO, mRow:TNxCustomBusinessObject;
 mOVNum, mVarSymbol, mTempStr:string;
 mColl:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(sender).DynSite;
  mRCList:=TStringList.Create;
  mRIList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mRCList);
  mOS:=TDynSiteForm(mSite).BaseObjectSpace;
  if mRCList.count>0 then begin
     if NxMessageBox('Dotaz', 'Přejete si vygenerovat faktury přijaté?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin
         k:=mRCList.count;
         WaitWin.StartProgress('Čekejte, prosím ...', '', k);
         for i:=0 to mRCList.count-1 do begin
           try
             mRCBO:=mOS.CreateObject(Class_ReceiptCard);
             mRCBO.Load(mRCList.Strings[i],nil);
             mTempStr:= mRCBO.GetFieldValueAsString('Description');
             mOVNum:=NxTrapStrTrim(mTempStr,' ');
             mVarSymbol:=NxSearchReplace(mTempStr,' ','',[srall]);
             mInputParams := TNxParameters.Create;
             mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
             mParam.AsString := '4200000101';
             mParam := mInputParams.GetOrCreateParam(dtInteger, 'RowGroupingKind');
             mParam.AsInteger := 1;
             mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AddToSourceGroups');
             mParam.AsBoolean:=True;
             mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AlwaysReplace');
             mParam.AsBoolean:=True;
             mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_ReceivedInvoice);
             mImportMan.AddInputDocument(mRCBO.OID);
             mImportMan.SelectedHeader:=mRCBO;
             mImportMan.LoadParams(mInputParams);
             mImportMan.Execute;
             mImportMan.CheckOutputDocument;
             mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '4200000101');
             mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mRCBO.GetFieldValueAsDateTime('DocDate$Date'));
             mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mRCBO.GetFieldValueAsString('Firm_ID'));
             mImportMan.OutputDocument.SetFieldValueAsString('Description',mRCBO.GetFieldValueAsString('Description'));
             if NxIsNumeric(mVarSymbol) then
              mImportMan.OutputDocument.SetFieldValueAsString('VarSymbol',mVarSymbol);
             mImportMan.OutputDocument.SetFieldValueAsString('ExternalNumber',mVarSymbol);
             mImportMan.OutputDocument.SetFieldValueAsString('VATReportReference',mVarSymbol);
             mImportMan.OutputDocument.save;
             mRIList.Add(QuotedStr(mImportMan.OutputDocument.OID));
             WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
             WaitWin.StepIt;
             except
               WaitWin.Stop;
               NxShowSimpleMessage(ExceptionMessage,mSite);
               exit;
             end;
         end;
         WaitWin.Stop;
         if mRIList.count>0 then begin
          mSite.ShowSite(Site_ReceivedInvoices,true,'QueryByUserDynSQLCondition;A.ID in ('+mRIList.DelimitedText+');Vygenerované faktury');
         end;
     end;
  end;
end;

begin
end.