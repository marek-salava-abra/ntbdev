////////////////////////////////////////////////////////////////////////////////
procedure NastavZemiPuvodu(ABO : TNxCustomBusinessObject);
var
  mZmena : Boolean;
  mRow : TNxCustomBusinessObject;
  mRows : TNxCustomBusinessMonikerCollection;
  mID : String;
  I : Integer;
begin
  mZmena := False;
  mRows := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('Rows'));
  For I := 0 to mRows.Count - 1 do
  begin
    mRow := mRows.BusinessObject[I];
    if mRow.GetFieldValueAsInteger('RowType') <> 3 then
      Continue;
    if CFxOID.IsEmpty(mRow.GetFieldValueAsString('StoreCard_ID')) then
      Exit;
    mID := mRow.GetFieldValueAsString('StoreCard_ID.Country_ID');
    if not CFxOID.IsEmpty(mID) then
    begin
      if mRow.GetFieldValueAsString('OriginCountry_ID') <> mID then
      begin
        mRow.SetFieldValueAsString('OriginCountry_ID', mID);
        mZmena := True;
      end;
    end;
  end;
  if mZmena then
    ABO.Save;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure actNastZemiPuvodu(Sender: TObject; AIndex: integer);
var
  mSiteForm : TSiteForm;
  mBO : TNxCustomBusinessObject;
  mFormDynKom : TDynSiteForm;
  mListIDs : TstringList;
  I : Integer;
  mstLog : TMemoryStream;
begin
  if(not (Sender is TComponent))then
    Exit;
  mSiteForm := NxFindSiteForm(TComponent(Sender));
  if not Assigned(mSiteForm) then
    Exit;
  if Trunc(Now) > EncodeDate(2022, 3, 1) then
  begin
    ShowMessage('Funkce není od 1.3.2022 podporována !', mSiteForm.GetSiteAppForm);
    Exit;
  end;
  if (mSiteForm is TDynSiteForm) then
  begin
    mFormDynKom := TDynSiteForm(mSiteForm);
    if Assigned(mFormDynKom) then
    begin
      mstLog := TMemoryStream.Create;
      try
        mListIDs := TstringList.Create;
        try
          mBO := mSiteForm.BaseObjectSpace.CreateObject(Class_IssuedCreditNote);
          try
            mFormDynKom.FillListWithSelectedRows(mListIDs);
            case AIndex of
              0 : begin
                    For I := 0 to mListIDs.Count - 1 do
                    begin
                      try
                        mBO.Load(mListIDs.Strings[I], nil);
                        NastavZemiPuvodu(mBO);
                      except
                        NxWriteString(mstLog,'Chyba na FV: '+Trim(mBO.DisplayName)+' : '+Trim(ExceptionMessage)+nxCrLf+nxCrLf);
                      end;
                    end;
                  end;
            end;
          finally
            mBO.Free;
            mBO := nil;
          end;
        finally
          mListIDs.Free;
          mListIDs := nil;
        end;
        if (mstLog.Size > 0)then
        begin
          NxShowEditorSite(mSiteForm.SiteContext, 'Chybové hlášení'+nxCrLf+nxCrLf + NxReadString(mstLog), true);
        end else
          ShowMessage('Hotovo', mSiteForm.GetSiteAppForm);
        mFormDynKom.RefreshData;
      finally
        mstLog.Free;
        mstLog := nil;
      end;
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

{
Vyvolává se po načtení vlastností formuláře.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
var
  mMuAction: TMultiAction;
  maclFunc: TActionList;
  mVisible : Boolean;
  i: integer;
begin
  maclFunc := Self.GetMainActionList;
  for i:= 0 to maclFunc.ActionCount-1 do
  begin
    if (maclFunc.Actions[i].Name = 'actNastZemiPuvodu') then
    begin
      if Trunc(Now) > EncodeDate(2022, 3, 1) then
        TMultiAction(maclFunc.Actions[i]).Category := 'Nexus';
    end;
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mMuAction: TMultiAction;
begin
  mMuAction := Self.GetNewMultiAction;
  mMuAction.ShowControl  := True;
  mMuAction.ShowMenuItem := True;
  mMuAction.Name         := 'actNastZemiPuvodu';
  mMuAction.Caption      := 'Nastavit zemi původu';
  mMuAction.Hint         := 'Nastavit zemi původu';
  mMuAction.Category     := 'tabList';
  mMuAction.Items.Add('Nastavení země původu');
  mMuAction.OnExecuteItem:= @actNastZemiPuvodu;
end;

begin
end.