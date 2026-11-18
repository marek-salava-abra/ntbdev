uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'CopyTPV';
  mAction.Caption := 'Naklonovat TPV';
  mAction.Hint := 'Naklonuje TPV z této karty do vybraných karet';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CopyTPV;
end;


Procedure CopyTPV(sender:TComponent);
var
  mBO, mPLBO, mPLBONew, mROBO, mROBONew: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mOpenRolSite: TOpenRolSite;
  mSelectedList, mAllowedSCList: TStringList;
  mPL_ID, mRoutine_ID, mSelectedCard, mSelectedRoutine, mSelectedSCName, mBOID: string;
  mParams: TNxParameters;
  i: integer;
begin
  mSite:= TComponent(Sender).DynSite;         //TComponent(Sender).BusRollSite;
  mOS:= mSite.BaseObjectSpace;
  mBO:= TDynSiteForm(mSite).CurrentObject;    //TBusRollSiteForm(mSite).CurrentObject;
  mBOID:= mBO.OID;
  try
    mSelectedList:= TStringList.Create;
    mAllowedSCList:= TStringList.Create;
    mSelectedCard:= '';
    mSelectedRoutine:= mOS.SQLSelectFirstAsString('SELECT ID FROM PLMRoutines WHERE StoreCard_ID= '+QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID')));
    if NxIsEmptyOID(mSelectedRoutine) then begin
      NxShowSimpleMessage('Vybraný výrobek nemá založený technologický postup. Nelze kopírovat!', mSite);
      exit;
    end;
    mOS.SQLSelect(
      ' SELECT SC.ID FROM StoreCards SC '+
      ' WHERE SC.IsProduct = ''A'' AND Hidden = ''N'' '+cSQL_X_Aktivni+' AND SC.ID NOT IN (SELECT PL.StoreCard_ID FROM PLMPieceLists PL JOIN PLMRoutines RO ON PL.StoreCard_ID = RO.StoreCard_ID)', mAllowedSCList);
    mParams := TNxParameters.Create;
    mParams.NewFromDataType(dtString, '_Allowed').AsString := mAllowedSCList.Text; // Omezeno na vybrané ID záznamů
    mOpenRolSite := TOpenRolSite.Create(mSite.SiteContext, Roll_StoreCards);
    mOpenRolSite.ParentForm := mSite.GetSiteAppForm;
    mOpenRolSite.MultiChoice := True;
    mOpenRolSite.Detailed := False;
    mOpenRolSite.AdditionalParams := mParams;
    mOpenRolSite.Open;
    //mSelectedList := mOpenRolSite.SelectedList;

    if NxMessageBox('Dotaz', 'Přejete si nakopírovat vybraný technologický postup do vybraných skladových karet ('+IntToStr(mOpenRolSite.SelectedList.Count)+')?'+#10#13+     //mSelectedList.Count
      '', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
      for i:= 0 to mOpenRolSite.SelectedList.Count -1 do begin
        mRoutine_ID:= mOS.SQLSelectFirstAsString('SELECT RO.ID FROM PLMRoutines RO WHERE RO.StoreCard_ID = '+QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID')));
        mSelectedSCName:= mOS.SQLSelectFirstAsString('SELECT Name FROM StoreCards WHERE ID = '+QuotedStr(mOpenRolSite.SelectedList.Strings[i]));
        {
        try
          mPLBO:= mOS.CreateObject(Class_PLMPieceList);
          mPLBO.Load(mBO.OID, nil);
          mPLBONew:= mPLBO.Clone;
          mPLBO.Free;
          mPLBONew.SetFieldValueAsString('StoreCard_ID', mOpenRolSite.SelectedList.Strings[i]);
          mPLBONew.SetFieldValueAsString('Name', mSelectedSCName);
          mPLBONew.Save;
          mPLBONew.Free;
        except
          NxShowSimpleMessage('Kusovník se nepodařilo vytvořit. Chyba: '+ExceptionMessage, mSite);
          mPLBO.Free;
          mPLBONew.Free;
          exit;
        end;
        }
        mROBO:= mOS.CreateObject(Class_PLMRoutine);
        try
          try
            mROBO.Load(mRoutine_ID, nil);
            mROBONew:= mROBO.Clone;
            //mROBO.Free;
            mROBONew.SetFieldValueAsString('StoreCard_ID', mOpenRolSite.SelectedList.Strings[i]);
            mROBONew.SetFieldValueAsString('Name', mSelectedSCName);
            mROBONew.Save;
          except
            NxShowSimpleMessage('Technologický postup se nepodařilo vytvořit. Chyba: '+ExceptionMessage, mSite);
            exit;
          end;
        finally
          mROBO.Free;
          mROBONew.Free;
        end;
      end;
      NxShowSimpleMessage('Technologické postupy byly nakopírovány.', mSite);
    end;
    mOpenRolSite.Free;
  except
    NxShowSimpleMessage(ExceptionMessage, mSite);
    mBO.Free;
    mSelectedList.Free;
    mAllowedSCList.Free;
    exit;
  end;
  mBO.Free;
  mSelectedList.Free;
  mAllowedSCList.Free;
  TDynSiteForm(mSite).RefreshData;
  TDynSiteForm(mSite).ActiveDataSet.SeekID(mBOID);
  //TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;   //   DataSet.RefreshCurrentItem;
end;

begin
end.