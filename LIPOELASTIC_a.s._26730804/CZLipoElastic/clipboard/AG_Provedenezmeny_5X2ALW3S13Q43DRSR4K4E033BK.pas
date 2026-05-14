uses 'clipboard.lib';

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
  mmAction.Caption := 'Obnovit ';
  mmAction.Hint := '(obnovení smazeneho dokladu)';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('se zachováním id a čísla');
  mMAction.Items.Add('nové číslování');

  mmAction.OnExecuteItem:= @Clipboard;
end;


procedure Clipboard(Sender: TAction; Index: integer);
var
  mSite: TDynSiteForm;
  mBO_Source: TNxCustomBusinessObject;
  mBO_Head: TNxHeaderBusinessObject;
  mID: string;
   mDL: TNxCustomBusinessObject;
  i,j,ii,iRows,iBatches, mIDataset,mPosIndex: integer;
  mMonikerRows,mMonBatches: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mpocet:integer;
   mFind:Boolean;
  mChyba:integer;
  mString:string;
  mMemory:String;
  mBookmark : TNxBookmarkList;
  mValueRows,mValueHead,mValueItems:tstringlist;
  mPomoc_ID:string;
  os:TNxCustomObjectSpace;
  mIsBatch:boolean;
  mIsStoreDocument:Boolean;
  mr:tstringlist;
  mTbytes:TBytes;
  mTByteDynArray:TByteDynArray;
  aaa:string;
begin
  mIsBatch:=true;
  mIsStoreDocument:=true;
  if Sender is TComponent then begin
      mSite := TComponent(Sender).DynSite;
      os:=msite.BaseObjectSpace;
      mBO_Source:=TDynSiteForm(mSite).CurrentObject;
      //mBO_Head := TNxHeaderBusinessObject(mSite.CurrentObject);
            if Assigned(mBO_Source) then begin
                  //if index=0 then FN_ClipboardChange(msite,os,mBO_Head,Index);
                  NxShowSimpleMessage(inttostr(mBO_Source.GetFieldValueAsInteger('Status')),nil);

                  NxShowSimpleMessage(mBO_Source.GetFieldValueAsString('CLSID'),nil);
                  NxShowSimpleMessage(mBO_Source.GetFieldValueAsString('Obj_ID'),nil);
                  NxShowSimpleMessage(mBO_Source.GetFieldValueAsString('ID'),nil);

                  NxShowSimpleMessage(mBO_Source.GetFieldValueAsString('ObjectName'),nil);

                 // nxcustomblob(mbo_source).blobdata

                  aaa:=TEncoding.GetString(mBO_Source.GetFieldValueAsBytes('LogData'));


                 NxShowSimpleMessage(aaa,nil);









            end;
  end;

end;



begin
end.