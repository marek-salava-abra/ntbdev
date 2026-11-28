procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Oprava kontaktů';
  mAction.Items.Add('Telefon 1');
  mAction.Items.Add('Email pro odeslání dokladů');
  mAction.Items.Add('Email pro OV');
  mAction.Items.Add('Další email. adresy');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Opraví data v adresáři firem';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CorrectFirm;

end;

procedure CorrectFirm(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mBO:TNxCustomBusinessObject;
 mText:String;
begin
 msite:=TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
  if index=0 then begin
   try
     mBO:=TBusRollSiteForm(msite).CurrentObject;
     mText:=mbo.GetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1');
     mText:=InputBox('Oprava','Změní telefon 1',mText);
     //if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1',mText);
     mBO.Save;


   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;
   if index=1 then begin
   try
     mBO:=TBusRollSiteForm(msite).CurrentObject;
     mText:=mbo.GetFieldValueAsString('ResidenceAddress_ID.Email');
     mText:=InputBox('Oprava','Email pro odeslání dokladů',mText);
     //if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsString('ResidenceAddress_ID.Email',mText);
     mBO.Save;


   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;
   if index=2 then begin
   try
     mBO:=TBusRollSiteForm(msite).CurrentObject;
     mText:=mbo.GetFieldValueAsString('U_EmailOV');
     mText:=InputBox('Oprava','Email pro OV',mText);
     //if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsString('U_EmailOV',mText);
     mBO.Save;


   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;
   if index=3 then begin
   try
     mBO:=TBusRollSiteForm(msite).CurrentObject;
     mText:=mbo.GetFieldValueAsString('U_dalEmaily');
     mText:=InputBox('Oprava','Další emaily',mText);
     //if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsString('U_dalEmaily',mText);
     mBO.Save;


   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;
   //msite.free;
 end;
end;


begin
end.