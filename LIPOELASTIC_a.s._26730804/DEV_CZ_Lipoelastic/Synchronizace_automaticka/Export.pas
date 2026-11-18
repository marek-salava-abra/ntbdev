uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib','NxApiProp.Prop' ;

procedure Export_SK (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var mid:string;
    mid_report:string;
    mi:integer;
mid_report1,mid_reportx:string;
mBoolean:boolean;
mr,mStringlist:Tstringlist;
adir,mfilename:string;
i:integer;
mCustomBusinessObject:TNxCustomBusinessObject;
begin
   Success := True;
   LogInfoStr := '';
          mid_reportx:='ATR0000101';
          adir:=Format('%s', ['\\CZVS0006\AbraExport\SK_Lipoelastic\DL\DPPO\ABRAGx_B2B_']);
             mr:=tstringlist.create;
             mCustomBusinessObject:= os.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
             try
               os.sqlselect('SELECT A.ID FROM StoreDocuments A WHERE A.DocumentType=' +quotedstr('21') + ' AND (A.DocQueue_ID IN (' + quotedstr('27L1000101') + '))'
                            +' AND (A.DocDate$DATE >= ' +  NxFloatToIBStr(Date)
                            +'  and A.DocDate$DATE < ' + NxFloatToIBStr(Date+1)
                            +' )' ,mr);
               LogInfoStr := LogInfoStr + 'Počet záznamů: DPPO' + inttostr(mr.count) + chr(10);
               if mr.count>0 then begin
                       for i := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                  mCustomBusinessObject.load(mr.Strings[i],nil);
                                  mStringlist:=TStringList.create;
                                  mStringlist.Add(mr.Strings[i]);
                                  try
                                         mfilename:=Format('%s-%s-%s%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                         mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),'.xml'
                                         ]);
                                        // mid:=iExportDocument(mCustomBusinessObject,'05DOXDMCSZDL3FUD00C5OG4NF4',mid_reportx,NxCreateContext(os),mStringlist,mfilename,adir);
                                         LogInfoStr := LogInfoStr + mCustomBusinessObject.DisplayName  + chr(10);
                                  finally
                                      mStringlist.free;
                                  end;
                        end;
               end;

             adir:=Format('%s', ['\\CZVS0006\AbraExport\SK_Lipoelastic\DL\DMA\ABRAGx_B2B_']);
             mr:=tstringlist.create;
               os.sqlselect('SELECT A.ID FROM StoreDocuments A WHERE A.DocumentType=' +quotedstr('21') + ' AND (A.DocQueue_ID IN (' + quotedstr('6732000101') + '))'
                            +' AND (A.DocDate$DATE >= ' +  NxFloatToIBStr(Date)
                            +'  and A.DocDate$DATE < ' + NxFloatToIBStr(Date+1)
                            +' )' ,mr);
               LogInfoStr := LogInfoStr+ chr(10) + chr(10);
               LogInfoStr := LogInfoStr + 'Počet záznamů: DMA' + inttostr(mr.count) + chr(10);
               if mr.count>0 then begin
                       for i := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                  mCustomBusinessObject.load(mr.Strings[i],nil);
                                  mStringlist:=TStringList.create;
                                  mStringlist.Add(mr.Strings[i]);
                                  try
                                         mfilename:=Format('%s-%s-%s%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                         mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),'.xml'
                                         ]);
                                        // mid:=iExportDocument(mCustomBusinessObject,'05DOXDMCSZDL3FUD00C5OG4NF4',mid_reportx,NxCreateContext(os),mStringlist,mfilename,adir);
                                         LogInfoStr := LogInfoStr + mCustomBusinessObject.DisplayName  + chr(10);
                                  finally
                                      mStringlist.free;
                                  end;
                        end;
               end;

               Success:=true;
           finally
               mr.free;
               mCustomBusinessObject.free;
           end;

end;



procedure Export_DL_JSON (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var mid:string;
    mid_report:string;
    mi:integer;
mid_report1,mid_reportx:string;
mBoolean:boolean;
mr,mStringlist,mQueryStringList:Tstringlist;
adir,mfilename:string;
i:integer;
self:TNxCustomBusinessObject;
mquery:string;
mTarget:string;
begin
   mTarget:='\\CZVS0006\AbraExport\SK_Lipoelastic'  ;
   Success := True;
   LogInfoStr := '';
             mr:=tstringlist.create;
             self:= os.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
             try
               os.sqlselect('SELECT A.ID FROM StoreDocuments A WHERE A.DocumentType=' +quotedstr('21') + ' AND (A.DocQueue_ID IN (' + quotedstr('27L1000101') + '))'
                            +' AND (A.DocDate$DATE >= ' +  NxFloatToIBStr(Date)
                            +'  and A.DocDate$DATE < ' + NxFloatToIBStr(Date+1)
                            +' )' ,mr);
               LogInfoStr := LogInfoStr + 'Počet záznamů: DPPO' + inttostr(mr.count) + chr(10);
               if mr.count>0 then begin
                       for i := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                  self.load(mr.Strings[i],nil);

                                   adir:='';
                                      if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                            NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                            exit;
                                      end else begin
                                            adir:=mExportDir + trim(copy(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID'),20,50));
                                      end;




                                                            mquery:=NxGetAPIHeadJSON(OS,self,'PR','Supervisor');
                                                            mquery:=mquery + NxGetAPIDocument(os,self);
                                                            mquery:=mquery + ']' + '}' + '}';


                                                             mQueryStringList := TStringList.Create;
                                                               try
                                                                   mQueryStringList.add(mQuery);

                                                                   mQueryStringList.SaveToFile(mTarget + '\' + 'PR' + '\'
                                                                                         + self.GetFieldValueAsString('DocQueue_ID.CODE') + '_'
                                                                                         + inttostr(self.GetFieldValueAsinteger('Ordnumber')) + '_'
                                                                                         + self.GetFieldValueAsString('Period_ID.CODE')
                                                                                         + '.json');

                                                                LogInfoStr := LogInfoStr + mTarget + '\' + 'PR' + '\'
                                                                                         + self.GetFieldValueAsString('DocQueue_ID.CODE') + '_'
                                                                                         + inttostr(self.GetFieldValueAsinteger('Ordnumber')) + '_'
                                                                                         + self.GetFieldValueAsString('Period_ID.CODE')
                                                                                         + '.json' + chr(10);
                                                                finally
                                                                  mQueryStringList.free;
                                                                end;


                        end;
               end;

               Success:=true;
           finally
               mr.free;
               self.free;
           end;

end;




begin
end.