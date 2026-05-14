procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '@@kopie intrastat';
  mAction.Hint := 'zkopríuje data pro intrastat';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CopyIntrastat;
end;

Procedure CopyIntrastat(sender:TComponent);
Var
 mSite:TSiteForm;
 mCurrBO, mBO:TNxCustomBusinessObject;
 mRoll: Variant;
 mOLE: Variant;
 mStoreCard_ID:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mCurrBO:=TBusRollSiteForm(mSite).CurrentObject;
 if assigned(mCurrBO) then begin
     mOLE := GetAbraOLEApplication;
     mRoll := mOLE.Getroll('S3WZQKDB5FDL342M01C0CX3FCC',0);
     mStoreCard_ID:='0000000000';
     mStoreCard_ID := mRoll.SelectDialog2(True, mStoreCard_ID);
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mBO:=msite.BaseObjectSpace.CreateObject(Class_StoreCard);
       mBO.load(mStoreCard_ID,nil);
       if NxMessageBox('Dotaz','Zkopírovat intrastat údaje '+#13#10+
                               'kód kombinované nomenklatury '+mbo.GetFieldValueAsString('IntrastatCommodity_ID.Code')+#13#10+
                               'hmotnost      '+FloatToStr(mbo.GetFieldValueAsFloat('IntrastatWeight'))+#13#10+
                               'kód země '+mbo.GetFieldValueAsString('country_id.Code')+#13#10+
                               'zvláštní pohyb '+mbo.GetFieldValueAsString('IntrastatExtraType_ID.code')+#13#10+
                                #13#10+'z  '+mbo.DisplayName+#13#10+
                               'do '+mCurrBO.DisplayName+ '?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                  mCurrBO.SetFieldValueAsString('IntrastatCommodity_ID',mbo.GetFieldValueAsString('IntrastatCommodity_ID'));
                  mCurrBO.SetFieldValueAsString('country_id',mbo.GetFieldValueAsString('country_id'));
                  mCurrBO.SetFieldValueAsString('IntrastatExtraType_ID',mbo.GetFieldValueAsString('IntrastatExtraType_ID'));
                  mCurrBO.SetFieldValueAsString('IntrastatInputStatistic_ID',mbo.GetFieldValueAsString('IntrastatInputStatistic_ID'));
                  mCurrBO.SetFieldValueAsString('IntrastatOutputStatistic_ID',mbo.GetFieldValueAsString('IntrastatOutputStatistic_ID'));
                  mCurrBO.SetFieldValueAsFloat('IntrastatWeight',mbo.GetFieldValueAsFloat('IntrastatWeight'));
                  mCurrBO.SetFieldValueAsInteger('IntrastatWeightUnit',mbo.GetFieldValueAsInteger('IntrastatWeightUnit'));
                  mCurrBO.save;
                  TBusRollSiteForm(mSite).RefreshData;
                  TBusRollSiteForm(mSite).DataSet.SeekID(mCurrBO.OID);


       end;
     end;
 end;
end;

begin
end.