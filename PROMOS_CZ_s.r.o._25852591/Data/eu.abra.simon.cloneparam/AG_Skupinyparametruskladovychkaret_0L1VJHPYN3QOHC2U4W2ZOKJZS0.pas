procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCloneParam';
  mAction.Caption := 'Nakopíruje parametr';
  mAction.Hint := 'tlačítko zkopíruje parametr';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CloneParams;
end;

Procedure CloneParams(Sender:tcomponent);
var
 mSite:TSiteForm;
 i:integer;
 mList:TStringList;
 mBO, mCloneBO,mParamBO:TNxCustomBusinessObject;
 mName, mcode, mCloneBO_ID:string;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if assigned(mBO) then begin
   mName:=InputBox('Nový název '+mbo.GetFieldValueAsString('Name'),'Nový název:','',msite);
   mCode:=mOS.SQLSelectFirstAsString('Select max(code) from defrolldata where code like ''___'' and clsid=''OD4JP4GMMNRO5DTOIFTDVCLISC'' ','');
   mcode:=AnsiRightStr('000'+(IntToStr(StrToInt(AnsiRightStr(mCode,3))+1)),3);
   mCloneBO:=mBO.clone;
   mCloneBO.SetFieldValueAsString('Code',mCode);
   mCloneBO.SetFieldValueAsString('Name',mName);
   mCloneBO.save;
   mCloneBO_ID:=mCloneBO.OID;
   mCloneBO.Free;
   mList:=TStringList.Create;
   mOS.SQLSelect('Select id from defrolldata where X_Value_ID='+Quotedstr(mBO.OID)+' and clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' ',mList);
   if mlist.count>0 then begin
    for i:=0 to mList.count-1 do begin
      mParamBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
      mParamBO.load(mlist.strings[i],nil);
      mCloneBO:=mParamBO.Clone;
      mCloneBO.SetFieldValueAsString('X_Value_ID',mCloneBO_ID);
      mclonebo.save;
      mclonebo.free;
      mParamBO.free;
    end;
   end;
   TBusRollSiteForm(mSite).RefreshData;
   TBusRollSiteForm(msite).DataSet.SeekID(mCloneBO_ID);
 end;
end;

begin
end.