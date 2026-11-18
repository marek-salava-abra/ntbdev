{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mDLRowBO:TNxCustomBusinessObject;
 mOrigDate:Extended;
begin
  if self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='60776480' then begin
   self.GetOriginalValue_1('DocDate$Date', mOrigDate);
   if mOrigDate>self.GetFieldValueAsDateTime('DocDate$Date') then begin
     mOS:=self.ObjectSpace;
     mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
     for i:=0 to mrows.count-1 do begin
        mList:=TStringList.Create;
        mOS.SQLSelect(format('select sd2.id from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.docdate$date>=%s '+
                                          ' and sd.documenttype=''21'' and sd2.storecard_id=''%s'' ',
                                          [IntToStr(trunc(self.GetFieldValueAsDateTime('DocDate$Date'))),mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID')]),
                                          mList);
        {for j:=0 to mlist.count-1 do begin
           mDLRowBO:=mos.CreateObject(Class_BillOfDeliveryRow);
           mDLRowBO.Load(mlist.Strings[j],nil);
           mDLRowBO.SetFieldValueAsFloat('X_UnitPrice_SRO', mDLRowBO.GetFieldValueAsFloat('StoreCard_ID.X_Price'));
           mDLRowBO.save;
           mDLRowBO.free;
        end; }
        mlist.Free;
     end;
   end;
  end;
end;

begin
end.