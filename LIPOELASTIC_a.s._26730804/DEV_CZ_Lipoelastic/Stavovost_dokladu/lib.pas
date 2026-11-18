uses '_Knihovny_ALL.Stavovost','_GlobalSettings.konstanty','_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib','NxApiProp.Prop' ;






 function SendDocAPI(self:TNxCustomBusinessObject;index:integer;mOnline:boolean;mKumulovane:boolean):string;
var
  os:TNxCustomObjectSpace;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
 aString:string;
  mstring:string;
  ARequest:string;

  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii,x:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows,mMonBAtch:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mjson,mTargetJson,mQueryJson:TJSONSuperObject;
 mboolean:boolean;
 mNewQueryrow:string;
 mParseListValue:tstringlist;
 iRow,IBatch:integer;
 mDocrowbatchList:tstringlist;
 mReturnJSON:TJSONSuperObject;
 mReturnImportRow,mReturnOtherRow:double;
 mReturnNewDocNumber,mReturnNewDocID,mReturnSourceDoc:string;
 mxString:string;
 mTypImportu:string ;
 mFind:boolean;
 mUser:string;
 mQueryStringList:tstringlist;
begin
  mids:='';
  mReturnNewDocID:='';
  mReturnNewDocNumber:='';
  mReturnSourceDoc:='';
  mReturnImportRow:=0;
  mReturnOtherRow:=0;
  mfind:=true;

                  //NxShowSimpleMessage(NxCreateContext(os).GetCompanyCache.GetUserID,nil);
                  {
                  mr:=tstringlist.create;
                  try
                       os.SQLSelect('Select LoginName from SecurityUsers where ID=' + quotedstr(NxCreateContext(os).GetCompanyCache.GetUserID),mr);
                       if mr.count>0 then begin

                           mUser:=ReplaceText(mr.strings[0],'"','') ;
                       end;
                  finally
                      mr.free;
                  end;
                   }
                 mTypImportu:='';
                           if (index=0)  then mTypImportu:='OP';
                           if (index=1)  then mTypImportu:='OV';
                           if (index=2)  then mTypImportu:='PR';
                           if (index=3) then mTypImportu:='DL';
                           if (index=4)  then mTypImportu:='PRV';
                           if (index=5)  then mTypImportu:='PRP';
                           if (index=6)  then mTypImportu:='FV';


                           mquery:=NxGetAPIHeadJSON(os,self,mTypImportu,mUser);

                           mquery:=mquery + NxGetAPIDocument(os,self);
                            mquery:=mquery + ']';
                                                           mquery:=mquery + '}';

                                                        mquery:=mquery + '}';


                                                    if mOnline then begin
                                                         mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Adress');
                                                           if mTarget='' then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                                exit ;
                                                           end;
                                                            //if (NxCreateContext(os).GetCompanyCache.GetUserID='SUPER00000')  then
                                                              mboolean:=InputQuery('API','Post 1 doklad',mtarget+'/script/NxApiLib/lib/APINxImporManager' + Chr(10) + chr(10) +mQuery);
                                                           mxString:=APICallString(os,'POST',mtarget+'/script/NxApiLib/lib/APINxImporManager',mQuery, true);
                                                                    mReturnNewDocNumber:='';
                                                                    mReturnSourceDoc:='';
                                                                    mReturnJSON:=TJSONSuperObject.create;
                                                                       try
                                                                       mReturnJSON:= TJSONSuperObject.ParseString(mxString,true);

                                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + mReturnJSON.S['New'] ;
                                                                                          if NxIBStrToFloat(mReturnJSON.S['Other'])>0 then begin
                                                                                              mReturnNewDocNumber:=mReturnNewDocNumber + ',   Bez vazby: ' + mReturnJSON.S['Other'];
                                                                                          end;
                                                                                          if NxIBStrToFloat(mReturnJSON.S['Import'])>0 then begin
                                                                                              mReturnNewDocNumber:=mReturnNewDocNumber + '   Import.: ' + mReturnJSON.S['Import']
                                                                                                                 +' z dokladů: ' + mReturnJSON.S['Source']+ chr(10);
                                                                                          end;
                                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + chr(10) ;

                                                                                    mReturnImportRow:=mReturnImportRow+ NxIBStrToFloat(mReturnJSON.S['Import']);
                                                                                    mReturnOtherRow:=mReturnOtherRow+NxIBStrToFloat(mReturnJSON.S['Other']);
                                                                                //end;

                                                                             //end;
                                                                    finally
                                                                        mReturnJSON.free;
                                                                    end;

                                                    end else begin


                                                                         if trim(self.GetFieldValueAsString('Firm_ID.X_API_Adress'))='' then begin
                                                                              NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                                              exit ;
                                                                         end else begin
                                                                              mTarget:=mExportDir + trim(copy(self.GetFieldValueAsString('Firm_ID.X_API_Adress'),20,50));
                                                                              mQueryStringList := TStringList.Create;
                                                                             try
                                                                                 mQueryStringList.add(mQuery);
                                                                                 mQueryStringList.SaveToFile(mTarget + '\'+mTypImportu+'\'
                                                                                         + self.GetFieldValueAsString('DocQueue_ID.CODE') + '_'
                                                                                         + inttostr(self.GetFieldValueAsinteger('Ordnumber')) + '_'
                                                                                         + self.GetFieldValueAsString('Period_ID.CODE')
                                                                                         + '.json');
                                                                              finally
                                                                                mQueryStringList.free;
                                                                              end;
                                                                         end;
                                                    end;
                                                if monline then begin
                                                            mstring:='';
                                                            mstring:=mstring + 'Operace dokončena: ' + chr(10)+ chr(10);
                                                            mstring:=mstring + 'Byl vytvořen doklad: ' +chr(10);
                                                            mstring:=mstring + mReturnNewDocNumber + chr(10);



                                                           mstring:=mstring + 'Celkem řádků : ' + chr(10);
                                                            if mReturnImportRow>0 then begin
                                                                mstring:=mstring + 'Importovaných: ' + NxFloatToIBStr(mReturnImportRow);
                                                                if mReturnOtherRow>0 then mstring:=mstring +' , ' ;
                                                            end;
                                                            if mReturnOtherRow>0 then begin
                                                                mstring:=mstring + ' Bez vazby: ' + NxFloatToIBStr(mReturnOtherRow) +chr(10);
                                                            end;



                                                        if mReturnNewDocNumber<>'' then begin
                                                              result:= mstring;
                                                        end else begin
                                                              //NxShowSimpleMessage(mstring,nil);
                                                              result:=('Chyba' +  chr(10) + ' Přenost dokladu neproběhl') ;

                                                        end


                                                end;

