uses 'NxApiLib.lib';

{
Vyvoláva sa po uložení vlastných dát objektu do databázy.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
   mstring:string;
   mAdresatEmail:string;
    aname,blat_File,mxid:string;
  mDynCLSID:string;
  mStringParameter:string;
  mPrintList,mr:TStringList;
  mfile,mReport_ID,mDivision_ID:string;
  mdocQueueCode:string;
begin
  if (osNew in self.State) then begin
     mdocQueueCode:=self.ObjectSpace.SQLSelectFirstAsString('Select dq.code from docqueues dq where dq.id='+QuotedStr(self.GetFieldValueAsString('Document_ID.DocQueue_ID')),'');
        if mdocQueueCode='OVIT' then begin

                mReport_ID:='FV00000001';
                mDivision_ID:='1000000101';
                mPrintList := TStringList.Create;

                                                    try
                                                       mPrintList.Add(Self.OID);
                                                       //AName := Self.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(Self.GetFieldValueAsInteger('Ordnumber'))  +'-' + Self.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;
                                                       AName := 'Schvaleni.pdf' ;
                                                           mr:=tstringlist.create;
                                                           try
                                                               Self.ObjectSpace.SQLSelect('select DataSource from Reports where ID=' + QuotedStr(mReport_ID),mr);
                                                               if mr.count>0 then begin
                                                                  mDynCLSID:=mr.strings[0];
                                                               end else begin
                                                                  mDynCLSID := Self.DefaultDynSourceID;
                                                               end;
                                                           finally
                                                               mr.free;
                                                           end;

                                                       try
                                                          CFxReportManager.PrintByIDs(NxCreateContext(Self.ObjectSpace),mPrintList,mDynCLSID, mReport_ID, rtofile, pekPDF,NxGetTempDir,aname);
                                                          mFile:=NxGetTempDir+'\'+aname;
                                                          try

                                                                  mFile:=NxGetTempDir+aname;
                                                          except

                                                          end;
                                                        except
                                                        end;
                                                    finally
                                                        mPrintList.free;
                                                    end;



                   mAdresatEmail:=           'jsyrovy@lipoelastic.com';    // self.
                   //mAdresatEmail:='mskacel@lipoelastic.com';
                   //mstring:=SendMail_BO(self.ObjectSpace, 'Doklad: ' + self.DisplayName , 'Právě byl uložen doklad s číslem: ' +  self.DisplayName , mAdresatEmail, '','','#300000001', mFile,'5O10000101',Self);
                    mstring:=SendMail_SCH(self.ObjectSpace, 'Schvaleni: '  , 'žadam o schvaleni : ' +  self.DisplayName , mAdresatEmail, '','','1100000101', mFile,mDivision_ID,Self);
                 //
                 //  if self.GetFieldValueAsString('DocQueue_ID.Code')='SOPMP' then begin
                 //     mstring:=SendMail_BO(TNxCustomBusinessObject.ObjectSpace, 'Doklad: ' + Self.DisplayName , 'Právě byl uložen doklad s číslem: ' +  Self.DisplayName , mAdresatEmail, '','','1100000101', '','5O10000101',self);
                 //  end;
            end;
      end;
end;

begin
end.