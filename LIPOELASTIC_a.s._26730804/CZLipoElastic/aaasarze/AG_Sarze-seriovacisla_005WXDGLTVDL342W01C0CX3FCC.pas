 uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';





const
mShowDebug=False;
var
     mBookmark : TBookmarkList;
     index:integer;



     procedure CheckDocumentSC(Sender: TAction; Index: integer);
var
 mbo,mboNew:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   msave:Boolean;
   mQuantityTemp,mQuantityVratka,mQuantityDoc, mQuantityPomoc, mQuantitySource:double;
   mBoolean:boolean;
begin
  msite:=TComponent(Sender).Site;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TBusRollSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin
           if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                              mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
//                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
//                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.quantity '+
                                                                                    ' FROM IssuedInvoices2 ii2 '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
//                                                                                    ' left join DocRowBatches DRB on DRB.Parent_ID= ii2.ProvideRow_ID' +
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (II2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by ii2.quantity desc',mr) ;





                              end;

                              if index=1 then begin
//                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
//                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreDocuments2 sd2  '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' left join DocRowBatches DRB on DRB.Parent_ID= ii2.ProvideRow_ID' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (SD.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('20') + ') order by sd2.quantity desc',mr) ;

                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=sd.Firm_ID ' +
                                                                                    ' left join DocRowBatches DRB on DRB.Parent_ID= ii2.ProvideRow_ID' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (SD.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('21') + ') order by sd2.quantity desc',mr) ;

                              end;



                                    if mShowDebug then  NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],21,10));
                                             if mShowDebug then NxShowSimpleMessage(' Množství ' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' mQuantity pomoc ' + NxFloatToIBStr(mQuantityPomoc),nil);

                                      if mQuantityPomoc>0  then begin

                                            mQuantityVratka:=0;
                                            try
                                            if index=0 then begin
                                            // ******** již vráceno

                                                          mx:=tstringlist.create;
                                                           try
                                                                 msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[0],11,10)),mx);
                                                                 if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                                 if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                           finally
                                                               mx.free;
                                                           end;
                                             end;
                                             finally

                                             end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_quantity) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_parent2_id=' +
                                                                                       quotedstr(copy(mr.Strings[0],11,10)),mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;



                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','2050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                                                   TBusRollSiteForm(mSite).CurrentObject.save;
                                                             end;
                                     end;
                                    end;
                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin
                                            mbonew:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                            try
                                            mboNew.new;
                                                mboNew.Prefill;
                                                if mShowDebug then   NxShowSimpleMessage('Založen na zbytek',nil);
                                                mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                mbonew.SetFieldValueAsString('X_PM_State','2050000101');
                                                if index=0 then mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                if index=1 then mbonew.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                if index=4 then mbonew.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                //NxShowSimpleMessage('Příprava uložení zbtku',nil);
                                                mbonew.save;
                                                if mShowDebug then  NxShowSimpleMessage('Zbytek Uložen',nil);
                                                mQuantityPomoc:=mQuantityPomoc-mQuantityPomoc;
                                             finally
                                                mbonew.free;
                                             end;
                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;
                            TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                            msite.Refresh;

         end
    end else begin
         for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                          ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                end else begin

                             mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.quantity '+
                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                    ' WHERE (ii.Firm_id='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) +') and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                    ') order by ii2.quantity desc',mr) ;
                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' WHERE (sd.Firm_id='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) +') and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('21') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' WHERE (sd.Firm_id='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) +') and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;



                                    if mShowDebug then NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then  NxShowSimpleMessage(mr.Strings[i],nil);
                                            if mShowDebug then NxShowSimpleMessage(' Množství ' + copy(mr.Strings[0],21,10),nil);
                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],21,10));
                                      if mQuantityPomoc>0  then begin

                                            // ******** již vráceno
                                         if index=0 then begin   mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[0],11,10)),mx);
                                                       if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                       if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                 finally
                                                     mx.free;
                                                 end;
                                         end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_quantity) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_parent2_id=' +
                                                                                       quotedstr(copy(mr.Strings[0],11,10)),mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;


                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','2050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                             end;
                                     end;
                                    end;
                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin
                                            mbonew:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                            try
                                            mboNew.new;
                                                mboNew.Prefill;
                                                if mShowDebug then NxShowSimpleMessage('Založen na zbytek',nil);
                                                mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                //if mShowDebug then  NxShowSimpleMessage('Příprava uložení zbtku',nil);
                                                mbonew.save;
                                                if mShowDebug then  NxShowSimpleMessage('Zbytek Uložen',nil);
                                                mQuantityPomoc:=mQuantityPomoc-mQuantityPomoc;
                                             finally
                                                mbonew.free;
                                             end;
                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;


                 end;
                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                 msite.Refresh;

         end;

    end;


ProgressDispose()   ;



end;



