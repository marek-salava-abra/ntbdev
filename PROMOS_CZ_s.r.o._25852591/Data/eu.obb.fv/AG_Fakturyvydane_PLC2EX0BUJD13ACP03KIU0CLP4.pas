uses 'eu.obb.fv.ParseData', 'eu.obb.fv.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import faktur';
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
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 {doklad','var_symbol','datum','zbyva_uhradit','mena','mena_zbyva','splatnost','ic','stredisko}
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
           ProgressInit(mSite, 'Import faktur...', j);
           for i := 0 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));

            mFirm_ID:=GetFirm_ID(mOS,mParRow.ParamByName('ic').AsString);
            if NxIsEmptyOID(mFirm_ID) then mFirm_ID:=GetFirm2_ID(mOS,mParRow.ParamByName('dic').AsString);
           if NxIsEmptyOID(mFirm_ID) then mFirm_id:='AAA1000000';
            mSMBO:=mos.CreateObject(Class_IssuedInvoice);
            msmbo.New;
            mSMBO.prefill;
            msmbo.SetFieldValueAsString('DocQueue_ID','2700000101');
            mSMBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
            mSMBO.SetFieldValueAsString('Period_ID','1000000101');
            mSMBO.SetFieldValueAsDateTime('DocDate$Date',mParRow.ParamByName('datum').AsDateTime);
            mSMBO.SetFieldValueAsDateTime('DueDate$Date',mParRow.ParamByName('splatnost').AsDateTime);
            msmbo.SetFieldValueAsString('Description',mParRow.ParamByName('doklad').AsString);
            msmbo.SetFieldValueAsString('VarSymbol',mParRow.ParamByName('var_symbol').AsString);
            msmbo.SetFieldValueAsBoolean('VatDocument',False);
            if not(NxIsBlank(mParRow.ParamByName('mena').AsString)) then begin
               if mParRow.ParamByName('mena').AsString='EUR' then begin
                  mSMBO.SetFieldValueAsString('Currency_ID','0000EUR000');
                  msmbo.SetFieldValueAsFloat('CurrRate',25.725);
               end;
               if mParRow.ParamByName('mena').AsString='PLN' then begin
                  mSMBO.SetFieldValueAsString('Currency_ID','0000PLN000');
                  msmbo.SetFieldValueAsFloat('CurrRate',6.126);
               end;
            end;
            mPLRows:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('Rows'));
            mPLRow:=mplrows.AddNewObject;
            mplrow.Prefill;
            mplrow.SetFieldValueAsInteger('RowType',1);
            mplrow.SetFieldValueAsString('Text', 'závazek');
            mplrow.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('mena_zbyva').AsString,' ','',[srall])));
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