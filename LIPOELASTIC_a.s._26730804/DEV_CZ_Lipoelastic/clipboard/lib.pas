uses
 '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata' ,'Nacteni_Dokladu.lib';



procedure FN_ClipboardChange(msite:TDynSiteForm;os:TNxCustomObjectSpace;mBO_Head:TNxHeaderBusinessObject;Index: integer);
var

  mID: string;
   mDL: TNxCustomBusinessObject;
  i,j,ii,iRows,iBatches, mIDataset,mPosIndex: integer;
  mMonikerRows,mMonBatches: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mDataset: TNxRowsObjectDataSet;
  mpocet:integer;
  mControl: TControl;
  mMonList:tstringlist;
  mDatasetList:tstringlist;
  mFind:Boolean;
  mChyba:integer;
  mString:string;
  mMemory:String;
  mGRows:TMultiGrid;
  mActualRow : TBookmark;
  mBookmark : TNxBookmarkList;
  mValueRows,mValueHead,mValueItems:tstringlist;
  mPomoc_ID:string;
  mIsStoreDocument:Boolean;
  mr:tstringlist;
  mIsHead,mIsRow,MIsBatch:boolean;
begin
  mIsHead:=true ;
  mIsRow:=false;
  MIsBatch:=false;

  mIsStoreDocument:=true;
                              mMemory:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','','');
                              if mMemory<>'' then begin
                                  mValueRows:=TStringList.create;
                                  mValueRows:=fnParsevalue(mMemory,chr(10));

                                  //NxShowSimpleMessage(inttostr(mValueRows.count),nil);
                                  if mValueRows.Count>0 then begin


                                      for I:=0 to mValueRows.count-1 do begin

                                          mValueItems:=TStringList.create;
                                          mValueItems:=fnParsevalue(
                                          NxSearchReplace(mValueRows.Strings[i],'"','',[srCase,srAll]),'=');

                                          if (mValueItems.count=1) and (copy(trim(mValueItems.Strings[0]),1,1)='~') then begin
                                              mid:= mValueItems.Strings[0] ;
                                              //NxShowSimpleMessage(mValueItems.Strings[0],nil);
                                          end;

                                          case trim(mValueItems.Strings[0]) of
                                              'Řádky': begin
                                                mIsHead:=False ;
                                                mIsRow:=True;
                                                MIsBatch:=False;
                                                NxShowSimpleMessage('Řádky ' + mid ,nil);
                                                end;

                                                'Vlastník': begin
                                                    if trim(mValueItems.Strings[1])='Odkaz bez názvu' then begin
                                                        mIsHead:=False ;
                                                        mIsRow:=False;
                                                        MIsBatch:=True;
                                                        //NxShowSimpleMessage('Šarže',nil);

                                                    end else begin
                                                        mIsHead:=False ;
                                                        mIsRow:=True;
                                                        MIsBatch:=False;
                                                        //NxShowSimpleMessage('Řádky',nil);
                                                    end;
                                                end;



                                              'Řádky šarží': begin
                                                    mIsHead:=False ;
                                                    mIsRow:=False;
                                                    MIsBatch:=True;
                                                    //NxShowSimpleMessage('Šarže',nil);
                                                 end;
                                            end;



                                          if mIsHead then begin
                                                  case trim(mValueItems.Strings[0]) of
                                                     'Vlastník' :
                                                        begin
                                                            NxShowSimpleMessage(' doklad' + mValueItems.Strings[1],nil);
                                                        end;

                                                  end;
                                          end;
                                          if mIsRow then begin
                                                if (trim(mValueItems.Strings[0])='Pořadí') and (mValueItems.count>1) then begin
                                                           NxShowSimpleMessage('Řádky ' +  mid + ' - ' + trim(mValueItems.Strings[1]),nil);
                                                end;
                                          end;
                                          if MIsBatch then begin
                                                if (trim(mValueItems.Strings[0])='Pořadí') and (mValueItems.count>1) then begin
                                                           NxShowSimpleMessage('Šarže '  +  mid + ' - ' + trim(mValueItems.Strings[1]),nil);
                                                end;
                                          end;








                                  end;
                                  //NxShowSimpleMessage(mMemory,nil);
                              end;
                    end;


end;





































procedure FN_Clipboard(msite:TDynSiteForm;os:TNxCustomObjectSpace;mBO_Head:TNxHeaderBusinessObject;Index: integer);
var

  mID: string;
   mDL: TNxCustomBusinessObject;
  i,j,ii,iRows,iBatches, mIDataset,mPosIndex: integer;
  mMonikerRows,mMonBatches: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mDataset: TNxRowsObjectDataSet;
  mpocet:integer;
  mControl: TControl;
  mMonList:tstringlist;
  mDatasetList:tstringlist;
  mFind:Boolean;
  mChyba:integer;
  mString:string;
  mMemory:String;
  mGRows:TMultiGrid;
  mActualRow : TBookmark;
  mBookmark : TNxBookmarkList;
  mValueRows,mValueHead,mValueItems:tstringlist;
  mPomoc_ID:string;
  mIsBatch:boolean;
  mIsStoreDocument:Boolean;
  mr:tstringlist;
