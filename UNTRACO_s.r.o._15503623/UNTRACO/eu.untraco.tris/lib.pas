procedure ExportOV (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('Select id from issuedorders where X_TrisExported=''N'' and X_toTris=''A'' and createdat$date>=%s ',[IntToStr(Trunc(Date-39))]),mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_IssuedOrder);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\IN_'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),5)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'W0NZQGROZZDL342X01C0CX3FCC','IH50000101',0,'',mFileName);
     mExportList.free;
     mbo.SetFieldValueAsBoolean('X_TrisExported',true);
     mBO.SetFieldValueAsInteger('X_TrisState',1);
     mbo.save;
     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;;
end;

procedure ExportOP (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('Select id from receivedorders where X_TrisExported=''N'' and X_toTris=''A''  and createdat$date>=%s ',[IntToStr(Trunc(Date-30))]),mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_ReceivedOrder);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     if mbo.GetFieldValueAsString('DocQueue_ID')='B100000101' then
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\OUT_'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),6)+'.xml' else
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\OUT_'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr(mbo.GetFieldValueAsString('DocQueue_ID.Code'),1)+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),6)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'40V53DORW3DL342X01C0CX3FCC','IH60000101',0,'',mFileName);
     mExportList.free;
     mbo.SetFieldValueAsBoolean('X_TrisExported',true);
     mBO.SetFieldValueAsInteger('X_TrisState',1);
     mbo.save;
     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;;
end;

procedure ExportINM (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('Select id from StoreDocuments where X_TrisExported=''N'' and X_toTris=''A'' and documenttype=''26'' and createdat$date>=%s ',[IntToStr(Trunc(Date-3))]),mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_InventoryShortFall);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\OUT_INM'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),5)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'1HDOXDMCSZDL3FUD00C5OG4NF4','JHA0000101',0,'',mFileName);
     mExportList.free;
     mbo.SetFieldValueAsBoolean('X_TrisExported',true);
     mBO.SetFieldValueAsInteger('X_TrisState',1);
     mbo.save;
     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;;
end;

procedure ExportVPR (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('Select id from StoreDocuments where X_TrisExported=''N'' and X_toTris=''A'' and documenttype=''30'' and createdat$date>=%s ',[IntToStr(Trunc(Date-3))]),mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_RefundedReceiptCard);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\OUT_VPR'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),5)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'VADQ0NX0IZDOL5HOBSJHGQJAHW','IHB0000101',0,'',mFileName);
     mExportList.free;
     mbo.SetFieldValueAsBoolean('X_TrisExported',true);
     mBO.SetFieldValueAsInteger('X_TrisState',1);
     mbo.save;
     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;;
end;

procedure ExportINP (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('Select id from StoreDocuments where X_TrisExported=''N'' and X_toTris=''A'' and documenttype=''25'' and createdat$date>=%s ',[IntToStr(Trunc(Date-3))]),mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_InventoryOverplus);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\IN_INP'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),5)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'15DOXDMCSZDL3FUD00C5OG4NF4','JHB0000101',0,'',mFileName);
     mExportList.free;
     mbo.SetFieldValueAsBoolean('X_TrisExported',true);
     mBO.SetFieldValueAsInteger('X_TrisState',1);
     mbo.save;
     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;;
end;


procedure ExportVR (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect(format('Select id from StoreDocuments where X_TrisExported=''N'' and X_toTris=''A'' and documenttype=''23'' and createdat$date>=%s ',[IntToStr(Trunc(Date-3))]),mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_RefundedBillOfDelivery);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\IN_VR'+mbo.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('00000'+IntToStr(mbo.GetFieldValueAsInteger('Ordnumber')),5)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'0HDOXDMCSZDL3FUD00C5OG4NF4','KHB0000101',0,'',mFileName);
     mExportList.free;
     mbo.SetFieldValueAsBoolean('X_TrisExported',true);
     mBO.SetFieldValueAsInteger('X_TrisState',1);
     mbo.save;
     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage+' počet záznamů '+IntToStr(mlist.count);;
end;

procedure ExportSC (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mExportList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mMessage, mFileName:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect('Select id from StoreCards where hidden=''N'' ',mList);
  if mlist.count>0 then begin
   for i:=0 to mList.Count-1 do begin
     mBO:=OS.CreateObject(Class_StoreCard);
     mBO.Load(mlist.Strings[i],nil);
     mExportList:=TStringList.Create;
     mExportList.add(mBO.OID);
     mFileName:='C:\SERVER\ABRA_DATA\TOTRIS\SKL_'+mbo.GetFieldValueAsString('Code')+'_'+FormatDateTime('DDMMYYYY',date)+'.xml';
     CFxReportManager.ExportByIDs(NxCreateContext(OS), mExportList,'OGQQA2C25JDL342N01C0CX3FCC','IHF0000101',0,'',mFileName);
     mExportList.free;

     mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;;
end;

begin
end.