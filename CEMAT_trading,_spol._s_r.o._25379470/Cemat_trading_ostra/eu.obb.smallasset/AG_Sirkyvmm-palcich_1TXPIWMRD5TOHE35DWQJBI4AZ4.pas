uses 'eu.obb.smallasset.ParseData', 'eu.obb.smallasset.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import majetku';
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
 mSMBO, mFirmBO, mbankBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList, mSqlList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mStoreCard_ID, mStoreCard2_ID:String;
 {'Code','name','Vnum','store','pujc','op','popis','nosnost','rozevreni','sirkaramu','hcg','hmotnost','konpl','ISO','stav','pc','dp','note'}
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
           ProgressInit(mSite, 'Import montáže...', j);
           for i := 0 to j - 1 do begin
            mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mSMBO:=mos.CreateObject('VWVHJ3QCG1T4VDU20DDRJ15IBS');
            msmbo.new;
            msmbo.SetFieldValueAsString('code',mParRow.ParamByName('Name').AsString);
            if NxIBStrToFloat(mParRow.ParamByName('Name').AsString)>100 then
            mSMBO.SetFieldValueAsString('Name','Šířka '+mParRow.ParamByName('Name').AsString+'mm')
            else mSMBO.SetFieldValueAsString('Name','Šířka '+mParRow.ParamByName('Name').AsString+'"');
            mSMBO.save;
            msmbo.Free;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally


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