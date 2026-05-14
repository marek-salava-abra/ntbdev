  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

      const
mTable='Storecards';
mApiTable='Storecards';

var
mQuery:string;




function GetQuerySC(self:TNxCustomBusinessObject;iTarget:integer): string;
var
I:integer;
mMon:TNxCustomBusinessMonikerCollection;
begin
   mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('StoreUnits'));
    mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
                          mQuery:=mQuery +'"category":'  +                              inttostr(Self.GetFieldValueAsinteger('category')) +', '                  ;
                          mQuery:=mQuery +'"code":"'  +                                  Self.GetFieldValueAsString('Code') +'", '                              ;

                          //if iTarget=1 then        mQuery:=mQuery +'"name":"' +                                   copy(Self.GetFieldValueAsString('Name'),1,80) +'", '                             ;
                          //if iTarget=2 then
                          mQuery:=mQuery +'"name":"' +                                   copy(Self.GetFieldValueAsString('X_Name_SK'),1,80) +'", '                             ;
                          //end else begin
                          //        mQuery:=mQuery +'"name":"' +                                   Self.GetFieldValueAsString('X_NAME_CZ') +'", '
                          //end;


                          mQuery:=mQuery +'"X_Marketing_Name":"' +                       Self.GetFieldValueAsString('X_Marketing_Name') +'", '                ;
                          mQuery:=mQuery +'"X_NAME_CZ":"' +                       Self.GetFieldValueAsString('X_NAME_CZ') +'", '                ;
                          mQuery:=mQuery +'"X_Name_SK":"' +                           Self.GetFieldValueAsString('X_Name_SK') +'", '                   ;
                          //mQuery:=mQuery +'"storecardcategory_id":"' +                           Self.GetFieldValueAsString('storecardcategory_id') +'", '                   ;



                          mQuery:=mQuery +'"x_busdivision_id":"' +                       Self.GetFieldValueAsString('x_busdivision_id') +'", '                ;
                          mQuery:=mQuery +'"mainunitcode":"' +                           Self.GetFieldValueAsString('mainunitcode') +'", '                   ;
                          mQuery:=mQuery +'"foreignname":"' +                            Self.GetFieldValueAsString('foreignname') +'", '                   ;
                          mQuery:=mQuery +'"shortname":"' +                              Self.GetFieldValueAsString('shortname') +'", '                    ;
                          mQuery:=mQuery +'"specification":"' +                          Self.GetFieldValueAsString('specification') +'", '               ;
                          mQuery:=mQuery +'"specification2":"' +                         Self.GetFieldValueAsString('specification2') +'", '             ;
                          mQuery:=mQuery +'"isproduct":"' +                            	BoolToStr(Self.GetFieldValueAsBoolean('isproduct'))+'", '       ;                   // ": true,
                          mQuery:=mQuery +'"isscalable":"' +                            	BoolToStr(Self.GetFieldValueAsBoolean('isscalable'))+'", '   ;                      // ": false,
                          mQuery:=mQuery +'"hidden":"' +                         			  BoolToStr(Self.GetFieldValueAsBoolean('hidden'))+'", '        ;                     // ": false,
                          mQuery:=mQuery +'"nonstocktype":"' +                           BoolToStr(Self.GetFieldValueAsBoolean('nonstocktype'))+'", ';                        // ": false,
                          mQuery:=mQuery +'"note":"' +                    			        	Self.GetFieldValueAsString('nonstocktype')+'", '          ;              // ": "",
                          mQuery:=mQuery +'"outofstockbatchdelivery":"' +                inttostr(Self.GetFieldValueAsinteger('outofstockbatchdelivery'))+'", ';  // ": 0,
                          mQuery:=mQuery +'"outofstockdelivery":"' +                     inttostr(Self.GetFieldValueAsinteger('outofstockdelivery'))+'", ' ;      // ": 0,
//                          mQuery:=mQuery +'"plu":"' +              				              inttostr(Self.GetFieldValueAsinteger('plu'))+'", '                ;      // ": 0,
//                          mQuery:=mQuery +'"prefixcode":"' +                            	Self.GetFieldValueAsString('prefixcode')+'", '                 ;         // ": "",
//                          mQuery:=mQuery +'"priority":"' +                            		inttostr(Self.GetFieldValueAsinteger('priority'))+'", '       ;          // ": 0,
                          mQuery:=mQuery +'"quantitydiscount_id":"' +                    Self.GetFieldValueAsString('quantitydiscount_id')+'", '       ;          // ": null,
//                          mQuery:=mQuery +'"serialnumberstructure":"' +                  Self.GetFieldValueAsString('serialnumberstructure')+'", '    ;           // ": "",
//                          mQuery:=mQuery +'"storeassortmentgroup_id":"' +                Self.GetFieldValueAsString('storeassortmentgroup_id')+'", ' ;              // ": "5VD0000101",
//                          mQuery:=mQuery +'"storebatchstructure_id":"' +                 Self.GetFieldValueAsstring('storebatchstructure_id')+'", ' ;               // ": null,
 //                         mQuery:=mQuery             +'"storemenuitem_id":"' +                   	  Self.GetFieldValueAsString('storemenuitem_id')+'", '   ;                   // ": "1A30000101",
                          mQuery:=mQuery +'"useoutofstockbatchdelivery":"' +             BoolToStr(Self.GetFieldValueAsBoolean('useoutofstockbatchdelivery'))+'",  ';          // ": false,
                          mQuery:=mQuery +'"useoutofstockdelivery":"' +                  BoolToStr(Self.GetFieldValueAsBoolean('useoutofstockdelivery'))+'", '   ;             // ": false,
//                          mQuery:=mQuery +'"usualgrossprofit":"' +                       inttostr(Self.GetFieldValueAsinteger('usualgrossprofit'))+'", '        ;   // ": 0,
//                          mQuery:=mQuery +'"x_aktivacenakladoveceny":"' +                inttostr(Self.GetFieldValueAsinteger('x_aktivacenakladoveceny'))+'", ';    // ": 0,
                          mQuery:=mQuery +'"x_aktivni":"' +                            	BoolToStr(Self.GetFieldValueAsBoolean('x_aktivni'))+'", '             ;              // ": true,
                          mQuery:=mQuery +'"x_barva":"' +                            		Self.GetFieldValueAsString('x_barva')+'", '                          ;     // ": "černá",
                          mQuery:=mQuery +'"x_brand_id":"' +                            	Self.GetFieldValueAsString('x_brand_id')+'", '                    ;       // ": "1QT1000101",
                          mQuery:=mQuery +'"x_bustransaction_id":"' +                    Self.GetFieldValueAsString('x_bustransaction_id')+'", '           ;        // ": "1T00000101",
                          mQuery:=mQuery +'"x_caskontrola":"' +                          NxFloatToIBStr(Self.GetFieldValueAsFloat('x_caskontrola'))+'", ' ;        // ": 2,
                          mQuery:=mQuery +'"x_casstrih":"' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_casstrih'))+'", '          ; // ": 1.25,
                          mQuery:=mQuery +'"x_casvyroby_ks":"' +                         NxFloatToIBStr(Self.GetFieldValueAsFloat('x_casvyroby_ks'))+'",  '     ; // ": 16.2,
                          mQuery:=mQuery +'"x_category":"' +                            	inttostr(Self.GetFieldValueAsinteger('x_category'))+'", '            ;   // ": 0,
                          mQuery:=mQuery +'"x_cena_skladova_SK":"' +                        NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladova_SK'))+'", ';      // ": 185.81,
                          mQuery:=mQuery +'"x_cena_rozprac_SK":"' +                        NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_rozprac_SK'))+'", ';      // ": 185.81,
                          mQuery:=mQuery +'"ExpirationDue":'  +                              inttostr(Self.GetFieldValueAsinteger('ExpirationDue')) +', '                  ;
                          mQuery:=mQuery +'"X_Skupina_ID":"' +                            		Self.GetFieldValueAsString('X_skupina_ID')+'", '                          ;     // ": "černá",
                          mQuery:=mQuery +'"x_cena":"' +                            			NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_precen'))+'", '    ;    // ": 0,
