function NewDL(ABO: TNxCustomBusinessObject;mSite: TDynSiteForm): string;
var
  mDL: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
  mchyb:integer;
begin
  mchyb:=0;
  result := '';
  mDL := TDynSiteForm(msite).CurrentObject;
  try
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMonInput := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));
      for i := 0 to mMoninput.Count-1 do begin
        mRow := mMonInput.BusinessObject[i];
          if mRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
              mBO_MonikerInput:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                 for ii:=0 to mBO_MonikerInput.Count-1 do begin
                                             mdocrowbatches:=mBO_MonikerInput.BusinessObject[ii];
                                                    // mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID'));
                                                     mr:= TStringList.create;
                                                     try
                                                         TDynSiteForm(msite).BaseObjectSpace.SQLSelect('select count(DRB.id) from DocRowBatches DRB left join Storedocuments2 SD2 on sd2.id=DRB.parent_ID where sd2.parent_id=' + QuotedStr(mDL.oid) + ' and drb.StoreBatch_ID=' + quotedstr(mdocrowbatches.getFieldValueAsstring('StoreBatch_ID')) ,mr);
                                                         if StrToInt(mr.Strings(0))>1 then begin
                                                            NxShowSimpleMessage('Šarže ' + mdocrowbatches.getFieldValueAsstring('StoreBatch_ID.name') + ' pro skladovou kartu ' + mRow.getFieldValueAsstring('StoreCard_ID.name')  + ' je v dokladu použita ' + mr.Strings(0)  + 'x.',
                                                            nil);
                                                            mchyb:=mchyb+1;
                                                         end;

                                                     finally
                                                         mr.free;
                                                     end;
                 end;
        end;
      end;

 if mchyb=0 then  NxShowSimpleMessage('Na dokladu nejsou duplicitní šarže',nil) else  NxShowSimpleMessage('Na dokladu je ' + inttostr(mchyb) + ' duplicitních záznamů šarže',nil)
  finally
    mDL.Free;
  end;
end;

procedure NewDLExecute(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewDL(mObj,msite);
      end;
    finally
    end;
  end;
end;



procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Kontrola šarží';
  mAction.Hint := 'Kontrola duplicity šarží';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @NewDLExecute;

end;

begin
end.