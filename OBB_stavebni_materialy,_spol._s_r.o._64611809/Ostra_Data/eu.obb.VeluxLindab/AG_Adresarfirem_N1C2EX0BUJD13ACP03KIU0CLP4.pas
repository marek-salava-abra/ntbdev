uses 'eu.obb.VeluxLindab.progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Velux/Lindab';
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
 mICO, mNumber, mFirm_ID:String;
 i, j:integer;
 mList:TStringList;
 mopenDLG:TOpenDialog;
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
        j:=mlist.count;
        try
           ProgressInit(mSite, 'Import Velux/Lindab...', j);
           for i := 1 to j - 1 do begin
           mICO:=NxTrapStr(mlist.strings[i],';');
           mNumber:=NxTrapStr(mlist.strings[i],';');
           mFirm_ID:=GetFirm_ID(mOS, mICO);
           if not(NxIsEmptyOID(mFirm_ID)) and (Length(mNumber)=13) then begin
             mBO:=mOS.CreateObject(Class_Firm);
             mBO.Load(mFirm_ID,nil);
             if NxIsBlank(mBO.GetFieldValueAsString('U_VeluxLindab')) then mBO.SetFieldValueAsString('U_VeluxLindab',mNumber);
             mbo.save;
             mbo.free;

           end;
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