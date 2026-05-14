

{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);

var
 mPartList:TStringList;
 mPartFinishProduct, mJobOrder, mOutputBO, mJobOrderRoutineBO:TNxCustomBusinessObject;
 mOutPuts, mJobOrdersRoutines:TNxCustomBusinessMonikerCollection;
 mPhase_ID, mName:String;
 i, j, k, l:integer;
 mCreateFP:boolean;
 mOrigDate, mPocetBaliku:extended;
 mPrintList:TStringList;
begin
 mCreateFP:=true;
 mPrintList:=TStringList.Create;
 self.GetOriginalValue_1('FinishedAt$DATE',mOrigDate);
 if (self.GetFieldValueAsFloat('Quantity')>0) and not(mOrigDate=self.GetFieldValueAsDateTime('FinishedAt$DATE')) and not(self.GetFieldValueAsBoolean('JobOrdersRoutines_ID.Finished')) then begin
  if self.GetFieldValueAsBoolean('JobOrdersRoutines_ID.Phase_ID.X_CheckFinish') then begin
    mPhase_ID:=self.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID');
    mName:=self.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID.X_NameOfProduct');
    mJobOrder:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
    mjoborder.Load(self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
    mOutPuts:=mJobOrder.GetLoadedCollectionMonikerForFieldCode(mJobOrder.GetFieldCode('Outputs'));
     for i:=0 to mOutPuts.count-1 do begin
       mOutputBO:=mOutPuts.BusinessObject[i];
       mJobOrdersRoutines:=mOutputBO.GetLoadedCollectionMonikerForFieldCode(mOutputBO.GetFieldCode('PLMJobOrdersRoutines'));
       for j:=0 to mJobOrdersRoutines.Count-1 do begin
          mJobOrderRoutineBO:=mJobOrdersRoutines.BusinessObject[j];
          if mJobOrderRoutineBO.GetFieldValueAsString('Phase_ID')=mPhase_ID then begin
            if mJobOrderRoutineBO.oid=self.GetFieldValueAsString('JobOrdersRoutines_ID') then begin
             if mJobOrderRoutineBO.GetFieldValueAsFloat('X_pocet_baliku')=0 then mPocetBaliku:=1 else
             mPocetBaliku:=mJobOrderRoutineBO.GetFieldValueAsFloat('X_pocet_baliku');
             if (mJobOrderRoutineBO.GetFieldValueAsFloat('RealizedQuantity')+self.GetFieldValueAsFloat('Quantity'))<mJobOrderRoutineBO.GetFieldValueAsFloat('PlannedQuantity') then mCreateFP:=false;
            end else begin
              if mJobOrderRoutineBO.GetFieldValueAsFloat('RealizedQuantity')<mJobOrderRoutineBO.GetFieldValueAsFloat('PlannedQuantity') then mCreateFP:=false;
            end;
          end;
       end;
     end;
  end;
  if mCreateFP then begin
    for l:=1 to Trunc(mPocetBaliku) do begin
    mPrintList.clear;
    mPartFinishProduct:=self.ObjectSpace.CreateObject('DYSBRTUOKLPO1ISIKUJLMCEELG');
    mPartFinishProduct.new;
    mPartFinishProduct.SetFieldValueAsString('Code',mJobOrder.GetFieldValueAsString('U_vyrobni_cislo'));
    mPartFinishProduct.SetFieldValueAsString('name',mName);
    mpartfinishproduct.SetFieldValueAsString('X_BusOrder_ID',mJobOrder.GetFieldValueAsString('BusOrder_ID'));
    mPartFinishProduct.SetFieldValueAsDateTime('X_Datum_vyroby$date',Date);
    mpartfinishproduct.SetFieldValueAsString('X_joborder_ID',mJobOrder.OID);
    mPartFinishProduct.SetFieldValueAsString('X_JobOrderDispName',mJobOrder.displayname);
    mPartFinishProduct.SetFieldValueAsFloat('X_pocet_baliku',l);
    mPartFinishProduct.SetFieldValueAsString('X_Phase_ID',mPhase_ID);
    mPartFinishProduct.SetFieldValueAsString('X_ID_Pozice',mJobOrder.GetFieldValueAsString('X_Pozice'));
    mPartFinishProduct.save;
    mPrintList.Add(mPartFinishProduct.oid);
    CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace), mPrintList, 'J0NJXZXRMBC4VEHGCJKKKASDMC', '1L70000101', rtoPrint, pekARP, mPartFinishProduct.GetFieldValueAsString('X_Phase_ID.X_Printer'), '');
    mPartFinishProduct.free;
    end;
  end;

 end;
 if self.GetFieldValueAsBoolean('JobOrdersRoutines_ID.Finished') and (self.GetFieldValueAsFloat('Quantity')>0) then begin
   mPartList:=TStringList.create;
   self.ObjectSpace.SQLSelect(format('select id from defrolldata where X_JobOrder_ID=''%s'' and clsid=''DYSBRTUOKLPO1ISIKUJLMCEELG'' and hidden=''N'' ',[self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID')]),mPartList);
   if mPartList.count>0 then begin
     for k:=0 to mPartList.count-1 do begin
      try
       mPartFinishProduct:=self.ObjectSpace.CreateObject('DYSBRTUOKLPO1ISIKUJLMCEELG');
       mPartFinishProduct.load(mPartList.strings[k],nil);
       mPartFinishProduct.Delete;
     Except
     end;

     end;
   end;
 end;
end;



{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se před fyzickým vymazáním vlastního objektu z databáze.
}
procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
 mStream:TMemoryStream;
 mBO:TNxCustomBusinessObject;
begin
  try
   mBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
   mbo.Load(self.getfieldvalueasstring('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
  //if osNew in self.State then begin
     mStream := TMemoryStream.Create;
     //if self.GetFieldValueAsFloat('Quantity')=0 then begin
      NxScriptingLog.WriteEvent(logInfo,'https://sod.spedos.cz/api/api.abra-vyroba.php?'+
      'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mbo.GetFieldValueAsString('U_id_vyrobku') +
      '&action=delete' +
      '&abra_id='+self.OID);
     CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyroba.php?',
      'user=aBra&password=skS8f-sxR&action=delete' +
      '&abra_id='+self.OID,mStream);
     //end;
     mStream.Free;
  Except
  end;
end;

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsBoolean('JobOrdersRoutines_ID.X_fix') and (self.GetFieldValueAsDateTime('FinishedAt$DATE')<0) then begin
    self.SetFieldValueAsDateTime('TotalTime',self.GetFieldValueAsFloat('JobOrdersRoutines_ID.TAC'));
    self.SetFieldValueAsFloat('Quantity',1);
    self.SetFieldValueAsBoolean('OperationResult',true);
  end;
end;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mStream:TMemoryStream;
 mBO, mOutPutBO:TNxCustomBusinessObject;
 mOutputs, mSerials:TNxCustomBusinessMonikerCollection;
 mS_User:string;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
begin
  NxScriptingLog.EnterSection('VytvoreniPL',logInfo);
  mS_User:='';
  mBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
  mbo.Load(self.getfieldvalueasstring('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
  NxScriptingLog.WriteEvent(logInfo,'https://sod.spedos.cz/api/api.abra-vyroba.php?'+
      'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mbo.GetFieldValueAsString('U_id_vyrobku') +
      '&cislo_vyrobniho_prikazu='+ mbo.DisplayName+
      '&cislo_etapy='+self.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID.Code')+
      '&datum_zahajeno='+ FormatDateTime('YYYY-MM-DD hh:mm:ss',self.GetFieldValueAsDateTime('StartedAt$DATE')) +
      '&datum_ukonceno='+ FormatDateTime('YYYY-MM-DD hh:mm:ss',self.GetFieldValueAsDateTime('FinishedAt$DATE')) +
      '&pocet_vyrobeno='+ inttostr(trunc(self.GetFieldValueAsFloat('Quantity')))+
      '&pocet_vyrobit='+ inttostr(trunc(mbo.GetFieldValueAsFloat('Quantity')))+
      '&vyrobil='+ self.GetFieldValueAsString('PerformedBy_ID.Person_ID.FullName')+
      '&abra_user='+mS_User+
      '&abra_id=');
  if NxIsEmptyOID(self.GetFieldValueAsString('JobOrdersSN_ID')) and (self.GetFieldValueAsDateTime('FinishedAt$DATE')>10000) and ((self.getfieldvalueasfloat('UnitQuantity')=1) or (self.getfieldvalueasfloat('UnitQuantity')=0)) then begin
  NxScriptingLog.WriteEvent(logInfo,'jdu zapsat');
   mOutputs:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('OutPuts'));
   mOutPutBO:=mOutputs.BusinessObject[0];
   mSerials:=mOutPutBO.GetLoadedCollectionMonikerForFieldCode(mOutPutBO.Getfieldcode('PLMJobOrdersSN'));
   if mSerials.Count>0 then begin
    NxScriptingLog.WriteEvent(logInfo,mSerials.BusinessObject[0].GetFieldValueAsString('StoreBatch_ID.name'));
    if not(NxIsEmptyOID(mSerials.BusinessObject[0].GetFieldValueAsString('StoreBatch_ID'))) then self.SetFieldValueAsString('JobOrdersSN_ID',mSerials.BusinessObject[0].OID);
   end;
  end;
  //if osNew in self.State then begin
     mStream := TMemoryStream.Create;
     //if self.GetFieldValueAsFloat('Quantity')=0 then begin
   //NxShowSimpleMessage(mBO.DisplayName+' '+mbo.GetFieldValueAsString('U_id_vyrobku'),nil);
   if not(mbo.GetFieldValueAsString('U_id_vyrobku')='00000000') then begin
    if not(NxIsBlank(mbo.GetFieldValueAsString('U_id_vyrobku'))) then
     try
     CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyroba.php?',
      'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mbo.GetFieldValueAsString('U_id_vyrobku') +
      '&cislo_vyrobniho_prikazu='+ mbo.DisplayName+
      '&cislo_etapy='+self.GetFieldValueAsString('JobOrdersRoutines_ID.Phase_ID.Code')+
      '&datum_zahajeno='+ FormatDateTime('YYYY-MM-DD hh:mm:ss',self.GetFieldValueAsDateTime('StartedAt$DATE')) +
      '&datum_ukonceno='+ FormatDateTime('YYYY-MM-DD hh:mm:ss',self.GetFieldValueAsDateTime('FinishedAt$DATE')) +
      '&pocet_vyrobeno='+ inttostr(trunc(self.GetFieldValueAsFloat('Quantity')))+
      '&pocet_vyrobit='+ inttostr(trunc(mbo.GetFieldValueAsFloat('Quantity')))+
      '&vyrobil='+ self.GetFieldValueAsString('PerformedBy_ID.Person_ID.FullName')+
      '&abra_user='+mS_User+
      '&abra_id='+self.OID,mStream);
     if self.GetFieldValueAsBoolean('JobOrdersRoutines_ID.Finished') then begin
     {
     CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyrobek.php?',
      'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mbo.GetFieldValueAsString('U_id_vyrobku') +
      '&datum_vyrobeno='+ FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('FinishedAt$DATE')) +
      '&abra_id='+self.OID,mStream);   }
                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek.php?ID_montaz_vyrobky=' + mbo.GetFieldValueAsString('U_id_vyrobku') +
                                                    '&datum_vyrobeno='+ FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('FinishedAt$DATE')) +
                                                    '&Rodneico='+ GetICO(self.ObjectSpace)+
                                                    '&abra_id='+self.OID);
                              mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP2.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
                              //NxShowSimpleMessage(mJSON.AsString,nil);

        end;

      except
       NxScriptingLog.WriteEvent(logInfo,ExceptionMessage);
      end;
     end;
     mStream.Free;
  //end;
   NxScriptingLog.LeaveSection('VytvoreniPL',logInfo);
end;

function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

begin
end.