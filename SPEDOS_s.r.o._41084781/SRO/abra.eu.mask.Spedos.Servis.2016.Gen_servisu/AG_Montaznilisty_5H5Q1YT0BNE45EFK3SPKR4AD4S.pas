


procedure zaplacenoOnExecute(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo,mbo_ml,mbo_ServiceAssembyForms,mbo_target2:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mr2,mr3,mrx,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
mNewRow,mbo_target: TNxCustomBusinessObject;
   mdate:Double;
   mBookmark:TBookmarkList;
   mcastka:double;
   mi:integer;
   mStrings:String;
   mID:string;
    self2:TNxCustomBusinessObject;
    mheaderBO,mDocQueue:TNxCustomBusinessObject;
    mposun:double;
    mr1:TStringList;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_posun:Double;
    mD_posun,mD_posunZ:date;
    mI_posun:integer;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mbo_target := msite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                     try
                     mbo_target.load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('servicedocument_ID'),nil);



                                // * * *  generování následného servisu podle smlouvy
                                if (mbo_target.GetFieldValueAsString('DocQueue_ID')='4B20000101') or (mbo_target.GetFieldValueAsString('DocQueue_ID')='8B20000101') or
                                   (mbo_target.GetFieldValueAsString('DocQueue_ID')='9B20000101') then begin
                                   if mbo_target.GetFieldValueAsInteger('ServiceDocState_ID.PosIndex')>18 then begin

                                      if not NxIsEmptyOID(mbo_target.GetFieldValueAsString('BusProject_ID')) then begin
                                          try
                                              mBO_BusProject:=mbo_target.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                              mBO_BusProject.load(mbo_target.GetFieldValueAsString('BusProject_ID'),nil);
                                               if mBO_BusProject.GetFieldValueAsBoolean('X_Generovat_prohlidky') then begin
                                                   if mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR')<>0 then begin      // počet prohlídek do roka
                                                        mD_posun:=NxIncMonth(mbo_target.getFieldValueAsDateTime('PromisedDeadLine$DATE'),trunc(mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR')));
                                                    //    mD_posunZ:=mbo_target.getFieldValueAsDateTime('PromisedDeadLine$DATE') + (365/mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR'));
                                                   end;
                                                     if pos(mBO_BusProject.GetFieldValueAsString('X_Obdobi_prohlidek'),'A')<>0 then begin   // korekce na období
                                                        // prohlidky
                                                        mI_posun:= NxGetMonth(mD_posun);
                                                        while (copy(mBO_BusProject.GetFieldValueAsString('X_Obdobi_prohlidek'),mi_posun,1)='A') and (i<=14) do begin
                                                            mD_posun:=NxIncMonth(mD_posun,1);
                                                            mD_posunZ:=NxIncMonth(mD_posunZ,1);
                                                            mI_posun:= NxGetMonth(mD_posun);
                                                            //NxShowSimpleMessage(inttostr(mI_posun),nil);
                                                            i:=i+1;
                                                        end;
                                                     end;
                                                     mr1:=tstringlist.Create;
                                                      try
                                                            mbo_target2:=mbo_target.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');    // založení nového sl
                                                            mbo_target2.ObjectSpace.SQLSelect(format('select sd.id from ServiceDocuments sd left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.ServicedObject_ID=%s and sd.Docqueue_ID=%s and ss.PosIndex<15 and sd.id<>%s',[quotedstr(mbo_target.GetFieldValueAsString('ServicedObject_ID')),quotedstr(mbo_target.GetFieldValueAsString('DocQueue_ID')),quotedstr(mbo_target.OID)]),mr1);
                                                           if mr1.count>0 then begin
                                                                mbo_target2.load(mr1.Strings[0],nil);
                                                               //NxShowSimpleMessage(NxFloatToIBStr(trunc(md_posun)),nil);
                                                               if mposun<mbo_target2.getFieldValueAsDateTime('PromisedDeadLine$DATE') then begin
                                                                    mbo_target2.SetFieldValueAsDateTime('docdate$date',FloatToDateTime(trunc(md_posun))) ;
                                                                    mbo_target2.SetFieldValueAsDateTime('PromisedDeadLine$DATE',FloatToDateTime(trunc(md_posun))) ;
                                                                    mbo_target2.save;
                                                               end;
                                                            end else begin
                                                                mbo_target2.new;
                                                                            mbo_target2.Prefill;
                                                                            mbo_target2.SetFieldValueAsString('Docqueue_ID', mbo_target.GetFieldValueAsString('Docqueue_ID'));
                                                                            mbo_target2.SetFieldValueAsDateTime('Docdate$date',FloatToDateTime(trunc(md_posun))) ;
                                                                            mbo_target2.SetFieldValueAsstring('ServicedObject_ID',mbo_target.GetFieldValueAsString('ServicedObject_ID'));

                                                                            mbo_target2.SetFieldValueAsstring('ServicedObjectIDCode','');
                                                                            mbo_target2.SetFieldValueAsstring('ServicedObjectText','');


                                                                            mbo_target2.SetFieldValueAsstring('Firm_ID',mbo_target.GetFieldValueAsString('Firm_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('PayerFirm_ID',mbo_target.GetFieldValueAsString('PayerFirm_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('FirmOffice_ID',mbo_target.GetFieldValueAsString('FirmOffice_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('PayerFirmOffice_ID',mbo_target.GetFieldValueAsString('PayerFirmOffice_ID'));
                                                                            mbo_target2.SetFieldValueAsString('Division_ID', mbo_target.GetFieldValueAsString('Division_ID'));
                                                                            mbo_target2.SetFieldValueAsString('BusOrder_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'));
                                                                            mbo_target2.SetFieldValueAsString('BusTransaction_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'));
                                                                            mbo_target2.SetFieldValueAsString('BusProject_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'));
                                                                            //self2.SetFieldValueAsString('AcceptedByUser_ID', '1410000101');
                                                                            mbo_target2.SetFieldValueAsDateTime('PromisedDeadLine$DATE', FloatToDateTime(trunc(md_posun)));
                                                                            if mbo_target2.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky')<>'' then begin
                                                                               mbo_target2.SetFieldValueAsstring('X_objednani', mbo_target.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky'));
                                                                            end else begin
                                                                               //mbo_target.SetFieldValueAsstring('X_objednani', mbo.GetFieldValueAsstring('X_objednani'));
                                                                            end;
                                                                            mbo_target2.SetFieldValueAsstring('ServiceDocState_ID','9900000101');
                                                                              // řádky montážního listu

                                                                            mbo_target2.Save ;
                                                                            mBO_ML:=mbo_target2.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                                  try
                                                                                     mBO_ML.new;
                                                                                     mBO_ML.Prefill;
                                                                                     mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',trunc(mbo_target2.GetFieldValueAsDateTime('PromisedDeadLine$DATE')));
                                                                                     mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mbo_target2.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                                                     mBO_ML.SetFieldValueAsString('ServiceDocument_ID',mbo_target.OID);
                                                                                     mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target2.GetFieldValueAsString('ServicedObject_ID'));
                                                                                     mBO_ML.SetFieldValueAsstring('X_State','3XQ1000101');
                                                                                     mBO_ML.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target2.GetFieldValueAsString('ServicedObject_ID'));
                                                                                     mBO_ML.SetFieldValueAsstring('X_id_zakaznika_id',mbo_target2.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                                     mBO_ML.SetFieldValueAsInteger('AssemblyState',0);
                                                                                     mr2:=TStringList.Create;
                                                                                     try
                                                                                          mbo_target2.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo_target2.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                                          if mr2.count=1 then begin
                                                                                             mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                                                          end;
                                                                                      finally
                                                                                         mr2.free;
                                                                                      end;
                                                                                      mr2:=TStringList.Create;
                                                                                      try
                                                                                          mbo_target2.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo_target2.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                                          if mr2.count=1 then begin
                                                                                             mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                                                          end;
                                                                                      finally
                                                                                          mr2.free;
                                                                                      end;
                                                                                     mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mbo_target2.GetFieldValueAsString('Docqueue_ID'));
                                                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mbo_target2.GetFieldValueAsInteger('Ordnumber'));
                                                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mbo_target2.GetFieldValueAsString('Period_ID'));
                                                                                    finally

                                                                                    end;


                                                            end;
                                                      finally
                                                          mr1.free;
                                                          mbo_target2.free;
                                                          mBO_ML.free;
                                                      end;
                                              end;
                                              mBO_BusProject.free;
                                          finally

                                          end;


                                     end;
                                   end;
                                   end;



                       finally
                          mbo_target.free;
                       end;
                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                        mbo_target := msite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                     try
                     mbo_target.load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('servicedocument_ID'),nil);



                                          // * * *  generování následného servisu podle smlouvy
                                if (mbo_target.GetFieldValueAsString('DocQueue_ID')='4B20000101') or (mbo_target.GetFieldValueAsString('DocQueue_ID')='8B20000101') or
                                   (mbo_target.GetFieldValueAsString('DocQueue_ID')='9B20000101') then begin
                                   if mbo_target.GetFieldValueAsInteger('ServiceDocState_ID.PosIndex')>14 then begin

                                      if not NxIsEmptyOID(mbo_target.GetFieldValueAsString('BusProject_ID')) then begin
                                          try
                                              mBO_BusProject:=mbo_target.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                              mBO_BusProject.load(mbo_target.GetFieldValueAsString('BusProject_ID'),nil);
                                               if mBO_BusProject.GetFieldValueAsBoolean('X_Generovat_prohlidky') then begin
                                                   if mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR')<>0 then begin      // počet prohlídek do roka
                                                        mD_posun:=NxIncMonth(mbo_target.getFieldValueAsDateTime('PromisedDeadLine$DATE'),trunc(mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR')));
                                                    //    mD_posunZ:=mbo_target.getFieldValueAsDateTime('PromisedDeadLine$DATE') + (365/mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR'));
                                                   end;
                                                     if pos(mBO_BusProject.GetFieldValueAsString('X_Obdobi_prohlidek'),'A')<>0 then begin   // korekce na období
                                                        // prohlidky
                                                        mI_posun:= NxGetMonth(mD_posun);
                                                        while (copy(mBO_BusProject.GetFieldValueAsString('X_Obdobi_prohlidek'),mi_posun,1)='A') and (i<12) do begin
                                                            mD_posun:=NxIncMonth(mD_posun,1);
                                                            mD_posunZ:=NxIncMonth(mD_posunZ,1);
                                                            mI_posun:= NxGetMonth(mD_posun);
                                                            //NxShowSimpleMessage(inttostr(mI_posun),nil);
                                                            i:=i+1;
                                                        end;
                                                     end;
                                                     mr1:=tstringlist.Create;
                                                      try
                                                            mbo_target2:=mbo_target.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');    // založení nového sl
                                                            mbo_target2.ObjectSpace.SQLSelect(format('select sd.id from ServiceDocuments sd left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.ServicedObject_ID=%s and sd.Docqueue_ID=%s and ss.PosIndex<15 and sd.id<>%s',[quotedstr(mbo_target.GetFieldValueAsString('ServicedObject_ID')),quotedstr('4B20000101'),quotedstr(mbo_target.OID)]),mr1);
                                                           if mr1.count>0 then begin
                                                                mbo_target2.load(mr1.Strings[0],nil);
                                                               if mposun<mbo_target2.getFieldValueAsDateTime('PromisedDeadLine$DATE') then begin
                                                                    mbo_target2.SetFieldValueAsDateTime('docdate$date',mbo_target.getFieldValueAsDateTime('docdate$date')+ trunc(md_posun)) ;
                                                                    mbo_target2.SetFieldValueAsDateTime('PromisedDeadLine$DATE',trunc(md_posun)) ;
                                                                    //mbo_target2.SetFieldValueAsString('AcceptedByUser_ID','2L00000101') ;
                                                               end;
                                                            end else begin
                                                                mbo_target2.new;
                                                                            mbo_target2.Prefill;
                                                                            mbo_target2.SetFieldValueAsString('Docqueue_ID', mbo_target.GetFieldValueAsString('Docqueue_ID'));
                                                                            mbo_target2.SetFieldValueAsDateTime('Docdate$date', mbo_target.getFieldValueAsDateTime('docdate$date')+ trunc(md_posun)) ;

                                                                            mbo_target2.SetFieldValueAsstring('ServicedObjectIDCode','');
                                                                            mbo_target2.SetFieldValueAsstring('ServicedObjectText','');

                                                                            mbo_target2.SetFieldValueAsstring('ServicedObject_ID',mbo_target.GetFieldValueAsString('ServicedObject_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('Firm_ID',mbo_target.GetFieldValueAsString('Firm_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('PayerFirm_ID',mbo_target.GetFieldValueAsString('PayerFirm_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('FirmOffice_ID',mbo_target.GetFieldValueAsString('FirmOffice_ID'));
                                                                            mbo_target2.SetFieldValueAsstring('PayerFirmOffice_ID',mbo_target.GetFieldValueAsString('PayerFirmOffice_ID'));
                                                                            mbo_target2.SetFieldValueAsString('Division_ID', mbo_target.GetFieldValueAsString('Division_ID'));
                                                                            mbo_target2.SetFieldValueAsString('BusOrder_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'));
                                                                            mbo_target2.SetFieldValueAsString('BusTransaction_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'));
                                                                            mbo_target2.SetFieldValueAsString('BusProject_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'));
                                                                            //mbo_target2.SetFieldValueAsString('AcceptedByUser_ID', mbo_target.GetFieldValueAsString('AcceptedByUser_ID'));
                                                                            mbo_target2.SetFieldValueAsDateTime('PromisedDeadLine$DATE', trunc(md_posun));
                                                                            if mbo_target2.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky')<>'' then begin
                                                                               mbo_target2.SetFieldValueAsstring('X_objednani', mbo_target.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky'));
                                                                            end else begin
                                                                               //mbo_target.SetFieldValueAsstring('X_objednani', mbo.GetFieldValueAsstring('X_objednani'));
                                                                            end;
                                                                            mbo_target2.SetFieldValueAsstring('ServiceDocState_ID','9900000101');
                                                                              // řádky montážního listu

                                                                            mbo_target2.Save ;
                                                                            mBO_ML:=mbo_target2.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                                  try
                                                                                     mBO_ML.new;
                                                                                     mBO_ML.Prefill;
                                                                                     mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',trunc(mbo_target2.GetFieldValueAsDateTime('PromisedDeadLine$DATE')));
                                                                                     mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mbo_target2.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                                                     mBO_ML.SetFieldValueAsString('ServiceDocument_ID',mbo_target.OID);
                                                                                     mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target2.GetFieldValueAsString('ServicedObject_ID'));
                                                                                     mBO_ML.SetFieldValueAsstring('X_State','3XQ1000101');
                                                                                     mBO_ML.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target2.GetFieldValueAsString('ServicedObject_ID'));
                                                                                     mBO_ML.SetFieldValueAsstring('X_id_zakaznika_id',mbo_target2.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                                     mBO_ML.SetFieldValueAsInteger('AssemblyState',0);
                                                                                     mr2:=TStringList.Create;
                                                                                     try
                                                                                          mbo_target2.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo_target2.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                                          if mr2.count=1 then begin
                                                                                             mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                                                          end;
                                                                                      finally
                                                                                         mr2.free;
                                                                                      end;
                                                                                      mr2:=TStringList.Create;
                                                                                      try
                                                                                          mbo_target2.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo_target2.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                                          if mr2.count=1 then begin
                                                                                             mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                                                          end;
                                                                                      finally
                                                                                          mr2.free;
                                                                                      end;
                                                                                     mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mbo_target2.GetFieldValueAsString('Docqueue_ID'));
                                                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mbo_target2.GetFieldValueAsInteger('Ordnumber'));
                                                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mbo_target2.GetFieldValueAsString('Period_ID'));
                                                                                    finally

                                                                                    end;


                                                            end;
                                                      finally
                                                          mr1.free;
                                                          mbo_target2.free;
                                                          mBO_ML.free;
                                                      end;
                                              end;
                                              mBO_BusProject.free;
                                          finally

                                          end;


                                     end;
                                   end;
                                   end;

              finally
                                  mbo_target.free;

              end;



                  end;
             end;

//        TDynSiteForm(mSite).RefreshData;


end;






 procedure InitSite_Hook(mbo_target: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin

    mMAction := mbo_target.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Následný servis';
  mMAction.Hint := 'Následný servis';
  mMAction.Category := 'tablist';
  mMAction.OnExecuteItem := @zaplacenoOnExecute;


end;

begin
end.