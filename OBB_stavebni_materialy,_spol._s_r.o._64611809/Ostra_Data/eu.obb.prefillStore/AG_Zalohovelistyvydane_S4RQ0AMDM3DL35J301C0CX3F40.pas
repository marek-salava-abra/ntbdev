

procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
 mGRows:TMultiGrid;
 mBORow, mBO, mUser: TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mStore_ID, mDivision_ID:String;
begin
      mBO:=TDynSiteForm(self).CurrentObject;
      mUser:=mbo.ObjectSpace.CreateObject(Class_SecurityUser);
      mUser.Load(NxGetActualUserID_1(mBO),nil);
      mDivision_ID:=muser.GetFieldValueAsString('X_division_ID');
      if NxIsEmptyOID(mbo.GetFieldValueAsString('DocQueue_ID')) then   mbo.SetFieldValueAsString('DocQueue_ID',muser.GetFieldValueAsString('X_IDI_ID'));
       muser.Free;

      if not(NxIsEmptyOID(mDivision_ID)) then begin
        try
          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          if mRows.Count=0 then begin
          mBORow:= mrows.AddNewObject;
          mBORow.Prefill;
          mBORow.SetFieldValueAsInteger('RowType',4);
          mBORow.SetFieldValueAsString('Division_ID',mDivision_ID);
          mGRows := TMultiGrid(NxFindChildControl(Self.FindParentForm, 'grdRows'));
          if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;

          TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
          end;
        finally
        end;
      end;
end;

begin
end.