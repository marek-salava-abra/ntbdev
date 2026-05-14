procedure ImportFile(var mOS:TNxCustomObjectSpace;var mFileName:string);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i:integer;
 mName, mCode, mEAN, mQunit, mVAT, mPohodaID:string;
begin
 mXMLHead:=TNxScriptingXMLWrapper.Create;
 mXMLHead.loadFromFile(mFileName);
 if mXMLHead.getElementsCountInArray('rsp:responsePackItem.lStk:listStock.lStk:stock')>0 then begin
   for i:=0 to mXMLHead.getElementsCountInArray('rsp:responsePackItem.lStk:listStock.lStk:stock')-1 do begin
    mName:='';
    mCode:='';
    mEAN:='';
    mQunit:='';
    mVAT:='';
    mPohodaID:=mXMLHead.getElementAsString('rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:id');
    if ElementExists(mXMLHead,'rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:name') then
     mName:=mXMLHead.getElementAsString('rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:name');
    if ElementExists(mXMLHead,'rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:code') then
     mCode:=mXMLHead.getElementAsString('rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:code');
    if ElementExists(mXMLHead,'rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:EAN') then
     mEAN:=mXMLHead.getElementAsString('rsp:responsePackItem.lStk:listStock.lStk:stock['+IntToStr(i)+'].stk:stockHeader.stk:EAN');
   end;
 end;
end;



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