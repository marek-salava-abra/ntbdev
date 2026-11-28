uses 'eu.obb.storemenu.ParseData';

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
           for i := 0 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mlevel1:=mParRow.ParamByName('level1').AsString;
           mlevel2:=mParRow.ParamByName('level2').AsString;
           mlevel3:=mParRow.ParamByName('level3').AsString;
           mlevel4:=mParRow.ParamByName('level4').AsString;
           mlevel5:=mParRow.ParamByName('level5').AsString;
           if not(NxIsBlank(mlevel1)) and NxIsBlank(mlevel2) and NxIsBlank(mlevel3) and nxisblank(mlevel4) and NxIsBlank(mLevel5) then begin
             mID:=Getlevel0_ID(mOS,mlevel1);
             if NxIsEmptyOID(mID) then begin
                mSMBO:=mos.CreateObject(Class_StoreMenuItem);
                mSMBO.New;
                mSMBO.Prefill;
                mSMBO.SetFieldValueAsString('Text',AnsiLeftStr(mlevel1,30));
                mSMBO.SetFieldValueAsInteger('PosIndex',i);
                msmbo.Save;
                mSMBO.free;


             end;
           end;
           if not(NxIsBlank(mlevel1)) and not(NxIsBlank(mlevel2)) and NxIsBlank(mlevel3) and nxisblank(mlevel4) and NxIsBlank(mLevel5) then begin
             mParent_ID:=Getlevel0_ID(mOS,mlevel1);
             mID:=Getlevelx_ID(mOS,mlevel2, mParent_ID);
             if NxIsEmptyOID(mID) then begin
                mSMBO:=mos.CreateObject(Class_StoreMenuItem);
                mSMBO.New;
                mSMBO.Prefill;
                mSMBO.SetFieldValueAsString('Text',AnsiLeftStr(mlevel2,30));
                mSMBO.SetFieldValueAsString('Parent_ID',mParent_ID);
                mSMBO.SetFieldValueAsInteger('PosIndex',i);
                msmbo.Save;
                mSMBO.free;


             end;
           end;
           if  not(NxIsBlank(mlevel1)) and not(NxIsBlank(mlevel2)) and not(NxIsBlank(mlevel3)) and nxisblank(mlevel4) and NxIsBlank(mLevel5) then begin
             mParent_ID:=Getlevel0_ID(mOS,mlevel1);
             mParent_ID:=Getlevelx_ID(mOS,mlevel2, mParent_ID);
             mID:=Getlevelx_ID(mOS,mlevel3, mParent_ID);
             if NxIsEmptyOID(mID) then begin
                mSMBO:=mos.CreateObject(Class_StoreMenuItem);
                mSMBO.New;
                mSMBO.Prefill;
                mSMBO.SetFieldValueAsString('Text',AnsiLeftStr(mlevel3,30));
                mSMBO.SetFieldValueAsString('Parent_ID',mParent_ID);
                mSMBO.SetFieldValueAsInteger('PosIndex',i);
                msmbo.Save;
                mSMBO.free;


             end;
           end;
           if  not(NxIsBlank(mlevel1)) and not(NxIsBlank(mlevel2)) and not(NxIsBlank(mlevel3)) and not(nxisblank(mlevel4)) and NxIsBlank(mLevel5) then begin
             mParent_ID:=Getlevel0_ID(mOS,mlevel1);
             mParent_ID:=Getlevelx_ID(mOS,mlevel2, mParent_ID);
             mParent_ID:=Getlevelx_ID(mOS,mlevel3, mParent_ID);
             mID:=Getlevelx_ID(mOS,mlevel4, mParent_ID);
             if NxIsEmptyOID(mID) then begin
                mSMBO:=mos.CreateObject(Class_StoreMenuItem);
                mSMBO.New;
                mSMBO.Prefill;
                mSMBO.SetFieldValueAsString('Text',AnsiLeftStr(mlevel4,30));
                mSMBO.SetFieldValueAsString('Parent_ID',mParent_ID);
                mSMBO.SetFieldValueAsInteger('PosIndex',i);
                msmbo.Save;
                mSMBO.free;


             end;
           end;
           if  not(NxIsBlank(mlevel1)) and not(NxIsBlank(mlevel2)) and not(NxIsBlank(mlevel3)) and not(nxisblank(mlevel4)) and not(NxIsBlank(mLevel5)) then begin
             mParent_ID:=Getlevel0_ID(mOS,mlevel1);
             mParent_ID:=Getlevelx_ID(mOS,mlevel2, mParent_ID);
             mParent_ID:=Getlevelx_ID(mOS,mlevel3, mParent_ID);
             mParent_ID:=Getlevelx_ID(mOS,mlevel4, mParent_ID);
             mID:=Getlevelx_ID(mOS,mlevel5, mParent_ID);
             if NxIsEmptyOID(mID) then begin
                mSMBO:=mos.CreateObject(Class_StoreMenuItem);
                mSMBO.New;
                mSMBO.Prefill;
                mSMBO.SetFieldValueAsString('Text',AnsiLeftStr(mlevel5,30));
                mSMBO.SetFieldValueAsString('Parent_ID',mParent_ID);
                mSMBO.SetFieldValueAsInteger('PosIndex',i);
                msmbo.Save;
                mSMBO.free;


             end;
           end;


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