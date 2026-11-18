procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mrsa,mr:tstringlist;
  msite:TSiteForm;
begin
  try
  if (AFieldCode = Self.GetFieldCode('Storecard_ID')) and (self.GetFieldValueAsInteger('RowType')=3) then begin
       mrsa:=TStringList.create;
       try
            self.ObjectSpace.SQLSelect('select max(X_Specifikace_id) from Subscribers where StoreCard_ID=' + quotedstr(AValue.AsString) + ' and  Firm_ID=' +
            quotedstr(self.GetFieldValueAsString('parent_id.Firm_id')),mrsa);
            if mrsa.count=1 then  begin
               if (trim(mrsa.Strings[0])<>'') and (trim(mrsa.Strings[0])<>'""') and (trim(mrsa.Strings[0])<>'0000000000') then begin
                   //NxShowSimpleMessage(mr.Strings[0],nil);
                   self.SetFieldValueAsString('X_specifikace_id',mrsa.Strings[0]);
               end;
            end else begin
              self.SetFieldValueAsString('X_specifikace_id','');

            end;;


       finally
          mrsa.free;
       end;



       mrsa:=TStringList.create;
       try
            self.ObjectSpace.SQLSelect('select ExternalSpecification from Subscribers where StoreCard_ID=' +
                quotedstr(AValue.AsString) + ' and Firm_ID=' +quotedstr(self.GetFieldValueAsString('parent_id.Firm_ID')),mrsa) ;
            if mrsa.count=1 then  begin
                    if mrsa.Strings[0]='""' then Self.SetFieldValueAsString('X_ExternalSpecification', '') else
                   //NxShowSimpleMessage(mr.Strings[0],nil);
                          Self.SetFieldValueAsString('X_ExternalSpecification', mrsa.Strings[0]);

            end else begin
              Self.SetFieldValueAsString('X_ExternalSpecification', '');

            end;;


       finally
          mrsa.free;
       end;


end;
  finally

  end;

end;

begin
end.