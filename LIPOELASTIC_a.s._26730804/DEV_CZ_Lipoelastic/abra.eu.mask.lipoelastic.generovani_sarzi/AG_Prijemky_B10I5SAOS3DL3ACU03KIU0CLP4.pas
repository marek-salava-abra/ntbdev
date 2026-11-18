uses '_GlobalSettings.konstanty';


  Var
mbo:TNxCustomBusinessObject;
mr:tstringlist;
mID:string;






procedure ShowRowOperationOnExecute(Sender: TAction);
var
  mSite : TSiteForm;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  mBO : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
  mGRows:TMultiGrid;
mList:TStringList;
mRows,mBO_Batches:TNxCustomBusinessMonikerCollection;
i,j,x:integer;
 mfilter:string;
begin
   msite:=TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
     mFilter:= '';
     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);
       for i:=0 to mRows.count-1 do begin
          if mList.count=0 then begin
            NxShowSimpleMessage('Není označen žádný řádek.',msite);
            exit;
          end;
          if  true then begin
                   for j:=0 to mList.count-1 do begin
                          if mRows.BusinessObject[i].OID=mList.Strings[j] then begin
                                mBO_Batches:=mRows.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mRows.BusinessObject[i].GetFieldCode('DocRowBatches'));
                                    for x:=0 to mBO_Batches.count-1 do begin
                                         mFilter:= mFilter + Format('''%s'',', [mBO_Batches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID')]);
                                    end;
                          end;
                    end;
          end;
       end;
       if mFilter <> '' then begin
          mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
       end;
      //NxShowSimpleMessage(mfilter,nil);
          msite.ShowSite('005WXDGLTVDL342W01C0CX3FCC',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ')');

end;







function iGetIDByCode(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Code=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


procedure ShowParameterItem(Sender: Tcomponent; Index: integer);
var
 L : TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TDynSiteForm;
 mr2:TStringList;
 mRows ,mBO_Batches: TNxCustomBusinessMonikerCollection;
 mBO:TNxCustomBusinessObject;
 mStrings:string;
 i,x:integer;
 mtext:string;
 mfilter:string;
begin
 mSite := TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
     mFilter:= '';
       for i:=0 to mRows.count-1 do begin
                                mBO_Batches:=mRows.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mRows.BusinessObject[i].GetFieldCode('DocRowBatches'));
                                    for x:=0 to mBO_Batches.count-1 do begin
                                         mFilter:= mFilter + Format('''%s'',', [mBO_Batches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID')]);
                                    end;
          end;

       if mFilter <> '' then begin
          mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
       end;

     //  NxShowSimpleMessage(mfilter,nil);
          msite.ShowSite('005WXDGLTVDL342W01C0CX3FCC',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ')');
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


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Šarže';
  mMAction.Hint := 'Šarže';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowParameterItem;
  mMAction.Items.Add('Šarže');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Šarže k řádku';
  mMAction.Hint := 'Šarže k řádku';
  mMAction.Category := 'tabdetail';
  mMAction.OnExecuteItem := @ShowRowOperationOnExecute;
  mMAction.Items.Add('Šarže');



end;



begin
end.