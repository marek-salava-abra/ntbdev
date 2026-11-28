
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mUserXLink:TNxCustomBusinessObject;
 mID_Old, mDescription:string;
begin
  if osNew in self.State then begin
    mID_Old:='';
    mDescription:='';
    if GlobParams.ParamExist('mid_old') then
      mid_old:=GlobParams.ParamByName('mid_old').AsString;
    if GlobParams.ParamExist('Description') then
      mDescription:=GlobParams.ParamByName('Description').AsString;
    if GlobParams.ParamExist('NoReason') then
      GlobParams.GetOrCreateParam(dtBoolean,'NoReason').AsBoolean:=False;
    if CFxOID.IsEmptyOrFull(mID_OLD) then exit else begin
      mUserXLink := self.ObjectSpace.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', self.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Destination_ID', mID_OLD);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description', mDescription);
        mUserXLink.Save;
      finally
       mUserXLink.free;
       GlobParams.ParamByName('mid_old').Clear;
       GlobParams.ParamByName('Description').Clear;
      end;
    end;
  end;
  GlobParams.Clear;
end;

begin
end.