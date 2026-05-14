uses 'abra.eu.MASK.funkce_ctecky2017.Base_function','abra.eu.MASK.funkce_ctecky2017.Libs','abra.eu.MASK.funkce_ctecky2017.Forms';

procedure AfterSiteOpen_Hook(Self: TDynSiteForm);
var
xsite:TDynSiteForm;
mBResult:boolean;
begin
//xSite:= self;
//    mBresult:=CteckaItem(xsite);
//   xsite.Refresh;
end;



procedure InitSite_Hook(Self: TSiteForm);
var

  mUser: TNxCustomBusinessObject;
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mC: TControl;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
           // if (mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                 mAList := Self.GetMainActionList;
                  for i := 0 to mAList.ActionCount-1 do begin
                    mAction := mALIst.Actions[i];
                          if (mAction.Name = 'actFind') then begin
                              mAction.Visible := False;
                          end;
                          if (mAction.Name = 'actFindNext') then begin
                              mAction.Visible := False;
                          end;
                          //if (mAction.Name = 'actShowAgenda') then begin
                          //    mAction.Visible := False;
                          //end;
                   end;



                  mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Ctecka 2017';
                  mMAction.Hint := 'Čtečka 2017 ';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @StartItem;
                  mMAction.Items.Add('Čtečka');

                  mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Manipulace se skladem';
                  mMAction.Hint := 'DL/PRV';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @RowOperationOnPrijem;
                  mMAction.Items.Add('Aktuální doklad');

            //if Self.CompanyCache.GetUserID='SUPER00000' then begin
                  mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Zajistit výrobu';
                  mMAction.Hint := 'Výroba';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @Vyroba_orderItem;
                  mMAction.Items.Add('Aktuální doklad');
                  //mMAction.Items.Add('Všechny');


            //end;


  finally
      mUSer.free;
  end;
end;

Procedure StartItem(sender:tcomponent;index:integer);
var
xsite:TDynSiteForm;
mBResult:boolean;
begin
xSite := TComponent(Sender).DynSite;
    mBresult:=CteckaItem(xsite);
    xsite.Refresh;
end;


procedure RowOperationOnPrijem(Sender: Tcomponent);
var
  mSite : TDynSiteForm;
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
  mBO : TNxCustomBusinessObject;
  mMon,mrowsOutput,mrowsinput,mrowsOutput1,mrowsinput1,mrows: TNxCustomBusinessMonikerCollection;
  ii,jj:integer;
  mEAN,mOldEan:string;
  mPokracovani:Boolean;
  mstorecard_ID:string;
  mr:TStringList;
  mpocet,mpomoc_pocet:double;
  mManager,mManager1 : TNxDocumentImportManager ;
  mParams,mParams1, mP : TNxParameters;
  mPar : TNxParameter;
  mi:integer;
  mbo_PRV,mbo_OP:TNxCustomBusinessObject;
  mid:string;
  mxpocet:integer;
begin
 mSite := TComponent(Sender).DynSite;

       mxpocet:=0;
        mDBGrid := TMultiGrid(NxFindChildControl(msite.MainPanel, 'grdRows'));
  try
        if NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_id.X_Cilovy_sklad')) then begin
             mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','050I5SAOS3DL3ACU03KIU0CLP4') ;
        end else begin
             mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','0P0I5SAOS3DL3ACU03KIU0CLP4');
        end;
        try

                mParams := TNxParameters.Create();
                //mList := tStringlist.create;
                try
                  mManager.AddInputDocument(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_id'));
                  if NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_id.X_Cilovy_sklad')) then begin
                        mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_id.DocQueue_ID.X_Delivery_ID');
                  end else begin
                     mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_id.DocQueue_ID.X_Prevodka_ID');
                       end;

                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));
                  if not (NxIsEmptyOID(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_id.X_Cilovy_sklad'))) then begin
                     mManager.OutputDocument.SetFieldValueAsString('IncomingTransferStore',mManager.InputDocument.GetFieldValueAsString('X_Cilovy_sklad'));
                  end;

                  //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
                  mRowsInput := mManager.inputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.inputDocument.GetFieldCode('Rows'));
                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  for ii:=0 to mRowsOutput.Count-1 do begin
                      for jj:=0 to mRowsinput.Count-1 do begin
                            if mRowsOutput.BusinessObject[ii].getFieldValueAsString('Storecard_ID') = mrowsinput.BusinessObject[jj].getFieldValueAsString('Storecard_ID')  then begin

                                    mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsinput.BusinessObject[jj].getFieldValueAsFloat('X_vychystano'));
                                    mxpocet:=mxpocet+1;
                                    if mRowsoutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')=0 then begin
                                            mRowsoutput.BusinessObject[ii].MarkForDelete;
                                            mxpocet:=mxpocet-1;
                                    end;//NxShowSimpleMessage(NxFloatToIBStr(mRowsinput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano')),nil);
                            end;
                      end;
                  end;

                  if mxpocet>0 then mManager.OutputDocument.Save;

                  //mid:=mManager.OutputDocument.oid;

   //               NxShowSimpleMessage('Převodka ' + mManager.OutputDocument.GetFieldValueAsString('Docqueue_ID.code') + ' - ' +
   //                                  inttostr(mManager.OutputDocument.GetFieldValueAsInteger('ordnumber')) + '/' +
   //                                  mManager.OutputDocument.GetFieldValueAsString('Period_ID.code') + ' byla vytvořena',nil);


                finally
                  mManager.Free;
                  //mOP.Free;
                  mParams.free;
                  //mList.Free;
                end;
         //mSite.CurrentObject.Refresh;

                 if mxpocet>0 then begin
                  mbo_OP:=mSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');

                  try
                     mbo_OP.load(mSite.CurrentObject.GetFieldValueAsString('parent_id'),nil);

                              mRows := mbo_OP.GetLoadedCollectionMonikerForFieldCode(mbo_OP.GetFieldCode('Rows'));

                              for jj:=0 to mRows.Count-1 do begin
                                  mRows.BusinessObject[jj].setFieldValueAsFloat('X_vychystano',0);
                                  //if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;
                             end;
                                mbo_OP.setFieldValueAsFloat('X_vychystano',0);
                                mbo_OP.save;
                  finally
                      mbo_OP.free;
                  end;
                  end;
    //            mbo.save;



  finally
      //mParams.free;
  end;
  finally
      //mManager.free;
  end;
  mpocet:=0;
TDynSiteForm(mSite).CurrentObject.Refresh;
msite.RefreshData;
end;



begin
end.
