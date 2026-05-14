uses 'eu.dotykacka.fce', 'eu.dotykacka.form';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actDotykacka';
  mAction.Caption := 'Dotykačka';
  mAction.Hint := 'Import dat z Dotykačky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportDotykacka;
end;

Procedure ImportDotykacka(Sender:TComponent);
var
 mSite:TSiteForm;
 mURL, mStatusText,mETag:string;
 mJSON:TJSONSuperObject;
 mStatusCode, i:integer;
 mDateFrom, mDateTo:Extended;
begin
      mSite:=TComponent(Sender).DynSite;
      GetInputForm(mSite,mDateFrom, mDateTo);
      mURL:= 'https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/orders/?include=orderItems&limit=100&filter=completed|gteq|'+IntToStr(DateTimeToUnix(mDateFrom))+'000'+';completed|lt|'+IntToStr(DateTimeToUnix(mDateTo+1))+'000';
      mURL:= CFxInternet.URLEncode(mURL);
      mJSON:= API_GET2(mURL, mStatusCode, mStatusText);
      if mStatusCode=200 then begin
        ProcessJSONData(mSite.BaseObjectSpace, mJSON,IntToStr(DateTimeToUnix(mDateFrom)),IntToStr(DateTimeToUnix(mDateTo+1)));
      end;

end;

begin
end.