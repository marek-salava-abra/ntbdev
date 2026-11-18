const cRentalDeviceBusinessObject = 'VFNPR04IPRQ41HGAGUTXNGLWYW';
{Print}


{a}



Function Print(AReportHelper:TNxQRScriptHelper;Activity_ID:String): Integer;
var
 mList, mRentList:Tstringlist;
 mSQL:String;
 mOS:TNxCustomObjectSpace;
 mJistina:Extended;
 mBO, mActivityBO:TNxCustomBusinessObject;
 i:Integer;
begin
    mOS:=AReportHelper.ObjectSpace;
    mActivityBO:=mos.CreateObject(Class_CRMActivity);
    mActivityBO.Load(Activity_ID,nil);
      if mActivityBO.GetFieldValueAsString('ActQueue_ID')='2000000101' then begin
      //self.Refresh;
      mJistina:=0;
       mRentList:=TStringList.Create;
       mSQL:= Format(
      'SELECT A.ID as ID '+
      ' FROM DefRollData A ' +
      ' WHERE A.CLSID=''%s'' AND A.X_Activity_ID=''%s''',
      [cRentalDeviceBusinessObject, mActivityBO.OID]);
      //NxShowSimpleMessage(msql,nil);

       mBO:= mOS.CreateObject(cRentalDeviceBusinessObject);
       mOS.SQLSelect(mSQL,mRentList);
       if mRentList.Count>0 then begin
         for i:=0 to mRentList.Count-1 do begin
           mBO.Load(mRentList.strings[i], nil);
           mJistina:=mJistina+mbo.GetFieldValueAsFloat('U_recommenddeposit');
         end;
       end;
       mList:=TStringList.Create;
       mlist.add(mActivityBO.OID);
       //CFxReportManager.PrintByIDs(NxCreateContext_1(self),mList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1I50000101',rtoPreview,pekPDF,'','');
       if mJistina>0 then CFxReportManager.PrintByIDs(NxCreateContext_1(mActivityBO),mList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1J50000101',rtoPreview,pekPDF,'','');
       mList.Free;
      end;

end;

begin
end.