



procedure GenerateVMVbyAW (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mVYPBO, mInputBO, mVMVHeadBO, mVMVRowBO,mJoMIPLMD,mJoMIPL,mObjRow:TNxCustomBusinessObject;
 mInputItems, mRows,mJoMIPLMDMon, mObjRowsMon,mMaterialDistrMon:TNxCustomBusinessMonikerCollection;
 i,j,y,k,l,z,n:integer;
 mImport:Boolean;
 mAvailableQuantity,mVMVRowQuantity, mDistributedQuantity, mQuantity, mKoeficient, mDiv:Extended;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mRowBO:TNxCustomBusinessObject;
 mPhase_ID, mVMV_ID, mPhaseCode, mString, mString2:string;
 mPLList, mVMVList:TStringList;
 mPLBO, mVMVBO:TNxCustomBusinessObject;
begin
  mPLList:=TStringList.Create;
  OS.SQLSelect(format('SELECT A.ID FROM PLMOperations A '+
                      'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
                      'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
                      'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
                      'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
                      'WHERE  (JO.DocQueue_ID IN (''2F10000101'')) AND (A.StartedAt$Date >= %s) AND (A.X_VMVGenerated LIKE ''N'') and a.quantity>0 and jo.finishedby_id is null ',[IntToStr(Trunc(Date-1))]),mPLList);
  if mPLList.count>0 then begin
  for k:=0 to mPLList.count-1 do begin
  mPLBO:=OS.CreateObject(Class_PLMOperation);
  mplbo.Load(mPLList.strings[k],nil);
  mVMVList:=TStringList.Create;
  OS.SQLSelect(format('select id from storedocuments where X_WT_ID=''%s'' ',[mPLBO.OID]),mVMVList);
  if mVMVList.Count>0 then begin
   for n:=0 to mVMVList.count-1 do begin
    try
     mVMVBO:=os.CreateObject(Class_MaterialDistribution);
     mVMVBO.Load(mVMVList.strings[n],nil);
     mVMVBO.Delete;
    except
    end;
   end;
  end;
  mVMVList.free;
  mPLBO.SetFieldValueAsString('X_Exception','');
  if mPLBO.GetFieldValueAsFloat('TotalTime')=0 then mPLBO.SetFieldValueAsFloat('TotalTime',0.001);
  if (not(mPLBO.getFieldValueAsBoolean('JobOrdersRoutines_ID.finished')) or (mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID.DocQueue_ID')='2L20000101'))and (mPLBO.GetFieldvalueasfloat('quantity')>0)  then begin
    NxScriptingLog.EnterSection('CreateVMV',logInfo);
     mPhase_ID:=mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID');
     mPhaseCode:=mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID.Code');
     mVYPBO:=mPLBO.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mVYPBO.load(mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
     NxScriptingLog.WriteEvent(loginfo,'Výrobní příkaz '+mVYPBO.DisplayName);
     mInputItems:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
     mDiv:=mPLBO.GetFieldValueAsFloat('JobOrdersRoutines_ID.PlannedQuantity');
     if mDiv=0 then mDiv:=1;
     mKoeficient:=mPLBO.GetFieldValueAsFloat('Quantity')/mDiv;
     mVMV_ID:='';
     NxScriptingLog.WriteEvent(logInfo,FloatToStr(mKoeficient)+' mDiv '+FloatToStr(mDiv));
      try
          l:=0;
          mString:='';
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := '1H10000101';
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mVYPBO.GetFieldValueAsString('Firm_ID');
          mParam :=  mInputParams.GetOrCreateParam(dtInteger, 'MethodOfMD');
          mParam.AsInteger := 0;
          //mParam.AsInteger := 1;         //změna dne 8.2.2024 na žádost Maler@pruser.sro
          mParam := mInputParams.GetOrCreateParam(dtList,'JOQuantities').AsList;
          mParam.AsList.GetOrCreateParam(dtfloat,mVYPBO.OID).AsFloat:= mPLBO.GetFieldValueAsFloat('Quantity');
          mImportMan := NxCreateDocumentImportManager(mVYPBO.ObjectSpace, Class_PLMJobOrder, Class_MaterialDistribution);
          mImportMan.AddInputDocument(mVYPBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mPLBO.GetFieldValueAsDateTime('DocDate$DATE'));
          mImportMan.OutputDocument.SetFieldValueAsString('X_WT_ID',mPLBO.OID);
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            for z:=0 to mRows.count-1 do begin
              mRowBO:=mrows.BusinessObject[z];
              mAvailableQuantity:=GetAvailableQuantity(mPLBO.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
              //if (mAvailableQuantity>0) then begin
              //  if mRowBO.GetFieldValueAsFloat('Quantity')> mAvailableQuantity then
                 //mRowBO.SetFieldValueAsFloat('Quantity',NxRoundByValue(mRowBO.GetFieldValueAsFloat('Quantity')*mKoeficient,ctUp,0.01)) else
              //   mRowBO.SetFieldValueAsFloat('Quantity', mAvailableQuantity);
                 //NxScriptingLog.WriteEvent(loginfo,'Množství bylo kladné '+mRowbo.GetFieldValueAsString('StoreCard_ID.Name')+'   '+FloatToStr(mAvailableQuantity)+'    vydáno '+FloatToStr(mrowbo.GetFieldValueAsFloat('Quantity')));
              //end;
              if mAvailableQuantity<mRowBO.GetFieldValueAsFloat('Quantity') then mRowBO.SetFieldValueAsFloat('Quantity',mAvailableQuantity);
              //mString:=mString+#13#10+'Množství kartě '+mRowbo.GetFieldValueAsString('StoreCard_ID.Name')+'   '+FloatToStr(mAvailableQuantity)+'    vydáno '+FloatToStr(mrowbo.GetFieldValueAsFloat('Quantity'));

              if mAvailableQuantity=0 then  mRowBO.MarkForDelete else begin
                l:=l+1;
                mString:=mString+#13#10+'Název karty '+mRowbo.GetFieldValueAsString('StoreCard_ID.Name')+'   stav skladu '+FloatToStr(mAvailableQuantity)+'    vydáno '+FloatToStr(mrowbo.GetFieldValueAsFloat('Quantity'));
              end;
            end;
          mImportMan.OutputDocument.SetFieldValueAsString('Description','AS '+mVYPBO.GetFieldValueAsString('U_vyrobni_cislo'));
          if mRows.CountOfNotDeleted>0 then begin

            mImportMan.OutputDocument.save;
            mPLBO.SetFieldValueAsString('X_VMVNumber',mImportMan.OutputDocument.DisplayName);
            mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+'Výdej '+mImportMan.OutputDocument.DisplayName+' byl založen v '+DateTimeToStr(now)+' a má '+IntToStr(l)+' řádků.'+mString);
            mVMV_ID:=mImportMan.OutputDocument.OID;
          end else begin
            mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+'Doklad by neměl řádky. čas '+DateTimeToStr(now)+' '+mString);
          end;
          //NxScriptingLog.WriteEvent(logInfo,'Založen doklad :'+mImportMan.OutputDocument.DisplayName);
          mImportMan.free;

          if not(NxIsEmptyOID(mVMV_ID)) then begin
          mVMVHeadBO:=mPLBO.ObjectSpace.CreateObject(Class_MaterialDistribution);
          mVMVHeadBO.Load(mVMV_ID,nil);
          //NxScriptingLog.WriteEvent(logInfo,'Nahrán doklad :'+mVMVHeadBO.DisplayName);
          mRows:=mVMVHeadBO.GetLoadedCollectionMonikerForFieldCode(mVMVHeadBO.GetFieldCode('Rows'));
          mString2:='';
          for j:=0 to mInputItems.Count-1 do begin

            mInputBO:=mInputItems.BusinessObject[j];
            mMaterialDistrMon:=mInputBO.GetLoadedCollectionMonikerForFieldCode(mInputBO.GetFieldCode('PLMMIPLMaterialDistribution'));
            for i:=0 to mMaterialDistrMon.Count-1 do begin
              for z:=0 to mRows.count-1 do begin
                mRowBO:=mrows.BusinessObject[z];
                //NxScriptingLog.WriteEvent(logInfo, );
                if mRowBO.OID=mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('StoreDocument2_ID') then begin
                 //NxScriptingLog.WriteEvent(logInfo,mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+' Máme shodu s MaterialDistrib Etapa_ID: '+mPhase_ID+'   etapa z materialdistrib'+mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID')+' počet nesmazaných řádků '+IntToStr(mrows.CountOfNotDeleted));
                  if NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusTransaction_ID')) then mRowBO.SetFieldValueAsString('BusTransaction_ID',mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.U_BusTransaction_ID'));
                   if not(mPhase_ID=mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID')) then begin
                    //NxScriptingLog.WriteEvent(logInfo,' Není shoda Etapy');
                    mString2:=mString2+#13#10+'Odmazávám položku '+mRowBO.GetFieldValueAsString('StoreCard_ID.name')+' z důvodu neshody etapy '+mPhaseCode+' s etapou '+mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID.Code');
                    mRowBO.MarkForDelete;
                   end;
                end;
              end;
            end;
          end;

          if mRows.CountOfNotDeleted>0 then begin
            mVMVHeadBO.save;
            mPLBO.SetFieldValueAsBoolean('X_VMVGenerated',true);
            mPLBO.SetFieldValueAsString('X_VMVNumber',mVMVHeadBO.DisplayName);
          end else begin
            mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+'odmazáno:'+#13#10+mString2+#13#10+
            'Výdej '+mVMVHeadBO.DisplayName+' byl smazán v '+DateTimeToStr(now)+' z důvodu neshodnosti etapy '+mPhaseCode);
            mPLBO.SetFieldValueAsBoolean('X_VMVGenerated',false);
            mPLBO.SetFieldValueAsString('X_VMVNumber','');
            mVMVHeadBO.Delete;
          end;
          end;
          //mVMVHeadBO.free;
          //NxScriptingLog.WriteEvent(logInfo,'Copak se tu asi stalo');
       Except
         NxScriptingLog.WriteEvent(loginfo,ExceptionMessage);
         mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+ExceptionMessage+#13#10+mString);
       end;

     if mVYPBO.NeedSave then mvypbo.save;
   NxScriptingLog.LeaveSection('CreateVMV',loginfo);
  end;
  mplbo.save;
  mplbo.free;
  end;
  end;
  try
     os.SQLExecute('delete from datachangeslogs where clsid=''2MV0SHPYLFJOL3D4WN02HCPX5S'' and  createdby_id=''SUPER00000'' ');
     os.SQLExecute('delete from datachangeslogs where clsid=''HTI3OTLGNRPO32EEISEPC0XZ0K'' and  createdby_id=''SUPER00000'' ');
   except
  end;
  Success := True;
  LogInfoStr := 'Zpracováno '+inttostr(mPLList.count)+' lístků';
  mPLList.free;
end;

procedure GenerateVMVbyAWforVYPP (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mVYPBO, mInputBO, mVMVHeadBO, mVMVRowBO,mJoMIPLMD,mJoMIPL,mObjRow:TNxCustomBusinessObject;
 mInputItems, mRows,mJoMIPLMDMon, mObjRowsMon,mMaterialDistrMon:TNxCustomBusinessMonikerCollection;
 i,j,y,k,l,z,n:integer;
 mImport:Boolean;
 mAvailableQuantity,mVMVRowQuantity, mDistributedQuantity, mQuantity, mKoeficient, mDiv:Extended;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mRowBO:TNxCustomBusinessObject;
 mPhase_ID, mVMV_ID, mPhaseCode, mString, mString2:string;
 mPLList, mVMVList:TStringList;
 mPLBO, mVMVBO:TNxCustomBusinessObject;
begin
  mPLList:=TStringList.Create;
  OS.SQLSelect(format('SELECT A.ID FROM PLMOperations A '+
                      'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
                      'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
                      'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
                      'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
                      'WHERE  (JO.DocQueue_ID IN (''2L20000101'')) AND (A.StartedAt$Date >= %s) AND (A.X_VMVGenerated LIKE ''N'') and a.quantity>0 and jo.finishedby_id is null ',[IntToStr(Trunc(Date))]),mPLList);
  if mPLList.count>0 then begin
  for k:=0 to mPLList.count-1 do begin
  mPLBO:=OS.CreateObject(Class_PLMOperation);
  mplbo.Load(mPLList.strings[k],nil);
  mVMVList:=TStringList.Create;
  OS.SQLSelect(format('select id from storedocuments where X_WT_ID=''%s'' ',[mPLBO.OID]),mVMVList);
  if mVMVList.Count>0 then begin
   for n:=0 to mVMVList.count-1 do begin
    try
     mVMVBO:=os.CreateObject(Class_MaterialDistribution);
     mVMVBO.Load(mVMVList.strings[n],nil);
     mVMVBO.Delete;
    except
    end;
   end;
  end;
  mVMVList.free;
  mPLBO.SetFieldValueAsString('X_Exception','');
  if mPLBO.GetFieldValueAsFloat('TotalTime')=0 then mPLBO.SetFieldValueAsFloat('TotalTime',0.001);
  if (not(mPLBO.getFieldValueAsBoolean('JobOrdersRoutines_ID.finished')) or (mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID.DocQueue_ID')='2L20000101'))and (mPLBO.GetFieldvalueasfloat('quantity')>0)  then begin
    NxScriptingLog.EnterSection('CreateVMV',logInfo);
     mPhase_ID:=mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID');
     mPhaseCode:=mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID.Code');
     mVYPBO:=mPLBO.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mVYPBO.load(mPLBO.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
     NxScriptingLog.WriteEvent(loginfo,'Výrobní příkaz '+mVYPBO.DisplayName);
     mInputItems:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
     mDiv:=mPLBO.GetFieldValueAsFloat('JobOrdersRoutines_ID.PlannedQuantity');
     if mDiv=0 then mDiv:=1;
     mKoeficient:=mPLBO.GetFieldValueAsFloat('Quantity')/mDiv;
     mVMV_ID:='';
     NxScriptingLog.WriteEvent(logInfo,FloatToStr(mKoeficient)+' mDiv '+FloatToStr(mDiv));
      try
          l:=0;
          mString:='';
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := '1H10000101';
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mVYPBO.GetFieldValueAsString('Firm_ID');
          mParam :=  mInputParams.GetOrCreateParam(dtInteger, 'MethodOfMD');
          //mParam.AsInteger := 0;
          mParam.AsInteger := 1;         //změna dne 8.2.2024 na žádost Maler@pruser.sro následně 22.7. rozděleno na dvě úlohy VYP a VYPP
          mParam := mInputParams.GetOrCreateParam(dtList,'JOQuantities').AsList;
          mParam.AsList.GetOrCreateParam(dtfloat,mVYPBO.OID).AsFloat:= mPLBO.GetFieldValueAsFloat('Quantity');
          mImportMan := NxCreateDocumentImportManager(mVYPBO.ObjectSpace, Class_PLMJobOrder, Class_MaterialDistribution);
          mImportMan.AddInputDocument(mVYPBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mPLBO.GetFieldValueAsDateTime('DocDate$DATE'));
          mImportMan.OutputDocument.SetFieldValueAsString('X_WT_ID',mPLBO.OID);
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            for z:=0 to mRows.count-1 do begin
              mRowBO:=mrows.BusinessObject[z];
              mAvailableQuantity:=GetAvailableQuantity(mPLBO.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
              //if (mAvailableQuantity>0) then begin
              //  if mRowBO.GetFieldValueAsFloat('Quantity')> mAvailableQuantity then
                 //mRowBO.SetFieldValueAsFloat('Quantity',NxRoundByValue(mRowBO.GetFieldValueAsFloat('Quantity')*mKoeficient,ctUp,0.01)) else
              //   mRowBO.SetFieldValueAsFloat('Quantity', mAvailableQuantity);
                 //NxScriptingLog.WriteEvent(loginfo,'Množství bylo kladné '+mRowbo.GetFieldValueAsString('StoreCard_ID.Name')+'   '+FloatToStr(mAvailableQuantity)+'    vydáno '+FloatToStr(mrowbo.GetFieldValueAsFloat('Quantity')));
              //end;
              if mAvailableQuantity<mRowBO.GetFieldValueAsFloat('Quantity') then mRowBO.SetFieldValueAsFloat('Quantity',mAvailableQuantity);
              //mString:=mString+#13#10+'Množství kartě '+mRowbo.GetFieldValueAsString('StoreCard_ID.Name')+'   '+FloatToStr(mAvailableQuantity)+'    vydáno '+FloatToStr(mrowbo.GetFieldValueAsFloat('Quantity'));

              if mAvailableQuantity=0 then  mRowBO.MarkForDelete else begin
                l:=l+1;
                mString:=mString+#13#10+'Název karty '+mRowbo.GetFieldValueAsString('StoreCard_ID.Name')+'   stav skladu '+FloatToStr(mAvailableQuantity)+'    vydáno '+FloatToStr(mrowbo.GetFieldValueAsFloat('Quantity'));
              end;
            end;
          mImportMan.OutputDocument.SetFieldValueAsString('Description','AS '+mVYPBO.GetFieldValueAsString('U_vyrobni_cislo'));
          if mRows.CountOfNotDeleted>0 then begin

            mImportMan.OutputDocument.save;
            mPLBO.SetFieldValueAsString('X_VMVNumber',mImportMan.OutputDocument.DisplayName);
            mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+'Výdej '+mImportMan.OutputDocument.DisplayName+' byl založen v '+DateTimeToStr(now)+' a má '+IntToStr(l)+' řádků.'+mString);
            mVMV_ID:=mImportMan.OutputDocument.OID;
          end else begin
            mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+'Doklad by neměl řádky. čas '+DateTimeToStr(now)+' '+mString);
          end;
          //NxScriptingLog.WriteEvent(logInfo,'Založen doklad :'+mImportMan.OutputDocument.DisplayName);
          mImportMan.free;

          if not(NxIsEmptyOID(mVMV_ID)) then begin
          mVMVHeadBO:=mPLBO.ObjectSpace.CreateObject(Class_MaterialDistribution);
          mVMVHeadBO.Load(mVMV_ID,nil);
          //NxScriptingLog.WriteEvent(logInfo,'Nahrán doklad :'+mVMVHeadBO.DisplayName);
          mRows:=mVMVHeadBO.GetLoadedCollectionMonikerForFieldCode(mVMVHeadBO.GetFieldCode('Rows'));
          mString2:='';
          for j:=0 to mInputItems.Count-1 do begin

            mInputBO:=mInputItems.BusinessObject[j];
            mMaterialDistrMon:=mInputBO.GetLoadedCollectionMonikerForFieldCode(mInputBO.GetFieldCode('PLMMIPLMaterialDistribution'));
            for i:=0 to mMaterialDistrMon.Count-1 do begin
              for z:=0 to mRows.count-1 do begin
                mRowBO:=mrows.BusinessObject[z];
                //NxScriptingLog.WriteEvent(logInfo, );
                if mRowBO.OID=mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('StoreDocument2_ID') then begin
                 //NxScriptingLog.WriteEvent(logInfo,mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+' Máme shodu s MaterialDistrib Etapa_ID: '+mPhase_ID+'   etapa z materialdistrib'+mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID')+' počet nesmazaných řádků '+IntToStr(mrows.CountOfNotDeleted));
                  if NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusTransaction_ID')) then mRowBO.SetFieldValueAsString('BusTransaction_ID',mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.U_BusTransaction_ID'));
                   if not(mPhase_ID=mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID')) then begin
                    //NxScriptingLog.WriteEvent(logInfo,' Není shoda Etapy');
                    mString2:=mString2+#13#10+'Odmazávám položku '+mRowBO.GetFieldValueAsString('StoreCard_ID.name')+' z důvodu neshody etapy '+mPhaseCode+' s etapou '+mMaterialDistrMon.BusinessObject[i].GetFieldValueAsString('Parent_ID.Phase_ID.Code');
                    mRowBO.MarkForDelete;
                   end;
                end;
              end;
            end;
          end;

          if mRows.CountOfNotDeleted>0 then begin
            mVMVHeadBO.save;
            mPLBO.SetFieldValueAsBoolean('X_VMVGenerated',true);
            mPLBO.SetFieldValueAsString('X_VMVNumber',mVMVHeadBO.DisplayName);
          end else begin
            mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+'odmazáno:'+#13#10+mString2+#13#10+
            'Výdej '+mVMVHeadBO.DisplayName+' byl smazán v '+DateTimeToStr(now)+' z důvodu neshodnosti etapy '+mPhaseCode);
            mPLBO.SetFieldValueAsBoolean('X_VMVGenerated',false);
            mPLBO.SetFieldValueAsString('X_VMVNumber','');
            mVMVHeadBO.Delete;
          end;
          end;
          //mVMVHeadBO.free;
          //NxScriptingLog.WriteEvent(logInfo,'Copak se tu asi stalo');
       Except
         NxScriptingLog.WriteEvent(loginfo,ExceptionMessage);
         mPLBO.SetFieldValueAsString('X_Exception',mPLBO.GetFieldValueAsString('X_Exception')+#13#10+ExceptionMessage+#13#10+mString);
       end;

     if mVYPBO.NeedSave then mvypbo.save;
   NxScriptingLog.LeaveSection('CreateVMV',loginfo);
  end;
  mplbo.save;
  mplbo.free;
  end;
  end;
  try
     os.SQLExecute('delete from datachangeslogs where clsid=''2MV0SHPYLFJOL3D4WN02HCPX5S'' and  createdby_id=''SUPER00000'' ');
     os.SQLExecute('delete from datachangeslogs where clsid=''HTI3OTLGNRPO32EEISEPC0XZ0K'' and  createdby_id=''SUPER00000'' ');
   except
  end;
  Success := True;
  LogInfoStr := 'Zpracováno '+inttostr(mPLList.count)+' lístků';
  mPLList.free;
end;



function GetAvailableQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID, aStore_ID:string): extended;
const
  cSQL = 'SELECT Quantity FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_id=''%s'' ';
var
  mList : TStringList;
  mQ:Extended;
begin
  mList := TStringList.Create;
  Result:=0;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID]), mList);
    if mList.Count > 0 then begin
      mQ := StrToFloat(mList.Strings[0]);
      if mQ>0 then Result:=mQ;
    end;
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