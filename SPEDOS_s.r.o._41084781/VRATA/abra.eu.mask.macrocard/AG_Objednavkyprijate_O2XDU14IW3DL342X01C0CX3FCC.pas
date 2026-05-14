Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;

procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
    zadej:string;
    mfilename:string;
    mdir,mfile:string;
    mfilter:string;
    mresult:Boolean;
    mStringlist:TStringList;
    mid:string;
    mid_report:string;
    mi:integer;
    adir,afilename:string;
mOLE, mRoll, mOResult: Variant;
mUser:TNxCustomBusinessObject;
mpocet:string;
mzruseni:boolean;
stav:boolean;
mr:tstringlist;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');





          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
              if index=0 then begin
                 mID := NewDL(mCustomBusinessObject);
                    if not NxIsEmptyOID(mID) then
                        mSite.ShowDynForm('B10I5SAOS3DL3ACU03KIU0CLP4', Nil, Nil, False, 'DoEdit;'+mID);
              end;
              if index=1 then begin
                 mID := NewPHV(mCustomBusinessObject);
                  if not NxIsEmptyOID(mID) then
                    mSite.ShowDynForm('B10I5SAOS3DL3ACU03KIU0CLP4', Nil, Nil, False, 'DoEdit;'+mID);


              end;

              if index=2 then begin
                 mID := NewDLV(mCustomBusinessObject);
                    if not NxIsEmptyOID(mID) then
                        mSite.ShowDynForm('B10I5SAOS3DL3ACU03KIU0CLP4', Nil, Nil, False, 'DoEdit;'+mID);
              end;


        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
             end;
        end;
     try


        finally
        end;
        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;




procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Makrokarta';
          mMAction.Caption := 'Makrokarta';
          mMAction.Items.Add('Makrokarta - výdej');
          mMAction.Items.Add('Makrokarta - příjem');
          mMAction.Items.Add('Výdej - DL');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


function NewDL(ABO: TNxCustomBusinessObject): string;
var
  mDL: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mOID : TNxOID;
  mIM : TNxDocumentImportManager;
  mImportedRows, mS : string;
  x : TNxParameters;
  mHead : TNxHeaderBusinessObject;
  mSList : TStringList;
begin
  result := '';
  try
    mIM := NxCreateDocumentImportManager(abo.ObjectSpace, Class_Receivedorder, Class_BillOfDelivery);
          mIM.AddInputDocument(abo.OID);

      x := TNxParameters.Create;
      try
        x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := 'P100000101';
        x.GetOrCreateParam(dtString, 'Firm_ID', pkInput).AsString := 'AG21000101';
        mIM.LoadParams(x);
      finally
        x.Free;
      end;
      mIM.Execute;
      mHead := TNxHeaderBusinessObject(mIM.OutputDocument);
  //    if mHead.GetFieldValueAsString('docqueue_ID')<>'9200000101' then begin

              for i := 0 to mHead.Rows.Count - 1 do begin
                 if mHead.Rows.BusinessObject[i].GetFieldValueAsInteger('Rowtype') = 3 then begin
                         if mHead.Rows.BusinessObject[i].getFieldValueAsString('Storecard_ID.name')=mHead.Rows.BusinessObject[i].getFieldValueAsString('X_group_macro_id.name') then begin

                                mHead.Rows.BusinessObject[i].MarkForDelete;
                         end;
                 end;
              end;
   //    end;
       TDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4',NxCreateContext(ABO.ObjectSpace), mHead);
      Result := mHead.DisplayName;
    finally
      mIM.Free;
    end;

end;



function newPHV(ABO: TNxCustomBusinessObject): string;
var
  mDL: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mDL := ABO.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', 'AG21000101');
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    mDL.SetFieldValueAsString('DocQueue_ID', 'U100000101');
    mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    try
      for i := 0 to mMon.Count-1 do begin
        mRow := mMon.BusinessObject[i];
        mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
        mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
      end;
      mList.Sort;
      mMon := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        if mRow.GetFieldValueAsInteger('RowType')=3 then begin
                  if mRow.getFieldValueAsString('Storecard_ID.name')=mRow.getFieldValueAsString('X_group_macro_id.name') then begin
                          mNewRow := mMon.AddNewObject;
                          mNewRow.SetFieldValueAsInteger('RowType',3 );
                          mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                          mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                          mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                          mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                          mNewRow.SetFieldValueAsFLoat('Unitprice', mRow.GetFieldValueAsFloat('Unitprice'));

                          //mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                          mNewRow.SetFieldValueAsString('Division_ID', 'D000000101');         // 702
                          mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                  mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
                  end;
        end;
      end;
    finally
      mList.Free;
    end;
    TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4',NxCreateContext(mDL.ObjectSpace), mDL);
  finally
    mDL.Free;
  end;
end;




function NewDLV(ABO: TNxCustomBusinessObject): string;
var
  mDL: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mOID : TNxOID;
  mIM : TNxDocumentImportManager;
  mImportedRows, mS : string;
  x : TNxParameters;
  mHead : TNxHeaderBusinessObject;
  mSList : TStringList;
begin
  result := '';
  try
    mIM := NxCreateDocumentImportManager(abo.ObjectSpace, Class_Receivedorder, Class_BillOfDelivery);
          mIM.AddInputDocument(abo.OID);

      x := TNxParameters.Create;
      try
        x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := 'O100000101';
        x.GetOrCreateParam(dtString, 'Firm_ID', pkInput).AsString := abo.GetFieldValueAsString('Firm_ID');
        mIM.LoadParams(x);
      finally
        x.Free;
      end;
      mIM.Execute;
      mHead := TNxHeaderBusinessObject(mIM.OutputDocument);

      for i := 0 to mHead.Rows.Count - 1 do begin
         if mHead.Rows.BusinessObject[i].GetFieldValueAsInteger('Rowtype') = 3 then begin
               if not(mHead.Rows.BusinessObject[i].getFieldValueAsString('Storecard_ID.name')=mHead.Rows.BusinessObject[i].getFieldValueAsString('X_group_macro_id.name')) then begin

                      mHead.Rows.BusinessObject[i].MarkForDelete;
               end;
         end;
      end;
       TDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4',NxCreateContext(ABO.ObjectSpace), mHead);
      Result := mHead.DisplayName;
    finally
      mIM.Free;
    end;

end;

begin
end.