end;


















procedure updatestatePMS (OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
mr:tstringlist;
mBO:TNxCustomBusinessObject;
mdatefrom , mdateto:string;
I:integer;
mPLState_ID:string;
begin
  Success := True;
  LogInfoStr := '';
  mdatefrom:=NxFloatToIBStr((Now)-7);
  mdateto:= NxFloatToIBStr((Now)-1);

  mr:=tstringlist.create;
  try
      mbo:=os.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
      LogInfoStr:=  LogInfoStr +   'SELECT A.id FROM ReceivedOrders A WHERE (A.DocDate$DATE >= ' + mdatefrom + ' and A.DocDate$DATE < ' + mdateto + ' ) AND (NOT (A.PMState_ID IN (' + quotedstr('~000000102') + ',' + quotedstr('3070000101') + ')))'  + chr(10);

      os.SQLSelect('SELECT A.id FROM ReceivedOrders A WHERE (A.DocDate$DATE >= ' + mdatefrom + ' and A.DocDate$DATE < ' + mdateto + ' ) AND (NOT (A.PMState_ID IN (' + quotedstr('~000000102') + ',' + quotedstr('3070000101') + ')))',
      mr);
      LogInfoStr:=  LogInfoStr + inttostr(mr.count) + chr(10);

       if mr.count>0 then begin
            for I:=0 to mr.count-1 do begin
                mbo.load(mr.Strings[i],nil);

                mPLState_ID:='' ;
                      mPLState_ID:=ReceivedOrder_State_ID(mBO);
                              if mPLState_ID<>'' then begin
                                    if MBO.GetFieldValueAsString('PMState_ID')<>mPLState_ID then begin
                                         //mi:=self.ObjectSpace.SQLExecute('update Receivedorders set PMState_ID=' + QuotedStr(mPLState_ID) + ' where id=' + quotedstr(self.oid));
                                         mbo.SetFieldValueAsString('PMState_ID',mPLState_ID);
                                         mbo.save;
                                         LogInfoStr:=  LogInfoStr + mr.Strings[i] + chr(10);
                                    end;
                              end;
            end;

       end;
  finally
      mr.free;
  end;


end;

function GenerateOVBatches(mBO:TNxCustomBusinessObject;mVisual:Boolean):string;
var
  os:TNxCustomObjectSpace;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i ,j: integer;
  mBO_PohybSarze, mBO_Sarze : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
  mQuantity_pomoc,mpocet,mQuantityUsed, mSiciDavka:double;
  mr:tstringlist;
  mID_Sarze:string;
  mBatch_name,mBatch_name_pomoc:string;
  mbatch_number:integer;
  mxx:TStringList;
  mi:integer;
begin
   os:=mbo.ObjectSpace;

       if true then begin
       //if copy(mbo.GetFieldValueAsString('Firm_ID.X_Stitek_parametr'),6,1)<>'1' then begin


                          mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                          for i := 0 to mMon.Count - 1 do begin
                            //NxShowSimpleMessage(IntToStr(mMon.BusinessObject[i].getFieldValueAsInteger('Storecard_ID.category')),msite);
                            //mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_ID', iGetIDByCode(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, 'BusOrders', cbStores.Text));
                            if mMon.BusinessObject[i].getFieldValueAsInteger('Storecard_ID.category')=2 then begin
                                 //NxShowSimpleMessage('Sarže',msite);
                                 mQuantity_pomoc:=mMon.BusinessObject[i].GetFieldValueAsFloat('quantity')*mMon.BusinessObject[i].GetFieldValueAsFloat('unitrate');
                                 mSiciDavka:=(mMon.BusinessObject[i].getFieldValueAsfloat('Storecard_ID.X_Davka_sici'));
                                 mr:= tstringlist.create;
                                 try
                                      os.SQLSelect('Select sum(a.X_quantity) from DefRollData A WHERE A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                      ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[i].OID) + ')' ,mr);
                                      if mr.count>0 then begin
                                          mQuantityUsed:=NxIBStrToFloat(mr.strings[0])
                                          end else begin
                                              mQuantityUsed:=0;
                                          end;
                                      mpocet:=(mQuantity_pomoc-mQuantityUsed);
                                      if mQuantity_pomoc>mQuantityUsed then begin

                                          if mMon.BusinessObject[i].getFieldValueAsstring('Storecard_ID.StoreCardCategory_ID.X_PerefixBatch')<>''
                                               then mBatch_name_pomoc:=mMon.BusinessObject[i].getFieldValueAsstring('Storecard_ID.StoreCardCategory_ID.X_PerefixBatch')
                                               else mBatch_name_pomoc:='';

                                           mBatch_name_pomoc:=mBatch_name_pomoc+copy(mMon.BusinessObject[i].getFieldValueAsstring('Storecard_ID.EAN'),8,5) +FormatDateTime('YY',mbo.GetFieldValueAsDateTime('DocDate$Date')) +
                                           RightStr('00' + inttostr(strtoint(FormatDateTime('MM',mbo.GetFieldValueAsDateTime('DocDate$Date'))) + GenMoveBatches),2);
                                           mxx:=tstringlist.create;
                                           try
                                               if mMon.BusinessObject[i].getFieldValueAsstring('Storecard_ID.StoreCardCategory_ID.X_PerefixBatch')<>''
                                                  then os.SQLSelect('Select substring(name,11,3) from StoreBatches where substring(name,1,10) = ' + QuotedStr(mBatch_name_pomoc) + ' order by name desc',mxx)
                                                  else os.SQLSelect('Select substring(name,10,3) from StoreBatches where substring(name,1,9) = ' + QuotedStr(mBatch_name_pomoc) + ' order by name desc',mxx);

                                               if mxx.count>0 then begin
                                                        //NxShowSimpleMessage(mxx.Strings[0],nil);
                                                        mbatch_number:=strtoint(mxx.Strings[0])+1;
                                               end else begin
                                                        mbatch_number:=1;
                                               end;
                                           finally
                                               mxx.free;
                                           end;

                                           // dogenerování šarží
                                           for j:=0 to trunc((mQuantity_pomoc-mQuantityUsed)/mSiciDavka) do begin
                                               mBO_Sarze:=os.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                               try
                                                     mID_Sarze:='';
                                                     mBO_Sarze.new;
                                                     mBO_Sarze.Prefill;
                                                     mBO_Sarze.SetFieldValueAsString('StoreCard_ID',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID'));


                                                     mBO_Sarze.SetFieldValueAsString('X_parent_ID',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_parent_ID'));
                                                     mBO_Sarze.SetFieldValueAsString('Name',mBatch_name_pomoc + (RightStr('00000' + inttostr(mbatch_number + j),3)));
                                                     mBO_Sarze.SetFieldValueAsString('Specification',mBatch_name_pomoc);
                                                     mBO_Sarze.SetFieldValueAsString('X_Specifikace_order',copy(mMon.BusinessObject[i].GetFieldValueAsString('X_ExternalSpecification'),1,80));  //    mBO.GetFieldValueAsString('ExternalNumber')
                                                     mBO_Sarze.SetFieldValueAsString('X_Verze',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_parent_ID.X_verze'));
                                                     mBO_Sarze.SetFieldValueAsBoolean('SerialNumber',False);
                                                     mBO_Sarze.SetFieldValueAsDateTime('ProductionDate$DATE',Now);
                  //                                   mBO_Sarze.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                    if not mBO_Sarze.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue')=0 then
                                                     mBO_Sarze.SetFieldValueAsDateTime('ExpirationDate$Date',NxIncDate(Now,mBO_Sarze.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue'),0,0)) ;   //1096
                                                    //mBO_Sarze.SetFieldValueAsDateTime('ExpirationDate$DATE',Now+1095);




                                                     // **** materiálové složení  *****
                                                                                               mBO_Sarze.SetFieldValueAsString('X_MAT1',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT1'));
                                                                                               mBO_Sarze.SetFieldValueAsString('X_MAT2',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT2'));
                                                                                               mBO_Sarze.SetFieldValueAsString('X_MAT3',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT3'));
                                                                                               mBO_Sarze.SetFieldValueAsString('X_MAT4',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT4'));
                                                                                               mBO_Sarze.SetFieldValueAsString('X_MAT5',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT5'));
                                                            //                                   mBO_Sarze.SetFieldValueAsString('MAT6',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT6'));
                                                                                               mBO_Sarze.SetFieldValueAsInteger('X_MAT1_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT1_PROC'));
                                                                                               mBO_Sarze.SetFieldValueAsInteger('X_MAT2_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT2_PROC'));
                                                                                               mBO_Sarze.SetFieldValueAsInteger('X_MAT3_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT3_PROC'));
                                                                                               mBO_Sarze.SetFieldValueAsInteger('X_MAT4_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT4_PROC'));
                                                                                               mBO_Sarze.SetFieldValueAsInteger('X_MAT5_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT5_PROC'));
                                                            //                                   mBO_Sarze.SetFieldValueAsInteger('X_MAT6_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT6_PROC'));



                                                    if mpocet>0 then  mBO_Sarze.Save;
                                                     mID_Sarze:=mBO_Sarze.oid;
                                               finally
                                                    mBO_Sarze.free;
                                               end;
                                               mBO_PohybSarze:=os.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                               try
                                                      mBO_PohybSarze.new;
                                                      mBO_PohybSarze.Prefill;
                                                      if mpocet>=mSiciDavka then begin
                                                          mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mSiciDavka);
                                                          mpocet:=mpocet-mSiciDavka;
                                                      end else begin
                                                          mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mpocet);
                                                      end;
                                                      mBO_PohybSarze.SetFieldValueAsstring('Code',mBO.OID);
                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[i].OID);
                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID'));
                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mID_Sarze);
                                                      mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                      copy(mbo.GetFieldValueAsString('Docqueue_ID.code') + '-' + inttostr(mbo.GetFieldValueAsinteger('Ordnumber')) + '/' + mbo.GetFieldValueAsString('Period_ID.code') +
                                                       ' - ' + mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                      //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));

                                                      if mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0 then mBO_PohybSarze.save;
                                                      //NxShowSimpleMessage('pohyb šarže',nil);
                                               finally
                                                   mBO_PohybSarze.free;
                                               end;
                                           end;
                                      end else begin
                                           if mQuantity_pomoc<mQuantityUsed then NxShowSimpleMessage('Chyba, je generováno víc šarží, než je na dokladu',nil);

                                      end;
                                 finally
                                      mr.free;
                                 end;


                            end;
                  //  mStore

                          end;


      end else begin
          NxShowSimpleMessage('Pro uvedeného dodavatele není dovoleno generovat šarže', nil);
      end;

end;




begin
end.