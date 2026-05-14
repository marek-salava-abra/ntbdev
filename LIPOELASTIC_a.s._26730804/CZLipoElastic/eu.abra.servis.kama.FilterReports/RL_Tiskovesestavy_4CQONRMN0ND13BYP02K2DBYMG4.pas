var
  mUserChecked: Boolean;

procedure InFilter_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ARowCookie: integer; var aResult: Boolean);
var
  mUserCheck: Boolean;
  mBO: TNxCustomBusinessObject;
  mpart:Boolean;
  mname:string;
begin
  aResult := true;
  if not mUserChecked then
    mUserCheck := GetUserCheck(Self.ObjectSpace);
  if not(mUserCheck) then begin
   mBO := Self.Package.GetMoniker(ARowCookie).BusinessObject;
   mPart := false;

 //   mName := Self.Package.GetKeyByName('System', ARowCookie);
          //mPart := AParams.ParamAsBoolean('system', false);
          //aResult := (mPart=true);
          AResult := Pos('ALL', mBO.GetFieldValueAsString('Title'))<>0;
  end;
end;

{
Vyvolá se při vytváření DynSQL výrazu.
}
procedure _CreateDynSQLWhere_Hook(Self: TNxBusinessRoll; var aSQLFragment: string);
begin

end;

function GetUserCheck(AOS: TNxCustomObjectSpace): Boolean;
var
  mSQL: string;
  mStr: TStrings;
begin
  mUserChecked := false;
  mSQL := Format('Select X_print from SecurityUsers where ID=%s', [QuotedStr(NxGetActualUserID(AOS))]);
  mStr := TStringList.Create;
  try
    AOS.SQLSelect(mSQL, mStr);
          result:=NxStrToBool(mstr.Strings[0]);
  finally
    mStr.Free;
  end;
end;






begin
end.