//                          mQuery:=mQuery +'"x_cena_rozprac":"' +                         NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_rozprac'))+'", '   ;    // ": 95.61,
//                          mQuery:=mQuery +'"x_cena_rozprac1":"' +                        NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_rozprac1'))+'", ' ;     // ": 45,
//                          mQuery:=mQuery +'"x_cena_skladova":"' +                        NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladova'))+'", ';      // ": 185.81,
//                          mQuery:=mQuery +'"x_cena_skladova1":"' +                       NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladova1'))+'", '   ;  // ": 165.11,
//                          mQuery:=mQuery +'"x_cena_skladovaxxx":"' +                     NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cena_skladovaxxx'))+'", ' ;  // ": 138.29,
                          mQuery:=mQuery +'"x_cenakontrola":"' +                         NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenakontrola'))+'", '     ;  // ": 3.72,
                          mQuery:=mQuery +'"x_cenamin_cz":"' +                           NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenamin_cz'))+'", '       ;  // ": 211.89,
                          mQuery:=mQuery +'"x_cenamin_dcera":"' +                        NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenamin_dcera'))+'", '   ;   // ": 297.3,
                          mQuery:=mQuery +'"x_cenamin_export":"' +                       NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenamin_export'))+'", ' ;    // ": 211.89,
                          mQuery:=mQuery +'"x_cenarezm":"' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenarezm'))+'",  '       ;   // ": 3.64,
                          mQuery:=mQuery +'"x_cenasiti":"' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenasiti'))+'",  '      ;    // ": 3.49,
                          mQuery:=mQuery +'"x_cenasprava":"' +                           NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenasprava'))+'", '     ;    // ": 1.09,
                          mQuery:=mQuery +'"x_cenastrih":"' +                            NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenastrih'))+'",  '    ;     // ": 3.49,
                          mQuery:=mQuery +'"x_cenathp":"' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenathp'))+'",  '      ;     // ": 1.35,
                         mQuery:=mQuery +'"x_cenavyrm":"' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenavyrm'))+'",  '  ;        // ": 77.74,
                         mQuery:=mQuery +'"x_cenavyrrez":"' +                           NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cenavyrrez'))+'", ' ;        // ": 0.5,
                         mQuery:=mQuery +'"x_cert_no_do":' +                            NxFloatToIBStr(Self.GetFieldValueAsFloat('x_cert_no_do'))+', ' ;                             // ": null,
                          mQuery:=mQuery +'"x_certifikat":"' +                           Self.GetFieldValueAsString('x_certifikat')+'", '              ;          // ": "",
                          mQuery:=mQuery +'"x_certifikat_do":' +                         NxFloatToIBStr(Self.GetFieldValueAsFloat('x_certifikat_do'))+', ' ;                          // ": null,
                          mQuery:=mQuery +'"x_certifikat_notifikace":"' +                Self.GetFieldValueAsString('x_certifikat_notifikace')+'", '  ;           // ": "",
//                          mQuery:=mQuery +'"x_cesta_detail01":"' +                       Self.GetFieldValueAsString('x_cesta_detail01')+'", '        ;            // ": "",
//                          mQuery:=mQuery +'"x_cesta_detail02":"' +                       Self.GetFieldValueAsString('x_cesta_detail02')+'", '       ;             // ": "",
//                          mQuery:=mQuery +'"x_cesta_detail03":"' +                       Self.GetFieldValueAsString('x_cesta_detail03')+'", '      ;              // ": "",
//                          mQuery:=mQuery +'"x_cesta_detail04":"' +                       Self.GetFieldValueAsString('x_cesta_detail04')+'", '     ;               // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona01":"' +                        Self.GetFieldValueAsString('x_cesta_ikona01')+'", '                    ; // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona02":"' +                        Self.GetFieldValueAsString('x_cesta_ikona02')+'", '                   ;  // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona03":"' +                        Self.GetFieldValueAsString('x_cesta_ikona03')+'", '                  ;   // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona04":"' +                        Self.GetFieldValueAsString('x_cesta_ikona04')+'", '                 ;    // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona05":"' +                        Self.GetFieldValueAsString('x_cesta_ikona05')+'", '                ;     // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona06":"' +                        Self.GetFieldValueAsString('x_cesta_ikona06')+'", '               ;      // ": "",
//                          mQuery:=mQuery +'"x_cesta_ikona07":"' +                        Self.GetFieldValueAsString('x_cesta_ikona07')+'", '              ;       // ": "",
//                          mQuery:=mQuery +'"x_cesta_model_cz":"' +                       Self.GetFieldValueAsString('x_cesta_model_cz')+'", '            ;        // ": "",
//                          mQuery:=mQuery +'"x_cesta_model_en":"' +                       Self.GetFieldValueAsString('x_cesta_model_en')+'", '           ;         // ": "",
//                          mQuery:=mQuery +'"x_cesta_obrazek":"' +                        Self.GetFieldValueAsString('x_cesta_obrazek')+'", '           ;          // ": "",
//                          mQuery:=mQuery +'"x_cesta_obrazek01":"' +                      Self.GetFieldValueAsString('x_cesta_obrazek01')+'", '        ;           // ": "",
//                          mQuery:=mQuery +'"x_cesta_obrazek02":"' +                      Self.GetFieldValueAsString('x_cesta_obrazek02')+'", '       ;            // ": "",
//                          mQuery:=mQuery +'"x_cesta_obrazek03":"' +                      Self.GetFieldValueAsString('x_cesta_obrazek03')+'", '      ;             // ": "",
//                          mQuery:=mQuery +'"x_cesta_obrazek04":"' +                      Self.GetFieldValueAsString('x_cesta_obrazek04')+'", '     ;              // ": "",
                          mQuery:=mQuery +'"x_cesta_piktogram":"' +                      Self.GetFieldValueAsString('x_cesta_piktogram')+'", '    ;               // ": "",
                          mQuery:=mQuery +'"x_cesta_piktogram1":"' +                     Self.GetFieldValueAsString('x_cesta_piktogram1')+'", '  ;                // ": "",
