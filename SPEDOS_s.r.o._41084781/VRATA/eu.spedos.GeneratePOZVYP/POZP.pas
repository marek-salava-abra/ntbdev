const
 cStorePolotovary='1B00000101';
 cFirm_ID='AG21000101';

procedure CalculateDataForPOZ(mBO:TNxCustomBusinessObject);
var
 mList:tstringlist;
  mNodeBO, mInputBO, mOutputBO:TNxCustomBusinessObject;
 mOutputs, mInputs, mNodes:TNxCustomBusinessMonikerCollection;
 i,j,k,l:integer;
 mOS:TNxCustomObjectSpace;
begin
 mOS:=mbo.ObjectSpace;
 mList:=TStringList.Create;
 if Assigned(mBO) then begin
   mInputs:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));
   mOutputs:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Outputs'));
   mNodes:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Nodes'));
   NxScriptingLog.WriteEvent(logInfo,'mám načtené uzly '+mBO.DisplayName);
   for j:=0 to mInputs.Count-1 do  begin
     mInputBO:=mInputs.BusinessObject[j];
     if (mInputBO.GetFieldValueAsInteger('Owner_ID.Issue')=1) and not(NxIsEmptyOID(mInputBO.GetFieldValueAsString('Owner_ID.Master_ID'))) and (mInputBO.GetFieldValueAsInteger('Owner_ID.TreeLevel')=2) then begin
       mList.Add(mInputBO.GetFieldValueAsString('RealStoreCard_ID')+';'+mbo.GetFieldValueAsString('Division_ID')+';'+FloatToStr(mInputBO.GetFieldValueAsFloat('Owner_ID.OutputItem_ID.Quantity')*mInputBO.GetFieldValueAsFloat('Quantity'))+';'+mbo.GetFieldValueAsString('BusTransaction_ID'));
     end;
   end;

   for i:=0 to mNodes.count-1 do begin
     mNodeBO:=mNodes.BusinessObject[i];
     if (mNodeBO.GetFieldValueAsInteger('Issue')=1) and not(NxIsEmptyOID(mnodebo.GetFieldValueAsString('Master_ID'))) then begin
       mNodeBO.SetFieldValueAsInteger('Issue',0);
       mNodeBO.SetFieldValueAsString('Store_ID',cStorePolotovary);
     end;
   end;
   if mbo.NeedSave then mbo.Save;
 end;
 if mList.count>0 then begin GeneratePOZP(mOS, mList,  mBO);


 end;
end;

function GeneratePOZP(var AOS:TNxCustomObjectSpace; var aList:TStringList; var aBOTest:TNxCustomBusinessObject):boolean;
var
 mPOZBO, mStoreCardBO, mPOZNodeBO, mTestPOZBO, mTestPOZNodeBO:TNxCustomBusinessObject;
 mStoreQuantity, mPOZPQuantity, mVYPPQuantity, mMinQuanity, mRequestedQuantity, mQuantity:Extended;
 i, j, k, l:integer;
 mStoreCard_ID, mDivision_ID, mBusTransaction_ID:string;
 mPOZBONodes, mTestInputs:TNxCustomBusinessMonikerCollection;
 mPOZList:TStringList;
 mGenerate:Boolean;
