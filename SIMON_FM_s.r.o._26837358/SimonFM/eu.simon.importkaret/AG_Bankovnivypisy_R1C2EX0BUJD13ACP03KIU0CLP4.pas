uses 'eu.simon.importkaret.ParseData', 'eu.simon.importkaret.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import karet';
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
 mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mVarSymbol:String;
 {'puv_cislo','nove_produktu','vyrobce','sortimen','nazev','popis','mj','dph','obj_cis'}
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
  mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
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
          // ProgressInit(mSite, 'Import karet...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            if Nxibstrtofloat(mParRow.ParamByName('Castka_brutto').AsString)>0 then begin
             mRow:=mRows.AddNewObject;
             mRow.prefill;
             mRow.SetFieldValueAsBoolean('Credit',true);
             mRow.SetFieldValueAsFloat('Amount',Nxibstrtofloat(mParRow.ParamByName('Castka_brutto').AsString));
             mRow.SetFieldValueAsString('Division_ID','1400000101');
             mVarSymbol:=GetVSOI(mOS, mParRow.ParamByName('Autorizacni_kod').AsString);
             if NxIsBlank(mVarSymbol) then mVarSymbol:=GetVS(mOS,mParRow.ParamByName('Variabilni_symbol').AsString);
             mRow.SetFieldValueAsString('VarSymbol',mVarSymbol);
            end;
            if Nxibstrtofloat(mParRow.ParamByName('Vyse_poplatku').AsString)>0 then begin
             mRow:=mRows.AddNewObject;
             mRow.prefill;
             mRow.SetFieldValueAsBoolean('Credit',false);
             mRow.SetFieldValueAsFloat('Amount',Nxibstrtofloat(mParRow.ParamByName('Vyse_poplatku').AsString));
             mRow.SetFieldValueAsString('Division_ID','1400000101');
             mrow.SetFieldValueAsString('AccPresetDef_ID','3E00000101');
            end;

          // ProgressSetPos(i+1);
           end;



        finally
          //ProgressDispose();
        mbo.Save;
        NxShowSimpleMessage('Naimportováno',mSite);
        end;
      finally
       TDynSiteForm(mSite).CurrentObject.Refresh;
      end;
    end;
  finally
  end;
  end;
end;
end;
begin
end.
