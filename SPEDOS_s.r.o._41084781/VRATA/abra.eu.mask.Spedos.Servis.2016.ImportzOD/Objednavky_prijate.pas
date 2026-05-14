uses 'abra.eu.mask.Spedos.Servis.2016.ImportzOD.lib' ,
      'abra.eu.mask.Spedos.Servis.2016.ImportzOD.fce';




      var
      mIDs_vyrobku:TStringList;


function Parsevalue(Atext:string;ASeparator: string): TStringList;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mstringlist:tstringlist;
begin
    mStr := Atext;
    mstringlist:=TStringList.create;
    try
        while (mStr<>'') and (mStr<>' ') and (mStr<>ASeparator) do begin
        //for i := 0 to sloupcu - 1 do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                mstringlist.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);

        end;

        Result:=mstringlist;
        NxShowSimpleMessage('Mstringlist -' + inttostr( mstringlist.count),nil);
        NxShowSimpleMessage('result -' + inttostr( result.count),nil);
    finally
        mstringlist.free;
    end;

end;


function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;


function Import_VYR_OD_dopl(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean;mbo_receivedorder:TNxCustomBusinessObject) : Boolean;
var
mXMLHead : TNxScriptingXMLWrapper;
mID_SP,mID:string;
mUmisteni,mSmlouva,MPlatce:string;
mUmisteniPerson,mSmlouvaPerson,MPlatcePerson:string;
mr:tstringlist;
mBO_DF,mBO1_DF,mBO_BusOrder,mBO_ROW:TNxCustomBusinessObject;
mdate:double;
mstart:string;
mresult:boolean;
mboNew_SL,mbo_ML:TNxCustomBusinessObject;
mr1,mr2,mr3:TStringList;
mprobehlo,mpokracuj:boolean;
mBusOrder_id,mDivision_ID,mBustransaction_id,mStoreCard_ID,mStore_id,mid_currency:string;
II:integer;
mRows_RO:TNxCustomBusinessMonikerCollection;
mGRows : TMultiGrid;
mid_BusOrder,mid_BusTransaction,mid_firm,mID_pozice:string;
mbo_receivedorder_source,mbo_pozice,mbo_vyrobek:TNxCustomBusinessObject;
mporadi:integer;
mzapis:boolean;
mID_Npozice:string;
mDBGrid : TMultiGrid;
mpocetzapis,mpocetzapis2:integer;
mpomoczapis:string;
mpozicePomoc:string;
mUnitprice, mtotalprice:double;
mIDs_vyrobku:tstringlist;
mi,ixx:integer;
mstr,ASeparator:string;
mpos:integer;
begin
      mporadi:=0;
   mpocetzapis:=0;
   mpocetzapis2:=0;
   mdate:=int(GetDate(mSite));

    mXMLHead := TNxScriptingXMLWrapper.Create;
     try

        mXMLHead.loadFromFile(AFileName);
            mRows_RO := mbo_receivedorder.GetCollectionMonikerForFieldCode(mbo_receivedorder.GetFieldCode('Rows'));

          mr:=tstringlist.create;
                  try
                      msite.BaseObjectSpace.SQLSelect('select max(posindex) from receivedorders2 where parent_ID=' + quotedstr(mbo_receivedorder.oid),mr);
                      if mr.count>0 then begin
                         mporadi:=strtoint(mr.Strings[0]);
                      end;
                  finally
                      mr.free;
                  end;



          for i := 0 to mXMLHead.getElementsCountInArray('Vyrobek') - 1 do begin
          mporadi:=mporadi+1;
             mID_SP:='';

             try
               if true then begin
                //if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id')<>'' then begin
                if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                                                  mID:='';
                                                  mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                                                  if mID='' then begin
                                                      mBO_BusOrder:=os.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                                      try
                                                         mBO_BusOrder.new;
                                                         mBO_BusOrder.Prefill;
                                                         mBO_BusOrder.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                                         mBO_BusOrder.SetFieldValueAsString('Name', mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].nazev_zak'));
                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment1_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_kod_cely'))));
                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment2_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_sub_kod_cely'))));
                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment3_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_sub2_kod_cely'))));
                                                         mBO_BusOrder.SetFieldValueAsString('Note','poznámka '+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_kod_cely'));
                                                         mBO_BusOrder.save;
                                                         mid_BusOrder:=mBO_BusOrder.oid;
                                                     //    NxShowSimpleMessage('Byla založena zakázka: ' +  mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),nil) ;
                                                      finally
                                                         mBO_BusOrder.free;
                                                      end;
                                                  end else begin
                                                       mid_BusOrder:=mid;

                                                  end;
                                           end;
            mDivision_ID:='';
            mr:=TStringList.create;
             try
                  os.SQLSelect('select id from Divisions where hidden=' + quotedstr('N') +
                                                     ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stredisko'))),mr);
                                          if mr.count>0 then begin
                                                     mDivision_ID:=mr.Strings[0];
                                                    // NxShowSimpleMessage('Středisko dohledáno: ' +  mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stredisko'),nil) ;
                                          end else begin
                                                mDivision_ID:=cDivision_ID

                                          end;

             finally
                mr.free;

             end;


             mStore_id:=cstore_ID;





                 mzapis:=True;
              //   mr:=TStringList.create;
              //    try
              //        os.SQLSelect('Select X_parent_ID from receivedorders2 where parent_ID=' + quotedstr(mbo_receivedorder.oid) + ' and X_parent_ID=' + quotedstr(mID_SP),mr);
              //        if (mr.count>0) and (mID_SP<>'') then mzapis:=False else mzapis:=true;
              //    finally
              //       mr.free;
              //    end;
                  if true  then begin
                     mpozicePomoc:='';

                                for ii := 0 to mXMLHead.getElementsCountInArray('Vyrobek['+inttostr(i)+'].stock.stock_item')-1 do begin

                                 mporadi:=mporadi+1;
                                 mID_pozice:='';

                              if (mpozicePomoc<>mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice')) or (mpozicePomoc='') then begin

                              // dohledani existující pozice
                                                        mzapis:=false;
                                                        mr:=TStringList.create;
                                                       mID_pozice:='';
                                                       mID_Npozice:='';
                                                       try
                                                           os.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('QGK21PXOQRT4ZEPWEBIC0KFCDO') +
                                                            ' AND substring(A.code from 1 for 10)=' +quotedstr(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10)) +
                                                            ' AND A.X_BusOrder_ID=' + quotedstr(mid_BusOrder) ,mr);
                                                          if mr.count>0 then begin
                                                             //  mID_pozice:=mr.Strings[0];
                                                               // if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('Pozice '+ copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice_temp'),1,40) + 'dohledána',nil) ;
                                                                  mzapis:=False;
                                                          end else begin
                                                               mID_Npozice:='';
                                                               mbo_pozice:=os.CreateObject('QGK21PXOQRT4ZEPWEBIC0KFCDO');
                                                                   mbo_pozice.new;
                                                                   mbo_pozice.prefill;
                                                                   mbo_pozice.SetFieldValueAsString('Code',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10));

                                                                   mbo_pozice.setfieldvalueasstring('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].polozka'),1,40));
                                                                   mbo_pozice.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                                   mbo_pozice.SetFieldValueAsDateTime('X_CorectDate',now());
                                                                   mbo_pozice.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                                   mbo_pozice.setfieldvalueasstring('X_field5',mbo_receivedorder.oid );
                                                                mbo_pozice.save;
                                                                mID_Npozice:= mbo_pozice.oid;
                                                                mpozicePomoc:= mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice');
                                                                mpokracuj:=false;
                                                                mzapis:=true;
                                                                mpocetzapis:=mpocetzapis+1;
                                                          //       if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('Pozice ' + copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice_temp'),1,40) + ' zalozena',nil) ;
                                                     mpomoczapis:= copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10);
                                                          end;
                                                       finally
                                                          mr.free;
                                                       end;

                                end;





                                if true then begin
                        // if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then begin

                               //   if not ErrtElementString(mXMLHead,('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_vyrobku')')then begin

                                  //*************
                                               if (mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_vyrobku')<>'')  then begin

                                                        // dohledani výrobku








                                                        mIDs_vyrobku:=TStringList.Create;
                                                        try
                                                             mStr := mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_vyrobku');
                                                             ASeparator:=';';


                                                              try
                                                                  while (mStr<>'') and (mStr<>' ') and (mStr<>ASeparator) do begin
                                                                  //for i := 0 to sloupcu - 1 do begin
                                                                      mPos := AnsiPos(ASeparator, mStr);
                                                                      if mPos = 0 then mPos := Length(mStr) + 1;
                                                                          mIDs_vyrobku.Add(NxLeft(mStr, mPos - 1));
                                                                          mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);

                                                                  end;

                                                                 // NxShowSimpleMessage('mIDs_vyrobku -' + inttostr( mIDs_vyrobku.count),nil);

                                                                  for ixx:=0 to mIDs_vyrobku.count-1 do begin
                                                                         mr:=TStringList.create;
                                                                               try
                                                                                   os.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('XNAVPBFTCRO4BBYJZ2FN14T51O') +
                                                                                        ' AND A.code =' +quotedstr(mIDs_vyrobku.Strings[ixx]) +
                                                                                    ,mr);
                                                                                  if mr.count>0 then begin
                                                                                       //mID_pozice:=mr.Strings[0];
                                                                                       mbo_vyrobek:=os.CreateObject('XNAVPBFTCRO4BBYJZ2FN14T51O');
                                                                                          try
                                                                                           mbo_vyrobek.load(mr.Strings[0],nil);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_OP_pozice',mID_pozice);
                                                                                           //mbo_vyrobek.SetFieldValueAsDateTime('X_Datum_vyroby$date',mdate);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_field5',mbo_receivedorder.oid );
                                                                                           mbo_vyrobek.save;
                                                                                          finally
                                                                                             mbo_vyrobek.free;
                                                                                          end;


                                                                                  end else begin
                                                                                     mbo_vyrobek:=os.CreateObject('XNAVPBFTCRO4BBYJZ2FN14T51O');
                                                                                          try
                                                                                           mbo_vyrobek.new;
                                                                                           mbo_vyrobek.prefill;
                                                                                           mbo_vyrobek.SetFieldValueAsString('Code',mIDs_vyrobku.Strings[ixx]);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_OP_pozice',mID_pozice);
                                                                                           //mbo_vyrobek.SetFieldValueAsDateTime('X_Datum_vyroby$date',0);
                                                                                           mbo_vyrobek.SetFieldValueAsDateTime('X_Vyrobeno$date',0);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_field5',mbo_receivedorder.oid );
                                                                                            mbo_vyrobek.save;
                                                                                          finally
                                                                                             mbo_vyrobek.free;
                                                                                          end;
                                                                                  end;
                                                                               finally
                                                                                  mr.free;
                                                                               end;




                                                                   end;
                                                              finally

                                                              end;









                                                        finally
                                                           mIDs_vyrobku.free;
                                                        end;

                                             end;

                           //         end else begin

                                  end;






                                               //  if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then
                                               //NxShowSimpleMessage('Přidání ' +  copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice_temp'),1,40) + ' zalozena',nil) ;
                                                      if true then begin

                                                            if mzapis then begin
                                                              //NxShowSimpleMessage('jdeme zapsat', msite);
                                                                  mpocetzapis2:=mpocetzapis2+1;

                                                                           mBO_ROW := mRows_RO.AddNewObject;
                                                                          //  NxShowSimpleMessage('Přidání '+  quotedstr(mID_Npozice) + ' - ' + quotedstr(mID_pozice),nil) ;
                                                                                                        mBO_ROW.SetFieldValueAsinteger('PosIndex',mporadi);
                                                                                                        mBO_ROW.SetFieldValueAsinteger('Rowtype',NxStrToInt(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].typ_dotazu')));
                                                                                                        if mBO_ROW.getFieldValueAsinteger('Rowtype')=3 then begin

                                                                                                                   mStoreCard_ID:='';
                                                                                                                         mr:=TStringList.create;
                                                                                                                         try
                                                                                                                              os.SQLSelect('select id from Storecards where hidden=' + quotedstr('N') +
                                                                                                                                                                 ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].kod_abra'))),mr);
                                                                                                                                                      if mr.count>0 then begin
                                                                                                                                                                 mStoreCard_ID:=mr.Strings[0];
                                                                                                                                                      end;
                                                                                                                                                      if mStoreCard_ID='' then begin
                                                                                                                                                           NxShowSimpleMessage( ' Karta : ' + Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].kod_abra')) + ' nebyla nalezena',nil) ;
                                                                                                                                                           mStoreCard_ID:=cStoreCard_ID;

                                                                                                                                                      end;
                                                                                                                         finally
                                                                                                                            mr.free;

                                                                                                                         end;
                                                                                                                      mBO_ROW.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                                                                                                         end else begin
                                                                                                              mBO_ROW.SetFieldValueAsString('Text',trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].polozka')));
                                                                                                         end ;
                                                                                                         if (mBO_ROW.GetFieldValueAsInteger('Rowtype')=3) and (not NxIsEmptyOID(mBO_ROW.getFieldValueAsString('StoreCard_ID.X_store_id'))) then begin
                                                                                                                   mBO_ROW.SetFieldValueAsString('Store_ID',mBO_ROW.getFieldValueAsString('StoreCard_ID.X_store_id'))
                                                                                                         end else begin
                                                                                                                 if (mBO_ROW.GetFieldValueAsInteger('Rowtype')=3) then mBO_ROW.SetFieldValueAsString('Store_ID',mStore_id);
                                                                                                         end;
                                                                                                        mBO_ROW.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].mnozstvi')));
                                                                                                        if mBO_ROW.getFieldValueAsFloat('Quantity')=0 then mBO_ROW.setFieldValueAsFloat('Quantity',1);


                                                              mtotalprice:= NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].cena_celkem'));



                                                              mUnitprice:=trunc(1000*(NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].cena_celkem'))/mBO_ROW.getFieldValueAsFloat('Quantity')))*0.001 ;
                                                              mBO_ROW.SetFieldValueAsFloat('UnitPrice',mUnitprice);
                                                              //mBO_ROW.SetFieldValueAsFloat('TotalPrice',mtotalprice);

                                                              //MASA 13.1.2022

                                                                                                        {if (mUnitprice*mBO_ROW.getFieldValueAsFloat('Quantity')) = mtotalprice then begin
                                                                                                            //mBO_ROW.SetFieldValueAsFloat('UnitPrice',0);

                                                                                                            mBO_ROW.SetFieldValueAsFloat('UnitPrice',mUnitprice);

                                                                                                            //zakomentováno 1.12.2021 MASA
                                                                                                        end;}


                                                                                                        mBO_ROW.SetFieldValueAsString('Division_ID',mDivision_ID);
                                                                                                        mBO_ROW.setfieldvalueasstring('BusOrder_ID',mid_BusOrder);

                                                                                                        mBO_ROW.setfieldvalueasstring('BusTransaction_ID',mid_BusTransaction);

                                                                                                        if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad')) then begin
                                                                                                                mBO_ROW.SetFieldValueAsString('BusTransaction_ID',GetBT_ID(OS,mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad'))
                                                                                                                {getIDfromfield(os,'ID','BusTransactions','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad'),'Hidden','N')}
                                                                                                                )

                                                                                                         end;

                                                                                                       try
                                                                                                        mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].sleva')));
                                                                                                       except

                                                                                                       end;



                                                                                         if (mbo_receivedorder.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587') then begin
                                                                                             mBO_ROW.SetFieldValueAsFloat('X_Vnitro_sleva',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].sleva')));

                                                                                             if not NxIsEmptyOID(mBO_ROW.getFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')) then begin

                                                                                                       mid:='';
                                                                                                       mr:=TStringList.create;
                                                                                                             try
                                                                                                                  os.SQLSelect('SELECT Y.Discount FROM FirmAssortmentDiscounts Y WHERE Y.Parent_ID='+quotedstr(mbo_receivedorder.GetFieldValueAsString('Firm_ID')) +
                                                                                                                  ' AND Y.StoreAssortmentGroup_ID = '+ quotedstr(mBO_ROW.getFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')),mr) ;
                                                                                                                                          if mr.count>0 then begin
                                                                                                                                                     mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mr.Strings[0]));


                                                                                                                                          end;


                                                                                                             finally
                                                                                                                mr.free;

                                                                                                             end;


                                                                                             end;
                                                                                           end;

                                                                                                        mBO_ROW.SetFieldValueAsString('X_Pozice_OD',mID_Npozice);
                                                                                                        mBO_ROW.SetFieldValueAsDateTime('DeliveryDate$Date',mdate);


                                                            end ;
                                                      end;


                               mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));

                            //  if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;


                             //  if Assigned(msite) then msite.Refresh;







                                if copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10)<> mpomoczapis then mzapis:=false   ;




                         end;

               end;

            end;
        finally
        end;

          end;


        mbo_receivedorder.save;;


        NxShowSimpleMessage('Importovány ' + inttostr(mpocetzapis) + ' pozice, ' + inttostr(mpocetzapis2) + ' řádků' ,msite) ;



          result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
          if result then begin
              DeleteFile(AFileName);
     //         if rucne and result and chyba then begin
                     //NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
     //         end;
          end;


     finally
      mXMLHead.Free;
     end;
    Result := True;