begin
 mPOZList:=TStringList.create;
 for i:=0 to aList.Count-1 do begin
   mStoreCard_ID:=NxToken(aList.strings[i],';');
   mDivision_ID:=NxToken(aList.strings[i],';');
   mRequestedQuantity:=NxIBStrToFloat(NxToken(aList.strings[i],';'));
   mBusTransaction_ID:=NxToken(aList.strings[i],';');
   mStoreCardBO:=aos.CreateObject(Class_StoreCard);
   mStoreCardBO.Load(mStoreCard_ID,nil);
   mMinQuanity:=mStoreCardBO.GetFieldValueAsFloat('X_Optimal_Batch');
   //NxShowSimpleMessage(mStoreCardBO.DisplayName,nil);
   mQuantity:=0;
   mStoreQuantity:=GetAvailableQuantity(aos,mStoreCard_ID,cStorePolotovary);
   mPOZPQuantity:=GetPOZPQuantity(AOS,mStoreCard_ID);
   mVYPPQuantity:=GetVYPPQuantity(AOS,mStoreCard_ID);
   if mStoreQuantity+mPOZPQuantity+mVYPPQuantity<mRequestedQuantity then mQuantity:=Max_1(mMinQuanity,mRequestedQuantity);
   if mQuantity>0 then begin
       mGenerate:=True;
       if mPOZList.Count>0 then begin
          mGenerate:=True;
          for k:=0 to mPOZList.Count-1 do begin
             mTestPOZBO:=AOS.CreateObject(Class_PLMProduceRequest);
             mTestPOZBO.Load(mPOZList.Strings[k],nil);
             mTestInputs:=mTestPOZBO.GetLoadedCollectionMonikerForFieldCode(mTestPOZBO.GetFieldCode('Inputs'));
             for l:=0 to mTestInputs.Count-1 do begin
               //if not(mGenerate) then begin
                 if mStoreCard_ID=mTestInputs.BusinessObject[l].GetFieldValueAsString('RealStoreCard_ID') then mGenerate:=False;

               //end;
             end;
             mTestPOZBO.free;
          end;
       end;
       if mGenerate then begin

       mPOZBO:=aos.CreateObject(Class_PLMProduceRequest);
       mPOZBO.New;
       mPOZBO.prefill;
       //NxShowSimpleMessage(aBOTest.GetFieldValueAsString('BusTransaction_ID'),nil);
       mPOZBO.SetFieldValueAsString('DocQueue_ID','1L20000101');
       mPOZBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
       mPOZBO.SetFieldValueAsString('Firm_ID',cFirm_ID);
       mPOZBO.SetFieldValueAsFloat('Quantity',mQuantity);
       mPOZBO.SetFieldValueAsFloat('CorrectedQuantity',mQuantity);
       mPOZBO.SetFieldValueAsString('Division_ID',mDivision_ID);
       mPOZBO.SetFieldValueAsString('BusTransaction_ID',aBOTest.GetFieldValueAsString('BusTransaction_ID'));
       mPOZBO.SetFieldValueAsString('Store_ID',cStorePolotovary);
       mPOZBO.save;
       mPOZList.Add(mPOZBO.OID);
       mPOZBO.free;
      end;
   end;
   mstorecardbo.Free;
 end;
 mPOZList.free;
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

function GetPOZPQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID:string): extended;
const
  cSQL = 'SELECT sum(Quantity) FROM PLMProduceRequests WHERE StoreCard_ID=''%s'' and joborder_id is Null ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetVYPPQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID:string): extended;
const
  cSQL = 'SELECT ID FROM PLMJObOrders WHERE StoreCard_ID=''%s'' and FinishedBy_ID is Null ';
  cSQL2 =  'Select sum(fp2.quantity) from PLMFinishedProducts fp left join PLMFinishedProducts2 fp2 on fp.id=fp2.parent_id where fp.JobOrder_ID=''%s'' ';
var
  mList, mList2 : TStringList;
  mBO:TNxCustomBusinessObject;
  i:Integer;
  mResult:Extended;
begin
  mList := TStringList.Create;
  mResult:=0;
  Result:=0;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then begin
      for i:=0 to mList.count-1 do begin;
      mList2 := TstringList.Create;
      mbo:=aos.CreateObject(Class_PLMJobOrder);
      mbo.Load(mlist.strings[i], nil);
      AOS.SQLSelect(Format(cSQL2, [mbo.OID]), mList2);
      if mbo.GetFieldValueAsFloat('Quantity')-StrToFloat(mList2.Strings[0])>0 then  mResult := mResult+mbo.GetFieldValueAsFloat('Quantity')-StrToFloat(mList2.Strings[0]);
      mlist2.Free;
      mbo.free;
    end;
    end;
  finally
    Result:=mresult;
    mList.Free;
  end;
end;

begin
end.