function CreateAllDocFromWorkListImport(msite:tSiteform;mCLSIDInput:string;mCLSIDOuput:string;mAgenda:string;mDocqueue_ID:string;mFirm_id:string;mDivision_ID:string;mStore_ID:string;mDocList:tstringlist;mRowList:tstringlist):string;
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  x,xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mtext:string;
  mValidateList:tstringlist;
  mRowsOutput,mRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mIDoc:integer;
  mVratka,mr:TStringList;
  mi:integer;
  msearch:boolean;
  i:integer;
  mBOVratka,mDefRoll:TNxCustomBusinessObject;
  mpocet:double;
begin
  mOS := msite.BaseObjectSpace;
  try
       mInputParams := TNxParameters.Create;
       mImportMan := NxCreateDocumentImportManager(mOS, 'O3BDOKTWEFD13ACM03KIU0CLP4', 'W402MSU3BBDL3ACR03KIU0CLP4');
      try
        //for mIDoc:=0 to mDocList.count-1 do begin
            // NxShowSimpleMessage('Dokladů ' + inttostr(mdoclist.count)  + ' - ' + mdoclist.Strings[0],nil);
             mImportMan.AddInputDocument(mDocList.Strings[0]);
        //end;

        mImportMan.LoadParams(mInputParams);

        //NxShowSimpleMessage('AA',nil);
        mImportMan.Execute;
        //NxShowSimpleMessage('bb',nil);
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2781000101' ); // musi byt...          '2781000101'
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mfirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID', 'PA10000101'); // musi byt...
          //NxShowSimpleMessage('CC',nil);
          mImportMan.OutputDocument.SetFieldValueAsinteger('Acknowledge',0); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription', 'Vraceni'); // musi byt...
       // NxShowSimpleMessage('dd',nil);



        if Assigned(mImportMan.OutputDocument) then begin
                 mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

                        //NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                        for xx:=0 to mRowsOutput.Count-1 do begin
                              mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',true);
                        end;
                        msave:=false;
                        for xxx:=0 to mRowList.Count-1 do begin
                              mFind:=false;
                              for xx:=0 to mRowsOutput.Count-1 do begin

                                   //NxShowSimpleMessage(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')+' = ' + mRowList.Strings[xxx],nil);
                                   if mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')=mRowList.Strings[xxx] then begin
                                      // NxShowSimpleMessage('Nalezeno',nil);
                                       mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID',mstore_ID);
                                       mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',false);
                                       //mRowsOutput.BusinessObject[xx].SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mRowList.Strings[xxx],51,10)));
                                      // mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID','2G10000101');
                                       msave:=true;
                                       mFind:=true;
                                   end;
                             end;
                            // if not mFind then mxList.add(mRowList.Strings[xxx]);

                        end;
                       for xx:=0 to mRowsOutput.Count-1 do begin
                              if mRowsOutput.BusinessObject[xx].GetFieldValueAsBoolean('X_MArkForDelete') then mRowsOutput.BusinessObject[xx].MarkForDelete;
                       end;
                   mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                //  NxShowSimpleMessage('K ulození radků  ' + inttostr(mRowsOutput.count),nil);

   end;
           mImportMan.CheckOutputDocument;


         if msave then begin
                            // NxShowSimpleMessage('Ukladani',nil);
                            mImportMan.OutputDocument.ClearValidateErrors;
                                      if Not mImportMan.OutputDocument.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mImportMan.OutputDocument.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořendoklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             //NxShowSimpleMessage('Chyba',nil);
                                             TDynSiteForm(msite).ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mImportMan.OutputDocument);
                                             result:='Chyba';
                                      end else begin
                                           mImportMan.OutputDocument.Save;
                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                           result:=mImportMan.OutputDocument.oid;
                                          //NxShowSimpleMessage('Byl vytvořen doklad',nil);

                                          mvratka:=tstringlist.create;

                                          try
                                          mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                                                      //NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                                                      for xxx:=0 to mRowList.Count-1 do begin
                                                            for xx:=0 to mRowsOutput.Count-1 do begin
                                                                 if mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')=mRowList.Strings[xxx] then begin
                                                                    mi:=msite.BaseObjectSpace.SQLExecute('update defrolldata set X_EN_NAZEV=' + quotedstr(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('ProvideRow_ID')) +
                                                                                                         ' where x_parent2_ID=' + quotedstr(mRowList.Strings[xxx])  + ' and CLSID= ' + quotedstr('45D1XVW5EY24JBXTOE01EHYRSG')) ;


                                                                                 msearch:=false;
                                                                                 for i:=0 to mvratka.count-1 do begin
                                                                                        if mvratka.strings[i]=mRowsOutput.BusinessObject[xx].GetFieldValueAsString('Provide_ID') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mvratka.add(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('Provide_ID'));



                                                                 end;
                                                           end;
                                                          // if not mFind then mxList.add(mRowList.Strings[xxx]);

                                                      end;
                                                      mImportMan.OutputDocument.Delete;


                                                mBOVratka:=msite.BaseObjectSpace.CreateObject('1T0I5SAOS3DL3ACU03KIU0CLP4');
                                                   mDefRoll:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                   try
                                                        for i:=0 to mVratka.count-1 do begin   // doklad
                                                            mBOVratka.load(mVratka.Strings[i],nil);
                                                                  mRows := mBOVratka.GetLoadedCollectionMonikerForFieldCode(mBOVratka.GetFieldCode('Rows'));
                                                                      for xx:=0 to mrows.count-1 do begin   // řádek
                                                                           if mrows.BusinessObject[xx].GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek
                                                                                   if mrows.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                          mpocet:=0;

                                                                                          mMonBatches :=  mrows.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode( mrows.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                                                                              for xxx := 0 to mMonBatches.Count - 1 do begin
                                                                                                    mr:=tstringlist.create;
                                                                                                    try
                                                                                                         msite.BaseObjectSpace.SQLSelect('SELECT a.id FROM DefRollData A WHERE A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' AND A.X_EN_NAZEV=' +
                                                                                                         quotedstr(mrows.BusinessObject[xx].oid)  +  ' AND A.X_Batches=' + quotedstr(mMonBatches.BusinessObject[xxx].GetFieldValueAsString('StoreBatch_ID')),mr);
                                                                                                         if mr.count>0 then begin
                                                                                                              mDefRoll.load(mr.strings[0],nil);
                                                                                                              mpocet:=mMonBatches.BusinessObject[xxx].GetFieldValueAsFloat('Quantity')-mDefRoll.GetFieldValueAsFloat('X_vychystano');
                                                                                                              if mDefRoll.GetFieldValueAsFloat('X_vychystano')<=mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity') then begin

                                                                                                                  mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                 mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  mDefRoll.save;
                                                                                                               end else begin
                                                                                                                 //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                  mDefRoll.setFieldValueAsFloat('X_dodano',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                  mDefRoll.save;

                                                                                                              end;
                                                                                                         end else begin
                                                                                                              mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity')));
                                                                                                              mMonBatches.BusinessObject[xxx].MarkForDelete;
                                                                                                         end;
                                                                                                    finally
                                                                                                        mr.free;
                                                                                                    end;
                                                                                              end;

                                                                                   end;
                                                                           end;
                                                                      end;
                                                              mBOVratka.SetFieldValueAsString('Description','Reklamace 8/2021');


                                                               for xx:=0 to mrows.count-1 do begin   // řádek
                                                                   if mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')= 0 then mrows.BusinessObject[xx].MarkForDelete;
                                                               end;
                                                            mBOVratka.ClearValidateErrors;
                                                                        if Not mBOVratka.Validate() then begin
                                                                              mValidateList := TStringList.Create;
                                                                              try
                                                                                 mBOVratka.GetValidateErrors(mValidateList);
                                                                                 mText := mValidateList.Text;
                                                                                 NxToken(mText, '=');
                                                                                 MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                                 mtWarning, [mbOK], 0);
                                                                               finally
                                                                                 mValidateList.Free;
                                                                               end;
                                                                               //NxShowSimpleMessage('Chyba',nil);
                                                                               TDynSiteForm(msite).ShowDynFormWithNewDocument('BL0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBOVratka);
                                                                               result:='Chyba';
                                                                        end else begin
                                                                             mBOVratka.save;
                                                                             //NxShowSimpleMessage('Doklad uložen',nil);
                                                                             result:=mImportMan.OutputDocument.oid;
                                                                            //NxShowSimpleMessage('Byl vytvořen doklad',nil);
                                                                       end;
                                                        end;

                                                   finally
                                                       mBOVratka.free;
                                                       mDefRoll.free;
                                                   end;
                                          finally
                                             mvratka.free;
                                          end;


                                      end;

                      end else begin
                          result:='Bez řádků , neuloženo';
                      end;
         //result:=mImportMan.OutputDocument.oid;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
      //mValidateList.Free;
    end;
   result:='ok';
end;


procedure CreateDocument(Sender: TAction; Index: integer);
var
 mbo,mRowDocBatchTarget:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mpomoclist:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:TStrings;
mListError,mWorkList:tstringlist;
  mListNoBatches:tstringlist;
   mstringlist,mxlist:tstringlist;
  mnote:string;
  mSTR:string;
  mCLSID:string;
  mpocetdokladu, mpocetradku,mpocetsarzi:integer;
  mIWorklist,mIšarže:integer;
  mHead:TNxHeaderBusinessObject;
  mRows,mBatches:TNxCustomBusinessMonikerCollection;
  mDocqueue_ID,mStore_ID,mFirm_id,mDivision_ID:string;
  mDocList:TStringList;
  mAgenda:string;
  mCLSIDInput,mCLSIDOuput:string;

begin

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


  mCLSID:='E03ZNUMDTCC4PDAUIEY1MBTJC0';
  mDocqueue_ID:='7700000101';
  mFirm_id:=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID');
  mDivision_ID:='4O10000101';
  mStore_ID:='4B30000101';


    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' + '', 100);

    mWorkList:=tstringlist.create;
    try
                      if mBookmark.count=0 then begin
                                                    if index=4 then begin
                                                            TBusRollSiteForm(mSite).CurrentObject.setFieldValueAsFloat('X_dodano',0);
                                                            TBusRollSiteForm(mSite).CurrentObject.setFieldValueAsstring('X_En_nazev','');


                                                    end else begin
                                                                  mWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +
                                                                                 NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano')));
                                                    end;


                      end else begin
                           for x := 0 to mBookmark.Count- 1 do begin
                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                                            ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));

                                                          mWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +
                                                                                 NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano')));



                           end;

                  end;
                  ProgressDispose()   ;


                     mDocList:=TStringList.create;
                   try

                   mDocList:=CreateAllDocFromWorkList(msite,mCLSID,mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mWorkList);



                   //mhead:=CreateAllDocFromWorkListImport(tdynsiteform(msite),mCLSIDInput,mCLSIDOuput,mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList);


                       if mShowDebug then NxShowSimpleMessage('Počet dokladů: ' + inttostr(mdocList.count),nil);
                   finally
                       mDocList.free;
                   end;


        finally
           mWorkList.free;
        end;


