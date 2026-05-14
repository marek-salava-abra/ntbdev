uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_StoreCard',
  'REST_SkladTerm_Customer.U_Requests';

procedure post(AContext: TNxContext; AHeaders, APath, AArguments: TStringList; ABody: String; AResponse: TStringList);
var
  mOS: TNxCustomObjectSpace;
begin
  mOS := AContext.GetObjectSpace;

  if not processSpecialPostRequests(AContext, AHeaders, APath, AArguments, ABody, AResponse) then
  begin
    // standardni zpracovani
    //podle toho zavolam funkci, ktera pozadavek zpracuje
    case APath.Strings[0] of
      'post_CheckEanExistence': Post_CheckEanExistence(mOS, ABody, APath, AResponse);
      'availableQuantity': Post_AvailableQuantity(mOS, APath, AArguments, ABody, AResponse);
      else SetPlainResponse(AResponse, Format(getString('error_path_not_found'), [APath.Text]), HTTP_SC_BadRequest);
    end;
  end;
end;

begin
end.