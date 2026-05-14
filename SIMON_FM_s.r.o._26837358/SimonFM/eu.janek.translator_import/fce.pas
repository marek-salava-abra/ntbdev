procedure ImportTranslator(var AOS:TNxCustomObjectSpace; var Arow:String);
var
 mCode, mCode2,mCode3:String;
 mTranslator_ID:String;
 mBO:TNxCustomBusinessObject;
begin
 mCode:=NxToken(Arow,';');
 mCode2:=NxToken(Arow,';');
 mCode3:=NxToken(Arow,';');
 if Assigned(AOS) then begin
   mTranslator_ID:=GetTranslator_ID(aos,mCode);
   mBO:=aos.CreateObject('FPXJLP5SC314DF45HVZNY0OBYO');
   mbo.New;
   mbo.Prefill;
   mbo.SetFieldValueAsString('X_vip_card_id',mTranslator_ID);
   mbo.SetFieldValueAsString('X_firm_id',mCode3);
   mbo.save;
   mbo.free;



 end;

end;

function GetTranslator_ID(var BOS : TNxCustomObjectSpace;var AValue : string) : string;
const
  cSQL = 'SELECT D.ID FROM defrolldata D where x_cardnumber=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    BOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.