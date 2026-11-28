procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if NxGetActualUserID(self.BaseObjectSpace)='7000000101' then begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Klon karty';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede klonování';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;
  end;
end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mList:TStringList;
 i,m:integer;
 mBO, mCloneBO, mSMBO, mUnit:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mUnits:TNxCustomBusinessMonikerCollection;
 mAmount:Extended;
 mStorePrice_ID:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.Create;
 TBusRollSiteForm(msite).list.GetSelectedId(mList);
 if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
      mBO:=mOS.CreateObject(Class_StoreCard);
      mBO.Load(mlist.strings[i],nil);
      mStorePrice_ID:=GetPrice_ID(mOS, mbo.OID,'1000000101');
      if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
            for m:=0 to mUnits.count-1 do begin
            mUnit:=mUnits.BusinessObject[m];
             //NxShowSimpleMessage(mUnit.GetFieldValueAsString('Price_ID'),mSite);
             if mUnit.GetFieldValueAsString('Price_ID')='1100000101' then begin
               //NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll]),mSite);
               if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                mAmount:=mUnit.GetFieldValueAsFloat('Amount');
                //mUnit.save;
               end;
             end;
            end;
         end;

      mCloneBO:=mBO.Clone;
     // mclonebo.SetFieldValueAsString('StoreAssortmentGroup_ID','B200000101');
      mCloneBO.SetFieldValueAsString('Code', NxSearchReplace(mbo.GetFieldValueAsString('Code'),'CR6523','CR6524',[srall]));
      mCloneBO.SetFieldValueAsString('Name', NxSearchReplace(mbo.GetFieldValueAsString('Name'),'CS','Inova',[srall]));
      mCloneBO.SetFieldValueAsBoolean('U_MassCloned',True);
      mCloneBO.save;
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.New;
             mSMBO.SetFieldValueAsString('StoreCard_id',mCloneBO.OID);
             msmbo.SetFieldValueAsString('PriceList_ID','1000000101');
             mUnits:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             mUnit:=mUnits.AddNewObject;
             mUnit.SetFieldValueAsString('Price_ID','1100000101');
             mUnit.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
             mUnit.SetFieldValueAsFloat('UnitRate',1);
             mUnit.SetFieldValueAsFloat('Amount',mAmount);
             msmbo.save;
             mSMBO.Free;
      mCloneBO.free;
      mbo.Free;
   end;
 end;
end;

function GetPrice_ID(AOS : TNxCustomObjectSpace; AStoreCard_ID, aPriceList_ID : string) : string;
const
  cSQL = 'SELECT ID FROM StorePrices WHERE StoreCard_ID=''%s'' and Pricelist_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AStoreCard_ID,aPriceList_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;


begin
end.