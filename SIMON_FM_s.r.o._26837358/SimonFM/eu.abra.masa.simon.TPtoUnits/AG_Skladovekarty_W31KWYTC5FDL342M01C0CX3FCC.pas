Var
 mNumEd:TNumEdit;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '##TP -> jednotky##';
  mAction.Items.Add('Hodnoty z tech. parametrů do jednotek');
  mAction.Items.Add('Hodnoty z jednotek do tech. parametrů');
  mAction.Hint := 'Převod hodnot mezi technickými parametry a hlavní jednotkou';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @SetParameters;
end;

Procedure SetParameters(Sender:TComponent; Index:integer);
var
 mSite:TSiteForm;
 mList:TStringList;
 mBO, mUnitBO, mParamBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 i, j, k, mDestValue, mSourceValue:integer;
 mTechParameter_ID, mParamValueStr, mParamValue_ID, mPosIndex:string;
 mKoef, mValue:Extended;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 mKoef:=1;
 if mlist.count>0 then begin
   if Index=0 then begin
    if GetDataForChange(mSite,mTechParameter_ID,mDestValue,mKoef) then begin
          k:=mList.Count;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
            Try
             for i:=0 to k-1 do begin
               mParamValueStr:=mOS.SQLSelectFirstAsString('Select X_ParamValue from defrolldata where clsid='+Quotedstr(Class_BO_Relations)+' and X_parameter_ID='+QuotedStr(mTechParameter_ID)+' and X_Rel_def='+QuotedStr('03')+' and X_Value_ID='+QuotedStr(mList.Strings[i]),'');
               //NxShowSimpleMessage(mParamValueStr,mSite);
               if NxIBStrToFloat(mParamValueStr)>0 then begin
                mBO:=mOS.CreateObject(Class_StoreCard);
                mBO.Load(mlist.Strings[i],nil);
                mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
                for j:=0 to mUnits.count-1 do begin
                  mUnitBO:=mUnits.BusinessObject[j];
                  if mBO.GetFieldValueAsString('MainUnitCode')=mUnitBO.GetFieldValueAsString('Code') then begin
                    if mDestValue=0 then mUnitBO.SetFieldValueAsFloat('Weight',NxIBStrToFloat(mParamValueStr)/mKoef);
                    if mDestValue=1 then mUnitBO.SetFieldValueAsFloat('Width',NxIBStrToFloat(mParamValueStr)/mKoef);
                    if mDestValue=2 then mUnitBO.SetFieldValueAsFloat('Depth',NxIBStrToFloat(mParamValueStr)/mKoef);
                    if mDestValue=3 then mUnitBO.SetFieldValueAsFloat('Height',NxIBStrToFloat(mParamValueStr)/mKoef);
                  end;
                end;
                mBO.save;
                mBO.free;
               end;
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
             end;
            WaitWin.Stop;
           except
            WaitWin.Stop;
            NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
           end;
    end;
   end;
   if Index=1 then begin
    if GetDataForChangeINV(mSite,mTechParameter_ID,mSourceValue,mKoef) then begin
          k:=mList.Count;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
            Try
             for i:=0 to k-1 do begin
               //mParamValueStr:=mOS.SQLSelectFirstAsString('Select X_ParamValue from defrolldata where clsid='+Quotedstr(Class_BO_Relations)+' and X_parameter_ID='+QuotedStr(mTechParameter_ID)+' and X_Rel_def='+QuotedStr('03')+' and X_Value_ID='+QuotedStr(mList.Strings[i]),'');
               //NxShowSimpleMessage(mParamValueStr,mSite);

                mBO:=mOS.CreateObject(Class_StoreCard);
                mBO.Load(mlist.Strings[i],nil);
                mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
                for j:=0 to mUnits.count-1 do begin
                  mUnitBO:=mUnits.BusinessObject[j];
                  if mBO.GetFieldValueAsString('MainUnitCode')=mUnitBO.GetFieldValueAsString('Code') then begin
                    if mSourceValue=0 then mValue:=mUnitBO.GetFieldValueAsFloat('Weight')*mKoef;
                    if mSourceValue=1 then mValue:=mUnitBO.GetFieldValueAsFloat('Width')*mKoef;
                    if mSourceValue=2 then mValue:=mUnitBO.GetFieldValueAsFloat('Depth')*mKoef;
                    if mSourceValue=3 then mValue:=mUnitBO.GetFieldValueAsFloat('Height')*mKoef;
                  end;
                end;
                mBO.free;
                mParamValue_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+Quotedstr(Class_BO_Relations)+' and X_parameter_ID='+QuotedStr(mTechParameter_ID)+' and X_Rel_def='+QuotedStr('03')+' and X_Value_ID='+QuotedStr(mList.Strings[i]),'');
                if not(NxIsEmptyOID(mParamValue_ID)) then begin
                  mParamBO:=mOS.CreateObject(Class_BO_Relations);
                  mParamBO.load(mParamValue_ID,nil);
                  mParamBO.SetFieldValueAsString('X_ParamValue',FloatToStr(mValue));
                  mParamBO.save;
                  mParamBO.free;
                end else begin
                  mParamBO:=mOS.CreateObject(Class_BO_Relations);
                  mParamBO.New;
                  mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid='+Quotedstr(Class_BO_Relations)+' and X_Rel_Def=''03'' and X_Value_ID='+QuotedStr(mList.strings[i]));
                  if Length(mPosIndex)=0 then mParamBO.SetFieldValueAsString('X_Posindex','01') else
                  mParamBO.SetFieldValueAsString('X_posindex',AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2));
                  mParamBO.SetFieldValueAsString('X_Value_ID',mList.strings[i]);
                  mParamBO.SetFieldValueAsString('X_Rel_Def','03');
                  mParamBO.SetFieldValueAsString('X_parameter_ID',mTechParameter_ID);
                  mParamBO.SetFieldValueAsString('X_ParamValue',FloatToStr(mValue));
                  mParamBO.save;
                  mParamBO.free;
                end;
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
             end;
            WaitWin.Stop;
           except
            WaitWin.Stop;
            NxShowSimpleMessage('Něco se nepovedlo: '+#13#10+ExceptionMessage,msite);
           end;
    end;
   end;
 end;
 mList.Free;
end;


Function GetDataForChange(var ASite : TSiteform; var aTechParameter_ID: String; var aDestinationValue:integer; var aKoeficient:Extended):boolean;
var
 mButOk, mButCancel : TButton;
 mResult, mCount : integer;
 mForm : TForm;
 mDestinationUnits:TStringList;
 mLabel, mCbCcTechParam:TLabel;
 mCbTechParam:TRollComboEdit;
 mDestinationUnitCB:TComboBox;
begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro změnu do jednotek:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mDestinationUnits:=TStringList.create;
    mDestinationUnits.add('Hmotnost');
    mDestinationUnits.add('Šířka');
    mDestinationUnits.add('Hloubka');
    mDestinationUnits.add('Výška');


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Parametr:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCcTechParam:= TLabel.Create(mForm);
    mCbCcTechParam.Parent:= mForm;
    mCbCcTechParam.Left:= 236;
    mCbCcTechParam.Top:= (mCount*25)+12;
    mCbCcTechParam.Width:= 255;

    mCbTechParam:= TRollComboEdit.Create(mForm);
    mCbTechParam.Parent:= mForm;
    mCbTechParam.ClassID:= Roll_SCParameteres;
    mCbTechParam.Complete:= True;
    mCbTechParam.Prefilling:= pmNone;
    mCbTechParam.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbTechParam.Top:= (mCount*25)+10;
    mCbTechParam.Left:= 140;
    mCbTechParam.Width:= 80;
    //mCbStoreCard.OnExit:=@SetComboBoxes;
    mCbTechParam.ConnectedControl:= mCbCcTechParam;
    mCbTechParam.ConnectedControlField:= 'Name';

    mCount:= mCount+1;


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Cíl. hodnota:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mDestinationUnitCB:= TComboBox.Create(mForm);
    mDestinationUnitCB.Parent:=mForm;
    mDestinationUnitCB.Left := 140;
    mDestinationUnitCB.Top := (mCount*25)+10;
    mDestinationUnitCB.Width := 80;
    mDestinationUnitCB.Items:=mDestinationUnits;
    mDestinationUnitCB.ItemIndex:=0;
    mDestinationUnitCB.OnExit:=@SetKoef;
    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Koeficient:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aKoeficient;
    mNumEd.DecimalPlaces := 3;
    mNumEd.Parent := mForm;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         Result:=true;
         aKoeficient:=mNumEd.value;
         aTechParameter_ID:=mCbTechParam.DataText;
         aDestinationValue:=mDestinationUnitCB.ItemIndex;
     end;
    mForm.free;
  end;
end;

Function GetDataForChangeINV(var ASite : TSiteform; var aTechParameter_ID: String; var aDestinationValue:integer; var aKoeficient:Extended):boolean;
var
 mButOk, mButCancel : TButton;
 mResult, mCount : integer;
 mForm : TForm;
 mDestinationUnits:TStringList;
 mLabel, mCbCcTechParam:TLabel;
 mCbTechParam:TRollComboEdit;
 mDestinationUnitCB:TComboBox;
begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro změnu do parametrů:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mDestinationUnits:=TStringList.create;
    mDestinationUnits.add('Hmotnost');
    mDestinationUnits.add('Šířka');
    mDestinationUnits.add('Hloubka');
    mDestinationUnits.add('Výška');


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Zdroj. hodnota:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mDestinationUnitCB:= TComboBox.Create(mForm);
    mDestinationUnitCB.Parent:=mForm;
    mDestinationUnitCB.Left := 140;
    mDestinationUnitCB.Top := (mCount*25)+10;
    mDestinationUnitCB.Width := 80;
    mDestinationUnitCB.Items:=mDestinationUnits;
    mDestinationUnitCB.ItemIndex:=0;
    mDestinationUnitCB.OnExit:=@SetKoef;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Cílový parametr:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCcTechParam:= TLabel.Create(mForm);
    mCbCcTechParam.Parent:= mForm;
    mCbCcTechParam.Left:= 236;
    mCbCcTechParam.Top:= (mCount*25)+12;
    mCbCcTechParam.Width:= 255;

    mCbTechParam:= TRollComboEdit.Create(mForm);
    mCbTechParam.Parent:= mForm;
    mCbTechParam.ClassID:= Roll_SCParameteres;
    mCbTechParam.Complete:= True;
    mCbTechParam.Prefilling:= pmNone;
    mCbTechParam.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbTechParam.Top:= (mCount*25)+10;
    mCbTechParam.Left:= 140;
    mCbTechParam.Width:= 80;
    //mCbStoreCard.OnExit:=@SetComboBoxes;
    mCbTechParam.ConnectedControl:= mCbCcTechParam;
    mCbTechParam.ConnectedControlField:= 'Name';

    mCount:= mCount+1;


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Koeficient:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aKoeficient;
    mNumEd.DecimalPlaces := 3;
    mNumEd.Parent := mForm;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         Result:=true;
         aKoeficient:=mNumEd.value;
         aTechParameter_ID:=mCbTechParam.DataText;
         aDestinationValue:=mDestinationUnitCB.ItemIndex;
     end;
    mForm.free;
  end;
end;


procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

Procedure SetKoef(Sender:TComboBox);
begin
 if Sender.ItemIndex>0 then mNumEd.Value:=1000;
end;

begin
end.