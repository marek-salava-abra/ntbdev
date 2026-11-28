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
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           if Length(mParRow.ParamByName('ucet').AsString)>3 then begin
           mSMBO:=mos.CreateObject(Class_Account);
           mSMBO.New;
           mSMBO.Prefill;
           mSMBO.SetFieldValueAsString('Code',mParRow.ParamByName('ucet').AsString);
           mSMBO.SetFieldValueAsString('Name',mParRow.ParamByName('nazev').AsString);
           mMaster_ID:=GetAccount_ID(mOS,AnsiLeftStr(mParRow.ParamByName('ucet').AsString,3));
           if not(NxIsEmptyOID(mMaster_ID)) then begin
           mSMMasterBO:=mos.CreateObject(Class_Account);
           mSMMasterBO.load(mMaster_ID,nil);
           msmbo.SetFieldValueAsString('AccountType',mSMMasterBO.GetFieldValueAsString('AccountType'));
           msmbo.SetFieldValueAsBoolean('Short',mSMMasterBO.GetFieldValueAsBoolean('Short'));
           msmbo.SetFieldValueAsBoolean('Taxable',mSMMasterBO.GetFieldValueAsBoolean('Taxable'));
           mSMMasterBO.Free;
           end;

           mSMBO.save;
           mSMBO.free;
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