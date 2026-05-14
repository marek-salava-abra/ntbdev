  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib','NxApiProp.Prop'
    //  ,'_GlobalSettings.Konstanty'

;
const
mtable='StoreCards';
mAPItable='StoreCards';


var
  mSite : TSiteForm;
  mfilter:string;
    mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mhead: TNxCustomBusinessObject;
  mID_StoreCard: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mKumulovane:boolean;



  function APICallNewValue(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
              if mStatus then begin
                    result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.ResponseText + ' - ' + mWinHTTP.StatusText ;
              end else begin
                    result:= mWinHTTP.ResponseText;
              end;
        end;
      finally
      end;

end;


function GetStoreCardJSON(mJSON:TJSONSuperObject;self:TNxCustomBusinessObject; AContext: TNxContext; miCount:integer): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,iRow,iBatch,ii,j : integer;
  mJSONHeads,mJSONRow,mJSONBatch,ARows,ABatches,mParameter:TJSONSuperObject;
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
  mMonStoreUnits:TNxCustomBusinessMonikerCollection;
  mQueryJSON,mReturnJSON:TJSONSuperObject ;
  mtarget:string;
  mUser_ID:string;
  mNewQueryID:string;
  mBoolean:boolean;
begin
   mtarget:='http://api.abra-sk.prod.ad.lipoelastic.com:83/SK_LipoElastic' ;
   mBOHead:=self;
   mMonStoreUnits := mBOHead.GetLoadedCollectionMonikerForFieldCode(mBOHead.GetFieldCode('StoreUnits'));

   mQueryJSON:=TJSONSuperObject.create;

   mQueryJSON.s['class']:=mAPItable;
   mQueryJSON.s['select']:='ID';
   mQueryJSON.s['where']:= ' id = ' + QuotedStr(mBOHead.OID);


  mString:=APICallString(mBOHead.ObjectSpace,'POST',mtarget+'/query',mQueryJSON.AsString,true);
         //NxShowSimpleMessage(mString,nil);
         mReturnJSON:=TJSONSuperObject.create;
               try

               mReturnJSON:= TJSONSuperObject.ParseString(copy(mString,2,Length(mstring)-1), true);
               mid:=mReturnJSON.S['ID'];
               exit;
           except


                mReturnJSON.free;
                mNewQueryID:='{"info_type": "New_value" ' ;
                                 mNewQueryID:=mNewQueryID +','+' "mSQL": "INSERT INTO ' + mtable + ' (ID,category,code,name,hidden,mainunitcode,EAN,storecardcategory_id,CreatedBy_ID,CreatedAt$DATE,Country_ID) VALUES (';
                                 mNewQueryID:=mNewQueryID + quotedstr(mBOHead.oid) ;
                                                          mNewQueryID:=mNewQueryID + ','+ inttostr(mBOHead.GetFieldValueAsinteger('category')) ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(mBOHead.GetFieldValueAsString('Code')) ;
                                                          //if i=1 then mNewQueryID:=mNewQueryID + ','+ quotedstr(copy(mBO.GetFieldValueAsString('name'),1,80))  ;
                                                          //if i=2 then
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(copy(mBOHead.GetFieldValueAsString('X_Name_SK'),1,80))  ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('N') ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(mBOHead.GetFieldValueAsString('mainunitcode')) ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr( AnsiUpperCase(mBOHead.GetFieldValueAsString('EAN'))) ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('7000000101');
                                                          //mNewQueryID:=mNewQueryID + ','+ quotedstr(mBO.GetFieldValueAsString('x_busdivision_id'));
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(mUser_ID);
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(NxFloatToIBStr(now));
                                                          //if i=1 then mNewQueryID:=mNewQueryID + ','+ quotedstr('00000CZ000') ;
                                                          //if i=2 then
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('00000SK000') ;
                                                         mNewQueryID:=mNewQueryID + ')"}';

                             if (AContext.GetCompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQueryID);
                             mString:=ApiCallNewValue(mBOHead,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID, true);



            end;
            exit;

   mResult_DocType:='';
   mResult_DocQueue:='';
   mResult_Documents:='';
   mPocetDokladu:=0;


      mJSON:=TJSONSuperObject.create;
      mParameter:=TJSONSuperObject.create;
      mStringList:=tstringlist.create;

      mPocetDokladu:= mStringList.count;






       mJSON.S['ID']:=Self.OID ;
                          mJSON.S['category']:=inttostr(Self.GetFieldValueAsinteger('category'));
                          mJSON.S['code']:=Self.GetFieldValueAsString('Code') ;

                          //if iTarget=1 then        mJSON.S['name']:=copy(Self.GetFieldValueAsString('Name'),1,80) ;
                          //if iTarget=2 then
                          mJSON.S['name']:=copy(Self.GetFieldValueAsString('X_Name_SK'),1,80) ;
                          //end else begin
                          //        mJSON.S['name']:=Self.GetFieldValueAsString('X_NAME_CZ');
                          //end;


                          mJSON.S['X_Marketing_Name']:=Self.GetFieldValueAsString('X_Marketing_Name') ;
                          mJSON.S['X_NAME_CZ']:=Self.GetFieldValueAsString('X_NAME_CZ') ;
                          mJSON.S['X_Name_SK']:=Self.GetFieldValueAsString('X_Name_SK') ;
                          mJSON.S['storecardcategory_id']:=Self.GetFieldValueAsString('storecardcategory_id') ;



                          mJSON.S['x_busdivision_id']:=Self.GetFieldValueAsString('x_busdivision_id');
                          mJSON.S['mainunitcode']:=Self.GetFieldValueAsString('mainunitcode') ;
                          mJSON.S['foreignname']:=Self.GetFieldValueAsString('foreignname') ;
                          mJSON.S['shortname']:=Self.GetFieldValueAsString('shortname');
                          mJSON.S['specification']:=Self.GetFieldValueAsString('specification') ;
                          mJSON.S['specification2']:=Self.GetFieldValueAsString('specification2') ;
                          mJSON.S['isproduct']:=BoolToStr(Self.GetFieldValueAsBoolean('isproduct'));              // ": true,
                          mJSON.S['isscalable']:=BoolToStr(Self.GetFieldValueAsBoolean('isscalable'));                      // ": false,
                          mJSON.S['hidden']:=BoolToStr(Self.GetFieldValueAsBoolean('hidden'));               // ": false,
                          mJSON.S['nonstocktype']:=BoolToStr(Self.GetFieldValueAsBoolean('nonstocktype'));            // ": false,
                          mJSON.S['note']:=Self.GetFieldValueAsString('note');
                          mJSON.S['outofstockbatchdelivery']:=Inttostr(Self.GetFieldValueAsinteger('outofstockbatchdelivery'));
                          mJSON.S['outofstockdelivery']:=inttostr(Self.GetFieldValueAsinteger('outofstockdelivery'));
//                          mJSON.S['plu']:=inttostr(Self.GetFieldValueAsinteger('plu'));
//                          mJSON.S['prefixcode']:=Self.GetFieldValueAsString('prefixcode');
//                          mJSON.S['priority"']:=inttostr(Self.GetFieldValueAsinteger('priority'));
                          mJSON.S['quantitydiscount_id']:=Self.GetFieldValueAsString('quantitydiscount_id');
//                          mJSON.S['serialnumberstructure']:=Self.GetFieldValueAsString('serialnumberstructure');
//                          mJSON.S['storeassortmentgroup_id']:=Self.GetFieldValueAsString('storeassortmentgroup_id');
//                          mJSON.S['storebatchstructure_id']:=Self.GetFieldValueAsstring('storebatchstructure_id');
 //                         mJSON.S['storemenuitem_id"']:=Self.GetFieldValueAsString('storemenuitem_id');
                          mJSON.S['useoutofstockbatchdelivery']:=BoolToStr(Self.GetFieldValueAsBoolean('useoutofstockbatchdelivery'));
                          mJSON.S['useoutofstockdelivery']:=BoolToStr(Self.GetFieldValueAsBoolean('useoutofstockdelivery'));
//                          mJSON.S['usualgrossprofit']:=inttostr(Self.GetFieldValueAsinteger('usualgrossprofit'));
//                          mmJSON.S['x_aktivacenakladoveceny']:=inttostr(Self.GetFieldValueAsinteger('x_aktivacenakladoveceny'));
                          mJSON.S['x_aktivni']:=BoolToStr(Self.GetFieldValueAsBoolean('x_aktivni'));
                          mJSON.S['x_barva']:=Self.GetFieldValueAsString('x_barva');
                          mJSON.S['x_brand_id']:=Self.GetFieldValueAsString('x_brand_id');
                          mJSON.S['x_bustransaction_id']:=Self.GetFieldValueAsString('x_bustransaction_id');
                          mJSON.S['x_caskontrola']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_caskontrola'));
                          mJSON.S['x_casstrih']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_casstrih'));
                          mJSON.S['x_casvyroby_ks']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_casvyroby_ks'));
                          mJSON.S['x_category']:=inttostr(Self.GetFieldValueAsinteger('x_category'));
                          mJSON.S['x_cena_skladova_SK']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladova_SK'));
                          mJSON.S['x_cena_rozprac_SK']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_rozprac_SK'));
                          mJSON.S['ExpirationDue']:=inttostr(Self.GetFieldValueAsinteger('ExpirationDue')) ;
                          mJSON.S['X_Skupina_ID']:=Self.GetFieldValueAsString('X_skupina_ID');
                          mJSON.S['x_cena']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_precen'));
//                          mJSON.S['x_cena_rozprac']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_rozprac'));
//                          mJSON.S['x_cena_rozprac1']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_rozprac1'));
//                          mJSON.S['x_cena_skladova']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladova'));
//                          mJSON.S['x_cena_skladova1']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladova1'));
//                          mJSON.S['x_cena_skladovaxxx']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladovaxxx'));
                          mJSON.S['x_cenakontrola']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenakontrola'));
                          mJSON.S['x_cenamin_cz']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenamin_cz'));
                          mJSON.S['x_cenamin_dcera']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenamin_dcera'));
                          mJSON.S['x_cenamin_export']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenamin_export'));
                          mJSON.S['x_cenarezm']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenarezm'));
                          mJSON.S['x_cenasiti']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenasiti'));
                          mJSON.S['x_cenasprava']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenasprava'));
                          mJSON.S['x_cenastrih']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenastrih'));
                          mJSON.S['x_cenathp']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenathp'));
                          mJSON.S['x_cenavyrm"']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenavyrm'));
                          mJSON.S['x_cenavyrrez']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenavyrrez'));
                          mJSON.S['x_cert_no_do']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cert_no_do'));
                          mJSON.S['x_certifikat']:=Self.GetFieldValueAsString('x_certifikat');
                          mJSON.S['x_certifikat_do']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_certifikat_do'));
                          mJSON.S['x_certifikat_notifikace']:=Self.GetFieldValueAsString('x_certifikat_notifikace');
//                          mJSON.S['x_cesta_detail01']:=Self.GetFieldValueAsString('x_cesta_detail01');
//                          mJSON.S['x_cesta_detail02']:=Self.GetFieldValueAsString('x_cesta_detail02');
//                          mJSON.S['x_cesta_detail03']:=Self.GetFieldValueAsString('x_cesta_detail03');
//                          mJSON.S['x_cesta_detail04']:=Self.GetFieldValueAsString('x_cesta_detail04');
//                          mJSON.S['x_cesta_ikona01']:=Self.GetFieldValueAsString('x_cesta_ikona01');
//                          mJSON.S['x_cesta_ikona02']:=Self.GetFieldValueAsString('x_cesta_ikona02');
//                          mJSON.S['x_cesta_ikona03']:=Self.GetFieldValueAsString('x_cesta_ikona03');
//                          mJSON.S['x_cesta_ikona04']:=Self.GetFieldValueAsString('x_cesta_ikona04');
//                          mJSON.S['x_cesta_ikona05']:=Self.GetFieldValueAsString('x_cesta_ikona05');
//                          mJSON.S['x_cesta_ikona06']:=Self.GetFieldValueAsString('x_cesta_ikona06');
//                          mJSON.S['x_cesta_ikona07']:=Self.GetFieldValueAsString('x_cesta_ikona07');
//                          mJSON.S['x_cesta_model_cz']:=Self.GetFieldValueAsString('x_cesta_model_cz');
//                          mJSON.S['x_cesta_model_en']:=Self.GetFieldValueAsString('x_cesta_model_en');
//                          mJSON.S['x_cesta_obrazek']:=Self.GetFieldValueAsString('x_cesta_obrazek');
//                          mJSON.S['x_cesta_obrazek01']:=Self.GetFieldValueAsString('x_cesta_obrazek01');
//                          mJSON.S['x_cesta_obrazek02']:=Self.GetFieldValueAsString('x_cesta_obrazek02');
//                          mJSON.S['x_cesta_obrazek03']:=Self.GetFieldValueAsString('x_cesta_obrazek03');
//                          mJSON.S['x_cesta_obrazek04']:=Self.GetFieldValueAsString('x_cesta_obrazek04');
                          mJSON.S['x_cesta_piktogram']:=Self.GetFieldValueAsString('x_cesta_piktogram');
                          mJSON.S['x_cesta_piktogram1']:=Self.GetFieldValueAsString('x_cesta_piktogram1');
//                          mJSON.S['x_cz_pomoc_name']:=Self.GetFieldValueAsString('x_cz_pomoc_name');
//                         mJSON.S['x_date$checksukl']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$checksukl'));
//                          mJSON.S['x_date$eudamed']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$eudamed'));
//                          mmJSON.S['x_date$initsukl']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$initsukl'));
//                          mJSON.S['x_date$newce']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$newce'));
                          mJSON.S['x_davka_sici']:=inttostr(Self.GetFieldValueAsinteger('x_davka_sici'));
//                          mJSON.S['x_documentacedate$date']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_documentacedate$date'));




                          mJSON.S['x_e_druh']:=Self.GetFieldValueAsString('x_e_druh');
                          mJSON.S['x_e_provedeni']:=Self.GetFieldValueAsString('x_e_provedeni');
                          mJSON.S['x_e_typ']:=Self.GetFieldValueAsString('x_e_typ');
                          mJSON.S['x_ean_usa']:=Self.GetFieldValueAsString('x_ean_usa');





//                          mJSON.S['x_en_pomoc_name']:=Self.GetFieldValueAsString('x_en_pomoc_name');
  //                        mJSON.S['x_en_popis_mat_sl']:=Self.GetFieldValueAsString('x_en_popis_mat_sl');
//                          mJSON.S['x_en_popis_produktu']:=Self.GetFieldValueAsString('x_en_popis_produktu');
//                          mJSON.S['x_en_popis_tab']:=Self.GetFieldValueAsString('x_en_popis_tab');
//                          mJSON.S['x_en_popis_udrzba']:=Self.GetFieldValueAsString('x_en_popis_udrzba');
//                          mJSON.S['x_eshop']:=Self.GetFieldValueAsString('x_eshop');
//                          mJSON.S['x_fda_id']:=Self.GetFieldValueAsString('x_fda_id');
//                          mJSON.S['x_gmdn']:=Self.GetFieldValueAsString('x_gmdn');
//                          mJSON.S['x_katalogno']:=Self.GetFieldValueAsString('x_katalogno');
//                          mJSON.S['x_katalogusa']:=Self.GetFieldValueAsString('x_katalogusa');
//                          mJSON.S['x_koeficient_ceny_zbozi_cz_b2b']:=inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_cz_b2b'));
//                          mJSON.S['x_koeficient_ceny_zbozi_cz_b2c']:=inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_cz_b2c'));
//                          mJSON.S['x_koeficient_ceny_zbozi_en_b2b']:=inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_en_b2b'));
//                          mQuery:=mQuery +'"x_koeficient_ceny_zbozi_en_b2c']:=inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_en_b2c'));
                          mJSON.S['x_konec_vyroby']:=BoolToStr(Self.GetFieldValueAsBoolean('x_konec_vyroby'));
//                          mJSON.S['x_krabicka_id']:=Self.GetFieldValueAsString('x_krabicka_id');
                          mJSON.S['x_krabicka_pocet']:=inttostr(Self.GetFieldValueAsinteger('x_krabicka_pocet'));
                          mJSON.S['x_lycra']:=Self.GetFieldValueAsString('x_lycra');
              //            mJSON.S['x_marketingova_cena']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_marketingova_cena'));
              //            mJSON.S['x_marketingova_cena1']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_marketingova_cena1'));
                          mJSON.S['x_mat1']:=Self.GetFieldValueAsString('x_mat1');
                          mJSON.S['x_mat1_proc']:=inttostr(Self.GetFieldValueAsinteger('x_mat1_proc'));
                          mJSON.S['x_mat2']:=Self.GetFieldValueAsString('x_mat2');
                          mJSON.S['x_mat2_proc']:=inttostr(Self.GetFieldValueAsinteger('x_mat2_proc'));
                          mJSON.S['x_mat3']:=Self.GetFieldValueAsString('x_mat3');
                          mJSON.S['x_mat3_proc']:=inttostr(Self.GetFieldValueAsinteger('x_mat3_proc'));
                          mJSON.S['x_mat4']:=Self.GetFieldValueAsString('x_mat4');
                          mJSON.S['x_mat4_proc']:=inttostr(Self.GetFieldValueAsinteger('x_mat4_proc'));
                          mJSON.S['x_mat5']:=Self.GetFieldValueAsString('x_mat5');
                          mJSON.S['x_mat5_proc']:=inttostr(Self.GetFieldValueAsinteger('x_mat5_proc'));
                          mJSON.S['x_matka']:=BoolToStr(Self.GetFieldValueAsBoolean('x_matka'));
                          mJSON.S['x_mermed']:=Self.GetFieldValueAsString('x_mermed');
                          mJSON.S['x_min_objedn_mnozstvi']:=inttostr(Self.GetFieldValueAsinteger('x_min_objedn_mnozstvi'));
                          mJSON.S['x_name_at']:=Self.GetFieldValueAsString('x_name_at');
                          mJSON.S['x_name_de']:=Self.GetFieldValueAsString('x_name_de');
                          mJSON.S['x_name_dk']:=Self.GetFieldValueAsString('x_name_dk');
                          mJSON.S['x_name_en']:=Self.GetFieldValueAsString('x_name_en');
                          mJSON.S['x_name_es']:=Self.GetFieldValueAsString('x_name_es');
                          mJSON.S['x_name_fr']:=Self.GetFieldValueAsString('x_name_fr');
                          mJSON.S['x_name_hu']:=Self.GetFieldValueAsString('x_name_hu');
                          mJSON.S['x_name_it']:=Self.GetFieldValueAsString('x_name_it');
                          mJSON.S['x_name_pl']:=Self.GetFieldValueAsString('x_name_pl');
                          mJSON.S['x_name_ru']:=Self.GetFieldValueAsString('x_name_ru');
                          mJSON.S['x_name_usa']:=Self.GetFieldValueAsString('x_name_usa');
                          mJSON.S['x_navod']:=Self.GetFieldValueAsString('x_navod');
//                          mJSON.S['x_notifik_osoba']:=Self.GetFieldValueAsString('x_notifik_osoba');
                          mJSON.S['x_obchodni_pripad']:=Self.GetFieldValueAsString('x_obchodni_pripad');
                          mJSON.S['x_pad']:=Self.GetFieldValueAsString('x_pad');
                          mJSON.S['x_parametry']:=Self.GetFieldValueAsString('x_parametry');
                          mJSON.S['x_parent_id']:=Self.GetFieldValueAsString('x_parent_id');
                         mJSON.S['x_pocetksvbal']:=inttostr(Self.GetFieldValueAsinteger('x_pocetksvbal'));
//                          mJSON.S['x_popis_mat_sl']:=Self.GetFieldValueAsString('x_popis_mat_sl');
//                          mJSON.S['x_popis_produktu']:=Self.GetFieldValueAsString('x_popis_produktu');
//                          mJSON.S['x_popis_tab']:=Self.GetFieldValueAsString('x_popis_tab');
//                          mJSON.S['x_popis_udrzba']:=Self.GetFieldValueAsString('x_popis_udrzba');
                          mJSON.S['x_praci_symbol']:=Self.GetFieldValueAsString('x_praci_symbol');
                          mJSON.S['x_prepocet']:=BoolToStr(Self.GetFieldValueAsBoolean('x_prepocet'));
                          mJSON.S['x_pv_kata']:=inttostr(Self.GetFieldValueAsinteger('x_pv_kata'));
                          mJSON.S['x_pv_katb']:=inttostr(Self.GetFieldValueAsinteger('x_pv_katb'));
                          mJSON.S['x_pv_katc']:=inttostr(Self.GetFieldValueAsinteger('x_pv_katc'));
                          mJSON.S['x_pv_katd']:=inttostr(Self.GetFieldValueAsinteger('x_pv_katd'));
                          mJSON.S['x_pzn']:=Self.GetFieldValueAsString('x_pzn');
 //                         mJSON.S['x_ridici_karta_seskupeni']:=Self.GetFieldValueAsString('x_ridici_karta_seskupeni');
//                         mJSON.S['x_sacek_id']:=Self.GetFieldValueAsString('x_sacek_id');
                          mJSON.S['x_sacek_old_id']:=Self.GetFieldValueAsString('x_sacek_old_id');
                          mJSON.S['x_sleva_dodavatel']:=inttostr(Self.GetFieldValueAsinteger('x_sleva_dodavatel'));
            //            mJSON.S['x_spolecny_kusovnik']:=Self.GetFieldValueAsString('x_spolecny_kusovnik');
              //            mJSON.S['x_spolecny_technpostup']:=Self.GetFieldValueAsString('x_spolecny_technpostup');
                          mJSON.S['x_statistika']:=Self.GetFieldValueAsString('x_statistika');
                          mJSON.S['x_stb_siti']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_stb_siti'));
                          mJSON.S['x_sterile']:=BoolToStr(Self.GetFieldValueAsBoolean('x_sterile'));
                          mJSON.S['x_texlabel']:=inttostr(Self.GetFieldValueAsinteger('x_texlabel'));
                          mJSON.S['x_tisk']:=BoolToStr(Self.GetFieldValueAsBoolean('x_tisk'));
                          mJSON.S['x_typ']:=Self.GetFieldValueAsString('x_typ');
                          mJSON.S['x_typ_deveno']:=Self.GetFieldValueAsString('x_typ_deveno');
                          mJSON.S['x_typ_produktu']:=Self.GetFieldValueAsString('x_typ_produktu');
                          mJSON.S['x_typ_uctovani']:=Self.GetFieldValueAsString('x_typ_uctovani');
                          mJSON.S['x_typ_velky']:=Self.GetFieldValueAsString('x_typ_velky');
                          mJSON.S['x_ukonceni']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_ukonceni'));
                          mJSON.S['x_vaha']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_vaha'));
                          mJSON.S['x_vaha_krabicka']:=NxFloatToIBStr(Self.GetFieldValueAsFloat('x_vaha_krabicka'));
                          mJSON.S['x_velikost']:=Self.GetFieldValueAsString('x_velikost');
                          mJSON.S['x_velikost_id']:=Self.GetFieldValueAsString('x_velikost_id');
                          mJSON.S['x_verze']:=Self.GetFieldValueAsString('x_verze');
                          mJSON.S['x_zip']:=Self.GetFieldValueAsString('x_zip');
                          //if (iTarget<>2) then begin
                          //     mJSON.S['vatrate_id']:=Self.GetFieldValueAsString('vatrate_id');
                          //end;
                          //if (iTarget=2)  then begin
                                if NxIsEmptyOID(Self.GetFieldValueAsString('X_sazba_DPH_SK')) then begin
                                      mJSON.S['vatrate_id']:='02000X0000';
                                end else begin
                                      mJSON.S['vatrate_id']:=Self.GetFieldValueAsString('X_sazba_DPH_SK');                       // ": ""
                                end;

                          //end;
                           // ": ""

                          mJSON.S['U_Kod_pojistovny']:=Self.GetFieldValueAsString('U_Kod_pojistovny');
                          mJSON.S['U_vestnikova_cena']:=Self.GetFieldValueAsString('U_vestnikova_cena');
                          mJSON.S['U_OPD']:=Self.GetFieldValueAsString('U_OPD');
                          mJSON.S['U_pc_mjd']:=Self.GetFieldValueAsString('U_pc_mjd');
                          mJSON.S['U_max_cena']:=Self.GetFieldValueAsString('U_max_cena');
                          mJSON.S['U_Regulovana_cena']:=BoolToStr(Self.GetFieldValueAsBoolean('U_Regulovana_cena'));
                          mJSON.S['U_kod_pojist']:=Self.GetFieldValueAsString('U_kod_pojist');
                          mJSON.S['U_Typ_zdravotiho_prostredu']:=Self.GetFieldValueAsString('U_Typ_zdravotiho_prostredu');
                          mJSON.S['U_OPD2']:=Self.GetFieldValueAsString('U_OPD2');
                          mJSON.S['U_pc_mjd2']:=Self.GetFieldValueAsString('U_pc_mjd2');
                          mJSON.S['U_max_cena2']:=Self.GetFieldValueAsString('U_max_cena2');
                          mJSON.S['U_Vest_cena2']:=Self.GetFieldValueAsString('U_Vest_cena2');
                          mJSON.S['U_barva_ID']:=Self.GetFieldValueAsString('U_barva_ID');
                          mJSON.S['U_provedeni_ID']:= Self.GetFieldValueAsString('U_provedeni_ID');
                          mJSON.S['U_druh_ID']:=Self.GetFieldValueAsString('U_druh_ID');
                          mJSON.S['U_Obrazek']:=Self.GetFieldValueAsString('U_Obrazek');
                          mJSON.S['U_Material']:=Self.GetFieldValueAsString('U_Material');
                          mJSON.S['U_komprese_ID']:=Self.GetFieldValueAsString('U_komprese_ID');
                          mJSON.S['X_KompreseID']:=Self.GetFieldValueAsString('X_KompreseID');

                          mJSON.S['U_velikost_chodidla_ID']:=Self.GetFieldValueAsString('U_velikost_chodidla_ID');
                          mJSON.S['U_obvod_stehna_ID']:=Self.GetFieldValueAsString('U_obvod_stehna_ID');
                          mJSON.S['U_vyska_ID']:=Self.GetFieldValueAsString('U_vyska_ID');
                          mJSON.S['U_boky_ID']:=Self.GetFieldValueAsString('U_boky_ID');
                          mJSON.S['U_velikost_ID']:=Self.GetFieldValueAsString('U_velikost_ID');
                          mJSON.S['U_material_ID"']:=Self.GetFieldValueAsString('U_material_ID');
                          mJSON.S['U_punc_typ']:=Self.GetFieldValueAsString('U_punc_typ');
                          mJSON.S['U_nadpis']:=Self.GetFieldValueAsString('U_nadpis');
                          mJSON.S['U_EAN_maxis']:=Self.GetFieldValueAsString('U_EAN_maxis');
                          mJSON.S['U_Material_2']:=Self.GetFieldValueAsString('U_Material_2');
                          mJSON.S['U_PAD_MAXIS']:=Self.GetFieldValueAsString('U_PAD_MAXIS');
                          mJSON.S['U_LYCRA_MAXIS']:=Self.GetFieldValueAsString('U_LYCRA_MAXIS');
                          mJSON.S['U_UcelCZ']:=Self.GetFieldValueAsString('U_UcelCZ');
                          mJSON.S['U_UcelEN']:=Self.GetFieldValueAsString('U_UcelEN');
                          mJSON.S['U_klinhodn']:=Self.GetFieldValueAsString('U_klinhodn');




                          mJSON.O['Rows'] := mJSONHeads.CreateJSONArray;

                    {      mJSON.S['storeunits": [  ';
                               mMonRows := mBOHead.GetLoadedCollectionMonikerForFieldCode(mBOHead.GetFieldCode('ROWS'));
                                                                                   // řádky

                                                                                for iRow := 0 to mMonRows.Count - 1 do begin
                                                                                    mJSONRow:=TJSONSuperObject.Create;
                                                                                        mJSONRow.I['PosIndex']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex');
                                                                                        //*****mJSONRow.S['Sklad']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code');
                                                                                        mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID');

                                                                                end;

                     }









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
                                                       mJSONHeads.S['ID']:= mr.Strings[0];
                                                       mJSONHeads.S['DocType']:= mDocumentType;
                                                       mJSONHeads.S['DocNumber']:=mBOHead.GetFieldValueAsString('DisplayName');
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

                                                               mJSONHeads.S['ExternalNumber']:= mBOHead.GetFieldValueAsString('ExternalNumber');
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
                                                                                        //*****mJSONRow.S['Sklad']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code');
                                                                                        mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID');
                                                                                        mJSONRow.S['StoreCard_EAN']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN');
                                                                                        mJSONRow.S['StoreCard_Name']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.Name');
                                                                                        mJSONRow.D['Quantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity');
                                                                                        mJSONRow.D['DeliveredQuantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('DeliveredQuantity');
                                                                                       //**** mJSONRow.S['DeliveryDate$DATE']:=FormatDateTime('YYYY-MM-DD',mMonRows.BusinessObject[i].GetFieldValueAsDateTime('DeliveryDate$DATE'));
                                                                                        mJSONRow.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                        if mMonRows.BusinessObject[iRow].GetFieldValueAsinteger('Storecard_ID.Category')=0 then begin
                                                                                                mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                      //mJSONBatch.S['Posindex']:=inttostr(0);
                                                                                                                      //mJSONBatch.S['StoreBatch']:='';
                                                                                                                      //mJSONBatch.D['Quantity']:=0
                                                                                                                      //mJSONBatch.S['QUnit']:='';
                                                                                                                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                        end;


                                                                                        if mImport then begin
                                                                                            mJSONRow.I['RowType']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('RowType');
                                                                                            mJSONRow.S['Text']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Text');
                                                                                            //**** mJSONRow.S['BusOrder_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID');
                                                                                            mJSONRow.S['BusOrder_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID.Code');
                                                                                           //**** mJSONRow.S['BusTransaction_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID');
                                                                                            mJSONRow.S['BusTransaction_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID.Code');
                                                                                            //**** mJSONRow.S['BusProject_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID');
                                                                                            mJSONRow.S['BusProject_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID.Code');
                                                                                            mJSONRow.S['X_ProvideRow_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID');
                                                                                            mJSONRow.S['X_Specifikace_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_specifikace_id');
                                                                                            mJSONRow.S['X_ExternalSpecification']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_ExternalSpecification');
                                                                                            mJSONRow.S['StoreCard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                                                            mJSONRow.S['Store_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID');
                                                                                            //**** mJSON.S['Division_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Division_ID.Code');

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
                                                                                                                mJSONRow.S['TAmount']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
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
                                                                                                                      mJSONBatch.D['DeliveredQuantity']:=0;
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
                                                                                                                                              if mBatchValue.count>2 then mJSONBatch.D['DeliveredQuantity']:=0;
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

       //mJSON.S['_Result_DocType']:=mResult_DocType;
       //mJSON.S['_Result_DocQueue']:=mResult_DocQueue;
       //mJSON.S['_Result_Documents']:=mResult_Documents;
       //mJSON.I['_Result_PocetDokladu']:=mPocetDokladu;
       result:=mJSON;
end;


















 procedure Synchronizace(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  self:TNxCustomBusinessObject;
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
 mMonRows:TNxCustomBusinessMonikerCollection;
 mJSON,mTargetJson,mQueryJson:TJSONSuperObject;
 mJSONArraynHead,mJSONArrayRows:TJSONSuperObjectArray;
 mboolean:boolean;
 mNewQueryrow:string;
 mParseListValue:tstringlist;
 iRow,IBatch:integer;
 mDocrowbatchList:tstringlist;
 mReturnJSON:TJSONSuperObject;
 mReturnImportRow,mReturnOtherRow:double;
 mReturnNewDocNumber,mReturnNewDocID,mReturnSourceDoc:string;
 mFind:boolean;
 mUser:string;
 mQueryStringList:tstringlist;
 mImport:boolean;
 mOK:string;
 mChyba:string;
 mInfo:string;
 mVystup:string;
 mKumulovane:boolean;mOnline:boolean ;
 mPocetDokladu:integer;
begin
mPocetDokladu:=0;
mKumulovane:=false;
mOnline:=true;
  mids:='';
  mReturnNewDocID:='';
  mReturnNewDocNumber:='';
  mReturnSourceDoc:='';
  mReturnImportRow:=0;
  mReturnOtherRow:=0;
  mfind:=true;
  mOK:='';
  mChyba:='';
  mInfo:='';


  if Sender is TComponent then mSite := TComponent(Sender).Site;
    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin


                  mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu



                  mr:=tstringlist.create;
                  try
                       msite.BaseObjectSpace.SQLSelect('Select LoginName from SecurityUsers where ID=' + quotedstr(mSite.CompanyCache.GetUserID),mr);
                       if mr.count>0 then begin

                           mUser:=ReplaceText(mr.strings[0],'"','') ;
                       end;
                  finally
                      mr.free;
                  end;


                                              mIBookmark:=0;
                                              if mBookmark.count>0 then begin
                                                   mIBookmark:=mBookmark.count-1;
                                                   ProgressInit(msite, 'Zpracování dat ' + '', 100);
                                              end;




                                              for mICount:=0 to mIBookmark do begin
                                                  mJSON:=TJSONSuperObject.create;
                                                  try
                                                  if mIBookmark>0 then begin
                                                       mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                                       ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                                  end;
                                                  self:=TBusRollSiteForm(msite).CurrentObject;    // načtení objektu


                                                             case inttostr(index) of
                                                                  '0': begin
                                                                       mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Stavovost dokladu zatím není podporována'  ;
                                                                                //exit;
                                                                       end;

                                                               end;
                                                       mJSON.S['User']:=mUser;

                                                       // **** vyjímky *****





                                                  mJSON:=GetStoreCardJSON(mJSON,self,NxCreateContext_1(self),mICount);
                                                  //mstring:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Source document','Json : ',mJSON.AsString,'Pokračovat','','');

                                                  if true then begin     //mOnline
                                                         if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                       end else begin
                                                                mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                                                                  if (mSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then begin


                                                                       //mboolean:=InputQuery('API','Post 1 doklad',);
                                                                       mstring:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Target document ' + IntToStr(micount),'Json : ',
                                                                       mtarget+'/script/NxApiLib/lib/APINxJSONImportManager' + Chr(10) + chr(10) +mJSON.AsString
                                                                       ,'Pokračovat','','');

                                                                  end;

                                                                       mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxJSONImportManager',mJSON.AsString, true);
                                                                       //NxShowSimpleMessage(mString,nil);
                                                                       mReturnJSON:=TJSONSuperObject.create;
                                                                             try
                                                                             mReturnJSON:= TJSONSuperObject.ParseString(mString,true);

                                                                                  case Trim(UpperCase(mReturnJSON.S['State'])) of
                                                                                        '201': begin
                                                                                             mOK:= mOK  + Chr(13)+ Chr(10) + 'Z ' +  'dokladu: ' + self.DisplayName + ' vznikl doklad ' + NxSearchReplace(mReturnJSON.S['New'],'_','/',[srCase,srAll]) ;
                                                                                                 if NxIBStrToFloat(mReturnJSON.S['Import'])>0 then begin
                                                                                                          mOK:= mOK  + Chr(13)+ Chr(10) + '       čerpáním ' + mReturnJSON.S['Import'] + ' řádků / '  + mReturnJSON.S['Imp_batch'] + ' šarží';
                                                                                                  end;
                                                                                                  if NxIBStrToFloat(mReturnJSON.S['Other'])>0 then begin
                                                                                                          mOK:= mOK  + Chr(13)+ Chr(10) + '       bez vazby ' + mReturnJSON.S['Other'] + ' řádků / '  + mReturnJSON.S['Oth_batch'] + ' šarží';
                                                                                                  end;
                                                                                                  if nxisblank(self.GetFieldValueAsString('X_ExternalDocument')) then begin
                                                                                                         try
                                                                                                               mi:=msite.BaseObjectSpace.SQLExecute('Update ' + mtable + ' set X_Synchronizace$Date=' + quotedstr(NxFloatToIBStr(Now)) + ', X_ExternalDocument=' + quotedstr(NxSearchReplace(mReturnJSON.S['New'],'_','/',[srCase,srAll])) + ' where id= ' + quotedstr(self.oid));
                                                                                                          finally
                                                                                                          end;
                                                                                                  end;
                                                                                                  mPocetDokladu:=mPocetDokladu+1;
                                                                                             end;
                                                                                        '400': begin
                                                                                             mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + mReturnJSON.S['Error']  ;

                                                                                             end;
                                                                                        '200': begin
                                                                                             mInfo:= mInfo +  Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mInfo:= mInfo + Chr(13)+ Chr(10)
                                                                                                    + 'Dne: ' + FormatDateTime('D.M.YY',NxIBStrToFloat(mReturnJSON.S['Error']))
                                                                                                    + ' byl již vytvořen : ' +NxSearchReplace(mReturnJSON.S['New'],'_','/',[srCase,srAll])+ ' uživatelem ' +  mReturnJSON.S['Created_by'] +   Chr(10)+ Chr(13);

                                                                                             end;
                                                                                   end;

                                                                            finally
                                                                             mReturnJSON.free;
                                                                            end;









                                                           end;
                                                    end;






                                                      finally
                                                          mJSON.free;
                                                      end;

                                              end;
                                              end;
                                              if mBookmark.count>0 then ProgressDispose()   ;


            end;


    //TBusRollSiteForm(msite).ActiveDataSet.RefreshAndRestoreLastSelectedItem;

    end;
  mVystup:='';
  if mChyba<>'' then begin
      mVystup:=mVystup + ' # # #  Chyba importu  # # # ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + mChyba ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
  end;

  if mInfo<>'' then begin
      mVystup:=mVystup + ' # # #  Import neproveden  # # # ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + mInfo ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
  end;

  if mOK<>'' then begin
      mVystup:=mVystup + ' * * *  Importováno  * * * ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + mOK ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + 'Bylo vytvořeno ' + inttostr(mPocetDokladu) + ' dokladu' +  chr(13) + chr(10) ;
  end;

 if mVystup<>'' then begin
                           mstring:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Výsledek','Doklady : ',mVystup,'Pokračovat','','');
  end else begin
      NxShowSimpleMessage('Nespecifikovaná chyba , prosím kontaktujte administrátora',nil);
  end;
            //TBusRollSiteForm(msite).RefreshData

end;







//procedure FormCreate_Hook(Self: TSiteForm);
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);

    if copy(muser.GetFieldValueAsString('X_Button_parametr'),9,1)='1' then begin    // hromadná změna stavu




                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Synchr.JSON new';
                mMAction.Hint := 'Synchronizace skladových karet ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('Abra SK');
                mMAction.OnExecuteItem := @Synchronizace;



   end;
finally
    muser.free;
end;

end;


begin
end.

