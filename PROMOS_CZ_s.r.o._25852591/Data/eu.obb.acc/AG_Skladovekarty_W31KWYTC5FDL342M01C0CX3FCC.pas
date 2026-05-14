uses 'eu.obb.acc.ParseData', 'eu.obb.acc.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import účtů';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mSMMasterBO, mbankBO, mUnitBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mMaster_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 {'puv_cislo','nove_produktu','vyrobce','sortimen','nazev','popis','mj','dph','obj_cis'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import rozvrhu...', j);
           for i := 0 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mMaster_ID:=GetStoreCArd_ID(mOS,(mParRow.ParamByName('code').AsString));
           if not(NxIsEmptyOID(mMaster_ID)) then begin
             mSMMasterBO:=mos.CreateObject(Class_StoreCard);
             mSMMasterBO.Load(mMaster_ID,nil);
             mSMMasterBO.SetFieldValueAsString('Name', AnsiLeftStr(NxSearchReplace(mParRow.ParamByName('name').AsString,'#','"',[srall]),100));
             if mParRow.ParamByName('category').AsString='A' then mSMMasterBO.SetFieldValueAsString('StoreAssortmentGroup_ID','1000000101');
             if mParRow.ParamByName('category').AsString='B' then mSMMasterBO.SetFieldValueAsString('StoreAssortmentGroup_ID','1100000101');
             if mParRow.ParamByName('category').AsString='C' then mSMMasterBO.SetFieldValueAsString('StoreAssortmentGroup_ID','2100000101');
             mSMMasterBO.Save;
             mSMMasterBO.free;
           end else begin
            mSMMasterBO:=mos.CreateObject(Class_StoreCard);
            mSMMasterBO.new;
            mSMMasterBO.prefill;
            mSMMasterBO.SetFieldValueAsString('Code', mParRow.ParamByName('code').AsString);
            mSMMasterBO.SetFieldValueAsString('Name', AnsiLeftStr(NxSearchReplace(mParRow.ParamByName('name').AsString,'#','"',[srall]),100));
            if mParRow.ParamByName('category').AsString='A' then mSMMasterBO.SetFieldValueAsString('StoreAssortmentGroup_ID','1000000101');
            if mParRow.ParamByName('category').AsString='B' then mSMMasterBO.SetFieldValueAsString('StoreAssortmentGroup_ID','1100000101');
            if mParRow.ParamByName('category').AsString='C' then mSMMasterBO.SetFieldValueAsString('StoreAssortmentGroup_ID','2100000101');
            mSMMasterBO.SetFieldValueAsString('VatRate_ID','02100X0000');
            mSMMasterBO.SetFieldValueAsString('StoreCardCategory_ID','1000000101');
            mSMMasterBO.Save;
            mSMMasterBO.free;

           end;
           ProgressSetPos(i+1);
           end;



        finally
          ProgressDispose();

        end;
      finally
      end;
    end;
  finally
  end;
  end;

end;
begin
end.