
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.

procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);

    if copy(muser.GetFieldValueAsString('X_Button_parametr'),10,1)='1' then begin    // hromadná změna stavu

        mmAction := Self.GetNewMultiAction;
        mmAction.ShowControl := True;
        mmAction.ShowMenuItem := True;
        mmAction.Caption := 'Doplnění množství na šarží';
        mmAction.Hint := 'Doplnění množství na šarží';
        mmAction.Category := 'tabList';
        mMAction.Items.Add('Doplnění množství na šarží');
        mmAction.OnExecuteItem:= @NewDLExecute;
      end;
finally
    muser.free;
end;



end;


function NewOP(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mOP: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:tstringlist;
  mpocet:double;
begin
  result := '';
  try
    mMonInput := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
        mpocet:=0;
        if mRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
            mBO_MonikerInput:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                           for ii:=0 to mBO_MonikerInput.Count-1 do begin
                                 if mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity')=1 then begin
                                         mr:=tstringlist.create;
                                         try
                                              msite.BaseObjectSpace.SQLSelect('select sum(quantity) from StoreSubBatches where StoreBatch_ID=' + QuotedStr(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID')) + ' and Store_ID='+ QuotedStr(mRow.GetFieldValueAsString('Store_ID')),mr);
                                            if mr.count>0 then begin
                                                mBO_MonikerInput.BusinessObject[ii].setFieldValueAsFloat('Quantity',(NxIBStrToFloat(mr.Strings[0]) + mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity')));
                                                mpocet:=mpocet + mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity');
                                            end;
                                         finally
                                             mr.free;
                                         end;
                                  end;
                           end;
        end;
        mrow.SetFieldValueAsFloat('Quantity', mpocet);
        mpocet:=0;
      end;


    abo.ClearValidateErrors;
    if Not abo.Validate() then begin
      mList := TStringList.Create;
      try
        abo.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        //MessageDlg('Automaticky vytvořenou objedn8vku nelze uložit z těchto důvodů:' + #13#10 + mText,
         // mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
       //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mOP);
       abo.save;
    end else begin
      //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mOP);
//      mOP.Save;
        abo.save;
      result := abo.OID;
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
        mID := NewOP(mObj,msite);
      end;
    finally
    end;
  end;
end;

 }

begin
end.