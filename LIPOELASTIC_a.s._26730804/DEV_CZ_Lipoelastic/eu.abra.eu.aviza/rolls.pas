////////////////////////////////////
//        SCRIPT Rolls            //
////////////////////////////////////
function RollFind(AContext: TNxContext; ARoll: TNxCustomRoll; const ATextField: String; const AText: Variant; var AID: String; AFilter: TStrings=nil): Boolean;
var
  mRollParams: TNxParameters;
  i: Integer;
begin
  mRollParams := TNxParameters.Create;
  try
    mRollParams.NewFromDataType(dtBoolean, '_ForcedField', pkInput).AsBoolean := True; //DoNotLocalize
    mRollParams.NewFromDataType(dtString, '_Text', pkInputOutput).AsVariant:= AText; //DoNotLocalize
    mRollParams.NewFromDataType(dtString, '_TextField', pkInput).AsString := ATextField; //DoNotLocalize
    if Assigned(AFilter) then begin
      for i := 0 to AFilter.Count - 1 do begin
        mRollParams.NewFromDataType(dtString, AFilter.Names[i], pkInput).AsString := AFilter.ValueFromIndex[i];
      end;
    end;
    mRollParams.GetOrCreateParam(dtString, '_ID', pkInputOutput).AsString := AID;
    Result := ARoll.Validate(AContext, vkCheckOnly, mRollParams, pmNone);
    if Result then
      AID := mRollParams.ParamByName('_ID').AsString;
  finally
    mRollParams.Free;
  end;
end;

function GetRoll(ABO: TNxCustomBusinessObject; AFieldName: String): TNxCustomRoll;
var
  mCode: Integer;
begin
  mCode := ABO.GetFieldCode(AFieldName);
  Result := NxCreateRoll_1(mCode, ABO);
end;

function SetFieldFromRoll(AContext: TNxContext; ABO: TNxCustomBusinessObject; const ABOFieldName: String; const ATextField: String; const AText: Variant; AFilter: TStrings=nil): Boolean;
var
  mRoll: TNxCustomRoll;
  mID: String;
begin
  mRoll := GetRoll(ABO, ABOFieldName);
  Result := RollFind(AContext, mRoll, ATextField, AText, mID, AFilter);
  if Result then begin
    ABO.SetFieldValueAsString(ABOFieldName, mID);
  end;
end;

///////////////////////////////////////
//             OLE ROLLs             //
///////////////////////////////////////
function FindByRollCLSIDAndCode(ACZOLE: Variant; ARollCLSID, ACode: String; AFilter: String = ''): String;
begin
  Result := FindByRoll(ACZOLE, ARollCLSID, 'Code', ACode, AFilter);
end;

function FindByRoll(ACZOLE: Variant; ARollCLSID, AFieldName: String; AValue: Variant; AFilter: String = ''): String;
var
  mRoll: Variant;
begin
  mRoll := GetRemoteRoll(ACZOLE, ARollCLSID);
  if AFilter <> '' then begin
    mRoll.Params.Text := AFilter;
  end;
  Result := mRoll.Find2(AFieldName, AValue, '0000000000');
  mRoll := nil;
end;

function FindByCode(ARoll: Variant; ACode: String): String;
begin
  Result := ARoll.Find2('Code', ACode, '0000000000');
end;

function GetRemoteRoll(ACZOLE: Variant; ACLSID: String): Variant;
begin
  Result := ACZOLE.GetRoll(ACLSID, 0);
end;

begin
end.