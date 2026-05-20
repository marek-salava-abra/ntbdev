uses 'abra.cz.servis.kama.EshopEmailing.common';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if CheckDefinitionExists(Self.BaseObjectSpace, 15) then begin
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
          if CheckDefinitionExists(mSite.BaseObjectSpace, 15) then begin
            mIDs := TStringList.Create;
            mBO := mSite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
            try
              TNxSiteList(mSite.List).GetSelectedId(mIDs);
              for i := 0 to mIDs.Count - 1 do begin
                mBO.Load(mIDs.Strings[i], nil);
                if Index = 0 then
                  mSave := EshopAction(mBO, 15);
                if Index = 1 then
                  mSave := EshopAction(mBO, 15, '', TDynSiteForm(mSite));
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
