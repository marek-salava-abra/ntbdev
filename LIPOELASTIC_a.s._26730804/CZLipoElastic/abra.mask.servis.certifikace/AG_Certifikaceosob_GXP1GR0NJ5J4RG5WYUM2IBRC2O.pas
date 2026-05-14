uses 'EU.Aabra.Mask.Validace.lib';
const
 ladit=false;


procedure Person(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mbo_SL:TNxCustomBusinessObject;
 xSite: TBusRollSiteForm;
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
begin
    xSite := TComponent(Sender).BusRollSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');


    mBO := TBusRollSiteForm(xSite).CurrentObject;


        mOLE:= GetAbraOLEApplication;
        mOResult:= mOLE.CreateStrings;
        if index=0 then mRoll:= mOLE.GetRoll('K1MQ4TFKGJD13E3C01K0LEIOE0', 0);
        if index=1 then mRoll:= mOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);

                          if not mRoll.MultiSelectDialog(False, mOResult) then Exit;
                                mids1:= TStringList.Create;
                                try
                                  mids1.Text:= mOResult.Text;
                                  for i:=0 to mids1.count-1 do begin


                                          mbo_target:=mbo.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                          try
                                            mbo_target:=mbo.Clone;
                                            if index=0 then  begin
                                                mbo_target.SetFieldValueAsString('X_Person_id',mids1.Strings[i]);
                                                mbo_target.SetFieldValueAsString('X_Firm_ID','');
                                            end;
                                            if index=1 then begin
                                                mbo_target.SetFieldValueAsString('X_Firm_ID',mids1.Strings[i]);
                                                mbo_target.SetFieldValueAsString('X_Person_id','')
                                            end;
                                            mbo_target.Save ;
                                          finally
                                            mbo_target.free;
                                          end;
                                  end;
                                 finally
                                    mids.free;
                                 end;
    TBusRollSiteForm(xSite).RefreshData;
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


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Hromadné plnění certifikce osob';
  mMAction.Hint := 'Hromadné plnění certifikce osob ';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @Person;
  mMAction.Items.Add('Hromadné plnění certifikce osob');
  mMAction.Items.Add('Hromadné plnění certifikce Firem');
end;





begin
end.