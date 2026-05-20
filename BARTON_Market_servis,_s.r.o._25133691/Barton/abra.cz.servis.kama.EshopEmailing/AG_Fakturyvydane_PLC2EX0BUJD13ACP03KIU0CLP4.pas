uses 'abra.cz.servis.kama.EshopEmailing.common';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
  mActionTrn: TAction;
begin
  if CheckDefinitionExists(Self.BaseObjectSpace, 8) then begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Odeslat emailem';
    mAction.Hint := 'Odeslání dokladu emailem';
    mAction.Items.Add('Hromadné odeslání');
    mAction.Items.Add('Odeslat s editací');
    mAction.Category := 'tabList';
    mAction.OnExecuteItem := @ExecItem;
    mAction.Name := 'actSendEmail';
 end;

  mActionTrn := Self.GetNewAction;
  mActionTrn.ShowControl := True;
  mActionTrn.ShowMenuItem := True;
  mActionTrn.Caption := 'Doplnit track. číslo';
  mActionTrn.Hint := 'Doplnění trackovacího čísla';
  mActionTrn.Category := 'tabList';
  mActionTrn.OnExecute := @ExecTrack;
  mActionTrn.Name := 'actTrackNumber';
end;


procedure ExecTrack(Sender: TObject);
var
  mSite: TSiteForm;
  mID, mTrn, mSQL: string;
  mSelected: TStrings;
  i: integer;
  mBO: TNxCustomBusinessObject;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).Site;
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        mSelected := TStringList.Create;
        mBO := mSite.BaseObjectSpace.CreateObject(Class_IssuedInvoice);
        try
          TNxSiteList(mSite.List).GetSelectedId(mSelected);
          for i := 0 to mSelected.Count -1 do begin
            mID := mSelected.Strings[i];
            mBO.Load(mID, nil);
            mTrn := InputBox(mBO.DisplayName, 'Trackovací číslo:', '', mSite.FindParentForm);
            if mTrn <> '' then begin
              mSQL := Format('Update IssuedInvoices set X_TRACKING_NUMBER=%s where ID=%s',[QuotedStr(mTrn), QuotedStr(mID)]);
              mSite.BaseObjectSpace.SQLExecute(mSQL);
            end;
          end;
          TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem;
        finally
          mSelected.Free;
          mBO.Free;
        end;
      end;
    end;
  end;
end;


procedure ExecItem(Sender: TObject; Index: integer);
var
  mSite: TSiteForm;
  mIDs: TStrings;
  i: Integer;
  mCount: Integer;
  mBO: TNxCustomBusinessObject;
  mSave: Boolean;
begin
  mCount := 0;
  if Sender is TComponent then begin
    mSite := TComponent(Sender).Site;
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        if (Index=1) or ((Index = 0) and (NxMessageBox('Dotaz', 'Provést odeslání dokladů e-mailem?', mdConfirm, mdbYesNo, 2, 0, False, nil) = mrYes)) then begin
          if CheckDefinitionExists(mSite.BaseObjectSpace, 8) then begin
            mIDs := TStringList.Create;
            mBO := mSite.BaseObjectSpace.CreateObject(Class_IssuedInvoice);
            try
              TNxSiteList(mSite.List).GetSelectedId(mIDs);
              for i := 0 to mIDs.Count - 1 do begin
                mBO.Load(mIDs.Strings[i], nil);
                if Index = 0 then
                  mSave := EshopAction(mBO, 8);
                if Index = 1 then
                  mSave := EshopAction(mBO, 8, '', TDynSiteForm(mSite));
                if mSave then begin
                  mBO.SetFieldValueAsBoolean('X_EmailSent', True);
                  mBO.Save;
                  inc(mCount);
                end;
              end;
            finally
              mIDs.free;
              mBO.free;
              NxShowMessage('Odeslání emailu', 'Počet zpracovaných dokladů: ' + IntToStr(mCount), mdInformation, false, mSite.FindParentForm);
              TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem;
            end;
          end else NxShowMessage('Varování', 'Neexistuje žádná definice pro odeslání emailu', mdWarning, false, mSite.FindParentForm);
        end;
      end;
    end;
  end;
end;


begin
end.
