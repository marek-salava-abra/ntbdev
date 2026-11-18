uses '_Knihovny_ALL.Parse',
     '_Knihovny_ALL.Komunikace',
     '_Knihovny_ALL.Parse',
     'NxApiProp.Prop';

     // iPrintDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string):string;
     // iSendMailx(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
     // iSendmsg(AOS : TNxCustomObjectSpace;const ASubject : string; const ABody : string; ATo : string; AFrom : string = '');


     // iSendmsg(xsite.BaseObjectSpace,
     //                                            ' API Error ' + mtable ,     // popis
     //                                             mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
     //                                             mToMSG ,                      // komu
     //                                             xsite.SiteContext.GetCompanyCache.GetUserID); // kdo





   function SendMail_SCH(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
var
  mbo,mRecipient : TNxCustomBusinessObject;
  mAttachmentColl: TNxCustomBusinessMonikerCollection ;
  mSL : TStringList;
  i : integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
begin
  result:='';
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID',AFrom);

        mBO.SetFieldValueAsString('Firm_ID','7F26300101');
        //mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
        //mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 1);
    mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
    mSL := TStringList.Create;
    try
      NxTokenToStrings(ATO, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 0);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;

    //mSL := TStringList.Create;
    //try
      //NxTokenToStrings(mS_CopyEmail, ';', mSL);
      //for i := 0 to mSL.Count - 1 do begin
    //    mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
    //    mRecipient.SetFieldValueAsInteger('EmailType', 1);
    //    mRecipient.SetFieldValueAsString('email', 'archiv@lipoelastic.com');
        //mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      //end;
    //finally
    //  mSL.Free;
    //end;

  // mSL := TStringList.Create;
  //  try
  //    NxTokenToStrings(mS_BccEmail, ';', mSL);
  //    for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 2);
        mRecipient.SetFieldValueAsString('email', 'mskacel@lipoelastic.com');
//        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
  //    end;
  //  finally
  //    mSL.Free;
  //  end;

    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
          TNxEmailSent(mbo).AttachFile(afilename);

    end;



    mbo.save;
   // NxShowSimpleMessage('Vytvořen email: ' + mbo.oid,nil);
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;






  function POST_APIStorecard_ID(AContext: TNxContext; mStorecard_code: string; APath: String): string;
var
  msBody:string;
  mBO_Storecard:TNxCustomBusinessObject;
  mCena:double;
  mStorecard_ID:string;
begin
  if not NxIsBlank(mStorecard_code) then begin
       mStorecard_ID:='';
       mStorecard_ID:=AContext.SQLSelectFirstAsString('select id from storecards where code=' + quotedstr(mStorecard_code) + ' and hidden=' + quotedstr('N') );
       if mStorecard_ID<>'' then begin
             result:=mStorecard_ID;
       end else begin
             result:='0000000000';
       end;
	end else begin
		RaiseException('Missing param info_type.');
	end;
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



     function JSONCorrectText(mString:string):string;
begin
              mString:=NxSearchReplace(mString,'/','_',[srCase,srAll]);
              mString:=NxSearchReplace(mString,'"','',[srCase,srAll]);
     result:=mString;
end;

 function GetDocJSON(mJSON:TJSONSuperObject;mBOHead:TNxCustomBusinessObject;mStore_ID:string;mDivison_ID:string;mImport:boolean;acontext:TNxContext;mICount:integer):TJSONSuperObject;
  var
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,iRow,iBatch,ii,j : integer;
  AInput,mJSONHeads,mJSONRow,mJSONBatch,ARows,ABatches,mParameter:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBORows,mBOBatches:TNxCustomBusinessObject;
  mID,mString,mQuery:string;
  mMonRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  mID_Period_ID, mOrdnumber,mID_Docqueue_ID,  mID_Doc, mDocumentType:string;
  mStringList,mxA:tstringlist;
  mStrings:string;
  iDocument:integer;
  mBatchesList,mBatchValue:tstringlist;
  mIBatch:integer;
  mResult_DocType,mResult_DocQueue,mResult_Documents:string;
  mPocetDokladu:integer;
  mUserBO:TNxCustomBusinessObject;
  mPrice:Double;
  mImportBatches:boolean;
  mBatch_ID:string;
  begin
  if UpperCase(mJSON.S['ImportBatches'])='TRUE' then mImportBatches:=true else mImportBatches:=false;


                        mJSON.O['AbraDocuments'] := mJSON.CreateJSONArray;
                        mJSON.A['AbraDocuments'].O[mICount]:= mJSON.CreateJSON;


                        mJSON.A['AbraDocuments'].O[mICount].S['DocNumber']:= JSONCorrectText(mBOHead.GetFieldValueAsString('DisplayName'));
                        mJSON.A['AbraDocuments'].O[mICount].S['DocDate']:= NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('DocDate$Date'));
                        mJSON.A['AbraDocuments'].O[mICount].S['Firma']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                        mJSON.A['AbraDocuments'].O[mICount].S['Provozovna']:= mBOHead.GetFieldValueAsString('FirmOffice_ID.Name');
                        mJSON.A['AbraDocuments'].O[mICount].S['Description']:= JSONCorrectText(mBOHead.GetFieldValueAsString('Description'));
                        //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');
                        //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');
                        //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');


                        if mImport then begin        // ****** přenášejí se podklady pro import
                               mJSON.A['AbraDocuments'].O[mICount].S['DocDate']:= NxFloatToIBStr(Now);
                               mJSON.A['AbraDocuments'].O[mICount].S['ID']:= mBOHead.oid;
                               mJSON.A['AbraDocuments'].O[mICount].S['Docqueue_ID']:=mBOHead.GetFieldValueAsString('Docqueue_ID');
                               mJSON.A['AbraDocuments'].O[mICount].S['X_Poznam_exp']:=JSONCorrectText(mBOHead.GetFieldValueAsString('X_Poznam_exp_ext'));
                               mJSON.A['AbraDocuments'].O[mICount].S['X_Poznam_exp_ext']:=JSONCorrectText(mBOHead.GetFieldValueAsString('X_Poznam_exp'));
                               mJSON.A['AbraDocuments'].O[mICount].S['TradeType']:= IntToStr(1);
                               //mJSON.A['AbraDocuments'].O[mICount].S['TradeType']:= IntToStr(mBOHead.GetFieldValueAsInteger('tradetype'));

                               //  mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');
                               if NxIsBlank(mBOHead.GetFieldValueAsString('X_ExternalDocument')) or (trim(mBOHead.GetFieldValueAsString('X_ExternalDocument'))='0') then begin
                                      mJSON.A['AbraDocuments'].O[mICount].S['X_ExternalDocument']:= JSONCorrectText(mBOHead.DisplayName);
                                      mJSON.A['AbraDocuments'].O[mICount].S['X_ExternalDocument']:= JSONCorrectText(mBOHead.GetFieldValueAsString('X_ExternalDocument'));
                               end;
                               //mJSON.A['AbraDocuments'].O[mICount].S['DocumentDiscount']:= NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount'));
                               try
                                   mJSON.A['AbraDocuments'].O[mICount].S['Description']:= JSONCorrectText(mBOHead.GetFieldValueAsString('Description'));
                               finally end;

                              //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');

                        end;

                        if ((mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // **** je objednávka
                                       try
                                           mJSON.A['AbraDocuments'].O[mICount].S['X_poznamka']:= JSONCorrectText(mBOHead.GetFieldValueAsString('X_poznamka'));
                                       finally end;
                                       mJSON.A['AbraDocuments'].O[mICount].S['Confirmed']:= 'True';
                                       mJSON.A['AbraDocuments'].O[mICount].S['Currency_ID']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                       try
                                               if NxIsBlank(mBOHead.GetFieldValueAsString('X_Identifikace'))  then begin
                                                   mJSON.A['AbraDocuments'].O[mICount].S['X_Identifikace']:=JSONCorrectText(mBOHead.GetFieldValueAsString('Firm_ID.Name'));
                                               end else begin
                                                  mJSON.A['AbraDocuments'].O[mICount].S['X_Identifikace']:= JSONCorrectText(mBOHead.GetFieldValueAsString('X_Identifikace'));
                                               end;

                                               if NxIsBlank(mBOHead.GetFieldValueAsString('ExternalNumber'))  then begin
                                                  mJSON.A['AbraDocuments'].O[mICount].S['ExternalNumber']:= JSONCorrectText(mBOHead.DisplayName);
                                               end else begin
                                                  mJSON.A['AbraDocuments'].O[mICount].S['ExternalNumber']:= JSONCorrectText(mBOHead.GetFieldValueAsString('ExternalNumber'));
                                               end;
                                       finally
                                       end;
                                       //mJSON.A['AbraDocuments'].O[mICount].S['CurrencyCode']:= mBOHead.GetFieldValueAsString('CurrencyCode');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['CountryCode']:= mBOHead.GetFieldValueAsString('CountryCode');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['DeliveryType']:= mBOHead.GetFieldValueAsString('DeliveryType');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['PaymentType']:= mBOHead.GetFieldValueAsString('PaymentType');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['X_poznamka']:= mBOHead.GetFieldValueAsString('X_poznamka');

                                 if (mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin   // ***  jen objednávka přijatá
                                        //******* JSON.A['AbraDocuments'].O[mICount].S['X_Termin_dodani']:= NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                   end;

                                   if mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then begin    // ***** jen objednávka vydaná
                                         //*******JSON.A['AbraDocuments'].O[mICount].S['X_datum_dodani']:= NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                   end;


                        end else begin    // **** je skladový doklad
                                    mJSON.A['AbraDocuments'].O[mICount].S['Currency_ID']:= '0000EUR000';
                                    mJSON.A['AbraDocuments'].O[mICount].S['CurrencyCode']:= 'EUR';
                        end;






                        // ****** řádkové objekty
                        mJSON.A['AbraDocuments'].O[mICount].O['Rows'] := mJSON.CreateJSONArray;
                            mMonRows := mBOHead.GetLoadedCollectionMonikerForFieldCode(mBOHead.GetFieldCode('ROWS'));
                                 if mMonRows.count>0 then begin
                                         for iRow := 0 to mMonRows.Count - 1 do begin

                                                mJSONRow:=TJSONSuperObject.Create;
                                                mJSONRow.I['PosIndex']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex');
                                                mJSONRow.S['Storecard_EAN']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN');
                                                mJSONRow.S['Storecard_Name']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.Name'));
                                                mJSONRow.D['Quantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity');
                                                mJSONRow.D['DeliveredQuantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('DeliveredQuantity');
                                               //**** mJSONRow.S['DeliveryDate$DATE']:=NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('DeliveryDate$DATE'));
                                                mJSONRow.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                if mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')='~000000G01' then begin
                                                        mJSONRow.S['Storecard_ID']:='~S00000C02';
                                                end else begin
                                                        mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                end;



                                                if trim(mJSON.S['Store_Code'])='' then mJSON.S['Store_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code') ;
                                                if mMonRows.BusinessObject[iRow].GetFieldValueAsinteger('Storecard_ID.Category')=0 then begin
                                                                                                mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                //mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                      //mJSONBatch.S['Posindex']:=inttostr(0);
                                                                                                                      //mJSONBatch.S['StoreBatch']:='';
                                                                                                                      //mJSONBatch.D['Quantity']:=0
                                                                                                                      //mJSONBatch.S['QUnit']:='';
                                                                                                //                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                        end;


                                                if mImport then begin
                                                      mJSONRow.I['RowType']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('RowType');
                                                      mJSONRow.S['Text']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Text'));

                                                      //**** mJSONRow.S['BusOrder_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID');
                                                      mJSONRow.S['BusOrder_ID_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID.Code');
                                                     //**** mJSONRow.S['BusTransaction_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID');
                                                      mJSONRow.S['BusTransaction_ID_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID.Code');
                                                      //**** mJSONRow.S['BusProject_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID');
                                                      mJSONRow.S['BusProject_ID_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID.Code');
                                                      mJSONRow.S['X_Providerow_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID');
                                                      mJSONRow.S['X_specifikace_id']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_specifikace_id'));
                                                      mJSONRow.S['X_ExternalSpecification']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_ExternalSpecification'));

                                                      //mJSONRow.S['Store_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID');
                                                      if trim(mJSON.S['Division_Code'])='' then  mJSON.S['Division_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Division_ID.Code');
                                                      mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID');

                                                      if uppercase(mJSON.S['WithPrices'])='TRUE' then begin
                                                              // **     ceny      *****
                                                              mprice:=0;
                                                              mxa:=tstringlist.create;
                                                                 // z faktury
                                                                       try
                                                                           if mDocumentType='21' then AContext.GetObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID where Providerow_ID =' + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID')),mxa);

                                                                           if mxa.count>0 then begin
                                                                                mprice:=NxIBStrToFloat(mxa.Strings[0]);
                                                                           end else begin
                                                                           end;
                                                                       finally
                                                                           mxa.free;
                                                                       end;

                                                                if mprice=0 then begin
                                                                                           //if mdebug then begin
                                                                                           //    result:= result+ chr(13) + chr(10) + 'NxGetStoreCardUnitPriceDef(' +  Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                           //           +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID'))+', '
                                                                                           //           +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                           //           +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                           //           +Quotedstr(MonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit')) +',False,'
                                                                                           //           +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                           //           +inttostr(trunc(mBOHead.GetFieldValueAsDateTime('Docdate$Date'))) + ')';
                                                                                           //end;

                                                                                                 mprice:=NxEvalObjectExprAsFloatDef(mBOHead,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                                        +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID'))+', '
                                                                                                        +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                                        +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                                        +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit'))+',False,'
                                                                                                        +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                                        +inttostr(trunc(mBOHead.GetFieldValueAsDateTime('Docdate$Date')))+')',0);



                                                                 end;


                                                            {     if mprice=0 then begin
                                                                       // z cenníku
                                                                            mprice:=NxEvalObjectExprAsFloatDef(mBOHead,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                            +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.PriceList_ID'))+', '
                                                                                            +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                            +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                            +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit'))+',False,'
                                                                                            +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                            +inttostr(trunc(Date))+')',0);
                                                                 end; }
                                                                 if mprice<>0 then begin
                                                                          mJSONRow.S['UnitPrice']:=NxFloatToIBStr(mprice);
                                                                          mJSONRow.S['TotalPrice']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                          mJSONRow.S['Tamount']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                          //mJSONRow.S['Tamountwithoutvat']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                 end;
                                                      end;


                                                end;

                                                if mImportBatches then begin

                                                            if ((mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // **** je objednávka
                                                                      mBatchesList:=tstringlist.create;
                                                                      try
                                                                      if (mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin     // šarže na objednávkách přijatých
                                                                              AContext.GetObjectSpace.SQLSelect('SELECT B.Name,A.X_quantity,B.ID FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                    + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)   ;
                                                                      end;
                                                                      if (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin     // šarže na objednávkách vydaných
                                                                              AContext.GetObjectSpace.SQLSelect('SELECT B.Name,A.X_quantity,B.ID FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                    + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)  ;
                                                                      end;
                                                                              if mBatchesList.count>0 then begin
                                                                                      for iBatch := 0 to mBatchesList.Count - 1 do begin
                                                                                          mJSONBatch:=TJSONSuperObject.Create;
                                                                                                 mJSONBatch.S['Posindex']:=inttostr(iBatch+1);
                                                                                                 mBatchValue:=TStringList.create;
                                                                                                 mBatchValue:=fnParsevalue(mBatchesList.Strings[mIBatch],';');
                                                                                                 try
                                                                                                      // ******  get or create batch     ****
                                                                                                      mBatch_ID:=API_GetOrCreateBatch(AContext.GetObjectSpace,mTargetAPI,mBatchValue.Strings[2]);
                                                                                                      if mBatchValue.count>0 then mJSONBatch.S['Name']:=JSONCorrectText(mBatchValue.Strings[0]);
                                                                                                      if mBatchValue.count>1 then mJSONBatch.D['Quantity']:=NxIBStrToFloat(mBatchValue.Strings[1]);
                                                                                                      mJSONBatch.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                                 finally
                                                                                                     mBatchValue.free;
                                                                                                 end;
                                                                                         mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                      end;
                                                                              end;
                                                                      finally
                                                                          mBatchesList.free;
                                                                      end;

                                                             end else begin
                                                                  // ****** šarže  skladový doklad
                                                                    mMonBatches := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('DocRowBatches'));
                                                                        if mMonBatches.count>0 then begin
                                                                              mJSONRow.O['DocRowBatches']:=mJSONRow.CreateJSONArray;
                                                                              for iBatch := 0 to mMonBatches.Count - 1 do begin
                                                                                    mJSONBatch:=TJSONSuperObject.create;
                                                                                        // ******  get or create batch     ****
                                                                                        mBatch_ID:=API_GetOrCreateBatch(AContext.GetObjectSpace,mTargetAPI,mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_id'));
                                                                                        mJSONBatch.S['Posindex']:=inttostr(mMonBatches.BusinessObject[iBatch].GetFieldValueAsInteger('Posindex'));
                                                                                        mJSONBatch.S['Name']:=JSONCorrectText(mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_id.Name'));
                                                                                        mJSONBatch.D['Quantity']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsFloat('Quantity');
                                                                                        mJSONBatch.S['QUnit']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('QUnit');
                                                                                    mJSONRow.A['DocRowBatches'].add(mJSONBatch);       // *** zapsání skladové šarže
                                                                              end;
                                                                        end;
                                                             end;
                                                end;
                                            mJSON.A['AbraDocuments'].O[mICount].A['Rows'].Add(mJSONRow);   // **** zapsání řádku
                                           end;
                                 end;

                       //    mJSON.A['AbraDocuments'].Add(mJSONHeads);
                 Result:=mJSON;

end;







 function GetDocJSON_new(mJSON:TJSONSuperObject;mBOHead:TNxCustomBusinessObject;mStore_ID:string;mDivison_ID:string;mImport:boolean;acontext:TNxContext;mICount:integer;mPath:string):TJSONSuperObject;
  var
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,iRow,iBatch,ii,j : integer;
  AInput,mJSONHeads,mJSONRow,mJSONBatch,ARows,ABatches,mParameter:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBORows,mBOBatches:TNxCustomBusinessObject;
  mID,mString,mQuery:string;
  mMonRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  mID_Period_ID, mOrdnumber,mID_Docqueue_ID,  mID_Doc, mDocumentType:string;
  mStringList,mxA:tstringlist;
  mStrings:string;
  iDocument:integer;
  mBatchesList,mBatchValue:tstringlist;
  mIBatch:integer;
  mResult_DocType,mResult_DocQueue,mResult_Documents:string;
  mPocetDokladu:integer;
  mUserBO:TNxCustomBusinessObject;
  mPrice:Double;
  mImportBatches:boolean;
  mBatch_ID:string;
  mStringReturn: string;
  begin
  if UpperCase(mJSON.S['ImportBatches'])='TRUE' then mImportBatches:=true else mImportBatches:=false;


                        mJSON.O['AbraDocuments'] := mJSON.CreateJSONArray;
                        mJSON.A['AbraDocuments'].O[mICount]:= mJSON.CreateJSON;


                        mJSON.A['AbraDocuments'].O[mICount].S['DocNumber']:= JSONCorrectText(mBOHead.GetFieldValueAsString('DisplayName'));
                        mJSON.A['AbraDocuments'].O[mICount].S['DocDate']:= NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('DocDate$Date'));
                        mJSON.A['AbraDocuments'].O[mICount].S['Firma']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                        mJSON.A['AbraDocuments'].O[mICount].S['Provozovna']:= mBOHead.GetFieldValueAsString('FirmOffice_ID.Name');
                        mJSON.A['AbraDocuments'].O[mICount].S['Description']:= JSONCorrectText(mBOHead.GetFieldValueAsString('Description'));
                        //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');
                        //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');
                        //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');


                        if mImport then begin        // ****** přenášejí se podklady pro import
                               mJSON.A['AbraDocuments'].O[mICount].S['DocDate']:= NxFloatToIBStr(Now);
                               mJSON.A['AbraDocuments'].O[mICount].S['ID']:= mBOHead.oid;
                               mJSON.A['AbraDocuments'].O[mICount].S['Docqueue_ID']:=mBOHead.GetFieldValueAsString('Docqueue_ID');
                               mJSON.A['AbraDocuments'].O[mICount].S['X_Poznam_exp']:=JSONCorrectText(mBOHead.GetFieldValueAsString('X_Poznam_exp_ext'));
                               mJSON.A['AbraDocuments'].O[mICount].S['X_Poznam_exp_ext']:=JSONCorrectText(mBOHead.GetFieldValueAsString('X_Poznam_exp'));
                               mJSON.A['AbraDocuments'].O[mICount].S['TradeType']:= IntToStr(1);
                               //mJSON.A['AbraDocuments'].O[mICount].S['TradeType']:= IntToStr(mBOHead.GetFieldValueAsInteger('tradetype'));

                               //  mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');
                               if NxIsBlank(mBOHead.GetFieldValueAsString('X_ExternalDocument')) or (trim(mBOHead.GetFieldValueAsString('X_ExternalDocument'))='0') then begin
                                      mJSON.A['AbraDocuments'].O[mICount].S['X_ExternalDocument']:= JSONCorrectText(mBOHead.DisplayName);
                                      mJSON.A['AbraDocuments'].O[mICount].S['X_ExternalDocument']:= JSONCorrectText(mBOHead.GetFieldValueAsString('X_ExternalDocument'));
                               end;
                               //mJSON.A['AbraDocuments'].O[mICount].S['DocumentDiscount']:= NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount'));
                               try
                                   mJSON.A['AbraDocuments'].O[mICount].S['Description']:= JSONCorrectText(mBOHead.GetFieldValueAsString('Description'));
                               finally end;

                              //mJSON.A['AbraDocuments'].O[mICount].S['']:= mBOHead.GetFieldValueAsString('');

                        end;

                        if ((mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // **** je objednávka
                                       try
                                           mJSON.A['AbraDocuments'].O[mICount].S['X_poznamka']:= JSONCorrectText(mBOHead.GetFieldValueAsString('X_poznamka'));
                                       finally end;
                                       mJSON.A['AbraDocuments'].O[mICount].S['Confirmed']:= 'True';
                                       mJSON.A['AbraDocuments'].O[mICount].S['Currency_ID']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                       try
                                               if NxIsBlank(mBOHead.GetFieldValueAsString('X_Identifikace'))  then begin
                                                   mJSON.A['AbraDocuments'].O[mICount].S['X_Identifikace']:=JSONCorrectText(mBOHead.GetFieldValueAsString('Firm_ID.Name'));
                                               end else begin
                                                  mJSON.A['AbraDocuments'].O[mICount].S['X_Identifikace']:= JSONCorrectText(mBOHead.GetFieldValueAsString('X_Identifikace'));
                                               end;

                                               if NxIsBlank(mBOHead.GetFieldValueAsString('ExternalNumber'))  then begin
                                                  mJSON.A['AbraDocuments'].O[mICount].S['ExternalNumber']:= JSONCorrectText(mBOHead.DisplayName);
                                               end else begin
                                                  mJSON.A['AbraDocuments'].O[mICount].S['ExternalNumber']:= JSONCorrectText(mBOHead.GetFieldValueAsString('ExternalNumber'));
                                               end;
                                       finally
                                       end;
                                       //mJSON.A['AbraDocuments'].O[mICount].S['CurrencyCode']:= mBOHead.GetFieldValueAsString('CurrencyCode');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['CountryCode']:= mBOHead.GetFieldValueAsString('CountryCode');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['DeliveryType']:= mBOHead.GetFieldValueAsString('DeliveryType');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['PaymentType']:= mBOHead.GetFieldValueAsString('PaymentType');
                                       //mJSON.A['AbraDocuments'].O[mICount].S['X_poznamka']:= mBOHead.GetFieldValueAsString('X_poznamka');

                                 if (mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin   // ***  jen objednávka přijatá
                                        //******* JSON.A['AbraDocuments'].O[mICount].S['X_Termin_dodani']:= NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                   end;

                                   if mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then begin    // ***** jen objednávka vydaná
                                         //*******JSON.A['AbraDocuments'].O[mICount].S['X_datum_dodani']:= NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                   end;


                        end else begin    // **** je skladový doklad
                                    mJSON.A['AbraDocuments'].O[mICount].S['Currency_ID']:= '0000EUR000';
                                    mJSON.A['AbraDocuments'].O[mICount].S['CurrencyCode']:= 'EUR';
                        end;






                        // ****** řádkové objekty
                        mJSON.A['AbraDocuments'].O[mICount].O['Rows'] := mJSON.CreateJSONArray;
                            mMonRows := mBOHead.GetLoadedCollectionMonikerForFieldCode(mBOHead.GetFieldCode('ROWS'));
                                 if mMonRows.count>0 then begin
                                         for iRow := 0 to mMonRows.Count - 1 do begin

                                                mJSONRow:=TJSONSuperObject.Create;
                                                mJSONRow.I['PosIndex']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex');
                                                mJSONRow.S['Storecard_EAN']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN');
                                                mJSONRow.S['Storecard_Name']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.Name'));
                                                mJSONRow.D['Quantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity');
                                                mJSONRow.D['DeliveredQuantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('DeliveredQuantity');
                                               //**** mJSONRow.S['DeliveryDate$DATE']:=NxFloatToIBStr(mBOHead.GetFieldValueAsDateTime('DeliveryDate$DATE'));
                                                mJSONRow.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');

                                                mStringReturn:='';
                                                try
                                                mStringReturn:=APICallRest(mBOHead,'POST',mPath,'/Script/','NxApiLib/Lib/APIStorecard_ID',mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.code'),True);
                                                    if copy(mStringReturn,1,3)='200' then begin
                                                            mStringReturn:=copy(mStringReturn,7,10);
                                                        if trim(mStringReturn)<>'' then begin
                                                                if mStringReturn<>mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID') then begin
                                                                        mJSONRow.S['Storecard_ID']:=mStringReturn;
                                                                end else begin
                                                                        mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                                end;
                                                        end else begin
                                                           mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')
                                                        end;
                                                    end else begin
                                                        mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                    end;
                                                 finally

                                                 end;








                                                //if mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')='~000000G01' then begin
                                                //        mJSONRow.S['Storecard_ID']:='~S00000C02';
                                                //end else begin
                                                //        mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                //end;



                                                if trim(mJSON.S['Store_Code'])='' then mJSON.S['Store_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code') ;
                                                if mMonRows.BusinessObject[iRow].GetFieldValueAsinteger('Storecard_ID.Category')=0 then begin
                                                                                                mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                //mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                      //mJSONBatch.S['Posindex']:=inttostr(0);
                                                                                                                      //mJSONBatch.S['StoreBatch']:='';
                                                                                                                      //mJSONBatch.D['Quantity']:=0
                                                                                                                      //mJSONBatch.S['QUnit']:='';
                                                                                                //                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                        end;


                                                if mImport then begin
                                                      mJSONRow.I['RowType']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('RowType');
                                                      mJSONRow.S['Text']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Text'));

                                                      //**** mJSONRow.S['BusOrder_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID');
                                                      mJSONRow.S['BusOrder_ID_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID.Code');
                                                     //**** mJSONRow.S['BusTransaction_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID');
                                                      mJSONRow.S['BusTransaction_ID_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID.Code');
                                                      //**** mJSONRow.S['BusProject_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID');
                                                      mJSONRow.S['BusProject_ID_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID.Code');
                                                      mJSONRow.S['X_Providerow_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID');
                                                      mJSONRow.S['X_specifikace_id']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_specifikace_id'));
                                                      mJSONRow.S['X_ExternalSpecification']:=JSONCorrectText(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_ExternalSpecification'));

                                                      //mJSONRow.S['Store_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID');
                                                      if trim(mJSON.S['Division_Code'])='' then  mJSON.S['Division_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Division_ID.Code');
                                                      mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID');

                                                      if uppercase(mJSON.S['WithPrices'])='TRUE' then begin
                                                              // **     ceny      *****
                                                              mprice:=0;
                                                              mxa:=tstringlist.create;
                                                                 // z faktury
                                                                       try
                                                                           if mDocumentType='21' then AContext.GetObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID where Providerow_ID =' + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID')),mxa);

                                                                           if mxa.count>0 then begin
                                                                                mprice:=NxIBStrToFloat(mxa.Strings[0]);
                                                                           end else begin
                                                                           end;
                                                                       finally
                                                                           mxa.free;
                                                                       end;

                                                                if mprice=0 then begin
                                                                                           //if mdebug then begin
                                                                                           //    result:= result+ chr(13) + chr(10) + 'NxGetStoreCardUnitPriceDef(' +  Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                           //           +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID'))+', '
                                                                                           //           +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                           //           +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                           //           +Quotedstr(MonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit')) +',False,'
                                                                                           //           +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                           //           +inttostr(trunc(mBOHead.GetFieldValueAsDateTime('Docdate$Date'))) + ')';
                                                                                           //end;

                                                                                                 mprice:=NxEvalObjectExprAsFloatDef(mBOHead,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                                        +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID'))+', '
                                                                                                        +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                                        +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                                        +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit'))+',False,'
                                                                                                        +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                                        +inttostr(trunc(mBOHead.GetFieldValueAsDateTime('Docdate$Date')))+')',0);



                                                                 end;


                                                            {     if mprice=0 then begin
                                                                       // z cenníku
                                                                            mprice:=NxEvalObjectExprAsFloatDef(mBOHead,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                            +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.PriceList_ID'))+', '
                                                                                            +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                            +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                            +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit'))+',False,'
                                                                                            +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                            +inttostr(trunc(Date))+')',0);
                                                                 end; }
                                                                 if mprice<>0 then begin
                                                                          mJSONRow.S['UnitPrice']:=NxFloatToIBStr(mprice);
                                                                          mJSONRow.S['TotalPrice']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                          mJSONRow.S['Tamount']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                          //mJSONRow.S['Tamountwithoutvat']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                 end;
                                                      end;


                                                end;

                                                if mImportBatches then begin

                                                            if ((mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // **** je objednávka
                                                                      mBatchesList:=tstringlist.create;
                                                                      try
                                                                      if (mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin     // šarže na objednávkách přijatých
                                                                              AContext.GetObjectSpace.SQLSelect('SELECT B.Name,A.X_quantity,B.ID FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                    + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)   ;
                                                                      end;
                                                                      if (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin     // šarže na objednávkách vydaných
                                                                              AContext.GetObjectSpace.SQLSelect('SELECT B.Name,A.X_quantity,B.ID FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                    + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)  ;
                                                                      end;
                                                                              if mBatchesList.count>0 then begin
                                                                                      for iBatch := 0 to mBatchesList.Count - 1 do begin
                                                                                          mJSONBatch:=TJSONSuperObject.Create;
                                                                                                 mJSONBatch.S['Posindex']:=inttostr(iBatch+1);
                                                                                                 mBatchValue:=TStringList.create;
                                                                                                 mBatchValue:=fnParsevalue(mBatchesList.Strings[mIBatch],';');
                                                                                                 try
                                                                                                      // ******  get or create batch     ****
                                                                                                      mBatch_ID:=API_GetOrCreateBatch(AContext.GetObjectSpace,mTargetAPI,mBatchValue.Strings[2]);
                                                                                                      if mBatchValue.count>0 then mJSONBatch.S['Name']:=JSONCorrectText(mBatchValue.Strings[0]);
                                                                                                      if mBatchValue.count>1 then mJSONBatch.D['Quantity']:=NxIBStrToFloat(mBatchValue.Strings[1]);
                                                                                                      mJSONBatch.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                                 finally
                                                                                                     mBatchValue.free;
                                                                                                 end;
                                                                                         mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                      end;
                                                                              end;
                                                                      finally
                                                                          mBatchesList.free;
                                                                      end;

                                                             end else begin
                                                                  // ****** šarže  skladový doklad
                                                                    mMonBatches := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('DocRowBatches'));
                                                                        if mMonBatches.count>0 then begin
                                                                              mJSONRow.O['DocRowBatches']:=mJSONRow.CreateJSONArray;
                                                                              for iBatch := 0 to mMonBatches.Count - 1 do begin
                                                                                    mJSONBatch:=TJSONSuperObject.create;
                                                                                        // ******  get or create batch     ****
                                                                                        mBatch_ID:=API_GetOrCreateBatch(AContext.GetObjectSpace,mTargetAPI,mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_id'));
                                                                                        mJSONBatch.S['Posindex']:=inttostr(mMonBatches.BusinessObject[iBatch].GetFieldValueAsInteger('Posindex'));
                                                                                        mJSONBatch.S['Name']:=JSONCorrectText(mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_id.Name'));
                                                                                        mJSONBatch.D['Quantity']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsFloat('Quantity');
                                                                                        mJSONBatch.S['QUnit']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('QUnit');
                                                                                    mJSONRow.A['DocRowBatches'].add(mJSONBatch);       // *** zapsání skladové šarže
                                                                              end;
                                                                        end;
                                                             end;
                                                end;
                                            mJSON.A['AbraDocuments'].O[mICount].A['Rows'].Add(mJSONRow);   // **** zapsání řádku
                                           end;
                                 end;

                       //    mJSON.A['AbraDocuments'].Add(mJSONHeads);
                 Result:=mJSON;

end;





function POST_APINxGetDOC(AContext: TNxContext; Abody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,iRow,iBatch,ii,j : integer;
  mJSON,AInput,mJSONHeads,mJSONRow,mJSONBatch,ARows,ABatches,mParameter:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBOHead,mBORows,mBOBatches:TNxCustomBusinessObject;
  mID,mString,mQuery:string;
  mMonRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  mID_Period_ID, mOrdnumber,mID_Docqueue_ID,  mID_Doc, mDocumentType:string;
  mImport:boolean;
  mStringList,mxA:tstringlist;
  mStrings:string;
  iDocument:integer;
  mBatchesList,mBatchValue:tstringlist;
  mIBatch:integer;
  mResult_DocType,mResult_DocQueue,mResult_Documents:string;
  mPocetDokladu:integer;
  mUserBO:TNxCustomBusinessObject;
  mPrice:Double;
  mJSONReturn:TJSONSuperObject;
  mStringReturn:string;
begin

   mResult_DocType:='';
   mResult_DocQueue:='';
   mResult_Documents:='';
   mPocetDokladu:=0;


      AInput:=TJSONSuperObject.create;
      AInput:= Abody;
      mJSON:=TJSONSuperObject.create;
      mParameter:=TJSONSuperObject.create;
      mStringList:=tstringlist.create;
      mImport:=false;
      try
          mImport:=NxStringToBool(Abody.S['Import']);
      finally
      end;

      mDocumentType:='';
      try
          mDocumentType:=Trim(UpperCase(Abody.S['DocType']));
      finally
      end;

      mStringList:=fnParsevalue(Abody.S['Input_Document'],';')  ;
     mPocetDokladu:= mStringList.count;
      for iDocument:=0 to mStringList.count-1 do begin;
                        if (AnsiPos('-', mStringList.Strings[iDocument])>0) and (AnsiPos('/', mStringList.Strings[iDocument])>0) then begin
                               mr:=tstringlist.create;
                               try
                                    if mDocumentType='' then AContext.SQLSelect('Select DocumentType from DocQUEUES where code=' + quotedstr(trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))),mr);
                                    if mDocumentType<>'' then AContext.SQLSelect('Select DocumentType from DocQUEUES where code=' + quotedstr(trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))) + ' and DocumentType=' + quotedstr('mDocumentType'),mr);

                                    if mr.count=1 then begin
                                          if (uppercase(mDocumentType)=Uppercase(mr.Strings[0])) or (trim(uppercase(mDocumentType))='')  then begin
                                                 mDocumentType:=mr.Strings[0]
                                          end else begin
                                               mResult_DocType:= 'Položky si neodpovídají';
                                          end;

                                    end else begin
                                          if mr.count=0 then begin
                                               mResult_DocQueue:=  'Nedohledána řada';
                                          end else begin
                                              mResult_DocQueue:= 'Více stejných řad';
                                          end
                                    end;

                               finally
                                    mr.free;
                               end;
                        end;

                        mr:=tstringlist.create;
                        try
                                 if mDocumentType='RO' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');

                                              AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Receivedorders Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) or (head.Externalnumber=' + quotedstr(mStringList.Strings[iDocument]) +
                                                                                  ')'
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                          end;
                                    if mDocumentType='IO' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');

                                              AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Issuedorders Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) or (head.Externalnumber=' + quotedstr(mStringList.Strings[iDocument]) +
                                                                                  ')'
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                          end;



                                    if mDocumentType='20' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');

                                              AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Storedocuments Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) '
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                    end;



                                   if mDocumentType='21' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');

                                               AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Storedocuments Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) '
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                    end;









                                         if mr.count=0 then mResult_Documents:= 'nedohledano';
                                         if mr.count>1 then mResult_Documents:= 'dohledano vice';

                                         if mr.count=1 then begin



                                                 mResult_DocType:=mDocumentType;
                                                 mResult_Documents:= 'Dohledáno_OK';



                                                              mBOHead.load(mr.Strings[0],nil);

                                                     if iDocument=0 then begin

                                                             if mImport then begin
                                                                    if mDocumentType='RO' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OP'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OP'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OP'), True);
                                                                            end;
                                                                      end;

                                                                    if mDocumentType='IO' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OV'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OV'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OV'), True);
                                                                            end;
                                                                      end;

                                                                      if mDocumentType='20' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'), True);
                                                                            end;
                                                                      end;

                                                                      if mDocumentType='21' then begin
                                                                             if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'), True);
                                                                            end;

                                                                            //if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_DL'))='') or
                                                                            //   (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_DL'))='{}') then begin
                                                                            //    mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                            //    result:=mJSON;
                                                                            //    exit;
                                                                            //end else begin
                                                                            //    mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_DL'), True);
                                                                            //end;
                                                                      end;

                                                                      if mDocumentType='03' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FP'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FP'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FP'), True);
                                                                            end;
                                                                      end;

                                                                      if mDocumentType='04' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FV'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FV'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FV'), True);
                                                                            end;
                                                                      end;


                                                                      mUserBO:= AContext.GetObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
                                                                      try
                                                                            mUserBO.load(AContext.GetCompanyCache.GetUserID,nil);
                                                                            mJSON.S['User']:= 'Supervisor';//mUserBO.GetFieldValueAsString('LoginName');
                                                                      finally
                                                                            mUserBO.free;
                                                                      end;

                                                                      mJSON.S['SelectedRows']:= '';
                                                                      mJSON.S['InputDocuments']:= '';
                                                                      mJSON.S['SelectedHeader']:= '';

                                                                      if trim(UpperCase(mJSON.S['Firm_Name']))= 'FIRM_ID.NAME' then
                                                                           mJSON.S['Firm_Name']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                                      //else mJSON.S['Firm_Name']:= 'LIPOELASTIC s.r.o.';

                                                                      //result:=mParameter;
                                                                      //exit ;
                                                             end;
                                                             mJSON.O['AbraDocuments'] := mJSON.CreateJSONArray;
                                                      end;
                                                      //mJSON.O['AbraDocuments'] := mJSON.CreateJSONArray;

                                                       mJSONHeads:=TJSONSuperObject.Create;
                                                     if mImport then mJSONHeads.S['ID']:= mr.Strings[0];
                                                     //  mJSONHeads.S['Document']:=mBOHead.GetFieldValueAsString('DisplayName');
                                                     //  mJSONHeads.I['TradeType']:=mBOHead.GetFieldValueAsInteger('TradeType');
                                                     //  mJSONHeads.S['Firm']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                       mJSONHeads.S['Firma']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                       mJSONHeads.S['Provozovna']:= mBOHead.GetFieldValueAsString('FirmOffice_ID.Name');

                                                        mJSONHeads.S['Description']:= mBOHead.GetFieldValueAsString('Description');

                                                       if mImport then begin
                                                             mJSONHeads.S['Docqueue_ID']:= mBOHead.GetFieldValueAsString('Docqueue_ID');
                                                            //**** mJSONHeads.S['X_Poznam_exp']:= mBOHead.GetFieldValueAsString('X_Poznam_exp_ext');
                                                            //**** mJSONHeads.S['X_Poznam_exp_ext']:= mBOHead.GetFieldValueAsString('X_Poznam_exp');
                                                             //***** mJSONHeads.S['Firm_ID']:= mBOHead.GetFieldValueAsString('Firm_ID');
                                                             mJSONHeads.S['TradeType']:= IntToStr(mBOHead.GetFieldValueAsInteger('tradetype'));
//                                                             mJSONHeads.S['Country_ID']:= mBOHead.GetFieldValueAsString('00000SK000');
                                                            // mJSONHeads.S['IntrastatDeliveryTerm_ID']:= mBOHead.GetFieldValueAsString('3001000000');
                                                            //mJSONHeads.S['IntrastatTransactionType_ID']:= mBOHead.GetFieldValueAsString('0101000000');
                                                            // mJSONHeads.S['IntrastatTransportationType_ID']:= mBOHead.GetFieldValueAsString('2000000000');

                                                                            if mDocumentType='RO' then begin
                                                                                  //******* mJSONHeads.S['X_Termin_dodani']:= FormatDateTime('YYYY-MM-DD',mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                                                            end;
                                                                            if mDocumentType='OV' then begin
                                                                                  //*******mJSONHeads.S['X_datum_dodani']:= FormatDateTime('YYYY-MM-DD',mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                                                            end;

                                                                           if NxIsBlank(mBOHead.GetFieldValueAsString('X_ExternalDocument')) or (trim(mBOHead.GetFieldValueAsString('X_ExternalDocument'))='0') then begin
                                                                                mJSONHeads.S['X_ExternalDocument']:= mBOHead.DisplayName;

                                                                                mJSONHeads.S['X_ExternalDocument']:= mBOHead.GetFieldValueAsString('X_ExternalDocument');
                                                                            end;

                                                                            if ((mDocumentType='IO') or  (mDocumentType='RO')) then begin
                                                                                 mJSONHeads.S['Confirmed']:= 'True';
                                                                                 mJSONHeads.S['Currency_ID']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                                                                 try
                                                                                         if NxIsBlank(mBOHead.GetFieldValueAsString('X_Identifikace'))  then begin
                                                                                            mJSONHeads.S['X_Identifikace']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                                                         end else begin
                                                                                            mJSONHeads.S['X_Identifikace']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                                                                         end;

                                                                                         if NxIsBlank(mBOHead.GetFieldValueAsString('ExternalNumber'))  then begin
                                                                                            mJSONHeads.S['ExternalNumber']:= mBOHead.DisplayName;
                                                                                         end else begin
                                                                                            mJSONHeads.S['ExternalNumber']:= mBOHead.GetFieldValueAsString('ExternalNumber');
                                                                                         end;
                                                                                 finally
                                                                                 end;
                                                                            end;
                                                                            //mQuery:=mQuery +'"DocumentDiscount":" ' + NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount')) + '", '                  ;
                                                                            try
                                                                             mJSONHeads.S['Description']:= mBOHead.GetFieldValueAsString('Description');
                                                                            finally end;
                                                                            try
                                                                            //*****    mJSONHeads.S['X_poznamka']:= mBOHead.GetFieldValueAsString('X_poznamka');
                                                                            finally end;
                                                       end;


                                                        if ((mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                              // mJSONHeads.S['CurrencyCode']:= mBOHead.GetFieldValueAsString('CurrencyCode');
                                                              //  mJSONHeads.S['CountryCode']:= mBOHead.GetFieldValueAsString('CountryCode');
                                                              //  mJSONHeads.S['DeliveryType']:= mBOHead.GetFieldValueAsString('DeliveryType');
                                                              //  mJSONHeads.S['PaymentType']:= mBOHead.GetFieldValueAsString('PaymentType');

                                                               mJSONHeads.S['Externalnumber']:= mBOHead.GetFieldValueAsString('Externalnumber');
                                                                       //*********mJSONHeads.S['X_poznamka']:= mBOHead.GetFieldValueAsString('X_poznamka');
                                                                       mJSONHeads.S['Currency_ID']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                                         end else begin
                                                                      mJSONHeads.S['Currency_ID']:= '0000EUR000';
                                                                      mJSONHeads.S['CurrencyCode']:= 'EUR';
                                                         end;
                                                                mMonRows := mBOHead.GetLoadedCollectionMonikerForFieldCode(mBOHead.GetFieldCode('ROWS'));
                                                                                   // řádky
                                                                                mJSONHeads.O['Rows'] := mJSONHeads.CreateJSONArray;
                                                                                for iRow := 0 to mMonRows.Count - 1 do begin
                                                                                    mJSONRow:=TJSONSuperObject.Create;
                                                                                        mJSONRow.I['PosIndex']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex');
                                                                                        mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].OID;
                                                                                        //*****mJSONRow.S['Sklad']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code');
                                                                                        mJSONRow.S['Storecard_EAN']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN');
                                                                                        mJSONRow.S['Storecard_Name']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.Name');
                                                                                        mJSONRow.D['Quantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity');
                                                                                        mJSONRow.D['DeliveredQuantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('DeliveredQuantity');
                                                                                       //**** mJSONRow.S['DeliveryDate$DATE']:=FormatDateTime('YYYY-MM-DD',mMonRows.BusinessObject[i].GetFieldValueAsDateTime('DeliveryDate$DATE'));
                                                                                        mJSONRow.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                        mJSONRow.S['Store_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code') ;

                                                                                        if mImport then begin
                                                                                            mJSONRow.I['RowType']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('RowType');
                                                                                            mJSONRow.S['Text']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Text');
                                                                                            //**** mJSONRow.S['BusOrder_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID');
                                                                                            mJSONRow.S['BusOrder_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID.Code');
                                                                                           //**** mJSONRow.S['BusTransaction_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID');
                                                                                            mJSONRow.S['BusTransaction_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID.Code');
                                                                                            //**** mJSONRow.S['BusProject_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID');
                                                                                            mJSONRow.S['BusProject_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID.Code');
                                                                                            mJSONRow.S['X_Providerow_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID');
                                                                                            mJSONRow.S['X_specifikace_id']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_specifikace_id');
                                                                                            mJSONRow.S['X_ExternalSpecification']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_ExternalSpecification');


                                                                                        try
                                                                                        mStringReturn:='';
                                                                                        mStringReturn:=APICallRest(mBOHead,'POST',mTargetAPI,'/Script/','NxApiLib/Lib/APIStorecard_ID',mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN'),True);
                                                                                        if trim(mStringReturn)<>'' then begin
                                                                                                if mStringReturn<>mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID') then begin
                                                                                                        mJSONRow.S['Storecard_ID']:=mStringReturn;
                                                                                                end else begin
                                                                                                        mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                                                                end;
                                                                                        end else begin
                                                                                           mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')
                                                                                        end;
                                                                                         finally

                                                                                         end;
                                                                                        //NxShowSimpleMessage(mStringReturn,nil);









                                                                                         //   if mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')='~000000G01' then begin
                                                                                         //           mJSONRow.S['Storecard_ID']:='~S00000C02';
                                                                                         //   end else begin
                                                                                         //           mJSONRow.S['Storecard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                                                         //   end;















                                                                                            mJSONRow.S['Store_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID');
                                                                                            //**** mJSON.S['Division_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Division_ID.Code');
                                                                                            mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID');
                                                                                            //mJSON.S['Store_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code') ;
                                                                                            if uppercase(mJSON.S['WithPrices'])='TRUE' then begin
                                                                                                    // **     ceny      *****
                                                                                                    mprice:=0;
                                                                                                    mxa:=tstringlist.create;
                                                                                                       // z faktury
                                                                                                             try
                                                                                                                 if mDocumentType='21' then AContext.GetObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID where Providerow_ID =' + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID')),mxa);

                                                                                                                 if mxa.count>0 then begin
                                                                                                                      mprice:=NxIBStrToFloat(mxa.Strings[0]);
                                                                                                                 end else begin
                                                                                                                 end;
                                                                                                             finally
                                                                                                                 mxa.free;
                                                                                                             end;
                                                                                                       if mprice=0 then begin
                                                                                                             // z cenníku
                                                                                                                  mprice:=NxEvalObjectExprAsFloatDef(mBOHead,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                                                                  +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID'))+', '
                                                                                                                                  +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                                                                  +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                                                                  +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit'))+',False,'
                                                                                                                                  +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                                                                  +inttostr(trunc(Date))+')',0);
                                                                                                       end;
                                                                                                       if mprice<>0 then begin
                                                                                                                mJSONRow.S['UnitPrice']:=NxFloatToIBStr(mprice);
                                                                                                                mJSONRow.S['TotalPrice']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                                                                mJSONRow.S['Tamount']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                                                                //mJSONRow.S['Tamountwithoutvat']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                                                       end;
                                                                                            end;
                                                                                        end;
                                                                                            if ((mBOHead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mBOHead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                       //                                          mJSONRow.S['X_Storedocuments2_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Storedocuments2_ID');
                                                       //                                         // ****** šarže na skladových dokladech
                                                                                                 mMonBatches := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('DocRowBatches'));
                                                                                                          mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                              for iBatch := 0 to mMonBatches.Count - 1 do begin
                                                                                                                  mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                      mJSONBatch.S['Posindex']:=inttostr(mMonBatches.BusinessObject[iBatch].GetFieldValueAsInteger('Posindex'));
                                                                                                                      mJSONBatch.S['ID']:=mMonBatches.BusinessObject[iBatch].OID;
                                                                                                                      mJSONBatch.S['StoreBatch']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_id.Name');
                                                                                                                      mJSONBatch.D['Quantity']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsFloat('Quantity');
                                                                                                                      mJSONBatch.S['QUnit']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('QUnit');
                                                                                                                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                                              end;
                                                                                            end else begin
                                                                                                 // šarže z objednávek
                                                                                                         mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                              mBatchesList:=tstringlist.create;
                                                                                                              try
                                                                                                              // ro
                                                                                                              if (mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                                                                      AContext.SQLSelect('SELECT A.ID,B.Name,A.X_quantity FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                                                            + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)   ;
                                                                                                              end;
                                                                                                              // io
                                                                                                              if (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                                                                      AContext.SQLSelect('SELECT A.ID,B.Name,A.X_quantity FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                                                            + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)  ;
                                                                                                              end;
                                                                                                                      if mBatchesList.count>0 then begin
                                                                                                                              for iBatch := 0 to mBatchesList.Count - 1 do begin
                                                                                                                                  mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                                         mJSONBatch.S['Posindex']:=inttostr(iBatch+1);
                                                                                                                                         mBatchValue:=TStringList.create;
                                                                                                                                         mBatchValue:=fnParsevalue(mBatchesList.Strings[mIBatch],';');
                                                                                                                                         try
                                                                                                                                              if mBatchValue.count>0 then mJSONBatch.S['ID']:=mBatchValue.Strings[0];
                                                                                                                                              if mBatchValue.count>1 then mJSONBatch.S['StoreBatch']:=mBatchValue.Strings[1];
                                                                                                                                              if mBatchValue.count>2 then mJSONBatch.D['Quantity']:=NxIBStrToFloat(mBatchValue.Strings[2]);
                                                                                                                                              mJSONBatch.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                                                                         finally
                                                                                                                                             mBatchValue.free;
                                                                                                                                         end;
                                                                                                                                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                                                              end;
                                                                                                                      end;
                                                                                                              finally
                                                                                                                  mBatchesList.free;
                                                                                                              end;

                                                                                            end;




                                                                                        mJSONHeads.A['Rows'].Add(mJSONRow);
                                                                                end;
                                                                     //   mJSON.A['AbraDocuments'].Add(mJSONHeads);

                                         end;









                        finally
                            mr.free;
                        end;
                           mJSON.A['AbraDocuments'].Add(mJSONHeads);

        end;    // konec cyklu dokladu


       mStringList.free;

       mJSON.S['_Result_DocType']:=mResult_DocType;
       mJSON.S['_Result_DocQueue']:=mResult_DocQueue;
       mJSON.S['_Result_Documents']:=mResult_Documents;
       mJSON.I['_Result_PocetDokladu']:=mPocetDokladu;
       result:=mJSON;
end;






function POST_APINxJSONImportManager(AContext: TNxContext; InputString: String; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  iJSONDocuments,iJSONRows,iJSONBatches:integer;
  mQuery:string;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput,AOutput,mDocument:TJSONSuperObject;
  mInputDocuments:tstringlist;
  mFindDoc,mFindRow:boolean;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP,mOutputDocument,mBatch,mBO_PohybSarze : TNxCustomBusinessObject;
  mRows, mRows_OP,mRowsOutput,mMonBatches : TNxCustomBusinessMonikerCollection;
  mValidateList,mSelectedRows,mrx:tstringlist;
  mText,mSelectedHeader:string;
  mImportMan: TNxDocumentImportManager;
  mFind:boolean;
  mJSONDocuments,mJSONRows,mJSONBatches: TJSONSuperObjectArray;
  mJSONDocument,mJSONRow,mJSONBatch:TJSONSuperObject;
  mDocuments,mStoreDocQueue_ID:string;
  mImportdocuments,mImportRows,mImportBatches,mOtherRows,mOtherBatches,mNotSaveRows,mNotsaveBatches:TStringList;
  mStore_ID,mFirm_ID,mDivision_ID:string;
  mpomocpocet,mUseQuantity:double;
  mPomocSarze,mUseSarze:double;
  mpocet:double;
  mDocInputDocument:string;
  mDebug,mWithPrices:boolean;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mEmail,mMesager:string;
  mSales:boolean;
  mFile:string;
  mDocrowbatchList,mPrintList:TStringList;
  mPomocMnozstvi:double;
  mlist:tstringlist;
  mdescription:string;
  mOtherAbra:string;
  mAllDocument:Boolean;
  Result_String:string;
  mFirmOffice_ID:string;
  mImport,mOnlyImport:boolean;
  mID_Sarze:string;
  mParseValue:tstringlist;
  mTMPString,mxTarget:string;
  aname,blat_File,mxid:string;
  mDynCLSID:string;
begin

      AInput:=TJSONSuperObject.create;
      AInput:=TJSONSuperObject.ParseString(InputString,true);
      //ainput:=InputString;
      AOutput:=TJSONSuperObject.create;
      try
      mDebug:=False;
      mUser_ID:='';
      mMsgUser_ID:='';
      mDocInputDocument:='';

         mInputDocumentClsid:='';
         try
         mInputDocumentClsid:=AInput.S['InputClsid'];
         finally

         end;
         mOutputDocumentClsid:='';
         try
         mOutputDocumentClsid:=AInput.S['OutputClsid'];
         finally
         end;


         mr:=TStringList.create;
                try
                     if trim(AInput.A['AbraDocuments'].O[0].S['DocNumber'])<>'' then begin
                             case mOutputDocumentClsid of
                                  '01CPMINJW3DL342X01C0CX3FCC': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code ||'+QuotedStr('-')+ '|| CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Receivedorders A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]))
                                           ,mr);
                                       end;

                                  'CDMK5QAWZZDL342X01C0CX3FCC': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Issuedorders A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]))
                                           ,mr);
                                       end;

                                  'E03ZNUMDTCC4PDAUIEY1MBTJC0': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Storedocuments A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll])) + ' and A.DocumentType='+quotedstr('20')
                                           ,mr);
                                       end;

                                  '050I5SAOS3DL3ACU03KIU0CLP4': begin
                                  //         AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Storedocuments A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll])) + ' and A.DocumentType='+quotedstr('21')
                                  //         ,mr);
                                       end;


                                  '0P0I5SAOS3DL3ACU03KIU0CLP4': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Storedocuments A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll])) + ' and A.DocumentType='+quotedstr('22')
                                           ,mr);
                                       end;

                             end;
                      end;
                     if mr.count>0 then begin
                         AOutput.S['State']:= '200';
                         mTMPString:=mr.Strings[0];
                         mTMPString:=NxSearchReplace(mTMPString,'"','',[srCase,srAll]);
                         mParseValue:=tstringlist;
                         try
                            mParseValue:=FNParsevalue(mTMPString,';') ;
                            if mParseValue.count>2 then begin
                                 AOutput.S['Error']:= mParseValue.strings[1];
                                 AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mParseValue.strings[2];
                                   AOutput.S['ID']:=mParseValue.strings[3];
                                   AOutput.S['New']:=mParseValue.strings[0];;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(0) ;
                                   AOutput.S['Other']:=inttostr(0);
                                   AOutput.S['Imp_batch']:=inttostr(0);
                                   AOutput.S['Oth_batch']:=inttostr(0);
                                   AOutput.S['NotSave']:=inttostr(0) ;
                                   AOutput.S['NotSave_batch']:=inttostr(0);
                                   result:=AOutput.AsString;
                                   exit;
                            end;
                         finally
                             mParseValue.free;
                         end;

                     end;
                finally
                    mr.free;
                end;




            ;



         mAllDocument:=false;
         try
              if uppercase(AInput.S['ImportAllDocument'])='TRUE' then mAllDocument:=True else mAllDocument:=false;
         finally

         end;

         mDebug:=False;
         try
               if uppercase(AInput.S['Debug'])='TRUE' then mDebug:=True else mDebug:=false;
         finally
         end;

         mImport:=True;
         try
              if trim(uppercase(AInput.S['Import']))='TRUE' then mImport:=True else mImport:=false;
         finally

         end;

         mOnlyImport:=false;
         try
                if trim(uppercase(AInput.S['OnlyImport']))='TRUE' then mOnlyImport:=True else mOnlyImport:=false;
         finally
         end;

         mWithPrices:=True;
         try
                 if uppercase(AInput.S['WithPrices'])='TRUE' then mWithPrices:=True else mWithPrices:=false;
         finally

         end;





        mDocQueue_ID:='';
        if trim(AInput.S['DocQueue_Code'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['DocQueue_Code']) + ' and hidden=' + quotedstr('N') ,mr);
                     if mr.count>0 then begin
                         mDocQueue_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;

        mStoreDocQueue_ID:='';
        if trim(AInput.S['StoreDocQueue_code'])<>'' then begin
              mr:=TStringList.create;
              try
                   AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['StoreDocQueue_code']) + ' and hidden=' + quotedstr('N') ,mr);
                   if mr.count>0 then begin
                       mStoreDocQueue_ID:=mr.Strings[0];
                   end;
              finally
                  mr.free;
              end;
        end;

        mFirm_ID:='';
        if trim(AInput.S['Firm_Name'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from firms where name=' + quotedstr(AInput.S['Firm_Name']) + ' and hidden=' + quotedstr('N')
                                                     + ' and Firm_id is null',mr);
                     if mr.count>0 then begin
                         mFirm_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;




        mStore_ID:='';
        if trim(AInput.S['Store_Code'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from Stores where code=' + quotedstr(AInput.S['Store_Code']) + ' and hidden=' + quotedstr('N') ,mr);
                     if mr.count>0 then begin
                         mStore_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;


        mDivision_ID:='';
        if trim(AInput.S['Division_Code'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from Divisions where code=' + quotedstr(AInput.S['Division_Code']) + ' and hidden=' + quotedstr('N') ,mr);
                     if mr.count>0 then begin
                         mDivision_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;

        mUser_ID:='';
        if trim(AInput.S['User'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['User']) ,mr);
                     if mr.count>0 then begin
                         mUser_ID:=mr.Strings[0];
                       //  if mUser_ID='SUPER00000' then  mUser_ID:='';
                     end;
                finally
                    mr.free;
                end;
        end;




       mMsgUser:='';
       if trim(AInput.S['Msg'])<>'' then begin
              mr:=TStringList.create;
              try
                   AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['Msg']) ,mr);
                   if mr.count>0 then begin
                       mMsgUser_ID:=mr.Strings[0];
                   end;
              finally
                  mr.free;
              end;
        end;


  finally

  end;



  mImportdocuments:=TStringList.create;
  mImportRows:=TStringList.create;
  mOtherRows:=TStringList.create;
  mOtherBatches:=TStringList.create;
  mImportBatches:=TStringList.create;
  mSelectedRows:=TstringList.Create;
  mNotSaveRows:=TstringList.Create;
  mNotsaveBatches:=TstringList.Create;

  try



      if true then begin    //// AInput.A['AbraDocuments'].Length>0 then begin                // v poli jSON jsou uvedeny doklady

          for iJSONDocuments := 0 to AInput.A['AbraDocuments'].Length - 1 do begin  // cyklus dokladu
                      if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].Length>0 then begin
                             for iJSONRows := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].Length - 1 do begin  // cyklus řádku dokladu
                                mpomocpocet:=NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Quantity']);
                                mr:=tstringlist.create;
                                try
                                    if ((mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') and (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                            if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from ReceivedOrders where id is null',mr);
                                            end else begin
                                                  AContext.GetObjectSpace.SQLSelect('Select ro.id,ro2.id,ro2.Store_ID,ro2.Storecard_id,ro2.X_Providerow_ID,X_specifikace_id, X_ExternalSpecification , Division_ID, BusOrder_ID, Bustransaction_id,BusProject_ID, (ro2.quantity-ro2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 ro2 left join ReceivedOrders ro on ro.id=ro2.parent_id '
                                                                      + ' where ro2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'])
                                                                      + ' and ro2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])
                                                                      + ' and ro.Closed=' + quotedstr('N')
//                                                                      + ' and ro.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and ro2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                             end;
                                     end;
                                    // z op do ov
                                    if ((mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') and (mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                            if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from ReceivedOrders where id is null',mr);
                                            end else begin
                                                  AContext.GetObjectSpace.SQLSelect('Select ro.id,ro2.id,ro2.Store_ID,ro2.Storecard_id,ro2.X_Providerow_ID, ro2.X_specifikace_id, ro2.X_ExternalSpecification , ro2.Division_ID, ro2.BusOrder_ID, ro2.Bustransaction_id,ro2.BusProject_ID,(ro2.quantity-ro2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 ro2 left join ReceivedOrders ro on ro.id=ro2.parent_id '
                                                                      + ' where ro2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'])
                                                                      + ' and ro2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])
                                                                      + ' and ro.Closed=' + quotedstr('N')
//                                                                      + ' and ro.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and (not exists (select * from ReceivedOrdersToIssuedOrders Y where Y.Source_ID = ro2.ID) )'
                                                                      + ' and ro2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                             end;
                                     end;

                                     if mInputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin

                                                {if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'SQL' + ' : ' +'Select io.id,io2.id,io2.Store_ID,IO2.Storecard_id,io2.X_Providerow_ID,(io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and io2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                       + ' and io2.quantity>io2.DeliveredQuantity';  }

                                             if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                     AContext.GetObjectSpace.SQLSelect('Select id from Issuedorders where id is null',mr);
                                             end else begin

                                                     AContext.GetObjectSpace.SQLSelect('Select io.id,io2.id,io2.Store_ID,IO2.Storecard_id,io2.X_Providerow_ID, io2.X_specifikace_id, io2.X_ExternalSpecification , io2.Division_ID, io2.BusOrder_ID, io2.Bustransaction_id,io2.BusProject_ID, (io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'])
                                                                      + ' and io2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and io2.quantity>io2.DeliveredQuantity'

                                                                       ,mr);
                                              end;
                                     end;


                                     if ((mInputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') and (mInputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                               if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from StoreDocuments where id is null',mr);
                                               end else begin
                                                        if AInput.S['DocumentType']='' then
                                                              AContext.GetObjectSpace.SQLSelect('Select sd.id,sd2.id,sd2.Store_ID,sd2.Storecard_id,sd2.X_Providerow_ID, sd2.X_specifikace_id, sd2.X_ExternalSpecification , sd2.Division_ID, sd2.BusOrder_ID, sd2.Bustransaction_id,sd2.BusProject_ID,(sd2.quantity-sd2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from StoreDocuments2 io2 left join StoreDocuments IO on sd.id=sd.parent_id '
                                                                      + ' where sd2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'])
                                                                      + ' and sd2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])
                                                                      + ' and sd.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and sd2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                                       if AInput.S['DocumentType']<>'' then
                                                              AContext.GetObjectSpace.SQLSelect('Select sd.id,sd2.id,sd2.Store_ID,sd2.Storecard_id,sd2.X_Providerow_ID,sd2.X_specifikace_id, sd2.X_ExternalSpecification , sd2.Division_ID, sd2.BusOrder_ID, sd2.Bustransaction_id,sd2.BusProject_ID,(sd2.quantity-sd2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from StoreDocuments2 io2 left join StoreDocuments IO on sd.id=sd.parent_id '
                                                                      + ' where sd2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'])
                                                                      + ' and sd2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])
                                                                      + ' and sd.Closed=' + quotedstr('N')
                                                                      + ' and sd.DocumentType=' + quotedstr(AInput.S['DocumentType'])
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and sd2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                               end;
                                      end;

                                   //  if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'Nalezeno' + ' : ' +inttostr(mr.count);

                                    if mr.count> 0 then begin
                                         for mri:=0 to mr.count-1 do begin
                                             mParseValue:=tstringlist.create;
                                             try
                                             mParseValue:=FNParsevalue(mr.Strings[mri],';');
                                                 if mpomocpocet>0 then begin
                                                           //if mpomocpocet>=NxIBStrToFloat(copy(mr.Strings[mri],56,10))  then begin
                                                           if false then begin // mpomocpocet>=NxIBStrToFloat(mParseValue.Strings[11])  then begin
                                                                          mUseQuantity:=0;
                                                                         // mUseQuantity:=NxIBStrToFloat(copy(mr.Strings[mri],56,10));
                                                                          mUseQuantity:=NxIBStrToFloat(mParseValue.Strings[11]);
                                                                          mImportRows.add(mParseValue.Strings[0]
                                                                                         +';' + mParseValue.Strings[1]
                                                                                         +';' + mParseValue.Strings[2]
                                                                                         +';' + mParseValue.Strings[3]
                                                                                         +';' + mParseValue.Strings[4]
                                                                                         +';' + mParseValue.Strings[5]
                                                                                         +';' + mParseValue.Strings[6]
                                                                                         +';' + mParseValue.Strings[7]
                                                                                         +';' + mParseValue.Strings[8]
                                                                                         +';' + mParseValue.Strings[9]
                                                                                         +';' + mParseValue.Strings[10]
                                                                                         +';' + NxFloatToIBStr(mUseQuantity)
                                                                                         +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );

                                                                          mpomocpocet:=mpomocpocet-mUseQuantity;
                                                           end else begin
                                                                          mUseQuantity:=0;
                                                                          mUseQuantity:=mPomocPocet;
                                                                          mImportRows.add(mParseValue.Strings[0]
                                                                                         +';' + mParseValue.Strings[1]
                                                                                         +';' + mParseValue.Strings[2]
                                                                                         +';' + mParseValue.Strings[3]
                                                                                         +';' + mParseValue.Strings[4]
                                                                                         +';' + mParseValue.Strings[5]
                                                                                         +';' + mParseValue.Strings[6]
                                                                                         +';' + mParseValue.Strings[7]
                                                                                         +';' + mParseValue.Strings[8]
                                                                                         +';' + mParseValue.Strings[9]
                                                                                         +';' + mParseValue.Strings[10]
                                                                                         +';' + (NxFloatToIBStr(mpomocpocet))
                                                                                         +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );
                                                                          mpomocpocet:=mpomocpocet-mpomocpocet;
                                                           end;

                                                       try
                                                       if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                                       //   if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'Počet' + ' : ' +NxFloatToIBStr(mUseQuantity);

                                                           if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                               for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                  mPomocSarze:=NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity']);
                                                                   //if mdebug then Result_string:=Result_string+ chr(10) + 'Šarže.' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name'] + ', Množství:' +  mJSONBatch.S['Quantity'];
                                                                  mrx:=tstringlist.create;
                                                                  try
                                                                       //if mdebug then Result_string:=Result_string + chr(10) +  'Select id from StoreBatches where Name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']) + ' and Storecard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']) + ' and hidden=' + quotedstr('N');
                                                                       AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']) + ' and Storecard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']) + ' and hidden=' + quotedstr('N'),mrx);
                                                                       if mrx.count> 0 then begin

                                                                          if mUseQuantity>=mPomocSarze then begin
                                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']>0 then begin
                                                                                     mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('00000000000000000000' +NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice']/ AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                              end else begin
                                                                                     mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('00000000000000000000' +NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                              end;
                                                                             //if mdebug then Result_string:=Result_string + chr(10) +  ' rows sarze' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('0000000000' +NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                          end else begin
                                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']>0 then begin
                                                                                   mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                              end else begin
                                                                                   mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                              end;
                                                                             // if mdebug then Result_string:=Result_string + chr(10) +  ' import rows sarze' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('0000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                          end;


                                                                           //if mdebug then Result_string:=Result_string+ chr(10) +  'import Podklad batches ' + ' : ' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+NxFloatToIBStr(mPomocSarze) + ';'

                                                                       end else begin
                                                                          // *** založení šarže *******

                                                                          mBatch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                         try
                                                                                               mID_Sarze:='';
                                                                                               mBatch.new;
                                                                                               mBatch.Prefill;
                                                                                               mBatch.SetFieldValueAsString('StoreCard_ID',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']);
                                                                                               mBatch.SetFieldValueAsString('X_parent_ID',mBatch.getFieldValueAsString('StoreCard_ID.X_parent_ID'));
                                                                                               mBatch.SetFieldValueAsString('Name',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']);
                                                                                               mBatch.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                                                               mBatch.Save;
                                                                                               mID_Sarze:=mBatch.oid;
                                                                                         finally
                                                                                              mBatch.free;
                                                                                         end;
                                                                                 mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']  + ';' + mID_Sarze +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                          //  if mdebug then Result_string:=Result_string + chr(10) + 'import Založit šarži.' +';'+mJSONBatch.S['Name'] + ', Množství:' +  AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'];
                                                                       end;

                                                                  finally
                                                                      mrx.free;
                                                                  end;
                                                               end;
                                                          end;
                                                          end ;
                                                          finally
                                                          end;
                                                  end;
                                            finally
                                                mParseValue.free;
                                            end;
                                         end;
                                         if (mpomocpocet>0)  then begin                          // není možné čerpat
                                                if mOnlyImport then begin
                                                     mNotSaveRows.add('0000000000' + ';'                  // doklad
                                                                    //+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['id']+ ';'
                                                                    +'0000000000' + ';'
                                                                    +mStore_ID+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID']+ ';'

                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_specifikace_id']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ExternalSpecification']+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusOrder_ID_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Bustransaction_id_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusProject_ID_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Quantity']
                                                                    +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );


                                                                    if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                                                   for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                                                    mNotsaveBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                                   end;
                                                                    end;
                                                end else begin

                                                     mOtherRows.add('0000000000' + ';'                  // doklad
                                                        +'0000000000' + ';'
                                                        + mstore_ID + ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';'                //io2.X_ProvideRow_ID
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_specifikace_id']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ExternalSpecification']+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusOrder_ID_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Bustransaction_id_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusProject_ID_Code']+ ';'
                                                        +NxFloatToIBStr(mpomocpocet)
                                                        +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );

                                                        //********

                                                           //if mdebug then Result_string:=Result_string  + chr(10) + ' other rows dohledáno provide_ID' + ('0000000000' + ';' +'0000000000' + ';' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Store_ID']
                                                           //+';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+';'+ AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID']+ ';' + NxFloatToIBStr(mpomocpocet)) ;

                                                        try
                                                        if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                                   for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                      mrx:=tstringlist.create;
                                                                      try
                                                                           AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']) + ' and Storecard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'])+ ' and hidden=' + quotedstr('N'),mrx);
                                                                           if mrx.count> 0 then begin
                                                                                if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']>0 then begin
                                                                                     mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10));
                                                                                 end else begin
                                                                                     mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10));
                                                                                 end;
                                                                             //   if mdebug then Result_string:=Result_string  + chr(10) + ' other rows sarze' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('0000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10));
                                                                           end else begin
                                                                               // *** založení šarže *******
                                                                                       mBatch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                               try
                                                                                                     mID_Sarze:='';
                                                                                                     mBatch.new;
                                                                                                     mBatch.Prefill;
                                                                                                     mBatch.SetFieldValueAsString('StoreCard_ID',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']);
                                                                                                     mBatch.SetFieldValueAsString('X_parent_ID',mBatch.getFieldValueAsString('StoreCard_ID.X_parent_ID'));
                                                                                                     mBatch.SetFieldValueAsString('Name',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']);
                                                                                                     mBatch.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                                                                     mBatch.Save;
                                                                                                     mID_Sarze:=mBatch.oid;
                                                                                               finally
                                                                                                    mBatch.free;
                                                                                               end;
                                                                                       mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mID_Sarze +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10));
                                                                            //    if mdebug then Result_string:=Result_string + chr(10) + 'other Založit šarži.' +';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name'] + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'];
                                                                           end;

                                                                      finally
                                                                          mrx.free;
                                                                      end;
                                                                      AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].free;

                                                                   end;
                                                              end;
                                                          end;
                                                        finally

                                                        end;
                                              end;
                                         end;
                                    end else begin
                                      if mOnlyImport then begin
                                         mNotSaveRows.add('0000000000' + ';'                  // doklad
                                                        //+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['id']+ ';'
                                                        +'0000000000' + ';'
                                                        +mStore_ID+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_specifikace_id']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ExternalSpecification']+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusOrder_ID_code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Bustransaction_id_code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusProject_ID_code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Quantity']
                                                                    +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );

                                                        try

                                                        if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                                             for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                                              mNotsaveBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                             end;
                                                              end;
                                                        end;
                                                        finally

                                                        end;
                                      end else begin
                                         mOtherRows.add('0000000000' + ';'                  // doklad
                                                        //+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['id']+ ';'
                                                        +'0000000000' + ';'
                                                        +mStore_ID+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_specifikace_id']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ExternalSpecification']+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusOrder_ID_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Bustransaction_id_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusProject_ID']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Quantity']
                                                                     +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID']));



                                                       // if mdebug then Result_string:=Result_string  + chr(10) + ' other rows nedohledáno provide_ID' + ('0000000000' + ';' +'0000000000' + ';' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Store_ID']
                                                       //    +';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+';'+ AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID']+ ';' + NxFloatToIBStr(mpomocpocet)) ;

                                        try
                                        if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                   for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                      mrx:=tstringlist.create;
                                                      try
                                                           AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']) + ' and Storecard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']),mrx);
                                                           if mrx.count> 0 then begin
                                                                if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']>0 then begin
                                                                    mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                end else begin
                                                                    mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                                end;
                                                                //if mdebug then Result_string:=Result_string + chr(10) + ' bez importu rows sarze' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('0000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10 ));
                                                           end else begin
                                                                // *** založení šarže *******
                                                                mBatch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                               try
                                                                                                     mID_Sarze:='';
                                                                                                     mBatch.new;
                                                                                                     mBatch.Prefill;
                                                                                                     mBatch.SetFieldValueAsString('StoreCard_ID',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']);
                                                                                                     mBatch.SetFieldValueAsString('X_parent_ID',mBatch.getFieldValueAsString('StoreCard_ID.X_parent_ID'));
                                                                                                     mBatch.SetFieldValueAsString('Name',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name']);
                                                                                                     mBatch.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                                                                     mBatch.Save;
                                                                                                     mID_Sarze:=mBatch.oid;
                                                                                               finally
                                                                                                    mBatch.free;
                                                                                               end;

                                                                mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID'] + ';' + mID_Sarze +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['Quantity']),10));

                                                                //if mdebug then Result_string:=Result_string + chr(10) + 'bez importu Založit šarži.' +';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name'] + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Quantity'];
                                                           end;

                                                      finally
                                                          mrx.free;
                                                      end;


                                                   end;
                                              end;
                                          end;
                                        finally

                                        end;
                                      end;
                                    end;
                                finally
                                    mr.free;
                                end;





                             end;
                      end;
          end;
      end;

        {
       mImportdocuments:=TstringList.Create;
              try
                 if AInput.A['InputDocuments'].Length>0 then begin
                  for i := 0 to AInput.A['InputDocuments'].Length - 1 do begin
                         mImportdocuments.Add(AInput.A['InputDocuments'].S[i]);
                  end;
                 end;
              finally
              end;

               mSelectedHeader:=AInput.S['SelectedHeader'];
               }

              try
                  if mImportRows.count>0 then begin
                      for i:=0 to mImportRows.count-1 do begin

                          mfind:=false;   // dohledání Dokladu
                          for x:=0 to mImportdocuments.count-1 do begin
                              if  mImportdocuments.Strings[x]=copy(mImportRows.Strings[i],1,10) then mfind:=true;
                          end;
                          if not mFind then mImportdocuments.add(copy(mImportRows.Strings[i],1,10)) ;


                          mfind:=false;   // dohledání řádku
                          for x:=0 to mSelectedRows.count-1 do begin
                              if  mSelectedRows.Strings[x]=copy(mImportRows.Strings[i],12,10) then mfind:=true;
                          end;
                          if not mFind then mSelectedRows.add(copy(mImportRows.Strings[i],12,10));
                      end;
                  end;
              finally

              end;




if mImportRows.count>0 then begin
  mImportMan := NxCreateDocumentImportManager(AContext.GetObjectSpace, mInputDocumentClsid, mOutputDocumentClsid);
  mParams := TNxParameters.Create();
end;

             if mImportdocuments.count>0 then begin     // import dokladu
                                      try
                                         if mImportdocuments.count>0 then begin
                                            for i:=0 to mImportdocuments.count-1 do begin
                                                mImportMan.AddInputDocument(mImportdocuments.Strings[i]);
                                                mDocInputDocument:=mDocInputDocument + mImportMan.InputDocuments[i].DisplayName;
                                                if i<>mImportdocuments.count-1 then mDocInputDocument:=mDocInputDocument + ', ' ;
                                            end;
                                          end;

                                         if trim(mSelectedHeader)='' then begin
                                             if mInputDocuments.count>1 then mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := mImportdocuments.Strings[0];
                                         end else begin
                                             mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := AInput.S['SelectedHeader'];
                                         end;

                                         if mDocQueue_ID<>'' then mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;

                                         if not mAllDocument then begin
                                                if mSelectedRows.count>0 then mParams.GetOrCreateParam(dtString, 'SelectedRows').AsString := mSelectedRows.Text;
                                                AOutput.S['Debug_text']:=inttostr(mSelectedRows.count);
                                         end;

                                    //      mParams.GetOrCreateParam(dtBoolean, 'ImportBatches').AsBoolean := True;

                                    if mSelectedRows.count>0 then begin
                                         try
                                         mImportMan.LoadParams(mParams);
                                         mImportMan.Execute;

                                         mOutputDocument:=mImportMan.OutputDocument;
                                         mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocDate']));
                                         if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                              mOutputDocument.setfieldvalueasstring('X_ExternalDocument',mJSONDocument.S['DocNumber']);
                                         end;
                                          mOutputDocument.setfieldvalueasstring('X_Identifikace',AInput.A['AbraDocuments'].O[iJSONDocuments].S['Identifikace']);
                                          if mFirm_ID<>'' then begin
                                               mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                                          end else begin
                                               mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                               mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                          end;
                                          if mAllDocument then begin
                                            if  mOutputDocumentClsid='050I5SAOS3DL3ACU03KIU0CLP4' then begin         // dodací list
                                                 mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                 mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                            end;
                                          end;
                                          if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                          end;


                                         mOutputDocument.SetFieldValueAsString('Description',copy((mImportMan.InputDocuments[0].GetFieldValueAsString('Description') ),1,50));

                                         if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                              mOutputDocument.SetFieldValueAsString('U_popis', mImportMan.InputDocument.GetFieldValueAsString('Description'));

                                         if (mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') or (mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                              if (trim(mOutputDocument.getfieldvalueasstring('ExternalNumber'))='') and (AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber']<>'') then begin
                                                   mOutputDocument.setfieldvalueasstring('ExternalNumber',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                              end;
                                              if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                   mOutputDocument.setfieldvalueasstring('X_ExternalDocument',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                              end;
                                          end;

                                         except
                                               mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                                mOutputDocument.new;
                                                mOutputDocument.prefill;
                                                mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                                mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocDate']));


                                                mOutputDocument.setFieldValueAsInteger('Tradetype',StrToInt(AInput.A['AbraDocuments'].O[iJSONDocuments].S['TradeType']));
                                                if mOutputDocument.GetFieldValueAsInteger('Tradetype')=2 then begin
                                                    mOutputDocument.setfieldvalueasstring('Country_ID','00000SK000');
                                                end;

                                                if mFirm_ID<>'' then mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);

                                                if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                end;


                                                if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                      mOutputDocument.setfieldvalueasstring('X_ExternalDocument',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));

                                                end;
                                                try
                                                 if mOutputDocument.getfieldvalueasstring('ExternalNumber')='' then begin
                                                      mOutputDocument.setfieldvalueasstring('ExternalNumber',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                end;
                                                finally

                                                end;

                                                    mOutputDocument.SetFieldValueAsString('Description',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));
                                                    mOutputDocument.SetFieldValueAsString('X_Identifikace',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['X_Identifikace'],'_','/',[srCase,srAll]));

                                                    if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                              mOutputDocument.SetFieldValueAsString('U_popis',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));


                                         end;
                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                              if mStore_ID='' then mStore_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Store_ID');
                                              if mDivision_ID='' then mDivision_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Division_ID');
                                              if ((mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' ))  then begin // op
                                                  // smazat původní pohyby šarží
                                                  mi:=AContext.GetObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' and code='+quotedstr(mOutputDocument.oid));
                                              end;

                                              if ((mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' ))  then begin  // ov
                                                  // smazat původní pohyby šarží
                                                   mi:=AContext.GetObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') + ' and code='+quotedstr(mOutputDocument.oid));
                                              end;

                                              if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC' ) and  (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC' )) then begin  // sd
                                                    // smazat původní pohyby šarží
                                                     //// ****chybný počet na šaržích ******
                                                   mRowsOutput.BusinessObject[mIRows].SetFieldValueAsFloat('Quantity',0);

                                                    mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                                    if mMonBatches.count>0 then begin
                                                          for mIBatchs := 0 to mMonBatches.Count - 1 do begin
                                                              mMonBatches.BusinessObject[mIBatchs].MarkForDelete;
                                                               // ***** chybný počet na šaržích    ****
                                                              mMonBatches.BusinessObject[mIBatchs].SetFieldValueAsFloat('Quantity',0);

                                                          end;
                                                    end;
                                              end;
                                                  // odmazání neimportovaných řádků . xxxxxxx
                                              if not mAllDocument then begin
                                                      mfind:=false;   // dohledání řádku
                                                  for i:=0 to mImportRows.count-1 do begin
                                                             if (mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_providerow_ID')=copy(mImportRows.strings[i],45,10))  and (not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_providerow_ID'))) then begin
                                                                  mfind:=true;
                                                             end;
                                                  end;
                                                  if not mFind then mRowsOutput.BusinessObject[mIRows].MarkForDelete;
                                              End;
                                         end;



                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                                for i:=0 to mImportRows.count-1 do begin
                                                      mParseValue:=tstringlist.create;
                                                      try
                                                      mParseValue:=FNParsevalue(mImportRows.strings[i],';');
                                                            if (mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_providerow_ID')=mParseValue.strings[4]) and (not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_providerow_ID'))) then begin
                                                                   if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'Počet' + ' : ' + (copy(mImportRows.strings[i],56,10));
                                                                   //mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportRows.strings[i],56,10)));
                                                                   mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mParseValue.strings[11]));
                                                                   if ((mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC') and (mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments
                                                                        mRowsOutput.BusinessObject[mIRows].setFieldValueAsstring('X_StoreDocuments2_ID',mParseValue.strings[12]);
                                                                   end;

                                                                  // if mdebug then Result_string:=Result_string + chr(10) +'  Množství zadávané  na řádku importem  :' + IntToStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsinteger('Posindex')) + ' / ' + NxFloatToIBStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsfloat('Quantity'));
                                                                     // if mDebug then  Result_string:=  Result_string + copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);

                                                                          if (UpperCase(AInput.S['ImportBatches'])='TRUE') and (mImportBatches.count>0) then begin
                                                                          if mRowsOutput.BusinessObject[mIRows].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                 // op
                                                                                      mPomocMnozstvi:=0;
                                                                                      for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                            if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') then begin
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],24,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            mBO_PohybSarze.save;
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                            end;
                                                                                      end;
                                                                                      if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                      if mdebug then Result_string:=Result_string + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                 //      ov
                                                                                   mPomocMnozstvi:=0;
                                                                                   for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                        if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') then begin
                                                                                              mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:= mPomocMnozstvi + NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            mBO_PohybSarze.save
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                        end;
                                                                                  end;
                                                                                   if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi);
                                                                                 //  if mdebug then Result_string:=Result_string + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;

                                                                                 if ((mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC') and (mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments

                                                                                      mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));

                                                                                          mPomocMnozstvi:=0;
                                                                                          for mIBatchs := 0 to mImportBatches.Count - 1 do begin

                                                                                               if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') then begin
                                                                                                   //Result_string:= Result_string +  copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                   mPomocMnozstvi:=mPomocMnozstvi +NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                   mBatch.SetFieldValueAsString('Qunit',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsstring('Qunit'));

                                                                                                  if mWithPrices then begin
                                                                                                     if mdebug then Result_string:=Result_string + '  Unitprice :' + (copy(mImportBatches.Strings[mIBatchs],46,10));
                                                                                                     if mdebug then Result_string:=Result_string + '  X_quantity' + (copy(mImportBatches.Strings[mIBatchs],34,10)) + chr(10);
                                                                                                  end;

                                                                                               end;

                                                                                          end;
                                                                                          if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi);
                                                                                           if mdebug then Result_string:=Result_string + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;
                                                                           end;
                                                                          end;
                                                            end;
                                                      finally
                                                           mParseValue.free;
                                                      end;

                                                end;
                                         end;
                                     end;
                                   finally
                                       //mParams.free;
                                      // mImportMan.free;
                                   end;



             end else begin
                                mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                mOutputDocument.new;
                                mOutputDocument.prefill;
                                mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                mOutputDocument.setFieldValueAsInteger('Tradetype',StrToInt(AInput.A['AbraDocuments'].O[iJSONDocuments].S['TradeType']));
                                                if mOutputDocument.GetFieldValueAsInteger('Tradetype')=2 then begin
                                                    mOutputDocument.setfieldvalueasstring('Country_ID','00000SK000');
                                                end;






                                if mFirm_ID<>'' then  mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);
                                 try
                                      mOutputDocument.setfieldvalueasstring('X_Identifikace',AInput.A['AbraDocuments'].O[iJSONDocuments].S['Identifikace']);
                                 finally
                                 end;

                                 mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocDate']));
                                                if mFirm_ID<>'' then mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);

                                                if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                end;


                                                if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                      mOutputDocument.setfieldvalueasstring('X_ExternalDocument',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));

                                                end;
                                                try
                                                 if ((mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC') or (mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments
                                                     if mOutputDocument.getfieldvalueasstring('ExternalNumber')='' then begin
                                                          mOutputDocument.setfieldvalueasstring('ExternalNumber',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                     end;
                                                end;
                                                finally

                                                end;

                                                    mOutputDocument.SetFieldValueAsString('Description',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));

                                               mOutputDocument.SetFieldValueAsString('X_ExternalDocument', NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));


                                                    if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                              mOutputDocument.SetFieldValueAsString('U_popis',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));





                                mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
           end;


           if mdebug then begin
               Result_string:=Result_string +  'Externí číslo: ' + AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'] + chr(10);
               Result_string:=Result_string +  'Řada dokladu: ' + mOutputDocument.GetFieldValueAsString('Docqueue_ID.CODE') + chr(10);
               Result_string:=Result_string +  'Firma: ' + mOutputDocument.GetFieldValueAsString('Firm_ID.Name') + chr(10);


           end;


           if mOtherRows.count>0 then begin
                for i:=0 to mOtherRows.count-1 do begin
                     mParseValue:=tstringlist.create;
                     try
                     mParseValue:=FNParsevalue(mOtherRows.strings[i],';');
                            mRow := mRowsOutput.AddNewObject;
                            mrow.Prefill;
                            if mOutputDocumentClsid<>'E03ZNUMDTCC4PDAUIEY1MBTJC0' then mrow.SetFieldValueAsInteger('Rowtype',3);
                            mrow.SetFieldValueAsString('Store_ID',mstore_ID);
                            mrow.SetFieldValueAsString('StoreCard_ID',mParseValue.strings[3]);

                            mrow.SetFieldValueAsString('X_Providerow_ID',mParseValue.strings[4]);
                            mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mParseValue.strings[11]));
                            mrow.Prefill;
                            mrow.SetFieldValueAsString('X_specifikace_id',mParseValue.strings[5]);
                            mrow.SetFieldValueAsString('X_ExternalSpecification',mParseValue.strings[6]);

                            //if mdebug then Result_string:=Result_string + chr(10) +'  Množství zadávané  na řádku  :' + IntToStr(mrow.getFieldValueAsinteger('Posindex')) + ' / ' + NxFloatToIBStr(mrow.getFieldValueAsfloat('Quantity'));
                            //mrow.SetFieldValueAsString('Qunit',mrow.GetFieldValueAsString('Storecard_ID.MainUnitCode'));
                            mrow.SetFieldValueAsString('Qunit','ks');
                            mrow.SetFieldValueAsString('Division_ID',mDivision_ID);
                            if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mrow.setFieldValueAsstring('X_StoreDocuments2_ID',mParseValue.strings[12]);
                            end;

                           // if mdebug then  Result_string:=Result_string + chr(10) + chr(13) + ' Otherrows vkládání do dokladu podklad  ' +(mOtherRows.strings[i]);


                          //if mdebug then  Result_string:=Result_string + '"other rows vkládání do dokladu parseRows " +"'             + mstore_ID + ', ' + copy(mOtherRows.strings[i],34,10) + ', ' + (copy(mOtherRows.strings[i],56,10))  +'"' + chr(10);







                            try           // šarže
                            if (UpperCase(AInput.S['ImportBatches'])='TRUE') and (mOtherBatches.count>0) then begin
                            if mrow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                      mPomocMnozstvi:=0;
                                                                                      for mIBatchs := 0 to mOtherBatches.Count - 1 do begin

                                                                                                 if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin
                                                                                                              //
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mrow.GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            if mdebug then Result_string:=Result_string + ' Šarže' + copy(mOtherBatches.Strings[mIBatchs],23,10)+ chr(10) + 'unitprice :  ' +  (copy(mOtherBatches.Strings[mIBatchs],46,10)) + ' quantity: ' + copy(mOtherBatches.Strings[mIBatchs],46,10);

                                                                                                            if not mdebug then mBO_PohybSarze.save;


                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                                end;
                                                                                      end;
                                                                                      if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                        mPomocMnozstvi:=0;
                                                                                        for mIBatchs := 0 to mOtherBatches.Count - 1 do begin
                                                                                                // if mdebug then Result_string:=Result_string + ' Šarže' + mOtherBatches.Strings[mIBatchs] + chr(10);
                                                                                                 if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin

                                                                                                      mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mrow.GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            if not mdebug then mBO_PohybSarze.save;

                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                                end;
                                                                                        end;
                                                                                        if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;



                                                                                 if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mrow.setFieldValueAsstring('X_StoreDocuments2_ID',mParseValue.strings[12]);
                                                                                      mMonBatches :=  mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                                                         mPomocMnozstvi:=0;
                                                                                          for mIBatchs := 0 to mOtherBatches.Count - 1 do begin


                                                                                               if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                   //AOutput.S['batch']:=mOtherBatches.Strings[mIBatchs];
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                   mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
//                                                                                                          mBatch.SetFieldValueAsString('Qunit',mRow.GetFieldValueAsString('Storecard_ID.MainUnitCode'));
                                                                                                          mBatch.SetFieldValueAsString('Qunit','ks');

                                                                                               end;

                                                                                          end;
                                                                                          if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;
                                                                           end;
                                                                           end;
                              finally

                            end;  // šarže
                     finally
                           mParseValue.free;
                     end;
                end;        // endfor
           end;   //endif

                mOutputDocument.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                if mFirm_ID<>'' then begin
                     mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                end else begin
                  if mImportRows.count>0 then begin
                     mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                     mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                  end;

                end;
                if mAllDocument then begin

                                            if  mOutputDocumentClsid='050I5SAOS3DL3ACU03KIU0CLP4' then begin
                                                 if mOtherRows.count=0 then begin
                                                      mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                      mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                                      if not nxisemptyoid(mImportMan.InputDocuments[0].GetFieldValueAsString('X_Delivery_adress_id')) then
                                                           mOutputDocument.setfieldvalueasstring('X_Delivery_adress_id',mImportMan.InputDocuments[0].GetFieldValueAsString('X_Delivery_adress_id'));
                                                      mOutputDocument.setfieldvalueasstring('TransportationType_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('TransportationType_ID'));


                                                 end;
                                            end;
                end;


               // mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                if mUser_ID<>'' then mOutputDocument.SetFieldValueAsString('CreatedBy_ID',mUser_ID);


                mOutputDocument.SetFieldValueAsString('X_ExternalDocument', NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                if mOutputDocument.GetFieldValueAsString('Firm_ID.Name')='LIPOELASTIC a.s.' then begin
                        mOutputDocument.setFieldValueAsInteger('Tradetype',2) ;
                        mOutputDocument.setFieldValueAsString('Country_ID','00000CZ000');
                end;
                if mOutputDocument.GetFieldValueAsString('Firm_ID.Name')='LIPOELASTIC s.r.o.' then begin
                        mOutputDocument.setFieldValueAsInteger('Tradetype',2) ;
                        mOutputDocument.setFieldValueAsString('Country_ID','00000SK000');
                end;







      if not mdebug then begin
            if true then begin
            //if mRowsOutput.Count>0 then begin
                 if mWithPrices then begin
                 //****kontrola cen
                     mxTarget:='';
                     if NxIsEmptyOID(mOutputDocument.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + mOutputDocument.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                       end else begin
                                                                mxTarget:=mOutputDocument.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                         end;

                                 for mIRows := 0 to mRowsOutput.Count - 1 do begin
                                     if not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID')) then begin
                                                  mQuery:='{' + chr(10);
                                                        mQuery:=mQuery + '"X_Providerow_ID":"' + mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') + '",' +chr(10);
                                                        mQuery:=mQuery + '"Storecard_ID":"' + mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('StoreCard_ID') + '",' +chr(10);
                                                        mQuery:=mQuery + '"Firm_Name":"' + mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Parent_id.Firm_id.Name') + '",' +chr(10);
                                                        //mQuery:=mQuery + '"X_Storedocument_ID":"' + '' + '",' +chr(10);

                                                  mQuery:=mQuery + '}' + chr(10);
                                                  mString:=APICallString(AContext.GetObjectSpace,'POST',mxtarget+'/script/NxApiLib/lib/APINxStorePrice',mQuery, true);
                                                  if NxIBStrToFloat(mstring)<>0 then begin
                                                     if NxIBStrToFloat(mstring)<>mRowsOutput.BusinessObject[mIRows].GetFieldValueAsFloat('Unitprice') then begin
                                                           // mXresult:=mXresult +  mCustomBusinessObject.displayname + ' - ' + mRowsOutput.BusinessObject[i].GetFieldValueAsString('Storecard_id.Displayname') + ' z ' + NxFloatToIBStr(mRowsOutput.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) + ' na ' + mString +chr(10) +chr(13);
                                                            mRowsOutput.BusinessObject[mIRows].SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mstring));
                                                            //NxShowSimpleMessage('Změna ceny pro ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) +' na ' + NxFloatToIBStr(NxIBStrToFloat(mstring)) ,nil);
                                                     end;
                                                  end;
                                      end;
                                  end;
                 end;

                 mOutputDocument.ClearValidateErrors;
                  if Not mOutputDocument.Validate() then begin
                     mList := TStringList.Create;
                      try
                        mOutputDocument.GetValidateErrors(mList);
                        mText := mList.Text;
                        NxToken(mText, '=');
                                   AOutput.S['State']:='400';
                                   AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mUser_ID;
                                   AOutput.S['ID']:='';
                                   AOutput.S['New']:='';
                                   AOutput.S['Error']:= mText ;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(mImportRows.count) ;
                                   AOutput.S['Other']:=inttostr(mOtherRows.count);
                                   AOutput.S['Imp_batch']:=inttostr(mImportBatches.count);
                                   AOutput.S['Oth_batch']:=inttostr(mOtherBatches.count);
                                   AOutput.S['NotSave']:=inttostr(mNotSaveRows.count) ;
                                   AOutput.S['NotSave_batch']:=inttostr(mNotsaveBatches.count);


                                  { Result_string:='{';
                                            Result_string:=Result_string + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result_string:=Result_string + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);

                                              Result_string:=Result_string + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result_string:=Result_string + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '",' + chr(10) ;
                                              Result_string:=Result_string + '"ERROR" :"' + mText+ '",' + chr(10) ;
                                              Result_string:=Result_string + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;

                                            Result_string:=Result_string + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                                        Result_string:=Result_string + '}
                      finally
                        mList.Free;
                      end;


                  end else begin
                      mOutputDocument.Save ;

            //     Result_string:=mOutputDocument.oid  +';'+ mOutputDocument.DisplayName   ;


                           if not NxIsBlank(AInput.S['Msg']) then begin
                                      iSendmsg(AContext.GetObjectSpace, mOutputDocument , mOutputDocumentClsid,
                                                                      mOutputDocument.DisplayName  + '-  byl vytvořen novy doklad ',     // popis
                                                                      ' Byl vytvořen novy doklad s číslem: ' + mOutputDocument.DisplayName ,                          // tělo
                                                                      mMsgUser_ID ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
                           end;


                           if not NxIsBlank(AInput.S['Email']) then begin
                                if not NxIsBlank(AInput.S['Report_ID']) then begin






                                mPrintList := TStringList.Create;
                                      try
                                         mPrintList.Add(mOutputDocument.OID);
                                         AName := mOutputDocument.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(mOutputDocument.GetFieldValueAsInteger('Ordnumber'))  +'-' + mOutputDocument.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;

                                             mr:=tstringlist.create;
                                             try
                                                 mOutputDocument.ObjectSpace.SQLSelect('select DataSource from Reports where ID=' + QuotedStr(AInput.S['Report_ID']),mr);
                                                 if mr.count>0 then begin
                                                    mDynCLSID:=mr.strings[0];
                                                 end else begin
                                                    mDynCLSID := mOutputDocument.DefaultDynSourceID;
                                                 end;
                                             finally
                                                 mr.free;
                                             end;

                                         try
                                            CFxReportManager.PrintByIDs(NxCreateContext(mOutputDocument.ObjectSpace),mPrintList,mDynCLSID, AInput.S['Report_ID'], rtofile, pekPDF,NxGetTempDir,aname);
                                            mFile:=NxGetTempDir+'\'+aname;
                                            try

                                                    mFile:=NxGetTempDir+aname;
                                            except
                                            end;
                                          except
                                          end;
                                      finally
                                          mPrintList.free;
                                      end;

                                      //mFile:=iPrintDocument(mOutputDocument,AInput.S['ReportID'])
                                end else begin
                                      mFile:='';
                                end;

                                //AOutput.S['DebugSent']:='sestava vytvářena' + mfile;

                                //mstring:=iSendMailx(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','1100000101', mFile,mDivision_ID,mOutputDocument);
                                mstring:=SendMail_BO(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','1100000101', mFile,mDivision_ID,mOutputDocument);



                           end;


                               {   Result_string:='{';

                                Result_string:=Result_string + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                Result_string:=Result_string + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                  Result_string:=Result_string + '"ID" :"' + mOutputDocument.oid+ '",' + chr(10);
                                  Result_string:=Result_string + '"New" :"' + mOutputDocument.DisplayName+ '",' + chr(10) ;
                                  Result_string:=Result_string + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                Result_string:=Result_string + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                Result_string:=Result_string + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                Result_string:=Result_string + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                Result_string:=Result_string + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                            Result_string:=Result_string + '}

                                   AOutput.S['State']:='201';
                                   AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mUser_ID;
                                   AOutput.S['ID']:= mOutputDocument.oid;
                                   AOutput.S['New']:= mOutputDocument.DisplayName;
                                   AOutput.S['Error']:= '' ;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(mImportRows.count) ;
                                   AOutput.S['Other']:=inttostr(mOtherRows.count);
                                   AOutput.S['Imp_batch']:=inttostr(mImportBatches.count);
                                   AOutput.S['Oth_batch']:=inttostr(mOtherBatches.count);
                                   AOutput.S['NotSave']:=inttostr(mNotSaveRows.count) ;
                                   AOutput.S['NotSave_batch']:=inttostr(mNotsaveBatches.count);

                  end ;
            end else begin

                                            {
                                            Result_string:=Result_string + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result_string:=Result_string + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                              Result_string:=Result_string + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result_string:=Result_string + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '" neobsahuje řádky, je prázdný,' + chr(10) ;
                                              Result_string:=Result_string + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                            Result_string:=Result_string + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                                Result_string:=Result_string + '}

                                   AOutput.S['State']:='400';
                                   AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mUser_ID;
                                   AOutput.S['ID']:='';
                                   AOutput.S['New']:='';
                                   AOutput.S['Error']:= 'Doklad neobsahuje žádný řádek' ;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(mImportRows.count) ;
                                   AOutput.S['Other']:=inttostr(mOtherRows.count);
                                   AOutput.S['Imp_batch']:=inttostr(mImportBatches.count);
                                   AOutput.S['Oth_batch']:=inttostr(mOtherBatches.count);
                                   AOutput.S['NotSave']:=inttostr(mNotSaveRows.count) ;
                                   AOutput.S['NotSave_batch']:=inttostr(mNotsaveBatches.count);



            end;
      end;
   result:=AOutput.AsString;
   //result:=AOutput;
  finally
          mImportdocuments.free;
          mImportRows.free;
          mOtherRows.free;
          mOtherBatches.free;
          mImportBatches.free;
          mSelectedRows.free;
          mNotSaveRows.free;
          mNotsaveBatches.free;
          AOutput.free;
  end;



end;















        function SendMail_BO(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
var
  mbo,mRecipient : TNxCustomBusinessObject;
  mAttachmentColl: TNxCustomBusinessMonikerCollection ;
  mSL : TStringList;
  i : integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
begin
  result:='';
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID',AFrom);
        mBO.SetFieldValueAsString('Firm_ID',mbo_source.GetFieldValueAsString('Firm_ID'));
        mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
        mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 1);
    mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
    mSL := TStringList.Create;
    try
      NxTokenToStrings(ATO, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 0);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;

    //mSL := TStringList.Create;
    //try
      //NxTokenToStrings(mS_CopyEmail, ';', mSL);
      //for i := 0 to mSL.Count - 1 do begin
    //    mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
    //    mRecipient.SetFieldValueAsInteger('EmailType', 1);
    //    mRecipient.SetFieldValueAsString('email', 'archiv@lipoelastic.com');
        //mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      //end;
    //finally
    //  mSL.Free;
    //end;

  // mSL := TStringList.Create;
  //  try
  //    NxTokenToStrings(mS_BccEmail, ';', mSL);
  //    for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 2);
        mRecipient.SetFieldValueAsString('email', 'mskacel@lipoelastic.com');
//        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
  //    end;
  //  finally
  //    mSL.Free;
  //  end;

    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
          TNxEmailSent(mbo).AttachFile(afilename);

    end;



    mbo.save;
   // NxShowSimpleMessage('Vytvořen email: ' + mbo.oid,nil);
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;



function POST_APINxIssuedPrice(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  AInput:TJSONSuperObject;
  mprice:Double;
  mX_parent_ID:string;
  mX_providerow_ID:string;
  mStorecard_ID:string;
  mFirm_ID,mFirmName:string;
  mBOFirm:TNxCustomBusinessObject;
  mQunit:string;
  mX_Storedocument_ID:string;
begin
  result:='';
  try
      mprice:=0;
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(ABody,true);

      mX_Storedocument_ID:='';
      try
          mX_Storedocument_ID:=AInput.S['X_Storedocument_ID'];
      finally
      end;

      if mX_Storedocument_ID<>'' then begin

                   mr:=tstringlist.create;
                   try
                      AContext.GetObjectSpace.SQLSelect('Select ii2.TAmountWithoutVAT/ii2.Quantity  '
                            + ' from Issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID '
                            + ' join Storecards SC on sc.id=ii2.Storecard_ID '
                            + ' where sd2.X_Storecard2_id=' + quotedstr(mX_Storedocument_ID)
                            + ' and SC.EAN=' + quotedstr(AInput.S['EAN'])
                             ,mr);
                             if mr.count>0 then begin
                                  mprice:=  NxIBStrToFloat(mr.Strings[0]);                                // cena z faktury
                             end;
                    finally
                        mr.free;
                    end;
      end;
    finally

    end;
result:= result + NxFloatToIBStr(mprice);
end;











function POST_APINxStorePrice(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  AInput:TJSONSuperObject;
  mprice:Double;
  mX_parent_ID:string;
  mX_providerow_ID:string;
  mStorecard_ID:string;
  mFirm_ID,mFirmName:string;
  mBOFirm:TNxCustomBusinessObject;
  mQunit:string;
  mX_Storedocument_ID:string;
  mStore_ID:string;
  mdebug:boolean;
begin
  result:='';
  try

      mStore_ID:='';
      mprice:=0;
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(ABody,true);

      mdebug:=false;
      try
          if Uppercase(AInput.S['Debug'])='TRUE' then mdebug:=True;
      finally
      end;



      mStorecard_ID:= AInput.S['Storecard_ID'];

      mX_Storedocument_ID:='';
      try
          mX_Storedocument_ID:=AInput.S['X_Storedocument_ID'];
          mStore_ID:=AContext.GetObjectSpace.SQLSelectFirstAsString('select Store_id from storedocuments2 where id=' +QuotedStr(mX_Storedocument_ID));

      finally
      end;

      mX_providerow_ID:='';
      try
          mX_providerow_ID:=AInput.S['X_Providerow_ID'];
          if mStore_ID='' then begin
             mStore_ID:=AContext.GetObjectSpace.SQLSelectFirstAsString('select Store_id from storedocuments2 where X_Providerow_ID=' +QuotedStr(mX_providerow_ID)
             );
          end;
      finally
      end;


      if mX_Storedocument_ID<>'' then begin
                     mStorecard_ID:= AInput.S['Storecard_ID'];

                   mr:=tstringlist.create;
                   try
                      AContext.GetObjectSpace.SQLSelect('Select ii2.TAmountWithoutVAT/ii2.Quantity  '
                            + ' from Issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID '
                            + ' where sd2.ID=' + quotedstr(mX_Storedocument_ID)
                            + ' and sd2.Storecard_ID=' + quotedstr(AInput.S['Storecard_ID'])
                             ,mr);
                             if mr.count>0 then begin
                                  mprice:=  NxIBStrToFloat(mr.Strings[0]);                                // cena z faktury
                             end;
                    finally
                        mr.free;
                    end;

      end;


      if (mprice=0) then begin
             if (mX_providerow_ID<>'') then begin
                    mX_providerow_ID:='';
                  try
                     mX_providerow_ID:=AInput.S['X_providerow_ID'];
                  finally
                  end;


                   mr:=tstringlist.create;
                   try
                      AContext.GetObjectSpace.SQLSelect('Select ii2.TAmountWithoutVAT/ii2.Quantity  '
                            + ' from Issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID '
                            + ' where sd2.X_providerow_ID=' + quotedstr(AInput.S['X_Providerow_ID'])
                            + ' and sd2.Storecard_ID=' + quotedstr(AInput.S['Storecard_ID'])
                             ,mr);

                             if mdebug then begin result:=result + 'Select ii2.unitprice '
                                              + ' from Issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID '
                                              + ' where sd2.X_providerow_ID=' + quotedstr(AInput.S['X_Providerow_ID'])
                                              + ' and sd2.Storecard_ID=' + quotedstr(AInput.S['Storecard_ID']) + chr(10);
                            end;

                        if mr.count>0 then begin
                            mprice:=  NxIBStrToFloat(mr.Strings[0]);                                // cena z faktury
                        end;
                   finally
                       mr.free;
                   end;
             end;

      end;
      if mprice=0 then begin
                    mFirm_ID:='';
                    if AInput.S['Firm_Name']<>'' then begin
                            mx:=TStringList.create;
                            try
                                 AContext.GetObjectSpace.SQLSelect('select id from firms where name=' + quotedstr(AInput.S['Firm_Name']) + ' and hidden=' + quotedstr('N')
                                                                 + ' and Firm_id is null',mx);
                                 if mx.count>0 then begin
                                     mBOFirm:=AContext.GetObjectSpace.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                     try
                                     mBOFirm.load(mx.Strings[0],nil);
                                     mQunit:='';
                                     mQunit:=AContext.GetObjectSpace.SQLSelectFirstAsString('select MainUnitCode from StoreCards where id=' + quotedstr(mStorecard_ID));

                                     if mdebug then begin
                                         result:= result+ chr(13) + chr(10) + 'NxGetStoreCardUnitPriceDef(' +  Quotedstr(mBOFirm.OID)+', '


                                                                                                                  +Quotedstr(mStore_ID)+', '
                                                                                                                  +QuotedStr(mStorecard_ID) + ','
                                                                                                                  +Quotedstr(mBOFirm.GetFieldValueAsString('Price_ID'))+', '
                                                                                                                  +Quotedstr(mQunit) +',False,'
                                                                                                                  +QuotedStr(mBOFirm.GetFieldValueAsString('Price_ID.Currency_ID'))+','
                                                                                                                  +inttostr(trunc(Date)) + ')';

                                     end;

                                           mprice:=NxEvalObjectExprAsFloatDef(mBOFirm,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOFirm.OID)+', '
                                                                                                                  +Quotedstr(mStore_ID)+', '
                                                                                                                  +QuotedStr(mStorecard_ID) + ','
                                                                                                                  +Quotedstr(mBOFirm.GetFieldValueAsString('Price_ID'))+', '
                                                                                                                  +Quotedstr(mQunit)+',False,'
                                                                                                                  +QuotedStr(mBOFirm.GetFieldValueAsString('Price_ID.Currency_ID'))+','
                                                                                                                  +inttostr(trunc(Date))+')',0);
                                          //result:= result + chr(10) + chr(13) + NxFloatToIBStr(mprice)


                                    finally

                                    end;


                                 end;
                            finally
                                mx.free;
                            end;
                    end;
      end;
      {  if mprice:=0 then begin
                    AContext.GetObjectSpace.SQLSelect('Select ro2.TAmountWithoutVAT/ro2.Quantity '
                      + ' from ReceivedOrders2 ro2 '
                      + ' where ro2.X_providerow_ID=' + quotedstr(AInput.S['X_Providerow_ID'])
                      + ' and ro2.Storecard_ID=' + quotedstr(AInput.S['Storecard_ID'])
                       ,mr);
                if mr.count>0 then begin
                      mprice:=  NxIBStrToFloat(mr.Strings[0]);                          // cena z objednávky
                end else begin
                      mprice:=0;
                end;
        end;}

              finally
              end;

result:= result + NxFloatToIBStr(mprice);
end;














function POST_APINxPLMPieceList(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  iJSONDocuments,iJSONRows,iJSONBatches:integer;
  mQuery:string;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput,mDocument:TJSONSuperObject;
  mInputDocuments:tstringlist;
  mFindDoc,mFindRow:boolean;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP,mOutputDocument,mBatch,mBO_PohybSarze : TNxCustomBusinessObject;
  mRows, mRows_OP,mRowsOutput,mMonBatches : TNxCustomBusinessMonikerCollection;
  mValidateList,mSelectedRows,mrx:tstringlist;
  mText,mSelectedHeader:string;
  mImportMan: TNxDocumentImportManager;
  mFind:boolean;
  mJSONDocuments,mJSONRows,mJSONBatches: TJSONSuperObjectArray;
  mJSONDocument,mJSONRow,mJSONBatch:TJSONSuperObject;
  mDocuments,mStoreDocQueue_ID:string;
  mImportdocuments,mImportRows,mImportBatches,mOtherRows,mOtherBatches:TStringList;
  mStore_ID,mFirm_ID,mDivision_ID:string;
  mpomocpocet,mUseQuantity:double;
  mPomocSarze,mUseSarze:double;
  mpocet:double;
  mDocInputDocument:string;
  mDebug,mWithPrices:boolean;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mEmail,mMesager:string;
  mSales:boolean;
  mFile:string;
  mDocrowbatchList:TStringList;
  mPomocMnozstvi:double;
  mlist:tstringlist;
  mdescription:string;
  mOtherAbra:string;
  mAllDocument:String;
begin
  mDebug:=False;
      mUser_ID:='';
      mMsgUser_ID:='';
      mDocInputDocument:='';
      AInput:=TJSONSuperObject.create;
      try
      AInput:= TJSONSuperObject.ParseString(ABody,true);




   {   AInput:=TJSONSuperObject.create;

          AInput:= TJSONSuperObject.ParseString(ABody,true);
            result:= AInput.S['User'];
            {if AInput.A['AbraDocuments'].Length>0 then begin                // v poli jSON jsou uvedeny doklady
                    for iJSONDocuments := 0 to AInput.A['AbraDocuments'].Length - 1 do begin  // cyklus dokladu
                        mJSONDocument:=TJSONSuperObject.create;
                        try
                           mJSONDocument:= TJSONSuperObject.ParseString(AInput.A['AbraDocuments'].S[iJSONDocuments],true);   // pole dokladu
                                // mImportdocuments.add(mJSONDocument.S['ID']);
                            if mJSONDocument.A['Rows'].Length>0 then begin
                                for iJSONRows := 0 to mJSONDocument.A['Rows'].Length - 1 do begin  // cyklus řádku dokladu
                                    mJSONRow:=TJSONSuperObject.create;
                                    try
                                        mJSONRow:= TJSONSuperObject.ParseString(mJSONDocument.A['Rows'].S[iJSONRows],true);
                                        result:= mJSONDocument.S['Name'];
                                    finally
                                        mJSONRow.free;
                                    end;
                                end;
                            end;
                        finally
                           mJSONDocument.free;
                        end;
                    end;
            end; }


            if not mdebug then begin
         {   if mRowsOutput.Count>0 then begin

                 mOutputDocument.ClearValidateErrors;
                  if Not mOutputDocument.Validate() then begin
                     mList := TStringList.Create;
                      try
                        mOutputDocument.GetValidateErrors(mList);
                        mText := mList.Text;
                        NxToken(mText, '='); }

                                   Result:='{';
                                            Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result:=Result + '"DocQueue_ID" :"' + ''+ '",' + chr(10);

                                              Result:=Result + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result:=Result + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '",' + chr(10) ;
                                              Result:=Result + '"z těchto důvodů: " :"' + ''+ '",' + chr(10) ;
                                              Result:=Result + '"Source" :"' + '' + '",' + chr(10) ;

                                            Result:=Result + '"Import" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Other" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Imp. batch" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Oth. batch" :"' + '0' + '",' + chr(10);
                                        Result:=Result + '}'  ;
                    {  finally
                        mList.Free;
                      end;


                  end else begin
                      mOutputDocument.Save ;   }



                        {
                           if not NxIsBlank(AInput.S['Msg']) then begin
                                      iSendmsg(AContext.GetObjectSpace, mOutputDocument , mOutputDocumentClsid,
                                                                      mOutputDocument.DisplayName  + '-  byl vytvořen novy doklad ',     // popis
                                                                      ' Byl vytvořen novy doklad s číslem: ' + mOutputDocument.DisplayName ,                          // tělo
                                                                      mMsgUser_ID ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
                           end; }

                          {
                           if not NxIsBlank(AInput.S['Email']) then begin
                                if not NxIsBlank(AInput.S['ReportID']) then mFile:=iPrintDocument(mOutputDocument,AInput.S['ReportID']) else mFile:='';

                                mstring:=iSendMailx(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','#300000001', mFile,mDivision_ID,mOutputDocument);
                           end; }

                              {
                                  Result:='{';

                                Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                Result:=Result + '"DocQueue_ID" :"' + ''+ '",' + chr(10);


                                  Result:=Result + '"ID" :"' + mOutputDocument.oid+ '",' + chr(10);
                                  Result:=Result + '"New" :"' + mOutputDocument.DisplayName+ '",' + chr(10) ;
                                  Result:=Result + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                Result:=Result + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                Result:=Result + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                Result:=Result + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                Result:=Result + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                            Result:=Result + '}//'  ;
        {          end ;
            end else begin


                                            Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result:=Result + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                              Result:=Result + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result:=Result + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '" neobsahuje řádky, je prázdný,' + chr(10) ;
                                              Result:=Result + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                            Result:=Result + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                            Result:=Result + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                            Result:=Result + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                            Result:=Result + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                                Result:=Result + '}//'  ;

          //  end;
      end;














      finally
          AInput.free;
      end;
end;





function POST_APINxPLMRoutine(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  iJSONDocuments,iJSONRows,iJSONBatches:integer;
  mQuery:string;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput,mDocument:TJSONSuperObject;
  mInputDocuments:tstringlist;
  mFindDoc,mFindRow:boolean;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP,mOutputDocument,mBatch,mBO_PohybSarze : TNxCustomBusinessObject;
  mRows, mRows_OP,mRowsOutput,mMonBatches : TNxCustomBusinessMonikerCollection;
  mValidateList,mSelectedRows,mrx:tstringlist;
  mText,mSelectedHeader:string;
  mImportMan: TNxDocumentImportManager;
  mFind:boolean;
  mJSONDocuments,mJSONRows,mJSONBatches: TJSONSuperObjectArray;
  mJSONDocument,mJSONRow,mJSONBatch:TJSONSuperObject;
  mDocuments,mStoreDocQueue_ID:string;
  mImportdocuments,mImportRows,mImportBatches,mOtherRows,mOtherBatches:TStringList;
  mStore_ID,mFirm_ID,mDivision_ID:string;
  mpomocpocet,mUseQuantity:double;
  mPomocSarze,mUseSarze:double;
  mpocet:double;
  mDocInputDocument:string;
  mDebug,mWithPrices:boolean;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mEmail,mMesager:string;
  mSales:boolean;
  mFile:string;
  mDocrowbatchList:TStringList;
  mPomocMnozstvi:double;
  mlist:tstringlist;
  mdescription:string;
  mOtherAbra:string;
  mAllDocument:String;
  mNewQueryID:string;
begin
  mDebug:=False;
      mUser_ID:='';
      mMsgUser_ID:='';
      mDocInputDocument:='';
      AInput:=TJSONSuperObject.create;

      try
      AInput:= TJSONSuperObject.ParseString(ABody,true);
            mOutputDocumentClsid:= AInput.S['output_document_clsid'];

        mUser_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['User']) ,mr);
             if mr.count>0 then begin
                 mUser_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;




            mOutputDocument:=AContext.GetObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4') ;


            if AInput.A['AbraDocuments'].Length>0 then begin                // v poli jSON jsou uvedeny doklady
                    for iJSONDocuments := 0 to AInput.A['AbraDocuments'].Length - 1 do begin  // cyklus dokladu
                        mJSONDocument:=TJSONSuperObject.create;
                        try
                           mJSONDocument:= TJSONSuperObject.ParseString(AInput.A['AbraDocuments'].S[iJSONDocuments],true);   // pole dokladu
                                    mr:=tstringlist.create;
                                    try
                                        AContext.SQLSelect('Select id from PLMRoutines where id=' + quotedstr(mJSONDocument.S['ID']),mr);
                                        if mr.count>0 then begin
                                            mOutputDocument.load(mr.Strings[0],nil);
                                        end else begin

                                             mNewQueryID:='INSERT INTO ' ;
                                                mNewQueryID:=mNewQueryID + 'PLMRoutines';
                                                mNewQueryID:=mNewQueryID + ' (id,Name,StoreCard_ID,Quantity,QUnit,CreatedBy_ID,RoutineType_ID,Created$DATE) ';
                                                mNewQueryID:=mNewQueryID + ' VALUES (' ;
                                                mNewQueryID:=mNewQueryID +  quotedstr(mJSONDocument.S['ID']);
                                                mNewQueryID:=mNewQueryID + ','+ quotedstr(mJSONDocument.S['Name']);


                                                mNewQueryID:=mNewQueryID + ','+ quotedstr(mJSONDocument.S['StoreCard_ID']);
                                                mNewQueryID:=mNewQueryID + ','+ quotedstr(mJSONDocument.S['Quantity']);
                                                mNewQueryID:=mNewQueryID + ','+ quotedstr(mJSONDocument.S['QUnit']);
                                                mNewQueryID:=mNewQueryID + ','+ quotedstr(mUser_ID);
                                                mNewQueryID:=mNewQueryID + ','+ quotedstr(mJSONDocument.S['RoutineType_ID']);
                                                mNewQueryID:=mNewQueryID + ','+ (mJSONDocument.S['Created$DATE']);

                                                mI:=AContext.SQLExecute(mNewQueryID) ;

                                                AContext.SQLSelect('Select id from PLMRoutines where id=' + quotedstr(mJSONDocument.S['ID']),mr);
                                                      if mr.count>0 then begin
                                                          mOutputDocument.load(mr.Strings[0],nil);
                                                      end else begin
                                                          result:='Nejde vytvořit';
                                                      end;
                                        end;
                                    finally
                                        mr.free;
                                    end;

                            if mJSONDocument.A['Rows'].Length>0 then begin
                                for iJSONRows := 0 to mJSONDocument.A['Rows'].Length - 1 do begin  // cyklus řádku dokladu
                                    mJSONRow:=TJSONSuperObject.create;
                                    try
                                        mJSONRow:= TJSONSuperObject.ParseString(mJSONDocument.A['Rows'].S[iJSONRows],true);
                                    finally
                                        mJSONRow.free;
                                    end;
                                end;
                            end;
                        finally
                           mJSONDocument.free;
                        end;
                    end;
            end;

      if not mdebug then begin
         //   if mRowsOutput.Count>0 then begin

                 mOutputDocument.ClearValidateErrors;
                  if Not mOutputDocument.Validate() then begin
                     mList := TStringList.Create;
                      try
                        mOutputDocument.GetValidateErrors(mList);
                        mText := mList.Text;
                        NxToken(mText, '=');

                                   Result:='{';
                                            Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result:=Result + '"DocQueue_ID" :"' + ''+ '",' + chr(10);

                                              Result:=Result + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result:=Result + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '",' + chr(10) ;
                                              Result:=Result + '"z těchto důvodů: " :"' + ''+ '",' + chr(10) ;
                                              Result:=Result + '"Source" :"' + '' + '",' + chr(10) ;

                                            Result:=Result + '"Import" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Other" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Imp. batch" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Oth. batch" :"' + '0' + '",' + chr(10);
                                        Result:=Result + '}'  ;
                      finally
                        mList.Free;
                      end;


                  end else begin
                     // mOutputDocument.Save ;



                        {
                           if not NxIsBlank(AInput.S['Msg']) then begin
                                      iSendmsg(AContext.GetObjectSpace, mOutputDocument , mOutputDocumentClsid,
                                                                      mOutputDocument.DisplayName  + '-  byl vytvořen novy doklad ',     // popis
                                                                      ' Byl vytvořen novy doklad s číslem: ' + mOutputDocument.DisplayName ,                          // tělo
                                                                      mMsgUser_ID ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
                           end; }

                          {
                           if not NxIsBlank(AInput.S['Email']) then begin
                                if not NxIsBlank(AInput.S['ReportID']) then mFile:=iPrintDocument(mOutputDocument,AInput.S['ReportID']) else mFile:='';

                                mstring:=iSendMailx(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','#300000001', mFile,mDivision_ID,mOutputDocument);
                           end; }


                                  Result:='{';

                                Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                Result:=Result + '"DocQueue_ID" :"' + ''+ '",' + chr(10);


                                  Result:=Result + '"ID" :"' + mOutputDocument.oid+ '",' + chr(10);
                                  Result:=Result + '"New" :"' + mOutputDocument.DisplayName+ '",' + chr(10) ;
                                  Result:=Result + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                Result:=Result + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                Result:=Result + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                Result:=Result + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                Result:=Result + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                            Result:=Result + '}'  ;
                  end ;
            end else begin


                                            Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result:=Result + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                              Result:=Result + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result:=Result + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '" neobsahuje řádky, je prázdný,' + chr(10) ;
                                              Result:=Result + '"Source" :"' + '' + '",' + chr(10) ;
                                            Result:=Result + '"Import" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Other" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Imp. batch" :"' + '0' + '",' + chr(10);
                                            Result:=Result + '"Oth. batch" :"' + '0' + '",' + chr(10);
                                Result:=Result + '}//'  ;

            end;
  //    end;



















      finally
          AInput.free;
      end;
end;



function POST_APINxImporManager(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  iJSONDocuments,iJSONRows,iJSONBatches:integer;
  mQuery:string;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput,mDocument:TJSONSuperObject;
  mInputDocuments:tstringlist;
  mFindDoc,mFindRow:boolean;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP,mOutputDocument,mBatch,mBO_PohybSarze : TNxCustomBusinessObject;
  mRows, mRows_OP,mRowsOutput,mMonBatches : TNxCustomBusinessMonikerCollection;
  mValidateList,mSelectedRows,mrx:tstringlist;
  mText,mSelectedHeader:string;
  mImportMan: TNxDocumentImportManager;
  mFind:boolean;
  mJSONDocuments,mJSONRows,mJSONBatches: TJSONSuperObjectArray;
  mJSONDocument,mJSONRow,mJSONBatch:TJSONSuperObject;
  mDocuments,mStoreDocQueue_ID:string;
  mImportdocuments,mImportRows,mImportBatches,mOtherRows,mOtherBatches:TStringList;
  mStore_ID,mFirm_ID,mDivision_ID:string;
  mpomocpocet,mUseQuantity:double;
  mPomocSarze,mUseSarze:double;
  mpocet:double;
  mDocInputDocument:string;
  mDebug,mWithPrices:boolean;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mEmail,mMesager:string;
  mSales:boolean;
  mFile:string;
  mDocrowbatchList:TStringList;
  mPomocMnozstvi:double;
  mlist:tstringlist;
  mdescription:string;
  mOtherAbra:string;
  mAllDocument:String;
  mStorecard_ID:string;
begin
  try
      mDebug:=False;
      mUser_ID:='';
      mMsgUser_ID:='';
      mDocInputDocument:='';
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(ABody,true);


         mInputDocumentClsid:=AInput.S['input_document_clsid'];
         mOutputDocumentClsid:=AInput.S['output_document_clsid'];
         mAllDocument:= AInput.S['ImportAllDocument'];
         if AInput.S['Debug']='True' then mDebug:=True else mDebug:=false;
         if AInput.S['WithPrices']='True' then mWithPrices:=True else mWithPrices:=false;



        mDocQueue_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['DocQueue_Code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mDocQueue_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;

        mStoreDocQueue_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['StoreDocQueue_code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mStoreDocQueue_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;



        mFirm_ID:='';
        if AInput.S['Firm_Name']<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from firms where name=' + quotedstr(AInput.S['Firm_Name']) + ' and hidden=' + quotedstr('N')
                                                     + ' and Firm_id is null',mr);
                     if mr.count>0 then begin
                         mFirm_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;

        mStore_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Stores where code=' + quotedstr(AInput.S['Store_Code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mStore_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;

        mDivision_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Divisions where code=' + quotedstr(AInput.S['Division_Code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mDivision_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;

        mUser_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['User']) ,mr);
             if mr.count>0 then begin
                 mUser_ID:=mr.Strings[0];
                 if mUser_ID='SUPER00000' then  mUser_ID:='';
             end;
        finally
            mr.free;
        end;

       mMsgUser:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['Msg']) ,mr);
             if mr.count>0 then begin
                 mMsgUser_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;


  finally

  end;
  mImportdocuments:=TStringList.create;
  mImportRows:=TStringList.create;
  mOtherRows:=TStringList.create;
  mOtherBatches:=TStringList.create;
  mImportBatches:=TStringList.create;
  mSelectedRows:=TstringList.Create;

  try





      if AInput.A['AbraDocuments'].Length>0 then begin                // v poli jSON jsou uvedeny doklady
          for iJSONDocuments := 0 to AInput.A['AbraDocuments'].Length - 1 do begin  // cyklus dokladu
                   mJSONDocument:=TJSONSuperObject.create;
                  mJSONDocument:= TJSONSuperObject.ParseString(AInput.A['AbraDocuments'].S[iJSONDocuments],true);   // pole dokladu

                 // mImportdocuments.add(mJSONDocument.S['ID']);

                      if mJSONDocument.A['Rows'].Length>0 then begin
                             for iJSONRows := 0 to mJSONDocument.A['Rows'].Length - 1 do begin  // cyklus řádku dokladu
                                mJSONRow:=TJSONSuperObject.create;
                                mJSONRow:= TJSONSuperObject.ParseString(mJSONDocument.A['Rows'].S[iJSONRows],true);    //pole řádku
                                mpomocpocet:=NxIBStrToFloat(mJSONRow.S['Quantity']);
                                mr:=tstringlist.create;
                                mStorecard_ID:='';
                                mStorecard_ID:= AContext.GetObjectSpace.SQLSelectFirstAsString('Select id from Storecards where EAN='  + quotedstr(mJSONRow.S['Storecard_ID']));

                                try
                                    if ((mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') and (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                            if (mInputDocumentClsid=mOutputDocumentClsid) or (AInput.S['Import']='0') then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from ReceivedOrders where id is null',mr);
                                            end else begin
                                                  AContext.GetObjectSpace.SQLSelect('Select ro.id,ro2.id,ro2.Store_ID,ro2.Storecard_id,ro2.X_Providerow_ID,(ro2.quantity-ro2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 ro2 left join ReceivedOrders ro on ro.id=ro2.parent_id '
                                                                      + ' where ro2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and ro2.Storecard_ID=' + quotedstr(mStorecard_ID)
                                                                      + ' and ro.Closed=' + quotedstr('N')
//                                                                      + ' and ro.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and ro2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                             end;
                                     end;
                                    // z op do ov
                                    if ((mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') and (mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                            if (mInputDocumentClsid=mOutputDocumentClsid) or (AInput.S['Import']='0') then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from ReceivedOrders where id is null',mr);
                                            end else begin
                                                  AContext.GetObjectSpace.SQLSelect('Select ro.id,ro2.id,ro2.Store_ID,ro2.Storecard_id,ro2.X_Providerow_ID,(ro2.quantity-ro2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 ro2 left join ReceivedOrders ro on ro.id=ro2.parent_id '
                                                                      + ' where ro2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and ro2.Storecard_ID=' + quotedstr(mStorecard_ID)
                                                                      + ' and ro.Closed=' + quotedstr('N')
//                                                                      + ' and ro.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and (not exists (select * from ReceivedOrdersToIssuedOrders Y where Y.Source_ID = ro2.ID) )'
                                                                      + ' and ro2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                             end;
                                     end;



                                     if mInputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin

                                                {if mdebug then result:=result+ chr(10) + chr(13) +  'SQL' + ' : ' +'Select io.id,io2.id,io2.Store_ID,IO2.Storecard_id,io2.X_Providerow_ID,(io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and io2.Storecard_ID=' + quotedstr(mStorecard_ID)
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                       + ' and io2.quantity>io2.DeliveredQuantity';  }

                                             if (mInputDocumentClsid=mOutputDocumentClsid) or (AInput.S['Import']='0') then begin
                                                     AContext.GetObjectSpace.SQLSelect('Select id from Issuedorders where id is null',mr);
                                             end else begin

                                                     AContext.GetObjectSpace.SQLSelect('Select io.id,io2.id,io2.Store_ID,IO2.Storecard_id,io2.X_Providerow_ID,(io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and io2.Storecard_ID=' + quotedstr(mstorecard_ID)
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and io2.quantity>io2.DeliveredQuantity'

                                                                       ,mr);
                                              end;
                                     end;


                                     if ((mInputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') and (mInputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                               if (mInputDocumentClsid=mOutputDocumentClsid) or (AInput.S['Import']='0') then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from StoreDocuments where id is null',mr);
                                               end else begin
                                                        if AInput.S['DocumentType']='' then
                                                              AContext.GetObjectSpace.SQLSelect('Select sd.id,sd2.id,sd2.Store_ID,sd2.Storecard_id,sd2.X_Providerow_ID,(sd2.quantity-sd2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from StoreDocuments2 io2 left join StoreDocuments IO on sd.id=sd.parent_id '
                                                                      + ' where sd2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and sd2.Storecard_ID=' + quotedstr(mStorecard_ID)
                                                                      + ' and sd.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and sd2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                                       if AInput.S['DocumentType']<>'' then
                                                              AContext.GetObjectSpace.SQLSelect('Select sd.id,sd2.id,sd2.Store_ID,sd2.Storecard_id,sd2.X_Providerow_ID,(sd2.quantity-sd2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from StoreDocuments2 io2 left join StoreDocuments IO on sd.id=sd.parent_id '
                                                                      + ' where sd2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and sd2.Storecard_ID=' + quotedstr(mStorecard_ID)
                                                                      + ' and sd.Closed=' + quotedstr('N')
                                                                      + ' and sd.DocumentType=' + quotedstr(AInput.S['DocumentType'])
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and sd2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                               end;
                                      end;




                                   //  if mdebug then result:=result+ chr(10) + chr(13) +  'Nalezeno' + ' : ' +inttostr(mr.count);

                                    if mr.count> 0 then begin

                                         for mri:=0 to mr.count-1 do begin

                                                 if mpomocpocet>0 then begin

                                                           if mpomocpocet>=NxIBStrToFloat(copy(mr.Strings[mri],56,10))  then begin
                                                                          mUseQuantity:=0;
                                                                          mUseQuantity:=NxIBStrToFloat(copy(mr.Strings[mri],56,10));
                                                                          mImportRows.add(copy(mr.Strings[mri],1,55)+ NxFloatToIBStr(mUseQuantity) ) ;
                                                                          mpomocpocet:=mpomocpocet-mUseQuantity;
                                                           end else begin
                                                                          mUseQuantity:=0;
                                                                          mUseQuantity:=mPomocPocet;
                                                                          mImportRows.add(copy(mr.Strings[mri],1,55)+ (NxFloatToIBStr(mpomocpocet)) ) ;
                                                                          mpomocpocet:=mpomocpocet-mpomocpocet;
                                                           end;



                                                       //   if mdebug then result:=result+ chr(10) + chr(13) +  'Počet' + ' : ' +NxFloatToIBStr(mUseQuantity);


                                                           if mJSONRow.A['docrowbatches'].Length>0 then begin
                                                               for iJSONBatches := 0 to mJSONRow.A['docrowbatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                  mJSONBatch:=TJSONSuperObject.create;
                                                                  mJSONBatch:= TJSONSuperObject.ParseString(mJSONRow.A['docrowbatches'].S[iJSONBatches],true);    //pole šarže
                                                                  mPomocSarze:=NxIBStrToFloat(mJSONBatch.S['Quantity']);
                                                                   //if mdebug then result:=result+ chr(10) + 'Šarže.' +mJSONBatch.S['Name'] + ', Množství:' +  mJSONBatch.S['Quantity'];

                                                                  mrx:=tstringlist.create;
                                                                  try
                                                                       //if mdebug then result:=result + chr(10) +  'Select id from StoreBatches where Name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mStorecard_ID) + ' and hidden=' + quotedstr('N');
                                                                       AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mStorecard_ID) + ' and hidden=' + quotedstr('N'),mrx);
                                                                       if mrx.count> 0 then begin

                                                                          if mUseQuantity>=mPomocSarze then begin
                                                                              if mJSONRow.D['Quantity']>0 then begin
                                                                                     mImportBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('00000000000000000000' +NxFloatToIBStr(mJSONRow.D['TotalPrice']/ mJSONRow.D['Quantity']),10 ));
                                                                              end else begin
                                                                                     mImportBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('00000000000000000000' +NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10 ));
                                                                              end;
                                                                             //if mdebug then result:=result + chr(10) +  ' rows sarze' + mJSONRow.S['X_Providerow_ID'] + ';' +(mStorecard_ID  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('0000000000' +NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10 ));
                                                                          end else begin
                                                                              if mJSONRow.D['Quantity']>0 then begin
                                                                                   mImportBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] / mJSONRow.D['Quantity']),10 ));
                                                                              end else begin
                                                                                   mImportBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10 ));
                                                                              end;
                                                                             // if mdebug then result:=result + chr(10) +  ' import rows sarze' + (mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('0000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10 ));
                                                                          end;


                                                                           //if mdebug then result:=result+ chr(10) +  'import Podklad batches ' + ' : ' +mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID  + ';' + mrx.Strings[0] +';'+NxFloatToIBStr(mPomocSarze) + ';'

                                                                       end else begin
                                                                          //  if mdebug then result:=result + chr(10) + 'import Založit šarži.' +';'+mJSONBatch.S['Name'] + ', Množství:' +  mJSONBatch.S['Quantity'];
                                                                       end;

                                                                  finally
                                                                      mrx.free;
                                                                  end;
                                                                  mJSONBatch.free;

                                                               end;
                                                          end;
                                                   end;
                                         end;
                                         if (mpomocpocet>0)  then begin                          // není možné čerpat
                                                     mOtherRows.add('0000000000' + ';'                  // doklad
                                                        +'0000000000' + ';'
                                                        +mJSONRow.S['Store_ID']+ ';'
                                                        +mStorecard_ID+ ';'
                                                        +mJSONRow.S['X_Providerow_ID'] + ';'                //io2.X_ProvideRow_ID
                                                        +NxFloatToIBStr(mpomocpocet)) ;
                                                        //********

                                                           //if mdebug then result:=result  + chr(10) + ' other rows dohledáno provide_ID' + ('0000000000' + ';' +'0000000000' + ';' + mJSONRow.S['Store_ID']
                                                           //+';'+mStorecard_ID+';'+ mJSONRow.S['X_Providerow_ID']+ ';' + NxFloatToIBStr(mpomocpocet)) ;

                                                        if mJSONRow.A['docrowbatches'].Length>0 then begin
                                                             for iJSONBatches := 0 to mJSONRow.A['docrowbatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                mJSONBatch:=TJSONSuperObject.create;
                                                                mJSONBatch:= TJSONSuperObject.ParseString(mJSONRow.A['docrowbatches'].S[iJSONBatches],true);    //pole šarže
                                                                mrx:=tstringlist.create;
                                                                try
                                                                     AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mStorecard_ID)+ ' and hidden=' + quotedstr('N'),mrx);
                                                                     if mrx.count> 0 then begin
                                                                          if mJSONRow.D['Quantity']>0 then begin
                                                                               mOtherBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + mJSONBatch.S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] / mJSONRow.D['Quantity']),10));
                                                                           end else begin
                                                                               mOtherBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + mJSONBatch.S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10));
                                                                           end;
                                                                       //   if mdebug then result:=result  + chr(10) + ' other rows sarze' + (mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + mJSONBatch.S['Quantity'],10)+';'+  NxRight('0000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10));
                                                                     end else begin
                                                                      //    if mdebug then result:=result + chr(10) + 'other Založit šarži.' +';'+mJSONBatch.S['Name'] + mJSONBatch.S['Quantity'];
                                                                     end;

                                                                finally
                                                                    mrx.free;
                                                                end;
                                                                mJSONBatch.free;

                                                             end;
                                                        end;













                                         end;
                                    end else begin
                                      if (AInput.S['Import']<>'1') then begin
                                         mOtherRows.add('0000000000' + ';'                  // doklad
                                                        //+mJSONRow.S['id']+ ';'
                                                        +'0000000000' + ';'
                                                        +mJSONRow.S['Store_ID']+ ';'
                                                        +mStorecard_ID+ ';'
                                                        +mJSONRow.S['X_Providerow_ID']+ ';'
                                                        +mJSONRow.S['Quantity']) ;

                                                       // if mdebug then result:=result  + chr(10) + ' other rows nedohledáno provide_ID' + ('0000000000' + ';' +'0000000000' + ';' + mJSONRow.S['Store_ID']
                                                       //    +';'+mStorecard_ID+';'+ mJSONRow.S['X_Providerow_ID']+ ';' + NxFloatToIBStr(mpomocpocet)) ;


                                        if mJSONRow.A['docrowbatches'].Length>0 then begin
                                             for iJSONBatches := 0 to mJSONRow.A['docrowbatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                mJSONBatch:=TJSONSuperObject.create;
                                                mJSONBatch:= TJSONSuperObject.ParseString(mJSONRow.A['docrowbatches'].S[iJSONBatches],true);    //pole šarže
                                                mrx:=tstringlist.create;
                                                try
                                                     AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mStorecard_ID),mrx);
                                                     if mrx.count> 0 then begin
                                                          if mJSONRow.D['Quantity']>0 then begin
                                                              mOtherBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + mJSONBatch.S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] / mJSONRow.D['Quantity']),10 ));
                                                          end else begin
                                                              mOtherBatches.add(mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + mJSONBatch.S['Quantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10 ));
                                                          end;
                                                          //if mdebug then result:=result + chr(10) + ' bez importu rows sarze' + (mJSONRow.S['X_Providerow_ID'] + ';' +mStorecard_ID + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + mJSONBatch.S['Quantity'],10)+';'+  NxRight('0000000000' + NxFloatToIBStr(mJSONRow.D['TotalPrice'] div mJSONRow.D['Quantity']),10 ));
                                                     end else begin
                                                          //if mdebug then result:=result + chr(10) + 'bez importu Založit šarži.' +';'+mJSONBatch.S['Name'] + mJSONBatch.S['Quantity'];
                                                     end;

                                                finally
                                                    mrx.free;
                                                end;
                                                mJSONBatch.free;

                                             end;
                                        end;
                                      end;
                                    end;
                                finally
                                    mr.free;
                                end;





                             end;
                      end;
          end;
      end;


        {
       mImportdocuments:=TstringList.Create;
              try
                 if AInput.A['InputDocuments'].Length>0 then begin
                  for i := 0 to AInput.A['InputDocuments'].Length - 1 do begin
                         mImportdocuments.Add(AInput.A['InputDocuments'].S[i]);
                  end;
                 end;
              finally
              end;

               mSelectedHeader:=AInput.S['SelectedHeader'];
               }

              try
                  if mImportRows.count>0 then begin
                      for i:=0 to mImportRows.count-1 do begin

                          mfind:=false;   // dohledání Dokladu
                          for x:=0 to mImportdocuments.count-1 do begin
                              if  mImportdocuments.Strings[x]=copy(mImportRows.Strings[i],1,10) then mfind:=true;
                          end;
                          if not mFind then mImportdocuments.add(copy(mImportRows.Strings[i],1,10)) ;


                          mfind:=false;   // dohledání řádku
                          for x:=0 to mSelectedRows.count-1 do begin
                              if  mSelectedRows.Strings[x]=copy(mImportRows.Strings[i],12,10) then mfind:=true;
                          end;
                          if not mFind then mSelectedRows.add(copy(mImportRows.Strings[i],12,10));


                      end;
                  end;
              finally

              end;




if mImportRows.count>0 then begin

  mImportMan := NxCreateDocumentImportManager(AContext.GetObjectSpace, mInputDocumentClsid, mOutputDocumentClsid);
                                  mParams := TNxParameters.Create();
end;



             if mImportdocuments.count>0 then begin     // import dokladu

                                      try
                                         if mImportdocuments.count>0 then begin
                                            for i:=0 to mImportdocuments.count-1 do begin
                                                mImportMan.AddInputDocument(mImportdocuments.Strings[i]);
                                                mDocInputDocument:=mDocInputDocument + mImportMan.InputDocuments[i].DisplayName;
                                                if i<>mImportdocuments.count-1 then mDocInputDocument:=mDocInputDocument + ', ' ;
                                            end;
                                          end;




                                         if trim(mSelectedHeader)='' then begin
                                             if mInputDocuments.count>1 then mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := mImportdocuments.Strings[0];
                                         end else begin
                                             mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := AInput.S['SelectedHeader'];
                                         end;

                                         if mDocQueue_ID<>'' then mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;

                                         if UpperCase(trim(mAllDocument))<>'TRUE' then begin
                                                if mSelectedRows.count>0 then mParams.GetOrCreateParam(dtString, 'SelectedRows').AsString := mSelectedRows.Text;
                                         end;

                                    //      mParams.GetOrCreateParam(dtBoolean, 'ImportBatches').AsBoolean := True;

                                    if mSelectedRows.count>0 then begin
                                         try
                                         mImportMan.LoadParams(mParams);
                                         mImportMan.Execute;

                                         mOutputDocument:=mImportMan.OutputDocument;
                                         mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(mJSONDocument.S['DocDate']));
                                         if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                              mOutputDocument.setfieldvalueasstring('X_ExternalDocument',mJSONDocument.S['DocNumber']);
                                         end;
                                          mOutputDocument.setfieldvalueasstring('X_Identifikace',mJSONDocument.S['Identifikace']);
                                          if mFirm_ID<>'' then begin
                                               mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                                          end else begin
                                               mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                               mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                          end;
                                          if uppercase(trim(mAllDocument))='TRUE' then begin

                                            if  mOutputDocumentClsid='050I5SAOS3DL3ACU03KIU0CLP4' then begin         // dodací list
                                                 mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                 mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                            end;
                                          end;
                                          if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',mJSONDocument.S['DocNumber']);
                                          end;


                                         mOutputDocument.SetFieldValueAsString('Description',copy((mImportMan.InputDocuments[0].GetFieldValueAsString('Description') ),1,50));
                                         if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                              mOutputDocument.SetFieldValueAsString('U_popis', mImportMan.InputDocument.GetFieldValueAsString('Description'));

                                         if (mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') or (mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                              if (trim(mOutputDocument.getfieldvalueasstring('ExternalNumber'))='') and (mJSONDocument.S['DocNumber']<>'') then begin
                                                   mOutputDocument.setfieldvalueasstring('ExternalNumber',mJSONDocument.S['DocNumber']);
                                              end;
                                              if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                   mOutputDocument.setfieldvalueasstring('X_ExternalDocument',mJSONDocument.S['DocNumber']);
                                              end;
                                          end;

                                         except
                                               mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                                mOutputDocument.new;
                                                mOutputDocument.prefill;
                                                mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                                mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(mJSONDocument.S['DocDate']));
                                                if mFirm_ID<>'' then mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);

                                                if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',mJSONDocument.S['DocNumber']);
                                                end;


                                                if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                      mOutputDocument.setfieldvalueasstring('X_ExternalDocument',mJSONDocument.S['DocNumber']);
                                                end;
                                                try
                                                 if mOutputDocument.getfieldvalueasstring('ExternalNumber')='' then begin
                                                      mOutputDocument.setfieldvalueasstring('ExternalNumber',mJSONDocument.S['DocNumber']);
                                                end;
                                                finally

                                                end;

                                                    mOutputDocument.SetFieldValueAsString('Description',copy((mImportMan.InputDocuments[0].GetFieldValueAsString('Description') ),1,50));
                                                    if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                              mOutputDocument.SetFieldValueAsString('U_popis', mImportMan.InputDocument.GetFieldValueAsString('Description'));


                                         end;
                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                              if mStore_ID='' then mStore_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Store_ID');
                                              if mDivision_ID='' then mDivision_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Division_ID');
                                              if ((mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' ))  then begin // op
                                                  // smazat původní pohyby šarží
                                                  mi:=AContext.GetObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' and code='+quotedstr(mOutputDocument.oid));
                                              end;

                                              if ((mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' ))  then begin  // ov
                                                  // smazat původní pohyby šarží
                                                   mi:=AContext.GetObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') + ' and code='+quotedstr(mOutputDocument.oid));
                                              end;

                                              if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC' ) and  (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC' )) then begin  // sd
                                                    // smazat původní pohyby šarží
                                                    mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                                    if mMonBatches.count>0 then begin
                                                          for mIBatchs := 0 to mMonBatches.Count - 1 do begin
                                                              mMonBatches.BusinessObject[mIBatchs].MarkForDelete;
                                                          end;
                                                    end;
                                              end;

                                         end;



                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                                        for i:=0 to mImportRows.count-1 do begin
                                                            if (mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_providerow_ID')=copy(mImportRows.strings[i],45,10)) and (not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_providerow_ID'))) then begin
                                                                   if mdebug then result:=result+ chr(10) + chr(13) +  'Počet' + ' : ' + (copy(mImportRows.strings[i],56,10));
                                                                   mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportRows.strings[i],56,10)));
                                                                  // if mdebug then result:=result + chr(10) +'  Množství zadávané  na řádku importem  :' + IntToStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsinteger('Posindex')) + ' / ' + NxFloatToIBStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsfloat('Quantity'));
                                                                     // if mDebug then  result:=  result + copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);

                                                                          if (UpperCase(AInput.S['ImportBatches'])='TRUE') and (mImportBatches.count>0) then begin
                                                                          if mRowsOutput.BusinessObject[mIRows].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                 // op
                                                                                      mPomocMnozstvi:=0;
                                                                                      for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                            if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') then begin
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],24,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            mBO_PohybSarze.save;
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                            end;
                                                                                      end;
                                                                                      if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                      if mdebug then result:=result + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                 //      ov
                                                                                   mPomocMnozstvi:=0;
                                                                                   for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                        if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') then begin
                                                                                              mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:= mPomocMnozstvi + NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            mBO_PohybSarze.save
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                        end;
                                                                                  end;
                                                                                   if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi);
                                                                                 //  if mdebug then result:=result + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;

                                                                                 if ((mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC') and (mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                                                                          mPomocMnozstvi:=0;
                                                                                          for mIBatchs := 0 to mImportBatches.Count - 1 do begin

                                                                                               if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') then begin
                                                                                                   //result:= result +  copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                   mPomocMnozstvi:=mPomocMnozstvi +NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                   mBatch.SetFieldValueAsString('Qunit',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsstring('Qunit'));

                                                                                                  if mWithPrices then begin
                                                                                                     if mdebug then result:=result + '  Unitprice :' + (copy(mImportBatches.Strings[mIBatchs],46,10));
                                                                                                     if mdebug then result:=result + '  X_quantity' + (copy(mImportBatches.Strings[mIBatchs],34,10)) + chr(10);
                                                                                                  end;

                                                                                               end;

                                                                                          end;
                                                                                          if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi);
                                                                                           if mdebug then result:=result + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;
                                                                           end;
                                                                          end;
                                                            end;

                                                        end;
                                         end;
                                     end;
                                   finally
                                       //mParams.free;
                                      // mImportMan.free;
                                   end;



             end else begin
                                mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                mOutputDocument.new;
                                mOutputDocument.prefill;
                                mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                if mFirm_ID<>'' then  mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);
                                 mOutputDocument.setfieldvalueasstring('X_Identifikace',mJSONDocument.S['Identifikace']);
                                mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
           end;


           if mdebug then begin
               result:=result +  'Externí číslo: ' + mJSONDocument.S['DocNumber'] + chr(10);
               result:=result +  'Řada dokladu: ' + mOutputDocument.GetFieldValueAsString('Docqueue_ID.CODE') + chr(10);
               result:=result +  'Firma: ' + mOutputDocument.GetFieldValueAsString('Firm_ID.Name') + chr(10);


           end;


           if mOtherRows.count>0 then begin
                      for i:=0 to mOtherRows.count-1 do begin
                            mRow := mRowsOutput.AddNewObject;
                            mrow.Prefill;
                            if mOutputDocumentClsid<>'E03ZNUMDTCC4PDAUIEY1MBTJC0' then mrow.SetFieldValueAsInteger('Rowtype',3);
                            mrow.SetFieldValueAsString('Store_ID',mstore_ID);
                            mrow.SetFieldValueAsString('StoreCard_ID',copy(mOtherRows.strings[i],34,10));
                            mrow.SetFieldValueAsString('X_Providerow_ID',copy(mOtherRows.strings[i],45,10));
                            mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mOtherRows.strings[i],56,10)));
                            //if mdebug then result:=result + chr(10) +'  Množství zadávané  na řádku  :' + IntToStr(mrow.getFieldValueAsinteger('Posindex')) + ' / ' + NxFloatToIBStr(mrow.getFieldValueAsfloat('Quantity'));
                            //mrow.SetFieldValueAsString('Qunit',mrow.GetFieldValueAsString('Storecard_ID.MainUnitCode'));
                            mrow.SetFieldValueAsString('Qunit','ks');
                            mrow.SetFieldValueAsString('Division_ID',mDivision_ID);

                           // if mdebug then  Result:=result + chr(10) + chr(13) + ' Otherrows vkládání do dokladu podklad  ' +(mOtherRows.strings[i]);


                          //if mdebug then  Result:=Result + '"other rows vkládání do dokladu parseRows " +"'             + mstore_ID + ', ' + copy(mOtherRows.strings[i],34,10) + ', ' + (copy(mOtherRows.strings[i],56,10))  +'"' + chr(10);







                            try           // šarže
                            if (UpperCase(AInput.S['ImportBatches'])='TRUE') and (mOtherBatches.count>0) then begin
                            if mrow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                      mPomocMnozstvi:=0;
                                                                                      for mIBatchs := 0 to mOtherBatches.Count - 1 do begin

                                                                                                 if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin
                                                                                                              //
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mrow.GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            if mdebug then result:=result + ' Šarže' + copy(mOtherBatches.Strings[mIBatchs],23,10)+ chr(10) + 'unitprice :  ' +  (copy(mOtherBatches.Strings[mIBatchs],46,10)) + ' quantity: ' + copy(mOtherBatches.Strings[mIBatchs],46,10);

                                                                                                            if not mdebug then mBO_PohybSarze.save;


                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                                end;
                                                                                      end;
                                                                                      if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                        mPomocMnozstvi:=0;
                                                                                        for mIBatchs := 0 to mOtherBatches.Count - 1 do begin
                                                                                                // if mdebug then result:=result + ' Šarže' + mOtherBatches.Strings[mIBatchs] + chr(10);
                                                                                                 if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin

                                                                                                      mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mrow.GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            if not mdebug then mBO_PohybSarze.save;

                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                                end;
                                                                                        end;
                                                                                        if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;



                                                                                 if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mMonBatches :=  mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                                                         mPomocMnozstvi:=0;
                                                                                          for mIBatchs := 0 to mOtherBatches.Count - 1 do begin


                                                                                               if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                   mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