//                          mQuery:=mQuery +'"x_cz_pomoc_name":"' +                        Self.GetFieldValueAsString('x_cz_pomoc_name')+'", '                 ;    // ": "99180",
//                         mQuery:=mQuery +'"x_date$checksukl":' +                         NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$checksukl'))+', ' ;                 // ": null,
//                          mQuery:=mQuery +'"x_date$eudamed":' +                          NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$eudamed'))+', '  ;                  // ": null,
//                          mQuery:=mQuery +'"x_date$initsukl":' +                         NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$initsukl'))+', ';                   // ": null,
//                          mQuery:=mQuery +'"x_date$newce":' +                            NxFloatToIBStr(Self.GetFieldValueAsFloat('x_date$newce'))+', '  ;                    // ": null,
                          mQuery:=mQuery +'"x_davka_sici":"' +                           inttostr(Self.GetFieldValueAsinteger('x_davka_sici'))+'", '    ;         // ": 20,
//                          mQuery:=mQuery +'"x_documentacedate$date":' +                  NxFloatToIBStr(Self.GetFieldValueAsFloat('x_documentacedate$date'))+', ' ;          // ": null,




                          mQuery:=mQuery +'"x_e_druh":"' +                            		Self.GetFieldValueAsString('x_e_druh')+'", '                   ;         // ": "5900000101",
                          mQuery:=mQuery +'"x_e_provedeni":"' +                          Self.GetFieldValueAsString('x_e_provedeni')+'",  '             ;         // ": "1700000101",
                          mQuery:=mQuery +'"x_e_typ":"' +                            		Self.GetFieldValueAsString('x_e_typ')+'",  '                   ;         // ": "PI",
                          mQuery:=mQuery +'"x_ean_usa":"' +                            	Self.GetFieldValueAsString('x_ean_usa')+'", '                 ;          // ": "8591846102994",





//                          mQuery:=mQuery +'"x_en_pomoc_name":"' +                        Self.GetFieldValueAsString('x_en_pomoc_name')+'", '         ;            // ": "300188",
  //                        mQuery:=mQuery +'"x_en_popis_mat_sl":"' +                      Self.GetFieldValueAsString('x_en_popis_mat_sl')+'", '      ;             // ": "",
//                          mQuery:=mQuery +'"x_en_popis_produktu":"' +                    Self.GetFieldValueAsString('x_en_popis_produktu')+'", '   ;              // ": "",
//                          mQuery:=mQuery +'"x_en_popis_tab":"' +                         Self.GetFieldValueAsString('x_en_popis_tab')+'", '       ;               // ": "",
//                          mQuery:=mQuery +'"x_en_popis_udrzba":"' +                      Self.GetFieldValueAsString('x_en_popis_udrzba')+'", '   ;                // ": "",
//                          mQuery:=mQuery +'"x_eshop":"' +                            		Self.GetFieldValueAsString('x_eshop')+'", '             ;                // ": "",
//                          mQuery:=mQuery +'"x_fda_id":"' +                            		Self.GetFieldValueAsString('x_fda_id')+'", '         ;                   // ": "QZ47000101",
//                          mQuery:=mQuery +'"x_gmdn":"' +                            			Self.GetFieldValueAsString('x_gmdn')+'", '          ;                    // ": null,
//                          mQuery:=mQuery +'"x_katalogno":"' +                            Self.GetFieldValueAsString('x_katalogno')+'", '     ;                    // ": "",
//                          mQuery:=mQuery +'"x_katalogusa":"' +                           Self.GetFieldValueAsString('x_katalogusa')+'", '                 ;       // ": "US-B005V-B-32C",
//                          mQuery:=mQuery +'"x_koeficient_ceny_zbozi_cz_b2b":"' +         inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_cz_b2b'))+'", ' ;  // ": 1,
//                          mQuery:=mQuery +'"x_koeficient_ceny_zbozi_cz_b2c":"' +         inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_cz_b2c'))+'", ' ;  // ": 1,
//                          mQuery:=mQuery +'"x_koeficient_ceny_zbozi_en_b2b":"' +         inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_en_b2b'))+'", ' ;  // ": 1,
//                          mQuery:=mQuery +'"x_koeficient_ceny_zbozi_en_b2c":"' +         inttostr(Self.GetFieldValueAsinteger('x_koeficient_ceny_zbozi_en_b2c'))+'", ';   // ": 1,
                          mQuery:=mQuery +'"x_konec_vyroby":"' +                         BoolToStr(Self.GetFieldValueAsBoolean('x_konec_vyroby'))+'", '    ;                 // ": false,
//                          mQuery:=mQuery +'"x_krabicka_id":"' +                          Self.GetFieldValueAsString('x_krabicka_id')+'",  '               ;       // ": "9MSB000101",
                          mQuery:=mQuery +'"x_krabicka_pocet":"' +                       inttostr(Self.GetFieldValueAsinteger('x_krabicka_pocet'))+'", ' ;        // ": 1,
                          mQuery:=mQuery +'"x_lycra":"' +                            		Self.GetFieldValueAsString('x_lycra')+'", '                 ;            // ": null,
              //            mQuery:=mQuery +'"x_marketingova_cena":"' +                    NxFloatToIBStr(Self.GetFieldValueAsFloat('x_marketingova_cena'))+'", ' ; // ": 216.87,
              //            mQuery:=mQuery +'"x_marketingova_cena1":"' +                   NxFloatToIBStr(Self.GetFieldValueAsFloat('x_marketingova_cena1'))+'", '; // ": 177.29,
                          mQuery:=mQuery +'"x_mat1":"' +                                 Self.GetFieldValueAsString('x_mat1')+'", '                     ;         // ",
                          mQuery:=mQuery +'"x_mat1_proc":"' +                            inttostr(Self.GetFieldValueAsinteger('x_mat1_proc'))+'", '    ;     ;     // ": 83,
                          mQuery:=mQuery +'"x_mat2":"' +                                 Self.GetFieldValueAsString('x_mat2')+'", '                        ;      // ",
                          mQuery:=mQuery +'"x_mat2_proc":"' +                            inttostr(Self.GetFieldValueAsinteger('x_mat2_proc'))+'", '       ;       // ": 17,
                          mQuery:=mQuery +'"x_mat3":"' +                            			Self.GetFieldValueAsString('x_mat3')+'", '                     ;         // ": null,
                          mQuery:=mQuery +'"x_mat3_proc":"' +                            inttostr(Self.GetFieldValueAsinteger('x_mat3_proc'))+'", '     ;         // ": 0,
                          mQuery:=mQuery +'"x_mat4":"' +                            			Self.GetFieldValueAsString('x_mat4')+'", '                   ;           // ": null,
                          mQuery:=mQuery +'"x_mat4_proc":"' +                            inttostr(Self.GetFieldValueAsinteger('x_mat4_proc'))+'", '   ;           // ": 0,
                          mQuery:=mQuery +'"x_mat5":"' +                            			Self.GetFieldValueAsString('x_mat5')+'", '                 ;             // ": null,
                          mQuery:=mQuery +'"x_mat5_proc":"' +                            inttostr(Self.GetFieldValueAsinteger('x_mat5_proc'))+'", ' ;             // ": 0,
                          mQuery:=mQuery +'"x_matka":"' +                            		 BoolToStr(Self.GetFieldValueAsBoolean('x_matka'))+'", '   ;                         // ": false,
                          mQuery:=mQuery +'"x_mermed":"' +                            		Self.GetFieldValueAsString('x_mermed')+'", '  ;                          // ": "mm12",
                          mQuery:=mQuery +'"x_min_objedn_mnozstvi":"' +                  inttostr(Self.GetFieldValueAsinteger('x_min_objedn_mnozstvi'))+'", '  ;  // ": 20,
                          mQuery:=mQuery +'"x_name_at":"' +                            	Self.GetFieldValueAsString('x_name_at')+'", '            ;               // ": "",
                          mQuery:=mQuery +'"x_name_de":"' +                            	Self.GetFieldValueAsString('x_name_de')+'", '           ;                // ": "",
                          mQuery:=mQuery +'"x_name_dk":"' +                            	Self.GetFieldValueAsString('x_name_dk')+'", '          ;                 // ": "",
                          mQuery:=mQuery +'"x_name_en":"' +                            	Self.GetFieldValueAsString('x_name_en')+'", '         ;                  // ": "_/PI standard, Variant, size 70C, black",
                          mQuery:=mQuery +'"x_name_es":"' +                            	Self.GetFieldValueAsString('x_name_es')+'", '        ;                   // ": "",
                          mQuery:=mQuery +'"x_name_fr":"' +                            	Self.GetFieldValueAsString('x_name_fr')+'", '       ;                    // ": "",
                          mQuery:=mQuery +'"x_name_hu":"' +                            	Self.GetFieldValueAsString('x_name_hu')+'", '      ;                     // ": "",
                          mQuery:=mQuery +'"x_name_it":"' +                            	Self.GetFieldValueAsString('x_name_it')+'", '     ;                      // ": "_/PI standard, Taglia 70C, nero",
                          mQuery:=mQuery +'"x_name_pl":"' +                            	Self.GetFieldValueAsString('x_name_pl')+'", '    ;                       // ": "",
                          mQuery:=mQuery +'"x_name_ru":"' +                            	Self.GetFieldValueAsString('x_name_ru')+'", '    ;                       // ": "",
                          mQuery:=mQuery +'"x_name_usa":"' +                            	Self.GetFieldValueAsString('x_name_usa')+'", '  ;                        // ": "",
                          mQuery:=mQuery +'"x_navod":"' +                            		Self.GetFieldValueAsString('x_navod')+'", '           ;                  // ": "",
