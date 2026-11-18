function IsSupervisor(AObjectSpace: TNxCustomObjectSpace): Boolean;
const
  cSQL = 'SELECT surl.user_id FROM SECURITYPRIVILEGERIGHTS spr inner join SECURITYUSERROLELINKS surl on surl.role_id=spr.role_id where spr.classid=''G1TDNZSKTVCL33N2010DELDFKK''';
var
  mSupervisors: TStringList;
  mCurrentUser: String;
begin
  mCurrentUser := NxGetActualUserID(AObjectSpace);
  mSupervisors := TStringList.Create;
  try
    AObjectSpace.SQLSelect(cSQL, mSupervisors);
    Result := mSupervisors.IndexOf(mCurrentUser) >= 0;
  finally
    mSupervisors.Free;
  end;
end;

function CheckLicenceDate(AOrgIdentNumber: String; ADate: TDate = 0): Boolean;
begin
  Result := True;
  if ADate > 0 then begin
    if ADate < Date then begin
      Result := False;
      ShowMessage('Licence na skript vypršela ' + DateToStr(ADate));
    end;
  end;
end;

function CheckLicenceFirm(AOrgIdentNumber: String; AContext: TNxContext): Boolean;
begin
  Result := (AOrgIdentNumber = AContext.GetCompanyCache.OrgIdentNumber);
end;

function GetCurrentObjects(ASite: TSiteForm; AIDs: TStrings): Boolean;
begin
  AIDs.Clear;
  ASite.List.GetSelectedId(AIDs);
  Result := AIDs.Count > 0;
end;

function GetCurrentObject(ASite: TSiteForm; var ACurrentObject: TNxCustomBusinessObject): Boolean;
begin
  Result := true;
  if ASite is TBusRollSiteForm then
    ACurrentObject := TBusRollSiteForm(ASite).CurrentObject
  else
    if ASite is TDynSiteForm then
      ACurrentObject := TDynSiteForm(ASite).CurrentObject
    else
      Result := False;
end;

function GetSiteFromControl(AControl: TControl; var ASite: TSiteForm): Boolean;
begin
  ASite := AControl.Site;
  Result := Assigned(ASite);
end;

procedure AddButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; ACaption, AHint, ACategory: String; AOnExecute: Pointer);
var
  mAction: TAction;
begin
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
  end;
end;

function GetFirstSQLResult(ASQL: String; AObjectSpace: TNxCustomObjectSpace; ADefaultValue: String = ''): String;
var
  mStrings: TStringList;
begin
  mStrings := TStringList.Create;
  try
    AObjectSpace.SQLSelect(ASQL, mStrings);
    if mStrings.Count > 0 then begin
      Result := mStrings.Strings[0];
    end else begin
      Result := ADefaultValue;
    end;
  finally
    mStrings.Free;
  end;
end;

function GetFirstSQLResultAsVariant(ASQL: String; AObjectSpace: TNxCustomObjectSpace; ADefaultValue: Variant = Null): Variant;
var
  mData: TMemoryDataset;
begin
  mData := TMemoryDataset.Create(nil);
  try
    AObjectSpace.SQLSelect2(ASQL, mData);
    if mData.Eof then begin
      Result := ADefaultValue;
    end else begin
      mData.First;
      mData.Fields[0].AsVariant;
    end;
  finally
    mData.Free;
  end;
end;


begin
end.