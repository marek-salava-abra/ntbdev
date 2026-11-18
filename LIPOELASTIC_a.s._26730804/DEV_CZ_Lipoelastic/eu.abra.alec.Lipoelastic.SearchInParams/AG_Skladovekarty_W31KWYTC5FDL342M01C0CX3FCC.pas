{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actSearchInParams';
  mAction.Caption:= '## Hledat v parametrech ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @SearchInParams;
end;

procedure SearchInParams(Sender: TComponent);
var
  mSite: TSiteForm;
  mForm: TForm;
  mOS: TNxCustomObjectSpace;
  mButOK, mButCancel, mButClear: TButton;
  mRGroup: TRadioGroup;
  mRoll: TRollComboEdit;
  mLabelRoll: TLabel;
  mTMemo, mParamsMemo, mParamValuesMemo: TMemo;
  mInversionChck: TCheckBox;
  mSQLFragment, mSELECT, mWHERE, mGROUPBY, mHAVING, mInversion, mSQL: string;
  i: integer;
begin
  mSite:= Sender.Site;
  mOS:= TBusRollSiteForm(mSite).BaseObjectSpace;
  try
    mForm:= TForm.Create(mSite);
    mForm.Height:= 500;
    mForm.Width:= 600;

    mLabelRoll:= TLabel.Create(mForm);
    mLabelRoll.Parent:= mForm;
    mLabelRoll.Top:= 23;
    mLabelRoll.Left:= 20;
    mLabelRoll.Width:= 70;
    mLabelRoll.Caption:= 'Hledat dle parametrů:';

    mRoll:= TRollComboEdit.Create(mForm);
    mRoll.Parent:= mForm;
    mRoll.Name:= 'mParameterRoll';
    mRoll.Text:= '';
    mRoll.Top:= 20;
    mRoll.Left:= 150;
    mRoll.MultiChoice:= true;
    mRoll.TextField:= 'Name';
    mRoll.Tag:= ObjToInt(mForm);
    mRoll.ClassID:= Roll_SCParameteres;
    mRoll.OnChange:= @RollOnchange;
    mRoll.OnExit:= @RollOnChange;

    mTMemo:= TMemo.Create(mForm);
    mTMemo.Parent:= mForm;
    mTMemo.Name:= 'mTMemo';
    mTMemo.Clear;
    mTMemo.ReadOnly:= true;
    mTMemo.WordWrap:= false;
    mTMemo.Top:= 50;
    mTMemo.Left:= 20;
    mTMemo.Width:= 520;
    mTMemo.Height:= 200;

    mParamsMemo:= TMemo.Create(mForm);
    mParamsMemo.Parent:= mForm;
    mParamsMemo.Name:= 'mParamsTMemo';
    mParamsMemo.Clear;
    mParamsMemo.ReadOnly:= true;
    mParamsMemo.WordWrap:= false;
    mParamsMemo.Top:= 250;
    mParamsMemo.Left:= 20;
    mParamsMemo.Width:= 500;
    mParamsMemo.Height:= 0;  //50

    mParamValuesMemo:= TMemo.Create(mForm);
    mParamValuesMemo.Parent:= mForm;
    mParamValuesMemo.Name:= 'mValuesTMemo';
    mParamValuesMemo.Clear;
    mParamValuesMemo.ReadOnly:= true;
    mParamValuesMemo.WordWrap:= false;
    mParamValuesMemo.Top:= 300;
    mParamValuesMemo.Left:= 20;
    mParamValuesMemo.Width:= 500;
    mParamValuesMemo.Height:= 0;     //50

    mRGroup:= TRadioGroup.Create(mForm);
    mRGroup.Parent:= mForm;
    mRGroup.Items.Add('A');
    mRGroup.Items.Add('Nebo');
    mRGroup.Caption:= 'Výběrová podmínka:';
    mRGroup.ItemIndex:= 0;
    mRGroup.Columns:= 2;
    mRGroup.Top:= 260;
    mRGroup.Left:= 20;
    mRGroup.Height:= 50;
    mRGroup.Width:= 200;

    mInversionChck:= TCheckBox.Create(mForm);
    mInversionChck.Parent:= mForm;
    mInversionChck.Caption:= 'Inverze';
    mInversionChck.Top:= 260;
    mInversionChck.Left:= 260;
    mInversionChck.Height:= 25;
    mInversionChck.Width:= 100;

    mButOK:= TButton.Create(mForm);
    mButOK.Parent:= mForm;
    mButOK.Top:= mForm.Height - 80;
    mButOK.Left:= 60;
    mButOK.Height:= 25;
    mButOK.Width:= 80;
    mButOK.Caption:= 'OK';
    mButOK.Name:= 'mMainButOK';
    mButOK.Default:= true;
    mButOK.ModalResult:= mrYes;

    mButCancel:= TButton.Create(mForm);
    mButCancel.Parent:= mForm;
    mButCancel.Top:= mForm.Height - 80;
    mButCancel.Left:= 260;
    mButCancel.Height:= 25;
    mButCancel.Width:= 80;
    mButCancel.Caption:= 'Cancel';
    mButCancel.ModalResult:= mrCancel;

    mButClear:= TButton.Create(mForm);
    mButClear.Parent:= mForm;
    mButClear.Top:= mForm.Height - 80;
    mButClear.Left:= 460;
    mButClear.Height:= 25;
    mButClear.Width:= 80;
    mButClear.Caption:= 'Vyčistit';
    mButClear.Tag:= ObjToInt(mForm);
    mButClear.OnClick:= @ClearMemoFields;

    if mForm.ShowModal(mSite) = mrYes then begin
      if mParamsMemo.Lines.Count > 0 then begin
        mSELECT:= '';
        mWHERE:= '';
        mGROUPBY:= '';
        mHAVING:= '';
        mInversion:= '';

        if mRGroup.ItemIndex = 0 then begin
          mSELECT:= ' SELECT DRD.X_Value_ID FROM DefRollData DRD ';
          mGROUPBY:= ' GROUP BY X_Value_ID ';
          mHAVING:= ' HAVING COUNT(X_Value_ID) = '+IntToStr(mParamsMemo.Lines.Count);
        end else begin
          mSELECT:= ' SELECT DISTINCT(DRD.X_Value_ID) FROM DefRollData DRD ';
        end;
        mWHERE:= ' WHERE (DRD.CLSID='+QuotedStr(Class_BO_Relations)+') AND (DRD.X_Rel_Def = ''10'') ';

        for i:= 0 to mParamsMemo.Lines.Count -1 do begin
          if i = 0 then
            mWHERE:= mWHERE + ' AND ('+mParamsMemo.Lines.Strings[i];
          if (i > 0) and (i < mParamsMemo.Lines.Count -1) then
            mWHERE:= mWHERE + ' OR '+ mParamsMemo.Lines.Strings[i];
          if (i = mParamsMemo.Lines.Count -1) and (mParamsMemo.Lines.Count > 1) then
            mWHERE:= mWHERE + ' OR '+ mParamsMemo.Lines.Strings[i];
          if (i = mParamsMemo.Lines.Count -1) then
            mWHERE:= mWHERE + ')';
        end;

        if mInversionChck.Checked then
          mInversion:= 'NOT';

        mWHERE:= NxSearchReplace(mWHERE, '##NOT##', mInversion, [srAll]);

        mSQL:= mSELECT + mWHERE + mGROUPBY + mHAVING;
        {
        if mParamsMemo.Lines.Count > 0 then begin
          mSQLFragment:= mSQLFragment + '(X_Parameter_ID in ('+mParamsMemo.Lines.CommaText+') AND X_RollValueID in ('+mParamValuesMemo.Lines.CommaText+'))';
          mSQLFragment:= NxSearchReplace(mSQLFragment, '"', '', [srAll]);
        end;
        }
        {
        if mTMemo.Lines.Count > 0 then begin
          if mParamsMemo.Lines.Count > 0 then
            mSQLFragment:= mSQLFragment + ' AND ';
          for i:= 0 to mTMemo.Lines.Count -1 do begin
            if i > 0 then
              mSQLFragment:= mSQLFragment + ' AND '+ mTMemo.Lines.Strings[i]
            else
              mSQLFragment:= mSQLFragment + mTMemo.Lines.Strings[i];
          end;
        end;
        }

        //NxShowSimpleMessage(mSQL, mForm.Site);
        //mSQLFragment:= '(SELECT DISTINCT(DRD.X_Value_ID) FROM DefRollData DRD '+mSQLFragment + 'AND DRD.CLSID='+QuotedStr(Class_BO_Relations)+')';
        mSite.ShowSite(Site_StoreCards, false, 'FilterByUserDynSQLCondition;A.ID in (' + mSQL + ')');
      end;
    end;
  finally
    mForm.Free;
  end;
end;

procedure RollOnChange(Sender: TObject);
var
  mForm, mNumericForm: TForm;
  mRoll: TRollComboEdit;
  mTMemo, mParamsMemo, mValuesMemo: TMemo;
  mLabelMin, mLabelMax: TLabel;
  mEditMin, mEditMax: TEdit;
  mButOK, mButCancel: TButton;
  mParamBO, mRollBO: TNxCustomBusinessObject;
  mRollCLSID, mBOCLSID, mStr: string;
  mType, i, j, mFoundAt: integer;
  mOpenRolSite: TOpenRolSite;
  mSelList, mSelNames, mParamIDs: TStringList;
  mIsValid: Boolean;
  mParams, mParamsSelection: TNxParameters;
begin
  mType:= 0;
  mRollCLSID:= '';
  mBOCLSID:= '';
  mForm:= TForm(TRollComboEdit(Sender).Tag);
  mRoll:= TRollComboEdit(mForm.FindComponent('mParameterRoll'));
  mTMemo:= TMemo(mForm.FindComponent('mTMemo'));
  mParamsMemo:= TMemo(mForm.FindComponent('mParamsTMemo'));
  mValuesMemo:= TMemo(mForm.FindComponent('mValuesTMemo'));
  if not(NxIsEmptyOID(mRoll.DataText)) then begin
    mParamBO:= mForm.Site.BaseObjectSpace.CreateObject(Class_BOSCParameters);
    try
      mParamBO.Load(mRoll.DataText, nil);
      mType:= mParamBO.GetFieldValueAsInteger('X_TypeOfValue');
      mRollCLSID:= mParamBO.GetFieldValueAsString('X_RollCLSID');
      mBOCLSID:= mParamBO.GetFieldValueAsString('X_BOCLSID');
    finally
      mParamBO.Free;
    end;

    if mType = 0 then begin   //ZNAKY
      mStr:= InputBox(mRoll.Text, '', '', mForm.Site);
      mParamsMemo.Lines.Add('(DRD.X_Parameter_ID = '+QuotedStr(mRoll.DataText)+' DRD.X_ParamValue= '+QuotedStr(mStr)+')');
      mTMemo.Lines.Add(mRoll.Text +' = '+ QuotedStr(mStr));
      mRoll.Clear;
      mRoll.DataText:= '';
    end;

    if mType = 1 then begin    //ČÍSELNÍK
      mSelList:= TStringList.Create;
      mSelList.Delimiter:= ',';
      mParamIDs:= TStringList.Create;
      mParamIDs.Delimiter:= ',';
      mSelNames:= TStringList.Create;
      try
        mParamsSelection:= TNxParameters.Create;
        mParams:= TNxParameters.Create;
        mParams.GetOrCreateParam(dtObject, '_SelectedList').AsObject:= mParamsSelection;

        for i:= 0 to mParamsMemo.lines.Count -1 do begin
          if NxSearch(mParamsMemo.Lines.Strings[i], 'DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText), [srAll], 0) <> 0 then begin

            mParamIDs.CommaText:= NxSearchReplace(mParamsMemo.Lines.Strings[i], '(DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText)+' AND DRD.X_RollValueID ##NOT## in (', '', [srAll]);
            mParamIDs.CommaText:= NxSearchReplace(mParamIDs.CommaText, Chr(39), '', [srAll]);
            mParamIDs.CommaText:= NxLeft(mParamIDs.CommaText, Length(mParamIDs.CommaText)-2);
            for j:= 0 to mParamIDs.Count -1 do begin
              mParamsSelection.GetOrCreateParam(dtString, mParamIDs[j]).AsString:= mParamIDs[j];
            end;
            mParams.GetOrCreateParam(dtObject, '_SelectedList').AsObject:= mParamsSelection;
            //NxShowSimpleMessage(mParamsSelection.ShowValues, mform);
            mParamIDs.Clear;
          end;
        end;
        //ZOBRAZÍM ČÍSELNÍK A VYBERU ZÁZNAMY
        if NxShowRoll(mForm.Site.SiteContext, mRollCLSID, mParams, 0, '', mForm.GetParentForm) then begin
          {
          mOpenRolSite:= TOpenRolSite.Create(mForm.Site.SiteContext, mRollCLSID);
          mOpenRolSite.ParentForm:= mForm;
          mOpenRolSite.AdditionalParams:= mParams;
          mOpenRolSite.MultiChoice:= True;
          mOpenRolSite.Detailed:= false;
          mOpenRolSite.Open;

          mSelList.AddStrings(mOpenRolSite.SelectedList);
          }

          //POKUD JE NĚCO VYBRÁNO PŘEDÁM SI TO DO LISTU S OZNAČENÝMI ZÁZNAMY
          {
          for i:= 0 to mParamsSelection.Count -1 do begin
            mSelList.Add(mParamsSelection.Params[i].AsString);
          end;
          }
          //ZÍSKÁM NÁZVY PARAMETRŮ A KVŮLI DALŠÍMU ZPRACOVÁNÍ PŘIDÁM QUOTES JEDNOTLIVÝM ZÁZNAMŮM
          mRollBO:= mForm.Site.BaseObjectSpace.CreateObject(mBOCLSID);
          try
            for i:=0 to mParamsSelection.Count -1 do begin
              mRollBO.Load(mParamsSelection.Params[i].AsString, nil);
              mSelNames.Add(mRollBO.GetFieldValueAsString('Name'));
              mSelList.Add(QuotedStr(mParamsSelection.Params[i].AsString));
              //mSelList[i]:= QuotedStr(mSelList[i]);
            end;
          finally
            mRollBO.Free;
          end;

        end;
        //POKUD BYL VYBRÁN ALESPOŇ JEDEN ZÁZNAM
        if mSelList.Count > 0 then begin
          OutputDebugString(mSelList.CommaText);
          //DOHLEDÁM JESTLI JIŽ NENÍ ZÁZNAM V SEZNAMU VYBRANÝCH PARAMETRŮ A ZMĚNÍM
          if NxSearch(mParamsMemo.Lines.CommaText, 'DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText), [srAll], 0) <> 0 then begin
            for i:= 0 to mParamsMemo.Lines.Count -1 do begin
              if NxSearch(mParamsMemo.Lines.Strings[i], 'DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText), [srAll], 0) <> 0 then begin
                mParamsMemo.Lines.Strings[i]:= '(DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText)+' AND DRD.X_RollValueID ##NOT## in ('+mSelList.CommaText+')) ';
                mTMemo.Lines.Strings[i]:= mRoll.Text +' = '+ mSelNames.CommaText;
              end;
            end;
          //KDYŽ NEDOHLEDÁM DOPLNÍM
          end else begin
            mParamsMemo.Lines.Add('(DRD.X_Parameter_ID='+QuotedStr(mRoll.DataText)+' AND DRD.X_RollValueID ##NOT## in ('+mSelList.CommaText+')) ');
            mTMemo.Lines.Add(mRoll.Text +' = '+ mSelNames.CommaText);
          end;

          //mParamsMemo.Lines.Add(QuotedStr(mRoll.DataText));
          //mValuesMemo.Lines.Add(mSelList.CommaText);

        end;

        mRoll.Clear;
        mRoll.DataText:= '';

      finally
        mSelList.Free;
        mParamIDs.Free;
        mSelNames.Free;
        mOpenRolSite.Free;
        mParamsSelection.Free;
        mParams.Free;
        //mParamsMemo.Clear;
        //mTMemo.Clear;
        //mValuesMemo.Clear;
      end;
    end;

    if mType = 2 then begin    //ČÍSLO
      mNumericForm:= TForm.Create(mForm);
      mNumericForm.Caption:= mRoll.Text;
      mNumericForm.Height:= 200;
      mNumericForm.Width:= 200;
      try
        mLabelMin:= TLabel.Create(mNumericForm);
        mLabelMin.Parent:= mNumericForm;
        mLabelMin.Top:= 20;
        mLabelMin.Left:= 23;
        mLabelMin.Height:= 30;
        mLabelMin.Width:= 50;
        mLabelMin.Caption:= 'Od:';

        mLabelMax:= TLabel.Create(mNumericForm);
        mLabelMax.Parent:= mNumericForm;
        mLabelMax.Top:= 20;
        mLabelMax.Left:= 103;
        mLabelMax.Height:= 30;
        mLabelMax.Width:= 50;
        mLabelMax.Caption:= 'Do:';

        mEditMin:= TEdit.Create(mNumericForm);
        mEditMin.Parent:= mNumericForm;
        mEditMin.Name:= 'mEditMin';
        mEditMin.EditText:= '';
        mEditMin.Top:= 40;
        mEditMin.Left:= 20;
        mEditMin.Height:= 30;
        mEditMin.Width:= 50;

        mEditMax:= TEdit.Create(mNumericForm);
        mEditMax.Parent:= mNumericForm;
        mEditMax.Name:= 'mEditMax';
        mEditMax.EditText:= '';
        mEditMax.Top:= 40;
        mEditMax.Left:= 100;
        mEditMax.Height:= 30;
        mEditMax.Width:= 50;

        mButOK:= TButton.Create(mNumericForm);
        mButOK.Parent:= mNumericForm;
        mButOK.Top:= 80;
        mButOK.Left:= 20;
        mButOK.Height:= 25;
        mButOK.Width:= 70;
        mButOK.Caption:= 'OK';
        mButOK.Name:= 'mOKButton';
        mButOK.Default:= true;
        mButOK.Tag:= ObjToInt(mNumericForm);
        mButOK.OnClick:= @OnButOKValidate;

        mButCancel:= TButton.Create(mNumericForm);
        mButCancel.Parent:= mNumericForm;
        mButCancel.Top:= 80;
        mButCancel.Left:= 100;
        mButCancel.Height:= 25;
        mButCancel.Width:= 70;
        mButCancel.Caption:= 'Cancel';
        mButCancel.ModalResult:= mrCancel;

        if mNumericForm.ShowModal(mForm) = mrYes then begin
          mParamsMemo.Lines.Add('(DRD.X_Parameter_ID = '+QuotedStr(mRoll.DataText)+ ' AND ((DRD.X_NumericValue >= '+mEditMin.EditText+') AND (DRD.X_NumericValue <= '+mEditMax.EditText+')))');
          mTMemo.Lines.Add(mRoll.Text +' od: '+ mEditMin.EditText + ' do: '+mEditMax.EditText);
          mRoll.Clear;
          mRoll.DataText:= '';
        end;
      finally
        mNumericForm.Free;
      end;
    end;

    if mType = 3 then begin     //BOOLEAN
      if NxMessageBox(mRoll.Text, mRoll.Text, mdConfirm, mdbYesNo, mrYes, nil, false, mForm.Site) = mrYes then begin
        mParamsMemo.Lines.Add('(DRD.X_Parameter_ID = '+QuotedStr(mRoll.DataText)+' AND DRD.X_BooleanValue= '+QuotedStr('A')+')');
        mTMemo.Lines.Add(mRoll.Text +' = '+ QuotedStr('A'));
      end else begin
        mParamsMemo.Lines.Add('(DRD.X_Parameter_ID = '+QuotedStr(mRoll.DataText)+' AND DRD.X_BooleanValue= '+QuotedStr('N')+')');
        mTMemo.Lines.Add(mRoll.Text +' = '+ QuotedStr('N'));
      end;
      mRoll.Clear;
      mRoll.DataText:= '';
    end;
  end;
end;

procedure OnButOKValidate(Sender: TObject);
var
  mNumericForm: TForm;
  mMin, mMax: TEdit;
  mMinVal, mMaxVal: Extended;
begin
  mNumericForm:= TForm(TButton(Sender).Tag);
  mMin:= TEdit(mNumericForm.FindComponent('mEditMin'));
  mMax:= TEdit(mNumericForm.FindComponent('mEditMax'));
  if (TryStrToFloat(mMin.EditText, mMinVal)) and (TryStrToFloat(mMax.EditText, mMaxVal)) then
    mNumericForm.ModalResult:= mrYes
  else
    NxShowSimpleMessage('Musíte vložit číselnou hodnotu', mNumericForm.Owner.Site);
end;

procedure ClearMemoFields(Sender: TObject);
var
  mForm: TForm;
  mTMemo, mParamsMemo, mValuesMemo: TMemo;
begin
  mForm:= TForm(TButton(Sender).Tag);
  mTMemo:= TMemo(mForm.FindComponent('mTMemo'));
  mParamsMemo:= TMemo(mForm.FindComponent('mParamsTMemo'));
  mValuesMemo:= TMemo(mForm.FindComponent('mValuesTMemo'));

  mTMemo.Clear;
  mParamsMemo.Clear;
  mValuesMemo.Clear;
end;

{
function NumericInputForm(AParent: TForm; ACaption: string): TForm;
var
  mForm: TForm;
  mLabelMin, mLabelMax: TLabel;
  mEditMin, mEditMax: TEdit;
  mButOK, mButCancel: TButton;
begin
  mForm:= TForm.Create(AParent);
  mForm.Caption:= ACaption;
  mForm.Height:= 200;
  mForm.Width:= 200;

  mLabelMin:= TLabel.Create(mForm);
  mLabelMin.Parent:= mForm;
  mLabelMin.Top:= 20;
  mLabelMin.Left:= 23;
  mLabelMin.Height:= 30;
  mLabelMin.Width:= 50;
  mLabelMin.Caption:= 'Od:';

  mLabelMax:= TLabel.Create(mForm);
  mLabelMax.Parent:= mForm;
  mLabelMax.Top:= 20;
  mLabelMax.Left:= 103;
  mLabelMax.Height:= 30;
  mLabelMax.Width:= 50;
  mLabelMax.Caption:= 'Do:';

  mEditMin:= TEdit.Create(mForm);
  mEditMin.Parent:= mForm;
  mEditMin.Name:= 'mEditMin';
  mEditMin.EditText:= '';
  mEditMin.Top:= 40;
  mEditMin.Left:= 20;
  mEditMin.Height:= 30;
  mEditMin.Width:= 50;

  mEditMax:= TEdit.Create(mForm);
  mEditMax.Parent:= mForm;
  mEditMax.Name:= 'mEditMax';
  mEditMax.EditText:= '';
  mEditMax.Top:= 40;
  mEditMax.Left:= 100;
  mEditMax.Height:= 30;
  mEditMax.Width:= 50;

  mButOK:= TButton.Create(mForm);
  mButOK.Parent:= mForm;
  mButOK.Top:= 80;
  mButOK.Left:= 20;
  mButOK.Height:= 25;
  mButOK.Width:= 70;
  mButOK.Caption:= 'OK';
  mButOK.Name:= 'mOKButton';
  mButOK.Default:= true;
  mButOK.Tag:= ObjToInt(mForm);
  mButOK.OnClick:= @OnButOKValidate;

  mButCancel:= TButton.Create(mForm);
  mButCancel.Parent:= mForm;
  mButCancel.Top:= 80;
  mButCancel.Left:= 100;
  mButCancel.Height:= 25;
  mButCancel.Width:= 70;
  mButCancel.Caption:= 'Cancel';
  mButCancel.ModalResult:= mrCancel;
end;
}

begin
end.