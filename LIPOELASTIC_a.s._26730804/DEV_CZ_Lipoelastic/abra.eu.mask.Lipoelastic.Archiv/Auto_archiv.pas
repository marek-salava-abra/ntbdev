uses 'abra.eu.mask.Lipoelastic.Archiv.lib';

procedure auto_dobropis (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
  var
  msql:string;
   mid_report,mid_report1:string;
   mCustomBusinessObject:TNxCustomBusinessObject;
   mresult:boolean;
   mIDs:TStringList;
   mid_II:string;
   mfilename,adir:string;
   i:integer;
   mStringlist:TStringList;
   mid:string;
   mi:integer;

begin
  Success := True;
  LogInfoStr := '';
  mSQL:='Select id from IssuedCreditNotes where docdate$date < ' + IntToStr(trunc(now) -1)+ ' and DocDate$DATE >= 42461 and X_Uzamceno=' + quotedstr('N')  ;

  // mid_report:='1CB0000101'; -- původní sestava
   mid_report:='1DH0000101';
   mid_report1:='1DH0000101';
   try
    mIDs := TStringList.Create;
    OS.SQLSelect(mSQL,mIDs);

             for i := 0 to mIDs.Count-1 do begin // projdu vsechny oznacene zaznamy


                      mCustomBusinessObject:= os.CreateObject('W402MSU3BBDL3ACR03KIU0CLP4');
                      try
                            mCustomBusinessObject.load(mids.Strings[i],nil);
                            mid_II:=mCustomBusinessObject.oid;
                            mresult:=Create_folder(mCustomBusinessObject);
                                    mStringlist:=TStringList.create;
                                    mStringlist.Add(mCustomBusinessObject.oid);
                                    try
                                       adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                       mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                                       ]);
                          if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje

                                          if NxCopyFile(adir+'\'+mfilename+'.pdf',constStoragePath+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH_NN',now))) then begin
                                              if NxDeleteFiles(adir,mfilename+'.pdf') then begin

                                              end;
                                          end;
                                      end;
                                       //if mCustomBusinessObject.GetFieldValueAsString('DocQueue_ID.Code')='FVR' then begin
                                       //     mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report1,NxCreateContext(os),mStringlist,mfilename,adir);
                                       //end else begin
                                            mid:=iPrintDocument(mCustomBusinessObject,'KLFAXNODG3DL3ACT03KIU0CLP4',mid_report,NxCreateContext(os),mStringlist,mfilename,adir);
                                       //end;
                                    finally
                                        mStringlist.free;
                                    end;
                      finally
                       mCustomBusinessObject.free;
                      end;
                    mi:=os.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mid_II));
                    mi:=os.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mid_II));

             end;
  finally
    mIDs.Free;
  end;
end;






procedure auto_archiv (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
  var
  msql:string;
   mid_report,mid_report1:string;
   mCustomBusinessObject:TNxCustomBusinessObject;
   mresult:boolean;
   mIDs:TStringList;
   mid_II:string;
   mfilename,adir:string;
   i:integer;
   mStringlist:TStringList;
   mid:string;
   mi:integer;

begin
  Success := True;
  LogInfoStr := '';
  mSQL:='Select id from issuedinvoices where docdate$date < ' + IntToStr(trunc(now) -1)+ ' and DocDate$DATE >= 42461 and X_Uzamceno=' + quotedstr('N') ;

  // mid_report:='1CB0000101'; -- původní sestava
   mid_report:='3WF7000101';
   mid_report1:='3WF7000101';
   try
    mIDs := TStringList.Create;
    OS.SQLSelect(mSQL,mIDs);

             for i := 0 to mIDs.Count-1 do begin // projdu vsechny oznacene zaznamy


                      mCustomBusinessObject:= os.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                      try
                            mCustomBusinessObject.load(mids.Strings[i],nil);
                            mid_II:=mCustomBusinessObject.oid;
                            mresult:=Create_folder(mCustomBusinessObject);
                                    mStringlist:=TStringList.create;
                                    mStringlist.Add(mCustomBusinessObject.oid);
                                    try
                                       adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                       mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                                       ]);
                          if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje

                                          if NxCopyFile(adir+'\'+mfilename+'.pdf',constStoragePath+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH_NN',now))) then begin
                                              if NxDeleteFiles(adir,mfilename+'.pdf') then begin

                                              end;
                                          end;
                                      end;
                                       //if mCustomBusinessObject.GetFieldValueAsString('DocQueue_ID.Code')='FVR' then begin
                                       //     mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report1,NxCreateContext(os),mStringlist,mfilename,adir);
                                       //end else begin
                                            mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(os),mStringlist,mfilename,adir);
                                       //end;
                                    finally
                                        mStringlist.free;
                                    end;
                      finally
                       mCustomBusinessObject.free;
                      end;
                    mi:=os.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mid_II));
                    mi:=os.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mid_II));

             end;
  finally
    mIDs.Free;
  end;
end;

begin
end.