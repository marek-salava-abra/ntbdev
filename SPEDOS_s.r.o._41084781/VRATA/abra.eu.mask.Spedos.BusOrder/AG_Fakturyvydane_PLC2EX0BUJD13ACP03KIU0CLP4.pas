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
mi,i:integer;
mr: tstringlist;
mIDS:string ;
mBO:TNxCustomBusinessObject;
mStream:TMemoryStream;
 // dopsáno MASA
 mRows:TNxCustomBusinessMonikerCollection;
 k:integer;
 mBusOrderBO:TNxCustomBusinessObject;
 mCheckDate:Boolean;
 mDate:Extended;
 // konec MASA

begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                  // dopsáno MASA
                     mCheckDate:=False;
                     mRows:=mCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mCustomBusinessObject.GetFieldCode('Rows'));
                     for k:=0 to mRows.Count-1 do begin
                       if not(mCheckDate) then begin
                         if mRows.BusinessObject[k].GetFieldValueAsDateTime('BusOrder_ID.X_ClosedDate')=0 then mCheckDate:=True;
                       end;
                     end;
                     if mCheckDate then GetDate(mDate,mSite);
                     if mDate>0 then begin
                       for k:=0 to mRows.Count-1 do begin
                          if not(NxIsEmptyOID(mRows.BusinessObject[k].GetFieldValueAsString('BusOrder_ID'))) then begin
                            if mRows.BusinessObject[k].GetFieldValueAsDateTime('BusOrder_ID.X_ClosedDate')=0 then begin
                              mBusOrderBO:=msite.BaseObjectSpace.CreateObject(Class_BusOrder);
                              mBusOrderBO.Load(mRows.BusinessObject[k].GetFieldValueAsString('BusOrder_ID'),nil);
                              mBusOrderBO.SetFieldValueAsDateTime('X_ClosedDate', mDate);
                              mBusOrderBO.save;
                              mBusOrderBO.Free;
                            end;
                          end;
                       end;
                     end;

                  // konec MASA
                  mr:=TStringList.create;
                  try
                     msite.BaseObjectSpace.SQLSelect('Select distinct BusOrder_id from issuedinvoices2 where parent_id=' + quotedstr(TDynSiteForm(mSite).CurrentObject.oid) , mr);
                        if mr.count>0 then begin
                           mIDS:='(';
                           for i:=0 to mr.count-1 do begin

                                        if index=0 then begin
                                         mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''A'', bo.x_Change_closed=(select max(head.docdate$date) from issuedinvoices head left join issuedinvoices2 rox on rox.parent_id=head.id where rox.BusOrder_id=' +
                                         quotedstr(mr.Strings[i]) + ') where bo.id=' + quotedstr(mr.Strings[i]));
                                         mBO:=msite.BaseObjectSpace.CreateObject(Class_BusOrder);
                                         mbo.Load(mr.Strings[i],nil);
                                         mStream := TMemoryStream.Create;
                                         try
                                         CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-zakazka.php?',
                                              'user=aBra&password=skS8f-sxR&cis_zak=' + mBO.GetFieldValueAsString('Code') +
                                              '&uzavreno=1',mStream);
                                             //end;
                                         Except
                                         end;
                                         mStream.Free;
                                         mbo.free;
                                         end;
                                        if index=1 then begin
                                        mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''N'', bo.x_Change_closed=' + QuotedStr(NxFloatToIBStr(0)) +
                                        ' where bo.id=' + quotedstr(mr.Strings[i]));
                                        mBO:=msite.BaseObjectSpace.CreateObject(Class_BusOrder);
                                         mbo.Load(mr.Strings[i],nil);
                                         mStream := TMemoryStream.Create;
                                         try
                                         CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-zakazka.php?',
                                              'user=aBra&password=skS8f-sxR&cis_zak=' + mBO.GetFieldValueAsString('Code') +
                                              '&uzavreno=0',mStream);
                                             //end;
                                         Except
                                         end;
                                         mStream.Free;
                                         mbo.free;
                                         end;

                           end;
                        end;

                  finally
                  mr.free;
                  end;
                  if index=1 then mi:=msite.BaseObjectSpace.SQLExecute('update busOrders set X_Closed =''N'',x_Change_closed=' +QuotedStr(NxFloatToIBStr(0)) + ' where id in ' + mIDS);


        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));

                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                      mr:=TStringList.create;
                  try
                     msite.BaseObjectSpace.SQLSelect('Select distinct BusOrder_id from issuedinvoices2 where parent_id=' + quotedstr(TDynSiteForm(mSite).CurrentObject.oid) , mr);
                        if mr.count>0 then begin
                           for i:=0 to mr.count-1 do begin

                                        if index=0 then begin
                                        mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''A'', bo.x_Change_closed=(select max(head.docdate$date) from issuedinvoices head left join issuedinvoices2 rox on rox.parent_id=head.id where rox.BusOrder_id=' +
                                         quotedstr(mr.Strings[i]) + ') where bo.id=' + quotedstr(mr.Strings[i]));
                                         mBO:=msite.BaseObjectSpace.CreateObject(Class_BusOrder);
                                         mbo.Load(mr.Strings[i],nil);
                                         mStream := TMemoryStream.Create;
                                         try
                                         CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-zakazka.php?',
                                              'user=aBra&password=skS8f-sxR&cis_zak=' + mBO.GetFieldValueAsString('Code') +
                                              '&uzavreno=1',mStream);
                                             //end;
                                         Except
                                         end;
                                         mStream.Free;
                                         mbo.free;
                                         end;
                                        if index=1 then begin
                                        mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''N'', bo.x_Change_closed=' + QuotedStr(NxFloatToIBStr(0)) +
                                        ' where bo.id=' + quotedstr(mr.Strings[i]));
                                        mBO:=msite.BaseObjectSpace.CreateObject(Class_BusOrder);
                                         mbo.Load(mr.Strings[i],nil);
                                         mStream := TMemoryStream.Create;
                                         try
                                         CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-zakazka.php?',
                                              'user=aBra&password=skS8f-sxR&cis_zak=' + mBO.GetFieldValueAsString('Code') +
                                              '&uzavreno=0',mStream);
                                             //end;
                                         Except
                                         end;
                                         mStream.Free;
                                         mbo.free;
                                         end;
                           end;
                        end;

                  finally
                  mr.free;
                  end;



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
          mMAction.Hint := 'Obchodní uzavření';
          mMAction.Caption := 'Obchodní uzavření';
          mMAction.Items.Add('Obchodní uzavření');
          mMAction.Items.Add('Obchodní zpetné otevření');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;

Function GetDate(var aDate:TDateTime; var Asite:TSiteForm):boolean;

var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TEdit;
  mEd2: TDateEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte údaje ';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mForm.Position := poScreenCenter;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Datum:';
    mLab.Parent := mForm;
    mEd2 := TDateEdit.Create(mForm);
    mEd2.Left := 110;
    mEd2.Top := 10;
    mEd2.Width := 80;
    mEd2.Date := date;
    mEd2.Parent := mForm;
    CreateButton(mForm, mForm, 30, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 30, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(Asite);
    if mResult = 1 then
      aDate:= mEd2.Date;
  finally
    mForm.Free;
  end;
end;

function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;



begin
end.