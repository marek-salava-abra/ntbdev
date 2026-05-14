procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := '## Kalkulovat ##';
    mAction.Items.Add('Kalkulovat - průměr');
   // mAction.Items.Add('Kalkulovat - kalkulační ceník');
    mAction.Hint := 'Provede nápočet kalkulace.';
    mAction.Category := 'tabList';
    mAction.OnExecuteItem := @Calculate;
end;

Procedure Calculate(sender:TComponent; index:integer);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mInputBO:TNxCustomBusinessObject;
 i,j,k:integer;
 mReqBO:TNxPLMProduceRequest;
 aWar, aErr:string;
 mPrice, mPrice2:Extended;
 mInputs,mPLMReqRoutines:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  TDynSiteForm(msite).list.GetSelectedId(mlist);

    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=0 to mlist.count-1 do begin

         mBO:=mOS.CreateObject(Class_PLMProduceRequest);
         mbo.Load(mlist.Strings[i],nil);
         mReqBO:=TNxPLMProduceRequest(mBO);
         mReqBO.GenerateAlwaysProduce(aWar,aErr);
         {mInputs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Inputs'));
             for j:=0 to mInputs.count-1 do begin
               mInputBO:=mInputs.BusinessObject[j];
               if index=0 then mInputBO.SetFieldValueAsInteger('CostingMethod',0);
               if index=1 then begin
                 mInputBO.SetFieldValueAsInteger('CostingMethod',2);
                 //NxShowSimpleMessage(mInputBO.GetFieldValueAsString('RealStoreCard_ID.name')+' ' +FloatToStr(mInputBO.GetFieldValueAsFloat('UnitRate')),mSite);
                 mPrice2:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr(mbo.GetFieldValueAsString('Firm_ID'))+', '+Quotedstr('')+', ' + QuotedStr(mInputBO.GetFieldValueAsString('RealStoreCard_ID')) + ','+Quotedstr('1000000101')+', '+Quotedstr(mbo.GetFieldValueAsString('StoreCard_ID.MainUnitCode'))+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(mbo.GetFieldValueAsDateTime('Schedule$DATE')))+')',0);
                 mInputBO.SetFieldValueAsFloat('CostingPrice',mPrice2*mInputBO.GetFieldValueAsFloat('UnitRate'));
               end;
             end;
           mBO.Save;
           mBO.free;
           mBO:=mOS.CreateObject(Class_PLMProduceRequest);
           mbo.Load(mlist.Strings[i],nil);
         }
         mReqBO:=TNxPLMProduceRequest(mBO);
         mReqBO.Calculate(aWar,aErr);
         //mPrice:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr(mbo.GetFieldValueAsString('Firm_ID'))+', '+Quotedstr('')+', ' + QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID')) + ','+Quotedstr('1000000101')+', '+Quotedstr(mbo.GetFieldValueAsString('StoreCard_ID.MainUnitCode'))+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
         mPrice:=mOS.SQLSelectFirstAsExtended('select (ro2.localtamountwithoutvat/(ro2.quantity/ro2.unitrate)) from receivedorders2 ro2 join relations r on r.leftside_Id=RO2.parent_id where r.rel_def=1620 and ro2.storecard_id='+
                                              QuotedStr(mbo.GetFieldValueAsString('StoreCard_ID'))+' and R.RightSide_ID='+Quotedstr(mbo.oid),0);

         mBO.SetFieldValueAsFloat('CostingPriceListAmount',mprice);
         mbo.save;
         mBO.Free;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Spočítáno '+IntToStr(mlist.count)+' kalkulací.',mSite);
     TDynSiteForm(mSite).RefreshData;
    end;
end;

begin
end.