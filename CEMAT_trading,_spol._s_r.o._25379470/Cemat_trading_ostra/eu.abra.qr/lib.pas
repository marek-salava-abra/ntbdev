
{GetFirmName}


{DocNumber}

function DocNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String):String;
var
 mHeader:TNxCustomBusinessObject;
 mList:TStringList;
 mSQL:string;
begin
  Result:='';
  mList:=TStringList.Create;
  mSQL:='Select sd.id from StoreDocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.documenttype=''22'' and sd2.provide_id=''%s'' ';
  AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
  if mlist.count>0 then begin
    mHeader:=AReportHelper.ObjectSpace.CreateObject(Class_OutgoingTransfer);
    mHeader.load(mList.strings[0],nil);
    Result:=mHeader.DisplayName;
    mHeader.free;
  end;
  mlist.free;
end;

function GetSortimentDiscount(AReportHelper:TNxQRScriptHelper;Firm_ID,StoreCard_ID:String):Extended;
var
 mStoreCardBO, mBO:TNxCustomBusinessObject;
 mList:TStringList;
 mSQL:string;
begin
  Result:=1;
  mStoreCardBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
  mStoreCardBo.load(StoreCard_ID,nil);
  mList:=TStringList.Create;
  mSQL:='Select ID from FIRMASSORTMENTDISCOUNTS where Parent_ID=''%s'' and StoreAssortmentGroup_ID=''%s'' ';
  AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[firm_ID, mStoreCardBO.GetFieldValueAsString('StoreAssortmentGroup_ID')]),mList);
  if mlist.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_FirmAssortmentDiscount);
    mBO.load(mList.strings[0],nil);
    Result:=(100-mbo.GetFieldValueAsFloat('Discount'))/100;
    mBO.free;
  end;
  mlist.free;
  mStoreCardBO.free;
end;

function GetFirmName(AReportHelper:TNxQRScriptHelper;Doc_ID:String;DocumentType:String):String;
var
 mReceiptCardBO:TNxCustomBusinessObject;
begin
  if DocumentType='20' then begin
    if not(NxIsEmptyOID(Doc_ID)) then begin
    mReceiptCardBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceiptCard);
    mReceiptCardBO.Load(Doc_ID,nil);
    Result:=mReceiptCardBO.GetFieldValueAsString('U_Firm_ID.Name');
    mReceiptCardBO.Free;
    end;
  end;
end;

function GetSerial(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_SerialNumber');
    mbo.free;



 end;
end;
function GetRozmer(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_rozmer');
    mbo.free;



 end;
end;


{GetKGPrice}

function GetKGPrice(AReportHelper:TNxQRScriptHelper;DocDate:Extended):Extended;
var
 mList:TstringList;
begin
  Result:=0;
  mList:=TStringList.Create;
  AReportHelper.ObjectSpace.SQLSelect(format('select x_price from defrolldata where clsid=''0MLW20M1ODEO3GU1SGUPOSRFRC'' and X_date>%s order by x_date',[inttostr(trunc(DocDate)-1)]),mList);
  result:=NxIBStrToFloat(mlist.strings[0]);
end;

function GetName(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('Name');
    mbo.free;



 end;
end;

function GetHf(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=IntToStr(mBO.GetFieldValueAsInteger('U_hf'));
    mbo.free;



 end;
end;


function GetNosnost(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_nosnost');
    mbo.free;



 end;
end;

function GetSirka(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_sirkaramu');
    mbo.free;



 end;
end;

function GetRozevreni(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_rozvereni');
    mbo.free;



 end;
end;

function GetHCG(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_hcg');
    mbo.free;



 end;
end;

function GetISO(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=mBO.GetFieldValueAsString('U_ISO');
    mbo.free;



 end;
end;

function GetHmotnost(AReportHelper:TNxQRScriptHelper;BusTransAction_ID :String):String;
var
 mBO:TNxCustomBusinessObject;
 mSQL:String;
 mList:TStringList;
begin
 mList:=TStringList.Create;
 mSQL:='Select id from userdata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and fieldcode=2000026 and stringfieldvalue=''%s'' ';
 AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[BusTransAction_ID]),mList);
 if mList.count>0 then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
    mBO.Load(mlist.Strings[0],nil);
    Result:=FloatToStr(mBO.GetFieldValueAsfloat('U_hmotnost'));
    mbo.free;



 end;
end;

function GetOPNum(AReportHelper:TNxQRScriptHelper;Provide_ID :String):String;
var
 mBO:TNxCustomBusinessObject;

begin
 Result:='';
 if not(NxIsEmptyOID(Provide_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
    mBO.Load(Provide_ID,nil);
    Result:=mbo.DisplayName;
    mbo.free;



 end;
end;

begin
end.