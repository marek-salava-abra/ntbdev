procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
begin

   if (AParams.ParamExist('mAssortmentGroup')) then begin
      if (not NxIsEmptyOID(AParams.GetOrCreateParam(dtString, 'mAssortmentGroup').AsString)) then begin
          //NxShowSimpleMessage('Yes ' + AParams.GetOrCreateParam(dtString, 'mAssortmentGroup').AsString,nil);
          ADSQL.Where.Add('(((A.X_StoreAssortmentGroup_ID = ' + quotedstr(AParams.GetOrCreateParam(dtString, 'mAssortmentGroup').AsString)  +
                            ') or (A.X_StoreAssortmentGroup_ID is null)) and (A.X_NewFilterParam = ''A''))') ;
      end else begin
      //  NxShowSimpleMessage('NO ' + AParams.GetOrCreateParam(dtString, 'mAssortmentGroup').AsString,nil);
          ADSQL.Where.Add('(A.X_StoreAssortmentGroup_ID ='''')  and (A.X_NewFilterParam = ''A'')') ;
     end;

   end;








end;

begin
end.