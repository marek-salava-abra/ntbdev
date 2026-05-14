const
 ladit=false;


procedure NEWSLExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mbo_SL:TNxCustomBusinessObject;
 xSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii,k,j:integer;
 mr,mr1,mr2,mIDs_MLRow:TStringList;
 mForm: TBusRollSiteForm;
   mMon,mRows_ML: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1,mbo_ml_target_row: TNxCustomBusinessObject;
   mdate:Double;
   mr_ML,mrax:tstringlist;
   mOLE, mRoll, mOResult: Variant;
   mids,mids1:TStringList;
   mBO_ml,mbo_target:TNxCustomBusinessObject;
   mstavpomoc:boolean;
   mobjednavka:string;
   mpotvrzeni:string;
   mOLEStore, mRollStore, mOResultStore,mOResult1: Variant;
   mOLEStorecard, mRollStorecard, mOResultStorecard: Variant;
   midsStore,midsStorecard:TStringList;
   mStore_id,mStorecard_ID:string;
   mi:integer;
begin
    xSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');


    mBO := TDynSiteForm(xSite).CurrentObject;

        mOLE:= GetAbraOLEApplication;
        mOResult:= mOLE.CreateStrings;
        mRoll:= mOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);
                          if not mRoll.MultiSelectDialog(False, mOResult) then Exit;
                                mids1:= TStringList.Create;
                                try
                                  mids1.Text:= mOResult.Text;
                                  for i:=0 to mids1.count-1 do begin
                                         mi:=xsite.BaseObjectSpace.SQLExecute('update issuedinvoices set firm_ID=' + QuotedStr(mids1.Strings[0])  + ' where id=' + QuotedStr(mbo.OID))    ;
                                         // mi:=xsite.BaseObjectSpace.SQLExecute('update storedocuments set firm_ID=' + QuotedStr(mids1.Strings[0])  + ' where id=' + QuotedStr('')
                                  end;

                                         mr:=TStringList.create;
                                         try
                                             xsite.BaseObjectSpace.SQLSelect('SELECT DISTINCT SD.id from IssuedInvoices2 A JOIN StoreDocuments2 SD2 ON SD2.ID=A.ProvideRow_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID' +
                                             ' WHERE A.Parent_ID=' + quotedstr(mbo.oid) + ' and SD.DocumentType = ' + quotedstr('21'),mr);
                                             if mr.count>0 then begin
                                                  for i:=0 to mr.count-1 do begin
                                                      mi:=xsite.BaseObjectSpace.SQLExecute('update storedocuments set firm_ID=' + QuotedStr(mids1.Strings[0])  + ' where id=' + QuotedStr(mr.Strings[i]));
                                                  end;
                                             end;
                                         finally
                                             mr.free;
                                         end;




                                 finally
                                    mids.free;
                                 end;


    TDynSiteForm(xSite).RefreshData;
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
            if mUser.GetFieldValueAsString('Name')='Buriánková Alena' then mUserFilter:= true;
  finally
    mUser.Free;
  end;

 // if mUserFilter then begin
        mMAction := Self.GetNewMultiAction;
        mMAction.ShowControl := True;
        mMAction.ShowMenuItem := True;
        mMAction.Caption := 'Změna fakturačních údajů';
        mMAction.Hint := 'Změna fakturačních údajů';
        mMAction.Category := 'tabList';
        mMAction.OnExecuteItem := @NEWSLExecuteItem;
        mMAction.Items.Add('Změna fakturačních údajů');
 //  end;
end;





begin
end.