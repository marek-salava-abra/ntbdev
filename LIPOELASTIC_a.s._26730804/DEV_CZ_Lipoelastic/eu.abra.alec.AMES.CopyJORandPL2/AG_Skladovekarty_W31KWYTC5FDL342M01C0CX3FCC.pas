{procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'CopyPL';
  mAction.Caption := 'Nakopírovat kus. a TPV';
  mAction.Hint := 'Nakopíruje kusovník a TPV z jiné karty k této';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CopyPL;
end;


Procedure CopyPL(sender:TComponent);
var
  mBO, mPLBO, mPLBONew, mROBO, mROBONew: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mOpenRolSite: TOpenRolSite;
  mSelectedList, mAllowedSCList: TStringList;
  mPL_ID, mRoutine_ID, mSelectedCard, mChoice, mSelectedSCName: string;
  mParams: TNxParameters;
  i: integer;
begin
  mSite:= TComponent(Sender).BusRollSite;
  mOS:= mSite.BaseObjectSpace;
  mBO:= TBusRollSiteForm(mSite).CurrentObject;
  try
    mSelectedList:= TStringList.Create;
    mAllowedSCList:= TStringList.Create;
    mSelectedCard:= '';
    mSelectedCard:= mOS.SQLSelectFirstAsString('SELECT PL.ID FROM PLMPieceLists PL WHERE PL.StoreCard_ID = '+QuotedStr(mBO.OID));
    if not(NxIsEmptyOID(mSelectedCard)) then begin
      NxShowSimpleMessage('Vybraná karta již na sobě má kusovník, vyberte jinou kartu.', mSite);
      exit;
    end;
    mSelectedCard:= '';
    mSelectedCard:= mOS.SQLSelectFirstAsString('SELECT RO.ID FROM PLMRoutines RO WHERE RO.StoreCard_ID = '+QuotedStr(mBO.OID));
    if not(NxIsEmptyOID(mSelectedCard)) then begin
      NxShowSimpleMessage('Vybraná karta již na sobě má technologický postup, vyberte jinou kartu.', mSite);
      exit;
    end;
    mOS.SQLSelect('SELECT PL.StoreCard_ID FROM PLMPieceLists PL JOIN PLMRoutines RO ON RO.StoreCard_ID = PL.StoreCard_ID WHERE PL.StoreCard_ID IS NOT NULL', mAllowedSCList);
    mParams := TNxParameters.Create;
    mParams.NewFromDataType(dtString, '_Allowed').AsString := mAllowedSCList.Text; // Omezeno na vybrané ID záznamů
    mOpenRolSite := TOpenRolSite.Create(mSite.SiteContext, Roll_StoreCards);
    mOpenRolSite.ParentForm := mSite.GetSiteAppForm;
    mOpenRolSite.MultiChoice := True;
    mOpenRolSite.Detailed := False;
    mOpenRolSite.AdditionalParams := mParams;
    mOpenRolSite.Open;
    mSelectedList := mOpenRolSite.SelectedList;
    mOpenRolSite.Free;
    NxShowSimpleMessage(mSelectedList.text, mSite);
    mSelectedSCName:= mOS.SQLSelectFirstAsString('SELECT Code || '' - '' || Name FROM StoreCards WHERE ID = '+QuotedStr(mSelectedList[0]));
    if NxMessageBox('Dotaz', 'Přejete si nakopírovat kusovník a technologický postup ze skladové karty :'+#10#13+mSelectedSCName+#10#13+
      'do skladové karty: '#10#13+mbo.GetFieldValueAsString('Code')+' - '+mbo.GetFieldValueAsString('Name'), mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
    //for i:= 0 to mSelectedList.Count-1 do begin
      mPL_ID:= mOS.SQLSelectFirstAsString('SELECT PL.ID FROM PLMPieceLists PL WHERE PL.StoreCard_ID = '+QuotedStr(mSelectedList[0]));
      mRoutine_ID:= mOS.SQLSelectFirstAsString('SELECT RO.ID FROM PLMRoutines RO WHERE RO.StoreCard_ID = '+QuotedStr(mSelectedList[0]));
      try
        mPLBO:= mOS.CreateObject(Class_PLMPieceList);
        mPLBO.Load(mPL_ID, nil);
        mPLBONew:= mPLBO.Clone;
        mPLBO.Free;
        mPLBONew.SetFieldValueAsString('StoreCard_ID', mBO.OID);
        mPLBONew.SetFieldValueAsString('Name', mBO.GetFieldValueAsString('Name'));
        mPLBONew.Save;
        mPLBONew.Free;
      except
        NxShowSimpleMessage('Kusovník se nepodařilo vytvořit. Chyba: '+ExceptionMessage, mSite);
        mPLBO.Free;
        mPLBONew.Free;
        exit;
      end;
      try
        mROBO:= mOS.CreateObject(Class_PLMRoutine);
        mROBO.Load(mRoutine_ID, nil);
        mROBONew:= mROBO.Clone;
        mROBO.Free;
        mROBONew.SetFieldValueAsString('StoreCard_ID', mBO.OID);
        mROBONew.SetFieldValueAsString('Name', mBO.GetFieldValueAsString('Name'));
        mROBONew.Save;
        mROBONew.Free;
      except
        NxShowSimpleMessage('Technologický postup se nepodařilo vytvořit. Chyba: '+ExceptionMessage, mSite);
        mROBO.Free;
        mROBONew.Free;
        exit;
      end;
      NxShowSimpleMessage(mSelectedList.Text, mSite);
      NxShowSimpleMessage('Kusovník a technologický postup nakopírován.', mSite);
    end;
  except
    NxShowSimpleMessage(ExceptionMessage, mSite);
    mBO.Free;
    mPLBO.Free;
    mPLBONew.Free;
    mSelectedList.Free;
    mAllowedSCList.Free;
    exit;
  end;
  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
end;
}
begin
end.