end;


procedure CreateDocumentImport(Sender: TAction; Index: integer);
var
 mbo,mRowDocBatchTarget:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mpomoclist:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  iSource,iTarget: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:TStrings;
mListError,mWorkList:tstringlist;
  mListNoBatches:tstringlist;
   mstringlist,mxlist:tstringlist;
  mnote:string;
  mSTR:string;
  mCLSID:string;
  mpocetdokladu, mpocetradku,mpocetsarzi:integer;
  mIWorklist,mIšarže:integer;
  mHead:TNxHeaderBusinessObject;
  mRows,mBatches:TNxCustomBusinessMonikerCollection;
  mDocqueue_ID,mStore_ID,mFirm_id,mDivision_ID:string;
  mDocList,mRowList:TStringList;
  mAgenda:string;
  msearch:boolean;
  mString:string;
  mTempWorkList,mTempRowslist:tstringlist;
begin

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


  mDocqueue_ID:='PA10000101';
  mFirm_id:=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID');
  mDivision_ID:='4O10000101';
  mStore_ID:='3D30000101';


    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' + '', 100);

    mWorkList:=tstringlist.create;
    mDocList:=TStringList.create;
    mRowList:=TStringList.create;
    try
                      if mBookmark.count=0 then begin
                       if index=5 then begin
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                                    TBusRollSiteForm(mSite).CurrentObject.save;
                                    TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                        end else begin
                                                                  mWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +
                                                                                 NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano')));

                                                                                 msearch:=false;
                                                                                 for i:=0 to mDocList.count-1 do begin
                                                                                        if mdoclist.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mdoclist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id'));


                                                                                 msearch:=false;
                                                                                 for i:=0 to mRowList.count-1 do begin
                                                                                        if mRowList.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mRowList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id'));


                       end;
                      end else begin
                           for x := 0 to mBookmark.Count- 1 do begin
                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                                            ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                                   if index=5 then begin
                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                                       TBusRollSiteForm(mSite).CurrentObject.save;
                                       TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                   end else begin
                                                          mWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') +
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +
                                                                                 NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano')));

                                                                                 msearch:=false;
                                                                                 for i:=0 to mDocList.count-1 do begin
                                                                                        if mdoclist.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mdoclist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id'));


                                                                                 msearch:=false;
                                                                                 for i:=0 to mRowList.count-1 do begin
                                                                                        if mRowList.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mRowList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id'));




                                   end;
                           end;

                  end;
                  ProgressDispose()   ;



                 mWorkList.Sort;
                  ProgressInit(msite, 'Zpracování dat', 100);


               //   mDocList
               //   mRowList

                  for mIWorklist:=0 to mWorkList.count-1 do begin
                      ProgressSetPos(1+NxFloor(mIWorklist/(mWorkList.count)*99), inttostr(mIWorklist) +' z '+inttostr(mWorkList.count));



                     if mIWorklist=0 then begin    // první záznam
                                     msearch:=false;
                                         mdoclist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id'));
                                         mRowList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id'));

                                   mpocetdokladu:=mpocetdokladu+1;



                     end else begin            // kromě prvního záznamu
                        if copy(mWorkList.Strings[mIWorklist-1],1,20)=copy(mWorkList.Strings[mIWorklist],1,20) then begin   // stejny doklad
                              if copy(mWorkList.Strings[mIWorklist-1],1,30)=copy(mWorkList.Strings[mIWorklist],1,30) then begin    // stejný řádek
                                    mpocetradku:=mpocetradku+1;
                                    if copy(mWorkList.Strings[mIWorklist-1],1,50)=copy(mWorkList.Strings[mIWorklist],1,50) then begin   // stejná šarže doklad
                                          // dohledání šarže a navýšení
                                              mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10) );
                                              mpocetsarzi:=mpocetsarzi+1

                                    end else begin    // rozdílná šarže
                                         mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));
                                              mpocetsarzi:=mpocetsarzi+1


                                          // založení šarže
                                    end;
                              end else begin    // rozdílný řádek
                                   // založení řádku
                                                                            mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));
                                                                            mpocetradku:=mpocetradku+1;

                              end;
                        end else begin   // rozdílný doklad
                             // uložení dokladu
                            //NxShowSimpleMessage(inttostr(mpocetradku),nil);
                             mstring:= CreateAllDocFromWorkListImport(msite,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList);
                                 mDocList.free;
                                 mRowList.free;
                                 mDocList:=TStringList.Create;
                                 mRowList:=TStringList.Create;

                                         mdoclist.add(copy(mWorkList.Strings[mIWorklist],11,10));
                                         mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));


                             //založení nového dokladu
                                    mpocetdokladu:=mpocetdokladu+1;
                             // založení nového řádku
                                          mpocetradku:=mpocetradku+1;
                        end;
                     end;


                  end;
                  // uložení posledního dokladu

                  // odeslani do importmanaegra;        }



                     if mDocList.count>0 then
                            mstring:= CreateAllDocFromWorkListImport(msite,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList);


                       ProgressDispose();

                   mpocetdokladu:=mDocList.count;
                   mpocetradku:=mRowList.count;
                   mpocetSarzi:=mRowList.count;

                        NxShowSimpleMessage('Dokladů : ' + inttostr(mpocetdokladu) + ',' + chr(13)+
                                      'řádků : ' + inttostr(mpocetradku) + ',' + chr(13)+
                                      'šarží : ' + inttostr(mpocetsarzi) + ',' + chr(13),
                                      nil);




                    // mhead.save;

        finally
          mWorkList.free;
          mDocList.free;
          mRowList.free;
        end;