//                          mQuery:=mQuery +'"x_notifik_osoba":"' +                        Self.GetFieldValueAsString('x_notifik_osoba')+'", '  ;                   // ": "",
                          mQuery:=mQuery +'"x_obchodni_pripad":"' +                      Self.GetFieldValueAsString('x_obchodni_pripad')+'", ' ;                  // ": "HE10000101",
                          mQuery:=mQuery +'"x_pad":"' +                            			Self.GetFieldValueAsString('x_pad')+'", '           ;                    // ": null,
                          mQuery:=mQuery +'"x_parametry":"' +                            Self.GetFieldValueAsString('x_parametry')+'", '   ;                      // ": "",
                          mQuery:=mQuery +'"x_parent_id":"' +                            Self.GetFieldValueAsString('x_parent_id')+'", '    ;                     // ": "CM9N000101",
                          mQuery:=mQuery +'"x_pocetksvbal":"' +                          inttostr(Self.GetFieldValueAsinteger('x_pocetksvbal'))+'", ' ;           // ": 1,
//                          mQuery:=mQuery +'"x_popis_mat_sl":"' +                         Self.GetFieldValueAsString('x_popis_mat_sl')+'", '    ;                  // ": "",
//                          mQuery:=mQuery +'"x_popis_produktu":"' +                       Self.GetFieldValueAsString('x_popis_produktu')+'", ' ;                   // ": "",
//                          mQuery:=mQuery +'"x_popis_tab":"' +                            Self.GetFieldValueAsString('x_popis_tab')+'", '      ;                   // ": "",
//                          mQuery:=mQuery +'"x_popis_udrzba":"' +                         Self.GetFieldValueAsString('x_popis_udrzba')+'", '  ;                    // ": "",
                          mQuery:=mQuery +'"x_praci_symbol":"' +                         Self.GetFieldValueAsString('x_praci_symbol')+'", '  ;                    // ": "3Z02000101",
                          mQuery:=mQuery +'"x_prepocet":"' +                            	BoolToStr(Self.GetFieldValueAsBoolean('x_prepocet'))+'", ' ;                        // ": false,
                          mQuery:=mQuery +'"x_pv_kata":"' +                            	inttostr(Self.GetFieldValueAsinteger('x_pv_kata'))+'", '  ;              // ": 0,
                          mQuery:=mQuery +'"x_pv_katb":"' +                            	inttostr(Self.GetFieldValueAsinteger('x_pv_katb'))+'", '  ;              // ": 0,
                          mQuery:=mQuery +'"x_pv_katc":"' +                            	inttostr(Self.GetFieldValueAsinteger('x_pv_katc'))+'", ' ;               // ": 0,
                          mQuery:=mQuery +'"x_pv_katd":"' +                            	inttostr(Self.GetFieldValueAsinteger('x_pv_katd'))+'", ';                // ": 15,
                          mQuery:=mQuery +'"x_pzn":"' +                            			Self.GetFieldValueAsString('x_pzn')+'", ' ;                              // ": "",
 //                         mQuery:=mQuery +'"x_ridici_karta_seskupeni":"' +               Self.GetFieldValueAsString('x_ridici_karta_seskupeni')+'", ' ;           // ": "7CZ0000101",
