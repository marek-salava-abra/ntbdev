
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'AAAAA';
  mAction.Hint := 'BBBBB';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Test;
end;

Procedure TEST(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mJSON:TJSONSuperObject;
 mWinHTTP: Variant;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP.Open('POST','https://sod.spedos.cz/api/api.abra-get-zakazka.php?cis_zak='+ mBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mbo.ObjectSpace));
                              mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
                              NxShowSimpleMessage(mJSON.AsString,msite);
                              NxShowSimpleMessage(FloatToStr(mJSON.D['cena']),mSite);
  end;
end;


function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

begin
end.