end;





function CreateAllDocFromWorkList(msite:tsiteform;mCLSID:string;mAgenda:string;mDocqueue_ID:string;mFirm_id:string;mDivision_ID:string;mStore_ID:string;mWorkList:tstringlist):TStringList;
var
  mHead:TNxHeaderBusinessObject;
  mRows,mBatches:TNxCustomBusinessMonikerCollection;
   mpocetdokladu, mpocetradku,mpocetsarzi:integer;
   mIWorklist,mIšarže:integer;
   mRow,mRowDocBatchTarget:TNxCustomBusinessObject;

begin
           result:=tstringlist.create;
                  mpocetdokladu:=0;
                  mpocetradku:=0;
                  mpocetsarzi:=0;
                  mWorkList.sort;
                  mhead:=TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0'));
                  try
                  ProgressInit(msite, 'Zpracování dat', 100);
                  for mIWorklist:=0 to mWorkList.count-1 do begin
                      ProgressSetPos(1+NxFloor(mIWorklist/(mWorkList.count)*99), inttostr(mIWorklist) +' z '+inttostr(mWorkList.count));
                     if mIWorklist=0 then begin    // první záznam

                                    mHead.new;
                                    mHead.Prefill;
                                    mHead.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                    mHead.setfieldvalueasstring('Firm_ID',copy(mWorkList.Strings[mIWorklist],1,10));
                                    mpocetdokladu:=mpocetdokladu+1;

                                          mRow := mhead.Rows.AddNewObject;
                                          mrow.SetFieldValueAsInteger('rowtype',3);
                                          mrow.SetFieldValueAsString('Store_ID',mStore_ID);
                                          mrow.SetFieldValueAsString('StoreCard_ID',copy(mWorkList.Strings[mIWorklist],31,10));
                                          mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                          mrow.SetFieldValueAsString('Division_ID',mDivision_ID);
                                          mpocetradku:=mpocetradku+1;

                                // kontrola a založení šarže
                                          if (mrow.getFieldValueAsInteger('StoreCard_ID.category')=2) and (copy(mWorkList.Strings[mIWorklist],41,10)<>'0000000000') then begin
                                                 mBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                          mRowDocBatchTarget := mBatches.AddNewObject;
                                                          mRowDocBatchTarget.Prefill;
                                                          mRowDocBatchTarget.SetFieldValueAsBoolean('NewBatch',false);
                                                          mRowDocBatchTarget.SetFieldValueAsString('StoreBatch_ID',copy(mWorkList.Strings[mIWorklist],41,10));
                                                          mRowDocBatchTarget.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                          //                    for mIbatches := 0 to mBatches.Count - 1 do begin
                                                          //                    end;
                                                          mpocetsarzi:=mpocetsarzi+1;

                                           end;


                     end else begin            // kromě prvního záznamu
                        if copy(mWorkList.Strings[mIWorklist-1],1,20)=copy(mWorkList.Strings[mIWorklist],1,20) then begin   // stejny doklad
                              if copy(mWorkList.Strings[mIWorklist-1],1,40)=copy(mWorkList.Strings[mIWorklist],1,40) then begin    // stejný řádek
                                    if copy(mWorkList.Strings[mIWorklist-1],1,50)=copy(mWorkList.Strings[mIWorklist],1,50) then begin   // stejná šarže doklad
                                          // dohledání šarže a navýšení
                                                      if (mrow.getFieldValueAsInteger('StoreCard_ID.category')=2) and (copy(mWorkList.Strings[mIWorklist],41,10)<>'0000000000') then begin
                                                           mrow.SetFieldValueAsFloat('Quantity',mrow.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                           mRowDocBatchTarget.SetFieldValueAsFloat('Quantity',mRowDocBatchTarget.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                           //NxShowSimpleMessage(NxFloatToIBStr(mrow.getFieldValueAsFloat('Quantity')),nil);
                                                      end;

                                    end else begin    // rozdílná šarže
                                          // založení šarže
                                          if (mrow.getFieldValueAsInteger('StoreCard_ID.category')=2) and (copy(mWorkList.Strings[mIWorklist],41,10)<>'0000000000') then begin
                                                 mBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                          mRowDocBatchTarget := mBatches.AddNewObject;
                                                          mRowDocBatchTarget.Prefill;
                                                          mRowDocBatchTarget.SetFieldValueAsBoolean('NewBatch',false);
                                                          mRowDocBatchTarget.SetFieldValueAsString('StoreBatch_ID',copy(mWorkList.Strings[mIWorklist],41,10));
                                                          mRowDocBatchTarget.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                          mrow.SetFieldValueAsFloat('Quantity',mrow.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                          mpocetsarzi:=mpocetsarzi+1;
                                           end;
                                    end;
                              end else begin    // rozdílný řádek
                                   // založení řádku
                                   mRow := mhead.Rows.AddNewObject;
                                          mrow.SetFieldValueAsInteger('rowtype',3);
                                          mrow.SetFieldValueAsString('Store_ID',mStore_ID);
                                          mrow.SetFieldValueAsString('StoreCard_ID',copy(mWorkList.Strings[mIWorklist],31,10));
                                          mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                          mrow.SetFieldValueAsString('Division_ID',mDivision_ID);
                                          mpocetradku:=mpocetradku+1;
                                   // kontrola a založení šarže
                                                 if (mrow.getFieldValueAsInteger('StoreCard_ID.category')=2) and (copy(mWorkList.Strings[mIWorklist],41,10)<>'0000000000') then begin
                                                 mBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                          mRowDocBatchTarget := mBatches.AddNewObject;
                                                          mRowDocBatchTarget.Prefill;
                                                          mRowDocBatchTarget.SetFieldValueAsBoolean('NewBatch',false);
                                                          mRowDocBatchTarget.SetFieldValueAsString('StoreBatch_ID',copy(mWorkList.Strings[mIWorklist],41,10));
                                                          mRowDocBatchTarget.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                          mpocetsarzi:=mpocetsarzi+1;

                                           end;

                              end;
                        end else begin   // rozdílný doklad
                             // uložení dokladu
                             mhead.save;
                             result.add(mhead.oid);
                             //založení nového dokladu
                             mHead.new;
                                    mHead.Prefill;
                                    mHead.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                    mHead.setfieldvalueasstring('Firm_ID',mfirm_ID);
                                    mpocetdokladu:=mpocetdokladu+1;
                             // založení nového řádku
                                          mRow := mhead.Rows.AddNewObject;
                                          mrow.SetFieldValueAsInteger('rowtype',3);
                                          mrow.SetFieldValueAsString('Store_ID',mStore_ID);
                                          mrow.SetFieldValueAsString('StoreCard_ID',copy(mWorkList.Strings[mIWorklist],31,10));
                                          mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                          mrow.SetFieldValueAsString('Division_ID',mDivision_ID);
                                          mpocetradku:=mpocetradku+1;
                             // založení nové šarže
                             if (mrow.getFieldValueAsInteger('StoreCard_ID.category')=2) and (copy(mWorkList.Strings[mIWorklist],41,10)<>'0000000000') then begin
                                                 mBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                          mRowDocBatchTarget := mBatches.AddNewObject;
                                                          mRowDocBatchTarget.Prefill;
                                                          mRowDocBatchTarget.SetFieldValueAsBoolean('NewBatch',false);
                                                          mRowDocBatchTarget.SetFieldValueAsString('StoreBatch_ID',copy(mWorkList.Strings[mIWorklist],41,10));
                                                          mRowDocBatchTarget.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mWorkList.Strings[mIWorklist],51,10)));
                                                          mpocetsarzi:=mpocetsarzi+1;

                                           end;


                        end;
                     end;


                  end;
                  // uložení posledního dokladu


                  mhead.save;
                  result.add(mhead.oid);
                  finally
                       ProgressDispose();
                       mhead.free;
                        NxShowSimpleMessage('Dokladů : ' + inttostr(mpocetdokladu) + ',' + chr(13)+
                                      'řádků : ' + inttostr(mpocetradku) + ',' + chr(13)+
                                      'šarží : ' + inttostr(mpocetsarzi) + ',' + chr(13),
                                      nil);
                  end;