//                          mQuery:=mQuery  +'"x_sacek_id":"' +                            	Self.GetFieldValueAsString('x_sacek_id')+'", '     ;                     // ": "7MVA000101",
                          mQuery:=mQuery +'"x_sacek_old_id":"' +                         Self.GetFieldValueAsString('x_sacek_old_id')+'", '     ;                 // ": null,
                          mQuery:=mQuery +'"x_sleva_dodavatel":"' +                      inttostr(Self.GetFieldValueAsinteger('x_sleva_dodavatel'))+'", ';        // ": 0,
            //            mQuery:=mQuery +'"x_spolecny_kusovnik":"' +                    Self.GetFieldValueAsString('x_spolecny_kusovnik')+'", '    ;             // ": "1I00000101",
              //            mQuery:=mQuery +'"x_spolecny_technpostup":"' +                 Self.GetFieldValueAsString('x_spolecny_technpostup')+'", '    ;          // ": "G830000101",
                          mQuery:=mQuery +'"x_statistika":"' +                           Self.GetFieldValueAsString('x_statistika')+'", ' ;                       // ": "2Z42000101",
                          mQuery:=mQuery +'"x_stb_siti":"' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_stb_siti'))+'", ';           // ": 12.9,
                          mQuery:=mQuery +'"x_sterile":"' +                            	BoolToStr(Self.GetFieldValueAsBoolean('x_sterile'))+'", '    ;                      // ": false,
                          mQuery:=mQuery +'"x_texlabel":"' +                            	inttostr(Self.GetFieldValueAsinteger('x_texlabel'))+'", ' ;              // ": 0,
                          mQuery:=mQuery +'"x_tisk":"' +                            			BoolToStr(Self.GetFieldValueAsBoolean('x_tisk'))+'", ';                             // ": false,
                          mQuery:=mQuery +'"x_typ":"' +                            			Self.GetFieldValueAsString('x_typ')+'",  '   ;                           // ": "C/PI",
                          mQuery:=mQuery +'"x_typ_deveno":"' +                           Self.GetFieldValueAsString('x_typ_deveno')+'", '  ;                      // ": null,
                          mQuery:=mQuery +'"x_typ_produktu":"' +                         Self.GetFieldValueAsString('x_typ_produktu')+'", ' ;                     // ": "2VH1000101",
                          mQuery:=mQuery +'"x_typ_uctovani":"' +                         Self.GetFieldValueAsString('x_typ_uctovani')+'", ';                      // ": "V",
                          mQuery:=mQuery +'"x_typ_velky":"' +                            Self.GetFieldValueAsString('x_typ_velky')+'", ' ;                        // ": "PI",
                          mQuery:=mQuery +'"x_ukonceni":' +                            	NxFloatToIBStr(Self.GetFieldValueAsFloat('x_ukonceni'))+', ' ;                         // ": null,
                          mQuery:=mQuery +'"x_vaha":"' +                            			NxFloatToIBStr(Self.GetFieldValueAsFloat('x_vaha'))+'", ' ;              // ": 0.123,
                          mQuery:=mQuery +'"x_vaha_krabicka":"' +                        NxFloatToIBStr(Self.GetFieldValueAsFloat('x_vaha_krabicka'))+'", ' ;     // ": 0.037,
                          mQuery:=mQuery +'"x_velikost":"' +                            	Self.GetFieldValueAsString('x_velikost')+'", '    ;                      // ": null,
                          mQuery:=mQuery +'"x_velikost_id":"' +                          Self.GetFieldValueAsString('x_velikost_id')+'", '  ;                     // ": "EFS0000101",
                          mQuery:=mQuery +'"x_verze":"' +                            		Self.GetFieldValueAsString('x_verze')+'", ';                             // ": "",
                          mQuery:=mQuery +'"x_zip":"' +                            			Self.GetFieldValueAsString('x_zip')+'", '  ;
                          //if (iTarget<>2) then begin
                          //     mQuery:=mQuery +'"vatrate_id":"' +                       Self.GetFieldValueAsString('vatrate_id')+'", '  ;
                          //end;
                          //if (iTarget=2)  then begin
                                if NxIsEmptyOID(Self.GetFieldValueAsString('X_sazba_DPH_SK')) then begin
                                      mQuery:=mQuery +'"vatrate_id":"' +                            '02000X0000' +'", '  ;                           // ": ""
                                end else begin
                                      mQuery:=mQuery +'"vatrate_id":"' +                            			Self.GetFieldValueAsString('X_sazba_DPH_SK')+'", '  ;                          // ": ""
                                end;

                          //end;
                           // ": ""

                          mQuery:=mQuery +'"U_Kod_pojistovny":"' +                      Self.GetFieldValueAsString('U_Kod_pojistovny')+'", '  ;
                          mQuery:=mQuery +'"U_vestnikova_cena":"' +                     Self.GetFieldValueAsString('U_vestnikova_cena')+'", '  ;
                          mQuery:=mQuery +'"U_OPD":"' +                            			Self.GetFieldValueAsString('U_OPD')+'", '  ;
                          mQuery:=mQuery +'"U_pc_mjd":"' +                            	Self.GetFieldValueAsString('U_pc_mjd')+'", '  ;
                          mQuery:=mQuery +'"U_max_cena":"' +                            Self.GetFieldValueAsString('U_max_cena')+'", '  ;
                          mQuery:=mQuery +'"U_Regulovana_cena":"' +                            			BoolToStr(Self.GetFieldValueAsBoolean('U_Regulovana_cena'))+'", ';
                          mQuery:=mQuery +'"U_kod_pojist":"' +                          Self.GetFieldValueAsString('U_kod_pojist')+'", '  ;
                          mQuery:=mQuery +'"U_Typ_zdravotiho_prostredu":"' +            Self.GetFieldValueAsString('U_Typ_zdravotiho_prostredu')+'", '  ;
                          mQuery:=mQuery +'"U_OPD2":"' +                            		Self.GetFieldValueAsString('U_OPD2')+'", '  ;
                          mQuery:=mQuery +'"U_pc_mjd2":"' +                            	Self.GetFieldValueAsString('U_pc_mjd2')+'", '  ;
                          mQuery:=mQuery +'"U_max_cena2":"' +                           Self.GetFieldValueAsString('U_max_cena2')+'", '  ;
                          mQuery:=mQuery +'"U_Vest_cena2":"' +                          Self.GetFieldValueAsString('U_Vest_cena2')+'", '  ;
                          mQuery:=mQuery +'"U_barva_ID":"' +                            Self.GetFieldValueAsString('U_barva_ID')+'", '  ;
                          mQuery:=mQuery +'"U_provedeni_ID":"' +                        Self.GetFieldValueAsString('U_provedeni_ID')+'", '  ;
                          mQuery:=mQuery +'"U_druh_ID":"' +                            	Self.GetFieldValueAsString('U_druh_ID')+'", '  ;
                          mQuery:=mQuery +'"U_Obrazek":"' +                            	Self.GetFieldValueAsString('U_Obrazek')+'", '  ;
                          mQuery:=mQuery +'"U_Material":"' +                            Self.GetFieldValueAsString('U_Material')+'", '  ;
                          mQuery:=mQuery +'"U_komprese_ID":"' +                         Self.GetFieldValueAsString('U_komprese_ID')+'", '  ;
                          mQuery:=mQuery +'"X_KompreseID":"' +                          Self.GetFieldValueAsString('X_KompreseID')+'", '  ;

                          mQuery:=mQuery +'"U_velikost_chodidla_ID":"' +                Self.GetFieldValueAsString('U_velikost_chodidla_ID')+'", '  ;
                          mQuery:=mQuery +'"U_obvod_stehna_ID":"' +                     Self.GetFieldValueAsString('U_obvod_stehna_ID')+'", '  ;
                          mQuery:=mQuery +'"U_vyska_ID":"' +                            Self.GetFieldValueAsString('U_vyska_ID')+'", '  ;
                          mQuery:=mQuery +'"U_boky_ID":"' +                            	Self.GetFieldValueAsString('U_boky_ID')+'", '  ;
                          mQuery:=mQuery +'"U_velikost_ID":"' +                         Self.GetFieldValueAsString('U_velikost_ID')+'", '  ;
                          mQuery:=mQuery +'"U_material_ID":"' +                         Self.GetFieldValueAsString('U_material_ID')+'", '  ;
                          mQuery:=mQuery +'"U_punc_typ":"' +                            Self.GetFieldValueAsString('U_punc_typ')+'", '  ;
                          mQuery:=mQuery +'"U_nadpis":"' +                            	Self.GetFieldValueAsString('U_nadpis')+'", '  ;
                          mQuery:=mQuery +'"U_EAN_maxis":"' +                           Self.GetFieldValueAsString('U_EAN_maxis')+'", '  ;
                          mQuery:=mQuery +'"U_Material_2":"' +                          Self.GetFieldValueAsString('U_Material_2')+'", '  ;
                          mQuery:=mQuery +'"U_PAD_MAXIS":"' +                           Self.GetFieldValueAsString('U_PAD_MAXIS')+'", '  ;
                          mQuery:=mQuery +'"U_LYCRA_MAXIS":"' +                         Self.GetFieldValueAsString('U_LYCRA_MAXIS')+'", '  ;
                          mQuery:=mQuery +'"U_UcelCZ":"' +                            	Self.GetFieldValueAsString('U_UcelCZ')+'", '  ;
                          mQuery:=mQuery +'"U_UcelEN":"' +                            	Self.GetFieldValueAsString('U_UcelEN')+'", '  ;
                          mQuery:=mQuery +'"U_klinhodn":"' +                            Self.GetFieldValueAsString('U_klinhodn')+'", '  ;






                          mQuery:=mQuery +'"storeunits": [  ';
                        for i := 0 to mMon.Count-1 do begin
                                         mQuery:=mQuery +' { ';
                                        mQuery:=mQuery +'"ID":"' +                            		   mMon.BusinessObject[i].GetFieldValueAsString('ID')+'", ' ;
                                        mQuery:=mQuery +'"code":"' +                            		   mMon.BusinessObject[i].GetFieldValueAsString('code')+'", ' ;
                                        mQuery:=mQuery +'"ean":"' +                            		     mMon.BusinessObject[i].GetFieldValueAsString('EAN')+'", '  ;
                                        mQuery:=mQuery +'"description":"' +                           mMon.BusinessObject[i].GetFieldValueAsString('description')+'", '   ;
              //                          mQuery:=mQuery +'"unitrate":' +                            	 inttostr(mMon.BusinessObject[i].GetFieldValueAsinteger('unitrate'))+', '   ;
                                        mQuery:=mQuery +'"posindex":' +                            	 inttostr(mMon.BusinessObject[i].GetFieldValueAsInteger('posindex'))+', '   ;

              //
                                        mQuery:=mQuery +'"capacity":' +                            	 NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('capacity'))+', ';
                                        mQuery:=mQuery +'"capacityunit":"' +                          inttostr(mMon.BusinessObject[i].GetFieldValueAsInteger('capacityunit'))+'", ' ;
                                        mQuery:=mQuery +'"depth":"' +                            		 NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('depth'))+'", '    ;
                                        mQuery:=mQuery +'"height":"' +                            		 NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('height'))+'", ' ;
                                       // mQuery:=mQuery +'"indivisiblequantity":"' +                   inttostr(Self.GetFieldValueAsinteger('indivisiblequantity'))+'", '   ;
                                        //  mQuery:=mQuery +'"plu":' +                            		   inttostr(mMon.BusinessObject[i].BusinessObject[i].GetFieldValueAsInteger('plu'))+', '    ;

              //                          mQuery:=mQuery +'"sizeunit":"' +                            	 inttostr(mMon.BusinessObject[i].GetFieldValueAsInteger('sizeunit'))+'", '  ;
                                        mQuery:=mQuery +'"weight":"' +                            		 NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('weight'))+'", '    ;
                                        mQuery:=mQuery +'"weightunit":"' +                            inttostr(mMon.BusinessObject[i].GetFieldValueAsInteger('weightunit'))+'", ' ;
                                        mQuery:=mQuery +'"width":"' +                            		 NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('width'))+'", ' ;
                                        mQuery:=mQuery +'"x_de_name":"' +                             mMon.BusinessObject[i].GetFieldValueAsString('x_de_name')+'", '   ;
                                        mQuery:=mQuery +'"x_en_nazev":"' +                            mMon.BusinessObject[i].GetFieldValueAsString('x_en_nazev')+'", '  ;
              //                          mQuery:=mQuery +'"x_unit_id":"' +                             mMon.BusinessObject[i].GetFieldValueAsString('x_unit_id')+'" '  ;
              //                          mQuery:=mQuery +'"hasanycontainer": ' +                       BoolToStr(Self.GetFieldValueAsBoolean('hasanycontainer'))+' ' ;
                                mQuery:=mQuery +' } ,';
                        end;

                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


         result:=mQuery;
