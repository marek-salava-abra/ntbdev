uses 'eu.obb.mzdy.ParseData', 'eu.obb.mzdy.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import mezd';
  mAction.Items.Add('Stary import');
  mAction.Items.Add('Import VEMA');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID, mDivisionMDCode, mDivisionDCode:String;
 mNew:Boolean;
 mBO:TNxCustomBusinessObject;
 mGRows : TMultiGrid;
 {Neco,jmeno, prijmeni,cislo,text,castka,mds,mda,ds,da,nic,btmd,btd,smd,sd,mducet,ducet}
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
        mBO := TDynSiteForm(mSite).CurrentObject;
        mRows:=mbo.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
        mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import mezd...', j);
           for i := 0 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mRow:=mRows.AddNewObject;
            mRow.SetFieldValueAsString('DebitAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('mds').AsString,'"','',[srAll])+NxSearchReplace(mParRow.ParamByName('mda').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('CreditAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('ds').AsString,'"','',[srAll])+NxSearchReplace(mParRow.ParamByName('da').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('DebitDivision_ID',GetDivision_ID(mos,NxSearchReplace(mParRow.ParamByName('sd').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('CreditDivision_ID',GetDivision_ID(mos,NxSearchReplace(mParRow.ParamByName('sd').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('Text', NxSearchReplace(mParRow.ParamByName('Jmeno').AsString,'"','',[srAll])+' '+
            NxSearchReplace(mParRow.ParamByName('prijmeni').AsString,'"','',[srAll])+' '+
            NxSearchReplace(mParRow.ParamByName('Text').AsString,'"','',[srAll]));
            //if i<5 then NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('prijmeni').AsString,'"','',[srAll])+ ' '+ mParRow.ParamByName('prijmeni').AsString, mSite);
            mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mParRow.ParamByName('castka').asstring));
            mRow.SetFieldValueAsFloat('LocalTAmount',NxIBStrToFloat(mParRow.ParamByName('castka').asstring));
          end;
          ProgressDispose();
        finally
         if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
        end;
      finally
      end;
    end;
  finally
  end;
  end;
  if index=1 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
       try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData2(mlist);
        mBO := TDynSiteForm(mSite).CurrentObject;
        mRows:=mbo.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
        mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import mezd...', j);
           for i := 3 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mRow:=mRows.AddNewObject;
            mRow.SetFieldValueAsString('DebitAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('ucmd').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('CreditAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('ucdal').AsString,'"','',[srAll])));
            mDivisionMDCode:=AnsiLeftStr(NxSearchReplace(mParRow.ParamByName('naklm').AsString,'"','',[srAll])+'0',2);
            mRow.SetFieldValueAsString('DebitDivision_ID',GetDivision_ID(mos,mDivisionMDCode));
            mDivisionDCode:=AnsiLeftStr(NxSearchReplace(mParRow.ParamByName('nakld').AsString,'"','',[srAll])+'0',2);
            mRow.SetFieldValueAsString('CreditDivision_ID',GetDivision_ID(mos,mDivisionDCode));
            mRow.SetFieldValueAsString('Text', NxSearchReplace(mParRow.ParamByName('poznamka').AsString,'"','',[srAll]));
            mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mParRow.ParamByName('mdkcs').asstring));
            mRow.SetFieldValueAsFloat('LocalTAmount',NxIBStrToFloat(mParRow.ParamByName('mdkcs').asstring));
          end;
          ProgressDispose();
        finally
         if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
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