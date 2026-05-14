uses 'abra.eu.simonasdf.service';

procedure MultiAkceExecuteItem(Sender: TObject; Index: integer);


var mSite : TSiteForm;
    mGrid : TDBGrid;
    mList : TStringList;
    mBO, mStoreCard, mBOReservation : TNxCustomBusinessObject;
    mStoreCard_ID, mReservation_ID : String;
    i : integer;
    mProrez: Extended;

begin
mList := TStringList.Create;
try
 mSite := TComponent(Sender).DynSite;
// mGrid := TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList'));
 if Assigned(mSite) then begin
  TDynSiteForm(mSite).FillListWithSelectedRows(mList);
   if (mList.count) > 0 then begin

     if index=0 then begin

         mBO := mSite.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
       try
         for i := 0 to (mList.Count - 1) do begin
          mBO.Load(mList.strings[i], nil);
          mBO.SetFieldValueAsDateTime('U_vychystano', Now);

          mBO.save;
         end;
          RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
         except showmessage('Chyba při přepsání aktivity!');
         end;
       end;
      if index=1 then begin

         mBO := mSite.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
       try
         for i := 0 to (mList.Count - 1) do begin
          mBO.Load(mList.strings[i], nil);
          mBO.SetFieldValueAsDateTime('U_odvezeno', Now);
          mBO.SetFieldValueAsString('U_ServiceStatus_ID','2000000101');

          mBO.save;
         end;
          RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
         except showmessage('Chyba při přepsání aktivity!');
         end;
         NxPrintByIDs(msite.SiteContext,mList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1C30000101',rtoPreview,pekPDF,'','')
       end;
      if index=2 then begin

         mBO := mSite.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
       try
         for i := 0 to (mList.Count - 1) do begin
          mBO.Load(mList.strings[i], nil);
          mBO.SetFieldValueAsDateTime('U_privezeno', Now);
          mBO.SetFieldValueAsString('U_ServiceStatus_ID','3000000101');

          mBO.save;
         end;
          RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
         except showmessage('Chyba při přepsání aktivity!');
         end;
       end;


    End
   else
    MessageDlg('Nevybrán žádný záznam', mtError,[mbOk],0);
 end;

finally mList.free;
end;
end;



begin
end.