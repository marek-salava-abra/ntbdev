uses 'eu.obb.OP.ParseData', 'eu.obb.OP.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změna zaokrouhlení';
  mAction.Items.Add('Změna zaokrouhlení');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Změna zaokrouhlení';
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
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin

  try
    if true then begin
      try
        mList := TStringList.Create;
        TDynSiteForm(mSite).List.GetSelectedId(mList);
        j:=mList.Count;
        try
           ProgressInit(mSite, 'Zaokrouhluji...', j);
           for i := 0 to j - 1 do begin
           try
           mSMBO:=mos.CreateObject(Class_IssuedOffer);
           msmbo.Load(mList.strings[i],nil);
           mSMBO.SetFieldValueAsInteger('TotalRounding',257);
           mSMBO.save;
           mSMBO.free;
           except
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