
procedure MAterial(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mBookmark:TBookmarkList;
   mImportManager : TNxDocumentImportManager ;
   mImportManagerParams : TNxParameters;
   //mPar : TNxParameter;
begin
 // mtext:='Description=' + quotedstr('');
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
  //  ProgressInit(msite, 'Načtení souboru ' , 100);
   // NxShowSimpleMessage(mMachine_ID,nil);

    if mBookmark.count=0 then begin
               //if index=0 then begin


                      mImportManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'HTI3OTLGNRPO32EEISEPC0XZ0K','2MV0SHPYLFJOL3D4WN02HCPX5S');
                      mImportManagerParams := TNxParameters.Create;


                try
                  mImportManager.AddInputDocument(TDynSiteForm(mSite).CurrentObject.OID);
                        mImportManagerParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := 'V300000101';
                        mImportManagerParams.GetOrCreateParam(dtString, 'Firm_ID').AsString := 'F000000101';
                        mImportManagerParams.GetOrCreateParam(dtDateTime, 'DocDate$DATE').AsDateTime := now;
                        mImportManagerParams.GetOrCreateParam(dtString, 'Division_ID').AsString := 'TA10000101';
                        //mImportManagerParams.GetOrCreateParam(dtString, 'SelectedRows').AsString := '7470000101';
                        //mImportManagerParams.GetOrCreateParam(dtInteger, 'MethodOfMD').AsInteger := 1;
                        //mImportManagerParams.GetOrCreateParam(dtInteger, 'UnitChoice').AsInteger := 0;
                        mImportManagerParams.GetOrCreateParam(dtInteger, 'AutoPrepare').AsInteger := 1;
                        //mImportManagerParams.GetOrCreateParam(dtList, 'Stores').AsList := '3000000101';
                        //mImportManagerParams.GetOrCreateParam(dtInteger, 'BatchAutoFill').AsInteger := 0;
                        //mImportManagerParams.GetOrCreateParam(dtInteger, 'SerialNumberAutoFill').AsInteger := 1;
                        //mImportManagerParams.GetOrCreateParam(dtInteger, 'StrategySelectionDisposition').AsInteger := 1;
                        //mImportManagerParams.GetOrCreateParam(dtInteger, 'ConsiderationDateExpiration').AsInteger := 1;

                  mImportManager.LoadParams(mImportManagerParams);
                  mImportManager.Execute;

                  mImportManager.OutputDocument.SAVE;

                finally
                   mImportManager.free;
                   mImportManagerParams.free;
                end;


                      //        NxShowSimpleMessage(TDynSiteForm(mSite).CurrentObject.oid,nil);

            //  mMachine_ID:='AAA';
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
       //  ProgressSetPos(1+NxFloor((i/mBookmark.Count)*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

         end;
    end;
//ProgressDispose()

end;




procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin


  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'x Materiál';
  mmAction.Hint := 'x Materiál';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('x Materiál');
  mmAction.OnExecuteItem:= @MAterial;


end;

end;





begin
end.