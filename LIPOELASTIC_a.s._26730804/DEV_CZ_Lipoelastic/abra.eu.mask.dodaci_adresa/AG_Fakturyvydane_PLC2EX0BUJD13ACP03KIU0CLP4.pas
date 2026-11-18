uses 'abra.eu.mask.dodaci_adresa.lib';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Dodací adresa';
          mMAction.Caption := 'Dodací adresa';
          mMAction.Items.Add('Dodací adresa');
          mMAction.Items.Add('Zrušení dodací adresy');

          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnDelivery_adress;


end;

procedure OnDelivery_adress(Sender: TComponent;index:integer);
var
  mid:string;
  mI_Result:integer;
begin
  mid:='';
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
  if index=0 then begin

          if NxIsEmptyOID(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Delivery_adress_id')) then  begin
                   mI_Result:=Mformx(msite,'Dodací adresa','Není uvedena dodací adresa', 'Založit novou','','','Zrušit');
                                                                  if (mI_Result=1)  then begin
                                                                      mid:= GetDelivery_adress(msite,TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Delivery_adress_id'));
                                                                      if mid<>'' then TDynSiteForm(msite).CurrentObject.setFieldValueAsString('X_Delivery_adress_id',mid);
                                                                      TDynSiteForm(msite).CurrentObject.save;
                                                                  end;


           end else begin
               mid:= GetDelivery_adress(msite,TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Delivery_adress_id'));
          end;
   end ;

   if index=1 then begin
            TDynSiteForm(msite).CurrentObject.setFieldValueAsString('X_Delivery_adress_id','');
            TDynSiteForm(msite).CurrentObject.save;
   end;

end;



begin
end.