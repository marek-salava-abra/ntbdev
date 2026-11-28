uses 'eu.obb.sc.ParseData', 'eu.obb.sc.Progress';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if NxGetActualUserID(self.BaseObjectSpace)='7000000101' then begin
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
end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO, mUnitBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID:String;
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
           ProgressInit(mSite, 'Import karet...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mSMBO:=mos.CreateObject(Class_StoreCard);
           mSMBO.New;
           mSMBO.Prefill;
           mSMBO.SetFieldValueAsString('Code',mParRow.ParamByName('cislo').AsString);
           mSMBO.SetFieldValueAsString('Name',mParRow.ParamByName('nazev').AsString);
           //mSMBO.SetFieldValueAsString('Note',mParRow.ParamByName('popis').AsString);
           //mSMBO.SetFieldValueAsString('X_Code',mParRow.ParamByName('puv_cislo').AsString);
           //mSMBO.SetFieldValueAsString('X_delivery_code',mParRow.ParamByName('obj_cis').AsString);
           mSMBO.SetFieldValueAsString('StoreCardCategory_ID','6000000101');
           mSMBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           //mSMBO.SetFieldValueAsString('StoreAssortmentGroup_ID',GetAssort_ID(mOS,mParRow.ParamByName('sortimen').AsString));
           //mSMBO.SetFieldValueAsString('Producer_ID',GetFirm_ID(mOS,mParRow.ParamByName('vyrobce').AsString));
           if not(NxIsBlank(mParRow.ParamByName('jednotka').AsString)) then begin
              mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsString('Code',mParRow.ParamByName('jednotka').AsString);
           end;
           mSMBO.save;
           mSMBO.free;

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