//                                                                                                          mBatch.SetFieldValueAsString('Qunit',mRow.GetFieldValueAsString('Storecard_ID.MainUnitCode'));
                                                                                                          mBatch.SetFieldValueAsString('Qunit','ks');

                                                                                               end;

                                                                                          end;
                                                                                          if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;
                                                                           end;
                                                                           end;
                              finally

                            end;  // šarže
                             end;


                   end;

                mOutputDocument.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                if mFirm_ID<>'' then begin
                     mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                end else begin
                     mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                     mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                end;
                if uppercase(trim(mAllDocument))='TRUE' then begin

                                            if  mOutputDocumentClsid='050I5SAOS3DL3ACU03KIU0CLP4' then begin
                                                 if mOtherRows.count=0 then begin
                                                      mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                      mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                                      if not nxisemptyoid(mImportMan.InputDocuments[0].GetFieldValueAsString('X_Delivery_adress_id')) then
                                                           mOutputDocument.setfieldvalueasstring('X_Delivery_adress_id',mImportMan.InputDocuments[0].GetFieldValueAsString('X_Delivery_adress_id'));
                                                      mOutputDocument.setfieldvalueasstring('TransportationType_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('TransportationType_ID'));


                                                 end;
                                            end;
                                          end;


                                  if mdebug then begin
//                               if mInputDocumentClsid=mOutputDocumentClsid then begin
                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         result:=result + chr(10) +  '  Řádky:' + chr(10);
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                                //mRowsOutput.BusinessObject[mIRows].setFieldValueAsString('X_Providerow_ID',mRowsOutput.BusinessObject[mIRows].OID);

                                                        result:=result + IntToStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsinteger('Posindex'))
                                                                                                         + ': ' + mRowsOutput.BusinessObject[mIRows].getFieldValueAsstring('Store_ID.Code')
                                                                                                         + ' / ' + mRowsOutput.BusinessObject[mIRows].getFieldValueAsstring('Storecard_ID.DisplayName')
                                                                                                         + ' - ' + NxFloatToIBStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsfloat('Quantity'))
                                                                                                         + ' * ' + NxFloatToIBStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsfloat('Unitprice'))
                                                                                                         + ' ( ' + NxFloatToIBStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsfloat('Totalprice')) + ')';

                                                        if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                              mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                                                          for mIBatchs := 0 to mMonBatches.Count - 1 do begin
                                                                                  result:=result + chr(10) + '          ' +IntToStr(mIBatchs+1)
                                                                                                       + ': ' + mMonBatches.BusinessObject[mIBatchs].getFieldValueAsString('StoreBatch_ID.Name')
                                                                                                       + ' - ' + NxFloatToIBStr(mMonBatches.BusinessObject[mIBatchs].getFieldValueAsfloat('Quantity'))
                                                                                                       + ' ' + mMonBatches.BusinessObject[mIBatchs].getFieldValueAsString('Qunit')  + chr(10);;
                                                                          end;
                                                        end;





                                         end;
                                 end;
                                 // END;
                if mUser_ID<>'' then mOutputDocument.SetFieldValueAsString('CreatedBy_ID',mUser_ID);



                 mOutputDocument.SetFieldValueAsString('X_ExternalDocument', mJSONDocument.S['DocNumber']);








      if not mdebug then begin
            if mRowsOutput.Count>0 then begin

                 mOutputDocument.ClearValidateErrors;
                  if Not mOutputDocument.Validate() then begin
                     mList := TStringList.Create;
                      try
                        mOutputDocument.GetValidateErrors(mList);
                        mText := mList.Text;
                        NxToken(mText, '=');

                                   Result:='{';
                                            Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result:=Result + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);

                                              Result:=Result + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result:=Result + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '",' + chr(10) ;
                                              Result:=Result + '"z těchto důvodů: " :"' + mText+ '",' + chr(10) ;
                                              Result:=Result + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;

                                            Result:=Result + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                            Result:=Result + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                            Result:=Result + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                            Result:=Result + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                                        Result:=Result + '}'  ;
                      finally
                        mList.Free;
                      end;


                  end else begin
                      mOutputDocument.Save ;

            //     result:=mOutputDocument.oid  +';'+ mOutputDocument.DisplayName   ;


                           if not NxIsBlank(AInput.S['Msg']) then begin
                                      iSendmsg(AContext.GetObjectSpace, mOutputDocument , mOutputDocumentClsid,
                                                                      mOutputDocument.DisplayName  + '-  byl vytvořen novy doklad ',     // popis
                                                                      ' Byl vytvořen novy doklad s číslem: ' + mOutputDocument.DisplayName ,                          // tělo
                                                                      mMsgUser_ID ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
                           end;


                           if not NxIsBlank(AInput.S['Email']) then begin
                                if not NxIsBlank(AInput.S['ReportID']) then mFile:=iPrintDocument(mOutputDocument,AInput.S['ReportID']) else mFile:='';

                                mstring:=iSendMailx(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','#300000001', mFile,mDivision_ID,mOutputDocument);
                           end;


                                  Result:='{';

                                Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                Result:=Result + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                  Result:=Result + '"ID" :"' + mOutputDocument.oid+ '",' + chr(10);
                                  Result:=Result + '"New" :"' + mOutputDocument.DisplayName+ '",' + chr(10) ;
                                  Result:=Result + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                Result:=Result + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                Result:=Result + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                Result:=Result + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                Result:=Result + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                            Result:=Result + '}'  ;
                  end ;
            end else begin


                                            Result:=Result + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result:=Result + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                              Result:=Result + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result:=Result + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '" neobsahuje řádky, je prázdný,' + chr(10) ;
                                              Result:=Result + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                            Result:=Result + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                            Result:=Result + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                            Result:=Result + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                            Result:=Result + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                                Result:=Result + '}'  ;

            end;
      end;
  finally
          mImportdocuments.free;
          mImportRows.free;
          mOtherRows.free;
          mOtherBatches.free;
          mImportBatches.free;
          mSelectedRows.free;
  end;



end;









function POST_APINxSQL_String(AContext: TNxContext; Astring: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i: integer;
  mQuery:string;
  mTyp,mFields,mpodminka,mtable:string;
  AInput:TJSONSuperObject;
begin
  AInput:=TJSONSuperObject.create;
  try

      AInput:= TJSONSuperObject.ParseString(astring,true);
          mTyp := AInput.S['Typ'];
          mtable:= AInput.S['Table'];
          mFields := AInput.S['Fields'];
          mPodminka := AInput.S['Podminka'];

           if mtyp='SELECT' then begin
               mr:=tstringlist.create;
               try
                  AContext.SQLSelect(mTyp + ' ' + mFields + ' from ' + mtable + ' where ' + mPodminka,mr);
                  if mr.Count>0 then begin
                     result:= result + NxSearchReplace(mr.Strings[0],'"','',[srAll]) ;
                  end;

               finally
                   mr.free;
               end;
            end;

            if mtyp='UPDATE' then begin
                i:=AContext.SQLExecute(mTyp + ' ' + mtable + ' SET ' + mFields + ' where ' + mPodminka);
                result:= IntToStr(i) ;
                //result:=(mTyp + ' ' + mtable + ' SET ' + mFields + ' where ' + mPodminka);
            end;
  finally
     AInput.Free;
  end;
end;

function POST_APINxSQL_Strings(AContext: TNxContext; Astring: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i: integer;
  mQuery:string;
  mTyp,mFields,mpodminka,mtable:string;
  AInput:TJSONSuperObject;
begin
  AInput:=TJSONSuperObject.create;
  try

      AInput:= TJSONSuperObject.ParseString(astring,true);
          mTyp := AInput.S['Typ'];
          mtable:= AInput.S['Table'];
          mFields := AInput.S['Fields'];
          mPodminka := AInput.S['Podminka'];

           if mtyp='SELECT' then begin
               mr:=tstringlist.create;
               try
                  AContext.SQLSelect(mTyp + ' ' + mFields + ' from ' + mtable + ' where ' + mPodminka,mr);
                  if mr.Count>0 then begin
                       for i:=0 to mr.count-1 do begin
                           result:= result + NxSearchReplace(mr.Strings[i],'"','',[srAll]) ;
                           if i<>mr.count-1 then result:= result +chr(13)+chr(10)
                       end;
                    end;


                  if mr.Count>0 then begin
                     result:= mr.Strings[0] ;
                  end;

               finally
                   mr.free;
               end;
            end;


  finally
     AInput.Free;
  end;
end;
function GetHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
    if not VarIsType(WinHttpRequest, varDispatch) then begin
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    end;
    Result:=True;
  except
    Result := False;
    OutputDebugString(ExceptionMessage);
    WinHttpRequest := nil;
  end;
end;

 function APICallString(os: TNxCustomObjectSpace; mTyp: string;mUrl: string;mstring:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
begin
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mstring);
              if mStatus then begin
                    if copy(FloatToStr(mWinHTTP.Status),1,1)='2' then begin
                         result:= mWinHTTP.ResponseText
                    end else begin
                        result:= mWinHTTP.ResponseText ;
                    end;
              end else begin
              result:= mWinHTTP.ResponseText ;
              end;

        end;
      finally
      end;

end;


function APINxSQL_String(os:TNxCustomObjectSpace;mtarget:string;mtype:string;mfields:string;mtable:string;mwhere:string):string;
var
mquery:string;
begin

 if Trim(UpperCase(mtype))='SELECT' then begin
         mQuery:='{';
                                      mQuery:=mQuery +'"Typ": "SELECT",';
                                      mQuery:=mQuery +'"Target": "'+ mtarget + '", ';
                                      mQuery:=mQuery +'"Table": "'+ mtable + '", ';
                                      mQuery:=mQuery +'"Fields": "'+ mfields + '", ';
                                       mQuery:=mQuery +'"Podminka": "' + mwhere + '" } ' ;
      result:=APICallString(os,'POST',mtarget +'script/Synchronizace_testdotazapismazat/libs/APINxSQL_String',mQuery, false);

  end;
  if Trim(UpperCase(mtype))='UPDATE' then begin
         mQuery:='{';
                                     mQuery:=mQuery +'"Typ": "UPDATE",';
                                      mQuery:=mQuery +'"Target": "'+ mtarget + '", ';
                                      mQuery:=mQuery +'"Table": "'+ mtable + '", ';
                                      mQuery:=mQuery +'"Fields": "'+ mfields + '", ';
                                       mQuery:=mQuery +'"Podminka": "' + mwhere + '" } ' ;
      result:=APICallString(os,'POST',mtarget +'script/Synchronizace_testdotazapismazat/libs/APINxSQL_String',mQuery, false);
  end;
end;

function APINxSQL_Strings(os:TNxCustomObjectSpace;mtarget:string;mtype:string;mfields:string;mtable:string;mwhere:string):String;
var
mquery:string;
begin

 if Trim(UpperCase(mtype))='SELECT' then begin
         mQuery:='{';
                                      mQuery:=mQuery +'"Typ": "SELECT",';
                                      mQuery:=mQuery +'"Target": "'+ mtarget + '", ';
                                      mQuery:=mQuery +'"Table": "'+ mtable + '", ';
                                      mQuery:=mQuery +'"Fields": "'+ mfields + '", ';
                                       mQuery:=mQuery +'"Podminka": "' + mwhere + '" } ' ;
      result:=APICallString(os,'POST',mtarget +'script/Synchronizace_testdotazapismazat/libs/APINxSQL_String',mQuery, false);

  end;

end;





Function NxGetAPIPieceList(msite:TSiteForm;self:TNxCustomBusinessObject):string;
var
  mDocQueryPieceList,mDocQueryPieceListID:string;
  mID:string;
  mNewQueryID:string;
 mMonRows,mMonBAtch,mRowsPictures,mRowsMaterials,mRowsMobileCompetences:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mParseListValue:tstringlist;
 iRow,IBatch,iCompetences,iMaterials,iMobileCompetences,iRowsPictures:integer;
 mDocrowbatchList,mx:tstringlist;
 mPomocPrice:double;
 mtarget:string;
 mQuery:string;
 mString:string;
begin

 mtarget:='';



                                                                // doklad
                                                                mDocQueryPieceList:= '{'  ;
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"ID": "' +                           Self.OID +'", '                                                            +chr(10);
                                                                //mDocQueryPieceList:=mDocQueryPieceList +'"DocQueue_ID": "' +                  Self.GetFieldValueAsString('Docqueue_ID') +'", '                  ;
                                                                // DocQueryWithBatch:=mDocQueryWithBatch +'"Customer": { ';
                                                                // mDocQueryWithBatch:=mDocQueryWithBatch +'}';


                                                                mDocQueryPieceList:=mDocQueryPieceList +'"busorder_id": "' +                  Self.GetFieldValueAsString('busorder_id') +'", '   +chr(10); ;
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"busproject_id": "' +                Self.GetFieldValueAsString('busproject_id') +'", '  +chr(10);  ;
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"bustransaction_id": "' +            Self.GetFieldValueAsString('bustransaction_id') +'", '   +chr(10); ;
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"Created$DATE": "' +                 NxFloatToIBStr(Self.GetFieldValueAsDateTime('Created$DATE')) +'", '   +chr(10); ;
                                                                //mDocQueryPieceList:=mDocQueryPieceList +'"Created$DATE": "' +                 FormatDateTime('YYYY-MM-DD',Self.GetFieldValueAsDateTime('Created$DATE')) +'", ' ;


                                                                mDocQueryPieceList:=mDocQueryPieceList +'"name": "' +                         Self.GetFieldValueAsString('name') +'", '   +chr(10); ;
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"note": "' +                         Self.GetFieldValueAsString('note') +'", '    +chr(10);;
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"developmentcosts": "' +             NxFloatToIBStr(Self.GetFieldValueAsFloat('DevelopmentCosts')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"PieceListType": "' +                '1' +'", '    +chr(10);
                                                                //mDocQueryPieceList:=mDocQueryPieceList +'"PieceListType": "' +                inttostr(Self.GetFieldValueAsInteger('PieceListType')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"PlanedCooperation": "' +            NxFloatToIBStr(Self.GetFieldValueAsFloat('PlanedCooperation')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"PlanedCoopMat": "' +                NxFloatToIBStr(Self.GetFieldValueAsFloat('PlanedCoopMat')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"PriceForReceipt ": "' +             NxFloatToIBStr(Self.GetFieldValueAsFloat('PriceForReceipt')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"Quantity": "' +                     NxFloatToIBStr(Self.GetFieldValueAsFloat('Quantity')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"QUnit": "' +                        (Self.GetFieldValueAsString('QUnit')) +'", '    +chr(10);
                                                                //mDocQueryPieceList:=mDocQueryPieceList +'"Released$DATE": "' +                (Self.GetFieldValueAsString('Released$DATE')) +'", '    +chr(10);
                                                                //mDocQueryPieceList:=mDocQueryPieceList +'"ReleasedBy_ID": "' +                (Self.GetFieldValueAsString('ReleasedBy_ID')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"RoutineStoreCard_ID": "' +          (Self.GetFieldValueAsString('RoutineStoreCard_ID')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"StoreCard_ID": "' +                (Self.GetFieldValueAsString('StoreCard_ID')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"UnitQuantity": "' +                (Self.GetFieldValueAsString('UnitQuantity')) +'", '    +chr(10);
                                                                mDocQueryPieceList:=mDocQueryPieceList +'"picture_id": "' +                (Self.GetFieldValueAsString('picture_id')) +'", '    +chr(10);








                                                         mRowsPictures := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('pictures'));
                                                                                                  mDocQueryPieceList:=mDocQueryPieceList +'"pictures": [  ';
                                                                                                      for iRowsPictures := 0 to mRowsPictures.Count-1 do begin
                                                                                                          mDocQueryPieceList:=mDocQueryPieceList +'{ ' ;
                                                                                                             mDocQueryPieceList:=mDocQueryPieceList +'"pID":"' +                           (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                                             mDocQueryPieceList:=mDocQueryPieceList +'"Posindex":"' +                      (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('Posindex'))+'", '   +chr(10);
                                                                                                             mDocQueryPieceList:=mDocQueryPieceList +'"PLMPicture_ID":"' +                 (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('PLMPicture_ID'))+'", '   +chr(10);
                                                                                                          mDocQueryPieceList:=mDocQueryPieceList +'}  ';
                                                                                                          if iRowsPictures <> mRowsPictures.Count-1 then  mDocQueryPieceList:=mDocQueryPieceList +','+chr(10) else mDocQueryPieceList:=mDocQueryPieceList +chr(10);
                                                                                                       end ;
                                                                                                      mDocQueryPieceList:=mDocQueryPieceList +'], ';

                                                                                                  mDocQueryPieceList:=mDocQueryPieceList +chr(10);











                                                                mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));

                                                                     // řádky   }
                                                                     mDocQueryPieceList:=mDocQueryPieceList +'"Rows": [  ';
                                                                              for iRow := 0 to mMonRows.Count-1 do begin
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'{ ' ;
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"id":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"posindex": ' +          IntToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex')) +', '                  ;

                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"allowmix":"' +           NxBoolToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsBoolean('AllowMix'))+'", '   +chr(10);
                                                                                              //mDocQueryPieceList:=mDocQueryPieceList +'"Bulkissue":"' +        IntToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('Bulkissue'))+'", '   +chr(10);
                                                                                              //mDocQueryPieceList:=mDocQueryPieceList +'"CostingMethod":"' +    inttostr(mMonRows.BusinessObject[iRow].GetFieldValueAsint('CostingMethod'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"CostingPrice":"' +       NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('CostingPrice'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Description":"' +        (mMonRows.BusinessObject[iRow].GetFieldValueAsString('Description'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"DoNotMultiply":"' +      NxBoolToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsBoolean('DoNotMultiply'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Issue":"' +              inttostr(mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('Issue'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Note":"' +               (mMonRows.BusinessObject[iRow].GetFieldValueAsString('Note'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Phase_ID":"' +           (mMonRows.BusinessObject[iRow].GetFieldValueAsString('Phase_ID'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Quantity":"' +           NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'))+'", '   +chr(10);
                                                                                              //mDocQueryPieceList:=mDocQueryPieceList +'"QuantityRounding ":"' +  (mMonRows.BusinessObject[iRow].GetFieldValueAsString('QuantityRounding'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Qunit":"' +              mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit')+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"RecordsSN":"' +          NxBoolToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsBoolean('RecordsSN'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"Replaceable":"' +        NxBoolToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsBoolean('Replaceable'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"StoreCard_ID":"' +       (mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"SupposedStore_ID":"' +   (mMonRows.BusinessObject[iRow].GetFieldValueAsString('SupposedStore_ID'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"UnitQuantity":"' +       NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('UnitQuantity'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"UnitRate":"' +           NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('UnitRate'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'"WastePercentage":"' +    NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('WastePercentage'))+'", '   +chr(10);
                                                                                              mDocQueryPieceList:=mDocQueryPieceList +'}  ';










                                                                                              if iRow <> mMonRows.Count-1 then  mDocQueryPieceList:=mDocQueryPieceList +','+chr(10) else mDocQueryPieceList:=mDocQueryPieceList +chr(10);

                                                                              end;
                                                                  // ukončení řádku
                                                                  mDocQueryPieceList:=mDocQueryPieceList +' ] ';

                                                       // ukončení dokladu
                                                       mDocQueryPieceList:=mDocQueryPieceList +' } '+chr(10);





