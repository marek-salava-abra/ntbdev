uses 'abra.eu.mask.2017.vyroba.Libsa';

var
xSite: TDynSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mOLE_SP, mRoll_SP, mOResult_SP: Variant;



procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction,mMAction1: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;


 if mUserFilter then begin
 { mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Vychystávání';
  mMAction.Hint := 'Vychystávání';
  mMAction.Category := 'tabList'; //jen na seznamu
  mMAction.OnExecuteItem := @SendSLExecuteItem;
  mMAction.Items.Add('Vychystávání dle dokladu s množstvím');
  mMAction.Items.Add('Vychystávání dle dokladu');  }

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'převod z 999';
  mMAction.Hint := 'převod z 999';
  mMAction.Category := 'tablist'; //jen na seznamu
  mMAction.OnExecuteItem := @RowOperationOnExecute;
  mMAction.Items.Add('převod z 999');


end;


end;





{
Vyvolává se po načtení vlastností formuláře.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

procedure RowOperationOnExecute(Sender: Tcomponent; Index: integer);
var
  mSite: TDynSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i : integer;
  mBO,mBO_StoreCard : TNxCustomBusinessObject;
  mMon,mrows : TNxCustomBusinessMonikerCollection;
  ii:integer;
  mEAN,mOldEan:string;
  mPokracovani:Boolean;
  mstorecard_ID:string;
  mr:TStringList;
  mpocet,mpomoc_pocet,mvychystano:double;
  mfind:boolean;
  mrow:TNxCustomBusinessObject;
  mI_result:double;
  mIDs_Document,mID_Filtr:string;
begin
 mSite := TComponent(Sender).DynSite;
   mPokracovani:=true;
        mOldEan:='.-.-';
        mEan:='.-.-';
        mBO := msite.BaseObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4');


        mbo.new;

        mpocet:=0;
        mbo.prefill;
        mbo.SetFieldValueAsString('DocQueue_ID','TA10000101');
        mbo.SetFieldValueAsDateTime('DocDate$date',Now());


        mPokracovani:=InputQuery('Dohledání položky','EAN ' ,mEAN);
                         mr:=TStringList.create;
                         try
                            mSite.BaseObjectSpace.SQLSelect('select su.Parent_ID from StoreEANs SE left join StoreUnits Su on su.id=se.Parent_ID where se.ean=' + quotedstr(mEAN),mr);
                            if mr.count>0 then begin
                               if mr.count=1 then begin
                                    mBO_StoreCard:=msite.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');

                                       mBO_StoreCard.load(mr.Strings[0],nil);


                                    mI_result:= Form_row(xSite,'05CPMINJW3DL342X01C0CX3FCC',True,
                                              0,0,800,640,
                                              'Zdrojový doklad: ',
                                              mEAN,mBO_StoreCard.GetFieldValueAsString('Code') + ',' + mBO_StoreCard.GetFieldValueAsString('Name'),'','',
                                              mIDs_Document,mID_Filtr,
                                              '','','','','','', ' ',
                                              0,0,0,0,0,0,0,
                                              1,
                                              'Zapsat', 'Přerušit','Doklad','','Zrušit')   ;

                               end;

                            end;

                         finally

                               mr.free;

                         end;









                  while mOldEan=mEan do begin
                  mean:='';





                     mpocet:=1;
                     mPokracovani:=InputQuery('Dohledání položky','EAN v počtu ' + NxFloatToIBStr(mpocet) ,mEAN);
                         mr:=TStringList.create;
                         try
                            mSite.BaseObjectSpace.SQLSelect('select su.Parent_ID from StoreEANs SE left join StoreUnits Su on su.id=se.Parent_ID where se.ean=' + quotedstr(mEAN),mr);
                            if mr.count>0 then begin
                               if mr.count=1 then begin





















                                   mrows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                   mrow:= mrows.AddNewObject;
                                          mpocet:=0;
                                          mpomoc_pocet:=0;

                                                     if index=0 then begin
                                                             mpomoc_pocet:=NxIBStrToFloat(

                                                             InputBox('Zadej množství pro skladovou kartu' ,
                                                             mRows.BusinessObject[ii].getFieldValueAsString('Storecard_id.code')+ ' - ¨' + mRows.BusinessObject[ii].getFieldValueAsString('Storecard_id.name'),
                                                             '1'));
                                                             end else begin
                                                                 mpomoc_pocet:=1;
                                                             end;
                                                     mpocet:= mpocet+mpomoc_pocet;



                                                     if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;


                                    if not mfind then begin
                                       NxShowSimpleMessage('Ean ' + mEAN + ' není použit v této objednávce ',nil);
                                       exit;
                                    end;
                               end else begin
                                   if (mEAN<>'') and (mr.count>0) then NxShowSimpleMessage('Pro ean ' + mEAN + ' je v systému více skladových karet',nil);
                                        exit;
                               end;
                            end else begin
                                if (mEAN<>'') and (mr.count=0) then NxShowSimpleMessage('Pro ean ' + mEAN + ' není v systému žádná skladová karta',nil);
                                    exit;
                            end;

                         finally
                            mr.free;
                         end;

                     mEAN:='';

                  end;



                //mbo.save;




        if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;



end;




function Form_batch(xSite:TSiteForm;mCLSID_DOC:string;mTBatches:boolean;
                                              mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;
                                              mLabel:string;
                                              mEan,mStorecard,mOldStorecard,mLocation:string;
                                              mids:string; mID_Filtr:string;
                                              mLabel1,mLabel2,mLabel3,mLabel4,mLabel5,mLabel6,mLabel7:string;
                                              mValue1,mValue2,mValue3,mValue4,mValue5,mValue6,mValue7:double;
                                              mUnitRate:double;
                                              mbutton1,mbutton2,mbutton3,mbutton4,mbutton5:string
                                              ):Double;
var

      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt,mtunitrate : TEdit;
      mbuttonx1value,mbuttonx2value,mbuttonx3value,mbuttonx4value,mbuttonx5value:tEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      mOldBarCode,mBarCode:string;
      mQuantity:double  ;
      mUnit:string;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mpocet_zapis:double;
      mMemNote,mOldMemNote:tmemo;
      mpokracovat:boolean;
      mll:tstringlist;
      mI_Resultxax:integer;
      mI_result:double;
      mstav_tl:integer;
begin
      mpokracovat:=true;
      Result := 0;
      mpocet_zapis:=0;
      mBarCode:= '.';
      mOldBarCode:='';








    //  while (mBarCode<>'') do begin
       if mpokracovat then begin
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
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,480,120,250,mEan,true,true,true,round(mWith/18), [fsBold],255) ;
                                        mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 500,10,150,250,90,mLocation,true,true,false,round(mWith/18), [fsBold],255) ;
                                        mMemNote := CreateMemo('ChMemNote','Popis zboží', 10, 110, mWith-40 ,80, 150,mStorecard , mForm,true,true,False,round(mWith/26), [fsBold],255);


                                        mBTN:= CreateButton('mbuttonx1x', '-', 99, mform, 10, 220, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbuttonx1label', 'Šarže 5456546 6/4', 99, mform, 100, 220, mWith-300, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mbuttonx1value:=CreateEdit('mbuttonx1value', '',mForm,600, 202, 90,50,50,NxFloatToIBStr(0),true,true,true,round(mWith/32),[fsBold],255);
                                        mBTN:= CreateButton('mbuttonx1y', '+', 99, mform, 690, 220, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);

                                        mBTN:= CreateButton('mbuttonx2x', '-', 99, mform, 10, 280, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbuttonx2label', 'Šarže 5456546 6/4', 99, mform, 100, 280, mWith-300, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mbuttonx2value:=CreateEdit('mbuttonx2value', '',mForm,600, 262, 90,50,50,NxFloatToIBStr(0),true,true,true,round(mWith/32),[fsBold],255);
                                        mBTN:= CreateButton('mbuttonx2y', '+', 99, mform, 690, 280, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);

                                        mBTN:= CreateButton('mbuttonx3x', '-', 99, mform, 10, 340, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbuttonx3label', 'Šarže 5456546 6/4', 99, mform, 100, 340, mWith-300, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mbuttonx3value:=CreateEdit('mbuttonx3value', '',mForm,600, 322, 90,50,50,NxFloatToIBStr(0),true,true,true,round(mWith/32),[fsBold],255);
                                        mBTN:= CreateButton('mbuttonx3y', '+', 99, mform, 690, 340, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);

                                        mBTN:= CreateButton('mbuttonx4x', '-', 99, mform, 10, 400, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbuttonx4label', 'Šarže 5456546 6/4', 99, mform, 100, 400, mWith-300, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mbuttonx4value:=CreateEdit('mbuttonx4value', '',mForm,600, 382, 90,50,50,NxFloatToIBStr(0),true,true,true,round(mWith/32),[fsBold],255);
                                        mBTN:= CreateButton('mbuttonx4y', '+', 99, mform, 690, 400, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);

                                        mBTN:= CreateButton('mbuttonx5x', '-', 99, mform, 10, 460, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbuttonx5label', 'Šarže 5456546 6/4', 99, mform, 100, 460, mWith-300, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mbuttonx5value:=CreateEdit('mbuttonx5value', '',mForm,600, 442, 90,50,50,NxFloatToIBStr(0),true,true,true,round(mWith/32),[fsBold],255);
                                        mBTN:= CreateButton('mbuttonx5y', '+', 99, mform, 690, 460, 80, 50,false,false,round(mWith/36),[fsBold],255,124,false,false);




                                        mBTN:= CreateButton('mbutton1', mbutton1, 100, mform, 10, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbutton2', mbutton2, 110, mform, 160, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbutton3', mbutton3, 120, mform, 310, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbutton4', mbutton4, 130, mform, 460, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('mbutton5', mbutton5, 140, mform, 640, mheight-115, 140, 70,false,true,round(mWith/36),[fsBold],255,124,false,false);




                                        //stav skladu

                                        //doddano












                                       mix_result:= mForm.ShowModal(xsite);   // změna položky









             finally
             mForm.free;
             end;
       end;

   //   end;

end;




function Form_row(xSite:TSiteForm;mCLSID_DOC:string;mTBatches:boolean;
                                              mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;
                                              mLabel:string;
                                              mEan,mStorecard,mOldStorecard,mLocation:string;
                                              mids:string; mID_Filtr:string;
                                              mLabel1,mLabel2,mLabel3,mLabel4,mLabel5,mLabel6,mLabel7:string;
                                              mValue1,mValue2,mValue3,mValue4,mValue5,mValue6,mValue7:double;
                                              mUnitRate:double;
                                              mbutton1,mbutton2,mbutton3,mbutton4,mbutton5:string
                                              ):Double;
var

      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt,mtunitrate : TEdit;
      mpol1Edt,mpol2Edt,mpol3Edt,mpol4Edt,mpol5Edt,mpol6Edt,mpol7Edt:tEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      mOldBarCode,mBarCode:string;
      mQuantity:double  ;
      mUnit:string;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mpocet_zapis:double;
      mMemNote,mOldMemNote:tmemo;
      mpokracovat:boolean;
      mll:tstringlist;
      mI_Resultxax:integer;
      mI_result:double;
      mIDs_Document:string;
begin
      mpokracovat:=true;
      Result := 0;
      mpocet_zapis:=0;
      mBarCode:= '...';
      mOldBarCode:= '...';


    mix_result:=101;




    mpocet_zapis:=1;
      while (mix_result<>0) do begin
       if mbarcode=mOldBarCode then begin
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
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,480,120,250,mEan,true,true,true,round(mWith/18), [fsBold],255) ;

                                        if mLocation<>'' then mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 500,10,150,250,90,mLocation,true,true,false,round(mWith/18), [fsBold],255) ;
                                        if mLocation<>'' then mMemNote := CreateMemo('ChMemNote','Popis zboží', 10, 110, mWith-40 ,120, 150,mStorecard , mForm,true,true,False,round(mWith/18), [fsBold],255);

                                        mQuantityEdt:=CreateEdit('mQuantityEdt', 'Množství',mForm,10, 255, 150,80,50,NxFloatToIBStr(mpocet_zapis),true,true,true,round(mWith/22),[fsBold],255);
                                        if mLocation<>'' then mUnitEdt:=CreateEdit('mUnitEdt', 'Jedn.',mForm,160, 255, 150,160,50,'ks',true,true,false,round(mWith/22),[fsBold],255);
                                        if mUnitRate<>1 then mtUnitrate:=CreateEdit('mUnitrate', '',mForm,320, 265, 80,160,50,NxFloatToIBStr(mUnitRate),true,true,false,round(mWith/28),[fsBold],255);

                                        mBTN:= CreateButton('Minus', '-', -1, mform, 420, 255, 90, 90,true,true,round(mWith/22),[fsBold],255,124,false,false);
                                        mBTN:= CreateButton('Plus', '+', 1, mform, 510, 255, 90, 90,true,true,round(mWith/22),[fsBold],255,124,false,false);

                                        if mTBatches then mBTN:= CreateButton('Sarze', 'Šarže', 99, mform, 620, 255, 150, 90,true,true,round(mWith/28),[fsBold],255,124,false,false);

                                        if mLabel1<>'' then mpol1Edt:=CreateEdit_noformat('mpol1Edt', mLabel1,mform, 10,355,100,150,150,NxFloatToIBStr(mvalue1),true,true,false,round(mWith/28),[fsBold] ,255) ;


                                        if mLabel2<>'' then mpol2Edt:=CreateEdit_noformat('mpol2Edt', mLabel2,mform, 120,355,100,150,150,NxFloatToIBStr(mvalue2),true,true,false,round(mWith/28),[fsBold],255) ;
                                        if mLabel3<>'' then mpol3Edt:=CreateEdit_noformat('mpol3Edt', mLabel3,mform, 230,355,100,150,150,NxFloatToIBStr(mvalue3),true,true,false,round(mWith/28),[fsBold],255) ;
                                        if mLabel4<>'' then mpol4Edt:=CreateEdit_noformat('mpol4Edt', mLabel4,mform, 340,355,100,150,150,NxFloatToIBStr(mvalue4),true,true,false,round(mWith/28),[fsBold],255) ;

                                        if mLabel5<>'' then mpol5Edt:=CreateEdit_noformat('mpol5Edt', mLabel5,mform, 450,355,100,150,150,NxFloatToIBStr(mvalue5),true,true,false,round(mWith/28),[fsBold],255) ;
                                        if mLabel6<>'' then mpol6Edt:=CreateEdit_noformat('mpol6Edt', mLabel6,mform, 560,355,100,150,150,NxFloatToIBStr(mvalue6),true,true,false,round(mWith/28),[fsBold],255) ;
                                        if mLabel7<>'' then mpol7Edt:=CreateEdit_noformat('mpol7Edt', mLabel7,mform, 670,355,100,150,150,NxFloatToIBStr(mvalue7),true,true,false,round(mWith/28),[fsBold],255) ;


                                        if mOldStorecard<>'' then mOldMemNote := CreateMemo('ChOldMemNote','Předchozí položka', 10, mheight-205, mWith-40 ,60 , 60,mOldStorecard , mForm,true,true,False,round(mWith/36), [fsItalic],255);




                                        if mbutton1<>'' then mBTN:= CreateButton('mbutton1', mbutton1, 10, mform, 10, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        if mbutton2<>'' then mBTN:= CreateButton('mbutton2', mbutton2, 20, mform, 160, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        if mbutton3<>'' then mBTN:= CreateButton('mbutton3', mbutton3, 30, mform, 310, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        if mbutton4<>'' then mBTN:= CreateButton('mbutton4', mbutton4, 40, mform, 460, mheight-115, 140, 70,false,false,round(mWith/36),[fsBold],255,124,false,false);
                                        if mbutton5<>'' then mBTN:= CreateButton('mbutton5', mbutton5, 0, mform, 640, mheight-115, 140, 70,false,true,round(mWith/36),[fsBold],255,124,false,false);




                                        //stav skladu

                                        //doddano












                                       mix_result:= mForm.ShowModal(xsite);   // změna položky

                                       if mix_result=1 then begin
                                              mpocet_zapis:=mpocet_zapis+1;
                                       end;

                                       if mix_result=(-1) then begin
                                              mpocet_zapis:=mpocet_zapis-1;
                                       end;


                                       if mix_result=10 then begin
                                              mpocet_zapis:=mpocet_zapis+1;
                                       end;


                                       if mix_result=99 then begin
                                              mI_result:=94;
                                              mI_result:= Form_batch(xSite,'05CPMINJW3DL342X01C0CX3FCC',True,
                                                          0,0,800,640,
                                                          'Zdrojový doklad: ',
                                                          '222222222222','Skladová karta','Stará skladová karta','L001',
                                                          mIDs_Document,mID_Filtr,
                                                          'Celkem','Skladem','Dodano','Vychystano','Objednano','Vyrobeno', ' ',
                                                          100,88.4,92.1,41.8,21,16,0,
                                                          1,
                                                          'Zapsat', 'Přerušit','Doklad','','Zrušit')   ;


                                       end;


             finally
             mForm.free;
             end;
       end;

      end;

end;








{
Vyvolává se při ukládání vlastností formuláře.
}
procedure SavingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

begin
end.