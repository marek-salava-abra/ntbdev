uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata';


 var
  //mRow: TNxCustomBusinessObject;
  mvalue:TStringList;
  mboolean:Boolean;
  mfind,mFindBatch:boolean;
  mImportFile:tstringlist;
  mstringline:string;
  //mMon,
  mBO_Batches: TNxCustomBusinessMonikerCollection;
  mi:integer;
  mr:tstringlist;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mQuantity,mQuantityBatch:double;
  mStoreCard,mBatch_ID:string;
  mInputString:string;
  mstring:string;
  mIRadku:integer;
  mIKusu:double;
  mDivision_ID:string;


Function ImportRowsFromConirmRO(xSite:TSiteForm;mhead:TNxHeaderBusinessObject;mStorecard_ID:string;mStore_ID:string;mQuantity:Double):string;
begin
    mImportFile:=TStringList.create;
    try
                              ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10),mImportFile);
                              ProgressInit(msite, 'Načítání dat ' + '', 100);
                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mvalue:=tstringlist.create;
                                               try
                                                   //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                                   ParsevalueRow(mstringline, chr(09),mvalue);

                                                     if mvalue.count>=3 then begin
                                                            //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                            //NxShowSimpleMessage(,nil);
                                                            //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                           mstorecard_ID:='';
                                                           mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[0]));


                                                           if mstorecard_ID<>'' then begin



                                                           end;
                                                      end;
                                                finally
                                                    mvalue.free;
                                                end;
                                          end;
                              end;
    finally
        mImportFile.free;
    end;

end;

function ImportRowsFromDatamatrix(xSite:TSiteForm;mhead:TNxHeaderBusinessObject;mStorecard_ID:string;mStore_ID:string;mQuantity:Double):string;
begin
    mImportFile:=TStringList.create;
                         ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah ','Datamatrix : ','','Pokračovat','',''), chr(10),mImportFile);
                         ProgressInit(msite, 'Načítání dat ' + '', 100);
                          for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mStoreCard_ID:='';
                                             mBatch_ID:='';
                                             mQuantity:=0;
                                             mInputString:='';
                                            mvalue:=tstringlist.create;
                                            try

                                                mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                                                ParsevalueRow(mstring, ';',mvalue);

                                                mStoreCard_ID:=mvalue.Strings[1];
                                                mBatch_ID:=mvalue.Strings[2];
                                                mQuantity:=NxIBStrToFloat(mvalue.Strings[3]);

                                                result:=mStoreCard_ID+';' + mBatch_ID + ';' +mvalue.Strings[3]  ;
                                              finally
                                                   mvalue.free;
                                              end;
                                        end;
                            end;
end;



 function NewOrUseRow(xSite:TSiteForm;mhead:TNxHeaderBusinessObject;mStorecard_ID:string;mStore_ID:string;mQuantity:Double):string;
 begin
