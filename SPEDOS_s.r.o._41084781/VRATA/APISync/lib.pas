function POST_PLMJobOrder_ID(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
   mPLMJobOrder_ID:string;
   mJSON:TJSONSuperObject;
begin
   mJSON:=TJSONSuperObject.Create;
   mPLMJobOrder_ID:=AContext.SQLSelectFirstAsString('SELECT ID FROM USERDATA WHERE FIELDCODE=2000001 AND CLSID='+QuotedStr('HTI3OTLGNRPO32EEISEPC0XZ0K')+' and STRINGFIELDVALUE = '+QuotedStr(AInput.S['code']),'');
   mJSON.S['ID']:=mPLMJobOrder_ID;
   Result:=mJSON;
end;

begin
end.