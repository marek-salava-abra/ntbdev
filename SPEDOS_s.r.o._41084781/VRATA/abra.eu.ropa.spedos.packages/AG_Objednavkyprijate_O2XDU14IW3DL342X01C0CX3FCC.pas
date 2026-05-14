 {

procedure GenSNOnExecute(Sender: TButton);
var
  mSite: TSiteForm;
  mDlg : TForm;
  mMessage : string;
  mObj : TNxCustomBusinessObject;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) and (mSite is TDynSiteForm ) then begin
      mObj := TDynSiteForm(mSite).CurrentObject;;
      GenSN(mObj);
    end;
  end;
end;

procedure GenSN(BO : TNxCustomBusinessObject);
var
  mRows : TNxCustomBusinessMonikerCollection;
  mRow, mBatch : TNxCustomBusinessObject;
  mStoreCardMon : TNxBusinessMoniker;
  i : integer;
  mSN, mList : TStringList;
const
  cBatchSelect = 'SELECT ID FROM StoreBatches WHERE StoreCard_ID=''%s'' and Name like ''%s'' ';
begin
  if not Assigned(BO) then
    exit;

  mRows := BO.GetCollectionMonikerForFieldCode(BO.GetFieldCode('ROWS'));
  if not Assigned(mRows) then
    RaiseException('Objednávka nemá řádky!');
  for i := 0 to mRows.Count - 1 do begin
    mRow := mRows.BusinessObject[i];
    if (mRow.GetFieldValueAsInteger('RowType') = 3) and (not NxIsBlank(mRow.GetFieldValueAsString('U_UserSerialNumber'))) then begin
      mStoreCardMon := mRow.GetMonikerForFieldCode(mRow.GetFieldCode('StoreCard_ID'));
      if mStoreCardMon.BusinessObject.GetFieldValueAsInteger('Category') = 1 then begin // řádek obsahuje kartu se seriovym cislem
        mSN := TStringList.Create;
        try
          NxTokenToStrings(mRow.GetFieldValueAsString('U_UserSerialNumber'), ';', mSN);
          if mSN.Count = mRow.GetFieldValueAsFloat('Quantity') then begin
            mBatch := BO.ObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
            try
              for i := 0 to mSN.Count -1 do begin
                mList := TStringList.Create;
                try
                  BO.ObjectSpace.SQLSelect(Format(cBatchSelect, [mRow.GetFieldValueAsString('StoreCard_ID'), mSN.Strings[i]]), mList);
                  if mList.Count = 0 then begin
                    mBatch.NewWithoutIdentity;
                    mBatch.SetFieldValueAsBoolean('SerialNumber', True);
                    mBatch.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                    mBatch.SetFieldValueAsString('Name', mSN.Strings[i]);
                    mBatch.Save;
                  end;
                finally
                  mList.Free;
                end;
              end;
            finally
              mBatch.Free;
            end;
          end else begin
            ShowMessage(Format('Řádek "%s" neobsahuje správný počet sériových čísel.',[mRow.DisplayName]));
            exit;
          end;
        finally
          mSN.Free;
        end;
      end;
    end;
  end;
  ShowMessage('Generování sériových čísel bylo dokončeno.');
end;


procedure GenSNOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := Not TDynSiteForm(mSite).ActiveDataset.EOF
          and Not TDynSiteForm(mSite).Edit;
      end;
    end;
  end;
end;




Vyvolává se po vytvoření instance formuláře.

procedure _AfterBeforePrint_Hook(Self: TSiteForm; APrintID: string; AParams: TNxParameters);
begin

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Generuj SČ';
  mAction.Hint := 'Vygeneruje sériové čísla pro danou objednávku.';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @GenSNOnExecute;
  mAction.OnUpdate := @GenSNOnUpdate;
end;
  }


begin
end.