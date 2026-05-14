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
 mbo,mBO1_DF:TNxCustomBusinessObject;
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
   mname,mparameter:string;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
       morig:=TBusRollSiteForm(mSite).CurrentObject.oid;
        if mBookmark.count=0 then begin
            mBO := TBusRollSiteForm(mSite).CurrentObject;
                 for ii:=1 to 36 do begin
                     mname:='mbo.GetFieldValueAsString(' + quotedstr('X_par' + inttostr(ii))+')';
                    // if not nxisblank(mbo.GetFieldValueAsString(quotedstr(mname))) then begin
                                     try
                                         // NxShowSimpleMessage(mname,nil);
                                          mBO1_DF:=msite.BaseObjectSpace.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                          // založení nového parametru
                                          mBO1_DF.new;
                                          mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                          mBO1_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis

                                          mBO1_DF.SetFieldValueAsString('X_ServicedObject_ID',mbo.oid); // sp
                                          if (copy(mbo.GetFieldValueAsString('code'),1,1)='A') or
                                             (copy(mbo.GetFieldValueAsString('code'),1,1)='E') or
                                             (copy(mbo.GetFieldValueAsString('code'),1,1)='V')
                                            then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','53L5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','63L5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','73L5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','83L5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','93L5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','A3L5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','B3L5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','C3L5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','3AL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','4AL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','5AL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','6AL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','7AL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','8AL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','9AL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','AAL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','BAL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','CAL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','DAL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','EAL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','FAL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','GAL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','HAL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','IAL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','JAL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','KAL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','LAL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MAL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','NAL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','OAL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','PAL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','QAL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','RAL5000101');
                                             end;




                                           if copy(mbo.GetFieldValueAsString('code'),1,2)='DP' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','3EL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','5EL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','6EL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','7EL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','8EL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','9EL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','AEL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','BEL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','CEL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','DEL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','EEL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','FEL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','GEL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','HEL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','IEL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','JEL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','KEL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','LEL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MEL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','NEL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','OEL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','PEL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','QEL5000101');
                                             end;


                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='K' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','RGL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','SGL5000101');

                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='M' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','TGL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','B3L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','UGL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','VGL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','WGL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','XGL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','YGL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','0HL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','ZGL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','1HL5000101');
                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='R' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','TGL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','2HL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','3HL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','4HL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','5HL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','6HL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','7HL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','8HL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','9HL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','AHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','BHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','CHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','DHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','EHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','FHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','GHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','HHL5000101');

                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='T' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','C3L5000101');

                                             end;

                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='Z' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','IHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','JHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','KHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','LHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','SGL5000101');

                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='PDO' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=36 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='PVO' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=36 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='PVP' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=36 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                             end;




                                             mBO1_DF.SetFieldValueAsString('Name',mBO1_DF.getFieldValueAsString('U_Parametr_ID.name'));

                                          if ii=1 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par1'));
                                          if ii=2 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par2'));
                                          if ii=3 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par3'));
                                          if ii=4 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par4'));
                                          if ii=5 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par5'));
                                          if ii=6 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par6'));
                                          if ii=7 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par7'));
                                          if ii=8 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par8'));
                                          if ii=9 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par9'));
                                          if ii=10 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par10'));
                                          if ii=11 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par11'));
                                          if ii=12 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par12'));
                                          if ii=13 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par13'));
                                          if ii=14 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par14'));
                                          if ii=15 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par15'));
                                          if ii=16 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par16'));
                                          if ii=17 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par17'));
                                          if ii=18 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par18'));
                                          if ii=19 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par19'));
                                          if ii=20 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par20'));
                                          if ii=21 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par21'));
                                          if ii=22 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par22'));
                                          if ii=23 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par23'));
                                          if ii=24 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par24'));
                                          if ii=25 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par25'));
                                          if ii=26 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par26'));
                                          if ii=27 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par27'));
                                          if ii=28 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par28'));
                                          if ii=29 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par29'));
                                          if ii=30 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par30'));
                                          if ii=31 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par31'));
                                          if ii=32 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par32'));
                                          if ii=33 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par33'));
                                          if ii=34 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par34'));
                                          if ii=35 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par35'));
                                          if ii=36 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par36'));





                                          mBO1_DF.SetFieldValueAsString('X_field5', 'V');
                                          if not (NxIsBlank(mBO1_DF.getFieldValueAsString('X_field2'))) then mBO1_DF.save;

                                     finally
                                          mBO1_DF.free;
                                     end;


                    //end;

                 end;

        end else begin
            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                    for ii:=1 to 36 do begin
                     mname:='mbo.GetFieldValueAsString(' + quotedstr('X_par' + inttostr(ii))+')';
                    // if not nxisblank(mbo.GetFieldValueAsString(quotedstr(mname))) then begin
                                     try
                                         // NxShowSimpleMessage(mname,nil);
                                          mBO1_DF:=msite.BaseObjectSpace.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                          // založení nového parametru
                                          mBO1_DF.new;
                                          mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                          mBO1_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis

                                          mBO1_DF.SetFieldValueAsString('X_ServicedObject_ID',mbo.oid); // sp
                                          if (copy(mbo.GetFieldValueAsString('code'),1,1)='A') or
                                             (copy(mbo.GetFieldValueAsString('code'),1,1)='E') or
                                             (copy(mbo.GetFieldValueAsString('code'),1,1)='V')
                                            then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','53L5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','63L5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','73L5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','83L5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','93L5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','A3L5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','B3L5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','C3L5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','3AL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','4AL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','5AL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','6AL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','7AL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','8AL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','9AL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','AAL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','BAL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','CAL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','DAL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','EAL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','FAL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','GAL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','HAL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','IAL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','JAL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','KAL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','LAL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MAL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','NAL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','OAL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','PAL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','QAL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','RAL5000101');
                                             end;




                                           if copy(mbo.GetFieldValueAsString('code'),1,2)='DP' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','3EL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','5EL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','6EL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','7EL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','8EL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','9EL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','AEL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','BEL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','CEL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','DEL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','EEL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','FEL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','GEL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','HEL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','IEL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','JEL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','KEL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','LEL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MEL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','NEL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','OEL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','PEL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','QEL5000101');
                                             end;


                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='K' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','RGL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','SGL5000101');

                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='M' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','TGL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','B3L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','UGL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','VGL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','WGL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','XGL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','YGL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','0HL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','ZGL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','1HL5000101');
                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='R' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','TGL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','2HL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','3HL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','4HL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','5HL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','6HL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','7HL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','8HL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','9HL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','AHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','BHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','CHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','DHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','EHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','FHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','GHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','HHL5000101');

                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='T' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','C3L5000101');

                                             end;

                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='Z' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','33L5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','43L5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','IHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','JHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','KHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','LHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','SGL5000101');

                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='PDO' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=36 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='PVO' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=36 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                             end;
                                             if copy(mbo.GetFieldValueAsString('code'),1,1)='PVP' then begin

                                                if ii=1 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=2 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=3 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=4 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=5 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=6 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=7 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=8 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=9 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=10 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=11 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=12 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=13 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=14 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=15 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=16 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=17 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=18 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=19 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=20 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=21 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=22 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=23 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=24 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=25 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=27 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=28 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=29 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=30 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=31 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=32 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=33 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=34 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=35 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                                if ii=36 then mBO1_DF.SetFieldValueAsString('U_Parametr_ID','MHL5000101');
                                             end;




                                             mBO1_DF.SetFieldValueAsString('Name',mBO1_DF.getFieldValueAsString('U_Parametr_ID.name'));

                                          if ii=1 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par1'));
                                          if ii=2 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par2'));
                                          if ii=3 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par3'));
                                          if ii=4 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par4'));
                                          if ii=5 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par5'));
                                          if ii=6 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par6'));
                                          if ii=7 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par7'));
                                          if ii=8 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par8'));
                                          if ii=9 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par9'));
                                          if ii=10 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par10'));
                                          if ii=11 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par11'));
                                          if ii=12 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par12'));
                                          if ii=13 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par13'));
                                          if ii=14 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par14'));
                                          if ii=15 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par15'));
                                          if ii=16 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par16'));
                                          if ii=17 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par17'));
                                          if ii=18 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par18'));
                                          if ii=19 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par19'));
                                          if ii=20 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par20'));
                                          if ii=21 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par21'));
                                          if ii=22 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par22'));
                                          if ii=23 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par23'));
                                          if ii=24 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par24'));
                                          if ii=25 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par25'));
                                          if ii=26 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par26'));
                                          if ii=27 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par27'));
                                          if ii=28 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par28'));
                                          if ii=29 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par29'));
                                          if ii=30 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par30'));
                                          if ii=31 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par31'));
                                          if ii=32 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par32'));
                                          if ii=33 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par33'));
                                          if ii=34 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par34'));
                                          if ii=35 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par35'));
                                          if ii=36 then mBO1_DF.SetFieldValueAsString('X_field2', mbo.GetFieldValueAsString('X_par36'));





                                          mBO1_DF.SetFieldValueAsString('X_field5', 'V');
                                          if not (NxIsBlank(mBO1_DF.getFieldValueAsString('X_field2'))) then mBO1_DF.save;

                                     finally
                                          mBO1_DF.free;
                                     end;

            end;
            end;
        end;

 TBusRollSiteForm(mSite).Refresh;
 mDBGrid.Refresh;
     msite.Refresh;
     //msite.ActiveDataSet.seekid(mbo.oid);
     //msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
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
  mMAction.Caption := 'prepis';
  mMAction.Hint := 'prepis';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SloucitExecuteItem;
  mMAction.Items.Add('Prepis');


end;


begin
end.