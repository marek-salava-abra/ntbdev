{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mVYPBO, mInputBO, mVMVHeadBO, mVMVRowBO,mJoMIPLMD,mJoMIPL,mObjRow:TNxCustomBusinessObject;
 mInputItems, mRows,mJoMIPLMDMon, mObjRowsMon,mMaterialDistrMon:TNxCustomBusinessMonikerCollection;
 i,j,y, z:integer;
 mImport:Boolean;
 mAvailableQuantity,mVMVRowQuantity, mDistributedQuantity, mQuantity, mKoeficient, mDiv:Extended;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mRowBO:TNxCustomBusinessObject;
 mPhase_ID, mVMV_ID:string;
begin

  {if not(self.getFieldValueAsBoolean('JobOrdersRoutines_ID.finished')) and (Self.GetFieldvalueasfloat('quantity')>0)  then begin
    NxScriptingLog.EnterSection('CreateVMV',logInfo);
     mPhase_ID:=self.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID');
     mVYPBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mVYPBO.load(self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
     mInputItems:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
     mDiv:=self.GetFieldValueAsFloat('JobOrdersRoutines_ID.MissedQuantity');
     if mDiv=0 then mDiv:=1;
     mKoeficient:=self.GetFieldValueAsFloat('Quantity')/mDiv;
     mVMV_ID:='';
      try
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := '1H10000101';
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mVYPBO.GetFieldValueAsString('Firm_ID');
          mParam :=  mInputParams.GetOrCreateParam(dtInteger, 'MethodOfMD');
          mParam.AsInteger := 1;
          mImportMan := NxCreateDocumentImportManager(mVYPBO.ObjectSpace, Class_PLMJobOrder, Class_MaterialDistribution);
          mImportMan.AddInputDocument(mVYPBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          //mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mVYPBO.GetFieldValueAsDateTime('PlanedStartAt$DATE'));
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            for z:=0 to mRows.count-1 do begin
              mRowBO:=mrows.BusinessObject[z];
              mAvailableQuantity:=GetAvailableQuantity(self.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
              if (mAvailableQuantity>0) then   mRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity')*mKoeficient) else mRowBO.MarkForDelete;
            end;
          mImportMan.OutputDocument.SetFieldValueAsString('Description',mVYPBO.GetFieldValueAsString('U_vyrobni_cislo'));
          if mRows.CountOfNotDeleted>0 then begin
            mImportMan.OutputDocument.save;
            mVMV_ID:=mImportMan.OutputDocument.OID;
          end;
          mImportMan.free;
          mVMVHeadBO:=self.ObjectSpace.CreateObject(Class_MaterialDistribution);
          mVMVHeadBO.Load(mVMV_ID,nil);
          mRows:=mVMVHeadBO.GetLoadedCollectionMonikerForFieldCode(mVMVHeadBO.GetFieldCode('Rows'));
          for j:=0 to mInputItems.Count-1 do begin
            mInputBO:=mInputItems.BusinessObject[j];
            mMaterialDistrMon:=mInputBO.GetLoadedCollectionMonikerForFieldCode(mInputBO.GetFieldCode('PLMMIPLMaterialDistribution'));
            for i:=0 to mMaterialDistrMon.Count-1 do begin
              for z:=0 to mRows.count-1 do begin
                mRowBO:=mrows.BusinessObject[z];
                if mRowBO.OID=mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('StoreDocument2_ID') then begin
                  if NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusTransaction_ID')) then mRowBO.SetFieldValueAsString('BusTransaction_ID',mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.U_BusTransaction_ID'));
                   if not(mPhase_ID=mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID')) then mRowBO.MarkForDelete;
                end;
              end;
            end;
          end;
          if mRows.CountOfNotDeleted>0 then mVMVHeadBO.save;
          if mrows.CountOfNotDeleted=0 then mVMVHeadBO.Delete;
          //mVMVHeadBO.free;

       Except
         NxShowSimpleMessage(ExceptionMessage,nil);
       end;





  {
   NxScriptingLog.EnterSection('CreateVMV',logInfo);
   NxScriptingLog.WriteEvent(logInfo,'Moje ID je '+self.OID);
     if not(self.GetFieldValueAsBoolean('U_Generated')) then  NxScriptingLog.WriteEvent(logInfo,'nejsem generovaný PL '+self.OID);
     mVYPBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mVYPBO.load(self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
     mInputItems:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
     for i:=0 to mInputItems.count-1 do begin
       if mInputItems.BusinessObject[i].GetFieldValueAsInteger('Owner_ID.Issue')=0 then begin
         mImport:=False;
         mInputBO:=mInputItems.BusinessObject[i];
         if (mInputBO.GetFieldValueAsString('Phase_ID')=self.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID'))then mImport:=true;
         NxScriptingLog.WriteEvent(logInfo,'Výrobní příkaz '+mVYPBO.DisplayName+' název karty '+mInputBO.GetFieldValueAsString('RealStoreCard_ID.Name'));
         if mImport then begin
           mAvailableQuantity:=GetAvailableQuantity(self.ObjectSpace,mInputBO.GetFieldValueAsString('RealStoreCard_ID'),mInputBO.GetFieldValueAsString('SupposedStore_ID'));
           if mAvailableQuantity>0 then begin
                mVMVRowQuantity:=Self.GetFieldvalueasfloat('quantity')*mInputBO.GetFieldValueAsFloat('Quantity');
                mDistributedQuantity:=GetDistributedQuantity(self.ObjectSpace,mInputBO.OID);
                //mVMVRowQuantity:=NxRoundByValue(mVMVRowQuantity,ctArithmetic,1);
                NxScriptingLog.WriteEvent(logInfo,'Výrobní příkaz '+mVYPBO.DisplayName+' název karty'+mInputBO.GetFieldValueAsString('RealStoreCard_ID.Name')+' kód karty'+mInputBO.GetFieldValueAsString('RealStoreCard_ID.Code')+' množství:'
                                         +floattostr(mInputBO.GetFieldValueAsFloat('Quantity'))+' dostupne: '+FloatToStr(mAvailableQuantity)+' vydat '+FloatToStr(mVMVRowQuantity)+' vydané '+FloatToStr(mDistributedQuantity));
                if mDistributedQuantity<mVMVRowQuantity then mQuantity:=mVMVRowQuantity-mDistributedQuantity else mQuantity:=0;

                if (mQuantity>0) and (mAvailableQuantity>0) then begin
                  try
                  mVMVHeadBO:=self.ObjectSpace.CreateObject(Class_MaterialDistribution);
                  mVMVHeadBO.new;
                  mVMVheadbo.prefill;
                  mVMVheadbo.SetFieldValueAsString('Firm_ID',mVYPBO.GetFieldValueAsString('Firm_ID'));
                  mVMVHeadBO.SetFieldValueAsString('Description',mVYPBO.GetFieldValueAsString('U_vyrobni_cislo'));
                  //mVMVHeadBO.SetFieldValueAsString('Description',mcode+' '+mPozice+' '+mVYPBO.DisplayName+' '+IntToStr(ii+1)+'/'+mInputCount);
                  mRows:=mVMVHeadBO.GetCollectionMonikerForFieldCode(mVMVHeadBO.GetFieldCode('Rows'));
                  mVMVRowBO:=mrows.AddNewObject;
                  mVMVRowBO.SetFieldValueAsInteger('RowType', 3);
                  mVMVRowBO.SetFieldValueAsString('Store_ID', mInputBO.GetFieldValueAsString('SupposedStore_ID'));
                  mVMVRowBO.SetFieldValueAsString('StoreCard_ID', mInputBO.GetFieldValueAsString('RealStoreCard_ID'));
                  if mQuantity>mAvailableQuantity then mVMVRowBO.SetFieldValueAsFloat('Quantity', mAvailableQuantity) else
                  mVMVRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
                  mVMVRowBO.SetFieldValueAsString('Division_ID', mVYPBO.GetFieldValueAsString('Division_ID'));
                  mVMVRowBO.SetFieldValueAsString('ProductionTask_ID', mVYPBO.GetFieldValueAsString('ProductionTask_ID'));
                  mVMVRowBO.SetFieldValueAsString('BusOrder_ID', mVYPBO.GetFieldValueAsString('BusOrder_ID'));
                  mVMVRowBO.SetFieldValueAsString('BusTransaction_ID',mInputBO.GetFieldValueAsString('U_BusTransaction_ID'));
                  mVMVRowBO.SetFieldValueAsString('Text', mInputBO.GetFieldValueAsString('Owner_ID')+mInputBO.OID);

                  mVMVHeadBO.save;
                  NxScriptingLog.WriteEvent(logInfo,'založil jsem VMV '+mVMVHeadBO.DisplayName);
                  Except
                   NxScriptingLog.WriteEvent(loginfo,'Nepovedlo se: '+ExceptionMessage);
                  end;
                  for Y := 0 to (mInputItems.Count - 1) do begin
                     mJoMIPL := mInputItems.BusinessObject[Y];
                       mJoMIPLMDMon := mJoMIPL.GetLoadedCollectionMonikerForFieldCode(mJoMIPL.GetFieldCode('PLMMIPLMaterialDistribution'));
                       mObjRowsMon := mVMVHeadBO.GetLoadedCollectionMonikerForFieldCode(mVMVHeadBO.GetFieldCode('ROWS'));
                       // Projdou se vsechny radky VMV az se narazi na radek, ktery odpovida radku kusovniku ...
                       for Z := 0 to (mObjRowsMon.Count -1) do begin
                        mObjRow := mObjRowsMon.BusinessObject[Z];
                        if NxTrim(mObjRow.GetFieldValueAsString('Text'),' ') = mJoMIPL.GetFieldValueAsString('Owner_ID') + mJoMIPL.GetFieldValueAsString('ID') then begin
                         // ... a konecne se vytvori vazba
                          mJoMIPLMD := mJoMIPLMDMon.AddNewObject;
                          mJoMIPLMD.Prefill;
                          mJoMIPLMD.SetFieldValueAsString('StoreDocument2_ID', mObjRow.GetFieldValueAsString('ID'));
                          mJoMIPL.SetFieldValueAsString('RealStoreCard_ID',mObjRow.GetFieldValueAsString('StoreCard_ID'));

                       end;
                     end;
                 end;
                 NxScriptingLog.WriteEvent(logInfo,'založil jsem VMV '+mVMVHeadBO.DisplayName+' a provedl jsem vazby');
                mvmvheadbo.free;
                end;






           end;
         end;
       end;


     end;   }
   {  if mVYPBO.NeedSave then mvypbo.save;
   NxScriptingLog.LeaveSection('CreateVMV',loginfo);
 end;     }
end;




function GetAvailableQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID, aStore_ID:string): extended;
const
  cSQL = 'SELECT Quantity FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetDistributedQuantity(var AOS : TNxCustomObjectSpace;var aOID:string): extended;
const
  cSQL = 'SELECT sum(sd2.Quantity) FROM PLMMIPLMaterialDistrib p left join storedocuments2 sd2 on sd2.id=p.StoreDocument2_id WHERE p.parent_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.