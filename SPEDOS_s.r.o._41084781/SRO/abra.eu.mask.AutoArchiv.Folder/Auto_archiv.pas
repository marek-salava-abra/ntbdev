uses 'abra.eu.mask.AutoArchiv.Folder.lib';

const
mid_report='1CB0000101';
mtype='03';
mclsid='40SBPEINEFD13ACM03KIU0CLP4';


procedure auto_archiv (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
  var
  msql:string;
   mid_report:string;
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
  mSQL:='Select id from issuedinvoices where trunc(docdate$date) < ' + IntToStr(trunc(now) -1)+ 'and DocDate$DATE >= 42461 and X_Uzamceno=' + quotedstr('N') ;



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
                                       adir:=Format('%s\%s\%s\%s', [constStoragePath,mtype, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
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
                                       mid:=iPrintDocument(mCustomBusinessObject,mclsid,mid_report,NxCreateContext(os),mStringlist,mfilename,adir);
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