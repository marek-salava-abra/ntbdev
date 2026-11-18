procedure RowOperationOnExecute(Sender: TAction);
var
msite:TSiteForm;
mGRows:TMultiGrid;
mList:TStringList;
mBO, mBO_Batches:TNxCustomBusinessObject;
mRowBO:TNxCustomBusinessObject;
mRows, mBatches:TNxCustomBusinessMonikerCollection;
i, j,x:integer;
mSarze:string;
mBoolean:boolean;
mRowNo:integer;
mActualRow : TBookmark;
mBookmark : TNxBookmarkList;
begin
mRowNo:=0;
 mSite := NxFindSiteForm(Sender);

     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));


     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then begin
            mSarze:='';
            mBoolean:=InputQuery('Zadej hledanou šarži', 'Šarže', mSarze);
            if (mBoolean) and (mSarze<>'') then begin
                       if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
                       if mlist.Count=0 then begin
                          mGRows.SelectAll;
                          mGRows.FillListFromSelectedRows_1(mList,false);
                       end;
                       mBookmark := mGRows.SelectedRows;
                       mActualRow := mGRows.DataSource.DataSet.GetBookmark;
                       for i:=0 to mRows.count-1 do begin
                          if mList.count=0 then begin
                            NxShowSimpleMessage('Není označen žádný řádek.',msite);
                            exit;
                          end;
                                  if  true then begin
                                       for j:=0 to mList.count-1 do begin
                                            if mRows.BusinessObject[i].OID=mList.Strings[j] then begin
                                                        mRowBO:=mRows.BusinessObject[i];
                                                        mBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                                                            for x:=0 to mBatches.count-1 do begin
                                                                 if pos(Trim(mSarze),mBatches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID.Name'))>0 then begin
                                                                       NxShowSimpleMessage('Řádek:' + inttostr(i+1) + ', karta: ' + mRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID.EAN') +', '+ mRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Name') + ', Šarže:' +  mBatches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID.Name'),nil);
                                                                       mRowNo:=i;
                                                                       exit;
                                                                 end;
                                                            end;





                            {                mBO2:=mBO.ObjectSpace.CreateObject(Class_StoreCard);
                                            mbo2.Load(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'),nil);
                                            mEANString:=InputBox('Info','Sejměte EAN?','');
                                            if NxIsItEAN(mEANString) then begin
                                              mUnits:=mBO2.GetLoadedCollectionMonikerForFieldCode(mBO2.GetFieldCode('StoreUnits'));
                                              mUnit:=mUnits.BusinessObject[0];
                                             mEans:=mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreEANs'));
                                              mEAN:=mEans.AddNewObject;
                                              mEAN.SetFieldValueAsString('Ean',mEANString);  }

                                            end;
                                       //if mBO2.NeedSave then mBO2.Save;
                                       end;
                                  end;
                       end;
                  end else begin
                      NxShowSimpleMessage('Nebyla zadána šarže , přerušuji',nil);
                  end;
                  //mGRows.DataSource.DataSet.

             //     mGRows.DataSource.DataSet.GotoBookmark(mActualRow.items(mRowNo));


            mGRows.DataSource.DataSet.GotoBookmark(mBookMark.items(mRowNo));
          //  mGRows.UnselectAll;


//          if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;
     end;
end;







  {
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);

    if copy(muser.GetFieldValueAsString('X_Button_parametr'),7,1)='1' then begin    // hromadná změna stavu
  //  NxShowSimpleMessage(copy(muser.GetFieldValueAsString('X_Button_parametr'),7,1),nil);
        mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := 'Test validace';
        mAction.Hint := 'Test validace';
        mAction.Category := 'tabDetail';
        mAction.OnExecute := @RowOperationOnExecute;
   end;
finally
    muser.free;
end;


end;



begin
end.