uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

function NewDL(ABO: TNxCustomBusinessObject): string;
var
  mpoz: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mDocBatchRowSource,mDocBatchRow: TNxCustomBusinessObject;
  mList,mr: TStringList;
  mText: string;
  mPocetDokladu,mPocetVyrobku:double;
begin
  result := '';
  mPocetDokladu:=0;
  mPocetVyrobku:=0;




















end;

procedure NewPOZExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount,i:integer;
  mRow,mPOZ, mBO_source: TNxCustomBusinessObject;
  mID: string;
  mPocetDokladu,mPocetVyrobku:double;
  mMon:TNxCustomBusinessMonikerCollection;
  mList,mr: TStringList;
  mText: string;
begin
  mPocetDokladu:=0;
  mPocetVyrobku:=0;
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

                      end;
                      for mICount:=0 to mIBookmark do begin

                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));


                          end;


                          mbo_source:=TDynSiteForm(msite).CurrentObject;
                          mMon := mbo_source.GetLoadedCollectionMonikerForFieldCode(mbo_source.GetFieldCode('ROWS'));
                                       ProgressInit(msite, 'Zpracování dat ' + '', 100);
                                        for i := 0 to mMon.Count-1 do begin
                                          mRow := mMon.BusinessObject[i];
                                             ProgressSetPos(1+NxFloor(mi/mMon.Count*99), inttostr(i) +' z '+inttostr(mMon.Count));
                                             if mrow.GetFieldValueAsBoolean('Storecard_ID.ISproduct') then begin

                                                     mpoz := TDynSiteForm(msite).BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                                                            try
                                                              mPOZ.New;
                                                              mPOZ.Prefill;
                                                              mPOZ.SetFieldValueAsString('DocQueue_ID','4712000101');
                                                              mPOZ.SetFieldValueAsString('Firm_ID', mbo_source.GetFieldValueAsString('Firm_ID'));
                                                              mPOZ.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                              mPOZ.SetFieldValueAsString('Store_ID', '51A1000101');
                                                              mPOZ.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                              mPOZ.SetFieldValueAsFloat('Quantity', mRow.GetFieldValueAsfloat('Quantity'));
                                                              mPOZ.SetFieldValueAsFloat('CorrectedQuantity', mRow.GetFieldValueAsfloat('Quantity'));
                                                            // mPOZ.SetFieldValueAsString('CorrectedUnitQuantity', mRow.GetFieldValueAsString('QUnit'));



                                                              mPOZ.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                              mPOZ.SetFieldValueAsString('BusProject_ID', mRow.GetFieldValueAsString('BusProject_ID'));
                                                              mPOZ.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

                                                              mPOZ.ClearValidateErrors;

                                                                              if Not mPOZ.Validate() then begin
                                                                                mList := TStringList.Create;
                                                                                try
                                                                                  mPOZ.GetValidateErrors(mList);
                                                                                  mText := mList.Text;
                                                                                  NxToken(mText, '=');
                                                                                  MessageDlg('Automaticky vytvořeny POZ nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                                                    mtWarning, [mbOK], 0);
                                                                                finally
                                                                                  mList.Free;
                                                                                end;
                                                                              end else begin
                                                                                mPOZ.Save;

                                                                                mPocetDokladu:=mPocetDokladu+1;
                                                                                mPocetVyrobku:=mPocetVyrobku+mPOZ.getFieldValueAsFloat('Quantity');
                                                                              end;
                                                            finally
                                                                  mPOZ.Free;
                                                            end;
                                                         end else begin
                                                           NxShowSimpleMessage('Položka ' + mrow.GetFieldValueAsString('Storecard_ID.displayname') + ' není označena jako výrobek a nebude s ní pracováno ',nil);
                                                         end;




                                        end;

                                       ProgressDispose()



                      end;
                     // if mBookmark.count>0 then     ;
                end;
            end;
    end;

     NxShowSimpleMessage('Bylo vytvořeno ' + NxFloatToIBStr(mPocetDokladu) + ' dokladů , a zajištěno :' +  NxFloatToIBStr(mPocetVyrobku) + ' jednotek' , msite);




end;



procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Požadavek na výrobu';
  mAction.Hint := 'Požadavek na výrobu';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @NewPOZExecute;

end;

begin
end.