end;



function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TRollSiteForm;index:integer;mICount:integer): string;
var
mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 astring:string;
 mr:TStringList;
 mString:string;
 mMon:TNxCustomBusinessMonikerCollection;
 mSU_ID:string;
 mboolean:boolean;
begin
 result:='';
   mTargetList:=tstringlist.create;
mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
    TRY


       //  mTargetList.Add(mSourceAPI + '/');
       //  mTargetList.Add('');
         mTargetList.Add(mTargetAPI + '/');



         // NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
         //   NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
          if true then begin
          //copy(mBO.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
                  mid:='';
                        //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
                     //                NxShowSimpleMessage(mBO.ObjectSpace.GetConnectionName,nil);
                     mQuery:='{}';



                   //   NxShowSimpleMessage(mQuery,nil) ;
                      // *** dohledání záznamu v cílové databázi
                        mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " id = ' + QuotedStr(mBO.OID)
                              +' " '
                              +'}';
              //                NxShowSimpleMessage(mQueryID,nil);


                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                    //NxShowSimpleMessage('Dohledán ' + copy(mString,15,10),nil);
                                    if copy(mString,9,2)='ID' then begin      // záznam namezen
                                             mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                    end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;




                        IF mid='' THEN BEGIN
                            //NxShowSimpleMessage('Nový záznam se stejným ID',nil);

                                 mNewQueryID:='{"info_type": "New_value" ' ;
                                 mNewQueryID:=mNewQueryID +','+' "mSQL": "INSERT INTO ' + mtable + ' (ID,category,code,name,hidden,mainunitcode,EAN,storecardcategory_id,CreatedBy_ID,CreatedAt$DATE,Country_ID) VALUES (';
                                 mNewQueryID:=mNewQueryID + quotedstr(mBO.oid) ;
                                                          mNewQueryID:=mNewQueryID + ','+ inttostr(mBO.GetFieldValueAsinteger('category')) ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(mBO.GetFieldValueAsString('Code')) ;
                                                          //if i=1 then mNewQueryID:=mNewQueryID + ','+ quotedstr(copy(mBO.GetFieldValueAsString('name'),1,80))  ;
                                                          //if i=2 then
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(copy(mBO.GetFieldValueAsString('X_Name_SK'),1,80))  ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('N') ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(mBO.GetFieldValueAsString('mainunitcode')) ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr( AnsiUpperCase(mBO.GetFieldValueAsString('EAN'))) ;
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('7000000101');
                                                          //mNewQueryID:=mNewQueryID + ','+ quotedstr(mBO.GetFieldValueAsString('x_busdivision_id'));
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('SUPER00000');
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr(NxFloatToIBStr(now));
                                                          //if i=1 then mNewQueryID:=mNewQueryID + ','+ quotedstr('00000CZ000') ;
                                                          //if i=2 then
                                                          mNewQueryID:=mNewQueryID + ','+ quotedstr('00000SK000') ;
                                                         mNewQueryID:=mNewQueryID + ')"}';

                             if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQueryID);


                                 mString:=ApiCallNewValue(mBO,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID, true);

                                 if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                    //NxShowSimpleMessage('vytvořena SC ',nil);
                                    //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                             mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                    //end;
                                  end else begin
                                            //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                           // iSendmsgstav(xsite.BaseObjectSpace,
                                           //      ' API Error ' + 'Storecards + ',     // popis
                                           //       mString  + '      POST' +mtarget+'script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                           //       mToMSG ,                      // komu
                                           //       xsite.SiteContext.GetCompanyCache.GetUserID,
                                           //       copy(mString,1,3),
                                           //       mtable,
                                           //       mBO.oid,
                                           //       mBO.oid); // kdo




                                  //          mID:='';
                                            //exit;
                                  end;



                                     IF mManual then BEGIN                   // **** ruční vykopírování údajů
                            mQuery:=GetQuerySC(mBO,i);
                    end;












      mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
              for ii:=0 to mMon.count-1 do begin
                    mNewQueryID:='{"info_type": "New_value" '
                                                           +','+' "mSQL": "INSERT INTO ' + 'storeunits' + ' (id,Parent_ID,code) VALUES (' +
                                                          quotedstr(mMon.BusinessObject[ii].oid)
                                                          + ','+ quotedstr(mBO.oid)
                                                          + ','+ quotedstr(mMon.BusinessObject[ii].GetFieldValueAsString('CODE'))
                                                         + ')"}';

                                                          if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQueryID);


                                                         mString:=ApiCallNewValue(mBO,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID,true);

               end;




                             //   if mid='' then begin
                             if true then begin
                                 mr:=tstringlist.create;
                                 try
                                     mBO.ObjectSpace.SQLSelect('Select id,code from storeunits where parent_id=' + quotedstr(mBO.oid),mr);
                                     if mr.count>0 then begin
                                         for ii:=0 to mr.count-1 do begin
                                             // if index=1 then NxShowSimpleMessage(mr.Strings[ii],nil);
                                            if copy(mr.Strings[ii],12,5)<>'' then begin





                                       if true then begin
