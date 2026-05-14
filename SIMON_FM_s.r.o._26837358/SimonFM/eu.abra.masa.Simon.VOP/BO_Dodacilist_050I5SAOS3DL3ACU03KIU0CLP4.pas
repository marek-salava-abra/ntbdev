{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrderList:TStringList;
 mBO, mCloneBO, mCloneRowBO, mRowBO, mUserXLink, mTempBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 i,j:integer;
 mRows, mCloneRows:TNxCustomBusinessMonikerCollection;
 mClone:Boolean;
begin
  if (self.GetFieldValueAsString('DocQueue_ID')='U200000101') and (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') then begin
     mOrderList:=TStringList.Create;
     mOS:=self.ObjectSpace;
     mOS.SQLSelect('Select distinct(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),mOrderList);
     if mOrderList.Count>0 then begin
        for i:=0 to mOrderList.count-1 do begin
          try
          mBO:=mOS.CreateObject(Class_ReceivedOrder);
          mBO.Load(mOrderList.Strings[i],nil);
          mbo.PMChangeState('7060000101');
          except
             CFxLog.SaveLog(NxCreateContext_1(self),'ERR','chyba DL03',mOrderList.Strings[i]+#13#10+mOrderList.DelimitedText,2,Now);
          end;
        end;
     end;
  end;
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and (osNew in self.State) and (self.GetFieldValueAsString('DocQueue_ID')='U200000101') then begin
     mOrderList:=TStringList.Create;
     mOS:=self.ObjectSpace;
     mOS.SQLSelect('Select distinct(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),mOrderList);
     if mOrderList.Count>0 then begin
        for i:=0 to mOrderList.count-1 do begin
         try
          mBO:=mOS.CreateObject(Class_ReceivedOrder);
          mBO.Load(mOrderList.Strings[i],nil);
          mClone:=False;
          mrows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
          for j:=0 to mRows.count-1 do begin
            if (mRows.BusinessObject[j].GetFieldValueAsInteger('RowType')=3)
             and (mRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')<mRows.BusinessObject[j].GetFieldValueAsFloat('Quantity'))
             and not(mClone) then mClone:=True;
          end;
          if mClone then begin
            mCloneBO:=mBO.Clone;
            mCloneRows:=mCloneBO.GetLoadedCollectionMonikerForFieldCode(mCloneBO.GetFieldCode('Rows'));
            for j:=0 to mCloneRows.Count-1 do begin
              mCloneRows.BusinessObject[j].MarkForDelete;
            end;
            for j:=0 to mRows.count-1 do begin
              if (mRows.BusinessObject[j].GetFieldValueAsInteger('RowType')=3)
               and (mRows.BusinessObject[j].GetFieldValueAsFloat('DeliveredQuantity')<mRows.BusinessObject[j].GetFieldValueAsFloat('Quantity'))
                then begin
                 mRowBO:=mRows.BusinessObject[j];
                 mCloneRowBO:=mCloneRows.AddNewObject;
                 mCloneRowBO.SetFieldValueAsInteger('RowType',mRowBO.GetFieldValueAsInteger('RowType'));
                 mCloneRowBO.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
                 mCloneRowBO.SetFieldValueAsString('StoreCard_ID',mRowBO.GetFieldValueAsString('StoreCard_ID'));
                 mCloneRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity')-mRowBO.GetFieldValueAsFloat('DeliveredQuantity'));
                 mCloneRowBO.SetFieldValueAsFloat('UnitPrice',mRowBO.GetFieldValueAsFloat('UnitPrice'));
                 mCloneRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
                 mCloneRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
                 mCloneRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
                 mCloneRowBO.SetFieldValueAsString('BusProject_ID',mRowBO.GetFieldValueAsString('BusProject_ID'));
                 mCloneRowBO.SetFieldValueAsFloat('RowDiscount',mRowBO.GetFieldValueAsFloat('RowDiscount'));
               end;
             end;
            mcloneBO.SetFieldValueAsString('PMState_ID','2060000101');
            if NxIsBlank(mCloneBO.GetFieldValueAsString('U_OrigOrderID')) then mCloneBO.SetFieldValueAsString('U_OrigOrderID',mBO.OID);
            try
              mbo.SetFieldValueAsBoolean('Closed',True);
              mBO.save;
              //dohledat rezervace z objektu a zneplatnit

              //konec znepltatnění rezervací
            except
              CFxLog.SaveLog(NxCreateContext_1(self),'ERR','chyba closed OPV',mOrderList.Strings[i]+#13#10+mOrderList.DelimitedText,2,Now);
            end;
            mCloneBO.save;
            mUserXLink := mOS.CreateObject(Class_UserXLink);
            try
              mUserXLink.New;
              mUserXLink.Prefill;
              mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
              mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
              mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_ReceivedOrder);
              mUserXLink.SetFieldValueAsString('Destination_ID', mCloneBO.OID);
              mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
              mUserXLink.SetFieldValueAsString('Description','Zbytek objednávky '+mBO.DisplayName);
              mUserXLink.Save;
            finally
              mUserXLink.Free;
            end;
          end;
          mbo.free;
        Except
         CFxLog.SaveLog(NxCreateContext_1(self),'ERR','chyba OPV',mOrderList.Strings[i]+#13#10+mOrderList.DelimitedText,2,Now);
        end;
       end;
     end;
  end;
end;

begin
end.