end;





{
Vyvolává se po provedení metody CloseQuery. Pomocí tohoto háčku je možné ovlivnit, zda je možné agendu/formulář zavřít.
}
procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin

end;

procedure CheckDocumentBatch(Sender: TAction; Index: integer);
var
 mbo,mboNew:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   msave:Boolean;
   mQuantityTemp,mQuantityVratka,mQuantityDoc, mQuantityPomoc, mQuantitySource:double;
   mBoolean:boolean;
begin
  msite:=TComponent(Sender).Site;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TBusRollSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin
           if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                              mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.quantity '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ') order by ii2.quantity desc',mr) ;


                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.quantity '+
                                                                                    ' FROM IssuedInvoices2 ii2 '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (II2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by ii2.quantity desc',mr) ;

                              end;
                              if mShowDebug then
                              mboolean:=InputQuery('','','SELECT  ii.id||ii2.id||ii2.quantity '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ') order by ii2.quantity desc') ;
                              if index=1 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('20') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=sd.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('21') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;



                                    if mShowDebug then  NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],21,10));
                                             if mShowDebug then NxShowSimpleMessage(' Množství ' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' mQuantity pomoc ' + NxFloatToIBStr(mQuantityPomoc),nil);

                                      if mQuantityPomoc>0  then begin

                                            mQuantityVratka:=0;
                                            try
                                            if index=0 then begin
                                            // ******** již vráceno

                                                          mx:=tstringlist.create;
                                                           try
                                                                 msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[0],11,10)),mx);
                                                                 if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                                 if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                           finally
                                                               mx.free;
                                                           end;
                                             end;
                                             finally

                                             end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_quantity) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_parent2_id=' +
                                                                                       quotedstr(copy(mr.Strings[0],11,10)),mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;



                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                                                   TBusRollSiteForm(mSite).CurrentObject.save;
                                                             end;
                                     end;
                                    end;
                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin
                                            mbonew:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                            try
                                            mboNew.new;
                                                mboNew.Prefill;
                                                if mShowDebug then   NxShowSimpleMessage('Založen na zbytek',nil);
                                                mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                if index=0 then mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                if index=1 then mbonew.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                if index=4 then mbonew.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                //NxShowSimpleMessage('Příprava uložení zbtku',nil);
                                                mbonew.save;
                                                if mShowDebug then  NxShowSimpleMessage('Zbytek Uložen',nil);
                                                mQuantityPomoc:=mQuantityPomoc-mQuantityPomoc;
                                             finally
                                                mbonew.free;
                                             end;
                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;
                            TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                            msite.Refresh;

         end
    end else begin
         for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                          ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                end else begin

                             mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.quantity '+
                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                    ' WHERE (ii.Firm_id='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) +') and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                    ') order by ii2.quantity desc',mr) ;
                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' WHERE (sd.Firm_id='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) +') and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('21') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.quantity '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' WHERE (sd.Firm_id='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) +') and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;



                                    if mShowDebug then NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then  NxShowSimpleMessage(mr.Strings[i],nil);
                                            if mShowDebug then NxShowSimpleMessage(' Množství ' + copy(mr.Strings[0],21,10),nil);
                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],21,10));
                                      if mQuantityPomoc>0  then begin

                                            // ******** již vráceno
                                         if index=0 then begin   mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[0],11,10)),mx);
                                                       if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                       if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                 finally
                                                     mx.free;
                                                 end;
                                         end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_quantity) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_parent2_id=' +
                                                                                       quotedstr(copy(mr.Strings[0],11,10)),mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;


                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                             end;
                                     end;
                                    end;
                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin
                                            mbonew:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                            try
                                            mboNew.new;
                                                mboNew.Prefill;
                                                if mShowDebug then NxShowSimpleMessage('Založen na zbytek',nil);
                                                mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                //if mShowDebug then  NxShowSimpleMessage('Příprava uložení zbtku',nil);
                                                mbonew.save;
                                                if mShowDebug then  NxShowSimpleMessage('Zbytek Uložen',nil);
                                                mQuantityPomoc:=mQuantityPomoc-mQuantityPomoc;
                                             finally
                                                mbonew.free;
                                             end;
                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;


                 end;
                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                 msite.Refresh;

         end;

    end;


