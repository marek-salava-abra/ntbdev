
{GetUserName}

function GetUserName(AReportHelper:TNxQRScriptHelper;ReceivedOrder_ID:String):String;
var
 mList:TStringList;
 mUser:TNxCustomBusinessObject;
begin
  Result:='';
  mList:=TStringList.create;
  AReportHelper.ObjectSpace.SQLSelect(format('Select sd.createdby_id from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd2.flowtype=''21'' and sd2.provide_id=''%s'' ',[ReceivedOrder_ID]),mList);
  if mlist.Count>0 then begin
    mUser:=AReportHelper.ObjectSpace.CreateObject(Class_SecurityUser);
    mUser.load(mlist.strings[0],nil);
    Result:=muser.GetFieldValueAsString('LoginName');
    mUser.free;
  end;
end;

function GetStoreName(AReportHelper:TNxQRScriptHelper;mStore_ID:String):String;
var
 mList:TStringList;
 mStore:TNxCustomBusinessObject;
begin
  Result:='';
  mList:=TStringList.create;
  AReportHelper.ObjectSpace.SQLSelect(format('Select id from stores where id=''%s'' ',[mStore_ID]),mList);
  if mlist.Count>0 then begin
    mStore:=AReportHelper.ObjectSpace.CreateObject(Class_Store);
    mStore.load(mlist.strings[0],nil);
    Result:=mStore.GetFieldValueAsString('Name');
    mStore.free;
  end;
end;

function GetICNNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String;):String;
Var
 mOV:TNxCustomBusinessObject;
 mSQL:String;
 mList, mList2, mNumList:TStringList;
 i:integer;
begin
 if not(NxIsEmptyOID(Doc_ID)) then begin
   mSQL:='select distinct icn.id from issuedinvoices2 ii2 '+
         'left join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
         'left join issuedCreditNotes icn on icn.Source_ID=ii2.parent_id '+
         'where sd2.provide_id=''%s'' ';
   mList:=TStringList.Create;

   AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
   Result:='';
   if mlist.Count>0 then begin
    mNumList:=TStringList.create;
    for i:=0 to mList.count-1 do begin
     if not(NxIsEmptyOID(mlist.Strings[i])) then begin
       mOV:=AReportHelper.objectspace.CreateObject(Class_IssuedCreditNote);
       mOV.load(mlist.strings[i],nil);
       mNumList.Add(mov.DisplayName);
       mOV.free;
     end;
    end;
     Result:=mNumList.DelimitedText;
   end;

 end;
end;

function GetOTNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String;):String;
Var
 mOV:TNxCustomBusinessObject;
 mSQL:String;
 mList, mList2, mNumList:TStringList;
 i:integer;
begin
 if not(NxIsEmptyOID(Doc_ID)) then begin
   mSQL:='select distinct sd.id from issuedinvoices2 ii2 '+
         'left join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
         'left join issuedCreditNotes icn on icn.Source_ID=ii2.parent_id '+
         'left join storedocuments sd on sd.X_DocumentID=icn.id '+
         'where sd2.provide_id=''%s'' ';
   mList:=TStringList.Create;
   mNumList:=TStringList.create;
   AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
   Result:='';
   if mlist.Count>0 then begin
    for i:=0 to mList.count-1 do begin
     if not(NxIsEmptyOID(mlist.strings[i])) then begin
       mOV:=AReportHelper.objectspace.CreateObject(Class_OutgoingTransfer);
       mOV.load(mlist.strings[i],nil);
       mNumList.Add(mov.DisplayName);
       mOV.free;
     end;
    end;
     Result:=mNumList.DelimitedText;
   end;

 end;
end;

function GetITNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String;):String;
Var
 mOV:TNxCustomBusinessObject;
 mSQL:String;
 mList, mList2, mNumList:TStringList;
 i:integer;
begin
 if not(NxIsEmptyOID(Doc_ID)) then begin
   mSQL:='select distinct sd.id from storedocuments sd '+
         'where sd.X_DocumentID=''%s'' ';
   mList:=TStringList.Create;
   mNumList:=TStringList.create;
   AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
   Result:='';
   if mlist.Count>0 then begin
    for i:=0 to mList.count-1 do begin

     mOV:=AReportHelper.objectspace.CreateObject(Class_IncomingTransfer);
     mOV.load(mlist.strings[i],nil);
     mNumList.Add(mov.DisplayName);
     mOV.free;
    end;
    Result:=mNumList.DelimitedText;
   end;

 end;
end;

function GetICNCompleteNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String;):String;
Var
 mICNBO, mOTBO, mITBO:TNxCustomBusinessObject;
 mSQL:String;
 mList, mList2, mList3, mNumList:TStringList;
 i:integer;
 mOTName, mITName, mPrevody:string;
begin
 if not(NxIsEmptyOID(Doc_ID)) then begin
   mSQL:='select distinct icn.id from issuedinvoices2 ii2 '+
         'left join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
         'left join issuedCreditNotes icn on icn.Source_ID=ii2.parent_id '+
         'where sd2.provide_id=''%s'' ';
   mList:=TStringList.Create;
   mList2:=TStringList.Create;
   mList3:=TStringList.Create;
   mNumList:=TStringList.create;
   AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
   Result:='';
   mITName:='';
   mOTName:='';
   mPrevody:='';
   if mlist.Count>0 then begin
    for i:=0 to mList.count-1 do begin
     if not(NxIsEmptyOID(mlist.Strings[i])) then begin
       mICNBO:=AReportHelper.objectspace.CreateObject(Class_IssuedCreditNote);
       mICNBO.load(mlist.strings[i],nil);
       AReportHelper.ObjectSpace.SQLSelect(format('select distinct sd.id from storedocuments sd where sd.X_DocumentID=''%s'' ',[mICNBO.OID]),mlist2);
       if mList2.count>0 then begin
         mOTBO:=AReportHelper.ObjectSpace.CreateObject(Class_OutgoingTransfer);
         mOTBO.Load(mlist2.strings[0],nil);
         mOTName:=mOTBO.DisplayName;
         AReportHelper.ObjectSpace.SQLSelect(format('select distinct sd2.parent_id from storedocuments2 sdx2 left join storedocuments2 sd2 on sd2.providerow_id=sdx2.id where sdx2.parent_id=''%s'' ',[mOTBO.OID]),mlist3);
         if mlist3.count>0 then begin
           mITBO:=AReportHelper.ObjectSpace.CreateObject(Class_IncomingTransfer);
           mITBO.Load(mlist3.strings[0],nil);
           mITName:=mITBO.DisplayName;
           mITBO.free;
         end;
         mOTBO.free;
       end;
      end;
     if not(NxIsBlank(mITName)) then mPrevody:=' ('+mOTName+' '+mITName+')';
     mNumList.Add(mICNBO.DisplayName+mPrevody);
     mICNBO.free;
    end;
    Result:=NxSearchReplace(NxSearchReplace(mNumList.DelimitedText,'"','',[srAll]),',',', ',[srAll]);
   end;

 end;
end;

begin
end.