//                                       if mSU_ID<>'' then begin

                                                mNewQueryID:='{"info_type": "New_value" '
                                                           +','+' "mSQL": "INSERT INTO ' + 'storeunits' + ' (id,Parent_ID,code) VALUES (' +
                                                          quotedstr(copy(mr.Strings[ii],1,10))
                                                          + ','+ quotedstr(mBO.oid)
                                                          + ','+ quotedstr(copy(mr.Strings[ii],12,5))
                                                         + ')"}';

                                                         if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQueryID);


                                                         mString:=ApiCallNewValue(mBO,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID,true);

                                                         if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                                            //NxShowSimpleMessage('vytvořena jednotka  ',nil);
                                                            //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                     //mID:= copy(mString,15,10);
                                                                     //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                                     mr1:=tstringlist.create;
                                                                         try
                                                                             mBO.ObjectSpace.sqlselect('select id,ean from StoreEANs where parent_id=' + quotedstr(copy(mr.Strings[ii],1,10)),mr1);
                                                                                 if mr1.count>0 then begin
                                                                                               for iii:=0 to mr1.count-1 do begin
                                                                                                        for iii:=0 to mr1.count-1 do begin
                                                                                                              mNewQueryID:='{"info_type": "New_value" '
                                                                                                                         +','+' "mSQL": "INSERT INTO ' + 'StoreEANs' + ' (id,Parent_ID,EAN) VALUES (' +
                                                                                                                        quotedstr(copy(mr1.Strings[iii],1,10))
                                                                                                                        + ','+ quotedstr(copy(mr.Strings[ii],1,10))
                                                                                                                        + ','+ quotedstr(copy(mr1.Strings[iii],12,20))
                                                                                                                       + ')"}';
                                                                                                                     //  mstring:=                      inputbox('EAN','AA',mNewQueryID)    ;
                                                                                                                        if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQueryID);

                                                                                                                       mString:=APICallNewValue(mBO,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID,true);
                                                                                                                       if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                                                                                                          //NxShowSimpleMessage('vytvořen EAN  ',nil);
                                                                                                                          //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                                                                   //mID:= copy(mString,15,10);
                                                                                                                                   //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                                                                                          //end;
                                                                                                                        end else begin
                                                                                                                                  //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                                                                //  iSendmsgStav(xsite.BaseObjectSpace,
                                                                                                                                //           ' API Error ' + 'StoreEANs + ',     // popis
                                                                                                                                //            mString  + '      POST'+mtarget+'script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                                                                                                                //            mToMSG ,                      // komu
                                                                                                                                //            xsite.SiteContext.GetCompanyCache.GetUserID,copy(mString,1,3),
                                                                                                                                //              'StoreEANs',
                                                                                                                                //              mBO.oid,
                                                                                                                                //              mBO.oid); // kdo

                                                                                                                                                                                                                              //mID:='';
                                                                                                                                  //exit;
                                                                                                                        end;
                                                                                                        end;
                                                                                               end;
                                                                                 end;
                                                                         finally
                                                                             mr1.free;
                                                                         end;

                                                            //end;
                                                          end else begin
                                                                   // NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                  //  iSendmsgstav(xsite.BaseObjectSpace,
                                                                  //       ' API Error ' + 'Storecards + ',     // popis
                                                                  //        mString  + '      POST' +mtarget+'script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                                                  //        mToMSG ,                      // komu
                                                                  //        xsite.SiteContext.GetCompanyCache.GetUserID,copy(mString,1,3),
                                                                  //                                                                            'StoreEANs',
                                                                  //                                                                            mBO.oid,
                                                                  //                                                                            mBO.oid); // kdo); // kdo
                                                                    //mID:='';
                                                                    //exit;
                                                          end;



                                            end;
                                         end;
                                      end;
                                     end;

                                 finally
                                    mr.free;
                                 end;
                                end;




                                mid:= mBO.oid;

                         end;




                             // mstring:=                      inputbox('Skladové karty - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;

                                if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Put Plná aktualizace záznamu 1 doklad',mtarget + mApiTable + '/' + mid+ Chr(10) + chr(10) +mQuery);

                                //if index=1 then mstring:= inputbox('Plná aktualizace záznamu','PUT', mtarget + mApiTable + '/' + mid  + mQuery )    ;

                              mString:= APICallRest(mBO,'PUT',mtarget,mApiTable,'/' + mid ,mQuery,true);  // načtení záznamu


                              if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                //NxShowSimpleMessage('Aktualizace max skladové karty  ' + copy(mString,15,10),nil);
                                //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                         mID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                         result:=mbo.oid;
                                //end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                       { iSendmsgstav(xsite.BaseObjectSpace,' API Error ' + 'Storecards', mString  ,mToMSG , xsite.SiteContext.GetCompanyCache.GetUserID,copy(mString,1,3),
                                                                                                                                              'StoreEANs',
                                                                                                                                              mBO.oid,
                                                                                                                                             mBO.oid); // kdo);
                                  }       mID:='';
                                        //exit;
                              end;

                        //                   skladové menu
                                 mr:=tstringlist.create;
                                 try
                                     mBO.ObjectSpace.sqlselect('select a.Storecard_ID, a.StoreMenuItem_ID from StoreCardMenuItemLinks a left join StoreMenu SM on sm.id=a.StoreMenuItem_ID where a.Storecard_ID=' + QuotedStr(mBO.oid) + ' and sm.hidden=' + QuotedStr('N'),mr) ;
                                        if mr.count>0 then begin
                                                for i:=0 to mr.count-1 do begin
                                                    try
                                                                  mQuery:='{'
                                                                       +'"Storecard_ID":"'  +  copy(mr.Strings[i],1,10) +'", '
                                                                       +'"StoreMenuItem_ID":"' +  copy(mr.Strings[i],12,10) +'"'
                                                                     + '}';
                                                              //  mstring:= inputbox('Skladové menu','AA',mQuery + '     ' + copy(mr.Strings[i],1,10)  + '   ' +copy(mr.Strings[i],12,10) )    ;
                                                                  mQueryID:='{'
                                                                          + ' "class": "StoreCardMenuItemLinks",'
                                                                          +' "select": ["ID",],'
                                                                          + ' "where": " Storecard_ID = ' + QuotedStr(copy(mr.Strings[i],1,10)) + ' and StoreMenuItem_ID=' + QuotedStr(copy(mr.Strings[i],12,10))
                                                                          +' " '
                                                                          + '}';
              //                                                                                             mstring:= inputbox('Skladové menu','Dotaz na existenci ',mQueryID)    ;
                                                                      mID:='';
                                                                      mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,True);
                                                                      if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                                                        //NxShowSimpleMessage('připojení menu dohledána ' + copy(mString,15,10),nil);
                                                                        //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                 mID:= copy(mString,15,10);
                                                                                 //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                                        //end;
                                                                      end else begin
                                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                iSendmsgy(xsite.BaseObjectSpace,' API Error ' + 'StoreMenuItemLinks', mString  , mToMSG , xsite.SiteContext.GetCompanyCache.GetUserID);
                                                                                mID:='';
                                                                                //exit;
                                                                      end;

                                                                 //     NxShowSimpleMessage(mid,nil);
                                                                  if mID='' then begin
                                                                        mID:= apiCallRest(TBusRollSiteForm(xsite).CurrentObject,'Post',mtarget,'StoreCardMenuItemLinks','',mQuery,true);
                                                                      if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                                                        //NxShowSimpleMessage('založení propojení menu',nil);
                                                                        //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                 mID:= copy(mString,15,10);
                                                                                 //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                                        //end;
                                                                      end else begin
                                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                iSendmsgy(xsite.BaseObjectSpace,' API Error ' + 'StoreCardMenuItemLinks', mString  , mToMSG , xsite.SiteContext.GetCompanyCache.GetUserID);
                                                                                mID:='';
                                                                                //exit;
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
    finally
   //   mTargetList.free;
    end;
