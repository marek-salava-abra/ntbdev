{
Vyvolá se, když se nezdaří hledání skladové karty. (Pokud se místo ID dílčí skladové karty vrátí text ABORT, vyhledávání se ukončí bez jakékoli zprávy na kase.)
}
procedure AfterSearchStoreCardError_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aHookStoreUnit_OID: TNxOID; aInput: string);
var
  mQ : TStringList;
  mStoreCardList: TStringList;
  mParam:TNxParameters;
mFirm_ID, mStoreCard_ID: string;
  mStoreCardBO:TNxCustomBusinessObject;
begin
 mFirm_ID:='G000000101';
   try
    if AnsiLeftStr(aInput,7) = '2900000' then begin
      NxPOSAddDiscount(
       aDocument.ObjectSpace,
       aDocument,
       aDocument.OID,
       '1300000101',
       '',0,0,0,'','1200000101');
    end;
   except
   NxShowSimpleMessage(ExceptionMessage,nil);
   end;
  aHookStoreUnit_OID  := 'ABORT'
end;

begin
end.