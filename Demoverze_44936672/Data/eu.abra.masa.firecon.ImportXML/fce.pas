function ElementExists(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if mXMLHead.getElementAsString(AName)<>'' then Result:= True;
  except
    Result:= False;
  end;
end;
begin
end.