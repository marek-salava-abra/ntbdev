procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actPokus';
  mAction.Caption := '##POKUS##';
  mAction.Hint := 'POKUS';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Pokus;
end;

Procedure Pokus(sender:TObject);
var
 mSite:TSiteForm;
 mPars,mSelectedList:TNxParameters;
 mList:TStringList;
 i:Integer;
 mOpenRolSite: TOpenRolSite;
 mIDs:string;
begin
 mSite:=TComponent(sender).DynSite;
 mList:=TStringList.create;
 mlist.LoadFromFile('C:\abrag3\test.txt');
 mPars := TNxParameters.Create;
 mSelectedList := TNxParameters.Create;
 if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
    mSelectedList.GetOrCreateParam(dtString, mlist.strings[i]).AsString := mlist.strings[i];
   end;
 end;

 mPars.GetOrCreateParam(dtObject, '_SelectedList').AsObject := mSelectedList;
 {
 mOpenRolSite:= TOpenRolSite.Create(mSite.SiteContext, Roll_ND_Type);
 mOpenRolSite.ParentForm:=mSite;
 mOpenRolSite.AdditionalParams:=mPars;
 mOpenRolSite.MultiChoice:= True;
 mOpenRolSite.Detailed:= false;
 mOpenRolSite.Open;  }

  if NxShowRoll(mSite.SiteContext, Roll_ND_Type, mPars, 0, '', nil) then begin
        mIDs := '';
        for i := 0 to mSelectedList.Count - 1 do
        begin
          mIDs := mIDs + mSelectedList.Params[i].AsString + ';';
        end;
        ShowMessage('Vybrané záznamy: ' + mIDs);

  end;


  {
  mSelList:= TStringList.Create;
      mSelNames:= TStringList.Create;
      mSelList.Delimiter:= ',';
      try
        mParamsSelection:= TNxParameters.Create;
        mParams:= TNxParameters.Create;    }
        {
        for i:= 0 to mParamsMemo.lines.Count -1 do begin
          if NxSearch(mParamsMemo.Lines.Strings[i], 'DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText), [srAll], 0) <> 0 then begin

            mSelList.CommaText:= NxSearchReplace(mParamsMemo.Lines.Strings[i], '(DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText)+' AND DRD.X_RollValueID ##NOT## in (', '', [srAll]);
            mSelList.CommaText:= NxSearchReplace(mSelList.CommaText, Chr(39), '', [srAll]);
            mSelList.CommaText:= NxLeft(mSelList.CommaText, Length(mSelList.CommaText)-2);
            for j:= 0 to mSelList.Count -1 do begin
              mParamsSelection.GetOrCreateParam(dtString, mSelList[j]).AsString:= mSelList[j];
              //NxShowSimpleMessage(mParamsSelection., mForm);
            end;
            //mParamsSelection.GetOrCreateParam(dtString, '~000002DHP').AsString:= '~000002DHP';
            mParams.GetOrCreateParam(dtObject, '_SelectedList').AsObject:= mParamsSelection;
            //NxShowSimpleMessage(mParamsSelection.ShowValues, mform);

            mSelList.Clear;
          end;
        end;
        }
        //if NxShowRoll(mForm.Site.SiteContext, mRollCLSID, mParams, 0, '', mForm) then begin
          //mSelList.CommaText:= mParamsSelection.ShowValues;
        {
          mOpenRolSite:= TOpenRolSite.Create(mForm.Site.SiteContext, mRollCLSID);
          mOpenRolSite.ParentForm:= mForm;
          mOpenRolSite.AdditionalParams:= mParams;
          mOpenRolSite.MultiChoice:= True;
          mOpenRolSite.Detailed:= false;
          mOpenRolSite.Open;
          }



end;

begin
end.