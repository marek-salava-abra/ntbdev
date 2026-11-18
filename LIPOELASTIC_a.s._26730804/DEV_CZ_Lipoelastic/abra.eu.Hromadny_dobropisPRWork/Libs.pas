const
mShowDebug=False;
mDocqueue_ID_VRDL='PA10000101';
mDocqueue_ID_DFV='2781000101';
mDocqueue_ID_VRPR='OA10000101';
mDocqueue_ID_DFP='Z300000101';
mCDivision_ID='1N00000101' ;
mCstore_ID='3D30000101';
mDocqueue_ID_PRVY='QA10000101';


function FindStoreBatchFV(os:TNxCustomObjectSpace;mTMPBO:TNxCustomBusinessObject;mquantity:double;index:integer):double;
 var
 i,x:integer;
 mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx:tstringlist;
   mVolne,mNaDokladu,mNaVratce:double;
   msave:Boolean;
   mQuantityTemp,mQuantityVratka,mQuantityDoc, mQuantityPomoc, mQuantitySource:double;
   mBoolean:boolean;
   maPocet:double;
   mbonew:TNxCustomBusinessObject;
begin
mr:=tstringlist.create;
try
    mQuantityPomoc:=0;
    mQuantityPomoc:= mquantity;
        if index=0 then begin


  mTMPBO.ObjectSpace.SQLSelect('select ii2.parent_ID,ii2.id,sd.id,sd2.id,drb.id,(DRB.Quantity-DRBn.Quantity)'
                                      +' from docrowbatches DRB'
                                      +' join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                      + ' join storedocuments sd on sd.id=Sd2.parent_ID'
                                      +' join Firms F on f.id=sd.Firm_ID '
                                      + ' left join storedocuments2 sd2x on  sd2x.RDocumentRow_ID=sd2.id'
                                      + ' left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID'
                                      + ' left join issuedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                      + ' where'
                                      +' (F.ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+')) )'
                                      + ' and drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                      + ' and sd.documenttype='+ quotedstr('21')
                                      + ' and exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                               +' union '
                                     +' select ii2.parent_ID,ii2.id,sd.id,sd2.id,drb.id,(DRB.Quantity-0)'
                                     +'  from docrowbatches DRB '
                                     +'  join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                     +'  join storedocuments sd on sd.id=Sd2.parent_ID'
                                     +' join Firms F on f.id=sd.Firm_ID '
                                     +'  left join issuedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                     +'  where '
                                     +' (F.ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+')) )'
                                      +' and not exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                                     +' and  drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                     +'   and sd.documenttype='+ quotedstr('21')
                                     ,mr) ;


    end;
    if index=2 then begin
         mTMPBO.ObjectSpace.SQLSelect('select sd.id as a,sd2.id as b,sd.id,sd2.id,drb.id,(DRB.Quantity-DRBn.Quantity)'
                                      +' from docrowbatches DRB'
                                      +' join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                      + ' join storedocuments sd on sd.id=Sd2.parent_ID'
                                      +' join Firms F on f.id=sd.Firm_ID '
                                      + ' left join StoreSubCards ssc on ssc.Storecard_ID=sd2.Storecard_ID and ssc.Store_ID=sd2.Store_ID'
                                      + ' left join storedocuments2 sd2x on  sd2x.RDocumentRow_ID=sd2.id'

                                      + ' left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID'
                                      //+ ' left join receivedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                      + ' where'
                                      +' (F.ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+')) )'
                                      + ' and drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                      + ' and sd.documenttype='+ quotedstr('20')
                                     // + ' and ssc.quantity>0 '
                                      + ' and exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                               +' union '
                                     +' select sd.id as a,sd2.id as b,sd.id,sd2.id,drb.id,(DRB.Quantity-0)'
                                     +'  from docrowbatches DRB '
                                     +'  join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                     +'  join storedocuments sd on sd.id=Sd2.parent_ID'
                                     +' join Firms F on f.id=sd.Firm_ID '
                                     + ' left join StoreSubCards ssc on ssc.Storecard_ID=sd2.Storecard_ID and ssc.Store_ID=sd2.Store_ID'
                                     //+'  left join receivedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                     +'  where '
                                     +' (F.ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+')) )'
                                      +' and not exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                                     +' and  drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                     +'   and sd.documenttype='+ quotedstr('20')
                                   //  + ' and ssc.quantity>0 '
                                     ,mr) ;


    end;




                                           //  NxShowSimpleMessage(copy(mr.Strings[i],1,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],12,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],23,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],34,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],45,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],56,10),nil);


                                      for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[i],56,10));

                                             if mShowDebug then NxShowSimpleMessage(' Množství na zdrojovém pohybu šarže' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' je potřeba vrátit pomoc k vrácení' + NxFloatToIBStr(mQuantityPomoc),nil);

                                                              if mQuantityPomoc>0  then begin

                                                                    mQuantityVratka:=0;

                                                                         //   ***** v temp již použito
                                                                         mQuantityTemp:=0;
                                                                         mx:=tstringlist.create;
                                                                         try
                                                                               os.SQLSelect('select sum(x.X_vychystano) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_DE_NAZEV=' +
                                                                                                               quotedstr(copy(mr.Strings[0],45,10)) + ' and x.hidden=' + quotedstr('N') ,mx);
                                                                                        if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                                                      if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],56,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                                         finally
                                                                             mx.free;
                                                                         end;



                                                                                     if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat


                                                                                               if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                                                     mTMPBO.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                                                     if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                                           ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);

                                                                                                           mbonew:=os.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                                                                                        mbonew.new;
                                                                                                                        mbonew.prefill;
                                                                                                                            mbonew.SetFieldValueAsString('X_CreatedBy_ID', mTMPBO.GetFieldValueAsString('X_CreatedBy_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('Code',mTMPBO.GetFieldValueAsString('Code'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Parent2_ID',copy(mr.Strings[i],12,10));
                                                                                                                            mbonew.SetFieldValueAsString('X_Parent_ID',copy(mr.Strings[i],1,10));

                                                                                                                            mbonew.SetFieldValueAsString('X_DEVENOLUX',copy(mr.Strings[i],23,10));
                                                                                                                            mbonew.SetFieldValueAsString('X_MX_NAZEV',copy(mr.Strings[i],34,10));
                                                                                                                            mbonew.SetFieldValueAsString('X_DE_NAZEV',copy(mr.Strings[i],45,10));
                                                                                                                            mbonew.SetFieldValueAsFloat('X_Quantity',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                            mbonew.SetFieldValueAsString('Name',mTMPBO.GetFieldValueAsString('name'));
                                                                                                                            mbonew.SetFieldValueAsString('X_firm_ID',mTMPBO.GetFieldValueAsString('X_Firm_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Store_ID',mTMPBO.GetFieldValueAsString('X_Store_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Storecard_ID',mTMPBO.GetFieldValueAsString('X_Storecard_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Batches',mTMPBO.GetFieldValueAsString('X_Batches'));
                                                                                                                            mbonew.SetFieldValueAsFloat('X_quantity',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                            mbonew.SetFieldValueAsDateTime('X_ABRADate',mTMPBO.GetFieldValueAsDateTime('X_ABRADate'));
                                                                                                                            mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                            mbonew.SetFieldValueAsString('X_PM_State','1050000101');

                                                                                                                            //mTMPBO.SetFieldValueAsString('X_PM_State','2020000101');
                                                                                                                        mbonew.save;
                                                                                                                                  mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                                    mTMPBO.SetFieldValueAsFloat('X_Quantity',mQuantityPomoc);
                                                                                                                                    mTMPBO.SetFieldValueAsFloat('X_vychystano',0);
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_Parent2_ID','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_Parent_ID','');

                                                                                                                                    mTMPBO.SetFieldValueAsString('X_DEVENOLUX','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_MX_NAZEV','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_DE_NAZEV','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_PM_State','2020000101');
                                                                                                                                    mTMPBO.save;
                                                                                                                                    //  NxShowSimpleMessage(copy(mr.Strings[i],1,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],12,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],23,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],34,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],45,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],56,10),nil);



                                                                                               end else begin
                                                                                                          mTMPBO.SetFieldValueAsString('X_Parent2_ID',copy(mr.Strings[i],12,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_Parent_ID',copy(mr.Strings[i],1,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_Devenolux',copy(mr.Strings[i],1,10));   // skladový doklad

                                                                                                          mTMPBO.SetFieldValueAsString('X_DEVENOLUX',copy(mr.Strings[i],23,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_MX_NAZEV',copy(mr.Strings[i],34,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_DE_NAZEV',copy(mr.Strings[i],45,10));
                                                                                                          mTMPBO.SetFieldValueAsFloat('X_Quantity',mQuantityPomoc);
                                                                                                          mTMPBO.SetFieldValueAsString('X_firm_ID',mTMPBO.GetFieldValueAsString('X_Firm_ID'));
                                                                                                          mTMPBO.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                          mTMPBO.SetFieldValueAsString('X_PM_State','1050000101');




                                                                                                    mTMPBO.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                                                      if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                                           ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                                                     mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                                                     mTMPBO.save;
                                                                                               end;


                                                                                               // if index=0 then mTMPBO.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');




                                                                                     end else begin
                                                                                           if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                                           ' nelze použít ' ,nil);

                                                                                     end;
                                                              end;

                                            //   náásledný doklad
                                      end;
                                       // mTMPBO.SetFieldValueAsFloat('X_Quantity',mQuantityPomoc);
                                       // mTMPBO.save;
                                        result:=mQuantityPomoc;
                              finally

                                 mr.free;
                              end;
                              result:=mQuantityPomoc;
end;






begin
end.