procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSUKL';
  mAction.Caption := 'SUKL';
  mAction.Hint := 'Vyhledá kartu podle SUKL';
  mAction.ShortCut := TextToShortCut('Ctrl+Q');
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @MatchCode;
end;

Procedure MatchCode(sender:TComponent);
var
 mSite:TSiteForm;
 mSearchString:string;
 mStoreCard_ID:string;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRowBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 if not(TDynSiteForm(mSite).Edit) then begin
    NxShowSimpleMessage('Nejste ve stavu editace, nejde použít.',mSite);
    exit;
 end;
 mSearchString:=InputBox('Kód SÚKL', 'Zadejte kód:','',mSite);
  if not(Trim(mSearchString)='') then begin

     mStoreCard_ID:=mSite.BaseObjectSpace.SQLSelectFirstAsString(Format('SELECT A.ID FROM StoreCards A WHERE (A.Hidden = ''N'' ) '+
                                            'AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000212 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' '+
                                            'AND ID = A.ID AND (STRINGFIELDVALUE LIKE ''%s'' ESCAPE ''~''))) ',[mSearchString]),'');
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mControl:= mSite.FindChildControl('tabRows.grdRows');
       mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
       if Assigned(mDataset) then begin
         mRowBO:=mDataset.CurrentObject;
         mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
         mDataset.UpdateFields;
       end;
     end;
  end;
end;

begin
end.