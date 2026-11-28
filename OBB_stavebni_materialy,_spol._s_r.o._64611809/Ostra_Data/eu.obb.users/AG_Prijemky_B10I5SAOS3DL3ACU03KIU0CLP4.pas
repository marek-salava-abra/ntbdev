uses 'eu.obb.users.ParseData', 'eu.obb.users.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import palet';
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
 mDLRows:TNxCustomBusinessMonikerCollection;
 mDLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 {ico','dic','adresa1','adresa2','adresa3','psc','adresa4','stat',
 'nazbanky','cisuctu','kodbanky','iban','bic','telefon','fax','mobil',
 'mail','www','predkont','sleva_proc','splatnost','prod_cena','tisk',
 'poznamka','skupina','limit_volb','limit_cena','stredisko','zakazka',
 'cinnost','varsymbol','dat_naroz','ico_faktur','id','datovka}
begin
 mSite:=TComponent(sender).DynSite;
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
           ProgressInit(mSite, 'Import dl...', j);
           for i := 0 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));

            //mFirm_ID:=GetFirm_ID(mOS,mParRow.ParamByName('ico').AsString);
            mSMBO:=mos.CreateObject(Class_ReceiptCard);
            msmbo.New;
            mSMBO.prefill;
            mSMBO.SetFieldValueAsDateTime('DocDate$Date',42733);
            mSMBO.SetFieldValueAsString('DocQueue_ID',Getdq_ID(mos,'PR'+mParRow.ParamByName('code').AsString));
            msmbo.SetFieldValueAsString('Firm_ID', 'AAA1000000');
            msmbo.SetFieldValueAsString('Period_ID','5000000101');
            mDLRows:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('Rows'));
            mDLRow:=mDLRows.AddNewObject;
            mDLRow.Prefill;
            mDLRow.SetFieldValueAsString('Store_ID',mParRow.ParamByName('Store_ID').AsString);
            mDLRow.SetFieldValueAsString('StoreCard_ID',mParRow.ParamByName('SC_ID').AsString);
            mDLRow.SetFieldValueAsFloat('Quantity',mParRow.ParamByName('quantity').AsFloat);
            mDLRow.SetFieldValueAsFloat('UnitPrice',0);
            mDLRow.SetFieldValueAsFloat('TotalPrice',0);
            mDLRow.SetFieldValueAsBoolean('CompletePrices',True);
            mDLRow.SetFieldValueAsString('Division_ID',GetDivision_ID(mos,mParRow.ParamByName('code').AsString));




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