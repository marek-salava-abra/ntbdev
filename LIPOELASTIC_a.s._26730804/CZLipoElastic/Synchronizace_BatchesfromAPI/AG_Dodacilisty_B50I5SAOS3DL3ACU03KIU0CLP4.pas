  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
       '_Knihovny_ALL.VisualForms',
       'Synchronizace_dokladu_na_SK.API' ;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
 mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Založení batches';
  mmAction.Hint := 'Založení batches';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Založení batches');
  mmAction.OnExecuteItem:= @NewDLExecute;
end;




function NewDL(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText,mBatch_ID: string;
begin
  result := '';

  try
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
      for i := 0 to mMoninput.Count-1 do begin
            mBO_MonikerInput:=mMoninput.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mMoninput.BusinessObject[i].GetFieldCode('DocRowBatches'));
                           for ii:=0 to mBO_MonikerInput.Count-1 do begin
                                               mBatch_ID:=API_GetOrCreateBatch(mSite,mTargetDocumentAPI,mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID'));


                           end;
        end;

  finally

  end;
end;

procedure NewDLExecute(Sender: TAction; Index: integer);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        if index=0 then mID := NewDL(mObj,msite);

      end;
    finally
    end;
  end;
end;



begin
end.