procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actChangePosition';
  mAction.Caption := 'Změna pořadí ve větvi';
  mAction.Hint := 'Změní pořadí ve větvi';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ChangePos;
end;

procedure changePos(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i,j:integer;
 mOrdNumber:string;
 mBO, mChanBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
     mOs:=mbo.ObjectSpace;
     mOrdNumber:=InputBox('Zadejte údaje','Pořadí','',mSite);
     j:=Trunc(NxIBStrToFloat(mOrdNumber));
     if j>0 then begin
       if NxMessageBox('Dotaz','Přesunout skladové menu '+mbo.DisplayName+' na pozici '+mOrdNumber+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
          mList:=TStringList.create;
          mOS.SQLSelect('Select id from storemenu where not(id='+Quotedstr(mbo.oid)+') and parent_id='+QuotedStr(mBO.GetFieldValueAsString('Parent_ID'))+' and posindex>='+IntToStr(j)+' order by posindex ',mList);
          mbo.SetFieldValueAsInteger('Posindex',j);
          mbo.save;
          if mlist.Count>0 then begin
            for i:=0 to mlist.Count-1 do begin
              mChanBO:=mOS.CreateObject(Class_StoreMenuItem);
              mChanBO.Load(mlist.strings[i],nil);
              mChanBO.SetFieldValueAsInteger('PosIndex',j+1+i);
              mchanbo.save;
              mChanBO.free;
            end;
          end;
          TBusRollSiteForm(mSite).RefreshData;
          TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
       end;
     end;

  end;
end;

begin
end.