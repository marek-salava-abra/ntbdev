uses
  'abra.lubi.ImportAlbertina.Books', 'abra.lubi.ImportAlbertina.ImportAlbertina';

procedure ButtonOnExecute(Sender: TObject; Index: integer);
var
  mSite: TSiteForm;
  mRowList: TStringList;
  mOS: TNxCustomObjectSpace;
  mSQL: string;
  mOID, mRes: string;
  i: integer;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mRowList := TStringList.Create;
    try
      if Index = 0 then begin
        TBusRollSiteForm(mSite).FillListWithSelectedRows(mRowList);
        ImportAlbertina(mSite.BaseObjectSpace, mSite, mRowList);
      end;
      if Index = 1 then begin
        mOS := mSite.BaseObjectSpace;
        TBusRollSiteForm(mSite).FillListWithSelectedRows(mRowList);
        for i := 0 to mRowList.Count - 1 do begin
          mOID := mRowList.Strings[i];
          if not NxIsEmptyOID(mOID) then begin
            mSQL := 'select X_ImportAlbertina from Firms where ID = ''%s''';
            mSQL := Format(mSQL, [mOID]);
            mRes := GetFirstRecordFromSQL(mOS, mSQL);
            if mRes = 'N' then begin
              mSQL := 'update Firms set X_ImportAlbertina = ''A'' where ID = ''%s''';
              mSQL := Format(mSQL, [mOID]);
              mOS.SQLExecute(mSQL);
            end;
            if mRes = 'A' then begin
              mSQL := 'update Firms set X_ImportAlbertina = ''N'' where ID = ''%s''';
              mSQL := Format(mSQL, [mOID]);
              mOS.SQLExecute(mSQL);
            end;
          end;
        end;
      end;
    finally
      mRowList.Free;
    end;
  end;
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TNxMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportAlbertina';
  mAction.Caption := 'Import albertina';
  mAction.Items.Text := 'Import albertina'#13#10'Nastavení položky Import Albertina';
  mAction.Hint := 'Funkce Importu Albertina';
  mAction.Category := 'tabList;tabDetail';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecuteItem := @ButtonOnExecute;
  mAction.Enabled := True;
  //mAction.ShortCut := TextToShortCut('Ctrl+Z');
  //mAction.ShortCutCtrlNumber := True;
end;

procedure btnOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  {if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TBusRollSiteForm then begin
        // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
        // a v pripade, ze neni zahajena editace
        TNxAction(Sender).Enabled := Not TBusRollSiteForm(mSite).DataSet.EOF
          and Not TBusRollSiteForm(mSite).Edit;
      end;
    end;
  end;
  }
end;

begin
end.