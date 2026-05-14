var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
          mOLE, mRoll, mOResult: Variant;
    mids:tstringlist;


procedure SloucitExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   morig:string;
   mi:Integer;
   mlist:TStringList;
   mfirm_ID,mPayerFirm_ID:string;
    mImportFile:TStringList;
    mTargetFile:TStringList;
    AFileName:string;
    zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mi_result:integer;
  mprefix_pomoc:string;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if PromptForFileName(AFileName, '', '', 'Soubory SP', 'C:\AAA', False) then begin
          mdir:=copy(Afilename,0,NxCharPosR('\',Afilename));
          mFile:=copy(Afilename,1+NxCharPosR('\',Afilename),Length(Afilename));
         // Import_SP_OD(msite.baseobjectspace, Afilename, Adir,Afile,msite,true,false);
        end else begin
      Result := False;
      exit;
    end;

    mImportFile := TStringList.Create;
    mImportFile.LoadFromFile(AFileName);


    //mImportFile.strings[i]:= NxSearchReplace(mImportFile.strings[i],'"','',2);
        if mBookmark.count=0 then begin
            mBO := TBusRollSiteForm(mSite).CurrentObject;
            {mprefix_pomoc:='S';
            if not NxIsEmptyOID(mbo.getFieldValueAsString('BusOrder_ID')) then begin
                    mprefix_pomoc:=copy(mbo.getFieldValueAsString('BusOrder_ID.code'),1,2);
                           if mprefix_pomoc='SK' then begin
                                 mprefix_pomoc:='K';
                            end else begin
                                 if mprefix_pomoc<>'' then begin
                                     mprefix_pomoc:=copy(mprefix_pomoc,1,1);
                                     if (mprefix_pomoc<>'A') AND (mprefix_pomoc<>'V') then  mprefix_pomoc:='S';
                                 end else begin
                                     mprefix_pomoc:='S';
                                 end;
                            end;
              end else begin
                  mprefix_pomoc:='S'
              end;

            if Length(mbo.getFieldValueAsString('X_ID_Obchodni_dokumentace'))<>8 then begin
              if trim(mbo.getFieldValueAsString('X_ID_Obchodni_dokumentace'))<>'' then begin


                    mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc + NxPadL(mbo.getFieldValueAsString('X_ID_Obchodni_dokumentace'), 7, '0'));
              end else begin
                  mr:=TStringList.create;
                  try
                      msite.BaseObjectSpace.SQLSelect('Select max(X_ID_Obchodni_dokumentace) from servicedobjects where substring(X_ID_Obchodni_dokumentace from 1 for 2)='+quotedstr(mprefix_pomoc+'9'),mr);
                      if mr.count>0 then begin
                          if mr.Strings[0]<>'' then begin
                               //if NxIsNumeric(copy(mr.Strings[0],3,6)) then begin
                                     mi_result:=strtoint(copy(mr.Strings[0],3,6)) + 1 ;
                                     mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL(inttostr(mi_result), 6, '0'));
                               //end;
                          end else begin
                                mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL('1', 6, '0'));
                          end;
                      end else begin
                         mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL('1', 6, '0'));
                      end;
                  finally
                     mr.free;
                  end;

              end;
              mbo.save;
            end;  }
            mImportFile.Add('rename ' +mbo.oid +' ' + mbo.GetFieldValueAsString('X_ID_Obchodni_dokumentace'))   ;





        end else begin
            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                    {      mprefix_pomoc:='S';
            if not NxIsEmptyOID(mbo.getFieldValueAsString('BusOrder_ID')) then begin
                    mprefix_pomoc:=copy(mbo.getFieldValueAsString('BusOrder_ID.code'),1,2);
                           if mprefix_pomoc='SK' then begin
                                 mprefix_pomoc:='K';
                            end else begin
                                 if mprefix_pomoc<>'' then begin
                                     mprefix_pomoc:=copy(mprefix_pomoc,1,1);
                                     if (mprefix_pomoc<>'A') AND (mprefix_pomoc<>'V') then mprefix_pomoc:='S';
                                 end else begin
                                     mprefix_pomoc:='S';
                                 end;
                            end;
              end else begin
                  mprefix_pomoc:='S'
              end;


                   if Length(mbo.getFieldValueAsString('X_ID_Obchodni_dokumentace'))<>8 then begin
              if trim(mbo.getFieldValueAsString('X_ID_Obchodni_dokumentace'))<>'' then begin

                    mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc + NxPadL(mbo.getFieldValueAsString('X_ID_Obchodni_dokumentace'), 7, '0'));

              end else begin
                  mr:=TStringList.create;
                  try
                      msite.BaseObjectSpace.SQLSelect('Select max(X_ID_Obchodni_dokumentace) from servicedobjects where substring(X_ID_Obchodni_dokumentace from 1 for 2)='+quotedstr(mprefix_pomoc+'9'),mr);
                      if mr.count>0 then begin
                          if mr.Strings[0]<>'' then begin
                               if NxIsNumeric(copy(mr.Strings[0],3,6)) then begin
                                     mi_result:=strtoint(copy(mr.Strings[0],3,6)) + 1;

                                     mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL(inttostr(mi_result), 6, '0'));
                               end else begin
                                mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL('1', 6, '0'));
                               end;
                          end;
                      end else begin
                         mbo.setFieldValueAsString('X_ID_Obchodni_dokumentace',mprefix_pomoc+'9' + NxPadL('1', 6, '0'));
                      end;
                  finally
                     mr.free;
                  end;

              end;
              mbo.save;
            end;       }
            mImportFile.Add('rename ' +mbo.oid +' ' + mbo.GetFieldValueAsString('X_ID_Obchodni_dokumentace'))   ;

            end;
        end;
      mImportFile.SaveToFile(AFileName);

      //Result := NxShellExecute('open',mFile,'',NxAddSlash(mdir)) ;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin

     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Rename_dir';
  mMAction.Hint := 'Rename_dir';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SloucitExecuteItem;
  mMAction.Items.Add('Přejmenování adresáře');


end;





begin
end.