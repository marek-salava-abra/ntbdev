function GenIntEAN(ABO : TNxCustomBusinessObject; APrefix : String) : string;
var
  mContext: TNxContext;
  mList: TStrings;
  mSQLSelect : string;
  mEAN : string;
  mEANPrefix : string;
  mNumEAN : Longint;
  mEANLen : integer;
const
  cSQL =  'select max(cast(ib_string_left(ean, 12) as varchar(12)) ) from StoreUnits where ean like ''%s___________'' ';
begin
  Result := '';
    mSQLSelect := Format(cSQL, [APrefix]);
    mList := TStringList.Create;
    try
      mContext := NxCreateContext_1(ABO);
      try
        mContext.SQLSelect(mSQLSelect, mList);
      finally
        mContext.Free;
      end;
      if (mList.Count > 0) then begin
        mEAN := mList.Strings[0];
        mEAN := Trim(mEAN);
        mEANPrefix := NxLeft(mEAN, 6);
        mEANLen := Length(mEAN);
        mEAN := NxRight(mEAN, mEANLen - 6);
        mNumEAN := StrToInt(mEAN);
        mNumEAN := mNumEAN + 1;
        mEAN := IntToStr(mNumEAN);
        mEAN := NxPadL(mEAN, mEANLen - 6, '0');
        mEAN := mEANPrefix + mEAN;
        NxCorrectEAN13(mEAN);
        Result := mEAN;
      end;
    finally
      mList.Free;
    end;
end;







{procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Generuj EAN';
  mAction.Hint := 'Vygeneruje EAN';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportOnExecute;
  mAction.OnUpdate := @ImportOnUpdate;

mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Zadej / ulož EAN';
  mAction.Hint := 'Zadej / ulož EAN';
  mAction.Category := 'tabList';
  mAction.OnExecute := @EditOnExecute;
  mAction.OnUpdate := @EditOnUpdate;
end;
          }



procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;


procedure EditOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ImportOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mBO : TNxCustomBusinessObject;
  mMainUnitCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;
  i : integer;
  mUnit : TNxCustomBusinessObject;
  mEAN : string;
  mi:integer;
begin
  if Sender is TComponent then begin
    //mSite := NxFindSiteForm(TComponent(Sender));
    mSite := TComponent(Sender).DynSite;
    mBO := TDynSiteForm(mSite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');

    try
          mBO.Load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Storecard_id'), nil);
          //NxShowSimpleMessage(mbo.GetFieldValueAsString('name'),nil);
      //     mBO := TBusRollSiteForm(mSite).CurrentObject;

        //if NxIsBlank(mBO.GetFieldValueAsString('EAN')) then begin
          mMainUnitCode := mBO.GetFieldValueAsString('MainUnitCode');
          mEAN := GenIntEAN(mBO, '21');
          mUnits := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
          for i := 0 to mUnits.count - 1 do begin
            mUnit := mUnits.BusinessObject[i];
            if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
              mEAN := GenIntEAN(mBO, '21');
              mUnit.SetFieldValueAsString('EAN', mEAN);
              mUnit.save;
            end;
          end;
          //mbo.SetFieldValueAsString('EAN', mEAN);
          //mBO.Save;
          mi:= msite.BaseObjectSpace.SQLExecute(format('update storeunits set ean=%s where code=%s and Parent_ID=%s',[quotedstr(mEAN),quotedstr(mbo.GetFieldValueAsString('MainUnitCode')),quotedstr(mbo.oid)]
          ));
          mi:= msite.BaseObjectSpace.SQLExecute(format('update storecards set ean=%s where id=%s',[quotedstr(mEAN),quotedstr(mbo.oid)]));
          //NxShowSimpleMessage(mbo.GetFieldValueAsString('name') + ' - ' + mEan,nil);
          mBO.Refresh;
         //end;
    finally
       mbo.free;
    end;




  end;
  mSite.Refresh;
end;


procedure EditOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mBO : TNxCustomBusinessObject;
  mMainUnitCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;
  i : integer;
  mUnit : TNxCustomBusinessObject;
  mEAN : string;
  mi:integer;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mBO := TDynSiteForm(mSite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');

    try
          mBO.Load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Storecard_id'), nil);
          //NxShowSimpleMessage(mbo.GetFieldValueAsString('name'),nil);
             //     mBO := TDynSiteForm(mSite).CurrentObject;
          //    mBO := TDynSiteForm(mSite).CurrentObject.Clone;

            //if NxIsBlank(mBO.GetFieldValueAsString('EAN')) then begin
              mEAN:='';
                  mEAN := InputBox('Zadání', 'Zadej EAN',mEAN);

              mMainUnitCode := mBO.GetFieldValueAsString('MainUnitCode');

              mUnits := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));

              for i := 0 to mUnits.count - 1 do begin
                mUnit := mUnits.BusinessObject[i];
                if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
                  mUnit.SetFieldValueAsString('EAN', mEAN);
                  munit.Save
                end;

              //end;
          mi:= msite.BaseObjectSpace.SQLExecute(format('update storeunits set ean=%s where code=%s and Parent_ID=%s',[quotedstr(mEAN),quotedstr(mbo.GetFieldValueAsString('MainUnitCode')),quotedstr(mbo.oid)]
          ));
          mi:= msite.BaseObjectSpace.SQLExecute(format('update storecards set ean=%s where id=%s',[quotedstr(mEAN),quotedstr(mbo.oid)]));
              //NxShowSimpleMessage(mbo.GetFieldValueAsString('name') + ' - ' + mEan,nil);
              //mbo.Refresh;
            end;
   finally
       mbo.free;
   end;

  end;
  mSite.Refresh;
end;




begin
end.