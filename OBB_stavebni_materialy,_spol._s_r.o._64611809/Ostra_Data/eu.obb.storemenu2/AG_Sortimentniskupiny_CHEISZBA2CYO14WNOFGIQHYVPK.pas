uses 'eu.obb.storemenu2.ParseData';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import Menu';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z Varicadu';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mlevel1, mlevel2, mlevel3, mLevel4, mLevel5, mParent_ID, mID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
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
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mlevel1:=mParRow.ParamByName('level1').AsString;
                mSMBO:=mos.CreateObject(Class_StoreAssortmentGroup);
                mSMBO.New;
                mSMBO.Prefill;
                mSMBO.SetFieldValueAsString('Code',AnsiLeftStr(mlevel1,20));
                mSMBO.SetFieldValueAsString('name',mlevel1);
                msmbo.Save;
                mSMBO.free;


             end;




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