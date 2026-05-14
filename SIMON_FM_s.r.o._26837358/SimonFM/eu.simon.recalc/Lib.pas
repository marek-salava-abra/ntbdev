procedure  CalcFirm(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mFirmList, mObrat, mobratPP:TstringList;
 i:Integer;
 mSQL:String;
 mFirm, mCategory:TNxCustomBusinessObject;
 mFirmLimit, mObratValue:Extended;
 mFirm_ID, mCategory_ID:String;
 mLog:String;
 mDIC:String;
 mDICBoolean:Boolean;
begin
  mSQL:='select id from firms where Firm_id is null and hidden=''N'' and  id in (select x_firm_id from defrolldata where clsid='+QuotedStr('FPXJLP5SC314DF45HVZNY0OBYO')+') order by name';
  mFirmList:=TStringList.Create;
  OS.SQLSelect(mSQL,mFirmList);
  for i:=0 to mFirmList.count-1 do begin
       mObratValue:=0;
       mFirm:=Os.CreateObject(Class_Firm);
       mfirm.Load(mFirmList.Strings[i],nil);
       if not(mfirm.GetFieldValueAsBoolean('U_pevna_VIP')) then begin
        if NxIsBlank(mfirm.GetFieldValueAsString('VatIdentNumber')) then mDIC:='Ne' else mDIC:='Ano';
        if NxIsBlank(mfirm.GetFieldValueAsString('VatIdentNumber')) then mDICBoolean:=False else mDICBoolean:=True;
        mFirm_ID:=mFirm.OID;
        mObrat:=TStringList.create;
        mObratPP:=TStringList.Create;
        OS.SQLSelect(Format('select sum(amount) from posdocuments where firm_ID in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and docdate$date>''%s'' ',[mFirm_ID, mFirm_ID, inttostr(Trunc(Date-365))]),mObrat);
        OS.SQLSelect(Format('select sum(amount) from CashReceived where firm_ID in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and docdate$date>''%s'' ',[mFirm_ID, mfirm_ID, inttostr(Trunc(Date-365))]),mObratPP);
        if mObrat.count>0 then mObratValue:= StrToFloat(mobrat.Strings[0]);
        if mObratPP.count>0 then begin
         mObratValue := mObratValue + StrToFloat(mobratPP.Strings[0]);
        end;
       if mDICBoolean and (mObratValue<8000) then mCategory_ID:='1600000101';
       if mDICBoolean and ((mObratValue>7999) and (mObratValue<16000)) then mCategory_ID:='2600000101';
       if mDICBoolean and (mObratValue>15999) then mCategory_ID:='3600000101';
       if not(mDICBoolean) and (mObratValue<4000) then mCategory_ID:='1600000101';
       if not(mDICBoolean) and ((mObratValue>3999) and (mObratValue<8000)) then mCategory_ID:='2600000101';
       if not(mDICBoolean) and (mObratValue>7999) then mCategory_ID:='3600000101';
       mCategory:=os.CreateObject(Class_DealerCategory);
       mcategory.Load(mCategory_ID,nil);
       mLog:=mLog+mfirm.GetFieldValueAsString('Name')+' '+FloatToStr(mObratValue)+' '+ mDIC+' '+mCategory.DisplayName+chr(13);
       mCategory.Free;
       mFirm.SetFieldValueAsString('DealerCategory_ID',mCategory_ID);
       mFirm.save;
       end;





  end;



  Success := True;
  LogInfoStr := mlog+chr(10)+chr(13)+chr(10)+chr(13)+
  'Bylo zpracováno '+inttostr(mfirmlist.count);
end;

begin
end.