begin
  mIsBatch:=true;
  mIsStoreDocument:=true;

                              mControl:= mSite.FindChildControl('tabRows.grdRows');
                              mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);


          if index=0 then begin
               if mBO_Head.CLSID='01CPMINJW3DL342X01C0CX3FCC' then begin
                      mMemory:='Typ	Text	Cena	%DPH	Sleva %	Typ p.	Počet	Jedn.	J.cena	Sklad	Kód skl.karty	Název skl.karty	#% sleva	#Po slevě s DPH %	#Specifikace	#Specifikace' + chr(10);   // OP
                      mIsStoreDocument:=False;
               end;
               if mBO_Head.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then begin
                     mMemory:='Typ	Text	Počet	Jedn.	Sklad	Kód skl.karty	Název skl.karty	#Vychystáno	#Specifikace	#Specifikace' + chr(10);   // OV
                     mIsStoreDocument:=False;
               end;


               if mBO_Head.CLSID='E03ZNUMDTCC4PDAUIEY1MBTJC0' then mMemory:='Sklad	Kód skl.karty	Název skl.karty	Počet	Jedn.	J.cena	C.cena	#Vychystáno' + chr(10);   // PR
               if mBO_Head.CLSID='050I5SAOS3DL3ACU03KIU0CLP4' then mMemory:='Typ	Text	Počet	Jedn.	Sklad	EAN skl.karty	Název skl.karty	#Specifikace	#Specifikace' + chr(10);   // DL
               if mBO_Head.CLSID='0P0I5SAOS3DL3ACU03KIU0CLP4' then mMemory:='Sklad	Název skl.karty	Počet	Jedn.' + chr(10);   // PRV
               if mBO_Head.CLSID='1D0I5SAOS3DL3ACU03KIU0CLP4' then mMemory:='Sklad	Kód skl.karty	Název skl.karty	Počet	Jedn.' + chr(10);   // PRP
               if mBO_Head.CLSID='E32A1GVWPYY4BJZFV5NFSRAODW' then mMemory:='Sklad	EAN skl.karty	Název skl.karty	Počet	Jedn.' + chr(10);   // ZMV
               if mBO_Head.CLSID='JFQYSEOTKPC4RAMLQVLUK5NV34' then mMemory:='Sklad	EAN skl.karty	Název skl.karty	Počet	Jedn.' + chr(10);   // ZMP


                                        try

                                          mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
                                             mBookmark := mGRows.SelectedRows;
                                             mActualRow := mGRows.DataSource.DataSet.GetBookmark;

                                          mList:=tstringlist.Create;
                                          mMonikerRows := mBO_Head.GetLoadedCollectionMonikerForFieldCode(mBO_Head.GetFieldCode('ROWS'));
                                          mDatasetList:=tstringlist.create;
                                          if Assigned(mGRows) then mGRows.FillListFromSelectedRows_1(mList,false);

                                          if mList.count=0 then begin
                                                 if mDataSet.Active then begin
                                                            mDataSet.First;
                                                            while not mDataSet.Eof do begin
                                                                mstring:=mDataSet.FieldByName('Storecard_ID').Asstring + inttostr(mDataSet.FieldByName('PosIndex').AsInteger)   ;
                                                                mDatasetList.add(mString);
                                                                mDataSet.Next;
                                                            end;
                                                end;
                                          end else begin
                                                for j:=0 to mList.count-1 do begin
                                                  for iRows:= 0 to mMonikerRows.count -1 do begin
                                                        if mMonikerRows.BusinessObject[iRows].OID=mList.Strings[j] then begin
                                                               mstring:=mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Storecard_ID') + inttostr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('PosIndex'))   ;
                                                               mDatasetList.add(mString);
                                                        end;
                                                  end;
                                                end;
                                          end;

                                                  for iRows:= 0 to mMonikerRows.count -1 do begin
                                                     for mIDataset:=0 to mDatasetList.count-1 do begin     // dohledání řádku
                                                             if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Storecard_ID')+inttostr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('PosIndex'))) = mDatasetList.Strings[mIDataset] then begin
                                                                  if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('RowType')=3) then begin
                                                                        mMemory:=mMemory + '"3       (Skladový řádek)"' + chr(09);
                                                                  end;

                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Text') + '"' + chr(09);
                                                                        mMemory:=mMemory + '' +NxFloatToIBStr(mMonikerRows.BusinessObject[iRows].GetFieldValueAsFloat('Quantity'))+ '' + chr(09);
                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Qunit') + '" ' + chr(09);
                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('Store_ID.Code') + '"' + chr(09);
                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID.EAN') + '"' + chr(09);
                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('StoreCard_ID.Name') + '"' + chr(09);
                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('X_Specifikace_id')+ '"' + chr(09);
                                                                        mMemory:=mMemory + '"' + mMonikerRows.BusinessObject[iRows].GetFieldValueAsString('X_ExternalSpecification') + '"' + chr(09);


                                                                  if (mMonikerRows.BusinessObject[iRows].GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin
                                                                     if mIsStoreDocument then begin
                                                                               mMonBatches:=mMonikerRows.BusinessObject[iRows].GetLoadedCollectionMonikerForFieldCode(mMonikerRows.BusinessObject[iRows].GetFieldCode('DocRowBatches'));
                                                                                      for iBatches:= 0 to mMonBatches.count -1 do begin  // kontrola stavu na šarži
                                                                                               mMemory:=mMemory + '"' + mMonBatches.BusinessObject[iBatches].GetFieldValueAsString('StoreBatch_ID')+ '"' + chr(09);
                                                                                               mMemory:=mMemory + '' +NxFloatToIBStr(mMonBatches.BusinessObject[iBatches].GetFieldValueAsFloat('Quantity')) + '' + chr(09);
                                                                                      end;
                                                                      end else begin
                                                                             if mBO_Head.CLSID='01CPMINJW3DL342X01C0CX3FCC' then begin
                                                                                     mr:=TStringList.create;
                                                                                         try
                                                                                             os.SQLSelect('SELECT a.X_batches,a.X_Quantity as hodnota FROM DefRollData A where A.CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                              ' and a.X_Parent_ID='+quotedstr((mMonikerRows.BusinessObject[iRows].OID)) ,mr);

                                                                                              if mr.count>0 then begin
                                                                                                           for i:= 0 to mr.Count - 1 do begin
                                                                                                                 mMemory:=mMemory + '"' + copy(mr.strings[i],1,10) + '"' + chr(09);
                                                                                                                 mMemory:=mMemory + '' +copy(mr.strings[i],12,10) + '' + chr(09);
                                                                                                           end;
                                                                                                  end;
                                                                                             finally
                                                                                                mr.free;
                                                                                             end;



                                                                             end;
                                                                             if mBO_Head.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then begin
                                                                                      mr:=TStringList.create;
                                                                                             try
                                                                                                 os.SQLSelect('SELECT  a.X_batches,a.X_Quantity as hodnota FROM DefRollData A where A.CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                  ' and a.X_Parent_ID='+quotedstr((mMonikerRows.BusinessObject[iRows].OID)) ,mr);

                                                                                                  if mr.count>0 then begin
                                                                                                           for i:= 0 to mr.Count - 1 do begin
                                                                                                                 mMemory:=mMemory + '"' + copy(mr.strings[i],1,10) + '"' + chr(09);
                                                                                                                 mMemory:=mMemory + '' +copy(mr.strings[i],12,10) + '' + chr(09);
                                                                                                           end;
                                                                                                  end;
                                                                                             finally
                                                                                                mr.free;
                                                                                             end;


                                                                             end;
                                                                      end;
                                                                  end;

                                                                 mMemory:=mMemory  + chr(10);
                                                             end;
                                                     end;
                                                  end;


                                          mMemory:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ',mMemory,'Pokračovat','','');
                                      finally
                                        //mDL.Free;
                                      end;
                            end;

                    if index=1 then begin
                              mMemory:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','','');
                              if mMemory<>'' then begin
                                  mValueRows:=TStringList.create;
                                  mValueRows:=fnParsevalue(mMemory,chr(10));
                                  if mValueRows.Count>0 then begin
                                      mValueHead:=TStringList.create;
                                      mValueHead:=fnParsevalue(mValueRows.Strings[0],chr(09));
                                      if mValueHead.count>0 then begin
                                          //NxShowSimpleMessage(mValueHead.Strings[0],nil);
                                      end;
                                      for I:=1 to mValueRows.count-1 do begin
                                          mValueItems:=TStringList.create;
                                          mValueItems:=fnParsevalue(
                                          NxSearchReplace(mValueRows.Strings[i],'"','',[srCase,srAll]),chr(09));

                                            if mValueItems.count>0 then begin
                                                  mDataSet.DisableControls;
                                                  mRow := mDataSet.CreateBusinessObject;
                                                  mRow.Prefill;

                                                  for j:=0 to mValueItems.count-1 do begin
                                                      if (mValueHead.count-1) >= j then begin    // jedná se o řádky
                                                            if mValueHead.Strings[j]='Typ' then begin
                                                                  //mRow.SetFieldValueAsInteger('RowType',strtoint(copy(mValueItems.Strings[j],1,1)));
                                                                  mRow.SetFieldValueAsInteger('RowType',3);
                                                            end;
                                                            if mValueHead.Strings[j]='Text' then begin
                                                                  mRow.SetFieldValueAsString('Text',mValueItems.Strings[j]);
                                                            end;
                                                             if mValueHead.Strings[j]='Sklad' then begin
                                                                mPomoc_ID:='';
                                                                  try
                                                                    mPomoc_ID:= os.SQLSelectFirstAsString('select id from Stores where code=' + quotedstr(mValueItems.Strings[j]));
                                                                    if mPomoc_ID<>'' then mRow.SetFieldValueAsString('Store_ID',mPomoc_ID);
                                                                  finally

                                                                  end;
                                                            end;
                                                            if mValueHead.Strings[j]='Počet' then begin
                                                                  mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mValueItems.Strings[j]));
                                                            end;
                                                            if mValueHead.Strings[j]='Jedn.' then begin
                                                                  mRow.SetFieldValueAsString('Qunit',mValueItems.Strings[j]);
                                                            end;
                                                            if mValueHead.Strings[j]='EAN skl.karty' then begin
                                                                  mPomoc_ID:='';
                                                                  try
                                                                      mPomoc_ID:= os.SQLSelectFirstAsString('select id from storecards where EAN=' + quotedstr(mValueItems.Strings[j]));
                                                                      if mPomoc_ID<>'' then mRow.SetFieldValueAsString('StoreCard_ID',mPomoc_ID);
                                                                  finally

                                                                  end;
                                                            end;
                                                          {  if mValueHead.Strings[j]='#Specifikace' then begin
                                                                  mRow.SetFieldValueAsstring('Specificaton',mValueItems.Strings[j]);
                                                            end;
                                                            if mValueHead.Strings[j]='#Specifikace2' then begin
                                                                  mRow.SetFieldValueAsstring('Specificaton2',mValueItems.Strings[j]);
                                                            end;}

                                                            //NxShowSimpleMessage(mValueItems.Strings[j],nil);
                                                      end else begin   // jedná se o šarže
                                                         if (mRow.GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin

                                                            if (TDynSiteForm(msite).CurrentObject.CLSID='E03ZNUMDTCC4PDAUIEY1MBTJC0')
                                                                or (TDynSiteForm(msite).CurrentObject.CLSID='050I5SAOS3DL3ACU03KIU0CLP4')
                                                                 or (TDynSiteForm(msite).CurrentObject.CLSID='1D0I5SAOS3DL3ACU03KIU0CLP4')
                                                                  or (TDynSiteForm(msite).CurrentObject.CLSID='JFQYSEOTKPC4RAMLQVLUK5NV34')
                                                                   or (TDynSiteForm(msite).CurrentObject.CLSID='5OSFHRXOFONO3F0BUIV5ZBJD0S')
                                                                    or (TDynSiteForm(msite).CurrentObject.CLSID='E32A1GVWPYY4BJZFV5NFSRAODW')
                                                                     or (TDynSiteForm(msite).CurrentObject.CLSID='0P0I5SAOS3DL3ACU03KIU0CLP4')
                                                                      or (TDynSiteForm(msite).CurrentObject.CLSID='P3TSZXYDJB44Z3350NYZWO102K')
                                                                       or (TDynSiteForm(msite).CurrentObject.CLSID='1T0I5SAOS3DL3ACU03KIU0CLP4')
                                                                        or (TDynSiteForm(msite).CurrentObject.CLSID='3OKSI2XXYK2OB2JRPZ3U4UXTGK')
                                                                   then begin
                                                                                    if mIsBatch then begin
                                                                                             mMonBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                                                 mdocrowbatches:=mMonBatches.AddNewObject;
                                                                                                 mdocrowbatches.Prefill;
                                                                                                 mdocrowbatches.SetFieldValueAsString('Storebatch_ID',mValueItems.Strings[j]);
                                                                                                 mdocrowbatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mValueItems.Strings[j+1]));
                                                                                         //NxShowSimpleMessage('Šarže je ' + mValueItems.Strings[j] + ' v množství ' + mValueItems.Strings[j+1],nil);

                                                                                       mIsBatch:=false;
                                                                                    end else begin
                                                                                       mIsBatch:=True;
                                                                                    end;
                                                             end else begin

                                                             end;
                                                          end;
                                                      end;
                                                   end;
                                                   mRow.SetFieldValueAsString('Division_ID','1N00000101');
                                                   TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                   mDataset.RefreshAndRestoreLastSelectedItem;
                                                   mDataSet.EnableControls;
                                            end;
                                      end;


                                  end;
                                  //NxShowSimpleMessage(mMemory,nil);
                              end;
                    end;


end;





begin
end.