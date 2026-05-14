procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'Hromadné generování pracovníků';
    mBut.Hint := 'Vygeneruje z označených záznamů pracovníky do výroby';
    mBut.Category := 'tabList';
    mBut.OnExecute := @GenerateWorker;


end;

procedure GenerateWorker (Sender:TComponent);
var
 mSite:TSiteForm;
 mWorkingRelation, mWorker:TNxCustomBusinessObject;
 i: integer;
 mWRList, mWorkerList:TStringList;
 mOS:TNxCustomObjectSpace;

begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mWRList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mWRList);
 for i:=0 to mWRList.Count-1 do begin
    mWorkingRelation:=mos.CreateObject(Class_WorkingRelation);
    mWorkingRelation.load(mWRList.strings[i],nil);
    mWorkerList:=TStringList.Create;
    mOS.SQLSelect(Format('select id from plmworkers where person_id=''%'' ',[mWorkingRelation.GetFieldValueAsString('Employee_ID.Person_id')]),mWorkerList);
     if mWorkerList.count=0 then begin
        mWorker:=mos.CreateObject(Class_PLMWorker);
        mWorker.New;
        mWorker.prefill;
        mWorker.SetFieldValueAsString('Person_ID',mWorkingRelation.GetFieldValueAsString('Employee_ID.Person_id'));
        mWorker.SetFieldValueAsString('Division_ID',mWorkingRelation.GetFieldValueAsString('Division_ID'));
        mWorker.SetFieldValueAsString('SalaryClass_ID','1000000101');
        mWorker.Save;
        mWorker.Free;
     end;
    mWorkerList.free;
    mWorkingRelation.Free;
 end;

end;

begin
end.