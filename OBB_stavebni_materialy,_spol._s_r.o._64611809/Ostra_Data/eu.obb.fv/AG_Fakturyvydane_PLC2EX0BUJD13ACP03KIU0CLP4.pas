uses 'eu.obb.fv.ParseData', 'eu.obb.fv.Progress';

{procedure FormCreate_Hook(Self: TSiteForm);
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

end;      }

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
            {'doklad','varsymbol','firm_ID','IC','castka','castkabez','mena','docdate','duedate','Division'}
            mFirm_ID:=mParRow.ParamByName('firm_ID').AsString;
           if NxIsEmptyOID(mFirm_ID) then mFirm_id:='AAA1000000';
            mSMBO:=mos.CreateObject(Class_IssuedInvoice);
            msmbo.New;
            mSMBO.prefill;
            msmbo.SetFieldValueAsString('DocQueue_ID','1F00000101');
            mSMBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
            mSMBO.SetFieldValueAsString('Period_ID',GetPeriod_ID(mos,AnsiRightStr(mParRow.ParamByName('docdate').AsString,4)));
            mSMBO.SetFieldValueAsDateTime('DocDate$Date',mParRow.ParamByName('docdate').AsDateTime);
            mSMBO.SetFieldValueAsDateTime('DueDate$Date',mParRow.ParamByName('duedate').AsDateTime);
            msmbo.SetFieldValueAsString('Description',mParRow.ParamByName('doklad').AsString);
            msmbo.SetFieldValueAsString('VarSymbol',mParRow.ParamByName('varsymbol').AsString);
            msmbo.SetFieldValueAsBoolean('VatDocument',true);
            if not(NxIsBlank(mParRow.ParamByName('mena').AsString)) then begin
               if mParRow.ParamByName('mena').AsString='EUR' then begin
                  mSMBO.SetFieldValueAsString('Currency_ID','0000EUR000');
                  msmbo.SetFieldValueAsFloat('CurrRate',27.02);
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
            mplrow.SetFieldValueAsFloat('totalprice',mParRow.ParamByName('castkabez').Asfloat);
            mplrow.SetFieldValueAsString('VatRate_ID','02100X0000');
            if not(mSMBO.GetFieldValueAsString('Currency_ID')='0000CZK000') then begin
            mplrow.SetFieldValueAsFloat('totalprice',mParRow.ParamByName('castka').Asfloat);
            mplrow.SetFieldValueAsString('VatRate_ID','00000X0000');


            end;
            mplrow.SetFieldValueAsString('Division_ID',mParRow.ParamByName('Division').AsString);
            mplrow.SetFieldValueAsString('BusTransaction_ID', mParRow.ParamByName('BT').AsString);
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