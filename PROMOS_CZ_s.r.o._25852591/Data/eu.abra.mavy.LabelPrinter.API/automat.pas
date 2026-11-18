uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.LabelPrinter.API.fce', 'eu.abra.mavy.LabelPrinter.API.consts.consts' ;
procedure  AutoUpdateStateFromLP(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mList: TSTringList;
  mDateString: String;
begin
  Success := True;
  LogInfoStr := #13#10;
  mList:= TStringList.Create;
  try
    mDateString:=IntToStr(trunc(Now-cDaysOffSetForUpdate));
    SQLMultiSelect(OS,'SELECT ID FROM PDMIssuedDocs WHERE DocDate$DATE >= '+mDateString+' and X_LP_DeliveredAt= 0 and X_LP_ExternalID <> '''' ' ,mList);
    LogInfoStr:= LogInfoStr + 'Počet záznamů odeslané pošty ke kontrole stavu: '+IntToStr(mList.Count)+#13#10;
    if mList.Count > 0 then begin
      try
        Success:= ImportFromLP(OS,mList,LogInfoStr);
      Except
        LogInfoStr:= LogInfoStr + 'Nastala neočekávaná chyba při zpracování autmoatické úlohy: ' + ExceptionMessage;
        Success:= False;
      end;
    end;
  finally
    mList.Free;
  end;
end;

begin
end.