result:= mDocQueryPieceList;
end;











Function NxGetAPIRoutine(msite:TSiteForm;self:TNxCustomBusinessObject):string;
var

  mDocQueryRoutine,mDocQueryRoutineID:string;
  mID:string;
  mNewQueryID:string;
 mMonRows,mMonBAtch,mRowsCompetences,mRowsMaterials,mRowsMobileCompetences,mRowsPictures:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mParseListValue:tstringlist;
 iRow,IBatch,iCompetences,iMaterials,iMobileCompetences,iRowsPictures:integer;
 mDocrowbatchList,mx:tstringlist;
 mPomocPrice:double;
 mtarget:string;
 mQuery:string;
 mString:string;
 mStream: TMemoryStream;
begin
 mStream := TMemoryStream.Create;
 mtarget:='';



                                                                // doklad
                                                                mDocQueryRoutine:= '{'  ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"ID": "' +                           Self.OID +'", '                                                            +chr(10);
                                                                //mDocQueryRoutine:=mDocQueryRoutine +'"DocQueue_ID": "' +                  Self.GetFieldValueAsString('Docqueue_ID') +'", '                  ;
                                                                // DocQueryWithBatch:=mDocQueryWithBatch +'"Customer": { ';
                                                                // mDocQueryWithBatch:=mDocQueryWithBatch +'}';


                                                                mDocQueryRoutine:=mDocQueryRoutine +'"BusOrder_ID": "' +                  Self.GetFieldValueAsString('busorder_id') +'", '   +chr(10); ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"BusProject_ID": "' +                Self.GetFieldValueAsString('busproject_id') +'", '  +chr(10);  ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"BusTransaction_ID": "' +            Self.GetFieldValueAsString('bustransaction_id') +'", '   +chr(10); ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CreatedBy_ID": "' +                 Self.GetFieldValueAsString('createdby_id') +'", '   +chr(10); ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Created$DATE": "' +                 NxFloatToIBStr(Self.GetFieldValueAsDateTime('Created$DATE')) +'", '   +chr(10); ;
                                                                //mDocQueryRoutine:=mDocQueryRoutine +'"Created$DATE": "' +                 FormatDateTime('YYYY-MM-DD',Self.GetFieldValueAsDateTime('Created$DATE')) +'", '   +chr(10); ;

                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Name": "' +                         Self.GetFieldValueAsString('name') +'", '   +chr(10); ;

                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Note": "' +                         NxSearchReplace(Self.GetFieldValueAsString('note'),'"','',[srAll])  +'", '    +chr(10);;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Quantity": "' +                     NxFloatToIBStr(Self.GetFieldValueAsFloat('quantity')) +'", '    +chr(10);;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"QUnit": "' +                        Self.GetFieldValueAsString('qunit') +'", '    +chr(10);;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"RoutineType_ID": "' +               Self.GetFieldValueAsString('routinetype_id') +'", '   +chr(10); ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"StoreCard_ID": "' +                 Self.GetFieldValueAsString('storecard_id') +'", '   +chr(10); ;
                                                                //mDocQueryRoutine:=mDocQueryRoutine +'"unitquantity": "' +                 Self.GetFieldValueAsString('unitquantity') +'", '   +chr(10);;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"UnitRate": "' +                     NxFloatToIBStr(Self.GetFieldValueAsFloat('unitrate')) +'", '   +chr(10); ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"X_Pristup": "' +                    Self.GetFieldValueAsString('x_pristup') +'", '   +chr(10); ;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"X_StoreCard_ID": "' +               Self.GetFieldValueAsString('x_storecard_id') +'", '    +chr(10);;
                                                                mDocQueryRoutine:=mDocQueryRoutine +'"X_Verze": "' +                      Self.GetFieldValueAsString('x_verze') +'", '    +chr(10);;



                                                                mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));

                                                                     // řádky   }
                                                                     mDocQueryRoutine:=mDocQueryRoutine +'"Rows": [  ';
                                                                              for iRow := 0 to mMonRows.Count-1 do begin
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'{ ' ;
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"PosIndex": ' +          IntToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex')) +', '                  ;
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Batch":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('batch'))+'", '   +chr(10);


                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Cooperation":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('cooperation'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Finished":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('finished'))+'", '   +chr(10);


                                                                                              //mStream.SetBytes(DecodeBase64(mMonRows.BusinessObject[iRow].GetFieldValueAsString('note')));
                                                                                              //mDocQueryRoutine:=mDocQueryRoutine +'"NoteBase64":"' +               NxReadString(mStream)+'", '   +chr(10);



                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Note":"' +                NxSearchReplace(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Note'),'"','',[srAll])+'", '   +chr(10);

                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Ongoing":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('ongoing'))+'", '   +chr(10);
                                                                                              //mDocQueryRoutine:=mDocQueryRoutine +'"parttime":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('parttime'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Phase_ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('phase_id'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Planned":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('planned'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Polymorphism":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('polymorphism'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"ProductPhase_ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('productphase_id'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"ProtocolFileNameExpr":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('protocolfilenameexpr'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Quantum":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('quantum'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"QuantumMultiplier":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('quantummultiplier'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"SalaryClass_ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('salaryclass_id'))+'", '   +chr(10);
                                                                                              //mDocQueryRoutine:=mDocQueryRoutine +'"setuptime":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('setuptime'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"ShortestEpisode":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('shortestepisode'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"SynergyRate":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('synergyrate'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"TAC":"' +                NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('tac'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"TACUnit":"' +              NxFloatToIBStr  (mMonRows.BusinessObject[iRow].GetFieldValueAsfloat('tacunit'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"TBC":"' +                NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('tbc'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"TBCUnit":"' +                NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('tbcunit'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"Title":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('title'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"UnitTAC":"' +                NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('unittac'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"UnitTBC":"' +                NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('unittbc'))+'", '   +chr(10);
                                                                                              //mDocQueryRoutine:=mDocQueryRoutine +'"usersmessage":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('usersmessage'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"WorkPlace_ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('workplace_id'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"X_Barevnost_ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('x_barevnost_id'))+'", '   +chr(10);
                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'"X_Operation_ID":"' +                (mMonRows.BusinessObject[iRow].GetFieldValueAsString('x_operation_id'))+'" ,'   +chr(10);
                                                                                             // mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                  // obrázky
                                                                                                   mRowsPictures := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('Rows'));
                                                                                                  mDocQueryRoutine:=mDocQueryRoutine +'"Rows": [  ';
                                                                                                      for iRowsPictures := 0 to mRowsPictures.Count-1 do begin
                                                                                                          mDocQueryRoutine:=mDocQueryRoutine +'{ ' ;
                                                                                                             mDocQueryRoutine:=mDocQueryRoutine +'"pID":"' +                           (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                                             mDocQueryRoutine:=mDocQueryRoutine +'"Posindex":"' +                      (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('Posindex'))+'", '   +chr(10);
                                                                                                             mDocQueryRoutine:=mDocQueryRoutine +'"PLMPicture_ID":"' +                 (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('PLMPicture_ID'))+'", '   +chr(10);
                                                                                                             mDocQueryRoutine:=mDocQueryRoutine +'"Name":"' +                          (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('PLMPicture_ID.Name'))+'" '   +chr(10);
                                                                                                             //mDocQueryRoutine:=mDocQueryRoutine +'"PLMPicture_ID_Title":"' +                  (mRowsPictures.BusinessObject[iRowsPictures].GetFieldValueAsString('PLMPicture_ID.Title'))+'" '   +chr(10);
                                                                                                          mDocQueryRoutine:=mDocQueryRoutine +'}  ';
                                                                                                          if iRowsPictures <> mRowsPictures.Count-1 then  mDocQueryRoutine:=mDocQueryRoutine +','+chr(10) else mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                       end ;
                                                                                                      mDocQueryRoutine:=mDocQueryRoutine +'], ';

                                                                                                 // mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                  mRowsCompetences := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('Competences'));
                                                                                                  mDocQueryRoutine:=mDocQueryRoutine +' "Competences": [ ';
                                                                                                  for iCompetences := 0 to mRowsCompetences.Count-1 do begin
                                                                                                         mDocQueryRoutine:=mDocQueryRoutine +'{ ' ;
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CalculateTBC":"' +                (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('CalculateTBC'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CompetenceQuantity":"' +          (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('CompetenceQuantity'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"cID":"' +                         (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Competence_ID":"' +              (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('Competence_ID'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CompetenceType":"' +             (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('CompetenceType'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CompetenceValue":"' +             (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('CompetenceValue'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"InputValue ":"' +                 (mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsString('InputValue'))+'", '   +chr(10);
                                                                                                               // mDocQueryRoutine:=mDocQueryRoutine +'"PosIndex ":"' +                   inttostr(mRowsCompetences.BusinessObject[iCompetences].GetFieldValueAsinteger('PosIndex'))+'", '   +chr(10);
                                                                                                         mDocQueryRoutine:=mDocQueryRoutine +'}  ';
                                                                                                         if iCompetences <> mRowsCompetences.Count-1 then  mDocQueryRoutine:=mDocQueryRoutine +','+chr(10) else mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                  end;
                                                                                                      mDocQueryRoutine:=mDocQueryRoutine +'],';

                                                                                                  mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                      mRowsMaterials := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('Materials'));
                                                                                                  mDocQueryRoutine:=mDocQueryRoutine +'"Materials": [ ';
                                                                                                  for iMaterials := 0 to mRowsMaterials.Count-1 do begin
                                                                                                         mDocQueryRoutine:=mDocQueryRoutine +'{ ' ;

                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"AllQuantity":"' +               (mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsString('AllQuantity'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"mID":"' +                       (mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"DoNotMultiply":"' +             (mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsString('DoNotMultiply'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"PosIndex":"' +                  inttostr(mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsInteger('PosIndex'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Quantity":"' +                  NxFloatToIBStr(mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsFloat('Quantity'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"QUnit":"' +                     (mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsString('QUnit'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"StoreCard_ID":"' +              (mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsString('StoreCard_ID'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"UnitQuantity":"' +              (mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsString('UnitQuantity'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"UnitRate":"' +                  NxFloatToIBStr(mRowsMaterials.BusinessObject[iMaterials].GetFieldValueAsFloat('UnitRate'))+'" '   +chr(10);

                                                                                                         mDocQueryRoutine:=mDocQueryRoutine +'}  ';
                                                                                                         if iMaterials <> mRowsMaterials.Count-1 then  mDocQueryRoutine:=mDocQueryRoutine +','+chr(10) else mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                  end;
                                                                                                   mDocQueryRoutine:=mDocQueryRoutine +'],';

                                                                                                   mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                       mRowsMobileCompetences := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('MobileCompetences'));
                                                                                                  mDocQueryRoutine:=mDocQueryRoutine +'"MobileCompetences": [ ';
                                                                                                  for iMobileCompetences := 0 to mRowsMobileCompetences.Count-1 do begin
                                                                                                         mDocQueryRoutine:=mDocQueryRoutine +'{ ' ;

                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CalculateTBC":"' +              (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('CalculateTBC'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Competence_ID":"' +            (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('Competence_ID'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"mcID":"' +                        (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('ID'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CompetenceQuantity":"' +        (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('CompetenceQuantity'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CompetenceType":"' +            (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('CompetenceType'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"CompetenceValue":"' +           (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('CompetenceValue'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"InputValue":"' +                (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('InputValue'))+'", '   +chr(10);
                                                                                                                mDocQueryRoutine:=mDocQueryRoutine +'"Overlap":"' +                   (mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsString('Overlap'))+'", '   +chr(10);
                                                                                                               // mDocQueryRoutine:=mDocQueryRoutine +'"PosIndex ":"' +                 inttostr(mRowsMobileCompetences.BusinessObject[iMobileCompetences].GetFieldValueAsinteger('PosIndex '))+'", '   +chr(10);

                                                                                                         mDocQueryRoutine:=mDocQueryRoutine +'}  ';
                                                                                                         if iMobileCompetences <> mRowsMobileCompetences.Count-1 then  mDocQueryRoutine:=mDocQueryRoutine +','+chr(10) else mDocQueryRoutine:=mDocQueryRoutine +chr(10);
                                                                                                  end;
                                                                                                   mDocQueryRoutine:=mDocQueryRoutine +']';



                                                                                              mDocQueryRoutine:=mDocQueryRoutine +'}  ';
                                                                                              if iRow <> mMonRows.Count-1 then  mDocQueryRoutine:=mDocQueryRoutine +','+chr(10) else mDocQueryRoutine:=mDocQueryRoutine +chr(10);

                                                                              end;
                                                                  // ukončení řádku
                                                                  mDocQueryRoutine:=mDocQueryRoutine +' ] ';

                                                       // ukončení dokladu
                                                      mDocQueryRoutine:=mDocQueryRoutine +' } '+chr(10);





result:= mDocQueryRoutine;
end;










      Function NxGetAPIDocument(os:TNxCustomObjectSpace;self:TNxCustomBusinessObject):string;
var

  mDocQueryWithBatch,mDocQueryWithBatchID:string;
  mID:string;
  mNewQueryID:string;
 mMonRows,mMonBAtch:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mParseListValue:tstringlist;
 iRow,IBatch:integer;
 mDocrowbatchList,mx:tstringlist;
 mPomocPrice:double;
 mtarget:string;
 mQuery:string;
 mString:string;
begin

 mtarget:='';
                     if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                       end else begin
                                                                mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                         end;



                                                                // doklad
                                                                mDocQueryWithBatch:= '{'  ;
                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"ID": "' +                                    Self.OID +'", '                                                            +chr(10);
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"DocQueue_ID": "' +                         Self.GetFieldValueAsString('Docqueue_ID') +'", '                  ;

                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"DocNumber": "' +                           Self.GetFieldValueAsString('DisplayName') +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"DocDate": "' +                             NxFloatToIBStr(Self.GetFieldValueAsDateTime('DocDate$Date')) +'", '              +chr(10);

                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"TradeType": ' +                            IntToStr(Self.GetFieldValueAsinteger('Tradetype')) +', '                 ;
                                                                   mQuery:=mQuery +'"IntrastatDeliveryTerm_ID":"' +                                     Self.GetFieldValueAsString('IntrastatDeliveryTerm_ID') +'", '                  ;
                                                                            mQuery:=mQuery +'"IntrastatTransactionType_ID":"' +                         Self.GetFieldValueAsString('IntrastatTransactionType_ID') +'", '                  ;
                                                                            mQuery:=mQuery +'"IntrastatTransportationType_ID":"' +                      Self.GetFieldValueAsString('IntrastatTransportationType_ID') +'", '                  ;
                                                                            mQuery:=mQuery +'"Country_ID": "' +                                         Self.GetFieldValueAsString('Country_ID') +'", '                  ;



                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Firm_ID":"'  +                             Self.GetFieldValueAsString('Firm_ID') +'", '                              ;
                                                                  if ((self.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (self.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                        mDocQueryWithBatch:=mDocQueryWithBatch +'"Externalnumber":" ' +                      Self.GetFieldValueAsString('Externalnumber') +'", '                  ;
                                                                        mDocQueryWithBatch:=mDocQueryWithBatch +'"X_poznamka": "' +                         Self.GetFieldValueAsString('X_poznamka') +'", '                  +chr(10);


                                                                  end;

                                                                  if ((self.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (self.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Currency_ID":"' +                         Self.GetFieldValueAsString('Currency_ID') +'", '                 +chr(10) ;
                                                                  end else begin
                                                                      if (self.CLSID<>'050I5SAOS3DL3ACU03KIU0CLP4') then begin
                                                                          mDocQueryWithBatch:=mDocQueryWithBatch +'"Currency_ID":"' +                         '0000EUR000' +'", '                 +chr(10) ;
                                                                      end;
                                                                  end;








                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Description": "' +                         Self.GetFieldValueAsString('Description') +'", '                  +chr(10);


                                                                {
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Docid": "' +                              ''  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Docqueue": "' +                           Self.GetFieldValueAsString('Docqueue_ID.code')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Ordnumber": "' +                          ''  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Period": "' +                             Self.GetFieldValueAsString('Period_ID.code')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Division": "' +                           ''  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Bank_code": "' +                          Self.GetFieldValueAsString('BankAccount_ID.code')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Obchod": "' +                             ''  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Obchodnik": "' +                          ''  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"PersonId": "' +                           Self.GetFieldValueAsString('PersonId_ID.code')   +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Eid": "' +                                Self.GetFieldValueAsString('Firm_ID.X_EID')   +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Customer": {  ';
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"VATPayor": "' +                    Self.GetFieldValueAsString('Firm_ID.VATPayor')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Name": "' +                        Self.GetFieldValueAsString('Firm_ID.Name')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"AllName": "' +                     Self.GetFieldValueAsString('Firm_ID.AllName')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"OrgIdentNumber": "' +              Self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"FirmOffice": "' +                  Self.GetFieldValueAsString('Firm_ID.FirmOffice')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"AcceptOrderEmail": "' +            Self.GetFieldValueAsString('Firm_ID.AcceptOrderEmail')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"ResidenceAddress": {  ';
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"Street": "' +                        Self.GetFieldValueAsString('ResidenceAddres_ID.Street')   +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"City": "' +                          Self.GetFieldValueAsString('ResidenceAddres_ID.City')  +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"PostCode": "' +                      Self.GetFieldValueAsString('ResidenceAddres_ID.PostCode')  +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"CountryCode": "' +                   Self.GetFieldValueAsString('ResidenceAddres_ID.CountryCode')  +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"Tel1": "' +                          Self.GetFieldValueAsString('ResidenceAddres_ID.Tel1')  +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"Tel2": "' +                          Self.GetFieldValueAsString('ResidenceAddres_ID.Tel2')  +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'"email": "' +                         Self.GetFieldValueAsString('ResidenceAddres_ID.email')  +'", '        ;
                                                                                                mDocQueryWithBatch:=mDocQueryWithBatch +'} { ';
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'}  {';
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"DeliveryAddress": {  ';
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Name": "' +                           Self.GetFieldValueAsString('X_DeliveryAddress_ID.Name')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Location": "' +                       Self.GetFieldValueAsString('X_DeliveryAddress_ID.Location')   +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Street": "' +                         Self.GetFieldValueAsString('X_DeliveryAddress_ID.Street')   +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"City": "' +                           Self.GetFieldValueAsString('X_DeliveryAddress_ID.City')  +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"PostCode": "' +                       Self.GetFieldValueAsString('X_DeliveryAddress_ID.PostCode')   +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Country": "' +                        Self.GetFieldValueAsString('X_DeliveryAddress_ID.Country')   +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Tel1": "' +                           Self.GetFieldValueAsString('X_DeliveryAddress_ID.Tel1')   +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'"Tel2": "' +                           Self.GetFieldValueAsString('X_DeliveryAddress_ID.Tel2')   +'", '        ;
                                                                                      mDocQueryWithBatch:=mDocQueryWithBatch +'}  {';
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"VATDocument": "' +                           Self.GetFieldValueAsString('VATDocument')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"VATRounding": "' +                           Self.GetFieldValueAsString('VATRounding')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"TotalRounding": "' +                         Self.GetFieldValueAsString('TotalRounding')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"RoundingAmount": "' +                        Self.GetFieldValueAsString('RoundingAmount')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"ExternalNumber": "' +                        Self.GetFieldValueAsString('ExternalNumber')  +'", '        ;

                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"TradeType": "' +                             Self.GetFieldValueAsString('TradeType')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"CurrencyCode": "' +                          Self.GetFieldValueAsString('CurrencyCode')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"CountryCode": "' +                           Self.GetFieldValueAsString('CountryCode') +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"CurrRate": "' +                              Self.GetFieldValueAsString('CurrRate')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"AmountWithoutVAT": "' +                      Self.GetFieldValueAsString('AmountWithoutVAT')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Amount": "' +                                Self.GetFieldValueAsString('Amount') +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"LocalTAmountWithoutVAT": "' +                Self.GetFieldValueAsString('LocalTAmountWithoutVAT')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"LocalTAmount": "' +                          Self.GetFieldValueAsString('LocalTAmount')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"PricesWithVAT": "' +                         Self.GetFieldValueAsString('PricesWithVAT')  +'", '        ;

                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"IntrastatDeliveryTerm": "' +                 Self.GetFieldValueAsString('IntrastatDeliveryTerm')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"IntrastatTransactionType": "' +              Self.GetFieldValueAsString('IntrastatTransactionType')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"IntrastatTransportationType": "' +           Self.GetFieldValueAsString('IntrastatTransportationType')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"DeliveryType": "' +                          Self.GetFieldValueAsString('DeliveryType')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"PaymentType": "' +                           Self.GetFieldValueAsString('PaymentType')  +'", '        ;
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"KonstSymbol": "' +                           Self.GetFieldValueAsString('KonstSymbol')  +'", '        ;

                                                                 }


                                                  mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));

                                                                 // řádky
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"Rows": [  ';
                                                                              for iRow := 0 to mMonRows.Count-1 do begin
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'{ ' ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"id":"' +                            		  mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID')+'", '   +chr(10);
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex')) +', '                  ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"RowType": ' +                             IntToStr(mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('RowType')) +', '                  ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Text":"' +                            		mMonRows.BusinessObject[iRow].GetFieldValueAsString('Text')+'", ' ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Store_ID":"' +                            mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID')+'", ' ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Storecard_ID":"' +                        mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID')+'", '   ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Storecard_EAN":"' +                       mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID.EAN')+'", '   ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Storecard_Code":"' +                      mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID.Code')+'", '   ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Storecard_Name":"' +                      mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID.Name')+'", '   ;

                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity')) +', '                  ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"QUnit":"' +                               mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit')+'", ' +chr(10)  ;

                                                                                              {
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"AcceptPrices":"' +                       mMonRows.BusinessObject[iRow].GetFieldValueAsString('AcceptPrices') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"Packed":"' +                             mMonRows.BusinessObject[iRow].GetFieldValueAsString('Packed') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"PrintLink":"' +                          mMonRows.BusinessObject[iRow].GetFieldValueAsString('PrintLink') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"Commodity": {  ';
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"EAN":"' +                           mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN') +'", ' +chr(10)  ;
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"Name":"' +                          mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.Name') +'", ' +chr(10)  ;
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"ForeignName":"' +                   mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.ForeignName') +'", ' +chr(10)  ;

                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'}  {';
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"Note":"' +                               mMonRows.BusinessObject[iRow].GetFieldValueAsString('Note') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"Discount":"' +                           mMonRows.BusinessObject[iRow].GetFieldValueAsString('Discount') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"VATRate":"' +                            mMonRows.BusinessObject[iRow].GetFieldValueAsString('VATRate') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"TAmountWithoutVAT":"' +                  mMonRows.BusinessObject[iRow].GetFieldValueAsString('TAmountWithoutVAT') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"TAmount":"' +                            mMonRows.BusinessObject[iRow].GetFieldValueAsString('TAmount') +'", ' +chr(10)  ; mDocQueryWithBatch:=mDocQueryWithBatch +'"QUnit":"' +                               '' +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"LocalTAmountWithoutVAT":"' +             mMonRows.BusinessObject[iRow].GetFieldValueAsString('LocalTAmountWithoutVAT') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"LocalTAmount":"' +                       mMonRows.BusinessObject[iRow].GetFieldValueAsString('LocalTAmount') +'", ' +chr(10)  ;
                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"ExternalSpecification":"' +              mMonRows.BusinessObject[iRow].GetFieldValueAsString('ExternalSpecification') +'", ' +chr(10)  ;

                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"Specification": {  ';
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"Jmeno":"' +                         mMonRows.BusinessObject[iRow].GetFieldValueAsString('Jmeno') +'", ' +chr(10)  ;
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"Telefon":"' +                       mMonRows.BusinessObject[iRow].GetFieldValueAsString('Telefon') +'", ' +chr(10)  ;
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"Osoba_id":"' +                      mMonRows.BusinessObject[iRow].GetFieldValueAsString('Osoba_id') +'", ' +chr(10)  ;
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"Vyska":"' +                         mMonRows.BusinessObject[iRow].GetFieldValueAsString('Vyska') +'", ' +chr(10)  ;
                                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"TG":"' +                            mMonRows.BusinessObject[iRow].GetFieldValueAsString('TG') +'", ' +chr(10)  ;

                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'}  {';
                                                                                              }

                                                                                               if (self.CLSID<>'050I5SAOS3DL3ACU03KIU0CLP4') then begin
                                                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"UnitPrice": ' +                       NxFloatToIBStr(NxRoundByValue(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('UnitPrice'),2,0.0001 )) +', '  ;
                                                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"TotalPrice": ' +                      NxFloatToIBStr(NxRoundByValue(mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('TotalPrice'),2,0.0001)) +', '                 +chr(10) ;
                                                                                                end else begin
                                                                                                  mx:=tstringlist.create;
                                                                                                  try
                                                                                                    self.ObjectSpace.SQLSelect('select (TAmountWithoutVAT/Quantity) from issuedinvoices2 where ProvideRow_ID =' + quotedstr( mMonRows.BusinessObject[iRow].oid),mx);
                                                                                                    if mx.count>0 then begin   // je fakturován
                                                                                                               mPomocPrice:= NxRoundByValue(NxIBStrToFloat(mx.strings[0]),2,0.001);
                                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"UnitPrice": ' +                           NxFloatToIBStr(NxRoundByValue(mPomocPrice,2,0.0001)) +', '  ;
                                                                                                               mDocQueryWithBatch:=mDocQueryWithBatch +'"TotalPrice": ' +                          NxFloatToIBStr(NxRoundByValue((mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('quantity') * mPomocPrice),2,0.0001)) +', '                 +chr(10) ;
                                                                                                    end else begin
                                                                                                           self.ObjectSpace.SQLSelect('select (TAmountWithoutVAT/Quantity) from Receivedorders2 where ID =' + quotedstr( mMonRows.BusinessObject[iRow].GetFieldValueAsString('ProvideRow_ID')),mx);
                                                                                                           if mx.count>0 then begin
                                                                                                                  mPomocPrice:= NxRoundByValue(NxIBStrToFloat(mx.strings[0]),2,0.001);
                                                                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"UnitPrice": ' +                           NxFloatToIBStr(NxRoundByValue(mPomocPrice,2,0.0001)) +', '  ;
                                                                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"TotalPrice": ' +                          NxFloatToIBStr(NxRoundByValue((mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('quantity') * mPomocPrice),2,0.0001)) +', '                 +chr(10) ;
                                                                                                           end else begin
                                                                                                                          mQuery:=' { '
                                                                                                                           + '"expr": "NxGetStoreCardUnitPriceDef('
                                                                                                                                      + QuotedStr(self.GetFieldValueAsString('Firm_ID')) + ','
                                                                                                                                      + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID')) + ','
                                                                                                                                      + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID')) + ','
                                                                                                                                      + QuotedStr(self.GetFieldValueAsString('Firm_ID.Price_ID')) + ','
                                                                                                                                      + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('StoreCard_ID.MainUnitCode')) + ','
                                                                                                                                      + 'False' + ','
                                                                                                                                      + QuotedStr(self.GetFieldValueAsString('Currency_ID'))
                                                                                                                                      +')"'
                                                                                                                           +'}' ;
                                                                                                                  mString:=APICallString(self.ObjectSpace,'POST',mSourceAPI+'/qrexpr',mQuery, true);
                                                                                                                  mPomocPrice:=NxRoundByValue(NxIBStrToFloat(copy(mString,11,Length(mString)-11)),2,0.001);
                                                                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"UnitPrice": ' +                           NxFloatToIBStr(NxRoundByValue(mPomocPrice,2,0.0001)) +', '  ;
                                                                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +'"TotalPrice": ' +                          NxFloatToIBStr(NxRoundByValue((mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('quantity') * mPomocPrice),2,0.0001)) +', '                 +chr(10) ;
                                                                                                           end;

                                                                                                    end;

                                                                                                  finally
                                                                                                      mx.free;
                                                                                                  end;
                                                                                                end;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"Division_ID":"' +                         mMonRows.BusinessObject[iRow].GetFieldValueAsString('Division_ID')+'", '   ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"BusProject_ID":"' +                       mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID')+'", '  +chr(10) ;
                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +'"X_Providerow_ID":"' +                     mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID')+'", '  ;
                                                                                              if ((self.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (self.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                                   mDocQueryWithBatch:=mDocQueryWithBatch +'"X_Storedocuments2_ID":"' +                   mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Storedocuments2_ID')+'", '   +chr(10);
                                                                                              end;
                                                                                                          // šarže
                                                                                                          mDocQueryWithBatch:=mDocQueryWithBatch +chr(10);
                                                                                                          mDocQueryWithBatch:=mDocQueryWithBatch +'"docrowbatches": [  '+chr(10);
                                                                                                              // storedocument


                                                                                                              if ((self.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (self.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                                                        mMonBAtch := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('DocRowBatches'));
                                                                                                                        for iBatch := 0 to mMonBAtch.Count-1 do begin

                                                                                                                              API_GetOrCreateBatch(self.ObjectSpace,mtarget,mMonBAtch.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_ID'));


                                                                                                                             mDocQueryWithBatch:=mDocQueryWithBatch +'{ ';
                                                                                                                                    mDocQueryWithBatch:=mDocQueryWithBatch +'"Name":"' +                            		mMonBAtch.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_ID.Name')+'", '   ;
                                                                                                                                    mDocQueryWithBatch:=mDocQueryWithBatch +'"Quantity": ' +                            NxFloatToIBStr(mMonBAtch.BusinessObject[iBatch].GetFieldValueAsFloat('Quantity')) +' '                  ;
                                                                                                                                    mDocQueryWithBatch:=mDocQueryWithBatch +'} ';
                                                                                                                                    if iBatch <> mMonBAtch.Count-1 then  mDocQueryWithBatch:=mDocQueryWithBatch +', ' +chr(10) else mDocQueryWithBatch:=mDocQueryWithBatch +chr(10);

                                                                                                                        end;
                                                                                                              end;

                                                                                                              // op
                                                                                                              //NxShowSimpleMessage(self.CLSID,nil);
                                                                                                              if (self.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                                                                                   mDocrowbatchList:=TStringList.create;
                                                                                                                          self.ObjectSpace.SQLSelect('SELECT  sb.id,sb.Name,df.X_Quantity FROM DefRollData DF join Storebatches SB on sb.id=DF.X_Batches WHERE (DF.Hidden = ' + quotedstr('N') + ' ) AND (df.CLSID = '
                                                                                                                                                          + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' ) AND (DF.X_Parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID)+')',mDocrowbatchList);
                                                                                                                          try
                                                                                                                               if mDocrowbatchList.count>0 then begin
                                                                                                                                    for iBatch := 0 to mDocrowbatchList.Count-1 do begin
                                                                                                                                        mDocQueryWithBatch:=mDocQueryWithBatch +'{ ' ;
                                                                                                                                        mParseListValue:=TStringList.create;

                                                                                                                                            try
                                                                                                                                                mParseListValue:=fnParsevalue(mDocrowbatchList.Strings[iBatch],';');
                                                                                                                                                      API_GetOrCreateBatch(self.ObjectSpace,mtarget,mParseListValue.Strings[0]);
                                                                                                                                                         mDocQueryWithBatch:=mDocQueryWithBatch +'"Name":"' +                            		 mParseListValue.Strings[1]+'", '  ;
                                                                                                                                                         mDocQueryWithBatch:=mDocQueryWithBatch +'"Quantity": ' +                            (mParseListValue.Strings[2])+' '  ;

                                                                                                                                            finally
                                                                                                                                                mParseListValue.free;
                                                                                                                                            end;
                                                                                                                                     mDocQueryWithBatch:=mDocQueryWithBatch +'} ';
                                                                                                                                     if iBatch <> mDocrowbatchList.Count-1 then  mDocQueryWithBatch:=mDocQueryWithBatch +', ' +chr(10) else mDocQueryWithBatch:=mDocQueryWithBatch +chr(10);
                                                                                                                                     end;
                                                                                                                               end
                                                                                                                          finally
                                                                                                                              mDocrowbatchList.free;
                                                                                                                          end;

                                                                                                               end;


                                                                                                              // ov
                                                                                                              if (self.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                                                                          mDocrowbatchList:=TStringList.create;
                                                                                                                          self.ObjectSpace.SQLSelect('SELECT  sb.id,sb.Name,df.X_Quantity FROM DefRollData DF join Storebatches SB on sb.id=DF.X_Batches WHERE (DF.Hidden = ' + quotedstr('N') + ' ) AND (df.CLSID = '
                                                                                                                                                          + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') + ' ) AND (DF.X_Parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID)+')',mDocrowbatchList);
                                                                                                                          try
                                                                                                                               if mDocrowbatchList.count>0 then begin
                                                                                                                                    for iBatch := 0 to mDocrowbatchList.Count-1 do begin
                                                                                                                                        mDocQueryWithBatch:=mDocQueryWithBatch +'{ ' ;
                                                                                                                                        mParseListValue:=TStringList.create;
                                                                                                                                            try
                                                                                                                                                mParseListValue:=fnParsevalue(mDocrowbatchList.Strings[iBatch],';');
                                                                                                                                                         API_GetOrCreateBatch(self.ObjectSpace,mtarget,mParseListValue.Strings[0]);
                                                                                                                                                         mDocQueryWithBatch:=mDocQueryWithBatch +'"Name":"' +                            		 mParseListValue.Strings[1]+'", '  ;
                                                                                                                                                         mDocQueryWithBatch:=mDocQueryWithBatch +'"Quantity": ' +                            (mParseListValue.Strings[2])+' '  ;

                                                                                                                                            finally
                                                                                                                                                mParseListValue.free;
                                                                                                                                            end;
                                                                                                                                     mDocQueryWithBatch:=mDocQueryWithBatch +'} ';
                                                                                                                                     if iBatch <> mDocrowbatchList.Count-1 then  mDocQueryWithBatch:=mDocQueryWithBatch +', ' +chr(10) else mDocQueryWithBatch:=mDocQueryWithBatch +chr(10);
                                                                                                                                     end;
                                                                                                                               end
                                                                                                                          finally
                                                                                                                              mDocrowbatchList.free;
                                                                                                                          end;
                                                                                                               end;



                                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +' ] ';



                                                                                              mDocQueryWithBatch:=mDocQueryWithBatch +' } ';
                                                                                              if iRow <> mMonRows.Count-1 then  mDocQueryWithBatch:=mDocQueryWithBatch +','+chr(10) else mDocQueryWithBatch:=mDocQueryWithBatch +chr(10);

                                                                              end;
                                                                  // ukončení řádku
                                                                  mDocQueryWithBatch:=mDocQueryWithBatch +' ] ';

                                                       // ukončení dokladu
                                                       mDocQueryWithBatch:=mDocQueryWithBatch +' } '+chr(10);





result:= mDocQueryWithBatch;
end;






function APICallRest(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
    try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
              if mStatus then begin
                    result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.ResponseText + ' - ' + mWinHTTP.StatusText ;
              end else begin
                    result:= mWinHTTP.ResponseText;
              end;
         end;
    finally
    end;
end;






function API_GetOrCreateBatch(os:TNxCustomObjectSpace;mApiTArget:string;mBatch_ID:String):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mBatchBO:TNxCustomBusinessObject;

begin
result:='';
mBatchBO:=os.CreateObject('C32QXZWCTVDL342W01C0CX3FCC')   ;
      try
         if mBatch_ID<>'' then begin
             mBatchBo.load(mBatch_ID,nil);
                  mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('Name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('Storecard_ID')) + '" }';
                   mString:=APICallRest(mBatchBO,'Post',mApiTArget,'/query','',mQueryID,True);
                   //NxShowSimpleMessage('AAA .' +copy(mString,10,2) +'.'+  copy(mString,15,10),nil);
                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          if copy(mString,10,2)='ID' then begin      // záznam namezen
                                   result:= copy(mString,15,10);
                                         //NxShowSimpleMessage('Šarže v cíli '  +  mid,nil);

                           end else begin
                                  //NxShowSimpleMessage('Šarže v cíli nenalezena - zakládám' ,nil);
                                  // ********    založení šarže
                                        mNewQueryID:='{'
                                            +' "serialnumber": false, '
                                            +'               "storecard_id": "' + mBatchBo.GetFieldValueAsString('storecard_id') + '", '
                                            +'               "name": "' + mBatchBo.GetFieldValueAsString('name') + '", '
                                            +'               "specification": "' + mBatchBo.GetFieldValueAsString('specification') + '", '
                                            +'               "x_verze": "' + mBatchBo.GetFieldValueAsString('x_verze') + '", '
                                            +'               "ExpirationDate$DATE":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('ExpirationDate$DATE')) +'", '
                                            +'               "productiondate$date":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('productiondate$date')) +'", '

                                            +'               "X_parent_ID": "' + mBatchBo.GetFieldValueAsString('X_parent_ID') + '", '
                                            +'               "X_Specifikace_order": "' + mBatchBo.GetFieldValueAsString('X_Specifikace_order') + '", '
                                            +'               "X_MAT1": "' + mBatchBo.GetFieldValueAsString('X_MAT1') + '", '
                                            +'               "X_MAT2": "' + mBatchBo.GetFieldValueAsString('X_MAT2') + '", '
                                            +'               "X_MAT3": "' + mBatchBo.GetFieldValueAsString('X_MAT3') + '", '
                                            +'               "X_MAT4": "' + mBatchBo.GetFieldValueAsString('X_MAT4') + '", '
                                            +'               "X_MAT5": "' + mBatchBo.GetFieldValueAsString('X_MAT5') + '", '
                                            +'               "X_MAT1_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT1_PROC')) + '", '
                                            +'               "X_MAT2_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT2_PROC')) + '", '
                                            +'               "X_MAT3_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT3_PROC')) + '", '
                                            +'               "X_MAT4_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT4_PROC')) + '", '
                                            +'               "X_MAT5_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT5_PROC')) + '", '
                                             +'}';



                                         //*** kontrola json
                                         if NxCreateContext(os).GetCompanyCache.GetUserID='SUPER00000' then begin
                                            //   mstring:= inputbox('Šarže','POST' + '   ' + mApiTArget+'/'+'StoreBatches' ,mNewQueryID)    ;
                                         end;
                                        mString:= APICallRest(mBatchBO,'post',mApiTArget,'/StoreBatches','' ,mNewQueryID,True);
//                                        NxShowSimpleMessage('Kontrola stavu založení šarže' + copy(mstring,1,3) , nil);
                                        if (copy(mString,1,3)='201') then begin   // stav založení
                                                    mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('storecard_id')) + '" }';

                                                    mString:= copy(APICallRest(mBatchBO,'Post',mApiTArget,'/query','',mQueryID,false),9,10);
                                                    if copy(mString,10,2)='ID' then result:= copy(mString,15,10);
                                        end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                        end;
                            end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;
      finally
         mBatchBO.free;
      end;

end;


















function POST_APINxRetino_WebHook(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  iJSONlines,iJSONRefund:integer;
  mQuery:string;
  AInput:TJSONSuperObject;
  mJSONLines,mJSONRefund:TJSONSuperObject;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mPolozky:string;
  mr,mvalue:tstringlist;
  mdocument_ID,mdocument:string;
  mbo:TNxCustomBusinessObject;
  mstring:string;
begin

      mUser_ID:='';
      mMsgUser_ID:='';
      result:='';
      mPolozky:='';
      mdocument_ID:='';
      mdocument:='';
      AInput:=TJSONSuperObject.create;
      mbo:=AContext.GetObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
      try
      AInput:= TJSONSuperObject.ParseString(ABody,true);

         result:=result + 'zákazník ' + AInput.S['customer.name']+ chr(10);
         result:=result + 'currency ' + AInput.S['currency']+ chr(10);
         result:=result + 'order_id ' + AInput.S['order_id']+ chr(10);
         result:=result + 'VS ' + AInput.S['order_id']+ chr(10);
         mr:=tstringlist.create;
         try
             AContext.SQLSelect('Select id from IssuedInvoices where VarSymbol=' + quotedstr(AInput.S['variable_symbol']),mr);
             if mr.count>0 then begin
                  mbo.load(mr.Strings[0],nil);
                  mdocument:=mbo.DisplayName;
                  mdocument_ID:=mr.Strings[0];
             end;
         finally

            mr.free;
         end;

              if AInput.A['products'].Length>0 then begin                // v poli jSON jsou uvedeny doklady
                  for iJSONlines := 0 to AInput.A['products'].Length - 1 do begin  // cyklus dokladu
                          mJSONLines:=TJSONSuperObject.create;
                          Try
                                mJSONLines:= TJSONSuperObject.ParseString(AInput.A['products'].S[iJSONlines],true);   // pole řádku
                                  mPolozky:=mPolozky+ inttostr(iJSONlines+1) + ': ';
                                  mPolozky:=mPolozky+ mJSONLines.S['product_id']  + ' ';
                                  mPolozky:=mPolozky+ mJSONLines.S['name']  + ' ';
                                  mPolozky:=mPolozky+ NxFloatToIBStr(mJSONLines.D['amount'])  + ' ';
                                  mPolozky:=mPolozky+ NxFloatToIBStr(mJSONLines.D['price.with_vat'])  +chr(10);





                                  mPolozky:=mPolozky+ mJSONLines.S['serial']  + ' ' + chr(10);



                                   // dekodovani datamatrix
                                  mstring:=DatamatrixDecodeBatches(AContext.GetObjectSpace, mJSONLines.S['serial']);
                                  mvalue:=tstringlist.create;
                                         try
                                              Parsevalue(mstring,';',mstring,mvalue,4);
                                              mPolozky:=mPolozky+ 'SC:' + mvalue.Strings[1]  + ' ' ;
                                              mPolozky:=mPolozky+ 'Batch:' + mvalue.Strings[2]  + ' ' ;
                                              mPolozky:=mPolozky+ 'Quantity: ' + mvalue.Strings[3]  + ' ' + chr(10) ;
                                         finally
                                            mvalue.free;
                                         end;









                          finally
                                mJSONLines.free;
                          end;


                  end;
              end;


         if AInput.A['refund_requests'].Length>0 then begin                // v poli jSON jsou uvedeny doklady
                  for iJSONRefund := 0 to AInput.A['refund_requests'].Length - 1 do begin  // cyklus dokladu
                          mJSONRefund:=TJSONSuperObject.create;
                          Try
                                mJSONRefund:= TJSONSuperObject.ParseString(AInput.A['refund_requests'].S[iJSONRefund],true);   // pole řádku
                                  mPolozky:=mPolozky+ inttostr(iJSONRefund+1) + ': ';
                                  mPolozky:=mPolozky+ ' BU: ' + mJSONRefund.S['bank_account']  + ' ';

                          finally
                              mJSONRefund.free;
                          end;
                  end;
         end;

  {
  if not NxIsEmptyOID(mMsgUser_ID) then begin
                                      iSendmsg(AContext.GetObjectSpace, mbo , 'O3BDOKTWEFD13ACM03KIU0CLP4',
                                                                      'Byl vytvořen Retino WebHook na doklad '  + mdocument ,     // popis
                                                                      'Byl vytvořen novy Retino WebHook na doklad s číslem: ' + mdocument +chr(10)
                                                                      +' na jméno: ' + AInput.S['credit_note.customer.name'] +chr(10)
                                                                      +' na položky: '
                                                                      +mPolozky
                                                                       +chr(10)

                                                                      ,                          // tělo
                                                                      'SUPER00000' ,                      // komu
                                                                      '2PK0000101'); // kdo
   end; }


   result:=result + 'Byl vytvořen novy Retino WebHook na doklad s číslem: ' + mdocument +chr(10)
                                                                      +' na jméno: ' + AInput.S['customer.name'] +chr(10)
                                                                      +' na položky: '
                                                                      +mPolozky
                                                                       +chr(10)
 finally
      mbo.free;
      AInput.free;

  end;


end;



















begin
end.