// Pomocná funkce pro vytažení textových parametrů z binárních dat
function ExtractParameters(const Bytes: TBytes): TStringList;
var
  i: Integer;
  CurrentStr: string;
  B: Byte;
begin
  Result := TStringList.Create;
  CurrentStr := '';

  for i := 0 to Length(Bytes) - 1 do
  begin
    B := Bytes[i];
    // Sledujeme tisknutelné ASCII znaky (písmena, čísla, speciální znaky)
    if (B >= 32) and (B <= 126) then
    begin
      CurrentStr := CurrentStr + Chr(B);
    end
    else
    begin
      // Jakmile narazíme na ne-tisknutelný znak, uložíme nasbíraný řetězec
      if Length(CurrentStr) >= 2 then
        Result.Add(CurrentStr);
      CurrentStr := '';
    end;
  end;

  // Přidání případného zbytku na konci pole
  if Length(CurrentStr) >= 2 then
    Result.Add(CurrentStr);
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actShow';
  mAction.Caption := '## Ukaž ##';
  mAction.Hint := 'Show me how to';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ShowNotes;
end;

procedure ShowNotes(Sender: TComponent);
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  EncodedStr: string;
  DecodedBytes: TBytes;
  Params: TStringList;
  i: Integer;
  ParamText: string;
begin
  mSite := TComponent(Sender).DynSite;
  mBO := TDynSiteForm(mSite).CurrentObject;

  if Assigned(mBO) then begin
    EncodedStr := mBO.GetFieldValueAsString('TaskParameters');

    if EncodedStr <> '' then begin
      DecodedBytes := DecodeBase64(EncodedStr);
      Params := ExtractParameters(DecodedBytes);
      try
        ParamText := '';
        for i := 0 to Params.Count - 1 do
        begin
          ParamText := ParamText + 'Param ' + IntToStr(i + 1) + ': ' + Params[i] + #13#10;
        end;

        NxShowSimpleMessage(ParamText, mSite);
      finally
        Params.Free;
      end;
    end;
  end;
end;

begin
end.