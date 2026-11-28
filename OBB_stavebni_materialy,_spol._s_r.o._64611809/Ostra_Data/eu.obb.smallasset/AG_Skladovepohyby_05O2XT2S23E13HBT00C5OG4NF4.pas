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
 mSMBO, mFirmBO, mHeader:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
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
           ProgressInit(mSite, 'Import cen...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));

            mSMBO:=mos.CreateObject(Class_ReceiptCardRow);
            msmbo.load(mParRow.ParamByName('ID').AsString,nil);
            mHeader:=mSMBO.GetMonikerForFieldCode(mSMBO.GetFieldCode('Parent_ID')).BusinessObject;
             mRows:=mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
             for k:=0 to mRows.count-1 do begin
               if mParRow.ParamByName('ID').AsString=mRows.BusinessObject[k].OID then mRows.BusinessObject[k].SetFieldValueAsFloat('UnitPrice',mParRow.ParamByName('Price').AsFloat);
             end;
            mheader.save;
            //mSMBO.save;
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