const
  constStoragePath = GetCurrentDir;
  constNewDirStr = '%s\%s';



function Create_folder(mCustomBusinessObject:TNxCustomBusinessObject):Boolean;
var
mresult:boolean;
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
                                showmessage('Úložiště není přístupné');
                                result:=false;
                        end;

  end;

function iExportDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string;Adir:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
begin
     mCommand := 0;

    NxExportByIDs(Acontext, mPrintList, ADynCLSID, ReportID, mCommand, '', adir+AName);

result:=adir+FName;
end;


function iPrintDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string;Adir:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
begin
        {if  NxIsBlank(ADynCLSID) then begin
            mDynCLSID := Obj.DefaultDynSourceID;
        end else begin
            mDynCLSID:=ADynCLSID;
        end;
        try
                mOLEApp := GetAbraOLEApplication;
                        mCommand := mOLEApp.CreateCustomCommand(mDynCLSID);  // ZL
                        mCond := mCommand.ConstraintByID('ID');
                        mCond.UsedKind := 1;
                        mCond.Value := QuotedStr(Obj.OID);
                mCommand.Execute;
        finally
        end;
        if not (mCommand.RowSets[0].EOF) then
                begin
                        FName:=GetFileNameBOLog(Obj,aname);
                        mCommand.Print(ReportID,8,adir,FName);
                end; }
                NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, adir, FName) ;
                result:=adir+FName;
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