end;


procedure _AfterSave_PostHook(xsite: TRollSiteForm);
var
mid:string;
mBO_pomoc:TNxCustomBusinessObject;
mS_pomoc:string;
begin
    if true then begin
              if not nxisemptyoid(TBusRollSiteForm(xsite).CurrentObject.GetFieldValueAsString('X_parent_ID')) then begin
                  if copy(TBusRollSiteForm(xsite).CurrentObject.GetFieldValueAsString('X_parent_ID.X_synchronizace_ID'),1,3)<>'1' then begin
                       mBO_pomoc:=TBusRollSiteForm(xsite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                       try
                          // mBO_pomoc.load(TBusRollSiteForm(xsite).CurrentObject.GetFieldValueAsString('X_parent_ID'),nil);
                          // mS_pomoc:=mBO_pomoc.getFieldValueAsString('X_synchronizace_ID');
                          // mS_pomoc:=copy(ms_pomoc,1,2) + '1' + copy(ms_pomoc,4,10);
                          // mBO_pomoc.SetFieldValueAsString('X_synchronizace_ID',mS_pomoc);
                           //mBO_pomoc.Save;
                        //   mID:=GetOrCreateAPI(mBO_pomoc,xsite,0,0);
                        finally
                           mBO_pomoc.free;
                        end;
                  end;
              end;

              if not nxisemptyoid(TBusRollSiteForm(xsite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni')) then begin
                  if copy(TBusRollSiteForm(xsite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni.X_synchronizace_ID'),1,3)<>'1' then begin
                       mBO_pomoc:=TBusRollSiteForm(xsite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                       try
                          // mBO_pomoc.load(TBusRollSiteForm(xsite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni'),nil);
                          // mS_pomoc:=mBO_pomoc.getFieldValueAsString('X_synchronizace_ID');
                          // mS_pomoc:=copy(ms_pomoc,1,2) + '1' + copy(ms_pomoc,4,10);
                          // mBO_pomoc.SetFieldValueAsString('X_synchronizace_ID',mS_pomoc) ;
                          // mBO_pomoc.Save;
                       //    mID:=GetOrCreateAPI(mBO_pomoc,xsite,0,0);
                        finally
                           mBO_pomoc.free;
                        end;
                  end;

              end;
   // (xsite.SiteContext.GetCompanyCache.GetUserID='SUPER00000') then begin
      //  mID:=GetOrCreateAPI(TBusRollSiteForm(xsite).CurrentObject,xsite,0,0);
    end;
end;



 procedure Synchronizace(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  mBO:TNxCustomBusinessObject;
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
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 mMon:TNxCustomBusinessMonikerCollection;
 mError:string;
 mBO_pomoc:TNxCustomBusinessObject;
mS_pomoc:string;
begin
  mids:='';
  mError:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

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
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;
                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                                // ***** volání funkce
                                        if not nxisemptyoid(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_parent_ID')) then begin
                                                    if copy(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_parent_ID.X_synchronizace_ID'),3,1)<>'1' then begin
                                                         mBO_pomoc:=TBusRollSiteForm(msite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                                                         try
                                                             mBO_pomoc.load(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_parent_ID'),nil);
                                                             mS_pomoc:=mBO_pomoc.getFieldValueAsString('X_synchronizace_ID');
                                                             mS_pomoc:=copy(ms_pomoc,1,2) + '1' + copy(ms_pomoc,4,10);
                                                             mBO_pomoc.SetFieldValueAsString('X_synchronizace_ID',mS_pomoc) ;
                                                             mBO_pomoc.Save;
                                                             mID:=GetOrCreateAPI(mBO_pomoc,TBusRollSiteForm(msite),0,mICount);
                                                          finally
                                                             mBO_pomoc.free;
                                                          end;
                                                    end;
                                                end;

                                                if not nxisemptyoid(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni')) then begin
                                                    if copy(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni.X_synchronizace_ID'),3,1)<>'1' then begin
                                                         mBO_pomoc:=TBusRollSiteForm(msite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                                                         try
                                                             mBO_pomoc.load(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni'),nil);
                                                             mS_pomoc:=mBO_pomoc.getFieldValueAsString('X_synchronizace_ID');
                                                             mS_pomoc:=copy(ms_pomoc,1,2) + '1' + copy(ms_pomoc,4,10) ;
                                                             mBO_pomoc.SetFieldValueAsString('X_synchronizace_ID',mS_pomoc) ;
                                                             mBO_pomoc.Save;
                                                             mID:=GetOrCreateAPI(mBO_pomoc,TBusRollSiteForm(msite),0,mICount);
                                                          finally
                                                             mBO_pomoc.free;
                                                          end;
                                                    end;

                                                end;
                               if copy(TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_synchronizace_ID'),3,1)='1' then begin
                                        //NxShowSimpleMessage(inttostr(mICount),nil);
                                       mID:=GetOrCreateAPI(TBusRollSiteForm(msite).CurrentObject,TBusRollSiteForm(msite),index,mICount);

                               end;
                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;



end;

procedure _CanNew_Hook(Self: TRollSiteForm; var ACanNew: Boolean);
begin

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace SK';
  mMAction.Hint := 'Zobrazuje normy pro výrobu';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Základní s ID ');
  mMAction.Items.Add('Rozšířená ');
  mMAction.OnExecuteItem := @Synchronizace;

end;

begin
end.





