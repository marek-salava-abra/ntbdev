procedure Import(sender:TComponent);
var
 mSite:TSiteForm;
 mParams2:TNxParameters;
 mBO:TNxCustomBusinessObject;
 mTemplates: TNxParameters;
begin
  mSite:=TComponent(sender).DynSite;
  //NxShowSimpleMessage('jsem tu', msite);
  mBO:=TDynSiteForm(mSite).CurrentObject;
  mParams2 := TNxParameters.Create;
     mTemplates := mParams2.NewFromDataType(dtList, 'TemplateParams').AsList;
     mTemplates.NewFromDataType(dtString, 'Firm_ID').AsString:=mBO.GetFieldValueAsString('Firm_ID');
     mTemplates.NewFromDataType(dtString, 'U_Activity_ID').AsString:=MBO.OID;
    msite.ShowDynForm('O2XDU14IW3DL342X01C0CX3FCC', mParams2, Nil, False, 'DoNewOnly');

end;

begin
end.