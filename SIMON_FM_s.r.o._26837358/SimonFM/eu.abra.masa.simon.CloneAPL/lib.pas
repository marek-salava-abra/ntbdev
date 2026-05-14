{---------------------------
Chyba
---------------------------
Testovaný výraz je chybný: Chyba při zpracování dat v databázi
"Dynamic SQL Error
SQL error code = -104
Token unknown - line 4, column 122
t

Tip: Pro zobrazení více informací o chybě je nutné nastavit firebird.msg podle metodiky z helpu.
"
SQL příkaz:
SELECT  * FROM
  ActionPriceLists A

WHERE (A.Code LIKE 'ES-T' ESCAPE '~' ) AND (A.Hidden = 'N' ) AND ((a.datefrom$date<=(45196)) and (a.dateto$date>(45196)) t)
.
---------------------------
OK
---------------------------
}

procedure CLoneAPL (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mBO,mNewBO, mStorePrice, mNewStorePrice:TNxCustomBusinessObject;
 i:integer;
 mSite:TSiteForm;
 mList:TStringList;
 mOS:TNxCustomObjectSpace;
 mAPL_ID, mOLDAPL_ID:string;
begin
   mOS:=OS;
   mOLDAPL_ID:=mOS.SQLSelectFirstAsString('Select a.id from ActionPriceLists a where a.code='+quotedstr('ES-T')+' and (a.datefrom$date<='+IntToStr(Trunc(date))+' and a.dateto$date>'+IntToStr(Trunc(date))+')','');
   if not(NxIsEmptyOID(mOLDAPL_ID)) then begin
     mBO:=mos.CreateObject(Class_ActionPriceList);
     mBO.Load(mOLDAPL_ID,nil);
     if Assigned(mBO) then begin
       mNewBO:=mBO.Clone;
       mNewBO.SetFieldValueAsDateTime('DateFrom$Date',date+1);
       mnewbo.SetFieldValueAsDateTime('DateTo$Date',Date+1000);
       mnewbo.SetFieldValueAsDateTime('CreationDate$DATE',Date+1);
       mNewBO.SetFieldValueAsDateTime('X_DateSort',Date+1);
       mBO.SetFieldValueAsDateTime('DateTo$Date',date);
       mbo.save;
       mNewBO.save;
       mAPL_ID:=mNewBO.OID;
       mNewBO.free;
       mList:=TStringList.Create;
       mOS.SQLSelect('Select id from actionstoreprices where pricelist_id='+QuotedStr(mBO.OID),mList);
       for i:=0 to mList.count-1 do begin
         mStorePrice:=mOS.CreateObject(Class_ActionStorePrice);
         mStorePrice.load(mList.Strings[i],nil);
         mNewStorePrice:=mStorePrice.Clone;
         mNewStorePrice.SetFieldValueAsString('PriceList_ID',mAPL_ID);
         mNewStorePrice.save;
         mStorePrice.free;
         mNewStorePrice.free;
       end;
      end;
 end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.