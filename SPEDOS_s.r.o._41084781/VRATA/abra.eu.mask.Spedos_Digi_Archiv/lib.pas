  const
  constStoragePath = '\\192.168.0.80\abradata\Archiv\Vrata';
  constNewDirStr = '%s\%s';
  mreport1='1Y50000101';
  mreport2='1Z50000101';
  mACLSID='40SBPEINEFD13ACM03KIU0CLP4';


procedure AutoArchiv (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
  var
    mr:tstringlist;
  mi:integer;
  mBO:TNxCustomBusinessObject;
   zadej:string;
    mfilename:string;
    mdir,skdir,mfile:string;
    mfilter:string;
    mresult:Boolean;
    mStringlist:TStringList;
    mid:string;
    adir:string;
    mid_report:string;
    i:integer;

begin
  Success := True;
  LogInfoStr := '';
  mr:=tstringlist.Create;

  try
     os.SQLSelect('select id from issuedinvoices where X_archiv=''N'' AND x_Print_id is not null order by docdate$date desc',mr) ;
     if mr.count>0 then begin
         for i:=0 to mr.count-1 do begin


                                 mbo:=os.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                                 try
                                        mbo.load(mr.strings[i],nil);


                                           if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code')]));
                                                if  not mresult then begin    // období
                                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code')]));
                                                end;
                                                mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code')]));
                                                if not mresult then begin    // řada
                                                        mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code')]));
                                                end;
                                                mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                if not mresult then begin    // řada
                                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                end;
                                            end;



                                            //    if mresult then begin
                                                        mStringlist:=TStringList.create;
                                                        try
                                                                   mStringlist.Add(mbo.GetFieldValueAsString('ID'));
                                                                   mid_report:=mbo.GetFieldValueAsString('X_print_ID');

                                                                       adir:=Format('%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code')]);
                                                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(mbo.GetFieldValueAsInteger('Ordnumber')),mbo.GetFieldValueAsString('Docqueue_id.code'),mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('varsymbol')]);
                                                                      if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje
                                                                                      mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                                                            if not mresult then begin    // řada
                                                                                                    mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                                                            end;


                                                                                            if NxCopyFile(adir+'\'+mfilename+'.pdf',adir+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH_NN',now))+'.pdf') then begin
                                                                                                if NxDeleteFiles(adir,mfilename+'.pdf') then begin
                                                                                                end;
                                                                                            end;

                                                                       end;
                                                                      //nxshowsimplemessage(mStringlist[0],nil);
                                                                      mid:=iPrintDocument(mbo,mACLSID,mid_report,NxCreateContext(os),mStringlist,mfilename,adir);

                                                                                              if  mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber') = '31708587' then begin
                                                            skdir:=copy(adir,1,31)+(Format('%s\%s', ['Slovensko', mbo.GetFieldValueAsString('Period_id.code')]));

                                                          //  NxShowSimpleMessage(skdir,nil);

                                                            mResult:=DirectoryExists(Format('%s\%s\%s', [skdir, 'Slovensko', mbo.GetFieldValueAsString('Period_id.code')]));
                                                                            if not mresult then begin    // řada
                                                                                    mResult:=NxCreateDir(Format('%s\%s\%s', [skdir, 'Slovensko',mbo.GetFieldValueAsString('Period_id.code')]));
                                                                            end;





                                                          mid:=iPrintDocument(mbo,mACLSID,mid_report,NxCreateContext(os),mStringlist,mfilename,skdir);

                                                    end;

                                                                      mi:=os.SQLExecute('update issuedinvoices set X_archiv=''A'' where id=' + QuotedStr(mbo.oid)) ;
                                                         finally
                                                                mStringlist.free;
                                                         end;
                                              //   end;

                                 finally
                                     mbo.free;

                                     Success := True;
                                 end;

         end;
     end;

  finally
     mr.free;
  end;

end;

function Create_folder(mCustomBusinessObject:TNxCustomBusinessObject):Boolean;
var
mresult:boolean;
constStoragePath:string;
begin
  //  if NxIsBlank(mCustomBusinessObject.GetFieldValueAsString('X_PrintReport_ID')) then  begin
                        if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code')]));
                                if  not mresult then begin    // období
                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code')]));


                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]));
                                if not mresult then begin    // řada
                                        mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]));

                                end;
                        //showmessage('Úložiště je vytvořeno');
                        end else begin

                                //NxShowSimpleMessage(Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                //mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]),nil)   ;
                                //showmessage('Úložiště není přístupné');
                                result:=false;
                        end;

    //  end;

             // mCustomBusinessObject.SetFieldValueAsString('X_path',(Format('%s\%s\%s\%s\%s', [mBO_ServiceDocument.GetFieldValueAsString('ServicedObject_ID'),'Servisni listy',mCustomBusinessObject.GetFieldValueAsString('ServiceDocument_ID'),'ML',mCustomBusinessObject.GetFieldValueAsString('ID')])));

end;


function iPrintDocument(mbo:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStringlist;AName:string;Adir:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;

        mDynCLSID:string;
begin
        if  NxIsBlank(ADynCLSID) then begin
            mDynCLSID := mbo.DefaultDynSourceID;
        end else begin
            mDynCLSID:=ADynCLSID;
        end;
        try
                mOLEApp := GetAbraOLEApplication;
                        mCommand := mOLEApp.CreateCustomCommand(mDynCLSID);  // ZL
                        mCond := mCommand.ConstraintByID('ID');
                        mCond.UsedKind := 1;
                        mCond.Value := QuotedStr(mbo.OID);
                mCommand.Execute;
        finally
        end;
        if not (mCommand.RowSets[0].EOF) then
                begin
                        //FName:=GetFileNameBOLog(Obj,aname);
                        mCommand.Print(ReportID,8,adir,AName+'.pdf');
                end;
                NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, adir, AName+'.pdf') ;
                result:=adir+AName+'.pdf';
end;

function iPrintallDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
begin
        if  NxIsBlank(ADynCLSID) then begin
            mDynCLSID := Obj.DefaultDynSourceID;
        end else begin
            mDynCLSID:=ADynCLSID;
        end;

                CFxReportManager.PrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtoPreview, pekARP, '','' ) ;
;
end;


function GetFileNameBOLog(mBO:TNxCustomBusinessObject;aname:string):string;
var s:string;
begin
        s:=aname;
        s:=NxRemoveDiacritics(s);
                while pos('.',s)>0 do delete(s,pos('.',s),1);
                while pos('/',s)>0 do delete(s,pos('/',s),1);
                while pos('-',s)>0 do delete(s,pos('-',s),1);
                while pos(':',s)>0 do delete(s,pos(':',s),1);
                while pos(',',s)>0 do delete(s,pos(',',s),1);
                while pos(' ',s)>0 do delete(s,pos(' ',s),1);
                while pos('"',s)>0 do delete(s,pos('"',s),1);
                result:=s+'.pdf';
end;

begin
end.