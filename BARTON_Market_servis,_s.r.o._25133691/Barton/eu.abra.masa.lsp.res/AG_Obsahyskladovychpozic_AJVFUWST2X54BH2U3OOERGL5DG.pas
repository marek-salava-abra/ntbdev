procedure FormCreate_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := 'Import csv';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ImportDBF;
end;

procedure ImportDBF(Sender: TBasicAction);
var
  mSite: TSiteForm;
  mListIDs: TStringList;
  mTempStr, mPosID, mSCID, mQS: String;
  mExcel: Variant;
  mOpenDialog: TOpenDialog;
  mLine: String;
  mBO:TNxCustomBusinessObject;
  mList:TStringList;
  i:Integer;
begin
  mSite := TComponent(Sender).DynSite;
  if Assigned(mSite) then begin
    mOpenDialog := TOpenDialog.Create(mSite);
    try
      mOpenDialog.Filter := 'Soubor s daty (*.txt)|*.txt';
      mOpenDialog.FileName := '';
      if mOpenDialog.Execute then begin
        mList:=TStringList.create;
        mList.LoadFromFile(mOpenDialog.FileName);
        for i:=0 to mlist.Count-1 do begin
          mTempStr:=mList.Strings[i];
          mPosID:=NxTrapStrTrim(mTempStr,';');
          mSCID:=NxTrapStrTrim(mTempStr,';');
          mQS:=NxFloatToIBStr(NxIBStrToFloat(NxTrapStrTrim(mTempStr,';')));
          TDynSiteForm(mSite).BaseObjectSpace.SQLExecute('update logstorecontents set Quantityreserved='+mQS+' where parent_id='+QuotedStr(mPosID)+' and storecard_id='+QuotedStr(mSCID));
        end;
      end;
    finally
    end;
  end;
end;


begin
end.