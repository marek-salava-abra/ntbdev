uses 'eu.abra.mforce.fce';

procedure _AfterSave_PostHook(Self: TDynSiteForm);
Var
 mReceivedOrder, mBusProject, mRes:TNxCustomBusinessObject;
 mRows, mReservations: TNxCustomBusinessMonikerCollection;
 mEmpty:boolean;
 i,j: integer;
 mBusProject_ID, mLisar_ID, mLisar_Store_ID: String;

begin
  mReceivedOrder:= self.CurrentObject;
  mRows:=mReceivedOrder.GetLoadedCollectionMonikerForFieldCode(mReceivedOrder.GetFieldCode('ROWS'));
  mLisar_ID:=scrGetLisar_ID(mReceivedOrder.ObjectSpace,mReceivedOrder.OID);
  mLisar_Store_ID:=scrGetStore_ID(mReceivedOrder.ObjectSpace, mLisar_ID);
  mBusProject_ID:=scrGetBusProject_ID(mReceivedOrder.ObjectSpace,mReceivedOrder.OID);
  if not(NxIsEmptyOID(mLisar_ID)) then begin
  
         mEmpty:=NxIsEmptyOID(mBusProject_ID);
         
         //if not(mEmpty) then exit;
         if mEmpty then begin
             mBusProject:=self.CurrentObject.ObjectSpace.CreateObject(Class_BusProject);
             mBusProject.New;
             mBusProject.Prefill;
             mBusProject.SetFieldValueAsString('Name',mReceivedOrder.GetFieldValueAsString('Firm_ID.Name'));
             mBusProject.SetFieldValueAsString('Division_ID',mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'));
             mBusProject.SetFieldValueAsString('Firm_ID', mReceivedOrder.GetFieldValueAsString('Firm_ID'));
             mBusProject.Save;
             mBusProject_ID:= mBusProject.OID;
             mBusProject.OID;
         
         end;
         for i := 0 to mRows.Count - 1 do begin
             if not(NxIsEmptyOID(mBusProject_ID)) then mRows.BusinessObject[i].SetFieldValueAsString('BusProject_id', mBusProject_ID);
             if not(NxIsEmptyOID(mLisar_Store_ID)) and (mrows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3) then
             mRows.BusinessObject[i].SetFieldValueAsString('Store_ID', mLisar_Store_ID);
             if not(nxisemptyOID(mrows.BusinessObject[i].GetFieldValueAsString('Reservation_ID'))) then begin
             mres:=mrows.BusinessObject[i].GetMonikerForFieldCode(mrows.BusinessObject[i].GetFieldCode('Reservation_ID')).BusinessObject;
             mres.SetFieldValueAsFloat('Reserved',0);
             mres.SetFieldValueAsInteger('Priority',99);
             end;
         end;
    if NxIsEmptyOID(mReceivedOrder.GetFieldValueAsString('X_status')) then mReceivedOrder.SetFieldValueAsString('X_status','1I00000101');
   mReceivedOrder.Save;
  end;
end;



begin
end.