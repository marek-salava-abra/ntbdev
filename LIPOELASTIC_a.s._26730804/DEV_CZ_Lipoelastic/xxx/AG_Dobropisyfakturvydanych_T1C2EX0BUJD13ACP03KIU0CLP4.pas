uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
var
     mBookmark : TBookmarkList;

procedure inovortho(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,j:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mMon:TNxCustomBusinessMonikerCollection;
begin
 // mtext:='Description=' + quotedstr('');
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
   // mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    if mBookmark.count=0 then begin
               if false then begin
                             // if TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.Name')='INOVORTHO' then begin

                                 {
                                  if not NxIsEmptyOID(tDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_BankAcount')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('BankAccount_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_BankAcount'))
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('BankAccount_ID','3000000101')  ;
                                  end;
                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_TransportationType_ID')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('TransportationType_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_TransportationType_ID'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('TransportationType_ID','2H00000101')  ;
                                  end;


                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                  end;

                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID','1001000000')  ;
                                  end;

                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                  end;
                                       }


                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsInteger('Acknowledge',1) ;
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('ReasonDescription','Vrácení : 2022.05' );
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Description','Vrácení: 2022.05');



                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;

                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


                                  mMon := TDynSiteForm(mSite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(mSite).CurrentObject.GetFieldCode('ROWS'));
                                    ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                           ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                //mMon.BusinessObject[j].SetFieldValueAsBoolean('ToESL',False);
                                                mMon.BusinessObject[j].SetFieldValueAsinteger('ESLStatus',0);
                                                mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','7000000000');
                                      end;
                                      ProgressDispose();


                                  TDynSiteForm(mSite).CurrentObject.save;
                            //  end else begin
                              //    NxShowSimpleMessage('Nejedná se o firmu INOVORTHO',nil) ;
                            //  end;
                              TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;

              end;





              if true then begin
                             TDynSiteForm(mSite).CurrentObject.SetFieldValueAsInteger('Acknowledge',0) ;
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('ReasonDescription','Jiné' );
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Description','Vraceni z ' + TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Firm_ID.Name') + ' z data ' + FormatDateTime('DD.MM.YYYY',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('Docdate$date') ));



                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000')  ;
                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


                                  mMon := TDynSiteForm(mSite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(mSite).CurrentObject.GetFieldCode('ROWS'));
                                    ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                           ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                //mMon.BusinessObject[j].SetFieldValueAsBoolean('ToESL',False);
                                                mMon.BusinessObject[j].SetFieldValueAsinteger('ESLStatus',1);
                                                mMon.BusinessObject[j].SetFieldValueAsBoolean('ToIntrastat',True);
                                                mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','1T00000000');
                                                mMon.BusinessObject[j].SetFieldValueAsstring('X_Duvod_Vraceni','TZX1100101');


                                      end;
                                      ProgressDispose();


                                  TDynSiteForm(mSite).CurrentObject.save;
                                   TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
                           end;




    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                            if false then begin

                             // if TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.Name')='INOVORTHO' then begin
                             {         if not NxIsEmptyOID(tDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_BankAcount')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('BankAccount_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_BankAcount'))
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('BankAccount_ID','3000000101')  ;
                                  end;
                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_TransportationType_ID')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('TransportationType_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_TransportationType_ID'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('TransportationType_ID','2H00000101')  ;
                                  end;


                                 if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                  end;

                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID','1001000000')  ;
                                  end;

                                  if not NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_')) then begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID',TDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'))  ;
                                  end else begin
                                      TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                  end;
                                          }
                                    TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;

                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;

                                     TDynSiteForm(mSite).CurrentObject.SetFieldValueAsInteger('Acknowledge',1) ;
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('ReasonDescription','Vrácení : 2022.05' );
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Description','Vrácení: 2022.05');




                                       mMon := TDynSiteForm(mSite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(mSite).CurrentObject.GetFieldCode('ROWS'));
                                  //  ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                           ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                mMon.BusinessObject[j].SetFieldValueAsinteger('ESLStatus',0);
                                                mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','7000000000');
                                      end;
                                   //   ProgressDispose();




                                      TDynSiteForm(mSite).CurrentObject.save;
                                      TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
                            //  end else begin
                             //     NxShowSimpleMessage('Nejedná se o firmu INOVORTHO',nil) ;
                            //  end;
                           end;

                           if true then begin


                             TDynSiteForm(mSite).CurrentObject.SetFieldValueAsInteger('Acknowledge',0) ;
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('ReasonDescription','Jiné' );
                                        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Description','Vraceni z ' + TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Firm_ID.Name') + ' z data ' + FormatDateTime('DD.MM.YYYY',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('Docdate$date')) );



                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000')  ;
                                   TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


                                  mMon := TDynSiteForm(mSite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(mSite).CurrentObject.GetFieldCode('ROWS'));
                                   // ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                   //        ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                //mMon.BusinessObject[j].SetFieldValueAsBoolean('ToESL',False);
                                                mMon.BusinessObject[j].SetFieldValueAsinteger('ESLStatus',1);
                                                mMon.BusinessObject[j].SetFieldValueAsBoolean('ToIntrastat',True);
                                                mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','7000000000');
                                                mMon.BusinessObject[j].SetFieldValueAsstring('X_Duvod_Vraceni','1T00000000');


                                      end;
                                    //  ProgressDispose();


                                  try
                                     TDynSiteForm(mSite).CurrentObject.save;
                                  finally

                                  end;
                                   TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
                           end;







         end;
       //  TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
    end;





end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Intrastat dodací podmínky';
  mmAction.Hint := 'Intrastat dodací podmínky';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Intrastat dodací podmínky');
  mMAction.Items.Add('Vratky "21" dodací podmínky');
  mMAction.Items.Add('Dobropis z dceřinky');

  mmAction.OnExecute:= @inovortho;



end;


begin
end.