
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mStoreAssortmentGroup_ID:string;
begin



                                        mStoreAssortmentGroup_ID:='';
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(self.GetFieldValueAsString('StoreAssortmentGroup_ID'))) then mStoreAssortmentGroup_ID:= self.GetFieldValueAsString('StoreAssortmentGroup_ID')   ;


                                        if mStoreAssortmentGroup_ID<>self.getFieldValueAsString('X_StoreAssortmentGroup_ID') then begin
                                          //   NxShowSimpleMessage(mStoreAssortmentGroup_ID,nil);

                                             self.SetFieldValueAsString('X_StoreAssortmentGroup_ID',mStoreAssortmentGroup_ID);
                                        end;
end;

begin
end.