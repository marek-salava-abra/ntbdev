{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i: Integer;
 mMessage:boolean;
 mSQL1:string;
 mList:TStringList;
 mPrice:Extended;
begin
{  if (NxGetActualUserID_1(self)='1F10000101') or
     (NxGetActualUserID_1(self)='1D20000101') or
     (NxGetActualUserID_1(self)='1E10000101') then begin  }
      mMessage:=false;
       mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
        for i:=0 to mrows.Count-1 do begin
          if not(mMessage) then begin
            mList:=TStringList.Create;
            mSQL1:='Select PurchasePrice from StoreSubcards where storecard_id=''%s'' and Store_ID=''%s'' ';
            self.ObjectSpace.SQLSelect(format(mSQL1,[mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'),mrows.BusinessObject[i].GetFieldValueAsString('Store_ID')]),mlist);
            mprice:=0;
            if mlist.count>0 then mPrice:=StrToFloat(mList.Strings[0]);
            if mprice>0 then begin
             if ((mrows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice')<(0.85*mPrice)) or (mrows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice')>(1.15*mPrice))) and mrows.BusinessObject[i].GetFieldValueAsBoolean('CompletePrices')  then mMessage:=true;
            end;
            mlist.free;
          end;
        end;
       if mMessage then NxShowSimpleMessage('POZOR! Jedna z položek je přijata se špatnou cenou!'+#13#10+' KONTAKTUJTE vedoucího pro schválení.',nil);
     end;
{end; }

begin
end.