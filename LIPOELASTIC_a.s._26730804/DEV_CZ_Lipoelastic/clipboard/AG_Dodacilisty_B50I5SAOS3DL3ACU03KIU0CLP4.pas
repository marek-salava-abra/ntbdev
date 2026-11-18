uses 'clipboard.lib';



procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);

    if copy(muser.GetFieldValueAsString('X_Button_parametr'),13,1)='1' then begin    // hromadná změna stavu
               mmAction := Self.GetNewMultiAction;
                mmAction.ShowControl := True;
                mmAction.ShowMenuItem := True;
                mmAction.Caption := 'Schránka ';
                mmAction.Hint := '(Clipboard)';
                mmAction.Category := 'tabDetail';
                mMAction.Items.Add('(IN) Do schránky');
                mMAction.Items.Add('(OUT) Ze schránky');
                mMAction.Items.Add('provedené změny');
                mmAction.OnExecuteItem:= @Clipboard;
    end;

  finally
    muser.free;
  end;
end;



procedure Clipboard(Sender: TAction; Index: integer);
var
  mSite: TDynSiteForm;
  mBO_Head: TNxHeaderBusinessObject;
  mID: string;
   mDL: TNxCustomBusinessObject;
  i,j,ii,iRows,iBatches, mIDataset,mPosIndex: integer;
  mMonikerRows,mMonBatches: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mDataset: TNxRowsObjectDataSet;
  mpocet:integer;
  mControl: TControl;
  mMonList:tstringlist;
  mDatasetList:tstringlist;
  mFind:Boolean;
  mChyba:integer;
  mString:string;
  mMemory:String;
  mGRows:TMultiGrid;
  mActualRow : TBookmark;
  mBookmark : TNxBookmarkList;
  mValueRows,mValueHead,mValueItems:tstringlist;
  mPomoc_ID:string;
  os:TNxCustomObjectSpace;
  mIsBatch:boolean;
  mIsStoreDocument:Boolean;
  mr:tstringlist;
begin
  mIsBatch:=true;
  mIsStoreDocument:=true;
  if Sender is TComponent then begin
      mSite := TComponent(Sender).DynSite;
      os:=msite.BaseObjectSpace;
      mBO_Head := TNxHeaderBusinessObject(mSite.CurrentObject);
            if Assigned(mBO_Head) then begin
                  if index=0 then FN_Clipboard(msite,os,mBO_Head,Index);
                  if index=1 then FN_Clipboard(msite,os,mBO_Head,Index);
                  if index=2 then FN_ClipboardChange(msite,os,mBO_Head,Index);
            end;
  end;

end;


begin
end.