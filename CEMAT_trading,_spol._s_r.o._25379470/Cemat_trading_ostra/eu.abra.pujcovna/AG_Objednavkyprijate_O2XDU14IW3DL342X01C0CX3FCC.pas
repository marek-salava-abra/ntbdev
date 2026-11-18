procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
 mGRows:TMultiGrid;
 mBORow, mBO, mActivityBO, mReportBO, mDeviceBO: TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mStore_ID, mDivision_ID,mTemp:String;
 mList, mList2:TstringList;
 i:Integer;
begin
      mBO:=TDynSiteForm(self).CurrentObject;
      if not(NxIsBlank(mBO.GetFieldValueAsString('U_listIDs'))) then begin
      mList2:=Tstringlist.Create;
      for i:=0 to Trunc(Length(mBO.GetFieldValueAsString('U_listIDs'))/10)-1 do begin
        mList2.add(copy(mBO.GetFieldValueAsString('U_listIDs'),(i*10)+1,10));
      end;
       mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          if mRows.Count=0 then begin
            for i:=0 to mList2.count-1 do begin
              mDeviceBO:= mbo.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
              mDeviceBO.Load(mlist2.strings[i],nil);
              mBORow:= mrows.AddNewObject;
              mBORow.SetFieldValueAsInteger('RowType',0);
              mBORow.SetFieldValueAsString('Division_ID','2500000101');
              mBORow.SetFieldValueAsString('Text','Prodej přídavného zařízení z majetku: '+mDeviceBO.GetFieldValueAsString('U_Description'));
              mBORow.SetFieldValueAsString('BusTransaction_ID',mDeviceBO.GetFieldValueAsString('U_BusTransaction_ID'));
              mBORow:= mrows.AddNewObject;
              mBORow.SetFieldValueAsInteger('RowType',2);
              mBORow.SetFieldValueAsFloat('Quantity',1);
              mBORow.SetFieldValueAsString('Qunit','ks');
              mBORow.SetFieldValueAsString('Division_ID','2500000101');
              mBORow.SetFieldValueAsString('VatRate_ID','02100X0000');
              mBORow.SetFieldValueAsString('IncomeType_ID','2500000101');
              mBORow.SetFieldValueAsString('Text',mDeviceBO.GetFieldValueAsString('Name')+ '  VČ:'+mDeviceBO.GetFieldValueAsString('U_SerialNumber')+ ', Čemat:'+mDeviceBO.GetFieldValueAsString('U_BusTransaction_ID.Code'));
              mBORow.SetFieldValueAsString('BusTransaction_ID',mDeviceBO.GetFieldValueAsString('U_BusTransaction_ID'));
            end;
            mGRows := TMultiGrid(NxFindChildControl(Self.FindParentForm, 'grdRows'));
            if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;

            TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
         end;
      end;
      if not(NxIsEmptyOID(mBO.GetFieldValueAsString('U_Activity_ID'))) then begin
        mActivityBO:=mbo.ObjectSpace.CreateObject(Class_CRMActivity);
        mActivityBO.Load(mBO.GetFieldValueAsString('U_Activity_ID'),nil);
        mList:=TStringList.Create;
        try
          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          if mRows.Count=0 then begin
          mbo.ObjectSpace.SQLSelect(format('Select id from defrolldata where clsid=''VFNPR04IPRQ41HGAGUTXNGLWYW'' and x_activity_ID=''%s'' ',[mActivityBO.oid]),mList);
          for i:=0 to mList.count-1 do begin
            mReportBO:=mbo.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
            mReportBO.Load(mList.Strings[i],nil);
            mBORow:= mrows.AddNewObject;
            mBORow.SetFieldValueAsInteger('RowType',0);
            mBORow.SetFieldValueAsString('Division_ID',mActivityBO.GetFieldValueAsString('Division_ID'));
            mBORow.SetFieldValueAsString('Text','Půjčovné: '+mReportBO.GetFieldValueAsString('X_RentalDevice_ID.U_Description'));
            mBORow.SetFieldValueAsString('BusTransaction_ID',mReportBO.GetFieldValueAsString('X_RentalDevice_ID.U_BusTransaction_ID'));
            mBORow:= mrows.AddNewObject;
            mBORow.SetFieldValueAsInteger('RowType',0);
            mBORow.SetFieldValueAsString('Division_ID',mActivityBO.GetFieldValueAsString('Division_ID'));
            mBORow.SetFieldValueAsString('Text',mReportBO.GetFieldValueAsString('X_RentalDevice_ID.Name')+'  VČ: '+mReportBO.GetFieldValueAsString('X_RentalDevice_ID.U_SerialNumber')+ '  Čemat:'+mReportBO.GetFieldValueAsString('X_RentalDevice_ID.U_BusTransaction_ID.Code'));
            mBORow.SetFieldValueAsString('BusTransaction_ID',mReportBO.GetFieldValueAsString('X_RentalDevice_ID.U_BusTransaction_ID'));
            mBORow:= mrows.AddNewObject;
            mBORow.SetFieldValueAsInteger('RowType',3);
            mBORow.SetFieldValueAsString('Division_ID',mActivityBO.GetFieldValueAsString('Division_ID'));
            mBORow.SetFieldValueAsString('Store_ID','3000000101');
            mBORow.SetFieldValueAsString('StoreCard_ID','21P1000101');
            mborow.SetFieldValueAsFloat('Quantity',Trunc((mActivityBO.GetFieldValueAsDateTime('SheduledDuration$DATE'))/7));
            mborow.SetFieldValueAsFloat('UnitPrice',mReportBO.GetFieldValueAsFloat('U_rentalAmount'));
            mBORow.SetFieldValueAsString('BusTransaction_ID',mReportBO.GetFieldValueAsString('X_RentalDevice_ID.U_BusTransaction_ID'));





          end;
          mGRows := TMultiGrid(NxFindChildControl(Self.FindParentForm, 'grdRows'));
          if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;

          TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
          end;
        finally
        end;

        mActivityBO.free;
      end;
end;



begin
end.