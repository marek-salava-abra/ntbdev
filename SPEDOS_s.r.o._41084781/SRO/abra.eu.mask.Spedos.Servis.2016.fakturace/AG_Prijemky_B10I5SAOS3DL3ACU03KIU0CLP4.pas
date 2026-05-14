var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
    mBustrasaction_ID:string;

procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mdoc_number:string;
   mcount:integer;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
      mIDs_MLRow:=TStringList.create;
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mBO1 := TDynSiteForm(mSite).CurrentObject;
                                mMon := mbo1.GetLoadedCollectionMonikerForFieldCode(mbo1.GetFieldCode('ROWS'));

                                for ii := 0 to mMon.Count-1 do begin
                                      mIDs_MLRow.Add(mMon.BusinessObject[ii].OID);
                                end;
                   end else begin
                          try
                                for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                        mBO1 := TDynSiteForm(mSite).CurrentObject;
                                                                  mr:=TStringList.create;
                                            mMon := mbo1.GetLoadedCollectionMonikerForFieldCode(mbo1.GetFieldCode('ROWS'));
                                            for ii := 0 to mMon.Count-1 do begin
                                                 mIDs_MLRow.Add(mMon.BusinessObject[ii].OID);
                                            end;

                                end;
                           finally
                               mr.free;
                           end;
                  end;

          if mIDs_MLRow.Count>0 then begin
                mcount:=0;
                try
                mbo:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                mBO.New;
                mBO.Prefill;
                mBO.SetFieldValueAsString('Docqueue_ID', '7D00000101');
                //mHeaderBO.SetFieldValueAsString('Description', 'Reklamace_dokladu:');
                mBO.SetFieldValueAsString('Firm_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('U_dodavatel'));
                mdoc_number:=mbo1.GetFieldValueAsString('Docqueue_ID.Code') + '-'+
                  inttostr(mbo1.GetFieldValueAsInteger('ordnumber')) +'/'+
                  mbo1.GetFieldValueAsstring('Period_ID.Code') ;
                mBO.SetFieldValueAsString('Description',mdoc_number);
                //mBO.SetFieldValueAsString('PaymentType_ID', mbo1.GetFieldValueAsString('X_PaymenType_ID'));
                mBO.SetFieldValueAsBoolean('IsRowDiscount',true);

                              mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));

                                  mRow:= mbo.ObjectSpace.CreateObject('FLQIA44IVWM4B20GYRHC42BHGW');
                                  for i := 0 to mIDs_MLRow.Count-1 do begin
                                                try
                                                  mRow.Load(mIDs_MLRow.Strings[i],nil);
                                                  mr:=tstringlist.create;
                                                  try
                                                      mbo.ObjectSpace.SQLSelect('select SD2.id from IssuedInvoices2 SD2 left join IssuedInvoices SD on SD.ID=sD2.Parent_ID where sD2.X_parent_id=' + quotedstr(mRow.GetFieldValueAsString('X_parent_ID')),mr);
                                                      if mr.count>0 then begin
                                                          for i:=0 to mr.count-1 do begin
                                                                if mr.Strings[0]=mdoc_number+' - '+mRow.GetFieldValueAsString('Storecard_ID.Code') + ' - ' +mRow.GetFieldValueAsString('Storecard_ID.Name') then begin

                                                                end else begin
                                                                     mNewRow := mMon.AddNewObject;

                                                                      mNewRow.SetFieldValueAsInteger('RowType', 2);

                                                                      mNewRow.SetFieldValueAsString('Text',mdoc_number+' - '+mRow.GetFieldValueAsString('Storecard_ID.Code') + ' - ' +mRow.GetFieldValueAsString('Storecard_ID.Name'));
                                                                      mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                      mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                      mNewRow.SetFieldValueAsFLoat('UnitPrice', mRow.GetFieldValueAsFloat('UnitPrice'));
                                                                      mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('BusTransaction_ID'));
                                                                      mNewRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Division_ID'));
                                                                      mNewRow.SetFieldValueAsString('IncomeType_ID','1Q00000101');
                                                                      mNewRow.SetFieldValueAsString('BusOrder_ID',mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                      mNewRow.SetFieldValueAsString('VATRate_ID', '02100X0000');
                                                                      mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('X_parent_ID'));

                                                                      mcount:=mcount+1;
                                                              end;
                                                          end;
                                                      end else begin
                                                         mNewRow := mMon.AddNewObject;

                                                                      mNewRow.SetFieldValueAsInteger('RowType', 2);

                                                                      mNewRow.SetFieldValueAsString('Text',mdoc_number+' - '+mRow.GetFieldValueAsString('Storecard_ID.Code') + ' - ' +mRow.GetFieldValueAsString('Storecard_ID.Name'));
                                                                      mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                      mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                      mNewRow.SetFieldValueAsFLoat('UnitPrice', mRow.GetFieldValueAsFloat('UnitPrice'));
                                                                      mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('BusTransaction_ID'));
                                                                      mNewRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Division_ID'));
                                                                      mNewRow.SetFieldValueAsString('IncomeType_ID','1Q00000101');
                                                                      mNewRow.SetFieldValueAsString('BusOrder_ID',mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                      mNewRow.SetFieldValueAsString('VATRate_ID', '02100X0000');
                                                                      mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('X_parent_ID'));
                                                                      mcount:=mcount+1;
                                                      end;
                                                  finally
                                                     mr.free;
                                                  end;




                                                finally

                                                    mrow.free;
                                                end;
                                  end;
                 if mcount=0 then begin
                      NxShowSimpleMessage('Není co fakturovat, Zdrojový doklad neobsahuje řádek, nebo již bylo vyfakturováno:',nil);
                 end else begin
                     TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBO);
                 end;
              finally
                  mbo.Free;
              end;
           end;
        finally

        end;
       finally
         mIDs_MLRow.free;
              end;

end;



procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
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
{  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace / záruka';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItem;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace / záruka i nulové';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItemwithnull;


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace -logistika';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItemLOG;


//  mAction := Self.GetNewAction;
//  mAction.ShowControl := True;
//  mAction.ShowMenuItem := True;
//  mAction.Caption := 'Zobraz fakturu';
//  mAction.Hint := 'Zobrazí vystavenou fakturu';
//  mAction.Category := 'tabList';
//  mAction.OnExecute := @FVShowExecuteItem;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Povolit znovu fakturovat';
  mAction.Hint := 'Částečná fakturace';
  mAction.Category := 'tabList';
  mAction.OnExecute := @FVeditItem;  }

   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Fakturace';
  mMAction.Hint := 'Operace dispečera servisu';
  mMAction.Category := 'tabList';
//  mMAction.OnUpdate := @FVOnExekute;
  mMAction.OnExecuteItem := @FVOnExekute;
  mMAction.Items.Add('Fakturace - reklamace');
//  mMAction.Items.Add('Zobraz doklad');

end;

procedure FVOnExekute(Sender: TAction;index:integer;);
begin
if index=0 then FVExecuteItem(sender,index);
end ;



begin
end.