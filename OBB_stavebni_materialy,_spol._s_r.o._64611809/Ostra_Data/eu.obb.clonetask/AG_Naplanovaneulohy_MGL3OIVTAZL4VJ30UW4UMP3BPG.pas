procedure InitSite_Hook(Self: TSiteForm);
var
  mBut: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

 mBut:= Self.GetNewAction;
 mBut.ShowControl := True;
 mBut.ShowMenuItem := True;
 mBut.Caption := 'Naklonuje úlohu';
 mBut.Category := 'tabList';
 mBut.OnExecute := @CloneTask;

end;

Procedure CloneTask(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO, mCloneBO:TNxCustomBusinessObject;
 mInt,i:integer;
begin
  mSite:=TComponent(sender).DynSite;
  mbo:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mbo) then begin
      mInt:=StrToInt(InputBox('Počet opakování','Zadej...','60',mSite));
      for i:=1 to mInt do begin
          try
            mCloneBO:=mbo.Clone;
            mCloneBO.SetFieldValueAsString('Code',mbo.GetFieldValueAsString('Code')+ AnsiRightStr('000'+IntToStr(i),3));
            mCloneBo.SetFieldValueAsDateTime('StartDateTime$Date',mbo.GetFieldValueAsDateTime('StartDateTime$Date')+(i*(1/6)*(1/24)));
            mCloneBO.save;
            mClonebo.Free;
          finally
          end;
      end;
     TDynSiteForm(mSite).RefreshData;
  end;
end;

begin
end.