procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
  mUser:TNxCustomBusinessObject;
begin
   mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
   if (mUser.OID='SUPER00000') or (mUser.OID='7000000101') then begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Nastaví řádek na vyčerpaný';
  mAction.Hint := 'Změní řádek na vyčerpaný';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @SetDelivery;
 end;   //mAction.OnUpdate := @ImportOnUpdate;

end;

Procedure SetDelivery(Sender:tcomponent);
var
 msite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i, j:integer;
begin
     msite:=TComponent(sender).DynSite;
     mBO:=TDynSiteForm(msite).CurrentObject;
     //mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));


     mList:=TStringList.create;
     mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
     if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,true);
     for i:=0 to mlist.Count-1 do begin
      mbo.ObjectSpace.SQLExecute(format('Update StoreDocuments2 set deliveredQuantity=Quantity where id=''%s'' ',[mlist.strings[i]]));

     end;
     mGRows.DataSource.DataSet.refresh;
     NxShowsimpleMessage('Provedeno',msite);
     //
end;


begin
end.