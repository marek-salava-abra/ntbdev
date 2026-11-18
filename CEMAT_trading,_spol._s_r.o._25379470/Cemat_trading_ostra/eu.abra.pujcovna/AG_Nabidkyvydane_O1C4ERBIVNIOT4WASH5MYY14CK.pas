procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
 mGRows:TMultiGrid;
 mBORow, mBO, mActivityBO, mReportBO, mDeviceBO: TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mStore_ID, mDivision_ID:String;
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
              mBORow.SetFieldValueAsInteger('RowType',2);
              mBORow.SetFieldValueAsFloat('Quantity',1);
              mBORow.SetFieldValueAsString('Qunit','ks');
              mBORow.SetFieldValueAsString('Division_ID','2500000101');
              mBORow.SetFieldValueAsString('VatRate_ID','02100X0000');
              mBORow.SetFieldValueAsString('Text','Nabídka repasovaného zařízení: '+mDeviceBO.GetFieldValueAsString('U_Description'));
              mBORow.SetFieldValueAsString('BusTransaction_ID',mDeviceBO.GetFieldValueAsString('U_BusTransaction_ID'));
            end;
            mGRows := TMultiGrid(NxFindChildControl(Self.FindParentForm, 'grdRows'));
            if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;

            TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
         end;
      end;
end;

begin
end.