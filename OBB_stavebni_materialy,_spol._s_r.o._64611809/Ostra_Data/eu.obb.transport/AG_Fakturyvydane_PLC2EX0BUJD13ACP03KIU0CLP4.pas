uses 'eu.obb.transport.fce';

{procedure _AfterSave_PreHook(Self: TDynSiteForm);
Var
 mRows:TNxCustomBusinessMonikerCollection;
 mRowBO, mBOProject, mBODL, mBO:TNxCustomBusinessObject;
 i:Integer;
 mString, mBOProject_ID:String;
begin
  mBO:=self.CurrentObject;
  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for i:=0 to mRows.Count-1 do begin
    mRowBO:=mrows.BusinessObject[i];
    if (mRowBO.GetFieldValueAsString('StoreCard_ID.Code')='97DO500500') or
       (mRowBO.GetFieldValueAsString('StoreCard_ID.Code')='97DO600110') or
       (mRowBO.GetFieldValueAsString('StoreCard_ID.Code')='97DO600510') then begin
      mBODL:=mbo.ObjectSpace.CreateObject(Class_BillOfDelivery);
      mBODL.Load(mRowBO.GetFieldValueAsString('Provide_ID'),nil);
      mString:=mBODL.DisplayName;
      mBOProject_ID:=GetProject_ID(mbo.ObjectSpace,mString);
      if NxIsEmptyOID(mBOProject_ID) then begin
      mBOProject:=mbo.ObjectSpace.CreateObject(Class_BusProject);
      mBOProject.New;
      mBOProject.SetFieldValueAsString('Code',mString);
      mBOProject.SetFieldValueAsString('Firm_ID',mRowBO.GetFieldValueAsString('Parent_ID.Firm_ID'));
      mBOProject.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
      mBOProject.save;
      mBOProject_ID:=mBOProject.OID;
      mBOProject.free;
      end;
      mRowBO.SetFieldValueAsString('BusProject_ID',mBOProject_ID);
      mRowBO.Save;



    end;


  end;
end;  }




begin
end.