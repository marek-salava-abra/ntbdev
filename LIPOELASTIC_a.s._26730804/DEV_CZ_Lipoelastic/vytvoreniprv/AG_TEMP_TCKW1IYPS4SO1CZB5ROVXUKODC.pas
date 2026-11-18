 uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
var
     mBookmark : TBookmarkList;






procedure plneni(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mrx:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   msave:Boolean;
   mIDHead,MidRow:string;
   mboolean:Boolean;
   mpocet,mvraceno,mporovnani:double;
   mHead:TNxHeaderBusinessObject;
   mBO_Row:TNxCustomBusinessObject;
   mRow:TNxCustomBusinessObject;
begin

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
   // mbo:= TBusRollSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);


   try
            mHead := TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));
            mHead.New;
            mHead.Prefill;
            mHead.SetFieldValueAsString('DocQueue_ID', '9400000101');
            mBO_Row := TBusRollSiteForm(mSite).CurrentObject;
            mHead.SetFieldValueAsString('Firm_ID', mBO_row.GetFieldValueAsString('X_Firm_ID'));
                //NxShowSimpleMessage(inttostr(mBookmark.Count),nil);
                  if mBookmark.Count=0 then begin
                        mBO_Row := TBusRollSiteForm(mSite).CurrentObject;
                        mRow := mhead.Rows.AddNewObject;
                        mRow.Prefill;
                        mRow.SetFieldValueAsInteger('RowType',3); //Typ radku je 1
                        mRow.SetFieldValueAsString('Store_ID','2G10000101'); //text bude  ...
                        mRow.SetFieldValueAsString('Storecard_ID',mBO_row.GetFieldValueAsString('X_Storecard_ID')); //text bude  ...
                        //mRow.SetFieldValueAsString('BusOrder_ID',mBO_row.GetFieldValueAsString('BusOrder_ID')); //text bude  ...
                        mRow.SetFieldValueAsFloat('Quantity',mBO_row.GetFieldValueAsFloat('X_Quantity')); //text bude  ...
                        mRow.SetFieldValueAsString('Division_ID','1N00000101');
                        //mRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('StoreCard_ID.X_Obchodni_pripad'));
                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                              if mBookmark.Count > 0 then begin
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                     mBO_Row := TBusRollSiteForm(mSite).CurrentObject;
                                      mRow := mhead.Rows.AddNewObject;
                                      mRow.Prefill;
                                mRow.SetFieldValueAsInteger('RowType',3); //Typ radku je 1
                        mRow.SetFieldValueAsString('Store_ID','2G10000101'); //text bude  ...
                        mRow.SetFieldValueAsString('Storecard_ID',mBO_row.GetFieldValueAsString('X_Storecard_ID')); //text bude  ...
                        //mRow.SetFieldValueAsString('BusOrder_ID',mBO_row.GetFieldValueAsString('BusOrder_ID')); //text bude  ...
                        mRow.SetFieldValueAsFloat('Quantity',mBO_row.GetFieldValueAsFloat('X_Quantity')); //text bude  ...
                        mRow.SetFieldValueAsString('Division_ID','1N00000101');


                              end;
                          end;
                  end;


                  mHead.save ;
            //      NxShowSimpleMessage('Byl vytvořen doklad',nil);
            //  end;
        finally
              mhead.free;
        end;











end;


procedure InitSite_Hook(Self: TBusRollSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
//if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'prevodka vydej';
  mmAction.Hint := 'prevodka vydej';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('prevodka vydej');
  mmAction.OnExecute:= @plneni;



//end ;


end;




begin
end.