ProgressDispose()   ;



end;






function ZpracujImport(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean;index:integer;ASaveFile:string;Savedirectory:string;savefilename:string) : Boolean;
var
    mImportFile:TStringList;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mStorecard_ID,mBatch_ID,mFirm_ID:string;
  mList:tstringlist;
  mQuantity:double;
  iRow,iBatch,i:Integer;
  mRSql:tstringlist;
  mWorkList:Tstringlist;
  mXMLHead : TNxScriptingXMLWrapper;
  mfieldValue:tstringlist;
  mBO_Temp:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  _ss:Variant;
  mr:tstringlist;
  mi:integer;
begin

    mWorkList:=TStringList.create;
    try
        //  NxShowSimpleMessage('eee',nil);
          if not FileExists(AFileName) then begin   // soubor nenalezen
            //NxShowSimpleMessage('Soubor nenalezen, přerušuji import',nil);
            Result := False;
            exit;
          end;
                  //NxShowSimpleMessage(inttostr(index),nil);
                 //NxShowSimpleMessage('ffff',nil);

                               try
                                   // mBO_Temp:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                      mImportFile:=TStringList.create;
                                      mImportFile.LoadFromFile(AFileName);
                                        // NxShowSimpleMessage(inttostr(index),nil);
                                         ProgressInit(msite, 'Načtení souboru ' + AFileName, 100);
                                             i := 0;
                                               for i:=1 to mImportFile.Count-1 do begin   // načtení souboru
                                                                 ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));

                                                                 mstringline:= mImportFile.strings[i];
                                                                 mCountField:=0;

                                                                 //if index=1 then mCountField :=NxCharCount(',',mstringline);
                                                                 //if index=2 then mCountField :=NxCharCount(';',mstringline);

                                                                 mfieldValue:= TStringList.Create;
                                                                 try

                                                                        if index=1 then Parsevalue(mstringline,',',mstringline,mfieldValue,mCountField);
                                                                        if index=2 then Parsevalue(mstringline,';',mstringline,mfieldValue,3);
                                                                             //  NxShowSimpleMessage(inttostr(mCountField),nil);
                                                                      mr:=tstringlist.create;
                                                                      try
                                                                       mSite.BaseObjectSpace.SQlselect('select id from storecards where code=' + quotedstr(mfieldValue.strings[0]) + 'and hidden=' + quotedstr('N') , mr);
                                                                              if mr.count>0 then begin
                                                                                   MI:= mSite.BaseObjectSpace.SQLExecute
                                                                                   //  NxShowSimpleMessage(
                                                                                     ('update storebatches set ExpirationDate$Date = ' +NxFloatToIBStr(NxIBStrToFloat(mfieldValue.strings[2])) + ' where StoreCard_ID=' +  quotedstr(mr.strings[0]) +' and name='+ quotedstr(mfieldValue.strings[1]) ) ;
                                                                                     //    ,nil);
                                                                              end;
                                                                     finally
                                                                         mr.free;
                                                                     end;
                                                                 finally
                                                                        mfieldValue.free;
                                                                 end;

                                               end;
                                               ProgressDispose();
                                finally
                                    mImportFile.free;
                               end;


     finally
         mWorkList.free;
     end;
     msite.Refresh;
     TBusRollSiteForm(msite).RefreshData;

