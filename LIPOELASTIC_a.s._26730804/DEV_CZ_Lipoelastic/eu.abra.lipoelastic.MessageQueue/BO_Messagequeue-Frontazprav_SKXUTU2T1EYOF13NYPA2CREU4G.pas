uses '.const';

{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
  mCode: String;
  mMaxNumber: Integer;
begin
  mCode := Self.ObjectSpace.SQLSelectFirstAsString('SELECT MAX(Code) FROM DefRollData WHERE ClsId = ' + QuotedStr(Class_MessageQueue),'');
  if mCode='' then begin
    mCode := 'MQ00000001';
  end else begin
    mMaxNumber := StrToIntDef(Copy(mCode, 3, Length(mCode) - 2), 0) + 1;
    mCode := 'MQ' + Format('%.8d', [mMaxNumber]);
  end;
  Self.SetFieldValueAsString('Code', mCode);
end;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if osNew in self.state then begin
    self.SetFieldValueAsDateTime('X_MQ_CreatedAt',Now);
  end else begin
    self.SetFieldValueAsDateTime('X_MQ_CorrectedAt',Now);
  end;
  if cMQ_BeautifyJSON then
    Self.SetFieldValueAsString('X_MQ_JSON', BeautifyJSON(Self.GetFieldValueAsString('X_MQ_JSON')));
end;

function BeautifyJSON(const aJSON: string): string;
var
  mI: Integer;
  mJ: Integer;
  mIndent: Integer;
  mChar: Char;
  mNextChar: Char;
  mInString: Boolean;
  mEscaped: Boolean;
  mResult: string;

  procedure AddIndent;
  var
    mK: Integer;
  begin
    for mK := 1 to mIndent do
      mResult := mResult + '  ';
  end;

  procedure AddNewLine;
  begin
    mResult := mResult + #13#10;
    AddIndent;
  end;

begin
  mResult := '';
  mIndent := 0;
  mInString := False;
  mEscaped := False;

  mI := 1;

  while mI <= Length(aJSON) do
  begin
    mChar := aJSON[mI];

    if mInString then
    begin
      mResult := mResult + mChar;

      if mEscaped then
        mEscaped := False
      else
      begin
        if mChar = '\' then
          mEscaped := True
        else if mChar = '"' then
          mInString := False;
      end;
    end
    else
    begin
      case mChar of
        '"':
          begin
            mInString := True;
            mResult := mResult + mChar;
          end;

        '{', '[':
          begin
            mResult := mResult + mChar;

            mJ := mI + 1;

            while (mJ <= Length(aJSON)) and
                  ((aJSON[mJ] = ' ') or
                   (aJSON[mJ] = #9) or
                   (aJSON[mJ] = #10) or
                   (aJSON[mJ] = #13)) do
              Inc(mJ);

            mNextChar := #0;

            if mJ <= Length(aJSON) then
              mNextChar := aJSON[mJ];

            if ((mChar = '{') and (mNextChar <> '}')) or
               ((mChar = '[') and (mNextChar <> ']')) then
            begin
              Inc(mIndent);
              AddNewLine;
            end;
          end;

        '}', ']':
          begin
            mJ := mI - 1;

            while (mJ >= 1) and
                  ((aJSON[mJ] = ' ') or
                   (aJSON[mJ] = #9) or
                   (aJSON[mJ] = #10) or
                   (aJSON[mJ] = #13)) do
              Dec(mJ);

            if (mJ >= 1) and
               (((mChar = '}') and (aJSON[mJ] = '{')) or
                ((mChar = ']') and (aJSON[mJ] = '['))) then
            begin
              mResult := mResult + mChar;
            end
            else
            begin
              Dec(mIndent);
              mResult := mResult + #13#10;
              AddIndent;
              mResult := mResult + mChar;
            end;
          end;

        ',':
          begin
            mResult := mResult + mChar;
            AddNewLine;
          end;

        ':':
          begin
            mResult := mResult + ': ';
          end;

        ' ', #9, #10, #13:
          begin
          end;

      else
        mResult := mResult + mChar;
      end;
    end;

    Inc(mI);
  end;

  Result := mResult;
end;



begin
end.
