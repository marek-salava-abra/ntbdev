{
Umožňuje ovlivnit validaci.
}
{procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mVYPBO, mOutputBO, mRoutineBO, mOperationBO:TNxCustomBusinessObject;
 mOutputs, mPLMJobOrdersRoutines:TNxCustomBusinessMonikerCollection;
 i,j,k :integer;
 mPlannedTime, mTotalTime:Extended;
 mLevel:string;
begin
  mPlannedTime:=0;
  k:=0;
  if Self.GetFieldvalueasfloat('TotalTime')>0  then begin
     mTotalTime:=self.GetFieldValueAsFloat('TotalTime');
     NxScriptingLog.EnterSection('CreatePLVYPP',logInfo);
     if not(self.GetFieldValueAsBoolean('JobOrdersRoutines_ID.Finished')) then begin
     mLevel:=self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.TreePathHumanReadable');
     if not(self.GetFieldValueAsBoolean('U_Generated')) then begin
         mVYPBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
         mVYPBO.load(self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
         if mVYPBO.GetFieldValueAsString('DocQueue_Id.code')='VYPP' then begin
            mOutputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Outputs'));
            for i:=0 to mOutputs.Count-1 do begin
              mOutputBO:=mOutputs.BusinessObject[i];
              mPLMJobOrdersRoutines:=mOutputBO.GetLoadedCollectionMonikerForFieldCode(mOutputBO.GetFieldCode('PLMJobOrdersRoutines'));
              for j:=0 to mPLMJobOrdersRoutines.count-1 do begin
                mRoutineBO:=mPLMJobOrdersRoutines.BusinessObject[j];
                if not(mRoutineBO.GetFieldValueAsBoolean('Finished')) then begin
                  if not(mRoutineBO.GetFieldValueAsString('WorkPlace_ID.code')='V-A2-ML02') and (mLevel=mRoutineBO.GetFieldValueAsString('Parent_ID.Owner_ID.TreePathHumanReadable')) then begin
                    mPlannedTime:=mPlannedTime+mRoutineBO.GetFieldValueAsFloat('TAC');
                    k:=k+1;
                  end;
                end;
              end;
            end;

            for i:=0 to mOutputs.Count-1 do begin
              mOutputBO:=mOutputs.BusinessObject[i];
              mPLMJobOrdersRoutines:=mOutputBO.GetLoadedCollectionMonikerForFieldCode(mOutputBO.GetFieldCode('PLMJobOrdersRoutines'));
              for j:=0 to mPLMJobOrdersRoutines.count-1 do begin
                mRoutineBO:=mPLMJobOrdersRoutines.BusinessObject[j];
                if not(mRoutineBO.GetFieldValueAsBoolean('Finished')) then begin
                  if not(mRoutineBO.GetFieldValueAsString('WorkPlace_ID.code')='V-A2-ML02')
                     and (mLevel=mRoutineBO.GetFieldValueAsString('Parent_ID.Owner_ID.TreePathHumanReadable'))
                     and not(mRoutineBO.OID=self.GetFieldValueAsString('JobOrdersRoutines_ID')) then begin
                     mOperationBO:=self.ObjectSpace.CreateObject(Class_PLMOperation);
                     mOperationBO.new;
                     mOperationBO.Prefill;
                     mOperationBO.SetFieldValueAsBoolean('U_Generated',True);
                     mOperationBO.SetFieldValueAsString('JobOrdersRoutines_ID', mRoutineBO.OID);
                     mOperationBO.SetFieldValueAsString('Workplace_ID',mRoutineBO.GetFieldValueAsString('WorkPlace_ID'));
                     mOperationBO.SetFieldValueAsString('PerformedBy_ID',self.GetFieldValueAsString('PerformedBy_ID'));
                     mOperationBO.SetFieldValueAsFloat('TotalTime',(mTotalTime/mPlannedTime)*mRoutineBO.GetFieldValueAsFloat('TAC'));
                     mOperationBO.SetFieldValueAsString('Division_ID',self.GetFieldValueAsString('Division_ID'));
                     mOperationBO.SetFieldValueAsString('BusOrder_ID',self.GetFieldValueAsString('BusOrder_ID'));
                     mOperationBO.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('BusTransaction_ID'));
                     mOperationBO.SetFieldValueAsString('BusProject_ID',self.GetFieldValueAsString('BusProject_ID'));
                     mOperationBO.SetFieldValueAsDateTime('StartedAt$DATE',self.GetFieldValueAsDateTime('StartedAt$DATE'));
                     mOperationBO.SetFieldValueAsDateTime('FinishedAt$DATE',self.GetFieldValueAsDateTime('FinishedAt$DATE'));
                     mOperationBO.SetFieldValueAsFloat('Quantity',self.GetFieldValueAsFloat('Quantity'));
                     mOperationBO.SetFieldValueAsBoolean('OperationResult',True);
                     mOperationBO.save;
                     mOperationBO.free;

                  end;
                end;
              end;
            end;
         if k>0 then
         self.SetFieldValueAsFloat('TotalTime',(mTotalTime/mPlannedTime)*self.GetFieldValueAsFloat('JobOrdersRoutines_ID.TAC'));

         end;
      end;
     end;
  end;
end;  }

begin
end.