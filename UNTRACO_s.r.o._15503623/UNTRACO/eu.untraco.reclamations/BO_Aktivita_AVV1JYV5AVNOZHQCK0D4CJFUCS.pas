const
  cRActivityType = '1000000101';

procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
  i: Integer;
  mBO: TNxCustomBusinessObject;
  mDts: TDataSet;
begin
  mDts:=TMemoryDataset.Create(nil);
  try
    Self.ObjectSpace.SQLSelect2(
      'select id,clsid from defrolldata where hidden = ''N'' and X_Activity_ID = '+QuotedStr(self.OID),mDts);

    while not mDts.Eof do begin
      mBO:=self.ObjectSpace.CreateObject(mDts.FieldByName('clsid').AsString);
      mBO.Load(mDts.FieldByName('id').AsString,nil);
      mBO.MarkForDelete;
      mBO.Save;
      mBO.Free;

      mDts.Next;
    end;
  finally
    mDts.Free;
  end;
end;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mOS: TNxCustomObjectSpace;
  mOldValue,mNewValue: String;
  mOldDate, mNewDate: TDateTime;
  mStatus, mOldStatus: Integer;
begin
  mOS:=self.ObjectSpace;
  if self.GetFieldValueAsString('ActivityType_ID') <> cRActivityType then exit;

  //////////////////////Změna stavu po určení řešitele///////////////////////////
  mNewValue:=self.GetFieldValueAsString('resolvedby_id');
  mStatus:=self.GetFieldValueAsInteger('status');

  if ((not NxIsEmptyOID(mNewValue)) and (mStatus = 0)) then begin
    mOldValue:=mOS.SQLSelectFirstAsString(
      'select resolvedby_id from crmActivities where id = '+QuotedStr(self.OID),'');

    if NxIsEmptyOID(mOldValue) then begin
      self.SetFieldValueAsInteger('status', 1);
    end;
  end;
  //-----------------------------------------------------------------------------

  ///////////////////////Změna data vyřešení reklamace///////////////////////////
  {if not (osNew in Self.State) then begin
    if mStatus = 2 then begin
      mOldStatus:=mOS.SQLSelectFirstAsInteger(
        'SELECT STATUS FROM crmActivities WHERE id = '+QuotedStr(self.OID),0);

      if mOldStatus < 2 then begin
        if self.GetFieldValueAsDateTime('RealEnd$DATE') = 0 then begin
          self.SetFieldValueAsDateTime('RealEnd$DATE', Now);
        end;
      end;
    end;
  end;}
  //-----------------------------------------------------------------------------


end;

begin
end.