end;




function GetDate(xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum dodání';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Zadej datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;


function Import_VYR_OD_OBDV(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean) : Boolean;
var
mXMLHead:TNxScriptingXMLWrapper;
mID_SP,mID:string;
mUmisteni,mSmlouva,MPlatce:string;
mUmisteniPerson,mSmlouvaPerson,MPlatcePerson:string;
mr:tstringlist;
mBO_DF,mBO1_DF,mBO_BusOrder,mBO_ROW:TNxCustomBusinessObject;
mdate:double;
mstart:string;
mresult:boolean;
mboNew_SL,mbo_ML:TNxCustomBusinessObject;
mr1,mr2,mr3:TStringList;
mprobehlo,mpokracuj:boolean;
mBusOrder_id,mDivision_ID,mBustransaction_id,mStoreCard_ID,mStore_id,mid_currency:string;
II:integer;
mRows_RO:TNxCustomBusinessMonikerCollection;
mGRows : TMultiGrid;
mid_BusOrder,mID_bankccount,mid_BusTransaction,mid_firm:string;
mbo_receivedorder_source:TNxCustomBusinessObject;
mporadi:integer;
mzapis:boolean;
mbo_receivedorder,mbo_pozice,mbo_vyrobek:TNxCustomBusinessObject;
mID_pozice:string;
mBresult:boolean;
mi,ixx:integer;
mtotalprice, munitprice:Double;
mstr,ASeparator, mTempSign:string;
mpos:integer;

mFirmBO:TNxCustomBusinessObject;

begin
      mporadi:=0;


     mdate:=int(GetDate(mSite));

    mBresult:=true;
    mXMLHead := TNxScriptingXMLWrapper.Create;
    mXMLHead.free;
    mXMLHead := TNxScriptingXMLWrapper.Create;
     try

        mXMLHead.loadFromFile(AFileName);


     i:=0;
               if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                      mID:='';
                      mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                      if mID<>'' then begin
                          NxShowSimpleMessage('Zakázka již existuje',nil);
                           if mBresult then
                                 if NxGetActualUserID(msite.BaseObjectSpace)<>'SUPER00000' then begin
                                    exit;
                                 end else begin
                                    mBresult:=true;
                                 end ;
                      end;

                end;

              if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].b_ucet')) then begin
                      mID_bankccount:='';
                      mID_bankccount:=getIDfromfield(os,'ID','BankAccounts','BankAccount',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].b_ucet'),'Hidden','N');


                end;

   if mBresult then begin

        mid_firm:='';
             mr:=TStringList.create;
             try
                  os.SQLSelect('select id from Firms where hidden=' + quotedstr('N') +
                                                     ' and OrgIdentNumber='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Smlouva.firma.ico'))),mr);
                                          if mr.count>0 then begin
                                                     mid_firm:=mr.Strings[0];
                                          end;

             finally
                mr.free;

             end;





mbo_receivedorder:=os.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
try
                  mbo_receivedorder.new;
                  mbo_receivedorder.Prefill;
                  mbo_receivedorder.SetFieldValueAsString('Docqueue_ID',cDocqueue_ID);
                  mbo_receivedorder.SetFieldValueAsString('Firm_id', mid_firm);
                   {Try
                      mFirmBO:=os.CreateObject(Class_Firm);
                      mFirmBO.Load(mid_firm,nil);
                      mFirmBO.SetFieldValueAsString('X_Segment1_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].segment_kod_cely'))));
                      mFirmBO.SetFieldValueAsString('X_Segment2_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].segment_sub_kod_cely'))));
                      mFirmBO.SetFieldValueAsString('X_Segment3_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].segment_sub2_kod_cely'))));
                      mfirmbo.save;
                      mFirmBO.free;
                   except
                   end; }
                  mbo_receivedorder.SetFieldValueAsBoolean('IsRowDiscount', True);


                 mbo_receivedorder.SetFieldValueAsString('BankAccount_ID', mID_bankccount);
                 mbo_receivedorder.SetFieldValueAsString('ConstSymbol_ID', '0000308000');
                 mbo_receivedorder.SetFieldValueAsString('TransportationType_ID','6000000101');
                 mbo_receivedorder.SetFieldValueAsString('PaymentType_ID', '4100000101');

              if (mbo_receivedorder.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587') then mbo_receivedorder.setFieldValueAsInteger('DealerDiscountKind',0);

              if Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].Smlouva.firma.ico'))='31708587' then begin
                           mbo_receivedorder.SetFieldValueAsInteger('Tradetype',2);
                           mbo_receivedorder.SetFieldValueAsstring('Description','SK');
                           mbo_receivedorder.SetFieldValueAsstring('Currency_ID','0000EUR000');

                           mbo_receivedorder.SetFieldValueAsstring('Country_ID','00000SK000');
                           mbo_receivedorder.SetFieldValueAsstring('IntrastatDeliveryTerm_ID','3001000000'); ;
                           mbo_receivedorder.SetFieldValueAsstring('IntrastatTransactionType_ID','1001000000');
                           mbo_receivedorder.SetFieldValueAsstring('IntrastatTransportationType_ID','2000000000');
                           mbo_receivedorder.SetFieldValueAsstring('BankAccount_ID','4100000101');
                           mbo_receivedorder.SetFieldValueAsstring('TransportationType_ID','6000000101');
                           mbo_receivedorder.SetFieldValueAsstring('PaymentType_ID','4100000101');
                           mbo_receivedorder.SetFieldValueAsstring('ConstSymbol_ID','0000110000');

              end else begin
                    mid_currency:='';
                           mr:=TStringList.create;
                           try
                                os.SQLSelect('select id from Currencies where hidden=' + quotedstr('N') +
                                                                   ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].mena'))),mr);
                                                        if mr.count>0 then begin
                                                                   mid_currency:=mr.Strings[0];

                                                        end;
                                                        if mid_currency='' then mid_currency:='0000CZK000';

                           finally
                              mr.free;

                           end;
                                       mbo_receivedorder.SetFieldValueAsString('Currency_ID', mid_currency);

              end;






            mRows_RO := mbo_receivedorder.GetCollectionMonikerForFieldCode(mbo_receivedorder.GetFieldCode('Rows'));



          for i := 0 to mXMLHead.getElementsCountInArray('Vyrobek') - 1 do begin


               //  if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('I :'+ IntToStr(i),nil) ;


             mporadi:=mporadi + 1;
             mID_SP:='';

               if true then begin





                //if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id')<>'' then begin
                if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                                                  mID:='';
                                                  mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                                                  if mID='' then begin
                                                     // mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','A');
                                                          //   if mID='' then begin


                                                                      mBO_BusOrder:=os.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                                                      try
                                                                         mBO_BusOrder.new;
                                                                         mBO_BusOrder.Prefill;
                                                                         mBO_BusOrder.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                                                         mBO_BusOrder.SetFieldValueAsString('Name', mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].nazev_zak'));
                                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment1_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_kod_cely'))));
                                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment2_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_sub_kod_cely'))));
                                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment3_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_sub2_kod_cely'))));
                                                                         mBO_BusOrder.SetFieldValueAsString('Note','poznámka '+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_kod_cely'));
                                                                         mTempSign:= AnsiLeftStr(AnsiRightStr(mBO_BusOrder.GetFieldValueAsString('Code'),5),1);
                                                                         if (mTempSign='D') and ((AnsiRightStr(mbo_receivedorder.GetFieldValueAsString('Firm_ID.VatIdentNumber'),2)='CZ')) then mbo_receivedorder.SetFieldValueAsBoolean('IsReverseChargeDeclared',True);
                                                                         mBO_BusOrder.save;
                                                                         mid_BusOrder:=mBO_BusOrder.oid;
                                                                      finally
                                                                         mBO_BusOrder.free;
                                                                      end;
                                                             // end else begin
                                                                 // mi:=msite.BaseObjectSpace.SQLExecute('update BusOrders set hidden=''N'' where id=' + QuotedStr(mID));
                                                                //  mid_BusOrder:=mid;
                                                             // end;
                                                  end else begin
                                                       mid_BusOrder:=mid;

                                                  end;

                                           end;



            mDivision_ID:='';
            mr:=TStringList.create;
             try
                  os.SQLSelect('select id from Divisions where hidden=' + quotedstr('N') +
                                                     ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stredisko'))),mr);
                                          if mr.count>0 then begin
                                                     mDivision_ID:=mr.Strings[0];
                                          end else begin
                                                mDivision_ID:=cDivision_ID

                                          end;

             finally
                mr.free;

             end;


             mStore_id:=mStore_id;




                 mzapis:=True;
                 mr:=TStringList.create;
                  try
                      os.SQLSelect('Select X_parent_ID from receivedorders2 where parent_ID=' + quotedstr(mbo_receivedorder.oid) + ' and X_parent_ID=' + quotedstr(mID_SP),mr);
                      if mr.count>0 then mzapis:=False;
                  finally
                     mr.free;
                  end;
                  if mzapis then

                  for ii := 0 to mXMLHead.getElementsCountInArray('Vyrobek['+inttostr(i)+'].stock.stock_item')-1 do begin

                 // if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('II :'+ IntToStr(ii),nil) ;
                  mporadi:=mporadi + 1;
                  mID_pozice:='';
                // dohledani existující pozice
                                          mr:=TStringList.create;
                                         try
                                             os.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('QGK21PXOQRT4ZEPWEBIC0KFCDO') +
                                              ' AND substring(A.code from 1 for 10)=' +quotedstr(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10)) +
                                              ' AND A.X_BusOrder_ID=' + quotedstr(mid_BusOrder) ,mr);
                                            if mr.count>0 then begin
                                                 mID_pozice:=mr.Strings[0];
                                            end else begin
                                               mbo_pozice:=os.CreateObject('QGK21PXOQRT4ZEPWEBIC0KFCDO');
                                                      mbo_pozice.new;
                                                     mbo_pozice.prefill;


                                                     mbo_pozice.SetFieldValueAsString('Code',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10));

                                                     mbo_pozice.setfieldvalueasstring('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].polozka'),1,40));
                                                     mbo_pozice.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                      mbo_pozice.SetFieldValueAsDateTime('X_CorectDate',now());
                                                      mbo_pozice.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                      mbo_pozice.setfieldvalueasstring('X_field5',mbo_receivedorder.oid );

                                              mbo_pozice.save;
                                              mID_pozice:= mbo_pozice.oid;
                                            end;
                                         finally
                                            mr.free;
                                         end;
                        if true then begin
                        // if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then begin

                               //   if not ErrtElementString(mXMLHead,('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_vyrobku')')then begin

                                  //*************
                                               if (mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_vyrobku')<>'')  then begin

                                                        // dohledani výrobku








                                                        mIDs_vyrobku:=TStringList.Create;
                                                        try
                                                             mStr := mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_vyrobku');
                                                             ASeparator:=';';


                                                              try
                                                                  while (mStr<>'') and (mStr<>' ') and (mStr<>ASeparator) do begin
                                                                  //for i := 0 to sloupcu - 1 do begin
                                                                      mPos := AnsiPos(ASeparator, mStr);
                                                                      if mPos = 0 then mPos := Length(mStr) + 1;
                                                                          mIDs_vyrobku.Add(NxLeft(mStr, mPos - 1));
                                                                          mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);

                                                                  end;

                                                                 // NxShowSimpleMessage('mIDs_vyrobku -' + inttostr( mIDs_vyrobku.count),nil);

                                                                  for ixx:=0 to mIDs_vyrobku.count-1 do begin
                                                                         mr:=TStringList.create;
                                                                               try
                                                                                   os.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('XNAVPBFTCRO4BBYJZ2FN14T51O') +


                                                                                    ' AND A.code =' +quotedstr(mIDs_vyrobku.Strings[ixx]) ,mr);

                                                                                  if mr.count>0 then begin

                                                                                       mbo_vyrobek:=os.CreateObject('XNAVPBFTCRO4BBYJZ2FN14T51O');
                                                                                          try
                                                                                           mbo_vyrobek.load(mr.Strings[0],nil);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_OP_pozice',mID_pozice);
                                                                                          // mbo_vyrobek.SetFieldValueAsDateTime('X_Datum_vyroby$date',mdate);
                                                                                          mbo_vyrobek.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                                                          mbo_vyrobek.setfieldvalueasstring('X_field5',mbo_receivedorder.oid );
                                                                                           mbo_vyrobek.save;
                                                                                          finally
                                                                                             mbo_vyrobek.free;
                                                                                          end;
                                                                                  end else begin
                                                                                     mbo_vyrobek:=os.CreateObject('XNAVPBFTCRO4BBYJZ2FN14T51O');
                                                                                          try
                                                                                           mbo_vyrobek.new;
                                                                                           mbo_vyrobek.prefill;
                                                                                           mbo_vyrobek.SetFieldValueAsString('Code',mIDs_vyrobku.Strings[ixx]);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                                                           mbo_vyrobek.setfieldvalueasstring('X_OP_pozice',mID_pozice);
                                                                                          // mbo_vyrobek.SetFieldValueAsDateTime('X_Datum_vyroby$date',mdate);
                                                                                            mbo_vyrobek.SetFieldValueAsDateTime('X_Vyrobeno$date',0);
                                                                                            mbo_vyrobek.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                                                            mbo_vyrobek.setfieldvalueasstring('X_field5',mbo_receivedorder.oid );
                                                                                            mbo_vyrobek.save;
                                                                                          finally
                                                                                             mbo_vyrobek.free;
                                                                                          end;
                                                                                  end;
                                                                               finally
                                                                                  mr.free;
                                                                               end;




                                                                   end;
                                                              finally

                                                              end;









                                                        finally
                                                           mIDs_vyrobku.free;
                                                        end;

                                             end;

                           //         end else begin

                            //        end;


                        end;   /// jen supervisor


                               mBO_ROW := mRows_RO.AddNewObject;
                                                            mBO_ROW.SetFieldValueAsinteger('PosIndex',mporadi);
                                                            mBO_ROW.SetFieldValueAsinteger('Rowtype',NxStrToInt(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].typ_dotazu')));
                                                            if mBO_ROW.getFieldValueAsinteger('Rowtype')=3 then begin

                                                                       mStoreCard_ID:='';
                                                                             mr:=TStringList.create;
                                                                             try
                                                                                  os.SQLSelect('select id from Storecards where hidden=' + quotedstr('N') +
                                                                                                                     ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].kod_abra'))),mr);
                                                                                                          if mr.count>0 then begin
                                                                                                                     mStoreCard_ID:=mr.Strings[0];
                                                                                                          end;
                                                                                                          if mStoreCard_ID='' then begin
                                                                                                               if NxGetActualUserID(msite.BaseObjectSpace)<>'SUPER00000' then NxShowSimpleMessage( ' Karta : ' + Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].kod_abra')) + ' nebyla nalezena',nil) ;
                                                                                                               mStoreCard_ID:=cStoreCard_ID;

                                                                                                          end;
                                                                             finally
                                                                                mr.free;

                                                                             end;
                                                                          mBO_ROW.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                                                             end else begin
                                                                  mBO_ROW.SetFieldValueAsString('Text',trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].polozka')));
                                                             end ;
                                                             if (mBO_ROW.GetFieldValueAsInteger('Rowtype')=3) and (not NxIsEmptyOID(mBO_ROW.getFieldValueAsString('StoreCard_ID.X_store_id'))) then begin
                                                                       mBO_ROW.SetFieldValueAsString('Store_ID',mBO_ROW.getFieldValueAsString('StoreCard_ID.X_store_id'))
                                                             end else begin
                                                                     mBO_ROW.SetFieldValueAsString('Store_ID',cStore_id);
                                                             end;
                                                            mBO_ROW.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].mnozstvi')));
                                                            if mBO_ROW.getFieldValueAsFloat('Quantity')=0 then mBO_ROW.setFieldValueAsFloat('Quantity',1);
                                                               mtotalprice:= NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].cena_celkem'));



                                                              mUnitprice:=trunc(1000*(NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].cena_celkem'))/mBO_ROW.getFieldValueAsFloat('Quantity')
                                                              ))*0.001 ;
                                                              mBO_ROW.SetFieldValueAsFloat('UnitPrice',munitprice);
                                                              //mBO_ROW.SetFieldValueAsFloat('TotalPrice',mtotalprice);
                                                                                                        {
                                                                                                        if (mUnitprice*mBO_ROW.getFieldValueAsFloat('Quantity')) = mtotalprice then begin
                                                                                                            //mBO_ROW.SetFieldValueAsFloat('UnitPrice',0);

                                                                                                            mBO_ROW.SetFieldValueAsFloat('UnitPrice',mUnitprice);

                                                                                                          //zakomentováno 2.12.2021 MASA
                                                                                                        end;}

                                                            mBO_ROW.SetFieldValueAsString('Division_ID',mDivision_ID);
                                                            mBO_ROW.setfieldvalueasstring('BusOrder_ID',mid_BusOrder);

                                                            mBO_ROW.setfieldvalueasstring('BusTransaction_ID',mid_BusTransaction);
                                                            mBO_ROW.setfieldvalueasstring('X_Pozice_OD',mID_pozice);

                                                            if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad')) then begin
                                                                    mBO_ROW.SetFieldValueAsString('BusTransaction_ID',GetBT_ID(OS,mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad'))
                                                                    {getIDfromfield(os,'ID','BusTransactions','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad'),'Hidden','N')}
                                                                    )

                                                             end;
                                                           mBO_ROW.SetFieldValueAsDateTime('DeliveryDate$Date',mdate);
                                                           try
                                                            mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].sleva')));
                                                           except

                                                           end;
                                                            if mbo_receivedorder.GetFieldValueAsBoolean('IsReverseChargeDeclared') then begin
                                                               mBO_ROW.SetFieldValueAsInteger('VATMode',1);
                                                               mbo_row.SetFieldValueAsString('DRCArticle_ID','1100000000');
                                                            end;


                                                                                          if (mbo_receivedorder.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587') then begin
                                                                                             mBO_ROW.SetFieldValueAsFloat('X_Vnitro_sleva',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].sleva')));

                                                                                             if not NxIsEmptyOID(mBO_ROW.getFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')) then begin

                                                                                                       mid:='';
                                                                                                       mr:=TStringList.create;
                                                                                                             try
                                                                                                                  os.SQLSelect('SELECT Y.Discount FROM FirmAssortmentDiscounts Y WHERE Y.Parent_ID='+quotedstr(mbo_receivedorder.GetFieldValueAsString('Firm_ID')) +
                                                                                                                  ' AND Y.StoreAssortmentGroup_ID = '+ quotedstr(mBO_ROW.getFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')),mr) ;
                                                                                                                                          if mr.count>0 then begin
                                                                                                                                                     mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mr.Strings[0]));


                                                                                                                                          end;


                                                                                                             finally
                                                                                                                mr.free;

                                                                                                             end;


                                                                                             end;
                                                                                           end;

                                                                                          mBO_ROW.SetFieldValueAsDateTime('DeliveryDate$Date',mdate);




                  end ;
            end;

    end;


    finally
      TDynSiteForm.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', msite.SiteContext, mbo_receivedorder);
          result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
          if result then begin
              DeleteFile(AFileName);
          end;
      //mBO_ROW.free;
      mbo_receivedorder.free;
  end ;
   end;




     finally
      mXMLHead.Free;

     end;
    Result := True;

    TDynSiteForm(msite).Refresh;
end;




function Import_VYR_OD(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean) : Boolean;
var
mXMLHead : TNxScriptingXMLWrapper;
mID_SP,mID:string;
mUmisteni,mSmlouva,MPlatce:string;
mUmisteniPerson,mSmlouvaPerson,MPlatcePerson:string;
mr:tstringlist;
mBO_DF,mBO1_DF,mBO_BusOrder,mBO_ROW:TNxCustomBusinessObject;
mdate:double;
mstart:string;
mresult:boolean;
mboNew_SL,mbo_ML:TNxCustomBusinessObject;
mr1,mr2,mr3:TStringList;
mprobehlo,mpokracuj:boolean;
mBusOrder_id,mDivision_ID,mBustransaction_id,mStoreCard_ID,mStore_id,mid_currency:string;
II:integer;
mRows_RO:TNxCustomBusinessMonikerCollection;
mGRows : TMultiGrid;
mid_BusOrder,mid_BusTransaction,mid_firm:string;
mbo_receivedorder,mbo_receivedorder_source:TNxCustomBusinessObject;
mporadi:integer;
mID_pozice:string;
mbo_pozice,mbo_sp, mFirmBO:TNxCustomBusinessObject;
begin
      mporadi:=0;




     try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);

       mporadi:=0;

        mid_firm:='';
             mr:=TStringList.create;
             try
                  os.SQLSelect('select id from Firms where hidden=' + quotedstr('N') +
                                                     ' and OrgIdentNumber='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].Smlouva.firma.ico'))),mr);
                                          if mr.count>0 then begin
                                                     mid_firm:=mr.Strings[0];
                                          end;

             finally
                mr.free;

             end;





                  mbo_receivedorder:=os.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                  mbo_receivedorder.new;
                  mbo_receivedorder.Prefill;
                  mbo_receivedorder.SetFieldValueAsString('Docqueue_ID',cDocqueue_ID);
                  mbo_receivedorder.SetFieldValueAsString('Firm_id', mid_firm);
                  {Try
                      mFirmBO:=os.CreateObject(Class_Firm);
                      mFirmBO.Load(mid_firm,nil);
                      mFirmBO.SetFieldValueAsString('X_Segment1_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].segment_kod_cely'))));
                      mFirmBO.SetFieldValueAsString('X_Segment2_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].segment_sub_kod_cely'))));
                      mFirmBO.SetFieldValueAsString('X_Segment3_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].segment_sub2_kod_cely'))));
                      mfirmbo.save;
                      mFirmBO.free;
                   except
                   end; }
                  mbo_receivedorder.SetFieldValueAsBoolean('IsRowDiscount', True);

           //  NxShowSimpleMessage('Hlavicka',nil);  //***********
              if Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].Smlouva.firma.ico'))='31708587' then begin
                           mbo_receivedorder.SetFieldValueAsInteger('Tradetype',2);
                           mbo_receivedorder.SetFieldValueAsstring('Description','SK');
                           mbo_receivedorder.SetFieldValueAsstring('Currency_ID','0000EUR000');

                           mbo_receivedorder.SetFieldValueAsstring('Country_ID','00000SK000');
                           mbo_receivedorder.SetFieldValueAsstring('IntrastatDeliveryTerm_ID','3001000000'); ;
                           mbo_receivedorder.SetFieldValueAsstring('IntrastatTransactionType_ID','1001000000');
                           mbo_receivedorder.SetFieldValueAsstring('IntrastatTransportationType_ID','2000000000');
                           mbo_receivedorder.SetFieldValueAsstring('BankAccount_ID','4100000101');
                           mbo_receivedorder.SetFieldValueAsstring('TransportationType_ID','6000000101');
                           mbo_receivedorder.SetFieldValueAsstring('PaymentType_ID','4100000101');
                           mbo_receivedorder.SetFieldValueAsstring('ConstSymbol_ID','0000110000');

              end else begin
               {     mid_currency:='';
                           mr:=TStringList.create;
                           try
                                os.SQLSelect('select id from Currencies where hidden=' + quotedstr('N') +
                                                                   ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(0)+'].mena'))),mr);
                                                        if mr.count>0 then begin
                                                                   mid_currency:=mr.Strings[0];

                                                        end;
                                                        if mid_currency='' then mid_currency:='0000CZK000';

                           finally
                              mr.free;

                           end;
                                       mbo_receivedorder.SetFieldValueAsString('Currency_ID', mid_currency);
                   }
              end;







            mRows_RO := mbo_receivedorder.GetCollectionMonikerForFieldCode(mbo_receivedorder.GetFieldCode('Rows'));


           // NxShowSimpleMessage('radky',nil);  //***********

          for i := 0 to mXMLHead.getElementsCountInArray('Vyrobek') - 1 do begin
               mporadi:=mporadi+1;
             mID_SP:='';

             try
               if true then begin
                //NxShowSimpleMessage(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.ico')),nil);

              mid_firm:='';
             mr:=TStringList.create;
                       try
                            os.SQLSelect('select id from Firms where hidden=' + quotedstr('N') +
                                                               ' and OrgIdentNumber='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].Smlouva.firma.ico'))),mr);
                                                    if mr.count>0 then begin
                                                               mid_firm:=mr.Strings[0];
                                                               //NxShowSimpleMessage(mid_firm,nil);
                                                    end;

                       finally
                          mr.free;

                       end;







                //if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id')<>'' then begin
                if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                //NxShowSimpleMessage('Zakazka',nil);  //***********
                                                  mID:='';
                                                  mID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                                                  if mID='' then begin
                                                      mBO_BusOrder:=os.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                                      try
                                                         mBO_BusOrder.new;
                                                         mBO_BusOrder.Prefill;
                                                         mBO_BusOrder.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                                         mBO_BusOrder.SetFieldValueAsString('Name', mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].nazev_zak'));
                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment1_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_kod_cely'))));
                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment2_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_sub_kod_cely'))));
                                                         mBO_BusOrder.SetFieldValueAsString('X_Segment3_id',GetSegment_ID(OS,Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_sub2_kod_cely'))));
                                                         mBO_BusOrder.SetFieldValueAsString('Note','poznámka '+mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].segment_kod_cely'));
                                                         mBO_BusOrder.save;
                                                         mid_BusOrder:=mBO_BusOrder.oid;
                                                      finally
                                                         mBO_BusOrder.free;
                                                      end;
                                                  end else begin
                                                       mid_BusOrder:=mid;

                                                  end;

                                           end;

                                      // NxShowSimpleMessage('OP',nil);  //***********
                                           if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].obchodni_pripad')) then begin
                                                  mID:='';
                                                  //mID:=getIDfromfield(os,'ID','BusTransactions','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].obchodni_pripad'),'Hidden','N');
                                                  mID:=GetBT_ID(OS,mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].obchodni_pripad'));
                                                  mid_BusTransaction:= mID;

                                           end;


                          //      NxShowSimpleMessage('Vyrobek',nil);  //***********
                       // dohledani existujícího výrobku
                                          mr:=TStringList.create;
                                         try
                                             os.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('VH0WSOTRTVTO3CWRT4QEX21Y30') +
                                              ' AND A.Code=' +quotedstr(Trim(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].id'),1,8))) ,mr);
                                            if mr.count>0 then begin
                                                 mID_SP:=mr.Strings[0];
                                            end else begin
                                               mbo_sp:=os.CreateObject('VH0WSOTRTVTO3CWRT4QEX21Y30');
                                                      try
                                                                mbo_SP.new;
                                                               mbo_sp.prefill;

                                                                if Length(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID'))=8 then begin
                                                                    mbo_sp.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID')) ;
                                                                end else begin
                                                                  mbo_sp.SetFieldValueAsString('Code',
                                                                  'S' + nxpadl(Trim(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].ID'),1,7)),7,'0'));
                                                                end;
                                                                mbo_sp.setfieldvalueasstring('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].vyrobni_cislo'),1,20));

                                                                  mbo_sp.save;
                                                                  mID_SP:=mbo_sp.oid;
                                                     finally
                                                         mbo_sp.free;
                                                     end;
                                            end;
                                         finally
                                            mr.free;
                                         end;







                         // NxShowSimpleMessage('Stredisko',nil);  //***********


            mDivision_ID:='';
            mr:=TStringList.create;
             try
                  os.SQLSelect('select id from Divisions where hidden=' + quotedstr('N') +
                                                     ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stredisko'))),mr);
                                          if mr.count>0 then begin
                                                     mDivision_ID:=mr.Strings[0];
                                          end else begin
                                                mDivision_ID:=cDivision_ID

                                          end;

             finally
                mr.free;

             end;

                        //  NxShowSimpleMessage('Sklad',nil);  //***********
             mStore_id:='';
             mr:=TStringList.create;
             try
                  os.SQLSelect('select id from Stores where hidden=' + quotedstr('N') +
                                                     ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].sklad'))),mr);
                                          if mr.count>0 then begin
                                                     mStore_id:=mr.Strings[0];

                                          end;
                                          if mStore_id='' then mStore_ID:=cStore_id;

             finally
                mr.free;

             end;









                  for ii := 0 to mXMLHead.getElementsCountInArray('Vyrobek['+inttostr(i)+'].stock.stock_item')-1 do begin
                              mporadi:=mporadi+1;


                 //  NxShowSimpleMessage('Pozice',nil);  //***********
                    mID_pozice:='';
                // dohledani existující pozice
                                          mr:=TStringList.create;
                                         try
                                             os.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('QGK21PXOQRT4ZEPWEBIC0KFCDO') +
                                              ' AND A.code=' +quotedstr(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice')) +
                                              ' AND A.X_BusOrder_ID=' + quotedstr(mid_BusOrder) ,mr);
                                            if mr.count>0 then begin
                                                 mID_pozice:=mr.Strings[0];
                                            end else begin
                                                 mbo_pozice:=os.CreateObject('QGK21PXOQRT4ZEPWEBIC0KFCDO');
                                                     mbo_pozice.new;
                                                     mbo_pozice.prefill;
                                                     mbo_pozice.SetFieldValueAsString('Code',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'),1,10));
                                                     mbo_pozice.setfieldvalueasstring('Name',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].id_pozice'));
                                                     mbo_pozice.setfieldvalueasstring('X_busOrder_ID',mid_BusOrder);
                                                     if mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice')<>'' then begin
                                                                        mdate:=0;
                                                                       if IsValidDate(strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),1,4)),
                                                                                      strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),6,2)),
                                                                                      strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),9,2))) then begin
                                                                                mdate:= EncodeDate(strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),1,4)),strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),6,2)),strtoint(copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].termin_pozice'),9,2)));
                                                                                //mbo_pozice.setfieldvalueasdatetime('X_Datum_vyroby$date',mdate);
                                                                       end;





                                             end;
                                              mbo_pozice.save;
                                              mID_pozice:= mbo_pozice.oid;
                                            end;
                                         finally
                                            mr.free;
                                         end;





                               mBO_ROW := mRows_RO.AddNewObject;
                                                            mporadi:=mporadi+1;
                                                            mBO_ROW.SetFieldValueAsinteger('PosIndex',mporadi);
                                                            mBO_ROW.SetFieldValueAsString('X_parent_id',mID_SP);
                                                            mBO_ROW.SetFieldValueAsinteger('Rowtype',NxStrToInt(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].typ_dotazu')));
                                                            if mBO_ROW.getFieldValueAsinteger('Rowtype')=3 then begin

                                                                       mStoreCard_ID:='';
                                                                             mr:=TStringList.create;
                                                                             try
                                                                                  os.SQLSelect('select id from Storecards where hidden=' + quotedstr('N') +
                                                                                                                     ' and code='+quotedstr(Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].kod_abra'))),mr);
                                                                                                          if mr.count>0 then begin
                                                                                                                     mStoreCard_ID:=mr.Strings[0];
                                                                                                          end;
                                                                                                          if mStoreCard_ID='' then begin
                                                                                                               NxShowSimpleMessage( ' Karta : ' + Trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].kod_abra')) + ' nebyla nalezena',nil) ;
                                                                                                               mStoreCard_ID:=cStoreCard_ID;

                                                                                                          end;
                                                                             finally
                                                                                mr.free;

                                                                             end;
                                                                          mBO_ROW.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                                                             end else begin
                                                                  mBO_ROW.SetFieldValueAsString('Text',trim(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].polozka')));
                                                             end ;
                                                             if (mBO_ROW.GetFieldValueAsInteger('Rowtype')=3) and (not NxIsEmptyOID(mBO_ROW.getFieldValueAsString('StoreCard_ID.X_store_id'))) then begin
                                                                       mBO_ROW.SetFieldValueAsString('Store_ID',mBO_ROW.getFieldValueAsString('StoreCard_ID.X_store_id'))
                                                             end else begin
                                                                     mBO_ROW.SetFieldValueAsString('Store_ID',mStore_id);
                                                             end;
                                                            mBO_ROW.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].mnozstvi')));
                                                            if mBO_ROW.getFieldValueAsFloat('Quantity')=0 then mBO_ROW.setFieldValueAsFloat('Quantity',1);

                                                            mBO_ROW.SetFieldValueAsString('Division_ID',mDivision_ID);
                                                            mBO_ROW.setfieldvalueasstring('BusOrder_ID',mid_BusOrder);

                                                            mBO_ROW.setfieldvalueasstring('BusTransaction_ID',mid_BusTransaction);

                                                            if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad')) then begin
                                                                    mBO_ROW.SetFieldValueAsString('BusTransaction_ID', GetBT_ID(OS,mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad'))
                                                                    {getIDfromfield(os,'ID','BusTransactions','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].obchodni_pripad'),'Hidden','N')}
                                                                    )

                                                             end;


                                                           mBO_ROW.setfieldvalueasstring('X_Pozice_OD',mID_pozice);


                                                            mBO_ROW.SetFieldValueAsDateTime('DeliveryDate$Date',mdate);

                                                            if (mbo_receivedorder.GetFieldValueAsString('Firm_ID.name')='SPEDOS Slovensko spol. s r.o.') then begin


                                                               if not NxIsEmptyOID(mBO_ROW.getFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')) then begin

                                                                         mid:='';
                                                                         mr:=TStringList.create;
                                                                               try
                                                                                    os.SQLSelect('SELECT Y.Discount FROM FirmAssortmentDiscounts Y WHERE Y.Parent_ID='+quotedstr(mbo_receivedorder.GetFieldValueAsString('Firm_ID')) +
                                                                                    ' AND Y.StoreAssortmentGroup_ID = '+ quotedstr(mBO_ROW.getFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID')),mr) ;
                                                                                                            if mr.count>0 then begin
                                                                                                                       mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mr.Strings[0]));

                                                                                                            end;


                                                                               finally
                                                                                  mr.free;

                                                                               end;
                                                               end else begin
                                                                       mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].sleva')));
                                                               end;
                                                            end else begin
                                                                 mBO_ROW.SetFieldValueAsFloat('RowDiscount',NxIBStrToFloat(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].stock.stock_item['+inttostr(ii)+'].sleva')));

                                                            end;









                  end ;
                 mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));

              //  if Assigned(mGRows) then mGRows.DataSource.DataSet.Refresh;


               //  if Assigned(msite) then msite.Refresh;
















            end;
        finally
              mbo_SP.free;
        end;

          end;


        TDynSiteForm.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', msite.SiteContext, mbo_receivedorder);

          result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
          if result then begin
              DeleteFile(AFileName);
     //         if rucne and result and chyba then begin
                     //NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
     //         end;
          end;


     finally
      mXMLHead.Free;
     end;
    Result := True;


end;



begin
end.