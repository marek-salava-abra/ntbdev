{
Umožňuje ovlivnit validaci.

 }


procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBODList:tstringlist;
 mRows:  TNxCustomBusinessMonikerCollection;
 mRowBO, mBO: TNxCustomBusinessObject;
 i: integer;
 mOtherStore: boolean;
 mPrintForm_ID:string;
begin
  if (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') then begin
      if CFxNxRuntime.NxGetEnvironmentType = reWebServices then begin
           mBODList:=TStringList.create;
           mBODList.add(self.OID);
           mPrintForm_ID:=Self.GetFieldValueAsString('Firm_ID.X_FormDL_ID');
           if not(NxIsEmptyOID(mPrintForm_ID)) then begin
             CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mBODList,'05DOXDMCSZDL3FUD00C5OG4NF4',mPrintForm_ID,rtoPrint,pekPDF,'HP_M521_Promos', '');
             CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mBODList,'05DOXDMCSZDL3FUD00C5OG4NF4',mPrintForm_ID,rtoPrint,pekPDF,'HP_M521_Promos', '');
           end;
           mBODList.free;
      end;
  end;
  if not(NxGetActualUserID_1(self) in ['1730000101','SUPER00000']) then begin

    mBO:= Self.ObjectSpace.CreateObject(Class_BillOfDelivery);
    mBO.Load(Self.OID, nil);
    if mbo.GetFieldValueAsString('Docqueue_id.Code') in ['DLR','DLZ','DLD'] then begin
      if mBO.GetFieldValueAsString('PMState_ID')='2000000001' then begin
       if not (osSaving in mBO.InternalState) then mBO.PMChangeState('SDDEF00000');
      end;
    end;
   end;
end;






begin
end.