mImportFile:=TStringList.create;
                         ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah ','Datamatrix : ','','Pokračovat','',''), chr(10),mImportFile);
                         ProgressInit(msite, 'Načítání dat ' + '', 100);
                          for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mStoreCard_ID:='';
                                             mBatch_ID:='';
                                             mQuantity:=0;
                                             mInputString:='';
                                            mvalue:=tstringlist.create;
                                            try

                                                mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                                                ParsevalueRow(mstring, ';',mvalue);

                                                mStoreCard_ID:=mvalue.Strings[1];
                                                mBatch_ID:=mvalue.Strings[2];
                                                mQuantity:=NxIBStrToFloat(mvalue.Strings[3]);


                                              finally
                                                   mvalue.free;
                                              end;

                                if mStoreCard_ID<>'' then begin
                                        mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));
                                        mFind:=False;
                                        for ii := 0 to mMon.Count - 1 do begin
                                                 if mMon.BusinessObject[ii].getFieldValueAsstring('Storecard_ID')= mStoreCard_ID then begin
                                                                          mMon.BusinessObject[ii].SetFieldValueAsFloat('Quantity',(mMon.BusinessObject[ii].GetFieldValueAsFloat('Quantity') + mQuantity));
                                                                           //mDataSet.FieldByName('Quantity').AsFloat:=(mDataSet.FieldByName('Quantity').AsFloat + mqauntity);
                                                                           mFind:=True;


                                                                 //
                                                  end;
                                        end;
                                        if not mFind then begin
                                                      mRow := mHead.Rows.AddNewObject;
                                                      mRow.Prefill;
                                                      //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                      mRow.SetFieldValueAsInteger('RowType',3);
                                                      mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                      mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                      mRow.SetFieldValueAsFloat('Quantity', mQuantity);
                                                      mIRadku:=mIRadku+1;
                                                      mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                      mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                      if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                 mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                 mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                      end;
                                                      mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                      mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                      mBusProject_ID:=GetProject_ID(mRow);
                                                      mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);

                                                      if ((mhead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mhead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                               mBO_Batches:=mMon.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mMon.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                                                                    mfindbatch:=false;
                                                                                                    for x:=0 to mBO_Batches.count-1 do begin
                                                                                                         if mBO_Batches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID')= mBatch_ID then begin
                                                                                                              mQuantityBatch:= mBO_Batches.BusinessObject[x].GetFieldValueAsFloat('Quantity') + mQuantity;
                                                                                                              mBO_Batches.BusinessObject[x].SetFieldValueAsFloat('Quantity',mQuantityBatch);
                                                                                                              mfindbatch:=true;
                                                                                                         end;
                                                                                                    end;
                                                                                                    If not mfindbatch then begin
                                                                                                    mBO_PohybSarze:= mBO_Batches.AddNewObject;
                                                                                                        mBO_PohybSarze.Prefill;
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('StoreBatch_ID',mBatch_ID);
                                                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('Qunit',mMon.BusinessObject[ii].getFieldValueAsstring('Qunit'));
                                                                                                    end;


                                                                                     end;


                                                      if ((mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                          if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                          if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                               try
                                                                                                                      mBO_PohybSarze.new;
                                                                                                                      mBO_PohybSarze.Prefill;
                                                                                                                      mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);

                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                      copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                      //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));

                                                                                                                      if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.Name')<>'0' then mBO_PohybSarze.save;

                                                                                                               finally
                                                                                                                   mBO_PohybSarze.free;
                                                                                                               end;
                                                       end;

                                        end;
                                end;



                          end;
            end;

 end;

 function NewOrUseBatch(mSite:TSiteForm;mhead:TNxHeaderBusinessObject;mrow:TNxCustomBusinessObject;mStorecard_ID:string;mBatch_ID:string;mQuantity:Double):string;

 begin
 if mBatch_ID<>'' then begin


                                                                                 mfindbatch:=false;


                                                                                 try
                                                                                     if ((mhead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mhead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                               mBO_Batches:=mMon.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mMon.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                                                                    mfindbatch:=false;
                                                                                                    for x:=0 to mBO_Batches.count-1 do begin
                                                                                                         if mBO_Batches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID')= mBatch_ID then begin
                                                                                                              mQuantityBatch:= mBO_Batches.BusinessObject[x].GetFieldValueAsFloat('Quantity') + mQuantity;
                                                                                                              mBO_Batches.BusinessObject[x].SetFieldValueAsFloat('Quantity',mQuantityBatch);
                                                                                                              mfindbatch:=true;
                                                                                                         end;
                                                                                                    end;
                                                                                                    If not mfindbatch then begin
                                                                                                    mBO_PohybSarze:= mBO_Batches.AddNewObject;
                                                                                                        mBO_PohybSarze.Prefill;
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('StoreBatch_ID',mBatch_ID);
                                                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('Qunit',mMon.BusinessObject[ii].getFieldValueAsstring('Qunit'));
                                                                                                    end;


                                                                                     end;
                                                                                     if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                                          // OP
                                                                                           mr:= tstringlist.create;
                                                                                             try
                                                                                                 msite.BaseObjectSpace.SQLSelect('Select a.id,a.X_quantity from DefRollData A WHERE A.CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                                        ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[ii].OID) + ') AND  (A.X_Batches =' + QuotedStr(mBatch_ID) + ')' ,mr);
                                                                                                        if mr.count>0 then begin
                                                                                                              mfindbatch:=true;
                                                                                                              mQuantityBatch:=NxIBStrToFloat(trim(copy(mr.Strings[0],12,20))) + mQuantity;
                                                                                                              mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_quantity=' + NxFloatToIBStr(mQuantityBatch) +  ' WHERE CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                                                  ' AND (id =' + QuotedStr(copy(mr.strings[0],1,10)) + ')') ;
                                                                                                        end else begin
                                                                                                              mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                                     try
                                                                                                                            mBO_PohybSarze.new;
                                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[ii].OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                            copy(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                                             if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.NAme')<>'0' then mBO_PohybSarze.save;
                                                                                                                     finally
                                                                                                                         mBO_PohybSarze.free;
                                                                                                                     end;
                                                                                                        end;
                                                                                              finally
                                                                                                  mr.free;
                                                                                              end;
                                                                                     end;
                                                                                     if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                                          // OV
                                                                                          mr:= tstringlist.create;
                                                                                             try
                                                                                                 msite.BaseObjectSpace.SQLSelect('Select a.id,a.X_quantity from DefRollData A WHERE A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                        ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[ii].OID) + ') AND  (A.X_Batches =' + QuotedStr(mBatch_ID) + ')' ,mr);
                                                                                                        if mr.count>0 then begin
                                                                                                              mfindbatch:=true;
                                                                                                              mQuantityBatch:=NxIBStrToFloat(trim(copy(mr.Strings[0],12,20))) + mQuantity;
                                                                                                              mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_quantity=' + NxFloatToIBStr(mQuantityBatch) +  ' WHERE CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                                  ' AND (id =' + QuotedStr(copy(mr.strings[0],1,10)) + ')') ;
                                                                                                        end else begin
                                                                                                              mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                                     try
                                                                                                                            mBO_PohybSarze.new;
                                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[ii].OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                            copy(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                                             if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.Name')<>'0' then mBO_PohybSarze.save;
                                                                                                                     finally
                                                                                                                         mBO_PohybSarze.free;
                                                                                                                     end;
                                                                                                        end;
                                                                                              finally
                                                                                                  mr.free;
                                                                                              end;


                                                                                     end;
                                                                                 finally

                                                                                 end;
 end;
end;



function ShowDocument(xSite:TSiteForm;mhead:TNxHeaderBusinessObject):string;

 begin
   NxShowSimpleMessage('Import proběhl' + chr(10) +
                                       'naplněno ' + NxFloatToIBStr(mIRadku) + ' položek ' + chr(10) +
                                       'v poctu ' + NxFloatToIBStr(mIKusu) + ' jednotek ' ,nil);
               if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op
               if  mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mSite.SiteContext, mhead);    // ov
               if  mhead.CLSID='E03ZNUMDTCC4PDAUIEY1MBTJC0' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // PR
               if  mhead.CLSID='050I5SAOS3DL3ACU03KIU0CLP4' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // DL
               if  mhead.CLSID='0P0I5SAOS3DL3ACU03KIU0CLP4' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // PRV

 end;







  function CreateMemo(AName, ACaption: string;
  ALeft, ATop, AWidth, AHeight: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False; AVisibled,AEnabled:boolean; AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TMemo;
var
mLbl: TLabel;
mFont: TFont;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TMemo.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  Result.Height := AHeight;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;
  Result.enabled:=AEnabled ;
  Result.Visible:=AVisibled;
  mFont := Result.Font;
    //mfont.:=left;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  end;
  Result.Text:= ADefaultValue;
end;






 function BarCode_document(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mPopis,mID_doklad:string;mbutton2,mbutton3,mbutton4:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
begin

      Result :='' ;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
    // mID_doklad:='';
      mi_resulta:=0;
      //NxShowSimpleMessage(mID_doklad,nil);
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                   mMemNote := CreateMemo('ChMemNote',mPopis, 10, 20, 600,800, 80, mID_doklad, mForm,true,true,True,round(180/24), [fsNormal],255);



                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky
                                 result:= mMemNote.Text;
                                 if mi_resulta<>10 then begin

                                end else begin
                                mi_resulta:=10;
                               end;
      finally
        mform.Free;
      end;
      end;


end;





begin
end.