end;



//procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
//begin
//  if (Self.CompanyCache.GetUserID= '1600000101') or (Self.CompanyCache.GetUserID ='6K00000101') or (Self.CompanyCache.GetUserID ='2K00000101') or (Self.CompanyCache.GetUserID ='3K00000101') or (Self.CompanyCache.GetUserID='SUPER00000') then begin
//      ACanSaveNow:=false;
//  end;
//end;





procedure Import_souboru(Sender: TAction; Index: integer);
var

  zadej:string;
  mfilename,mSavefile:string;
  mdir,mfile,msavedir,msave:string;
  msaveFileName:string;
  msite:TSiteForm;
  mfilter:String;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
begin
  mdir:='';
  mfile:='';
  msavedir:='';
  msavefile:='';
 // NxShowSimpleMessage('AAA',nil);
    mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
   //NxShowSimpleMessage('bbb',nil);
   if PromptForFileName(mFileName, mfilter, '', 'Soubory k importu', mdir, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
 // NxShowSimpleMessage('ccc',nil);
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
 ZpracujImport(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,index,msavefile,msavedir,msavefile);


end;





procedure InitSite_Hook(Self: TSiteForm);

var
mAction: TAction;
  mMAction: TMultiAction;
begin
//if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Import ze souboru';
  mmAction.Hint := 'Import ze souboru "Batch,SC,Quantity"';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('XML');
  mMAction.Items.Add('CSV - oddělovač ","');
  mMAction.Items.Add('CSV - oddělovač ";"');
  mmAction.OnExecuteItem:= @Import_souboru;







end;







begin
end.