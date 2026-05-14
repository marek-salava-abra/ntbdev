uses 'eu.spedos.createPOZP.const', 'eu.spedos.createPOZP.fce';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvoří polotovary';
  mAction.Hint := 'Vygeneruje polotovary do chybějícího množství';
  mAction.Items.Add('Vytvoří polotovary');
  //mAction.Items.Add('Vytvoří polotovary s hláškou');
  //mAction.Items.Add('Vytvoří polotovary 1. úrovně');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CalcucateDataForPOZ;
end;

procedure CalcucateDataForPOZ(Sender:TAction; Index:Integer);
var
 mList:tstringlist;
 mSite:TSiteForm;
 mBO, mNodeBO, mInputBO, mOutputBO:TNxCustomBusinessObject;
 mOutputs, mInputs, mNodes:TNxCustomBusinessMonikerCollection;
 i,j,k,l:integer;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mList:=TStringList.Create;
 mOS:=mbo.ObjectSpace;
 if Assigned(mBO) then begin
   mInputs:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));
   mOutputs:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Outputs'));
   mNodes:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Nodes'));
   for j:=0 to mInputs.Count-1 do  begin
     mInputBO:=mInputs.BusinessObject[j];
     {NxShowSimpleMessage('způsob výdeje '+IntToStr(mInputBO.GetFieldValueAsInteger('Owner_ID.Issue'))+#13#10+
                         ' id mastera '+mInputBO.GetFieldValueAsString('Owner_ID.Master_ID')+#13#10+
                         ' Výrobek master ' +mInputBO.GetFieldValueAsString('Owner_ID.StoreCard_ID.Name')+#13#10+
                         ' název karty '+mInputBO.GetFieldValueAsString('RealStoreCard_ID.Name')+#13#10+
                         ' kód karty '+mInputBO.GetFieldValueAsString('RealStoreCard_ID.Code')+#13#10+
                         ' množství '+FloatToStr(mInputBO.GetFieldValueAsFloat('Quantity'))+#13#10+
                         ' množství vlastník'+FloatToStr(mInputBO.GetFieldValueAsFloat('Owner_ID.OutputItem_ID.Quantity'))+#13#10+'nic',mSite); }
     if (mInputBO.GetFieldValueAsInteger('Owner_ID.Issue')=1) and not(NxIsEmptyOID(mInputBO.GetFieldValueAsString('Owner_ID.Master_ID'))) and (Index<2) then begin
       mList.Add(mInputBO.GetFieldValueAsString('RealStoreCard_ID')+';'+mbo.GetFieldValueAsString('Division_ID')+';'+FloatToStr(mInputBO.GetFieldValueAsFloat('Owner_ID.OutputItem_ID.Quantity')*mInputBO.GetFieldValueAsFloat('Quantity')));
     end;
     if (mInputBO.GetFieldValueAsInteger('Owner_ID.Issue')=1) and not(NxIsEmptyOID(mInputBO.GetFieldValueAsString('Owner_ID.Master_ID'))) and (Index=2) and (mInputBO.GetFieldValueAsInteger('Owner_ID.TreeLevel')=2) then begin
       //NxShowSimpleMessage(mInputBO.GetFieldValueAsString('RealStoreCard_ID.code')+' '+mInputBO.GetFieldValueAsString('RealStoreCard_ID.Name')+'  level '+ IntToStr(mInputBO.GetFieldValueAsInteger('Owner_ID.TreeLevel')),mSite);
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
 if mList.count>0 then begin
    GeneratePOZP(mOS, mList, Index, mBO);


 end;
end;


function GeneratePOZP(var AOS:TNxCustomObjectSpace; var aList:TStringList; var aIndex:Integer; var aBOTest:TNxCustomBusinessObject):boolean;
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
   if aIndex=1 then
   NxShowSimpleMessage('Karta '+mStoreCardBO.DisplayName+#13#10+#13#10+
                       'Min množství '+FloatToStr(mMinQuanity)+#13#10+#13#10+
                       'Skladem    '+FloatToStr(mStoreQuantity)+#13#10+
                       'POZ        '+FloatToStr(mPOZPQuantity)+#13#10+
                       'VYP        '+FloatToStr(mVYPPQuantity)+#13#10+#13#10+
                       'z dávky    '+FloatToStr(mRequestedQuantity)+#13#10+#13#10+
                       'Vyrábět    '+FloatToStr(mQuantity),nil);

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
       if mGenerate and (aIndex=1) then NxShowSimpleMessage('budeme vyrábět kartu '+mstorecardbo.DisplayName+'  v množství '+FloatToStr(mQuantity),nil);
       if not(mGenerate)  and (aIndex=1) then NxShowSimpleMessage('Nebudeme vyrábět kartu '+mStoreCardBO.DisplayName,nil);
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
       if aIndex<2 then begin
         mPOZBONodes:=mPOZBO.GetLoadedCollectionMonikerForFieldCode(mpozbo.GetFieldCode('Nodes'));
         for j:=0 to mPOZBONodes.count-1 do begin
           mPOZNodeBO:=mPOZBONodes.BusinessObject[j];
           {if (mPOZNodeBO.GetFieldValueAsInteger('Issue')=1) and not(NxIsEmptyOID(mPOZNodeBO.GetFieldValueAsString('Master_ID'))) then begin
             mPOZNodeBO.SetFieldValueAsInteger('Issue',0);
             mPOZNodeBO.SetFieldValueAsString('Store_ID',cStorePolotovary);
           end; }
         end;
       end;
       mPOZBO.save;
       mPOZList.Add(mPOZBO.OID);
       mPOZBO.free;
      end;
   end;
   mstorecardbo.Free;
 end;
 mPOZList.free;
end;

begin
end.